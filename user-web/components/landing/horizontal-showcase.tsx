/**
 * @fileoverview Interactive Process Showcase - Unique micro-interactions
 *
 * Creative timeline with hover-activated animations and visual storytelling.
 * Features card flips, particle effects, and dynamic content reveals.
 */

"use client";

import { useRef, useState } from "react";
import { useReducedMotion, useInView, motion } from "framer-motion";
import {
  Upload,
  Sparkles,
  MessageSquare,
  CheckCircle2,
  ArrowRight,
  Clock,
  Users,
  Zap,
  Target
} from "lucide-react";
import { cn } from "@/lib/utils";
import "@/app/landing.css";

interface ProcessStep {
  id: string;
  number: string;
  title: string;
  description: string;
  icon: React.ElementType;
  stats: { value: string; label: string }[];
  features: string[];
}

const processSteps: ProcessStep[] = [
  {
    id: "submit",
    number: "01",
    title: "Submit Your Project",
    description: "Upload your requirements in under 2 minutes. Our AI analyzes and matches you with the perfect expert.",
    icon: Upload,
    stats: [
      { value: "2min", label: "Quick Setup" },
      { value: "100+", label: "Subjects" },
    ],
    features: [
      "Instant file upload",
      "Smart requirement analysis",
      "Flexible deadlines",
    ],
  },
  {
    id: "match",
    number: "02",
    title: "Expert Matching",
    description: "AI-powered matching connects you with verified experts in your subject within seconds.",
    icon: Sparkles,
    stats: [
      { value: "15sec", label: "Match Time" },
      { value: "500+", label: "Experts" },
    ],
    features: [
      "PhD-verified experts",
      "Subject specialists",
      "Real-time availability",
    ],
  },
  {
    id: "collaborate",
    number: "03",
    title: "Live Collaboration",
    description: "Stay connected throughout. Chat, request revisions, and track progress in real-time.",
    icon: MessageSquare,
    stats: [
      { value: "24/7", label: "Support" },
      { value: "∞", label: "Revisions" },
    ],
    features: [
      "Live chat system",
      "Progress tracking",
      "Unlimited feedback",
    ],
  },
  {
    id: "deliver",
    number: "04",
    title: "Quality Delivery",
    description: "Receive plagiarism-free, high-quality work before your deadline. Guaranteed.",
    icon: CheckCircle2,
    stats: [
      { value: "98%", label: "On-Time" },
      { value: "4.9★", label: "Rating" },
    ],
    features: [
      "Plagiarism checked",
      "Quality assured",
      "On-time guarantee",
    ],
  },
];

interface StepCardProps {
  step: ProcessStep;
  index: number;
  isActive: boolean;
  onHover: (id: string | null) => void;
}

function StepCard({ step, index, isActive, onHover }: StepCardProps) {
  const ref = useRef<HTMLDivElement>(null);
  const isInView = useInView(ref, { once: true, amount: 0.3 });
  const prefersReducedMotion = useReducedMotion();
  const Icon = step.icon;

  return (
    <motion.div
      ref={ref}
      initial={prefersReducedMotion ? false : { opacity: 0, y: 60, scale: 0.9 }}
      animate={isInView ? { opacity: 1, y: 0, scale: 1 } : {}}
      transition={{
        delay: index * 0.15,
        duration: 0.7,
        ease: [0.16, 1, 0.3, 1],
      }}
      onMouseEnter={() => onHover(step.id)}
      onMouseLeave={() => onHover(null)}
      className={cn(
        "landing-card group relative overflow-hidden transition-all duration-500 landing-spotlight",
        isActive && "scale-[1.02] shadow-2xl border-[var(--landing-accent-primary)]"
      )}
    >
      {/* Gradient overlay on hover */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: isActive ? 1 : 0 }}
        className="absolute inset-0 bg-gradient-to-br from-[var(--landing-accent-primary)]/5 to-transparent pointer-events-none"
      />

      {/* Content */}
      <div className="relative z-10">
        {/* Header with number and icon */}
        <div className="flex items-start justify-between mb-6">
          <motion.div
            animate={isActive && !prefersReducedMotion ? { rotate: [0, -10, 10, 0] } : {}}
            transition={{ duration: 0.5 }}
            className={cn(
              "w-16 h-16 rounded-2xl flex items-center justify-center transition-all duration-500",
              isActive
                ? "bg-gradient-to-br from-[var(--landing-accent-primary)] to-[var(--landing-accent-secondary)] shadow-lg"
                : "bg-[var(--landing-accent-lighter)]"
            )}
          >
            <Icon className={cn("w-8 h-8 transition-colors duration-500", isActive ? "text-white" : "text-[var(--landing-accent-primary)]")} />
          </motion.div>

          <span className={cn(
            "text-5xl font-black tabular-nums transition-all duration-500",
            isActive ? "text-[var(--landing-accent-primary)]" : "text-[var(--landing-accent-light)]"
          )}>
            {step.number}
          </span>
        </div>

        {/* Title and description */}
        <div className="mb-6">
          <h3 className="text-2xl font-bold text-[var(--landing-text-primary)] mb-3 landing-heading">
            {step.title}
          </h3>
          <p className="text-[var(--landing-text-secondary)] leading-relaxed">
            {step.description}
          </p>
        </div>

        {/* Stats */}
        <div className="flex gap-4 mb-6">
          {step.stats.map((stat, i) => (
            <motion.div
              key={stat.label}
              initial={{ opacity: 0, x: -20 }}
              animate={isInView ? { opacity: 1, x: 0 } : {}}
              transition={{ delay: index * 0.15 + 0.3 + i * 0.1, duration: 0.5 }}
              className="flex-1 p-3 rounded-xl bg-[var(--landing-accent-lighter)] border border-[var(--landing-border)]"
            >
              <div className="text-xl font-bold text-[var(--landing-accent-primary)] tabular-nums">
                {stat.value}
              </div>
              <div className="text-xs text-[var(--landing-text-muted)] uppercase tracking-wider mt-1">
                {stat.label}
              </div>
            </motion.div>
          ))}
        </div>

        {/* Features list - revealed on hover */}
        <motion.div
          initial={{ height: 0, opacity: 0 }}
          animate={isActive ? { height: "auto", opacity: 1 } : { height: 0, opacity: 0 }}
          transition={{ duration: 0.4, ease: [0.16, 1, 0.3, 1] }}
          className="overflow-hidden"
        >
          <div className="pt-4 border-t border-[var(--landing-border)] space-y-2">
            {step.features.map((feature, i) => (
              <motion.div
                key={feature}
                initial={{ x: -20, opacity: 0 }}
                animate={isActive ? { x: 0, opacity: 1 } : { x: -20, opacity: 0 }}
                transition={{ delay: i * 0.05, duration: 0.3 }}
                className="flex items-center gap-2 text-sm text-[var(--landing-text-secondary)]"
              >
                <CheckCircle2 className="w-4 h-4 text-[var(--landing-accent-primary)] flex-shrink-0" />
                {feature}
              </motion.div>
            ))}
          </div>
        </motion.div>
      </div>

      {/* Hover arrow indicator */}
      <motion.div
        initial={{ opacity: 0, x: -10 }}
        animate={isActive ? { opacity: 1, x: 0 } : { opacity: 0, x: -10 }}
        className="absolute bottom-6 right-6"
      >
        <ArrowRight className="w-6 h-6 text-[var(--landing-accent-primary)]" />
      </motion.div>
    </motion.div>
  );
}

// Floating feature badges
function FeatureBadge({
  icon: Icon,
  label,
  delay = 0
}: {
  icon: React.ElementType;
  label: string;
  delay?: number;
}) {
  const ref = useRef<HTMLDivElement>(null);
  const isInView = useInView(ref, { once: true, amount: 0.8 });
  const prefersReducedMotion = useReducedMotion();

  return (
    <motion.div
      ref={ref}
      initial={prefersReducedMotion ? false : { opacity: 0, y: 30, scale: 0.8 }}
      animate={isInView ? { opacity: 1, y: 0, scale: 1 } : {}}
      transition={{
        delay,
        duration: 0.6,
        ease: [0.16, 1, 0.3, 1],
      }}
      className="landing-card inline-flex items-center gap-3 px-5 py-3 landing-hover-scale"
    >
      <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-[var(--landing-accent-primary)] to-[var(--landing-accent-secondary)] flex items-center justify-center">
        <Icon className="w-5 h-5 text-white" />
      </div>
      <span className="font-semibold text-[var(--landing-text-primary)]">{label}</span>
    </motion.div>
  );
}

export function HorizontalShowcase() {
  const [activeStep, setActiveStep] = useState<string | null>(null);
  const sectionRef = useRef<HTMLDivElement>(null);
  const isInView = useInView(sectionRef, { once: true, amount: 0.2 });
  const prefersReducedMotion = useReducedMotion();

  return (
    <section
      ref={sectionRef}
      className="relative py-24 sm:py-32 bg-[var(--landing-bg-secondary)] overflow-hidden"
    >
      {/* Background decorations */}
      <div className="absolute inset-0 landing-grid-pattern opacity-30" />
      <div className="landing-shape-blob absolute top-[20%] right-[5%] w-[600px] h-[600px] bg-[var(--landing-accent-primary)]" />
      <div className="landing-shape-blob absolute bottom-[10%] left-[10%] w-[500px] h-[500px] bg-[var(--landing-accent-secondary)]" />

      <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6">
        {/* Section Header */}
        <div className="text-center mb-20">
          <motion.div
            initial={prefersReducedMotion ? false : { opacity: 0, y: 30 }}
            animate={isInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
          >
            <span className="landing-badge landing-badge-secondary inline-flex items-center gap-2 mb-6">
              <Zap className="w-3.5 h-3.5" />
              How It Works
            </span>

            <h2 className="landing-heading landing-heading-lg text-[var(--landing-text-primary)] mb-6">
              Four steps to
              <br />
              <span className="landing-text-gradient-animated">academic success</span>
            </h2>

            <p className="text-lg text-[var(--landing-text-secondary)] max-w-2xl mx-auto">
              Our streamlined process gets you from stress to success in minutes.
              <br />
              Hover over each step to explore the details.
            </p>
          </motion.div>
        </div>

        {/* Process Cards Grid */}
        <div className="grid md:grid-cols-2 gap-8 mb-20">
          {processSteps.map((step, index) => (
            <StepCard
              key={step.id}
              step={step}
              index={index}
              isActive={activeStep === step.id}
              onHover={setActiveStep}
            />
          ))}
        </div>

        {/* Bottom Feature Badges */}
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0 }}
          animate={isInView ? { opacity: 1 } : {}}
          transition={{ delay: 0.8, duration: 1 }}
          className="flex flex-wrap justify-center items-center gap-4"
        >
          <FeatureBadge icon={Clock} label="24/7 Support" delay={0.9} />
          <FeatureBadge icon={Users} label="500+ Experts" delay={1.0} />
          <FeatureBadge icon={Target} label="98% Success Rate" delay={1.1} />
        </motion.div>
      </div>
    </section>
  );
}
