"use server";

import { verifyAdmin, serverFetch } from "@/lib/admin/auth";

export async function getLearningResources(params: {
  search?: string;
  contentType?: string;
  category?: string;
  page?: number;
  perPage?: number;
}) {
  await verifyAdmin();

  const query = new URLSearchParams();
  if (params.search) query.set("search", params.search);
  if (params.contentType) query.set("contentType", params.contentType);
  if (params.category) query.set("category", params.category);
  if (params.page) query.set("page", String(params.page));
  if (params.perPage) query.set("perPage", String(params.perPage));

  try {
    const result = await serverFetch(`/api/admin/learning-resources?${query.toString()}`);
    const arr = result.resources || result.data || [];
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

export async function getLearningResourceById(id: string) {
  await verifyAdmin();
  return serverFetch(`/api/admin/learning-resources/${id}`);
}

export async function createLearningResource(formData: {
  title: string;
  description?: string;
  content_type: string;
  content_url?: string;
  thumbnail_url?: string;
  category?: string;
  tags?: string[];
  target_audience?: string[];
  is_active?: boolean;
  is_featured?: boolean;
}) {
  await verifyAdmin();

  return serverFetch(`/api/admin/learning-resources`, {
    method: "POST",
    body: JSON.stringify(formData),
  });
}

export async function updateLearningResource(
  id: string,
  formData: {
    title?: string;
    description?: string;
    content_type?: string;
    content_url?: string;
    thumbnail_url?: string;
    category?: string;
    tags?: string[];
    target_audience?: string[];
    is_active?: boolean;
    is_featured?: boolean;
  }
) {
  await verifyAdmin();

  return serverFetch(`/api/admin/learning-resources/${id}`, {
    method: "PUT",
    body: JSON.stringify(formData),
  });
}

export async function deleteLearningResource(id: string) {
  await verifyAdmin();

  await serverFetch(`/api/admin/learning-resources/${id}`, {
    method: "DELETE",
  });

  return { success: true };
}

export async function toggleLearningFeatured(id: string, featured: boolean) {
  await verifyAdmin();

  await serverFetch(`/api/admin/learning-resources/${id}`, {
    method: "PUT",
    body: JSON.stringify({ is_featured: featured }),
  });

  return { success: true };
}
