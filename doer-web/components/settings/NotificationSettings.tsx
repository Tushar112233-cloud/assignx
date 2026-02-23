'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import { Bell, Mail, MessageSquare, Calendar } from 'lucide-react'
import { Switch } from '@/components/ui/switch'
import { Label } from '@/components/ui/label'

/**
 * NotificationSettings - Manage notification preferences
 */
export function NotificationSettings() {
  const [notifications, setNotifications] = useState({
    emailNotifications: true,
    pushNotifications: true,
    projectUpdates: true,
    paymentAlerts: true,
    messageNotifications: true,
    deadlineReminders: true,
    weeklyDigest: false,
  })

  const handleToggle = (key: keyof typeof notifications) => {
    setNotifications(prev => ({ ...prev, [key]: !prev[key] }))
  }

  const notificationItems = [
    {
      key: 'emailNotifications' as const,
      icon: Mail,
      title: 'Email Notifications',
      description: 'Receive notifications via email',
      iconBg: 'bg-[#E3E9FF]',
      iconColor: 'text-[#4F6CF7]',
    },
    {
      key: 'pushNotifications' as const,
      icon: Bell,
      title: 'Push Notifications',
      description: 'Enable browser push notifications',
      iconBg: 'bg-[#E6F4FF]',
      iconColor: 'text-[#4B9BFF]',
    },
    {
      key: 'projectUpdates' as const,
      icon: MessageSquare,
      title: 'Project Updates',
      description: 'Get notified about project status changes',
      iconBg: 'bg-[#ECE9FF]',
      iconColor: 'text-[#6B5BFF]',
    },
    {
      key: 'paymentAlerts' as const,
      icon: Bell,
      title: 'Payment Alerts',
      description: 'Receive alerts for payments and payouts',
      iconBg: 'bg-[#FFE7E1]',
      iconColor: 'text-[#FF8B6A]',
    },
    {
      key: 'messageNotifications' as const,
      icon: MessageSquare,
      title: 'New Messages',
      description: 'Get notified when you receive new messages',
      iconBg: 'bg-[#E3E9FF]',
      iconColor: 'text-[#4F6CF7]',
    },
    {
      key: 'deadlineReminders' as const,
      icon: Calendar,
      title: 'Deadline Reminders',
      description: 'Reminders for upcoming project deadlines',
      iconBg: 'bg-[#E6F4FF]',
      iconColor: 'text-[#4B9BFF]',
    },
    {
      key: 'weeklyDigest' as const,
      icon: Mail,
      title: 'Weekly Digest',
      description: 'Receive a weekly summary of your activity',
      iconBg: 'bg-[#ECE9FF]',
      iconColor: 'text-[#6B5BFF]',
    },
  ]

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3 }}
      className="rounded-[28px] border border-white/70 bg-white/85 p-8 shadow-[0_18px_40px_rgba(30,58,138,0.08)]"
    >
      <div className="space-y-6">
        <div>
          <h2 className="text-xl font-semibold text-slate-900">Notification Preferences</h2>
          <p className="mt-2 text-sm text-slate-500">
            Choose how you want to receive updates and notifications
          </p>
        </div>

        <div className="space-y-4">
          {notificationItems.map((item) => (
            <div
              key={item.key}
              className="flex items-center justify-between rounded-2xl bg-slate-50/80 p-5 transition hover:bg-slate-50"
            >
              <div className="flex items-center gap-4">
                <div className={`flex h-11 w-11 items-center justify-center rounded-xl ${item.iconBg}`}>
                  <item.icon className={`h-5 w-5 ${item.iconColor}`} />
                </div>
                <div>
                  <Label htmlFor={item.key} className="text-sm font-semibold text-slate-900 cursor-pointer">
                    {item.title}
                  </Label>
                  <p className="text-xs text-slate-500">{item.description}</p>
                </div>
              </div>
              <Switch
                id={item.key}
                checked={notifications[item.key]}
                onCheckedChange={() => handleToggle(item.key)}
              />
            </div>
          ))}
        </div>
      </div>
    </motion.div>
  )
}
