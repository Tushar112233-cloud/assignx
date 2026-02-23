/**
 * @fileoverview Component displaying supervisor reviews received from users.
 * @module components/profile/my-reviews
 */

"use client"

import { useState } from "react"
import {
  Star,
  MessageSquare,
  Clock,
  ChevronDown,
  ChevronUp,
  ThumbsUp,
  Filter,
} from "lucide-react"
import { formatDistanceToNow } from "date-fns"

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Progress } from "@/components/ui/progress"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Textarea } from "@/components/ui/textarea"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { ScrollArea } from "@/components/ui/scroll-area"
import { cn } from "@/lib/utils"
import { SupervisorReview, ReviewStats } from "./types"

const DEFAULT_REVIEW_STATS: ReviewStats = {
  average_rating: 0,
  total_reviews: 0,
  rating_distribution: { 5: 0, 4: 0, 3: 0, 2: 0, 1: 0 },
  recent_reviews: [],
}

interface ReviewCardProps {
  review: SupervisorReview
  onRespond?: (reviewId: string, response: string) => void
}

function ReviewCard({ review, onRespond }: ReviewCardProps) {
  const [showResponse, setShowResponse] = useState(false)
  const [responseText, setResponseText] = useState("")
  const [isSubmitting, setIsSubmitting] = useState(false)

  const handleSubmitResponse = async () => {
    if (!responseText.trim()) return
    setIsSubmitting(true)
    await new Promise((resolve) => setTimeout(resolve, 500))
    onRespond?.(review.id, responseText)
    setShowResponse(false)
    setResponseText("")
    setIsSubmitting(false)
  }

  return (
    <Card className="rounded-2xl border border-gray-200 bg-white shadow-sm">
      <CardContent className="pt-6">
        <div className="flex gap-4">
          <Avatar className="h-10 w-10">
            <AvatarImage src={review.client_avatar} alt={review.client_name} />
            <AvatarFallback>
              {review.client_name
                .split(" ")
                .map((n) => n[0])
                .join("")}
            </AvatarFallback>
          </Avatar>
          <div className="flex-1 min-w-0">
            <div className="flex items-start justify-between gap-2">
              <div>
                <p className="font-medium">{review.client_name}</p>
                <p className="text-xs text-gray-500">
                  {review.project_title} ({review.project_id})
                </p>
              </div>
              <div className="flex items-center gap-1 shrink-0">
                {Array.from({ length: 5 }).map((_, i) => (
                  <Star
                    key={i}
                    className={cn(
                      "h-4 w-4",
                      i < review.rating
                        ? "fill-amber-400 text-amber-400"
                        : "text-gray-300"
                    )}
                  />
                ))}
              </div>
            </div>

            <p className="mt-2 text-sm text-gray-500">{review.comment}</p>

            <div className="flex items-center gap-4 mt-3 text-xs text-gray-500">
              <span className="flex items-center gap-1">
                <Clock className="h-3 w-3" />
                {formatDistanceToNow(new Date(review.created_at), { addSuffix: true })}
              </span>
              {!review.response && (
                <Button
                  variant="ghost"
                  size="sm"
                  className="h-auto py-1 px-2 text-xs"
                  onClick={() => setShowResponse(!showResponse)}
                >
                  <MessageSquare className="h-3 w-3 mr-1" />
                  Respond
                </Button>
              )}
            </div>

            {/* Existing Response */}
            {review.response && (
              <div className="mt-4 p-3 bg-orange-50/50 rounded-xl border-l-2 border-orange-200">
                <div className="flex items-center gap-2 text-xs text-gray-500 mb-1">
                  <ThumbsUp className="h-3 w-3" />
                  <span>Your Response</span>
                  {review.responded_at && (
                    <span>
                      {formatDistanceToNow(new Date(review.responded_at), {
                        addSuffix: true,
                      })}
                    </span>
                  )}
                </div>
                <p className="text-sm">{review.response}</p>
              </div>
            )}

            {/* Response Form */}
            {showResponse && !review.response && (
              <div className="mt-4 space-y-2">
                <Textarea
                  placeholder="Write your response..."
                  value={responseText}
                  onChange={(e) => setResponseText(e.target.value)}
                  rows={3}
                />
                <div className="flex justify-end gap-2">
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => setShowResponse(false)}
                  >
                    Cancel
                  </Button>
                  <Button
                    size="sm"
                    onClick={handleSubmitResponse}
                    disabled={!responseText.trim() || isSubmitting}
                  >
                    {isSubmitting ? "Submitting..." : "Submit Response"}
                  </Button>
                </div>
              </div>
            )}
          </div>
        </div>
      </CardContent>
    </Card>
  )
}

export function MyReviews() {
  const [reviews, setReviews] = useState<SupervisorReview[]>([])
  const [filterRating, setFilterRating] = useState<string>("all")
  const stats = DEFAULT_REVIEW_STATS

  const filteredReviews =
    filterRating === "all"
      ? reviews
      : reviews.filter((r) => r.rating === parseInt(filterRating))

  const handleRespond = (reviewId: string, response: string) => {
    setReviews((prev) =>
      prev.map((r) =>
        r.id === reviewId
          ? { ...r, response, responded_at: new Date().toISOString() }
          : r
      )
    )
  }

  const totalRatings = Object.values(stats.rating_distribution).reduce((a, b) => a + b, 0)

  return (
    <div className="space-y-6">
      {/* Rating Overview */}
    <Card className="rounded-2xl border border-gray-200 bg-white shadow-sm">
      <CardHeader>
        <CardTitle className="text-lg font-semibold text-[#1C1C1C]">Rating Overview</CardTitle>
        <CardDescription className="text-sm text-gray-500">
          Your overall rating from clients
        </CardDescription>
      </CardHeader>
      <CardContent>
        <div className="flex flex-col md:flex-row gap-6">
          {/* Average Rating */}
          <div className="flex flex-col items-center justify-center p-4 bg-orange-50/60 border border-orange-100 rounded-2xl min-w-[140px]">
            <p className="text-4xl font-semibold text-[#1C1C1C]">{stats.average_rating}</p>
              <div className="flex items-center gap-1 mt-1">
                {Array.from({ length: 5 }).map((_, i) => (
                  <Star
                    key={i}
                    className={cn(
                      "h-4 w-4",
                      i < Math.round(stats.average_rating)
                        ? "fill-amber-400 text-amber-400"
                        : "text-gray-300"
                    )}
                  />
                ))}
              </div>
            <p className="text-sm text-gray-500 mt-1">
              {stats.total_reviews} reviews
            </p>
          </div>

            {/* Rating Distribution */}
            <div className="flex-1 space-y-2">
              {[5, 4, 3, 2, 1].map((rating) => {
                const count = stats.rating_distribution[rating as keyof typeof stats.rating_distribution]
                const percentage = totalRatings > 0 ? (count / totalRatings) * 100 : 0
                return (
                  <div key={rating} className="flex items-center gap-3">
                    <div className="flex items-center gap-1 w-12">
                      <span className="text-sm font-medium">{rating}</span>
                      <Star className="h-3 w-3 fill-amber-400 text-amber-400" />
                    </div>
                    <Progress value={percentage} className="flex-1 h-2" />
                    <span className="text-sm text-gray-500 w-8 text-right">
                      {count}
                    </span>
                  </div>
                )
              })}
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Filters */}
      <div className="flex items-center justify-between">
        <h3 className="text-lg font-semibold text-[#1C1C1C]">Client Reviews</h3>
        <Select value={filterRating} onValueChange={setFilterRating}>
          <SelectTrigger className="w-[160px]">
            <Filter className="h-4 w-4 mr-2" />
            <SelectValue placeholder="Filter by rating" />
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
      </div>

      {/* Reviews List */}
      <ScrollArea className="h-[calc(100vh-28rem)]">
        <div className="space-y-4 pr-4">
          {filteredReviews.length > 0 ? (
            filteredReviews.map((review) => (
              <ReviewCard key={review.id} review={review} onRespond={handleRespond} />
            ))
          ) : (
            <div className="flex flex-col items-center justify-center py-12 text-center">
              <Star className="h-12 w-12 text-gray-300 mb-4" />
              <h3 className="text-lg font-medium">No reviews found</h3>
              <p className="text-sm text-gray-500 mt-1">
                {filterRating !== "all"
                  ? "Try changing your filter"
                  : "Reviews from clients will appear here"}
              </p>
            </div>
          )}
        </div>
      </ScrollArea>
    </div>
  )
}
