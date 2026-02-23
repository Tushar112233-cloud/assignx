/**
 * @fileoverview API route handler for Supabase auth callback.
 * Handles token_hash (server-side) and PKCE code (client-side) flows.
 * After auth, auto-creates supervisor record from approved email_access_requests metadata.
 * @module app/api/auth/callback/route
 */

import { createClient } from "@/lib/supabase/server"
import { NextResponse } from "next/server"

/**
 * Maps frontend qualification values to DB-compatible values.
 * DB CHECK constraint allows: undergraduate, postgraduate, phd, professional
 */
const QUALIFICATION_MAP: Record<string, string> = {
  high_school: "undergraduate",
  bachelors: "undergraduate",
  masters: "postgraduate",
  phd: "phd",
  postdoc: "phd",
  professional: "professional",
}

function mapQualification(value: string | undefined): string {
  if (!value) return "undergraduate"
  return QUALIFICATION_MAP[value] || "undergraduate"
}

export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url)
  const code = searchParams.get("code")
  const token_hash = searchParams.get("token_hash")
  const type = searchParams.get("type")

  // token_hash flow — can be handled server-side (no PKCE verifier needed)
  if (token_hash && type) {
    const supabase = await createClient()
    const { error, data } = await supabase.auth.verifyOtp({
      token_hash,
      type: type as "email" | "magiclink" | "recovery" | "invite" | "signup",
    })

    if (!error && data?.user) {
      // Auto-create supervisor using the authenticated session
      await autoCreateSupervisor(supabase, data.user)
      return NextResponse.redirect(`${origin}/training`)
    }
  }

  // PKCE code flow — hand off to client page (browser has the code verifier)
  if (code) {
    return NextResponse.redirect(`${origin}/auth/confirm?code=${encodeURIComponent(code)}`)
  }

  return NextResponse.redirect(`${origin}/login?error=auth`)
}

/**
 * If no supervisor record exists, check email_access_requests for an approved
 * request with metadata and create the supervisor record + training progress.
 * Uses the authenticated session client (supervisors & profiles have RLS off).
 */
async function autoCreateSupervisor(supabase: any, user: any) {
  try {
    // Check if supervisor already exists
    const { data: existing } = await supabase
      .from("supervisors")
      .select("id")
      .eq("profile_id", user.id)
      .maybeSingle()

    if (existing) return

    // Check for approved access request with metadata
    const { data: request } = await supabase
      .from("email_access_requests")
      .select("*")
      .eq("email", user.email)
      .eq("role", "supervisor")
      .eq("status", "approved")
      .maybeSingle()

    if (!request || !request.metadata) return

    const meta = request.metadata as Record<string, any>

    // Ensure profile exists (RLS off on profiles)
    const { data: existingProfile } = await supabase
      .from("profiles")
      .select("id")
      .eq("id", user.id)
      .maybeSingle()

    if (!existingProfile) {
      await supabase.from("profiles").insert({
        id: user.id,
        email: user.email,
        full_name: request.full_name || "",
        user_type: "supervisor",
      } as any)
    }

    // Create supervisor record with is_access_granted=true (already admin-approved)
    await supabase.from("supervisors").insert({
      profile_id: user.id,
      qualification: mapQualification(meta.qualification),
      years_of_experience: meta.yearsOfExperience || 0,
      bank_name: meta.bankName || null,
      bank_account_number: meta.accountNumber || null,
      bank_ifsc_code: meta.ifscCode || null,
      upi_id: meta.upiId || null,
      is_access_granted: true,
    } as any)

    // Create training_progress records only for modules without existing records
    const { data: mandatoryMods } = await supabase
      .from("training_modules")
      .select("id")
      .eq("target_role", "supervisor")
      .eq("is_mandatory", true)
      .eq("is_active", true)

    if (mandatoryMods && mandatoryMods.length > 0) {
      const { data: existingProgress } = await supabase
        .from("training_progress")
        .select("module_id")
        .eq("profile_id", user.id)

      const existingModuleIds = new Set(
        (existingProgress || []).map((p: any) => p.module_id)
      )
      const missingModules = mandatoryMods.filter(
        (m: any) => !existingModuleIds.has(m.id)
      )

      if (missingModules.length > 0) {
        await supabase.from("training_progress").insert(
          missingModules.map((m: any) => ({
            profile_id: user.id,
            module_id: m.id,
            status: "not_started",
            progress_percentage: 0,
          }))
        )
      }
    }
  } catch (err) {
    console.error("Auto-create supervisor error:", err)
  }
}
