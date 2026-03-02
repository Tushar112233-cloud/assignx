"use server";

import { verifyAdmin, serverFetch } from "@/lib/admin/auth";

export async function getDoers(params: {
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
    const result = await serverFetch(`/api/doers?${query.toString()}`);
    const raw = result.doers || result.data || [];
    // Normalize camelCase API fields to snake_case for the component
    const arr = raw.map((d: any) => ({
      id: d.id || d._id,
      profile_id: d.profile_id || d.profileId || d.id || d._id,
      full_name: d.full_name || d.fullName || d.profile?.fullName || null,
      email: d.email || d.profile?.email || null,
      avatar_url: d.avatar_url || d.avatarUrl || d.profile?.avatarUrl || null,
      is_active: d.is_active ?? d.isAccessGranted ?? d.isActivated ?? false,
      is_activated: d.is_activated ?? d.isActivated ?? d.isAccessGranted ?? false,
      phone: d.phone || d.profile?.phone || null,
      city: d.city || d.profile?.city || null,
      created_at: d.created_at || d.createdAt || new Date().toISOString(),
      tasks_assigned: d.tasks_assigned ?? d.totalProjectsAssigned ?? 0,
      tasks_completed: d.tasks_completed ?? d.totalProjectsCompleted ?? 0,
      completion_rate: d.completion_rate ?? d.successRate ?? 0,
    }));
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

export async function approveDoer(doerId: string) {
  await verifyAdmin();

  await serverFetch(`/api/admin/doers/${doerId}/approve`, {
    method: "POST",
  });

  return { success: true };
}

export async function rejectDoer(doerId: string, reason: string) {
  await verifyAdmin();

  await serverFetch(`/api/admin/doers/${doerId}/reject`, {
    method: "POST",
    body: JSON.stringify({ reason }),
  });

  return { success: true };
}

export async function getDoerById(doerId: string) {
  await verifyAdmin();
  return serverFetch(`/api/doers/${doerId}`);
}
