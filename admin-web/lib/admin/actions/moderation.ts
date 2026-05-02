"use server";

import { verifyAdmin, serverFetch } from "@/lib/admin/auth";

export async function getFlaggedContent(params: {
  contentType?: string;
  status?: string;
  page?: number;
  perPage?: number;
}) {
  await verifyAdmin();

  const query = new URLSearchParams();
  if (params.contentType) query.set("contentType", params.contentType);
  if (params.status) query.set("status", params.status);
  if (params.page) query.set("page", String(params.page));
  if (params.perPage) query.set("perPage", String(params.perPage));

  try {
    return await serverFetch(`/api/admin/moderation/flagged?${query.toString()}`);
  } catch {
    return { data: [], total: 0, page: params.page || 1, per_page: params.perPage || 20, total_pages: 1 };
  }
}

export async function moderateContent(
  contentType: string,
  contentId: string,
  action: string,
  reason: string
) {
  await verifyAdmin();

  await serverFetch(`/api/admin/moderation/action`, {
    method: "POST",
    body: JSON.stringify({ contentType, contentId, action, reason }),
  });

  return { success: true };
}
