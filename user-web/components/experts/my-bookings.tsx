"use client";

/**
 * MyBookings - Clean, modern bookings management
 * Features capsule tabs and solid card design
 */

import { useState, useMemo } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  CalendarClock,
  CheckCircle2,
  XCircle,
  Calendar,
  Clock,
  Video,
  MessageCircle,
  RefreshCw,
  Trash2,
  ArrowRight,
  BadgeCheck,
  Star,
} from "lucide-react";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { formatINR } from "@/lib/utils";
import type { ConsultationBooking, SessionStatus } from "@/types/expert";
import { MOCK_EXPERTS } from "@/lib/data/experts";
import { ReviewForm } from "@/components/experts/review-form";
import { apiClient } from "@/lib/api/client";

interface MyBookingsProps {
  bookings: ConsultationBooking[];
  onMessage?: (bookingId: string) => void;
  onReschedule?: (bookingId: string) => void;
  onCancel?: (bookingId: string) => void;
  onJoin?: (bookingId: string) => void;
  className?: string;
}

type BookingTab = "upcoming" | "completed" | "cancelled";

/**
 * Tab configuration with emojis
 */
const TABS: Array<{
  id: BookingTab;
  label: string;
  emoji: string;
  statuses: SessionStatus[];
}> = [
  {
    id: "upcoming",
    label: "Upcoming",
    emoji: "📅",
    statuses: ["upcoming", "in_progress"],
  },
  {
    id: "completed",
    label: "Completed",
    emoji: "✅",
    statuses: ["completed"],
  },
  {
    id: "cancelled",
    label: "Cancelled",
    emoji: "❌",
    statuses: ["cancelled", "no_show"],
  },
];

/**
 * Get expert by ID
 */
function getExpertById(expertId: string) {
  return MOCK_EXPERTS.find((e) => e.id === expertId);
}

/**
 * Get initials from name
 */
function getInitials(name: string): string {
  return name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);
}

/**
 * Format date for display
 */
function formatBookingDate(date: Date): string {
  const now = new Date();
  const bookingDate = new Date(date);
  const diff = bookingDate.getTime() - now.getTime();
  const days = Math.ceil(diff / (1000 * 60 * 60 * 24));

  if (days === 0) return "Today";
  if (days === 1) return "Tomorrow";
  if (days === -1) return "Yesterday";
  if (days > 0 && days < 7) return `In ${days} days`;

  return bookingDate.toLocaleDateString("en-IN", {
    weekday: "short",
    day: "numeric",
    month: "short",
  });
}

/**
 * Get time until booking
 */
function getTimeUntil(date: Date, startTime: string): string {
  const now = new Date();
  const bookingDate = new Date(date);
  const [hours, minutes] = startTime.split(":").map(Number);
  bookingDate.setHours(hours, minutes, 0, 0);

  const diff = bookingDate.getTime() - now.getTime();
  const hoursUntil = Math.floor(diff / (1000 * 60 * 60));
  const minutesUntil = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));

  if (diff < 0) return "Started";
  if (hoursUntil < 1) return `${minutesUntil}m`;
  if (hoursUntil < 24) return `${hoursUntil}h ${minutesUntil}m`;
  return `${Math.floor(hoursUntil / 24)}d`;
}

/**
 * Status badge configuration - clean solid design
 */
function getStatusConfig(status: SessionStatus) {
  switch (status) {
    case "upcoming":
      return {
        label: "Confirmed",
        className:
          "bg-emerald-100 text-emerald-700 dark:bg-emerald-900/50 dark:text-emerald-300",
      };
    case "in_progress":
      return {
        label: "In Progress",
        className:
          "bg-violet-100 text-violet-700 dark:bg-violet-900/50 dark:text-violet-300",
      };
    case "completed":
      return {
        label: "Completed",
        className:
          "bg-emerald-100 text-emerald-700 dark:bg-emerald-900/50 dark:text-emerald-300",
      };
    case "cancelled":
      return {
        label: "Cancelled",
        className:
          "bg-red-100 text-red-700 dark:bg-red-900/50 dark:text-red-300",
      };
    case "no_show":
      return {
        label: "No Show",
        className:
          "bg-stone-100 text-stone-700 dark:bg-stone-800 dark:text-stone-300",
      };
  }
}

/**
 * Booking card component - Clean solid design
 */
function BookingCard({
  booking,
  onMessage,
  onReschedule,
  onCancel,
  onJoin,
}: {
  booking: ConsultationBooking;
  onMessage?: () => void;
  onReschedule?: () => void;
  onCancel?: () => void;
  onJoin?: () => void;
}) {
  const expert = getExpertById(booking.expertId);
  const statusConfig = getStatusConfig(booking.status);
  const isUpcoming =
    booking.status === "upcoming" || booking.status === "in_progress";
  const isCompleted = booking.status === "completed";
  const [showReviewForm, setShowReviewForm] = useState(false);
  const [hasReviewed, setHasReviewed] = useState(!!(booking as any).review_rating);

  /**
   * Submit review via API
   */
  const handleReviewSubmit = async ({ rating, comment }: { rating: number; comment: string }) => {
    try {
      await apiClient(`/api/experts/${booking.expertId}/review`, {
        method: "POST",
        body: JSON.stringify({
          rating,
          review: comment,
          bookingId: booking.id,
        }),
      });
    } catch {
      // Best-effort — mock bookings have non-UUID IDs and won't match
    }
    setHasReviewed(true);
    setShowReviewForm(false);
  };

  if (!expert) return null;

  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -10 }}
      whileHover={{ y: -2 }}
      transition={{ duration: 0.2 }}
      className="group"
    >
      <div className="relative overflow-hidden rounded-2xl bg-white dark:bg-stone-900 border border-stone-200 dark:border-stone-800 hover:border-violet-300 dark:hover:border-violet-700 hover:shadow-lg transition-all duration-200">
        <div className="p-5">
          <div className="flex flex-col md:flex-row gap-4">
            {/* Expert Info */}
            <div className="flex items-start gap-4 flex-1">
              {/* Avatar with gradient ring */}
              <div className="relative shrink-0">
                <div className="absolute -inset-0.5 bg-gradient-to-br from-violet-400 to-purple-500 rounded-full opacity-60" />
                <Avatar className="relative h-14 w-14 border-2 border-white dark:border-stone-900">
                  <AvatarImage src={expert.avatar} alt={expert.name} />
                  <AvatarFallback className="text-base font-bold bg-violet-100 dark:bg-violet-900/50 text-violet-700 dark:text-violet-300">
                    {getInitials(expert.name)}
                  </AvatarFallback>
                </Avatar>
                {expert.availability === "available" && (
                  <span className="absolute -bottom-0.5 -right-0.5 h-4 w-4 bg-emerald-500 rounded-full border-2 border-white dark:border-stone-900" />
                )}
              </div>

              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 mb-1">
                  <h3 className="font-semibold text-foreground truncate">
                    {expert.name}
                  </h3>
                  {expert.verified && (
                    <BadgeCheck className="h-4 w-4 text-violet-500 shrink-0" />
                  )}
                  <span
                    className={cn(
                      "px-2 py-0.5 rounded-full text-xs font-medium",
                      statusConfig.className
                    )}
                  >
                    {statusConfig.label}
                  </span>
                </div>
                <p className="text-sm text-muted-foreground mb-3">
                  {expert.designation}
                </p>

                {/* Date & Time - Capsule style */}
                <div className="flex flex-wrap items-center gap-2">
                  <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-stone-100 dark:bg-stone-800 text-sm">
                    <Calendar className="h-3.5 w-3.5 text-stone-500" />
                    <span className="text-stone-700 dark:text-stone-300">
                      {formatBookingDate(booking.date)}
                    </span>
                  </div>
                  <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-stone-100 dark:bg-stone-800 text-sm">
                    <Clock className="h-3.5 w-3.5 text-stone-500" />
                    <span className="text-stone-700 dark:text-stone-300">
                      {booking.startTime} - {booking.endTime}
                    </span>
                  </div>
                  {booking.meetLink && (
                    <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-violet-100 dark:bg-violet-900/30 text-sm">
                      <Video className="h-3.5 w-3.5 text-violet-600 dark:text-violet-400" />
                      <span className="text-violet-700 dark:text-violet-300">
                        Video Call
                      </span>
                    </div>
                  )}
                </div>

                {/* Topic */}
                {booking.topic && (
                  <p className="text-sm text-muted-foreground mt-2 line-clamp-1">
                    <span className="font-medium">Topic:</span> {booking.topic}
                  </p>
                )}
              </div>
            </div>

            {/* Right Side - Time & Actions */}
            <div className="flex flex-col items-end justify-between shrink-0 min-w-[140px]">
              {isUpcoming && (
                <div className="text-right mb-3 p-3 rounded-xl bg-violet-50 dark:bg-violet-950/30 border border-violet-100 dark:border-violet-900/50">
                  <div className="text-xs text-violet-600 dark:text-violet-400 mb-0.5">
                    Starts in
                  </div>
                  <div className="text-xl font-bold text-violet-700 dark:text-violet-300">
                    {getTimeUntil(booking.date, booking.startTime)}
                  </div>
                </div>
              )}

              <div className="text-right mb-3">
                <div className="text-xs text-muted-foreground">Amount Paid</div>
                <div className="text-lg font-bold text-foreground">
                  {formatINR(booking.totalAmount)}
                </div>
              </div>

              {/* Actions */}
              {isUpcoming && booking.status !== "in_progress" && (
                <div className="flex items-center gap-2">
                  <Button
                    size="sm"
                    variant="outline"
                    className="gap-1.5 h-8 border-stone-200 dark:border-stone-700 hover:bg-stone-100 dark:hover:bg-stone-800"
                    onClick={onMessage}
                  >
                    <MessageCircle className="h-3.5 w-3.5" />
                    <span className="hidden sm:inline">Message</span>
                  </Button>
                  <Button
                    size="sm"
                    variant="outline"
                    className="gap-1.5 h-8 border-stone-200 dark:border-stone-700 hover:bg-stone-100 dark:hover:bg-stone-800"
                    onClick={onReschedule}
                  >
                    <RefreshCw className="h-3.5 w-3.5" />
                    <span className="hidden sm:inline">Reschedule</span>
                  </Button>
                  <Button
                    size="sm"
                    variant="outline"
                    className="gap-1.5 h-8 text-red-600 hover:text-red-700 hover:bg-red-50 dark:hover:bg-red-950/30 border-stone-200 dark:border-stone-700"
                    onClick={onCancel}
                  >
                    <Trash2 className="h-3.5 w-3.5" />
                  </Button>
                </div>
              )}

              {booking.status === "in_progress" && booking.meetLink && (
                <Button
                  size="sm"
                  className="gap-1.5 bg-violet-600 hover:bg-violet-700 text-white shadow-lg shadow-violet-500/25"
                  onClick={onJoin}
                >
                  <Video className="h-3.5 w-3.5" />
                  Join Now
                  <ArrowRight className="h-3.5 w-3.5" />
                </Button>
              )}

              {isCompleted && !hasReviewed && !showReviewForm && (
                <Button
                  size="sm"
                  className="gap-1.5 bg-amber-500 hover:bg-amber-600 text-white shadow-md shadow-amber-500/25"
                  onClick={() => setShowReviewForm(true)}
                >
                  <Star className="h-3.5 w-3.5" />
                  Rate Session
                </Button>
              )}

              {isCompleted && hasReviewed && (
                <div className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-amber-50 dark:bg-amber-950/30 border border-amber-200 dark:border-amber-800">
                  <Star className="h-3.5 w-3.5 fill-amber-400 text-amber-400" />
                  <span className="text-xs font-medium text-amber-700 dark:text-amber-300">Reviewed</span>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Inline review form */}
        {showReviewForm && (
          <div className="px-5 pb-5 pt-0">
            <div className="border-t border-stone-200 dark:border-stone-800 pt-4">
              <ReviewForm
                expertId={booking.expertId}
                expertName={expert.name}
                bookingId={booking.id}
                onSubmit={handleReviewSubmit}
                onCancel={() => setShowReviewForm(false)}
              />
            </div>
          </div>
        )}
      </div>
    </motion.div>
  );
}

/**
 * Empty state component - Clean design
 */
function EmptyState({ tab }: { tab: BookingTab }) {
  const config = {
    upcoming: {
      icon: CalendarClock,
      emoji: "📅",
      title: "No upcoming bookings",
      description: "Book a consultation with an expert to get started",
    },
    completed: {
      icon: CheckCircle2,
      emoji: "✅",
      title: "No completed sessions",
      description: "Your completed consultations will appear here",
    },
    cancelled: {
      icon: XCircle,
      emoji: "❌",
      title: "No cancelled bookings",
      description: "Any cancelled sessions will appear here",
    },
  };

  const { emoji, title, description } = config[tab];

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="flex flex-col items-center justify-center py-20 text-center"
    >
      <div className="text-5xl mb-4">{emoji}</div>
      <h3 className="text-lg font-semibold mb-2">{title}</h3>
      <p className="text-sm text-muted-foreground max-w-xs">{description}</p>
    </motion.div>
  );
}

/**
 * MyBookings component - Clean modern design
 */
export function MyBookings({
  bookings,
  onMessage,
  onReschedule,
  onCancel,
  onJoin,
  className,
}: MyBookingsProps) {
  const [activeTab, setActiveTab] = useState<BookingTab>("upcoming");

  /**
   * Filter bookings by tab
   */
  const filteredBookings = useMemo(() => {
    const tab = TABS.find((t) => t.id === activeTab);
    if (!tab) return [];
    return bookings.filter((b) => tab.statuses.includes(b.status));
  }, [bookings, activeTab]);

  /**
   * Count bookings per tab
   */
  const tabCounts = useMemo(() => {
    return TABS.reduce(
      (acc, tab) => {
        acc[tab.id] = bookings.filter((b) =>
          tab.statuses.includes(b.status)
        ).length;
        return acc;
      },
      {} as Record<BookingTab, number>
    );
  }, [bookings]);

  return (
    <div className={cn("space-y-6", className)}>
      {/* Capsule Tabs - Horizontal scroll */}
      <div className="flex justify-center">
        <div className="flex gap-2 p-1">
          {TABS.map((tab) => {
            const isActive = activeTab === tab.id;
            const count = tabCounts[tab.id];

            return (
              <motion.button
                key={tab.id}
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                onClick={() => setActiveTab(tab.id)}
                className={cn(
                  "flex items-center gap-2 px-5 py-2.5 rounded-full text-sm font-medium transition-all duration-200",
                  isActive
                    ? "bg-violet-600 text-white shadow-md shadow-violet-500/25"
                    : "bg-white dark:bg-stone-900 text-stone-600 dark:text-stone-300 border border-stone-200 dark:border-stone-800 hover:border-violet-300 dark:hover:border-violet-700 hover:bg-violet-50 dark:hover:bg-violet-950/30"
                )}
              >
                <span>{tab.emoji}</span>
                <span>{tab.label}</span>
                {count > 0 && (
                  <span
                    className={cn(
                      "min-w-[20px] h-5 px-1.5 rounded-full text-xs font-bold flex items-center justify-center",
                      isActive
                        ? "bg-white/20 text-white"
                        : "bg-stone-200 dark:bg-stone-700 text-stone-600 dark:text-stone-300"
                    )}
                  >
                    {count}
                  </span>
                )}
              </motion.button>
            );
          })}
        </div>
      </div>

      {/* Bookings List */}
      <AnimatePresence mode="wait">
        {filteredBookings.length === 0 ? (
          <EmptyState tab={activeTab} />
        ) : (
          <motion.div
            key={activeTab}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            className="space-y-4"
          >
            {filteredBookings.map((booking) => (
              <BookingCard
                key={booking.id}
                booking={booking}
                onMessage={() => onMessage?.(booking.id)}
                onReschedule={() => onReschedule?.(booking.id)}
                onCancel={() => onCancel?.(booking.id)}
                onJoin={() => onJoin?.(booking.id)}
              />
            ))}
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

export default MyBookings;
