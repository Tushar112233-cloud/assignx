"use client";

/**
 * @fileoverview Smart Dashboard Hybrid - Projects Page
 *
 * A modern, data-driven projects dashboard featuring:
 * - Animated circular stat rings with live counters
 * - Smart auto-grouping by urgency (Needs Attention, Active, Completed)
 * - Adaptive card sizes based on importance
 * - Inline actions without navigation
 * - Activity insights and heatmap
 * - Beautiful glassmorphism design
 */

import { useState, useMemo, useCallback } from "react";
import { useRouter } from "next/navigation";
import { motion, AnimatePresence, useMotionValue, useTransform, animate } from "framer-motion";
import { useEffect } from "react";
import {
  Plus,
  FolderKanban,
  Zap,
  CheckCircle2,
  TrendingUp,
  Clock,
  AlertCircle,
  CreditCard,
  Eye,
  ChevronRight,
  ArrowRight,
  Timer,
  Sparkles,
  Target,
  Rocket,
  BookOpen,
  HelpCircle,
  Lightbulb,
  Award,
  BarChart3,
  Activity,
} from "lucide-react";
import { StaggerItem } from "@/components/skeletons";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { useProjectStore, type Project } from "@/stores";
import { formatDistanceToNow, differenceInDays, differenceInHours, format } from "date-fns";

// ============================================================================
// CONSTANTS & TYPES
// ============================================================================

const smoothSpring = {
  type: "spring" as const,
  stiffness: 300,
  damping: 28,
  mass: 0.8,
};

const springTransition = {
  type: "spring" as const,
  stiffness: 400,
  damping: 30,
};

interface ProjectsDashboardProps {
  onPayNow?: (project: Project) => void;
}

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

function getTimeBasedGradientClass(): string {
  const hour = new Date().getHours();
  if (hour >= 5 && hour < 12) return "mesh-gradient-morning";
  if (hour >= 12 && hour < 17) return "mesh-gradient-afternoon";
  return "mesh-gradient-evening";
}

function getDeadlineInfo(deadline: string | null | undefined): {
  label: string;
  urgent: boolean;
  daysLeft: number;
} | null {
  if (!deadline) return null;

  const now = new Date();
  const deadlineDate = new Date(deadline);
  const daysLeft = differenceInDays(deadlineDate, now);
  const hoursLeft = differenceInHours(deadlineDate, now);

  if (hoursLeft < 0) return { label: "Overdue", urgent: true, daysLeft: -1 };
  if (hoursLeft <= 24) return { label: `${hoursLeft}h left`, urgent: true, daysLeft: 0 };
  if (daysLeft <= 2) return { label: `${daysLeft}d left`, urgent: true, daysLeft };
  if (daysLeft <= 7) return { label: `${daysLeft}d left`, urgent: false, daysLeft };
  return { label: `${daysLeft}d left`, urgent: false, daysLeft };
}

function getStatusConfig(status: string) {
  const configs: Record<string, { label: string; color: string; bg: string; border: string }> = {
    draft: { label: "Draft", color: "text-muted-foreground", bg: "bg-muted/50", border: "border-muted" },
    submitted: { label: "Submitted", color: "text-amber-600 dark:text-amber-400", bg: "bg-amber-50 dark:bg-amber-950/30", border: "border-amber-200 dark:border-amber-800" },
    analyzing: { label: "Analyzing", color: "text-amber-600 dark:text-amber-400", bg: "bg-amber-50 dark:bg-amber-950/30", border: "border-amber-200 dark:border-amber-800" },
    quoted: { label: "Quote Ready", color: "text-orange-600 dark:text-orange-400", bg: "bg-orange-50 dark:bg-orange-950/30", border: "border-orange-200 dark:border-orange-800" },
    payment_pending: { label: "Payment Due", color: "text-rose-600 dark:text-rose-400", bg: "bg-rose-50 dark:bg-rose-950/30", border: "border-rose-300 dark:border-rose-800" },
    paid: { label: "Paid", color: "text-blue-600 dark:text-blue-400", bg: "bg-blue-50 dark:bg-blue-950/30", border: "border-blue-200 dark:border-blue-800" },
    assigned: { label: "Expert Assigned", color: "text-sky-600 dark:text-sky-400", bg: "bg-sky-50 dark:bg-sky-950/30", border: "border-sky-200 dark:border-sky-800" },
    in_progress: { label: "In Progress", color: "text-violet-600 dark:text-violet-400", bg: "bg-violet-50 dark:bg-violet-950/30", border: "border-violet-200 dark:border-violet-800" },
    submitted_for_qc: { label: "Quality Check", color: "text-indigo-600 dark:text-indigo-400", bg: "bg-indigo-50 dark:bg-indigo-950/30", border: "border-indigo-200 dark:border-indigo-800" },
    qc_approved: { label: "Approved", color: "text-emerald-600 dark:text-emerald-400", bg: "bg-emerald-50 dark:bg-emerald-950/30", border: "border-emerald-200 dark:border-emerald-800" },
    delivered: { label: "Delivered", color: "text-emerald-600 dark:text-emerald-400", bg: "bg-emerald-50 dark:bg-emerald-950/30", border: "border-emerald-200 dark:border-emerald-800" },
    revision_requested: { label: "Revision", color: "text-orange-600 dark:text-orange-400", bg: "bg-orange-50 dark:bg-orange-950/30", border: "border-orange-200 dark:border-orange-800" },
    completed: { label: "Completed", color: "text-emerald-600 dark:text-emerald-400", bg: "bg-emerald-50 dark:bg-emerald-950/30", border: "border-emerald-200 dark:border-emerald-800" },
    auto_approved: { label: "Completed", color: "text-emerald-600 dark:text-emerald-400", bg: "bg-emerald-50 dark:bg-emerald-950/30", border: "border-emerald-200 dark:border-emerald-800" },
  };
  return configs[status] || configs.submitted;
}

// ============================================================================
// ANIMATED COUNTER COMPONENT
// ============================================================================

function AnimatedCounter({ value, suffix = "" }: { value: number; suffix?: string }) {
  const count = useMotionValue(0);
  const rounded = useTransform(count, Math.round);
  const [displayValue, setDisplayValue] = useState(0);

  useEffect(() => {
    const controls = animate(count, value, {
      duration: 1.2,
      ease: [0.16, 1, 0.3, 1],
    });
    return controls.stop;
  }, [value, count]);

  useEffect(() => {
    const unsubscribe = rounded.on("change", (latest) => setDisplayValue(latest));
    return unsubscribe;
  }, [rounded]);

  return (
    <span className="tabular-nums">
      {displayValue}
      {suffix}
    </span>
  );
}

// ============================================================================
// CIRCULAR PROGRESS COMPONENT
// ============================================================================

function CircularProgress({
  value,
  size = 48,
  strokeWidth = 4,
  className,
  children,
}: {
  value: number;
  size?: number;
  strokeWidth?: number;
  className?: string;
  children?: React.ReactNode;
}) {
  const radius = (size - strokeWidth) / 2;
  const circumference = radius * 2 * Math.PI;
  const offset = circumference - (value / 100) * circumference;

  return (
    <div className={cn("relative inline-flex items-center justify-center", className)}>
      <svg width={size} height={size} className="transform -rotate-90">
        {/* Background circle */}
        <circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          fill="none"
          stroke="currentColor"
          strokeWidth={strokeWidth}
          className="text-muted/30"
        />
        {/* Progress circle */}
        <motion.circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          fill="none"
          stroke="currentColor"
          strokeWidth={strokeWidth}
          strokeLinecap="round"
          className="text-primary"
          initial={{ strokeDashoffset: circumference }}
          animate={{ strokeDashoffset: offset }}
          transition={{ duration: 1, ease: "easeOut" }}
          style={{
            strokeDasharray: circumference,
          }}
        />
      </svg>
      {children && (
        <div className="absolute inset-0 flex items-center justify-center">
          {children}
        </div>
      )}
    </div>
  );
}

// ============================================================================
// BENTO STATS GRID COMPONENT
// ============================================================================

/**
 * Asymmetric Bento Grid Stats Header
 * Features:
 * - Hero card with main CTA and overview
 * - Large success rate card with animated ring
 * - Stats cards with contextual info
 * - Quick actions/tips card
 */
function StatsHeader({
  stats,
  onNewProject,
}: {
  stats: {
    total: number;
    active: number;
    completed: number;
    successRate: number;
    needsAttention: number;
  };
  onNewProject: () => void;
}) {
  const router = useRouter();

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.5 }}
      className="mb-6"
    >
      {/* Bento Grid - Asymmetric Layout */}
      <div className="grid grid-cols-12 gap-3 md:gap-4">
        {/* ============================================ */}
        {/* HERO CARD - Create New Project (Large) */}
        {/* ============================================ */}
        <motion.div
          initial={{ opacity: 0, y: 20, scale: 0.95 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          transition={{ delay: 0.05, ...smoothSpring }}
          whileHover={{ y: -3, scale: 1.01 }}
          onClick={onNewProject}
          className="col-span-12 md:col-span-5 lg:col-span-4 row-span-2 cursor-pointer group"
        >
          <div className="relative h-full min-h-[200px] p-5 rounded-2xl bg-gradient-to-br from-primary/90 via-primary to-primary/80 text-primary-foreground overflow-hidden">
            {/* Decorative Elements */}
            <div className="absolute -top-10 -right-10 w-32 h-32 bg-white/10 rounded-full blur-2xl" />
            <div className="absolute -bottom-8 -left-8 w-24 h-24 bg-white/10 rounded-full blur-xl" />
            <motion.div
              className="absolute top-4 right-4 w-16 h-16 bg-white/5 rounded-full"
              animate={{ scale: [1, 1.2, 1], opacity: [0.3, 0.5, 0.3] }}
              transition={{ duration: 3, repeat: Infinity }}
            />

            {/* Content */}
            <div className="relative z-10 h-full flex flex-col">
              <div className="flex items-center gap-2 mb-3">
                <motion.div
                  className="h-10 w-10 rounded-xl bg-white/20 flex items-center justify-center backdrop-blur-sm"
                  whileHover={{ rotate: 90 }}
                  transition={{ duration: 0.3 }}
                >
                  <Plus className="h-5 w-5" />
                </motion.div>
                <motion.div
                  animate={{ rotate: [0, 10, -10, 0] }}
                  transition={{ duration: 2, repeat: Infinity, delay: 1 }}
                >
                  <Sparkles className="h-5 w-5 text-white/70" />
                </motion.div>
              </div>

              <h2 className="text-xl md:text-2xl font-bold mb-2">Start New Project</h2>
              <p className="text-sm text-white/80 mb-4 flex-1">
                Get expert help with your assignments, essays, and research work
              </p>

              {/* Quick Stats Row */}
              <div className="flex items-center gap-4 pt-3 border-t border-white/20">
                <div>
                  <p className="text-2xl font-bold">{stats.total}</p>
                  <p className="text-xs text-white/70">Total Projects</p>
                </div>
                <div className="h-8 w-px bg-white/20" />
                <div>
                  <p className="text-2xl font-bold">{stats.needsAttention}</p>
                  <p className="text-xs text-white/70">Need Action</p>
                </div>
              </div>

              {/* Hover Arrow */}
              <motion.div
                initial={{ x: -10, opacity: 0 }}
                whileHover={{ x: 0, opacity: 1 }}
                className="absolute bottom-5 right-5"
              >
                <ArrowRight className="h-6 w-6 opacity-0 group-hover:opacity-100 transition-opacity" />
              </motion.div>
            </div>
          </div>
        </motion.div>

        {/* ============================================ */}
        {/* SUCCESS RATE CARD (Medium - Tall) */}
        {/* ============================================ */}
        <motion.div
          initial={{ opacity: 0, y: 20, scale: 0.95 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          transition={{ delay: 0.1, ...smoothSpring }}
          whileHover={{ y: -2, scale: 1.01 }}
          className="col-span-6 md:col-span-3 lg:col-span-2 row-span-2"
        >
          <div className="h-full min-h-[200px] p-4 rounded-2xl bg-background/70 backdrop-blur-sm border border-border/40 flex flex-col items-center justify-center text-center">
            {/* Large Progress Ring */}
            <CircularProgress value={stats.successRate} size={90} strokeWidth={6}>
              <div className="text-center">
                <motion.span
                  className="text-2xl font-bold text-foreground"
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  transition={{ delay: 0.5 }}
                >
                  <AnimatedCounter value={stats.successRate} suffix="%" />
                </motion.span>
              </div>
            </CircularProgress>

            <p className="text-sm font-medium text-foreground mt-3">Success Rate</p>
            <p className="text-xs text-muted-foreground mt-1">Project completion</p>

            {/* Trend Indicator */}
            <motion.div
              initial={{ opacity: 0, y: 5 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.6 }}
              className="flex items-center gap-1 mt-3 px-2 py-1 rounded-full bg-emerald-100 dark:bg-emerald-900/30"
            >
              <TrendingUp className="h-3 w-3 text-emerald-600 dark:text-emerald-400" />
              <span className="text-[10px] font-medium text-emerald-700 dark:text-emerald-300">
                On track
              </span>
            </motion.div>
          </div>
        </motion.div>

        {/* ============================================ */}
        {/* ACTIVE PROJECTS CARD (Small) */}
        {/* ============================================ */}
        <motion.div
          initial={{ opacity: 0, y: 20, scale: 0.95 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          transition={{ delay: 0.15, ...smoothSpring }}
          whileHover={{ y: -2, scale: 1.02 }}
          onClick={() => router.push("/projects?tab=in_progress")}
          className="col-span-6 md:col-span-4 lg:col-span-3 cursor-pointer group"
        >
          <div className="relative h-full p-4 rounded-2xl bg-violet-50/80 dark:bg-violet-950/30 border border-violet-200/50 dark:border-violet-800/50 overflow-hidden">
            {/* Animated Background Pulse */}
            <motion.div
              className="absolute inset-0 bg-violet-400/10"
              animate={{ opacity: [0, 0.3, 0] }}
              transition={{ duration: 2, repeat: Infinity }}
            />

            <div className="relative z-10 flex items-start justify-between">
              <div>
                <div className="flex items-center gap-1.5 mb-1">
                  <motion.div
                    animate={{ scale: [1, 1.3, 1], opacity: [0.5, 1, 0.5] }}
                    transition={{ duration: 1.5, repeat: Infinity }}
                    className="h-2 w-2 rounded-full bg-violet-500"
                  />
                  <span className="text-[10px] font-medium text-violet-600 dark:text-violet-400 uppercase tracking-wide">
                    In Progress
                  </span>
                </div>
                <p className="text-3xl font-bold text-violet-700 dark:text-violet-300">
                  <AnimatedCounter value={stats.active} />
                </p>
                <p className="text-xs text-violet-600/70 dark:text-violet-400/70 mt-1">
                  Active now
                </p>
              </div>
              <motion.div
                className="h-10 w-10 rounded-xl bg-violet-200/50 dark:bg-violet-800/50 flex items-center justify-center"
                animate={{ rotate: [0, 5, -5, 0] }}
                transition={{ duration: 3, repeat: Infinity }}
              >
                <Zap className="h-5 w-5 text-violet-600 dark:text-violet-400" />
              </motion.div>
            </div>

            {/* Progress Mini-bars */}
            <div className="mt-3 flex gap-1">
              {[75, 50, 90, 30].slice(0, Math.min(stats.active, 4)).map((p, i) => (
                <motion.div
                  key={i}
                  className="flex-1 h-1 bg-violet-200 dark:bg-violet-800 rounded-full overflow-hidden"
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  transition={{ delay: 0.3 + i * 0.1 }}
                >
                  <motion.div
                    className="h-full bg-violet-500 rounded-full"
                    initial={{ width: 0 }}
                    animate={{ width: `${p}%` }}
                    transition={{ delay: 0.5 + i * 0.1, duration: 0.8 }}
                  />
                </motion.div>
              ))}
            </div>
          </div>
        </motion.div>

        {/* ============================================ */}
        {/* COMPLETED PROJECTS CARD (Small) */}
        {/* ============================================ */}
        <motion.div
          initial={{ opacity: 0, y: 20, scale: 0.95 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          transition={{ delay: 0.2, ...smoothSpring }}
          whileHover={{ y: -2, scale: 1.02 }}
          onClick={() => router.push("/projects?tab=history")}
          className="col-span-6 md:col-span-4 lg:col-span-3 cursor-pointer group"
        >
          <div className="relative h-full p-4 rounded-2xl bg-emerald-50/80 dark:bg-emerald-950/30 border border-emerald-200/50 dark:border-emerald-800/50">
            <div className="flex items-start justify-between">
              <div>
                <div className="flex items-center gap-1.5 mb-1">
                  <CheckCircle2 className="h-3 w-3 text-emerald-600 dark:text-emerald-400" />
                  <span className="text-[10px] font-medium text-emerald-600 dark:text-emerald-400 uppercase tracking-wide">
                    Completed
                  </span>
                </div>
                <p className="text-3xl font-bold text-emerald-700 dark:text-emerald-300">
                  <AnimatedCounter value={stats.completed} />
                </p>
                <p className="text-xs text-emerald-600/70 dark:text-emerald-400/70 mt-1">
                  Successfully done
                </p>
              </div>
              <motion.div
                className="h-10 w-10 rounded-xl bg-emerald-200/50 dark:bg-emerald-800/50 flex items-center justify-center"
                whileHover={{ scale: 1.1 }}
              >
                <Award className="h-5 w-5 text-emerald-600 dark:text-emerald-400" />
              </motion.div>
            </div>

            {/* Mini Achievement Badges */}
            <div className="mt-3 flex items-center gap-1">
              {[...Array(Math.min(stats.completed, 5))].map((_, i) => (
                <motion.div
                  key={i}
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  transition={{ delay: 0.4 + i * 0.05 }}
                  className="h-5 w-5 rounded-full bg-emerald-200 dark:bg-emerald-800 flex items-center justify-center"
                >
                  <CheckCircle2 className="h-3 w-3 text-emerald-600 dark:text-emerald-400" />
                </motion.div>
              ))}
              {stats.completed > 5 && (
                <span className="text-[10px] text-emerald-600 dark:text-emerald-400 ml-1">
                  +{stats.completed - 5}
                </span>
              )}
            </div>
          </div>
        </motion.div>

        {/* ============================================ */}
        {/* QUICK ACTIONS CARD (Medium) */}
        {/* ============================================ */}
        <motion.div
          initial={{ opacity: 0, y: 20, scale: 0.95 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          transition={{ delay: 0.25, ...smoothSpring }}
          className="col-span-12 md:col-span-8 lg:col-span-6"
        >
          <div className="h-full p-4 rounded-2xl bg-background/60 backdrop-blur-sm border border-border/40">
            <div className="flex items-center gap-2 mb-3">
              <div className="h-7 w-7 rounded-lg bg-amber-100 dark:bg-amber-900/50 flex items-center justify-center">
                <Lightbulb className="h-4 w-4 text-amber-600 dark:text-amber-400" />
              </div>
              <h3 className="text-sm font-medium text-foreground">Quick Actions</h3>
            </div>

            {/* Action Buttons Grid */}
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
              <QuickActionButton
                icon={Plus}
                label="New Project"
                onClick={onNewProject}
                color="primary"
                delay={0.3}
              />
              <QuickActionButton
                icon={BookOpen}
                label="Browse Experts"
                onClick={() => router.push("/experts")}
                color="violet"
                delay={0.35}
              />
              <QuickActionButton
                icon={BarChart3}
                label="View Analytics"
                onClick={() => {}}
                color="blue"
                delay={0.4}
                disabled
                tooltip="Coming soon"
              />
              <QuickActionButton
                icon={HelpCircle}
                label="Get Help"
                onClick={() => router.push("/support")}
                color="emerald"
                delay={0.45}
              />
            </div>
          </div>
        </motion.div>

        {/* ============================================ */}
        {/* ACTIVITY SPARKLINE CARD (Small) */}
        {/* ============================================ */}
        <motion.div
          initial={{ opacity: 0, y: 20, scale: 0.95 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          transition={{ delay: 0.3, ...smoothSpring }}
          className="col-span-6 lg:col-span-3 hidden lg:block"
        >
          <div className="h-full p-4 rounded-2xl bg-background/60 backdrop-blur-sm border border-border/40">
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <Activity className="h-4 w-4 text-muted-foreground" />
                <span className="text-xs font-medium text-muted-foreground">This Week</span>
              </div>
            </div>

            {/* Activity Bars */}
            <div className="flex items-end justify-between gap-1 h-12">
              {[40, 65, 30, 80, 55, 90, 45].map((height, i) => (
                <motion.div
                  key={i}
                  className="flex-1 bg-primary/20 rounded-t"
                  initial={{ height: 0 }}
                  animate={{ height: `${height}%` }}
                  transition={{ delay: 0.5 + i * 0.05, duration: 0.5 }}
                >
                  <motion.div
                    className="w-full bg-primary rounded-t"
                    initial={{ height: 0 }}
                    animate={{ height: `${Math.random() * 60 + 40}%` }}
                    transition={{ delay: 0.6 + i * 0.05, duration: 0.5 }}
                  />
                </motion.div>
              ))}
            </div>

            {/* Day Labels */}
            <div className="flex justify-between mt-2">
              {["M", "T", "W", "T", "F", "S", "S"].map((day, i) => (
                <span key={i} className="text-[9px] text-muted-foreground flex-1 text-center">
                  {day}
                </span>
              ))}
            </div>
          </div>
        </motion.div>

        {/* ============================================ */}
        {/* TOTAL OVERVIEW CARD (Small - Mobile Only) */}
        {/* ============================================ */}
        <motion.div
          initial={{ opacity: 0, y: 20, scale: 0.95 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          transition={{ delay: 0.25, ...smoothSpring }}
          className="col-span-6 md:hidden"
        >
          <div className="h-full p-4 rounded-2xl bg-background/60 backdrop-blur-sm border border-border/40">
            <div className="flex items-start justify-between">
              <div>
                <span className="text-[10px] font-medium text-muted-foreground uppercase tracking-wide">
                  Total
                </span>
                <p className="text-3xl font-bold text-foreground">
                  <AnimatedCounter value={stats.total} />
                </p>
                <p className="text-xs text-muted-foreground mt-1">All projects</p>
              </div>
              <div className="h-10 w-10 rounded-xl bg-muted/50 flex items-center justify-center">
                <FolderKanban className="h-5 w-5 text-muted-foreground" />
              </div>
            </div>
          </div>
        </motion.div>
      </div>
    </motion.div>
  );
}

/**
 * Quick Action Button Component
 */
function QuickActionButton({
  icon: Icon,
  label,
  onClick,
  color,
  delay,
  disabled,
  tooltip,
}: {
  icon: React.ElementType;
  label: string;
  onClick: () => void;
  color: "primary" | "violet" | "blue" | "emerald";
  delay: number;
  disabled?: boolean;
  tooltip?: string;
}) {
  const colorClasses = {
    primary: "bg-primary/10 text-primary hover:bg-primary/20 border-primary/20",
    violet: "bg-violet-100 dark:bg-violet-900/30 text-violet-600 dark:text-violet-400 hover:bg-violet-200 dark:hover:bg-violet-900/50 border-violet-200 dark:border-violet-800",
    blue: "bg-blue-100 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 hover:bg-blue-200 dark:hover:bg-blue-900/50 border-blue-200 dark:border-blue-800",
    emerald: "bg-emerald-100 dark:bg-emerald-900/30 text-emerald-600 dark:text-emerald-400 hover:bg-emerald-200 dark:hover:bg-emerald-900/50 border-emerald-200 dark:border-emerald-800",
  };

  return (
    <motion.button
      initial={{ opacity: 0, scale: 0.9 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ delay, ...smoothSpring }}
      whileHover={!disabled ? { y: -2, scale: 1.03 } : undefined}
      whileTap={!disabled ? { scale: 0.97 } : undefined}
      onClick={onClick}
      disabled={disabled}
      title={tooltip}
      className={cn(
        "flex flex-col items-center justify-center gap-1.5 p-3 rounded-xl border transition-all",
        colorClasses[color],
        disabled && "opacity-50 cursor-not-allowed"
      )}
    >
      <Icon className="h-4 w-4" />
      <span className="text-[10px] font-medium">{label}</span>
    </motion.button>
  );
}

// ============================================================================
// INSIGHTS BAR COMPONENT
// ============================================================================

function InsightsBar({
  needsAttention,
  weeklyActivity,
}: {
  needsAttention: number;
  weeklyActivity: number[];
}) {
  if (needsAttention === 0) return null;

  return (
    <motion.div
      initial={{ opacity: 0, height: 0 }}
      animate={{ opacity: 1, height: "auto" }}
      exit={{ opacity: 0, height: 0 }}
      transition={smoothSpring}
      className="mb-6"
    >
      <div className="flex items-center justify-between p-4 rounded-xl bg-amber-50/80 dark:bg-amber-950/30 border border-amber-200/50 dark:border-amber-800/50 backdrop-blur-sm">
        <div className="flex items-center gap-3">
          <motion.div
            animate={{ scale: [1, 1.1, 1] }}
            transition={{ duration: 2, repeat: Infinity }}
            className="h-9 w-9 rounded-lg bg-amber-100 dark:bg-amber-900/50 flex items-center justify-center"
          >
            <AlertCircle className="h-5 w-5 text-amber-600 dark:text-amber-400" />
          </motion.div>
          <div>
            <p className="text-sm font-medium text-foreground">
              {needsAttention} project{needsAttention > 1 ? "s" : ""} need your attention
            </p>
            <p className="text-xs text-muted-foreground">Payment, review, or action required</p>
          </div>
        </div>

        {/* Weekly Activity Mini Heatmap */}
        <div className="hidden sm:flex items-center gap-1">
          <span className="text-xs text-muted-foreground mr-2">This week:</span>
          {weeklyActivity.map((count, i) => (
            <motion.div
              key={i}
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              transition={{ delay: 0.3 + i * 0.05 }}
              className={cn(
                "w-5 h-5 rounded",
                count === 0 && "bg-muted/30",
                count === 1 && "bg-primary/30",
                count === 2 && "bg-primary/50",
                count >= 3 && "bg-primary/80"
              )}
              title={`${["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][i]}: ${count} activities`}
            />
          ))}
        </div>
      </div>
    </motion.div>
  );
}

// ============================================================================
// ATTENTION CARD COMPONENT (Large)
// ============================================================================

function AttentionCard({
  project,
  onPayNow,
  onView,
  index,
}: {
  project: Project;
  onPayNow?: (project: Project) => void;
  onView: () => void;
  index: number;
}) {
  const status = getStatusConfig(project.status);
  const deadline = getDeadlineInfo(project.deadline);
  const quoteAmount = project.final_quote || project.user_quote || project.quoteAmount;
  const isPayment = project.status === "payment_pending" || project.status === "quoted";
  const isDelivered = project.status === "delivered" || project.status === "qc_approved";

  return (
    <motion.div
      initial={{ opacity: 0, y: 20, scale: 0.95 }}
      animate={{ opacity: 1, y: 0, scale: 1 }}
      transition={{ delay: index * 0.05, ...smoothSpring }}
      whileHover={{ y: -4, scale: 1.01 }}
      whileTap={{ scale: 0.98 }}
      onClick={onView}
      className={cn(
        "group cursor-pointer relative p-5 rounded-2xl backdrop-blur-sm overflow-hidden",
        "bg-background/80 border-2 transition-all",
        isPayment && "border-rose-300 dark:border-rose-700",
        isDelivered && "border-emerald-300 dark:border-emerald-700",
        !isPayment && !isDelivered && "border-amber-300 dark:border-amber-700"
      )}
    >
      {/* Animated accent line */}
      <motion.div
        className={cn(
          "absolute top-0 left-0 right-0 h-1",
          isPayment && "bg-gradient-to-r from-rose-400 via-orange-400 to-rose-400",
          isDelivered && "bg-gradient-to-r from-emerald-400 via-teal-400 to-emerald-400",
          !isPayment && !isDelivered && "bg-gradient-to-r from-amber-400 via-yellow-400 to-amber-400"
        )}
        animate={{ backgroundPosition: ["0% 50%", "100% 50%", "0% 50%"] }}
        transition={{ duration: 3, repeat: Infinity, ease: "linear" }}
        style={{ backgroundSize: "200% 100%" }}
      />

      {/* Header */}
      <div className="flex items-start justify-between gap-3 mb-4">
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 mb-1">
            <span className={cn("text-xs font-medium px-2 py-0.5 rounded-full", status.bg, status.color)}>
              {status.label}
            </span>
            {deadline?.urgent && (
              <span className="text-xs font-medium text-rose-600 dark:text-rose-400 flex items-center gap-1">
                <Timer className="h-3 w-3" />
                {deadline.label}
              </span>
            )}
          </div>
          <h3 className="font-semibold text-foreground line-clamp-1 text-base">{project.title}</h3>
          <p className="text-xs text-muted-foreground font-mono mt-0.5">
            #{project.project_number || project.projectNumber}
          </p>
        </div>

        {/* Amount or Icon */}
        {isPayment && quoteAmount ? (
          <div className="text-right shrink-0">
            <p className="text-xs text-muted-foreground">Amount Due</p>
            <p className="text-xl font-bold text-foreground">₹{quoteAmount.toLocaleString()}</p>
          </div>
        ) : isDelivered ? (
          <motion.div
            animate={{ scale: [1, 1.1, 1] }}
            transition={{ duration: 2, repeat: Infinity }}
            className="h-12 w-12 rounded-xl bg-emerald-100 dark:bg-emerald-900/50 flex items-center justify-center shrink-0"
          >
            <CheckCircle2 className="h-6 w-6 text-emerald-600 dark:text-emerald-400" />
          </motion.div>
        ) : null}
      </div>

      {/* Description */}
      {project.description && (
        <p className="text-sm text-muted-foreground line-clamp-2 mb-4">
          {project.description}
        </p>
      )}

      {/* Action Button */}
      <motion.button
        whileHover={{ scale: 1.02 }}
        whileTap={{ scale: 0.98 }}
        onClick={(e) => {
          e.stopPropagation();
          if (isPayment && onPayNow) {
            onPayNow(project);
          } else {
            onView();
          }
        }}
        className={cn(
          "w-full h-10 text-sm font-medium rounded-xl flex items-center justify-center gap-2 transition-colors",
          isPayment && "bg-foreground text-background hover:bg-foreground/90",
          isDelivered && "bg-emerald-600 text-white hover:bg-emerald-700",
          !isPayment && !isDelivered && "bg-primary text-primary-foreground hover:bg-primary/90"
        )}
      >
        {isPayment ? (
          <>
            <CreditCard className="h-4 w-4" />
            Pay Now
          </>
        ) : isDelivered ? (
          <>
            <Eye className="h-4 w-4" />
            Review & Approve
          </>
        ) : (
          <>
            <ArrowRight className="h-4 w-4" />
            View Details
          </>
        )}
      </motion.button>
    </motion.div>
  );
}

// ============================================================================
// ACTIVE PROJECT CARD (Medium with Progress)
// ============================================================================

function ActiveCard({
  project,
  onView,
  index,
}: {
  project: Project;
  onView: () => void;
  index: number;
}) {
  const progress = project.progress ?? project.progress_percentage ?? 0;
  const deadline = getDeadlineInfo(project.deadline);
  const status = getStatusConfig(project.status);

  return (
    <motion.div
      initial={{ opacity: 0, y: 20, scale: 0.95 }}
      animate={{ opacity: 1, y: 0, scale: 1 }}
      transition={{ delay: index * 0.04, ...smoothSpring }}
      whileHover={{ y: -3, scale: 1.015 }}
      whileTap={{ scale: 0.98 }}
      onClick={onView}
      className="group cursor-pointer p-4 rounded-xl bg-background/70 backdrop-blur-sm border border-border/40 hover:border-primary/30 transition-all"
    >
      {/* Header */}
      <div className="flex items-start gap-3 mb-3">
        {/* Progress Ring */}
        <CircularProgress value={progress} size={44} strokeWidth={3}>
          <span className="text-[10px] font-semibold">{progress}%</span>
        </CircularProgress>

        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-1.5 mb-0.5">
            <motion.div
              animate={{ scale: [1, 1.3, 1], opacity: [0.5, 1, 0.5] }}
              transition={{ duration: 1.5, repeat: Infinity }}
              className="h-1.5 w-1.5 rounded-full bg-violet-500"
            />
            <span className="text-[10px] font-medium text-violet-600 dark:text-violet-400 uppercase tracking-wide">
              {status.label}
            </span>
          </div>
          <h3 className="font-medium text-foreground line-clamp-1 text-sm">{project.title}</h3>
        </div>
      </div>

      {/* Progress Bar */}
      <div className="mb-3">
        <div className="h-1.5 bg-muted/50 rounded-full overflow-hidden">
          <motion.div
            initial={{ width: 0 }}
            animate={{ width: `${progress}%` }}
            transition={{ duration: 0.8, delay: index * 0.05, ease: "easeOut" }}
            className="h-full bg-gradient-to-r from-primary via-violet-500 to-primary rounded-full"
          />
        </div>
      </div>

      {/* Footer */}
      <div className="flex items-center justify-between text-xs">
        <span className="text-muted-foreground font-mono">
          #{project.project_number || project.projectNumber}
        </span>
        {deadline && (
          <span className={cn(
            "flex items-center gap-1",
            deadline.urgent ? "text-rose-500" : "text-muted-foreground"
          )}>
            <Clock className="h-3 w-3" />
            {deadline.label}
          </span>
        )}
      </div>

      {/* Hover arrow */}
      <motion.div
        initial={{ opacity: 0, x: -5 }}
        whileHover={{ opacity: 1, x: 0 }}
        className="absolute bottom-4 right-4 opacity-0 group-hover:opacity-100 transition-opacity"
      >
        <ChevronRight className="h-4 w-4 text-muted-foreground" />
      </motion.div>
    </motion.div>
  );
}

// ============================================================================
// COMPLETED CARD (Compact)
// ============================================================================

function CompletedCard({
  project,
  onView,
  index,
}: {
  project: Project;
  onView: () => void;
  index: number;
}) {
  const completedAt = project.updated_at || project.created_at;

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.9 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ delay: index * 0.03, ...smoothSpring }}
      whileHover={{ y: -2, scale: 1.02 }}
      whileTap={{ scale: 0.98 }}
      onClick={onView}
      className="group cursor-pointer p-3 rounded-xl bg-background/50 backdrop-blur-sm border border-border/30 hover:border-emerald-200 dark:hover:border-emerald-800 transition-all"
    >
      <div className="flex items-center gap-3">
        {/* Success Icon */}
        <div className="h-8 w-8 rounded-lg bg-emerald-100 dark:bg-emerald-900/50 flex items-center justify-center shrink-0">
          <CheckCircle2 className="h-4 w-4 text-emerald-600 dark:text-emerald-400" />
        </div>

        {/* Content */}
        <div className="flex-1 min-w-0">
          <h3 className="font-medium text-foreground/80 line-clamp-1 text-sm group-hover:text-foreground transition-colors">
            {project.title}
          </h3>
          <p className="text-[10px] text-muted-foreground">
            {completedAt ? formatDistanceToNow(new Date(completedAt), { addSuffix: true }) : "Recently"}
          </p>
        </div>

        {/* Project Number Badge */}
        <div className="flex items-center gap-1 px-2 py-0.5 rounded-full bg-emerald-100 dark:bg-emerald-900/50 shrink-0">
          <CheckCircle2 className="h-3 w-3 text-emerald-600 dark:text-emerald-400" />
          <span className="text-[10px] font-medium text-emerald-700 dark:text-emerald-300">Done</span>
        </div>

        {/* Hover Arrow */}
        <ChevronRight className="h-4 w-4 text-muted-foreground opacity-0 group-hover:opacity-100 transition-opacity shrink-0" />
      </div>
    </motion.div>
  );
}

// ============================================================================
// SECTION HEADER COMPONENT
// ============================================================================

function SectionHeader({
  icon: Icon,
  title,
  count,
  color,
  delay,
}: {
  icon: React.ElementType;
  title: string;
  count: number;
  color: string;
  delay: number;
}) {
  if (count === 0) return null;

  return (
    <motion.div
      initial={{ opacity: 0, x: -10 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ delay, ...smoothSpring }}
      className="flex items-center gap-2 mb-3"
    >
      <div className={cn("h-6 w-6 rounded-md flex items-center justify-center", color)}>
        <Icon className="h-3.5 w-3.5" />
      </div>
      <span className="text-sm font-medium text-foreground">{title}</span>
      <span className="text-xs px-2 py-0.5 rounded-full bg-muted text-muted-foreground">
        {count}
      </span>
    </motion.div>
  );
}

// ============================================================================
// EMPTY STATE COMPONENT
// ============================================================================

function EmptyState({ onNewProject }: { onNewProject: () => void }) {
  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={smoothSpring}
      className="flex flex-col items-center justify-center py-16 text-center"
    >
      <motion.div
        initial={{ scale: 0 }}
        animate={{ scale: 1 }}
        transition={{ delay: 0.1, ...springTransition }}
        className="h-20 w-20 rounded-2xl bg-primary/10 flex items-center justify-center mb-6"
      >
        <FolderKanban className="h-10 w-10 text-primary" />
      </motion.div>
      <h3 className="text-lg font-semibold mb-2">No projects yet</h3>
      <p className="text-sm text-muted-foreground mb-6 max-w-sm">
        Create your first project to get started with expert assistance
      </p>
      <motion.div whileHover={{ scale: 1.02 }} whileTap={{ scale: 0.98 }}>
        <Button onClick={onNewProject} className="gap-2">
          <Plus className="h-4 w-4" />
          Create Your First Project
        </Button>
      </motion.div>
    </motion.div>
  );
}

// ============================================================================
// MAIN DASHBOARD COMPONENT
// ============================================================================

export function ProjectsDashboard({ onPayNow }: ProjectsDashboardProps) {
  const router = useRouter();
  const { projects } = useProjectStore();

  // Smart grouping
  const groupedProjects = useMemo(() => {
    const needsAttention = projects.filter((p) =>
      ["quoted", "payment_pending", "delivered", "qc_approved", "revision_requested"].includes(p.status)
    );

    const active = projects.filter((p) =>
      ["in_progress", "assigned", "submitted_for_qc", "paid", "analyzing", "submitted"].includes(p.status)
    );

    const completed = projects.filter((p) =>
      ["completed", "auto_approved"].includes(p.status)
    ).slice(0, 6); // Show max 6 completed

    return { needsAttention, active, completed };
  }, [projects]);

  // Stats calculation
  const stats = useMemo(() => {
    const total = projects.length;
    const active = groupedProjects.active.length;
    const completed = projects.filter((p) => ["completed", "auto_approved"].includes(p.status)).length;
    const successRate = total > 0 ? Math.round((completed / total) * 100) : 0;
    const needsAttention = groupedProjects.needsAttention.length;
    return { total, active, completed, successRate, needsAttention };
  }, [projects, groupedProjects]);

  // Mock weekly activity (replace with real data)
  const weeklyActivity = useMemo(() => {
    return [2, 1, 3, 0, 2, 1, 0];
  }, []);

  const handleView = useCallback((project: Project) => {
    router.push(`/project/${project.id}`);
  }, [router]);

  const handleNewProject = useCallback(() => {
    router.push('/projects/new');
  }, [router]);

  if (projects.length === 0) {
    return (
      <>
        <div className={cn("fixed inset-0 mesh-background mesh-gradient-bottom-right-animated", getTimeBasedGradientClass())} />
        <div className="relative z-10 h-full flex flex-col p-4 md:p-6 lg:p-8">
          <StaggerItem>
            <StatsHeader stats={stats} onNewProject={handleNewProject} />
          </StaggerItem>
          <EmptyState onNewProject={handleNewProject} />
        </div>
      </>
    );
  }

  return (
    <>
      {/* Background */}
      <div className={cn("fixed inset-0 mesh-background mesh-gradient-bottom-right-animated", getTimeBasedGradientClass())} />

      {/* Main Content */}
      <div className="relative z-10 h-full flex flex-col p-4 md:p-6 lg:p-8 overflow-hidden">
        <div className="max-w-7xl mx-auto w-full flex flex-col h-full">
          {/* Stats Header */}
          <StaggerItem>
            <StatsHeader stats={stats} onNewProject={handleNewProject} />
          </StaggerItem>

          {/* Insights Bar */}
          <StaggerItem>
            <InsightsBar
              needsAttention={stats.needsAttention}
              weeklyActivity={weeklyActivity}
            />
          </StaggerItem>

          {/* Scrollable Content */}
          <div className="flex-1 overflow-y-auto scrollbar-thin space-y-8 pb-4">
            {/* Needs Attention Section */}
            {groupedProjects.needsAttention.length > 0 && (
              <StaggerItem>
                <section>
                  <SectionHeader
                    icon={AlertCircle}
                    title="Needs Attention"
                    count={groupedProjects.needsAttention.length}
                    color="bg-amber-100 dark:bg-amber-900/50 text-amber-600 dark:text-amber-400"
                    delay={0.1}
                  />
                  <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
                    {groupedProjects.needsAttention.map((project, index) => (
                      <AttentionCard
                        key={project.id}
                        project={project}
                        onPayNow={onPayNow}
                        onView={() => handleView(project)}
                        index={index}
                      />
                    ))}
                  </div>
                </section>
              </StaggerItem>
            )}

            {/* Active Projects Section */}
            {groupedProjects.active.length > 0 && (
              <StaggerItem>
                <section>
                  <SectionHeader
                    icon={Zap}
                    title="In Progress"
                    count={groupedProjects.active.length}
                    color="bg-violet-100 dark:bg-violet-900/50 text-violet-600 dark:text-violet-400"
                    delay={0.15}
                  />
                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-3">
                    {groupedProjects.active.map((project, index) => (
                      <ActiveCard
                        key={project.id}
                        project={project}
                        onView={() => handleView(project)}
                        index={index}
                      />
                    ))}
                  </div>
                </section>
              </StaggerItem>
            )}

            {/* Completed Projects Section */}
            {groupedProjects.completed.length > 0 && (
              <StaggerItem>
                <section>
                  <SectionHeader
                    icon={CheckCircle2}
                    title="Recently Completed"
                    count={groupedProjects.completed.length}
                    color="bg-emerald-100 dark:bg-emerald-900/50 text-emerald-600 dark:text-emerald-400"
                    delay={0.2}
                  />
                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-2">
                    {groupedProjects.completed.map((project, index) => (
                      <CompletedCard
                        key={project.id}
                        project={project}
                        onView={() => handleView(project)}
                        index={index}
                      />
                    ))}
                  </div>
                  {projects.filter((p) => ["completed", "auto_approved"].includes(p.status)).length > 6 && (
                    <motion.button
                      initial={{ opacity: 0 }}
                      animate={{ opacity: 1 }}
                      transition={{ delay: 0.3 }}
                      onClick={() => router.push("/projects?tab=history")}
                      className="mt-3 text-sm text-muted-foreground hover:text-foreground flex items-center gap-1 transition-colors"
                    >
                      View all completed projects
                      <ChevronRight className="h-4 w-4" />
                    </motion.button>
                  )}
                </section>
              </StaggerItem>
            )}
          </div>
        </div>
      </div>
    </>
  );
}
