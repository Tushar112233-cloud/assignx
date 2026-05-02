"use server";

import { verifyAdmin, serverFetch } from "@/lib/admin/auth";

export async function getColleges(params: {
  search?: string;
  page?: number;
  perPage?: number;
}) {
  await verifyAdmin();

  const query = new URLSearchParams();
  if (params.search) query.set("search", params.search);
  if (params.page) query.set("page", String(params.page));
  if (params.perPage) query.set("perPage", String(params.perPage));

  try {
    const result = await serverFetch(`/api/admin/colleges?${query.toString()}`);
    const arr = result.colleges || result.data || [];
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

export async function getCollegeDetail(collegeId: string) {
  await verifyAdmin();
  return serverFetch(`/api/admin/colleges/${collegeId}`);
}
