"use client"

import { useEffect } from "react"
import { useRouter } from "next/navigation"

export default function AuthConfirmError({ error }: { error: Error }) {
  const router = useRouter()

  useEffect(() => {
    console.error("[auth/confirm] Error:", error.message)
    router.replace("/login?error=auth")
  }, [error, router])

  return null
}
