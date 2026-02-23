"use client"

import { memo } from "react"
import Link from "next/link"
import { motion } from "framer-motion"
import { Heart, User, Users } from "lucide-react"
import { cn } from "@/lib/utils"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import type { ListingDisplay } from "./masonry-grid"

interface TextCardProps {
  listing: ListingDisplay
  onFavorite?: (listingId: string) => void
  className?: string
}

/**
 * TextCard - Minimalist card for community posts
 */
export const TextCard = memo(function TextCard({
  listing,
  onFavorite,
  className
}: TextCardProps) {
  const handleFavorite = (e: React.MouseEvent) => {
    e.preventDefault()
    e.stopPropagation()
    onFavorite?.(listing.id)
  }

  const getTimeAgo = (dateStr: string) => {
    const date = new Date(dateStr)
    const now = new Date()
    const diffMs = now.getTime() - date.getTime()
    const diffHours = Math.floor(diffMs / (1000 * 60 * 60))
    const diffDays = Math.floor(diffHours / 24)

    if (diffDays > 0) return `${diffDays}d ago`
    if (diffHours > 0) return `${diffHours}h ago`
    return "Just now"
  }

  return (
    <Link href={`/marketplace/${listing.id}`} className="block group">
      <motion.article
        whileHover={{ y: -2, scale: 1.01 }}
        transition={{ duration: 0.2 }}
        className={cn(
          "rounded-xl overflow-hidden border border-border bg-card",
          "hover:border-foreground/20 transition-colors",
          className
        )}
      >
        {/* Header with icon placeholder */}
        <div className="relative h-20 bg-muted flex items-center justify-center">
          <Users className="h-8 w-8 text-muted-foreground/50" strokeWidth={1.5} />

          {/* Favorite Button */}
          <motion.button
            onClick={handleFavorite}
            whileTap={{ scale: 0.9 }}
            className={cn(
              "absolute right-2 top-2 p-2 rounded-lg",
              "bg-background/90 border border-border",
              "opacity-0 group-hover:opacity-100 transition-opacity",
              listing.is_favorited && "opacity-100"
            )}
          >
            <motion.div
              animate={listing.is_favorited ? { scale: [1, 1.3, 1] } : {}}
              transition={{ duration: 0.3 }}
            >
              <Heart
                className={cn(
                  "h-3.5 w-3.5",
                  listing.is_favorited
                    ? "fill-red-500 text-red-500"
                    : "text-muted-foreground"
                )}
              />
            </motion.div>
          </motion.button>

        </div>

        {/* Content */}
        <div className="p-3">
          {/* Title */}
          <h3 className="text-sm font-medium text-foreground line-clamp-2">
            {listing.title}
          </h3>

          {/* Description */}
          {listing.description && (
            <p className="text-xs text-muted-foreground line-clamp-2 mt-1">
              {listing.description}
            </p>
          )}

          {/* Footer */}
          <div className="flex items-center justify-between mt-3 pt-2 border-t border-border">
            {/* Author */}
            <div className="flex items-center gap-2 min-w-0">
              <Avatar className="h-5 w-5">
                <AvatarImage src={listing.seller?.avatar_url || ""} />
                <AvatarFallback className="text-[10px]">
                  <User className="h-2.5 w-2.5" />
                </AvatarFallback>
              </Avatar>
              <span className="text-xs text-muted-foreground truncate max-w-[80px]">
                {listing.seller?.full_name || "Anonymous"}
              </span>
            </div>

            {/* Category badge */}
            <span className="px-1.5 py-0.5 rounded text-[10px] font-medium bg-muted text-amber-600 dark:text-amber-400">
              Community
            </span>
          </div>
        </div>
      </motion.article>
    </Link>
  )
})
