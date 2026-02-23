/**
 * @fileoverview Premium Dashboard Layout V2 - Command Center wrapper.
 * Dark, editorial design with premium sidebar and header.
 * @module app/(dashboard)/layout-v2
 */

import { redirect } from "next/navigation"
import { createClient } from "@/lib/supabase/server"
import { SidebarProvider, SidebarInset } from "@/components/ui/sidebar"
import { AppSidebarV2 } from "@/components/layout/app-sidebar-v2"
import { HeaderV2 } from "@/components/layout/header-v2"
import { AuthSessionSync } from "@/components/providers/auth-session-sync"

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
  const supabase = await createClient()

  const { data: { user } } = await supabase.auth.getUser()
  const { data: { session } } = await supabase.auth.getSession()

  if (!user) {
    redirect("/login")
  }

  // Get user profile
  let profile: UserProfile | null = null
  try {
    const { data } = await supabase
      .from("profiles")
      .select("full_name, email, avatar_url")
      .eq("id", user.id)
      .single()
    profile = data as UserProfile | null
  } catch {
    // Profile table may not exist yet
  }

  const userData = {
    name: profile?.full_name || user.user_metadata?.full_name || "Supervisor",
    email: profile?.email || user.email || "",
    avatarUrl: profile?.avatar_url,
  }

  // Fetch stats
  let notificationCount = 0
  let pendingProjects = 0
  let unreadChats = 0

  try {
    const { data: supervisor } = await supabase
      .from("supervisors")
      .select("id")
      .eq("profile_id", user.id)
      .single()

    if (supervisor) {
      const [notificationsResult, pendingResult, chatsResult] = await Promise.all([
        supabase
          .from("notifications")
          .select("id", { count: "exact", head: true })
          .eq("user_id", user.id)
          .eq("target_role", "supervisor")
          .eq("read", false),
        supabase
          .from("projects")
          .select("id", { count: "exact", head: true })
          .eq("supervisor_id", supervisor.id)
          .eq("status", "submitted_for_qc"),
        // Mock unread chats count - replace with actual query
        Promise.resolve({ count: 0 }),
      ])

      notificationCount = notificationsResult.count || 0
      pendingProjects = pendingResult.count || 0
      unreadChats = chatsResult.count || 0
    }
  } catch {
    // Stats queries may fail
  }

  return (
    <SidebarProvider>
      <AuthSessionSync
        accessToken={session?.access_token ?? null}
        refreshToken={session?.refresh_token ?? null}
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
