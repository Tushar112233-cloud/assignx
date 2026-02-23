"use client"

import { useCallback, useEffect, useRef, useState } from "react"
import Masonry from "react-masonry-css"
import { Loader2 } from "lucide-react"
import { cn } from "@/lib/utils"
import { ItemCard } from "./item-card"
import { TextCard } from "./text-card"
import { BannerCard } from "./banner-card"
/**
 * Simplified listing type for display
 */
export interface ListingDisplay {
  id: string
  title: string
  description?: string
  price?: number
  listing_type: string
  is_active: boolean
  view_count?: number
  created_at: string
  updated_at: string
  seller_id: string
  seller?: {
    id: string
    full_name: string
    avatar_url: string | null
  }
  category?: {
    id: string
    name: string
    slug: string
    is_active: boolean
  }
  is_favorited?: boolean
  is_featured?: boolean
  image_url?: string | null
  city?: string
}

/**
 * Grid layout variants
 */
type GridVariant = "masonry"


/**
 * Props for MasonryGrid component
 */
interface MasonryGridProps {
  listings: ListingDisplay[]
  onFavorite?: (listingId: string) => void
  onLoadMore?: () => void
  hasMore?: boolean
  isLoading?: boolean
  className?: string
  /** Grid layout variant - 'masonry' for Pinterest-style, 'bento' for random sized cards */
  variant?: GridVariant
}

/**
 * Breakpoint configuration for Masonry columns - 5 columns on large screens
 */
const breakpointColumns = {
  default: 5,
  1280: 5,
  1024: 4,
  768: 3,
  640: 2,
}

/**
 * MasonryGrid component for Pinterest-style layout
 * Renders different card types based on listing type
 * Supports infinite scroll loading
 */
export function MasonryGrid({
  listings,
  onFavorite,
  onLoadMore,
  hasMore = false,
  isLoading = false,
  className,
  variant = "masonry",
}: MasonryGridProps) {
  const observerRef = useRef<IntersectionObserver | null>(null)
  const loadMoreRef = useRef<HTMLDivElement>(null)

  // Set up intersection observer for infinite scroll
  useEffect(() => {
    if (!onLoadMore || !hasMore) return

    observerRef.current = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting && !isLoading) {
          onLoadMore()
        }
      },
      { threshold: 0.1 }
    )

    if (loadMoreRef.current) {
      observerRef.current.observe(loadMoreRef.current)
    }

    return () => {
      observerRef.current?.disconnect()
    }
  }, [onLoadMore, hasMore, isLoading])

  /**
   * Renders the appropriate card type based on listing
   */
  const renderCard = useCallback(
    (listing: ListingDisplay) => {
      // Community posts use TextCard
      if (listing.listing_type === "community_post") {
        return <TextCard key={listing.id} listing={listing} onFavorite={onFavorite} />
      }

      // Opportunities and featured events use BannerCard
      if (
        listing.listing_type === "opportunity" ||
        listing.is_featured
      ) {
        return (
          <div key={listing.id} className="col-span-full">
            <BannerCard listing={listing} onFavorite={onFavorite} />
          </div>
        )
      }

      // Default to ItemCard
      return (
        <ItemCard
          key={listing.id}
          listing={listing}
          onFavorite={onFavorite}
        />
      )
    },
    [onFavorite]
  )

  if (listings.length === 0 && !isLoading) {
    return (
      <div className="flex flex-col items-center justify-center py-12 text-center">
        <p className="text-lg font-medium text-muted-foreground">
          No listings found
        </p>
        <p className="text-sm text-muted-foreground">
          Try adjusting your filters or check back later
        </p>
      </div>
    )
  }


  // Render masonry grid layout
  return (
    <div className={cn("w-full", className)}>
      <Masonry
        breakpointCols={breakpointColumns}
        className="flex w-auto -ml-3"
        columnClassName="pl-3 bg-clip-padding"
      >
        {listings.map((listing) => (
          <div key={listing.id} className="mb-3">
            {renderCard(listing)}
          </div>
        ))}
      </Masonry>

      {/* Load More Trigger */}
      {hasMore && (
        <div
          ref={loadMoreRef}
          className="flex items-center justify-center py-8"
        >
          {isLoading && (
            <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
          )}
        </div>
      )}

      {/* Loading State */}
      {isLoading && listings.length === 0 && (
        <div className="flex items-center justify-center py-12">
          <Loader2 className="h-8 w-8 animate-spin text-primary" />
        </div>
      )}
    </div>
  )
}
