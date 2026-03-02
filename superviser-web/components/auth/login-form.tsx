/**
 * @fileoverview Supervisor login form -- email-only magic link authentication.
 * No password required. API sends a sign-in link to the user's email.
 * @module components/auth/login-form
 */

"use client"

import { useState, useEffect } from "react"
import Link from "next/link"
import { useSearchParams } from "next/navigation"
import { Loader2, Mail, ArrowRight, Inbox, CheckCircle2 } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { sendMagicLink, checkAccessRequest, devLogin, isDevBypassEmail } from "@/lib/api/auth"

export function LoginForm() {
  const searchParams = useSearchParams()
  const [email, setEmail] = useState("")
  const [isLoading, setIsLoading] = useState(false)
  const [sent, setSent] = useState(false)
  const [error, setError] = useState<string | null>(null)

  // Show error when callback redirects back with ?error=auth (expired/invalid link)
  useEffect(() => {
    if (searchParams.get("error") === "auth") {
      setError("The sign-in link was invalid or has expired. Please request a new one.")
    }
  }, [])

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
      await sendMagicLink(trimmed)

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
        {/* Success icon */}
        <div className="flex items-center gap-4 p-4 rounded-xl bg-orange-50 border border-orange-200">
          <div className="relative shrink-0">
            <div className="w-11 h-11 rounded-xl bg-orange-100 flex items-center justify-center">
              <Inbox className="h-5 w-5 text-orange-600" />
            </div>
            <span className="absolute -top-1 -right-1 flex h-5 w-5">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-60" />
              <span className="relative inline-flex rounded-full h-5 w-5 bg-emerald-400 items-center justify-center">
                <CheckCircle2 className="h-3 w-3 text-white" />
              </span>
            </span>
          </div>
          <div className="min-w-0">
            <p className="text-sm font-semibold text-[#1C1C1C]">Sign-in link sent!</p>
            <p className="text-xs text-gray-500 truncate">Check <span className="font-medium text-[#1C1C1C]">{email}</span></p>
          </div>
        </div>

        <div className="space-y-2.5">
          {[
            "Open the email from AssignX",
            'Click the "Sign in" link',
            "You'll be logged in automatically",
          ].map((step, i) => (
            <div key={i} className="flex items-center gap-3">
              <div className="w-5 h-5 rounded-full bg-orange-100 flex items-center justify-center shrink-0 text-[11px] font-bold text-orange-600">
                {i + 1}
              </div>
              <p className="text-sm text-gray-600">{step}</p>
            </div>
          ))}
        </div>

        <button
          onClick={() => { setSent(false); setEmail("") }}
          className="text-xs text-gray-400 hover:text-orange-600 transition-colors underline underline-offset-4"
        >
          Wrong email? Try again
        </button>
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
        We'll send a secure sign-in link to your email. No password needed.
      </p>
    </form>
  )
}
