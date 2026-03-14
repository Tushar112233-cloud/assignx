/**
 * @fileoverview How It Works — Dolancer Landing
 *
 * Three-step process with Lottie animations and alternating layout.
 * Steps: Browse Task Pool → Accept & Deliver → Get Paid Fast
 */
"use client"

import { useRef, useState, useEffect, Suspense } from "react"
import dynamic from "next/dynamic"
import { motion, useReducedMotion, useInView } from "framer-motion"
import { Search, CheckCircle2, BanknoteIcon, ArrowRight } from "lucide-react"
import { cn } from "@/lib/utils"
import { DOER_EASE } from "@/lib/animations/constants"
import "@/app/landing.css"

// Lazy-load Lottie to prevent SSR issues
const Lottie = dynamic(() => import("lottie-react"), { ssr: false })

const steps = [
  {
    number: "01",
    Icon: Search,
    title: "Browse Task Pool",
    description:
      "See all available tasks filtered by your subject area. Each task shows the payout, deadline, and requirements — no guesswork.",
    lottieFile: "/lottie/browse-tasks.json",
    bgColor: "bg-blue-50 dark:bg-blue-950/20",
    iconBg: "bg-blue-100 dark:bg-blue-900/30",
    iconColor: "text-blue-600 dark:text-blue-400",
    watermarkColor: "text-blue-600",
  },
  {
    number: "02",
    Icon: CheckCircle2,
    title: "Accept & Deliver",
    description:
      "Pick tasks that match your skills. Work on your own schedule, submit when ready. Your supervisor reviews and gives feedback.",
    lottieFile: "/lottie/complete-work.json",
    bgColor: "bg-indigo-50 dark:bg-indigo-950/20",
    iconBg: "bg-indigo-100 dark:bg-indigo-900/30",
    iconColor: "text-indigo-600 dark:text-indigo-400",
    watermarkColor: "text-indigo-600",
  },
  {
    number: "03",
    Icon: BanknoteIcon,
    title: "Get Paid Fast",
    description:
      "Payment released within 48 hours of approval. No waiting, no disputes. Build your rating and unlock higher-value tasks.",
    lottieFile: "/lottie/get-paid.json",
    bgColor: "bg-violet-50 dark:bg-violet-950/20",
    iconBg: "bg-violet-100 dark:bg-violet-900/30",
    iconColor: "text-violet-600 dark:text-violet-400",
    watermarkColor: "text-violet-600",
  },
]

type Step = (typeof steps)[0]

/** Lottie player that fetches and renders animation data */
function LottiePlayer({ src }: { src: string }) {
  const [animationData, setAnimationData] = useState<object | null>(null)

  useEffect(() => {
    fetch(src)
      .then((r) => r.json())
      .then(setAnimationData)
      .catch(() => {
        // Silently fail — the fallback UI will show
      })
  }, [src])

  if (!animationData) {
    return (
      <div className="w-40 h-40 rounded-2xl bg-white/30 animate-pulse" />
    )
  }

  return (
    <Lottie
      animationData={animationData}
      loop
      autoplay
      style={{ width: 200, height: 200 }}
    />
  )
}

/** Individual step card with alternating layout */
function StepCard({
  step,
  index,
}: {
  step: Step
  index: number
}) {
  const ref = useRef<HTMLDivElement>(null)
  const isInView = useInView(ref, { once: true, amount: 0.3 })
  const prefersReducedMotion = useReducedMotion()
  const isReversed = index % 2 !== 0
  const { Icon } = step

  return (
    <motion.div
      ref={ref}
      initial={prefersReducedMotion ? false : { opacity: 0, y: 40 }}
      animate={isInView ? { opacity: 1, y: 0 } : {}}
      transition={{ delay: index * 0.1, duration: 0.7, ease: DOER_EASE }}
      className={cn(
        "grid grid-cols-1 lg:grid-cols-2 gap-10 lg:gap-16 items-center",
        isReversed && "lg:[direction:rtl]"
      )}
    >
      {/* Text column */}
      <div className={cn(isReversed && "lg:[direction:ltr]")}>
        <div className="flex items-center gap-3 mb-4">
          <div
            className={cn(
              "w-10 h-10 rounded-xl flex items-center justify-center",
              step.iconBg
            )}
          >
            <Icon className={cn("w-5 h-5", step.iconColor)} />
          </div>
          <span className="text-xs font-bold tracking-widest text-[var(--landing-text-muted)] uppercase">
            Step {step.number}
          </span>
        </div>

        <h3 className="landing-heading-md text-[var(--landing-text-primary)] mb-4">
          {step.title}
        </h3>
        <p className="text-base text-[var(--landing-text-secondary)] leading-relaxed mb-6">
          {step.description}
        </p>

        {/* "Then" pointer to next step */}
        {index < steps.length - 1 && (
          <div className="flex items-center gap-2 text-sm font-medium text-[var(--landing-accent-primary)]">
            <span>Then</span>
            <ArrowRight className="w-4 h-4" />
            <span>{steps[index + 1].title}</span>
          </div>
        )}
      </div>

      {/* Lottie illustration column */}
      <div
        className={cn(
          "relative flex items-center justify-center rounded-3xl p-8 min-h-[280px]",
          step.bgColor,
          "border border-[var(--landing-border)]",
          isReversed && "lg:[direction:ltr]"
        )}
      >
        <Suspense
          fallback={
            <div className="w-48 h-48 rounded-2xl bg-white/30 animate-pulse" />
          }
        >
          <LottiePlayer src={step.lottieFile} />
        </Suspense>

        {/* Step number watermark */}
        <div
          className={cn(
            "absolute bottom-4 right-6 text-6xl font-black opacity-10 select-none",
            step.watermarkColor
          )}
        >
          {step.number}
        </div>
      </div>
    </motion.div>
  )
}

/** How It Works section */
export function HowItWorks() {
  const sectionRef = useRef<HTMLElement>(null)
  const isInView = useInView(sectionRef, { once: true, amount: 0.1 })
  const prefersReducedMotion = useReducedMotion()

  return (
    <section
      ref={sectionRef}
      id="how-it-works"
      className="relative py-24 md:py-32 overflow-hidden"
      style={{ background: "var(--landing-bg-secondary)" }}
    >
      {/* Top separator */}
      <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-[var(--landing-border)] to-transparent" />

      {/* Subtle grid */}
      <div className="absolute inset-0 landing-grid-pattern opacity-20" />

      <div className="max-w-6xl mx-auto px-4 sm:px-6 relative z-10">
        {/* Section header */}
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, ease: DOER_EASE }}
          className="text-center mb-20"
        >
          <span className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[var(--landing-accent-lighter)] border border-[var(--landing-border-teal)] mb-6">
            <motion.span
              className="w-2 h-2 rounded-full bg-[var(--landing-accent-primary)]"
              animate={{ scale: [1, 1.5, 1] }}
              transition={{ duration: 2, repeat: Infinity }}
            />
            <span className="text-sm font-medium text-[var(--landing-accent-primary)]">
              Simple Process
            </span>
          </span>
          <h2 className="landing-heading-lg text-[var(--landing-text-primary)] mb-4">
            How Dolancers{" "}
            <span className="landing-text-gradient">Earn</span>
          </h2>
          <p className="text-lg text-[var(--landing-text-secondary)] max-w-2xl mx-auto">
            Three steps to start earning with your expertise. No complicated
            setup, no lengthy approval process.
          </p>
        </motion.div>

        {/* Steps */}
        <div className="flex flex-col gap-20 md:gap-24">
          {steps.map((step, index) => (
            <StepCard key={step.number} step={step} index={index} />
          ))}
        </div>
      </div>
    </section>
  )
}
