'use client'

import { useEffect } from 'react'
import { AlertTriangle, RefreshCw, ArrowLeft } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card'

/**
 * Error boundary for activation routes
 * Catches errors in training, quiz, bank-details
 */
export default function ActivationError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    console.error('[Activation] Route error:', error)
  }, [error])

  return (
    <div className="min-h-[60vh] flex items-center justify-center p-4">
      <Card className="max-w-md w-full">
        <CardHeader className="text-center">
          <div className="mx-auto mb-4 w-16 h-16 rounded-full bg-destructive/10 flex items-center justify-center">
            <AlertTriangle className="w-8 h-8 text-destructive" />
          </div>
          <CardTitle>Activation Error</CardTitle>
          <CardDescription>
            There was a problem with the activation process. Please try again.
          </CardDescription>
        </CardHeader>
        <CardContent>
          {process.env.NODE_ENV === 'development' && (
            <div className="bg-muted rounded-lg p-3 text-xs font-mono overflow-auto max-h-32">
              <p className="text-destructive font-semibold mb-1">{error.name}</p>
              <p>{error.message}</p>
            </div>
          )}
        </CardContent>
        <CardFooter className="flex gap-2">
          <Button variant="outline" onClick={() => window.location.href = '/training'} className="flex-1">
            <ArrowLeft className="w-4 h-4 mr-2" />
            Back to Training
          </Button>
          <Button onClick={reset} className="flex-1">
            <RefreshCw className="w-4 h-4 mr-2" />
            Try Again
          </Button>
        </CardFooter>
      </Card>
    </div>
  )
}
