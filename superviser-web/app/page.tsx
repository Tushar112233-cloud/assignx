/**
 * @fileoverview Splash screen page displaying animated logo and tagline before redirecting to login.
 * @module app/page
 */

"use client"

import { useEffect, useMemo, useState } from "react"
import { useRouter } from "next/navigation"
import { motion } from "framer-motion"
import { APP_NAME, APP_TAGLINE } from "@/lib/constants"
import { createClient } from "@/lib/supabase/client"

export default function SplashPage() {
  const router = useRouter()
  const supabase = useMemo(() => createClient(), [])
  const [showTagline, setShowTagline] = useState(false)

  useEffect(() => {
    // Show tagline after logo animation
    const taglineTimer = setTimeout(() => {
      setShowTagline(true)
    }, 800)

    // Check auth state and navigate accordingly
    const navigationTimer = setTimeout(async () => {
      try {
        // Use getSession() which reads from localStorage (no network request)
        // Server-side layout and middleware will validate the session properly
        const { data: { session } } = await supabase.auth.getSession()
        if (session?.user) {
          router.push("/dashboard")
        } else {
          router.push("/login")
        }
      } catch {
        router.push("/login")
      }
    }, 2500)

    return () => {
      clearTimeout(taglineTimer)
      clearTimeout(navigationTimer)
    }
  }, [router])

  return (
    <div className="min-h-screen bg-[#1E3A5F] flex flex-col items-center justify-center">
      <motion.div
        initial={{ opacity: 0, scale: 0.8 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.6, ease: "easeOut" }}
        className="text-center"
      >
        {/* Logo */}
        <motion.div
          initial={{ y: -20 }}
          animate={{ y: 0 }}
          transition={{ duration: 0.5, delay: 0.2 }}
          className="mb-6"
        >
          <div className="w-24 h-24 mx-auto bg-white rounded-2xl flex items-center justify-center shadow-2xl">
            <span className="text-4xl font-bold text-[#1E3A5F]">AX</span>
          </div>
        </motion.div>

        {/* App Name */}
        <motion.h1
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.5, delay: 0.4 }}
          className="text-4xl font-bold text-white mb-4"
        >
          {APP_NAME}
        </motion.h1>

        {/* Tagline */}
        <motion.p
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: showTagline ? 1 : 0, y: showTagline ? 0 : 10 }}
          transition={{ duration: 0.5 }}
          className="text-lg text-slate-300 tracking-wide"
        >
          {APP_TAGLINE}
        </motion.p>
      </motion.div>

      {/* Loading indicator */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1.5 }}
        className="absolute bottom-12"
      >
        <div className="flex space-x-2">
          {[0, 1, 2].map((i) => (
            <motion.div
              key={i}
              className="w-2 h-2 bg-white/60 rounded-full"
              animate={{
                scale: [1, 1.5, 1],
                opacity: [0.6, 1, 0.6],
              }}
              transition={{
                duration: 0.8,
                repeat: Infinity,
                delay: i * 0.2,
              }}
            />
          ))}
        </div>
      </motion.div>
    </div>
  )
}
