"use client";

/**
 * PlatformPreview - Main preview container component
 * Showcases the platform's dashboard with device mockups,
 * interactive hover states, and animated transitions
 */

import { useState, useEffect, useRef } from "react";
import { motion, AnimatePresence, useInView } from "framer-motion";
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import {
  MonitorPlay,
  Smartphone,
  Tablet,
  ArrowRight,
  Sparkles,
  Eye,
  Zap,
  Shield,
  MessageCircle,
  FileCheck,
  Clock,
  ChevronLeft,
  ChevronRight,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { DeviceFrame, DeviceFrameGroup } from "./device-frame";
import { PreviewDashboard, TimelinePreview } from "./preview-dashboard";

// Register GSAP plugin
if (typeof window !== "undefined") {
  gsap.registerPlugin(ScrollTrigger);
}

/**
 * Preview view configuration
 */
const previewViews = [
  {
    id: "dashboard",
    label: "Smart Dashboard",
    description: "Track all your projects in real-time with intelligent insights",
    icon: MonitorPlay,
    component: PreviewDashboard,
    props: { variant: "full" as const },
  },
  {
    id: "chat",
    label: "Expert Chat",
    description: "Communicate directly with experts on your projects",
    icon: MessageCircle,
    component: PreviewDashboard,
    props: { variant: "chat" as const },
  },
  {
    id: "timeline",
    label: "Project Timeline",
    description: "Follow your project's journey from start to finish",
    icon: Clock,
    component: TimelinePreview,
    props: {},
  },
];

/**
 * Feature highlight card
 */
function FeatureCard({
  icon: Icon,
  title,
  description,
  delay = 0,
}: {
  icon: React.ElementType;
  title: string;
  description: string;
  delay?: number;
}) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true }}
      transition={{ duration: 0.5, delay }}
      className="group flex items-start gap-4 p-4 rounded-2xl bg-white/60 dark:bg-slate-800/60 backdrop-blur-sm border border-slate-200/50 dark:border-slate-700/50 hover:border-primary/30 hover:shadow-lg hover:shadow-primary/5 transition-all duration-300"
    >
      <div className="shrink-0 w-12 h-12 rounded-xl bg-gradient-to-br from-primary/20 to-primary/5 flex items-center justify-center group-hover:scale-110 transition-transform duration-300">
        <Icon className="w-6 h-6 text-primary" />
      </div>
      <div>
        <h4 className="font-semibold text-slate-900 dark:text-slate-100 mb-1">
          {title}
        </h4>
        <p className="text-sm text-slate-600 dark:text-slate-400 leading-relaxed">
          {description}
        </p>
      </div>
    </motion.div>
  );
}

/**
 * View selector tabs
 */
function ViewTabs({
  views,
  activeView,
  onViewChange,
}: {
  views: typeof previewViews;
  activeView: string;
  onViewChange: (id: string) => void;
}) {
  return (
    <div className="flex items-center justify-center gap-2 p-1.5 bg-slate-100 dark:bg-slate-800 rounded-full">
      {views.map((view) => {
        const Icon = view.icon;
        const isActive = view.id === activeView;

        return (
          <button
            key={view.id}
            onClick={() => onViewChange(view.id)}
            className={cn(
              "relative flex items-center gap-2 px-4 py-2 rounded-full text-sm font-medium transition-all duration-300",
              isActive
                ? "text-white"
                : "text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-200"
            )}
          >
            {isActive && (
              <motion.div
                layoutId="activeTab"
                className="absolute inset-0 bg-gradient-to-r from-primary to-primary/80 rounded-full shadow-md"
                transition={{ type: "spring", stiffness: 300, damping: 30 }}
              />
            )}
            <span className="relative z-10 flex items-center gap-2">
              <Icon className="w-4 h-4" />
              <span className="hidden sm:inline">{view.label}</span>
            </span>
          </button>
        );
      })}
    </div>
  );
}

/**
 * Mobile carousel navigation
 */
function CarouselNav({
  onPrev,
  onNext,
  canPrev,
  canNext,
}: {
  onPrev: () => void;
  onNext: () => void;
  canPrev: boolean;
  canNext: boolean;
}) {
  return (
    <div className="absolute inset-x-0 top-1/2 -translate-y-1/2 flex items-center justify-between px-2 pointer-events-none md:hidden">
      <button
        onClick={onPrev}
        disabled={!canPrev}
        className={cn(
          "pointer-events-auto w-10 h-10 rounded-full bg-white/90 dark:bg-slate-800/90 backdrop-blur-sm border border-slate-200 dark:border-slate-700 flex items-center justify-center shadow-lg transition-all",
          canPrev ? "opacity-100" : "opacity-30"
        )}
      >
        <ChevronLeft className="w-5 h-5 text-slate-600 dark:text-slate-400" />
      </button>
      <button
        onClick={onNext}
        disabled={!canNext}
        className={cn(
          "pointer-events-auto w-10 h-10 rounded-full bg-white/90 dark:bg-slate-800/90 backdrop-blur-sm border border-slate-200 dark:border-slate-700 flex items-center justify-center shadow-lg transition-all",
          canNext ? "opacity-100" : "opacity-30"
        )}
      >
        <ChevronRight className="w-5 h-5 text-slate-600 dark:text-slate-400" />
      </button>
    </div>
  );
}

/**
 * Floating particles background effect
 */
function FloatingParticles() {
  return (
    <div className="absolute inset-0 overflow-hidden pointer-events-none">
      {[...Array(6)].map((_, i) => (
        <motion.div
          key={i}
          className="absolute w-2 h-2 rounded-full bg-primary/20"
          initial={{
            x: Math.random() * 100 + "%",
            y: Math.random() * 100 + "%",
          }}
          animate={{
            y: [null, "-20%", "120%"],
            x: [null, `${Math.random() * 20 - 10}%`],
            opacity: [0, 1, 0],
          }}
          transition={{
            duration: 8 + Math.random() * 4,
            repeat: Infinity,
            delay: i * 1.5,
            ease: "linear",
          }}
        />
      ))}
    </div>
  );
}

/**
 * PlatformPreview - Main component
 */
export function PlatformPreview() {
  const [activeView, setActiveView] = useState("dashboard");
  const [deviceType, setDeviceType] = useState<"desktop" | "mobile">("desktop");
  const containerRef = useRef<HTMLElement>(null);
  const isInView = useInView(containerRef, { once: true, margin: "-100px" });

  const activeViewConfig = previewViews.find((v) => v.id === activeView);
  const currentIndex = previewViews.findIndex((v) => v.id === activeView);

  const handlePrev = () => {
    if (currentIndex > 0) {
      setActiveView(previewViews[currentIndex - 1].id);
    }
  };

  const handleNext = () => {
    if (currentIndex < previewViews.length - 1) {
      setActiveView(previewViews[currentIndex + 1].id);
    }
  };

  // Auto-rotate views
  useEffect(() => {
    if (!isInView) return;

    const interval = setInterval(() => {
      setActiveView((current) => {
        const currentIdx = previewViews.findIndex((v) => v.id === current);
        const nextIdx = (currentIdx + 1) % previewViews.length;
        return previewViews[nextIdx].id;
      });
    }, 6000);

    return () => clearInterval(interval);
  }, [isInView]);

  return (
    <section
      ref={containerRef}
      id="platform-preview"
      className="relative py-24 md:py-32 lg:py-40 overflow-hidden"
    >
      {/* Background gradient */}
      <div className="absolute inset-0 bg-gradient-to-b from-slate-50 via-white to-slate-50 dark:from-slate-950 dark:via-slate-900 dark:to-slate-950" />

      {/* Decorative blobs */}
      <div className="absolute top-0 left-1/4 w-96 h-96 bg-primary/5 rounded-full blur-3xl" />
      <div className="absolute bottom-0 right-1/4 w-96 h-96 bg-accent/10 rounded-full blur-3xl" />

      {/* Floating particles */}
      <FloatingParticles />

      <div className="container relative px-6 md:px-8 lg:px-12">
        {/* Section header */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="text-center max-w-3xl mx-auto mb-12 md:mb-16"
        >
          <motion.span
            initial={{ opacity: 0, scale: 0.9 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true }}
            transition={{ delay: 0.1 }}
            className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full text-sm font-semibold bg-primary/10 text-primary mb-6"
          >
            <Sparkles className="w-4 h-4" />
            Live Platform Preview
          </motion.span>

          <h2 className="text-4xl md:text-5xl lg:text-6xl font-bold tracking-tight mb-6 text-slate-900 dark:text-white">
            Experience the{" "}
            <span className="bg-gradient-to-r from-primary via-primary/80 to-secondary bg-clip-text text-transparent">
              Dashboard
            </span>
          </h2>

          <p className="text-lg md:text-xl text-slate-600 dark:text-slate-300 leading-relaxed">
            See exactly how you'll manage your projects, communicate with experts,
            and track progress in real-time.
          </p>
        </motion.div>

        {/* View selector */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ delay: 0.2 }}
          className="flex justify-center mb-8"
        >
          <ViewTabs
            views={previewViews}
            activeView={activeView}
            onViewChange={setActiveView}
          />
        </motion.div>

        {/* Device type toggle */}
        <motion.div
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true }}
          transition={{ delay: 0.3 }}
          className="flex justify-center gap-2 mb-8"
        >
          <button
            onClick={() => setDeviceType("desktop")}
            className={cn(
              "flex items-center gap-2 px-3 py-1.5 rounded-lg text-sm font-medium transition-all",
              deviceType === "desktop"
                ? "bg-slate-900 dark:bg-slate-100 text-white dark:text-slate-900"
                : "text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800"
            )}
          >
            <MonitorPlay className="w-4 h-4" />
            Desktop
          </button>
          <button
            onClick={() => setDeviceType("mobile")}
            className={cn(
              "flex items-center gap-2 px-3 py-1.5 rounded-lg text-sm font-medium transition-all",
              deviceType === "mobile"
                ? "bg-slate-900 dark:bg-slate-100 text-white dark:text-slate-900"
                : "text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800"
            )}
          >
            <Smartphone className="w-4 h-4" />
            Mobile
          </button>
        </motion.div>

        {/* Device preview */}
        <div className="relative">
          <AnimatePresence mode="wait">
            <motion.div
              key={`${activeView}-${deviceType}`}
              initial={{ opacity: 0, scale: 0.95, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.95, y: -20 }}
              transition={{ duration: 0.4, ease: [0.16, 1, 0.3, 1] }}
              className="flex justify-center"
            >
              {deviceType === "desktop" ? (
                <DeviceFrame
                  type="desktop"
                  url={`assignx.in/${activeView}`}
                  className="w-full max-w-4xl"
                >
                  <div className="h-[450px] md:h-[500px] overflow-hidden">
                    {activeViewConfig && (
                      <activeViewConfig.component {...activeViewConfig.props} />
                    )}
                  </div>
                </DeviceFrame>
              ) : (
                <DeviceFrame type="mobile" showEffects>
                  <div className="h-[500px] overflow-hidden">
                    {activeViewConfig && (
                      <activeViewConfig.component {...activeViewConfig.props} />
                    )}
                  </div>
                </DeviceFrame>
              )}
            </motion.div>
          </AnimatePresence>

          {/* Mobile carousel navigation */}
          <CarouselNav
            onPrev={handlePrev}
            onNext={handleNext}
            canPrev={currentIndex > 0}
            canNext={currentIndex < previewViews.length - 1}
          />
        </div>

        {/* View description */}
        <motion.div
          key={activeView}
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3 }}
          className="text-center mt-8 mb-12"
        >
          <h3 className="text-xl font-semibold text-slate-900 dark:text-slate-100 mb-2">
            {activeViewConfig?.label}
          </h3>
          <p className="text-slate-600 dark:text-slate-400">
            {activeViewConfig?.description}
          </p>
        </motion.div>

        {/* View indicators */}
        <div className="flex justify-center gap-2 mb-16">
          {previewViews.map((view) => (
            <button
              key={view.id}
              onClick={() => setActiveView(view.id)}
              className={cn(
                "w-2 h-2 rounded-full transition-all duration-300",
                view.id === activeView
                  ? "w-8 bg-primary"
                  : "bg-slate-300 dark:bg-slate-600 hover:bg-slate-400 dark:hover:bg-slate-500"
              )}
            />
          ))}
        </div>

        {/* Feature cards */}
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4 max-w-5xl mx-auto">
          <FeatureCard
            icon={Zap}
            title="Real-time Updates"
            description="Watch your project progress live with instant notifications and status changes."
            delay={0.1}
          />
          <FeatureCard
            icon={MessageCircle}
            title="Direct Communication"
            description="Chat directly with your assigned expert. No middlemen, just results."
            delay={0.2}
          />
          <FeatureCard
            icon={Shield}
            title="Secure & Private"
            description="Bank-grade encryption protects your data. Your privacy is our priority."
            delay={0.3}
          />
        </div>

        {/* CTA */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ delay: 0.4 }}
          className="text-center mt-12"
        >
          <motion.a
            href="/signup"
            className="inline-flex items-center gap-2 px-8 py-4 bg-gradient-to-r from-primary to-primary/80 text-white font-semibold rounded-full shadow-lg shadow-primary/25 hover:shadow-xl hover:shadow-primary/30 transition-all duration-300"
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
          >
            Start Your First Project
            <ArrowRight className="w-5 h-5" />
          </motion.a>
          <p className="mt-4 text-sm text-slate-500 dark:text-slate-400">
            Free to sign up. No credit card required.
          </p>
        </motion.div>
      </div>
    </section>
  );
}

/**
 * PlatformPreviewCompact - Smaller version for inline use
 */
export function PlatformPreviewCompact({
  className,
}: {
  className?: string;
}) {
  return (
    <div className={cn("relative", className)}>
      <DeviceFrame type="desktop" url="assignx.in/dashboard" showEffects>
        <div className="h-[300px] overflow-hidden">
          <PreviewDashboard variant="compact" />
        </div>
      </DeviceFrame>
    </div>
  );
}

/**
 * DualDevicePreview - Shows both desktop and mobile side by side
 */
export function DualDevicePreview() {
  return (
    <DeviceFrameGroup className="scale-75 md:scale-90 lg:scale-100">
      <DeviceFrame type="desktop" url="assignx.in/dashboard" delay={0}>
        <div className="h-[400px] overflow-hidden">
          <PreviewDashboard variant="full" />
        </div>
      </DeviceFrame>
      <DeviceFrame type="mobile" delay={0.2}>
        <div className="h-[500px] overflow-hidden">
          <PreviewDashboard variant="chat" />
        </div>
      </DeviceFrame>
    </DeviceFrameGroup>
  );
}
