/**
 * @fileoverview Supervisor access-request pending page.
 * Shown after user submits their application; admin must approve before account is created.
 * @module app/(auth)/pending/page
 */

import { Suspense } from "react"
import { Clock, ArrowLeft } from "lucide-react"
import Link from "next/link"
import { Button } from "@/components/ui/button"
import { PendingEmailBadge } from "@/components/auth/pending-email-badge"

export default function PendingPage() {
  return (
    <div className="space-y-6 animate-fade-in-up">
      {/* Status icon */}
      <div className="flex justify-center">
        <div className="relative">
          <div className="w-20 h-20 rounded-full bg-gradient-to-br from-[#F97316]/15 to-[#FB923C]/10 flex items-center justify-center">
            <div className="w-14 h-14 rounded-full bg-gradient-to-br from-[#F97316]/25 to-[#EA580C]/20 flex items-center justify-center">
              <Clock className="h-7 w-7 text-[#F97316]" />
            </div>
          </div>
          <span className="absolute -top-1 -right-1 flex h-6 w-6">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-amber-400 opacity-60" />
            <span className="relative inline-flex rounded-full h-6 w-6 bg-amber-400 items-center justify-center">
              <Clock className="h-3.5 w-3.5 text-white" />
            </span>
          </span>
        </div>
      </div>

      {/* Message */}
      <div className="text-center space-y-2">
        <div className="inline-flex items-center gap-2 rounded-full border border-orange-200 bg-orange-50 px-3 py-1 text-xs font-semibold uppercase tracking-[0.15em] text-orange-700">
          Under Review
        </div>
        <h1 className="text-2xl lg:text-3xl font-semibold tracking-tight text-[#1C1C1C]">
          Your application is under review
        </h1>
        <p className="text-sm text-gray-500 leading-relaxed max-w-sm mx-auto">
          You'll receive an email once your application has been approved. This usually takes 24-48 hours.
        </p>
      </div>

      {/* Email badge */}
      <Suspense fallback={null}>
        <PendingEmailBadge />
      </Suspense>

      {/* Actions */}
      <div className="space-y-3 pt-2">
        <Link href="/login">
          <Button
            variant="outline"
            size="lg"
            className="w-full h-11 rounded-xl border-gray-200 text-[#1C1C1C] hover:bg-gray-50 font-semibold"
          >
            <ArrowLeft className="h-4 w-4 mr-2" />
            Back to sign in
          </Button>
        </Link>
        <p className="text-center text-xs text-gray-400">
          Submitted the wrong email?{" "}
          <Link href="/register" className="text-orange-600 font-semibold hover:underline underline-offset-4">
            Re-apply
          </Link>
        </p>
      </div>
    </div>
  )
}
