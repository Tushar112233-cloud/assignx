"use server";

import { createClient } from "@/lib/supabase/server";
import { verifyAdmin } from "@/lib/admin/auth";

export async function getFinancialSummary(period?: string) {
  await verifyAdmin();
  const supabase = await createClient();

  const { data, error } = await supabase.rpc("admin_get_financial_summary", {
    p_period: period || "30d",
  });

  if (error) {
    // Fallback: compute from wallet_transactions
    const now = new Date();
    const daysBack = period === "7d" ? 7 : period === "90d" ? 90 : 30;
    const startDate = new Date(now.getTime() - daysBack * 86400000).toISOString();

    const { data: transactions } = await supabase
      .from("wallet_transactions")
      .select("type, amount, status")
      .gte("created_at", startDate)
      .eq("status", "completed");

    const txns = transactions || [];
    const revenue = txns
      .filter((t) => t.type === "project_payment")
      .reduce((s, t) => s + Number(t.amount), 0);
    const refunds = txns
      .filter((t) => t.type === "refund")
      .reduce((s, t) => s + Number(t.amount), 0);
    const payouts = txns
      .filter((t) => t.type === "project_earning" || t.type === "withdrawal")
      .reduce((s, t) => s + Number(t.amount), 0);
    const commissions = txns
      .filter((t) => t.type === "commission")
      .reduce((s, t) => s + Number(t.amount), 0);

    return {
      total_revenue: revenue,
      refunds,
      payouts,
      platform_fees: commissions,
      net_revenue: revenue - refunds - payouts,
      avg_project_value: revenue > 0 ? revenue / txns.filter((t) => t.type === "project_payment").length : 0,
    };
  }

  return data;
}

export async function getTransactions(params: {
  walletId?: string;
  type?: string;
  status?: string;
  dateFrom?: string;
  dateTo?: string;
  page?: number;
  perPage?: number;
}) {
  await verifyAdmin();
  const supabase = await createClient();

  const { data, error } = await supabase.rpc("admin_get_transaction_ledger", {
    p_wallet_id: params.walletId || null,
    p_type: params.type || null,
    p_status: params.status || null,
    p_date_from: params.dateFrom || null,
    p_date_to: params.dateTo || null,
    p_page: params.page || 1,
    p_per_page: params.perPage || 20,
  });

  if (error) {
    const page = params.page || 1;
    const perPage = params.perPage || 20;
    const offset = (page - 1) * perPage;

    let query = supabase
      .from("wallet_transactions")
      .select(
        "*, wallet:wallets!wallet_id(id, profile_id, profiles:profiles!profile_id(full_name, email))",
        { count: "exact" }
      )
      .order("created_at", { ascending: false })
      .range(offset, offset + perPage - 1);

    if (params.walletId) query = query.eq("wallet_id", params.walletId);
    if (params.type) query = query.eq("type", params.type);
    if (params.status) query = query.eq("status", params.status);
    if (params.dateFrom) query = query.gte("created_at", params.dateFrom);
    if (params.dateTo) query = query.lte("created_at", params.dateTo);

    const { data: txns, count, error: fallbackError } = await query;
    if (fallbackError) throw new Error(fallbackError.message);

    return {
      data: txns || [],
      total: count || 0,
      page,
      total_pages: Math.ceil((count || 0) / perPage),
    };
  }

  return data;
}

export async function processRefund(
  projectId: string,
  amount: number,
  reason: string
) {
  const admin = await verifyAdmin();
  const supabase = await createClient();

  const { data, error } = await supabase.rpc("admin_process_refund", {
    p_project_id: projectId,
    p_amount: amount,
    p_reason: reason,
    p_admin_id: admin.id,
  });

  if (error) throw new Error(error.message);

  await supabase.from("admin_audit_logs").insert({
    admin_id: admin.id,
    action: "process_refund",
    target_type: "project",
    target_id: projectId,
    details: { amount, reason },
  });

  return data || { success: true };
}

export async function getWalletById(walletId: string) {
  await verifyAdmin();
  const supabase = await createClient();

  const { data: wallet, error: walletError } = await supabase
    .from("wallets")
    .select("*, profile:profiles!profile_id(id, full_name, email, avatar_url)")
    .eq("id", walletId)
    .single();

  if (walletError) throw new Error(walletError.message);

  const { data: transactions } = await supabase
    .from("wallet_transactions")
    .select("*")
    .eq("wallet_id", walletId)
    .order("created_at", { ascending: false })
    .limit(50);

  return { wallet, transactions: transactions || [] };
}
