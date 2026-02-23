'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'

/**
 * Session establishment page
 * After OAuth, this page runs client-side to establish the session in localStorage
 * by calling getSession() which reads the JWT from local storage (no network call).
 */
export default function SessionPage() {
  const router = useRouter()
  const [status, setStatus] = useState('Initializing...')

  useEffect(() => {
    const establishSession = async () => {
      try {
        const supabase = createClient()

        setStatus('Verifying session...')

        // Use getSession() to check local session (avoids network hang)
        const { data: { session } } = await supabase.auth.getSession()
        const user = session?.user ?? null
        const error = !user ? new Error('No session') : null

        if (error) {
          setStatus('Error: ' + error.message)
          setTimeout(() => router.push('/login'), 2000)
          return
        }

        if (!user) {
          setStatus('No session found - redirecting to login...')
          setTimeout(() => router.push('/login'), 2000)
          return
        }

        setStatus('Session established! Redirecting...')

        // Small delay to ensure localStorage write completes
        await new Promise(resolve => setTimeout(resolve, 1000))

        // Check where to redirect based on the 'next' query param
        const params = new URLSearchParams(window.location.search)
        const next = params.get('next') || '/dashboard'
        // Validate redirect is a relative path (prevent open redirect)
        const safePath = next.startsWith('/') && !next.startsWith('//') ? next : '/dashboard'

        router.push(safePath)
      } catch {
        setStatus('Unexpected error occurred')
        setTimeout(() => router.push('/login'), 2000)
      }
    }

    establishSession()
  }, [router])

  return (
    <div className="flex items-center justify-center min-h-screen bg-background">
      <div className="text-center space-y-4">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto"></div>
        <p className="text-lg text-muted-foreground">Setting up your session...</p>
        <p className="text-sm text-muted-foreground">{status}</p>
      </div>
    </div>
  )
}
