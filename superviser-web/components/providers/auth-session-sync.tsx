"use client"

import { useEffect, useMemo, useRef } from "react"
import { createClient } from "@/lib/supabase/client"

interface AuthSessionSyncProps {
  accessToken: string | null
  refreshToken: string | null
}

export function AuthSessionSync({ accessToken, refreshToken }: AuthSessionSyncProps) {
  const supabase = useMemo(() => createClient(), [])
  const lastTokensRef = useRef<string | null>(null)

  useEffect(() => {
    if (!accessToken || !refreshToken) return

    const tokenKey = `${accessToken}.${refreshToken}`
    if (lastTokensRef.current === tokenKey) return

    lastTokensRef.current = tokenKey

    void supabase.auth.setSession({
      access_token: accessToken,
      refresh_token: refreshToken,
    })
  }, [accessToken, refreshToken, supabase])

  return null
}
