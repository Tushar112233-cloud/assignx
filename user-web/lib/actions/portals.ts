"use server";

import { createClient, createAdminClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";
import type { PortalRole } from "@/types/portals";

const VALID_ROLES: PortalRole[] = ["student", "professional", "business"];

/**
 * Get user ID for data fetching (mirrors data.ts pattern)
 */
async function getUserId(): Promise<string | null> {
  const requireLogin = process.env.NEXT_PUBLIC_REQUIRE_LOGIN !== "false";

  if (!requireLogin) {
    const adminClient = createAdminClient();
    if (!adminClient) return null;

    const devEmail = process.env.NEXT_PUBLIC_DEV_USER_EMAIL || "omrajpal.exe@gmail.com";
    const { data: profile } = await adminClient
      .from("profiles")
      .select("id")
      .eq("email", devEmail)
      .single();

    return profile?.id || null;
  }

  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  return user?.id || null;
}

/**
 * Get the appropriate Supabase client for profile mutations.
 * In dev mode (no login required), uses admin client to bypass RLS.
 * In prod mode, uses the normal auth client.
 */
async function getClientForMutation() {
  const requireLogin = process.env.NEXT_PUBLIC_REQUIRE_LOGIN !== "false";

  if (!requireLogin) {
    const adminClient = createAdminClient();
    if (adminClient) return adminClient;
  }

  return createClient();
}

/**
 * Fetch user's roles from profile
 */
export async function getUserRoles(): Promise<PortalRole[]> {
  const supabase = await createClient();
  const userId = await getUserId();

  if (!userId) return [];

  // Try fetching user_roles column; if it doesn't exist, fall back to user_type only
  const { data: profile, error } = await supabase
    .from("profiles")
    .select("user_type, user_roles")
    .eq("id", userId)
    .single();

  if (error || !profile) return [];

  // If user_roles exists and has values, use it
  const roles = profile.user_roles;
  if (Array.isArray(roles) && roles.length > 0) {
    return roles as PortalRole[];
  }

  return [profile.user_type as PortalRole];
}

/**
 * Add a role to the current user (direct column update, no RPC needed)
 */
export async function addUserRole(role: PortalRole): Promise<{ success?: boolean; error?: string }> {
  if (!VALID_ROLES.includes(role)) {
    return { error: "Invalid role" };
  }

  const userId = await getUserId();
  if (!userId) return { error: "Not authenticated" };

  const client = await getClientForMutation();

  // Fetch current profile
  const { data: profile, error: fetchError } = await client
    .from("profiles")
    .select("user_type, user_roles")
    .eq("id", userId)
    .single();

  if (fetchError || !profile) {
    return { error: "Could not fetch profile" };
  }

  // Build current roles array (handle column not existing yet)
  const currentRoles: string[] = Array.isArray(profile.user_roles) && profile.user_roles.length > 0
    ? profile.user_roles
    : [profile.user_type];

  // Already has this role
  if (currentRoles.includes(role)) {
    return { success: true };
  }

  const newRoles = [...currentRoles, role];

  const { error: updateError } = await client
    .from("profiles")
    .update({
      user_roles: newRoles,
      updated_at: new Date().toISOString(),
    })
    .eq("id", userId);

  if (updateError) {
    // If user_roles column doesn't exist yet, give clear error
    if (updateError.message?.includes("user_roles") || updateError.code === "42703") {
      return { error: "The user_roles column hasn't been added yet. Please run the database migration first." };
    }
    return { error: updateError.message };
  }

  revalidatePath("/campus-connect");
  revalidatePath("/settings");
  return { success: true };
}

/**
 * Remove a role from the current user (direct column update, no RPC needed)
 */
export async function removeUserRole(role: PortalRole): Promise<{ success?: boolean; error?: string }> {
  const userId = await getUserId();
  if (!userId) return { error: "Not authenticated" };

  const client = await getClientForMutation();

  // Fetch current profile
  const { data: profile, error: fetchError } = await client
    .from("profiles")
    .select("user_type, user_roles")
    .eq("id", userId)
    .single();

  if (fetchError || !profile) {
    return { error: "Could not fetch profile" };
  }

  // Cannot remove primary role
  if (profile.user_type === role) {
    return { error: "Cannot remove your primary role" };
  }

  const currentRoles: string[] = Array.isArray(profile.user_roles) && profile.user_roles.length > 0
    ? profile.user_roles
    : [profile.user_type];

  // Role not present — nothing to remove
  if (!currentRoles.includes(role)) {
    return { success: true };
  }

  const newRoles = currentRoles.filter((r: string) => r !== role);

  if (newRoles.length < 1) {
    return { error: "Cannot remove last role" };
  }

  const { error: updateError } = await client
    .from("profiles")
    .update({
      user_roles: newRoles,
      updated_at: new Date().toISOString(),
    })
    .eq("id", userId);

  if (updateError) {
    if (updateError.message?.includes("user_roles") || updateError.code === "42703") {
      return { error: "The user_roles column hasn't been added yet. Please run the database migration first." };
    }
    return { error: updateError.message };
  }

  revalidatePath("/campus-connect");
  revalidatePath("/settings");
  return { success: true };
}
