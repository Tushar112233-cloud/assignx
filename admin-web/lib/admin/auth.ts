import { redirect } from "next/navigation";
import { cookies } from "next/headers";

const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000";

export type AdminSession = {
  id: string;
  profileId: string;
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

  if (res.status === 401) {
    redirect("/login");
  }

  if (!res.ok) {
    const errorBody = await res.json().catch(() => ({ message: res.statusText }));
    throw new Error(errorBody.message || errorBody.error || res.statusText);
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
      profileId: profile._id || profile.id,
      email: profile.email || "",
      role: role || "admin",
      permissions: data?.roleData?.permissions || null,
    };
  } catch (error: any) {
    if (error?.digest?.startsWith("NEXT_REDIRECT")) {
      throw error;
    }
    redirect("/login");
  }
}
