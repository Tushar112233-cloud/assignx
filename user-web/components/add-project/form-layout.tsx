"use client";

/**
 * @fileoverview Dynamic Step Context Form Layout
 *
 * Two-column layout with:
 * - Dynamic left panel that changes with each step
 * - Clean white right panel for form content
 * - Professional, context-aware design
 */

import { motion, AnimatePresence } from "framer-motion";
import { Sparkles, Lightbulb, FileText, Clock, CheckCircle, Star, Zap, ArrowRight } from "lucide-react";
import { cn } from "@/lib/utils";
import "./form-layout.css";

interface FormLayoutProps {
  /** Page title shown in visual panel */
  title: string;
  /** Subtitle shown in visual panel */
  subtitle: string;
  /** Accent word in title (will be highlighted) */
  accentWord?: string;
  /** Current step (0-indexed) */
  currentStep: number;
  /** Total number of steps */
  totalSteps: number;
  /** Step labels */
  stepLabels?: string[];
  /** Floating cards data (kept for API compatibility but not rendered) */
  floatingCards?: unknown[];
  /** Form content */
  children: React.ReactNode;
  /** Back button handler */
  onBack?: () => void;
  /** Show back button */
  showBack?: boolean;
  /** Service type for different visual themes */
  serviceType?: "project" | "report" | "proofreading" | "consultation";
}

/**
 * Step context data - changes per step
 */
const stepContextData = [
  {
    icon: Lightbulb,
    heading: "Choose Your Focus",
    message: "Select the subject area that matches your project. Our experts cover 50+ academic fields.",
    tip: "💡 Pro tip: Not sure? Start broad - you can refine details later.",
    nextLabel: "Set requirements",
  },
  {
    icon: FileText,
    heading: "Set Your Scope",
    message: "Define the length and citation style. We handle everything from 250 to 50,000 words.",
    tip: "📊 Pro tip: Average project is 2,500 words with APA7 citations",
    nextLabel: "Choose timeline",
  },
  {
    icon: Clock,
    heading: "When Do You Need It?",
    message: "Choose your deadline and urgency. We've delivered 10,000+ projects on time.",
    tip: "⚡ Pro tip: Standard delivery gives you the best value",
    nextLabel: "Add details",
  },
  {
    icon: CheckCircle,
    heading: "Final Touches",
    message: "Add any specific instructions or reference materials. The more details, the better we can help.",
    tip: "📎 Pro tip: Attach style guides, rubrics, or sample papers for best results",
    nextLabel: "Review & submit",
  },
];

/**
 * Circular Progress Ring Component - Enhanced and Larger
 */
function ProgressRing({ progress }: { progress: number }) {
  const radius = 70;
  const circumference = 2 * Math.PI * radius;
  const strokeDashoffset = circumference - (progress / 100) * circumference;

  return (
    <div className="relative w-44 h-44">
      <svg className="transform -rotate-90 w-44 h-44">
        {/* Background circle */}
        <circle
          cx="88"
          cy="88"
          r={radius}
          stroke="rgba(255,255,255,0.08)"
          strokeWidth="4"
          fill="none"
        />
        {/* Progress circle with gradient */}
        <motion.circle
          cx="88"
          cy="88"
          r={radius}
          stroke="url(#progressGradient)"
          strokeWidth="4"
          fill="none"
          strokeDasharray={circumference}
          strokeDashoffset={strokeDashoffset}
          strokeLinecap="round"
          initial={{ strokeDashoffset: circumference }}
          animate={{ strokeDashoffset }}
          transition={{ duration: 0.6, ease: "easeInOut" }}
        />
        {/* Gradient definition */}
        <defs>
          <linearGradient id="progressGradient" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor="rgba(255,107,53,0.9)" />
            <stop offset="100%" stopColor="rgba(160,122,101,0.9)" />
          </linearGradient>
        </defs>
      </svg>
      {/* Percentage text - Larger */}
      <div className="absolute inset-0 flex flex-col items-center justify-center">
        <span className="text-3xl font-semibold text-white">{Math.round(progress)}%</span>
        <span className="text-xs text-white/60 mt-1">Complete</span>
      </div>
    </div>
  );
}

/**
 * Dynamic Step Context - Left Panel
 */
function DynamicStepContext({ currentStep, totalSteps }: { currentStep: number; totalSteps: number }) {
  const stepData = stepContextData[currentStep];
  const Icon = stepData.icon;
  const progress = ((currentStep + 1) / totalSteps) * 100;

  return (
    <div className="relative hidden flex-1 max-w-[55%] flex-col justify-between overflow-hidden bg-[#14110F] p-12 lg:flex xl:p-14 h-screen">
      {/* Animated gradient background - Enhanced for landing page consistency */}
      <div className="absolute inset-[-50%] z-0 animate-gradient-rotate">
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_20%_20%,rgba(255,107,53,0.08)_0%,transparent_50%)]" />
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_80%_20%,rgba(160,122,101,0.10)_0%,transparent_50%)]" />
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_40%_80%,rgba(118,83,65,0.12)_0%,transparent_50%)]" />
      </div>

      {/* Grid pattern overlay - Enhanced mesh effect */}
      <div
        className="absolute inset-0 z-[1] pointer-events-none opacity-40"
        style={{
          backgroundImage: `
            linear-gradient(rgba(255, 255, 255, 0.02) 1px, transparent 1px),
            linear-gradient(90deg, rgba(255, 255, 255, 0.02) 1px, transparent 1px)
          `,
          backgroundSize: "60px 60px",
        }}
      />

      {/* Logo Badge */}
      <div className="relative z-10">
        <div className="mb-12">
          <span className="inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/[0.05] px-4 py-2 text-[13px] font-medium text-white/90 backdrop-blur-sm">
            <Sparkles className="h-4 w-4" />
            AssignX
          </span>
        </div>
      </div>

      {/* Main Content - Centered Progress Ring + Context */}
      <div className="relative z-10 flex flex-1 flex-col justify-center max-w-[480px]">
        {/* Centered Progress Ring */}
        <div className="relative mb-12 flex justify-center">
          <AnimatePresence mode="wait">
            <motion.div
              key={currentStep}
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.95 }}
              transition={{ duration: 0.3, ease: [0.4, 0, 0.2, 1] }}
              className="relative"
            >
              <ProgressRing progress={progress} />
            </motion.div>
          </AnimatePresence>
        </div>

        {/* Step-Specific Content */}
        <AnimatePresence mode="wait">
          <motion.div
            key={currentStep}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            transition={{ duration: 0.3, delay: 0.15, ease: [0.4, 0, 0.2, 1] }}
            className="space-y-6"
          >
            {/* Icon with enhanced glow */}
            <motion.div
              animate={{ scale: [1, 1.05, 1] }}
              transition={{ duration: 2, repeat: Infinity, repeatDelay: 3 }}
              className="inline-flex h-14 w-14 items-center justify-center rounded-2xl bg-gradient-to-br from-white/15 to-white/5 backdrop-blur-sm border border-white/10"
            >
              <Icon className="h-7 w-7 text-white/90" strokeWidth={1.5} />
            </motion.div>

            {/* Heading - Enhanced typography */}
            <h3 className="text-[32px] font-bold leading-tight text-white tracking-tight">
              {stepData.heading}
            </h3>

            {/* Message - Better readability */}
            <p className="text-[16px] leading-relaxed text-white/75 max-w-[420px]">
              {stepData.message}
            </p>

            {/* Tip - Enhanced card style */}
            <div className="inline-flex items-start gap-2 rounded-xl bg-gradient-to-br from-white/[0.08] to-white/[0.02] px-5 py-3.5 border border-white/10 backdrop-blur-sm">
              <span className="text-[14px] leading-relaxed text-white/60">
                {stepData.tip}
              </span>
            </div>
          </motion.div>
        </AnimatePresence>
      </div>

      {/* Bottom Section - Trust Signals + What's Next */}
      <div className="relative z-10 space-y-5">
        {/* Trust Signals - Enhanced with glassmorphic cards */}
        <div className="flex items-center gap-4 text-[13px] text-white/60 border-t border-white/[0.08] pt-6">
          <div className="flex items-center gap-2 px-3 py-2 rounded-lg bg-white/[0.04] border border-white/[0.08]">
            <CheckCircle className="h-4 w-4 text-emerald-400/70" />
            <span className="font-medium">15,234 projects</span>
          </div>
          <div className="flex items-center gap-2 px-3 py-2 rounded-lg bg-white/[0.04] border border-white/[0.08]">
            <Star className="h-4 w-4 text-amber-400/70" />
            <span className="font-medium">4.9/5 rating</span>
          </div>
          <div className="flex items-center gap-2 px-3 py-2 rounded-lg bg-white/[0.04] border border-white/[0.08]">
            <Zap className="h-4 w-4 text-orange-400/70" />
            <span className="font-medium">98% on-time</span>
          </div>
        </div>

        {/* What's Next - Enhanced styling */}
        <div className="flex items-center justify-between border-t border-white/[0.08] pt-5 px-4 py-3 rounded-xl bg-gradient-to-r from-white/[0.04] to-transparent">
          <span className="text-[15px] font-semibold text-white/70">
            Next: {stepData.nextLabel}
          </span>
          <ArrowRight className="h-5 w-5 text-white/50" />
        </div>
      </div>
    </div>
  );
}

/**
 * Split-screen Form Layout - Dynamic Step Context
 */
export function FormLayout({
  currentStep,
  totalSteps,
  stepLabels,
  children,
}: FormLayoutProps) {
  const progress = ((currentStep + 1) / totalSteps) * 100;

  return (
    <div className="flex h-screen bg-background font-sans overflow-hidden">
      {/* Left Panel - Dynamic Step Context */}
      <DynamicStepContext currentStep={currentStep} totalSteps={totalSteps} />

      {/* Right Panel - Clean Form Side with scroll */}
      <div className="flex h-screen flex-1 flex-col items-center justify-start bg-background p-6 md:p-8 lg:min-w-[45%] lg:p-12 xl:p-16 overflow-y-auto">
        <div className="w-full max-w-[480px] pt-8">
          {/* Mobile logo */}
          <div className="mb-10 flex justify-center lg:hidden">
            <span className="inline-flex items-center gap-2 rounded-full bg-[#14110F] px-4 py-2 text-[13px] font-medium text-white">
              <Sparkles className="h-4 w-4" />
              AssignX
            </span>
          </div>

          {/* Progress indicator - Bar only */}
          <div className="mb-8">
            <div className="h-1.5 bg-muted rounded-full overflow-hidden">
              <div
                className="h-full bg-gradient-to-r from-[#FF6B35] to-[#A07A65] rounded-full transition-all duration-500"
                style={{ width: `${progress}%` }}
              />
            </div>
          </div>

          {/* Form content */}
          <div className="min-h-[400px]">
            {children}
          </div>
        </div>
      </div>
    </div>
  );
}

/**
 * Form Card - wrapper for form sections
 */
export function FormCard({
  title,
  description,
  children,
  className,
}: {
  title?: string;
  description?: string;
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <div className={cn("bg-card border border-border rounded-xl p-6", className)}>
      {(title || description) && (
        <div className="text-center pb-6 mb-6 border-b border-border">
          {title && <h2 className="text-xl font-semibold">{title}</h2>}
          {description && <p className="text-sm text-muted-foreground mt-2">{description}</p>}
        </div>
      )}
      <div>
        {children}
      </div>
    </div>
  );
}

/**
 * Form Input Group
 */
export function FormInputGroup({
  label,
  icon,
  hint,
  error,
  children,
  className,
}: {
  label: string;
  icon?: React.ReactNode;
  hint?: string;
  error?: string;
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <div className={cn("mb-5", className)}>
      <label className="flex items-center gap-2 text-sm font-medium mb-2">
        {icon && (
          <span className="flex items-center justify-center h-7 w-7 rounded-lg bg-muted border border-border text-muted-foreground">
            {icon}
          </span>
        )}
        {label}
      </label>
      {children}
      {hint && !error && <p className="text-xs text-muted-foreground mt-1.5 pl-1">{hint}</p>}
      {error && <p className="text-xs text-red-500 mt-1.5 pl-1">{error}</p>}
    </div>
  );
}

/**
 * Form Submit Button
 */
export function FormSubmitButton({
  children,
  isLoading,
  disabled,
  onClick,
  type = "submit",
  className,
}: {
  children: React.ReactNode;
  isLoading?: boolean;
  disabled?: boolean;
  onClick?: () => void;
  type?: "submit" | "button";
  className?: string;
}) {
  return (
    <button
      type={type}
      onClick={onClick}
      disabled={disabled || isLoading}
      className={cn(
        "w-full h-11 flex items-center justify-center gap-2 px-6 mt-6",
        "bg-primary text-primary-foreground font-medium text-sm rounded-lg",
        "hover:bg-primary/90 transition-colors",
        "disabled:opacity-50 disabled:cursor-not-allowed",
        className
      )}
    >
      {isLoading ? (
        <span className="flex items-center gap-2">
          <span className="h-4 w-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
          Processing...
        </span>
      ) : (
        children
      )}
    </button>
  );
}

/**
 * Form Secondary Button
 */
export function FormSecondaryButton({
  children,
  onClick,
  type = "button",
  className,
}: {
  children: React.ReactNode;
  onClick?: () => void;
  type?: "submit" | "button";
  className?: string;
}) {
  return (
    <button
      type={type}
      onClick={onClick}
      className={cn(
        "w-full h-10 flex items-center justify-center gap-2 px-6 mt-3",
        "bg-transparent border border-border text-muted-foreground text-sm rounded-lg",
        "hover:bg-muted hover:text-foreground transition-colors",
        className
      )}
    >
      {children}
    </button>
  );
}
