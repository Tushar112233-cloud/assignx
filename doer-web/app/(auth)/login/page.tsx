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
      if (isDevBypassEmail(trimmed)) {
        await devLogin(trimmed)
        window.location.href = '/dashboard'
        return
      }

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

      await sendOTP(trimmed, 'login', 'doer')
      setOtpSent(true)
      setResendCooldown(30)
      setTimeout(() => inputRefs.current[0]?.focus(), 100)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Something went wrong. Please try again.')
    } finally {
      setIsLoading(false)
    }
  }

  // ── OTP screen ──
  if (otpSent) {
    return (
      <div className="space-y-6">
        {/* Mobile logo */}
        <div className="lg:hidden flex items-center gap-2.5 mb-2">
          <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-[#5A7CFF]">
            <span className="text-xs font-bold text-white">D</span>
          </div>
          <span className="text-base font-bold tracking-tight text-slate-900">Dolancer</span>
        </div>

        <div className="text-center space-y-3">
          <div className="mx-auto flex h-14 w-14 items-center justify-center rounded-2xl bg-[#EEF2FF]">
            <KeyRound className="h-6 w-6 text-[#5A7CFF]" />
          </div>
          <div>
            <h1 className="text-xl font-bold tracking-tight text-slate-900">Check your email</h1>
            <p className="mt-1 text-sm text-slate-500">Enter the 6-digit code we sent to</p>
          </div>
        </div>

        <div className="flex items-center justify-center gap-2 rounded-lg bg-slate-50 px-4 py-2.5">
          <Mail className="h-4 w-4 text-slate-400" />
          <span className="text-sm font-medium text-slate-700">{email}</span>
        </div>

        <div>
          <div className="flex justify-center gap-2.5" onPaste={handleOtpPaste}>
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
                className="h-13 w-12 rounded-xl border-2 border-slate-200 bg-white text-center text-xl font-bold text-slate-900 transition-all focus:border-[#5A7CFF] focus:outline-none focus:ring-4 focus:ring-[#5A7CFF]/10 disabled:opacity-40"
              />
            ))}
          </div>

          {error && (
            <div className="mt-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-600">
              {error}
            </div>
          )}

          <Button
            type="button"
            size="lg"
            disabled={isLoading || otp.join('').length !== 6}
            onClick={() => handleVerify()}
            className="mt-5 h-11 w-full rounded-xl bg-[#5A7CFF] text-sm font-semibold text-white shadow-md shadow-[#5A7CFF]/20 hover:bg-[#4A6AEF] disabled:cursor-not-allowed disabled:opacity-40"
          >
            {isLoading ? (
              <><Loader2 className="mr-2 h-4 w-4 animate-spin" />Verifying...</>
            ) : (
              <>Verify & Login<ArrowRight className="ml-2 h-4 w-4" /></>
            )}
          </Button>
        </div>

        <div className="flex flex-col items-center gap-3 pt-1">
          <div className="flex items-center gap-2">
            {resendCooldown > 0 && (
              <span className="flex items-center gap-1 text-xs text-slate-400">
                <Clock className="h-3.5 w-3.5" />{resendCooldown}s
              </span>
            )}
            <button
              type="button"
              disabled={resendCooldown > 0}
              onClick={handleResend}
              className="text-sm font-medium text-[#5A7CFF] hover:underline underline-offset-4 disabled:text-slate-300 disabled:no-underline"
            >
              Resend code
            </button>
          </div>
          <button
            onClick={() => { setOtpSent(false); setOtp(['', '', '', '', '', '']); setError(null) }}
            className="flex items-center gap-1 text-xs font-medium text-slate-500 hover:text-slate-700"
          >
            <ArrowLeft className="h-3 w-3" />
            Use a different email
          </button>
        </div>
      </div>
    )
  }

  // ── Email screen ──
  return (
    <div className="space-y-6">
      {/* Mobile logo */}
      <div className="lg:hidden flex items-center gap-2.5 mb-2">
        <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-[#5A7CFF]">
          <span className="text-xs font-bold text-white">D</span>
        </div>
        <span className="text-base font-bold tracking-tight text-slate-900">Dolancer</span>
      </div>

      <div className="space-y-1">
        <h1 className="text-xl font-bold tracking-tight text-slate-900">Welcome back</h1>
        <p className="text-sm text-slate-500">Sign in with your email using OTP</p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-4">
        <div className="space-y-1.5">
          <label htmlFor="email" className="text-sm font-medium text-slate-700">
            Email address
          </label>
          <div className="relative">
            <Mail className="pointer-events-none absolute left-3.5 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
            <Input
              id="email"
              type="email"
              placeholder="you@example.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              disabled={isLoading}
              className="h-11 rounded-xl border-slate-200 bg-white pl-10 text-slate-900 placeholder:text-slate-400 focus-visible:border-[#5A7CFF] focus-visible:ring-4 focus-visible:ring-[#5A7CFF]/10"
            />
          </div>
        </div>

        {error && (
          <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-600">
            {error}
            {error.includes('account') && (
              <Link href="/register" className="mt-1 block font-semibold text-[#5A7CFF] hover:underline underline-offset-4">
                Request access
              </Link>
            )}
          </div>
        )}

        <Button
          type="submit"
          size="lg"
          disabled={isLoading || !email.trim()}
          className="h-11 w-full rounded-xl bg-[#5A7CFF] text-sm font-semibold text-white shadow-md shadow-[#5A7CFF]/20 hover:bg-[#4A6AEF] disabled:cursor-not-allowed disabled:opacity-40"
        >
          {isLoading ? (
            <><Loader2 className="mr-2 h-4 w-4 animate-spin" />Sending code...</>
          ) : (
            <>Continue<ArrowRight className="ml-2 h-4 w-4" /></>
          )}
        </Button>
      </form>

      <div className="relative">
        <div className="absolute inset-0 flex items-center"><div className="w-full border-t border-slate-100" /></div>
        <div className="relative flex justify-center"><span className="bg-white px-3 text-xs text-slate-400">or</span></div>
      </div>

      <p className="text-center text-sm text-slate-500">
        Don&apos;t have an account?{' '}
        <Link href="/register" className="font-semibold text-[#5A7CFF] hover:underline underline-offset-4">
          Apply to join
        </Link>
      </p>
    </div>
  )
}
