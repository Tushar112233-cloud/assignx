"use client";

/**
 * Projects Pro - Ultra Premium Gen Z Design
 *
 * Matching the aesthetic of dashboard-pro and auth pages:
 * - Glassmorphic bento cards
 * - Gradient overlays and decorative blobs
 * - Premium hover states with shadows
 * - Dark hero cards for attention items
 * - Floating card animations
 * - Split layout with greeting + bento grid
 */

import { useState, useMemo, useCallback, useEffect, useRef } from "react";
import { useRouter } from "next/navigation";
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
  TrendingUp,
  Star,
  FileText,
  Rocket,
  Crown,
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
 * Status configuration
 */
const statusConfig: Record<string, { label: string; dot: string }> = {
  draft: { label: "Draft", dot: "bg-muted-foreground" },
  submitted: { label: "Submitted", dot: "bg-amber-500" },
  analyzing: { label: "Analyzing", dot: "bg-amber-500" },
  quoted: { label: "Quote Ready", dot: "bg-rose-500" },
  payment_pending: { label: "Payment Due", dot: "bg-rose-500" },
  paid: { label: "Paid", dot: "bg-blue-500" },
  assigning: { label: "Matching Expert", dot: "bg-blue-500" },
  assigned: { label: "Expert Assigned", dot: "bg-violet-500" },
  in_progress: { label: "In Progress", dot: "bg-violet-500" },
  submitted_for_qc: { label: "Quality Check", dot: "bg-indigo-500" },
  qc_in_progress: { label: "QC Review", dot: "bg-indigo-500" },
  qc_approved: { label: "Approved", dot: "bg-emerald-500" },
  qc_rejected: { label: "Revision Needed", dot: "bg-red-500" },
  delivered: { label: "Delivered", dot: "bg-emerald-500" },
  revision_requested: { label: "Revision Requested", dot: "bg-orange-500" },
  in_revision: { label: "In Revision", dot: "bg-blue-500" },
  completed: { label: "Completed", dot: "bg-emerald-500" },
  auto_approved: { label: "Completed", dot: "bg-emerald-500" },
  cancelled: { label: "Cancelled", dot: "bg-muted-foreground" },
  refunded: { label: "Refunded", dot: "bg-muted-foreground" },
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
 * Main Projects Component - Ultra Premium Design
 */
export function ProjectsPro({ onPayNow }: ProjectsProProps) {
  const router = useRouter();
  const { getProjectsByTab, projects } = useProjectStore();
  const { user } = useUserStore();

  const [searchQuery, setSearchQuery] = useState("");
  const [selectedTab, setSelectedTab] = useState<ProjectTab>("in_progress");
  const hasAutoSelected = useRef(false);

  // User's first name
  const firstName = useMemo(() => {
    if (!user) return "there";
    const fullName = user.fullName || user.full_name || user.email?.split("@")[0] || "";
    return fullName.split(" ")[0] || "there";
  }, [user]);

  // Projects for selected tab
  const displayProjects = useMemo(() => {
    return getProjectsByTab(selectedTab);
  }, [selectedTab, getProjectsByTab]);

  // Stats
  const stats = useMemo(() => {
    const inProgress = getProjectsByTab("in_progress").length;
    const inReview = getProjectsByTab("in_review").length;
    const forReview = getProjectsByTab("for_review").length;
    const completed = getProjectsByTab("history").filter(
      (p) => p.status === "completed" || p.status === "auto_approved"
    ).length;
    return { inProgress, inReview, forReview, completed, total: projects.length };
  }, [projects, getProjectsByTab]);

  // Tab counts
  const tabCounts = useMemo(() => {
    const counts: Record<string, number> = {};
    tabs.forEach((tab) => {
      counts[tab.value] = getProjectsByTab(tab.value).length;
    });
    return counts;
  }, [getProjectsByTab]);

  // Search filter
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

  // Payment pending projects
  const attentionProjects = useMemo(() => {
    return projects.filter((p) => p.status === "payment_pending" || p.status === "quoted");
  }, [projects]);

  // Handle project click
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

  // Auto-select tab with projects (only on initial mount, not on user tab switches)
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
    <>
      {/* Mesh Gradient Background */}
      <div className={cn("mesh-background mesh-gradient-bottom-right-animated h-full overflow-hidden", getTimeBasedGradientClass())}>
        <div className="relative z-10 h-full px-4 py-6 md:px-6 md:py-8 lg:px-8 lg:py-10 overflow-y-auto">
          <div className="max-w-[1400px] mx-auto">
            {/* ═══════════════════════════════════════════════════════════════ */}
            {/* HERO SECTION - Two Column Layout */}
            {/* ═══════════════════════════════════════════════════════════════ */}
            <div className="flex flex-col lg:flex-row gap-8 lg:gap-12 items-start lg:items-center justify-between mb-8">
              {/* Left Column - Greeting & Stats */}
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

                {/* Quick Stats Row */}
                <div className="flex flex-wrap items-center gap-3 mt-4">
                  <div className="flex items-center gap-2 px-4 py-2 rounded-full bg-card/60 backdrop-blur-sm border border-border/50">
                    <Zap className="h-4 w-4 text-violet-500" />
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

              {/* Right Column - Quick Actions Bento */}
              <div className="w-full lg:w-auto lg:flex-shrink-0">
                <div className="grid grid-cols-2 gap-3 lg:gap-4 w-full lg:w-[380px]">
                  {/* New Project - Hero Card */}
                  <button
                    onClick={() => router.push('/projects/new')}
                    className="col-span-2 group relative overflow-hidden rounded-[20px] p-5 lg:p-6 bg-gradient-to-br from-stone-800 via-stone-900 to-neutral-900 dark:from-stone-800 dark:via-stone-900 dark:to-neutral-950 text-white transition-all duration-300 hover:shadow-2xl hover:shadow-stone-900/30 hover:-translate-y-1 text-left"
                  >
                    {/* Decorative gradient overlay */}
                    <div className="absolute inset-0 bg-gradient-to-br from-orange-500/10 via-transparent to-rose-500/5 pointer-events-none" />
                    {/* Decorative circles */}
                    <div className="absolute -top-8 -right-8 w-32 h-32 bg-gradient-to-br from-orange-400/20 to-amber-500/10 rounded-full blur-2xl" />
                    <div className="absolute -bottom-6 -left-6 w-24 h-24 bg-gradient-to-tr from-rose-400/15 to-transparent rounded-full blur-xl" />

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
                        <h3 className="text-xl lg:text-[22px] font-semibold mb-1.5 tracking-tight">New Project</h3>
                        <p className="text-sm text-white/60 leading-relaxed">Upload assignment & get expert help</p>
                      </div>
                      <div className="h-14 w-14 rounded-2xl bg-white/10 backdrop-blur-sm flex items-center justify-center border border-white/10 transition-all duration-300 group-hover:bg-white/20 group-hover:scale-105 shrink-0">
                        <ArrowRight className="h-6 w-6 text-white/80 transition-transform duration-300 group-hover:translate-x-0.5" />
                      </div>
                    </div>
                  </button>

                  {/* Active Projects Card - Enhanced violet styling */}
                  <button
                    onClick={() => setSelectedTab("in_progress")}
                    className={cn(
                      "group relative overflow-hidden rounded-[20px] p-4 lg:p-5 backdrop-blur-xl border transition-all duration-300 hover:shadow-xl hover:-translate-y-1 text-left",
                      selectedTab === "in_progress"
                        ? "bg-violet-100/90 dark:bg-violet-950/50 border-violet-300 dark:border-violet-700 shadow-lg shadow-violet-500/10"
                        : "bg-white/80 dark:bg-violet-950/20 border-violet-200/60 dark:border-violet-800/40 hover:bg-violet-50/80 dark:hover:bg-violet-950/40 hover:border-violet-300/80 dark:hover:border-violet-700/60"
                    )}
                  >
                    <div className="absolute inset-0 bg-gradient-to-br from-violet-200/50 to-purple-100/30 dark:from-violet-800/30 dark:to-purple-900/20 pointer-events-none rounded-[20px]" />
                    {/* Subtle glow */}
                    <div className="absolute -inset-px rounded-[20px] bg-gradient-to-br from-violet-400/10 via-transparent to-purple-400/5 pointer-events-none" />
                    <div className="relative z-10">
                      <div className="h-11 w-11 rounded-2xl bg-gradient-to-br from-violet-500 to-purple-600 flex items-center justify-center mb-4 shadow-lg shadow-violet-500/30">
                        <Zap className="h-5 w-5 text-white" strokeWidth={1.5} />
                      </div>
                      <span className="text-3xl font-bold text-foreground">{stats.inProgress}</span>
                      <h3 className="font-medium text-foreground text-sm mt-1">Active Projects</h3>
                      <p className="text-xs text-muted-foreground/80 mt-0.5">Being worked on</p>
                    </div>
                    <ChevronRight className="absolute bottom-4 right-4 h-4 w-4 text-violet-500/60 dark:text-violet-400/60 opacity-0 group-hover:opacity-100 transition-all duration-300" />
                  </button>

                  {/* Completed Card - Enhanced emerald styling */}
                  <button
                    onClick={() => setSelectedTab("history")}
                    className={cn(
                      "group relative overflow-hidden rounded-[20px] p-4 lg:p-5 backdrop-blur-xl border transition-all duration-300 hover:shadow-xl hover:-translate-y-1 text-left",
                      selectedTab === "history"
                        ? "bg-emerald-100/90 dark:bg-emerald-950/50 border-emerald-300 dark:border-emerald-700 shadow-lg shadow-emerald-500/10"
                        : "bg-white/80 dark:bg-emerald-950/20 border-emerald-200/60 dark:border-emerald-800/40 hover:bg-emerald-50/80 dark:hover:bg-emerald-950/40 hover:border-emerald-300/80 dark:hover:border-emerald-700/60"
                    )}
                  >
                    <div className="absolute inset-0 bg-gradient-to-br from-emerald-200/50 to-teal-100/30 dark:from-emerald-800/30 dark:to-teal-900/20 pointer-events-none rounded-[20px]" />
                    {/* Subtle glow */}
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

            {/* ═══════════════════════════════════════════════════════════════ */}
            {/* PAYMENT ATTENTION SECTION */}
            {/* ═══════════════════════════════════════════════════════════════ */}
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

            {/* ═══════════════════════════════════════════════════════════════ */}
            {/* TABS + SEARCH */}
            {/* ═══════════════════════════════════════════════════════════════ */}
            <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mb-6">
              {/* Tabs */}
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
                          ? "bg-foreground text-background shadow-lg"
                          : "text-muted-foreground hover:text-foreground hover:bg-white/50 dark:hover:bg-white/10"
                      )}
                    >
                      <Icon className="h-4 w-4" />
                      <span className="hidden sm:inline">{tab.label}</span>
                      {count > 0 && (
                        <span
                          className={cn(
                            "text-xs px-2 py-0.5 rounded-full tabular-nums",
                            isActive ? "bg-background/20 text-background" : "bg-muted text-muted-foreground"
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
                  className="w-full sm:w-72 h-11 pl-11 pr-4 text-sm bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 rounded-xl focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary/50 transition-all"
                />
              </div>
            </div>

            {/* ═══════════════════════════════════════════════════════════════ */}
            {/* PROJECTS GRID */}
            {/* ═══════════════════════════════════════════════════════════════ */}
            {(() => {
              const displayableProjects = filteredProjects.filter((p) => p.status !== "payment_pending" && p.status !== "quoted");
              return displayableProjects.length === 0 ? (
                <EmptyState tab={selectedTab} searchQuery={searchQuery} onNewProject={() => router.push('/projects/new')} />
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
    </>
  );
}

/**
 * Payment Card - Premium Dark Hero Style
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
          {project.subject?.name && ` · ${project.subject.name}`}
        </p>

        {/* Amount */}
        <div className="flex items-end justify-between">
          <div>
            <p className="text-[10px] text-white/40 uppercase tracking-wider mb-1">Amount</p>
            <p className="text-2xl font-bold text-white">₹{(quoteAmount || 0).toLocaleString()}</p>
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
 * Project Card - Glassmorphic Style with Enhanced Visibility
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

  // Card accent color based on status - ENHANCED for better visibility
  const getAccentColor = () => {
    if (isDelivered || isCompleted) return "from-emerald-100/60 to-teal-50/40 dark:from-emerald-900/30 dark:to-emerald-950/20";
    if (isActive) return "from-violet-100/70 to-purple-100/50 dark:from-violet-900/40 dark:to-purple-950/30";
    if (isDraft) return "from-gray-100/50 to-slate-50/30 dark:from-gray-900/20 dark:to-slate-950/10";
    return "from-amber-100/60 to-orange-50/40 dark:from-amber-900/30 dark:to-orange-950/20";
  };

  const getIconBg = () => {
    if (isDelivered || isCompleted) return "from-emerald-400 to-teal-500";
    if (isActive) return "from-violet-500 to-purple-600";
    if (isDraft) return "from-gray-400 to-slate-500";
    return "from-amber-400 to-orange-500";
  };

  // Card background and border styling based on status
  const getCardStyle = () => {
    if (isActive) {
      return "bg-white/80 dark:bg-violet-950/40 border-violet-200/70 dark:border-violet-700/50 hover:border-violet-300 dark:hover:border-violet-600 hover:shadow-violet-500/10";
    }
    if (isDelivered || isCompleted) {
      return "bg-white/80 dark:bg-emerald-950/30 border-emerald-200/60 dark:border-emerald-800/40 hover:border-emerald-300 dark:hover:border-emerald-700";
    }
    return "bg-white/70 dark:bg-white/5 border-white/50 dark:border-white/10 hover:bg-white/90 dark:hover:bg-white/10";
  };

  const StatusIcon = isDelivered || isCompleted ? CheckCircle2 : isActive ? Zap : isDraft ? FileText : Clock;

  return (
    <div
      onClick={onClick}
      className={cn(
        "group relative overflow-hidden rounded-[20px] p-5 backdrop-blur-xl border cursor-pointer transition-all duration-300 hover:shadow-xl hover:-translate-y-1",
        getCardStyle()
      )}
    >
      {/* Gradient overlay */}
      <div className={cn("absolute inset-0 bg-gradient-to-br pointer-events-none rounded-[20px]", getAccentColor())} />

      {/* Active status glow effect */}
      {isActive && (
        <div className="absolute -inset-px rounded-[20px] bg-gradient-to-br from-violet-400/20 via-transparent to-purple-400/10 pointer-events-none" />
      )}

      <div className="relative z-10">
        {/* Icon + Status Row */}
        <div className="flex items-start justify-between mb-4">
          <div className={cn("h-11 w-11 rounded-2xl bg-gradient-to-br flex items-center justify-center shadow-lg", getIconBg())}>
            <StatusIcon className="h-5 w-5 text-white" strokeWidth={1.5} />
          </div>
          <div className="flex items-center gap-1.5">
            <div className={cn("h-2 w-2 rounded-full", status.dot)} />
            <span className="text-xs font-medium text-muted-foreground">{status.label}</span>
          </div>
        </div>

        {/* Title */}
        <h3 className="font-semibold text-foreground line-clamp-2 text-[15px] leading-snug mb-1">{project.title}</h3>
        <p className="text-xs text-muted-foreground mb-3">
          #{projectNumber}
          {project.subject?.name && ` · ${project.subject.name}`}
        </p>

        {/* Progress Bar - Active projects */}
        {isActive && progress > 0 && (
          <div className="mb-3">
            <div className="flex items-center justify-between mb-1.5">
              <span className="text-xs text-muted-foreground">Progress</span>
              <span className="text-xs font-semibold tabular-nums">{progress}%</span>
            </div>
            <div className="h-2 bg-muted/50 rounded-full overflow-hidden">
              <div
                className="h-full bg-gradient-to-r from-violet-500 to-purple-500 rounded-full transition-all duration-500"
                style={{ width: `${progress}%` }}
              />
            </div>
          </div>
        )}

        {/* Delivered indicator */}
        {isDelivered && (
          <div className="mb-3 flex items-center gap-2 px-3 py-2 rounded-xl bg-emerald-100/80 dark:bg-emerald-900/30">
            <Star className="h-4 w-4 text-emerald-600 dark:text-emerald-400" />
            <span className="text-xs font-medium text-emerald-700 dark:text-emerald-300">Ready for Review</span>
          </div>
        )}

        {/* Footer */}
        <div className="flex items-center justify-between pt-3 border-t border-border/30">
          <div className="flex items-center gap-2 text-xs text-muted-foreground">
            {deadlineUrgency ? (
              <span className={cn("flex items-center gap-1", deadlineUrgency.urgent && "text-rose-600 dark:text-rose-400")}>
                <Timer className="h-3 w-3" />
                {deadlineUrgency.label}
              </span>
            ) : lastUpdated ? (
              <span>{formatDistanceToNow(new Date(lastUpdated), { addSuffix: true })}</span>
            ) : null}
          </div>
          <ChevronRight className="h-4 w-4 text-muted-foreground/40 opacity-0 group-hover:opacity-100 transition-all duration-300 group-hover:translate-x-0.5" />
        </div>
      </div>
    </div>
  );
}

/**
 * Get deadline urgency
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
 * Empty State - Premium Style
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
        <p className="text-sm text-muted-foreground max-w-xs">No projects match &quot;{searchQuery}&quot;</p>
      </div>
    );
  }

  const emptyConfig: Record<string, { icon: React.ElementType; title: string; message: string; gradient: string }> = {
    in_progress: {
      icon: Zap,
      title: "No active projects",
      message: "Projects being worked on will show here",
      gradient: "from-violet-400 to-purple-500",
    },
    in_review: {
      icon: Eye,
      title: "Nothing in review",
      message: "Projects under review will appear here",
      gradient: "from-blue-400 to-cyan-500",
    },
    for_review: {
      icon: Clock,
      title: "Nothing pending",
      message: "Completed work ready for review appears here",
      gradient: "from-amber-400 to-orange-500",
    },
    history: {
      icon: CheckCircle2,
      title: "No completed projects",
      message: "Your finished projects will be stored here",
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
      <Button onClick={onNewProject} className="gap-2 rounded-xl h-11 px-6">
        <Plus className="h-4 w-4" />
        Create Project
      </Button>
    </div>
  );
}
