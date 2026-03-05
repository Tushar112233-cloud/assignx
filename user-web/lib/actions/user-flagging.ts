"use server";

import { cookies } from "next/headers";
import { serverApiClient } from "@/lib/api/client";

export type FlagReason = "phone_sharing" | "address_sharing" | "link_sharing" | "email_sharing";

export interface FlagUserResult {
  success: boolean;
  error?: string;
  flagCount?: number;
}

async function getToken(): Promise<string | null> {
  const cookieStore = await cookies();
  return cookieStore.get("accessToken")?.value || null;
}

/**
 * Flag a user for violating chat policies
 */
export async function flagUserForViolation(
  userId: string,
  reason: FlagReason
): Promise<FlagUserResult> {
  const token = await getToken();
  if (!token) return { success: false, error: "Not authenticated" };

  try {
    const result = await serverApiClient("/api/users/flag", {
      method: "POST",
      body: JSON.stringify({ userId, reason }),
    }, token);

    return { success: true, flagCount: result.flagCount };
  } catch (error: any) {
    return { success: false, error: error.message || "Failed to flag user" };
  }
}

/**
 * Check if a user is flagged
 */
export async function isUserFlagged(userId: string): Promise<boolean> {
  const token = await getToken();
  if (!token) return false;

  try {
    const result = await serverApiClient(`/api/users/${userId}/flag-status`, {}, token);
    return result.isFlagged || result.isBlocked || false;
  } catch {
    return false;
  }
}
