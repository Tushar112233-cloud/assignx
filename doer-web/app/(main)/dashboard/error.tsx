'use client'

import { useEffect } from 'react'
import { AlertCircle, RefreshCw, Home, LayoutDashboard } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card'

/**
 * Error boundary for the Dashboard page
 * Handles errors during dashboard data fetching and rendering
 *
 * @param error - The error object with optional digest
 * @param reset - Function to reset error state and retry
 */
export default function DashboardError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    console.error('[Dashboard] Error caught:', error)
  }, [error])

  return (
    <div className="min-h-[60vh] flex items-center justify-center p-4">
      <Card className="max-w-md w-full">
        <CardHeader className="text-center">
          <div className="mx-auto mb-4 w-16 h-16 rounded-full bg-red-100 flex items-center justify-center">
            <AlertCircle className="w-8 h-8 text-red-600" />
          </div>
          <CardTitle className="flex items-center justify-center gap-2">
            <LayoutDashboard className="w-5 h-5" />
            Dashboard Error
          </CardTitle>
          <CardDescription>
            {error.message || 'Failed to load dashboard data. This could be due to a network issue or server error.'}
          </CardDescription>
        </CardHeader>

        <CardContent>
          {process.env.NODE_ENV === 'development' && (
            <div className="bg-slate-100 border border-slate-200 rounded-lg p-3 text-xs font-mono overflow-auto max-h-32">
              <p className="text-red-600 font-semibold mb-1">{error.name}</p>
              <p className="text-slate-700">{error.message}</p>
              {error.digest && (
                <p className="text-slate-500 mt-2">Error ID: {error.digest}</p>
              )}
            </div>
          )}
        </CardContent>

        <CardFooter className="flex gap-3 justify-center">
          <Button
            onClick={reset}
            className="gap-2"
          >
            <RefreshCw className="w-4 h-4" />
            Try Again
          </Button>

          <Button
            variant="outline"
            onClick={() => window.location.href = '/projects'}
            className="gap-2"
          >
            <Home className="w-4 h-4" />
            Go to Projects
          </Button>
        </CardFooter>
      </Card>
    </div>
  )
}
