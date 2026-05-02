import { apiClient } from "./client";

const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000";

const DEV_BYPASS_EMAILS: string[] = [];

export function isDevBypassEmail(email: string): boolean {
  return DEV_BYPASS_EMAILS.includes(email.toLowerCase().trim());
}

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

    storeTokens(data);
    return { success: true, user: data.user || data.profile };
  } catch (error: any) {
    return { success: false, error: error.message || "Network error" };
  }
}

export async function checkAccount(email: string): Promise<{ exists: boolean; error?: string }> {
  try {
    const res = await fetch(`${API_URL}/api/auth/check-account`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email: email.toLowerCase().trim() }),
    });

    const data = await res.json();
    if (!res.ok) {
      return { exists: false, error: data.message || "Check failed" };
    }

    return { exists: data.exists };
  } catch (error: any) {
    return { exists: false, error: error.message || "Network error" };
  }
}

export async function sendOTP(
  email: string,
  purpose: 'login' | 'signup',
  role?: string
): Promise<{ success: boolean; message?: string; error?: string }> {
  try {
    const res = await fetch(`${API_URL}/api/auth/send-otp`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email: email.toLowerCase().trim(), purpose, role }),
    });

    const data = await res.json();
    if (!res.ok) {
      return { success: false, error: data.message || data.error || "Failed to send OTP" };
    }

    return { success: true, message: data.message || "Verification code sent" };
  } catch (error: any) {
    return { success: false, error: error.message || "Network error" };
  }
}

export async function verifyOTP(
  email: string,
  otp: string,
  purpose: 'login' | 'signup',
  role?: string
): Promise<{ success: boolean; error?: string; user?: any }> {
  try {
    const res = await fetch(`${API_URL}/api/auth/verify`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email: email.toLowerCase().trim(), otp, purpose, role }),
    });

    const data = await res.json();
    if (!res.ok) {
      return { success: false, error: data.message || data.error || "Verification failed" };
    }

    storeTokens(data);
    return { success: true, user: data.user || data.profile };
  } catch (error: any) {
    return { success: false, error: error.message || "Network error" };
  }
}

function storeTokens(data: any) {
  if (data.accessToken) {
    localStorage.setItem("accessToken", data.accessToken);
    const secure = window.location.protocol === 'https:' ? '; Secure' : '';
    document.cookie = `accessToken=${data.accessToken}; path=/; max-age=604800; SameSite=Lax${secure}`;
    document.cookie = `loggedIn=true; path=/; max-age=604800; SameSite=Lax${secure}`;
    const user = data.user || data.profile;
    if (user?.onboardingCompleted) {
      document.cookie = `onboardingCompleted=true; path=/; max-age=604800; SameSite=Lax${secure}`;
    }
  }
  if (data.refreshToken) {
    localStorage.setItem("refreshToken", data.refreshToken);
  }
  const user = data.user || data.profile;
  if (user) {
    localStorage.setItem("user", JSON.stringify(user));
  }
}

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
    document.cookie = "onboardingCompleted=; path=/; max-age=0";
  }
}

export function getAccessToken(): string | null {
  if (typeof window === "undefined") return null;
  return localStorage.getItem("accessToken");
}

export function isLoggedIn(): boolean {
  if (typeof window === "undefined") return false;
  return !!localStorage.getItem("accessToken");
}

export function getStoredUser(): any | null {
  if (typeof window === "undefined") return null;
  try {
    const user = localStorage.getItem("user");
    return user ? JSON.parse(user) : null;
  } catch {
    return null;
  }
}

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
