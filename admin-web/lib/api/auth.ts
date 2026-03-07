import { apiClient } from "./client";

const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000";

/**
 * Login with email and password (admin panel uses password auth)
 */
export async function loginWithPassword(
  email: string,
  password: string
): Promise<{ success: boolean; error?: string; user?: any }> {
  try {
    const res = await fetch(`${API_URL}/api/auth/login`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email: email.toLowerCase().trim(), password }),
    });

    const data = await res.json();

    if (!res.ok) {
      return { success: false, error: data.message || data.error || "Invalid email or password." };
    }

    // Check admin role
    if (data.user?.role !== "admin" && data.user?.role !== "super_admin") {
      return { success: false, error: "You do not have admin access." };
    }

    // Store tokens
    if (data.accessToken) {
      localStorage.setItem("accessToken", data.accessToken);
    }
    if (data.refreshToken) {
      localStorage.setItem("refreshToken", data.refreshToken);
    }
    if (data.user) {
      localStorage.setItem("user", JSON.stringify(data.user));
    }

    return { success: true, user: data.user };
  } catch (error: any) {
    return { success: false, error: error.message || "Network error" };
  }
}

/**
 * Send a magic link email for passwordless login
 */
export async function sendMagicLink(
  email: string
): Promise<{ success: boolean; message?: string; error?: string }> {
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
 * Verify OTP code from magic link
 */
export async function verifyOTP(
  email: string,
  otp: string
): Promise<{ success: boolean; error?: string; user?: any }> {
  try {
    const res = await fetch(`${API_URL}/api/auth/verify`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email: email.toLowerCase().trim(), otp, purpose: 'login', role: 'admin' }),
    });

    const data = await res.json();

    if (!res.ok) {
      return { success: false, error: data.message || data.error || "Verification failed" };
    }

    // Check admin role
    if (data.user?.role !== "admin" && data.user?.role !== "super_admin") {
      return { success: false, error: "You do not have admin access." };
    }

    if (data.accessToken) localStorage.setItem("accessToken", data.accessToken);
    if (data.refreshToken) localStorage.setItem("refreshToken", data.refreshToken);
    if (data.user) localStorage.setItem("user", JSON.stringify(data.user));

    return { success: true, user: data.user };
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
 * Fetch current user from API (validates token)
 */
export async function getCurrentUser(): Promise<any | null> {
  try {
    const user = await apiClient("/api/auth/me");
    if (user) {
      localStorage.setItem("user", JSON.stringify(user));
    }
    return user;
  } catch {
    return null;
  }
}
