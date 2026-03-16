"use client";

/**
 * Experts Page - Redesigned for Academic/Professional Experts
 * Glassmorphic design with coffee bean + teal accent palette
 * Matches dashboard-pro design system
 */

import { useState, useMemo, useCallback, useEffect } from "react";
import { useRouter } from "next/navigation";
import { motion, AnimatePresence } from "framer-motion";
import {
  Search,
  Star,
  CheckCircle,
  ChevronRight,
  ChevronLeft,
  Clock,
  Users,
  Calendar,
  Video,
  X,
  Loader2,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import { useBookingStore } from "@/stores";
import { fetchExperts, fetchExpertById } from "@/lib/data/experts";
import type { Expert, ExpertSpecialization } from "@/types/expert";

/**
 * Category filter options
 */
const CATEGORY_FILTERS: { label: string; value: ExpertSpecialization | "all" }[] = [
  { label: "All", value: "all" },
  { label: "Research", value: "research_methodology" },
  { label: "Writing", value: "academic_writing" },
  { label: "Math & Stats", value: "mathematics" },
  { label: "Science", value: "science" },
  { label: "Engineering", value: "engineering" },
  { label: "Business", value: "business" },
  { label: "Computer Science", value: "programming" },
  { label: "Law", value: "law" },
  { label: "Medicine", value: "medicine" },
];

/**
 * Tab types for the page
 */
type TabType = "all" | "bookings";

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
 * Glassmorphic card base classes
 */
const GLASS_CARD =
  "bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 rounded-[20px] shadow-sm";
const GLASS_CARD_HOVER =
  "hover:shadow-xl hover:shadow-black/5 transition-all duration-300";

/**
 * Page transition variants
 */
const pageVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: { duration: 0.4, ease: [0.25, 0.1, 0.25, 1] as const },
  },
  exit: {
    opacity: 0,
    y: -20,
    transition: { duration: 0.3 },
  },
};

const staggerContainer = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: { staggerChildren: 0.06 },
  },
};

const staggerItem = {
  hidden: { opacity: 0, y: 16 },
  visible: {
    opacity: 1,
    y: 0,
    transition: { duration: 0.35, ease: [0.25, 0.1, 0.25, 1] },
  },
};

/**
 * Get initials from a name
 */
function getInitials(name: string): string {
  return name
    .split(" ")
    .filter((part) => !["Dr.", "Prof.", "Adv."].includes(part))
    .map((part) => part[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);
}

/**
 * Featured Expert Carousel
 */
function FeaturedCarousel({
  experts,
  onExpertClick,
  onBookClick,
}: {
  experts: Expert[];
  onExpertClick: (e: Expert) => void;
  onBookClick: (e: Expert) => void;
}) {
  const [currentIndex, setCurrentIndex] = useState(0);

  // Auto-rotate
  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentIndex((prev) => (prev + 1) % experts.length);
    }, 5000);
    return () => clearInterval(interval);
  }, [experts.length]);

  const current = experts[currentIndex];
  if (!current) return null;

  return (
    <div className={cn(GLASS_CARD, "p-5 md:p-6 relative overflow-hidden")}>
      {/* Teal accent glow */}
      <div className="absolute -top-12 -right-12 w-40 h-40 bg-teal-500/10 rounded-full blur-3xl pointer-events-none" />
      <div className="absolute -bottom-8 -left-8 w-32 h-32 bg-teal-600/5 rounded-full blur-2xl pointer-events-none" />

      {/* Header */}
      <div className="flex items-center justify-between mb-5">
        <div className="flex items-center gap-2">
          <span className="px-2.5 py-1 rounded-full bg-teal-500/10 text-[11px] font-semibold text-teal-700 dark:text-teal-400 border border-teal-500/20 uppercase tracking-wider">
            Top Pick
          </span>
          <Star className="h-3.5 w-3.5 text-amber-500 fill-amber-500" />
        </div>
        <div className="flex items-center gap-1.5">
          <button
            onClick={() =>
              setCurrentIndex(
                (prev) => (prev - 1 + experts.length) % experts.length
              )
            }
            className="h-8 w-8 rounded-xl bg-white/60 dark:bg-white/10 backdrop-blur-sm border border-white/40 dark:border-white/10 flex items-center justify-center hover:bg-white/80 dark:hover:bg-white/20 transition-colors"
          >
            <ChevronLeft className="h-4 w-4 text-foreground/60" />
          </button>
          <button
            onClick={() =>
              setCurrentIndex((prev) => (prev + 1) % experts.length)
            }
            className="h-8 w-8 rounded-xl bg-white/60 dark:bg-white/10 backdrop-blur-sm border border-white/40 dark:border-white/10 flex items-center justify-center hover:bg-white/80 dark:hover:bg-white/20 transition-colors"
          >
            <ChevronRight className="h-4 w-4 text-foreground/60" />
          </button>
        </div>
      </div>

      {/* Expert content */}
      <AnimatePresence mode="wait">
        <motion.div
          key={current.id}
          initial={{ opacity: 0, x: 30 }}
          animate={{ opacity: 1, x: 0 }}
          exit={{ opacity: 0, x: -30 }}
          transition={{ duration: 0.3 }}
          className="flex flex-col sm:flex-row gap-5 items-start"
        >
          {/* Avatar */}
          <button
            onClick={() => onExpertClick(current)}
            className="shrink-0 group"
          >
            <div className="relative">
              <div className="h-20 w-20 rounded-2xl bg-gradient-to-br from-teal-500 to-teal-700 flex items-center justify-center text-white text-xl font-bold shadow-lg shadow-teal-500/20 group-hover:shadow-teal-500/40 transition-shadow">
                {getInitials(current.name)}
              </div>
              {current.availability === "available" && (
                <div className="absolute -bottom-1 -right-1 h-5 w-5 rounded-full bg-emerald-500 border-2 border-white dark:border-gray-900" />
              )}
            </div>
          </button>

          {/* Info */}
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 mb-1">
              <button
                onClick={() => onExpertClick(current)}
                className="text-lg font-semibold text-foreground hover:text-teal-700 dark:hover:text-teal-400 transition-colors truncate"
              >
                {current.name}
              </button>
              {current.verified && (
                <CheckCircle className="h-4 w-4 text-teal-600 dark:text-teal-400 shrink-0" />
              )}
            </div>
            <p className="text-sm text-muted-foreground mb-2">
              {current.designation}
            </p>
            <p className="text-sm text-muted-foreground/80 line-clamp-2 mb-3">
              {current.bio}
            </p>
            <div className="flex flex-wrap items-center gap-3">
              <div className="flex items-center gap-1">
                <Star className="h-3.5 w-3.5 text-amber-500 fill-amber-500" />
                <span className="text-sm font-medium">{current.rating}</span>
                <span className="text-xs text-muted-foreground">
                  ({current.reviewCount})
                </span>
              </div>
              <div className="flex items-center gap-1 text-xs text-muted-foreground">
                <Users className="h-3.5 w-3.5" />
                {current.totalSessions} sessions
              </div>
              <div className="flex items-center gap-1 text-xs text-muted-foreground">
                <Clock className="h-3.5 w-3.5" />
                {current.responseTime}
              </div>
            </div>
          </div>

          {/* Price + Book */}
          <div className="shrink-0 flex flex-row sm:flex-col items-center sm:items-end gap-3 w-full sm:w-auto">
            <div className="text-right">
              <p className="text-xl font-bold text-foreground">
                <span className="text-base font-normal text-muted-foreground">
                  {"\u20B9"}
                </span>
                {current.pricePerSession}
              </p>
              <p className="text-[11px] text-muted-foreground">per session</p>
            </div>
            <button
              onClick={() => onBookClick(current)}
              className="px-5 py-2.5 rounded-xl bg-teal-600 hover:bg-teal-700 text-white text-sm font-medium transition-colors shadow-lg shadow-teal-600/20 hover:shadow-teal-600/30 w-full sm:w-auto"
            >
              Book Session
            </button>
          </div>
        </motion.div>
      </AnimatePresence>

      {/* Dots */}
      <div className="flex items-center justify-center gap-1.5 mt-5">
        {experts.map((_, idx) => (
          <button
            key={idx}
            onClick={() => setCurrentIndex(idx)}
            className={cn(
              "h-1.5 rounded-full transition-all duration-300",
              idx === currentIndex
                ? "w-6 bg-teal-600"
                : "w-1.5 bg-foreground/20 hover:bg-foreground/30"
            )}
          />
        ))}
      </div>
    </div>
  );
}

/**
 * Expert Card Component
 */
function ExpertGridCard({
  expert,
  onExpertClick,
  onBookClick,
}: {
  expert: Expert;
  onExpertClick: (e: Expert) => void;
  onBookClick: (e: Expert) => void;
}) {
  return (
    <div
      className={cn(
        GLASS_CARD,
        GLASS_CARD_HOVER,
        "p-5 group cursor-pointer hover:-translate-y-1"
      )}
      onClick={() => onExpertClick(expert)}
    >
      {/* Top row: avatar + info */}
      <div className="flex items-start gap-4 mb-4">
        {/* Avatar */}
        <div className="relative shrink-0">
          <div className="h-14 w-14 rounded-2xl bg-gradient-to-br from-teal-500 to-teal-700 flex items-center justify-center text-white text-base font-bold shadow-md shadow-teal-500/15">
            {getInitials(expert.name)}
          </div>
          {expert.availability === "available" && (
            <div className="absolute -bottom-0.5 -right-0.5 h-4 w-4 rounded-full bg-emerald-500 border-2 border-white dark:border-gray-900" />
          )}
        </div>

        {/* Name, designation, verified */}
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-1.5 mb-0.5">
            <h3 className="font-semibold text-foreground text-[15px] truncate group-hover:text-teal-700 dark:group-hover:text-teal-400 transition-colors">
              {expert.name}
            </h3>
            {expert.verified && (
              <CheckCircle className="h-3.5 w-3.5 text-teal-600 dark:text-teal-400 shrink-0" />
            )}
          </div>
          <p className="text-xs text-muted-foreground truncate">
            {expert.designation}
          </p>
        </div>
      </div>

      {/* Specialization tags */}
      <div className="flex flex-wrap gap-1.5 mb-3">
        {expert.specializations.slice(0, 2).map((spec) => (
          <span
            key={spec}
            className="px-2 py-0.5 rounded-full bg-teal-500/8 dark:bg-teal-500/15 text-[10px] font-medium text-teal-700 dark:text-teal-400 border border-teal-500/10 dark:border-teal-500/20"
          >
            {SPEC_DISPLAY[spec] || spec}
          </span>
        ))}
      </div>

      {/* Stats row */}
      <div className="flex items-center gap-3 mb-4">
        <div className="flex items-center gap-1">
          <Star className="h-3.5 w-3.5 text-amber-500 fill-amber-500" />
          <span className="text-sm font-medium">{expert.rating}</span>
        </div>
        <span className="text-xs text-muted-foreground">
          {expert.totalSessions} sessions
        </span>
        {expert.availability === "available" ? (
          <span className="ml-auto text-[10px] font-medium text-emerald-600 dark:text-emerald-400">
            Online
          </span>
        ) : (
          <span className="ml-auto text-[10px] font-medium text-amber-600 dark:text-amber-400">
            Busy
          </span>
        )}
      </div>

      {/* Bottom: price + book */}
      <div className="flex items-center justify-between pt-3 border-t border-foreground/5">
        <p className="text-base font-bold text-foreground">
          <span className="text-sm font-normal text-muted-foreground">
            {"\u20B9"}
          </span>
          {expert.pricePerSession}
          <span className="text-[11px] font-normal text-muted-foreground">
            /session
          </span>
        </p>
        <button
          onClick={(e) => {
            e.stopPropagation();
            onBookClick(expert);
          }}
          className="px-4 py-2 rounded-xl bg-teal-600 hover:bg-teal-700 text-white text-xs font-medium transition-colors shadow-sm shadow-teal-600/20 hover:shadow-teal-600/30"
        >
          Book
        </button>
      </div>
    </div>
  );
}

/**
 * Specialization display names
 */
const SPEC_DISPLAY: Record<string, string> = {
  academic_writing: "Academic Writing",
  research_methodology: "Research",
  data_analysis: "Data Analysis",
  programming: "Computer Science",
  mathematics: "Math & Stats",
  science: "Science",
  business: "Business",
  engineering: "Engineering",
  law: "Law",
  medicine: "Medicine",
  arts: "Arts",
  other: "Other",
};

/**
 * Experts Page Component
 */
export default function ExpertsPage() {
  const router = useRouter();

  // State
  const [activeTab, setActiveTab] = useState<TabType>("all");
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedCategory, setSelectedCategory] = useState<
    ExpertSpecialization | "all"
  >("all");
  const [allExperts, setAllExperts] = useState<Expert[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  // Booking store
  const bookings = useBookingStore((s) => s.bookings);
  const fetchBookings = useBookingStore((s) => s.fetchBookings);
  const updateBookingStatus = useBookingStore((s) => s.updateBookingStatus);

  // Fetch experts from API on mount
  useEffect(() => {
    let cancelled = false;
    setIsLoading(true);
    fetchExperts()
      .then(({ experts }) => {
        if (!cancelled) setAllExperts(experts);
      })
      .finally(() => {
        if (!cancelled) setIsLoading(false);
      });
    return () => { cancelled = true; };
  }, []);

  // Fetch bookings from API on mount
  useEffect(() => {
    fetchBookings();
  }, [fetchBookings]);

  // Featured experts for carousel
  const featuredExperts = useMemo(() => {
    return allExperts.filter((e) => e.featured);
  }, [allExperts]);

  // Active bookings count
  const activeBookingsCount = useMemo(() => {
    return bookings.filter(
      (b) => b.status === "upcoming" || b.status === "in_progress"
    ).length;
  }, [bookings]);

  // Filtered experts
  const filteredExperts = useMemo(() => {
    let result = [...allExperts];

    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase();
      result = result.filter(
        (expert) =>
          expert.name.toLowerCase().includes(query) ||
          expert.designation.toLowerCase().includes(query) ||
          expert.bio?.toLowerCase().includes(query)
      );
    }

    if (selectedCategory !== "all") {
      result = result.filter((expert) =>
        expert.specializations.includes(selectedCategory)
      );
    }

    return result;
  }, [searchQuery, selectedCategory, allExperts]);

  // Navigation handlers
  const handleExpertClick = useCallback(
    (expert: Expert) => {
      router.push(`/experts/${expert.id}`);
    },
    [router]
  );

  const handleBookClick = useCallback(
    (expert: Expert) => {
      router.push(`/experts/booking/${expert.id}`);
    },
    [router]
  );

  // Booking action handlers
  const handleReschedule = useCallback((_bookingId: string) => {
    toast.info("Rescheduling feature coming soon!");
  }, []);

  const handleCancelBooking = useCallback(
    (bookingId: string) => {
      updateBookingStatus(bookingId, "cancelled");
      toast.success("Booking cancelled successfully");
    },
    [updateBookingStatus]
  );

  const handleJoinSession = useCallback(
    (bookingId: string) => {
      const booking = bookings.find((b) => b.id === bookingId);
      if (booking?.meetLink) {
        window.open(booking.meetLink, "_blank");
      }
    },
    [bookings]
  );

  return (
    <div
      className={cn(
        "mesh-background mesh-gradient-bottom-right-animated h-full overflow-hidden",
        getTimeBasedGradientClass()
      )}
    >
      <div className="relative z-10 h-full px-4 py-6 md:px-6 md:py-8 lg:px-8 lg:py-10 overflow-y-auto">
        <div className="max-w-[1400px] mx-auto space-y-8">
          {/* ===== HERO SECTION ===== */}
          <div className="space-y-5">
            <div>
              <h1 className="text-3xl md:text-4xl lg:text-[42px] font-light tracking-tight text-foreground/90">
                Find Your{" "}
                <span className="font-semibold text-teal-600 dark:text-teal-400">
                  Expert
                </span>
              </h1>
              <p className="text-base md:text-lg text-muted-foreground mt-2 max-w-xl">
                Connect with verified academic professionals for personalized
                guidance on research, writing, data analysis, and more.
              </p>
            </div>

            {/* Search Bar */}
            <div
              className={cn(
                GLASS_CARD,
                "flex items-center gap-3 px-4 py-3 max-w-2xl"
              )}
            >
              <Search className="h-5 w-5 text-muted-foreground shrink-0" />
              <input
                type="text"
                placeholder="Search experts by name, specialization, or topic..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="flex-1 bg-transparent text-sm text-foreground placeholder:text-muted-foreground/60 focus:outline-none"
              />
              {searchQuery && (
                <button
                  onClick={() => setSearchQuery("")}
                  className="h-6 w-6 rounded-full bg-foreground/10 flex items-center justify-center hover:bg-foreground/20 transition-colors"
                >
                  <X className="h-3 w-3 text-foreground/60" />
                </button>
              )}
            </div>

            {/* Stats Pills - populated from real data in production */}
          </div>

          {/* ===== TABS ===== */}
          <div className="flex items-center gap-1 p-1 rounded-2xl bg-foreground/5 dark:bg-white/5 w-fit">
            <button
              onClick={() => setActiveTab("all")}
              className={cn(
                "px-5 py-2 rounded-xl text-sm font-medium transition-all duration-200",
                activeTab === "all"
                  ? "bg-white dark:bg-white/15 text-foreground shadow-sm"
                  : "text-muted-foreground hover:text-foreground"
              )}
            >
              All Experts
            </button>
            <button
              onClick={() => setActiveTab("bookings")}
              className={cn(
                "px-5 py-2 rounded-xl text-sm font-medium transition-all duration-200 flex items-center gap-2",
                activeTab === "bookings"
                  ? "bg-white dark:bg-white/15 text-foreground shadow-sm"
                  : "text-muted-foreground hover:text-foreground"
              )}
            >
              My Bookings
              {activeBookingsCount > 0 && (
                <span className="h-5 min-w-[20px] px-1.5 rounded-full bg-teal-600 text-white text-[10px] font-bold flex items-center justify-center">
                  {activeBookingsCount}
                </span>
              )}
            </button>
          </div>

          {/* ===== TAB CONTENT ===== */}
          <AnimatePresence mode="wait">
            {activeTab === "all" && (
              <motion.div
                key="all-experts"
                variants={pageVariants}
                initial="hidden"
                animate="visible"
                exit="exit"
                className="space-y-8"
              >
                {/* Featured Expert Carousel */}
                {featuredExperts.length > 0 && (
                  <FeaturedCarousel
                    experts={featuredExperts}
                    onExpertClick={handleExpertClick}
                    onBookClick={handleBookClick}
                  />
                )}

                {/* Category Filter Pills */}
                <div className="flex flex-wrap gap-2">
                  {CATEGORY_FILTERS.map((cat) => (
                    <button
                      key={cat.value}
                      onClick={() => setSelectedCategory(cat.value)}
                      className={cn(
                        "px-3.5 py-1.5 rounded-full text-xs font-medium transition-all duration-200 border",
                        selectedCategory === cat.value
                          ? "bg-teal-600 text-white border-teal-600 shadow-sm shadow-teal-600/20"
                          : "bg-white/60 dark:bg-white/5 text-muted-foreground border-white/50 dark:border-white/10 hover:bg-white/80 dark:hover:bg-white/10 hover:text-foreground"
                      )}
                    >
                      {cat.label}
                    </button>
                  ))}
                </div>

                {/* Results count */}
                <p className="text-sm text-muted-foreground">
                  {filteredExperts.length} expert
                  {filteredExperts.length !== 1 && "s"} available
                </p>

                {/* Expert Cards Grid */}
                {isLoading ? (
                  <div className="flex flex-col items-center justify-center py-16">
                    <Loader2 className="h-8 w-8 animate-spin text-teal-600 mb-4" />
                    <p className="text-sm text-muted-foreground">Loading experts...</p>
                  </div>
                ) : filteredExperts.length === 0 ? (
                  <div className="flex flex-col items-center justify-center py-16 text-center">
                    <div
                      className={cn(
                        GLASS_CARD,
                        "h-16 w-16 flex items-center justify-center mb-5 shadow-lg"
                      )}
                    >
                      <Search className="h-7 w-7 text-muted-foreground" />
                    </div>
                    <h3 className="text-xl font-semibold mb-2">
                      No experts found
                    </h3>
                    <p className="text-sm text-muted-foreground max-w-xs">
                      Try adjusting your search or filters
                    </p>
                  </div>
                ) : (
                  <motion.div
                    variants={staggerContainer}
                    initial="hidden"
                    animate="visible"
                    className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4"
                  >
                    {filteredExperts.map((expert) => (
                      <motion.div key={expert.id} variants={staggerItem}>
                        <ExpertGridCard
                          expert={expert}
                          onExpertClick={handleExpertClick}
                          onBookClick={handleBookClick}
                        />
                      </motion.div>
                    ))}
                  </motion.div>
                )}
              </motion.div>
            )}

            {activeTab === "bookings" && (
              <motion.div
                key="bookings"
                variants={pageVariants}
                initial="hidden"
                animate="visible"
                exit="exit"
                className="space-y-6"
              >
                {bookings.length === 0 ? (
                  <div className="flex flex-col items-center justify-center py-16 text-center">
                    <div
                      className={cn(
                        GLASS_CARD,
                        "h-16 w-16 flex items-center justify-center mb-5 shadow-lg"
                      )}
                    >
                      <Calendar className="h-7 w-7 text-muted-foreground" />
                    </div>
                    <h3 className="text-xl font-semibold mb-2">
                      No bookings yet
                    </h3>
                    <p className="text-sm text-muted-foreground max-w-xs mb-4">
                      Book a session with an expert to get started
                    </p>
                    <button
                      onClick={() => setActiveTab("all")}
                      className="px-5 py-2.5 rounded-xl bg-teal-600 hover:bg-teal-700 text-white text-sm font-medium transition-colors"
                    >
                      Browse Experts
                    </button>
                  </div>
                ) : (
                  <motion.div
                    variants={staggerContainer}
                    initial="hidden"
                    animate="visible"
                    className="space-y-4"
                  >
                    {bookings.map((booking) => {
                      // Find expert from loaded experts list
                      const expert = allExperts.find(
                        (e) => e.id === booking.expertId
                      );

                      const bookingDate = new Date(booking.date);
                      const isUpcoming =
                        booking.status === "upcoming" ||
                        booking.status === "in_progress";
                      const isCompleted = booking.status === "completed";
                      const isCancelled = booking.status === "cancelled";

                      return (
                        <motion.div
                          key={booking.id}
                          variants={staggerItem}
                          className={cn(
                            GLASS_CARD,
                            GLASS_CARD_HOVER,
                            "p-5"
                          )}
                        >
                          <div className="flex flex-col sm:flex-row gap-4">
                            {/* Expert info */}
                            <div className="flex items-start gap-3 flex-1 min-w-0">
                              <div className="h-12 w-12 rounded-xl bg-gradient-to-br from-teal-500 to-teal-700 flex items-center justify-center text-white text-sm font-bold shrink-0">
                                {expert
                                  ? getInitials(expert.name)
                                  : "EX"}
                              </div>
                              <div className="flex-1 min-w-0">
                                <h4 className="font-semibold text-foreground text-sm truncate">
                                  {expert?.name || "Expert"}
                                </h4>
                                <p className="text-xs text-muted-foreground truncate">
                                  {booking.topic || "Consultation Session"}
                                </p>
                                <div className="flex items-center gap-2 mt-1.5">
                                  <span className="text-xs text-muted-foreground flex items-center gap-1">
                                    <Calendar className="h-3 w-3" />
                                    {bookingDate.toLocaleDateString("en-IN", {
                                      day: "numeric",
                                      month: "short",
                                    })}
                                  </span>
                                  <span className="text-xs text-muted-foreground flex items-center gap-1">
                                    <Clock className="h-3 w-3" />
                                    {booking.startTime} -{" "}
                                    {booking.endTime}
                                  </span>
                                </div>
                              </div>
                            </div>

                            {/* Status + Actions */}
                            <div className="flex items-center gap-2 sm:flex-col sm:items-end sm:gap-3">
                              <span
                                className={cn(
                                  "px-2.5 py-1 rounded-full text-[10px] font-semibold uppercase tracking-wider",
                                  isUpcoming &&
                                    "bg-teal-500/10 text-teal-700 dark:text-teal-400",
                                  isCompleted &&
                                    "bg-emerald-500/10 text-emerald-700 dark:text-emerald-400",
                                  isCancelled &&
                                    "bg-red-500/10 text-red-700 dark:text-red-400"
                                )}
                              >
                                {booking.status.replace("_", " ")}
                              </span>

                              <div className="flex items-center gap-2">
                                {isUpcoming && (
                                  <>
                                    {booking.meetLink ? (
                                      <button
                                        onClick={() =>
                                          handleJoinSession(booking.id)
                                        }
                                        className="px-3 py-1.5 rounded-lg bg-teal-600 hover:bg-teal-700 text-white text-xs font-medium transition-colors flex items-center gap-1.5"
                                      >
                                        <Video className="h-3 w-3" />
                                        Join
                                      </button>
                                    ) : (
                                      <span className="px-2.5 py-1 rounded-full text-[10px] font-medium text-amber-600 dark:text-amber-400 bg-amber-500/10">
                                        Meet link pending
                                      </span>
                                    )}
                                    <button
                                      onClick={() =>
                                        handleCancelBooking(booking.id)
                                      }
                                      className="h-8 w-8 rounded-lg bg-red-500/10 hover:bg-red-500/20 flex items-center justify-center transition-colors"
                                    >
                                      <X className="h-3.5 w-3.5 text-red-500" />
                                    </button>
                                  </>
                                )}
                                {isCompleted && (
                                  <button
                                    onClick={() =>
                                      handleReschedule(booking.id)
                                    }
                                    className="px-3 py-1.5 rounded-lg bg-foreground/5 hover:bg-foreground/10 text-xs font-medium text-foreground transition-colors"
                                  >
                                    Book Again
                                  </button>
                                )}
                              </div>
                            </div>
                          </div>
                        </motion.div>
                      );
                    })}
                  </motion.div>
                )}
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>
    </div>
  );
}
