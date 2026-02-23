/**
 * @fileoverview Client-side auth code exchange page.
 * Handles PKCE code exchange using the browser client which has access
 * to the code verifier stored in cookies during signInWithOtp.
 * @module app/auth/confirm/page
 */

"use client"

import { Suspense, useEffect, useRef } from "react"
import { useSearchParams, useRouter } from "next/navigation"
import { createClient, storeAuthUser } from "@/lib/supabase/client"
import { Loader2 } from "lucide-react"

function ConfirmHandler() {
  const searchParams = useSearchParams()
  const router = useRouter()
  const exchanged = useRef(false)

  useEffect(() => {
    if (exchanged.current) return
    exchanged.current = true

    const code = searchParams.get("code")

    if (!code) {
      router.replace("/login?error=auth")
      return
    }

    const supabase = createClient()

    supabase.auth.exchangeCodeForSession(code).then(async ({ data, error }) => {
      if (error) {
        router.replace("/login?error=auth")
      } else {
        // Persist user to localStorage so dashboard loads instantly
        if (data.user) storeAuthUser(data.user)
        // Auto-create supervisor record from approved access request metadata
        await fetch("/api/auth/setup-supervisor", { method: "POST" }).catch(() => {})
        router.replace("/dashboard")
      }
    })
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
