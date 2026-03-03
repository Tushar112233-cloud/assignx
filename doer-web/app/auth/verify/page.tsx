'use client'

import { Suspense, useEffect, useState, useRef } from 'react'
import { useSearchParams } from 'next/navigation'
import { CheckCircle2, XCircle, Loader2 } from 'lucide-react'

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000'

function VerifyContent() {
  const searchParams = useSearchParams()
  const [status, setStatus] = useState<'verifying' | 'success' | 'error'>('verifying')
  const [message, setMessage] = useState('')
  const called = useRef(false)

  useEffect(() => {
    if (called.current) return
    called.current = true

    const email = searchParams.get('email')
    const token = searchParams.get('token')

    if (!email || !token) {
      setStatus('error')
      setMessage('Invalid link. Please request a new sign-in link.')
      return
    }

    const verify = async () => {
      try {
        const res = await fetch(`${API_URL}/api/auth/magic-link/verify`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ email, token }),
        })

        if (res.ok) {
          setStatus('success')
          setMessage('You can now close this tab and return to the login page.')
        } else {
          const data = await res.json().catch(() => null)
          setStatus('error')
          setMessage(data?.message || 'This link is invalid or has expired. Please request a new one.')
        }
      } catch {
        setStatus('error')
        setMessage('Something went wrong. Please try again.')
      }
    }

    verify()
  }, [searchParams])

  return (
    <div className="flex items-center justify-center min-h-screen bg-slate-50">
      <div className="w-full max-w-sm mx-auto px-6">
        <div className="rounded-2xl border border-slate-200 bg-white p-8 shadow-sm text-center space-y-5">
          {status === 'verifying' && (
            <>
              <Loader2 className="h-12 w-12 animate-spin text-[#5A7CFF] mx-auto" />
              <p className="text-sm text-slate-600 font-medium">Verifying your sign-in link...</p>
            </>
          )}

          {status === 'success' && (
            <>
              <div className="w-16 h-16 rounded-full bg-emerald-100 flex items-center justify-center mx-auto">
                <CheckCircle2 className="h-8 w-8 text-emerald-600" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-slate-900">Email verified!</h1>
                <p className="mt-2 text-sm text-slate-500 leading-relaxed">{message}</p>
              </div>
            </>
          )}

          {status === 'error' && (
            <>
              <div className="w-16 h-16 rounded-full bg-red-100 flex items-center justify-center mx-auto">
                <XCircle className="h-8 w-8 text-red-500" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-slate-900">Verification failed</h1>
                <p className="mt-2 text-sm text-slate-500 leading-relaxed">{message}</p>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  )
}

export default function VerifyPage() {
  return (
    <Suspense
      fallback={
        <div className="flex items-center justify-center min-h-screen bg-slate-50">
          <Loader2 className="h-8 w-8 animate-spin text-[#5A7CFF]" />
        </div>
      }
    >
      <VerifyContent />
    </Suspense>
  )
}
