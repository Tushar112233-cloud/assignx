'use client'

import { useMemo } from 'react'
import { AppSidebar } from '@/components/app-sidebar'
import { SidebarInset, SidebarProvider, SidebarTrigger } from '@/components/ui/sidebar'

type UserData = {
  name: string
  email: string
  avatar: string
}

type MainShellProps = {
  children: React.ReactNode
  userData: UserData
  stats?: {
    activeProjects?: number
    pendingEarnings?: number
  }
}

/**
 * Main shell layout that conditionally renders the app sidebar.
 */
export function MainShell({ children, userData, stats }: MainShellProps) {
  const layoutId = useMemo(() => 'main-shell', [])
  return (
    <SidebarProvider data-layout={layoutId}>
      <AppSidebar userData={userData} stats={stats} />
      <SidebarInset className="bg-[#F8FAFC]">
        <div className="flex items-center gap-3 border-b border-border/70 bg-background/80 px-6 py-4 md:hidden">
          <SidebarTrigger />
          <span className="text-sm font-semibold text-foreground">Menu</span>
        </div>
        <div className="min-h-screen px-6 py-6 lg:px-10">
          {children}
        </div>
      </SidebarInset>
    </SidebarProvider>
  )
}
