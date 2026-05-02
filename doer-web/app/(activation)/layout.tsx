'use client'

import { usePathname, useRouter } from 'next/navigation'
import { motion } from 'framer-motion'
import { Check, Lock, PlayCircle, ClipboardCheck, CreditCard } from 'lucide-react'
import { cn } from '@/lib/utils'
import { ACTIVATION_STEPS, ROUTES } from '@/lib/constants'
import { Logo } from '@/components/shared/Logo'
import { useActivationStore } from '@/hooks/useActivation'

/** Icon mapping for activation steps */
const stepIcons = {
  'play-circle': PlayCircle,
  'clipboard-check': ClipboardCheck,
  'credit-card': CreditCard,
}

/**
 * Activation layout with visual stepper
 * Shows progress through the 3 activation steps
 */
export default function ActivationLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const pathname = usePathname()
  const router = useRouter()

  /** Determine current step based on route */
  const getCurrentStep = () => {
    if (pathname.includes('/training')) return 1
    if (pathname.includes('/quiz')) return 2
    if (pathname.includes('/bank-details')) return 3
    return 1
  }

  const currentStep = getCurrentStep()

  const activation = useActivationStore((s) => s.activation)

  /** Get step status */
  const getStepStatus = (stepId: number) => {
    // Derive completed steps from activation store
    let completedSteps = 0
    if (activation?.training_completed) completedSteps = 1
    if (activation?.quiz_passed) completedSteps = 2
    if (activation?.bank_details_added) completedSteps = 3

    if (stepId < currentStep || stepId <= completedSteps) return 'completed'
    if (stepId === currentStep) return 'current'
    return 'locked'
  }

  /** Handle step click navigation */
  const handleStepClick = (step: typeof ACTIVATION_STEPS[number]) => {
    const status = getStepStatus(step.id)
    if (status !== 'locked') {
      router.push(step.route)
    }
  }

  return (
    <div className="min-h-screen bg-background flex flex-col">
      {/* Header with logo */}
      <header className="border-b">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <Logo size="sm" />
          <span className="text-sm text-muted-foreground">
            Account Setup
          </span>
        </div>
      </header>

      {/* Stepper */}
      <div className="border-b bg-muted/30">
        <div className="container mx-auto px-4 py-6">
          <div className="flex items-center justify-center">
            {ACTIVATION_STEPS.map((step, index) => {
              const status = getStepStatus(step.id)
              const Icon = stepIcons[step.icon as keyof typeof stepIcons]

              return (
                <div key={step.id} className="flex items-center">
                  {/* Step circle */}
                  <motion.button
                    onClick={() => handleStepClick(step)}
                    disabled={status === 'locked'}
                    className={cn(
                      'flex flex-col items-center gap-2 group',
                      status === 'locked' && 'cursor-not-allowed opacity-60'
                    )}
                    whileHover={status !== 'locked' ? { scale: 1.05 } : {}}
                    whileTap={status !== 'locked' ? { scale: 0.95 } : {}}
                  >
                    <div
                      className={cn(
                        'w-12 h-12 rounded-full flex items-center justify-center transition-colors',
                        status === 'completed' && 'bg-green-500 text-white',
                        status === 'current' && 'bg-primary text-primary-foreground',
                        status === 'locked' && 'bg-muted text-muted-foreground'
                      )}
                    >
                      {status === 'completed' ? (
                        <Check className="w-6 h-6" />
                      ) : status === 'locked' ? (
                        <Lock className="w-5 h-5" />
                      ) : (
                        <Icon className="w-6 h-6" />
                      )}
                    </div>
                    <div className="text-center">
                      <p
                        className={cn(
                          'text-sm font-medium',
                          status === 'current' && 'text-primary',
                          status === 'completed' && 'text-green-600',
                          status === 'locked' && 'text-muted-foreground'
                        )}
                      >
                        {step.title}
                      </p>
                      <p className="text-xs text-muted-foreground hidden sm:block max-w-[120px]">
                        {step.description}
                      </p>
                    </div>
                  </motion.button>

                  {/* Connector line */}
                  {index < ACTIVATION_STEPS.length - 1 && (
                    <div
                      className={cn(
                        'w-16 sm:w-24 h-1 mx-2 rounded-full transition-colors',
                        getStepStatus(step.id) === 'completed' ? 'bg-green-500' : 'bg-muted'
                      )}
                    />
                  )}
                </div>
              )
            })}
          </div>
        </div>
      </div>

      {/* Main content */}
      <main className="flex-1 container mx-auto px-4 py-8">
        {children}
      </main>
    </div>
  )
}
