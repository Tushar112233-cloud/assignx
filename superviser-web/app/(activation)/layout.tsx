/**
 * @fileoverview Activation flow layout with authentication and status verification for approved supervisors.
 * @module app/(activation)/layout
 */

import { redirect } from "next/navigation"
import { createClient } from "@/lib/supabase/server"

interface SupervisorStatus {
  id: string
  status: "pending" | "in_review" | "active" | "rejected" | "suspended" | null
}

interface ActivationStatus {
  training_completed: boolean
  quiz_passed: boolean
  is_activated: boolean
}

export default async function ActivationLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const supabase = await createClient()

  const { data: { user } } = await supabase.auth.getUser()

  if (!user) {
    redirect("/login")
  }

  // Check supervisor status
  try {
    const { data: supervisorData } = await supabase
      .from("supervisors")
      .select("id, status")
      .eq("profile_id", user.id)
      .single()

    const supervisor = supervisorData as SupervisorStatus | null

    if (!supervisor || supervisor.status !== "active") {
      // Supervisor not approved yet
      redirect("/training")
    }

    // Check activation status - use the supervisor's id, not user.id
    const { data } = await supabase
      .from("supervisor_activation")
      .select("training_completed, quiz_passed, is_activated")
      .eq("supervisor_id", supervisor.id)
      .single()

    const activation = data as ActivationStatus | null

    if (activation?.is_activated) {
      // Already activated, go to dashboard
      redirect("/dashboard")
    }
  } catch {
    // No activation record yet, continue to activation flow
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary/5 via-background to-secondary/5">
      {children}
    </div>
  )
}
