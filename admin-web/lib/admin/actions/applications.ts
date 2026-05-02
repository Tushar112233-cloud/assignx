"use server";

import { verifyAdmin, serverFetch } from "@/lib/admin/auth";

export async function getApplications(params: {
  search?: string;
  status?: string;
  role?: string;
  page?: number;
  perPage?: number;
}) {
  await verifyAdmin();

  const query = new URLSearchParams();
  if (params.search) query.set("search", params.search);
  if (params.status) query.set("status", params.status);
  if (params.role) query.set("role", params.role);
  if (params.page) query.set("page", String(params.page));
  if (params.perPage) query.set("limit", String(params.perPage));

  try {
    const result = await serverFetch(`/api/admin/access-requests?${query.toString()}`);
    const arr = result.requests || result.data || [];
    return {
      data: arr,
      total: result.total || arr.length,
      page: result.page || params.page || 1,
      totalPages: result.totalPages || Math.ceil((result.total || arr.length) / (params.perPage || 20)),
    };
  } catch {
    return { data: [], total: 0, page: params.page || 1, totalPages: 1 };
  }
}

export async function approveApplication(id: string) {
  await verifyAdmin();

  return serverFetch(`/api/admin/access-requests/${id}/approve`, {
    method: "POST",
  });
}

export async function rejectApplication(id: string) {
  await verifyAdmin();

  return serverFetch(`/api/admin/access-requests/${id}/reject`, {
    method: "POST",
  });
}
