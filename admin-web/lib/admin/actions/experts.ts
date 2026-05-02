"use server";

import { verifyAdmin, serverFetch } from "@/lib/admin/auth";

// Normalize a raw expert object from the API (camelCase MongoDB fields)
// into the snake_case format expected by admin components.
// The API may return either or both formats; we handle all cases.
function normalizeExpert(raw: Record<string, unknown>) {
  return {
    id: (raw._id || raw.id || "") as string,
    full_name: (raw.full_name || raw.fullName || raw.name || "") as string,
    email: (raw.email || "") as string,
    avatar_url: (raw.avatar_url || raw.avatarUrl || null) as string | null,
    is_active: Boolean(raw.is_active !== undefined ? raw.is_active : raw.isActive !== undefined ? raw.isActive : true),
    category: (raw.category || null) as string | null,
    hourly_rate: (raw.hourly_rate ?? raw.hourlyRate ?? null) as number | null,
    verification_status: (raw.verification_status || raw.verificationStatus || "pending") as string,
    is_featured: Boolean(raw.is_featured !== undefined ? raw.is_featured : raw.isFeatured !== undefined ? raw.isFeatured : false),
    bio: (raw.bio || null) as string | null,
    qualifications: (raw.qualifications || null) as Record<string, unknown> | null,
    created_at: (raw.created_at || raw.createdAt || "") as string,
    // Detail view fields
    phone: (raw.phone || raw.whatsappNumber || raw.whatsapp_number || null) as string | null,
    city: (raw.city || raw.organization || null) as string | null,
    headline: (raw.headline || raw.title || null) as string | null,
    designation: (raw.designation || null) as string | null,
    review_count: (raw.review_count ?? raw.totalReviews ?? 0) as number,
    session_count: (raw.session_count ?? raw.totalSessions ?? 0) as number,
    availability_slots: (raw.availability_slots || raw.availabilitySlots || []) as Array<{day: string; startTime: string; endTime: string}>,
  };
}

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
      data: arr.map((e: Record<string, unknown>) => normalizeExpert(e)),
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
    const result = await serverFetch(`/api/experts/${id}`);
    const raw = result.expert || result;
    return normalizeExpert(raw);
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
  avatar_url?: string;
  availability_slots?: Array<{day: string; startTime: string; endTime: string}>;
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
      avatarUrl: params.avatar_url || null,
      availabilitySlots: params.availability_slots || [],
    }),
  });

  return { success: true, expertId: result._id || result.id };
}

export async function updateExpert(expertId: string, params: {
  full_name?: string;
  email?: string;
  headline?: string;
  designation?: string;
  organization?: string;
  category?: string;
  hourly_rate?: number;
  bio?: string;
  whatsapp_number?: string;
  avatar_url?: string;
  availability_slots?: Array<{day: string; startTime: string; endTime: string}>;
}) {
  await verifyAdmin();

  const body: Record<string, unknown> = {};
  if (params.full_name !== undefined) body.fullName = params.full_name;
  if (params.email !== undefined) body.email = params.email;
  if (params.headline !== undefined) body.headline = params.headline;
  if (params.designation !== undefined) body.designation = params.designation;
  if (params.organization !== undefined) body.organization = params.organization;
  if (params.category !== undefined) body.category = params.category;
  if (params.hourly_rate !== undefined) body.hourlyRate = params.hourly_rate;
  if (params.bio !== undefined) body.bio = params.bio;
  if (params.whatsapp_number !== undefined) body.whatsappNumber = params.whatsapp_number;
  if (params.avatar_url !== undefined) body.avatarUrl = params.avatar_url;
  if (params.availability_slots !== undefined) body.availabilitySlots = params.availability_slots;

  await serverFetch(`/api/experts/${expertId}`, {
    method: "PUT",
    body: JSON.stringify(body),
  });

  return { success: true };
}

export async function featureExpert(expertId: string, featured: boolean) {
  await verifyAdmin();

  await serverFetch(`/api/experts/${expertId}`, {
    method: "PUT",
    body: JSON.stringify({ isFeatured: featured }),
  });

  return { success: true };
}

/**
 * Fetch all expert bookings for the admin panel.
 */
export async function getExpertBookings(params?: {
  status?: string;
  page?: number;
  perPage?: number;
}) {
  await verifyAdmin();

  const query = new URLSearchParams();
  if (params?.status) query.set("status", params.status);
  if (params?.page) query.set("page", String(params.page));
  if (params?.perPage) query.set("perPage", String(params.perPage));

  try {
    const result = await serverFetch(`/api/experts/bookings/all?${query.toString()}`);
    const bookings = result.bookings || [];
    return {
      bookings: bookings.map((b: Record<string, unknown>) => ({
        id: (b._id || b.id || "") as string,
        expertId: b.expertId,
        userId: b.userId,
        date: b.date,
        startTime: (b.startTime || b.timeSlot || "") as string,
        endTime: (b.endTime || "") as string,
        duration: (b.duration || 60) as number,
        topic: (b.topic || "") as string,
        notes: (b.notes || "") as string,
        status: (b.status || "pending") as string,
        meetLink: (b.meetLink || "") as string,
        amount: (b.amount || 0) as number,
        paymentStatus: (b.paymentStatus || "pending") as string,
        paymentId: (b.paymentId || "") as string,
        createdAt: b.createdAt,
      })),
      total: result.total || bookings.length,
      page: result.page || 1,
      totalPages: result.totalPages || 1,
    };
  } catch {
    return { bookings: [], total: 0, page: 1, totalPages: 1 };
  }
}

/**
 * Update the meet link for a booking.
 */
export async function updateBookingMeetLink(bookingId: string, meetLink: string) {
  await verifyAdmin();

  await serverFetch(`/api/experts/bookings/${bookingId}/meet-link`, {
    method: "PUT",
    body: JSON.stringify({ meetLink }),
  });

  return { success: true };
}
