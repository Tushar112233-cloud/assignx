"use client";

// Admin login is handled client-side via the API.
// See login-form.tsx for the login implementation.

export async function logoutAdmin() {
  if (typeof window === "undefined") return;
  const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000";
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
    // Clear the httpOnly cookie
    await fetch("/api/auth/set-token", { method: "DELETE" }).catch(() => {});
  } finally {
    localStorage.removeItem("accessToken");
    localStorage.removeItem("refreshToken");
    localStorage.removeItem("user");
    window.location.href = "/login";
  }
}
