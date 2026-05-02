import { redirect } from "next/navigation";
import { cookies } from "next/headers";

const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000";

export type AdminSession = {
  id: string;
  email: string;
  role: string;
  permissions: Record<string, boolean> | null;
};

/**
 * Get the auth token from the admin-token cookie.
 * The login page sets this cookie via the API route.
 */
async function getAuthToken(): Promise<string | null> {
  try {
    const cookieStore = await cookies();
    return cookieStore.get("admin-token")?.value || null;
  } catch {
    return null;
  }
}

/**
 * Make an authenticated API call from the server side using the stored cookie token.
 */
export async function serverFetch<T = any>(
  path: string,
  options: RequestInit = {}
): Promise<T> {
  const token = await getAuthToken();
  const url = `${API_URL}${path}`;

  const headers: Record<string, string> = {
    "Content-Type": "application/json",
    ...(options.headers as Record<string, string>),
  };

  if (token) {
    headers["Authorization"] = `Bearer ${token}`;
  }

  const res = await fetch(url, {
    ...options,
    headers,
    cache: "no-store",
  });

  if (!res.ok) {
    const errorBody = await res.json().catch(() => ({ message: res.statusText }));
    const message = errorBody.message || errorBody.error || res.statusText;
    throw new Error(`${res.status}: ${message}`);
  }

  const text = await res.text();
  if (!text) return {} as T;
  return JSON.parse(text);
}

/**
 * Verifies the current user is an admin.
 * Redirects to /login if not authenticated or not an admin.
 */
export async function verifyAdmin(): Promise<AdminSession> {
  const token = await getAuthToken();

  if (!token) {
    redirect("/login");
  }

  // Try up to 2 times to handle transient errors (e.g. API server restart)
  let lastError: any = null;
  for (let attempt = 0; attempt < 2; attempt++) {
    try {
      const data = await serverFetch<any>("/api/auth/me");

      // API returns { profile, roleData } - extract the profile
      const profile = data?.profile || data;
      const role = profile?.userType || profile?.role;

      if (!profile || (role !== "admin" && role !== "super_admin")) {
        redirect("/login");
      }

      return {
        id: profile._id || profile.id,
        email: profile.email || "",
        role: role || "admin",
        permissions: data?.roleData?.permissions || null,
      };
    } catch (error: any) {
      // Always rethrow Next.js redirects
      if (error?.digest?.startsWith("NEXT_REDIRECT")) {
        throw error;
      }
      lastError = error;
      // Brief pause before retry
      if (attempt === 0) {
        await new Promise((r) => setTimeout(r, 500));
      }
    }
  }

  // Only redirect to login if we're sure it's an auth issue (401),
  // not a transient network error
  if (lastError?.message?.includes("401") || lastError?.message?.includes("Unauthorized")) {
    redirect("/login");
  }

  // For transient errors, throw so Next.js shows an error page
  // instead of losing the session by redirecting to login
  throw lastError || new Error("Failed to verify admin session");
}
