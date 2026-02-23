"use client";

import { useState, useMemo } from "react";
import { motion } from "framer-motion";
import {
  Search,
  MapPin,
  Briefcase,
  DollarSign,
  Clock,
  ExternalLink,
  Filter,
  Wifi,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
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

const TYPE_COLORS: Record<JobType, string> = {
  "full-time": "bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-400",
  "part-time": "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400",
  contract: "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400",
  internship: "bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-400",
  freelance: "bg-rose-100 text-rose-700 dark:bg-rose-900/30 dark:text-rose-400",
};

const containerVariants = {
  hidden: { opacity: 0 },
  show: {
    opacity: 1,
    transition: { staggerChildren: 0.06 },
  },
};

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  show: { opacity: 1, y: 0, transition: { duration: 0.35 } },
};

/**
 * Job Portal component
 * Search, filter, and browse job listings with category chips and type filters
 */
export function JobPortal() {
  const [search, setSearch] = useState("");
  const [selectedCategory, setSelectedCategory] = useState<JobCategory | "all">("all");
  const [selectedType, setSelectedType] = useState<JobType | "all">("all");
  const [remoteOnly, setRemoteOnly] = useState(false);

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

  return (
    <div className="space-y-6">
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
              key={cat.value}
              onClick={() => setSelectedCategory(cat.value)}
              className={cn(
                "px-3 py-1.5 rounded-full text-xs font-medium whitespace-nowrap transition-colors border",
                selectedCategory === cat.value
                  ? "bg-primary text-primary-foreground border-primary"
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
          onClick={() => setRemoteOnly(!remoteOnly)}
          className={cn(
            "flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium border transition-colors",
            remoteOnly
              ? "bg-primary text-primary-foreground border-primary"
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

      {/* Job Cards Grid */}
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="show"
        className="grid gap-4 sm:grid-cols-2"
      >
        {filtered.map((job) => (
          <motion.div
            key={job.id}
            variants={itemVariants}
            className="action-card-glass rounded-xl p-5 space-y-3 hover:shadow-lg transition-shadow"
          >
            {/* Header */}
            <div className="flex items-start justify-between gap-2">
              <div className="flex items-center gap-3 min-w-0">
                <div className="h-10 w-10 rounded-lg bg-gradient-to-br from-primary/20 to-primary/5 flex items-center justify-center shrink-0 border border-border/30">
                  <Briefcase className="h-4.5 w-4.5 text-primary" />
                </div>
                <div className="min-w-0">
                  <h3 className="text-sm font-semibold text-foreground truncate">{job.title}</h3>
                  <p className="text-xs text-muted-foreground truncate">{job.company}</p>
                </div>
              </div>
              <Badge className={cn("text-[10px] shrink-0", TYPE_COLORS[job.type])}>
                {job.type}
              </Badge>
            </div>

            {/* Description */}
            <p className="text-xs text-muted-foreground line-clamp-2">{job.description}</p>

            {/* Meta */}
            <div className="flex flex-wrap items-center gap-3 text-xs text-muted-foreground">
              <span className="flex items-center gap-1">
                <MapPin className="h-3 w-3" />
                {job.location}
              </span>
              <span className="flex items-center gap-1">
                <DollarSign className="h-3 w-3" />
                {job.salary}
              </span>
              <span className="flex items-center gap-1">
                <Clock className="h-3 w-3" />
                {job.postedAt}
              </span>
              {job.isRemote && (
                <span className="flex items-center gap-1 text-emerald-600 dark:text-emerald-400">
                  <Wifi className="h-3 w-3" />
                  Remote
                </span>
              )}
            </div>

            {/* Tags */}
            <div className="flex flex-wrap gap-1.5">
              {job.tags.map((tag) => (
                <span
                  key={tag}
                  className="px-2 py-0.5 rounded-md bg-muted/60 text-[10px] font-medium text-muted-foreground"
                >
                  {tag}
                </span>
              ))}
            </div>

            {/* Action */}
            <Button
              size="sm"
              className="w-full mt-1"
              variant="outline"
            >
              <ExternalLink className="h-3.5 w-3.5 mr-1.5" />
              Apply Now
            </Button>
          </motion.div>
        ))}
      </motion.div>

      {filtered.length === 0 && (
        <div className="text-center py-12">
          <Filter className="h-10 w-10 text-muted-foreground/40 mx-auto mb-3" />
          <p className="text-sm text-muted-foreground">No jobs match your filters</p>
          <button
            onClick={() => { setSearch(""); setSelectedCategory("all"); setSelectedType("all"); setRemoteOnly(false); }}
            className="text-xs text-primary mt-2 hover:underline"
          >
            Clear all filters
          </button>
        </div>
      )}
    </div>
  );
}
