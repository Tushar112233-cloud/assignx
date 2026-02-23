/**
 * @fileoverview Client component that reads email from search params for the pending page.
 * Isolated here so the parent server component doesn't need 'use client'.
 * @module components/auth/pending-email-badge
 */

"use client"

import { useSearchParams } from "next/navigation"
import { Mail } from "lucide-react"

export function PendingEmailBadge() {
  const searchParams = useSearchParams()
  const email = searchParams.get("email") || ""

  if (!email) return null

  return (
    <div className="rounded-2xl border border-orange-200/60 bg-orange-50/50 p-4 flex items-center gap-3 shadow-sm">
      <div className="w-9 h-9 rounded-xl bg-orange-100 flex items-center justify-center shrink-0">
        <Mail className="h-4 w-4 text-orange-600" />
      </div>
      <div className="min-w-0">
        <p className="text-[11px] text-gray-400 font-semibold uppercase tracking-wide">Request submitted for</p>
        <p className="text-sm font-semibold text-[#1C1C1C] truncate">{email}</p>
      </div>
    </div>
  )
}
