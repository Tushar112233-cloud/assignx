/**
 * @fileoverview Server API route to auto-create supervisor record from approved
 * email_access_requests metadata. Called after auth when no supervisor record exists.
 * @module app/api/auth/setup-supervisor/route
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

export async function POST() {
  try {
    const supabase = await createClient()
    const {
      data: { user },
    } = await supabase.auth.getUser()

    if (!user || !user.email) {
      return NextResponse.json({ error: "Not authenticated" }, { status: 401 })
    }

    // Check if supervisor record already exists (RLS is off on supervisors)
    const { data: existing } = await supabase
      .from("supervisors")
      .select("id")
      .eq("profile_id", user.id)
      .maybeSingle()

    if (existing) {
      return NextResponse.json({ status: "already_exists" })
    }

    // Check for approved access request with metadata
    const { data: request } = await (supabase as any)
      .from("email_access_requests")
      .select("*")
      .eq("email", user.email)
      .eq("role", "supervisor")
      .eq("status", "approved")
      .maybeSingle()

    if (!request || !request.metadata) {
      return NextResponse.json(
        { error: "No approved access request found" },
        { status: 404 }
      )
    }

    const meta = request.metadata as Record<string, any>

    // Ensure profile exists (RLS is off on profiles)
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

    // Create supervisor record from metadata (RLS is off on supervisors)
    const { error: supError } = await supabase.from("supervisors").insert({
      profile_id: user.id,
      qualification: mapQualification(meta.qualification),
      years_of_experience: meta.yearsOfExperience || 0,
      bank_name: meta.bankName || null,
      bank_account_number: meta.accountNumber || null,
      bank_ifsc_code: meta.ifscCode || null,
      upi_id: meta.upiId || null,
      is_access_granted: true,
    } as any)

    if (supError) {
      console.error("Failed to create supervisor:", supError)
      return NextResponse.json(
        { error: "Failed to create supervisor record", details: supError.message },
        { status: 500 }
      )
    }

    // Create training_progress records only for modules that don't have records yet
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

    return NextResponse.json({ status: "created" })
  } catch (err) {
    console.error("Setup supervisor error:", err)
    return NextResponse.json(
      { error: "Internal server error", details: String(err) },
      { status: 500 }
    )
  }
}
