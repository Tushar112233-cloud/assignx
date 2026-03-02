/**
 * Server-side API helpers for Next.js API routes and Server Components.
 *
 * These utilities extract the JWT from incoming requests (cookies or
 * Authorization header) and forward it to the Express API server.
 */

import { cookies } from "next/headers";
import { NextRequest } from "next/server";

const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000";

/**
 * Extract the JWT bearer token from a NextRequest.
 * Checks the Authorization header first, then falls back to the
 * `accessToken` cookie that the client sets after login.
 */
export function extractToken(request: NextRequest): string | null {
  const authHeader = request.headers.get("authorization");
  if (authHeader?.startsWith("Bearer ")) {
    return authHeader.substring(7);
  }
  return request.cookies.get("accessToken")?.value ?? null;
}

/**
 * Extract the JWT bearer token from the cookie store (for server actions / RSC).
 */
export async function extractTokenFromCookies(): Promise<string | null> {
  try {
    const cookieStore = await cookies();
    return cookieStore.get("accessToken")?.value ?? null;
  } catch {
    return null;
  }
}

/**
 * Validate a JWT by calling the Express API's /api/auth/me endpoint.
 * Returns the user object if valid, or null.
 */
export async function validateToken(
  token: string
): Promise<{ id: string; email: string; [key: string]: unknown } | null> {
  try {
    const res = await fetch(`${API_URL}/api/auth/me`, {
      headers: { Authorization: `Bearer ${token}` },
      cache: "no-store",
    });
    if (!res.ok) return null;
    return res.json();
  } catch {
    return null;
  }
}

/**
 * Generic server-side fetch wrapper that adds the Bearer token and
 * calls the Express API.  Designed for use inside Next.js API routes.
 */
export async function serverFetch<T = unknown>(
  path: string,
  token: string | null,
  options: RequestInit = {}
): Promise<{ data: T | null; error: string | null; status: number }> {
  const url = `${API_URL}${path}`;
  const headers: Record<string, string> = {
    "Content-Type": "application/json",
    ...(options.headers as Record<string, string>),
  };

  if (token) {
    headers["Authorization"] = `Bearer ${token}`;
  }

  try {
    const res = await fetch(url, {
      ...options,
      headers,
      cache: "no-store",
    });

    const text = await res.text();
    const body = text ? JSON.parse(text) : {};

    if (!res.ok) {
      return {
        data: null,
        error: body.message || body.error || res.statusText,
        status: res.status,
      };
    }

    return { data: body as T, error: null, status: res.status };
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : "Network error";
    return { data: null, error: message, status: 500 };
  }
}
