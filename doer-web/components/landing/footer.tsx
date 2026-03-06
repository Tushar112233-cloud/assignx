/**
 * @fileoverview Footer — Doer Landing
 *
 * Dark teal footer with brand column + 3 link columns.
 * Fade-in on scroll. Copyright bar at bottom.
 */
"use client"

import { useRef } from "react"
import { motion, useReducedMotion, useInView } from "framer-motion"
import Link from "next/link"
import { Briefcase, ArrowUpRight } from "lucide-react"
import { DOER_EASE } from "@/lib/animations/constants"
import "@/app/landing.css"

const footerLinks = {
  forDoers: {
    title: "For Doers",
    links: [
      { label: "Browse Tasks", href: "/register" },
      { label: "How It Works", href: "#how-it-works" },
      { label: "Benefits", href: "#benefits" },
      { label: "Apply Now", href: "/register" },
    ],
  },
  company: {
    title: "Company",
    links: [
      { label: "About AssignX", href: "#" },
      { label: "For Students", href: "#" },
      { label: "For Supervisors", href: "#" },
      { label: "Blog", href: "#" },
    ],
  },
  support: {
    title: "Support",
    links: [
      { label: "Help Center", href: "#" },
      { label: "Contact Us", href: "#" },
      { label: "Sign In", href: "/login" },
      { label: "Sign Up", href: "/register" },
    ],
  },
}

/** Footer */
export function Footer() {
  const currentYear = new Date().getFullYear()
  const footerRef = useRef<HTMLDivElement>(null)
  const isInView = useInView(footerRef, { once: true, amount: 0.1 })
  const prefersReducedMotion = useReducedMotion()

  return (
    <footer
      className="relative overflow-hidden"
      style={{ background: "var(--landing-bg-dark)" }}
    >
      {/* Top border gradient */}
      <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-white/10 to-transparent" />

      <div ref={footerRef} className="max-w-7xl mx-auto px-4 sm:px-6 py-16">
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0, y: 20 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, ease: DOER_EASE }}
          className="grid grid-cols-1 lg:grid-cols-5 gap-12 mb-16"
        >
          {/* Brand column — spans 2 of 5 */}
          <div className="lg:col-span-2">
            <Link href="/" className="flex items-center gap-2 mb-4 w-fit">
              <div className="w-8 h-8 rounded-lg bg-[var(--landing-accent-primary)] flex items-center justify-center">
                <Briefcase className="w-4 h-4 text-white" />
              </div>
              <span className="font-bold text-lg text-white tracking-tight">
                Dolancer
              </span>
            </Link>
            <p className="text-sm text-white/50 leading-relaxed mb-6 max-w-xs">
              Turn your academic expertise into real income. Join India&apos;s
              fastest growing expert network.
            </p>
            <p className="text-xs text-white/30">
              Powered by{" "}
              <span className="text-[var(--landing-accent-primary)] font-medium">
                AssignX
              </span>
            </p>
          </div>

          {/* Link columns */}
          {Object.values(footerLinks).map((col) => (
            <div key={col.title}>
              <h4 className="text-xs font-semibold uppercase tracking-widest text-white/40 mb-4">
                {col.title}
              </h4>
              <ul className="flex flex-col gap-2.5">
                {col.links.map((link) => (
                  <li key={link.label}>
                    <Link
                      href={link.href}
                      className="text-sm text-white/50 hover:text-white transition-colors duration-200 flex items-center gap-1 group w-fit"
                    >
                      {link.label}
                      {link.href.startsWith("http") && (
                        <ArrowUpRight className="w-3 h-3 opacity-0 group-hover:opacity-100 transition-opacity" />
                      )}
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </motion.div>

        {/* Bottom bar */}
        <div className="flex flex-col sm:flex-row items-center justify-between gap-4 pt-8 border-t border-white/10">
          <p className="text-xs text-white/30">
            &copy; {currentYear} AssignX. All rights reserved.
          </p>
          <div className="flex items-center gap-6">
            {["Privacy Policy", "Terms of Service"].map((item) => (
              <Link
                key={item}
                href="#"
                className="text-xs text-white/30 hover:text-white/60 transition-colors duration-200"
              >
                {item}
              </Link>
            ))}
          </div>
        </div>
      </div>
    </footer>
  )
}
