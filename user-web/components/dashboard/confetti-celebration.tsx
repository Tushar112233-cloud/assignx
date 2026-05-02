"use client"

/**
 * ConfettiCelebration - Canvas confetti celebrations for achievements
 * Provides various confetti effects for milestones and completions
 */

import * as React from "react"
import confetti from "canvas-confetti"
import { motion, AnimatePresence } from "framer-motion"
import { CheckCircle2, Trophy, Star, PartyPopper } from "lucide-react"

import { cn } from "@/lib/utils"
import { celebrationPop, springs } from "@/lib/animations/variants"

type ConfettiType = "standard" | "fireworks" | "stars" | "snow" | "burst"

interface ConfettiOptions {
  type?: ConfettiType
  duration?: number
  particleCount?: number
}

/**
 * Hook to trigger confetti celebrations
 */
export function useConfetti() {
  const triggerConfetti = React.useCallback((options: ConfettiOptions = {}) => {
    const {
      type = "standard",
      duration = 3000,
      particleCount = 100,
    } = options

    const end = Date.now() + duration

    const colors = ["#FF5C35", "#00C48C", "#FFB800", "#5B8DEF", "#FF6B9D"]

    switch (type) {
      case "fireworks": {
        const interval = setInterval(() => {
          if (Date.now() > end) {
            clearInterval(interval)
            return
          }

          confetti({
            particleCount: 30,
            startVelocity: 30,
            spread: 360,
            origin: {
              x: Math.random(),
              y: Math.random() - 0.2,
            },
            colors,
          })
        }, 250)
        break
      }

      case "stars": {
        const defaults = {
          spread: 360,
          ticks: 50,
          gravity: 0,
          decay: 0.94,
          startVelocity: 30,
          shapes: ["star"] as confetti.Shape[],
          colors,
        }

        confetti({
          ...defaults,
          particleCount: 40,
          scalar: 1.2,
          origin: { y: 0.3 },
        })

        confetti({
          ...defaults,
          particleCount: 25,
          scalar: 0.75,
          origin: { y: 0.5 },
        })
        break
      }

      case "snow": {
        const interval = setInterval(() => {
          if (Date.now() > end) {
            clearInterval(interval)
            return
          }

          confetti({
            particleCount: 2,
            startVelocity: 0,
            ticks: 200,
            gravity: 0.3,
            origin: {
              x: Math.random(),
              y: 0,
            },
            colors: ["#ffffff", "#f0f0f0"],
            shapes: ["circle"],
            scalar: 0.8,
          })
        }, 50)
        break
      }

      case "burst": {
        const count = 200
        const defaults = {
          origin: { y: 0.7 },
          colors,
        }

        function fire(particleRatio: number, opts: confetti.Options) {
          confetti({
            ...defaults,
            particleCount: Math.floor(count * particleRatio),
            ...opts,
          })
        }

        fire(0.25, { spread: 26, startVelocity: 55 })
        fire(0.2, { spread: 60 })
        fire(0.35, { spread: 100, decay: 0.91, scalar: 0.8 })
        fire(0.1, { spread: 120, startVelocity: 25, decay: 0.92, scalar: 1.2 })
        fire(0.1, { spread: 120, startVelocity: 45 })
        break
      }

      default: {
        confetti({
          particleCount,
          spread: 70,
          origin: { y: 0.6 },
          colors,
        })
      }
    }
  }, [])

  return { triggerConfetti }
}

/**
 * Celebration modal/toast for achievements
 */
interface CelebrationModalProps {
  isOpen: boolean
  onClose: () => void
  type?: "completion" | "achievement" | "milestone"
  title: string
  description?: string
  action?: {
    label: string
    onClick: () => void
  }
}

const celebrationIcons = {
  completion: CheckCircle2,
  achievement: Trophy,
  milestone: Star,
}

const celebrationColors = {
  completion: "text-green-500 bg-green-100 dark:bg-green-900/30",
  achievement: "text-yellow-500 bg-yellow-100 dark:bg-yellow-900/30",
  milestone: "text-purple-500 bg-purple-100 dark:bg-purple-900/30",
}

export function CelebrationModal({
  isOpen,
  onClose,
  type = "completion",
  title,
  description,
  action,
}: CelebrationModalProps) {
  const { triggerConfetti } = useConfetti()
  const Icon = celebrationIcons[type]

  React.useEffect(() => {
    if (isOpen) {
      triggerConfetti({ type: "burst" })
    }
  }, [isOpen, triggerConfetti])

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Backdrop */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="fixed inset-0 z-50 bg-black/40 backdrop-blur-sm"
          />

          {/* Modal */}
          <motion.div
            initial={{ opacity: 0, scale: 0.9, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.9, y: 20 }}
            transition={springs.bouncy}
            className="fixed left-1/2 top-1/2 z-50 -translate-x-1/2 -translate-y-1/2 w-full max-w-sm"
          >
            <div className="bg-card rounded-2xl p-6 shadow-xl border text-center">
              {/* Animated icon */}
              <motion.div
                variants={celebrationPop}
                initial="hidden"
                animate="visible"
                className={cn(
                  "mx-auto mb-4 flex items-center justify-center size-16 rounded-full",
                  celebrationColors[type]
                )}
              >
                <Icon className="size-8" />
              </motion.div>

              {/* Party popper decoration */}
              <motion.div
                initial={{ scale: 0, rotate: -45 }}
                animate={{ scale: 1, rotate: 0 }}
                transition={{ delay: 0.2, ...springs.bouncy }}
                className="absolute top-4 right-4"
              >
                <PartyPopper className="size-6 text-primary" />
              </motion.div>

              <motion.h2
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.1 }}
                className="text-xl font-bold text-foreground mb-2"
              >
                {title}
              </motion.h2>

              {description && (
                <motion.p
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.15 }}
                  className="text-muted-foreground mb-6"
                >
                  {description}
                </motion.p>
              )}

              <motion.div
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.2 }}
                className="flex gap-3 justify-center"
              >
                {action && (
                  <motion.button
                    whileHover={{ scale: 1.02 }}
                    whileTap={{ scale: 0.98 }}
                    onClick={action.onClick}
                    className="px-6 py-2.5 bg-primary text-primary-foreground rounded-xl font-medium"
                  >
                    {action.label}
                  </motion.button>
                )}
                <motion.button
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={onClose}
                  className="px-6 py-2.5 bg-muted text-muted-foreground rounded-xl font-medium"
                >
                  {action ? "Later" : "Awesome!"}
                </motion.button>
              </motion.div>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  )
}

/**
 * Small celebration badge that pops in
 */
export function CelebrationBadge({
  children,
  className,
}: {
  children: React.ReactNode
  className?: string
}) {
  return (
    <motion.div
      initial={{ scale: 0, rotate: -180 }}
      animate={{ scale: 1, rotate: 0 }}
      transition={springs.bouncy}
      className={cn(
        "inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full",
        "bg-primary/10 text-primary font-medium text-sm",
        className
      )}
    >
      <Star className="size-4 fill-current" />
      {children}
    </motion.div>
  )
}
