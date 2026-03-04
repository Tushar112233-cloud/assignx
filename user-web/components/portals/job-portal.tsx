"use client";

import { useState, useMemo, useEffect } from "react";
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
} from "lucide-react";
import { LiveStatsBadge } from "@/components/campus-connect/live-stats-badge";
import { cn } from "@/lib/utils";
import type { JobListing, JobCategory, JobType } from "@/types/portals";

/**
 * Mock job listings for initial display
 */
const MOCK_JOBS: JobListing[] = [
  {
    id: "1",
    title: "Frontend Engineer",
    company: "TechFlow",
    location: "Bangalore, India",
    type: "full-time",
    category: "engineering",
    salary: "12-18 LPA",
    description: "Build modern web applications with React and Next.js",
    postedAt: "2d ago",
    isRemote: true,
    tags: ["React", "TypeScript", "Next.js"],
  },
  {
    id: "2",
    title: "Product Design Intern",
    company: "DesignLab",
    location: "Mumbai, India",
    type: "internship",
    category: "design",
    salary: "25K/mo",
    description: "Join our design team to create beautiful user experiences",
    postedAt: "1d ago",
    isRemote: false,
    tags: ["Figma", "UI/UX", "Prototyping"],
  },
  {
    id: "3",
    title: "Data Analyst",
    company: "DataPulse",
    location: "Hyderabad, India",
    type: "full-time",
    category: "data",
    salary: "8-14 LPA",
    description: "Analyze large datasets and build insightful dashboards",
    postedAt: "3d ago",
    isRemote: true,
    tags: ["Python", "SQL", "Tableau"],
  },
  {
    id: "4",
    title: "Marketing Manager",
    company: "GrowthHQ",
    location: "Delhi, India",
    type: "full-time",
    category: "marketing",
    salary: "10-16 LPA",
    description: "Lead marketing campaigns and drive brand awareness",
    postedAt: "5d ago",
    isRemote: false,
    tags: ["SEO", "Content", "Analytics"],
  },
  {
    id: "5",
    title: "Backend Developer",
    company: "CloudNine",
    location: "Pune, India",
    type: "contract",
    category: "engineering",
    salary: "15-22 LPA",
    description: "Design and implement scalable microservices architecture",
    postedAt: "1d ago",
    isRemote: true,
    tags: ["Node.js", "PostgreSQL", "AWS"],
  },
  {
    id: "6",
    title: "Sales Executive",
    company: "SalesForce India",
    location: "Chennai, India",
    type: "full-time",
    category: "sales",
    salary: "6-10 LPA + Commission",
    description: "Drive enterprise sales and build client relationships",
    postedAt: "4d ago",
    isRemote: false,
    tags: ["B2B", "CRM", "Negotiation"],
  },
  {
    id: "7",
    title: "Product Manager",
    company: "InnovateTech",
    location: "Bangalore, India",
    type: "full-time",
    category: "product",
    salary: "18-28 LPA",
    description: "Define product strategy and roadmap for SaaS platform",
    postedAt: "6h ago",
    isRemote: true,
    tags: ["Strategy", "Agile", "Analytics"],
  },
  {
    id: "8",
    title: "Finance Analyst",
    company: "FinEdge",
    location: "Mumbai, India",
    type: "part-time",
    category: "finance",
    salary: "5-8 LPA",
    description: "Financial modeling and investment analysis",
    postedAt: "2d ago",
    isRemote: false,
    tags: ["Excel", "Modeling", "Valuation"],
  },
];

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

/** Reactive column count: 3 ≥1024px, 2 ≥640px, 1 mobile */
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
  show: { opacity: 1, y: 0, transition: { duration: 0.6, ease: 'easeOut' } },
};

const HERO_SPARKLE_INDICES = [0, 1, 2, 3, 4, 5];

/**
 * JobCard — glassmorphism card for a single job listing.
 * Color-tinted per job type; masonry-safe (no fixed height).
 */
function JobCard({ job }: { job: JobListing }) {
  const prefersReducedMotion = useReducedMotion();
  const theme = JOB_TYPE_THEME[job.type];
  const companyInitial = job.company.charAt(0).toUpperCase();

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
      {/* Avatar row: avatar initial + type pill + remote badge */}
      <div className="flex items-center justify-between gap-2">
        <div
          className={cn(
            "h-10 w-10 rounded-full flex items-center justify-center shrink-0 text-white font-bold text-sm shadow-sm",
            theme.avatar
          )}
        >
          {companyInitial}
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

      {/* Company · Location */}
      <p className="text-xs text-muted-foreground flex items-center gap-1">
        <Building2 className="h-3 w-3 shrink-0" aria-hidden="true" />
        <span className="truncate">{job.company}</span>
        <span className="mx-0.5">·</span>
        <MapPin className="h-3 w-3 shrink-0" aria-hidden="true" />
        <span className="truncate">{job.location}</span>
      </p>

      {/* Salary */}
      <p className={cn("text-xs font-semibold flex items-center gap-1", theme.salary)}>
        <DollarSign className="h-3 w-3" aria-hidden="true" />
        {job.salary}
      </p>

      {/* Description */}
      <p className="text-xs text-muted-foreground line-clamp-3 leading-relaxed">
        {job.description}
      </p>

      {/* Skill chips */}
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

      {/* Footer: posted time + apply button */}
      <div className="flex items-center justify-between pt-2 border-t border-border/40">
        <span className="text-[10px] text-muted-foreground flex items-center gap-1">
          <Clock className="h-3 w-3" aria-hidden="true" />
          {job.postedAt}
        </span>
        <button
          type="button"
          className={cn(
            "flex items-center gap-1 text-white text-[11px] font-medium px-3 py-1 rounded-lg transition-all",
            "sm:opacity-0 sm:group-hover:opacity-100 sm:group-focus-within:opacity-100",
            theme.button
          )}
        >
          <ExternalLink className="h-3 w-3" aria-hidden="true" />
          Apply
        </button>
      </div>
    </motion.div>
  );
}

/**
 * JobPortalHero - Premium hero banner for the Professional jobs tab
 * Displays animated stats, headline, and CTA buttons
 */
function JobPortalHero() {
  const prefersReducedMotion = useReducedMotion()

  return (
    <motion.div
      initial="hidden"
      animate="show"
      variants={staggerContainer}
      className="relative overflow-hidden rounded-3xl mb-8 bg-gradient-to-br from-slate-900 via-indigo-950 to-blue-950"
    >
      {/* Animated Background Elements */}
      <div className="absolute inset-0 overflow-hidden" aria-hidden="true">
        {/* Orb 1 */}
        <motion.div
          className="absolute -top-20 -left-20 w-96 h-96 bg-indigo-600/30 rounded-full blur-3xl"
          animate={prefersReducedMotion ? {} : {
            scale: [1, 1.2, 1],
            opacity: [0.5, 0.8, 0.5],
          }}
          transition={prefersReducedMotion ? {} : { duration: 3, repeat: Infinity, ease: 'easeInOut', delay: 0 }}
        />
        {/* Orb 2 */}
        <motion.div
          className="absolute -bottom-20 -right-20 w-80 h-80 bg-blue-500/20 rounded-full blur-3xl"
          animate={prefersReducedMotion ? {} : {
            scale: [1, 1.2, 1],
            opacity: [0.5, 0.8, 0.5],
          }}
          transition={prefersReducedMotion ? {} : { duration: 3, repeat: Infinity, ease: 'easeInOut', delay: 1 }}
        />
        {/* Orb 3 */}
        <motion.div
          className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-64 h-64 bg-violet-500/15 rounded-full blur-3xl"
          animate={prefersReducedMotion ? {} : {
            scale: [1, 1.2, 1],
            opacity: [0.5, 0.8, 0.5],
          }}
          transition={prefersReducedMotion ? {} : { duration: 3, repeat: Infinity, ease: 'easeInOut', delay: 2 }}
        />

        {/* Grid overlay */}
        <div className="absolute inset-0 bg-[linear-gradient(to_right,#ffffff0d_1px,transparent_1px),linear-gradient(to_bottom,#ffffff0d_1px,transparent_1px)] bg-[size:50px_50px]" />

        {/* Sparkle particles */}
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
                animate={{
                  opacity: [0, 1, 0],
                  scale: [0, 1, 0],
                }}
                transition={{
                  duration: 3,
                  repeat: Infinity,
                  delay: i * 0.5,
                  ease: 'easeInOut',
                }}
              />
            ))}
          </>
        )}
      </div>

      {/* Content */}
      <div className="relative z-10 p-6 md:p-8 lg:p-12">
        {/* Stats row */}
        <motion.div variants={fadeInUp} className="flex flex-wrap gap-2.5 mb-6">
          <LiveStatsBadge value={2847} label="Active Jobs" icon={Briefcase} color="blue" />
          <LiveStatsBadge value={340} label="Top Companies" icon={Building2} color="violet" />
          <LiveStatsBadge value={156} label="Hired This Month" icon={Users} color="blue" autoIncrement={false} />
        </motion.div>

        {/* Headline */}
        <motion.h1
          variants={fadeInUp}
          className="text-3xl md:text-4xl lg:text-5xl font-bold text-white leading-tight mb-4"
        >
          Find Your{' '}
          <span className="bg-gradient-to-r from-indigo-400 via-blue-400 to-violet-400 bg-clip-text text-transparent">
            Dream Career
          </span>
        </motion.h1>

        {/* Subheading */}
        <motion.p
          variants={fadeInUp}
          className="text-sm md:text-base text-slate-300/90 max-w-xl leading-relaxed mb-6"
        >
          Connect with top companies, discover opportunities, and land the role you&apos;ve been working toward.
        </motion.p>

        {/* CTA Buttons */}
        <motion.div variants={fadeInUp} className="flex flex-wrap gap-3">
          <button type="button" className="flex items-center gap-2 px-5 py-2.5 rounded-xl bg-gradient-to-r from-indigo-600 to-blue-600 hover:from-indigo-500 hover:to-blue-500 text-white font-medium shadow-lg shadow-indigo-500/25 hover:-translate-y-0.5 transition-all text-sm">
            <Briefcase className="h-4 w-4" />
            Browse Jobs
          </button>
          <button type="button" className="flex items-center gap-2 px-5 py-2.5 rounded-xl bg-white/10 border border-white/20 hover:bg-white/15 backdrop-blur-sm text-white font-medium transition-all text-sm">
            <Upload className="h-4 w-4" />
            Upload Resume
          </button>
        </motion.div>
      </div>
    </motion.div>
  )
}

/**
 * Job Portal component
 * Search, filter, and browse job listings with category chips and type filters
 */
export function JobPortal() {
  const [search, setSearch] = useState("");
  const [selectedCategory, setSelectedCategory] = useState<JobCategory | "all">("all");
  const [selectedType, setSelectedType] = useState<JobType | "all">("all");
  const [remoteOnly, setRemoteOnly] = useState(false);
  const colCount = useColumnCount();

  const filtered = useMemo(() => {
    return MOCK_JOBS.filter((job) => {
      if (search && !job.title.toLowerCase().includes(search.toLowerCase()) && !job.company.toLowerCase().includes(search.toLowerCase())) {
        return false;
      }
      if (selectedCategory !== "all" && job.category !== selectedCategory) return false;
      if (selectedType !== "all" && job.type !== selectedType) return false;
      if (remoteOnly && !job.isRemote) return false;
      return true;
    });
  }, [search, selectedCategory, selectedType, remoteOnly]);

  const columns = useMemo(
    () => distributeIntoColumns(filtered, colCount),
    [filtered, colCount]
  );

  return (
    <div className="space-y-6">
      <JobPortalHero />
      {/* Search Bar */}
      <div className="relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
        <input
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
          <Wifi className="h-3 w-3" />
          Remote
        </button>
      </div>

      {/* Results Count */}
      <p className="text-xs text-muted-foreground">
        {filtered.length} job{filtered.length !== 1 ? "s" : ""} found
      </p>

      {/* Masonry job grid */}
      {filtered.length > 0 ? (
        <div className="-ml-4 flex w-auto items-start">
          {columns.map((col, colIdx) => (
            <div key={colIdx} className="pl-4 flex-1 min-w-0 flex flex-col gap-4">
              {col.map((job) => (
                <JobCard key={job.id} job={job} />
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
    </div>
  );
}
