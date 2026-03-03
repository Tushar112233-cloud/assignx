/**
 * @fileoverview Supervisor login form -- email-only magic link authentication.
 * No password required. API sends a verification link to the user's email.
 * The page polls for verification and shows a Login button once verified.
 * @module components/auth/login-form
 */

"use client"

import { useState, useEffect, useCallback } from "react"
import Link from "next/link"
import { useSearchParams } from "next/navigation"
import { Loader2, Mail, ArrowRight, Inbox, CheckCircle2 } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { sendMagicLink, checkMagicLinkStatus, checkAccessRequest, devLogin, isDevBypassEmail } from "@/lib/api/auth"

export function LoginForm() {
  const searchParams = useSearchParams()
  const [email, setEmail] = useState("")
  const [isLoading, setIsLoading] = useState(false)
  const [sent, setSent] = useState(false)
  const [sessionId, setSessionId] = useState("")
  const [verified, setVerified] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [resendCooldown, setResendCooldown] = useState(0)

  // Show error when callback redirects back with ?error=auth (expired/invalid link)
  useEffect(() => {
    if (searchParams.get("error") === "auth") {
      setError("The sign-in link was invalid or has expired. Please request a new one.")
    }
  }, [])

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
      const result = await sendMagicLink(email.trim().toLowerCase())
      setSessionId(result.sessionId)
      setVerified(false)
      setResendCooldown(30)
    } catch {
      setError("Failed to resend. Please try again.")
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
        setError("Please click the link in your email first.")
      }
    } catch {
      setError("Please click the link in your email first, then try again.")
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

      // Check email_access_requests to give specific feedback
      const request = await checkAccessRequest(trimmed, "supervisor")

      if (!request) {
        setError("No account found for this email. You need to create an account first.")
        return
      }

      const status = request.status
      if (status === "pending") {
        setError("Your access request is still pending admin verification. Please wait for approval.")
        return
      }
      if (status === "rejected") {
        setError("Your access request was not approved. Please contact support.")
        return
      }

      // Status is approved -- send magic link via API
      const result = await sendMagicLink(trimmed)
      setSessionId(result.sessionId)

      setSent(true)
    } catch {
      setError("Something went wrong. Please try again.")
    } finally {
      setIsLoading(false)
    }
  }

  if (sent) {
    return (
      <div className="space-y-5">
        {/* Status banner */}
        <div className="flex items-center gap-4 p-4 rounded-xl bg-orange-50 border border-orange-200">
          <div className="relative shrink-0">
            <div className="w-11 h-11 rounded-xl bg-orange-100 flex items-center justify-center">
              {verified ? (
                <CheckCircle2 className="h-5 w-5 text-emerald-600" />
              ) : (
                <Inbox className="h-5 w-5 text-orange-600" />
              )}
            </div>
            {!verified && (
              <span className="absolute -top-1 -right-1 flex h-5 w-5">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-orange-400 opacity-40" />
                <span className="relative inline-flex rounded-full h-5 w-5 bg-orange-100 items-center justify-center">
                  <Loader2 className="h-3 w-3 text-orange-600 animate-spin" />
                </span>
              </span>
            )}
            {verified && (
              <span className="absolute -top-1 -right-1 flex h-5 w-5">
                <span className="relative inline-flex rounded-full h-5 w-5 bg-emerald-400 items-center justify-center">
                  <CheckCircle2 className="h-3 w-3 text-white" />
                </span>
              </span>
            )}
          </div>
          <div className="min-w-0">
            <p className="text-sm font-semibold text-[#1C1C1C]">
              {verified ? "Email verified!" : "Verification link sent!"}
            </p>
            <p className="text-xs text-gray-500 truncate">
              {verified
                ? "Click Login to continue"
                : <>Check <span className="font-medium text-[#1C1C1C]">{email}</span></>
              }
            </p>
          </div>
        </div>

        {!verified && (
          <div className="space-y-2.5">
            {[
              "Open the email from AssignX",
              "Click the verification link",
              "Come back here and click Login",
            ].map((step, i) => (
              <div key={i} className="flex items-center gap-3">
                <div className="w-5 h-5 rounded-full bg-orange-100 flex items-center justify-center shrink-0 text-[11px] font-bold text-orange-600">
                  {i + 1}
                </div>
                <p className="text-sm text-gray-600">{step}</p>
              </div>
            ))}
          </div>
        )}

        {!verified && (
          <div className="flex items-center gap-2 px-3 py-2.5 rounded-xl bg-orange-50/60 border border-orange-100">
            <Loader2 className="h-3.5 w-3.5 text-orange-500 animate-spin shrink-0" />
            <p className="text-xs text-gray-500">Waiting for email verification...</p>
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
          className="w-full h-11 text-sm font-semibold rounded-xl bg-[#1C1C1C] hover:bg-[#2D2D2D] text-white border-0 shadow-sm hover:shadow-md transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
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
            className="rounded-xl border-gray-200 text-gray-700 hover:bg-gray-50 font-semibold"
          >
            {resendCooldown > 0
              ? `Resend in ${resendCooldown}s`
              : "Resend email"}
          </Button>
          <button
            onClick={() => { setSent(false); setEmail(""); setSessionId(""); setVerified(false) }}
            className="text-xs text-gray-400 hover:text-orange-600 transition-colors underline underline-offset-4"
          >
            Wrong email? Try again
          </button>
        </div>
      </div>
    )
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
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
              Create an account →
            </Link>
          )}
          {error.includes("pending") && (
            <Link
              href={`/pending?email=${encodeURIComponent(email.trim().toLowerCase())}`}
              className="block mt-1.5 font-semibold text-orange-600 hover:underline underline-offset-4"
            >
              View request status →
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
            Sending link...
          </>
        ) : (
          <>
            Send sign-in link
            <ArrowRight className="h-4 w-4 ml-2" />
          </>
        )}
      </Button>

      <p className="text-center text-xs text-gray-400">
        We'll send a secure verification link to your email. No password needed.
      </p>
    </form>
  )
}
