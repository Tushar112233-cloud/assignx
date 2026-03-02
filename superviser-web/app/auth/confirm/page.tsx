/**
 * @fileoverview Client-side auth code exchange page.
 * Handles OTP/magic-link token verification via Express API.
 * @module app/auth/confirm/page
 */

"use client"

import { Suspense, useEffect, useRef } from "react"
import { useSearchParams, useRouter } from "next/navigation"
import { setTokens } from "@/lib/api/client"
import { storeUser } from "@/lib/api/auth"
import { Loader2 } from "lucide-react"

const API_BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000"

function ConfirmHandler() {
  const searchParams = useSearchParams()
  const router = useRouter()
  const exchanged = useRef(false)

  useEffect(() => {
    if (exchanged.current) return
    exchanged.current = true

    const token = searchParams.get("token")
    const code = searchParams.get("code")

    if (!token && !code) {
      router.replace("/login?error=auth")
      return
    }

    const verify = async () => {
      try {
        const res = await fetch(`${API_BASE}/api/auth/verify-token`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ token: token || code }),
        })

        if (!res.ok) {
          router.replace("/login?error=auth")
          return
        }

        const data = await res.json()

        if (data.accessToken && data.refreshToken) {
          setTokens(data.accessToken, data.refreshToken)
        }
        if (data.user) {
          storeUser(data.user)
        }

        // Auto-create supervisor record from approved access request metadata
        await fetch(`${API_BASE}/api/auth/setup-supervisor`, {
          method: "POST",
          headers: {
            Authorization: `Bearer ${data.accessToken}`,
          },
        }).catch(() => {})

        router.replace("/dashboard")
      } catch {
        router.replace("/login?error=auth")
      }
    }

    verify()
  }, [searchParams, router])

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
