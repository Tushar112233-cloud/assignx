"use server"

/**
 * @fileoverview Server actions for project operations.
 * Uses Express API for fetching unassigned projects and claiming.
 * @module app/actions/projects
 */

import { z } from "zod"
import { cookies } from "next/headers"

const API_BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000"

/**
 * Helper to get auth token from cookies in server actions.
 */
async function getToken(): Promise<string | null> {
  const cookieStore = await cookies()
  return cookieStore.get("supervisor_token")?.value || null
}

/**
 * Fetch NEW/UNASSIGNED projects that need a supervisor.
 */
export async function fetchNewRequestsAction() {
  try {
    const token = await getToken()
    if (!token) {
      return { data: [], error: "Not authenticated" }
    }

    const res = await fetch(`${API_BASE}/api/projects?unassigned=true&status=submitted,analyzing`, {
      headers: { Authorization: `Bearer ${token}` },
    })

    if (!res.ok) {
      return { data: [], error: "Failed to fetch new requests" }
    }

    const data = await res.json()
    return { data: data.projects || data || [], error: null }
  } catch (error) {
    console.error("fetchNewRequestsAction error:", error)
    return { data: [], error: "An unexpected error occurred" }
  }
}

const claimProjectSchema = z.object({
  projectId: z.string().uuid("Invalid project ID"),
})

/**
 * Claim a project - assign it to the current supervisor.
 */
export async function claimProjectAction(params: unknown) {
  const parsed = claimProjectSchema.safeParse(params)
  if (!parsed.success) {
    return { success: false, error: parsed.error.issues[0]?.message || "Invalid input" }
  }

  const { projectId } = parsed.data

  try {
    const token = await getToken()
    if (!token) {
      return { success: false, error: "Not authenticated" }
    }

    const res = await fetch(`${API_BASE}/api/projects/${projectId}/claim`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
    })

    if (!res.ok) {
      const data = await res.json().catch(() => ({}))
      return { success: false, error: data.error || "Failed to claim project" }
    }

    return { success: true }
  } catch (error) {
    console.error("claimProjectAction error:", error)
    return { success: false, error: "An unexpected error occurred" }
  }
}
