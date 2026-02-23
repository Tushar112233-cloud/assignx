"use client";

/**
 * Experts Page - Premium design matching projects-pro
 * Features: Mesh background, glassmorphic cards, proper spacing
 */

import { useState, useMemo, useCallback } from "react";
import { useRouter } from "next/navigation";
import { motion, AnimatePresence } from "framer-motion";
import {
  ExpertsHero,
  ExpertsTabs,
  DoctorsCarousel,
  MedicalFilter,
  DoctorsGrid,
  MyBookings,
  ExpertCard,
  SpecializationFilter,
} from "@/components/experts";
import type { ExpertsTabType } from "@/components/experts";
import {
  MOCK_EXPERTS,
  getFeaturedExperts,
} from "@/lib/data/experts";
import type { Expert, ExpertSpecialization } from "@/types/expert";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import { useBookingStore } from "@/stores";

/**
 * Filter doctors (experts with medicine specialization)
 */
function getDoctors(experts: Expert[]): Expert[] {
  return experts.filter((e) => e.specializations.includes("medicine"));
}

/**
 * Get time-based gradient class - matching projects-pro
 */
function getTimeBasedGradientClass(): string {
  const hour = new Date().getHours();
  if (hour >= 5 && hour < 12) return "mesh-gradient-morning";
  if (hour >= 12 && hour < 17) return "mesh-gradient-afternoon";
  return "mesh-gradient-evening";
}

/**
 * Page transition variants
 */
const pageVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.4,
      ease: [0.25, 0.1, 0.25, 1] as const,
    },
  },
  exit: {
    opacity: 0,
    y: -20,
    transition: {
      duration: 0.3,
    },
  },
};

/**
 * Content transition variants
 */
const contentVariants = {
  hidden: { opacity: 0, y: 10 },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.3,
      staggerChildren: 0.1,
    },
  },
};

/**
 * Experts Page Component - matching projects-pro design
 */
export default function ExpertsPage() {
  const router = useRouter();

  // Tab state
  const [activeTab, setActiveTab] = useState<ExpertsTabType>("doctors");

  // Bookings from shared store (persists across pages)
  const bookings = useBookingStore((s) => s.bookings);
  const updateBookingStatus = useBookingStore((s) => s.updateBookingStatus);

  // Filter states
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedMedicalSpec, setSelectedMedicalSpec] = useState<string>("all");
  const [selectedExpertSpec, setSelectedExpertSpec] = useState<
    ExpertSpecialization | "all"
  >("all");

  // Get featured doctors for carousel
  const featuredDoctors = useMemo(() => {
    return getFeaturedExperts().filter((e) =>
      e.specializations.includes("medicine")
    );
  }, []);

  // Get all doctors
  const allDoctors = useMemo(() => getDoctors(MOCK_EXPERTS), []);

  // Get user bookings count for tab badge
  const bookingsCount = useMemo(() => {
    return bookings.filter(
      (b) => b.status === "upcoming" || b.status === "in_progress"
    ).length;
  }, [bookings]);

  /**
   * Filter doctors by search and specialization
   */
  const filteredDoctors = useMemo(() => {
    let result = [...allDoctors];

    // Search filter
    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase();
      result = result.filter(
        (doc) =>
          doc.name.toLowerCase().includes(query) ||
          doc.designation.toLowerCase().includes(query) ||
          doc.bio?.toLowerCase().includes(query)
      );
    }

    return result;
  }, [allDoctors, searchQuery, selectedMedicalSpec]);

  /**
   * Filter all experts by search and specialization
   */
  const filteredExperts = useMemo(() => {
    let result = [...MOCK_EXPERTS];

    // Search filter
    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase();
      result = result.filter(
        (expert) =>
          expert.name.toLowerCase().includes(query) ||
          expert.designation.toLowerCase().includes(query) ||
          expert.bio?.toLowerCase().includes(query)
      );
    }

    // Specialization filter
    if (selectedExpertSpec !== "all") {
      result = result.filter((expert) =>
        expert.specializations.includes(selectedExpertSpec)
      );
    }

    return result;
  }, [searchQuery, selectedExpertSpec]);

  /**
   * Handle doctor click - navigate to profile
   */
  const handleDoctorClick = useCallback(
    (doctor: Expert) => {
      router.push(`/experts/${doctor.id}`);
    },
    [router]
  );

  /**
   * Handle book click - navigate to booking
   */
  const handleBookClick = useCallback(
    (doctor: Expert) => {
      router.push(`/experts/booking/${doctor.id}`);
    },
    [router]
  );

  /**
   * Handle booking actions
   */
  const handleMessage = useCallback((bookingId: string) => {
    toast.info("Messaging feature coming soon!");
  }, []);

  const handleReschedule = useCallback((bookingId: string) => {
    toast.info("Rescheduling feature coming soon!");
  }, []);

  const handleCancelBooking = useCallback((bookingId: string) => {
    updateBookingStatus(bookingId, "cancelled");
    toast.success("Booking cancelled successfully");
  }, [updateBookingStatus]);

  const handleJoinSession = useCallback((bookingId: string) => {
    const booking = bookings.find((b) => b.id === bookingId);
    if (booking?.meetLink) {
      window.open(booking.meetLink, "_blank");
    }
  }, [bookings]);

  /**
   * Handle search from hero
   */
  const handleHeroSearch = useCallback((query: string) => {
    setSearchQuery(query);
  }, []);

  return (
    <>
      {/* Mesh Gradient Background - matching projects-pro */}
      <div
        className={cn(
          "mesh-background mesh-gradient-bottom-right-animated h-full overflow-hidden",
          getTimeBasedGradientClass()
        )}
      >
        <div className="relative z-10 h-full px-4 py-6 md:px-6 md:py-8 lg:px-8 lg:py-10 overflow-y-auto">
          <div className="max-w-[1400px] mx-auto space-y-8">
            {/* Hero Section */}
            <ExpertsHero onSearch={handleHeroSearch} />

            {/* Tab Navigation */}
            <ExpertsTabs
              activeTab={activeTab}
              onTabChange={setActiveTab}
              bookingsCount={bookingsCount}
            />

            {/* Tab Content */}
            <AnimatePresence mode="wait">
              {activeTab === "doctors" && (
                <motion.div
                  key="doctors"
                  variants={pageVariants}
                  initial="hidden"
                  animate="visible"
                  exit="exit"
                  className="space-y-8"
                >
                  {/* Featured Doctors Carousel */}
                  {featuredDoctors.length > 0 && (
                    <DoctorsCarousel
                      doctors={featuredDoctors}
                      onDoctorClick={handleDoctorClick}
                      onBookClick={handleBookClick}
                    />
                  )}

                  {/* Medical Specialization Filter */}
                  <motion.div variants={contentVariants}>
                    <MedicalFilter
                      selected={selectedMedicalSpec}
                      onSelect={setSelectedMedicalSpec}
                    />
                  </motion.div>

                  {/* Results count */}
                  <motion.div variants={contentVariants}>
                    <p className="text-sm text-muted-foreground">
                      {filteredDoctors.length} doctor
                      {filteredDoctors.length !== 1 && "s"} available
                    </p>
                  </motion.div>

                  {/* Doctors Grid */}
                  <DoctorsGrid
                    doctors={filteredDoctors}
                    onDoctorClick={handleDoctorClick}
                    onBookClick={handleBookClick}
                  />
                </motion.div>
              )}

              {activeTab === "all" && (
                <motion.div
                  key="all-experts"
                  variants={pageVariants}
                  initial="hidden"
                  animate="visible"
                  exit="exit"
                  className="space-y-8"
                >
                  {/* Specialization Filter */}
                  <motion.div variants={contentVariants}>
                    <SpecializationFilter
                      selected={selectedExpertSpec}
                      onSelect={setSelectedExpertSpec}
                    />
                  </motion.div>

                  {/* Results count */}
                  <motion.div variants={contentVariants}>
                    <p className="text-sm text-muted-foreground">
                      {filteredExperts.length} expert
                      {filteredExperts.length !== 1 && "s"} available
                    </p>
                  </motion.div>

                  {/* Experts List */}
                  {filteredExperts.length === 0 ? (
                    <motion.div
                      variants={contentVariants}
                      className="flex flex-col items-center justify-center py-16 text-center"
                    >
                      <div className="h-16 w-16 rounded-[20px] bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 flex items-center justify-center mb-5 shadow-lg">
                        <svg
                          className="h-7 w-7 text-muted-foreground"
                          fill="none"
                          viewBox="0 0 24 24"
                          stroke="currentColor"
                        >
                          <path
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            strokeWidth={1.5}
                            d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
                          />
                        </svg>
                      </div>
                      <h3 className="text-xl font-semibold mb-2">
                        No experts found
                      </h3>
                      <p className="text-sm text-muted-foreground max-w-xs">
                        Try adjusting your search or filters
                      </p>
                    </motion.div>
                  ) : (
                    <motion.div variants={contentVariants} className="space-y-4">
                      {filteredExperts.map((expert, idx) => (
                        <motion.div
                          key={expert.id}
                          initial={{ opacity: 0, y: 20 }}
                          animate={{ opacity: 1, y: 0 }}
                          transition={{ delay: idx * 0.05 }}
                        >
                          <ExpertCard
                            expert={expert}
                            variant="default"
                            onClick={() => handleDoctorClick(expert)}
                            onBook={() => handleBookClick(expert)}
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
                >
                  <MyBookings
                    bookings={bookings}
                    onMessage={handleMessage}
                    onReschedule={handleReschedule}
                    onCancel={handleCancelBooking}
                    onJoin={handleJoinSession}
                  />
                </motion.div>
              )}
            </AnimatePresence>
          </div>
        </div>
      </div>
    </>
  );
}
