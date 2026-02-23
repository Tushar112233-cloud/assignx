"use server";

import { createClient } from "@/lib/supabase/server";
import { verifyAdmin } from "@/lib/admin/auth";

export async function getUsers(params: {
  search?: string;
  userType?: string;
  status?: string;
  page?: number;
  perPage?: number;
  sortBy?: string;
  sortOrder?: string;
}) {
  await verifyAdmin();
  const supabase = await createClient();

  const { data, error } = await supabase.rpc("admin_get_users", {
    p_search: params.search || null,
    p_user_type: params.userType || null,
    p_status: params.status || null,
    p_page: params.page || 1,
    p_per_page: params.perPage || 20,
    p_sort_by: params.sortBy || "created_at",
    p_sort_order: params.sortOrder || "desc",
  });

  if (error) throw new Error(error.message);
  return data;
}

export async function getUserById(userId: string) {
  await verifyAdmin();
  const supabase = await createClient();

  const { data: profile, error: profileError } = await supabase
    .from("profiles")
    .select("*")
    .eq("id", userId)
    .single();
  if (profileError) throw new Error(profileError.message);

  const { data: wallet } = await supabase
    .from("wallets")
    .select("*")
    .eq("profile_id", userId)
    .single();

  const { data: projects } = await supabase
    .from("projects")
    .select("id, title, status, service_type, user_quote, created_at")
    .eq("user_id", userId)
    .order("created_at", { ascending: false })
    .limit(10);

  const { data: activity } = await supabase
    .from("activity_logs")
    .select("*")
    .eq("profile_id", userId)
    .order("created_at", { ascending: false })
    .limit(20);

  return { profile, wallet, projects: projects || [], activity: activity || [] };
}

export async function suspendUser(userId: string, reason: string) {
  const admin = await verifyAdmin();
  const supabase = await createClient();

  const { error } = await supabase
    .from("profiles")
    .update({ is_active: false })
    .eq("id", userId);
  if (error) throw new Error(error.message);

  await supabase.from("admin_audit_logs").insert({
    admin_id: admin.id,
    action: "suspend_user",
    target_type: "profile",
    target_id: userId,
    details: { reason },
  });

  return { success: true };
}

export async function activateUser(userId: string) {
  const admin = await verifyAdmin();
  const supabase = await createClient();

  const { error } = await supabase
    .from("profiles")
    .update({ is_active: true })
    .eq("id", userId);
  if (error) throw new Error(error.message);

  await supabase.from("admin_audit_logs").insert({
    admin_id: admin.id,
    action: "activate_user",
    target_type: "profile",
    target_id: userId,
  });

  return { success: true };
}
