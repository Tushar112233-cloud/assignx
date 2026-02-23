/**
 * @fileoverview User Type Cards - Three elegant cards for different user segments
 *
 * Displays service offerings for Students, Professionals, and Businessmen
 * with glassmorphism effects and smooth animations.
 */

"use client";

import { useRef } from "react";
import Link from "next/link";
import {
  motion,
  useReducedMotion,
  useInView,
} from "framer-motion";
import {
  GraduationCap,
  Briefcase,
  Building2,
  ArrowRight,
  BookOpen,
  FileText,
  BarChart3,
  Presentation,
  Search,
  TrendingUp,
  FileSpreadsheet,
  Target,
} from "lucide-react";

import { cn } from "@/lib/utils";
import { ASSIGNX_EASE } from "@/lib/animations/constants";

/**
 * User type configuration
 */
interface UserType {
  id: string;
  title: string;
  description: string;
  icon: React.ElementType;
  gradient: string;
  services: {
    icon: React.ElementType;
    label: string;
  }[];
  cta: string;
  href: string;
}

const userTypes: UserType[] = [
  {
    id: "students",
    title: "Students",
    description: "Academic excellence with expert guidance on assignments, projects, and exam preparation.",
    icon: GraduationCap,
    gradient: "from-[#765341] to-[#5C4233]",
    services: [
      { icon: BookOpen, label: "Assignments & Essays" },
      { icon: FileText, label: "Research Projects" },
      { icon: Target, label: "Exam Preparation" },
    ],
    cta: "Get Started",
    href: "/signup?type=student",
  },
  {
    id: "professionals",
    title: "Professionals",
    description: "Elevate your work with polished reports, compelling presentations, and thorough research.",
    icon: Briefcase,
    gradient: "from-[#34312D] to-[#14110F]",
    services: [
      { icon: FileSpreadsheet, label: "Reports & Analysis" },
      { icon: Presentation, label: "Presentations" },
      { icon: Search, label: "Research & Insights" },
    ],
    cta: "Explore Services",
    href: "/signup?type=professional",
  },
  {
    id: "businessmen",
    title: "Business Owners",
    description: "Strategic support with business plans, proposals, and data-driven analytics.",
    icon: Building2,
    gradient: "from-[#14110F] to-[#34312D]",
    services: [
      { icon: TrendingUp, label: "Business Plans" },
      { icon: FileText, label: "Proposals & Pitches" },
      { icon: BarChart3, label: "Analytics & Reports" },
    ],
    cta: "Scale Your Business",
    href: "/signup?type=business",
  },
];

/**
 * Individual user type card component
 */
function UserTypeCard({
  userType,
  index,
}: {
  userType: UserType;
  index: number;
}) {
  const ref = useRef<HTMLDivElement>(null);
  const isInView = useInView(ref, { once: true, amount: 0.3 });
  const prefersReducedMotion = useReducedMotion();

  const Icon = userType.icon;

  return (
    <motion.div
      ref={ref}
      initial={prefersReducedMotion ? false : { opacity: 0, y: 40 }}
      animate={isInView ? { opacity: 1, y: 0 } : {}}
      transition={{
        delay: index * 0.15,
        duration: 0.6,
        ease: ASSIGNX_EASE,
      }}
      className="group relative"
    >
      {/* Card */}
      <div
        className={cn(
          "relative overflow-hidden rounded-2xl",
          "bg-white/70 backdrop-blur-xl",
          "border border-[var(--landing-border)]",
          "p-6 sm:p-8",
          "transition-all duration-500 ease-out",
          "hover:border-[var(--landing-accent-light)]",
          "hover:shadow-[0_20px_60px_-15px_rgba(20,17,15,0.15)]",
          "hover:-translate-y-2"
        )}
      >
        {/* Gradient accent on hover */}
        <div
          className={cn(
            "absolute inset-0 opacity-0 transition-opacity duration-500",
            "group-hover:opacity-5",
            `bg-gradient-to-br ${userType.gradient}`
          )}
        />

        {/* Icon */}
        <div
          className={cn(
            "relative w-14 h-14 rounded-xl mb-6",
            "flex items-center justify-center",
            `bg-gradient-to-br ${userType.gradient}`,
            "transition-transform duration-500 group-hover:scale-110"
          )}
        >
          <Icon className="w-7 h-7 text-white" />
        </div>

        {/* Content */}
        <div className="relative space-y-4">
          <h3 className="landing-heading-sm text-[var(--landing-text-primary)]">
            {userType.title}
          </h3>

          <p className="text-[var(--landing-text-secondary)] leading-relaxed">
            {userType.description}
          </p>

          {/* Services list */}
          <ul className="space-y-3 pt-2">
            {userType.services.map((service, i) => (
              <motion.li
                key={service.label}
                initial={prefersReducedMotion ? false : { opacity: 0, x: -10 }}
                animate={isInView ? { opacity: 1, x: 0 } : {}}
                transition={{
                  delay: index * 0.15 + 0.3 + i * 0.1,
                  duration: 0.4,
                  ease: ASSIGNX_EASE,
                }}
                className="flex items-center gap-3 text-sm text-[var(--landing-text-secondary)]"
              >
                <div className="w-8 h-8 rounded-lg bg-[var(--landing-accent-lighter)] flex items-center justify-center flex-shrink-0">
                  <service.icon className="w-4 h-4 text-[var(--landing-accent-primary)]" />
                </div>
                <span>{service.label}</span>
              </motion.li>
            ))}
          </ul>

          {/* CTA */}
          <Link
            href={userType.href}
            className={cn(
              "inline-flex items-center gap-2 mt-4 pt-4",
              "text-[var(--landing-accent-primary)] font-medium",
              "transition-all duration-300",
              "group/link hover:gap-3"
            )}
          >
            {userType.cta}
            <ArrowRight className="w-4 h-4 transition-transform duration-300 group-hover/link:translate-x-1" />
          </Link>
        </div>
      </div>
    </motion.div>
  );
}

/**
 * User Type Cards Section
 */
export function UserTypeCards() {
  const ref = useRef<HTMLElement>(null);
  const isInView = useInView(ref, { once: true, amount: 0.2 });
  const prefersReducedMotion = useReducedMotion();

  return (
    <section
      ref={ref}
      className="relative py-20 sm:py-28"
      style={{ background: "var(--landing-bg-secondary)" }}
    >
      {/* Top separator line */}
      <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-[var(--landing-border)] to-transparent" />

      {/* Subtle background pattern */}
      <div className="absolute inset-0 landing-grid-pattern opacity-30" />

      <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6">
        {/* Section header */}
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0, y: 20 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, ease: ASSIGNX_EASE }}
          className="text-center max-w-2xl mx-auto mb-14 sm:mb-16"
        >
          <span className="landing-badge landing-badge-secondary inline-flex items-center gap-2 mb-4">
            For Everyone
          </span>
          <h2 className="landing-heading-lg text-[var(--landing-text-primary)] mb-4">
            Tailored for your needs
          </h2>
          <p className="text-lg text-[var(--landing-text-secondary)]">
            Whether you&apos;re a student, professional, or business owner,
            we have the right experts ready to help you succeed.
          </p>
        </motion.div>

        {/* Cards grid */}
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6 lg:gap-8">
          {userTypes.map((userType, index) => (
            <UserTypeCard key={userType.id} userType={userType} index={index} />
          ))}
        </div>
      </div>
    </section>
  );
}
