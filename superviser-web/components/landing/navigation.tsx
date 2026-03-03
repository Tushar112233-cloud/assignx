/**
 * @fileoverview Supervisor Landing Navigation
 *
 * Transparent on top. On scroll → floating dark pill with blur.
 * Nav links hidden in pill state. Always shows Sign In + Apply Now.
 */
"use client"

import { useState, useEffect } from "react"
import { motion, AnimatePresence, useReducedMotion } from "framer-motion"
import Link from "next/link"
import { Menu, X, ShieldCheck, LayoutDashboard } from "lucide-react"
import { cn } from "@/lib/utils"
import { getAccessToken } from "@/lib/api/client"
import "@/app/landing.css"

const navLinks = [
  { label: "How It Works", href: "#how-it-works" },
  { label: "Benefits", href: "#benefits" },
  { label: "Earnings", href: "#earnings" },
  { label: "Testimonials", href: "#testimonials" },
]

export function Navigation() {
  const [scrolled, setScrolled] = useState(false)
  const [mobileOpen, setMobileOpen] = useState(false)
  const [isLoggedIn, setIsLoggedIn] = useState(false)
  const prefersReducedMotion = useReducedMotion()

  useEffect(() => {
    setIsLoggedIn(!!getAccessToken())
  }, [])

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 80)
    window.addEventListener("scroll", onScroll, { passive: true })
    onScroll()
    return () => window.removeEventListener("scroll", onScroll)
  }, [])

  return (
    <>
      <div className="h-16" />

      <motion.nav
        initial={prefersReducedMotion ? {} : { y: -100, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ type: "spring", stiffness: 100, damping: 20, delay: 0.1 }}
        className={cn(
          "fixed left-1/2 -translate-x-1/2 z-50 transition-all duration-500",
          scrolled
            ? "top-4 bg-[var(--sv-bg-dark)]/90 backdrop-blur-2xl border border-white/10 shadow-2xl rounded-full w-[92%] max-w-2xl"
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
              <div className="w-8 h-8 rounded-lg bg-[var(--sv-accent)] flex items-center justify-center">
                <ShieldCheck className="w-4 h-4 text-white" />
              </div>
              <span
                className={cn(
                  "font-bold text-lg tracking-tight transition-colors duration-300",
                  scrolled ? "text-white" : "text-[var(--sv-text-primary)]"
                )}
              >
                SupervisorX
              </span>
            </motion.div>
          </Link>

          {/* Desktop nav links — hidden in pill state */}
          {!scrolled && (
            <div className="hidden md:flex items-center gap-1">
              {navLinks.map((link) => (
                <a
                  key={link.label}
                  href={link.href}
                  className="px-3 py-1.5 rounded-lg text-sm font-medium text-[var(--sv-text-muted)] hover:text-[var(--sv-text-primary)] hover:bg-[var(--sv-accent-lighter)] transition-colors duration-200"
                >
                  {link.label}
                </a>
              ))}
            </div>
          )}

          {/* Desktop CTA buttons */}
          <div className="hidden md:flex items-center gap-2">
            {isLoggedIn ? (
              <Link
                href="/dashboard"
                className="flex items-center gap-1.5 px-4 py-2 rounded-xl text-sm font-semibold transition-all bg-[var(--sv-accent)] text-white hover:bg-[var(--sv-accent-hover)]"
              >
                <LayoutDashboard className="w-4 h-4" />
                Dashboard
              </Link>
            ) : (
              <>
                <Link
                  href="/login"
                  className={cn(
                    "px-4 py-2 rounded-xl text-sm font-semibold transition-all",
                    scrolled
                      ? "text-white/80 hover:text-white hover:bg-white/10"
                      : "text-[var(--sv-text-secondary)] hover:text-[var(--sv-text-primary)] hover:bg-[var(--sv-accent-lighter)]"
                  )}
                >
                  Sign In
                </Link>
                <Link
                  href="/register"
                  className="px-4 py-2 rounded-xl text-sm font-semibold bg-[var(--sv-accent)] text-white hover:bg-[var(--sv-accent-hover)] transition-all hover:-translate-y-0.5"
                >
                  Apply Now
                </Link>
              </>
            )}
          </div>

          {/* Mobile hamburger */}
          <button
            onClick={() => setMobileOpen((p) => !p)}
            className={cn(
              "md:hidden p-2 rounded-lg transition-colors",
              scrolled
                ? "text-white hover:bg-white/10"
                : "text-[var(--sv-text-primary)] hover:bg-[var(--sv-accent-lighter)]"
            )}
            aria-label="Toggle menu"
          >
            {mobileOpen ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
          </button>
        </div>
      </motion.nav>

      {/* Mobile menu overlay */}
      <AnimatePresence>
        {mobileOpen && (
          <motion.div
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            transition={{ duration: 0.2 }}
            className="fixed inset-0 z-40 bg-white dark:bg-[var(--sv-bg-dark)] pt-24 px-6 md:hidden"
          >
            <nav className="flex flex-col gap-2">
              {navLinks.map((link) => (
                <a
                  key={link.label}
                  href={link.href}
                  onClick={() => setMobileOpen(false)}
                  className="py-3 px-4 rounded-xl text-lg font-medium text-[var(--sv-text-primary)] hover:bg-[var(--sv-accent-lighter)] transition-colors"
                >
                  {link.label}
                </a>
              ))}
              <div className="mt-4 flex flex-col gap-3">
                <Link href="/login" onClick={() => setMobileOpen(false)} className="sv-btn-secondary text-center">
                  Sign In
                </Link>
                <Link href="/register" onClick={() => setMobileOpen(false)} className="sv-btn-primary text-center">
                  Apply as Supervisor
                </Link>
              </div>
            </nav>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  )
}
