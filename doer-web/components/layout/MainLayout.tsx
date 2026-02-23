'use client'

import { useState } from 'react'
import { Header } from './Header'
import { Sidebar } from './Sidebar'
import { cn } from '@/lib/utils'
import { useAuth } from '@/hooks/useAuth'

interface MainLayoutProps {
  /** Page content */
  children: React.ReactNode
}

/**
 * Main layout wrapper for authenticated pages
 * Includes header, sidebar, and main content area
 */
export function MainLayout({ children }: MainLayoutProps) {
  const [isSidebarOpen, setIsSidebarOpen] = useState(false)
  const { user, doer } = useAuth()

  const toggleSidebar = () => {
    setIsSidebarOpen(prev => !prev)
  }

  const closeSidebar = () => {
    setIsSidebarOpen(false)
  }

  // Build user data for sidebar from auth state
  const userData = user ? {
    name: user.full_name || 'User',
    email: user.email || '',
    avatar: user.avatar_url || undefined,
    rating: doer?.average_rating || 0,
  } : undefined

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <Header
        onMenuClick={toggleSidebar}
        isSidebarOpen={isSidebarOpen}
      />

      {/* Sidebar */}
      <Sidebar
        isOpen={isSidebarOpen}
        onClose={closeSidebar}
        user={userData}
      />

      {/* Main content */}
      <main
        className={cn(
          'min-h-[calc(100vh-3.5rem)] transition-all duration-200',
          'md:ml-64' // Offset for desktop sidebar
        )}
      >
        <div className="container py-6">
          {children}
        </div>
      </main>
    </div>
  )
}
