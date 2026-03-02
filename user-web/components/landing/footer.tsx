/**
 * @fileoverview Footer - Clean modern footer
 *
 * Simple footer with newsletter signup and link columns.
 * No ghost text animation - clean and professional.
 */

"use client";

import { useRef, useState } from "react";
import { motion, useInView, useReducedMotion } from "framer-motion";
import { cn } from "@/lib/utils";
import Link from "next/link";
import { ArrowRight, GraduationCap, Mail, Phone, MapPin } from "lucide-react";
import "@/app/landing.css";

const footerLinks = {
  services: {
    title: "Services",
    links: [
      { label: "Academic Reports", href: "/signup" },
      { label: "Proofreading", href: "/signup" },
      { label: "1-on-1 Tutoring", href: "/signup" },
      { label: "Consultation", href: "/signup" },
    ],
  },
  company: {
    title: "Company",
    links: [
      { label: "About Us", href: "/#how-it-works" },
      { label: "How It Works", href: "/#how-it-works" },
      { label: "Get Started", href: "/signup" },
      { label: "Sign In", href: "/login" },
    ],
  },
  support: {
    title: "Support",
    links: [
      { label: "Help Center", href: "/support" },
      { label: "Contact Us", href: "/support" },
      { label: "Campus Connect", href: "/verify-college" },
      { label: "Sign Up", href: "/signup" },
    ],
  },
};

export function Footer() {
  const currentYear = new Date().getFullYear();
  const footerRef = useRef<HTMLDivElement>(null);
  const prefersReducedMotion = useReducedMotion();
  const isInView = useInView(footerRef, { once: true, amount: 0.1 });
  const [email, setEmail] = useState("");

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: { staggerChildren: 0.08, delayChildren: 0.1 },
    },
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 15 },
    visible: { opacity: 1, y: 0, transition: { duration: 0.4 } },
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    console.log("Newsletter signup:", email);
    setEmail("");
  };

  return (
    <footer
      ref={footerRef}
      className="relative bg-[var(--landing-bg-dark)] overflow-hidden"
    >
      {/* Main footer content */}
      <div className="relative z-10 pt-16 sm:pt-20 pb-8">
        <div className="max-w-7xl mx-auto px-4 sm:px-6">
          <motion.div
            variants={prefersReducedMotion ? {} : containerVariants}
            initial="hidden"
            animate={isInView ? "visible" : "hidden"}
          >
            {/* Top section: Logo + Newsletter */}
            <motion.div
              variants={prefersReducedMotion ? {} : itemVariants}
              className="flex flex-col lg:flex-row lg:items-start lg:justify-between gap-10 pb-12 border-b border-white/10"
            >
              {/* Logo and description */}
              <div className="max-w-sm">
                <Link href="/" className="inline-flex items-center gap-2 mb-4">
                  <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-[var(--landing-accent-primary)] to-[var(--landing-accent-secondary)] flex items-center justify-center">
                    <GraduationCap className="w-5 h-5 text-white" />
                  </div>
                  <span className="text-2xl font-bold text-white tracking-tight">
                    Assign<span className="text-[var(--landing-accent-tertiary)]">X</span>
                  </span>
                </Link>
                <p className="text-white/60 text-sm leading-relaxed mb-6">
                  Empowering students with expert academic support. Quality work, delivered on time, every time.
                </p>

                {/* Contact info */}
                <div className="space-y-2 text-sm text-white/50">
                  <div className="flex items-center gap-2">
                    <Mail className="w-4 h-4" />
                    <span>support@assignx.com</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <Phone className="w-4 h-4" />
                    <span>+1 (555) 123-4567</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <MapPin className="w-4 h-4" />
                    <span>San Francisco, CA</span>
                  </div>
                </div>
              </div>

              {/* Newsletter */}
              <div className="max-w-md">
                <h3 className="text-lg font-semibold text-white mb-2">
                  Stay Updated
                </h3>
                <p className="text-white/60 text-sm mb-4">
                  Get tips, updates, and exclusive offers delivered to your inbox.
                </p>
                <form onSubmit={handleSubmit} className="flex gap-2">
                  <input
                    type="email"
                    placeholder="Enter your email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="flex-1 h-12 px-4 rounded-xl bg-white/[0.08] border border-white/[0.15] text-white placeholder:text-white/40 text-sm focus:outline-none focus:border-[var(--landing-accent-primary)] transition-colors"
                    required
                  />
                  <button
                    type="submit"
                    className="h-12 px-5 rounded-xl bg-[var(--landing-accent-tertiary)] text-white font-medium text-sm hover:bg-[var(--landing-accent-tertiary-hover)] transition-colors flex items-center gap-2"
                  >
                    Subscribe
                    <ArrowRight className="w-4 h-4" />
                  </button>
                </form>
              </div>
            </motion.div>

            {/* Link columns */}
            <motion.div
              variants={prefersReducedMotion ? {} : itemVariants}
              className="grid grid-cols-2 md:grid-cols-3 gap-8 py-12"
            >
              {Object.entries(footerLinks).map(([key, section]) => (
                <div key={key}>
                  <h4 className="text-white font-semibold text-sm mb-4">
                    {section.title}
                  </h4>
                  <ul className="space-y-3">
                    {section.links.map((link) => (
                      <li key={link.label}>
                        <Link
                          href={link.href}
                          className="text-white/50 hover:text-[var(--landing-accent-primary)] text-sm transition-colors duration-200"
                        >
                          {link.label}
                        </Link>
                      </li>
                    ))}
                  </ul>
                </div>
              ))}
            </motion.div>

            {/* Bottom bar */}
            <motion.div
              variants={prefersReducedMotion ? {} : itemVariants}
              className="flex flex-col sm:flex-row items-center justify-between gap-4 pt-8 border-t border-white/10"
            >
              {/* Copyright */}
              <p className="text-white/40 text-sm">
                © {currentYear} AssignX. All rights reserved.
              </p>

              {/* Legal links */}
              <div className="flex items-center gap-6 text-sm">
                <Link href="/privacy" className="text-white/40 hover:text-white/70 transition-colors">
                  Privacy Policy
                </Link>
                <Link href="/terms" className="text-white/40 hover:text-white/70 transition-colors">
                  Terms of Service
                </Link>
              </div>
            </motion.div>
          </motion.div>
        </div>
      </div>
    </footer>
  );
}
