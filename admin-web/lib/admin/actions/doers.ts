"use server";

import { createClient } from "@/lib/supabase/server";
import { verifyAdmin } from "@/lib/admin/auth";

export async function getDoers(params: {
  search?: string;
  status?: string;
  page?: number;
  perPage?: number;
}) {
  await verifyAdmin();
  const supabase = await createClient();
  const page = params.page || 1;
  const perPage = params.perPage || 20;
  const offset = (page - 1) * perPage;

  // Query from doers table joined with profiles
  const { data: doerRows, count, error } = await supabase
    .from("doers")
    .select(
      `id, profile_id, is_activated, created_at,
       profile:profiles!doers_profile_id_fkey(id, full_name, email, avatar_url, phone, city, created_at, is_active)`,
      { count: "exact" }
    )
    .range(offset, offset + perPage - 1)
    .order("created_at", { ascending: false });

  if (error) throw new Error(error.message);

  const doers = await Promise.all(
    (doerRows || []).map(async (d: any) => {
      const profile = Array.isArray(d.profile) ? d.profile[0] : d.profile;

      // Filter by search on profile fields
      if (params.search) {
        const search = params.search.toLowerCase();
        if (
          !profile?.full_name?.toLowerCase().includes(search) &&
          !profile?.email?.toLowerCase().includes(search)
        ) {
          return null;
        }
      }

      const isActive = profile?.is_active ?? true;

      // Filter by status
      if (params.status === "active" && (!isActive || !d.is_activated)) return null;
      if (params.status === "suspended" && isActive) return null;
      if (params.status === "pending" && (d.is_activated || !isActive)) return null;

      const { count: assignedCount } = await supabase
        .from("projects")
        .select("id", { count: "exact", head: true })
        .eq("doer_id", d.id);

      const { count: completedCount } = await supabase
        .from("projects")
        .select("id", { count: "exact", head: true })
        .eq("doer_id", d.id)
        .eq("status", "completed");

      const assigned = assignedCount || 0;
      const completed = completedCount || 0;

      return {
        id: d.id,
        profile_id: d.profile_id,
        full_name: profile?.full_name || null,
        email: profile?.email || null,
        avatar_url: profile?.avatar_url || null,
        phone: profile?.phone || null,
        city: profile?.city || null,
        is_active: isActive,
        is_activated: d.is_activated ?? false,
        created_at: profile?.created_at || d.created_at,
        tasks_assigned: assigned,
        tasks_completed: completed,
        completion_rate: assigned > 0 ? Math.round((completed / assigned) * 100) : 0,
      };
    })
  );

  const filtered = doers.filter((d): d is NonNullable<typeof d> => d !== null);

  return {
    data: filtered,
    total: count || 0,
    page,
    per_page: perPage,
    total_pages: Math.ceil((count || 0) / perPage) || 1,
  };
}

export async function approveDoer(doerId: string) {
  const admin = await verifyAdmin();
  const supabase = await createClient();

  const { error } = await supabase
    .from("doers")
    .update({
      is_activated: true,
      activated_at: new Date().toISOString(),
      is_access_granted: true,
    })
    .eq("id", doerId);

  if (error) throw new Error(error.message);

  await supabase.from("admin_audit_logs").insert({
    admin_id: admin.id,
    action: "approve_doer",
    target_type: "doer",
    target_id: doerId,
    details: { approved_at: new Date().toISOString() },
  });

  return { success: true };
}

export async function rejectDoer(doerId: string, reason: string) {
  const admin = await verifyAdmin();
  const supabase = await createClient();

  const { error } = await supabase
    .from("doers")
    .update({
      is_activated: false,
      is_flagged: true,
      flag_reason: reason || "Rejected during onboarding review",
      flagged_by: admin.profileId,
      flagged_at: new Date().toISOString(),
    })
    .eq("id", doerId);

  if (error) throw new Error(error.message);

  await supabase.from("admin_audit_logs").insert({
    admin_id: admin.id,
    action: "reject_doer",
    target_type: "doer",
    target_id: doerId,
    details: { reason },
  });

  return { success: true };
}

export async function getDoerById(doerId: string) {
  await verifyAdmin();
  const supabase = await createClient();

  // Get doer with profile
  const { data: doer, error } = await supabase
    .from("doers")
    .select(`id, profile_id, is_activated, created_at,
             profile:profiles!doers_profile_id_fkey(*)`)
    .eq("id", doerId)
    .single();

  if (error) throw new Error(error.message);

  const profile = Array.isArray(doer.profile) ? doer.profile[0] : doer.profile;

  const { data: projects } = await supabase
    .from("projects")
    .select("id, title, status, price, user_quote, user_id, supervisor_id, created_at")
    .eq("doer_id", doerId)
    .order("created_at", { ascending: false })
    .limit(50);

  const allProjects = projects || [];
  const completed = allProjects.filter((p: any) => p.status === "completed").length;
  const inProgress = allProjects.filter(
    (p: any) => p.status === "in_progress"
  ).length;

  return {
    profile,
    tasks: allProjects,
    metrics: {
      total_tasks: allProjects.length,
      completed,
      in_progress: inProgress,
      completion_rate:
        allProjects.length > 0
          ? Math.round((completed / allProjects.length) * 100)
          : 0,
    },
  };
}
