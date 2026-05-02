/**
 * @fileoverview Supervisor login form -- email + OTP authentication.
 * Phase 1: Email input -> check supervisor status -> route based on result.
 * Phase 2: OTP input (6 digits) -> verify -> redirect based on isActivated.
 * @module components/auth/login-form
 */

"use client"

import { useState, useEffect, useCallback } from "react"
import Link from "next/link"
import { useSearchParams } from "next/navigation"
import { Loader2, Mail, ArrowRight, KeyRound } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { checkSupervisorStatus, sendSupervisorOTP, verifySupervisorOTP, devLogin, isDevBypassEmail } from "@/lib/api/auth"

export function LoginForm() {
  const searchParams = useSearchParams()
  const [email, setEmail] = useState("")
  const [otp, setOtp] = useState("")
  const [phase, setPhase] = useState<"email" | "otp">("email")
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [statusMessage, setStatusMessage] = useState<{ type: "pending" | "rejected"; text: string } | null>(null)
  const [resendCooldown, setResendCooldown] = useState(0)
  const [isActivated, setIsActivated] = useState(false)

  useEffect(() => {
    if (searchParams.get("error") === "auth") {
      setError("Your session has expired. Please sign in again.")
    }
  }, [searchParams])

  useEffect(() => {
    if (resendCooldown <= 0) return
    const timer = setTimeout(() => setResendCooldown(resendCooldown - 1), 1000)
    return () => clearTimeout(timer)
  }, [resendCooldown])

  const handleResend = useCallback(async () => {
    if (resendCooldown > 0) return
    try {
      await sendSupervisorOTP(email.trim().toLowerCase(), "login")
      setResendCooldown(60)
      setError(null)
    } catch {
      setError("Failed to resend code. Please try again.")
    }
  }, [email, resendCooldown])

  const handleEmailSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    const trimmed = email.trim().toLowerCase()
    if (!trimmed) return

    setIsLoading(true)
    setError(null)
    setStatusMessage(null)

    try {
      // Dev bypass
      if (isDevBypassEmail(trimmed)) {
        await devLogin(trimmed)
        window.location.href = "/dashboard"
        return
      }

      const result = await checkSupervisorStatus(trimmed)

      if (result.status === "not_found") {
        setError("No account found for this email. Please create an account first.")
        return
      }

      if (result.status === "pending") {
        setStatusMessage({
          type: "pending",
          text: "Your application is under review. You'll receive an email once approved.",
        })
        return
      }

      if (result.status === "rejected") {
        setStatusMessage({
          type: "rejected",
          text: "Your application was not approved.",
        })
        return
      }

      // Approved -- send OTP
      setIsActivated(result.isActivated ?? false)
      await sendSupervisorOTP(trimmed, "login")
      setPhase("otp")
      setResendCooldown(60)
    } catch {
      setError("Something went wrong. Please try again.")
    } finally {
      setIsLoading(false)
    }
  }

  const handleOtpSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (otp.length !== 6) return

    setIsLoading(true)
    setError(null)

    try {
      await verifySupervisorOTP(email.trim().toLowerCase(), otp)
      window.location.href = isActivated ? "/dashboard" : "/modules"
    } catch {
      setError("Invalid or expired code. Please try again.")
    } finally {
      setIsLoading(false)
    }
  }

  if (phase === "otp") {
    return (
      <div className="space-y-4">
        <div className="flex items-center gap-3 p-3.5 rounded-xl bg-orange-50 border border-orange-200">
          <div className="w-10 h-10 rounded-xl bg-orange-100 flex items-center justify-center shrink-0">
            <KeyRound className="h-5 w-5 text-orange-600" />
          </div>
          <div className="min-w-0">
            <p className="text-sm font-semibold text-[#1C1C1C]">Enter verification code</p>
            <p className="text-xs text-gray-500 truncate">
              Sent to <span className="font-medium text-[#1C1C1C]">{email}</span>
            </p>
          </div>
        </div>

        <form onSubmit={handleOtpSubmit} className="space-y-4">
          <div className="space-y-1.5">
            <label htmlFor="otp" className="text-sm font-semibold text-[#1C1C1C]">
              6-digit code
            </label>
            <Input
              id="otp"
              type="text"
              inputMode="numeric"
              pattern="[0-9]*"
              maxLength={6}
              placeholder="000000"
              value={otp}
              onChange={(e) => setOtp(e.target.value.replace(/\D/g, "").slice(0, 6))}
              disabled={isLoading}
              autoFocus
              className="h-12 text-center text-2xl font-mono tracking-[0.5em] bg-gray-50 border-gray-200 rounded-xl text-[#1C1C1C] placeholder:text-gray-300 focus-visible:border-[#F97316] focus-visible:ring-4 focus-visible:ring-orange-500/10 transition-all"
            />
          </div>

          {error && (
            <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-600">
              {error}
            </div>
          )}

          <Button
            type="submit"
            size="lg"
            disabled={isLoading || otp.length !== 6}
            className="w-full h-11 text-sm font-semibold rounded-xl bg-[#1C1C1C] hover:bg-[#2D2D2D] text-white border-0 shadow-sm hover:shadow-md transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isLoading ? (
              <>
                <Loader2 className="h-4 w-4 animate-spin mr-2" />
                Verifying...
              </>
            ) : (
              <>
                Verify & Sign In
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
              className="rounded-xl border-gray-200 text-gray-700 hover:bg-gray-50 font-semibold"
            >
              {resendCooldown > 0 ? `Resend in ${resendCooldown}s` : "Resend code"}
            </Button>
            <button
              type="button"
              onClick={() => { setPhase("email"); setOtp(""); setError(null) }}
              className="text-xs text-gray-400 hover:text-orange-600 transition-colors underline underline-offset-4"
            >
              Wrong email? Go back
            </button>
          </div>
        </form>
      </div>
    )
  }

  return (
    <form onSubmit={handleEmailSubmit} className="space-y-4">
      <div className="space-y-1.5">
        <label htmlFor="login-email" className="text-sm font-semibold text-[#1C1C1C]">
          Email address
        </label>
        <div className="relative">
          <Mail className="absolute left-3.5 top-1/2 -translate-y-1/2 h-[17px] w-[17px] text-gray-400 pointer-events-none" />
          <Input
            id="login-email"
            type="email"
            placeholder="you@company.com"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            disabled={isLoading}
            className="pl-10 h-11 bg-gray-50 border-gray-200 rounded-xl text-[#1C1C1C] placeholder:text-gray-400 focus-visible:border-[#F97316] focus-visible:ring-4 focus-visible:ring-orange-500/10 transition-all"
          />
        </div>
      </div>

      {error && (
        <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-600">
          {error}
          {error.includes("create an account") && (
            <Link
              href="/register"
              className="block mt-1.5 font-semibold text-orange-600 hover:underline underline-offset-4"
            >
              Create an account &rarr;
            </Link>
          )}
        </div>
      )}

      {statusMessage && (
        <div className={`rounded-xl border px-4 py-3 text-sm ${
          statusMessage.type === "pending"
            ? "border-amber-200 bg-amber-50 text-amber-700"
            : "border-red-200 bg-red-50 text-red-600"
        }`}>
          {statusMessage.text}
          {statusMessage.type === "rejected" && (
            <Link
              href="/register"
              className="block mt-1.5 font-semibold text-orange-600 hover:underline underline-offset-4"
            >
              Re-apply &rarr;
            </Link>
          )}
        </div>
      )}

      <Button
        type="submit"
        size="lg"
        disabled={isLoading || !email.trim()}
        className="w-full h-11 text-sm font-semibold rounded-xl bg-[#1C1C1C] hover:bg-[#2D2D2D] text-white border-0 shadow-sm hover:shadow-md transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
      >
        {isLoading ? (
          <>
            <Loader2 className="h-4 w-4 animate-spin mr-2" />
            Checking...
          </>
        ) : (
          <>
            Continue
            <ArrowRight className="h-4 w-4 ml-2" />
          </>
        )}
      </Button>

      <p className="text-center text-xs text-gray-400">
        We'll send a 6-digit verification code to your email.
      </p>
    </form>
  )
}
