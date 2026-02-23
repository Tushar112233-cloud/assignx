"use client"

import { memo } from "react"
import Image from "next/image"
import Link from "next/link"
import { motion } from "framer-motion"
import { Calendar, Heart, MapPin, Briefcase, CalendarDays } from "lucide-react"
import { cn } from "@/lib/utils"
import type { ListingDisplay } from "./masonry-grid"

interface BannerCardProps {
  listing: ListingDisplay
  onFavorite?: (listingId: string) => void
  className?: string
}

/**
 * BannerCard - Minimalist card for opportunities and featured items
 */
export const BannerCard = memo(function BannerCard({
  listing,
  onFavorite,
  className
}: BannerCardProps) {
  const isOpportunity = listing.listing_type === "opportunity"

  const handleFavorite = (e: React.MouseEvent) => {
    e.preventDefault()
    e.stopPropagation()
    onFavorite?.(listing.id)
  }

  const formatDate = (dateStr: string) => {
    const date = new Date(dateStr)
    return date.toLocaleDateString("en-IN", { month: "short", day: "numeric" })
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
        {/* Image Section */}
        <div className="relative aspect-[16/9] overflow-hidden bg-muted">
          {listing.image_url ? (
            <motion.div
              className="relative w-full h-full"
              whileHover={{ scale: 1.05 }}
              transition={{ duration: 0.3 }}
            >
              <Image
                src={listing.image_url}
                alt={listing.title}
                fill
                className="object-cover"
                sizes="(max-width: 640px) 100vw, 50vw"
              />
            </motion.div>
          ) : (
            <div className="flex h-full w-full items-center justify-center">
              {isOpportunity ? (
                <Briefcase className="h-12 w-12 text-muted-foreground/50" strokeWidth={1.5} />
              ) : (
                <CalendarDays className="h-12 w-12 text-muted-foreground/50" strokeWidth={1.5} />
              )}
            </div>
          )}

          {/* Favorite Button */}
          <motion.button
            onClick={handleFavorite}
            whileTap={{ scale: 0.9 }}
            className={cn(
              "absolute top-2 right-2 p-2 rounded-lg",
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
        <div className="p-3 space-y-2">
          {/* Title */}
          <h3 className="text-sm font-medium text-foreground line-clamp-2">
            {listing.title}
          </h3>

          {/* Description */}
          {listing.description && (
            <p className="text-xs text-muted-foreground line-clamp-2">
              {listing.description}
            </p>
          )}

          {/* Meta row */}
          <div className="flex items-center justify-between gap-2 pt-2 border-t border-border">
            <div className="flex items-center gap-3 text-xs text-muted-foreground">
              {listing.city && (
                <span className="flex items-center gap-1">
                  <MapPin className="h-3 w-3 shrink-0" />
                  <span className="truncate max-w-[80px]">{listing.city}</span>
                </span>
              )}
              {listing.created_at && (
                <span className="flex items-center gap-1">
                  <Calendar className="h-3 w-3 shrink-0" />
                  {formatDate(listing.created_at)}
                </span>
              )}
            </div>

            {/* Category badge */}
            <span className={cn(
              "px-1.5 py-0.5 rounded text-[10px] font-medium bg-muted",
              isOpportunity
                ? "text-purple-600 dark:text-purple-400"
                : "text-primary"
            )}>
              {isOpportunity ? "Opportunity" : "Featured"}
            </span>
          </div>
        </div>
      </motion.article>
    </Link>
  )
})
