"use server";

import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import { cookies } from "next/headers";
import { serverApiClient } from "@/lib/api/client";

/**
 * Helper to read the JWT from the cookie store (server-side).
 * The client sets `accessToken` as a cookie after login.
 */
async function getTokenFromCookies(): Promise<string | null> {
  const cookieStore = await cookies();
  return cookieStore.get("accessToken")?.value || null;
}

/**
 * Sign out the current user
 */
export async function signOut() {
  const cookieStore = await cookies();
  cookieStore.delete("accessToken");
  cookieStore.delete("refreshToken");
  cookieStore.delete("loggedIn");
  revalidatePath("/", "layout");
  redirect("/login");
}

/**
 * Get current user from API
 */
export async function getUser() {
  const token = await getTokenFromCookies();
  if (!token) return null;

  try {
    const user = await serverApiClient("/api/auth/me", {}, token);
    return user;
  } catch {
    return null;
  }
}

/**
 * Get auth user data for onboarding forms
 */
export async function getAuthUserData() {
  const token = await getTokenFromCookies();
  if (!token) return null;

  try {
    const user = await serverApiClient("/api/auth/me", {}, token);
    return {
      id: user._id || user.id,
      email: user.email || "",
      fullName: user.fullName || user.full_name || "",
      avatarUrl: user.avatarUrl || user.avatar_url || "",
    };
  } catch {
    return null;
  }
}

/**
 * Create or update user profile after signup
 */
export async function createProfile(data: {
  fullName: string;
  phone?: string;
  userType: "student" | "professional" | "business";
}) {
  const token = await getTokenFromCookies();
  if (!token) return { error: "Not authenticated" };

  try {
    const endpoint = data.userType === "student"
      ? "/api/profiles/student"
      : "/api/profiles/professional";

    await serverApiClient(endpoint, {
      method: "POST",
      body: JSON.stringify({
        fullName: data.fullName,
        phone: data.phone,
        userType: data.userType,
      }),
    }, token);

    revalidatePath("/", "layout");
    return { success: true };
  } catch (error: any) {
    return { error: error.message || "Failed to create profile" };
  }
}

/**
 * Create student profile with additional details
 */
export async function createStudentProfile(data: {
  fullName: string;
  dateOfBirth?: string;
  universityId: string;
  courseId: string;
  semester: number;
  yearOfStudy?: number;
  collegeEmail?: string;
  phone: string;
}) {
  const token = await getTokenFromCookies();
  if (!token) return { error: "Not authenticated" };

  try {
    await serverApiClient("/api/profiles/student", {
      method: "POST",
      body: JSON.stringify(data),
    }, token);

    revalidatePath("/", "layout");
    return { success: true };
  } catch (error: any) {
    return { error: error.message || "Failed to create student profile" };
  }
}

/**
 * Create professional profile
 */
export async function createProfessionalProfile(data: {
  fullName: string;
  industryId: string;
  phone: string;
}) {
  const token = await getTokenFromCookies();
  if (!token) return { error: "Not authenticated" };

  try {
    await serverApiClient("/api/profiles/professional", {
      method: "POST",
      body: JSON.stringify(data),
    }, token);

    revalidatePath("/", "layout");
    return { success: true };
  } catch (error: any) {
    return { error: error.message || "Failed to create professional profile" };
  }
}

/**
 * Generate a new 2FA secret and QR code URL
 */
export async function generate2FASecret() {
  const token = await getTokenFromCookies();
  if (!token) return { error: "Not authenticated" };

  try {
    return await serverApiClient("/api/auth/2fa/generate", { method: "POST" }, token);
  } catch (error: any) {
    return { error: error.message };
  }
}

/**
 * Verify a 2FA code against a secret
 */
export async function verify2FACode(secret: string, code: string) {
  try {
    // 2FA verification can be done client-side with TOTP, keeping server-side for now
    const token = await getTokenFromCookies();
    if (!token) return { valid: false };

    const result = await serverApiClient("/api/auth/2fa/verify", {
      method: "POST",
      body: JSON.stringify({ secret, code }),
    }, token);

    return { valid: result.valid || false };
  } catch {
    return { valid: false };
  }
}

/**
 * Enable 2FA for the current user
 */
export async function enable2FA(secret: string) {
  const token = await getTokenFromCookies();
  if (!token) return { error: "Not authenticated" };

  try {
    await serverApiClient("/api/auth/2fa/enable", {
      method: "POST",
      body: JSON.stringify({ secret }),
    }, token);

    revalidatePath("/profile");
    return { success: true };
  } catch (error: any) {
    return { error: error.message || "Failed to enable 2FA" };
  }
}

/**
 * Disable 2FA for the current user
 */
export async function disable2FA() {
  const token = await getTokenFromCookies();
  if (!token) return { error: "Not authenticated" };

  try {
    await serverApiClient("/api/auth/2fa/disable", {
      method: "POST",
    }, token);

    revalidatePath("/profile");
    return { success: true };
  } catch (error: any) {
    return { error: error.message || "Failed to disable 2FA" };
  }
}

/**
 * Check if user has 2FA enabled
 */
export async function get2FAStatus() {
  const token = await getTokenFromCookies();
  if (!token) return { enabled: false };

  try {
    const result = await serverApiClient("/api/auth/2fa/status", {}, token);
    return {
      enabled: result.enabled || false,
      verifiedAt: result.verifiedAt || null,
    };
  } catch {
    return { enabled: false };
  }
}

/**
 * Session info type for active sessions display
 */
export interface SessionInfo {
  id: string;
  device: string;
  browser: string;
  location: string;
  ipAddress: string;
  lastActive: string;
  current: boolean;
}

/**
 * Get active sessions for the current user
 */
export async function getActiveSessions(): Promise<{ sessions: SessionInfo[]; error: string | null }> {
  const token = await getTokenFromCookies();
  if (!token) return { sessions: [], error: "No active session" };

  try {
    const result = await serverApiClient<{ sessions: SessionInfo[] }>("/api/auth/sessions", {}, token);
    return { sessions: result.sessions || [], error: null };
  } catch (error: any) {
    // Return a mock current session if the endpoint doesn't exist yet
    return {
      sessions: [{
        id: "current",
        device: "Current Device",
        browser: "Browser",
        location: "Unknown",
        ipAddress: "Unknown",
        lastActive: new Date().toISOString(),
        current: true,
      }],
      error: null,
    };
  }
}

/**
 * Revoke a specific session
 */
export async function revokeSession(sessionId: string, isCurrent: boolean): Promise<{ success: boolean; error: string | null; shouldRedirect: boolean }> {
  if (isCurrent) {
    await signOut();
    return { success: true, error: null, shouldRedirect: true };
  }
  return { success: true, error: null, shouldRedirect: false };
}

/**
 * Revoke all other sessions
 */
export async function revokeAllOtherSessions(): Promise<{ success: boolean; error: string | null }> {
  const token = await getTokenFromCookies();
  if (!token) return { success: false, error: "Not authenticated" };

  try {
    await serverApiClient("/api/auth/sessions/revoke-all", { method: "POST" }, token);
    revalidatePath("/", "layout");
    return { success: true, error: null };
  } catch (error: any) {
    return { success: false, error: error.message };
  }
}

/**
 * Verify college email for Campus Connect access
 */
export async function verifyCollegeEmail(email: string, isAddingToAccount: boolean = false) {
  const token = await getTokenFromCookies();

  try {
    const result = await serverApiClient("/api/auth/verify-college", {
      method: "POST",
      body: JSON.stringify({ email, isAddingToAccount }),
    }, token || undefined);

    return result;
  } catch (error: any) {
    return { error: error.message || "Failed to verify college email" };
  }
}

/**
 * Sign in with Magic Link (server action wrapper)
 */
export async function signInWithMagicLink(email: string, redirectTo?: string) {
  try {
    const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000";
    const res = await fetch(`${API_URL}/api/auth/magic-link`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email: email.toLowerCase().trim() }),
    });

    const data = await res.json();

    if (!res.ok) {
      return { error: data.message || data.error || "Failed to send magic link" };
    }

    return { success: true, message: "Magic link sent successfully" };
  } catch (error: any) {
    return { error: error.message || "Network error" };
  }
}
