"use client"

import { motion } from "framer-motion"

interface DataPoint {
  month: string
  value: number
}

interface UserGrowthChartProps {
  data: DataPoint[]
}

export function UserGrowthChart({ data }: UserGrowthChartProps) {
  // Calculate SVG path from data points
  const maxValue = Math.max(...data.map((d) => d.value))
  const minValue = Math.min(...data.map((d) => d.value))
  const range = maxValue - minValue || 1

  // Generate path coordinates (viewBox is 300x120)
  const points = data.map((point, index) => {
    const x = (index / (data.length - 1)) * 300
    const y = 100 - ((point.value - minValue) / range) * 80 // Leave space for top/bottom margins
    return { x, y, value: point.value }
  })

  // Create SVG path string
  const linePath = points.map((p, i) => `${i === 0 ? 'M' : 'L'} ${p.x} ${p.y}`).join(' ')

  // Create area path (fill under line)
  const areaPath = `${linePath} L ${points[points.length - 1].x} 120 L 0 120 Z`

  return (
    <div className="relative w-full h-[140px]">
      <svg
        viewBox="0 0 300 120"
        className="w-full h-full"
        preserveAspectRatio="none"
      >
        <defs>
          <linearGradient id="userGrowthGradient" x1="0%" y1="0%" x2="0%" y2="100%">
            <stop offset="0%" stopColor="#F97316" stopOpacity="0.3" />
            <stop offset="100%" stopColor="#F97316" stopOpacity="0" />
          </linearGradient>
        </defs>

        {/* Grid lines */}
        <line x1="0" y1="30" x2="300" y2="30" stroke="#E5E7EB" strokeWidth="1" opacity="0.5" />
        <line x1="0" y1="60" x2="300" y2="60" stroke="#E5E7EB" strokeWidth="1" opacity="0.5" />
        <line x1="0" y1="90" x2="300" y2="90" stroke="#E5E7EB" strokeWidth="1" opacity="0.5" />

        {/* Area fill with gradient */}
        <motion.path
          d={areaPath}
          fill="url(#userGrowthGradient)"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.6, delay: 0.2 }}
        />

        {/* Main line path */}
        <motion.path
          d={linePath}
          stroke="#F97316"
          strokeWidth="2.5"
          fill="none"
          strokeLinecap="round"
          strokeLinejoin="round"
          initial={{ pathLength: 0 }}
          animate={{ pathLength: 1 }}
          transition={{ duration: 1, ease: "easeInOut" }}
        />

        {/* Data points */}
        {points.map((point, index) => (
          <motion.circle
            key={index}
            cx={point.x}
            cy={point.y}
            r="4"
            fill="#F97316"
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ duration: 0.3, delay: 0.8 + index * 0.1 }}
          />
        ))}
      </svg>

      {/* Month labels */}
      <div className="absolute bottom-0 left-0 right-0 flex justify-between px-2 text-[10px] text-gray-400 font-medium">
        {data.map((point, index) => (
          <span key={index} className="transform -translate-x-1/2">
            {point.month}
          </span>
        ))}
      </div>
    </div>
  )
}
