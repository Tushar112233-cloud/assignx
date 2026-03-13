"use client";

/**
 * @fileoverview Glassmorphic Step Context Form Layout
 *
 * Two-column layout with:
 * - Warm gradient mesh left panel with glassmorphic elements
 * - Clean right panel for form content
 * - Coffee brown palette: #765341, #14110F, #E4E1C7
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
    tip: "Not sure? Start broad — you can refine details later.",
    nextLabel: "Set requirements",
  },
  {
    icon: FileText,
    heading: "Set Your Scope",
    message: "Define the length and citation style. We handle everything from 250 to 50,000 words.",
    tip: "Average project is 2,500 words with APA7 citations.",
    nextLabel: "Choose timeline",
  },
  {
    icon: Clock,
    heading: "When Do You Need It?",
    message: "Choose your deadline and urgency. We've delivered 10,000+ projects on time.",
    tip: "Standard delivery gives you the best value.",
    nextLabel: "Add details",
  },
  {
    icon: CheckCircle,
    heading: "Final Touches",
    message: "Add any specific instructions or reference materials. The more details, the better we can help.",
    tip: "Attach style guides, rubrics, or sample papers for best results.",
    nextLabel: "Review & submit",
  },
];

/**
 * Circular Progress Ring Component - Thin elegant style with coffee brown arc
 */
function ProgressRing({ progress, currentStep, totalSteps }: { progress: number; currentStep: number; totalSteps: number }) {
  const radius = 72;
  const circumference = 2 * Math.PI * radius;
  const strokeDashoffset = circumference - (progress / 100) * circumference;

  return (
    <div className="relative w-44 h-44">
      <svg className="transform -rotate-90 w-44 h-44">
        {/* Background circle - subtle */}
        <circle
          cx="88"
          cy="88"
          r={radius}
          stroke="rgba(255,255,255,0.06)"
          strokeWidth="2.5"
          fill="none"
        />
        {/* Progress circle - coffee brown gradient */}
        <motion.circle
          cx="88"
          cy="88"
          r={radius}
          stroke="url(#coffeeBrownGradient)"
          strokeWidth="2.5"
          fill="none"
          strokeDasharray={circumference}
          strokeDashoffset={strokeDashoffset}
          strokeLinecap="round"
          initial={{ strokeDashoffset: circumference }}
          animate={{ strokeDashoffset }}
          transition={{ duration: 0.8, ease: [0.4, 0, 0.2, 1] }}
        />
        <defs>
          <linearGradient id="coffeeBrownGradient" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor="#A07A65" />
            <stop offset="50%" stopColor="#765341" />
            <stop offset="100%" stopColor="#E4E1C7" />
          </linearGradient>
        </defs>
      </svg>
      {/* Center content */}
      <div className="absolute inset-0 flex flex-col items-center justify-center">
        <span className="text-[28px] font-light tracking-tight text-white/90">
          {currentStep + 1}
          <span className="text-white/30 text-lg font-light">/{totalSteps}</span>
        </span>
        <span className="text-[11px] text-white/40 mt-0.5 uppercase tracking-widest font-medium">Step</span>
      </div>
    </div>
  );
}

/**
 * Dynamic Step Context - Left Panel with warm gradient mesh
 */
function DynamicStepContext({ currentStep, totalSteps }: { currentStep: number; totalSteps: number }) {
  const stepData = stepContextData[currentStep];
  const Icon = stepData.icon;
  const progress = ((currentStep + 1) / totalSteps) * 100;

  return (
    <div className="relative hidden flex-1 max-w-[55%] flex-col justify-between overflow-hidden p-12 lg:flex xl:p-14 h-screen"
      style={{ background: "linear-gradient(135deg, #1E1714 0%, #2A1F1A 30%, #1C1612 60%, #231A15 100%)" }}
    >
      {/* Warm gradient mesh background orbs */}
      <div className="absolute inset-0 z-0 overflow-hidden">
        <div className="absolute -top-[20%] -left-[10%] w-[70%] h-[70%] rounded-full opacity-30"
          style={{ background: "radial-gradient(circle, rgba(118,83,65,0.4) 0%, transparent 70%)" }}
        />
        <div className="absolute top-[20%] -right-[15%] w-[60%] h-[60%] rounded-full opacity-25"
          style={{ background: "radial-gradient(circle, rgba(160,122,101,0.35) 0%, transparent 70%)" }}
        />
        <div className="absolute -bottom-[15%] left-[10%] w-[65%] h-[65%] rounded-full opacity-20"
          style={{ background: "radial-gradient(circle, rgba(228,225,199,0.15) 0%, transparent 70%)" }}
        />
        <div className="absolute top-[50%] left-[30%] w-[40%] h-[40%] rounded-full opacity-15"
          style={{ background: "radial-gradient(circle, rgba(118,83,65,0.3) 0%, transparent 60%)" }}
        />
      </div>

      {/* Subtle noise/grain texture overlay */}
      <div className="absolute inset-0 z-[1] opacity-[0.03]"
        style={{
          backgroundImage: `url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)'/%3E%3C/svg%3E")`,
        }}
      />

      {/* Soft grid pattern */}
      <div
        className="absolute inset-0 z-[1] pointer-events-none opacity-20"
        style={{
          backgroundImage: `
            linear-gradient(rgba(228, 225, 199, 0.03) 1px, transparent 1px),
            linear-gradient(90deg, rgba(228, 225, 199, 0.03) 1px, transparent 1px)
          `,
          backgroundSize: "80px 80px",
        }}
      />

      {/* Logo Badge - Glassmorphic */}
      <div className="relative z-10">
        <div className="mb-10">
          <span className="inline-flex items-center gap-2.5 rounded-2xl border border-white/[0.08] bg-white/[0.04] backdrop-blur-xl px-5 py-2.5 text-[13px] font-medium text-white/80 shadow-lg shadow-black/10">
            <Sparkles className="h-4 w-4 text-[#A07A65]" />
            AssignX
          </span>
        </div>
      </div>

      {/* Main Content - Progress Ring + Context */}
      <div className="relative z-10 flex flex-1 flex-col justify-center max-w-[480px]">
        {/* Progress Ring */}
        <div className="relative mb-10 flex justify-center">
          <AnimatePresence mode="wait">
            <motion.div
              key={currentStep}
              initial={{ opacity: 0, scale: 0.96 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.96 }}
              transition={{ duration: 0.4, ease: [0.4, 0, 0.2, 1] }}
              className="relative"
            >
              <ProgressRing progress={progress} currentStep={currentStep} totalSteps={totalSteps} />
            </motion.div>
          </AnimatePresence>
        </div>

        {/* Step-Specific Content */}
        <AnimatePresence mode="wait">
          <motion.div
            key={currentStep}
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -12 }}
            transition={{ duration: 0.35, delay: 0.1, ease: [0.4, 0, 0.2, 1] }}
            className="space-y-5"
          >
            {/* Step icon - glassmorphic container */}
            <motion.div
              animate={{ scale: [1, 1.04, 1] }}
              transition={{ duration: 3, repeat: Infinity, repeatDelay: 4 }}
              className="inline-flex h-12 w-12 items-center justify-center rounded-2xl bg-white/[0.06] backdrop-blur-xl border border-white/[0.08] shadow-lg shadow-black/5"
            >
              <Icon className="h-6 w-6 text-[#A07A65]" strokeWidth={1.5} />
            </motion.div>

            {/* Heading */}
            <h3 className="text-[30px] font-semibold leading-tight text-white/95 tracking-[-0.02em]">
              {stepData.heading}
            </h3>

            {/* Description */}
            <p className="text-[15px] leading-[1.7] text-white/50 max-w-[400px]">
              {stepData.message}
            </p>

            {/* Pro tip - glassmorphic card */}
            <div className="inline-flex items-start gap-3 rounded-2xl bg-white/[0.04] backdrop-blur-xl px-5 py-4 border border-white/[0.06] shadow-lg shadow-black/5">
              <Lightbulb className="h-4 w-4 text-[#A07A65] mt-0.5 flex-shrink-0" />
              <span className="text-[13px] leading-relaxed text-white/45">
                {stepData.tip}
              </span>
            </div>
          </motion.div>
        </AnimatePresence>
      </div>

      {/* Bottom Section - Stats + What's Next */}
      <div className="relative z-10 space-y-4">
        {/* Stats pills - glassmorphic */}
        <div className="flex items-center gap-3 text-[12px] text-white/50 border-t border-white/[0.05] pt-5">
          <div className="flex items-center gap-2 px-3.5 py-2 rounded-xl bg-white/[0.03] backdrop-blur-xl border border-white/[0.06]">
            <CheckCircle className="h-3.5 w-3.5 text-emerald-400/60" />
            <span className="font-medium">15,234 projects</span>
          </div>
          <div className="flex items-center gap-2 px-3.5 py-2 rounded-xl bg-white/[0.03] backdrop-blur-xl border border-white/[0.06]">
            <Star className="h-3.5 w-3.5 text-[#A07A65]/70" />
            <span className="font-medium">4.9/5 rating</span>
          </div>
          <div className="flex items-center gap-2 px-3.5 py-2 rounded-xl bg-white/[0.03] backdrop-blur-xl border border-white/[0.06]">
            <Zap className="h-3.5 w-3.5 text-[#765341]/70" />
            <span className="font-medium">98% on-time</span>
          </div>
        </div>

        {/* What's Next - subtle chip */}
        <div className="flex items-center justify-between px-4 py-3 rounded-xl bg-white/[0.02] border border-white/[0.04]">
          <span className="text-[13px] font-medium text-white/35">
            Next: {stepData.nextLabel}
          </span>
          <ArrowRight className="h-4 w-4 text-white/25" />
        </div>
      </div>
    </div>
  );
}

/**
 * Split-screen Form Layout - Glassmorphic Coffee Brown Theme
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
      {/* Left Panel - Warm Gradient Mesh */}
      <DynamicStepContext currentStep={currentStep} totalSteps={totalSteps} />

      {/* Right Panel - Clean Form Side */}
      <div className="flex h-screen flex-1 flex-col items-center justify-start bg-background p-6 md:p-8 lg:min-w-[45%] lg:p-12 xl:p-16 overflow-y-auto">
        <div className="w-full max-w-[480px] pt-8">
          {/* Mobile logo */}
          <div className="mb-10 flex justify-center lg:hidden">
            <span className="inline-flex items-center gap-2 rounded-2xl bg-[#1E1714] px-5 py-2.5 text-[13px] font-medium text-white/90">
              <Sparkles className="h-4 w-4 text-[#A07A65]" />
              AssignX
            </span>
          </div>

          {/* Progress bar - coffee brown gradient */}
          <div className="mb-8">
            {/* Step labels */}
            {stepLabels && (
              <div className="flex items-center justify-between mb-3">
                {stepLabels.map((label, i) => (
                  <span
                    key={i}
                    className={cn(
                      "text-[11px] font-medium uppercase tracking-wider transition-colors duration-300",
                      i <= currentStep ? "text-[#765341]" : "text-muted-foreground/40"
                    )}
                  >
                    {label}
                  </span>
                ))}
              </div>
            )}
            <div className="h-1 bg-muted/60 rounded-full overflow-hidden">
              <motion.div
                className="h-full rounded-full"
                style={{ background: "linear-gradient(90deg, #765341, #A07A65, #E4E1C7)" }}
                initial={{ width: 0 }}
                animate={{ width: `${progress}%` }}
                transition={{ duration: 0.5, ease: [0.4, 0, 0.2, 1] }}
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
 * Form Card - wrapper for form sections with glassmorphic styling
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
    <div className={cn(
      "bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 rounded-[20px] shadow-sm p-6",
      className
    )}>
      {(title || description) && (
        <div className="text-center pb-5 mb-5 border-b border-border/50">
          {title && <h2 className="text-lg font-semibold text-foreground">{title}</h2>}
          {description && <p className="text-sm text-muted-foreground mt-1.5">{description}</p>}
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
          <span className="flex items-center justify-center h-7 w-7 rounded-lg bg-[#765341]/5 border border-[#765341]/10 text-[#765341]">
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
 * Form Submit Button - Coffee brown primary
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
        "w-full h-12 flex items-center justify-center gap-2 px-6 mt-6",
        "bg-[#765341] text-white font-medium text-sm rounded-xl",
        "hover:bg-[#654332] active:bg-[#543828] transition-all duration-200",
        "shadow-lg shadow-[#765341]/15 hover:shadow-xl hover:shadow-[#765341]/20",
        "disabled:opacity-50 disabled:cursor-not-allowed disabled:shadow-none",
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
        "bg-transparent border border-[#765341]/15 text-muted-foreground text-sm rounded-xl",
        "hover:bg-[#765341]/5 hover:border-[#765341]/25 hover:text-foreground transition-all duration-200",
        className
      )}
    >
      {children}
    </button>
  );
}
