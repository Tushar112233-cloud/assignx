"use client"

/**
 * GreetingHeader - Personalized animated greeting with time-based messages
 * Features wave animation, typing effect, and contextual greetings
 */

import * as React from "react"
import { motion } from "framer-motion"

import { cn } from "@/lib/utils"
import { fadeInUp, staggerContainer, staggerItem, springs } from "@/lib/animations/variants"
import { WalletPill } from "./wallet-pill"

interface GreetingHeaderProps {
  /** User's display name */
  userName: string
  /** User's avatar URL */
  avatarUrl?: string
  /** Show wallet pill */
  showWallet?: boolean
  /** Custom className */
  className?: string
}

/**
 * Get time-based greeting and emoji
 */
function getGreeting(): { text: string; emoji: string } {
  const hour = new Date().getHours()

  if (hour >= 5 && hour < 12) {
    return { text: "Good morning", emoji: "☀️" }
  } else if (hour >= 12 && hour < 17) {
    return { text: "Good afternoon", emoji: "🌤️" }
  } else if (hour >= 17 && hour < 21) {
    return { text: "Good evening", emoji: "🌅" }
  } else {
    return { text: "Good night", emoji: "🌙" }
  }
}

/**
 * Get motivational subtitle based on time/context
 */
function getSubtitle(): string {
  const hour = new Date().getHours()
  const day = new Date().getDay()

  // Weekend
  if (day === 0 || day === 6) {
    return "Taking the weekend to work on projects? That's dedication!"
  }

  // Time-based messages
  if (hour >= 5 && hour < 9) {
    return "Early bird catches the worm. Ready to be productive?"
  } else if (hour >= 9 && hour < 12) {
    return "Peak productivity hours! Let's make them count."
  } else if (hour >= 12 && hour < 14) {
    return "Hope you had a great lunch. Ready to continue?"
  } else if (hour >= 14 && hour < 17) {
    return "Afternoon grind. You're doing great!"
  } else if (hour >= 17 && hour < 21) {
    return "Wrapping up for the day? Let's finish strong."
  } else {
    return "Burning the midnight oil? Don't forget to rest!"
  }
}

export function GreetingHeader({
  userName,
  avatarUrl,
  showWallet = true,
  className,
}: GreetingHeaderProps) {
  const { text: greeting, emoji } = getGreeting()
  const subtitle = getSubtitle()
  const firstName = userName.split(" ")[0]

  return (
    <motion.div
      className={cn("flex items-start justify-between gap-4", className)}
      variants={staggerContainer}
      initial="hidden"
      animate="visible"
    >
      {/* Left: Greeting */}
      <div className="flex-1 min-w-0">
        <motion.div
          className="flex items-center gap-2 mb-1"
          variants={staggerItem}
        >
          <motion.h1
            className="text-2xl md:text-3xl font-bold text-foreground truncate"
          >
            {greeting}, {firstName}
          </motion.h1>

          {/* Animated waving emoji */}
          <motion.span
            className="text-2xl md:text-3xl"
            animate={{
              rotate: [0, 14, -8, 14, -4, 10, 0],
            }}
            transition={{
              duration: 2.5,
              ease: "easeInOut",
              repeat: Infinity,
              repeatDelay: 3,
            }}
            style={{ transformOrigin: "70% 70%" }}
          >
            {emoji}
          </motion.span>
        </motion.div>

        <motion.p
          className="text-sm md:text-base text-muted-foreground"
          variants={staggerItem}
        >
          {subtitle}
        </motion.p>
      </div>

      {/* Right: Wallet Pill - fetches its own balance from store */}
      {showWallet && (
        <motion.div
          variants={fadeInUp}
          className="shrink-0"
        >
          <WalletPill />
        </motion.div>
      )}
    </motion.div>
  )
}

/**
 * Compact greeting for mobile or secondary pages
 */
export function CompactGreeting({
  userName,
  className,
}: {
  userName: string
  className?: string
}) {
  const { emoji } = getGreeting()
  const firstName = userName.split(" ")[0]

  return (
    <motion.div
      className={cn("flex items-center gap-2", className)}
      initial={{ opacity: 0, y: -10 }}
      animate={{ opacity: 1, y: 0 }}
      transition={springs.gentle}
    >
      <motion.span
        className="text-lg"
        animate={{ rotate: [0, 14, -8, 14, 0] }}
        transition={{ duration: 1.5, delay: 0.5 }}
        style={{ transformOrigin: "70% 70%" }}
      >
        {emoji}
      </motion.span>
      <span className="text-sm font-medium">
        Hey, {firstName}
      </span>
    </motion.div>
  )
}
