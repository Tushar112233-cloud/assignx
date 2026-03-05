'use client'

import { useState, useEffect, useRef, useCallback } from 'react'
import Link from 'next/link'
import { Loader2, Mail, ArrowRight, ArrowLeft, KeyRound, Clock } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { sendOTP, verifyOTP, devLogin, isDevBypassEmail, checkAccessStatus } from '@/lib/api/auth'

export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [otp, setOtp] = useState(['', '', '', '', '', ''])
  const [isLoading, setIsLoading] = useState(false)
  const [otpSent, setOtpSent] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [resendCooldown, setResendCooldown] = useState(0)
  const inputRefs = useRef<(HTMLInputElement | null)[]>([])

  useEffect(() => {
    if (resendCooldown <= 0) return
    const timer = setTimeout(() => setResendCooldown(resendCooldown - 1), 1000)
    return () => clearTimeout(timer)
  }, [resendCooldown])

  // Auto-submit when all 6 digits are entered
  useEffect(() => {
    const code = otp.join('')
    if (code.length === 6 && otpSent) {
      handleVerify(code)
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [otp])

  const handleOtpChange = (index: number, value: string) => {
    if (!/^\d*$/.test(value)) return
    const newOtp = [...otp]
    newOtp[index] = value.slice(-1)
    setOtp(newOtp)
    setError(null)

    // Auto-focus next input
    if (value && index < 5) {
      inputRefs.current[index + 1]?.focus()
    }
  }

  const handleOtpKeyDown = (index: number, e: React.KeyboardEvent) => {
    if (e.key === 'Backspace' && !otp[index] && index > 0) {
      inputRefs.current[index - 1]?.focus()
    }
  }

  const handleOtpPaste = (e: React.ClipboardEvent) => {
    e.preventDefault()
    const pasted = e.clipboardData.getData('text').replace(/\D/g, '').slice(0, 6)
    if (pasted.length === 0) return
    const newOtp = [...otp]
    for (let i = 0; i < 6; i++) {
      newOtp[i] = pasted[i] || ''
    }
    setOtp(newOtp)
    const focusIndex = Math.min(pasted.length, 5)
    inputRefs.current[focusIndex]?.focus()
  }

  const handleResend = useCallback(async () => {
    if (resendCooldown > 0) return
    try {
      setError(null)
      await sendOTP(email.trim().toLowerCase(), 'login', 'doer')
      setOtp(['', '', '', '', '', ''])
      setResendCooldown(30)
    } catch {
      setError('Failed to resend. Please try again.')
    }
  }, [email, resendCooldown])

  const handleVerify = async (code?: string) => {
    const otpCode = code || otp.join('')
    if (otpCode.length !== 6) {
      setError('Please enter the 6-digit code.')
      return
    }

    try {
      setIsLoading(true)
      setError(null)
      await verifyOTP(email.trim().toLowerCase(), otpCode)
      window.location.href = '/dashboard'
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Invalid code. Please try again.')
      setOtp(['', '', '', '', '', ''])
      inputRefs.current[0]?.focus()
    } finally {
      setIsLoading(false)
    }
  }

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

      // Check access status
      const accessData = await checkAccessStatus(trimmed, 'doer')

      if (!accessData || accessData.status === 'not_found') {
        setError("No account found for this email. Apply for access below.")
        return
      }

      if (accessData.status === 'pending') {
        setError("Your profile is under review. Please wait for approval.")
        return
      }

      if (accessData.status === 'rejected') {
        setError("Your application was not approved. Please contact support.")
        return
      }

      // Send OTP
      await sendOTP(trimmed, 'login', 'doer')
      setOtpSent(true)
      setResendCooldown(30)
      // Focus first OTP input after render
      setTimeout(() => inputRefs.current[0]?.focus(), 100)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Something went wrong. Please try again.')
    } finally {
      setIsLoading(false)
    }
  }

  // OTP entry screen
  if (otpSent) {
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
        <div className="space-y-4">
          <div className="relative inline-flex">
            <div className="w-20 h-20 rounded-full bg-gradient-to-br from-[#5A7CFF]/15 to-teal-500/15 flex items-center justify-center">
              <div className="w-14 h-14 rounded-full bg-gradient-to-br from-[#5A7CFF]/25 to-teal-500/25 flex items-center justify-center">
                <KeyRound className="h-7 w-7 text-[#5A7CFF]" />
              </div>
            </div>
          </div>
          <div>
            <h1 className="text-2xl sm:text-3xl font-bold tracking-tight text-slate-900">
              Enter verification code
            </h1>
            <p className="mt-2 text-sm text-slate-500 leading-relaxed">
              We sent a 6-digit code to your email
            </p>
          </div>
        </div>

        {/* Email display */}
        <div className="rounded-2xl border border-[#5A7CFF]/20 bg-[#F7F9FF] p-4 flex items-center gap-3 shadow-sm">
          <div className="w-9 h-9 rounded-xl bg-[#5A7CFF]/10 flex items-center justify-center shrink-0">
            <Mail className="h-4 w-4 text-[#5A7CFF]" />
          </div>
          <div className="min-w-0">
            <p className="text-[11px] text-slate-400 font-medium uppercase tracking-wide">Code sent to</p>
            <p className="text-sm font-semibold text-slate-800 truncate">{email}</p>
          </div>
        </div>

        {/* OTP input */}
        <div className="rounded-2xl border border-slate-200/80 bg-[#F7F9FF] p-5 shadow-[0_4px_20px_rgba(148,163,184,0.08)]">
          <div className="flex justify-center gap-3" onPaste={handleOtpPaste}>
            {otp.map((digit, i) => (
              <input
                key={i}
                ref={(el) => { inputRefs.current[i] = el }}
                type="text"
                inputMode="numeric"
                maxLength={1}
                value={digit}
                onChange={(e) => handleOtpChange(i, e.target.value)}
                onKeyDown={(e) => handleOtpKeyDown(i, e)}
                disabled={isLoading}
                className="w-12 h-14 text-center text-xl font-bold rounded-xl border border-slate-200 bg-white text-slate-900 focus:border-[#5A7CFF] focus:ring-4 focus:ring-[#5A7CFF]/10 focus:outline-none transition-all disabled:opacity-50"
              />
            ))}
          </div>

          {error && (
            <div className="mt-4 rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-600">
              {error}
            </div>
          )}

          <Button
            type="button"
            size="lg"
            disabled={isLoading || otp.join('').length !== 6}
            onClick={() => handleVerify()}
            className="w-full mt-4 h-11 text-sm font-semibold rounded-xl bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] text-white border-0 shadow-[0_8px_24px_rgba(90,124,255,0.30)] hover:shadow-[0_12px_32px_rgba(90,124,255,0.40)] hover:opacity-95 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isLoading ? (
              <>
                <Loader2 className="h-4 w-4 animate-spin mr-2" />
                Verifying...
              </>
            ) : (
              <>
                Verify & Login
                <ArrowRight className="h-4 w-4 ml-2" />
              </>
            )}
          </Button>
        </div>

        {/* Resend + back */}
        <div className="flex flex-col items-center gap-2">
          <div className="flex items-center gap-2">
            {resendCooldown > 0 && (
              <div className="flex items-center gap-1 text-xs text-slate-400">
                <Clock className="h-3.5 w-3.5" />
                {resendCooldown}s
              </div>
            )}
            <Button
              type="button"
              variant="outline"
              size="sm"
              disabled={resendCooldown > 0}
              onClick={handleResend}
              className="rounded-xl border-slate-200 text-slate-700 hover:bg-slate-50 font-semibold"
            >
              Resend code
            </Button>
          </div>
          <button
            onClick={() => { setOtpSent(false); setOtp(['', '', '', '', '', '']); setError(null) }}
            className="text-xs text-[#5A7CFF] font-semibold hover:underline underline-offset-4 flex items-center gap-1"
          >
            <ArrowLeft className="h-3 w-3" />
            Change email
          </button>
        </div>
      </div>
    )
  }

  // Email entry screen
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
            <p className="text-xs text-slate-500">Sign in with your email using OTP</p>
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
                Sending code...
              </>
            ) : (
              <>
                Send OTP
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
