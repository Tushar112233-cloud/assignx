"use server";

import { verifyAdmin, serverFetch } from "@/lib/admin/auth";

export async function getUsers(params: {
  search?: string;
  userType?: string;
  status?: string;
  page?: number;
  perPage?: number;
  sortBy?: string;
  sortOrder?: string;
}) {
  await verifyAdmin();

  const query = new URLSearchParams();
  if (params.search) query.set("search", params.search);
  if (params.userType) query.set("userType", params.userType);
  if (params.status) query.set("status", params.status);
  if (params.page) query.set("page", String(params.page));
  if (params.perPage) query.set("perPage", String(params.perPage));
  if (params.sortBy) query.set("sortBy", params.sortBy);
  if (params.sortOrder) query.set("sortOrder", params.sortOrder);

  return serverFetch(`/api/admin/users?${query.toString()}`);
}

export async function getUserById(userId: string) {
  await verifyAdmin();

  const [profile, wallet, projects, activity] = await Promise.all([
    serverFetch(`/api/profiles/${userId}`),
    serverFetch(`/api/wallets/by-profile/${userId}`).catch(() => null),
    serverFetch(`/api/projects?userId=${userId}&limit=10&sort=-createdAt`).catch(() => ({ data: [] })),
    serverFetch(`/api/admin/activity-logs?profileId=${userId}&limit=20`).catch(() => []),
  ]);

  return {
    profile,
    wallet,
    projects: projects.data || projects || [],
    activity: activity.data || activity || [],
  };
}

export async function suspendUser(userId: string, reason: string) {
  await verifyAdmin();

  await serverFetch(`/api/admin/users/${userId}/suspend`, {
    method: "POST",
    body: JSON.stringify({ reason }),
  });

  return { success: true };
}

export async function activateUser(userId: string) {
  await verifyAdmin();

  await serverFetch(`/api/admin/users/${userId}/activate`, {
    method: "POST",
  });

  return { success: true };
}
