'use client'

import { useState, useCallback } from 'react'
import { motion, AnimatePresence, useMotionValue, useTransform, PanInfo } from 'framer-motion'
import { X, Globe, Wallet, Headphones, BookOpen, Check } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'

interface OnboardingSlide {
  id: number
  title: string
  description: string
  icon: React.ReactNode
  color: string
  lightColor: string
}

const slides: OnboardingSlide[] = [
  {
    id: 1,
    title: 'Countless Opportunities',
    description: 'Discover countless opportunities in your field of expertise. Connect with projects that match your skills.',
    icon: <Globe className="h-8 w-8" />,
    color: '#5B86FF', // Blue
    lightColor: '#EEF2FF',
  },
  {
    id: 2,
    title: 'Small Tasks, Big Rewards',
    description: 'Complete small tasks and earn big rewards consistently. Your skills have real value here.',
    icon: <Wallet className="h-8 w-8" />,
    color: '#14B8A6', // Teal
    lightColor: '#CCFBF1',
  },
  {
    id: 3,
    title: 'Supervisor Support (24x7)',
    description: 'Get round-the-clock support from dedicated supervisors. We are here to help you succeed.',
    icon: <Headphones className="h-8 w-8" />,
    color: '#A855F7', // Purple
    lightColor: '#F3E8FF',
  },
  {
    id: 4,
    title: 'Practical Learning',
    description: 'Practical learning with part-time earning opportunities. Grow your skills while you earn.',
    icon: <BookOpen className="h-8 w-8" />,
    color: '#FF8B6A', // Coral
    lightColor: '#FFE7E1',
  },
]

interface OnboardingCarouselProps {
  onComplete: () => void
  onSkip?: () => void
}

/**
 * 3D Floating Card Stack Onboarding
 * Unique card-based interaction with depth and perspective
 */
export function OnboardingCarousel({ onComplete, onSkip }: OnboardingCarouselProps) {
  const [currentIndex, setCurrentIndex] = useState(0)
  const [direction, setDirection] = useState(0)
  const [completedCards, setCompletedCards] = useState<number[]>([])
  const dragY = useMotionValue(0)
  const dragOpacity = useTransform(dragY, [-200, 0, 200], [0.5, 1, 0.5])

  const currentSlide = slides[currentIndex]
  const isLastSlide = currentIndex === slides.length - 1
  const allCompleted = completedCards.length === slides.length

  const handleNext = useCallback(() => {
    if (!completedCards.includes(currentIndex)) {
      setCompletedCards(prev => [...prev, currentIndex])
    }

    if (isLastSlide) {
      if (allCompleted || completedCards.length === slides.length - 1) {
        onComplete()
      }
    } else {
      setDirection(1)
      setCurrentIndex(prev => prev + 1)
    }
  }, [currentIndex, isLastSlide, completedCards, allCompleted, onComplete])

  const handlePrevious = useCallback(() => {
    if (currentIndex > 0) {
      setDirection(-1)
      setCurrentIndex(prev => prev - 1)
    }
  }, [currentIndex])

  const handleSkip = useCallback(() => {
    onSkip?.() ?? onComplete()
  }, [onSkip, onComplete])

  const handleDragEnd = useCallback(
    (_: MouseEvent | TouchEvent | PointerEvent, info: PanInfo) => {
      const threshold = 50
      if (info.offset.y < -threshold && !isLastSlide) {
        handleNext()
      } else if (info.offset.y > threshold && currentIndex > 0) {
        handlePrevious()
      }
    },
    [handleNext, handlePrevious, currentIndex, isLastSlide]
  )

  const cardVariants = {
    enter: (direction: number) => ({
      y: direction > 0 ? 400 : -400,
      opacity: 0,
    }),
    center: {
      y: 0,
      opacity: 1,
    },
    exit: (direction: number) => ({
      y: direction < 0 ? 400 : -400,
      opacity: 0,
    }),
  }

  return (
    <div className="relative h-screen w-full bg-white overflow-hidden flex flex-col">
      {/* Subtle Moving Gradients */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <motion.div
          className="absolute w-96 h-96 rounded-full opacity-30 blur-3xl"
          style={{ backgroundColor: `${currentSlide.color}20` }}
          animate={{
            x: ['-20%', '120%', '-20%'],
            y: ['0%', '80%', '0%'],
          }}
          transition={{
            duration: 20,
            repeat: Infinity,
            ease: 'linear',
          }}
        />
        <motion.div
          className="absolute w-96 h-96 rounded-full opacity-20 blur-3xl"
          style={{ backgroundColor: `${currentSlide.color}15` }}
          animate={{
            x: ['120%', '-20%', '120%'],
            y: ['80%', '0%', '80%'],
          }}
          transition={{
            duration: 25,
            repeat: Infinity,
            ease: 'linear',
            delay: 5,
          }}
        />
      </div>

      {/* Top Bar - Fixed */}
      <div className="relative z-50 flex items-center justify-between px-6 py-5 bg-white/80 backdrop-blur-sm border-b border-slate-200">
        {/* Logo */}
        <div className="flex items-center gap-2.5">
          <div
            className="w-9 h-9 rounded-xl flex items-center justify-center shadow-sm"
            style={{ backgroundColor: currentSlide.color }}
          >
            <span className="text-sm font-bold text-white">AX</span>
          </div>
          <span className="font-semibold text-base text-slate-900">AssignX</span>
        </div>

        {/* Skip Button - Made explicitly clickable */}
        <button
          onClick={handleSkip}
          className="flex items-center gap-1 px-3 py-1.5 text-sm font-medium text-slate-600 hover:text-slate-900 hover:bg-slate-100 rounded-lg transition-colors cursor-pointer"
          type="button"
        >
          <span>Skip</span>
          <X className="h-4 w-4" />
        </button>
      </div>

      {/* Main 3D Card Stack Area */}
      <div className="flex-1 relative flex items-center justify-center px-6 py-8">
        {/* Active Card */}
        <AnimatePresence mode="wait" custom={direction}>
          <motion.div
            key={currentIndex}
            custom={direction}
            variants={cardVariants}
            initial="enter"
            animate="center"
            exit="exit"
            transition={{
              y: { type: 'spring' as const, stiffness: 300, damping: 30 },
              opacity: { duration: 0.3 },
            }}
            drag="y"
            dragConstraints={{ top: 0, bottom: 0 }}
            dragElastic={0.2}
            onDragEnd={handleDragEnd}
            style={{
              y: dragY,
              opacity: dragOpacity,
            }}
            className="relative w-full max-w-sm cursor-grab active:cursor-grabbing"
          >
            <motion.div
              className="rounded-3xl p-10 shadow-2xl border-2 bg-white relative overflow-hidden"
              style={{
                borderColor: currentSlide.color,
              }}
              whileHover={{ scale: 1.02 }}
              transition={{ duration: 0.2 }}
            >
              {/* Completed Indicator */}
              <AnimatePresence>
                {completedCards.includes(currentIndex) && (
                  <motion.div
                    initial={{ scale: 0, opacity: 0 }}
                    animate={{ scale: 1, opacity: 1 }}
                    exit={{ scale: 0, opacity: 0 }}
                    className="absolute top-4 right-4 w-8 h-8 rounded-full flex items-center justify-center shadow-lg"
                    style={{ backgroundColor: currentSlide.color }}
                  >
                    <Check className="h-5 w-5 text-white" />
                  </motion.div>
                )}
              </AnimatePresence>

              {/* Icon */}
              <motion.div
                className="mb-6 flex items-center justify-center w-20 h-20 rounded-2xl shadow-lg mx-auto"
                style={{ backgroundColor: currentSlide.color }}
                initial={{ scale: 0, rotate: -180 }}
                animate={{ scale: 1, rotate: 0 }}
                transition={{ delay: 0.2, type: 'spring' as const, stiffness: 200 }}
              >
                <div className="text-white">{currentSlide.icon}</div>
              </motion.div>

              {/* Title */}
              <motion.h2
                className="text-2xl font-bold text-slate-900 text-center mb-3"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.3 }}
              >
                {currentSlide.title}
              </motion.h2>

              {/* Description */}
              <motion.p
                className="text-slate-600 text-center leading-relaxed text-sm"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.4 }}
              >
                {currentSlide.description}
              </motion.p>

              {/* Swipe Indicator */}
              <motion.div
                className="mt-6 flex items-center justify-center gap-2 text-xs text-slate-400"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.6 }}
              >
                <div className="w-1 h-1 rounded-full bg-slate-400" />
                <span>Swipe or tap to continue</span>
                <div className="w-1 h-1 rounded-full bg-slate-400" />
              </motion.div>
            </motion.div>
          </motion.div>
        </AnimatePresence>
      </div>

      {/* Bottom Section */}
      <div className="relative z-50 px-6 pb-8 bg-white/80 backdrop-blur-sm">
        {/* Progress Dots */}
        <div className="flex justify-center gap-2 mb-6">
          {slides.map((slide, index) => (
            <button
              key={slide.id}
              onClick={() => {
                setDirection(index > currentIndex ? 1 : -1)
                setCurrentIndex(index)
              }}
              className="relative group"
              aria-label={`Go to card ${index + 1}`}
            >
              {/* Completed ring */}
              {completedCards.includes(index) && (
                <motion.div
                  className="absolute inset-0 rounded-full border-2"
                  style={{ borderColor: slide.color }}
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  transition={{ type: 'spring' as const }}
                />
              )}

              {/* Dot */}
              <motion.div
                className={cn(
                  'w-2 h-2 rounded-full transition-all duration-300',
                  index === currentIndex ? 'w-8' : 'group-hover:w-4'
                )}
                style={{
                  backgroundColor: index === currentIndex ? slide.color : '#CBD5E1',
                }}
                animate={{
                  scale: index === currentIndex ? 1.2 : 1,
                }}
              />
            </button>
          ))}
        </div>

        {/* Action Buttons */}
        <div className="flex gap-3 max-w-sm mx-auto">
          {currentIndex > 0 && (
            <Button
              onClick={handlePrevious}
              variant="outline"
              className="flex-1 border-slate-300 text-slate-700 hover:bg-slate-50"
            >
              Previous
            </Button>
          )}

          <Button
            onClick={handleNext}
            className="flex-1 text-white shadow-lg border-0 font-medium"
            style={{ backgroundColor: currentSlide.color }}
          >
            {isLastSlide ? 'Get Started' : 'Next'}
          </Button>
        </div>

        {/* Counter */}
        <p className="text-center text-xs text-slate-500 mt-4">
          {currentIndex + 1} of {slides.length}
        </p>
      </div>

      {/* Completion Progress Bar */}
      <motion.div
        className="absolute bottom-0 left-0 h-1 bg-teal-500"
        initial={{ width: 0 }}
        animate={{ width: `${(completedCards.length / slides.length) * 100}%` }}
        transition={{ duration: 0.5 }}
      />
    </div>
  )
}
