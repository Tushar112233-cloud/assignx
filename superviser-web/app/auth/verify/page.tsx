/**
 * @fileoverview Legacy magic link verify page -- redirects to login.
 * Magic link auth has been replaced by OTP flow.
 * @module app/auth/verify/page
 */

"use client"

import { useEffect } from "react"
import { useRouter } from "next/navigation"
import { Loader2 } from "lucide-react"

export default function VerifyPage() {
  const router = useRouter()

  useEffect(() => {
    router.replace("/login")
  }, [router])

  return (
    <div className="flex items-center justify-center min-h-screen bg-gray-50">
      <Loader2 className="h-8 w-8 animate-spin text-[#F97316]" />
    </div>
  )
}
