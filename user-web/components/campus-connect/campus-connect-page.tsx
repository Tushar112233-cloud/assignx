"use client";

/**
 * Campus Connect Page - Redesigned
 *
 * Cleaner, more focused layout:
 * - Hero section (kept as-is with globe visualization)
 * - Simplified category pills (max 6 visible + "More" dropdown)
 * - Glassmorphic Quick Access cards
 * - Search + filters bar
 * - Post feed with skeleton loading
 * - FAB for creating posts
 *
 * STUDENT-ONLY HOUSING:
 * - Housing category is only visible to users with user_type === 'student'
 */

import { useState, useEffect, useCallback, useMemo, useRef } from "react";
import Link from "next/link";
import { motion, AnimatePresence, useReducedMotion } from "framer-motion";
import {
  Search,
  Plus,
  X,
  AlertCircle,
  RefreshCw,
  Users,
  HelpCircle,
  Home,
  Briefcase,
  BookOpen,
  Calendar,
  ShoppingBag,
  Car,
  Trophy,
  Megaphone,
  MessageSquare,
  Sparkles,
  Filter,
  GraduationCap,
  ChevronDown,
  Search as SearchIcon,
  Lock,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { toast } from "sonner";
import { cn } from "@/lib/utils";
import { useUserStore } from "@/stores/user-store";
import { CampusConnectMasonryGrid } from "./masonry-grid";
import { CollegeFilterCompact } from "./college-filter";
import {
  FilterSheet,
  ActiveFiltersBar,
  CampusConnectFilters,
  defaultCampusConnectFilters,
} from "./filter-sheet";
import { CampusPulseHero } from "./campus-pulse-hero";
import { SavedListings } from "./saved-listings";
import {
  getCampusConnectPosts,
  togglePostLike,
  togglePostSave,
  checkCollegeVerification,
} from "@/lib/actions/campus-connect";
import type { CampusConnectPost, CampusConnectCategory } from "@/types/campus-connect";

// =============================================================================
// GLASSMORPHIC CARD CLASSES
// =============================================================================

const GLASS_CARD =
  "bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 rounded-[20px] shadow-sm hover:shadow-xl hover:shadow-black/5 transition-all duration-300";

// =============================================================================
// ANIMATION VARIANTS
// =============================================================================

const fadeInUp = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0 },
};

const staggerContainer = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: { staggerChildren: 0.08, delayChildren: 0.05 },
  },
};

// =============================================================================
// CATEGORY CONFIGURATION
// =============================================================================

interface CategoryConfig {
  id: CampusConnectCategory;
  label: string;
  icon: React.ElementType;
  gradient: string;
  description: string;
  emoji: string;
}

function getAllCategories(isStudent: boolean): CategoryConfig[] {
  const categories: CategoryConfig[] = [
    { id: "questions", label: "Questions", icon: HelpCircle, gradient: "from-blue-500 to-cyan-500", description: "Academic Q&A", emoji: "?" },
    { id: "housing", label: "Housing", icon: Home, gradient: "from-emerald-500 to-teal-500", description: "PG & flats", emoji: "" },
    { id: "opportunities", label: "Opportunities", icon: Briefcase, gradient: "from-purple-500 to-violet-500", description: "Jobs", emoji: "" },
    { id: "events", label: "Events", icon: Calendar, gradient: "from-orange-500 to-amber-500", description: "Events", emoji: "" },
    { id: "marketplace", label: "Marketplace", icon: ShoppingBag, gradient: "from-pink-500 to-rose-500", description: "Buy/Sell", emoji: "" },
    { id: "resources", label: "Resources", icon: BookOpen, gradient: "from-cyan-500 to-blue-500", description: "Study tips", emoji: "" },
    { id: "lost_found", label: "Lost & Found", icon: SearchIcon, gradient: "from-red-500 to-rose-500", description: "Lost items", emoji: "" },
    { id: "rides", label: "Rides", icon: Car, gradient: "from-indigo-500 to-blue-500", description: "Carpool", emoji: "" },
    { id: "study_groups", label: "Study Groups", icon: Users, gradient: "from-violet-500 to-purple-500", description: "Study teams", emoji: "" },
    { id: "clubs", label: "Clubs", icon: Trophy, gradient: "from-yellow-500 to-amber-500", description: "Societies", emoji: "" },
    { id: "announcements", label: "Announcements", icon: Megaphone, gradient: "from-slate-500 to-gray-500", description: "Official", emoji: "" },
    { id: "discussions", label: "Discussions", icon: MessageSquare, gradient: "from-teal-500 to-emerald-500", description: "General", emoji: "" },
  ];

  if (!isStudent) {
    return categories.filter(cat => cat.id !== "housing");
  }

  return categories;
}

/** First 6 categories shown as visible pills, rest go into "More" dropdown */
const VISIBLE_PILL_COUNT = 6;

// =============================================================================
// QUICK ACCESS CARDS CONFIG
// =============================================================================

interface QuickAccessItem {
  id: CampusConnectCategory;
  label: string;
  icon: React.ElementType;
  gradient: string;
  description: string;
}

function getQuickAccessItems(isStudent: boolean): QuickAccessItem[] {
  const items: QuickAccessItem[] = [
    { id: "questions", label: "Ask a Doubt", icon: HelpCircle, gradient: "from-blue-500 to-cyan-500", description: "Get help from peers" },
    { id: "housing", label: "Find Housing", icon: Home, gradient: "from-emerald-500 to-teal-500", description: "PGs & flats" },
    { id: "opportunities", label: "Jobs & Gigs", icon: Briefcase, gradient: "from-purple-500 to-violet-500", description: "Internships & more" },
    { id: "events", label: "Campus Events", icon: Calendar, gradient: "from-orange-500 to-amber-500", description: "Fests & workshops" },
    { id: "marketplace", label: "Buy & Sell", icon: ShoppingBag, gradient: "from-pink-500 to-rose-500", description: "Student marketplace" },
    { id: "resources", label: "Study Resources", icon: BookOpen, gradient: "from-cyan-500 to-blue-500", description: "Notes & papers" },
  ];

  if (!isStudent) {
    return items.filter(item => item.id !== "housing");
  }

  return items;
}

// =============================================================================
// SKELETON LOADING COMPONENT
// =============================================================================

function PostSkeletonGrid() {
  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
      {[...Array(6)].map((_, i) => (
        <div key={i} className={cn(GLASS_CARD, "p-5 space-y-4 animate-pulse")}>
          {/* Author row */}
          <div className="flex items-center gap-3">
            <div className="h-10 w-10 rounded-full bg-[#765341]/10 dark:bg-white/10" />
            <div className="flex-1 space-y-2">
              <div className="h-3.5 w-24 rounded-full bg-[#765341]/10 dark:bg-white/10" />
              <div className="h-2.5 w-16 rounded-full bg-[#765341]/8 dark:bg-white/8" />
            </div>
            <div className="h-5 w-14 rounded-full bg-[#765341]/8 dark:bg-white/8" />
          </div>
          {/* Content lines */}
          <div className="space-y-2">
            <div className="h-4 w-full rounded-full bg-[#765341]/10 dark:bg-white/10" />
            <div className="h-4 w-4/5 rounded-full bg-[#765341]/8 dark:bg-white/8" />
            <div className="h-4 w-3/5 rounded-full bg-[#765341]/6 dark:bg-white/6" />
          </div>
          {/* Image placeholder (sometimes) */}
          {i % 2 === 0 && (
            <div className="h-40 rounded-2xl bg-[#765341]/8 dark:bg-white/8" />
          )}
          {/* Engagement row */}
          <div className="flex items-center gap-4 pt-1">
            <div className="h-3 w-12 rounded-full bg-[#765341]/8 dark:bg-white/8" />
            <div className="h-3 w-12 rounded-full bg-[#765341]/8 dark:bg-white/8" />
            <div className="h-3 w-12 rounded-full bg-[#765341]/8 dark:bg-white/8" />
          </div>
        </div>
      ))}
    </div>
  );
}

// =============================================================================
// CATEGORY PILLS BAR WITH "MORE" DROPDOWN
// =============================================================================

interface CategoryPillsBarProps {
  categories: CategoryConfig[];
  selectedCategory: CampusConnectCategory | "all";
  onSelect: (category: CampusConnectCategory | "all") => void;
}

function CategoryPillsBar({ categories, selectedCategory, onSelect }: CategoryPillsBarProps) {
  const [moreOpen, setMoreOpen] = useState(false);
  const moreRef = useRef<HTMLDivElement>(null);
  const prefersReducedMotion = useReducedMotion();

  const visibleCats = categories.slice(0, VISIBLE_PILL_COUNT);
  const overflowCats = categories.slice(VISIBLE_PILL_COUNT);
  const hasOverflow = overflowCats.length > 0;

  // Is the selected category in the overflow?
  const selectedInOverflow = overflowCats.some(c => c.id === selectedCategory);

  // Close dropdown when clicking outside
  useEffect(() => {
    if (!moreOpen) return;
    function handleClickOutside(e: MouseEvent) {
      if (moreRef.current && !moreRef.current.contains(e.target as Node)) {
        setMoreOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [moreOpen]);

  const pillClass = (active: boolean) =>
    cn(
      "flex items-center gap-2 px-4 py-2 text-sm font-medium rounded-full transition-all duration-200 whitespace-nowrap",
      active
        ? "bg-[#765341] text-white shadow-lg shadow-[#765341]/20"
        : "bg-white/70 dark:bg-white/5 backdrop-blur-sm text-[#14110F]/70 dark:text-white/60 hover:text-[#14110F] dark:hover:text-white hover:bg-white dark:hover:bg-white/10 border border-[#765341]/15 dark:border-white/10"
    );

  return (
    <div className="flex flex-wrap items-center gap-2">
      {/* "All" pill */}
      <button
        onClick={() => onSelect("all")}
        className={pillClass(selectedCategory === "all")}
      >
        <Sparkles className="h-3.5 w-3.5" />
        All
      </button>

      {/* Visible category pills */}
      {visibleCats.map((cat) => {
        const Icon = cat.icon;
        return (
          <button
            key={cat.id}
            onClick={() => onSelect(cat.id)}
            className={pillClass(selectedCategory === cat.id)}
          >
            <Icon className="h-3.5 w-3.5" />
            {cat.label}
          </button>
        );
      })}

      {/* "More" dropdown */}
      {hasOverflow && (
        <div className="relative" ref={moreRef}>
          <button
            onClick={() => setMoreOpen(!moreOpen)}
            className={cn(
              pillClass(selectedInOverflow),
              "gap-1.5"
            )}
          >
            {selectedInOverflow
              ? categories.find(c => c.id === selectedCategory)?.label || "More"
              : "More"}
            <ChevronDown className={cn(
              "h-3.5 w-3.5 transition-transform duration-200",
              moreOpen && "rotate-180"
            )} />
          </button>

          <AnimatePresence>
            {moreOpen && (
              <motion.div
                initial={{ opacity: 0, y: -8, scale: 0.96 }}
                animate={{ opacity: 1, y: 0, scale: 1 }}
                exit={{ opacity: 0, y: -8, scale: 0.96 }}
                transition={{ duration: 0.15 }}
                className={cn(
                  "absolute top-full left-0 mt-2 z-50 min-w-[200px]",
                  "bg-white/90 dark:bg-[#14110F]/90 backdrop-blur-xl rounded-2xl",
                  "border border-[#765341]/15 dark:border-white/10",
                  "shadow-xl shadow-black/10 p-2"
                )}
              >
                {overflowCats.map((cat) => {
                  const Icon = cat.icon;
                  const isActive = selectedCategory === cat.id;
                  return (
                    <button
                      key={cat.id}
                      onClick={() => {
                        onSelect(cat.id);
                        setMoreOpen(false);
                      }}
                      className={cn(
                        "flex items-center gap-3 w-full px-3 py-2.5 rounded-xl text-sm transition-all",
                        isActive
                          ? "bg-[#765341] text-white"
                          : "text-[#14110F]/80 dark:text-white/70 hover:bg-[#765341]/10 dark:hover:bg-white/10"
                      )}
                    >
                      <div className={cn(
                        "h-7 w-7 rounded-lg flex items-center justify-center",
                        isActive
                          ? "bg-white/20"
                          : `bg-gradient-to-br ${cat.gradient}`
                      )}>
                        <Icon className="h-3.5 w-3.5 text-white" />
                      </div>
                      <div className="text-left">
                        <span className="font-medium">{cat.label}</span>
                        <p className={cn(
                          "text-[11px]",
                          isActive ? "text-white/70" : "text-[#14110F]/50 dark:text-white/40"
                        )}>
                          {cat.description}
                        </p>
                      </div>
                    </button>
                  );
                })}
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      )}
    </div>
  );
}

// =============================================================================
// QUICK ACCESS GLASSMORPHIC CARDS
// =============================================================================

interface QuickAccessSectionProps {
  items: QuickAccessItem[];
  selectedCategory: CampusConnectCategory | "all";
  onSelect: (category: CampusConnectCategory) => void;
}

function QuickAccessSection({ items, selectedCategory, onSelect }: QuickAccessSectionProps) {
  const prefersReducedMotion = useReducedMotion();

  return (
    <motion.div
      initial="hidden"
      whileInView="visible"
      viewport={{ once: true }}
      variants={staggerContainer}
      className="mb-6"
    >
      <motion.div variants={fadeInUp} className="flex items-center gap-2 mb-3">
        <Sparkles className="h-4 w-4 text-[#765341]" />
        <h3 className="text-sm font-semibold text-[#14110F] dark:text-[#E4E1C7]">Quick Access</h3>
      </motion.div>

      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3">
        {items.map((item) => {
          const Icon = item.icon;
          const isActive = selectedCategory === item.id;

          return (
            <motion.button
              key={item.id}
              variants={fadeInUp}
              whileHover={prefersReducedMotion ? {} : { y: -4, scale: 1.02 }}
              whileTap={prefersReducedMotion ? {} : { scale: 0.97 }}
              onClick={() => onSelect(item.id)}
              className={cn(
                "relative group p-4 rounded-[20px] text-left transition-all duration-300",
                "bg-white/70 dark:bg-white/5 backdrop-blur-xl",
                "border shadow-sm hover:shadow-xl hover:shadow-black/5",
                isActive
                  ? "border-[#765341]/40 dark:border-violet-400/30 ring-2 ring-[#765341]/20 dark:ring-violet-400/20"
                  : "border-white/50 dark:border-white/10"
              )}
            >
              <div className={cn(
                "h-10 w-10 rounded-xl flex items-center justify-center mb-3 transition-transform group-hover:scale-110",
                `bg-gradient-to-br ${item.gradient}`
              )}>
                <Icon className="h-5 w-5 text-white" strokeWidth={1.5} />
              </div>
              <p className="text-sm font-semibold text-[#14110F] dark:text-[#E4E1C7] mb-0.5">
                {item.label}
              </p>
              <p className="text-[11px] text-[#14110F]/50 dark:text-white/40 leading-relaxed">
                {item.description}
              </p>
            </motion.button>
          );
        })}
      </div>
    </motion.div>
  );
}

// =============================================================================
// MAIN PAGE COMPONENT
// =============================================================================

export function CampusConnectPage() {
  const { user } = useUserStore();
  const prefersReducedMotion = useReducedMotion();

  const isStudent = useMemo(() => {
    return user?.user_type === "student" || user?.userType === "student";
  }, [user]);

  const isLoggedIn = !!user;
  const allCategories = useMemo(() => getAllCategories(isStudent), [isStudent]);
  const quickAccessItems = useMemo(() => getQuickAccessItems(isStudent), [isStudent]);

  // State
  const [posts, setPosts] = useState<CampusConnectPost[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedCategory, setSelectedCategory] = useState<CampusConnectCategory | "all">("all");
  const [selectedUniversityId, setSelectedUniversityId] = useState<string | null>(null);
  const [myCollegeOnly, setMyCollegeOnly] = useState(false);
  const [filterSheetOpen, setFilterSheetOpen] = useState(false);
  const [showSaved, setShowSaved] = useState(false);
  const [isVerified, setIsVerified] = useState(false);
  const [internalFilters, setInternalFilters] = useState<CampusConnectFilters>(defaultCampusConnectFilters);
  const [hasMore, setHasMore] = useState(false);
  const [page, setPage] = useState(0);

  const POSTS_PER_PAGE = 20;

  const firstName = useMemo(() => {
    if (!user) return "there";
    const fullName = user.fullName || user.full_name || user.email?.split("@")[0] || "";
    return fullName.split(" ")[0] || "there";
  }, [user]);

  // Check verification
  useEffect(() => {
    async function checkVerification() {
      if (user) {
        const { isVerified: verified } = await checkCollegeVerification();
        setIsVerified(verified);
      }
    }
    checkVerification();
  }, [user]);

  // Fetch posts
  const fetchPosts = useCallback(async (reset = false) => {
    try {
      if (reset) {
        setIsLoading(true);
        setPage(0);
      }
      setError(null);

      const currentPage = reset ? 0 : page;
      const { data, total, error: fetchError } = await getCampusConnectPosts({
        category: selectedCategory,
        universityId: myCollegeOnly ? undefined : selectedUniversityId,
        search: searchQuery || undefined,
        sortBy: "recent",
        limit: POSTS_PER_PAGE,
        offset: currentPage * POSTS_PER_PAGE,
        excludeHousing: !isStudent,
      });

      if (fetchError) {
        setError(fetchError);
        toast.error(fetchError);
        return;
      }

      let filteredData = data;
      if (!isStudent) {
        filteredData = data.filter(post => post.category !== "housing");
      }

      if (reset) {
        setPosts(filteredData);
      } else {
        setPosts(prev => [...prev, ...filteredData]);
      }

      setHasMore(filteredData.length === POSTS_PER_PAGE && (currentPage + 1) * POSTS_PER_PAGE < total);
    } catch (err) {
      const message = err instanceof Error ? err.message : "Failed to load posts";
      setError(message);
      toast.error(message);
    } finally {
      setIsLoading(false);
    }
  }, [selectedCategory, selectedUniversityId, searchQuery, myCollegeOnly, page, isStudent]);

  useEffect(() => {
    fetchPosts(true);
  }, [selectedCategory, selectedUniversityId, myCollegeOnly]);

  useEffect(() => {
    const timer = setTimeout(() => {
      if (searchQuery !== undefined) {
        fetchPosts(true);
      }
    }, 300);
    return () => clearTimeout(timer);
  }, [searchQuery]);

  const handleLoadMore = useCallback(() => {
    setPage(prev => prev + 1);
    fetchPosts(false);
  }, [fetchPosts]);

  const handleLike = async (postId: string) => {
    if (!user) {
      toast.error("Please sign in to like posts");
      return;
    }

    setPosts(prev =>
      prev.map(post =>
        post.id === postId
          ? { ...post, isLiked: !post.isLiked, likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1 }
          : post
      )
    );

    const { success, error } = await togglePostLike(postId);

    if (!success || error) {
      setPosts(prev =>
        prev.map(post =>
          post.id === postId
            ? { ...post, isLiked: !post.isLiked, likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1 }
            : post
        )
      );
      toast.error(error || "Failed to update like");
    }
  };

  const handleSave = async (postId: string) => {
    if (!user) {
      toast.error("Please sign in to save posts");
      return;
    }

    setPosts(prev =>
      prev.map(post =>
        post.id === postId ? { ...post, isSaved: !post.isSaved } : post
      )
    );

    const { success, isSaved, error } = await togglePostSave(postId);

    if (!success || error) {
      setPosts(prev =>
        prev.map(post =>
          post.id === postId ? { ...post, isSaved: !post.isSaved } : post
        )
      );
      toast.error(error || "Failed to update save");
    } else {
      toast.success(isSaved ? "Post saved" : "Post unsaved");
    }
  };

  const clearFilters = () => {
    setSearchQuery("");
    setSelectedCategory("all");
    setSelectedUniversityId(null);
    setMyCollegeOnly(false);
    setFilterSheetOpen(false);
  };

  const isHousingRestricted = !isStudent && selectedCategory === "housing";
  const hasActiveFilters = searchQuery || selectedCategory !== "all" || selectedUniversityId || myCollegeOnly;
  const showLoading = isLoading && posts.length === 0;

  return (
    <div className="min-h-screen bg-gradient-to-b from-[#E4E1C7]/30 via-white to-[#E4E1C7]/20 dark:from-[#14110F] dark:via-[#14110F]/95 dark:to-[#14110F]">
      {/* Subtle decorative background */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-0 left-1/4 w-96 h-96 bg-gradient-to-br from-violet-400/8 to-purple-400/8 rounded-full blur-3xl" />
        <div className="absolute top-1/3 right-0 w-80 h-80 bg-gradient-to-br from-[#765341]/6 to-[#765341]/4 rounded-full blur-3xl" />
        <div className="absolute bottom-1/4 left-0 w-72 h-72 bg-gradient-to-br from-violet-400/6 to-fuchsia-400/6 rounded-full blur-3xl" />
      </div>

      <div className="relative z-10 px-4 py-6 md:px-6 md:py-8 lg:px-8 lg:py-10 overflow-y-auto min-h-screen">
        <div className="max-w-[1400px] mx-auto space-y-6">

          {/* ============================================================= */}
          {/* 1. HERO SECTION (kept as-is) */}
          {/* ============================================================= */}
          <CampusPulseHero firstName={firstName} isVerified={isVerified} />

          {/* ============================================================= */}
          {/* 2. QUICK ACCESS GLASSMORPHIC CARDS */}
          {/* ============================================================= */}
          <QuickAccessSection
            items={quickAccessItems}
            selectedCategory={selectedCategory}
            onSelect={(cat) => setSelectedCategory(selectedCategory === cat ? "all" : cat)}
          />

          {/* ============================================================= */}
          {/* 3. SEARCH + FILTERS BAR */}
          {/* ============================================================= */}
          <div className={cn(GLASS_CARD, "p-4")}>
            <div className="flex flex-col sm:flex-row items-start sm:items-center gap-3">
              {/* Search input */}
              <div className="relative w-full sm:flex-1 sm:max-w-md">
                <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-[#765341]/40 dark:text-white/40" />
                <input
                  type="text"
                  placeholder="Search posts, questions, events..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="w-full h-10 pl-10 pr-9 text-sm bg-[#14110F]/5 dark:bg-white/5 border border-[#765341]/10 dark:border-white/10 rounded-xl focus:outline-none focus:ring-2 focus:ring-violet-500/20 focus:border-violet-500/30 transition-all text-[#14110F] dark:text-white placeholder:text-[#14110F]/40 dark:placeholder:text-white/40"
                />
                {searchQuery && (
                  <button
                    onClick={() => setSearchQuery("")}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-[#14110F]/40 dark:text-white/40 hover:text-[#14110F] dark:hover:text-white transition-colors"
                  >
                    <X className="h-4 w-4" />
                  </button>
                )}
              </div>

              {/* Filter controls */}
              <div className="flex items-center gap-2 w-full sm:w-auto">
                <CollegeFilterCompact
                  selectedUniversityId={selectedUniversityId}
                  onUniversityChange={setSelectedUniversityId}
                />
                <FilterSheet
                  filters={internalFilters}
                  onFiltersChange={setInternalFilters}
                  activeCategory={
                    selectedCategory === "housing"
                      ? "housing"
                      : selectedCategory === "events"
                      ? "events"
                      : selectedCategory === "resources"
                      ? "resources"
                      : "all"
                  }
                />
                <Sheet open={filterSheetOpen} onOpenChange={setFilterSheetOpen}>
                  <SheetTrigger asChild>
                    <button className="relative h-10 w-10 flex items-center justify-center rounded-xl bg-[#14110F]/5 dark:bg-white/5 border border-[#765341]/10 dark:border-white/10 hover:bg-[#14110F]/10 dark:hover:bg-white/10 transition-all">
                      <Filter className="h-4 w-4 text-[#765341]/60 dark:text-white/60" />
                      {hasActiveFilters && (
                        <span className="absolute top-1.5 right-1.5 h-2 w-2 rounded-full bg-violet-500" />
                      )}
                    </button>
                  </SheetTrigger>
                  <SheetContent side="bottom" className="h-auto max-h-[80vh] rounded-t-3xl">
                    <SheetHeader className="pb-4">
                      <SheetTitle>General Filters</SheetTitle>
                    </SheetHeader>
                    <div className="space-y-6">
                      <div className="flex items-center justify-between gap-4">
                        <div className="space-y-0.5">
                          <Label className="text-sm font-medium">My College Only</Label>
                          <p className="text-xs text-muted-foreground">Show posts from your university</p>
                        </div>
                        <Switch checked={myCollegeOnly} onCheckedChange={setMyCollegeOnly} disabled={!user} />
                      </div>
                      <div className="flex gap-3 pt-2">
                        <Button variant="outline" className="flex-1 h-11 rounded-xl" onClick={clearFilters}>
                          Clear All
                        </Button>
                        <Button className="flex-1 h-11 rounded-xl bg-[#765341] hover:bg-[#765341]/90" onClick={() => setFilterSheetOpen(false)}>
                          Apply
                        </Button>
                      </div>
                    </div>
                  </SheetContent>
                </Sheet>
              </div>
            </div>
          </div>

          <ActiveFiltersBar filters={internalFilters} onFiltersChange={setInternalFilters} className="mb-0" />

          {/* ============================================================= */}
          {/* 4. CATEGORY PILLS + ACTION BUTTONS */}
          {/* ============================================================= */}
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
            {/* Category pills */}
            <CategoryPillsBar
              categories={allCategories}
              selectedCategory={selectedCategory}
              onSelect={setSelectedCategory}
            />

            {/* Action buttons */}
            <div className="flex items-center gap-2 shrink-0">
              <Button
                asChild
                size="sm"
                className="gap-2 rounded-xl h-9 px-4 bg-gradient-to-r from-violet-600 to-fuchsia-600 hover:shadow-lg transition-all text-sm"
              >
                <Link href="/campus-connect/create">
                  <Plus className="h-3.5 w-3.5" />
                  Create Post
                </Link>
              </Button>
              <Button
                variant={showSaved ? "default" : "outline"}
                size="sm"
                className="gap-2 rounded-xl h-9 px-4 text-sm"
                onClick={() => setShowSaved(!showSaved)}
              >
                <Sparkles className="h-3.5 w-3.5" />
                {showSaved ? "All Posts" : "Saved"}
              </Button>
            </div>
          </div>

          {/* Active filter badges */}
          {hasActiveFilters && (
            <div className="flex items-center gap-2 flex-wrap">
              <span className="text-xs text-[#14110F]/50 dark:text-white/40">Active:</span>
              {searchQuery && (
                <Badge variant="secondary" className="gap-1 text-xs rounded-full px-3 py-1 bg-[#765341]/10 text-[#765341] dark:bg-white/10 dark:text-white/80 border-0">
                  &quot;{searchQuery}&quot;
                  <button onClick={() => setSearchQuery("")}><X className="h-3 w-3" /></button>
                </Badge>
              )}
              {selectedCategory !== "all" && (
                <Badge variant="secondary" className="gap-1 text-xs capitalize rounded-full px-3 py-1 bg-[#765341]/10 text-[#765341] dark:bg-white/10 dark:text-white/80 border-0">
                  {selectedCategory.replace("_", " ")}
                  <button onClick={() => setSelectedCategory("all")}><X className="h-3 w-3" /></button>
                </Badge>
              )}
              {myCollegeOnly && (
                <Badge variant="secondary" className="gap-1 text-xs rounded-full px-3 py-1 bg-[#765341]/10 text-[#765341] dark:bg-white/10 dark:text-white/80 border-0">
                  My College
                  <button onClick={() => setMyCollegeOnly(false)}><X className="h-3 w-3" /></button>
                </Badge>
              )}
            </div>
          )}

          {/* ============================================================= */}
          {/* 5. SAVED LISTINGS (toggle) */}
          {/* ============================================================= */}
          {showSaved && (
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
            >
              <SavedListings />
            </motion.div>
          )}

          {/* ============================================================= */}
          {/* 6. POST FEED AREA */}
          {/* ============================================================= */}
          {error && (
            <div className={cn(GLASS_CARD, "flex items-start gap-3 p-5 border-red-200/50 dark:border-red-800/30")}>
              <div className="h-10 w-10 rounded-xl bg-gradient-to-br from-red-400 to-rose-500 flex items-center justify-center shrink-0">
                <AlertCircle className="h-5 w-5 text-white" />
              </div>
              <div className="flex-1">
                <p className="text-sm font-medium text-red-700 dark:text-red-300">{error}</p>
                <Button variant="ghost" size="sm" onClick={() => fetchPosts(true)} className="mt-2 h-8 text-xs gap-1">
                  <RefreshCw className="h-3 w-3" />
                  Try Again
                </Button>
              </div>
            </div>
          )}

          <AnimatePresence mode="wait">
            {isHousingRestricted ? (
              <motion.div
                key="housing-restricted"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -20 }}
                transition={{ duration: 0.3 }}
              >
                <HousingRestrictedState onClearFilters={clearFilters} />
              </motion.div>
            ) : showLoading ? (
              <motion.div
                key="loading"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
              >
                <PostSkeletonGrid />
              </motion.div>
            ) : posts.length === 0 ? (
              <motion.div
                key="empty"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -20 }}
              >
                <EmptyState
                  searchQuery={searchQuery}
                  selectedCategory={selectedCategory}
                  isVerified={isVerified}
                  onClearFilters={clearFilters}
                  allCategories={allCategories}
                />
              </motion.div>
            ) : (
              <motion.div
                key={`posts-${selectedCategory}`}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -20 }}
                className="space-y-4 pb-8"
              >
                <p className="text-xs text-[#14110F]/40 dark:text-white/30 text-center">
                  Showing {posts.length} {posts.length === 1 ? "post" : "posts"}
                  {searchQuery && ` matching "${searchQuery}"`}
                </p>
                <CampusConnectMasonryGrid
                  posts={posts}
                  onLike={handleLike}
                  onSave={handleSave}
                  onLoadMore={handleLoadMore}
                  hasMore={hasMore}
                  isLoading={isLoading && posts.length > 0}
                />
              </motion.div>
            )}
          </AnimatePresence>

          {/* ============================================================= */}
          {/* 7. FLOATING ACTION BUTTON */}
          {/* ============================================================= */}
          <motion.div
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.5, type: "spring", stiffness: 200 }}
            className="fixed bottom-24 right-6 z-50"
          >
            <Button
              asChild
              size="lg"
              className="h-14 w-14 rounded-full shadow-xl shadow-violet-500/30 bg-gradient-to-r from-violet-600 to-fuchsia-600 hover:shadow-2xl hover:scale-105 transition-all"
            >
              <Link href="/campus-connect/create">
                <Plus className="h-6 w-6" />
                <span className="sr-only">Create Post</span>
              </Link>
            </Button>
          </motion.div>

        </div>
      </div>
    </div>
  );
}

// =============================================================================
// EMPTY STATE COMPONENT
// =============================================================================

interface EmptyStateProps {
  searchQuery: string;
  selectedCategory: CampusConnectCategory | "all";
  isVerified: boolean;
  onClearFilters: () => void;
  allCategories: CategoryConfig[];
}

function EmptyState({ searchQuery, selectedCategory, isVerified, onClearFilters, allCategories }: EmptyStateProps) {
  if (searchQuery) {
    return (
      <div className={cn(GLASS_CARD, "flex flex-col items-center justify-center py-16 text-center")}>
        <div className="h-14 w-14 rounded-2xl bg-[#765341]/10 dark:bg-white/10 flex items-center justify-center mb-4">
          <Search className="h-6 w-6 text-[#765341]/60 dark:text-white/60" />
        </div>
        <h3 className="text-lg font-semibold text-[#14110F] dark:text-[#E4E1C7] mb-1.5">No results found</h3>
        <p className="text-sm text-[#14110F]/50 dark:text-white/40 max-w-xs mb-5">No posts match &quot;{searchQuery}&quot;</p>
        <Button variant="outline" className="rounded-xl h-10 px-5 border-[#765341]/20" onClick={onClearFilters}>
          Clear Search
        </Button>
      </div>
    );
  }

  const categoryConfig = allCategories.find(c => c.id === selectedCategory);
  const Icon = categoryConfig?.icon || Users;
  const gradient = categoryConfig?.gradient || "from-violet-500 to-fuchsia-600";

  return (
    <div className={cn(GLASS_CARD, "flex flex-col items-center justify-center py-16 text-center")}>
      <div className={cn("h-14 w-14 rounded-2xl bg-gradient-to-br flex items-center justify-center mb-4 shadow-lg", gradient)}>
        <Icon className="h-6 w-6 text-white" />
      </div>
      <h3 className="text-lg font-semibold text-[#14110F] dark:text-[#E4E1C7] mb-1.5">
        {selectedCategory !== "all" ? `No ${selectedCategory.replace("_", " ")} yet` : "No posts yet"}
      </h3>
      <p className="text-sm text-[#14110F]/50 dark:text-white/40 mb-5 max-w-xs">
        Be the first to share something with your campus community!
      </p>
      {isVerified ? (
        <Button asChild className="gap-2 rounded-xl h-10 px-5 bg-gradient-to-r from-violet-600 to-fuchsia-600">
          <Link href="/campus-connect/create">
            <Plus className="h-4 w-4" />
            Create Post
          </Link>
        </Button>
      ) : (
        <Button asChild variant="outline" className="gap-2 rounded-xl h-10 px-5 border-[#765341]/20">
          <Link href="/verify-college">
            <GraduationCap className="h-4 w-4" />
            Verify College to Post
          </Link>
        </Button>
      )}
    </div>
  );
}

// =============================================================================
// HOUSING RESTRICTED STATE
// =============================================================================

function HousingRestrictedState({ onClearFilters }: { onClearFilters: () => void }) {
  return (
    <div className={cn(GLASS_CARD, "flex flex-col items-center justify-center py-16 text-center")}>
      <div className="h-14 w-14 rounded-2xl bg-gradient-to-br from-amber-400 to-orange-500 flex items-center justify-center mb-4 shadow-lg">
        <Lock className="h-6 w-6 text-white" />
      </div>
      <h3 className="text-lg font-semibold text-[#14110F] dark:text-[#E4E1C7] mb-1.5">Student-Only Feature</h3>
      <p className="text-sm text-[#14110F]/50 dark:text-white/40 mb-1.5 max-w-sm">
        Housing listings are available exclusively for verified students.
      </p>
      <p className="text-xs text-[#14110F]/40 dark:text-white/30 mb-5 max-w-xs">
        Verify your student status to access PGs, flats, and roommate listings.
      </p>
      <div className="flex flex-col sm:flex-row gap-3">
        <Button asChild className="gap-2 rounded-xl h-10 px-5 bg-gradient-to-r from-amber-500 to-orange-500">
          <Link href="/verify-student">
            <GraduationCap className="h-4 w-4" />
            Verify Student Status
          </Link>
        </Button>
        <Button variant="outline" className="rounded-xl h-10 px-5 border-[#765341]/20" onClick={onClearFilters}>
          Browse Other Categories
        </Button>
      </div>
    </div>
  );
}

export default CampusConnectPage;
