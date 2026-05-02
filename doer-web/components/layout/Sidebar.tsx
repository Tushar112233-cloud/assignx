'use client'

import { useState } from 'react'
import { usePathname, useRouter } from 'next/navigation'
import Link from 'next/link'
import {
  LayoutDashboard,
  FolderOpen,
  BookOpen,
  User,
  Star,
  BarChart3,
  HelpCircle,
  Settings,
  LogOut,
  X,
  Loader2,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Separator } from '@/components/ui/separator'
import { Sheet, SheetContent, SheetHeader, SheetTitle } from '@/components/ui/sheet'
import { ScrollArea } from '@/components/ui/scroll-area'
import { AvailabilityToggle } from '@/components/shared/AvailabilityToggle'
import { cn } from '@/lib/utils'
import { ROUTES } from '@/lib/constants'
import { useAuth } from '@/hooks/useAuth'
import { toast } from 'sonner'

/** Navigation menu items */
const menuItems = [
  {
    title: 'Dashboard',
    href: ROUTES.dashboard,
    icon: LayoutDashboard,
  },
  {
    title: 'My Projects',
    href: ROUTES.projects,
    icon: FolderOpen,
  },
  {
    title: 'Resources',
    href: ROUTES.resources,
    icon: BookOpen,
  },
]

const profileItems = [
  {
    title: 'My Profile',
    href: ROUTES.profile,
    icon: User,
  },
  {
    title: 'Reviews',
    href: '/reviews',
    icon: Star,
  },
  {
    title: 'Statistics',
    href: '/statistics',
    icon: BarChart3,
  },
]

const supportItems = [
  {
    title: 'Help & Support',
    href: '/support',
    icon: HelpCircle,
  },
  {
    title: 'Settings',
    href: '/settings',
    icon: Settings,
  },
]

interface SidebarProps {
  /** Whether sidebar is open (mobile) */
  isOpen: boolean
  /** Callback to close sidebar */
  onClose: () => void
  /** User data */
  user?: {
    name: string
    email: string
    avatar?: string
    rating: number
  }
}

/**
 * Sidebar/Drawer component
 * Contains user info, availability toggle, and navigation
 */
export function Sidebar({
  isOpen,
  onClose,
  user,
}: SidebarProps) {
  const pathname = usePathname()
  const router = useRouter()
  const { signOut } = useAuth()
  const [isLoggingOut, setIsLoggingOut] = useState(false)

  const handleLogout = async () => {
    setIsLoggingOut(true)
    try {
      await signOut()
      toast.success('Logged out successfully')
    } catch (error) {
      console.error('Error logging out:', error)
      toast.error('Failed to log out')
      setIsLoggingOut(false)
    }
  }

  const handleAvailabilityChange = (_available: boolean) => {
    // TODO: Update availability in database
  }

  const SidebarContent = () => (
    <div className="flex flex-col h-full">
      {/* User info section */}
      <div className="p-4 space-y-4">
        <div className="flex items-center gap-3">
          <Avatar className="h-12 w-12">
            <AvatarImage src={user?.avatar} alt={user?.name || 'User'} />
            <AvatarFallback>
              {user?.name ? user.name.split(' ').map(n => n[0]).join('') : 'U'}
            </AvatarFallback>
          </Avatar>
          <div className="flex-1 min-w-0">
            <p className="font-medium truncate">{user?.name || 'Loading...'}</p>
            <div className="flex items-center gap-1 text-sm text-muted-foreground">
              <Star className="h-3 w-3 fill-yellow-400 text-yellow-400" />
              <span>{(user?.rating || 0).toFixed(1)}</span>
            </div>
          </div>
        </div>

        {/* Availability toggle */}
        <div className="bg-muted/50 rounded-lg p-3">
          <AvailabilityToggle
            defaultValue={true}
            onChange={handleAvailabilityChange}
          />
        </div>
      </div>

      <Separator />

      {/* Navigation */}
      <ScrollArea className="flex-1 px-2">
        <div className="py-2">
          {/* Main navigation */}
          <div className="space-y-1">
            {menuItems.map((item) => {
              const isActive = pathname === item.href
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  onClick={onClose}
                  className={cn(
                    'flex items-center gap-3 rounded-lg px-3 py-2 text-sm transition-colors',
                    isActive
                      ? 'bg-primary text-primary-foreground'
                      : 'text-muted-foreground hover:bg-muted hover:text-foreground'
                  )}
                >
                  <item.icon className="h-4 w-4" />
                  {item.title}
                </Link>
              )
            })}
          </div>

          <Separator className="my-4" />

          {/* Profile section */}
          <p className="px-3 text-xs font-medium text-muted-foreground mb-2">
            Profile
          </p>
          <div className="space-y-1">
            {profileItems.map((item) => {
              const isActive = pathname === item.href
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  onClick={onClose}
                  className={cn(
                    'flex items-center gap-3 rounded-lg px-3 py-2 text-sm transition-colors',
                    isActive
                      ? 'bg-primary text-primary-foreground'
                      : 'text-muted-foreground hover:bg-muted hover:text-foreground'
                  )}
                >
                  <item.icon className="h-4 w-4" />
                  {item.title}
                </Link>
              )
            })}
          </div>

          <Separator className="my-4" />

          {/* Support section */}
          <p className="px-3 text-xs font-medium text-muted-foreground mb-2">
            Support
          </p>
          <div className="space-y-1">
            {supportItems.map((item) => {
              const isActive = pathname === item.href
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  onClick={onClose}
                  className={cn(
                    'flex items-center gap-3 rounded-lg px-3 py-2 text-sm transition-colors',
                    isActive
                      ? 'bg-primary text-primary-foreground'
                      : 'text-muted-foreground hover:bg-muted hover:text-foreground'
                  )}
                >
                  <item.icon className="h-4 w-4" />
                  {item.title}
                </Link>
              )
            })}
          </div>
        </div>
      </ScrollArea>

      <Separator />

      {/* Logout button */}
      <div className="p-4">
        <Button
          variant="ghost"
          className="w-full justify-start text-muted-foreground hover:text-destructive hover:bg-destructive/10"
          onClick={handleLogout}
          disabled={isLoggingOut}
        >
          {isLoggingOut ? (
            <Loader2 className="h-4 w-4 mr-3 animate-spin" />
          ) : (
            <LogOut className="h-4 w-4 mr-3" />
          )}
          {isLoggingOut ? 'Logging out...' : 'Log Out'}
        </Button>
      </div>
    </div>
  )

  return (
    <>
      {/* Mobile sidebar (Sheet) */}
      <Sheet open={isOpen} onOpenChange={onClose}>
        <SheetContent side="left" className="p-0 w-72">
          <SheetHeader className="sr-only">
            <SheetTitle>Navigation Menu</SheetTitle>
          </SheetHeader>
          <SidebarContent />
        </SheetContent>
      </Sheet>

      {/* Desktop sidebar */}
      <aside className="hidden md:flex fixed left-0 top-14 bottom-0 w-64 border-r bg-background z-40">
        <SidebarContent />
      </aside>
    </>
  )
}
