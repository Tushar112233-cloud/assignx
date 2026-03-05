/**
 * @fileoverview Premium Dashboard Layout V2 - Command Center wrapper.
 * Dark, editorial design with premium sidebar and header.
 * @module app/(dashboard)/layout-v2
 */

import { redirect } from "next/navigation"
import { cookies } from "next/headers"
import { SidebarProvider, SidebarInset } from "@/components/ui/sidebar"
import { AppSidebarV2 } from "@/components/layout/app-sidebar-v2"
import { HeaderV2 } from "@/components/layout/header-v2"
import { AuthSessionSync } from "@/components/providers/auth-session-sync"

const API_BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000"

interface UserProfile {
  full_name: string | null
  email: string | null
  avatar_url: string | null
}

export default async function DashboardLayoutV2({
  children,
}: {
  children: React.ReactNode
}) {
  const cookieStore = await cookies()
  const token = cookieStore.get("supervisor_token")?.value

  if (!token) {
    redirect("/login")
  }

  // Validate token and get user info
  let user: any = null
  try {
    const authRes = await fetch(`${API_BASE}/api/auth/me`, {
      headers: { Authorization: `Bearer ${token}` },
    })

    if (!authRes.ok) {
      redirect("/login")
    }

    const authData = await authRes.json()
    user = authData.user
  } catch {
    redirect("/login")
  }

  if (!user) {
    redirect("/login")
  }

  // Get supervisor data (now includes auth fields)
  let supervisorProfile: any = null
  try {
    const supervisorRes = await fetch(`${API_BASE}/api/supervisors/me`, {
      headers: { Authorization: `Bearer ${token}` },
    })
    if (supervisorRes.ok) {
      supervisorProfile = await supervisorRes.json()
    }
  } catch {
    // Supervisor fetch may fail
  }

  const userData = {
    name: supervisorProfile?.full_name || user.full_name || user.user_metadata?.full_name || "Supervisor",
    email: supervisorProfile?.email || user.email || "",
    avatarUrl: supervisorProfile?.avatar_url || null,
  }

  // Fetch notification stats
  let notificationCount = 0
  let pendingProjects = 0
  let unreadChats = 0

  try {
    if (supervisorProfile?.id) {
      const [notificationsRes, pendingRes] = await Promise.all([
        fetch(
          `${API_BASE}/api/notifications?recipientId=${supervisorProfile.id}&recipientRole=supervisor&read=false&countOnly=true`,
          { headers: { Authorization: `Bearer ${token}` } }
        ).catch(() => null),
        fetch(
          `${API_BASE}/api/projects?supervisorId=${supervisorProfile.id}&status=submitted_for_qc&countOnly=true`,
          { headers: { Authorization: `Bearer ${token}` } }
        ).catch(() => null),
      ])

      if (notificationsRes?.ok) {
        const notifData = await notificationsRes.json()
        notificationCount = notifData.count || 0
      }
      if (pendingRes?.ok) {
        const pendingData = await pendingRes.json()
        pendingProjects = pendingData.count || 0
      }
    }
  } catch {
    // Stats queries may fail
  }

  return (
    <SidebarProvider>
      <AuthSessionSync
        accessToken={token}
        refreshToken={null}
      />
      <AppSidebarV2
        user={userData}
        unreadChats={unreadChats}
        pendingProjects={pendingProjects}
      />
      <SidebarInset className="bg-[#0F0F0F]">
        <HeaderV2
          userName={userData.name}
          notificationCount={notificationCount}
        />
        <main className="flex-1 overflow-auto">
          {children}
        </main>
      </SidebarInset>
    </SidebarProvider>
  )
}
