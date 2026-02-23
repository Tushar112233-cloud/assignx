"use server"

import { createClient } from "@/lib/supabase/server"

/**
 * Flag types for chat policy violations
 */
export type FlagReason = "phone_sharing" | "address_sharing" | "link_sharing" | "email_sharing"

/**
 * Result of flagging operation
 */
export interface FlagUserResult {
  success: boolean
  error?: string
  flagCount?: number
}

/**
 * Flag a user for violating chat policies
 * This server action updates the user's profile to mark them as flagged
 *
 * @param userId - The UUID of the user to flag
 * @param reason - The reason for flagging
 * @returns Result indicating success or failure
 */
export async function flagUserForViolation(
  userId: string,
  reason: FlagReason
): Promise<FlagUserResult> {
  try {
    const supabase = await createClient()

    // First get current flag count
    const { data: profile, error: fetchError } = await supabase
      .from("profiles")
      .select("flag_count, is_flagged")
      .eq("id", userId)
      .single()

    if (fetchError) {
      console.error("Error fetching profile for flagging:", fetchError)
      return { success: false, error: "Failed to fetch user profile" }
    }

    const currentFlagCount = profile?.flag_count || 0
    const newFlagCount = currentFlagCount + 1

    // Update the profile with flag information
    const { error: updateError } = await supabase
      .from("profiles")
      .update({
        is_flagged: true,
        flag_reason: reason,
        flagged_at: new Date().toISOString(),
        flag_count: newFlagCount,
      })
      .eq("id", userId)

    if (updateError) {
      console.error("Error flagging user:", updateError)
      return { success: false, error: "Failed to flag user" }
    }

    // If user has been flagged multiple times, block them
    if (newFlagCount >= 3) {
      await supabase
        .from("profiles")
        .update({
          is_blocked: true,
          block_reason: `Automatically blocked after ${newFlagCount} chat policy violations`,
        })
        .eq("id", userId)
    }

    return { success: true, flagCount: newFlagCount }
  } catch (error) {
    console.error("Unexpected error flagging user:", error)
    return { success: false, error: "An unexpected error occurred" }
  }
}

/**
 * Check if a user is flagged
 * @param userId - The UUID of the user to check
 * @returns Whether the user is flagged
 */
export async function isUserFlagged(userId: string): Promise<boolean> {
  try {
    const supabase = await createClient()

    const { data, error } = await supabase
      .from("profiles")
      .select("is_flagged, is_blocked")
      .eq("id", userId)
      .single()

    if (error) {
      console.error("Error checking user flag status:", error)
      return false
    }

    return data?.is_flagged || data?.is_blocked || false
  } catch {
    return false
  }
}
