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
  if (params.perPage) query.set("limit", String(params.perPage));

  const result = await serverFetch(`/api/support/tickets?${query.toString()}`);
  const raw = result.tickets || result.data || [];
  const arr = raw.map((t: Record<string, unknown>) => ({
    ...t,
    id: t._id || t.id,
    ticket_number: t.ticketNumber || t.ticket_number || null,
    created_at: t.createdAt || t.created_at,
    requester: t.requester || (t.raisedByName ? { full_name: t.raisedByName } : null),
  }));
  return {
    data: arr,
    total: result.total || arr.length,
    page: result.page || params.page || 1,
    total_pages: result.totalPages || result.total_pages || 1,
  };
}

export async function getTicketById(id: string) {
  await verifyAdmin();
  const result = await serverFetch(`/api/support/tickets/${id}`);
  const t = result.ticket || result;
  const ticket = {
    ...t,
    id: t._id || t.id,
    subject: t.subject,
    description: t.description || null,
    status: t.status,
    priority: t.priority,
    createdAt: t.createdAt || t.created_at,
    resolvedAt: t.resolvedAt || t.resolved_at || null,
    resolutionNotes: t.resolutionNotes || t.resolution_notes || null,
    assignedTo: t.assignedTo || t.assigned_to || null,
    raisedById: t.raisedById || null,
    userName: t.userName || t.raisedByName || null,
  };
  const rawMessages = result.messages || t.messages || [];
  const messages = rawMessages.map((m: Record<string, unknown>) => ({
    _id: m._id || m.id,
    message: m.message,
    senderRole: m.senderRole || m.sender_type,
    senderName: m.senderName || (m.sender as Record<string, unknown>)?.full_name || null,
    isInternal: m.isInternal || m.is_internal || false,
    createdAt: m.createdAt || m.created_at,
  }));
  return { ticket, messages };
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
    const result = await serverFetch(`/api/admin/support/stats`);
    const s = result.stats || result;
    return {
      open_count: s.open ?? 0,
      in_progress_count: s.inProgress ?? 0,
      resolved_count: s.resolved ?? 0,
      closed_count: s.closed ?? 0,
      total_count: s.total ?? 0,
    };
  } catch {
    return {
      open_count: 0,
      in_progress_count: 0,
      resolved_count: 0,
      closed_count: 0,
      total_count: 0,
    };
  }
}

export async function getAdmins() {
  await verifyAdmin();

  try {
    const result = await serverFetch(`/api/admin/admins`);
    const raw = Array.isArray(result) ? result : result.admins || result.data || [];
    return raw.map((a: Record<string, unknown>) => ({
      id: a._id || a.id,
      full_name: a.fullName || a.full_name || null,
      role: a.adminRole || a.role || null,
      email: a.email || null,
    }));
  } catch {
    return [];
  }
}
