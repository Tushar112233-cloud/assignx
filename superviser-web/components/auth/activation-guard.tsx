/**
 * @fileoverview Client-side activation guard that redirects non-activated supervisors to /modules.
 * Wrap around dashboard content to enforce training completion before access.
 * @module components/auth/activation-guard
 */

"use client"

import { useEffect, useState } from "react"
import { useRouter, usePathname } from "next/navigation"
import { apiFetch } from "@/lib/api/client"
import { getAccessToken } from "@/lib/api/client"

/** Routes that skip the activation check */
const BYPASS_PATHS = ["/login", "/register", "/pending", "/modules", "/training"]

export function ActivationGuard({ children }: { children: React.ReactNode }) {
  const router = useRouter()
  const pathname = usePathname()
  const [checked, setChecked] = useState(false)

  useEffect(() => {
    const check = async () => {
      const token = getAccessToken()
      if (!token) {
        setChecked(true)
        return
      }

      // Skip check for auth pages and modules page
      if (BYPASS_PATHS.some(p => pathname.startsWith(p))) {
        setChecked(true)
        return
      }

      try {
        const data = await apiFetch<{
          profile: { userType: string }
          roleData: { isActivated: boolean } | null
        }>("/api/auth/me")

        if (
          data.profile?.userType === "supervisor" &&
          data.roleData &&
          !data.roleData.isActivated
        ) {
          router.replace("/modules")
          return
        }
      } catch {
        // Token invalid -- let normal auth flow handle it
      }

      setChecked(true)
    }

    check()
  }, [pathname, router])

  if (!checked) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="h-6 w-6 animate-spin rounded-full border-2 border-[#F97316] border-t-transparent" />
      </div>
    )
  }

  return <>{children}</>
}
