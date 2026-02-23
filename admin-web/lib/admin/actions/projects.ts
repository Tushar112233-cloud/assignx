"use server";

import { createClient } from "@/lib/supabase/server";
import { verifyAdmin } from "@/lib/admin/auth";

export async function getProjects(params: {
  search?: string;
  status?: string;
  dateFrom?: string;
  dateTo?: string;
  supervisorId?: string;
  doerId?: string;
  page?: number;
  perPage?: number;
}) {
  await verifyAdmin();
  const supabase = await createClient();

  const { data, error } = await supabase.rpc("admin_get_projects", {
    p_search: params.search || null,
    p_status: params.status || null,
    p_date_from: params.dateFrom || null,
    p_date_to: params.dateTo || null,
    p_supervisor_id: params.supervisorId || null,
    p_doer_id: params.doerId || null,
    p_page: params.page || 1,
    p_per_page: params.perPage || 20,
  });

  if (error) {
    // Fallback to direct query if RPC not available
    const page = params.page || 1;
    const perPage = params.perPage || 20;
    const offset = (page - 1) * perPage;

    let query = supabase
      .from("projects")
      .select(
        "*, user:profiles!projects_user_id_fkey(id, full_name, email, avatar_url), supervisor:supervisors!projects_supervisor_id_fkey(id, profile:profiles!supervisors_profile_id_fkey(id, full_name, email)), doer:doers!projects_doer_id_fkey(id, profile:profiles!doers_profile_id_fkey(id, full_name, email))",
        { count: "exact" }
      )
      .order("created_at", { ascending: false })
      .range(offset, offset + perPage - 1);

    if (params.search) {
      query = query.or(
        `title.ilike.%${params.search}%,description.ilike.%${params.search}%`
      );
    }
    if (params.status) query = query.eq("status", params.status);
    if (params.dateFrom) query = query.gte("created_at", params.dateFrom);
    if (params.dateTo) query = query.lte("created_at", params.dateTo);
    if (params.supervisorId) query = query.eq("supervisor_id", params.supervisorId);
    if (params.doerId) query = query.eq("doer_id", params.doerId);

    const { data: projects, count, error: fallbackError } = await query;
    if (fallbackError) throw new Error(fallbackError.message);

    return {
      data: projects || [],
      total: count || 0,
      page,
      total_pages: Math.ceil((count || 0) / perPage),
    };
  }

  return data;
}

export async function getProjectById(id: string) {
  await verifyAdmin();
  const supabase = await createClient();

  const [projectResult, historyResult, filesResult, paymentsResult] =
    await Promise.all([
      supabase
        .from("projects")
        .select(
          "*, user:profiles!projects_user_id_fkey(id, full_name, email, avatar_url), supervisor:supervisors!projects_supervisor_id_fkey(id, profile:profiles!supervisors_profile_id_fkey(id, full_name, email, avatar_url)), doer:doers!projects_doer_id_fkey(id, profile:profiles!doers_profile_id_fkey(id, full_name, email, avatar_url))"
        )
        .eq("id", id)
        .single(),
      supabase
        .from("project_status_history")
        .select("*, changed_by_profile:profiles!changed_by(full_name)")
        .eq("project_id", id)
        .order("created_at", { ascending: false }),
      supabase
        .from("project_files")
        .select("*")
        .eq("project_id", id)
        .order("created_at", { ascending: false }),
      supabase
        .from("wallet_transactions")
        .select("id, transaction_type, amount, status, description, created_at")
        .eq("reference_id", id)
        .order("created_at", { ascending: false }),
    ]);

  if (projectResult.error) throw new Error(projectResult.error.message);

  // Flatten supervisor/doer nested profile
  const raw = projectResult.data as any;
  const supervisorRaw = raw.supervisor as { id: string; profile: Record<string, unknown> } | null;
  const doerRaw = raw.doer as { id: string; profile: Record<string, unknown> } | null;

  const project = {
    ...raw,
    price: raw.user_quote,
    supervisor: supervisorRaw?.profile ?? null,
    doer: doerRaw?.profile ?? null,
  };

  // Map from_status/to_status/notes to old_status/new_status/reason for the UI
  const statusHistory = (historyResult.data || []).map((entry: any) => ({
    id: entry.id,
    old_status: entry.from_status,
    new_status: entry.to_status,
    reason: entry.notes,
    created_at: entry.created_at,
    changed_by_profile: entry.changed_by_profile,
  }));

  // Map transaction_type → type for the UI
  const payments = (paymentsResult.data || []).map((txn: any) => ({
    ...txn,
    type: txn.transaction_type,
  }));

  return {
    project,
    statusHistory,
    files: filesResult.data || [],
    payments,
  };
}

export async function updateProjectStatus(
  projectId: string,
  newStatus: string,
  reason?: string
) {
  const admin = await verifyAdmin();
  const supabase = await createClient();

  const { data: project, error: fetchError } = await supabase
    .from("projects")
    .select("status")
    .eq("id", projectId)
    .single();

  if (fetchError) throw new Error(fetchError.message);

  const oldStatus = project.status;

  const { error: updateError } = await supabase
    .from("projects")
    .update({ status: newStatus, updated_at: new Date().toISOString() })
    .eq("id", projectId);

  if (updateError) throw new Error(updateError.message);

  await supabase.from("project_status_history").insert({
    project_id: projectId,
    from_status: oldStatus,
    to_status: newStatus,
    changed_by: admin.profileId,
    notes: reason || null,
  });

  await supabase.from("admin_audit_logs").insert({
    admin_id: admin.id,
    action: "update_project_status",
    target_type: "project",
    target_id: projectId,
    details: { old_status: oldStatus, new_status: newStatus, reason },
  });

  return { success: true };
}

export async function reassignProject(
  projectId: string,
  newDoerId: string,
  reason?: string
) {
  const admin = await verifyAdmin();
  const supabase = await createClient();

  const { data: project, error: fetchError } = await supabase
    .from("projects")
    .select("doer_id")
    .eq("id", projectId)
    .single();

  if (fetchError) throw new Error(fetchError.message);

  const oldDoerId = project.doer_id;

  const { error: updateError } = await supabase
    .from("projects")
    .update({ doer_id: newDoerId, updated_at: new Date().toISOString() })
    .eq("id", projectId);

  if (updateError) throw new Error(updateError.message);

  await supabase.from("admin_audit_logs").insert({
    admin_id: admin.id,
    action: "reassign_project",
    target_type: "project",
    target_id: projectId,
    details: { old_doer_id: oldDoerId, new_doer_id: newDoerId, reason },
  });

  return { success: true };
}
