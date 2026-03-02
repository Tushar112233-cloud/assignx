"use server";

import { verifyAdmin, serverFetch } from "@/lib/admin/auth";

export async function getTickets(params: {
  search?: string;
  status?: string;
  priority?: string;
  page?: number;
  perPage?: number;
}) {
  await verifyAdmin();

  const query = new URLSearchParams();
  if (params.search) query.set("search", params.search);
  if (params.status) query.set("status", params.status);
  if (params.priority) query.set("priority", params.priority);
  if (params.page) query.set("page", String(params.page));
  if (params.perPage) query.set("perPage", String(params.perPage));

  const result = await serverFetch(`/api/support/tickets?${query.toString()}`);
  const arr = result.tickets || result.data || [];
  return {
    data: arr,
    total: result.total || arr.length,
    page: result.page || params.page || 1,
    total_pages: result.totalPages || result.total_pages || 1,
  };
}

export async function getTicketById(id: string) {
  await verifyAdmin();
  return serverFetch(`/api/support/tickets/${id}`);
}

export async function replyToTicket(
  ticketId: string,
  message: string,
  isInternal: boolean = false
) {
  await verifyAdmin();

  await serverFetch(`/api/support/tickets/${ticketId}/messages`, {
    method: "POST",
    body: JSON.stringify({ message, isInternal }),
  });

  return { success: true };
}

export async function assignTicket(ticketId: string, adminId: string) {
  await verifyAdmin();

  await serverFetch(`/api/support/tickets/${ticketId}`, {
    method: "PUT",
    body: JSON.stringify({ assignedTo: adminId }),
  });

  return { success: true };
}

export async function resolveTicket(ticketId: string, resolutionNotes: string) {
  await verifyAdmin();

  await serverFetch(`/api/support/tickets/${ticketId}`, {
    method: "PUT",
    body: JSON.stringify({
      status: "resolved",
      resolutionNotes,
    }),
  });

  return { success: true };
}

export async function getTicketStats() {
  await verifyAdmin();

  try {
    return await serverFetch(`/api/admin/support/stats`);
  } catch {
    return {
      open_count: 0,
      in_progress_count: 0,
      avg_resolution_time: 0,
      by_priority: { low: 0, medium: 0, high: 0, urgent: 0 },
    };
  }
}

export async function getAdmins() {
  await verifyAdmin();

  try {
    return await serverFetch(`/api/admin/admins`);
  } catch {
    return [];
  }
}
