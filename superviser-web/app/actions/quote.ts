"use server"

/**
 * @fileoverview Server actions for quote operations.
 * @module app/actions/quote
 */

import { z } from "zod"
import { cookies } from "next/headers"

const API_BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000"

const submitQuoteSchema = z.object({
  projectId: z.string().uuid("Invalid project ID"),
  userQuote: z.number().positive("User quote must be positive"),
  doerPayout: z.number().positive("Doer payout must be positive"),
})

interface QuoteResult {
  success: boolean
  error?: string
}

/**
 * Submit a quote for a project.
 * Validates the supervisor is assigned to the project before updating.
 * Commission and platform fee are calculated server-side for financial integrity.
 */
export async function submitQuoteAction(params: unknown): Promise<QuoteResult> {
  const parsed = submitQuoteSchema.safeParse(params)
  if (!parsed.success) {
    return { success: false, error: parsed.error.issues[0]?.message || "Invalid input" }
  }

  const { projectId, userQuote, doerPayout } = parsed.data

  try {
    const cookieStore = await cookies()
    const token = cookieStore.get("supervisor_token")?.value

    if (!token) {
      return { success: false, error: "Not authenticated" }
    }

    const res = await fetch(`${API_BASE}/api/projects/${projectId}/quote`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({
        userQuote,
        doerPayout,
      }),
    })

    if (!res.ok) {
      const data = await res.json().catch(() => ({}))
      return { success: false, error: data.error || "Failed to submit quote" }
    }

    return { success: true }
  } catch (error) {
    console.error("Submit quote error:", error)
    return { success: false, error: "An unexpected error occurred" }
  }
}
