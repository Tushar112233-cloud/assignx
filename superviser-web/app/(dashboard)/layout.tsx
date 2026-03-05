/**
 * @fileoverview Dashboard layout wrapper with sidebar navigation, header, and user authentication.
 * @module app/(dashboard)/layout
 */

"use client"

import { useEffect, useState } from "react"
import { useRouter } from "next/navigation"
import { SidebarProvider, SidebarInset } from "@/components/ui/sidebar"
import { AppSidebarV2 } from "@/components/layout/app-sidebar-v2"
import { HeaderV2 } from "@/components/layout/header-v2"
import { useAuth } from "@/hooks/use-auth"
import { apiFetch } from "@/lib/api/client"
import { ActivationGuard } from "@/components/auth/activation-guard"

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const router = useRouter()
  const { user, isLoading: authLoading } = useAuth()

  const [pendingQCCount, setPendingQCCount] = useState(0)
  const [notificationCount, setNotificationCount] = useState(0)
  const [supervisorAvailability, setSupervisorAvailability] = useState(true)

  useEffect(() => {
    if (!authLoading && !user) {
      router.push("/login")
    }
  }, [user, authLoading, router])

  useEffect(() => {
    if (!user) return

    async function fetchCounts() {
      try {
        const [supervisorData, notifData] = await Promise.all([
          apiFetch<{ id: string; is_available: boolean }>("/api/supervisors/me").catch(() => null),
          apiFetch<{ unreadCount: number }>("/api/notifications?role=supervisor&limit=0").catch(() => null),
        ])

        if (supervisorData) {
          setSupervisorAvailability(supervisorData.is_available ?? true)
        }
        if (notifData) {
          setNotificationCount(notifData.unreadCount || 0)
        }
      } catch {
        // Stats queries may fail
      }
    }

    fetchCounts()
  }, [user])

  if (authLoading || !user) {
    return null
  }

  const userData = {
    name: user.full_name || user.email?.split("@")[0] || "Supervisor",
    email: user.email || "",
    avatarUrl: user.avatar_url,
  }

  return (
    <SidebarProvider>
      <AppSidebarV2
        user={userData}
        unreadChats={0}
        pendingProjects={pendingQCCount}
      />
      <SidebarInset className="bg-gray-50">
        <HeaderV2
          userName={userData.name}
          notificationCount={notificationCount}
          initialAvailability={supervisorAvailability}
        />
        <main className="flex-1 overflow-auto">
          <ActivationGuard>
            {children}
          </ActivationGuard>
        </main>
      </SidebarInset>
    </SidebarProvider>
  )
}
