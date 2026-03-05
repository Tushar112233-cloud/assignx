"use server";

import { cookies } from "next/headers";
import { revalidatePath } from "next/cache";
import { serverApiClient } from "@/lib/api/client";
import type { PortalRole } from "@/types/portals";

const VALID_ROLES: PortalRole[] = ["student", "professional", "business"];

async function getToken(): Promise<string | null> {
  const cookieStore = await cookies();
  return cookieStore.get("accessToken")?.value || null;
}

/**
 * Fetch user's roles from profile
 */
export async function getUserRoles(): Promise<PortalRole[]> {
  const token = await getToken();
  if (!token) return [];

  try {
    const profile = await serverApiClient("/api/users/me", {}, token);
    if (!profile) return [];

    // Check for extended roles from preferences
    if (profile.roles && Array.isArray(profile.roles) && profile.roles.length > 0) {
      return profile.roles as PortalRole[];
    }

    const userType = profile.user_type || profile.userType;
    return userType ? [userType as PortalRole] : [];
  } catch {
    return [];
  }
}

/**
 * Add a role to the current user
 */
export async function addUserRole(role: PortalRole): Promise<{ success?: boolean; error?: string }> {
  if (!VALID_ROLES.includes(role)) {
    return { error: "Invalid role" };
  }

  const token = await getToken();
  if (!token) return { error: "Not authenticated" };

  try {
    await serverApiClient("/api/users/me", {
      method: "POST",
      body: JSON.stringify({ role }),
    }, token);

    revalidatePath("/campus-connect");
    revalidatePath("/settings");
    return { success: true };
  } catch (error: any) {
    return { error: error.message };
  }
}

/**
 * Remove a role from the current user
 */
export async function removeUserRole(role: PortalRole): Promise<{ success?: boolean; error?: string }> {
  const token = await getToken();
  if (!token) return { error: "Not authenticated" };

  try {
    await serverApiClient("/api/users/me", {
      method: "DELETE",
      body: JSON.stringify({ role }),
    }, token);

    revalidatePath("/campus-connect");
    revalidatePath("/settings");
    return { success: true };
  } catch (error: any) {
    return { error: error.message };
  }
}
