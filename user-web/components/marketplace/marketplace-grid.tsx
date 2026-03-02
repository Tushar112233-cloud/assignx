"use client";

import { cn } from "@/lib/utils";
import { ItemCard } from "./item-card";
import type { ListingDisplay } from "./masonry-grid";

interface MarketplaceGridProps {
  listings: ListingDisplay[];
  onFavorite?: (listingId: string) => void;
  className?: string;
}

/**
 * MarketplaceGrid - Responsive grid layout for marketplace listings
 * 1 column on mobile, 2 on tablet, 3 on desktop
 * Uses the existing ItemCard component for each listing
 */
export function MarketplaceGrid({
  listings,
  onFavorite,
  className,
}: MarketplaceGridProps) {
  if (listings.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-16 text-center">
        <p className="text-lg font-medium text-muted-foreground">
          No listings found
        </p>
        <p className="text-sm text-muted-foreground mt-1">
          Try adjusting your filters or check back later
        </p>
      </div>
    );
  }

  return (
    <div
      className={cn(
        "grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4",
        className
      )}
    >
      {listings.map((listing) => (
        <ItemCard
          key={listing.id}
          listing={listing}
          onFavorite={onFavorite}
        />
      ))}
    </div>
  );
}
