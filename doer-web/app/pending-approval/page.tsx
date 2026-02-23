'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { Clock, Shield, CheckCircle2, FileCheck, UserCheck, Zap, LogOut, RefreshCw } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { createClient } from '@/lib/supabase/client'
import { useAuth } from '@/hooks/useAuth'

const steps = [
  {
    icon: CheckCircle2,
    label: 'Application submitted',
    desc: 'Your details have been received',
    state: 'done' as const,
  },
  {
    icon: FileCheck,
    label: 'Profile review',
    desc: 'Our team is verifying your qualifications and experience',
    state: 'active' as const,
  },
  {
    icon: UserCheck,
    label: 'Access approval',
    desc: 'An admin will grant you platform access once verified',
    state: 'pending' as const,
  },
  {
    icon: Zap,
    label: 'Full doer access',
    desc: 'Start taking on projects and earning',
    state: 'pending' as const,
  },
]

export default function PendingApprovalPage() {
  const router = useRouter()
  const [isChecking, setIsChecking] = useState(false)
  const [isLoggingOut, setIsLoggingOut] = useState(false)

  const handleCheckStatus = async () => {
    setIsChecking(true)
    try {
      const supabase = createClient()
      const { data: { session } } = await supabase.auth.getSession()
      const user = session?.user
      if (!user) {
        router.push('/login')
        return
      }

      const { data: doer } = await supabase
        .from('doers')
        .select('is_access_granted')
        .eq('profile_id', user.id)
        .maybeSingle()

      if (doer?.is_access_granted) {
        router.push('/dashboard')
      }
    } catch {
      // ignore
    } finally {
      setIsChecking(false)
    }
  }

  const { signOut } = useAuth()

  const handleLogout = async () => {
    setIsLoggingOut(true)
    try {
      await signOut()
    } catch {
      // ignore
    } finally {
      setIsLoggingOut(false)
    }
  }

  return (
    <div className="min-h-screen bg-[#F5F8FF] flex items-center justify-center p-4">
      {/* Background accents */}
      <div className="fixed top-[-100px] right-[-60px] w-[400px] h-[400px] bg-[#5A7CFF]/[0.04] blur-[100px] rounded-full pointer-events-none" />
      <div className="fixed bottom-[-80px] left-[-40px] w-72 h-72 bg-[#5A7CFF]/[0.03] blur-[80px] rounded-full pointer-events-none" />

      <div className="relative w-full max-w-lg space-y-6 animate-fade-in-up">
        {/* Header */}
        <div className="text-center space-y-4">
          <div className="relative inline-flex mx-auto">
            <div className="w-20 h-20 rounded-full bg-gradient-to-br from-blue-100 to-indigo-100 flex items-center justify-center">
              <div className="w-14 h-14 rounded-full bg-gradient-to-br from-blue-200 to-indigo-200 flex items-center justify-center">
                <Clock className="h-7 w-7 text-[#5A7CFF]" />
              </div>
            </div>
            <span className="absolute -top-1 -right-1 flex h-6 w-6">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-[#5A7CFF] opacity-60" />
              <span className="relative inline-flex rounded-full h-6 w-6 bg-[#5A7CFF] items-center justify-center">
                <Shield className="h-3.5 w-3.5 text-white" />
              </span>
            </span>
          </div>

          <div>
            <div className="inline-flex items-center gap-2 rounded-full border border-blue-200 bg-blue-50 px-3 py-1 text-xs font-semibold uppercase tracking-[0.15em] text-[#5A7CFF] mb-3">
              Under review
            </div>
            <h1 className="text-2xl lg:text-3xl font-semibold tracking-tight text-[#1C1C1C]">
              Almost there!
            </h1>
            <p className="mt-2 text-sm text-gray-500 leading-relaxed max-w-sm mx-auto">
              Your doer application is being reviewed by our team. We&apos;ll notify you once access is granted.
            </p>
          </div>
        </div>

        {/* Progress steps */}
        <div className="rounded-2xl border border-gray-200 overflow-hidden shadow-sm bg-white">
          {steps.map((step, i) => (
            <div
              key={i}
              className={`flex items-center gap-4 px-5 py-4 ${
                i < steps.length - 1 ? 'border-b border-gray-100' : ''
              } ${step.state === 'active' ? 'bg-blue-50/50' : ''}`}
            >
              <div
                className={`w-9 h-9 rounded-xl flex items-center justify-center shrink-0 ${
                  step.state === 'done'
                    ? 'bg-emerald-100'
                    : step.state === 'active'
                    ? 'bg-blue-100'
                    : 'bg-gray-100'
                }`}
              >
                <step.icon
                  className={`h-4 w-4 ${
                    step.state === 'done'
                      ? 'text-emerald-600'
                      : step.state === 'active'
                      ? 'text-[#5A7CFF]'
                      : 'text-gray-300'
                  }`}
                />
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 flex-wrap">
                  <span
                    className={`text-sm font-medium ${
                      step.state === 'pending' ? 'text-gray-400' : 'text-[#1C1C1C]'
                    }`}
                  >
                    {step.label}
                  </span>
                  {step.state === 'done' && (
                    <span className="text-[11px] font-semibold text-emerald-700 bg-emerald-50 border border-emerald-200 px-2 py-0.5 rounded-full">
                      Done
                    </span>
                  )}
                  {step.state === 'active' && (
                    <span className="text-[11px] font-semibold text-[#5A7CFF] bg-blue-50 border border-blue-200 px-2 py-0.5 rounded-full animate-pulse">
                      In progress
                    </span>
                  )}
                </div>
                <p
                  className={`text-xs mt-0.5 ${
                    step.state === 'pending' ? 'text-gray-300' : 'text-gray-500'
                  }`}
                >
                  {step.desc}
                </p>
              </div>
            </div>
          ))}
        </div>

        {/* Info card */}
        <div className="rounded-2xl border border-blue-200 bg-gradient-to-br from-blue-50 to-white p-4 flex items-start gap-3 shadow-sm">
          <div className="w-8 h-8 rounded-xl bg-blue-100 flex items-center justify-center shrink-0 mt-0.5">
            <Shield className="h-4 w-4 text-[#5A7CFF]" />
          </div>
          <div>
            <p className="text-sm font-semibold text-[#1C1C1C]">Quality-first verification</p>
            <p className="text-xs text-gray-500 mt-0.5 leading-relaxed">
              Every doer application is carefully reviewed to maintain our quality standards. This typically takes 24-48 hours.
            </p>
          </div>
        </div>

        {/* Actions */}
        <div className="space-y-3">
          <Button
            onClick={handleCheckStatus}
            disabled={isChecking}
            size="lg"
            className="w-full h-11 rounded-xl bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] text-white font-semibold shadow-[0_8px_24px_rgba(90,124,255,0.30)] hover:shadow-[0_12px_32px_rgba(90,124,255,0.40)] hover:opacity-95"
          >
            {isChecking ? (
              <>
                <RefreshCw className="h-4 w-4 animate-spin mr-2" />
                Checking...
              </>
            ) : (
              <>
                <RefreshCw className="h-4 w-4 mr-2" />
                Check approval status
              </>
            )}
          </Button>

          <Button
            onClick={handleLogout}
            disabled={isLoggingOut}
            variant="outline"
            size="lg"
            className="w-full h-11 rounded-xl border-gray-200 text-[#1C1C1C] hover:bg-gray-50 font-semibold"
          >
            <LogOut className="h-4 w-4 mr-2" />
            Sign out
          </Button>
        </div>

        <p className="text-center text-xs text-gray-400">
          Have questions? Contact us at{' '}
          <a href="mailto:support@assignx.com" className="text-[#5A7CFF] font-semibold hover:underline underline-offset-4">
            support@assignx.com
          </a>
        </p>
      </div>
    </div>
  )
}
