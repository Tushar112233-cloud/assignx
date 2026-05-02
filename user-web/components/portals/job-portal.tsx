"use client";

import { useState, useMemo, useEffect, useCallback, useRef } from "react";
import { motion, useReducedMotion } from "framer-motion";
import {
  Search,
  MapPin,
  Briefcase,
  DollarSign,
  Clock,
  ExternalLink,
  Filter,
  Wifi,
  Building2,
  Upload,
  Users,
  FileText,
  CheckCircle2,
  XCircle,
  Loader2,
  ArrowLeft,
} from "lucide-react";
import { LiveStatsBadge } from "@/components/campus-connect/live-stats-badge";
import { cn } from "@/lib/utils";
import { apiClient } from "@/lib/api/client";
import type { JobListing, JobCategory, JobType, JobApplicationEntry } from "@/types/portals";

const CATEGORIES: { value: JobCategory | "all"; label: string }[] = [
  { value: "all", label: "All" },
  { value: "engineering", label: "Engineering" },
  { value: "design", label: "Design" },
  { value: "marketing", label: "Marketing" },
  { value: "sales", label: "Sales" },
  { value: "finance", label: "Finance" },
  { value: "product", label: "Product" },
  { value: "data", label: "Data" },
  { value: "operations", label: "Operations" },
  { value: "hr", label: "HR" },
];

const JOB_TYPES: { value: JobType | "all"; label: string }[] = [
  { value: "all", label: "All Types" },
  { value: "full-time", label: "Full-time" },
  { value: "part-time", label: "Part-time" },
  { value: "contract", label: "Contract" },
  { value: "internship", label: "Internship" },
  { value: "freelance", label: "Freelance" },
];

/** Per-type color theme for glassmorphism cards */
const JOB_TYPE_THEME: Record<
  JobType,
  {
    cardGradient: string;
    border: string;
    hoverShadow: string;
    avatar: string;
    badgeBg: string;
    badgeText: string;
    salary: string;
    titleHover: string;
    button: string;
  }
> = {
  "full-time": {
    cardGradient: "from-emerald-500/10",
    border: "border-emerald-500/20",
    hoverShadow: "hover:shadow-emerald-500/10",
    avatar: "bg-gradient-to-br from-emerald-500 to-teal-500",
    badgeBg: "bg-emerald-500/15",
    badgeText: "text-emerald-700 dark:text-emerald-400",
    salary: "text-emerald-600 dark:text-emerald-400",
    titleHover: "group-hover:text-emerald-600 dark:group-hover:text-emerald-400",
    button: "bg-gradient-to-r from-emerald-600 to-teal-600 hover:from-emerald-500 hover:to-teal-500",
  },
  "part-time": {
    cardGradient: "from-blue-500/10",
    border: "border-blue-500/20",
    hoverShadow: "hover:shadow-blue-500/10",
    avatar: "bg-gradient-to-br from-blue-500 to-cyan-500",
    badgeBg: "bg-blue-500/15",
    badgeText: "text-blue-700 dark:text-blue-400",
    salary: "text-blue-600 dark:text-blue-400",
    titleHover: "group-hover:text-blue-600 dark:group-hover:text-blue-400",
    button: "bg-gradient-to-r from-blue-600 to-cyan-600 hover:from-blue-500 hover:to-cyan-500",
  },
  contract: {
    cardGradient: "from-amber-500/10",
    border: "border-amber-500/20",
    hoverShadow: "hover:shadow-amber-500/10",
    avatar: "bg-gradient-to-br from-amber-500 to-orange-500",
    badgeBg: "bg-amber-500/15",
    badgeText: "text-amber-700 dark:text-amber-400",
    salary: "text-amber-600 dark:text-amber-400",
    titleHover: "group-hover:text-amber-600 dark:group-hover:text-amber-400",
    button: "bg-gradient-to-r from-amber-600 to-orange-600 hover:from-amber-500 hover:to-orange-500",
  },
  internship: {
    cardGradient: "from-violet-500/10",
    border: "border-violet-500/20",
    hoverShadow: "hover:shadow-violet-500/10",
    avatar: "bg-gradient-to-br from-violet-500 to-purple-500",
    badgeBg: "bg-violet-500/15",
    badgeText: "text-violet-700 dark:text-violet-400",
    salary: "text-violet-600 dark:text-violet-400",
    titleHover: "group-hover:text-violet-600 dark:group-hover:text-violet-400",
    button: "bg-gradient-to-r from-violet-600 to-purple-600 hover:from-violet-500 hover:to-purple-500",
  },
  freelance: {
    cardGradient: "from-rose-500/10",
    border: "border-rose-500/20",
    hoverShadow: "hover:shadow-rose-500/10",
    avatar: "bg-gradient-to-br from-rose-500 to-pink-500",
    badgeBg: "bg-rose-500/15",
    badgeText: "text-rose-700 dark:text-rose-400",
    salary: "text-rose-600 dark:text-rose-400",
    titleHover: "group-hover:text-rose-600 dark:group-hover:text-rose-400",
    button: "bg-gradient-to-r from-rose-600 to-pink-600 hover:from-rose-500 hover:to-pink-500",
  },
};

/** Distributes items round-robin across N columns for masonry layout */
function distributeIntoColumns<T>(items: T[], colCount: number): T[][] {
  if (colCount <= 0) return [items];
  const columns: T[][] = Array.from({ length: colCount }, () => []);
  items.forEach((item, i) => columns[i % colCount].push(item));
  return columns;
}

/** Reactive column count: 3 >=1024px, 2 >=640px, 1 mobile */
function useColumnCount(): number {
  const [cols, setCols] = useState<number | null>(null);
  useEffect(() => {
    const update = () => {
      if (window.innerWidth >= 1024) setCols(3);
      else if (window.innerWidth >= 640) setCols(2);
      else setCols(1);
    };
    update();
    window.addEventListener("resize", update);
    return () => window.removeEventListener("resize", update);
  }, []);
  return cols ?? 1;
}

const staggerContainer = {
  hidden: {},
  show: { transition: { staggerChildren: 0.15 } },
};

const fadeInUp = {
  hidden: { opacity: 0, y: 30 },
  show: { opacity: 1, y: 0, transition: { duration: 0.6, ease: 'easeOut' as const } },
};

const HERO_SPARKLE_INDICES = [0, 1, 2, 3, 4, 5];

// ============================================================================
// Application Status Badge
// ============================================================================

const STATUS_STYLES: Record<string, { bg: string; text: string }> = {
  applied: { bg: "bg-blue-500/15", text: "text-blue-600 dark:text-blue-400" },
  reviewing: { bg: "bg-amber-500/15", text: "text-amber-600 dark:text-amber-400" },
  shortlisted: { bg: "bg-emerald-500/15", text: "text-emerald-600 dark:text-emerald-400" },
  rejected: { bg: "bg-red-500/15", text: "text-red-600 dark:text-red-400" },
};

// ============================================================================
// JobCard
// ============================================================================

function JobCard({
  job,
  onApply,
  appliedJobIds,
  isApplying,
}: {
  job: JobListing;
  onApply: (jobId: string) => void;
  appliedJobIds: Set<string>;
  isApplying: string | null;
}) {
  const prefersReducedMotion = useReducedMotion();
  const theme = JOB_TYPE_THEME[job.type];
  const companyInitial = job.company.charAt(0).toUpperCase();
  const hasApplied = appliedJobIds.has(job.id);
  const currentlyApplying = isApplying === job.id;

  return (
    <motion.div
      initial={prefersReducedMotion ? false : { opacity: 0, y: 20 }}
      animate={prefersReducedMotion ? {} : { opacity: 1, y: 0 }}
      transition={{ duration: 0.35 }}
      className={cn(
        "group rounded-2xl border bg-gradient-to-br to-transparent",
        "shadow-sm hover:shadow-md hover:-translate-y-1 transition-all duration-300 p-5 space-y-3",
        theme.cardGradient,
        theme.border,
        theme.hoverShadow
      )}
    >
      {/* Avatar row */}
      <div className="flex items-center justify-between gap-2">
        <div
          className={cn(
            "h-10 w-10 rounded-full flex items-center justify-center shrink-0 text-white font-bold text-sm shadow-sm",
            theme.avatar
          )}
        >
          {job.companyLogo ? (
            <img src={job.companyLogo} alt={job.company} className="h-10 w-10 rounded-full object-cover" />
          ) : (
            companyInitial
          )}
        </div>
        <div className="flex items-center gap-1 shrink-0">
          <span
            className={cn(
              "px-2 py-0.5 rounded-full text-[10px] font-medium capitalize border border-border/30",
              theme.badgeBg,
              theme.badgeText
            )}
          >
            {job.type}
          </span>
          {job.isRemote && (
            <span className="flex items-center gap-0.5 px-2 py-0.5 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-[10px] font-medium text-emerald-600 dark:text-emerald-400">
              <Wifi className="h-2.5 w-2.5" aria-hidden="true" />
              Remote
            </span>
          )}
        </div>
      </div>

      {/* Job title */}
      <h3
        className={cn(
          "text-sm font-bold text-foreground line-clamp-2 leading-snug transition-colors",
          theme.titleHover
        )}
      >
        {job.title}
      </h3>

      {/* Company + Location */}
      <p className="text-xs text-muted-foreground flex items-center gap-1">
        <Building2 className="h-3 w-3 shrink-0" aria-hidden="true" />
        <span className="truncate">{job.company}</span>
        <span className="mx-0.5">·</span>
        <MapPin className="h-3 w-3 shrink-0" aria-hidden="true" />
        <span className="truncate">{job.location}</span>
      </p>

      {/* Salary */}
      {job.salary && (
        <p className={cn("text-xs font-semibold flex items-center gap-1", theme.salary)}>
          <DollarSign className="h-3 w-3" aria-hidden="true" />
          {job.salary}
        </p>
      )}

      {/* Description */}
      <p className="text-xs text-muted-foreground line-clamp-3 leading-relaxed">
        {job.description}
      </p>

      {/* Skill chips */}
      {job.tags && job.tags.length > 0 && (
        <div className="flex flex-wrap gap-1.5">
          {job.tags.map((tag) => (
            <span
              key={tag}
              className="px-2 py-0.5 rounded-md bg-muted/50 border border-border/40 text-[10px] font-medium text-muted-foreground"
            >
              {tag}
            </span>
          ))}
        </div>
      )}

      {/* Footer */}
      <div className="flex items-center justify-between pt-2 border-t border-border/40">
        <span className="text-[10px] text-muted-foreground flex items-center gap-1">
          <Clock className="h-3 w-3" aria-hidden="true" />
          {job.postedAt}
        </span>
        <div className="flex items-center gap-1.5">
          {job.applyUrl && (
            <a
              href={job.applyUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-1 text-muted-foreground text-[11px] font-medium px-2 py-1 rounded-lg hover:text-foreground transition-colors"
            >
              <ExternalLink className="h-3 w-3" aria-hidden="true" />
              Link
            </a>
          )}
          {hasApplied ? (
            <span className="flex items-center gap-1 text-emerald-600 dark:text-emerald-400 text-[11px] font-medium px-3 py-1">
              <CheckCircle2 className="h-3 w-3" />
              Applied
            </span>
          ) : (
            <button
              type="button"
              onClick={() => onApply(job.id)}
              disabled={currentlyApplying}
              className={cn(
                "flex items-center gap-1 text-white text-[11px] font-medium px-3 py-1 rounded-lg transition-all",
                "sm:opacity-0 sm:group-hover:opacity-100 sm:group-focus-within:opacity-100",
                "disabled:opacity-50",
                theme.button
              )}
            >
              {currentlyApplying ? (
                <Loader2 className="h-3 w-3 animate-spin" />
              ) : (
                <Briefcase className="h-3 w-3" aria-hidden="true" />
              )}
              Apply
            </button>
          )}
        </div>
      </div>
    </motion.div>
  );
}

// ============================================================================
// JobPortalHero
// ============================================================================

function JobPortalHero({
  stats,
  onUploadResume,
  resumeUrl,
  isUploading,
}: {
  stats: { activeJobs: number; topCompanies: number; hiredThisMonth: number };
  onUploadResume: () => void;
  resumeUrl: string | null;
  isUploading: boolean;
}) {
  const prefersReducedMotion = useReducedMotion();

  return (
    <motion.div
      initial="hidden"
      animate="show"
      variants={staggerContainer}
      className="relative overflow-hidden rounded-3xl mb-8 bg-gradient-to-br from-slate-900 via-indigo-950 to-blue-950"
    >
      {/* Animated Background Elements */}
      <div className="absolute inset-0 overflow-hidden" aria-hidden="true">
        <motion.div
          className="absolute -top-20 -left-20 w-96 h-96 bg-indigo-600/30 rounded-full blur-3xl"
          animate={prefersReducedMotion ? {} : { scale: [1, 1.2, 1], opacity: [0.5, 0.8, 0.5] }}
          transition={prefersReducedMotion ? {} : { duration: 3, repeat: Infinity, ease: 'easeInOut', delay: 0 }}
        />
        <motion.div
          className="absolute -bottom-20 -right-20 w-80 h-80 bg-blue-500/20 rounded-full blur-3xl"
          animate={prefersReducedMotion ? {} : { scale: [1, 1.2, 1], opacity: [0.5, 0.8, 0.5] }}
          transition={prefersReducedMotion ? {} : { duration: 3, repeat: Infinity, ease: 'easeInOut', delay: 1 }}
        />
        <motion.div
          className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-64 h-64 bg-violet-500/15 rounded-full blur-3xl"
          animate={prefersReducedMotion ? {} : { scale: [1, 1.2, 1], opacity: [0.5, 0.8, 0.5] }}
          transition={prefersReducedMotion ? {} : { duration: 3, repeat: Infinity, ease: 'easeInOut', delay: 2 }}
        />
        <div className="absolute inset-0 bg-[linear-gradient(to_right,#ffffff0d_1px,transparent_1px),linear-gradient(to_bottom,#ffffff0d_1px,transparent_1px)] bg-[size:50px_50px]" />
        {!prefersReducedMotion && (
          <>
            {HERO_SPARKLE_INDICES.map((i) => (
              <motion.div
                key={i}
                className="absolute h-1 w-1 rounded-full"
                style={{
                  left: `${15 + i * 14}%`,
                  top: `${25 + (i % 3) * 25}%`,
                  backgroundColor: i % 2 === 0 ? 'rgb(129 140 248 / 0.6)' : 'rgb(96 165 250 / 0.5)',
                }}
                animate={{ opacity: [0, 1, 0], scale: [0, 1, 0] }}
                transition={{ duration: 3, repeat: Infinity, delay: i * 0.5, ease: 'easeInOut' }}
              />
            ))}
          </>
        )}
      </div>

      {/* Content */}
      <div className="relative z-10 p-6 md:p-8 lg:p-12">
        <motion.div variants={fadeInUp} className="flex flex-wrap gap-2.5 mb-6">
          <LiveStatsBadge value={stats.activeJobs} label="Active Jobs" icon={Briefcase} color="blue" autoIncrement={false} />
          <LiveStatsBadge value={stats.topCompanies} label="Top Companies" icon={Building2} color="violet" autoIncrement={false} />
          <LiveStatsBadge value={stats.hiredThisMonth} label="Applied This Month" icon={Users} color="blue" autoIncrement={false} />
        </motion.div>

        <motion.h1
          variants={fadeInUp}
          className="text-3xl md:text-4xl lg:text-5xl font-bold text-white leading-tight mb-4"
        >
          Find Your{' '}
          <span className="bg-gradient-to-r from-indigo-400 via-blue-400 to-violet-400 bg-clip-text text-transparent">
            Dream Career
          </span>
        </motion.h1>

        <motion.p
          variants={fadeInUp}
          className="text-sm md:text-base text-slate-300/90 max-w-xl leading-relaxed mb-6"
        >
          Connect with top companies, discover opportunities, and land the role you&apos;ve been working toward.
        </motion.p>

        <motion.div variants={fadeInUp} className="flex flex-wrap gap-3 items-center">
          <button
            type="button"
            onClick={() => document.getElementById("job-search-input")?.focus()}
            className="flex items-center gap-2 px-5 py-2.5 rounded-xl bg-gradient-to-r from-indigo-600 to-blue-600 hover:from-indigo-500 hover:to-blue-500 text-white font-medium shadow-lg shadow-indigo-500/25 hover:-translate-y-0.5 transition-all text-sm"
          >
            <Briefcase className="h-4 w-4" aria-hidden="true" />
            Browse Jobs
          </button>
          <button
            type="button"
            onClick={onUploadResume}
            disabled={isUploading}
            className="flex items-center gap-2 px-5 py-2.5 rounded-xl bg-white/10 border border-white/20 hover:bg-white/15 backdrop-blur-sm text-white font-medium transition-all text-sm disabled:opacity-50"
          >
            {isUploading ? (
              <Loader2 className="h-4 w-4 animate-spin" aria-hidden="true" />
            ) : (
              <Upload className="h-4 w-4" aria-hidden="true" />
            )}
            {resumeUrl ? "Update Resume" : "Upload Resume"}
          </button>
          {resumeUrl && (
            <span className="flex items-center gap-1 text-emerald-400 text-xs">
              <CheckCircle2 className="h-3.5 w-3.5" />
              Resume uploaded
            </span>
          )}
        </motion.div>
      </div>
    </motion.div>
  );
}

// ============================================================================
// My Applications View
// ============================================================================

function MyApplicationsView({
  applications,
  loading,
  onBack,
}: {
  applications: JobApplicationEntry[];
  loading: boolean;
  onBack: () => void;
}) {
  if (loading) {
    return (
      <div className="flex items-center justify-center py-20">
        <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
      </div>
    );
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <button
          type="button"
          onClick={onBack}
          className="flex items-center gap-1 text-sm text-muted-foreground hover:text-foreground transition-colors"
        >
          <ArrowLeft className="h-4 w-4" />
          Back to Jobs
        </button>
        <h2 className="text-lg font-semibold">My Applications ({applications.length})</h2>
      </div>

      {applications.length === 0 ? (
        <div className="text-center py-16">
          <div className="relative inline-flex mb-4">
            <div className="absolute inset-0 bg-gradient-to-br from-indigo-400/20 to-blue-500/20 rounded-full blur-xl" />
            <div className="relative h-14 w-14 rounded-2xl bg-gradient-to-br from-indigo-500 to-blue-600 flex items-center justify-center shadow-lg">
              <FileText className="h-6 w-6 text-white" />
            </div>
          </div>
          <p className="text-sm font-medium text-foreground mb-1">No applications yet</p>
          <p className="text-xs text-muted-foreground">Start applying to jobs to track your applications here</p>
        </div>
      ) : (
        <div className="space-y-3">
          {applications.map((app) => {
            const statusStyle = STATUS_STYLES[app.status] || STATUS_STYLES.applied;
            return (
              <div
                key={app.id}
                className="rounded-xl border border-border/50 bg-background/80 backdrop-blur-sm p-4 space-y-2"
              >
                <div className="flex items-start justify-between gap-3">
                  <div className="min-w-0">
                    <h3 className="text-sm font-semibold truncate">{app.job?.title || "Job"}</h3>
                    <p className="text-xs text-muted-foreground flex items-center gap-1 mt-0.5">
                      <Building2 className="h-3 w-3 shrink-0" />
                      {app.job?.company || "Company"}
                      {app.job?.location && (
                        <>
                          <span className="mx-0.5">·</span>
                          <MapPin className="h-3 w-3 shrink-0" />
                          {app.job.location}
                        </>
                      )}
                    </p>
                  </div>
                  <span className={cn("px-2 py-0.5 rounded-full text-[10px] font-medium capitalize", statusStyle.bg, statusStyle.text)}>
                    {app.status}
                  </span>
                </div>
                <div className="flex items-center gap-3 text-[10px] text-muted-foreground">
                  <span className="flex items-center gap-1">
                    <Clock className="h-3 w-3" />
                    Applied {new Date(app.created_at).toLocaleDateString()}
                  </span>
                  <a
                    href={app.resumeUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-1 text-indigo-600 dark:text-indigo-400 hover:underline"
                  >
                    <FileText className="h-3 w-3" />
                    View Resume
                  </a>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

// ============================================================================
// Apply Modal
// ============================================================================

function ApplyModal({
  jobTitle,
  resumeUrl,
  onConfirm,
  onCancel,
  isSubmitting,
}: {
  jobTitle: string;
  resumeUrl: string | null;
  onConfirm: (coverLetter: string) => void;
  onCancel: () => void;
  isSubmitting: boolean;
}) {
  const [coverLetter, setCoverLetter] = useState("");

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm">
      <motion.div
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        exit={{ opacity: 0, scale: 0.95 }}
        className="w-full max-w-md rounded-2xl border border-border/50 bg-background p-6 shadow-xl space-y-4"
      >
        <h3 className="text-lg font-semibold">Apply to {jobTitle}</h3>

        {!resumeUrl ? (
          <div className="rounded-xl bg-amber-500/10 border border-amber-500/20 p-4">
            <p className="text-sm text-amber-700 dark:text-amber-400 font-medium">
              Please upload your resume first using the &quot;Upload Resume&quot; button in the hero section.
            </p>
          </div>
        ) : (
          <>
            <div className="flex items-center gap-2 text-sm text-emerald-600 dark:text-emerald-400">
              <CheckCircle2 className="h-4 w-4" />
              Resume attached
            </div>
            <div className="space-y-1.5">
              <label className="text-sm font-medium text-foreground" htmlFor="cover-letter">
                Cover Letter (optional)
              </label>
              <textarea
                id="cover-letter"
                value={coverLetter}
                onChange={(e) => setCoverLetter(e.target.value)}
                placeholder="Tell them why you're a great fit..."
                className="w-full rounded-xl border border-border/50 bg-muted/30 px-3 py-2.5 text-sm resize-none h-28 focus:outline-none focus:ring-2 focus:ring-primary/30"
              />
            </div>
          </>
        )}

        <div className="flex justify-end gap-2 pt-2">
          <button
            type="button"
            onClick={onCancel}
            className="px-4 py-2 rounded-lg text-sm font-medium text-muted-foreground hover:text-foreground transition-colors"
          >
            Cancel
          </button>
          {resumeUrl && (
            <button
              type="button"
              onClick={() => onConfirm(coverLetter)}
              disabled={isSubmitting}
              className="flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium text-white bg-gradient-to-r from-indigo-600 to-blue-600 hover:from-indigo-500 hover:to-blue-500 disabled:opacity-50 transition-all"
            >
              {isSubmitting ? (
                <Loader2 className="h-4 w-4 animate-spin" />
              ) : (
                <Briefcase className="h-4 w-4" />
              )}
              Submit Application
            </button>
          )}
        </div>
      </motion.div>
    </div>
  );
}

// ============================================================================
// Main JobPortal Component
// ============================================================================

export function JobPortal() {
  const [search, setSearch] = useState("");
  const [selectedCategory, setSelectedCategory] = useState<JobCategory | "all">("all");
  const [selectedType, setSelectedType] = useState<JobType | "all">("all");
  const [remoteOnly, setRemoteOnly] = useState(false);
  const colCount = useColumnCount();

  // Data state
  const [jobs, setJobs] = useState<JobListing[]>([]);
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState({ activeJobs: 0, topCompanies: 0, hiredThisMonth: 0 });

  // Resume state
  const [resumeUrl, setResumeUrl] = useState<string | null>(null);
  const [isUploading, setIsUploading] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Application state
  const [appliedJobIds, setAppliedJobIds] = useState<Set<string>>(new Set());
  const [applyingJobId, setApplyingJobId] = useState<string | null>(null);
  const [applyModalJob, setApplyModalJob] = useState<JobListing | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  // My Applications view
  const [showApplications, setShowApplications] = useState(false);
  const [applications, setApplications] = useState<JobApplicationEntry[]>([]);
  const [applicationsLoading, setApplicationsLoading] = useState(false);

  // Fetch jobs from API
  const fetchJobs = useCallback(async () => {
    setLoading(true);
    try {
      const params = new URLSearchParams();
      if (selectedCategory !== "all") params.set("category", selectedCategory);
      if (selectedType !== "all") params.set("type", selectedType);
      if (remoteOnly) params.set("remote", "true");
      if (search) params.set("search", search);

      const data = await apiClient<{ jobs: JobListing[]; total: number }>(
        `/api/jobs?${params.toString()}`
      );
      setJobs(data.jobs || []);
    } catch (err) {
      console.error("Failed to fetch jobs:", err);
      setJobs([]);
    } finally {
      setLoading(false);
    }
  }, [selectedCategory, selectedType, remoteOnly, search]);

  // Fetch stats
  useEffect(() => {
    apiClient<{ activeJobs: number; topCompanies: number; hiredThisMonth: number }>("/api/jobs/stats")
      .then(setStats)
      .catch(() => {});
  }, []);

  // Fetch jobs when filters change
  useEffect(() => {
    const timeout = setTimeout(fetchJobs, search ? 300 : 0);
    return () => clearTimeout(timeout);
  }, [fetchJobs]);

  // Fetch user's existing applications to know which jobs they applied to
  useEffect(() => {
    apiClient<{ applications: JobApplicationEntry[] }>("/api/jobs/my-applications")
      .then((data) => {
        const ids = new Set((data.applications || []).map((a) => a.jobId || (a.job as any)?.id));
        setAppliedJobIds(ids);
      })
      .catch(() => {});
  }, []);

  // Load saved resume URL from localStorage
  useEffect(() => {
    const saved = localStorage.getItem("job-portal-resume-url");
    if (saved) setResumeUrl(saved);
  }, []);

  // Upload resume handler
  const handleUploadResume = useCallback(() => {
    fileInputRef.current?.click();
  }, []);

  const handleFileChange = useCallback(async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setIsUploading(true);
    try {
      const formData = new FormData();
      formData.append("file", file);
      formData.append("folder", "resumes");

      const result = await apiClient<{ url: string }>("/api/upload", {
        method: "POST",
        body: formData,
        isFormData: true,
      });

      if (result.url) {
        setResumeUrl(result.url);
        localStorage.setItem("job-portal-resume-url", result.url);
      }
    } catch (err) {
      console.error("Failed to upload resume:", err);
      alert("Failed to upload resume. Please try again.");
    } finally {
      setIsUploading(false);
      if (fileInputRef.current) fileInputRef.current.value = "";
    }
  }, []);

  // Apply to job
  const handleApplyClick = useCallback((jobId: string) => {
    const job = jobs.find((j) => j.id === jobId);
    if (job) setApplyModalJob(job);
  }, [jobs]);

  const handleConfirmApply = useCallback(async (coverLetter: string) => {
    if (!applyModalJob || !resumeUrl) return;

    setIsSubmitting(true);
    try {
      await apiClient(`/api/jobs/${applyModalJob.id}/apply`, {
        method: "POST",
        body: JSON.stringify({ resumeUrl, coverLetter: coverLetter || undefined }),
      });

      setAppliedJobIds((prev) => new Set([...prev, applyModalJob.id]));
      setApplyModalJob(null);
    } catch (err: any) {
      alert(err.message || "Failed to apply. Please try again.");
    } finally {
      setIsSubmitting(false);
    }
  }, [applyModalJob, resumeUrl]);

  // Fetch my applications
  const handleShowApplications = useCallback(async () => {
    setShowApplications(true);
    setApplicationsLoading(true);
    try {
      const data = await apiClient<{ applications: JobApplicationEntry[] }>("/api/jobs/my-applications");
      setApplications(data.applications || []);
    } catch {
      setApplications([]);
    } finally {
      setApplicationsLoading(false);
    }
  }, []);

  // Client-side filtering (already server-filtered, this is for instant feedback)
  const filtered = useMemo(() => jobs, [jobs]);

  const columns = useMemo(
    () => distributeIntoColumns(filtered, colCount),
    [filtered, colCount]
  );

  // My Applications view
  if (showApplications) {
    return (
      <div className="space-y-6">
        <MyApplicationsView
          applications={applications}
          loading={applicationsLoading}
          onBack={() => setShowApplications(false)}
        />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Hidden file input for resume upload */}
      <input
        ref={fileInputRef}
        type="file"
        accept=".pdf,.doc,.docx"
        onChange={handleFileChange}
        className="hidden"
      />

      <JobPortalHero
        stats={stats}
        onUploadResume={handleUploadResume}
        resumeUrl={resumeUrl}
        isUploading={isUploading}
      />

      {/* Search Bar */}
      <div className="relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
        <input
          id="job-search-input"
          type="text"
          placeholder="Search jobs, companies..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full pl-10 pr-4 py-3 rounded-xl border border-border/50 bg-background/80 backdrop-blur-sm text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary/50 transition-all"
        />
      </div>

      {/* Filters Row */}
      <div className="flex flex-wrap items-center gap-3">
        {/* Category Chips */}
        <div className="flex items-center gap-1.5 overflow-x-auto pb-1 scrollbar-hide">
          {CATEGORIES.map((cat) => (
            <button
              type="button"
              key={cat.value}
              onClick={() => setSelectedCategory(cat.value)}
              className={cn(
                "px-3 py-1.5 rounded-full text-xs font-medium whitespace-nowrap transition-colors border",
                selectedCategory === cat.value
                  ? "bg-gradient-to-r from-indigo-600 to-blue-600 text-white border-transparent shadow-sm"
                  : "bg-muted/50 text-muted-foreground border-border/40 hover:bg-muted hover:text-foreground"
              )}
            >
              {cat.label}
            </button>
          ))}
        </div>

        <div className="h-5 w-px bg-border/40 hidden sm:block" />

        {/* Job Type Filter */}
        <select
          value={selectedType}
          onChange={(e) => setSelectedType(e.target.value as JobType | "all")}
          className="px-3 py-1.5 rounded-lg text-xs font-medium bg-muted/50 border border-border/40 text-foreground focus:outline-none focus:ring-1 focus:ring-primary/30"
        >
          {JOB_TYPES.map((t) => (
            <option key={t.value} value={t.value}>{t.label}</option>
          ))}
        </select>

        {/* Remote Toggle */}
        <button
          type="button"
          onClick={() => setRemoteOnly(!remoteOnly)}
          className={cn(
            "flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium border transition-colors",
            remoteOnly
              ? "bg-gradient-to-r from-indigo-600 to-blue-600 text-white border-transparent shadow-sm"
              : "bg-muted/50 text-muted-foreground border-border/40 hover:bg-muted"
          )}
        >
          <Wifi className="h-3 w-3" aria-hidden="true" />
          Remote
        </button>

        <div className="h-5 w-px bg-border/40 hidden sm:block" />

        {/* My Applications Button */}
        <button
          type="button"
          onClick={handleShowApplications}
          className="flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium border border-border/40 bg-muted/50 text-muted-foreground hover:bg-muted hover:text-foreground transition-colors"
        >
          <FileText className="h-3 w-3" aria-hidden="true" />
          My Applications
        </button>
      </div>

      {/* Results Count */}
      <p className="text-xs text-muted-foreground">
        {loading ? "Loading..." : `${filtered.length} job${filtered.length !== 1 ? "s" : ""} found`}
      </p>

      {/* Masonry job grid */}
      {loading ? (
        <div className="flex items-center justify-center py-20">
          <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
        </div>
      ) : filtered.length > 0 ? (
        <div className="-ml-4 flex w-auto items-start">
          {columns.map((col, colIdx) => (
            <div key={colIdx} className="pl-4 flex-1 min-w-0 flex flex-col gap-4">
              {col.map((job) => (
                <JobCard
                  key={job.id}
                  job={job}
                  onApply={handleApplyClick}
                  appliedJobIds={appliedJobIds}
                  isApplying={applyingJobId}
                />
              ))}
            </div>
          ))}
        </div>
      ) : (
        <div className="text-center py-16">
          <div className="relative inline-flex mb-4">
            <div className="absolute inset-0 bg-gradient-to-br from-indigo-400/20 to-blue-500/20 rounded-full blur-xl" />
            <div className="relative h-14 w-14 rounded-2xl bg-gradient-to-br from-indigo-500 to-blue-600 flex items-center justify-center shadow-lg">
              <Filter className="h-6 w-6 text-white" />
            </div>
          </div>
          <p className="text-sm font-medium text-foreground mb-1">No jobs match your filters</p>
          <p className="text-xs text-muted-foreground mb-3">Try adjusting your search or filters</p>
          <button
            type="button"
            onClick={() => {
              setSearch("");
              setSelectedCategory("all");
              setSelectedType("all");
              setRemoteOnly(false);
            }}
            className="text-xs text-indigo-600 dark:text-indigo-400 hover:underline font-medium"
          >
            Clear all filters
          </button>
        </div>
      )}

      {/* Apply Modal */}
      {applyModalJob && (
        <ApplyModal
          jobTitle={applyModalJob.title}
          resumeUrl={resumeUrl}
          onConfirm={handleConfirmApply}
          onCancel={() => setApplyModalJob(null)}
          isSubmitting={isSubmitting}
        />
      )}
    </div>
  );
}
