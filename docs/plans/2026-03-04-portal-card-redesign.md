# Portal Card Redesign — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task.

**Goal:** Replace the plain uniform 2-column grids in JobPortal and BusinessPortal with category-tinted glassmorphism cards in a masonry layout, matching the visual richness of the student Campus Connect portal.

**Architecture:** Each portal file gets: (1) a `JOB_TYPE_THEME` / `STAGE_THEME` color record keyed to card type, (2) `distributeIntoColumns` + `useColumnCount` masonry helpers defined inline, (3) a dedicated `JobCard` / `InvestorTile` sub-component, (4) the filter chip active state upgraded to a portal-themed gradient, and (5) an upgraded empty state with gradient icon. Business portal also gets an upgraded pitch deck upload section. No new files, no new dependencies.

**Tech Stack:** Next.js 14, Framer Motion, Tailwind CSS, lucide-react. All existing imports/types preserved.

---

## Reference files (read before implementing)

| File | Purpose |
|---|---|
| `user-web/components/portals/job-portal.tsx` | Modify — Task 1 |
| `user-web/components/portals/business-portal.tsx` | Modify — Task 2 |
| `user-web/components/campus-connect/masonry-grid.tsx` | Reference for `-ml-4 flex w-auto` masonry column pattern |

---

## Task 1: JobPortal Card Redesign

**File:** `user-web/components/portals/job-portal.tsx`

### Step 1: Add `useEffect` to the React import

Find line 3:
```typescript
import { useState, useMemo } from "react";
```
Change to:
```typescript
import { useState, useMemo, useEffect } from "react";
```

### Step 2: Add `JOB_TYPE_THEME` color record after the `TYPE_COLORS` constant

Insert after line `const TYPE_COLORS: Record<JobType, string> = { ... };` (around line 156–162):

```typescript
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
```

### Step 3: Remove `containerVariants` and `itemVariants` — add masonry helpers in their place

Delete these two constants (they will no longer be used after the grid is replaced):
```typescript
const containerVariants = { ... };
const itemVariants = { ... };
```

Insert in their place (keep `staggerContainer`, `fadeInUp`, `HERO_SPARKLE_INDICES` untouched):

```typescript
/** Distributes items round-robin across N columns for masonry layout */
function distributeIntoColumns<T>(items: T[], colCount: number): T[][] {
  const columns: T[][] = Array.from({ length: colCount }, () => []);
  items.forEach((item, i) => columns[i % colCount].push(item));
  return columns;
}

/** Reactive column count: 3 ≥1024px, 2 ≥640px, 1 mobile */
function useColumnCount(): number {
  const [cols, setCols] = useState(2);
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
  return cols;
}
```

### Step 4: Add `JobCard` component above `JobPortalHero`

Insert this full component above the `function JobPortalHero()` definition:

```tsx
/**
 * JobCard — glassmorphism card for a single job listing.
 * Color-tinted per job type; masonry-safe (no fixed height).
 */
function JobCard({ job }: { job: JobListing }) {
  const theme = JOB_TYPE_THEME[job.type];
  const companyInitial = job.company.charAt(0).toUpperCase();

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.35 }}
      className={cn(
        "group rounded-2xl border bg-gradient-to-br to-transparent",
        "shadow-sm hover:shadow-md hover:-translate-y-1 transition-all duration-300 p-5 space-y-3",
        theme.cardGradient,
        theme.border,
        theme.hoverShadow
      )}
    >
      {/* Company avatar + type badge */}
      <div className="flex items-start justify-between gap-2">
        <div className="flex items-center gap-3 min-w-0">
          <div
            className={cn(
              "h-10 w-10 rounded-xl flex items-center justify-center shrink-0 text-white font-bold text-sm shadow-sm",
              theme.avatar
            )}
          >
            {companyInitial}
          </div>
          <div className="min-w-0">
            <p className="text-xs font-semibold text-foreground truncate">{job.company}</p>
            <p className="text-xs text-muted-foreground flex items-center gap-1 mt-0.5">
              <MapPin className="h-3 w-3 shrink-0" />
              <span className="truncate">{job.location}</span>
            </p>
          </div>
        </div>
        <div className="flex items-center gap-1 shrink-0">
          {job.isRemote && (
            <span className="flex items-center gap-0.5 px-2 py-0.5 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-[10px] font-medium text-emerald-600 dark:text-emerald-400">
              <Wifi className="h-2.5 w-2.5" />
              Remote
            </span>
          )}
          <span
            className={cn(
              "px-2 py-0.5 rounded-full text-[10px] font-medium capitalize border border-current/10",
              theme.badgeBg,
              theme.badgeText
            )}
          >
            {job.type}
          </span>
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

      {/* Salary */}
      <p className={cn("text-xs font-semibold flex items-center gap-1", theme.salary)}>
        <DollarSign className="h-3 w-3" />
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
          <Clock className="h-3 w-3" />
          {job.postedAt}
        </span>
        <button
          type="button"
          className={cn(
            "flex items-center gap-1 text-white text-[11px] font-medium px-3 py-1 rounded-lg transition-all",
            "sm:opacity-0 sm:group-hover:opacity-100",
            theme.button
          )}
        >
          <ExternalLink className="h-3 w-3" />
          Apply
        </button>
      </div>
    </motion.div>
  );
}
```

### Step 5: Call `useColumnCount()` inside `JobPortal`

In the `JobPortal` function body, add one line after the existing state declarations:

```typescript
export function JobPortal() {
  const [search, setSearch] = useState("");
  const [selectedCategory, setSelectedCategory] = useState<JobCategory | "all">("all");
  const [selectedType, setSelectedType] = useState<JobType | "all">("all");
  const [remoteOnly, setRemoteOnly] = useState(false);
  const colCount = useColumnCount(); // ← add this line
  ...
```

### Step 6: Replace the category filter chip active class

Find the active class for category chips (inside the `CATEGORIES.map(...)` render):

```typescript
selectedCategory === cat.value
  ? "bg-primary text-primary-foreground border-primary"
  : "bg-muted/50 ..."
```

Replace the active branch with:
```typescript
selectedCategory === cat.value
  ? "bg-gradient-to-r from-indigo-600 to-blue-600 text-white border-transparent shadow-sm"
  : "bg-muted/50 text-muted-foreground border-border/40 hover:bg-muted hover:text-foreground"
```

Also update the Remote toggle button active class:
```typescript
// Old:
remoteOnly
  ? "bg-primary text-primary-foreground border-primary"
  : "..."
// New:
remoteOnly
  ? "bg-gradient-to-r from-indigo-600 to-blue-600 text-white border-transparent shadow-sm"
  : "bg-muted/50 text-muted-foreground border-border/40 hover:bg-muted"
```

### Step 7: Replace the job cards grid and empty state

Find and delete the entire `{/* Job Cards Grid */}` `motion.div` block and the following `{filtered.length === 0 && ...}` empty state block.

Replace with:

```tsx
{/* Masonry job grid */}
{filtered.length > 0 ? (
  <div className="-ml-4 flex w-auto items-start">
    {distributeIntoColumns(filtered, colCount).map((col, colIdx) => (
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
```

### Step 8: Lint and commit

```bash
cd "/Volumes/Crucial X9/AssignX/user-web"
npx eslint components/portals/job-portal.tsx --max-warnings=0
```

Expected: no output (clean).

```bash
cd "/Volumes/Crucial X9/AssignX"
git add user-web/components/portals/job-portal.tsx
git commit -m "feat: redesign JobPortal cards — masonry grid + glassmorphism type-tinted cards"
```

---

## Task 2: BusinessPortal Card Redesign + Pitch Deck Upgrade

**File:** `user-web/components/portals/business-portal.tsx`

### Step 1: Add `useEffect` to the React import

```typescript
// Old:
import { useState, useMemo } from "react";
// New:
import { useState, useMemo, useEffect } from "react";
```

### Step 2: Add `STAGE_THEME` color record after the existing `STAGE_COLORS` constant

Insert after `const STAGE_COLORS: Record<FundingStage, string> = { ... };` (around line 119–126):

```typescript
/** Per-stage color theme for glassmorphism investor cards */
const STAGE_THEME: Record<
  FundingStage,
  {
    cardGradient: string;
    border: string;
    hoverShadow: string;
    avatar: string;
    button: string;
    ticket: string;
  }
> = {
  "pre-seed": {
    cardGradient: "from-violet-500/10",
    border: "border-violet-500/20",
    hoverShadow: "hover:shadow-violet-500/10",
    avatar: "bg-gradient-to-br from-violet-500 to-purple-600",
    button: "bg-gradient-to-r from-violet-600 to-purple-600 hover:from-violet-500 hover:to-purple-500",
    ticket: "text-violet-600 dark:text-violet-400",
  },
  seed: {
    cardGradient: "from-emerald-500/10",
    border: "border-emerald-500/20",
    hoverShadow: "hover:shadow-emerald-500/10",
    avatar: "bg-gradient-to-br from-emerald-500 to-teal-600",
    button: "bg-gradient-to-r from-emerald-600 to-teal-600 hover:from-emerald-500 hover:to-teal-500",
    ticket: "text-emerald-600 dark:text-emerald-400",
  },
  "series-a": {
    cardGradient: "from-blue-500/10",
    border: "border-blue-500/20",
    hoverShadow: "hover:shadow-blue-500/10",
    avatar: "bg-gradient-to-br from-blue-500 to-indigo-600",
    button: "bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-500 hover:to-indigo-500",
    ticket: "text-blue-600 dark:text-blue-400",
  },
  "series-b": {
    cardGradient: "from-amber-500/10",
    border: "border-amber-500/20",
    hoverShadow: "hover:shadow-amber-500/10",
    avatar: "bg-gradient-to-br from-amber-500 to-orange-600",
    button: "bg-gradient-to-r from-amber-600 to-orange-600 hover:from-amber-500 hover:to-orange-500",
    ticket: "text-amber-600 dark:text-amber-400",
  },
  "series-c": {
    cardGradient: "from-rose-500/10",
    border: "border-rose-500/20",
    hoverShadow: "hover:shadow-rose-500/10",
    avatar: "bg-gradient-to-br from-rose-500 to-red-600",
    button: "bg-gradient-to-r from-rose-600 to-red-600 hover:from-rose-500 hover:to-red-500",
    ticket: "text-rose-600 dark:text-rose-400",
  },
  growth: {
    cardGradient: "from-cyan-500/10",
    border: "border-cyan-500/20",
    hoverShadow: "hover:shadow-cyan-500/10",
    avatar: "bg-gradient-to-br from-cyan-500 to-blue-600",
    button: "bg-gradient-to-r from-cyan-600 to-blue-600 hover:from-cyan-500 hover:to-blue-500",
    ticket: "text-cyan-600 dark:text-cyan-400",
  },
};
```

### Step 3: Remove `containerVariants` and `itemVariants` — add masonry helpers in their place

Delete these two constants (no longer used after grid replacement):
```typescript
const containerVariants = { ... };
const itemVariants = { ... };
```

Insert in their place:

```typescript
/** Distributes items round-robin across N columns for masonry layout */
function distributeIntoColumns<T>(items: T[], colCount: number): T[][] {
  const columns: T[][] = Array.from({ length: colCount }, () => []);
  items.forEach((item, i) => columns[i % colCount].push(item));
  return columns;
}

/** Reactive column count: 3 ≥1024px, 2 ≥640px, 1 mobile */
function useColumnCount(): number {
  const [cols, setCols] = useState(2);
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
  return cols;
}

/** Returns up to 2 uppercase initials from a full name */
function getInvestorInitials(name: string): string {
  return name
    .split(" ")
    .map((w) => w[0])
    .slice(0, 2)
    .join("")
    .toUpperCase();
}
```

### Step 4: Add `InvestorTile` component above `BusinessPortalHero`

Insert this full component above the `function BusinessPortalHero()` definition:

```tsx
/**
 * InvestorTile — glassmorphism card for a single investor.
 * Color-tinted by primary funding stage; masonry-safe (no fixed height).
 */
function InvestorTile({ inv }: { inv: InvestorCard }) {
  const primaryStage = inv.fundingStages[0];
  const theme = STAGE_THEME[primaryStage];
  const initials = getInvestorInitials(inv.name);

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.35 }}
      className={cn(
        "group rounded-2xl border bg-gradient-to-br to-transparent",
        "shadow-sm hover:shadow-md hover:-translate-y-1 transition-all duration-300 p-5 space-y-3",
        theme.cardGradient,
        theme.border,
        theme.hoverShadow
      )}
    >
      {/* Investor avatar + deal count */}
      <div className="flex items-start justify-between gap-2">
        <div className="flex items-center gap-3 min-w-0">
          <div
            className={cn(
              "h-11 w-11 rounded-full flex items-center justify-center shrink-0 text-white font-bold text-sm shadow-sm",
              theme.avatar
            )}
          >
            {initials}
          </div>
          <div className="min-w-0">
            <h3 className="text-sm font-bold text-foreground truncate">{inv.name}</h3>
            <p className="text-xs text-muted-foreground truncate">{inv.firm}</p>
          </div>
        </div>
        <span className="text-[10px] text-muted-foreground shrink-0 whitespace-nowrap mt-1">
          {inv.portfolio} deals
        </span>
      </div>

      {/* Bio */}
      <p className="text-xs text-muted-foreground line-clamp-3 leading-relaxed">{inv.bio}</p>

      {/* Funding stage badges */}
      <div className="flex flex-wrap gap-1.5">
        {inv.fundingStages.map((stage) => (
          <Badge key={stage} className={cn("text-[10px]", STAGE_COLORS[stage])}>
            {stage}
          </Badge>
        ))}
      </div>

      {/* Sector chips */}
      <div className="flex flex-wrap gap-1.5">
        {inv.sectors.map((sector) => (
          <span
            key={sector}
            className="px-2 py-0.5 rounded-md bg-muted/50 border border-border/40 text-[10px] font-medium text-muted-foreground"
          >
            {sector}
          </span>
        ))}
      </div>

      {/* Ticket size */}
      <p className={cn("text-xs font-semibold flex items-center gap-1", theme.ticket)}>
        <DollarSign className="h-3 w-3" />
        {inv.ticketSize}
      </p>

      {/* Connect button */}
      <button
        type="button"
        className={cn(
          "w-full flex items-center justify-center gap-1.5 text-white text-xs font-medium py-2 rounded-xl transition-all",
          theme.button
        )}
      >
        <ArrowUpRight className="h-3.5 w-3.5" />
        Connect
      </button>
    </motion.div>
  );
}
```

### Step 5: Call `useColumnCount()` inside `BusinessPortal`

```typescript
export function BusinessPortal() {
  const [search, setSearch] = useState("");
  const [selectedStage, setSelectedStage] = useState<FundingStage | "all">("all");
  const [selectedSector, setSelectedSector] = useState("All");
  const colCount = useColumnCount(); // ← add this line
  ...
```

### Step 6: Update the funding stage filter chip active class

Find the active class inside `FUNDING_STAGES.map(...)`:
```typescript
selectedStage === stage.value
  ? "bg-primary text-primary-foreground border-primary"
  : "..."
```
Replace with:
```typescript
selectedStage === stage.value
  ? "bg-gradient-to-r from-orange-600 to-amber-600 text-white border-transparent shadow-sm"
  : "bg-muted/50 text-muted-foreground border-border/40 hover:bg-muted hover:text-foreground"
```

### Step 7: Replace the investors grid section

Find and delete the entire `{/* Investors Grid */}` section — the `<div>` containing the `<h2>`, the `motion.div` with `containerVariants`, the investor card renders, and the `{filtered.length === 0 && ...}` empty state.

Replace with:

```tsx
{/* Investors Masonry */}
<div>
  <h2 className="text-sm font-semibold text-foreground mb-3 flex items-center gap-2">
    <TrendingUp className="h-4 w-4 text-primary" />
    Investors & VCs
    <span className="text-xs text-muted-foreground font-normal">({filtered.length})</span>
  </h2>

  {filtered.length > 0 ? (
    <div className="-ml-4 flex w-auto items-start">
      {distributeIntoColumns(filtered, colCount).map((col, colIdx) => (
        <div key={colIdx} className="pl-4 flex-1 min-w-0 flex flex-col gap-4">
          {col.map((inv) => (
            <InvestorTile key={inv.id} inv={inv} />
          ))}
        </div>
      ))}
    </div>
  ) : (
    <div className="text-center py-16">
      <div className="relative inline-flex mb-4">
        <div className="absolute inset-0 bg-gradient-to-br from-orange-400/20 to-amber-500/20 rounded-full blur-xl" />
        <div className="relative h-14 w-14 rounded-2xl bg-gradient-to-br from-orange-500 to-amber-600 flex items-center justify-center shadow-lg">
          <Building2 className="h-6 w-6 text-white" />
        </div>
      </div>
      <p className="text-sm font-medium text-foreground mb-1">No investors match your filters</p>
      <p className="text-xs text-muted-foreground mb-3">Try adjusting your search or filters</p>
      <button
        onClick={() => {
          setSearch("");
          setSelectedStage("all");
          setSelectedSector("All");
        }}
        className="text-xs text-orange-600 dark:text-orange-400 hover:underline font-medium"
      >
        Clear all filters
      </button>
    </div>
  )}
</div>
```

### Step 8: Upgrade the Pitch Deck upload zone

Find the existing upload zone button (the `<button className="w-full border-2 border-dashed...">` block).

Replace it entirely with:

```tsx
<button
  type="button"
  className="w-full border-2 border-dashed border-orange-500/30 bg-orange-500/5 rounded-xl p-6 flex flex-col items-center gap-2 hover:border-orange-500/50 hover:bg-orange-500/[0.08] transition-colors group"
>
  <div className="h-10 w-10 rounded-xl bg-gradient-to-br from-orange-500 to-amber-500 flex items-center justify-center shadow-sm mb-1">
    <Rocket className="h-5 w-5 text-white" />
  </div>
  <span className="text-sm font-medium text-foreground group-hover:text-orange-600 dark:group-hover:text-orange-400 transition-colors">
    Drop your pitch deck here
  </span>
  <span className="text-xs text-muted-foreground">
    Pitch to 1,240+ active investors
  </span>
  <span className="text-[10px] text-muted-foreground/60">PDF, PPTX up to 25MB</span>
</button>
```

### Step 9: Add colored left-border stripe to deck status rows

Find the deck row `<div key={deck.id} className="flex items-center justify-between p-3 rounded-lg bg-muted/30 border border-border/30">`.

Replace the `className` with:

```tsx
className={cn(
  "flex items-center justify-between p-3 rounded-lg bg-muted/30 border border-border/30 border-l-4",
  deck.status === "shortlisted"
    ? "border-l-emerald-500"
    : deck.status === "reviewed"
    ? "border-l-blue-500"
    : "border-l-amber-500"
)}
```

### Step 10: Lint and commit

```bash
cd "/Volumes/Crucial X9/AssignX/user-web"
npx eslint components/portals/business-portal.tsx --max-warnings=0
```

Expected: no output (clean).

```bash
cd "/Volumes/Crucial X9/AssignX"
git add user-web/components/portals/business-portal.tsx
git commit -m "feat: redesign BusinessPortal — masonry grid + glassmorphism stage-tinted cards + pitch deck upgrade"
```

---

## Verification

1. `cd user-web && npm run dev`
2. Navigate to `/campus-connect` → **Professional tab**: verify masonry grid, each card has a distinct gradient tint (emerald for full-time, violet for internship, etc.), company initial avatar, salary in accent color, frosted skill chips, "Apply" appears on card hover (desktop)
3. **Business tab**: verify masonry grid, each investor card tinted by primary funding stage, gradient initials avatar, sector chips, ticket size in accent color, full-width Connect button
4. Pitch deck upload zone: orange dashed border, Rocket icon, "Pitch to 1,240+ investors" copy
5. Deck rows: colored left-border stripe (emerald = shortlisted, blue = reviewed, amber = pending)
6. Filter chips active state: indigo gradient (Professional), orange gradient (Business)
7. Mobile (≤639px): 1 column, Apply button always visible
8. Tablet (640–1023px): 2 columns
9. Desktop (≥1024px): 3 columns
