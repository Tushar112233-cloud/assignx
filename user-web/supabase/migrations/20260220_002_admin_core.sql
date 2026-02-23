-- Admin Core RPCs Migration
-- Project management, financial summary, transaction ledger, refund processing, ticket stats

-- RPC: Admin get projects with pagination and filters
CREATE OR REPLACE FUNCTION admin_get_projects(
  p_search TEXT DEFAULT NULL,
  p_status TEXT DEFAULT NULL,
  p_date_from TIMESTAMPTZ DEFAULT NULL,
  p_date_to TIMESTAMPTZ DEFAULT NULL,
  p_supervisor_id UUID DEFAULT NULL,
  p_doer_id UUID DEFAULT NULL,
  p_page INT DEFAULT 1,
  p_per_page INT DEFAULT 20
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result JSON;
  total_count INT;
  offset_val INT;
BEGIN
  offset_val := (p_page - 1) * p_per_page;

  SELECT COUNT(*) INTO total_count
  FROM projects pr
  WHERE (p_search IS NULL OR pr.title ILIKE '%' || p_search || '%' OR pr.description ILIKE '%' || p_search || '%')
    AND (p_status IS NULL OR pr.status::text = p_status)
    AND (p_date_from IS NULL OR pr.created_at >= p_date_from)
    AND (p_date_to IS NULL OR pr.created_at <= p_date_to)
    AND (p_supervisor_id IS NULL OR pr.supervisor_id = p_supervisor_id)
    AND (p_doer_id IS NULL OR pr.doer_id = p_doer_id);

  SELECT json_build_object(
    'data', COALESCE(json_agg(row_to_json(t)), '[]'::json),
    'total', total_count,
    'page', p_page,
    'per_page', p_per_page,
    'total_pages', CEIL(total_count::float / p_per_page)
  ) INTO result
  FROM (
    SELECT
      pr.id,
      pr.title,
      pr.description,
      pr.status::text as status,
      pr.user_quote,
      pr.doer_payout,
      pr.platform_fee,
      pr.deadline,
      pr.created_at,
      pr.updated_at,
      pr.user_id,
      u.full_name as user_name,
      pr.supervisor_id,
      svp.full_name as supervisor_name,
      pr.doer_id,
      dr.full_name as doer_name,
      sub.name as subject_name
    FROM projects pr
    LEFT JOIN profiles u ON u.id = pr.user_id
    LEFT JOIN supervisors sv ON sv.id = pr.supervisor_id
    LEFT JOIN profiles svp ON svp.id = sv.profile_id
    LEFT JOIN doers d ON d.id = pr.doer_id
    LEFT JOIN profiles dr ON dr.id = d.profile_id
    LEFT JOIN subjects sub ON sub.id = pr.subject_id
    WHERE (p_search IS NULL OR pr.title ILIKE '%' || p_search || '%' OR pr.description ILIKE '%' || p_search || '%')
      AND (p_status IS NULL OR pr.status::text = p_status)
      AND (p_date_from IS NULL OR pr.created_at >= p_date_from)
      AND (p_date_to IS NULL OR pr.created_at <= p_date_to)
      AND (p_supervisor_id IS NULL OR pr.supervisor_id = p_supervisor_id)
      AND (p_doer_id IS NULL OR pr.doer_id = p_doer_id)
    ORDER BY pr.created_at DESC
    LIMIT p_per_page OFFSET offset_val
  ) t;

  RETURN result;
END;
$$;

-- RPC: Admin get financial summary
CREATE OR REPLACE FUNCTION admin_get_financial_summary(p_period TEXT DEFAULT '30d')
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result JSON;
  date_from TIMESTAMPTZ;
BEGIN
  date_from := CASE
    WHEN p_period = '7d' THEN NOW() - INTERVAL '7 days'
    WHEN p_period = '30d' THEN NOW() - INTERVAL '30 days'
    WHEN p_period = '90d' THEN NOW() - INTERVAL '90 days'
    WHEN p_period = '1y' THEN NOW() - INTERVAL '1 year'
    WHEN p_period = 'all' THEN '1970-01-01'::TIMESTAMPTZ
    ELSE NOW() - INTERVAL '30 days'
  END;

  SELECT json_build_object(
    'total_revenue', COALESCE(SUM(amount) FILTER (WHERE transaction_type = 'project_payment' AND status = 'completed'), 0),
    'refunds', COALESCE(SUM(amount) FILTER (WHERE transaction_type = 'refund' AND status = 'completed'), 0),
    'payouts', COALESCE(SUM(amount) FILTER (WHERE transaction_type = 'withdrawal' AND status = 'completed'), 0),
    'platform_fees', COALESCE(SUM(amount) FILTER (WHERE transaction_type = 'commission' AND status = 'completed'), 0),
    'net_revenue', COALESCE(
      SUM(amount) FILTER (WHERE transaction_type = 'project_payment' AND status = 'completed'), 0
    ) - COALESCE(
      SUM(amount) FILTER (WHERE transaction_type = 'refund' AND status = 'completed'), 0
    ) - COALESCE(
      SUM(amount) FILTER (WHERE transaction_type = 'withdrawal' AND status = 'completed'), 0
    ),
    'avg_project_value', COALESCE(
      AVG(amount) FILTER (WHERE transaction_type = 'project_payment' AND status = 'completed'), 0
    ),
    'transaction_count', COUNT(*) FILTER (WHERE status = 'completed')
  ) INTO result
  FROM wallet_transactions
  WHERE created_at >= date_from;

  RETURN result;
END;
$$;

-- RPC: Admin get transaction ledger with pagination
CREATE OR REPLACE FUNCTION admin_get_transaction_ledger(
  p_wallet_id UUID DEFAULT NULL,
  p_type TEXT DEFAULT NULL,
  p_status TEXT DEFAULT NULL,
  p_date_from TIMESTAMPTZ DEFAULT NULL,
  p_date_to TIMESTAMPTZ DEFAULT NULL,
  p_page INT DEFAULT 1,
  p_per_page INT DEFAULT 20
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result JSON;
  total_count INT;
  offset_val INT;
BEGIN
  offset_val := (p_page - 1) * p_per_page;

  SELECT COUNT(*) INTO total_count
  FROM wallet_transactions wt
  WHERE (p_wallet_id IS NULL OR wt.wallet_id = p_wallet_id)
    AND (p_type IS NULL OR wt.transaction_type::text = p_type)
    AND (p_status IS NULL OR wt.status::text = p_status)
    AND (p_date_from IS NULL OR wt.created_at >= p_date_from)
    AND (p_date_to IS NULL OR wt.created_at <= p_date_to);

  SELECT json_build_object(
    'data', COALESCE(json_agg(row_to_json(t)), '[]'::json),
    'total', total_count,
    'page', p_page,
    'per_page', p_per_page,
    'total_pages', CEIL(total_count::float / p_per_page)
  ) INTO result
  FROM (
    SELECT
      wt.id,
      wt.wallet_id,
      wt.transaction_type::text as transaction_type,
      wt.amount,
      wt.balance_before,
      wt.balance_after,
      wt.status::text as status,
      wt.description,
      wt.reference_id,
      wt.created_at,
      p.full_name as profile_name,
      p.email as profile_email
    FROM wallet_transactions wt
    LEFT JOIN wallets w ON w.id = wt.wallet_id
    LEFT JOIN profiles p ON p.id = w.profile_id
    WHERE (p_wallet_id IS NULL OR wt.wallet_id = p_wallet_id)
      AND (p_type IS NULL OR wt.transaction_type::text = p_type)
      AND (p_status IS NULL OR wt.status::text = p_status)
      AND (p_date_from IS NULL OR wt.created_at >= p_date_from)
      AND (p_date_to IS NULL OR wt.created_at <= p_date_to)
    ORDER BY wt.created_at DESC
    LIMIT p_per_page OFFSET offset_val
  ) t;

  RETURN result;
END;
$$;

-- RPC: Admin process refund
CREATE OR REPLACE FUNCTION admin_process_refund(
  p_project_id UUID,
  p_amount DECIMAL,
  p_reason TEXT,
  p_admin_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_project RECORD;
  v_wallet RECORD;
  v_transaction_id UUID;
  result JSON;
BEGIN
  -- Get the project
  SELECT * INTO v_project FROM projects WHERE id = p_project_id;
  IF NOT FOUND THEN
    RETURN json_build_object('success', false, 'error', 'Project not found');
  END IF;

  -- Check project is in a refundable state
  IF v_project.status IN ('refunded', 'cancelled', 'draft') THEN
    RETURN json_build_object('success', false, 'error', 'Project is not in a refundable state');
  END IF;

  -- Get the user wallet
  SELECT * INTO v_wallet FROM wallets WHERE profile_id = v_project.user_id;
  IF NOT FOUND THEN
    RETURN json_build_object('success', false, 'error', 'User wallet not found');
  END IF;

  -- Create refund transaction with balance tracking
  INSERT INTO wallet_transactions (wallet_id, transaction_type, amount, balance_before, balance_after, status, description, reference_id)
  VALUES (v_wallet.id, 'refund', p_amount, v_wallet.balance, v_wallet.balance + p_amount, 'completed', 'Refund: ' || p_reason, p_project_id)
  RETURNING id INTO v_transaction_id;

  -- Credit wallet balance
  UPDATE wallets SET balance = balance + p_amount, updated_at = NOW() WHERE id = v_wallet.id;

  -- Update project status
  UPDATE projects SET status = 'refunded', updated_at = NOW() WHERE id = p_project_id;

  -- Log to admin audit
  INSERT INTO admin_audit_logs (admin_id, action, target_type, target_id, details)
  VALUES (
    p_admin_id,
    'process_refund',
    'project',
    p_project_id,
    json_build_object(
      'amount', p_amount,
      'reason', p_reason,
      'transaction_id', v_transaction_id,
      'original_status', v_project.status::text
    )::jsonb
  );

  RETURN json_build_object(
    'success', true,
    'transaction_id', v_transaction_id,
    'refunded_amount', p_amount
  );
END;
$$;

-- RPC: Admin get ticket stats
CREATE OR REPLACE FUNCTION admin_get_ticket_stats()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'open_count', COUNT(*) FILTER (WHERE status = 'open'),
    'in_progress_count', COUNT(*) FILTER (WHERE status = 'in_progress'),
    'waiting_response_count', COUNT(*) FILTER (WHERE status = 'waiting_response'),
    'resolved_count', COUNT(*) FILTER (WHERE status = 'resolved'),
    'closed_count', COUNT(*) FILTER (WHERE status = 'closed'),
    'total_count', COUNT(*),
    'avg_resolution_time_hours', COALESCE(
      EXTRACT(EPOCH FROM AVG(resolved_at - created_at) FILTER (WHERE resolved_at IS NOT NULL)) / 3600,
      0
    ),
    'by_priority', json_build_object(
      'low', COUNT(*) FILTER (WHERE priority = 'low'),
      'medium', COUNT(*) FILTER (WHERE priority = 'medium'),
      'high', COUNT(*) FILTER (WHERE priority = 'high'),
      'urgent', COUNT(*) FILTER (WHERE priority = 'urgent')
    ),
    'avg_satisfaction', COALESCE(AVG(satisfaction_rating) FILTER (WHERE satisfaction_rating IS NOT NULL), 0)
  ) INTO result
  FROM support_tickets;

  RETURN result;
END;
$$;
