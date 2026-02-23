"use server"

/**
 * @fileoverview Server actions for project operations.
 * Uses admin client to bypass RLS for fetching unassigned projects and claiming.
 * @module app/actions/projects
 */

import { z } from "zod"
import { createAdminClient } from "@/lib/supabase/admin"
import { createClient } from "@/lib/supabase/server"

/**
 * Fetch NEW/UNASSIGNED projects that need a supervisor.
 * Uses admin client to bypass RLS since supervisors can't see projects
 * where supervisor_id IS NULL through normal RLS policies.
 */
export async function fetchNewRequestsAction() {
  try {
    const supabase = await createClient()
    const { data: { user }, error: authError } = await supabase.auth.getUser()

    if (authError || !user) {
      return { data: [], error: "Not authenticated" }
    }

    // Verify user is a supervisor
    const { data: supervisor, error: supervisorError } = await supabase
      .from("supervisors")
      .select("id")
      .eq("profile_id", user.id)
      .single()

    if (supervisorError || !supervisor) {
      return { data: [], error: "Supervisor profile not found" }
    }

    // Use admin client to bypass RLS and fetch unassigned projects
    const adminClient = createAdminClient()

    const { data, error: queryError } = await adminClient
      .from("projects")
      .select(`
        *,
        profiles!projects_user_id_fkey (*),
        subjects (*),
        doers (
          *,
          profiles!profile_id (*)
        )
      `)
      .is("supervisor_id", null)
      .in("status", ["submitted", "analyzing"])
      .order("created_at", { ascending: false })

    if (queryError) {
      console.error("Fetch new requests error:", queryError)
      return { data: [], error: "Failed to fetch new requests" }
    }

    return { data: data || [], error: null }
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
 * Uses admin client to bypass RLS for updating unassigned projects.
 */
export async function claimProjectAction(params: unknown) {
  const parsed = claimProjectSchema.safeParse(params)
  if (!parsed.success) {
    return { success: false, error: parsed.error.issues[0]?.message || "Invalid input" }
  }

  const { projectId } = parsed.data

  try {
    const supabase = await createClient()
    const { data: { user }, error: authError } = await supabase.auth.getUser()

    if (authError || !user) {
      return { success: false, error: "Not authenticated" }
    }

    // Get supervisor ID
    const { data: supervisor, error: supervisorError } = await supabase
      .from("supervisors")
      .select("id")
      .eq("profile_id", user.id)
      .single()

    if (supervisorError || !supervisor) {
      return { success: false, error: "Supervisor profile not found" }
    }

    const adminClient = createAdminClient()

    // Verify project is still unclaimed
    const { data: project, error: projectCheckError } = await adminClient
      .from("projects")
      .select("id, supervisor_id, status")
      .eq("id", projectId)
      .single()

    if (projectCheckError || !project) {
      return { success: false, error: "Project not found" }
    }

    if (project.supervisor_id !== null) {
      return { success: false, error: "Project already claimed by another supervisor" }
    }

    // Claim the project
    const { error: updateError } = await adminClient
      .from("projects")
      .update({
        supervisor_id: supervisor.id,
        status: "analyzing",
        supervisor_assigned_at: new Date().toISOString(),
        status_updated_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      })
      .eq("id", projectId)
      .is("supervisor_id", null)

    if (updateError) {
      console.error("Claim project error:", updateError)
      return { success: false, error: "Failed to claim project" }
    }

    return { success: true }
  } catch (error) {
    console.error("claimProjectAction error:", error)
    return { success: false, error: "An unexpected error occurred" }
  }
}
