"use client";

import { useState, useMemo } from "react";
import { motion, useReducedMotion } from "framer-motion";
import {
  Search,
  Building2,
  TrendingUp,
  Upload,
  FileText,
  CheckCircle,
  Clock,
  Star,
  ArrowUpRight,
  Rocket,
  DollarSign,
} from "lucide-react";
import { LiveStatsBadge } from "@/components/campus-connect/live-stats-badge";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";
import type { InvestorCard, FundingStage, PitchDeck } from "@/types/portals";

/**
 * Mock investor data
 */
const MOCK_INVESTORS: InvestorCard[] = [
  {
    id: "1",
    name: "Priya Sharma",
    firm: "Nexus Venture Partners",
    fundingStages: ["seed", "series-a"],
    sectors: ["Tech", "SaaS", "EdTech"],
    ticketSize: "$500K - $5M",
    portfolio: 45,
    bio: "Early-stage investor focused on India's tech ecosystem. Backed 3 unicorns.",
  },
  {
    id: "2",
    name: "Rahul Mehta",
    firm: "Sequoia Capital India",
    fundingStages: ["series-a", "series-b"],
    sectors: ["Fintech", "Healthcare", "AI/ML"],
    ticketSize: "$2M - $20M",
    portfolio: 80,
    bio: "Investing in transformative startups building for the next billion users.",
  },
  {
    id: "3",
    name: "Ananya Gupta",
    firm: "Blume Ventures",
    fundingStages: ["pre-seed", "seed"],
    sectors: ["D2C", "Gaming", "Web3"],
    ticketSize: "$100K - $2M",
    portfolio: 120,
    bio: "Micro-VC investing in bold founders. Love consumer and creator economy.",
  },
  {
    id: "4",
    name: "Vikram Reddy",
    firm: "Accel India",
    fundingStages: ["seed", "series-a", "series-b"],
    sectors: ["Enterprise", "Cloud", "DevTools"],
    ticketSize: "$1M - $15M",
    portfolio: 60,
    bio: "Focused on India-born global SaaS companies. Partner at Accel since 2018.",
  },
  {
    id: "5",
    name: "Meera Jain",
    firm: "Titan Capital",
    fundingStages: ["pre-seed", "seed"],
    sectors: ["EdTech", "HealthTech", "Sustainability"],
    ticketSize: "$50K - $1M",
    portfolio: 200,
    bio: "Angel investor and ecosystem builder. Strong focus on impact-driven startups.",
  },
  {
    id: "6",
    name: "Arjun Das",
    firm: "Peak XV Partners",
    fundingStages: ["series-b", "series-c", "growth"],
    sectors: ["Fintech", "Logistics", "Commerce"],
    ticketSize: "$10M - $100M",
    portfolio: 35,
    bio: "Growth-stage investor. Helping companies scale from Series B to IPO.",
  },
];

const MOCK_DECKS: PitchDeck[] = [
  { id: "1", name: "AssignX Series A Deck.pdf", uploadedAt: "2 days ago", status: "reviewed" },
  { id: "2", name: "Q1 2026 Update.pdf", uploadedAt: "1 week ago", status: "shortlisted" },
];

const FUNDING_STAGES: { value: FundingStage | "all"; label: string }[] = [
  { value: "all", label: "All Stages" },
  { value: "pre-seed", label: "Pre-seed" },
  { value: "seed", label: "Seed" },
  { value: "series-a", label: "Series A" },
  { value: "series-b", label: "Series B" },
  { value: "series-c", label: "Series C" },
  { value: "growth", label: "Growth" },
];

const SECTORS = [
  "All",
  "Tech",
  "Fintech",
  "Healthcare",
  "EdTech",
  "SaaS",
  "D2C",
  "AI/ML",
  "Web3",
  "Enterprise",
  "Sustainability",
];

const STAGE_COLORS: Record<FundingStage, string> = {
  "pre-seed": "bg-violet-100 text-violet-700 dark:bg-violet-900/30 dark:text-violet-400",
  seed: "bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-400",
  "series-a": "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400",
  "series-b": "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400",
  "series-c": "bg-rose-100 text-rose-700 dark:bg-rose-900/30 dark:text-rose-400",
  growth: "bg-cyan-100 text-cyan-700 dark:bg-cyan-900/30 dark:text-cyan-400",
};

const DECK_STATUS_STYLES: Record<PitchDeck["status"], { color: string; icon: React.ElementType }> = {
  pending: { color: "text-amber-600 dark:text-amber-400", icon: Clock },
  reviewed: { color: "text-blue-600 dark:text-blue-400", icon: CheckCircle },
  shortlisted: { color: "text-emerald-600 dark:text-emerald-400", icon: Star },
};

const BUSINESS_SPARKLE_INDICES = [0, 1, 2, 3, 4, 5];

const heroStaggerContainer = {
  hidden: {},
  show: { transition: { staggerChildren: 0.15 } },
};

const heroFadeInUp = {
  hidden: { opacity: 0, y: 30 },
  show: { opacity: 1, y: 0, transition: { duration: 0.6, ease: "easeOut" } },
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
 * BusinessPortalHero - Premium hero section for the Business tab
 * Displays animated background orbs, live stats badges, headline, and CTA buttons
 */
function BusinessPortalHero() {
  const prefersReducedMotion = useReducedMotion();

  return (
    <motion.div
      initial="hidden"
      animate="show"
      variants={heroStaggerContainer}
      className="relative overflow-hidden rounded-3xl mb-8 bg-gradient-to-br from-slate-900 via-orange-950 to-amber-950"
    >
      {/* Animated Background Elements */}
      <div className="absolute inset-0 overflow-hidden" aria-hidden="true">
        {/* Orb 1 - top-left */}
        <motion.div
          className="absolute -top-20 -left-20 w-96 h-96 bg-orange-600/30 rounded-full blur-3xl"
          animate={prefersReducedMotion ? {} : { scale: [1, 1.2, 1], opacity: [0.5, 0.8, 0.5] }}
          transition={prefersReducedMotion ? {} : { duration: 3, repeat: Infinity, ease: "easeInOut", delay: 0 }}
        />
        {/* Orb 2 - bottom-right */}
        <motion.div
          className="absolute -bottom-20 -right-20 w-80 h-80 bg-amber-500/20 rounded-full blur-3xl"
          animate={prefersReducedMotion ? {} : { scale: [1, 1.2, 1], opacity: [0.5, 0.8, 0.5] }}
          transition={prefersReducedMotion ? {} : { duration: 3, repeat: Infinity, ease: "easeInOut", delay: 1 }}
        />
        {/* Orb 3 - center */}
        <motion.div
          className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-64 h-64 bg-red-500/15 rounded-full blur-3xl"
          animate={prefersReducedMotion ? {} : { scale: [1, 1.2, 1], opacity: [0.5, 0.8, 0.5] }}
          transition={prefersReducedMotion ? {} : { duration: 3, repeat: Infinity, ease: "easeInOut", delay: 2 }}
        />

        {/* Grid overlay */}
        <div className="absolute inset-0 bg-[linear-gradient(to_right,#ffffff0d_1px,transparent_1px),linear-gradient(to_bottom,#ffffff0d_1px,transparent_1px)] bg-[size:50px_50px]" />

        {/* Sparkle particles */}
        {!prefersReducedMotion && (
          <>
            {BUSINESS_SPARKLE_INDICES.map((i) => (
              <motion.div
                key={i}
                className="absolute h-1 w-1 rounded-full"
                style={{
                  left: `${15 + i * 14}%`,
                  top: `${25 + (i % 3) * 25}%`,
                  backgroundColor:
                    i % 2 === 0
                      ? "rgb(251 146 60 / 0.6)"
                      : "rgb(245 158 11 / 0.5)",
                }}
                animate={{
                  opacity: [0, 1, 0],
                  scale: [0, 1, 0],
                }}
                transition={{
                  duration: 3,
                  repeat: Infinity,
                  delay: i * 0.5,
                  ease: "easeInOut",
                }}
              />
            ))}
          </>
        )}
      </div>

      {/* Content */}
      <div className="relative z-10 p-6 md:p-8 lg:p-12">
        {/* Stats row */}
        <motion.div variants={heroFadeInUp} className="flex flex-wrap gap-2.5 mb-6">
          <LiveStatsBadge value={1240} label="Active Investors" icon={TrendingUp} color="amber" />
          <LiveStatsBadge value={89} label="Funded Startups" icon={Building2} color="blue" autoIncrement={false} />
          <LiveStatsBadge value={4.2} label="Avg Funding ($M)" icon={DollarSign} color="emerald" autoIncrement={false} />
        </motion.div>

        {/* Headline */}
        <motion.h1
          variants={heroFadeInUp}
          className="text-3xl md:text-4xl lg:text-5xl font-bold text-white leading-tight mb-4"
        >
          Connect With{" "}
          <span className="bg-gradient-to-r from-orange-400 via-amber-400 to-yellow-400 bg-clip-text text-transparent">
            Top Investors
          </span>
        </motion.h1>

        {/* Subheading */}
        <motion.p
          variants={heroFadeInUp}
          className="text-sm md:text-base text-slate-300/90 max-w-xl leading-relaxed mb-6"
        >
          Pitch your idea, meet the right investors, and turn your vision into a funded reality.
        </motion.p>

        {/* CTA Buttons */}
        <motion.div variants={heroFadeInUp} className="flex flex-wrap gap-3">
          <button
            type="button"
            className="flex items-center gap-2 px-5 py-2.5 rounded-xl bg-gradient-to-r from-orange-600 to-amber-600 hover:from-orange-500 hover:to-amber-500 text-white font-medium shadow-lg shadow-orange-500/25 hover:-translate-y-0.5 transition-all text-sm"
          >
            <Rocket className="h-4 w-4" />
            Pitch Your Idea
          </button>
          <button
            type="button"
            className="flex items-center gap-2 px-5 py-2.5 rounded-xl bg-white/10 border border-white/20 hover:bg-white/15 backdrop-blur-sm text-white font-medium transition-all text-sm"
          >
            <Search className="h-4 w-4" />
            Find Investors
          </button>
        </motion.div>
      </div>
    </motion.div>
  );
}

/**
 * Business Portal component
 * Investor/VC discovery, pitch deck management, and funding stage filtering
 */
export function BusinessPortal() {
  const [search, setSearch] = useState("");
  const [selectedStage, setSelectedStage] = useState<FundingStage | "all">("all");
  const [selectedSector, setSelectedSector] = useState("All");

  const filtered = useMemo(() => {
    return MOCK_INVESTORS.filter((inv) => {
      if (search && !inv.name.toLowerCase().includes(search.toLowerCase()) && !inv.firm.toLowerCase().includes(search.toLowerCase())) {
        return false;
      }
      if (selectedStage !== "all" && !inv.fundingStages.includes(selectedStage)) return false;
      if (selectedSector !== "All" && !inv.sectors.includes(selectedSector)) return false;
      return true;
    });
  }, [search, selectedStage, selectedSector]);

  return (
    <div className="space-y-6">
      <BusinessPortalHero />

      {/* Search Bar */}
      <div className="relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
        <input
          type="text"
          placeholder="Search investors, firms..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full pl-10 pr-4 py-3 rounded-xl border border-border/50 bg-background/80 backdrop-blur-sm text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary/50 transition-all"
        />
      </div>

      {/* Filters */}
      <div className="flex flex-wrap items-center gap-3">
        {/* Funding Stage Chips */}
        <div className="flex items-center gap-1.5 overflow-x-auto pb-1 scrollbar-hide">
          {FUNDING_STAGES.map((stage) => (
            <button
              key={stage.value}
              onClick={() => setSelectedStage(stage.value)}
              className={cn(
                "px-3 py-1.5 rounded-full text-xs font-medium whitespace-nowrap transition-colors border",
                selectedStage === stage.value
                  ? "bg-primary text-primary-foreground border-primary"
                  : "bg-muted/50 text-muted-foreground border-border/40 hover:bg-muted hover:text-foreground"
              )}
            >
              {stage.label}
            </button>
          ))}
        </div>

        <div className="h-5 w-px bg-border/40 hidden sm:block" />

        {/* Sector Filter */}
        <select
          value={selectedSector}
          onChange={(e) => setSelectedSector(e.target.value)}
          className="px-3 py-1.5 rounded-lg text-xs font-medium bg-muted/50 border border-border/40 text-foreground focus:outline-none focus:ring-1 focus:ring-primary/30"
        >
          {SECTORS.map((s) => (
            <option key={s} value={s}>{s}</option>
          ))}
        </select>
      </div>

      {/* Investors Grid */}
      <div>
        <h2 className="text-sm font-semibold text-foreground mb-3 flex items-center gap-2">
          <TrendingUp className="h-4 w-4 text-primary" />
          Investors & VCs
          <span className="text-xs text-muted-foreground font-normal">({filtered.length})</span>
        </h2>

        <motion.div
          variants={containerVariants}
          initial="hidden"
          animate="show"
          className="grid gap-4 sm:grid-cols-2"
        >
          {filtered.map((inv) => (
            <motion.div
              key={inv.id}
              variants={itemVariants}
              className="action-card-glass rounded-xl p-5 space-y-3 hover:shadow-lg transition-shadow"
            >
              {/* Header */}
              <div className="flex items-start gap-3">
                <div className="h-11 w-11 rounded-full bg-gradient-to-br from-primary/20 to-primary/5 flex items-center justify-center shrink-0 border border-border/30">
                  <Building2 className="h-5 w-5 text-primary" />
                </div>
                <div className="min-w-0 flex-1">
                  <h3 className="text-sm font-semibold text-foreground">{inv.name}</h3>
                  <p className="text-xs text-muted-foreground">{inv.firm}</p>
                </div>
                <span className="text-xs text-muted-foreground shrink-0">{inv.portfolio} deals</span>
              </div>

              {/* Bio */}
              <p className="text-xs text-muted-foreground line-clamp-2">{inv.bio}</p>

              {/* Stages */}
              <div className="flex flex-wrap gap-1.5">
                {inv.fundingStages.map((stage) => (
                  <Badge key={stage} className={cn("text-[10px]", STAGE_COLORS[stage])}>
                    {stage}
                  </Badge>
                ))}
              </div>

              {/* Sectors + Ticket */}
              <div className="flex items-center justify-between text-xs text-muted-foreground">
                <span className="truncate">{inv.sectors.join(", ")}</span>
                <span className="shrink-0 font-medium">{inv.ticketSize}</span>
              </div>

              {/* Action */}
              <Button size="sm" className="w-full mt-1" variant="outline">
                <ArrowUpRight className="h-3.5 w-3.5 mr-1.5" />
                Connect
              </Button>
            </motion.div>
          ))}
        </motion.div>

        {filtered.length === 0 && (
          <div className="text-center py-12">
            <Building2 className="h-10 w-10 text-muted-foreground/40 mx-auto mb-3" />
            <p className="text-sm text-muted-foreground">No investors match your filters</p>
            <button
              onClick={() => { setSearch(""); setSelectedStage("all"); setSelectedSector("All"); }}
              className="text-xs text-primary mt-2 hover:underline"
            >
              Clear all filters
            </button>
          </div>
        )}
      </div>

      {/* Pitch Deck Section */}
      <div className="space-y-3">
        <h2 className="text-sm font-semibold text-foreground flex items-center gap-2">
          <FileText className="h-4 w-4 text-primary" />
          Pitch Decks
        </h2>

        {/* Upload Zone */}
        <button className="w-full border-2 border-dashed border-border/50 rounded-xl p-6 flex flex-col items-center gap-2 hover:border-primary/40 hover:bg-primary/5 transition-colors group">
          <Upload className="h-6 w-6 text-muted-foreground group-hover:text-primary transition-colors" />
          <span className="text-xs text-muted-foreground group-hover:text-foreground transition-colors">
            Drop your pitch deck here or click to upload
          </span>
          <span className="text-[10px] text-muted-foreground/60">PDF, PPTX up to 25MB</span>
        </button>

        {/* Deck List */}
        <div className="space-y-2">
          {MOCK_DECKS.map((deck) => {
            const StatusConfig = DECK_STATUS_STYLES[deck.status];
            return (
              <div
                key={deck.id}
                className="flex items-center justify-between p-3 rounded-lg bg-muted/30 border border-border/30"
              >
                <div className="flex items-center gap-3 min-w-0">
                  <FileText className="h-4 w-4 text-muted-foreground shrink-0" />
                  <div className="min-w-0">
                    <p className="text-sm font-medium text-foreground truncate">{deck.name}</p>
                    <p className="text-[10px] text-muted-foreground">{deck.uploadedAt}</p>
                  </div>
                </div>
                <div className={cn("flex items-center gap-1 text-xs font-medium", StatusConfig.color)}>
                  <StatusConfig.icon className="h-3.5 w-3.5" />
                  <span className="capitalize">{deck.status}</span>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
