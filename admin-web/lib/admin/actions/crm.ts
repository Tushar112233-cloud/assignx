"use server";

import { verifyAdmin, serverFetch } from "@/lib/admin/auth";

// ============================================================================
// CRM Dashboard
// ============================================================================

export async function getCrmDashboard() {
  await verifyAdmin();

  try {
    const result = await serverFetch(`/api/admin/crm/dashboard`);
    // Normalize topCustomers from API camelCase to component snake_case
    if (result.topCustomers && Array.isArray(result.topCustomers)) {
      result.topCustomers = result.topCustomers.map((c: any) => ({
        id: c.id || c._id,
        name: c.name || c.fullName || "Unknown",
        email: c.email || "",
        avatar_url: c.avatar_url || c.avatarUrl || null,
        user_type: c.user_type || c.userSubType || c.userType || "student",
        total: c.total ?? c.totalSpend ?? 0,
      }));
    }
    return result;
  } catch {
    return {
      totalCustomers: 0,
      activeThisMonth: 0,
      newThisMonth: 0,
      churnRate: 0,
      pipeline: {
        quoted: { count: 0, value: 0 },
        paid: { count: 0, value: 0 },
        in_progress: { count: 0, value: 0 },
        completed: { count: 0, value: 0 },
      },
      segments: {},
      topCustomers: [],
    };
  }
}

// ============================================================================
// Customer Segments
// ============================================================================

export async function getCustomerSegments() {
  await verifyAdmin();

  try {
    return await serverFetch(`/api/admin/crm/segments`);
  } catch {
    return {
      highValue: { count: 0, users: [] },
      atRisk: { count: 0, users: [] },
      newUsers: { count: 0, users: [] },
      repeat: { count: 0, users: [] },
    };
  }
}

// ============================================================================
// Communications
// ============================================================================

export async function getRecentCommunications(params: {
  type?: string;
  page?: number;
  perPage?: number;
}) {
  await verifyAdmin();

  const query = new URLSearchParams();
  if (params.type) query.set("type", params.type);
  if (params.page) query.set("page", String(params.page));
  if (params.perPage) query.set("perPage", String(params.perPage));

  try {
    return await serverFetch(`/api/admin/crm/communications?${query.toString()}`);
  } catch {
    return { data: [], total: 0, page: params.page || 1, totalPages: 1 };
  }
}

export async function sendAnnouncementNotification(params: {
  title: string;
  body: string;
  targetSegment: string;
  targetRole?: string;
}) {
  await verifyAdmin();

  return serverFetch(`/api/admin/crm/announcements`, {
    method: "POST",
    body: JSON.stringify(params),
  });
}

// ============================================================================
// Content Control
// ============================================================================

export async function getContentOverview() {
  await verifyAdmin();

  try {
    return await serverFetch(`/api/admin/crm/content-overview`);
  } catch {
    return {
      banners: { data: [], total: 0 },
      faqs: { data: [], total: 0 },
      listings: { data: [], total: 0 },
      campusPosts: { data: [], total: 0 },
      learningResources: { data: [], total: 0 },
    };
  }
}

export async function toggleContentStatus(
  table: "banners" | "faqs" | "learning_resources",
  id: string,
  active: boolean
) {
  await verifyAdmin();

  await serverFetch(`/api/admin/crm/content-status`, {
    method: "PUT",
    body: JSON.stringify({ table, id, active }),
  });

  return { success: true };
}

export async function moderateCampusPost(
  postId: string,
  action: "hide" | "unhide" | "flag" | "unflag"
) {
  await verifyAdmin();

  await serverFetch(`/api/admin/crm/moderate-post`, {
    method: "POST",
    body: JSON.stringify({ postId, action }),
  });

  return { success: true };
}

export async function moderateMarketplaceListing(
  listingId: string,
  action: "approve" | "reject" | "feature",
  reason?: string
) {
  await verifyAdmin();

  await serverFetch(`/api/admin/crm/moderate-listing`, {
    method: "POST",
    body: JSON.stringify({ listingId, action, reason }),
  });

  return { success: true };
}

export async function updateFaq(
  id: string,
  data: { question?: string; answer?: string; category?: string; is_active?: boolean; display_order?: number }
) {
  await verifyAdmin();

  await serverFetch(`/api/admin/crm/faqs/${id}`, {
    method: "PUT",
    body: JSON.stringify(data),
  });

  return { success: true };
}

export async function createFaq(data: {
  question: string;
  answer: string;
  category: string;
  target_role?: string;
  is_active?: boolean;
  display_order?: number;
}) {
  await verifyAdmin();

  return serverFetch(`/api/admin/crm/faqs`, {
    method: "POST",
    body: JSON.stringify(data),
  });
}

// ============================================================================
// Customer Detail (360-degree view)
// ============================================================================

export async function getCustomerDetail(customerId: string) {
  await verifyAdmin();

  try {
    return await serverFetch(`/api/admin/crm/customers/${customerId}`);
  } catch {
    throw new Error("Failed to load customer details");
  }
}

export async function addCustomerNote(customerId: string, note: string) {
  await verifyAdmin();

  await serverFetch(`/api/admin/crm/customers/${customerId}/notes`, {
    method: "POST",
    body: JSON.stringify({ note }),
  });

  return { success: true };
}

export async function getCustomerNotes(customerId: string) {
  await verifyAdmin();

  try {
    const data = await serverFetch(`/api/admin/crm/customers/${customerId}/notes`);
    return data || [];
  } catch {
    return [];
  }
}

export async function sendCustomerNotification(customerId: string, title: string, body: string) {
  await verifyAdmin();

  await serverFetch(`/api/notifications`, {
    method: "POST",
    body: JSON.stringify({
      profileId: customerId,
      notificationType: "system_alert",
      title,
      body,
      targetRole: "user",
    }),
  });

  return { success: true };
}
