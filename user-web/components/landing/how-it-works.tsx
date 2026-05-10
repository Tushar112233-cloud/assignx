"use client";

/**
 * HowItWorks - Step-by-step process section with realistic device mockups
 * Features GSAP line drawing, step reveals, and actual dashboard previews in browser frames
 */

import { useEffect, useRef } from "react";
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { motion } from "framer-motion";
import { Upload, Users, FileCheck, Download, ArrowRight, Clock, MessageSquare, CheckCircle2, Sparkles } from "lucide-react";

import { cn } from "@/lib/utils";
import { easings } from "@/lib/gsap/animations";

// Register plugin
if (typeof window !== "undefined") {
  gsap.registerPlugin(ScrollTrigger);
}

const steps = [
  {
    number: "01",
    title: "Submit Your Project",
    description:
      "Tell us about your project requirements. Upload any reference materials and set your deadline.",
    icon: Upload,
    color: "from-[#765341] to-[#5C4233]",
    preview: "submit",
  },
  {
    number: "02",
    title: "Get a supervisor",
    description:
      "Our supervisor gets the work done from the expert for you as per your requirements.",
    icon: Users,
    color: "from-[#5C4233] to-[#34312D]",
    preview: "match",
  },
  {
    number: "03",
    title: "Review Progress",
    description:
      "Track your project in real-time. Communicate directly with your expert and request changes.",
    icon: FileCheck,
    color: "from-[#A07A65] to-[#765341]",
    preview: "progress",
  },
  {
    number: "04",
    title: "Download & Succeed",
    description:
      "Receive your completed work, reviewed for quality. Unlimited revisions until you're satisfied.",
    icon: Download,
    color: "from-[#E4E1C7] to-[#A07A65]",
    preview: "complete",
  },
];

/**
 * Browser Chrome Component - Realistic browser frame
 */
function BrowserChrome({ url = "assignx.in" }: { url?: string }) {
  return (
    <div className="flex items-center gap-2 px-3 py-2 bg-gradient-to-b from-slate-100 to-slate-50 dark:from-slate-800 dark:to-slate-900 border-b border-slate-200 dark:border-slate-700 rounded-t-lg">
      {/* Traffic lights */}
      <div className="flex items-center gap-1.5">
        <div className="w-2.5 h-2.5 rounded-full bg-red-400" />
        <div className="w-2.5 h-2.5 rounded-full bg-yellow-400" />
        <div className="w-2.5 h-2.5 rounded-full bg-green-400" />
      </div>

      {/* URL bar */}
      <div className="flex-1 mx-3">
        <div className="flex items-center gap-1.5 px-2 py-1 bg-white dark:bg-slate-800 rounded text-[10px] text-slate-500">
          <div className="w-2.5 h-2.5 rounded-full bg-green-500 flex-shrink-0" />
          <span className="truncate">{url}</span>
        </div>
      </div>
    </div>
  );
}

/**
 * Step preview component - Shows realistic mockups for each step
 */
function StepPreview({ type }: { type: string }) {
  switch (type) {
    case "submit":
      return (
        <div className="rounded-lg overflow-hidden border border-slate-200 dark:border-slate-700 shadow-xl bg-white dark:bg-slate-900">
          <BrowserChrome url="assignx.in/new-project" />
          <div className="p-4 bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-950">
            {/* Project Form Mockup */}
            <div className="space-y-3">
              <div className="text-sm font-semibold text-slate-800 dark:text-slate-200">New Project</div>

              {/* Form fields */}
              <div className="space-y-2">
                <div className="h-8 bg-white dark:bg-slate-800 rounded border border-slate-200 dark:border-slate-700 flex items-center px-2">
                  <span className="text-[10px] text-slate-400">Project Title</span>
                </div>
                <div className="h-16 bg-white dark:bg-slate-800 rounded border border-slate-200 dark:border-slate-700 flex items-start px-2 pt-1">
                  <span className="text-[10px] text-slate-400">Description...</span>
                </div>
                <div className="flex gap-2">
                  <div className="flex-1 h-8 bg-white dark:bg-slate-800 rounded border border-slate-200 dark:border-slate-700 flex items-center px-2">
                    <Clock className="w-3 h-3 text-slate-400 mr-1" />
                    <span className="text-[10px] text-slate-400">Deadline</span>
                  </div>
                  <div className="flex-1 h-8 bg-white dark:bg-slate-800 rounded border border-slate-200 dark:border-slate-700 flex items-center px-2">
                    <span className="text-[10px] text-slate-400">Budget</span>
                  </div>
                </div>
              </div>

              {/* Upload area */}
              <motion.div
                className="border-2 border-dashed border-[#765341]/30 rounded-lg p-3 text-center bg-[#765341]/5"
                animate={{ borderColor: ["rgba(118,83,65,0.2)", "rgba(118,83,65,0.5)", "rgba(118,83,65,0.2)"] }}
                transition={{ duration: 2, repeat: Infinity }}
              >
                <Upload className="w-5 h-5 text-[#765341] mx-auto mb-1" />
                <span className="text-[9px] text-[#765341]">Upload files</span>
              </motion.div>

              {/* Submit button */}
              <motion.div
                className="h-8 bg-gradient-to-r from-[#765341] to-[#5C4233] rounded flex items-center justify-center cursor-pointer"
                whileHover={{ scale: 1.02 }}
              >
                <span className="text-[11px] text-white font-medium flex items-center gap-1">
                  Submit Project <ArrowRight className="w-3 h-3" />
                </span>
              </motion.div>
            </div>
          </div>
        </div>
      );

    case "match":
      return (
        <div className="rounded-lg overflow-hidden border border-slate-200 dark:border-slate-700 shadow-xl bg-white dark:bg-slate-900">
          <BrowserChrome url="assignx.in/matching" />
          <div className="p-4 bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-950">
            {/* Matching Animation */}
            <div className="text-sm font-semibold text-slate-800 dark:text-slate-200 mb-3">Finding Your Expert</div>

            {/* Expert cards */}
            <div className="space-y-2">
              {[
                { name: "Dr. Sarah K.", expertise: "Research & Writing", rating: 4.9, match: 98 },
                { name: "Prof. Michael R.", expertise: "Data Analysis", rating: 4.8, match: 92 },
                { name: "Dr. Emily T.", expertise: "Technical Writing", rating: 4.9, match: 87 },
              ].map((expert, i) => (
                <motion.div
                  key={expert.name}
                  className={cn(
                    "flex items-center gap-2 p-2 rounded-lg border transition-all",
                    i === 0
                      ? "border-[#765341] bg-[#765341]/5 shadow-md"
                      : "border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800"
                  )}
                  initial={{ opacity: 0, x: -10 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: i * 0.15 }}
                >
                  <div className="w-8 h-8 rounded-full bg-gradient-to-br from-[#765341] to-[#A07A65] flex items-center justify-center text-white text-[10px] font-bold">
                    {expert.name.split(' ').map(n => n[0]).join('')}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="text-[11px] font-medium text-slate-800 dark:text-slate-200 truncate">{expert.name}</div>
                    <div className="text-[9px] text-slate-500">{expert.expertise}</div>
                  </div>
                  <div className="text-right">
                    <div className="text-[10px] font-bold text-[#765341]">{expert.match}%</div>
                    <div className="text-[8px] text-slate-400">match</div>
                  </div>
                </motion.div>
              ))}
            </div>

            {/* Best match indicator */}
            <motion.div
              className="mt-3 flex items-center justify-center gap-1 text-[10px] text-[#765341] font-medium"
              animate={{ opacity: [0.5, 1, 0.5] }}
              transition={{ duration: 1.5, repeat: Infinity }}
            >
              <Sparkles className="w-3 h-3" />
              Best Match Found!
            </motion.div>
          </div>
        </div>
      );

    case "progress":
      return (
        <div className="rounded-lg overflow-hidden border border-slate-200 dark:border-slate-700 shadow-xl bg-white dark:bg-slate-900">
          <BrowserChrome url="assignx.in/dashboard" />
          <div className="p-4 bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-950">
            {/* Dashboard Preview */}
            <div className="flex items-center justify-between mb-3">
              <div className="text-sm font-semibold text-slate-800 dark:text-slate-200">Project Dashboard</div>
              <div className="flex items-center gap-1 text-[9px] text-green-600 bg-green-50 px-2 py-0.5 rounded-full">
                <span className="w-1.5 h-1.5 rounded-full bg-green-500 animate-pulse" />
                Live
              </div>
            </div>

            {/* Progress bar */}
            <div className="mb-3">
              <div className="flex justify-between text-[9px] text-slate-500 mb-1">
                <span>Progress</span>
                <span className="font-medium text-[#765341]">67%</span>
              </div>
              <div className="h-2 bg-slate-200 dark:bg-slate-700 rounded-full overflow-hidden">
                <motion.div
                  className="h-full bg-gradient-to-r from-[#765341] to-[#A07A65] rounded-full"
                  initial={{ width: 0 }}
                  animate={{ width: "67%" }}
                  transition={{ duration: 1.5, ease: "easeOut" }}
                />
              </div>
            </div>

            {/* Chat preview */}
            <div className="bg-white dark:bg-slate-800 rounded-lg p-2 border border-slate-100 dark:border-slate-700">
              <div className="flex items-center gap-2 mb-2">
                <MessageSquare className="w-3 h-3 text-[#765341]" />
                <span className="text-[10px] font-medium text-slate-700 dark:text-slate-300">Expert Chat</span>
              </div>
              <div className="space-y-1.5">
                <div className="flex gap-1">
                  <div className="w-5 h-5 rounded-full bg-[#765341] flex-shrink-0 flex items-center justify-center">
                    <span className="text-[8px] text-white">SK</span>
                  </div>
                  <div className="bg-slate-100 dark:bg-slate-700 rounded-lg rounded-bl-none px-2 py-1 text-[9px] text-slate-600 dark:text-slate-300">
                    Great progress! I'll have draft ready by tomorrow.
                  </div>
                </div>
                <motion.div
                  className="flex gap-1 justify-end"
                  initial={{ opacity: 0, y: 5 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.5 }}
                >
                  <div className="bg-[#765341] rounded-lg rounded-br-none px-2 py-1 text-[9px] text-white">
                    Perfect, thanks! 👍
                  </div>
                </motion.div>
              </div>
            </div>

            {/* Status pills */}
            <div className="flex gap-1.5 mt-3">
              {[
                { label: "On Track", color: "bg-green-100 text-green-700" },
                { label: "2 days left", color: "bg-blue-100 text-blue-700" },
              ].map((pill) => (
                <span key={pill.label} className={cn("text-[8px] font-medium px-2 py-0.5 rounded-full", pill.color)}>
                  {pill.label}
                </span>
              ))}
            </div>
          </div>
        </div>
      );

    case "complete":
      return (
        <div className="rounded-lg overflow-hidden border border-slate-200 dark:border-slate-700 shadow-xl bg-white dark:bg-slate-900">
          <BrowserChrome url="assignx.in/project/complete" />
          <div className="p-4 bg-gradient-to-br from-green-50 to-emerald-50 dark:from-slate-900 dark:to-slate-950">
            {/* Completion Screen */}
            <div className="text-center">
              <motion.div
                className="w-14 h-14 rounded-full bg-gradient-to-br from-green-500 to-emerald-500 flex items-center justify-center mx-auto mb-3 shadow-lg"
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ type: "spring", stiffness: 200 }}
              >
                <motion.div
                  initial={{ pathLength: 0 }}
                  animate={{ pathLength: 1 }}
                  transition={{ duration: 0.5, delay: 0.3 }}
                >
                  <CheckCircle2 className="w-7 h-7 text-white" />
                </motion.div>
              </motion.div>

              <div className="text-sm font-bold text-slate-800 dark:text-slate-200 mb-1">
                Project Complete!
              </div>
              <div className="text-[10px] text-slate-500 mb-4">
                Quality verified & ready to download
              </div>

              {/* File card */}
              <div className="bg-white dark:bg-slate-800 rounded-lg p-3 border border-slate-100 dark:border-slate-700 mb-3">
                <div className="flex items-center gap-2">
                  <div className="w-8 h-8 rounded bg-[#765341]/10 flex items-center justify-center">
                    <FileCheck className="w-4 h-4 text-[#765341]" />
                  </div>
                  <div className="flex-1 text-left">
                    <div className="text-[11px] font-medium text-slate-800 dark:text-slate-200">Research_Paper_Final.pdf</div>
                    <div className="text-[9px] text-slate-500">2.4 MB • Quality Verified</div>
                  </div>
                </div>
              </div>

              {/* Download button */}
              <motion.div
                className="h-9 bg-gradient-to-r from-[#765341] to-[#5C4233] rounded-lg flex items-center justify-center cursor-pointer shadow-lg"
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
              >
                <Download className="w-4 h-4 text-white mr-1.5" />
                <span className="text-[11px] text-white font-medium">Download Now</span>
              </motion.div>

              {/* Rating prompt */}
              <div className="mt-3 flex items-center justify-center gap-0.5">
                {[1, 2, 3, 4, 5].map((star) => (
                  <motion.div
                    key={star}
                    initial={{ opacity: 0, scale: 0 }}
                    animate={{ opacity: 1, scale: 1 }}
                    transition={{ delay: 0.5 + star * 0.1 }}
                  >
                    <svg className="w-4 h-4 text-yellow-400" fill="currentColor" viewBox="0 0 20 20">
                      <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                    </svg>
                  </motion.div>
                ))}
              </div>
            </div>
          </div>
        </div>
      );

    default:
      return null;
  }
}

export function HowItWorks() {
  const containerRef = useRef<HTMLElement>(null);
  const headingRef = useRef<HTMLDivElement>(null);
  const stepsRef = useRef<HTMLDivElement>(null);
  const lineRef = useRef<SVGPathElement>(null);

  useEffect(() => {
    const ctx = gsap.context(() => {
      // Heading animation
      gsap.fromTo(
        headingRef.current,
        { opacity: 0, y: 50 },
        {
          opacity: 1,
          y: 0,
          duration: 1,
          ease: easings.smooth,
          scrollTrigger: {
            trigger: headingRef.current,
            start: "top 85%",
            toggleActions: "play none none none",
          },
        }
      );

      // Line drawing animation
      if (lineRef.current) {
        const lineLength = lineRef.current.getTotalLength();
        gsap.set(lineRef.current, {
          strokeDasharray: lineLength,
          strokeDashoffset: lineLength,
        });

        gsap.to(lineRef.current, {
          strokeDashoffset: 0,
          duration: 2,
          ease: "none",
          scrollTrigger: {
            trigger: stepsRef.current,
            start: "top 60%",
            end: "bottom 40%",
            scrub: 1,
          },
        });
      }

      // Steps animation
      const stepCards = stepsRef.current?.querySelectorAll(".step-card");
      if (stepCards) {
        stepCards.forEach((card, index) => {
          gsap.fromTo(
            card,
            { opacity: 0, x: index % 2 === 0 ? -60 : 60 },
            {
              opacity: 1,
              x: 0,
              duration: 1,
              ease: easings.smooth,
              scrollTrigger: {
                trigger: card,
                start: "top 85%",
                toggleActions: "play none none none",
              },
            }
          );
        });
      }
    }, containerRef);

    // Refresh ScrollTrigger on hash navigation so animations fire
    const handleHashChange = () => {
      setTimeout(() => ScrollTrigger.refresh(), 100);
    };
    window.addEventListener("hashchange", handleHashChange);

    // Also refresh after initial load in case page was loaded with a hash
    if (window.location.hash === "#how-it-works") {
      setTimeout(() => ScrollTrigger.refresh(), 300);
    }

    return () => {
      ctx.revert();
      window.removeEventListener("hashchange", handleHashChange);
    };
  }, []);

  return (
    <section
      ref={containerRef}
      id="how-it-works"
      className="relative py-24 md:py-32 lg:py-40 overflow-hidden bg-transparent"
    >
      <div className="container px-6 md:px-8 lg:px-12">
        {/* Heading */}
        <div ref={headingRef} className="text-center max-w-3xl mx-auto mb-16 md:mb-24">
          <span className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[var(--landing-accent-lighter)] border border-[var(--landing-border)] mb-6">
            <span className="w-2 h-2 rounded-full bg-[var(--landing-accent-primary)]" />
            <span className="text-sm font-medium text-[var(--landing-text-secondary)]">
              How It Works
            </span>
          </span>
          <h2 className="landing-heading-lg text-[var(--landing-text-primary)] mb-6">
            Simple Steps to{" "}
            <span className="landing-text-gradient">
              Get Started
            </span>
          </h2>
          <p className="text-lg md:text-xl text-[var(--landing-text-secondary)] leading-relaxed">
            Getting expert help is easy. Follow these four simple steps and
            let us handle the rest.
          </p>
        </div>

        {/* Steps */}
        <div ref={stepsRef} className="relative max-w-6xl mx-auto">
          {/* Connecting line (desktop) */}
          <svg
            className="absolute left-1/2 top-0 bottom-0 -translate-x-1/2 h-full w-2 hidden lg:block"
            viewBox="0 0 4 800"
            preserveAspectRatio="none"
          >
            <path
              ref={lineRef}
              d="M2 0 L2 800"
              stroke="url(#lineGradient)"
              strokeWidth="3"
              fill="none"
              strokeLinecap="round"
            />
            <defs>
              <linearGradient id="lineGradient" x1="0%" y1="0%" x2="0%" y2="100%">
                <stop offset="0%" stopColor="#765341" />
                <stop offset="50%" stopColor="#A07A65" />
                <stop offset="100%" stopColor="#E4E1C7" />
              </linearGradient>
            </defs>
          </svg>

          {/* Step cards with browser mockups */}
          <div className="space-y-16 md:space-y-24">
            {steps.map((step, index) => {
              const Icon = step.icon;
              const isEven = index % 2 === 0;

              return (
                <div
                  key={step.number}
                  className={cn(
                    "step-card relative flex flex-col lg:flex-row items-center gap-8 lg:gap-16",
                    isEven ? "lg:flex-row" : "lg:flex-row-reverse"
                  )}
                >
                  {/* Content */}
                  <div
                    className={cn(
                      "flex-1",
                      isEven ? "lg:text-right" : "lg:text-left"
                    )}
                  >
                    <div
                      className={cn(
                        "inline-block px-4 py-1.5 rounded-full text-sm font-bold mb-4",
                        `bg-gradient-to-r ${step.color} text-white shadow-lg`
                      )}
                    >
                      Step {step.number}
                    </div>
                    <h3 className="text-2xl md:text-3xl lg:text-4xl font-bold mb-4 text-[var(--landing-text-primary)]">
                      {step.title}
                    </h3>
                    <p className="text-lg text-[var(--landing-text-secondary)] max-w-md leading-relaxed">
                      {step.description}
                    </p>
                  </div>

                  {/* Icon circle (mobile/tablet) */}
                  <div className="relative z-10 lg:hidden">
                    <div
                      className={cn(
                        "w-20 h-20 rounded-full flex items-center justify-center",
                        "bg-[var(--landing-bg-elevated)] border-4 border-[#765341]",
                        "shadow-xl"
                      )}
                    >
                      <Icon className="size-8 text-[#765341]" />
                    </div>
                  </div>

                  {/* Browser mockup preview (desktop) */}
                  <div className="flex-1 hidden lg:block">
                    <motion.div
                      className="relative"
                      initial={{ opacity: 0, scale: 0.95 }}
                      whileInView={{ opacity: 1, scale: 1 }}
                      viewport={{ once: true }}
                      transition={{ duration: 0.6, delay: 0.2 }}
                    >
                      <div className="relative max-w-[380px] mx-auto">
                        <StepPreview type={step.preview} />
                      </div>
                      {/* Decorative glow */}
                      <div className="absolute -inset-4 rounded-3xl opacity-30 blur-xl -z-10 bg-gradient-to-br from-[var(--landing-accent-primary)]/20 to-[var(--landing-accent-light)]/10" />
                    </motion.div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </div>
    </section>
  );
}
