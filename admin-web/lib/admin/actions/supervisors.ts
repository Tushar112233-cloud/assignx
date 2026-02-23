"use server";

import { createClient } from "@/lib/supabase/server";
import { verifyAdmin } from "@/lib/admin/auth";

export async function getSupervisors(params: {
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

  // Query from supervisors table joined with profiles
  const { data: supervisorRows, count, error } = await supabase
    .from("supervisors")
    .select(
      `id, profile_id, is_activated, created_at,
       profile:profiles!supervisors_profile_id_fkey(id, full_name, email, avatar_url, phone, city, created_at, is_active)`,
      { count: "exact" }
    )
    .range(offset, offset + perPage - 1)
    .order("created_at", { ascending: false });

  if (error) throw new Error(error.message);

  const supervisors = await Promise.all(
    (supervisorRows || []).map(async (s: any) => {
      const profile = Array.isArray(s.profile) ? s.profile[0] : s.profile;

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
      if (params.status === "active" && !isActive) return null;
      if (params.status === "suspended" && isActive) return null;

      const { count: assignedCount } = await supabase
        .from("projects")
        .select("id", { count: "exact", head: true })
        .eq("supervisor_id", s.id);

      const { count: completedCount } = await supabase
        .from("projects")
        .select("id", { count: "exact", head: true })
        .eq("supervisor_id", s.id)
        .eq("status", "completed");

      const assigned = assignedCount || 0;
      const completed = completedCount || 0;

      return {
        id: s.id,
        profile_id: s.profile_id,
        full_name: profile?.full_name || null,
        email: profile?.email || null,
        avatar_url: profile?.avatar_url || null,
        phone: profile?.phone || null,
        city: profile?.city || null,
        is_active: isActive,
        created_at: profile?.created_at || s.created_at,
        projects_assigned: assigned,
        projects_completed: completed,
        completion_rate: assigned > 0 ? Math.round((completed / assigned) * 100) : 0,
      };
    })
  );

  const filtered = supervisors.filter(Boolean);

  return {
    data: filtered,
    total: count || 0,
    page,
    per_page: perPage,
    total_pages: Math.ceil((count || 0) / perPage) || 1,
  };
}

export async function getSupervisorById(supervisorId: string) {
  await verifyAdmin();
  const supabase = await createClient();

  // Get supervisor with profile
  const { data: supervisor, error } = await supabase
    .from("supervisors")
    .select(`id, profile_id, is_activated, created_at,
             profile:profiles!supervisors_profile_id_fkey(*)`)
    .eq("id", supervisorId)
    .single();

  if (error) throw new Error(error.message);

  const profile = Array.isArray(supervisor.profile)
    ? supervisor.profile[0]
    : supervisor.profile;

  const { data: projects } = await supabase
    .from("projects")
    .select("id, title, status, user_quote, user_id, doer_id, created_at")
    .eq("supervisor_id", supervisorId)
    .order("created_at", { ascending: false })
    .limit(50);

  const allProjects = projects || [];
  const completed = allProjects.filter((p: any) => p.status === "completed").length;
  const inProgress = allProjects.filter(
    (p: any) => p.status === "in_progress"
  ).length;

  return {
    profile,
    projects: allProjects,
    metrics: {
      total_projects: allProjects.length,
      completed,
      in_progress: inProgress,
      completion_rate:
        allProjects.length > 0
          ? Math.round((completed / allProjects.length) * 100)
          : 0,
    },
  };
}
