-- ============================================================================
-- Atomic Wallet Transaction Functions
-- ============================================================================
-- These functions ensure all wallet operations are atomic (all-or-nothing)
-- to prevent race conditions and data inconsistencies.
--
-- Run this migration in your Supabase SQL Editor or via supabase db push
-- ============================================================================

-- Function: Process wallet top-up atomically
-- Used when user adds money to wallet via Razorpay
CREATE OR REPLACE FUNCTION process_wallet_topup(
  p_profile_id UUID,
  p_amount DECIMAL,
  p_razorpay_order_id TEXT,
  p_razorpay_payment_id TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_wallet_id UUID;
  v_old_balance DECIMAL;
  v_new_balance DECIMAL;
  v_transaction_id UUID;
  v_result JSON;
BEGIN
  -- Lock the wallet row to prevent concurrent modifications
  SELECT id, balance INTO v_wallet_id, v_old_balance
  FROM wallets
  WHERE profile_id = p_profile_id
  FOR UPDATE;

  IF v_wallet_id IS NULL THEN
    RAISE EXCEPTION 'Wallet not found for profile %', p_profile_id;
  END IF;

  -- Calculate new balance
  v_new_balance := v_old_balance + p_amount;

  -- Create transaction record
  INSERT INTO wallet_transactions (
    wallet_id,
    amount,
    transaction_type,
    description,
    reference_id,
    metadata
  ) VALUES (
    v_wallet_id,
    p_amount,
    'credit',
    'Wallet top-up via Razorpay',
    p_razorpay_payment_id,
    jsonb_build_object(
      'razorpay_order_id', p_razorpay_order_id,
      'razorpay_payment_id', p_razorpay_payment_id,
      'type', 'topup'
    )
  )
  RETURNING id INTO v_transaction_id;

  -- Update wallet balance
  UPDATE wallets
  SET balance = v_new_balance,
      updated_at = NOW()
  WHERE id = v_wallet_id;

  -- Log activity
  INSERT INTO activity_logs (
    profile_id,
    action,
    action_category,
    description,
    metadata
  ) VALUES (
    p_profile_id,
    'payment_verified',
    'payment',
    'Wallet top-up: ' || p_razorpay_payment_id,
    jsonb_build_object(
      'payment_id', p_razorpay_payment_id,
      'amount', p_amount,
      'type', 'topup',
      'old_balance', v_old_balance,
      'new_balance', v_new_balance
    )
  );

  -- Build result
  v_result := json_build_object(
    'success', true,
    'transaction_id', v_transaction_id,
    'old_balance', v_old_balance,
    'new_balance', v_new_balance
  );

  RETURN v_result;
END;
$$;

-- Function: Process project payment via Razorpay atomically
-- Used when user pays for a project directly via Razorpay
CREATE OR REPLACE FUNCTION process_razorpay_project_payment(
  p_profile_id UUID,
  p_project_id UUID,
  p_amount DECIMAL,
  p_razorpay_order_id TEXT,
  p_razorpay_payment_id TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_wallet_id UUID;
  v_project_status TEXT;
  v_transaction_id UUID;
  v_result JSON;
BEGIN
  -- Get wallet (for transaction record)
  SELECT id INTO v_wallet_id
  FROM wallets
  WHERE profile_id = p_profile_id;

  IF v_wallet_id IS NULL THEN
    RAISE EXCEPTION 'Wallet not found for profile %', p_profile_id;
  END IF;

  -- Lock and verify project
  SELECT status INTO v_project_status
  FROM projects
  WHERE id = p_project_id AND user_id = p_profile_id
  FOR UPDATE;

  IF v_project_status IS NULL THEN
    RAISE EXCEPTION 'Project not found or unauthorized';
  END IF;

  -- Create transaction record
  INSERT INTO wallet_transactions (
    wallet_id,
    amount,
    transaction_type,
    description,
    reference_id,
    metadata
  ) VALUES (
    v_wallet_id,
    p_amount,
    'debit',
    'Payment for project',
    p_razorpay_payment_id,
    jsonb_build_object(
      'razorpay_order_id', p_razorpay_order_id,
      'razorpay_payment_id', p_razorpay_payment_id,
      'type', 'project_payment',
      'project_id', p_project_id
    )
  )
  RETURNING id INTO v_transaction_id;

  -- Update project status
  UPDATE projects
  SET is_paid = true,
      paid_at = NOW(),
      payment_id = p_razorpay_payment_id,
      status = 'payment_confirmed',
      updated_at = NOW()
  WHERE id = p_project_id;

  -- Create status history entry
  INSERT INTO project_status_history (
    project_id,
    old_status,
    new_status,
    changed_by,
    notes
  ) VALUES (
    p_project_id,
    v_project_status,
    'payment_confirmed',
    p_profile_id,
    'Payment received via Razorpay'
  );

  -- Log activity
  INSERT INTO activity_logs (
    profile_id,
    action,
    action_category,
    description,
    metadata
  ) VALUES (
    p_profile_id,
    'payment_verified',
    'payment',
    'Project payment: ' || p_razorpay_payment_id,
    jsonb_build_object(
      'payment_id', p_razorpay_payment_id,
      'amount', p_amount,
      'type', 'project_payment',
      'project_id', p_project_id
    )
  );

  -- Build result
  v_result := json_build_object(
    'success', true,
    'transaction_id', v_transaction_id,
    'project_id', p_project_id
  );

  RETURN v_result;
END;
$$;

-- Function: Process wallet payment for project atomically
-- Used when user pays for a project using wallet balance
CREATE OR REPLACE FUNCTION process_wallet_project_payment(
  p_profile_id UUID,
  p_project_id UUID,
  p_amount DECIMAL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_wallet_id UUID;
  v_old_balance DECIMAL;
  v_new_balance DECIMAL;
  v_project_status TEXT;
  v_project_number TEXT;
  v_is_paid BOOLEAN;
  v_transaction_id UUID;
  v_result JSON;
BEGIN
  -- Lock the wallet row to prevent concurrent modifications
  SELECT id, balance INTO v_wallet_id, v_old_balance
  FROM wallets
  WHERE profile_id = p_profile_id
  FOR UPDATE;

  IF v_wallet_id IS NULL THEN
    RAISE EXCEPTION 'Wallet not found for profile %', p_profile_id;
  END IF;

  -- Check sufficient balance
  IF v_old_balance < p_amount THEN
    RAISE EXCEPTION 'Insufficient balance. Available: %, Required: %', v_old_balance, p_amount;
  END IF;

  -- Lock and verify project
  SELECT status, project_number, is_paid
  INTO v_project_status, v_project_number, v_is_paid
  FROM projects
  WHERE id = p_project_id AND user_id = p_profile_id
  FOR UPDATE;

  IF v_project_status IS NULL THEN
    RAISE EXCEPTION 'Project not found or unauthorized';
  END IF;

  IF v_is_paid THEN
    RAISE EXCEPTION 'Project is already paid';
  END IF;

  -- Calculate new balance
  v_new_balance := v_old_balance - p_amount;

  -- Update wallet balance
  UPDATE wallets
  SET balance = v_new_balance,
      updated_at = NOW()
  WHERE id = v_wallet_id;

  -- Create transaction record
  INSERT INTO wallet_transactions (
    wallet_id,
    amount,
    transaction_type,
    description,
    reference_id,
    metadata
  ) VALUES (
    v_wallet_id,
    p_amount,
    'debit',
    'Payment for project ' || v_project_number,
    p_project_id::TEXT,
    jsonb_build_object(
      'type', 'project_payment',
      'project_id', p_project_id,
      'project_number', v_project_number
    )
  )
  RETURNING id INTO v_transaction_id;

  -- Update project status
  UPDATE projects
  SET is_paid = true,
      paid_at = NOW(),
      payment_id = 'wallet_' || v_transaction_id,
      status = 'payment_confirmed',
      updated_at = NOW()
  WHERE id = p_project_id;

  -- Create status history entry
  INSERT INTO project_status_history (
    project_id,
    old_status,
    new_status,
    changed_by,
    notes
  ) VALUES (
    p_project_id,
    v_project_status,
    'payment_confirmed',
    p_profile_id,
    'Payment received from wallet balance'
  );

  -- Log activity
  INSERT INTO activity_logs (
    profile_id,
    action,
    action_category,
    description,
    metadata
  ) VALUES (
    p_profile_id,
    'wallet_payment',
    'payment',
    'Wallet payment for project ' || v_project_number,
    jsonb_build_object(
      'project_id', p_project_id,
      'amount', p_amount,
      'old_balance', v_old_balance,
      'new_balance', v_new_balance
    )
  );

  -- Build result
  v_result := json_build_object(
    'success', true,
    'transaction_id', v_transaction_id,
    'old_balance', v_old_balance,
    'new_balance', v_new_balance,
    'project_id', p_project_id
  );

  RETURN v_result;
END;
$$;

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION process_wallet_topup TO authenticated;
GRANT EXECUTE ON FUNCTION process_razorpay_project_payment TO authenticated;
GRANT EXECUTE ON FUNCTION process_wallet_project_payment TO authenticated;

-- Add comments for documentation
COMMENT ON FUNCTION process_wallet_topup IS 'Atomically processes wallet top-up via Razorpay';
COMMENT ON FUNCTION process_razorpay_project_payment IS 'Atomically processes project payment via Razorpay';
COMMENT ON FUNCTION process_wallet_project_payment IS 'Atomically processes project payment using wallet balance';
