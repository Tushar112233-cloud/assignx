"use server"

/**
 * @fileoverview Server actions for quote operations.
 * @module app/actions/quote
 */

import { z } from "zod"
import { createClient } from "@/lib/supabase/server"

const submitQuoteSchema = z.object({
  projectId: z.string().uuid("Invalid project ID"),
  userQuote: z.number().positive("User quote must be positive"),
  doerPayout: z.number().positive("Doer payout must be positive"),
})

interface QuoteResult {
  success: boolean
  error?: string
}

// Commission/fee rates calculated server-side to prevent client manipulation
const SUPERVISOR_COMMISSION_RATE = 0.10 // 10%
const PLATFORM_FEE_RATE = 0.05 // 5%

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

  // Recalculate commission and fees server-side
  const supervisorCommission = Math.round(userQuote * SUPERVISOR_COMMISSION_RATE * 100) / 100
  const platformFee = Math.round(userQuote * PLATFORM_FEE_RATE * 100) / 100

  try {
    const supabase = await createClient()
    const { data: { user }, error: authError } = await supabase.auth.getUser()

    if (authError || !user) {
      return { success: false, error: "Not authenticated" }
    }

    // Get the supervisor ID for this user
    const { data: supervisor, error: supervisorError } = await supabase
      .from("supervisors")
      .select("id")
      .eq("profile_id", user.id)
      .single()

    if (supervisorError || !supervisor) {
      return { success: false, error: "Supervisor profile not found" }
    }

    // Verify the supervisor is assigned to this project
    const { data: project, error: projectCheckError } = await supabase
      .from("projects")
      .select("id, supervisor_id, status, user_id, project_number")
      .eq("id", projectId)
      .single()

    if (projectCheckError || !project) {
      return { success: false, error: "Project not found" }
    }

    if (project.supervisor_id !== supervisor.id) {
      return { success: false, error: "Not authorized to quote this project" }
    }

    // Insert the quote record
    const { error: quoteError } = await supabase.from("project_quotes").insert({
      project_id: projectId,
      user_amount: userQuote,
      doer_amount: doerPayout,
      supervisor_amount: supervisorCommission,
      platform_amount: platformFee,
      quoted_by: supervisor.id,
      status: "pending",
    })

    if (quoteError) {
      return { success: false, error: "Failed to create quote record" }
    }

    // Update the project status and financials
    const { error: updateError } = await supabase
      .from("projects")
      .update({
        status: "quoted",
        user_quote: userQuote,
        doer_payout: doerPayout,
        supervisor_commission: supervisorCommission,
        platform_fee: platformFee,
        status_updated_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      })
      .eq("id", projectId)

    if (updateError) {
      return { success: false, error: "Failed to update project" }
    }

    // Create notification for the project owner (user)
    if (project.user_id) {
      await supabase.from("notifications").insert({
        profile_id: project.user_id,
        notification_type: "quote_ready",
        title: "Quote Ready",
        body: `A quote of ₹${userQuote.toLocaleString("en-IN")} is ready for your project${project.project_number ? ` ${project.project_number}` : ""}. Review and approve to proceed.`,
        reference_type: "project",
        reference_id: projectId,
        action_url: `/project/${projectId}`,
        target_role: "user",
      })
    }

    // Create notification for the supervisor (self-confirmation)
    await supabase.from("notifications").insert({
      profile_id: user.id,
      notification_type: "quote_ready",
      title: "Quote Submitted",
      body: `You submitted a quote of ₹${userQuote.toLocaleString("en-IN")} for project${project.project_number ? ` ${project.project_number}` : ""}.`,
      reference_type: "project",
      reference_id: projectId,
      action_url: `/projects/${projectId}`,
      target_role: "supervisor",
    })

    return { success: true }
  } catch (error) {
    console.error("Submit quote error:", error)
    return { success: false, error: "An unexpected error occurred" }
  }
}
