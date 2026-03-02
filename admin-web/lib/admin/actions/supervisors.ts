"use server";

import { verifyAdmin, serverFetch } from "@/lib/admin/auth";

export async function getSupervisors(params: {
  search?: string;
  status?: string;
  page?: number;
  perPage?: number;
}) {
  await verifyAdmin();

  const query = new URLSearchParams();
  if (params.search) query.set("search", params.search);
  if (params.status) query.set("status", params.status);
  if (params.page) query.set("page", String(params.page));
  if (params.perPage) query.set("limit", String(params.perPage));

  try {
    const result = await serverFetch(`/api/supervisors?${query.toString()}`);
    const arr = result.supervisors || result.data || [];
    return {
      data: arr,
      total: result.total || arr.length,
      page: result.page || params.page || 1,
      total_pages: result.totalPages || result.total_pages || Math.ceil((result.total || arr.length) / (params.perPage || 20)),
    };
  } catch {
    return { data: [], total: 0, page: params.page || 1, total_pages: 1 };
  }
}

export async function getSupervisorById(supervisorId: string) {
  await verifyAdmin();
  return serverFetch(`/api/supervisors/${supervisorId}`);
}
