'use client'

import { useRouter } from 'next/navigation'
import { motion } from 'framer-motion'
import { Lock, Check, PlayCircle, ClipboardCheck, CreditCard, ArrowRight } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Progress } from '@/components/ui/progress'
import { cn } from '@/lib/utils'
import { ACTIVATION_STEPS, ROUTES } from '@/lib/constants'

/** Icon mapping for activation steps */
const stepIcons = {
  'play-circle': PlayCircle,
  'clipboard-check': ClipboardCheck,
  'credit-card': CreditCard,
}

interface ActivationGateProps {
  /** Current activation status for each step */
  activationStatus?: {
    training_completed: boolean
    quiz_passed: boolean
    bank_details_submitted: boolean
  }
  /** User's name for personalized greeting */
  userName?: string
}

/**
 * Activation gate component
 * Shows when user tries to access dashboard before completing activation
 */
export function ActivationGate({
  activationStatus = {
    training_completed: false,
    quiz_passed: false,
    bank_details_submitted: false,
  },
  userName = 'there',
}: ActivationGateProps) {
  const router = useRouter()

  /** Calculate completion percentage */
  const completedCount = [
    activationStatus.training_completed,
    activationStatus.quiz_passed,
    activationStatus.bank_details_submitted,
  ].filter(Boolean).length

  const progressPercentage = (completedCount / 3) * 100

  /** Get step completion status */
  const getStepCompleted = (stepId: number) => {
    switch (stepId) {
      case 1:
        return activationStatus.training_completed
      case 2:
        return activationStatus.quiz_passed
      case 3:
        return activationStatus.bank_details_submitted
      default:
        return false
    }
  }

  /** Get step locked status */
  const isStepLocked = (stepId: number) => {
    if (stepId === 1) return false
    if (stepId === 2) return !activationStatus.training_completed
    if (stepId === 3) return !activationStatus.quiz_passed
    return true
  }

  /** Get the next step to complete */
  const getNextStep = () => {
    if (!activationStatus.training_completed) return ACTIVATION_STEPS[0]
    if (!activationStatus.quiz_passed) return ACTIVATION_STEPS[1]
    if (!activationStatus.bank_details_submitted) return ACTIVATION_STEPS[2]
    return null
  }

  const nextStep = getNextStep()

  /** Handle continue button click */
  const handleContinue = () => {
    if (nextStep) {
      router.push(nextStep.route)
    }
  }

  return (
    <div className="min-h-screen bg-background flex items-center justify-center p-4">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="w-full max-w-2xl"
      >
        <Card className="border-2">
          <CardHeader className="text-center pb-4">
            <div className="mx-auto mb-4 w-16 h-16 rounded-full bg-primary/10 flex items-center justify-center">
              <Lock className="w-8 h-8 text-primary" />
            </div>
            <CardTitle className="text-2xl">
              Unlock Your Doer Dashboard
            </CardTitle>
            <CardDescription className="text-base">
              Hi {userName}! Complete these 3 steps to start earning
            </CardDescription>
          </CardHeader>

          <CardContent className="space-y-6">
            {/* Progress bar */}
            <div className="space-y-2">
              <div className="flex justify-between text-sm">
                <span className="text-muted-foreground">Setup Progress</span>
                <span className="font-medium">{completedCount}/3 completed</span>
              </div>
              <Progress value={progressPercentage} className="h-2" />
            </div>

            {/* Steps list */}
            <div className="space-y-3">
              {ACTIVATION_STEPS.map((step) => {
                const isCompleted = getStepCompleted(step.id)
                const isLocked = isStepLocked(step.id)
                const Icon = stepIcons[step.icon as keyof typeof stepIcons]

                return (
                  <motion.div
                    key={step.id}
                    whileHover={!isLocked ? { scale: 1.02 } : {}}
                    className={cn(
                      'flex items-center gap-4 p-4 rounded-lg border transition-colors',
                      isCompleted && 'bg-green-50 border-green-200 dark:bg-green-950/20 dark:border-green-800',
                      !isCompleted && !isLocked && 'bg-primary/5 border-primary/20 cursor-pointer hover:bg-primary/10',
                      isLocked && 'bg-muted/50 opacity-60 cursor-not-allowed'
                    )}
                    onClick={() => !isLocked && router.push(step.route)}
                  >
                    {/* Step icon */}
                    <div
                      className={cn(
                        'w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0',
                        isCompleted && 'bg-green-500 text-white',
                        !isCompleted && !isLocked && 'bg-primary text-primary-foreground',
                        isLocked && 'bg-muted text-muted-foreground'
                      )}
                    >
                      {isCompleted ? (
                        <Check className="w-5 h-5" />
                      ) : isLocked ? (
                        <Lock className="w-4 h-4" />
                      ) : (
                        <Icon className="w-5 h-5" />
                      )}
                    </div>

                    {/* Step content */}
                    <div className="flex-1">
                      <h3
                        className={cn(
                          'font-medium',
                          isCompleted && 'text-green-700 dark:text-green-400',
                          isLocked && 'text-muted-foreground'
                        )}
                      >
                        Step {step.id}: {step.title}
                      </h3>
                      <p className="text-sm text-muted-foreground">
                        {step.description}
                      </p>
                    </div>

                    {/* Status indicator */}
                    <div className="flex-shrink-0">
                      {isCompleted ? (
                        <span className="text-sm text-green-600 dark:text-green-400 font-medium">
                          Done
                        </span>
                      ) : !isLocked ? (
                        <ArrowRight className="w-5 h-5 text-primary" />
                      ) : null}
                    </div>
                  </motion.div>
                )
              })}
            </div>

            {/* Continue button */}
            {nextStep && (
              <Button
                onClick={handleContinue}
                className="w-full"
                size="lg"
              >
                Continue to {nextStep.title}
                <ArrowRight className="w-4 h-4 ml-2" />
              </Button>
            )}
          </CardContent>
        </Card>
      </motion.div>
    </div>
  )
}
