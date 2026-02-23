-- ============================================================================
-- Wallet-to-Wallet Transfer Function
-- ============================================================================
-- Atomic function for sending money between user wallets.
-- Prevents race conditions via row-level locking in UUID order (deadlock prevention).
-- ============================================================================

CREATE OR REPLACE FUNCTION process_wallet_transfer(
  p_sender_profile_id UUID,
  p_recipient_email TEXT,
  p_amount DECIMAL,
  p_note TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_recipient_profile_id UUID;
  v_recipient_name TEXT;
  v_sender_name TEXT;
  v_sender_wallet_id UUID;
  v_recipient_wallet_id UUID;
  v_sender_balance DECIMAL;
  v_recipient_balance DECIMAL;
  v_sender_new_balance DECIMAL;
  v_recipient_new_balance DECIMAL;
  v_transaction_id UUID;
  v_transfer_ref TEXT;
  v_result JSON;
BEGIN
  -- Validate amount range
  IF p_amount < 1 THEN
    RAISE EXCEPTION 'Minimum transfer amount is ₹1';
  END IF;

  IF p_amount > 50000 THEN
    RAISE EXCEPTION 'Maximum transfer amount is ₹50,000';
  END IF;

  -- Look up recipient by email
  SELECT id, full_name INTO v_recipient_profile_id, v_recipient_name
  FROM profiles
  WHERE email = LOWER(TRIM(p_recipient_email))
    AND is_active = true;

  IF v_recipient_profile_id IS NULL THEN
    RAISE EXCEPTION 'Recipient not found';
  END IF;

  -- Prevent self-transfer
  IF v_recipient_profile_id = p_sender_profile_id THEN
    RAISE EXCEPTION 'Cannot send money to yourself';
  END IF;

  -- Get sender name
  SELECT full_name INTO v_sender_name
  FROM profiles
  WHERE id = p_sender_profile_id;

  -- Generate transfer reference
  v_transfer_ref := 'TRF-' || UPPER(SUBSTRING(gen_random_uuid()::TEXT FROM 1 FOR 8));

  -- Lock wallets in UUID order to prevent deadlocks
  IF p_sender_profile_id < v_recipient_profile_id THEN
    SELECT id, balance INTO v_sender_wallet_id, v_sender_balance
    FROM wallets WHERE profile_id = p_sender_profile_id FOR UPDATE;

    SELECT id, balance INTO v_recipient_wallet_id, v_recipient_balance
    FROM wallets WHERE profile_id = v_recipient_profile_id FOR UPDATE;
  ELSE
    SELECT id, balance INTO v_recipient_wallet_id, v_recipient_balance
    FROM wallets WHERE profile_id = v_recipient_profile_id FOR UPDATE;

    SELECT id, balance INTO v_sender_wallet_id, v_sender_balance
    FROM wallets WHERE profile_id = p_sender_profile_id FOR UPDATE;
  END IF;

  IF v_sender_wallet_id IS NULL THEN
    RAISE EXCEPTION 'Sender wallet not found';
  END IF;

  IF v_recipient_wallet_id IS NULL THEN
    RAISE EXCEPTION 'Recipient wallet not found';
  END IF;

  -- Check sufficient balance
  IF v_sender_balance < p_amount THEN
    RAISE EXCEPTION 'Insufficient balance. Available: %, Required: %', v_sender_balance, p_amount;
  END IF;

  -- Calculate new balances
  v_sender_new_balance := v_sender_balance - p_amount;
  v_recipient_new_balance := v_recipient_balance + p_amount;

  -- Update sender wallet
  UPDATE wallets
  SET balance = v_sender_new_balance, updated_at = NOW()
  WHERE id = v_sender_wallet_id;

  -- Update recipient wallet
  UPDATE wallets
  SET balance = v_recipient_new_balance, updated_at = NOW()
  WHERE id = v_recipient_wallet_id;

  -- Create debit transaction for sender
  INSERT INTO wallet_transactions (
    wallet_id, amount, transaction_type, description,
    reference_type, reference_id, balance_after, status, metadata
  ) VALUES (
    v_sender_wallet_id, p_amount, 'debit',
    'Sent to ' || COALESCE(v_recipient_name, p_recipient_email),
    'wallet_transfer', v_transfer_ref, v_sender_new_balance, 'completed',
    jsonb_build_object(
      'transfer_ref', v_transfer_ref,
      'recipient_email', p_recipient_email,
      'recipient_name', v_recipient_name,
      'note', p_note
    )
  )
  RETURNING id INTO v_transaction_id;

  -- Create credit transaction for recipient
  INSERT INTO wallet_transactions (
    wallet_id, amount, transaction_type, description,
    reference_type, reference_id, balance_after, status, metadata
  ) VALUES (
    v_recipient_wallet_id, p_amount, 'credit',
    'Received from ' || COALESCE(v_sender_name, 'a user'),
    'wallet_transfer', v_transfer_ref, v_recipient_new_balance, 'completed',
    jsonb_build_object(
      'transfer_ref', v_transfer_ref,
      'sender_name', v_sender_name,
      'note', p_note
    )
  );

  -- Activity log for sender
  INSERT INTO activity_logs (
    profile_id, action, action_category, description, metadata
  ) VALUES (
    p_sender_profile_id, 'wallet_transfer_sent', 'payment',
    'Sent ₹' || p_amount || ' to ' || COALESCE(v_recipient_name, p_recipient_email),
    jsonb_build_object(
      'transfer_ref', v_transfer_ref,
      'amount', p_amount,
      'recipient_email', p_recipient_email,
      'recipient_name', v_recipient_name
    )
  );

  -- Activity log for recipient
  INSERT INTO activity_logs (
    profile_id, action, action_category, description, metadata
  ) VALUES (
    v_recipient_profile_id, 'wallet_transfer_received', 'payment',
    'Received ₹' || p_amount || ' from ' || COALESCE(v_sender_name, 'a user'),
    jsonb_build_object(
      'transfer_ref', v_transfer_ref,
      'amount', p_amount,
      'sender_name', v_sender_name
    )
  );

  -- Notification for sender
  INSERT INTO notifications (
    profile_id, type, title, message, is_read
  ) VALUES (
    p_sender_profile_id, 'payment',
    'Money Sent',
    'You sent ₹' || p_amount || ' to ' || COALESCE(v_recipient_name, p_recipient_email),
    false
  );

  -- Notification for recipient
  INSERT INTO notifications (
    profile_id, type, title, message, is_read
  ) VALUES (
    v_recipient_profile_id, 'payment',
    'Money Received',
    'You received ₹' || p_amount || ' from ' || COALESCE(v_sender_name, 'someone'),
    false
  );

  -- Build result
  v_result := json_build_object(
    'success', true,
    'transaction_id', v_transaction_id,
    'transfer_ref', v_transfer_ref,
    'new_balance', v_sender_new_balance,
    'recipient_name', v_recipient_name,
    'amount', p_amount
  );

  RETURN v_result;
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION process_wallet_transfer TO authenticated;

COMMENT ON FUNCTION process_wallet_transfer IS 'Atomically processes wallet-to-wallet transfer between users';
