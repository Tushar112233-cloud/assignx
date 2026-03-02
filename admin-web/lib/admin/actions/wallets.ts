"use server";

import { verifyAdmin, serverFetch } from "@/lib/admin/auth";

export async function getFinancialSummary(period?: string) {
  await verifyAdmin();

  try {
    return await serverFetch(`/api/admin/financial-summary?period=${period || "30d"}`);
  } catch {
    return {
      total_revenue: 0,
      refunds: 0,
      payouts: 0,
      platform_fees: 0,
      net_revenue: 0,
      avg_project_value: 0,
    };
  }
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

  const query = new URLSearchParams();
  if (params.walletId) query.set("walletId", params.walletId);
  if (params.type) query.set("type", params.type);
  if (params.status) query.set("status", params.status);
  if (params.dateFrom) query.set("dateFrom", params.dateFrom);
  if (params.dateTo) query.set("dateTo", params.dateTo);
  if (params.page) query.set("page", String(params.page));
  if (params.perPage) query.set("perPage", String(params.perPage));

  try {
    return await serverFetch(`/api/admin/transactions?${query.toString()}`);
  } catch {
    return { data: [], total: 0, page: params.page || 1, total_pages: 1 };
  }
}

export async function processRefund(
  projectId: string,
  amount: number,
  reason: string
) {
  await verifyAdmin();

  const data = await serverFetch(`/api/admin/refund`, {
    method: "POST",
    body: JSON.stringify({ projectId, amount, reason }),
  });

  return data || { success: true };
}

export async function getWalletById(walletId: string) {
  await verifyAdmin();
  return serverFetch(`/api/admin/wallets/${walletId}`);
}
