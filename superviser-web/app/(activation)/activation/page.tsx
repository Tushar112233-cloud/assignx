/**
 * @fileoverview Legacy activation page — redirects to new training flow.
 * @module app/(activation)/activation/page
 */

"use client"

import { useEffect } from "react"
import { useRouter } from "next/navigation"
import { Loader2 } from "lucide-react"

export default function ActivationPage() {
  const router = useRouter()

  useEffect(() => {
    router.replace("/training")
  }, [router])

  return (
    <div className="min-h-screen flex items-center justify-center">
      <Loader2 className="h-8 w-8 animate-spin text-[#F97316]" />
    </div>
  )
}
