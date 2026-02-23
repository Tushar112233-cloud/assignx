"use client"

import { useState } from "react"
import { motion, AnimatePresence } from "framer-motion"
import { Filter, Search } from "lucide-react"
import { ReviewCard, type Review } from "./ReviewCard"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { cn } from "@/lib/utils"

/**
 * Props for ReviewsListSection component
 */
interface ReviewsListSectionProps {
  /**
   * All reviews to display
   */
  reviews: Review[]
  /**
   * Optional click handler for individual reviews
   */
  onReviewClick?: (review: Review) => void
  /**
   * Additional CSS classes
   */
  className?: string
}

/**
 * ReviewsListSection Component
 *
 * A comprehensive tabbed reviews list with filtering and search capabilities.
 * Features multiple view modes and advanced filtering options.
 *
 * Features:
 * - Tabbed views: All, Recent (last 30 days), Top Rated (5 stars)
 * - Search by project name or review content
 * - Filter by rating (1-5 stars)
 * - Sort by date or rating
 * - Smooth animations and transitions
 * - Empty state handling
 * - Responsive layout
 *
 * @example
 * ```tsx
 * <ReviewsListSection
 *   reviews={allReviews}
 *   onReviewClick={(review) => console.log('Clicked:', review.id)}
 * />
 * ```
 */
export function ReviewsListSection({
  reviews,
  onReviewClick,
  className,
}: ReviewsListSectionProps) {
  const [searchQuery, setSearchQuery] = useState("")
  const [ratingFilter, setRatingFilter] = useState<string>("all")
  const [sortBy, setSortBy] = useState<"date" | "rating">("date")

  // Calculate review categories
  const thirtyDaysAgo = new Date()
  thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30)

  const recentReviews = reviews.filter(
    (review) => new Date(review.created_at) >= thirtyDaysAgo
  )

  const topRatedReviews = reviews.filter((review) => review.overall_rating === 5)

  /**
   * Filter and sort reviews based on current filters
   */
  const getFilteredReviews = (reviewList: Review[]) => {
    let filtered = [...reviewList]

    // Search filter
    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase()
      filtered = filtered.filter(
        (review) =>
          review.project?.title?.toLowerCase().includes(query) ||
          review.review_text?.toLowerCase().includes(query) ||
          review.reviewer?.full_name?.toLowerCase().includes(query)
      )
    }

    // Rating filter
    if (ratingFilter !== "all") {
      const rating = parseInt(ratingFilter)
      filtered = filtered.filter((review) => review.overall_rating === rating)
    }

    // Sort
    filtered.sort((a, b) => {
      if (sortBy === "date") {
        return new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
      } else {
        return b.overall_rating - a.overall_rating
      }
    })

    return filtered
  }

  const filteredAllReviews = getFilteredReviews(reviews)
  const filteredRecentReviews = getFilteredReviews(recentReviews)
  const filteredTopRatedReviews = getFilteredReviews(topRatedReviews)

  /**
   * Render review list with animations
   */
  const renderReviewList = (reviewList: Review[], emptyMessage: string) => {
    if (reviewList.length === 0) {
      return (
        <div className="flex flex-col items-center justify-center py-12 text-center">
          <div className="w-16 h-16 rounded-full bg-slate-100 flex items-center justify-center mb-4">
            <Filter className="w-8 h-8 text-slate-400" />
          </div>
          <p className="text-sm font-medium text-slate-600 mb-1">{emptyMessage}</p>
          <p className="text-xs text-slate-500">
            {searchQuery || ratingFilter !== "all"
              ? "Try adjusting your filters"
              : "Reviews will appear here as you complete projects"}
          </p>
        </div>
      )
    }

    return (
      <motion.div
        className="space-y-4"
        initial="hidden"
        animate="visible"
        variants={{
          hidden: { opacity: 0 },
          visible: {
            opacity: 1,
            transition: {
              staggerChildren: 0.05,
            },
          },
        }}
      >
        {reviewList.map((review) => (
          <motion.div
            key={review.id}
            variants={{
              hidden: { opacity: 0, y: 20 },
              visible: { opacity: 1, y: 0 },
            }}
          >
            <ReviewCard
              review={review}
              variant="full"
              onClick={() => onReviewClick?.(review)}
            />
          </motion.div>
        ))}
      </motion.div>
    )
  }

  return (
    <div
      className={cn(
        "bg-white/85 rounded-2xl border border-white/70 shadow-[0_16px_35px_rgba(30,58,138,0.08)] p-6",
        className
      )}
    >
      {/* Header */}
      <div className="mb-6">
        <h2 className="text-2xl font-bold text-slate-900 mb-2">All Reviews</h2>
        <p className="text-sm text-slate-500">
          Feedback from supervisors on your completed projects
        </p>
      </div>

      {/* Filter Controls */}
      <div className="flex flex-col sm:flex-row gap-3 mb-6">
        {/* Search */}
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <Input
            type="text"
            placeholder="Search reviews, projects, or supervisors..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pl-10 bg-white border-slate-200 focus:border-[#5A7CFF] focus:ring-[#5A7CFF]"
          />
        </div>

        {/* Rating Filter */}
        <Select value={ratingFilter} onValueChange={setRatingFilter}>
          <SelectTrigger className="w-full sm:w-40 bg-white border-slate-200">
            <Filter className="w-4 h-4 mr-2" />
            <SelectValue placeholder="All Ratings" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Ratings</SelectItem>
            <SelectItem value="5">5 Stars</SelectItem>
            <SelectItem value="4">4 Stars</SelectItem>
            <SelectItem value="3">3 Stars</SelectItem>
            <SelectItem value="2">2 Stars</SelectItem>
            <SelectItem value="1">1 Star</SelectItem>
          </SelectContent>
        </Select>

        {/* Sort */}
        <Select value={sortBy} onValueChange={(v) => setSortBy(v as "date" | "rating")}>
          <SelectTrigger className="w-full sm:w-40 bg-white border-slate-200">
            <SelectValue placeholder="Sort by" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="date">Most Recent</SelectItem>
            <SelectItem value="rating">Highest Rated</SelectItem>
          </SelectContent>
        </Select>
      </div>

      {/* Tabbed Reviews */}
      <Tabs defaultValue="all" className="w-full">
        <TabsList className="grid w-full max-w-md grid-cols-3 h-11 rounded-full bg-slate-100 p-1">
          <TabsTrigger
            value="all"
            className="rounded-full text-sm data-[state=active]:bg-white data-[state=active]:shadow-sm"
          >
            All ({filteredAllReviews.length})
          </TabsTrigger>
          <TabsTrigger
            value="recent"
            className="rounded-full text-sm data-[state=active]:bg-white data-[state=active]:shadow-sm"
          >
            Recent ({filteredRecentReviews.length})
          </TabsTrigger>
          <TabsTrigger
            value="top"
            className="rounded-full text-sm data-[state=active]:bg-white data-[state=active]:shadow-sm"
          >
            Top Rated ({filteredTopRatedReviews.length})
          </TabsTrigger>
        </TabsList>

        <TabsContent value="all" className="mt-6">
          {renderReviewList(filteredAllReviews, "No reviews yet")}
        </TabsContent>

        <TabsContent value="recent" className="mt-6">
          {renderReviewList(filteredRecentReviews, "No reviews in the last 30 days")}
        </TabsContent>

        <TabsContent value="top" className="mt-6">
          {renderReviewList(filteredTopRatedReviews, "No 5-star reviews yet")}
        </TabsContent>
      </Tabs>
    </div>
  )
}
