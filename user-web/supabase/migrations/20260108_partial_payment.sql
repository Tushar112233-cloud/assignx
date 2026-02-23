-- ============================================================================
-- Partial Payment Support
-- ============================================================================
-- This migration adds support for partial wallet + Razorpay payment
-- where wallet balance is deducted first, then remaining amount via Razorpay
-- ============================================================================

CREATE OR REPLACE FUNCTION process_partial_project_payment(
  p_profile_id UUID,
  p_project_id UUID,
  p_total_amount NUMERIC,
  p_wallet_amount NUMERIC,
  p_razorpay_amount NUMERIC,
  p_razorpay_order_id TEXT,
  p_razorpay_payment_id TEXT
) RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_wallet_id UUID;
  v_wallet_transaction_id UUID;
  v_old_balance DECIMAL;
  v_new_balance DECIMAL;
  v_project_exists BOOLEAN;
  v_already_paid BOOLEAN;
BEGIN
  -- Check if project exists and belongs to user
  SELECT EXISTS(
    SELECT 1 FROM projects
    WHERE id = p_project_id AND user_id = p_profile_id
  ) INTO v_project_exists;

  IF NOT v_project_exists THEN
    RAISE EXCEPTION 'Project not found or does not belong to user';
  END IF;

  -- Check if project is already paid
  SELECT is_paid INTO v_already_paid
  FROM projects WHERE id = p_project_id;

  IF v_already_paid THEN
    RAISE EXCEPTION 'Project is already paid';
  END IF;

  -- Validate amounts
  IF p_wallet_amount < 0 OR p_razorpay_amount < 0 THEN
    RAISE EXCEPTION 'Invalid payment amounts';
  END IF;

  IF (p_wallet_amount + p_razorpay_amount) != p_total_amount THEN
    RAISE EXCEPTION 'Payment amounts do not match total';
  END IF;

  -- Get wallet and balance
  SELECT id, balance INTO v_wallet_id, v_old_balance
  FROM wallets WHERE profile_id = p_profile_id;

  IF v_wallet_id IS NULL THEN
    RAISE EXCEPTION 'Wallet not found';
  END IF;

  -- Check sufficient wallet balance for wallet portion
  IF p_wallet_amount > 0 AND v_old_balance < p_wallet_amount THEN
    RAISE EXCEPTION 'Insufficient wallet balance. Available: %, Required: %', v_old_balance, p_wallet_amount;
  END IF;

  -- Calculate new balance after wallet deduction
  v_new_balance := v_old_balance - p_wallet_amount;

  -- Create wallet transaction if wallet amount > 0
  IF p_wallet_amount > 0 THEN
    INSERT INTO wallet_transactions (
      wallet_id,
      transaction_type,
      amount,
      balance_before,
      balance_after,
      reference_type,
      reference_id,
      description,
      notes,
      status
    ) VALUES (
      v_wallet_id,
      'debit',
      p_wallet_amount,
      v_old_balance,
      v_new_balance,
      'project_payment',
      p_project_id,
      'Partial payment from wallet',
      jsonb_build_object(
        'wallet_amount', p_wallet_amount,
        'razorpay_amount', p_razorpay_amount,
        'total_amount', p_total_amount,
        'payment_type', 'partial'
      )::text,
      'completed'
    ) RETURNING id INTO v_wallet_transaction_id;
  END IF;

  -- Update project payment status
  UPDATE projects
  SET
    is_paid = true,
    paid_at = NOW(),
    status = CASE
      WHEN status = 'payment_pending' THEN 'in_progress'
      WHEN status = 'quoted' THEN 'in_progress'
      ELSE status
    END,
    updated_at = NOW()
  WHERE id = p_project_id;

  -- Log activity
  INSERT INTO activity_logs (
    profile_id,
    action,
    action_category,
    target_type,
    target_id,
    description,
    metadata
  ) VALUES (
    p_profile_id,
    'project_payment_partial',
    'payment',
    'project',
    p_project_id,
    'Project paid: ₹' || p_wallet_amount || ' (wallet) + ₹' || p_razorpay_amount || ' (card)',
    jsonb_build_object(
      'total_amount', p_total_amount,
      'wallet_amount', p_wallet_amount,
      'razorpay_amount', p_razorpay_amount,
      'project_id', p_project_id,
      'wallet_transaction_id', v_wallet_transaction_id,
      'razorpay_order_id', p_razorpay_order_id,
      'razorpay_payment_id', p_razorpay_payment_id,
      'payment_method', 'partial'
    )
  );

  RETURN json_build_object(
    'wallet_transaction_id', v_wallet_transaction_id,
    'new_balance', v_new_balance,
    'project_id', p_project_id,
    'wallet_amount', p_wallet_amount,
    'razorpay_amount', p_razorpay_amount,
    'total_amount', p_total_amount,
    'payment_method', 'partial'
  );
END;
$$;

COMMENT ON FUNCTION process_partial_project_payment IS 'Processes partial project payment using wallet balance + Razorpay';
