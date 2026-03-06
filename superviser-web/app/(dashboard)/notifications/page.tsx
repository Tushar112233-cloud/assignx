/**
 * @fileoverview Notifications page displaying project submissions, payments, and message alerts.
 * @module app/(dashboard)/notifications/page
 */

"use client"

import { NotificationList } from "@/components/notifications"

export default function NotificationsPage() {
  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h2 className="text-2xl font-bold tracking-tight">Notifications</h2>
        <p className="text-muted-foreground">
          Stay updated with project submissions, payments, and messages
        </p>
      </div>

      {/* Notification List */}
      <NotificationList />
    </div>
  )
}
