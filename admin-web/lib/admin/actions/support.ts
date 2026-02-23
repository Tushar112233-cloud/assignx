"use server";

import { createClient } from "@/lib/supabase/server";
import { verifyAdmin } from "@/lib/admin/auth";

export async function getTickets(params: {
  search?: string;
  status?: string;
  priority?: string;
  page?: number;
  perPage?: number;
}) {
  await verifyAdmin();
  const supabase = await createClient();

  const page = params.page || 1;
  const perPage = params.perPage || 20;
  const offset = (page - 1) * perPage;

  let query = supabase
    .from("support_tickets")
    .select(
      "*, requester:profiles!requester_id(id, full_name, email, avatar_url), assigned_admin:admins!assigned_to(id, profiles:profiles!profile_id(full_name, email))",
      { count: "exact" }
    )
    .order("created_at", { ascending: false })
    .range(offset, offset + perPage - 1);

  if (params.search) {
    query = query.or(
      `subject.ilike.%${params.search}%,ticket_number.ilike.%${params.search}%`
    );
  }
  if (params.status) query = query.eq("status", params.status);
  if (params.priority) query = query.eq("priority", params.priority);

  const { data: tickets, count, error } = await query;
  if (error) throw new Error(error.message);

  return {
    data: tickets || [],
    total: count || 0,
    page,
    total_pages: Math.ceil((count || 0) / perPage),
  };
}

export async function getTicketById(id: string) {
  await verifyAdmin();
  const supabase = await createClient();

  const [ticketResult, messagesResult] = await Promise.all([
    supabase
      .from("support_tickets")
      .select(
        "*, requester:profiles!requester_id(id, full_name, email, avatar_url), assigned_admin:admins!assigned_to(id, profiles:profiles!profile_id(full_name, email)), project:projects!project_id(id, title, status)"
      )
      .eq("id", id)
      .single(),
    supabase
      .from("ticket_messages")
      .select("*, sender:profiles!sender_id(id, full_name, email, avatar_url)")
      .eq("ticket_id", id)
      .order("created_at", { ascending: true }),
  ]);

  if (ticketResult.error) throw new Error(ticketResult.error.message);

  return {
    ticket: ticketResult.data,
    messages: messagesResult.data || [],
  };
}

export async function replyToTicket(
  ticketId: string,
  message: string,
  isInternal: boolean = false
) {
  const admin = await verifyAdmin();
  const supabase = await createClient();

  const { error: msgError } = await supabase.from("ticket_messages").insert({
    ticket_id: ticketId,
    sender_id: admin.profileId,
    sender_type: "admin",
    message,
    is_internal: isInternal,
  });

  if (msgError) throw new Error(msgError.message);

  // Update first_response_at if this is the first admin reply
  const { data: ticket } = await supabase
    .from("support_tickets")
    .select("first_response_at, status")
    .eq("id", ticketId)
    .single();

  const updates: Record<string, unknown> = {};
  if (!ticket?.first_response_at) {
    updates.first_response_at = new Date().toISOString();
  }
  if (ticket?.status === "open") {
    updates.status = "in_progress";
  }

  if (Object.keys(updates).length > 0) {
    await supabase.from("support_tickets").update(updates).eq("id", ticketId);
  }

  return { success: true };
}

export async function assignTicket(ticketId: string, adminId: string) {
  const admin = await verifyAdmin();
  const supabase = await createClient();

  const { error } = await supabase
    .from("support_tickets")
    .update({
      assigned_to: adminId,
      assigned_at: new Date().toISOString(),
    })
    .eq("id", ticketId);

  if (error) throw new Error(error.message);

  await supabase.from("admin_audit_logs").insert({
    admin_id: admin.id,
    action: "assign_ticket",
    target_type: "support_ticket",
    target_id: ticketId,
    details: { assigned_to: adminId },
  });

  return { success: true };
}

export async function resolveTicket(ticketId: string, resolutionNotes: string) {
  const admin = await verifyAdmin();
  const supabase = await createClient();

  const { error } = await supabase
    .from("support_tickets")
    .update({
      status: "resolved",
      resolved_at: new Date().toISOString(),
      resolved_by: admin.profileId,
      resolution_notes: resolutionNotes,
    })
    .eq("id", ticketId);

  if (error) throw new Error(error.message);

  await supabase.from("admin_audit_logs").insert({
    admin_id: admin.id,
    action: "resolve_ticket",
    target_type: "support_ticket",
    target_id: ticketId,
    details: { resolution_notes: resolutionNotes },
  });

  return { success: true };
}

export async function getTicketStats() {
  await verifyAdmin();
  const supabase = await createClient();

  const { data, error } = await supabase.rpc("admin_get_ticket_stats");

  if (error) {
    // Fallback: compute from support_tickets
    const { data: tickets } = await supabase
      .from("support_tickets")
      .select("status, priority, created_at, resolved_at");

    const all = tickets || [];
    const open = all.filter((t) => t.status === "open").length;
    const inProgress = all.filter((t) => t.status === "in_progress").length;
    const resolved = all.filter((t) => t.resolved_at);
    const avgResolution =
      resolved.length > 0
        ? resolved.reduce((sum, t) => {
            const created = new Date(t.created_at).getTime();
            const resolvedAt = new Date(t.resolved_at!).getTime();
            return sum + (resolvedAt - created);
          }, 0) /
          resolved.length /
          3600000
        : 0;

    return {
      open_count: open,
      in_progress_count: inProgress,
      avg_resolution_time: Math.round(avgResolution * 10) / 10,
      by_priority: {
        low: all.filter((t) => t.priority === "low").length,
        medium: all.filter((t) => t.priority === "medium").length,
        high: all.filter((t) => t.priority === "high").length,
        urgent: all.filter((t) => t.priority === "urgent").length,
      },
    };
  }

  return data;
}

export async function getAdmins() {
  await verifyAdmin();
  const supabase = await createClient();

  const { data, error } = await supabase
    .from("admins")
    .select("id, admin_role, profiles:profiles!profile_id(full_name, email)");

  if (error) throw new Error(error.message);
  return (data || []).map((admin: any) => ({
    id: admin.id,
    role: admin.admin_role,
    profiles: admin.profiles,
  }));
}
