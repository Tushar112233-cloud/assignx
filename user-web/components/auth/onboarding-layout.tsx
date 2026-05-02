"use client";

import { motion, AnimatePresence, useReducedMotion } from "framer-motion";
import { Sparkles } from "lucide-react";

import "../auth/onboarding.css";

// Animation configuration
const EASE = [0.16, 1, 0.3, 1] as const;

interface FloatingCardData {
  icon: React.ElementType;
  iconBg: string;
  title: string;
  value: string;
  label: string;
  position: string;
  delay: number;
}

interface OnboardingLayoutProps {
  children: React.ReactNode;
  visualHeading: string;
  visualSubheading: string;
  cards: FloatingCardData[];
  currentStep: number;
  totalSteps: number;
  showProgress?: boolean;
  logoText?: string;
}

/**
 * Floating card component for the visual panel
 */
function FloatingCard({
  icon: Icon,
  iconBg,
  title,
  value,
  label,
  className,
  delay,
}: {
  icon: React.ElementType;
  iconBg: string;
  title: string;
  value: string;
  label: string;
  className: string;
  delay: number;
}) {
  const prefersReducedMotion = useReducedMotion();

  return (
    <motion.div
      initial={prefersReducedMotion ? {} : { opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay, duration: 0.6, ease: EASE }}
      className={`onboarding-float-card ${className}`}
    >
      <div className={`onboarding-float-card-icon ${iconBg}`}>
        <Icon className="w-5 h-5 text-white" />
      </div>
      <div className="onboarding-float-card-title">{title}</div>
      <div className="onboarding-float-card-value">{value}</div>
      <div className="onboarding-float-card-label">{label}</div>
    </motion.div>
  );
}

/**
 * Step indicator dots for bottom of visual panel
 */
function StepIndicator({
  currentStep,
  totalSteps,
}: {
  currentStep: number;
  totalSteps: number;
}) {
  return (
    <div className="onboarding-steps-indicator">
      {Array.from({ length: totalSteps }, (_, i) => (
        <div
          key={i}
          className={`onboarding-step-dot ${
            currentStep === i ? "active" : ""
          } ${i < currentStep ? "completed" : ""}`}
        />
      ))}
    </div>
  );
}

/**
 * Progress bar component
 */
function ProgressBar({
  currentStep,
  totalSteps,
}: {
  currentStep: number;
  totalSteps: number;
}) {
  const progress = ((currentStep + 1) / totalSteps) * 100;

  return (
    <div className="onboarding-progress">
      <div className="onboarding-progress-bar">
        <motion.div
          className="onboarding-progress-fill"
          initial={{ width: 0 }}
          animate={{ width: `${progress}%` }}
          transition={{ duration: 0.5, ease: EASE }}
        />
      </div>
      <div className="onboarding-progress-label">
        <span>Step {currentStep + 1} of {totalSteps}</span>
        <span>{Math.round(progress)}% complete</span>
      </div>
    </div>
  );
}

/**
 * Premium split-screen onboarding layout
 * Left side: Visual panel with floating cards and gradient background
 * Right side: Form panel with content
 */
export function OnboardingLayout({
  children,
  visualHeading,
  visualSubheading,
  cards,
  currentStep,
  totalSteps,
  showProgress = true,
  logoText = "AssignX",
}: OnboardingLayoutProps) {
  const prefersReducedMotion = useReducedMotion();

  return (
    <div className="onboarding-page">
      {/* Left Panel - Visual Side */}
      <div className="onboarding-visual">
        {/* Floating cards */}
        <div className="onboarding-floating-cards">
          <AnimatePresence mode="wait">
            {cards.map((card, index) => (
              <FloatingCard
                key={`card-${index}`}
                icon={card.icon}
                iconBg={card.iconBg}
                title={card.title}
                value={card.value}
                label={card.label}
                className={card.position}
                delay={card.delay}
              />
            ))}
          </AnimatePresence>
        </div>

        {/* Content */}
        <div className="onboarding-visual-content">
          <motion.div
            initial={prefersReducedMotion ? {} : { opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, ease: EASE }}
            className="onboarding-visual-logo"
          >
            <span>
              <Sparkles className="w-4 h-4" />
              {logoText}
            </span>
          </motion.div>

          <AnimatePresence mode="wait">
            <motion.h1
              key={`heading-${currentStep}`}
              initial={prefersReducedMotion ? {} : { opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -30 }}
              transition={{ delay: 0.2, duration: 0.6, ease: EASE }}
              className="onboarding-visual-heading"
            >
              {visualHeading}
            </motion.h1>
          </AnimatePresence>

          <AnimatePresence mode="wait">
            <motion.p
              key={`subheading-${currentStep}`}
              initial={prefersReducedMotion ? {} : { opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              transition={{ delay: 0.4, duration: 0.6, ease: EASE }}
              className="onboarding-visual-subheading"
            >
              {visualSubheading}
            </motion.p>
          </AnimatePresence>
        </div>

        {/* Step indicators */}
        <motion.div
          initial={prefersReducedMotion ? {} : { opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.6, duration: 0.6 }}
        >
          <StepIndicator currentStep={currentStep} totalSteps={totalSteps} />
        </motion.div>
      </div>

      {/* Right Panel - Form */}
      <div className="onboarding-form-panel">
        <div className="onboarding-form-container">
          {/* Mobile logo */}
          <motion.div
            initial={prefersReducedMotion ? {} : { opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.4 }}
            className="onboarding-mobile-logo"
          >
            <span>
              <Sparkles className="w-4 h-4" />
              {logoText}
            </span>
          </motion.div>

          {/* Progress bar */}
          {showProgress && (
            <ProgressBar currentStep={currentStep} totalSteps={totalSteps} />
          )}

          {/* Content */}
          {children}
        </div>
      </div>
    </div>
  );
}

export { FloatingCard, StepIndicator, ProgressBar };
