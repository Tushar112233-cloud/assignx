/**
 * @fileoverview Professional settings page for application preferences and configuration.
 * @module app/(dashboard)/settings/page
 */

"use client"

import { useState, useEffect } from "react"
import {
  Settings,
  Bell,
  Shield,
  Globe,
  Smartphone,
  Mail,
  MessageSquare,
  Clock,
  ChevronRight,
  Eye,
  Lock,
  HelpCircle,
  ExternalLink,
} from "lucide-react"

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Switch } from "@/components/ui/switch"
import { Label } from "@/components/ui/label"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Separator } from "@/components/ui/separator"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import {
  Tabs,
  TabsContent,
  TabsList,
  TabsTrigger,
} from "@/components/ui/tabs"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import {
  AlertDescription,
} from "@/components/ui/alert"
import { toast } from "sonner"
import { cn } from "@/lib/utils"
import { apiFetch } from "@/lib/api/client"
import { getStoredUser } from "@/lib/api/auth"

export default function SettingsPage() {
  const [activeTab, setActiveTab] = useState("notifications")

  // Notification settings state
  const [notifications, setNotifications] = useState({
    emailNewProject: true,
    emailProjectUpdate: true,
    emailPayment: true,
    emailMarketing: false,
    pushNewProject: true,
    pushChat: true,
    pushDeadline: true,
    pushPayment: false,
    sound: true,
    quietHours: false,
    quietStart: "22:00",
    quietEnd: "08:00",
  })

  // Privacy settings state
  const [privacy, setPrivacy] = useState({
    showOnline: true,
    showActivity: true,
    showEarnings: false,
    twoFactor: false,
  })

  // Language & region
  const [language, setLanguage] = useState("en")
  const [timezone, setTimezone] = useState("Asia/Kolkata")

  // Load settings from API on mount
  useEffect(() => {
    const loadSettings = async () => {
      try {
        const user = getStoredUser()
        if (!user) return

        const data = await apiFetch<{ settings?: Record<string, unknown> }>(
          `/api/profiles/${user.id}`
        )

        if (data?.settings) {
          const s = data.settings
          if (s.notifications) setNotifications(prev => ({ ...prev, ...(s.notifications as object) }))
          if (s.privacy) setPrivacy(prev => ({ ...prev, ...(s.privacy as object) }))
          if (s.language) setLanguage(s.language as string)
          if (s.timezone) setTimezone(s.timezone as string)
        }
      } catch {
        // Settings may not exist yet
      }
    }
    loadSettings()
  }, [])

  const saveSettings = async (settingsData: Record<string, unknown>) => {
    try {
      const user = getStoredUser()
      if (!user) return

      await apiFetch(`/api/profiles/${user.id}`, {
        method: "PUT",
        body: JSON.stringify({
          settings: settingsData,
          updated_at: new Date().toISOString(),
        }),
      })
    } catch (err) {
      console.error("Failed to save settings:", err)
      toast.error("Failed to save settings")
    }
  }

  const handleNotificationChange = (key: string, value: boolean) => {
    const updatedNotifications = { ...notifications, [key]: value }
    setNotifications(updatedNotifications)
    saveSettings({ notifications: updatedNotifications, privacy, language, timezone })
    toast.success("Settings updated")
  }

  const handlePrivacyChange = (key: string, value: boolean) => {
    const updatedPrivacy = { ...privacy, [key]: value }
    setPrivacy(updatedPrivacy)
    saveSettings({ notifications, privacy: updatedPrivacy, language, timezone })
    toast.success("Privacy settings updated")
  }

  return (
    <div className="mx-auto w-full max-w-[1200px] space-y-8 px-6 py-8 lg:px-8 animate-fade-in">
      {/* Header */}
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div className="space-y-1">
          <div className="flex items-center gap-3">
            <div className="h-12 w-12 rounded-2xl border border-orange-100 bg-orange-50 flex items-center justify-center">
              <Settings className="h-5 w-5 text-orange-600" />
            </div>
            <div>
              <p className="text-xs font-semibold uppercase tracking-[0.2em] text-gray-400">Account</p>
              <h1 className="text-3xl font-semibold tracking-tight text-[#1C1C1C]">Settings</h1>
              <p className="text-sm text-gray-500">
                Manage your account preferences
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Settings Tabs */}
      <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-6">
        <TabsList className="grid w-full grid-cols-3 lg:w-auto lg:inline-grid p-1 rounded-2xl border border-orange-100 bg-orange-50/60">
          <TabsTrigger
            value="notifications"
            className="gap-2 rounded-xl text-gray-500 data-[state=active]:bg-white data-[state=active]:text-[#1C1C1C] data-[state=active]:shadow-sm"
          >
            <Bell className="h-4 w-4" />
            <span className="hidden sm:inline">Notifications</span>
          </TabsTrigger>
          <TabsTrigger
            value="privacy"
            className="gap-2 rounded-xl text-gray-500 data-[state=active]:bg-white data-[state=active]:text-[#1C1C1C] data-[state=active]:shadow-sm"
          >
            <Shield className="h-4 w-4" />
            <span className="hidden sm:inline">Privacy</span>
          </TabsTrigger>
          <TabsTrigger
            value="language"
            className="gap-2 rounded-xl text-gray-500 data-[state=active]:bg-white data-[state=active]:text-[#1C1C1C] data-[state=active]:shadow-sm"
          >
            <Globe className="h-4 w-4" />
            <span className="hidden sm:inline">Language</span>
          </TabsTrigger>
        </TabsList>

        {/* Notifications Tab */}
        <TabsContent value="notifications" className="space-y-6 animate-fade-in-up">
          {/* Email Notifications */}
          <Card className="rounded-2xl border border-gray-200 bg-white shadow-sm">
            <CardHeader>
              <div className="flex items-center gap-2">
                <Mail className="h-5 w-5 text-orange-600" />
                <div>
                  <CardTitle className="text-lg font-semibold text-[#1C1C1C]">Email Notifications</CardTitle>
                  <CardDescription className="text-sm text-gray-500">Manage what emails you receive</CardDescription>
                </div>
              </div>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center justify-between">
                <div className="space-y-0.5">
                  <Label>New project requests</Label>
                  <p className="text-sm text-gray-500">Get notified when new projects need quotes</p>
                </div>
                <Switch
                  checked={notifications.emailNewProject}
                  onCheckedChange={(v) => handleNotificationChange("emailNewProject", v)}
                />
              </div>
              <Separator />
              <div className="flex items-center justify-between">
                <div className="space-y-0.5">
                  <Label>Project updates</Label>
                  <p className="text-sm text-gray-500">Updates on project status changes</p>
                </div>
                <Switch
                  checked={notifications.emailProjectUpdate}
                  onCheckedChange={(v) => handleNotificationChange("emailProjectUpdate", v)}
                />
              </div>
              <Separator />
              <div className="flex items-center justify-between">
                <div className="space-y-0.5">
                  <Label>Payment notifications</Label>
                  <p className="text-sm text-gray-500">Get notified about payments and withdrawals</p>
                </div>
                <Switch
                  checked={notifications.emailPayment}
                  onCheckedChange={(v) => handleNotificationChange("emailPayment", v)}
                />
              </div>
              <Separator />
              <div className="flex items-center justify-between">
                <div className="space-y-0.5">
                  <Label>Marketing emails</Label>
                  <p className="text-sm text-gray-500">Tips, product updates and offers</p>
                </div>
                <Switch
                  checked={notifications.emailMarketing}
                  onCheckedChange={(v) => handleNotificationChange("emailMarketing", v)}
                />
              </div>
            </CardContent>
          </Card>

          {/* Push Notifications */}
          <Card className="rounded-2xl border border-gray-200 bg-white shadow-sm">
            <CardHeader>
              <div className="flex items-center gap-2">
                <Smartphone className="h-5 w-5 text-orange-600" />
                <div>
                  <CardTitle className="text-lg font-semibold text-[#1C1C1C]">Push Notifications</CardTitle>
                  <CardDescription className="text-sm text-gray-500">In-app and browser notifications</CardDescription>
                </div>
              </div>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center justify-between">
                <div className="space-y-0.5">
                  <Label>New projects</Label>
                  <p className="text-sm text-gray-500">Instant alerts for new project requests</p>
                </div>
                <Switch
                  checked={notifications.pushNewProject}
                  onCheckedChange={(v) => handleNotificationChange("pushNewProject", v)}
                />
              </div>
              <Separator />
              <div className="flex items-center justify-between">
                <div className="space-y-0.5">
                  <Label>Chat messages</Label>
                  <p className="text-sm text-gray-500">New messages from clients and experts</p>
                </div>
                <Switch
                  checked={notifications.pushChat}
                  onCheckedChange={(v) => handleNotificationChange("pushChat", v)}
                />
              </div>
              <Separator />
              <div className="flex items-center justify-between">
                <div className="space-y-0.5">
                  <Label>Deadline reminders</Label>
                  <p className="text-sm text-gray-500">Reminders before project deadlines</p>
                </div>
                <Switch
                  checked={notifications.pushDeadline}
                  onCheckedChange={(v) => handleNotificationChange("pushDeadline", v)}
                />
              </div>
              <Separator />
              <div className="flex items-center justify-between">
                <div className="space-y-0.5">
                  <Label>Notification sound</Label>
                  <p className="text-sm text-gray-500">Play sound for notifications</p>
                </div>
                <Switch
                  checked={notifications.sound}
                  onCheckedChange={(v) => handleNotificationChange("sound", v)}
                />
              </div>
            </CardContent>
          </Card>

          {/* Quiet Hours */}
          <Card className="rounded-2xl border border-gray-200 bg-white shadow-sm">
            <CardHeader>
              <div className="flex items-center gap-2">
                <Clock className="h-5 w-5 text-orange-600" />
                <div>
                  <CardTitle className="text-lg font-semibold text-[#1C1C1C]">Quiet Hours</CardTitle>
                  <CardDescription className="text-sm text-gray-500">Pause notifications during specific hours</CardDescription>
                </div>
              </div>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center justify-between">
                <div className="space-y-0.5">
                  <Label>Enable quiet hours</Label>
                  <p className="text-sm text-gray-500">Mute notifications during set times</p>
                </div>
                <Switch
                  checked={notifications.quietHours}
                  onCheckedChange={(v) => handleNotificationChange("quietHours", v)}
                />
              </div>
              {notifications.quietHours && (
                <div className="flex items-center gap-4 pt-2">
                  <div className="flex-1">
                    <Label className="text-xs text-gray-500">From</Label>
                    <Input
                      type="time"
                      value={notifications.quietStart}
                      onChange={(e) => setNotifications((p) => ({ ...p, quietStart: e.target.value }))}
                    />
                  </div>
                  <div className="flex-1">
                    <Label className="text-xs text-gray-500">To</Label>
                    <Input
                      type="time"
                      value={notifications.quietEnd}
                      onChange={(e) => setNotifications((p) => ({ ...p, quietEnd: e.target.value }))}
                    />
                  </div>
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        {/* Privacy Tab */}
        <TabsContent value="privacy" className="space-y-6 animate-fade-in-up">
          <Card className="rounded-2xl border border-gray-200 bg-white shadow-sm">
            <CardHeader>
              <div className="flex items-center gap-2">
                <Eye className="h-5 w-5 text-orange-600" />
                <div>
                  <CardTitle className="text-lg font-semibold text-[#1C1C1C]">Profile Visibility</CardTitle>
                  <CardDescription className="text-sm text-gray-500">Control what others can see</CardDescription>
                </div>
              </div>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center justify-between">
                <div className="space-y-0.5">
                  <Label>Show online status</Label>
                  <p className="text-sm text-gray-500">Let others see when you&apos;re online</p>
                </div>
                <Switch
                  checked={privacy.showOnline}
                  onCheckedChange={(v) => handlePrivacyChange("showOnline", v)}
                />
              </div>
              <Separator />
              <div className="flex items-center justify-between">
                <div className="space-y-0.5">
                  <Label>Show activity status</Label>
                  <p className="text-sm text-gray-500">Show your recent activity to doers</p>
                </div>
                <Switch
                  checked={privacy.showActivity}
                  onCheckedChange={(v) => handlePrivacyChange("showActivity", v)}
                />
              </div>
              <Separator />
              <div className="flex items-center justify-between">
                <div className="space-y-0.5">
                  <Label>Show earnings badge</Label>
                  <p className="text-sm text-gray-500">Display your earnings tier on profile</p>
                </div>
                <Switch
                  checked={privacy.showEarnings}
                  onCheckedChange={(v) => handlePrivacyChange("showEarnings", v)}
                />
              </div>
            </CardContent>
          </Card>

          <Card className="rounded-2xl border border-gray-200 bg-white shadow-sm">
            <CardHeader>
              <div className="flex items-center gap-2">
                <Lock className="h-5 w-5 text-orange-600" />
                <div>
                  <CardTitle className="text-lg font-semibold text-[#1C1C1C]">Security</CardTitle>
                  <CardDescription className="text-sm text-gray-500">Protect your account</CardDescription>
                </div>
              </div>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center justify-between">
                <div className="space-y-0.5">
                  <div className="flex items-center gap-2">
                    <Label>Two-factor authentication</Label>
                    <Badge variant="secondary" className="text-xs border border-orange-100 bg-orange-50 text-orange-700">
                      Recommended
                    </Badge>
                  </div>
                  <p className="text-sm text-gray-500">Add an extra layer of security</p>
                </div>
                <Switch
                  checked={privacy.twoFactor}
                  onCheckedChange={(v) => {
                    // TODO: Integrate with Supabase MFA enrollment API
                    toast.info("Two-factor authentication setup is not yet available. Coming soon.")
                  }}
                />
              </div>
              <Separator />
              <div className="flex items-center justify-between">
                <div className="space-y-0.5">
                  <Label>Active sessions</Label>
                  <p className="text-sm text-gray-500">Manage your logged in devices</p>
                </div>
                <Button
                  variant="outline"
                  size="sm"
                  className="gap-1"
                  onClick={() => {
                    // TODO: Implement session management UI
                    toast.info("Session management is not yet available.")
                  }}
                >
                  Manage
                  <ChevronRight className="h-4 w-4" />
                </Button>
              </div>
            </CardContent>
          </Card>

          <Card className="rounded-2xl border border-rose-200 bg-white shadow-sm">
            <CardHeader>
              <CardTitle className="text-lg font-semibold text-rose-600">Danger Zone</CardTitle>
              <CardDescription className="text-sm text-gray-500">Irreversible and destructive actions</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center justify-between">
                <div className="space-y-0.5">
                  <Label>Delete account</Label>
                  <p className="text-sm text-gray-500">Permanently delete your account and all data</p>
                </div>
                <Button
                  variant="destructive"
                  size="sm"
                  onClick={() => {
                    // TODO: Implement account deletion flow with confirmation dialog and Supabase admin API
                    toast.info("To delete your account, please contact support at support@assignx.com")
                  }}
                >
                  Delete Account
                </Button>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Language Tab */}
        <TabsContent value="language" className="space-y-6 animate-fade-in-up">
          <Card className="rounded-2xl border border-gray-200 bg-white shadow-sm">
            <CardHeader>
              <CardTitle className="text-lg font-semibold text-[#1C1C1C]">Language & Region</CardTitle>
              <CardDescription className="text-sm text-gray-500">Set your preferred language and timezone</CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="space-y-2">
                <Label>Display language</Label>
                <Select value={language} onValueChange={setLanguage}>
                  <SelectTrigger className="w-full">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="en">English</SelectItem>
                    <SelectItem value="hi">Hindi (हिंदी)</SelectItem>
                    <SelectItem value="ta">Tamil (தமிழ்)</SelectItem>
                    <SelectItem value="te">Telugu (తెలుగు)</SelectItem>
                    <SelectItem value="kn">Kannada (ಕನ್ನಡ)</SelectItem>
                    <SelectItem value="ml">Malayalam (മലയാളം)</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label>Timezone</Label>
                <Select value={timezone} onValueChange={setTimezone}>
                  <SelectTrigger className="w-full">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="Asia/Kolkata">India Standard Time (IST)</SelectItem>
                    <SelectItem value="Asia/Dubai">Gulf Standard Time (GST)</SelectItem>
                    <SelectItem value="America/New_York">Eastern Time (ET)</SelectItem>
                    <SelectItem value="America/Los_Angeles">Pacific Time (PT)</SelectItem>
                    <SelectItem value="Europe/London">Greenwich Mean Time (GMT)</SelectItem>
                  </SelectContent>
                </Select>
                <p className="text-sm text-gray-500">
                  Current time: {new Date().toLocaleTimeString("en-IN", { timeZone: timezone })}
                </p>
              </div>
            </CardContent>
          </Card>

          <Card className="rounded-2xl border border-gray-200 bg-white shadow-sm">
            <CardHeader>
              <CardTitle className="text-lg font-semibold text-[#1C1C1C]">Help & Support</CardTitle>
              <CardDescription className="text-sm text-gray-500">Get help when you need it</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <Button variant="outline" className="w-full justify-between" asChild>
                <a href="/support">
                  <div className="flex items-center gap-2">
                    <HelpCircle className="h-4 w-4" />
                    Help Center
                  </div>
                  <ChevronRight className="h-4 w-4" />
                </a>
              </Button>
              <Button variant="outline" className="w-full justify-between" asChild>
                <a href="/support">
                  <div className="flex items-center gap-2">
                    <MessageSquare className="h-4 w-4" />
                    Contact Support
                  </div>
                  <ChevronRight className="h-4 w-4" />
                </a>
              </Button>
              <Button variant="outline" className="w-full justify-between" asChild>
                <a href="/resources">
                  <div className="flex items-center gap-2">
                    <ExternalLink className="h-4 w-4" />
                    Documentation
                  </div>
                  <ChevronRight className="h-4 w-4" />
                </a>
              </Button>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  )
}
