"use client";

import { motion, useReducedMotion } from "framer-motion";
import { Sparkles, Star, TrendingUp, Shield, Lock, Zap } from "lucide-react";
import Link from "next/link";

/**
 * Props for AuthLayout component
 */
interface AuthLayoutProps {
  /** Content to render in the form area */
  children: React.ReactNode;
  /** Heading for the visual panel */
  heading?: React.ReactNode;
  /** Subheading for the visual panel */
  subheading?: string;
  /** Whether to show the visual panel (hidden on mobile) */
  showVisualPanel?: boolean;
  /** Custom stats to display in the footer */
  stats?: Array<{
    value: string;
    label: string;
  }>;
}

/**
 * Floating card data for the visual panel
 */
const floatingCards = [
  {
    icon: TrendingUp,
    iconBg: "bg-primary/30",
    title: "Success Rate",
    value: "98%",
    label: "This month",
    position: "top-[15%] right-[10%]",
    delay: 0.8,
  },
  {
    icon: Star,
    iconBg: "bg-amber-500/30",
    title: "Student Rating",
    value: "4.9",
    label: "500+ reviews",
    position: "top-[50%] right-[18%]",
    delay: 1.0,
  },
];

/**
 * Default stats for the visual panel footer
 */
const defaultStats = [
  { value: "50K+", label: "Projects done" },
  { value: "10K+", label: "Students" },
  { value: "24/7", label: "Support" },
];

/**
 * FloatingCard - Animated card for visual panel
 */
function FloatingCard({
  icon: Icon,
  iconBg,
  title,
  value,
  label,
  position,
  delay,
}: {
  icon: React.ElementType;
  iconBg: string;
  title: string;
  value: string;
  label: string;
  position: string;
  delay: number;
}) {
  const prefersReducedMotion = useReducedMotion();

  return (
    <motion.div
      initial={prefersReducedMotion ? {} : { opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay, duration: 0.6, ease: [0.4, 0, 0.2, 1] }}
      className={`absolute ${position} w-40 rounded-xl bg-white/[0.04] p-4 backdrop-blur-xl border border-white/[0.08] animate-float`}
      style={{
        animationDelay: `${delay}s`,
      }}
    >
      <div className={`mb-2.5 flex h-9 w-9 items-center justify-center rounded-lg ${iconBg}`}>
        <Icon className="h-5 w-5 text-white" />
      </div>
      <div className="mb-1 text-xs font-medium text-white/70">{title}</div>
      <div className="text-xl font-semibold text-white">{value}</div>
      <div className="mt-1 text-[11px] text-white/40">{label}</div>
    </motion.div>
  );
}

/**
 * AuthLayout - Shared layout for authentication pages
 *
 * Provides a consistent split-screen layout with animated visual panel
 * on the left and form content on the right. Fully responsive with
 * the visual panel hidden on mobile.
 *
 * @example
 * ```tsx
 * <AuthLayout
 *   heading={<>Your academic <span>success</span> starts here</>}
 *   subheading="Expert guidance for reports, research, and academic excellence."
 * >
 *   <LoginForm />
 * </AuthLayout>
 * ```
 */
export function AuthLayout({
  children,
  heading = (
    <>
      Your academic <span className="text-white/60 font-normal">success</span> starts here
    </>
  ),
  subheading = "Expert guidance for reports, research, and academic excellence. Join thousands of students achieving their goals.",
  showVisualPanel = true,
  stats = defaultStats,
}: AuthLayoutProps) {
  const prefersReducedMotion = useReducedMotion();

  return (
    <div className="flex min-h-screen bg-background font-sans">
      {/* Left Panel - Visual Side */}
      {showVisualPanel && (
        <div className="relative hidden flex-[1.2] max-w-[55%] flex-col justify-between overflow-hidden bg-[#14110F] p-12 lg:flex xl:p-14">
          {/* Animated gradient background */}
          <div className="absolute inset-[-50%] z-0 animate-gradient-rotate">
            <div className="absolute inset-0 bg-[radial-gradient(circle_at_20%_20%,rgba(118,83,65,0.15)_0%,transparent_40%)]" />
            <div className="absolute inset-0 bg-[radial-gradient(circle_at_80%_20%,rgba(52,49,45,0.12)_0%,transparent_40%)]" />
            <div className="absolute inset-0 bg-[radial-gradient(circle_at_40%_80%,rgba(160,122,101,0.10)_0%,transparent_40%)]" />
          </div>

          {/* Grid pattern overlay */}
          <div
            className="absolute inset-0 z-[1] pointer-events-none"
            style={{
              backgroundImage: `
                linear-gradient(rgba(255, 255, 255, 0.02) 1px, transparent 1px),
                linear-gradient(90deg, rgba(255, 255, 255, 0.02) 1px, transparent 1px)
              `,
              backgroundSize: "60px 60px",
            }}
          />

          {/* Floating cards */}
          <div className="absolute inset-0 z-[5] overflow-hidden pointer-events-none">
            {floatingCards.map((card, index) => (
              <FloatingCard key={index} {...card} />
            ))}
          </div>

          {/* Content */}
          <div className="relative z-10 flex flex-1 flex-col justify-center max-w-[480px]">
            <motion.div
              initial={prefersReducedMotion ? {} : { opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, ease: [0.4, 0, 0.2, 1] }}
              className="mb-12"
            >
              <span className="inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/[0.05] px-4 py-2 text-[13px] font-medium text-white/90">
                <Sparkles className="h-4 w-4" />
                AssignX
              </span>
            </motion.div>

            <motion.h1
              initial={prefersReducedMotion ? {} : { opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.2, duration: 0.6, ease: [0.4, 0, 0.2, 1] }}
              className="text-5xl font-semibold leading-[1.1] tracking-[-0.03em] text-white xl:text-[56px]"
            >
              {heading}
            </motion.h1>

            <motion.p
              initial={prefersReducedMotion ? {} : { opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.4, duration: 0.6, ease: [0.4, 0, 0.2, 1] }}
              className="mt-5 max-w-[400px] text-base leading-relaxed text-white/50"
            >
              {subheading}
            </motion.p>
          </div>

          {/* Footer stats */}
          <motion.div
            initial={prefersReducedMotion ? {} : { opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.6, duration: 0.6 }}
            className="relative z-10 flex max-w-xs gap-8 border-t border-white/[0.06] pt-5"
          >
            {stats.map((stat, index) => (
              <div key={index} className="flex flex-col">
                <span className="text-2xl font-semibold text-white">{stat.value}</span>
                <span className="mt-1 text-[11px] text-white/40">{stat.label}</span>
              </div>
            ))}
          </motion.div>
        </div>
      )}

      {/* Right Panel - Form Side */}
      <div className="flex min-h-screen flex-1 flex-col items-center justify-center bg-background p-6 md:p-8 lg:min-w-[45%] lg:flex-[0.8] lg:p-12 xl:p-16">
        <div className="w-full max-w-[380px]">
          {/* Mobile logo */}
          <motion.div
            initial={prefersReducedMotion ? {} : { opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.4 }}
            className="mb-10 flex justify-center lg:hidden"
          >
            <span className="inline-flex items-center gap-2 rounded-full bg-[#14110F] px-4 py-2 text-[13px] font-medium text-white">
              <Sparkles className="h-4 w-4" />
              AssignX
            </span>
          </motion.div>

          {/* Form content */}
          {children}

          {/* Trust badges */}
          <motion.div
            initial={prefersReducedMotion ? {} : { opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.7, duration: 0.5 }}
            className="mt-8 flex flex-wrap justify-center gap-4 border-t border-border pt-6"
          >
            <div className="flex items-center gap-1.5 text-[11px] text-muted-foreground">
              <Shield className="h-3.5 w-3.5 text-muted-foreground/70" />
              <span>Secure</span>
            </div>
            <div className="flex items-center gap-1.5 text-[11px] text-muted-foreground">
              <Lock className="h-3.5 w-3.5 text-muted-foreground/70" />
              <span>Encrypted</span>
            </div>
            <div className="flex items-center gap-1.5 text-[11px] text-muted-foreground">
              <Zap className="h-3.5 w-3.5 text-muted-foreground/70" />
              <span>Fast</span>
            </div>
          </motion.div>
        </div>
      </div>
    </div>
  );
}

/**
 * Google logo SVG component
 */
export function GoogleIcon({ className }: { className?: string }) {
  return (
    <svg
      className={className}
      viewBox="0 0 24 24"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path
        d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
        fill="#4285F4"
      />
      <path
        d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
        fill="#34A853"
      />
      <path
        d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
        fill="#FBBC05"
      />
      <path
        d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
        fill="#EA4335"
      />
    </svg>
  );
}
