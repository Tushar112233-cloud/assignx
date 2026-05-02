/**
 * @fileoverview Footer — Supervisor Landing
 *
 * Dark footer with 3-column link layout and copyright bar.
 */
"use client"

import { useRef } from "react"
import { motion, useReducedMotion, useInView } from "framer-motion"
import Link from "next/link"
import { SV_EASE } from "@/lib/animations/constants"
import "@/app/landing.css"

const footerLinks = {
  forSupervisors: {
    title: "For Supervisors",
    links: [
      { label: "How It Works", href: "#how-it-works" },
      { label: "Your Role", href: "#role" },
      { label: "Benefits", href: "#benefits" },
      { label: "Apply Now", href: "/register" },
    ],
  },
  company: {
    title: "Company",
    links: [
      { label: "About AssignX", href: "#" },
      { label: "For Students", href: "#" },
      { label: "For DoLancers", href: "#" },
      { label: "Blog", href: "#" },
    ],
  },
  support: {
    title: "Support",
    links: [
      { label: "Help Center", href: "#" },
      { label: "Contact Us", href: "#" },
      { label: "Sign In", href: "/login" },
      { label: "Apply", href: "/register" },
    ],
  },
}

export function Footer() {
  const currentYear = new Date().getFullYear()
  const footerRef = useRef<HTMLDivElement>(null)
  const isInView = useInView(footerRef, { once: true, amount: 0.1 })
  const prefersReducedMotion = useReducedMotion()

  return (
    <footer
      className="relative overflow-hidden"
      style={{ background: "var(--sv-bg-dark)" }}
    >
      <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-white/10 to-transparent" />

      <motion.div
        ref={footerRef}
        initial={prefersReducedMotion ? false : { opacity: 0, y: 20 }}
        animate={isInView ? { opacity: 1, y: 0 } : {}}
        transition={{ duration: 0.7, ease: SV_EASE }}
        className="max-w-6xl mx-auto px-4 sm:px-6 py-16"
      >
        <div className="grid grid-cols-1 md:grid-cols-4 gap-10">
          {/* Brand column */}
          <div className="md:col-span-1">
            <div className="flex items-center gap-2 mb-4">
              <img src="/logo.svg" alt="SupervisorX" className="w-8 h-8 rounded-lg" />
              <span className="font-bold text-lg text-white tracking-tight">
                SupervisorX
              </span>
            </div>
            <p className="text-sm text-white/40 leading-relaxed mb-4">
              Quality. Integrity. Supervision.
            </p>
            <p className="text-xs text-white/30 leading-relaxed">
              The expert supervision platform by AssignX — connecting verified
              domain experts with academic task management.
            </p>
          </div>

          {/* Link columns */}
          {Object.values(footerLinks).map((section) => (
            <div key={section.title}>
              <h4 className="text-sm font-semibold text-white/60 uppercase tracking-wider mb-4">
                {section.title}
              </h4>
              <ul className="space-y-3">
                {section.links.map((link) => (
                  <li key={link.label}>
                    <Link
                      href={link.href}
                      className="text-sm text-white/40 hover:text-white/80 transition-colors duration-200"
                    >
                      {link.label}
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>

        {/* Bottom bar */}
        <div className="mt-12 pt-8 border-t border-white/10 flex flex-col sm:flex-row items-center justify-between gap-4">
          <p className="text-xs text-white/30">
            © {currentYear} AssignX. All rights reserved.
          </p>
          <p className="text-xs text-white/20 italic">
            Quality. Integrity. Supervision.
          </p>
        </div>
      </motion.div>
    </footer>
  )
}
