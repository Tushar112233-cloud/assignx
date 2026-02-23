"use client"

import { memo } from "react"
import Image from "next/image"
import Link from "next/link"
import { motion } from "framer-motion"
import { Heart, MapPin, Package, Home, Briefcase, Users, Eye } from "lucide-react"
import { cn } from "@/lib/utils"
import type { ListingDisplay } from "./masonry-grid"

interface ItemCardProps {
  listing: ListingDisplay
  onFavorite?: (listingId: string) => void
  className?: string
}

/**
 * Get listing type config for icon and badge
 */
function getListingConfig(type: string) {
  switch (type) {
    case "sell":
      return { icon: Package, badge: "Product", color: "text-blue-600 dark:text-blue-400" }
    case "housing":
      return { icon: Home, badge: "Housing", color: "text-emerald-600 dark:text-emerald-400" }
    case "opportunity":
      return { icon: Briefcase, badge: "Opportunity", color: "text-purple-600 dark:text-purple-400" }
    default:
      return { icon: Users, badge: "Community", color: "text-amber-600 dark:text-amber-400" }
  }
}

/**
 * ItemCard - Minimalist marketplace card
 */
export const ItemCard = memo(function ItemCard({
  listing,
  onFavorite,
  className
}: ItemCardProps) {
  const handleFavorite = (e: React.MouseEvent) => {
    e.preventDefault()
    e.stopPropagation()
    onFavorite?.(listing.id)
  }

  const config = getListingConfig(listing.listing_type)
  const Icon = config.icon

  const priceDisplay = listing.price === 0
    ? "Free"
    : listing.price
      ? `₹${listing.price.toLocaleString()}`
      : null

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
        {/* Image Container */}
        <div className="relative aspect-[4/3] overflow-hidden bg-muted">
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
                sizes="(max-width: 640px) 50vw, (max-width: 1024px) 33vw, 25vw"
              />
            </motion.div>
          ) : (
            <div className="flex h-full w-full items-center justify-center">
              <Icon className="h-10 w-10 text-muted-foreground/50" strokeWidth={1.5} />
            </div>
          )}

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

          {/* Price Tag */}
          {priceDisplay && (
            <div className={cn(
              "absolute bottom-2 left-2",
              "px-2 py-1 rounded-lg",
              "bg-background/90 border border-border",
              "text-xs font-semibold",
              listing.price === 0 ? "text-emerald-600 dark:text-emerald-400" : "text-foreground"
            )}>
              {priceDisplay}
            </div>
          )}
        </div>

        {/* Content */}
        <div className="p-3">
          {/* Title */}
          <h3 className="text-sm font-medium leading-snug line-clamp-2 text-foreground">
            {listing.title}
          </h3>

          {/* Meta row */}
          <div className="mt-2 flex items-center justify-between gap-2">
            {listing.city ? (
              <p className="flex items-center gap-1 text-xs text-muted-foreground">
                <MapPin className="h-3 w-3 shrink-0" />
                <span className="truncate">{listing.city}</span>
              </p>
            ) : listing.view_count ? (
              <p className="flex items-center gap-1 text-xs text-muted-foreground">
                <Eye className="h-3 w-3 shrink-0" />
                <span>{listing.view_count}</span>
              </p>
            ) : (
              <div />
            )}

            {/* Category badge */}
            <span className={cn(
              "px-1.5 py-0.5 rounded text-[10px] font-medium bg-muted",
              config.color
            )}>
              {config.badge}
            </span>
          </div>
        </div>
      </motion.article>
    </Link>
  )
})
