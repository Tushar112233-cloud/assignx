'use client'

import { useState, useEffect, useCallback } from 'react'
import Link from 'next/link'
import { useSearchParams } from 'next/navigation'
import { Loader2, Mail, ArrowRight, CheckCircle2, Inbox } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { sendMagicLink, checkMagicLinkStatus, devLogin, isDevBypassEmail } from '@/lib/api/auth'
import { apiClient } from '@/lib/api/client'

export default function LoginPage() {
  const searchParams = useSearchParams()
  const [email, setEmail] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const [sent, setSent] = useState(false)
  const [sessionId, setSessionId] = useState('')
  const [verified, setVerified] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [resendCooldown, setResendCooldown] = useState(0)

  useEffect(() => {
    const err = searchParams.get('error')
    if (err) {
      setError('The sign-in link was invalid or has expired. Please request a new one.')
    }
  }, [searchParams])

  useEffect(() => {
    if (resendCooldown <= 0) return
    const timer = setTimeout(() => setResendCooldown(resendCooldown - 1), 1000)
    return () => clearTimeout(timer)
  }, [resendCooldown])

  // Poll for magic link verification
  useEffect(() => {
    if (!sent || !sessionId || verified) return

    const interval = setInterval(async () => {
      try {
        const result = await checkMagicLinkStatus(email.trim().toLowerCase(), sessionId)
        if (result.status === 'verified') {
          setVerified(true)
          clearInterval(interval)
          window.location.href = '/dashboard'
        }
      } catch {
        // Token expired or not found — stop polling
        clearInterval(interval)
      }
    }, 3000)

    return () => clearInterval(interval)
  }, [sent, sessionId, email, verified])

  const handleResend = useCallback(async () => {
    if (resendCooldown > 0) return
    try {
      const result = await sendMagicLink(email.trim().toLowerCase(), 'doer')
      setSessionId(result.sessionId)
      setVerified(false)
      setResendCooldown(30)
    } catch {
      setError('Failed to resend. Please try again.')
    }
  }, [email, resendCooldown])

  const handleLogin = useCallback(async () => {
    // If already verified by polling, just redirect
    if (verified) {
      window.location.href = '/dashboard'
      return
    }
    try {
      setIsLoading(true)
      setError(null)
      const result = await checkMagicLinkStatus(email.trim().toLowerCase(), sessionId)
      if (result.status === 'verified') {
        setVerified(true)
        window.location.href = '/dashboard'
      } else {
        setError('Please click the link in your email first.')
      }
    } catch {
      setError('Please click the link in your email first, then try again.')
    } finally {
      setIsLoading(false)
    }
  }, [email, sessionId, verified])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    const trimmed = email.trim().toLowerCase()
    if (!trimmed) return

    setIsLoading(true)
    setError(null)

    try {
      // Dev bypass: direct login without OTP
      if (isDevBypassEmail(trimmed)) {
        await devLogin(trimmed)
        window.location.href = '/dashboard'
        return
      }

      // Check email access request status via API
      try {
        const accessData = await apiClient<{ status: string }>(
          `/api/auth/access-status?email=${encodeURIComponent(trimmed)}&role=doer`,
          { skipAuth: true }
        )

        if (!accessData || accessData.status === 'not_found') {
          setError("No account found for this email. Apply for access below.")
          return
        }

        if (accessData.status === 'pending') {
          setError("Your application is still under review. Please wait for approval.")
          return
        }
        if (accessData.status === 'rejected') {
          setError("Your application was not approved. Please contact support.")
          return
        }
      } catch {
        // If access check fails, proceed with magic link anyway
      }

      // Send magic link via API
      const result = await sendMagicLink(trimmed, 'doer')
      setSessionId(result.sessionId)
      setSent(true)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Something went wrong. Please try again.')
    } finally {
      setIsLoading(false)
    }
  }

  if (sent) {
    return (
      <div className="space-y-7">
        {/* Mobile logo */}
        <div className="lg:hidden flex items-center gap-3">
          <div className="w-11 h-11 rounded-xl bg-gradient-to-br from-teal-500 to-emerald-600 flex items-center justify-center shadow-lg shadow-teal-500/20">
            <span className="text-lg font-bold text-white">AX</span>
          </div>
          <div>
            <p className="text-base font-bold text-slate-900">AssignX</p>
            <p className="text-xs text-slate-500">Doer Portal</p>
          </div>
        </div>

        {/* Success state */}
        <div className="space-y-4">
          <div className="relative inline-flex">
            <div className="w-20 h-20 rounded-full bg-gradient-to-br from-[#5A7CFF]/15 to-teal-500/15 flex items-center justify-center">
              <div className="w-14 h-14 rounded-full bg-gradient-to-br from-[#5A7CFF]/25 to-teal-500/25 flex items-center justify-center">
                {verified ? (
                  <CheckCircle2 className="h-7 w-7 text-emerald-500" />
                ) : (
                  <Inbox className="h-7 w-7 text-[#5A7CFF]" />
                )}
              </div>
            </div>
            {!verified && (
              <span className="absolute -top-1 -right-1 flex h-6 w-6">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-[#5A7CFF] opacity-40" />
                <span className="relative inline-flex rounded-full h-6 w-6 bg-[#5A7CFF]/20 items-center justify-center">
                  <Loader2 className="h-3.5 w-3.5 text-[#5A7CFF] animate-spin" />
                </span>
              </span>
            )}
            {verified && (
              <span className="absolute -top-1 -right-1 flex h-6 w-6">
                <span className="relative inline-flex rounded-full h-6 w-6 bg-emerald-400 items-center justify-center">
                  <CheckCircle2 className="h-3.5 w-3.5 text-white" />
                </span>
              </span>
            )}
          </div>
          <div>
            <h1 className="text-2xl sm:text-3xl font-bold tracking-tight text-slate-900">
              {verified ? 'Email verified!' : 'Check your inbox'}
            </h1>
            <p className="mt-2 text-sm text-slate-500 leading-relaxed">
              {verified
                ? 'You are now verified. Click Login to continue.'
                : 'We sent a verification link to your email'}
            </p>
          </div>
        </div>

        <div className="rounded-2xl border border-[#5A7CFF]/20 bg-[#F7F9FF] p-4 flex items-center gap-3 shadow-sm">
          <div className="w-9 h-9 rounded-xl bg-[#5A7CFF]/10 flex items-center justify-center shrink-0">
            <Mail className="h-4 w-4 text-[#5A7CFF]" />
          </div>
          <div className="min-w-0">
            <p className="text-[11px] text-slate-400 font-medium uppercase tracking-wide">Verification link sent to</p>
            <p className="text-sm font-semibold text-slate-800 truncate">{email}</p>
          </div>
        </div>

        {!verified && (
          <div className="rounded-2xl border border-slate-200/80 bg-white p-4 space-y-3 shadow-sm">
            <p className="text-sm font-semibold text-slate-700">What to do next</p>
            {[
              'Open the email from AssignX',
              'Click the verification link',
              'Come back here and click Login',
            ].map((step, i) => (
              <div key={i} className="flex items-center gap-3">
                <div className="w-5 h-5 rounded-full bg-[#5A7CFF]/10 flex items-center justify-center shrink-0 text-[11px] font-bold text-[#5A7CFF]">
                  {i + 1}
                </div>
                <p className="text-sm text-slate-600">{step}</p>
              </div>
            ))}
          </div>
        )}

        {!verified && (
          <div className="flex items-center gap-2 px-4 py-3 rounded-xl bg-[#5A7CFF]/5 border border-[#5A7CFF]/10">
            <Loader2 className="h-4 w-4 text-[#5A7CFF] animate-spin shrink-0" />
            <p className="text-xs text-slate-500">Waiting for email verification...</p>
          </div>
        )}

        {error && (
          <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-600">
            {error}
          </div>
        )}

        <Button
          type="button"
          size="lg"
          disabled={isLoading}
          onClick={handleLogin}
          className="w-full h-11 text-sm font-semibold rounded-xl bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] text-white border-0 shadow-[0_8px_24px_rgba(90,124,255,0.30)] hover:shadow-[0_12px_32px_rgba(90,124,255,0.40)] hover:opacity-95 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {isLoading ? (
            <>
              <Loader2 className="h-4 w-4 animate-spin mr-2" />
              Logging in...
            </>
          ) : (
            <>
              Login
              <ArrowRight className="h-4 w-4 ml-2" />
            </>
          )}
        </Button>

        <div className="flex flex-col items-center gap-2">
          <Button
            type="button"
            variant="outline"
            size="sm"
            disabled={resendCooldown > 0}
            onClick={handleResend}
            className="rounded-xl border-slate-200 text-slate-700 hover:bg-slate-50 font-semibold"
          >
            {resendCooldown > 0
              ? `Resend in ${resendCooldown}s`
              : 'Resend email'}
          </Button>
          <p className="text-xs text-slate-400">
            Wrong email?{' '}
            <button
              onClick={() => { setSent(false); setEmail(''); setSessionId(''); setVerified(false) }}
              className="text-[#5A7CFF] font-semibold hover:underline underline-offset-4"
            >
              Try again
            </button>
          </p>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-7">
      {/* Mobile logo */}
      <div className="lg:hidden flex items-center gap-3">
        <div className="w-11 h-11 rounded-xl bg-gradient-to-br from-teal-500 to-emerald-600 flex items-center justify-center shadow-lg shadow-teal-500/20">
          <span className="text-lg font-bold text-white">AX</span>
        </div>
        <div>
          <p className="text-base font-bold text-slate-900">AssignX</p>
          <p className="text-xs text-slate-500">Doer Portal</p>
        </div>
      </div>

      {/* Header */}
      <div className="space-y-2">
        <div className="flex items-center gap-3">
          <div className="h-10 w-10 rounded-full bg-[#F3F6FF] flex items-center justify-center text-[#5A7CFF] text-xl">
            *
          </div>
          <div>
            <h1 className="text-2xl font-semibold text-slate-900">Welcome back</h1>
            <p className="text-xs text-slate-500">Sign in with just your email -- no password needed</p>
          </div>
        </div>
      </div>

      {/* Form */}
      <div className="rounded-2xl border border-slate-200/80 bg-[#F7F9FF] p-5 shadow-[0_4px_20px_rgba(148,163,184,0.08)]">
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-1.5">
            <label htmlFor="email" className="text-sm font-semibold text-slate-700">
              Email address
            </label>
            <div className="relative">
              <Mail className="absolute left-3.5 top-1/2 -translate-y-1/2 h-[17px] w-[17px] text-slate-400 pointer-events-none" />
              <Input
                id="email"
                type="email"
                placeholder="you@example.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                disabled={isLoading}
                className="pl-10 h-11 bg-white border-slate-200 rounded-xl text-slate-900 placeholder:text-slate-400 focus-visible:border-[#5A7CFF] focus-visible:ring-4 focus-visible:ring-[#5A7CFF]/10 transition-all"
              />
            </div>
          </div>

          {error && (
            <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-600">
              {error}
              {error.includes('account') && (
                <Link href="/register" className="block mt-1.5 font-semibold text-[#5A7CFF] hover:underline underline-offset-4">
                  Request access
                </Link>
              )}
            </div>
          )}

          <Button
            type="submit"
            size="lg"
            disabled={isLoading || !email.trim()}
            className="w-full h-11 text-sm font-semibold rounded-xl bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] text-white border-0 shadow-[0_8px_24px_rgba(90,124,255,0.30)] hover:shadow-[0_12px_32px_rgba(90,124,255,0.40)] hover:opacity-95 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isLoading ? (
              <>
                <Loader2 className="h-4 w-4 animate-spin mr-2" />
                Sending link...
              </>
            ) : (
              <>
                Send sign-in link
                <ArrowRight className="h-4 w-4 ml-2" />
              </>
            )}
          </Button>
        </form>
      </div>

      {/* Feature highlights */}
      <div className="rounded-2xl border border-slate-200/80 bg-white p-4 shadow-[0_10px_30px_-20px_rgba(26,46,94,0.2)]">
        <div className="relative py-2">
          <div className="absolute inset-0 flex items-center">
            <div className="w-full border-t border-slate-200" />
          </div>
          <div className="relative flex justify-center text-[11px] uppercase tracking-[0.2em] text-slate-400">
            <span className="bg-white px-3">Why join as a Doer?</span>
          </div>
        </div>
        <div className="mt-4 grid gap-3">
          {[
            { icon: 'z', title: 'Flexible Work', desc: 'Choose projects that fit your schedule' },
            { icon: 'o', title: 'Fair Compensation', desc: 'Competitive rates for quality work' },
            { icon: 'v', title: 'Secure Platform', desc: 'Protected payments and data' },
          ].map((item) => (
            <div key={item.title} className="flex items-center gap-3 rounded-2xl bg-[#F5F8FF] px-4 py-3">
              <div className="h-9 w-9 rounded-full bg-[#EEF2FF] flex items-center justify-center text-base shrink-0">
                {item.icon === 'z' ? '~' : item.icon === 'o' ? '*' : '+'}
              </div>
              <div>
                <p className="text-sm font-semibold text-slate-900">{item.title}</p>
                <p className="text-xs text-slate-600">{item.desc}</p>
              </div>
            </div>
          ))}
        </div>
      </div>

      <p className="text-center text-sm text-slate-500">
        New to AssignX?{' '}
        <Link href="/register" className="font-semibold text-[#5A7CFF] hover:underline underline-offset-4">
          Request access
        </Link>
      </p>
    </div>
  )
}
