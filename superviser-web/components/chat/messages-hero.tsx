"use client"

import { motion } from "framer-motion"
import { MessageSquare, ArrowRight } from "lucide-react"
import { Button } from "@/components/ui/button"
import Link from "next/link"

interface MessagesHeroProps {
  userName: string
  unreadCount: number
}

// Messages Illustration Component - Modern minimal style matching dashboard
function MessagesIllustration() {
  return (
    <svg viewBox="0 0 400 300" fill="none" xmlns="http://www.w3.org/2000/svg" className="w-full h-full">
      {/* Background circles */}
      <circle cx="200" cy="150" r="140" fill="#FFF7ED" opacity="0.3" />
      <circle cx="200" cy="150" r="100" fill="#FFEDD5" opacity="0.4" />

      {/* Main chat bubble - large */}
      <rect x="100" y="80" width="180" height="100" rx="16" fill="white" stroke="#E5E7EB" strokeWidth="2" />
      <path d="M140 180 L155 200 L170 180" fill="white" stroke="#E5E7EB" strokeWidth="2" strokeLinejoin="round" />

      {/* Chat bubble content lines */}
      <rect x="120" y="100" width="100" height="8" rx="4" fill="#F97316" opacity="0.3" />
      <rect x="120" y="118" width="140" height="8" rx="4" fill="#E5E7EB" />
      <rect x="120" y="136" width="120" height="8" rx="4" fill="#E5E7EB" />
      <rect x="120" y="154" width="80" height="8" rx="4" fill="#E5E7EB" />

      {/* Secondary chat bubble - right side */}
      <rect x="220" y="140" width="120" height="70" rx="12" fill="#F97316" />
      <path d="M300 210 L315 225 L330 210" fill="#F97316" />

      {/* Secondary bubble content */}
      <rect x="235" y="155" width="70" height="6" rx="3" fill="white" opacity="0.8" />
      <rect x="235" y="168" width="90" height="6" rx="3" fill="white" opacity="0.6" />
      <rect x="235" y="181" width="50" height="6" rx="3" fill="white" opacity="0.6" />

      {/* Person avatar - left */}
      <circle cx="70" cy="120" r="25" fill="#FCD34D" />
      <circle cx="63" cy="115" r="3" fill="#1C1C1C" />
      <circle cx="77" cy="115" r="3" fill="#1C1C1C" />
      <path d="M65 125 Q70 130 75 125" stroke="#1C1C1C" strokeWidth="2" fill="none" strokeLinecap="round" />
      {/* Hair */}
      <path d="M50 110 Q55 90 70 95 Q85 90 90 110 Q92 105 90 120 L50 120 Q48 105 50 110" fill="#1C1C1C" />

      {/* Person avatar - right */}
      <circle cx="360" cy="185" r="22" fill="#10B981" opacity="0.2" />
      <circle cx="360" cy="185" r="18" fill="#10B981" />
      <circle cx="354" cy="182" r="2.5" fill="white" />
      <circle cx="366" cy="182" r="2.5" fill="white" />
      <path d="M356 190 Q360 194 364 190" stroke="white" strokeWidth="1.5" fill="none" strokeLinecap="round" />

      {/* Notification badges */}
      <circle cx="95" cy="95" r="12" fill="#F97316" />
      <text x="95" y="99" fontSize="12" fill="white" textAnchor="middle" fontWeight="bold">3</text>

      {/* Floating message icons */}
      <rect x="300" y="60" width="50" height="35" rx="8" fill="white" stroke="#F97316" strokeWidth="2" opacity="0.9" />
      <circle cx="315" cy="73" r="4" fill="#F97316" />
      <line x1="325" y1="70" x2="340" y2="70" stroke="#E5E7EB" strokeWidth="2" strokeLinecap="round" />
      <line x1="325" y1="78" x2="335" y2="78" stroke="#E5E7EB" strokeWidth="2" strokeLinecap="round" />

      {/* Small floating bubble */}
      <rect x="50" y="170" width="40" height="28" rx="6" fill="#FFEDD5" />
      <rect x="58" y="178" width="24" height="4" rx="2" fill="#F97316" opacity="0.5" />
      <rect x="58" y="186" width="16" height="4" rx="2" fill="#F97316" opacity="0.3" />

      {/* Decorative dots */}
      <circle cx="45" cy="80" r="5" fill="#FDBA74" opacity="0.6" />
      <circle cx="355" cy="250" r="7" fill="#FED7AA" opacity="0.5" />
      <circle cx="320" cy="120" r="4" fill="#FEF3C7" opacity="0.7" />
      <circle cx="130" cy="220" r="6" fill="#FDBA74" opacity="0.4" />

      {/* Connection lines */}
      <path d="M95 120 L100 120" stroke="#E5E7EB" strokeWidth="2" strokeDasharray="4 4" />
      <path d="M340 185 L338 185" stroke="#E5E7EB" strokeWidth="2" strokeDasharray="4 4" />
    </svg>
  )
}

export function MessagesHero({ userName, unreadCount }: MessagesHeroProps) {
  const firstName = userName?.split(" ")[0] || "there"

  const getSubtitle = () => {
    if (unreadCount === 0) {
      return "All caught up! No unread messages at the moment"
    }
    if (unreadCount === 1) {
      return "You have 1 unread message waiting for you"
    }
    return `You have ${unreadCount} unread messages waiting for you`
  }

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: 0.1, duration: 0.5 }}
      className="flex flex-col lg:flex-row items-center justify-between gap-8 mb-8"
    >
      {/* Left - Greeting */}
      <div className="flex-1 space-y-4">
        <div>
          <h1 className="text-4xl lg:text-5xl font-bold text-[#1C1C1C] tracking-tight">
            Hi {firstName},
          </h1>
          <p className="text-lg text-gray-500 mt-2">
            {getSubtitle()}
          </p>
        </div>
        <Link href="/messages">
          <Button className="bg-[#F97316] hover:bg-[#EA580C] text-white rounded-full px-6 h-11 font-medium shadow-lg shadow-orange-500/20 hover:shadow-xl hover:shadow-orange-500/30 hover:-translate-y-0.5 active:translate-y-0 transition-all duration-200">
            <MessageSquare className="mr-2 h-4 w-4" />
            View Messages
            <ArrowRight className="ml-2 h-4 w-4" />
          </Button>
        </Link>
      </div>

      {/* Right - Illustration */}
      <motion.div
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ delay: 0.2, duration: 0.5 }}
        className="w-[280px] h-[210px] lg:w-[320px] lg:h-[240px]"
      >
        <MessagesIllustration />
      </motion.div>
    </motion.div>
  )
}

export default MessagesHero
