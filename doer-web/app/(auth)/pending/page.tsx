'use client'

/**
 * @fileoverview Doer access-request pending page.
 * Shown after user submits their email; admin must approve before account is created.
 */

import { Suspense } from 'react'
import { useSearchParams } from 'next/navigation'
import Link from 'next/link'
import { CheckCircle2, Clock, Shield, Zap, Mail, ArrowLeft, Sparkles } from 'lucide-react'
import { Button } from '@/components/ui/button'

const statusSteps = [
  {
    icon: CheckCircle2,
    label: 'Application submitted',
    desc: 'Your email is in the review queue',
    state: 'done',
  },
  {
    icon: Clock,
    label: 'Under review',
    desc: 'Our team will verify your request within 24–48 hours',
    state: 'active',
  },
  {
    icon: Shield,
    label: 'Account activation',
    desc: "You'll receive a confirmation email once approved",
    state: 'pending',
  },
  {
    icon: Zap,
    label: 'Start earning',
    desc: 'Accept projects, build your reputation, and grow',
    state: 'pending',
  },
]

function PendingContent() {
  const searchParams = useSearchParams()
  const email = searchParams.get('email') || ''

  return (
    <div className="space-y-7">
      {/* Mobile logo */}
      <div className="lg:hidden flex items-center gap-3">
        <div className="w-11 h-11 rounded-xl bg-gradient-to-br from-teal-500 to-emerald-600 flex items-center justify-center shadow-lg shadow-teal-500/20">
          <span className="text-lg font-bold text-white">AX</span>
        </div>
        <div>
          <p className="text-base font-bold text-slate-900">AssignX</p>
          <p className="text-xs text-slate-500">Dolancer Portal</p>
        </div>
      </div>

      {/* Status icon + title */}
      <div className="space-y-4">
        <div className="relative inline-flex">
          {/* Outer ring */}
          <div className="w-20 h-20 rounded-full bg-gradient-to-br from-[#5A7CFF]/15 to-teal-500/15 flex items-center justify-center">
            {/* Inner ring */}
            <div className="w-14 h-14 rounded-full bg-gradient-to-br from-[#5A7CFF]/25 to-teal-500/25 flex items-center justify-center">
              <CheckCircle2 className="h-7 w-7 text-[#5A7CFF]" />
            </div>
          </div>
          {/* Pulsing badge */}
          <span className="absolute -top-1 -right-1 flex h-6 w-6">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-amber-400 opacity-60" />
            <span className="relative inline-flex rounded-full h-6 w-6 bg-amber-400 items-center justify-center">
              <Clock className="h-3.5 w-3.5 text-white" />
            </span>
          </span>
        </div>

        <div>
          <div className="inline-flex items-center gap-1.5 rounded-full bg-[#EEF2FF] border border-[#C7D2FE] px-3 py-1 text-xs font-semibold text-[#5A7CFF] mb-3">
            <Sparkles className="h-3 w-3" />
            Application received
          </div>
          <h1 className="text-2xl sm:text-3xl font-bold tracking-tight text-slate-900">
            You're in the queue!
          </h1>
          <p className="mt-1.5 text-sm text-slate-500 leading-relaxed max-w-sm">
            Your application is under review. We'll send you an email as soon as it's approved.
          </p>
        </div>
      </div>

      {/* Email confirmation */}
      {email && (
        <div className="rounded-2xl border border-[#5A7CFF]/20 bg-[#F7F9FF] p-4 flex items-center gap-3 shadow-sm">
          <div className="w-9 h-9 rounded-xl bg-[#5A7CFF]/10 flex items-center justify-center shrink-0">
            <Mail className="h-4 w-4 text-[#5A7CFF]" />
          </div>
          <div className="min-w-0">
            <p className="text-[11px] text-slate-400 font-medium uppercase tracking-wide">Submitted for</p>
            <p className="text-sm font-semibold text-slate-800 truncate">{email}</p>
          </div>
        </div>
      )}

      {/* Progress steps */}
      <div className="rounded-2xl border border-slate-200/80 overflow-hidden shadow-[0_4px_20px_rgba(148,163,184,0.08)]">
        {statusSteps.map((step, i) => (
          <div
            key={i}
            className={`flex items-center gap-4 px-5 py-4 ${
              i < statusSteps.length - 1 ? 'border-b border-slate-100' : ''
            } ${step.state === 'active' ? 'bg-amber-50/60' : 'bg-white'}`}
          >
            <div
              className={`w-9 h-9 rounded-xl flex items-center justify-center shrink-0 transition-colors ${
                step.state === 'done'
                  ? 'bg-emerald-100'
                  : step.state === 'active'
                  ? 'bg-amber-100'
                  : 'bg-slate-100'
              }`}
            >
              <step.icon
                className={`h-4 w-4 ${
                  step.state === 'done'
                    ? 'text-emerald-600'
                    : step.state === 'active'
                    ? 'text-amber-600'
                    : 'text-slate-300'
                }`}
              />
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2 flex-wrap">
                <span
                  className={`text-sm font-medium ${
                    step.state === 'pending' ? 'text-slate-400' : 'text-slate-800'
                  }`}
                >
                  {step.label}
                </span>
                {step.state === 'done' && (
                  <span className="text-[11px] font-semibold text-emerald-600 bg-emerald-50 border border-emerald-200 px-2 py-0.5 rounded-full">
                    Done
                  </span>
                )}
                {step.state === 'active' && (
                  <span className="text-[11px] font-semibold text-amber-600 bg-amber-50 border border-amber-200 px-2 py-0.5 rounded-full animate-pulse">
                    In progress
                  </span>
                )}
              </div>
              <p
                className={`text-xs mt-0.5 ${
                  step.state === 'pending' ? 'text-slate-300' : 'text-slate-500'
                }`}
              >
                {step.desc}
              </p>
            </div>
          </div>
        ))}
      </div>

      {/* Actions */}
      <div className="space-y-3">
        <Link href="/login">
          <Button
            variant="outline"
            size="lg"
            className="w-full h-11 rounded-xl border-slate-200 text-slate-700 hover:bg-slate-50 font-semibold"
          >
            <ArrowLeft className="h-4 w-4 mr-2" />
            Back to sign in
          </Button>
        </Link>
        <p className="text-center text-xs text-slate-400">
          Submitted the wrong email?{' '}
          <Link href="/register" className="text-[#5A7CFF] font-semibold hover:underline underline-offset-4">
            Try again
          </Link>
        </p>
      </div>
    </div>
  )
}

export default function PendingPage() {
  return (
    <Suspense
      fallback={
        <div className="space-y-7 animate-pulse">
          <div className="w-20 h-20 rounded-full bg-slate-100" />
          <div className="h-8 w-48 rounded-lg bg-slate-100" />
          <div className="h-16 rounded-2xl bg-slate-100" />
          <div className="h-48 rounded-2xl bg-slate-100" />
        </div>
      }
    >
      <PendingContent />
    </Suspense>
  )
}
