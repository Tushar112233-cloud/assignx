"use client";

/**
 * Campus Connect Page - Ultra Modern Community Platform
 *
 * FEATURES:
 * - Animated hero section with floating illustrations
 * - Feature carousel with stunning visuals
 * - Category cards with hover effects
 * - Pinterest-style masonry grid
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
  ChevronRight,
  ChevronLeft,
  Sparkles,
  Filter,
  GraduationCap,
  Zap,
  Globe,
  Search as SearchIcon,
  Lock,
  MapPin,
  Lightbulb,
  Target,
  Handshake,
  PartyPopper,
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
import {
  getCampusConnectPosts,
  togglePostLike,
  togglePostSave,
  checkCollegeVerification,
} from "@/lib/actions/campus-connect";
import type { CampusConnectPost, CampusConnectCategory } from "@/types/campus-connect";

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
    transition: { staggerChildren: 0.1, delayChildren: 0.1 },
  },
};

const floatAnimation = {
  initial: { y: 0 },
  animate: {
    y: [-10, 10, -10],
    transition: {
      duration: 6,
      repeat: Infinity,
      ease: "easeInOut" as const,
    },
  },
};

// =============================================================================
// FEATURE CAROUSEL DATA
// =============================================================================

interface FeatureSlide {
  id: string;
  title: string;
  subtitle: string;
  description: string;
  features: string[];
  icon: React.ElementType;
  illustration: React.ElementType;
  gradient: string;
  accentColor: string;
}

function getFeatureSlides(isStudent: boolean): FeatureSlide[] {
  const allSlides: FeatureSlide[] = [
    {
      id: "community",
      title: "Your Campus Community",
      subtitle: "Connect & Collaborate",
      description: "Join thousands of students sharing knowledge, opportunities, and experiences across 500+ colleges",
      features: ["Ask academic doubts", "Share study resources", "Form study groups"],
      icon: Users,
      illustration: Globe,
      gradient: "from-blue-600 via-indigo-600 to-violet-600",
      accentColor: "blue",
    },
    {
      id: "opportunities",
      title: "Discover Opportunities",
      subtitle: "Jobs & Internships",
      description: "Find internships, part-time jobs, and career opportunities exclusively posted by verified students and alumni",
      features: ["Campus placements", "Startup internships", "Freelance gigs"],
      icon: Briefcase,
      illustration: Target,
      gradient: "from-violet-600 via-purple-600 to-fuchsia-600",
      accentColor: "purple",
    },
    {
      id: "housing",
      title: "Find Your Space",
      subtitle: "Housing & Roommates",
      description: "Discover verified PGs, flats, and hostels near your campus with student reviews and transparent pricing",
      features: ["Verified listings", "Roommate finder", "Area guides"],
      icon: Home,
      illustration: MapPin,
      gradient: "from-emerald-600 via-teal-600 to-cyan-600",
      accentColor: "emerald",
    },
    {
      id: "events",
      title: "Campus Events",
      subtitle: "Never Miss Out",
      description: "Stay updated with fests, workshops, hackathons, and social events happening across your city",
      features: ["Cultural fests", "Tech hackathons", "Networking events"],
      icon: Calendar,
      illustration: PartyPopper,
      gradient: "from-orange-500 via-amber-500 to-yellow-500",
      accentColor: "amber",
    },
    {
      id: "resources",
      title: "Study Resources",
      subtitle: "Learn Together",
      description: "Access notes, previous year papers, and study materials shared by seniors and toppers",
      features: ["Subject notes", "PYQ papers", "Video lectures"],
      icon: BookOpen,
      illustration: Lightbulb,
      gradient: "from-rose-500 via-pink-500 to-fuchsia-500",
      accentColor: "pink",
    },
  ];

  if (!isStudent) {
    return allSlides.filter(slide => slide.id !== "housing");
  }

  return allSlides;
}

// =============================================================================
// CATEGORY CONFIGURATION
// =============================================================================

interface CategoryCardConfig {
  id: CampusConnectCategory;
  label: string;
  icon: React.ElementType;
  gradient: string;
  description: string;
  emoji: string;
}

function getFeaturedCategories(isStudent: boolean): CategoryCardConfig[] {
  const allFeatured: CategoryCardConfig[] = [
    { id: "questions", label: "Questions", icon: HelpCircle, gradient: "from-blue-500 to-cyan-500", description: "Ask doubts", emoji: "❓" },
    { id: "housing", label: "Housing", icon: Home, gradient: "from-emerald-500 to-teal-500", description: "Find PGs", emoji: "🏠" },
    { id: "opportunities", label: "Jobs", icon: Briefcase, gradient: "from-purple-500 to-violet-500", description: "Internships", emoji: "💼" },
    { id: "events", label: "Events", icon: Calendar, gradient: "from-orange-500 to-amber-500", description: "Campus events", emoji: "🎉" },
    { id: "marketplace", label: "Market", icon: ShoppingBag, gradient: "from-pink-500 to-rose-500", description: "Buy & sell", emoji: "🛍️" },
    { id: "resources", label: "Resources", icon: BookOpen, gradient: "from-cyan-500 to-blue-500", description: "Study tips", emoji: "📚" },
  ];

  if (!isStudent) {
    return allFeatured.filter(cat => cat.id !== "housing");
  }

  return allFeatured;
}

function getAllCategories(isStudent: boolean): CategoryCardConfig[] {
  const categories: CategoryCardConfig[] = [
    { id: "questions", label: "Questions", icon: HelpCircle, gradient: "from-blue-500 to-cyan-500", description: "Academic Q&A", emoji: "❓" },
    { id: "housing", label: "Housing", icon: Home, gradient: "from-emerald-500 to-teal-500", description: "PG & flats", emoji: "🏠" },
    { id: "opportunities", label: "Opportunities", icon: Briefcase, gradient: "from-purple-500 to-violet-500", description: "Jobs", emoji: "💼" },
    { id: "events", label: "Events", icon: Calendar, gradient: "from-orange-500 to-amber-500", description: "Events", emoji: "🎉" },
    { id: "marketplace", label: "Marketplace", icon: ShoppingBag, gradient: "from-pink-500 to-rose-500", description: "Buy/Sell", emoji: "🛍️" },
    { id: "resources", label: "Resources", icon: BookOpen, gradient: "from-cyan-500 to-blue-500", description: "Study tips", emoji: "📚" },
    { id: "lost_found", label: "Lost & Found", icon: SearchIcon, gradient: "from-red-500 to-rose-500", description: "Lost items", emoji: "🔍" },
    { id: "rides", label: "Rides", icon: Car, gradient: "from-indigo-500 to-blue-500", description: "Carpool", emoji: "🚗" },
    { id: "study_groups", label: "Study Groups", icon: Users, gradient: "from-violet-500 to-purple-500", description: "Study teams", emoji: "👥" },
    { id: "clubs", label: "Clubs", icon: Trophy, gradient: "from-yellow-500 to-amber-500", description: "Societies", emoji: "🏆" },
    { id: "announcements", label: "Announcements", icon: Megaphone, gradient: "from-slate-500 to-gray-500", description: "Official", emoji: "📢" },
    { id: "discussions", label: "Discussions", icon: MessageSquare, gradient: "from-teal-500 to-emerald-500", description: "General", emoji: "💬" },
  ];

  if (!isStudent) {
    return categories.filter(cat => cat.id !== "housing");
  }

  return categories;
}

// getGreeting moved to campus-pulse-hero.tsx

// =============================================================================
// FEATURE CAROUSEL COMPONENT
// =============================================================================

interface FeatureCarouselProps {
  slides: FeatureSlide[];
}

function FeatureCarousel({ slides }: FeatureCarouselProps) {
  const [currentSlide, setCurrentSlide] = useState(0);
  const [isPaused, setIsPaused] = useState(false);
  const [direction, setDirection] = useState(1);
  const intervalRef = useRef<NodeJS.Timeout | null>(null);
  const prefersReducedMotion = useReducedMotion();

  useEffect(() => {
    if (isPaused || prefersReducedMotion) return;

    intervalRef.current = setInterval(() => {
      setDirection(1);
      setCurrentSlide((prev) => (prev + 1) % slides.length);
    }, 5000);

    return () => {
      if (intervalRef.current) clearInterval(intervalRef.current);
    };
  }, [isPaused, slides.length, prefersReducedMotion]);

  const goToSlide = (index: number) => {
    setDirection(index > currentSlide ? 1 : -1);
    setCurrentSlide(index);
    setIsPaused(true);
    setTimeout(() => setIsPaused(false), 8000);
  };

  const goToPrev = () => {
    setDirection(-1);
    setCurrentSlide((prev) => (prev - 1 + slides.length) % slides.length);
    setIsPaused(true);
    setTimeout(() => setIsPaused(false), 8000);
  };

  const goToNext = () => {
    setDirection(1);
    setCurrentSlide((prev) => (prev + 1) % slides.length);
    setIsPaused(true);
    setTimeout(() => setIsPaused(false), 8000);
  };

  const slide = slides[currentSlide];
  const SlideIcon = slide.icon;
  const IllustrationIcon = slide.illustration;

  const slideVariants = {
    enter: (direction: number) => ({
      x: direction > 0 ? 300 : -300,
      opacity: 0,
      scale: 0.9,
    }),
    center: {
      x: 0,
      opacity: 1,
      scale: 1,
    },
    exit: (direction: number) => ({
      x: direction > 0 ? -300 : 300,
      opacity: 0,
      scale: 0.9,
    }),
  };

  return (
    <div
      className="relative w-full overflow-hidden rounded-3xl mb-8"
      onMouseEnter={() => setIsPaused(true)}
      onMouseLeave={() => setIsPaused(false)}
    >
      {/* Background */}
      <motion.div
        key={slide.id + "-bg"}
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.5 }}
        className={cn("absolute inset-0 bg-gradient-to-br", slide.gradient)}
      />

      {/* Decorative Elements */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute top-0 right-0 w-96 h-96 bg-white/10 rounded-full blur-3xl -translate-y-1/2 translate-x-1/2" />
        <div className="absolute bottom-0 left-0 w-64 h-64 bg-white/10 rounded-full blur-3xl translate-y-1/2 -translate-x-1/2" />

        {/* Animated Illustration */}
        {!prefersReducedMotion && (
          <motion.div
            variants={floatAnimation}
            initial="initial"
            animate="animate"
            className="absolute right-10 top-1/2 -translate-y-1/2 opacity-20 hidden lg:block"
          >
            <IllustrationIcon className="h-48 w-48 text-white" strokeWidth={0.5} />
          </motion.div>
        )}

        {/* Grid Pattern */}
        <div className="absolute inset-0 bg-[linear-gradient(rgba(255,255,255,0.03)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,0.03)_1px,transparent_1px)] bg-[size:40px_40px]" />
      </div>

      {/* Content */}
      <div className="relative p-6 md:p-8 lg:p-10 min-h-[280px] md:min-h-[320px]">
        <AnimatePresence mode="wait" custom={direction}>
          <motion.div
            key={slide.id}
            custom={direction}
            variants={slideVariants}
            initial="enter"
            animate="center"
            exit="exit"
            transition={{
              x: { type: "spring", stiffness: 300, damping: 30 },
              opacity: { duration: 0.3 },
              scale: { duration: 0.3 },
            }}
            className="relative z-10"
          >
            {/* Badge */}
            <motion.div
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.1 }}
              className="flex items-center gap-3 mb-4"
            >
              <div className="h-14 w-14 rounded-2xl bg-white/20 backdrop-blur-sm flex items-center justify-center shadow-lg">
                <SlideIcon className="h-7 w-7 text-white" strokeWidth={1.5} />
              </div>
              <span className="px-4 py-1.5 rounded-full bg-white/20 backdrop-blur-sm text-sm font-medium text-white">
                {slide.subtitle}
              </span>
            </motion.div>

            {/* Title */}
            <motion.h2
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.2 }}
              className="text-3xl md:text-4xl lg:text-5xl font-bold text-white mb-3 tracking-tight"
            >
              {slide.title}
            </motion.h2>

            {/* Description */}
            <motion.p
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.3 }}
              className="text-base md:text-lg text-white/80 max-w-xl mb-6"
            >
              {slide.description}
            </motion.p>

            {/* Features List */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.4 }}
              className="flex flex-wrap gap-3"
            >
              {slide.features.map((feature, i) => (
                <div
                  key={i}
                  className="flex items-center gap-2 px-4 py-2 rounded-full bg-white/15 backdrop-blur-sm text-sm text-white"
                >
                  <Sparkles className="h-3.5 w-3.5" />
                  <span>{feature}</span>
                </div>
              ))}
            </motion.div>
          </motion.div>
        </AnimatePresence>

        {/* Navigation Arrows */}
        <button
          onClick={goToPrev}
          className="absolute left-4 top-1/2 -translate-y-1/2 h-12 w-12 rounded-full bg-white/20 backdrop-blur-sm flex items-center justify-center text-white hover:bg-white/30 transition-all hover:scale-110 shadow-lg"
          aria-label="Previous slide"
        >
          <ChevronLeft className="h-6 w-6" />
        </button>
        <button
          onClick={goToNext}
          className="absolute right-4 top-1/2 -translate-y-1/2 h-12 w-12 rounded-full bg-white/20 backdrop-blur-sm flex items-center justify-center text-white hover:bg-white/30 transition-all hover:scale-110 shadow-lg"
          aria-label="Next slide"
        >
          <ChevronRight className="h-6 w-6" />
        </button>

        {/* Dots Navigation */}
        <div className="absolute bottom-4 left-1/2 -translate-x-1/2 flex items-center gap-2">
          {slides.map((_, index) => (
            <button
              key={index}
              onClick={() => goToSlide(index)}
              className="group relative"
              aria-label={`Go to slide ${index + 1}`}
            >
              <div
                className={cn(
                  "h-2 rounded-full transition-all duration-300",
                  index === currentSlide
                    ? "w-10 bg-white"
                    : "w-2 bg-white/40 group-hover:bg-white/60"
                )}
              />
              {index === currentSlide && !isPaused && !prefersReducedMotion && (
                <motion.div
                  className="absolute inset-0 bg-white/30 rounded-full origin-left"
                  initial={{ scaleX: 0 }}
                  animate={{ scaleX: 1 }}
                  transition={{ duration: 5, ease: "linear" }}
                  key={currentSlide}
                />
              )}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}

// =============================================================================
// WHAT IS CAMPUS CONNECT SECTION
// =============================================================================

function WhatIsCampusConnect() {
  const prefersReducedMotion = useReducedMotion();

  const features = [
    {
      icon: HelpCircle,
      title: "Ask & Answer",
      description: "Get help with academic doubts from seniors and peers",
      color: "blue",
    },
    {
      icon: Home,
      title: "Find Housing",
      description: "Discover verified PGs, flats, and roommates near campus",
      color: "emerald",
    },
    {
      icon: Briefcase,
      title: "Grab Opportunities",
      description: "Find internships, jobs, and freelance gigs",
      color: "purple",
    },
    {
      icon: Calendar,
      title: "Join Events",
      description: "Never miss fests, hackathons, and workshops",
      color: "orange",
    },
    {
      icon: ShoppingBag,
      title: "Buy & Sell",
      description: "Trade textbooks, gadgets, and more safely",
      color: "pink",
    },
    {
      icon: Handshake,
      title: "Network",
      description: "Connect with students from 500+ colleges",
      color: "cyan",
    },
  ];

  const colorMap: Record<string, string> = {
    blue: "from-blue-500 to-cyan-500",
    emerald: "from-emerald-500 to-teal-500",
    purple: "from-purple-500 to-violet-500",
    orange: "from-orange-500 to-amber-500",
    pink: "from-pink-500 to-rose-500",
    cyan: "from-cyan-500 to-blue-500",
  };

  return (
    <motion.div
      initial="hidden"
      whileInView="visible"
      viewport={{ once: true, margin: "-100px" }}
      variants={staggerContainer}
      className="mb-8"
    >
      <motion.div variants={fadeInUp} className="flex items-center gap-2 mb-4">
        <div className="h-8 w-8 rounded-lg bg-gradient-to-br from-violet-500 to-fuchsia-500 flex items-center justify-center">
          <Zap className="h-4 w-4 text-white" />
        </div>
        <h2 className="text-lg font-semibold text-foreground">What is Campus Connect?</h2>
      </motion.div>

      <motion.p variants={fadeInUp} className="text-sm text-muted-foreground mb-6 max-w-2xl">
        Campus Connect is your all-in-one platform to stay connected with your college community. From academic help to housing, we&apos;ve got you covered.
      </motion.p>

      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-3">
        {features.map((feature, index) => {
          const Icon = feature.icon;
          return (
            <motion.div
              key={feature.title}
              variants={fadeInUp}
              whileHover={prefersReducedMotion ? {} : { y: -4, scale: 1.02 }}
              className="group p-4 rounded-2xl bg-white/80 dark:bg-white/5 backdrop-blur-sm border border-border/50 hover:border-border hover:shadow-lg transition-all cursor-pointer"
            >
              <div className={cn(
                "h-10 w-10 rounded-xl bg-gradient-to-br flex items-center justify-center mb-3 group-hover:scale-110 transition-transform",
                colorMap[feature.color]
              )}>
                <Icon className="h-5 w-5 text-white" strokeWidth={1.5} />
              </div>
              <h3 className="text-sm font-semibold text-foreground mb-1">{feature.title}</h3>
              <p className="text-[11px] text-muted-foreground leading-relaxed">{feature.description}</p>
            </motion.div>
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

  const featureSlides = useMemo(() => getFeatureSlides(isStudent), [isStudent]);
  const featuredCategories = useMemo(() => getFeaturedCategories(isStudent), [isStudent]);
  const allCategories = useMemo(() => getAllCategories(isStudent), [isStudent]);

  // State
  const [posts, setPosts] = useState<CampusConnectPost[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedCategory, setSelectedCategory] = useState<CampusConnectCategory | "all">("all");
  const [selectedUniversityId, setSelectedUniversityId] = useState<string | null>(null);
  const [myCollegeOnly, setMyCollegeOnly] = useState(false);
  const [filterSheetOpen, setFilterSheetOpen] = useState(false);
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
    <div className="min-h-screen bg-gradient-to-b from-slate-50 via-white to-slate-50 dark:from-slate-950 dark:via-slate-900 dark:to-slate-950">
      {/* Decorative background */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-0 left-1/4 w-96 h-96 bg-gradient-to-br from-violet-400/10 to-purple-400/10 rounded-full blur-3xl" />
        <div className="absolute top-1/3 right-0 w-80 h-80 bg-gradient-to-br from-blue-400/10 to-cyan-400/10 rounded-full blur-3xl" />
        <div className="absolute bottom-1/4 left-0 w-72 h-72 bg-gradient-to-br from-pink-400/10 to-fuchsia-400/10 rounded-full blur-3xl" />
      </div>

      <div className="relative z-10 px-4 py-6 md:px-6 md:py-8 lg:px-8 lg:py-10 overflow-y-auto min-h-screen">
        <div className="max-w-[1400px] mx-auto">
          {/* Hero Section - Live Campus Pulse */}
          <CampusPulseHero firstName={firstName} isVerified={isVerified} />

          {/* Feature Carousel */}
          <FeatureCarousel slides={featureSlides} />

          {/* What is Campus Connect */}
          <WhatIsCampusConnect />

          {/* Quick Access Categories */}
          <motion.div
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true }}
            variants={staggerContainer}
            className="mb-6"
          >
            <motion.div variants={fadeInUp} className="flex items-center gap-2 mb-4">
              <Sparkles className="h-4 w-4 text-amber-500" />
              <h3 className="text-sm font-medium text-foreground">Quick Access</h3>
            </motion.div>
            <div className="flex flex-wrap gap-3">
              {featuredCategories.map((cat) => {
                const Icon = cat.icon;
                const isActive = selectedCategory === cat.id;

                return (
                  <motion.button
                    key={cat.id}
                    variants={fadeInUp}
                    onClick={() => setSelectedCategory(isActive ? "all" : cat.id)}
                    whileHover={prefersReducedMotion ? {} : { scale: 1.02 }}
                    whileTap={prefersReducedMotion ? {} : { scale: 0.98 }}
                    className={cn(
                      "flex items-center gap-3 px-4 py-3 rounded-2xl border transition-all duration-200",
                      isActive
                        ? "bg-foreground border-transparent text-background shadow-lg"
                        : "bg-white/80 dark:bg-white/5 backdrop-blur-sm border-border/50 hover:border-border hover:bg-white dark:hover:bg-white/10"
                    )}
                  >
                    <div className={cn(
                      "h-9 w-9 rounded-xl flex items-center justify-center",
                      isActive ? "bg-background/20" : `bg-gradient-to-br ${cat.gradient}`
                    )}>
                      <Icon className="h-4 w-4 text-white" strokeWidth={1.5} />
                    </div>
                    <div className="text-left">
                      <p className={cn("text-sm font-medium", isActive ? "text-background" : "text-foreground")}>
                        {cat.emoji} {cat.label}
                      </p>
                      <p className={cn("text-[11px]", isActive ? "text-background/70" : "text-muted-foreground")}>
                        {cat.description}
                      </p>
                    </div>
                  </motion.button>
                );
              })}
            </div>
          </motion.div>

          {/* Search + Filters */}
          <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mb-6">
            <div className="relative w-full sm:w-auto flex-1 max-w-md">
              <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <input
                type="text"
                placeholder="Search posts, questions, events..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full h-12 pl-11 pr-4 text-sm bg-white/80 dark:bg-white/5 backdrop-blur-sm border border-border/50 rounded-2xl focus:outline-none focus:ring-2 focus:ring-violet-500/20 focus:border-violet-500/50 transition-all"
              />
              {searchQuery && (
                <button
                  onClick={() => setSearchQuery("")}
                  className="absolute right-4 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground transition-colors"
                >
                  <X className="h-4 w-4" />
                </button>
              )}
            </div>

            <div className="flex items-center gap-3">
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
                  <button className="relative h-12 w-12 flex items-center justify-center rounded-2xl bg-white/80 dark:bg-white/5 backdrop-blur-sm border border-border/50 hover:bg-white dark:hover:bg-white/10 transition-all">
                    <Filter className="h-5 w-5 text-muted-foreground" />
                    {hasActiveFilters && (
                      <span className="absolute top-2 right-2 h-2.5 w-2.5 rounded-full bg-violet-500" />
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
                      <Button variant="outline" className="flex-1 h-12 rounded-xl" onClick={clearFilters}>
                        Clear All
                      </Button>
                      <Button className="flex-1 h-12 rounded-xl" onClick={() => setFilterSheetOpen(false)}>
                        Apply
                      </Button>
                    </div>
                  </div>
                </SheetContent>
              </Sheet>
            </div>
          </div>

          <ActiveFiltersBar filters={internalFilters} onFiltersChange={setInternalFilters} className="mb-4" />

          {/* All Category Tabs */}
          <div className="mb-6">
            <div className="flex flex-wrap gap-2">
              <motion.button
                onClick={() => setSelectedCategory("all")}
                whileHover={prefersReducedMotion ? {} : { scale: 1.03 }}
                whileTap={prefersReducedMotion ? {} : { scale: 0.97 }}
                className={cn(
                  "flex items-center gap-2 px-4 py-2.5 text-sm font-medium rounded-full transition-all duration-200",
                  selectedCategory === "all"
                    ? "bg-foreground text-background shadow-lg"
                    : "bg-white/80 dark:bg-white/5 text-muted-foreground hover:text-foreground hover:bg-white dark:hover:bg-white/10 border border-border/50"
                )}
              >
                <Sparkles className="h-4 w-4" />
                <span>All</span>
              </motion.button>

              {allCategories.map((cat) => {
                const isActive = selectedCategory === cat.id;
                const Icon = cat.icon;

                return (
                  <motion.button
                    key={cat.id}
                    onClick={() => setSelectedCategory(cat.id)}
                    whileHover={prefersReducedMotion ? {} : { scale: 1.03 }}
                    whileTap={prefersReducedMotion ? {} : { scale: 0.97 }}
                    className={cn(
                      "flex items-center gap-2 px-4 py-2.5 text-sm font-medium rounded-full transition-all duration-200",
                      isActive
                        ? "bg-foreground text-background shadow-lg"
                        : "bg-white/80 dark:bg-white/5 text-muted-foreground hover:text-foreground hover:bg-white dark:hover:bg-white/10 border border-border/50"
                    )}
                  >
                    <span>{cat.emoji}</span>
                    <span>{cat.label}</span>
                  </motion.button>
                );
              })}
            </div>
          </div>

          {/* Active Filters */}
          {hasActiveFilters && (
            <div className="flex items-center gap-2 flex-wrap mb-6">
              <span className="text-xs text-muted-foreground">Active filters:</span>
              {searchQuery && (
                <Badge variant="secondary" className="gap-1 text-xs rounded-full px-3 py-1">
                  &quot;{searchQuery}&quot;
                  <button onClick={() => setSearchQuery("")}><X className="h-3 w-3" /></button>
                </Badge>
              )}
              {selectedCategory !== "all" && (
                <Badge variant="secondary" className="gap-1 text-xs capitalize rounded-full px-3 py-1">
                  {selectedCategory.replace("_", " ")}
                  <button onClick={() => setSelectedCategory("all")}><X className="h-3 w-3" /></button>
                </Badge>
              )}
              {myCollegeOnly && (
                <Badge variant="secondary" className="gap-1 text-xs rounded-full px-3 py-1">
                  My College
                  <button onClick={() => setMyCollegeOnly(false)}><X className="h-3 w-3" /></button>
                </Badge>
              )}
            </div>
          )}

          {/* Main Content */}
          {error && (
            <div className="flex items-start gap-3 p-5 rounded-2xl bg-red-50/80 dark:bg-red-950/30 backdrop-blur-sm border border-red-200 dark:border-red-800 mb-6">
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
                className="flex flex-col items-center justify-center py-20"
              >
                <div className="relative mb-5">
                  <div className="h-16 w-16 rounded-2xl bg-gradient-to-br from-violet-500 to-fuchsia-600 flex items-center justify-center shadow-lg animate-pulse">
                    <Users className="h-7 w-7 text-white" />
                  </div>
                  <div className="absolute -inset-4 bg-gradient-to-br from-violet-400/20 to-fuchsia-500/20 rounded-full blur-xl pointer-events-none animate-pulse" />
                </div>
                <p className="text-sm text-muted-foreground">Loading posts...</p>
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
                <p className="text-xs text-muted-foreground text-center">
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

          {/* Floating Create Button - Mobile */}
          {isVerified && (
            <div className="fixed bottom-24 right-6 lg:hidden z-30">
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
            </div>
          )}
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
  allCategories: CategoryCardConfig[];
}

function EmptyState({ searchQuery, selectedCategory, isVerified, onClearFilters, allCategories }: EmptyStateProps) {
  if (searchQuery) {
    return (
      <div className="flex flex-col items-center justify-center py-20 text-center">
        <div className="h-16 w-16 rounded-2xl bg-white/80 dark:bg-white/5 backdrop-blur-sm border border-border/50 flex items-center justify-center mb-5 shadow-lg">
          <Search className="h-7 w-7 text-muted-foreground" />
        </div>
        <h3 className="text-xl font-semibold mb-2">No results found</h3>
        <p className="text-sm text-muted-foreground max-w-xs mb-6">No posts match &quot;{searchQuery}&quot;</p>
        <Button variant="outline" className="rounded-xl h-11 px-6" onClick={onClearFilters}>
          Clear Search
        </Button>
      </div>
    );
  }

  const categoryConfig = allCategories.find(c => c.id === selectedCategory);
  const Icon = categoryConfig?.icon || Users;
  const gradient = categoryConfig?.gradient || "from-violet-500 to-fuchsia-600";

  return (
    <div className="flex flex-col items-center justify-center py-20 text-center">
      <div className="relative mb-5">
        <div className={cn("h-16 w-16 rounded-2xl bg-gradient-to-br flex items-center justify-center shadow-lg", gradient)}>
          <Icon className="h-7 w-7 text-white" />
        </div>
        <div className="absolute -inset-4 bg-gradient-to-br from-violet-400/20 to-fuchsia-500/20 rounded-full blur-xl pointer-events-none" />
      </div>
      <h3 className="text-xl font-semibold mb-2">
        {selectedCategory !== "all" ? `No ${selectedCategory.replace("_", " ")} yet` : "No posts yet"}
      </h3>
      <p className="text-sm text-muted-foreground mb-6 max-w-xs">
        Be the first to share something with your campus community!
      </p>
      {isVerified ? (
        <Button asChild className="gap-2 rounded-xl h-11 px-6 bg-gradient-to-r from-violet-600 to-fuchsia-600">
          <Link href="/campus-connect/create">
            <Plus className="h-4 w-4" />
            Create Post
          </Link>
        </Button>
      ) : (
        <Button asChild variant="outline" className="gap-2 rounded-xl h-11 px-6">
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
    <div className="flex flex-col items-center justify-center py-20 text-center">
      <div className="relative mb-5">
        <div className="h-16 w-16 rounded-2xl bg-gradient-to-br from-amber-400 to-orange-500 flex items-center justify-center shadow-lg">
          <Lock className="h-7 w-7 text-white" />
        </div>
        <div className="absolute -inset-4 bg-gradient-to-br from-amber-400/20 to-orange-500/20 rounded-full blur-xl pointer-events-none" />
      </div>
      <h3 className="text-xl font-semibold mb-2">Student-Only Feature</h3>
      <p className="text-sm text-muted-foreground mb-2 max-w-sm">
        Housing listings are available exclusively for verified students.
      </p>
      <p className="text-xs text-muted-foreground mb-6 max-w-xs">
        Verify your student status to access PGs, flats, and roommate listings.
      </p>
      <div className="flex flex-col sm:flex-row gap-3">
        <Button asChild className="gap-2 rounded-xl h-11 px-6 bg-gradient-to-r from-amber-500 to-orange-500">
          <Link href="/verify-student">
            <GraduationCap className="h-4 w-4" />
            Verify Student Status
          </Link>
        </Button>
        <Button variant="outline" className="rounded-xl h-11 px-6" onClick={onClearFilters}>
          Browse Other Categories
        </Button>
      </div>
    </div>
  );
}

export default CampusConnectPage;
