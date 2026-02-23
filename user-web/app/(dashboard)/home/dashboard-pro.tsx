"use client";

/**
 * Dashboard Pro - Premium Design System
 * Unique bento cards with individual personalities
 * Responsive asymmetric grid layout
 */

import { useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import {
  Plus,
  CheckCircle,
  Sparkles,
  ChevronRight,
  GraduationCap,
  ArrowRight,
  Shield,
  Zap,
  FileText,
  Users,
  Star,
  TrendingUp,
  Home,
  Calendar,
  BookOpen,
  ShoppingBag,
  MessageCircle,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { useUserStore } from "@/stores/user-store";
import { useProjectStore } from "@/stores";
import { SkeletonBox, SkeletonText } from "@/components/skeletons/primitives";
import { QuickStats } from "@/components/dashboard/quick-stats";
import { GreetingAnimation } from "@/components/dashboard/greeting-animation";

/**
 * Status configuration with consistent neutral theme
 */
/**
 * Campus Connect carousel items
 */
const CAMPUS_CONNECT_ITEMS = [
  {
    id: "housing",
    icon: Home,
    title: "Student Housing",
    description: "Find your perfect place",
    gradient: "from-rose-400 to-pink-500",
    bgGradient: "from-rose-100/40 to-pink-50/20 dark:from-rose-900/10",
  },
  {
    id: "events",
    icon: Calendar,
    title: "Campus Events",
    description: "Never miss what's happening",
    gradient: "from-blue-400 to-indigo-500",
    bgGradient: "from-blue-100/40 to-indigo-50/20 dark:from-blue-900/10",
  },
  {
    id: "resources",
    icon: BookOpen,
    title: "Study Resources",
    description: "Notes, guides & materials",
    gradient: "from-amber-400 to-orange-500",
    bgGradient: "from-amber-100/40 to-orange-50/20 dark:from-amber-900/10",
  },
  {
    id: "marketplace",
    icon: ShoppingBag,
    title: "Marketplace",
    description: "Buy & sell with students",
    gradient: "from-emerald-400 to-teal-500",
    bgGradient: "from-emerald-100/40 to-teal-50/20 dark:from-emerald-900/10",
  },
];

/**
 * Campus Connect Carousel Component
 * Animated carousel button that cycles through Campus Connect features
 */
function CampusConnectCarousel() {
  const [currentIndex, setCurrentIndex] = useState(0);
  const router = useRouter();

  // Auto-rotate every 3 seconds
  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentIndex((prev) => (prev + 1) % CAMPUS_CONNECT_ITEMS.length);
    }, 3000);
    return () => clearInterval(interval);
  }, []);

  const currentItem = CAMPUS_CONNECT_ITEMS[currentIndex];
  const Icon = currentItem.icon;

  return (
    <button
      onClick={() => router.push("/campus-connect")}
      className="col-span-2 group relative overflow-hidden rounded-[20px] p-4 lg:p-5 bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 transition-all duration-300 hover:shadow-xl hover:shadow-black/5 hover:-translate-y-1 hover:bg-white/90 dark:hover:bg-white/10 text-left"
    >
      {/* Animated gradient background */}
      <div
        className={cn(
          "absolute inset-0 bg-gradient-to-r to-transparent pointer-events-none rounded-[20px] transition-all duration-500",
          currentItem.bgGradient
        )}
      />

      {/* Shimmer effect */}
      <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-500">
        <div className="absolute inset-0 -translate-x-full group-hover:translate-x-full transition-transform duration-1000 bg-gradient-to-r from-transparent via-white/20 to-transparent" />
      </div>

      <div className="relative z-10 flex items-center gap-4">
        {/* Animated Icon Container */}
        <div className="relative">
          <div
            className={cn(
              "h-12 w-12 rounded-2xl bg-gradient-to-br flex items-center justify-center shadow-lg transition-all duration-500",
              currentItem.gradient
            )}
            style={{
              boxShadow: `0 10px 25px -5px ${currentIndex === 0 ? 'rgba(244,63,94,0.25)' : currentIndex === 1 ? 'rgba(99,102,241,0.25)' : currentIndex === 2 ? 'rgba(251,146,60,0.25)' : 'rgba(20,184,166,0.25)'}`,
            }}
          >
            <Icon className="h-6 w-6 text-white transition-transform duration-300 group-hover:scale-110" strokeWidth={1.5} />
          </div>
          {/* Pulse ring */}
          <div className={cn(
            "absolute inset-0 rounded-2xl opacity-50 animate-ping",
            `bg-gradient-to-br ${currentItem.gradient}`
          )} style={{ animationDuration: '2s' }} />
        </div>

        {/* Content with slide animation */}
        <div className="flex-1 min-w-0 overflow-hidden">
          <div className="flex items-center gap-2 mb-1">
            <h3 className="font-semibold text-foreground text-[15px] transition-all duration-300">
              Campus Connect
            </h3>
            <span className="flex items-center gap-1 px-1.5 py-0.5 rounded-md bg-primary/10 text-[10px] font-medium text-primary">
              <MessageCircle className="h-3 w-3" />
              Live
            </span>
          </div>
          {/* Animated subtitle */}
          <div className="relative h-4 overflow-hidden">
            <p
              key={currentItem.id}
              className="text-xs text-muted-foreground/80 animate-slide-up"
            >
              {currentItem.title} - {currentItem.description}
            </p>
          </div>
        </div>

        {/* Carousel dots */}
        <div className="flex items-center gap-1.5 mr-2">
          {CAMPUS_CONNECT_ITEMS.map((_, index) => (
            <div
              key={index}
              className={cn(
                "h-1.5 rounded-full transition-all duration-300",
                index === currentIndex
                  ? "w-4 bg-primary"
                  : "w-1.5 bg-muted-foreground/30"
              )}
            />
          ))}
        </div>

        {/* Arrow */}
        <div className="h-9 w-9 rounded-xl bg-primary/10 flex items-center justify-center transition-all duration-300 group-hover:bg-primary/20 shrink-0">
          <ChevronRight className="h-4 w-4 text-primary transition-transform duration-300 group-hover:translate-x-0.5" />
        </div>
      </div>

      {/* Bottom progress bar */}
      <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-muted/30 overflow-hidden rounded-b-[20px]">
        <div
          className="h-full bg-gradient-to-r from-primary/60 to-primary transition-all duration-300 ease-linear"
          style={{
            width: '100%',
            animation: 'progress 3s linear infinite',
          }}
        />
      </div>
    </button>
  );
}

const STATUS_CONFIG: Record<string, { label: string; dot: string }> = {
  submitted: { label: "Submitted", dot: "bg-muted-foreground" },
  analyzing: { label: "Reviewing", dot: "bg-muted-foreground" },
  quoted: { label: "Quote Ready", dot: "bg-primary" },
  payment_pending: { label: "Payment Due", dot: "bg-primary" },
  paid: { label: "Paid", dot: "bg-foreground" },
  assigned: { label: "Assigned", dot: "bg-muted-foreground" },
  in_progress: { label: "In Progress", dot: "bg-primary" },
  qc: { label: "Quality Check", dot: "bg-primary" },
  delivered: { label: "Delivered", dot: "bg-foreground" },
  completed: { label: "Completed", dot: "bg-foreground" },
  revision: { label: "Revision", dot: "bg-muted-foreground" },
};

/**
 * Main Dashboard Component - NO ANIMATIONS
 */
export function DashboardPro() {
  const router = useRouter();
  const { user, isLoading: userLoading, fetchUser } = useUserStore();
  const { projects, isLoading: projectsLoading, fetchProjects } = useProjectStore();

  useEffect(() => {
    fetchUser();
    fetchProjects();
  }, [fetchUser, fetchProjects]);

  const isLoading = userLoading || projectsLoading;
  const firstName = user?.fullName?.split(" ")[0] || user?.full_name?.split(" ")[0] || "there";

  // Needs attention - projects requiring user action
  const ATTENTION_STATUSES = ["quoted", "payment_pending", "delivered", "revision"];
  const needsAttention = useMemo(() => {
    return projects
      .filter((p) => ATTENTION_STATUSES.includes(p.status))
      .slice(0, 3);
  }, [projects]);

  // Show skeleton while loading
  if (isLoading) {
    return <DashboardSkeleton />;
  }

  return (
    <div className={cn("mesh-background mesh-gradient-bottom-right-animated h-full overflow-hidden", getTimeBasedGradientClass())}>
      <div className="relative z-10 h-full px-4 py-6 md:px-6 md:py-8 lg:px-8 lg:py-10 flex items-center justify-center">
        <div className="max-w-[1400px] w-full">
          {/* Main Content - Two Column Layout */}
          <div className="flex flex-col lg:flex-row gap-8 lg:gap-12 items-start lg:items-center justify-between">
            {/* Left Column - Greeting */}
            <div className="flex-1 max-w-2xl space-y-4">
              {/* Greeting */}
              <div className="relative">
                <h1 className="text-3xl md:text-4xl lg:text-5xl xl:text-6xl font-light tracking-tight text-foreground/90">
                  Good {getGreeting()},
                </h1>
                {/* Name with Lottie animation to the right */}
                <div className="flex items-center gap-3 mt-1">
                  <h2 className="text-3xl md:text-4xl lg:text-5xl xl:text-6xl font-semibold tracking-tight text-foreground">
                    {firstName}
                  </h2>
                  {/* Lottie animation to the right of name */}
                  <GreetingAnimation
                    className="hidden md:block"
                    size={64}
                  />
                </div>
              </div>
              <p className="text-base md:text-lg text-muted-foreground mt-3 max-w-lg">
                Ready to optimize your workflow and generate insights.
              </p>

              {/* Quick Stats Row */}
              <QuickStats
                activeProjects={projects.filter(p => ["in_progress", "assigned", "qc"].includes(p.status)).length}
                pendingActions={projects.filter(p => ["quoted", "payment_pending", "delivered", "revision"].includes(p.status)).length}
                walletBalance={user?.wallet?.balance || 0}
                className="mt-2"
              />

              {/* Needs Attention Section - Below Greeting */}
              {needsAttention.length > 0 && (
                <div className="mt-8 pt-6 border-t border-border/40">
                  <div className="flex items-center gap-2 mb-3">
                    <span className="text-sm font-medium text-muted-foreground">
                      Needs Attention
                    </span>
                    <span className="text-xs px-2 py-1 rounded-full bg-primary/10 text-primary font-medium">
                      {needsAttention.length}
                    </span>
                  </div>
                  <div className="space-y-2">
                    {needsAttention.slice(0, 3).map((project) => {
                      const status = STATUS_CONFIG[project.status] || {
                        label: project.status,
                        dot: "bg-muted-foreground",
                      };
                      return (
                        <button
                          key={project.id}
                          onClick={() => router.push(`/project/${project.id}`)}
                          className="w-full flex items-center gap-3 p-3 rounded-xl bg-card/60 backdrop-blur-sm border border-border/50 text-left"
                        >
                          <div className={cn("h-2 w-2 rounded-full shrink-0", status.dot)} />
                          <div className="flex-1 min-w-0">
                            <p className="text-sm font-medium truncate">{project.title}</p>
                            <p className="text-xs text-muted-foreground mt-0.5">{status.label}</p>
                          </div>
                          <ChevronRight className="h-4 w-4 text-muted-foreground" />
                        </button>
                      );
                    })}
                  </div>
                </div>
              )}
            </div>

            {/* Right Column - Gen Z Glassmorphic Bento Grid */}
            <div className="w-full lg:w-auto lg:flex-shrink-0">
              <div className="grid grid-cols-2 gap-3 lg:gap-4 w-full lg:w-[460px]">
                {/* ====== HERO CARD - Create New Project ====== */}
                <Link
                  href="/projects/new"
                  className="col-span-2 group relative overflow-hidden rounded-[20px] p-5 lg:p-6 bg-gradient-to-br from-stone-800 via-stone-900 to-neutral-900 dark:from-stone-800 dark:via-stone-900 dark:to-neutral-950 text-white transition-all duration-300 hover:shadow-2xl hover:shadow-stone-900/30 hover:-translate-y-1"
                >
                  {/* Subtle warm glow overlay */}
                  <div className="absolute inset-0 bg-gradient-to-br from-orange-500/10 via-transparent to-rose-500/5 pointer-events-none" />

                  {/* Decorative circles */}
                  <div className="absolute -top-8 -right-8 w-32 h-32 bg-gradient-to-br from-orange-400/20 to-amber-500/10 rounded-full blur-2xl" />
                  <div className="absolute -bottom-6 -left-6 w-24 h-24 bg-gradient-to-tr from-rose-400/15 to-transparent rounded-full blur-xl" />

                  {/* Content */}
                  <div className="relative z-10 flex items-center justify-between gap-4">
                    <div className="flex-1">
                      <div className="flex items-center gap-3 mb-3">
                        <div className="h-11 w-11 rounded-2xl bg-gradient-to-br from-orange-400 to-rose-500 flex items-center justify-center shadow-lg shadow-orange-500/25">
                          <Plus className="h-5 w-5 text-white" strokeWidth={2.5} />
                        </div>
                        <span className="px-2.5 py-1 rounded-full bg-white/10 backdrop-blur-sm text-[11px] font-medium text-white/90 border border-white/10">
                          ✨ Start Here
                        </span>
                      </div>
                      <h3 className="text-xl lg:text-[22px] font-semibold mb-1.5 tracking-tight">
                        New Project
                      </h3>
                      <p className="text-sm text-white/60 leading-relaxed">
                        Essays, research, assignments & more
                      </p>
                    </div>

                    {/* Arrow */}
                    <div className="h-14 w-14 rounded-2xl bg-white/10 backdrop-blur-sm flex items-center justify-center border border-white/10 transition-all duration-300 group-hover:bg-white/20 group-hover:scale-105 shrink-0">
                      <ArrowRight className="h-6 w-6 text-white/80 transition-transform duration-300 group-hover:translate-x-0.5" />
                    </div>
                  </div>
                </Link>

                {/* ====== EXPERT CONSULTATIONS ====== */}
                <Link
                  href="/experts"
                  className="group relative overflow-hidden rounded-[20px] p-4 lg:p-5 bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 transition-all duration-300 hover:shadow-xl hover:shadow-black/5 hover:-translate-y-1 hover:bg-white/90 dark:hover:bg-white/10"
                >
                  {/* Subtle warm tint */}
                  <div className="absolute inset-0 bg-gradient-to-br from-amber-100/40 to-orange-50/20 dark:from-amber-900/10 dark:to-transparent pointer-events-none rounded-[20px]" />

                  <div className="relative z-10">
                    <div className="h-11 w-11 rounded-2xl bg-gradient-to-br from-amber-400 to-orange-500 flex items-center justify-center mb-4 shadow-lg shadow-amber-500/20">
                      <GraduationCap className="h-5 w-5 text-white" strokeWidth={1.5} />
                    </div>

                    {/* Mini avatars */}
                    <div className="flex items-center gap-2 mb-3">
                      <div className="flex -space-x-1.5">
                        {[...Array(3)].map((_, i) => (
                          <div
                            key={i}
                            className="h-5 w-5 rounded-full bg-gradient-to-br from-amber-200 to-orange-300 dark:from-amber-600 dark:to-orange-500 border-2 border-white dark:border-stone-900"
                          />
                        ))}
                      </div>
                      <span className="text-[10px] font-medium text-amber-700 dark:text-amber-400 bg-amber-100/80 dark:bg-amber-900/50 px-1.5 py-0.5 rounded-full">
                        50+ experts
                      </span>
                    </div>

                    <h3 className="font-semibold text-foreground text-[15px] mb-0.5">
                      Expert Sessions
                    </h3>
                    <p className="text-xs text-muted-foreground/80">
                      1-on-1 video consultations
                    </p>
                  </div>

                  {/* Hover indicator */}
                  <ChevronRight className="absolute bottom-4 right-4 h-4 w-4 text-muted-foreground/40 opacity-0 group-hover:opacity-100 transition-all duration-300 group-hover:translate-x-0.5" />
                </Link>

                {/* ====== AI PLAGIARISM CHECK (Swapped to single column) ====== */}
                <Link
                  href="/projects/new?type=plagiarism"
                  className="group relative overflow-hidden rounded-[20px] p-4 lg:p-5 bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 transition-all duration-300 hover:shadow-xl hover:shadow-black/5 hover:-translate-y-1 hover:bg-white/90 dark:hover:bg-white/10"
                >
                  {/* Subtle green tint */}
                  <div className="absolute inset-0 bg-gradient-to-br from-emerald-100/40 to-teal-50/20 dark:from-emerald-900/10 dark:to-transparent pointer-events-none rounded-[20px]" />

                  <div className="relative z-10">
                    <div className="h-11 w-11 rounded-2xl bg-gradient-to-br from-emerald-400 to-teal-500 flex items-center justify-center mb-4 shadow-lg shadow-emerald-500/20">
                      <Shield className="h-5 w-5 text-white" strokeWidth={1.5} />
                    </div>

                    {/* Accuracy indicator */}
                    <div className="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full bg-emerald-100/80 dark:bg-emerald-900/40 mb-3">
                      <CheckCircle className="h-3 w-3 text-emerald-600 dark:text-emerald-400" />
                      <span className="text-[10px] font-medium text-emerald-700 dark:text-emerald-300">99.9% Accurate</span>
                    </div>

                    <h3 className="font-semibold text-foreground text-[15px] mb-0.5">
                      Plagiarism Check
                    </h3>
                    <p className="text-xs text-muted-foreground/80">
                      AI-powered detection
                    </p>
                  </div>

                  {/* Hover indicator */}
                  <ChevronRight className="absolute bottom-4 right-4 h-4 w-4 text-muted-foreground/40 opacity-0 group-hover:opacity-100 transition-all duration-300 group-hover:translate-x-0.5" />
                </Link>

                {/* ====== CAMPUS CONNECT CAROUSEL ====== */}
                <CampusConnectCarousel />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}


/**
 * Dashboard Skeleton Component - Static, NO animations
 */
function DashboardSkeleton() {
  return (
    <div className={cn("mesh-background mesh-gradient-bottom-right-animated h-full overflow-hidden", getTimeBasedGradientClass())}>
      <div className="relative z-10 h-full px-4 py-6 md:px-6 md:py-8 lg:px-8 lg:py-10 flex items-center justify-center">
        <div className="max-w-[1400px] w-full">
          <div className="flex flex-col lg:flex-row gap-8 lg:gap-12 items-start lg:items-center justify-between">
            {/* Left Column Skeleton - Greeting Area */}
            <div className="flex-1 max-w-2xl space-y-4">
              {/* "Good Morning," text */}
              <SkeletonText width={280} lineHeight={64} animate="none" />
              {/* User name */}
              <SkeletonText width={240} lineHeight={64} animate="none" />
              {/* Subtitle */}
              <div className="mt-3">
                <SkeletonText width={360} lineHeight={24} animate="none" />
              </div>

              {/* Needs Attention Section Skeleton */}
              <div className="mt-8 pt-6 border-t border-border/40 space-y-3">
                <div className="flex items-center gap-2">
                  <SkeletonText width={120} lineHeight={16} animate="none" />
                  <SkeletonBox width={28} height={24} animate="none" className="rounded-full" />
                </div>
                {/* Attention items */}
                {[1, 2, 3].map((i) => (
                  <div
                    key={i}
                    className="flex items-center gap-3 p-3 rounded-xl bg-card/50 border border-border/50"
                  >
                    <SkeletonBox width={8} height={8} animate="none" className="rounded-full" />
                    <div className="flex-1 space-y-1.5">
                      <SkeletonText width={200} lineHeight={14} animate="none" />
                      <SkeletonText width={90} lineHeight={12} animate="none" />
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Right Column Skeleton - Premium Bento Grid */}
            <div className="w-full lg:w-auto lg:flex-shrink-0">
              <div className="grid grid-cols-2 gap-3 lg:gap-4 w-full lg:w-[480px]">
                {/* Hero card skeleton */}
                <div className="col-span-2 h-[140px] rounded-2xl bg-muted/50 border border-border/30" />
                {/* Two medium cards */}
                <div className="h-[160px] rounded-2xl bg-muted/40 border border-border/30" />
                <div className="h-[160px] rounded-2xl bg-muted/40 border border-border/30" />
                {/* Bottom wide card */}
                <div className="col-span-2 h-[80px] rounded-2xl bg-muted/30 border border-border/30" />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}


/**
 * Get greeting based on time of day
 */
function getGreeting(): string {
  const hour = new Date().getHours();
  if (hour < 12) return "Morning";
  if (hour < 17) return "Afternoon";
  return "Evening";
}

/**
 * Get time-based gradient class for subtle theming
 */
function getTimeBasedGradientClass(): string {
  const hour = new Date().getHours();
  if (hour >= 5 && hour < 12) return "mesh-gradient-morning";
  if (hour >= 12 && hour < 17) return "mesh-gradient-afternoon";
  return "mesh-gradient-evening";
}
