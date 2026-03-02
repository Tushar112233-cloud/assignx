'use client'

import { Suspense } from 'react'
import { useEffect, useState } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import { verifyOTP } from '@/lib/api/auth'

/**
 * Session content component that uses useSearchParams
 */
function SessionContent() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const [status, setStatus] = useState('Initializing...')

  useEffect(() => {
    const establishSession = async () => {
      try {
        // Check if tokens are passed directly from the callback route
        const accessTokenParam = searchParams.get('access_token')
        const refreshTokenParam = searchParams.get('refresh_token')

        if (accessTokenParam) {
          setStatus('Storing session tokens...')
          localStorage.setItem('access_token', accessTokenParam)
          if (refreshTokenParam) {
            localStorage.setItem('refresh_token', refreshTokenParam)
          }
          setStatus('Session established! Redirecting...')
        } else {
          // Fallback: OTP-based verification
          const email = searchParams.get('email')
          const otp = searchParams.get('otp') || searchParams.get('token')

          if (email && otp) {
            setStatus('Verifying sign-in link...')
            await verifyOTP(email, otp)
            setStatus('Session established! Redirecting...')
          } else {
            // Check if tokens already exist
            const token = localStorage.getItem('access_token')
            if (!token) {
              setStatus('No session found - redirecting to login...')
              setTimeout(() => router.push('/login'), 2000)
              return
            }
            setStatus('Session found! Redirecting...')
          }
        }

        await new Promise(resolve => setTimeout(resolve, 500))

        const next = searchParams.get('next') || '/dashboard'
        const safePath = next.startsWith('/') && !next.startsWith('//') ? next : '/dashboard'

        router.push(safePath)
      } catch (err) {
        setStatus('Error: ' + (err instanceof Error ? err.message : 'Session verification failed'))
        setTimeout(() => router.push('/login?error=session'), 2000)
      }
    }

    establishSession()
  }, [router, searchParams])

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

/**
 * Session establishment page
 * Wrapped in Suspense for useSearchParams compatibility
 */
export default function SessionPage() {
  return (
    <Suspense
      fallback={
        <div className="flex items-center justify-center min-h-screen bg-background">
          <div className="text-center space-y-4">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto"></div>
            <p className="text-lg text-muted-foreground">Loading...</p>
          </div>
        </div>
      }
    >
      <SessionContent />
    </Suspense>
  )
}
