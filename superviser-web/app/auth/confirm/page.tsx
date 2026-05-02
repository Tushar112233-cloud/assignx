/**
 * @fileoverview Client-side auth confirm page.
 * Handles magic link token verification via Express API.
 * Reads email + token from URL params, verifies, and redirects to dashboard.
 * @module app/auth/confirm/page
 */

"use client"

import { Suspense, useEffect, useRef } from "react"
import { useSearchParams } from "next/navigation"
import { verifyOTP } from "@/lib/api/auth"
import { Loader2 } from "lucide-react"

function ConfirmHandler() {
  const searchParams = useSearchParams()
  const exchanged = useRef(false)

  useEffect(() => {
    if (exchanged.current) return
    exchanged.current = true

    const email = searchParams.get("email")
    const token = searchParams.get("token")

    if (!email || !token) {
      window.location.href = "/login?error=auth"
      return
    }

    const verify = async () => {
      try {
        await verifyOTP(email, token)
        // Use full page navigation to ensure useAuth initializes fresh
        window.location.href = "/dashboard"
      } catch {
        window.location.href = "/login?error=auth"
      }
    }

    verify()
  }, [searchParams])

  return null
}

export default function AuthConfirmPage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="text-center space-y-4">
        <Loader2 className="h-8 w-8 animate-spin text-[#F97316] mx-auto" />
        <p className="text-sm text-gray-500 font-medium">Signing you in...</p>
      </div>
      <Suspense fallback={null}>
        <ConfirmHandler />
      </Suspense>
    </div>
  )
}
