const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000";

/**
 * Get the stored access token
 */
function getAccessToken(): string | null {
  if (typeof window === "undefined") return null;
  return localStorage.getItem("accessToken");
}

/**
 * Get the stored refresh token
 */
function getRefreshToken(): string | null {
  if (typeof window === "undefined") return null;
  return localStorage.getItem("refreshToken");
}

/**
 * Attempt to refresh the access token using the refresh token
 */
async function refreshAccessToken(): Promise<string | null> {
  const refreshToken = getRefreshToken();
  if (!refreshToken) return null;

  try {
    const res = await fetch(`${API_URL}/api/auth/refresh`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refreshToken }),
    });

    if (!res.ok) return null;

    const data = await res.json();
    if (data.accessToken) {
      localStorage.setItem("accessToken", data.accessToken);
      if (data.refreshToken) {
        localStorage.setItem("refreshToken", data.refreshToken);
      }
      return data.accessToken;
    }
    return null;
  } catch {
    return null;
  }
}

/**
 * Generic fetch wrapper that adds Authorization header and handles 401 refresh.
 * Used by client components.
 */
export async function apiClient<T = any>(
  path: string,
  options: RequestInit & { isFormData?: boolean } = {}
): Promise<T> {
  const { isFormData, ...fetchOptions } = options;
  const url = `${API_URL}${path}`;

  const headers: Record<string, string> = {};
  const token = getAccessToken();
  if (token) {
    headers["Authorization"] = `Bearer ${token}`;
  }
  if (!isFormData) {
    headers["Content-Type"] = "application/json";
  }

  const mergedHeaders = {
    ...headers,
    ...(fetchOptions.headers as Record<string, string>),
  };

  let res = await fetch(url, {
    ...fetchOptions,
    headers: mergedHeaders,
    cache: "no-store",
  });

  // If 401, try refreshing the token once
  if (res.status === 401) {
    const newToken = await refreshAccessToken();
    if (newToken) {
      mergedHeaders["Authorization"] = `Bearer ${newToken}`;
      res = await fetch(url, {
        ...fetchOptions,
        headers: mergedHeaders,
        cache: "no-store",
      });
    } else {
      if (typeof window !== "undefined") {
        localStorage.removeItem("accessToken");
        localStorage.removeItem("refreshToken");
        localStorage.removeItem("user");
        window.location.href = "/login";
      }
      throw new Error("Session expired");
    }
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
 * Server-side API client for use in Server Components and Server Actions.
 * Reads the token from cookies.
 */
export async function serverApiClient<T = any>(
  path: string,
  options: RequestInit = {},
  token?: string
): Promise<T> {
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
    throw new Error(errorBody.message || errorBody.error || res.statusText);
  }

  const text = await res.text();
  if (!text) return {} as T;
  return JSON.parse(text);
}
