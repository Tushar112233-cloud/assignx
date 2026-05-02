/**
 * @fileoverview Activation flow layout with authentication and status verification for approved supervisors.
 * @module app/(activation)/layout
 */

import { redirect } from "next/navigation"
import { cookies } from "next/headers"

const API_BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000"

export default async function ActivationLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const cookieStore = await cookies()
  const token = cookieStore.get("supervisor_token")?.value

  if (!token) {
    redirect("/login")
  }

  // Validate token and check supervisor status
  try {
    const authRes = await fetch(`${API_BASE}/api/auth/me`, {
      headers: { Authorization: `Bearer ${token}` },
    })

    if (!authRes.ok) {
      redirect("/login")
    }

    // Check supervisor status
    const supervisorRes = await fetch(`${API_BASE}/api/supervisors/me`, {
      headers: { Authorization: `Bearer ${token}` },
    })

    if (!supervisorRes.ok) {
      // Supervisor not approved yet
      redirect("/training")
    }

    const supervisor = await supervisorRes.json()

    if (!supervisor || supervisor.status !== "active") {
      redirect("/training")
    }

    // Check activation status
    const activationRes = await fetch(`${API_BASE}/api/supervisors/me/activation`, {
      headers: { Authorization: `Bearer ${token}` },
    })

    if (activationRes.ok) {
      const activation = await activationRes.json()
      if (activation?.is_activated) {
        redirect("/dashboard")
      }
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
