/**
 * @fileoverview Doer Landing Navigation
 *
 * Floating pill nav on scroll, teal-branded, with "Start Earning" CTA.
 * Transparent at top, becomes dark floating pill when scrolled > 80px.
 */
"use client"

import { useState, useEffect } from "react"
import { motion, AnimatePresence, useReducedMotion } from "framer-motion"
import Link from "next/link"
import { Menu, X, Briefcase, LayoutDashboard } from "lucide-react"
import { cn } from "@/lib/utils"
import { getAccessToken } from "@/lib/api/client"
import "@/app/landing.css"

const navLinks = [
  { label: "How It Works", href: "#how-it-works" },
  { label: "Benefits", href: "#benefits" },
  { label: "Earnings", href: "#earnings" },
  { label: "Testimonials", href: "#testimonials" },
]

/**
 * Navigation bar for the Doer landing page.
 * Transitions from transparent to a floating dark pill on scroll.
 */
export function Navigation() {
  const [scrolled, setScrolled] = useState(false)
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)
  const [isLoggedIn, setIsLoggedIn] = useState(false)
  const prefersReducedMotion = useReducedMotion()

  useEffect(() => {
    const token = getAccessToken()
    setIsLoggedIn(!!token)
  }, [])

  useEffect(() => {
    const handleScroll = () => setScrolled(window.scrollY > 80)
    window.addEventListener("scroll", handleScroll, { passive: true })
    handleScroll()
    return () => window.removeEventListener("scroll", handleScroll)
  }, [])

  return (
    <>
      {/* Spacer so content doesn't hide behind fixed nav */}
      <div className="h-16" />

      <motion.nav
        initial={prefersReducedMotion ? {} : { y: -100, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ type: "spring", stiffness: 100, damping: 20, delay: 0.1 }}
        className={cn(
          "fixed left-1/2 -translate-x-1/2 z-50 transition-all duration-500 ease-[cubic-bezier(0.16,1,0.3,1)]",
          scrolled
            ? "top-4 bg-[var(--landing-bg-dark)]/90 backdrop-blur-2xl border border-white/10 shadow-2xl shadow-black/25 rounded-full w-[92%] max-w-2xl"
            : "top-3 w-full max-w-7xl bg-transparent border border-transparent"
        )}
      >
        <div className="flex items-center h-14 px-4 sm:px-6 justify-between">
          {/* Logo */}
          <Link href="/" className="flex-shrink-0">
            <motion.div
              className="flex items-center gap-2"
              whileHover={prefersReducedMotion ? {} : { scale: 1.02 }}
              whileTap={prefersReducedMotion ? {} : { scale: 0.98 }}
            >
              <div className="w-8 h-8 rounded-lg bg-[var(--landing-accent-primary)] flex items-center justify-center">
                <Briefcase className="w-4 h-4 text-white" />
              </div>
              <span
                className={cn(
                  "font-bold text-lg tracking-tight transition-colors duration-300",
                  scrolled
                    ? "text-white"
                    : "text-[var(--landing-text-primary)]"
                )}
              >
                Dolancer
              </span>
            </motion.div>
          </Link>

          {/* Desktop nav links — hidden in capsule mode */}
          {!scrolled && (
            <div className="hidden md:flex items-center gap-1">
              {navLinks.map((link) => (
                <a
                  key={link.label}
                  href={link.href}
                  className="px-3 py-1.5 rounded-lg text-sm font-medium transition-colors duration-200 text-[var(--landing-text-secondary)] hover:text-[var(--landing-text-primary)] hover:bg-[var(--landing-accent-lighter)]"
                >
                  {link.label}
                </a>
              ))}
            </div>
          )}

          {/* CTA buttons */}
          <div className="hidden md:flex items-center gap-2">
            {isLoggedIn ? (
              <Link
                href="/dashboard"
                className={cn(
                  "flex items-center gap-1.5 px-4 py-2 rounded-full text-sm font-medium transition-all duration-200",
                  "bg-[var(--landing-accent-primary)] text-white hover:bg-[var(--landing-accent-primary-hover)]"
                )}
              >
                <LayoutDashboard className="w-3.5 h-3.5" />
                Dashboard
              </Link>
            ) : (
              <>
                <Link
                  href="/login"
                  className={cn(
                    "px-4 py-2 rounded-full text-sm font-medium transition-colors duration-200",
                    scrolled
                      ? "text-white/70 hover:text-white"
                      : "text-[var(--landing-text-secondary)] hover:text-[var(--landing-text-primary)]"
                  )}
                >
                  Sign In
                </Link>
                <Link
                  href="/register"
                  className="flex items-center gap-1.5 px-4 py-2 rounded-full text-sm font-semibold bg-[var(--landing-accent-primary)] text-white hover:bg-[var(--landing-accent-primary-hover)] transition-all duration-200 shadow-sm"
                >
                  Start Earning
                </Link>
              </>
            )}
          </div>

          {/* Mobile menu button */}
          <button
            className={cn(
              "md:hidden p-2 rounded-lg transition-colors duration-200",
              scrolled
                ? "text-white hover:bg-white/10"
                : "text-[var(--landing-text-primary)] hover:bg-[var(--landing-accent-lighter)]"
            )}
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            aria-label="Toggle navigation menu"
          >
            {mobileMenuOpen ? (
              <X className="w-5 h-5" />
            ) : (
              <Menu className="w-5 h-5" />
            )}
          </button>
        </div>

        {/* Mobile menu dropdown */}
        <AnimatePresence>
          {mobileMenuOpen && (
            <motion.div
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: "auto" }}
              exit={{ opacity: 0, height: 0 }}
              transition={{ duration: 0.2 }}
              className="md:hidden overflow-hidden border-t border-white/10"
            >
              <div className="px-4 py-4 flex flex-col gap-2">
                {navLinks.map((link) => (
                  <a
                    key={link.label}
                    href={link.href}
                    onClick={() => setMobileMenuOpen(false)}
                    className="px-3 py-2 rounded-lg text-sm font-medium text-white/70 hover:text-white hover:bg-white/10 transition-colors duration-200"
                  >
                    {link.label}
                  </a>
                ))}
                <div className="flex gap-2 mt-2 pt-2 border-t border-white/10">
                  <Link
                    href="/login"
                    className="flex-1 text-center py-2 text-sm text-white/70 hover:text-white transition-colors duration-200"
                    onClick={() => setMobileMenuOpen(false)}
                  >
                    Sign In
                  </Link>
                  <Link
                    href="/register"
                    className="flex-1 text-center py-2 rounded-full text-sm font-semibold bg-[var(--landing-accent-primary)] text-white hover:bg-[var(--landing-accent-primary-hover)] transition-colors duration-200"
                    onClick={() => setMobileMenuOpen(false)}
                  >
                    Start Earning
                  </Link>
                </div>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.nav>
    </>
  )
}
