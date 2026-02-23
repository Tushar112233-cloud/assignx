/**
 * @fileoverview Push notification setup component
 * Handles permission requests and subscription management
 */

"use client"

import { useState, useEffect } from "react"
import { Bell, BellOff, AlertCircle, CheckCircle2 } from "lucide-react"

import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { toast } from "sonner"
import {
  isPushSupported,
  getPermissionStatus,
  subscribeToPush,
  unsubscribeFromPush,
  savePushSubscription,
  removePushSubscription,
  getPushSubscription,
  showTestNotification,
} from "@/lib/notifications/push"
import { VAPID_PUBLIC_KEY, areVapidKeysConfigured, getVapidSetupInstructions } from "@/lib/notifications/vapid"

export function PushNotificationSetup() {
  const [isSupported, setIsSupported] = useState(false)
  const [permission, setPermission] = useState<NotificationPermission>("default")
  const [isSubscribed, setIsSubscribed] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const [vapidConfigured, setVapidConfigured] = useState(false)

  useEffect(() => {
    // Check if push notifications are supported
    setIsSupported(isPushSupported())
    setPermission(getPermissionStatus())
    setVapidConfigured(areVapidKeysConfigured())

    // Check current subscription status
    checkSubscriptionStatus()
  }, [])

  const checkSubscriptionStatus = async () => {
    try {
      const subscription = await getPushSubscription()
      setIsSubscribed(!!subscription)
    } catch (error) {
      console.error("Failed to check subscription status:", error)
    }
  }

  const handleEnableNotifications = async () => {
    if (!isSupported) {
      toast.error("Push notifications are not supported in your browser")
      return
    }

    if (!vapidConfigured) {
      toast.error("Push notifications are not configured. Please contact support.")
      console.error(getVapidSetupInstructions())
      return
    }

    setIsLoading(true)

    try {
      // Subscribe to push notifications
      const subscriptionData = await subscribeToPush(VAPID_PUBLIC_KEY)

      // Save subscription to database
      await savePushSubscription(subscriptionData)

      setPermission("granted")
      setIsSubscribed(true)
      toast.success("Push notifications enabled successfully!")
    } catch (error) {
      console.error("Failed to enable notifications:", error)
      if (error instanceof Error) {
        toast.error(`Failed to enable notifications: ${error.message}`)
      } else {
        toast.error("Failed to enable notifications. Please try again.")
      }
    } finally {
      setIsLoading(false)
    }
  }

  const handleDisableNotifications = async () => {
    setIsLoading(true)

    try {
      // Unsubscribe from push notifications
      await unsubscribeFromPush()

      // Remove subscription from database
      await removePushSubscription()

      setIsSubscribed(false)
      toast.success("Push notifications disabled")
    } catch (error) {
      console.error("Failed to disable notifications:", error)
      toast.error("Failed to disable notifications. Please try again.")
    } finally {
      setIsLoading(false)
    }
  }

  const handleTestNotification = async () => {
    setIsLoading(true)

    try {
      await showTestNotification()
      toast.success("Test notification sent!")
    } catch (error) {
      console.error("Failed to show test notification:", error)
      toast.error("Failed to show test notification")
    } finally {
      setIsLoading(false)
    }
  }

  if (!isSupported) {
    return (
      <Alert variant="destructive">
        <AlertCircle className="h-4 w-4" />
        <AlertDescription>
          Push notifications are not supported in your browser. Please use a modern browser like
          Chrome, Firefox, or Edge.
        </AlertDescription>
      </Alert>
    )
  }

  if (!vapidConfigured && process.env.NODE_ENV === "development") {
    return (
      <Alert variant="destructive">
        <AlertCircle className="h-4 w-4" />
        <AlertDescription>
          Push notifications are not configured. Please set up VAPID keys in your environment
          variables. Run <code className="text-xs">npx web-push generate-vapid-keys</code> to
          generate keys.
        </AlertDescription>
      </Alert>
    )
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          {isSubscribed ? (
            <>
              <Bell className="h-5 w-5 text-green-600" />
              Push Notifications Enabled
            </>
          ) : (
            <>
              <BellOff className="h-5 w-5 text-muted-foreground" />
              Push Notifications
            </>
          )}
        </CardTitle>
        <CardDescription>
          {isSubscribed
            ? "You'll receive real-time notifications for new projects, payments, and QC submissions"
            : "Enable push notifications to get instant alerts for important events"}
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        {permission === "denied" && (
          <Alert variant="destructive">
            <AlertCircle className="h-4 w-4" />
            <AlertDescription>
              Notification permission was denied. Please enable notifications in your browser
              settings to receive push notifications.
            </AlertDescription>
          </Alert>
        )}

        {permission === "granted" && isSubscribed && (
          <Alert>
            <CheckCircle2 className="h-4 w-4 text-green-600" />
            <AlertDescription>
              Push notifications are active. You'll receive alerts for:
              <ul className="list-disc list-inside mt-2 text-sm">
                <li>New project submissions</li>
                <li>Payment confirmations</li>
                <li>Work submitted for QC review</li>
                <li>New messages from clients or doers</li>
              </ul>
            </AlertDescription>
          </Alert>
        )}

        <div className="flex flex-col sm:flex-row gap-2">
          {!isSubscribed || permission !== "granted" ? (
            <Button
              onClick={handleEnableNotifications}
              disabled={isLoading || permission === "denied"}
              className="gap-2"
            >
              <Bell className="h-4 w-4" />
              {isLoading ? "Enabling..." : "Enable Push Notifications"}
            </Button>
          ) : (
            <>
              <Button
                onClick={handleTestNotification}
                disabled={isLoading}
                variant="outline"
                className="gap-2"
              >
                <Bell className="h-4 w-4" />
                {isLoading ? "Sending..." : "Send Test Notification"}
              </Button>
              <Button
                onClick={handleDisableNotifications}
                disabled={isLoading}
                variant="outline"
                className="gap-2"
              >
                <BellOff className="h-4 w-4" />
                {isLoading ? "Disabling..." : "Disable Notifications"}
              </Button>
            </>
          )}
        </div>

        <p className="text-xs text-muted-foreground">
          Push notifications work even when you close the browser tab. You can disable them at any
          time.
        </p>
      </CardContent>
    </Card>
  )
}
