/**
 * @fileoverview Navigation - Modern minimal navigation
 *
 * Notion/Linear inspired navbar with smooth transitions.
 * Transforms into floating pill on scroll.
 */

"use client";

import { useState, useEffect } from "react";
import { Menu, X, GraduationCap, LayoutDashboard } from "lucide-react";
import { motion, useReducedMotion, AnimatePresence } from "framer-motion";
import Link from "next/link";
import { cn } from "@/lib/utils";
import { isLoggedIn as checkLoggedIn } from "@/lib/api/auth";
import "@/app/landing.css";

export function Navigation() {
  const [scrolled, setScrolled] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const prefersReducedMotion = useReducedMotion();
  // Check if user is logged in
  useEffect(() => {
    setIsLoggedIn(checkLoggedIn());
    setIsLoading(false);
  }, []);

  // Track scroll position
  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 80);
    };

    window.addEventListener("scroll", handleScroll, { passive: true });
    handleScroll();

    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  // Close mobile menu when route changes
  useEffect(() => {
    setMobileMenuOpen(false);
  }, []);

  return (
    <>
      {/* Spacer */}
      <div className="h-16" />

      <motion.nav
        initial={prefersReducedMotion ? {} : { y: -100, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{
          type: "spring",
          stiffness: 100,
          damping: 20,
          delay: 0.1,
        }}
        className={cn(
          "fixed left-1/2 -translate-x-1/2 z-50 transition-all duration-500 ease-[cubic-bezier(0.16,1,0.3,1)]",
          scrolled
            ? "top-4 bg-[#14110F]/90 backdrop-blur-2xl border border-white/10 shadow-2xl shadow-black/25 rounded-full w-[92%] max-w-2xl"
            : "top-3 w-full max-w-7xl bg-transparent border border-transparent"
        )}
      >
        <div
          className={cn(
            "flex items-center transition-all duration-500",
            scrolled ? "h-14 px-4 sm:px-6 justify-between" : "h-14 px-4 sm:px-6 justify-between"
          )}
        >
          {/* Logo */}
          <Link href="/" className="flex-shrink-0">
            <motion.div
              className="flex items-center gap-2"
              whileHover={prefersReducedMotion ? {} : { scale: 1.02 }}
              whileTap={prefersReducedMotion ? {} : { scale: 0.98 }}
            >
              <div
                className={cn(
                  "rounded-lg flex items-center justify-center transition-all duration-300",
                  scrolled
                    ? "h-9 w-9 bg-gradient-to-br from-[var(--landing-accent-primary)] to-[var(--landing-accent-secondary)]"
                    : "h-9 w-9 bg-[var(--landing-accent-primary)]"
                )}
              >
                <GraduationCap className="text-white h-5 w-5" />
              </div>
              <span
                className={cn(
                  "font-bold tracking-tight transition-all duration-300 text-xl",
                  scrolled ? "text-white" : "text-[var(--landing-text-primary)]"
                )}
              >
                Assign<span className={cn(
                  "transition-colors duration-300",
                  scrolled ? "text-[var(--landing-accent-light)]" : "text-[var(--landing-accent-primary)]"
                )}>X</span>
              </span>
            </motion.div>
          </Link>


          {/* Right: CTA Buttons */}
          <div className="flex items-center gap-1 sm:gap-2">
            <motion.div
              initial={prefersReducedMotion ? {} : { opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.2, duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
              className="flex items-center gap-1 sm:gap-3"
            >
              {isLoggedIn ? (
                /* Dashboard button for logged-in users */
                <Link
                  href="/home"
                  className={cn(
                    "inline-flex items-center justify-center gap-2 rounded-full font-medium text-sm transition-all duration-300",
                    "px-5 py-2 bg-[var(--landing-accent-primary)] text-white",
                    "hover:bg-[var(--landing-accent-primary-hover)]",
                    "hover:shadow-lg hover:shadow-[var(--landing-accent-primary)]/20",
                    "hover:scale-[1.02] active:scale-[0.98]"
                  )}
                >
                  <LayoutDashboard className="h-4 w-4" />
                  Dashboard
                </Link>
              ) : (
                <>
                  {/* Sign In - Hidden on mobile */}
                  <Link
                    href="/login"
                    className={cn(
                      "hidden sm:inline-flex px-5 py-2 text-sm font-medium transition-all duration-300 rounded-full",
                      scrolled
                        ? "text-white/80 hover:text-white hover:bg-white/10"
                        : "text-[var(--landing-text-secondary)] hover:text-[var(--landing-text-primary)] hover:bg-[var(--landing-accent-lighter)]"
                    )}
                  >
                    Sign In
                  </Link>

                  {/* Get Started */}
                  <Link
                    href="/signup"
                    className={cn(
                      "inline-flex items-center justify-center rounded-full font-medium text-sm transition-all duration-300",
                      "px-5 py-2 bg-[var(--landing-accent-primary)] text-white",
                      "hover:bg-[var(--landing-accent-primary-hover)]",
                      "hover:shadow-lg hover:shadow-[var(--landing-accent-primary)]/20",
                      "hover:scale-[1.02] active:scale-[0.98]"
                    )}
                  >
                    Get Started
                  </Link>
                </>
              )}
            </motion.div>

            {/* Mobile Menu Button */}
            <button
              className={cn(
                "p-2 md:hidden rounded-lg transition-colors",
                scrolled ? "hover:bg-white/10" : "hover:bg-[var(--landing-accent-lighter)]"
              )}
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              aria-label="Toggle menu"
            >
              <AnimatePresence mode="wait">
                {mobileMenuOpen ? (
                  <motion.div
                    key="close"
                    initial={{ rotate: -90, opacity: 0 }}
                    animate={{ rotate: 0, opacity: 1 }}
                    exit={{ rotate: 90, opacity: 0 }}
                    transition={{ duration: 0.2 }}
                  >
                    <X className={cn("h-5 w-5", scrolled ? "text-white" : "text-[var(--landing-text-primary)]")} />
                  </motion.div>
                ) : (
                  <motion.div
                    key="menu"
                    initial={{ rotate: 90, opacity: 0 }}
                    animate={{ rotate: 0, opacity: 1 }}
                    exit={{ rotate: -90, opacity: 0 }}
                    transition={{ duration: 0.2 }}
                  >
                    <Menu className={cn("h-5 w-5", scrolled ? "text-white" : "text-[var(--landing-text-primary)]")} />
                  </motion.div>
                )}
              </AnimatePresence>
            </button>
          </div>
        </div>
      </motion.nav>

      {/* Mobile Menu */}
      <AnimatePresence>
        {mobileMenuOpen && (
          <>
            {/* Backdrop */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              transition={{ duration: 0.2 }}
              className="fixed inset-0 bg-black/20 backdrop-blur-sm z-40 md:hidden"
              onClick={() => setMobileMenuOpen(false)}
            />

            {/* Menu Panel */}
            <motion.div
              initial={{ opacity: 0, y: -10, scale: 0.95 }}
              animate={{ opacity: 1, y: 0, scale: 1 }}
              exit={{ opacity: 0, y: -10, scale: 0.95 }}
              transition={{ duration: 0.2, ease: [0.16, 1, 0.3, 1] }}
              className="fixed top-20 left-4 right-4 z-50 landing-card shadow-2xl md:hidden overflow-hidden"
            >
              <div className="p-2">
                {/* Auth Links */}
                <div className="space-y-2">
                  {isLoggedIn ? (
                    <motion.div
                      initial={{ opacity: 0, x: -20 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: 0.15, duration: 0.3 }}
                    >
                      <Link
                        href="/home"
                        className="flex items-center justify-center gap-2 px-4 py-3 text-sm font-medium text-white bg-[var(--landing-accent-primary)] rounded-lg hover:bg-[var(--landing-accent-primary-hover)] transition-colors"
                        onClick={() => setMobileMenuOpen(false)}
                      >
                        <LayoutDashboard className="h-4 w-4" />
                        Go to Dashboard
                      </Link>
                    </motion.div>
                  ) : (
                    <>
                      <motion.div
                        initial={{ opacity: 0, x: -20 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: 0.15, duration: 0.3 }}
                      >
                        <Link
                          href="/login"
                          className="block px-4 py-3 text-sm font-medium text-[var(--landing-text-secondary)] hover:text-[var(--landing-text-primary)] transition-colors rounded-lg hover:bg-[var(--landing-accent-lighter)]"
                          onClick={() => setMobileMenuOpen(false)}
                        >
                          Sign In
                        </Link>
                      </motion.div>
                      <motion.div
                        initial={{ opacity: 0, x: -20 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: 0.2, duration: 0.3 }}
                      >
                        <Link
                          href="/signup"
                          className="block px-4 py-3 text-sm font-medium text-white bg-[var(--landing-accent-primary)] rounded-lg text-center hover:bg-[var(--landing-accent-primary-hover)] transition-colors"
                          onClick={() => setMobileMenuOpen(false)}
                        >
                          Get Started
                        </Link>
                      </motion.div>
                    </>
                  )}
                </div>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </>
  );
}
