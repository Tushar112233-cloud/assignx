/**
 * @fileoverview Resources Page Hero Section
 * Matches dashboard design system with custom illustration
 * @module components/resources/hero-section
 */

"use client"

import { motion } from "framer-motion"
import { BookOpen, CheckCircle, DollarSign, Clock } from "lucide-react"
import { ResourcesIllustration } from "./resources-illustration"
import { cn } from "@/lib/utils"

interface StatPillProps {
  icon: React.ComponentType<{ className?: string }>
  label: string
  value: string | number
  delay?: number
}

function StatPill({ icon: Icon, label, value, delay = 0 }: StatPillProps) {
  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.9 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ delay, duration: 0.3 }}
      className="inline-flex items-center gap-2 px-4 py-2 bg-white rounded-xl border border-gray-200 hover:border-orange-200 hover:shadow-md transition-all duration-200"
    >
      <div className="w-8 h-8 rounded-lg bg-orange-100 flex items-center justify-center">
        <Icon className="h-4 w-4 text-orange-600" />
      </div>
      <div className="text-left">
        <p className="text-xs text-gray-500 leading-none">{label}</p>
        <p className="text-sm font-bold text-[#1C1C1C] leading-none mt-0.5">{value}</p>
      </div>
    </motion.div>
  )
}

export function HeroSection() {
  const stats = [
    { icon: BookOpen, label: "Tools Used", value: "12", delay: 0.2 },
    { icon: CheckCircle, label: "Quality Checks", value: "156", delay: 0.25 },
    { icon: DollarSign, label: "Price Quotes", value: "89", delay: 0.3 },
    { icon: Clock, label: "Training Hours", value: "24", delay: 0.35 },
  ]

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: 0.1, duration: 0.5 }}
      className="flex flex-col lg:flex-row items-center justify-between gap-8 mb-8"
    >
      {/* Left - Title and Stats */}
      <div className="flex-1 space-y-6">
        <div>
          <motion.h1
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.15, duration: 0.4 }}
            className="text-4xl lg:text-5xl font-bold text-[#1C1C1C] tracking-tight"
          >
            Resources & Tools
          </motion.h1>
          <motion.p
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2, duration: 0.4 }}
            className="text-lg text-gray-500 mt-2"
          >
            Everything you need to manage projects efficiently
          </motion.p>
        </div>

        {/* Stats Pills - Inline compact layout */}
        <div className="flex flex-wrap gap-3">
          {stats.map((stat) => (
            <StatPill
              key={stat.label}
              icon={stat.icon}
              label={stat.label}
              value={stat.value}
              delay={stat.delay}
            />
          ))}
        </div>
      </div>

      {/* Right - Illustration */}
      <motion.div
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ delay: 0.2, duration: 0.5 }}
        className="w-[280px] h-[210px] lg:w-[320px] lg:h-[240px]"
      >
        <ResourcesIllustration />
      </motion.div>
    </motion.div>
  )
}
