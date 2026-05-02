'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import { User, Bell, Shield, LogOut, Trash2, Loader2 } from 'lucide-react'
import {
  SettingsHero,
  AccountSettings,
  NotificationSettings,
  PrivacySettings,
} from '@/components/settings'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Button } from '@/components/ui/button'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  DialogClose,
} from '@/components/ui/dialog'
import { useAuth } from '@/hooks/useAuth'
import { toast } from 'sonner'

type SettingsClientProps = {
  userEmail: string
  profile: any
  doer: any
}

type SettingsTab = 'account' | 'notifications' | 'privacy'

/**
 * Settings client component
 * Comprehensive settings page with account, notifications, privacy, and display preferences
 */
export function SettingsClient({ userEmail, profile, doer }: SettingsClientProps) {
  const [activeTab, setActiveTab] = useState<SettingsTab>('account')
  const [isSigningOut, setIsSigningOut] = useState(false)
  const { signOut } = useAuth()
  const userId = profile?.id || ''

  /**
   * Handle sign out - calls API logout and redirects to login
   */
  const handleSignOut = async () => {
    setIsSigningOut(true)
    try {
      await signOut()
    } catch {
      toast.error('Failed to sign out. Please try again.')
      setIsSigningOut(false)
    }
  }

  return (
    <div className="relative min-h-screen">
      {/* Background gradient overlay - matches dashboard */}
      <div className="pointer-events-none absolute inset-0 -z-10 bg-[radial-gradient(circle_at_top,rgba(90,124,255,0.18),transparent_55%),radial-gradient(circle_at_80%_20%,rgba(73,197,255,0.16),transparent_50%)]" />

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        className="space-y-6"
      >
        {/* Hero Section */}
        <SettingsHero
          userName={profile?.full_name || doer?.full_name || 'User'}
          userEmail={userEmail}
        />

        {/* Tabs Navigation -- explicit id prevents Radix useId() hydration mismatch
            where server-generated aria-controls IDs differ from client-generated ones */}
        <Tabs id="settings-tabs" value={activeTab} onValueChange={(value) => setActiveTab(value as SettingsTab)}>
          <TabsList className="grid w-full grid-cols-3 h-12 rounded-full bg-white/85 p-1 shadow-[0_14px_28px_rgba(30,58,138,0.08)]">
            <TabsTrigger
              value="account"
              className="rounded-full text-sm data-[state=active]:bg-gradient-to-r data-[state=active]:from-[#5A7CFF] data-[state=active]:to-[#49C5FF] data-[state=active]:text-white transition-all"
            >
              <User className="mr-2 h-4 w-4" />
              Account
            </TabsTrigger>
            <TabsTrigger
              value="notifications"
              className="rounded-full text-sm data-[state=active]:bg-gradient-to-r data-[state=active]:from-[#5A7CFF] data-[state=active]:to-[#49C5FF] data-[state=active]:text-white transition-all"
            >
              <Bell className="mr-2 h-4 w-4" />
              Notifications
            </TabsTrigger>
            <TabsTrigger
              value="privacy"
              className="rounded-full text-sm data-[state=active]:bg-gradient-to-r data-[state=active]:from-[#5A7CFF] data-[state=active]:to-[#49C5FF] data-[state=active]:text-white transition-all"
            >
              <Shield className="mr-2 h-4 w-4" />
              Privacy
            </TabsTrigger>
          </TabsList>

          <div className="mt-5">
            <motion.main
              key={activeTab}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.3 }}
              className="min-w-0"
            >
              <TabsContent value="account" className="mt-0">
                <AccountSettings profile={profile} userId={userId} />
              </TabsContent>

              <TabsContent value="notifications" className="mt-0">
                <NotificationSettings userId={userId} />
              </TabsContent>

              <TabsContent value="privacy" className="mt-0">
                <PrivacySettings userId={userId} />
              </TabsContent>

            </motion.main>
          </div>
        </Tabs>

        {/* Account Actions */}
        <div className="mt-8 rounded-[24px] border border-white/70 bg-white/85 p-6 shadow-[0_18px_40px_rgba(30,58,138,0.08)]">
          <h3 className="text-base font-semibold text-slate-900 mb-4">Account</h3>
          <div className="flex flex-wrap gap-3">
            <Button
              variant="outline"
              onClick={handleSignOut}
              disabled={isSigningOut}
              className="justify-start gap-3 h-11 rounded-2xl border-slate-200/80 bg-white text-slate-700 hover:bg-slate-50"
            >
              {isSigningOut ? (
                <Loader2 className="h-5 w-5 animate-spin text-slate-600" />
              ) : (
                <LogOut className="h-5 w-5 text-slate-600" />
              )}
              <span>{isSigningOut ? 'Signing out...' : 'Sign Out'}</span>
            </Button>

            <Dialog>
              <DialogTrigger asChild>
                <Button
                  variant="outline"
                  className="justify-start gap-3 h-11 rounded-2xl border-red-200/80 bg-white text-red-600 hover:bg-red-50"
                >
                  <Trash2 className="h-5 w-5" />
                  <span>Delete Account</span>
                </Button>
              </DialogTrigger>
              <DialogContent className="rounded-2xl sm:max-w-md">
                <DialogHeader>
                  <DialogTitle>Delete Account</DialogTitle>
                  <DialogDescription>
                    Account deletion requires admin review. Please contact support at{' '}
                    <a href="mailto:support@assignx.com" className="font-semibold text-[#5A7CFF] hover:underline">
                      support@assignx.com
                    </a>{' '}
                    to request account deletion. This ensures all pending payouts and projects are properly handled.
                  </DialogDescription>
                </DialogHeader>
                <DialogFooter className="gap-2 sm:gap-0">
                  <DialogClose asChild>
                    <Button variant="outline" className="rounded-xl">
                      Close
                    </Button>
                  </DialogClose>
                  <Button
                    onClick={() => {
                      window.location.href = 'mailto:support@assignx.com?subject=Account%20Deletion%20Request'
                    }}
                    className="rounded-xl bg-red-600 hover:bg-red-700 text-white"
                  >
                    Contact Support
                  </Button>
                </DialogFooter>
              </DialogContent>
            </Dialog>
          </div>
        </div>
      </motion.div>
    </div>
  )
}
