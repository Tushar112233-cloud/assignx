"use server";

import { verifyAdmin, serverFetch } from "@/lib/admin/auth";

export async function getBanners(params: {
  search?: string;
  location?: string;
  active?: string;
  page?: number;
  perPage?: number;
}) {
  await verifyAdmin();

  const query = new URLSearchParams();
  if (params.search) query.set("search", params.search);
  if (params.location) query.set("location", params.location);
  if (params.active) query.set("active", params.active);
  if (params.page) query.set("page", String(params.page));
  if (params.perPage) query.set("perPage", String(params.perPage));

  try {
    const result = await serverFetch(`/api/admin/banners?${query.toString()}`);
    const arr = result.banners || result.data || [];
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

export async function getBannerById(id: string) {
  await verifyAdmin();
  return serverFetch(`/api/admin/banners/${id}`);
}

export async function createBanner(formData: {
  title: string;
  subtitle?: string;
  image_url?: string;
  image_url_mobile?: string;
  display_location?: string;
  display_order?: number;
  start_date?: string;
  end_date?: string;
  is_active?: boolean;
  target_roles?: string[];
  target_user_types?: string[];
  cta_text?: string;
  cta_url?: string;
  cta_action?: string;
}) {
  await verifyAdmin();

  return serverFetch(`/api/admin/banners`, {
    method: "POST",
    body: JSON.stringify(formData),
  });
}

export async function updateBanner(
  id: string,
  formData: {
    title?: string;
    subtitle?: string;
    image_url?: string;
    image_url_mobile?: string;
    display_location?: string;
    display_order?: number;
    start_date?: string;
    end_date?: string;
    is_active?: boolean;
    target_roles?: string[];
    target_user_types?: string[];
    cta_text?: string;
    cta_url?: string;
    cta_action?: string;
  }
) {
  await verifyAdmin();

  return serverFetch(`/api/admin/banners/${id}`, {
    method: "PUT",
    body: JSON.stringify(formData),
  });
}

export async function deleteBanner(id: string) {
  await verifyAdmin();

  await serverFetch(`/api/admin/banners/${id}`, {
    method: "DELETE",
  });

  return { success: true };
}

export async function toggleBannerActive(id: string, active: boolean) {
  await verifyAdmin();

  await serverFetch(`/api/admin/banners/${id}`, {
    method: "PUT",
    body: JSON.stringify({ is_active: active }),
  });

  return { success: true };
}
