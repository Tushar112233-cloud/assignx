/**
 * @fileoverview Component displaying doer reviews and ratings history.
 * @module components/dashboard/doer-reviews
 */

"use client"

import { useState, useEffect, useCallback } from "react"
import { format } from "date-fns"
import {
  Star,
  ThumbsUp,
  MessageCircle,
  TrendingUp,
  ExternalLink,
  Loader2,
} from "lucide-react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Progress } from "@/components/ui/progress"
import { ScrollArea } from "@/components/ui/scroll-area"
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet"
import { cn } from "@/lib/utils"
import { createClient } from "@/lib/supabase/client"
import type { Doer } from "./assign-doer-modal"

interface Review {
  id: string
  project_id: string
  project_title: string
  reviewer_name: string
  reviewer_type: "user" | "supervisor"
  rating: number
  comment: string
  created_at: string
  helpful_count: number
  tags: string[]
}

interface DoerReviewsProps {
  doer: Doer
  onViewProfile?: (doerId: string) => void
}

export function DoerReviews({ doer, onViewProfile }: DoerReviewsProps) {
  const [reviews, setReviews] = useState<Review[]>([])
  const [isLoading, setIsLoading] = useState(false)
  const [isOpen, setIsOpen] = useState(false)

  // Fetch reviews from Supabase
  const fetchReviews = useCallback(async () => {
    if (!doer.id) return

    setIsLoading(true)
    try {
      const supabase = createClient()
      const { data, error } = await supabase
        .from("doer_reviews")
        .select(`
          id,
          overall_rating,
          review_text,
          reviewer_type,
          created_at,
          project_id,
          projects (
            project_number,
            title
          ),
          profiles:reviewer_id (
            full_name
          )
        `)
        .eq("doer_id", doer.id)
        .eq("is_public", true)
        .order("created_at", { ascending: false })
        .limit(20)

      if (error) throw error

      // Transform data to Review interface
      const formattedReviews: Review[] = (data || []).map((review) => {
        const project = review.projects as { project_number?: string; title?: string } | null
        const reviewer = review.profiles as { full_name?: string } | null

        return {
          id: review.id,
          project_id: review.project_id || "",
          project_title: project?.title || project?.project_number || "Project",
          reviewer_name: reviewer?.full_name || (review.reviewer_type === "supervisor" ? "Supervisor" : "Client"),
          reviewer_type: review.reviewer_type === "supervisor" ? "supervisor" : "user",
          rating: review.overall_rating || 0,
          comment: review.review_text || "",
          created_at: review.created_at || new Date().toISOString(),
          helpful_count: 0,
          tags: [],
        }
      })

      setReviews(formattedReviews)
    } catch (error) {
      console.error("Error fetching reviews:", error)
      setReviews([])
    } finally {
      setIsLoading(false)
    }
  }, [doer.id])

  // Fetch reviews when sheet opens
  useEffect(() => {
    if (isOpen) {
      fetchReviews()
    }
  }, [isOpen, fetchReviews])

  // Calculate rating distribution
  const ratingDistribution = [5, 4, 3, 2, 1].map((rating) => ({
    rating,
    count: reviews.filter((r) => r.rating === rating).length,
    percentage: (reviews.filter((r) => r.rating === rating).length / reviews.length) * 100,
  }))

  const renderStars = (rating: number) => {
    return (
      <div className="flex items-center gap-0.5">
        {[1, 2, 3, 4, 5].map((star) => (
          <Star
            key={star}
            className={cn(
              "h-4 w-4",
              star <= rating
                ? "fill-yellow-400 text-yellow-400"
                : "text-gray-300"
            )}
          />
        ))}
      </div>
    )
  }

  return (
    <Sheet open={isOpen} onOpenChange={setIsOpen}>
      <SheetTrigger asChild>
        <Button variant="ghost" size="sm" className="gap-1.5">
          <Star className="h-4 w-4 fill-yellow-400 text-yellow-400" />
          <span>{doer.rating}</span>
          <span className="text-muted-foreground">
            ({isLoading ? "..." : reviews.length} reviews)
          </span>
          <ExternalLink className="h-3 w-3 ml-1" />
        </Button>
      </SheetTrigger>
      <SheetContent className="w-[400px] sm:w-[540px]">
        <SheetHeader>
          <SheetTitle className="flex items-center gap-3">
            <Avatar className="h-10 w-10">
              <AvatarImage src={doer.avatar_url || undefined} />
              <AvatarFallback>
                {doer.full_name
                  .split(" ")
                  .map((n) => n[0])
                  .join("")
                  .toUpperCase()}
              </AvatarFallback>
            </Avatar>
            <div>
              <span>{doer.full_name}</span>
              <div className="flex items-center gap-1 text-sm font-normal text-muted-foreground">
                {renderStars(Math.round(doer.rating))}
                <span className="ml-1">{doer.rating} out of 5</span>
              </div>
            </div>
          </SheetTitle>
          <SheetDescription>
            {doer.total_projects} projects completed with {doer.success_rate}%
            success rate
          </SheetDescription>
        </SheetHeader>

        <ScrollArea className="h-[calc(100vh-180px)] pr-4 mt-6">
          <div className="space-y-6">
            {/* Rating Summary */}
            <Card>
              <CardHeader className="pb-3">
                <CardTitle className="text-sm font-medium">
                  Rating Breakdown
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-2">
                {ratingDistribution.map(({ rating, count, percentage }) => (
                  <div key={rating} className="flex items-center gap-3">
                    <span className="w-12 text-sm text-muted-foreground">
                      {rating} star
                    </span>
                    <Progress value={percentage} className="h-2 flex-1" />
                    <span className="w-8 text-sm text-muted-foreground">
                      {count}
                    </span>
                  </div>
                ))}
              </CardContent>
            </Card>

            {/* Performance Stats */}
            <Card>
              <CardHeader className="pb-3">
                <CardTitle className="text-sm font-medium">
                  Performance Stats
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-2 gap-4">
                  <div className="text-center p-3 rounded-lg bg-muted/50">
                    <div className="flex items-center justify-center gap-1 text-green-600">
                      <TrendingUp className="h-4 w-4" />
                      <span className="text-2xl font-bold">
                        {doer.success_rate}%
                      </span>
                    </div>
                    <p className="text-xs text-muted-foreground mt-1">
                      Success Rate
                    </p>
                  </div>
                  <div className="text-center p-3 rounded-lg bg-muted/50">
                    <div className="flex items-center justify-center gap-1 text-primary">
                      <MessageCircle className="h-4 w-4" />
                      <span className="text-2xl font-bold">
                        ~{doer.response_time_hours}h
                      </span>
                    </div>
                    <p className="text-xs text-muted-foreground mt-1">
                      Avg Response
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Reviews List */}
            <div className="space-y-4">
              <h3 className="text-sm font-medium">Recent Reviews</h3>
              {isLoading ? (
                <div className="flex items-center justify-center py-8">
                  <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
                </div>
              ) : reviews.length === 0 ? (
                <div className="text-center py-8 text-muted-foreground">
                  <MessageCircle className="h-8 w-8 mx-auto mb-2 opacity-50" />
                  <p className="text-sm">No reviews yet</p>
                </div>
              ) : (
                reviews.map((review) => (
                  <Card key={review.id}>
                    <CardContent className="p-4">
                      <div className="flex items-start justify-between mb-2">
                        <div>
                          <div className="flex items-center gap-2">
                            {renderStars(review.rating)}
                            <Badge
                              variant={
                                review.reviewer_type === "supervisor"
                                  ? "default"
                                  : "outline"
                              }
                              className="text-xs"
                            >
                              {review.reviewer_type === "supervisor"
                                ? "Supervisor"
                                : "Client"}
                            </Badge>
                          </div>
                          <p className="text-sm text-muted-foreground mt-1">
                            {review.reviewer_name} •{" "}
                            {format(new Date(review.created_at), "MMM d, yyyy")}
                          </p>
                        </div>
                      </div>

                      <p className="text-sm mb-3">{review.comment}</p>

                      {review.tags.length > 0 && (
                        <div className="flex flex-wrap gap-1.5 mb-3">
                          {review.tags.map((tag) => (
                            <Badge
                              key={tag}
                              variant="secondary"
                              className="text-xs"
                            >
                              {tag}
                            </Badge>
                          ))}
                        </div>
                      )}

                      <div className="flex items-center gap-4 text-xs text-muted-foreground">
                        <button className="flex items-center gap-1 hover:text-foreground transition-colors">
                          <ThumbsUp className="h-3.5 w-3.5" />
                          <span>Helpful ({review.helpful_count})</span>
                        </button>
                        <span className="text-xs">{review.project_title}</span>
                      </div>
                    </CardContent>
                  </Card>
                ))
              )}
            </div>

            {/* View Full Profile Button */}
            {onViewProfile && (
              <Button
                variant="outline"
                className="w-full"
                onClick={() => onViewProfile(doer.id)}
              >
                View Full Profile
                <ExternalLink className="h-4 w-4 ml-2" />
              </Button>
            )}
          </div>
        </ScrollArea>
      </SheetContent>
    </Sheet>
  )
}

// Compact version for use in cards
export function DoerReviewsBadge({ doer }: { doer: Doer }) {
  return (
    <DoerReviews doer={doer} />
  )
}
