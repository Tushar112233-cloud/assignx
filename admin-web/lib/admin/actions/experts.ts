"use server";

import { verifyAdmin, serverFetch } from "@/lib/admin/auth";

export async function getExperts(params: {
  search?: string;
  status?: string;
  category?: string;
  page?: number;
  perPage?: number;
}) {
  await verifyAdmin();

  const query = new URLSearchParams();
  if (params.search) query.set("search", params.search);
  if (params.status) query.set("status", params.status);
  if (params.category) query.set("category", params.category);
  if (params.page) query.set("page", String(params.page));
  if (params.perPage) query.set("perPage", String(params.perPage));

  try {
    const result = await serverFetch(`/api/experts?${query.toString()}`);
    const arr = result.experts || result.data || [];
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

export async function getExpertById(id: string) {
  await verifyAdmin();

  try {
    return await serverFetch(`/api/experts/${id}`);
  } catch {
    return null;
  }
}

export async function verifyExpert(expertId: string) {
  await verifyAdmin();

  await serverFetch(`/api/experts/${expertId}`, {
    method: "PUT",
    body: JSON.stringify({ verificationStatus: "verified" }),
  });

  return { success: true };
}

export async function rejectExpert(expertId: string, reason: string) {
  await verifyAdmin();

  await serverFetch(`/api/experts/${expertId}`, {
    method: "PUT",
    body: JSON.stringify({ verificationStatus: "rejected", rejectionReason: reason }),
  });

  return { success: true };
}

export async function suspendExpert(expertId: string) {
  await verifyAdmin();

  await serverFetch(`/api/experts/${expertId}`, {
    method: "PUT",
    body: JSON.stringify({ isActive: false }),
  });

  return { success: true };
}

export async function createExpert(params: {
  email: string;
  full_name: string;
  headline: string;
  designation: string;
  organization?: string;
  category: string;
  hourly_rate: number;
  bio?: string;
  whatsapp_number?: string;
}) {
  await verifyAdmin();

  const result = await serverFetch(`/api/experts`, {
    method: "POST",
    body: JSON.stringify({
      email: params.email,
      fullName: params.full_name,
      headline: params.headline,
      designation: params.designation,
      organization: params.organization || null,
      category: params.category,
      hourlyRate: params.hourly_rate,
      bio: params.bio || null,
      whatsappNumber: params.whatsapp_number || null,
    }),
  });

  return { success: true, expertId: result._id || result.id };
}

export async function featureExpert(expertId: string, featured: boolean) {
  await verifyAdmin();

  await serverFetch(`/api/experts/${expertId}`, {
    method: "PUT",
    body: JSON.stringify({ isFeatured: featured }),
  });

  return { success: true };
}
