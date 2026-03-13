"use client";

/**
 * Projects Pro - Premium Glassmorphic Design
 *
 * Matches dashboard-pro aesthetic:
 * - Glassmorphic bento cards with backdrop blur
 * - Coffee bean palette (#765341, #14110F, #E4E1C7)
 * - Warm amber/orange accent for projects
 * - Split layout with greeting + bento grid
 * - Tab bar with glassmorphic pills
 * - Responsive project card grid with status stripes
 */

import { useState, useMemo, useCallback, useEffect, useRef } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import {
  Plus,
  Search,
  ArrowRight,
  Zap,
  CheckCircle2,
  Clock,
  ChevronRight,
  CreditCard,
  Timer,
  Eye,
  Sparkles,
  FileText,
  FolderOpen,
  BookOpen,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { useProjectStore, useUserStore, type Project } from "@/stores";
import type { ProjectTab } from "@/types/project";
import { formatDistanceToNow, differenceInDays, differenceInHours } from "date-fns";

/**
 * Tab configuration
 */
interface TabConfig {
  value: ProjectTab;
  label: string;
  icon: React.ElementType;
}

const tabs: TabConfig[] = [
  { value: "in_progress", label: "Active", icon: Zap },
  { value: "in_review", label: "Review", icon: Eye },
  { value: "for_review", label: "Pending", icon: Clock },
  { value: "history", label: "Completed", icon: CheckCircle2 },
];

/**
 * Status configuration with color stripes
 */
const statusConfig: Record<string, { label: string; dot: string; stripe: string }> = {
  draft: { label: "Draft", dot: "bg-muted-foreground", stripe: "bg-gray-400" },
  submitted: { label: "Submitted", dot: "bg-amber-500", stripe: "bg-amber-500" },
  analyzing: { label: "Analyzing", dot: "bg-amber-500", stripe: "bg-amber-500" },
  quoted: { label: "Quote Ready", dot: "bg-rose-500", stripe: "bg-rose-500" },
  payment_pending: { label: "Payment Due", dot: "bg-rose-500", stripe: "bg-rose-500" },
  paid: { label: "Paid", dot: "bg-blue-500", stripe: "bg-blue-500" },
  assigning: { label: "Matching Expert", dot: "bg-blue-500", stripe: "bg-blue-500" },
  assigned: { label: "Expert Assigned", dot: "bg-violet-500", stripe: "bg-violet-500" },
  in_progress: { label: "In Progress", dot: "bg-amber-500", stripe: "bg-amber-500" },
  submitted_for_qc: { label: "Quality Check", dot: "bg-indigo-500", stripe: "bg-indigo-500" },
  qc_in_progress: { label: "QC Review", dot: "bg-indigo-500", stripe: "bg-indigo-500" },
  qc_approved: { label: "Approved", dot: "bg-emerald-500", stripe: "bg-emerald-500" },
  qc_rejected: { label: "Revision Needed", dot: "bg-red-500", stripe: "bg-red-500" },
  delivered: { label: "Delivered", dot: "bg-emerald-500", stripe: "bg-emerald-500" },
  revision_requested: { label: "Revision Requested", dot: "bg-orange-500", stripe: "bg-orange-500" },
  in_revision: { label: "In Revision", dot: "bg-blue-500", stripe: "bg-blue-500" },
  completed: { label: "Completed", dot: "bg-emerald-500", stripe: "bg-emerald-500" },
  auto_approved: { label: "Completed", dot: "bg-emerald-500", stripe: "bg-emerald-500" },
  cancelled: { label: "Cancelled", dot: "bg-muted-foreground", stripe: "bg-gray-400" },
  refunded: { label: "Refunded", dot: "bg-muted-foreground", stripe: "bg-gray-400" },
};

interface ProjectsProProps {
  onPayNow?: (project: Project) => void;
}

/**
 * Get greeting based on time
 */
function getGreeting(): string {
  const hour = new Date().getHours();
  if (hour < 12) return "Morning";
  if (hour < 17) return "Afternoon";
  return "Evening";
}

/**
 * Get time-based gradient class
 */
function getTimeBasedGradientClass(): string {
  const hour = new Date().getHours();
  if (hour >= 5 && hour < 12) return "mesh-gradient-morning";
  if (hour >= 12 && hour < 17) return "mesh-gradient-afternoon";
  return "mesh-gradient-evening";
}

/**
 * Main Projects Component - Premium Glassmorphic Design
 */
export function ProjectsPro({ onPayNow }: ProjectsProProps) {
  const router = useRouter();
  const { getProjectsByTab, projects } = useProjectStore();
  const { user } = useUserStore();

  const [searchQuery, setSearchQuery] = useState("");
  const [selectedTab, setSelectedTab] = useState<ProjectTab>("in_progress");
  const hasAutoSelected = useRef(false);

  /** User's first name */
  const firstName = useMemo(() => {
    if (!user) return "there";
    const fullName = user.fullName || user.full_name || user.email?.split("@")[0] || "";
    return fullName.split(" ")[0] || "there";
  }, [user]);

  /** Projects for selected tab */
  const displayProjects = useMemo(() => {
    return getProjectsByTab(selectedTab);
  }, [selectedTab, getProjectsByTab]);

  /** Aggregated stats */
  const stats = useMemo(() => {
    const inProgress = getProjectsByTab("in_progress").length;
    const inReview = getProjectsByTab("in_review").length;
    const forReview = getProjectsByTab("for_review").length;
    const completed = getProjectsByTab("history").filter(
      (p) => p.status === "completed" || p.status === "auto_approved"
    ).length;
    return { inProgress, inReview, forReview, completed, total: projects.length };
  }, [projects, getProjectsByTab]);

  /** Tab counts */
  const tabCounts = useMemo(() => {
    const counts: Record<string, number> = {};
    tabs.forEach((tab) => {
      counts[tab.value] = getProjectsByTab(tab.value).length;
    });
    return counts;
  }, [getProjectsByTab]);

  /** Search filter */
  const filteredProjects = useMemo(() => {
    if (!searchQuery.trim()) return displayProjects;
    const query = searchQuery.toLowerCase();
    return displayProjects.filter(
      (p) =>
        p.title.toLowerCase().includes(query) ||
        (p.projectNumber || p.project_number || "").toLowerCase().includes(query) ||
        (p.subject?.name || "").toLowerCase().includes(query)
    );
  }, [displayProjects, searchQuery]);

  /** Payment pending projects */
  const attentionProjects = useMemo(() => {
    return projects.filter((p) => p.status === "payment_pending" || p.status === "quoted");
  }, [projects]);

  /** Handle project click */
  const handleProjectClick = useCallback(
    (project: Project) => {
      const needsPayment = project.status === "payment_pending" || project.status === "quoted";
      if (needsPayment && onPayNow) {
        onPayNow(project);
      } else {
        router.push(`/project/${project.id}`);
      }
    },
    [router, onPayNow]
  );

  /** Auto-select tab with projects on initial mount */
  useEffect(() => {
    if (hasAutoSelected.current) return;
    if (displayProjects.length === 0 && projects.length > 0) {
      hasAutoSelected.current = true;
      const tabWithProjects = tabs.find((tab) => getProjectsByTab(tab.value).length > 0);
      if (tabWithProjects) {
        setSelectedTab(tabWithProjects.value);
      }
    }
  }, [displayProjects.length, projects.length, getProjectsByTab]);

  return (
    <div className={cn("mesh-background mesh-gradient-bottom-right-animated h-full overflow-hidden", getTimeBasedGradientClass())}>
      <div className="relative z-10 h-full px-4 py-6 md:px-6 md:py-8 lg:px-8 lg:py-10 overflow-y-auto">
        <div className="max-w-[1400px] mx-auto">

          {/* ================================================================ */}
          {/* HERO SECTION - Two Column Layout                                 */}
          {/* ================================================================ */}
          <div className="flex flex-col lg:flex-row gap-8 lg:gap-12 items-start lg:items-center justify-between mb-10">

            {/* Left Column - Greeting and Stats */}
            <div className="flex-1 max-w-2xl space-y-4">
              {/* Greeting */}
              <div className="relative">
                <h1 className="text-3xl md:text-4xl lg:text-5xl xl:text-6xl font-light tracking-tight text-foreground/90">
                  Good {getGreeting()},
                </h1>
                <div className="flex items-center gap-3 mt-1">
                  <h2 className="text-3xl md:text-4xl lg:text-5xl xl:text-6xl font-semibold tracking-tight text-foreground">
                    {firstName}
                  </h2>
                  <Sparkles className="hidden md:block h-8 w-8 text-amber-500" />
                </div>
              </div>

              <p className="text-base md:text-lg text-muted-foreground mt-3 max-w-lg">
                Track your projects and manage deadlines efficiently.
              </p>

              {/* Quick Stats Pills */}
              <div className="flex flex-wrap items-center gap-3 mt-4">
                <div className="flex items-center gap-2 px-4 py-2 rounded-full bg-card/60 backdrop-blur-sm border border-border/50">
                  <Zap className="h-4 w-4 text-amber-500" />
                  <span className="text-sm font-medium">{stats.inProgress} Active</span>
                </div>
                <div className="flex items-center gap-2 px-4 py-2 rounded-full bg-card/60 backdrop-blur-sm border border-border/50">
                  <CheckCircle2 className="h-4 w-4 text-emerald-500" />
                  <span className="text-sm font-medium">{stats.completed} Done</span>
                </div>
                {attentionProjects.length > 0 && (
                  <div className="flex items-center gap-2 px-4 py-2 rounded-full bg-rose-50 dark:bg-rose-950/30 border border-rose-200 dark:border-rose-800">
                    <CreditCard className="h-4 w-4 text-rose-500" />
                    <span className="text-sm font-medium text-rose-700 dark:text-rose-300">
                      {attentionProjects.length} Payment{attentionProjects.length !== 1 ? "s" : ""} Due
                    </span>
                  </div>
                )}
              </div>
            </div>

            {/* Right Column - Bento Grid */}
            <div className="w-full lg:w-auto lg:flex-shrink-0">
              <div className="grid grid-cols-2 gap-3 lg:gap-4 w-full lg:w-[380px]">

                {/* New Project - Dark Hero Card (full width) */}
                <Link
                  href="/projects/new"
                  className="col-span-2 group relative overflow-hidden rounded-[20px] p-5 lg:p-6 bg-gradient-to-br from-[#14110F] via-[#2a2118] to-[#14110F] text-white transition-all duration-300 hover:shadow-2xl hover:shadow-[#765341]/20 hover:-translate-y-1"
                >
                  {/* Warm amber glow overlay */}
                  <div className="absolute inset-0 bg-gradient-to-br from-amber-500/10 via-transparent to-orange-500/5 pointer-events-none" />
                  {/* Decorative blobs */}
                  <div className="absolute -top-8 -right-8 w-32 h-32 bg-gradient-to-br from-amber-400/20 to-orange-500/10 rounded-full blur-2xl" />
                  <div className="absolute -bottom-6 -left-6 w-24 h-24 bg-gradient-to-tr from-orange-400/15 to-transparent rounded-full blur-xl" />

                  <div className="relative z-10 flex items-center justify-between gap-4">
                    <div className="flex-1">
                      <div className="flex items-center gap-3 mb-3">
                        <div className="h-11 w-11 rounded-2xl bg-gradient-to-br from-amber-400 to-orange-500 flex items-center justify-center shadow-lg shadow-amber-500/25">
                          <Plus className="h-5 w-5 text-white" strokeWidth={2.5} />
                        </div>
                        <span className="px-2.5 py-1 rounded-full bg-white/10 backdrop-blur-sm text-[11px] font-medium text-white/90 border border-white/10">
                          Start Here
                        </span>
                      </div>
                      <h3 className="text-xl lg:text-[22px] font-semibold mb-1.5 tracking-tight">New Project</h3>
                      <p className="text-sm text-white/60 leading-relaxed">Upload assignment & get expert help</p>
                    </div>
                    <div className="h-14 w-14 rounded-2xl bg-white/10 backdrop-blur-sm flex items-center justify-center border border-white/10 transition-all duration-300 group-hover:bg-white/20 group-hover:scale-105 shrink-0">
                      <ArrowRight className="h-6 w-6 text-white/80 transition-transform duration-300 group-hover:translate-x-0.5" />
                    </div>
                  </div>
                </Link>

                {/* Active Projects Count Card - Amber/Orange accent */}
                <button
                  onClick={() => setSelectedTab("in_progress")}
                  className={cn(
                    "group relative overflow-hidden rounded-[20px] p-4 lg:p-5 backdrop-blur-xl border transition-all duration-300 hover:shadow-xl hover:-translate-y-1 text-left",
                    selectedTab === "in_progress"
                      ? "bg-amber-100/90 dark:bg-amber-950/50 border-amber-300 dark:border-amber-700 shadow-lg shadow-amber-500/10"
                      : "bg-white/70 dark:bg-white/5 border-amber-200/60 dark:border-amber-800/40 hover:bg-amber-50/80 dark:hover:bg-amber-950/40 hover:border-amber-300/80 dark:hover:border-amber-700/60"
                  )}
                >
                  <div className="absolute inset-0 bg-gradient-to-br from-amber-200/50 to-orange-100/30 dark:from-amber-800/30 dark:to-orange-900/20 pointer-events-none rounded-[20px]" />
                  <div className="absolute -inset-px rounded-[20px] bg-gradient-to-br from-amber-400/10 via-transparent to-orange-400/5 pointer-events-none" />
                  <div className="relative z-10">
                    <div className="h-11 w-11 rounded-2xl bg-gradient-to-br from-amber-500 to-orange-600 flex items-center justify-center mb-4 shadow-lg shadow-amber-500/30">
                      <Zap className="h-5 w-5 text-white" strokeWidth={1.5} />
                    </div>
                    <span className="text-3xl font-bold text-foreground">{stats.inProgress}</span>
                    <h3 className="font-medium text-foreground text-sm mt-1">Active Projects</h3>
                    <p className="text-xs text-muted-foreground/80 mt-0.5">Being worked on</p>
                  </div>
                  <ChevronRight className="absolute bottom-4 right-4 h-4 w-4 text-amber-500/60 dark:text-amber-400/60 opacity-0 group-hover:opacity-100 transition-all duration-300" />
                </button>

                {/* Completed Count Card - Green accent */}
                <button
                  onClick={() => setSelectedTab("history")}
                  className={cn(
                    "group relative overflow-hidden rounded-[20px] p-4 lg:p-5 backdrop-blur-xl border transition-all duration-300 hover:shadow-xl hover:-translate-y-1 text-left",
                    selectedTab === "history"
                      ? "bg-emerald-100/90 dark:bg-emerald-950/50 border-emerald-300 dark:border-emerald-700 shadow-lg shadow-emerald-500/10"
                      : "bg-white/70 dark:bg-white/5 border-emerald-200/60 dark:border-emerald-800/40 hover:bg-emerald-50/80 dark:hover:bg-emerald-950/40 hover:border-emerald-300/80 dark:hover:border-emerald-700/60"
                  )}
                >
                  <div className="absolute inset-0 bg-gradient-to-br from-emerald-200/50 to-teal-100/30 dark:from-emerald-800/30 dark:to-teal-900/20 pointer-events-none rounded-[20px]" />
                  <div className="absolute -inset-px rounded-[20px] bg-gradient-to-br from-emerald-400/10 via-transparent to-teal-400/5 pointer-events-none" />
                  <div className="relative z-10">
                    <div className="h-11 w-11 rounded-2xl bg-gradient-to-br from-emerald-500 to-teal-600 flex items-center justify-center mb-4 shadow-lg shadow-emerald-500/30">
                      <CheckCircle2 className="h-5 w-5 text-white" strokeWidth={1.5} />
                    </div>
                    <span className="text-3xl font-bold text-foreground">{stats.completed}</span>
                    <h3 className="font-medium text-foreground text-sm mt-1">Completed</h3>
                    <p className="text-xs text-muted-foreground/80 mt-0.5">All done</p>
                  </div>
                  <ChevronRight className="absolute bottom-4 right-4 h-4 w-4 text-emerald-500/60 dark:text-emerald-400/60 opacity-0 group-hover:opacity-100 transition-all duration-300" />
                </button>
              </div>
            </div>
          </div>

          {/* ================================================================ */}
          {/* PAYMENT ATTENTION SECTION                                        */}
          {/* ================================================================ */}
          {attentionProjects.length > 0 && (
            <section className="mb-8">
              <div className="flex items-center gap-2 mb-4">
                <div className="h-2 w-2 rounded-full bg-rose-500 animate-pulse" />
                <h2 className="text-sm font-semibold text-foreground uppercase tracking-wide">Action Required</h2>
                <span className="text-xs px-2 py-1 rounded-full bg-rose-100 dark:bg-rose-900/50 text-rose-700 dark:text-rose-300 font-medium">
                  {attentionProjects.length}
                </span>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {attentionProjects.map((project) => (
                  <PaymentCard key={project.id} project={project} onClick={() => handleProjectClick(project)} onPayNow={onPayNow} />
                ))}
              </div>
            </section>
          )}

          {/* ================================================================ */}
          {/* TABS + SEARCH BAR                                                */}
          {/* ================================================================ */}
          <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mb-6">
            {/* Glassmorphic Tab Bar */}
            <div className="flex items-center gap-1 p-1.5 bg-white/60 dark:bg-white/5 backdrop-blur-xl rounded-2xl border border-white/50 dark:border-white/10">
              {tabs.map((tab) => {
                const isActive = selectedTab === tab.value;
                const count = tabCounts[tab.value];
                const Icon = tab.icon;

                return (
                  <button
                    key={tab.value}
                    onClick={() => setSelectedTab(tab.value)}
                    className={cn(
                      "flex items-center gap-2 px-4 py-2.5 text-sm font-medium rounded-xl transition-all duration-200",
                      isActive
                        ? "bg-[#765341] text-white shadow-lg shadow-[#765341]/20"
                        : "text-muted-foreground hover:text-foreground hover:bg-white/50 dark:hover:bg-white/10"
                    )}
                  >
                    <Icon className="h-4 w-4" />
                    <span className="hidden sm:inline">{tab.label}</span>
                    {count > 0 && (
                      <span
                        className={cn(
                          "text-xs px-2 py-0.5 rounded-full tabular-nums",
                          isActive ? "bg-white/20 text-white" : "bg-muted text-muted-foreground"
                        )}
                      >
                        {count}
                      </span>
                    )}
                  </button>
                );
              })}
            </div>

            {/* Search */}
            <div className="relative w-full sm:w-auto">
              <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <input
                type="text"
                placeholder="Search projects..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full sm:w-72 h-11 pl-11 pr-4 text-sm bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#765341]/20 focus:border-[#765341]/50 transition-all"
              />
            </div>
          </div>

          {/* ================================================================ */}
          {/* PROJECTS GRID                                                    */}
          {/* ================================================================ */}
          {(() => {
            const displayableProjects = filteredProjects.filter(
              (p) => p.status !== "payment_pending" && p.status !== "quoted"
            );
            return displayableProjects.length === 0 ? (
              <EmptyState tab={selectedTab} searchQuery={searchQuery} onNewProject={() => router.push("/projects/new")} />
            ) : (
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
                {displayableProjects.map((project) => (
                  <ProjectCard key={project.id} project={project} onClick={() => handleProjectClick(project)} />
                ))}
              </div>
            );
          })()}
        </div>
      </div>
    </div>
  );
}

/**
 * Payment Card - Dark hero style for attention items
 */
function PaymentCard({
  project,
  onClick,
  onPayNow,
}: {
  project: Project;
  onClick: () => void;
  onPayNow?: (project: Project) => void;
}) {
  const quoteAmount = project.final_quote || project.user_quote || project.quoteAmount;
  const projectNumber = project.project_number || project.projectNumber;
  const deadlineUrgency = getDeadlineUrgency(project.deadline);

  return (
    <div
      onClick={onClick}
      className="group relative overflow-hidden rounded-[20px] p-5 bg-gradient-to-br from-rose-900 via-rose-950 to-neutral-950 text-white cursor-pointer transition-all duration-300 hover:shadow-2xl hover:shadow-rose-900/30 hover:-translate-y-1"
    >
      {/* Decorative elements */}
      <div className="absolute inset-0 bg-gradient-to-br from-rose-500/10 via-transparent to-orange-500/5 pointer-events-none" />
      <div className="absolute -top-6 -right-6 w-24 h-24 bg-gradient-to-br from-rose-400/20 to-orange-500/10 rounded-full blur-2xl" />
      <div className="absolute -bottom-4 -left-4 w-20 h-20 bg-gradient-to-tr from-pink-400/15 to-transparent rounded-full blur-xl" />

      <div className="relative z-10">
        {/* Badge Row */}
        <div className="flex items-center gap-2 mb-3">
          <span className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-white/10 backdrop-blur-sm text-[11px] font-medium text-white/90 border border-white/10">
            <CreditCard className="h-3.5 w-3.5" />
            Payment Due
          </span>
          {deadlineUrgency?.urgent && (
            <span className="flex items-center gap-1 px-2 py-1 rounded-full bg-red-500/20 text-[10px] font-medium text-red-200">
              <Timer className="h-3 w-3" />
              {deadlineUrgency.label}
            </span>
          )}
        </div>

        {/* Title */}
        <h3 className="font-semibold text-white line-clamp-1 text-base mb-1">{project.title}</h3>
        <p className="text-xs text-white/50 mb-4">
          #{projectNumber}
          {project.subject?.name && ` \u00B7 ${project.subject.name}`}
        </p>

        {/* Amount */}
        <div className="flex items-end justify-between">
          <div>
            <p className="text-[10px] text-white/40 uppercase tracking-wider mb-1">Amount</p>
            <p className="text-2xl font-bold text-white">{"\u20B9"}{(quoteAmount || 0).toLocaleString()}</p>
          </div>

          {/* Pay Button */}
          <button
            onClick={(e) => {
              e.stopPropagation();
              if (onPayNow) onPayNow(project);
            }}
            className="flex items-center gap-2 px-4 py-2.5 bg-white text-rose-900 font-semibold text-sm rounded-xl hover:bg-white/90 transition-all duration-200 shadow-lg shadow-black/20"
          >
            Pay Now
            <ArrowRight className="h-4 w-4" />
          </button>
        </div>
      </div>
    </div>
  );
}

/**
 * Project Card - Glassmorphic with status color stripe on left edge
 */
function ProjectCard({ project, onClick }: { project: Project; onClick: () => void }) {
  const status = statusConfig[project.status] || statusConfig.submitted;
  const isCompleted = project.status === "completed" || project.status === "auto_approved";
  const isDelivered = project.status === "delivered" || project.status === "qc_approved";
  const isActive = project.status === "in_progress" || project.status === "assigned" || project.status === "assigning";
  const isDraft = project.status === "draft";

  const progress = project.progress ?? project.progress_percentage ?? 0;
  const lastUpdated = project.updated_at || project.created_at;
  const deadlineUrgency = getDeadlineUrgency(project.deadline);
  const projectNumber = project.project_number || project.projectNumber;

  return (
    <div
      onClick={onClick}
      className="group relative overflow-hidden rounded-[20px] bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 cursor-pointer transition-all duration-300 hover:shadow-xl hover:shadow-black/5 hover:-translate-y-1"
    >
      {/* Status color stripe on left edge */}
      <div className={cn("absolute left-0 top-0 bottom-0 w-1 rounded-l-[20px]", status.stripe)} />

      <div className="p-5 pl-6">
        {/* Title and Status Row */}
        <div className="flex items-start justify-between gap-3 mb-2">
          <h3 className="font-semibold text-foreground line-clamp-2 text-[15px] leading-snug flex-1">
            {project.title}
          </h3>
          {/* Status Badge */}
          <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-white/80 dark:bg-white/10 border border-white/60 dark:border-white/10 shrink-0">
            <div className={cn("h-1.5 w-1.5 rounded-full", status.dot)} />
            <span className="text-[11px] font-medium text-muted-foreground whitespace-nowrap">{status.label}</span>
          </div>
        </div>

        {/* Project ID and Subject */}
        <p className="text-xs text-muted-foreground mb-3">
          #{projectNumber}
          {project.subject?.name && (
            <span className="ml-2 inline-flex items-center gap-1 px-2 py-0.5 rounded-md bg-[#765341]/10 dark:bg-[#765341]/20 text-[#765341] dark:text-[#E4E1C7] text-[10px] font-medium">
              <BookOpen className="h-2.5 w-2.5" />
              {project.subject.name}
            </span>
          )}
        </p>

        {/* Progress Bar - Active projects */}
        {isActive && progress > 0 && (
          <div className="mb-3">
            <div className="flex items-center justify-between mb-1.5">
              <span className="text-xs text-muted-foreground">Progress</span>
              <span className="text-xs font-semibold tabular-nums">{progress}%</span>
            </div>
            <div className="h-1.5 bg-muted/50 rounded-full overflow-hidden">
              <div
                className="h-full bg-gradient-to-r from-amber-500 to-orange-500 rounded-full transition-all duration-500"
                style={{ width: `${progress}%` }}
              />
            </div>
          </div>
        )}

        {/* Delivered indicator */}
        {isDelivered && (
          <div className="mb-3 flex items-center gap-2 px-3 py-2 rounded-xl bg-emerald-100/80 dark:bg-emerald-900/30">
            <CheckCircle2 className="h-4 w-4 text-emerald-600 dark:text-emerald-400" />
            <span className="text-xs font-medium text-emerald-700 dark:text-emerald-300">Ready for Review</span>
          </div>
        )}

        {/* Footer - Deadline and Action */}
        <div className="flex items-center justify-between pt-3 border-t border-border/20">
          {/* Deadline Chip */}
          <div className="flex items-center gap-2 text-xs text-muted-foreground">
            {deadlineUrgency ? (
              <span
                className={cn(
                  "flex items-center gap-1 px-2 py-1 rounded-lg",
                  deadlineUrgency.urgent
                    ? "bg-rose-100/80 dark:bg-rose-900/30 text-rose-600 dark:text-rose-400 font-medium"
                    : "bg-muted/50 text-muted-foreground"
                )}
              >
                <Timer className="h-3 w-3" />
                {deadlineUrgency.label}
              </span>
            ) : lastUpdated ? (
              <span className="text-muted-foreground/70">{formatDistanceToNow(new Date(lastUpdated), { addSuffix: true })}</span>
            ) : null}
          </div>

          {/* Quick action button on hover */}
          <div className="h-8 w-8 rounded-xl bg-[#765341]/10 dark:bg-[#765341]/20 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-all duration-300 group-hover:translate-x-0">
            <ChevronRight className="h-4 w-4 text-[#765341] dark:text-[#E4E1C7]" />
          </div>
        </div>
      </div>
    </div>
  );
}

/**
 * Get deadline urgency info
 */
function getDeadlineUrgency(deadline: string | null | undefined): { label: string; urgent: boolean } | null {
  if (!deadline) return null;

  const now = new Date();
  const deadlineDate = new Date(deadline);
  const daysLeft = differenceInDays(deadlineDate, now);
  const hoursLeft = differenceInHours(deadlineDate, now);

  if (hoursLeft < 0) return { label: "Overdue", urgent: true };
  if (hoursLeft <= 24) return { label: `${hoursLeft}h left`, urgent: true };
  if (daysLeft <= 2) return { label: `${daysLeft}d left`, urgent: true };
  if (daysLeft <= 7) return { label: `${daysLeft} days`, urgent: false };
  return { label: `${daysLeft} days`, urgent: false };
}

/**
 * Empty State - Glassmorphic style with illustration text
 */
function EmptyState({
  tab,
  searchQuery,
  onNewProject,
}: {
  tab: ProjectTab;
  searchQuery: string;
  onNewProject: () => void;
}) {
  if (searchQuery) {
    return (
      <div className="flex flex-col items-center justify-center pt-16 pb-36 text-center">
        <div className="h-16 w-16 rounded-[20px] bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 flex items-center justify-center mb-5 shadow-lg">
          <Search className="h-7 w-7 text-muted-foreground" />
        </div>
        <h3 className="text-xl font-semibold mb-2">No results found</h3>
        <p className="text-sm text-muted-foreground max-w-xs">
          No projects match &quot;{searchQuery}&quot;. Try a different search term.
        </p>
      </div>
    );
  }

  const emptyConfig: Record<string, { icon: React.ElementType; title: string; message: string; gradient: string }> = {
    in_progress: {
      icon: Zap,
      title: "No active projects",
      message: "Projects being worked on by experts will appear here. Create one to get started!",
      gradient: "from-amber-400 to-orange-500",
    },
    in_review: {
      icon: Eye,
      title: "Nothing in review",
      message: "Projects under quality review will show up here.",
      gradient: "from-blue-400 to-cyan-500",
    },
    for_review: {
      icon: Clock,
      title: "Nothing pending",
      message: "Delivered work waiting for your review will appear here.",
      gradient: "from-[#765341] to-[#96705e]",
    },
    history: {
      icon: CheckCircle2,
      title: "No completed projects yet",
      message: "Your finished and approved projects will be archived here.",
      gradient: "from-emerald-400 to-teal-500",
    },
  };

  const config = emptyConfig[tab] || emptyConfig.in_progress;
  const Icon = config.icon;

  return (
    <div className="flex flex-col items-center justify-center pt-16 pb-36 text-center">
      <div className="relative mb-5">
        <div
          className={cn(
            "h-16 w-16 rounded-[20px] bg-gradient-to-br flex items-center justify-center shadow-lg",
            config.gradient
          )}
        >
          <Icon className="h-7 w-7 text-white" />
        </div>
        <div className="absolute -inset-4 bg-gradient-to-br from-white/20 to-transparent rounded-full blur-xl pointer-events-none" />
      </div>
      <h3 className="text-xl font-semibold mb-2">{config.title}</h3>
      <p className="text-sm text-muted-foreground mb-6 max-w-xs">{config.message}</p>
      <Button
        onClick={onNewProject}
        className="gap-2 rounded-xl h-11 px-6 bg-[#765341] hover:bg-[#654332] text-white"
      >
        <Plus className="h-4 w-4" />
        Create Project
      </Button>
    </div>
  );
}
