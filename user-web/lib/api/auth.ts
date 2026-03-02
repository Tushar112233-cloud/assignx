import { apiClient } from "./client";

const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000";

/** Emails that bypass magic link and login directly */
const DEV_BYPASS_EMAILS = ['admin@gmail.com', 'testuser@gmail.com', 'omrajpal.exe@gmail.com'];

/**
 * Check if email can use direct login (no OTP)
 */
export function isDevBypassEmail(email: string): boolean {
  return DEV_BYPASS_EMAILS.includes(email.toLowerCase().trim());
}

/**
 * Direct login without OTP for dev bypass emails
 */
export async function devLogin(email: string): Promise<{ success: boolean; error?: string; user?: any }> {
  try {
    const res = await fetch(`${API_URL}/api/auth/dev-login`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email: email.toLowerCase().trim(), role: "user" }),
    });

    const data = await res.json();

    if (!res.ok) {
      return { success: false, error: data.message || data.error || "Login failed" };
    }

    if (data.accessToken) {
      localStorage.setItem("accessToken", data.accessToken);
      document.cookie = `accessToken=${data.accessToken}; path=/; max-age=604800; SameSite=Lax`;
    }
    if (data.refreshToken) localStorage.setItem("refreshToken", data.refreshToken);
    const devUser = data.user || data.profile;
    if (devUser) localStorage.setItem("user", JSON.stringify(devUser));

    return { success: true, user: devUser };
  } catch (error: any) {
    return { success: false, error: error.message || "Network error" };
  }
}

/**
 * Send a magic link email for passwordless login
 */
export async function sendMagicLink(email: string): Promise<{ success: boolean; message?: string; error?: string }> {
  try {
    const res = await fetch(`${API_URL}/api/auth/magic-link`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email: email.toLowerCase().trim() }),
    });

    const data = await res.json();

    if (!res.ok) {
      return { success: false, error: data.message || data.error || "Failed to send magic link" };
    }

    return { success: true, message: data.message || "Magic link sent successfully" };
  } catch (error: any) {
    return { success: false, error: error.message || "Network error" };
  }
}

/**
 * Verify OTP code from magic link email
 */
export async function verifyOTP(
  email: string,
  otp: string
): Promise<{ success: boolean; error?: string; user?: any }> {
  try {
    const res = await fetch(`${API_URL}/api/auth/verify`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email: email.toLowerCase().trim(), otp }),
    });

    const data = await res.json();

    if (!res.ok) {
      return { success: false, error: data.message || data.error || "Verification failed" };
    }

    // Store tokens in localStorage and cookie (for server actions)
    if (data.accessToken) {
      localStorage.setItem("accessToken", data.accessToken);
      document.cookie = `accessToken=${data.accessToken}; path=/; max-age=604800; SameSite=Lax`;
    }
    if (data.refreshToken) {
      localStorage.setItem("refreshToken", data.refreshToken);
    }
    const user = data.user || data.profile;
    if (user) {
      localStorage.setItem("user", JSON.stringify(user));
    }

    return { success: true, user };
  } catch (error: any) {
    return { success: false, error: error.message || "Network error" };
  }
}

/**
 * Log out the current user
 */
export async function logout(): Promise<void> {
  try {
    const token = localStorage.getItem("accessToken");
    if (token) {
      await fetch(`${API_URL}/api/auth/logout`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      }).catch(() => {});
    }
  } finally {
    localStorage.removeItem("accessToken");
    localStorage.removeItem("refreshToken");
    localStorage.removeItem("user");
    document.cookie = "accessToken=; path=/; max-age=0";
    document.cookie = "loggedIn=; path=/; max-age=0";
  }
}

/**
 * Get the stored access token
 */
export function getAccessToken(): string | null {
  if (typeof window === "undefined") return null;
  return localStorage.getItem("accessToken");
}

/**
 * Check if user is currently logged in
 */
export function isLoggedIn(): boolean {
  if (typeof window === "undefined") return false;
  return !!localStorage.getItem("accessToken");
}

/**
 * Get the currently stored user data
 */
export function getStoredUser(): any | null {
  if (typeof window === "undefined") return null;
  try {
    const user = localStorage.getItem("user");
    return user ? JSON.parse(user) : null;
  } catch {
    return null;
  }
}

/**
 * Fetch current user from API
 */
export async function getCurrentUser(): Promise<any | null> {
  try {
    const user = await apiClient("/api/auth/me");
    // Update stored user data
    if (user) {
      localStorage.setItem("user", JSON.stringify(user));
    }
    return user;
  } catch {
    return null;
  }
}
