/**
 * @fileoverview Supervisor access-request pending page.
 * Shown after user submits their email; admin must approve before account is created.
 * @module app/(auth)/pending/page
 */

import { Suspense } from "react"
import { CheckCircle2, Clock, Shield, Zap, Mail, ArrowLeft } from "lucide-react"
import Link from "next/link"
import { Button } from "@/components/ui/button"
import { PendingEmailBadge } from "@/components/auth/pending-email-badge"

const statusSteps = [
  {
    icon: CheckCircle2,
    label: "Application submitted",
    desc: "Your email is in the review queue",
    state: "done" as const,
  },
  {
    icon: Clock,
    label: "Under review",
    desc: "Our team verifies every supervisor request within 24–48 hours",
    state: "active" as const,
  },
  {
    icon: Shield,
    label: "Account activation",
    desc: "You'll receive a confirmation email once approved",
    state: "pending" as const,
  },
  {
    icon: Zap,
    label: "Full supervisor access",
    desc: "Review, approve, and track quality outcomes in one place",
    state: "pending" as const,
  },
]

export default function PendingPage() {
  return (
    <div className="space-y-6 animate-fade-in-up">
      {/* Status icon + header */}
      <div className="space-y-4">
        <div className="relative inline-flex">
          {/* Outer glow ring */}
          <div className="w-20 h-20 rounded-full bg-gradient-to-br from-[#F97316]/15 to-[#FB923C]/10 flex items-center justify-center">
            <div className="w-14 h-14 rounded-full bg-gradient-to-br from-[#F97316]/25 to-[#EA580C]/20 flex items-center justify-center">
              <CheckCircle2 className="h-7 w-7 text-[#F97316]" />
            </div>
          </div>
          {/* Pulsing indicator */}
          <span className="absolute -top-1 -right-1 flex h-6 w-6">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-amber-400 opacity-60" />
            <span className="relative inline-flex rounded-full h-6 w-6 bg-amber-400 items-center justify-center">
              <Clock className="h-3.5 w-3.5 text-white" />
            </span>
          </span>
        </div>

        <div>
          <div className="inline-flex items-center gap-2 rounded-full border border-orange-200 bg-orange-50 px-3 py-1 text-xs font-semibold uppercase tracking-[0.15em] text-orange-700 mb-3">
            Application received
          </div>
          <h1 className="text-2xl lg:text-3xl font-semibold tracking-tight text-[#1C1C1C]">
            You're in the queue!
          </h1>
          <p className="mt-2 text-sm text-gray-500 leading-relaxed max-w-sm">
            Your supervisor access request is under review. We'll notify you by email once it's approved.
          </p>
        </div>
      </div>

      {/* Email badge — client component to read searchParams */}
      <Suspense fallback={null}>
        <PendingEmailBadge />
      </Suspense>

      {/* Progress steps */}
      <div className="rounded-2xl border border-gray-200 overflow-hidden shadow-sm">
        {statusSteps.map((step, i) => (
          <div
            key={i}
            className={`flex items-center gap-4 px-5 py-4 ${
              i < statusSteps.length - 1 ? "border-b border-gray-100" : ""
            } ${step.state === "active" ? "bg-orange-50/50" : "bg-white"}`}
          >
            <div
              className={`w-9 h-9 rounded-xl flex items-center justify-center shrink-0 ${
                step.state === "done"
                  ? "bg-emerald-100"
                  : step.state === "active"
                  ? "bg-orange-100"
                  : "bg-gray-100"
              }`}
            >
              <step.icon
                className={`h-4 w-4 ${
                  step.state === "done"
                    ? "text-emerald-600"
                    : step.state === "active"
                    ? "text-orange-600"
                    : "text-gray-300"
                }`}
              />
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2 flex-wrap">
                <span
                  className={`text-sm font-medium ${
                    step.state === "pending" ? "text-gray-400" : "text-[#1C1C1C]"
                  }`}
                >
                  {step.label}
                </span>
                {step.state === "done" && (
                  <span className="text-[11px] font-semibold text-emerald-700 bg-emerald-50 border border-emerald-200 px-2 py-0.5 rounded-full">
                    Done
                  </span>
                )}
                {step.state === "active" && (
                  <span className="text-[11px] font-semibold text-orange-700 bg-orange-50 border border-orange-200 px-2 py-0.5 rounded-full animate-pulse">
                    In progress
                  </span>
                )}
              </div>
              <p
                className={`text-xs mt-0.5 ${
                  step.state === "pending" ? "text-gray-300" : "text-gray-500"
                }`}
              >
                {step.desc}
              </p>
            </div>
          </div>
        ))}
      </div>

      {/* Info note */}
      <div className="rounded-2xl border border-orange-200 bg-gradient-to-br from-orange-50 to-white p-4 flex items-start gap-3 shadow-sm">
        <div className="w-8 h-8 rounded-xl bg-orange-100 flex items-center justify-center shrink-0 mt-0.5">
          <Shield className="h-4 w-4 text-orange-600" />
        </div>
        <div>
          <p className="text-sm font-semibold text-[#1C1C1C]">Approval-first access</p>
          <p className="text-xs text-gray-500 mt-0.5 leading-relaxed">
            Supervisor access is carefully verified to ensure quality control standards. Every application is personally reviewed.
          </p>
        </div>
      </div>

      {/* Actions */}
      <div className="space-y-3">
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
            Try again
          </Link>
        </p>
      </div>
    </div>
  )
}
