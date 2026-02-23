"use client"

import { motion } from "framer-motion"
import { Wrench, CheckCircle2, GraduationCap } from "lucide-react"
import { ReactNode } from "react"

interface ResourcesHeroProps {
  toolsCount?: number
  checksToday?: number
  trainingProgress?: number
  children?: ReactNode
}

const stats = [
  {
    key: "tools",
    label: "Tools",
    icon: Wrench,
    getValue: (props: ResourcesHeroProps) => props.toolsCount ?? 8,
  },
  {
    key: "checks",
    label: "Checks Today",
    icon: CheckCircle2,
    getValue: (props: ResourcesHeroProps) => props.checksToday ?? 0,
  },
  {
    key: "training",
    label: "Training",
    icon: GraduationCap,
    getValue: (props: ResourcesHeroProps) => `${props.trainingProgress ?? 0}%`,
  },
]

export function ResourcesHero({
  toolsCount = 8,
  checksToday = 0,
  trainingProgress = 0,
  children,
}: ResourcesHeroProps) {
  const props = { toolsCount, checksToday, trainingProgress }

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.4 }}
      className="grid grid-cols-1 lg:grid-cols-2 gap-8 lg:gap-12 items-center"
    >
      {/* Left side - Text content */}
      <div className="space-y-6">
        <div>
          <motion.h1
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1, duration: 0.5 }}
            className="text-4xl lg:text-5xl font-bold tracking-tight text-[#1C1C1C]"
          >
            Resources & Tools
          </motion.h1>
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.15, duration: 0.5 }}
            className="text-lg text-gray-500 mt-2"
          >
            Everything you need to deliver quality work
          </motion.p>
        </div>

        {/* Stats row */}
        <div className="flex flex-wrap gap-3 mt-6">
          {stats.map((stat, index) => {
            const Icon = stat.icon
            return (
              <motion.div
                key={stat.key}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.2 + index * 0.1, duration: 0.3 }}
                className="flex items-center gap-3 px-4 py-3 bg-white rounded-2xl border border-gray-200 shadow-sm"
              >
                <div className="w-10 h-10 rounded-xl bg-orange-50 flex items-center justify-center">
                  <Icon className="h-5 w-5 text-[#F97316]" />
                </div>
                <div>
                  <div className="text-xs font-semibold uppercase tracking-[0.12em] text-gray-400">
                    {stat.label}
                  </div>
                  <div className="text-lg font-bold text-[#1C1C1C]">
                    {stat.getValue(props)}
                  </div>
                </div>
              </motion.div>
            )
          })}
        </div>
      </div>

      {/* Right side - Illustration slot */}
      <motion.div
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ delay: 0.3, duration: 0.5 }}
        className="flex items-center justify-center lg:justify-end"
      >
        {children}
      </motion.div>
    </motion.div>
  )
}

export default ResourcesHero
