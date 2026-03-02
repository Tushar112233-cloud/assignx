"use client";

import { useState, useEffect, useCallback, useMemo } from "react";
import Link from "next/link";
import { motion } from "framer-motion";
import {
  Search,
  Plus,
  X,
  AlertCircle,
  RefreshCw,
  Loader2,
  ShoppingBag,
} from "lucide-react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import { useUserStore } from "@/stores/user-store";
import { MarketplaceHero } from "./marketplace-hero";
import { MarketplaceGrid } from "./marketplace-grid";
import {
  fetchListings,
  toggleListingFavorite,
  type MarketplaceListingData,
} from "@/lib/actions/marketplace-listings";
import type { ListingDisplay } from "./masonry-grid";

/**
 * Category tab configuration for marketplace
 */
const CATEGORY_TABS = [
  { id: "all", label: "All" },
  { id: "books", label: "Books" },
  { id: "electronics", label: "Electronics" },
  { id: "services", label: "Services" },
  { id: "tutoring", label: "Tutoring" },
  { id: "housing", label: "Housing" },
  { id: "clothing", label: "Clothing" },
  { id: "furniture", label: "Furniture" },
  { id: "other", label: "Other" },
] as const;

type CategoryTab = (typeof CATEGORY_TABS)[number]["id"];

/**
 * Transform server listing data to the ListingDisplay format
 * used by ItemCard component
 */
function transformToDisplay(listing: MarketplaceListingData): ListingDisplay {
  return {
    id: listing.id,
    title: listing.title,
    description: listing.description || undefined,
    price: listing.price || undefined,
    listing_type: listing.listing_type,
    is_active: listing.status === "active",
    view_count: listing.view_count || undefined,
    created_at: listing.created_at,
    updated_at: listing.updated_at,
    seller_id: listing.seller_id,
    seller: listing.seller
      ? {
          id: listing.seller.id,
          full_name: listing.seller.full_name || "Unknown",
          avatar_url: listing.seller.avatar_url || null,
        }
      : undefined,
    category: listing.category
      ? {
          id: listing.category.id,
          name: listing.category.name,
          slug: listing.category.slug,
          is_active: listing.category.is_active,
        }
      : undefined,
    is_favorited: listing.is_favorited,
    image_url: listing.image_url,
    city: listing.city || undefined,
  };
}

/**
 * MarketplacePage - Full marketplace listing experience
 *
 * Features:
 * - Hero section with stats
 * - Search bar
 * - Category filter tabs
 * - Responsive grid of listings using ItemCard
 * - Create listing button and FAB
 */
export function MarketplacePage() {
  const { user } = useUserStore();

  const [rawListings, setRawListings] = useState<MarketplaceListingData[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedCategory, setSelectedCategory] = useState<CategoryTab>("all");
  const [total, setTotal] = useState(0);

  /** Derived display listings */
  const listings = useMemo(
    () => rawListings.map(transformToDisplay),
    [rawListings]
  );

  /** Unique seller count for hero */
  const uniqueSellers = useMemo(() => {
    const ids = new Set(rawListings.map((l) => l.seller_id));
    return ids.size;
  }, [rawListings]);

  /**
   * Fetch listings from server action
   */
  const loadListings = useCallback(async () => {
    try {
      setIsLoading(true);
      setError(null);

      const categoryFilter =
        selectedCategory === "all" ? undefined : selectedCategory;
      const searchFilter = searchQuery.trim() || undefined;

      const result = await fetchListings(categoryFilter, searchFilter);

      if (result.error) {
        setError(result.error);
        toast.error("Failed to load listings");
        return;
      }

      setRawListings(result.data);
      setTotal(result.total);
    } catch (err) {
      const message =
        err instanceof Error ? err.message : "Failed to load listings";
      setError(message);
      toast.error(message);
    } finally {
      setIsLoading(false);
    }
  }, [selectedCategory, searchQuery]);

  useEffect(() => {
    loadListings();
  }, [loadListings]);

  /**
   * Handle favorite toggle with optimistic update
   */
  const handleFavorite = async (listingId: string) => {
    if (!user?.id) {
      toast.error("Please sign in to save favorites");
      return;
    }

    const listing = rawListings.find((l) => l.id === listingId);
    const wasFavorited = listing?.is_favorited;

    // Optimistic update
    setRawListings((prev) =>
      prev.map((l) =>
        l.id === listingId ? { ...l, is_favorited: !l.is_favorited } : l
      )
    );

    const result = await toggleListingFavorite(listingId);

    if (!result.success || result.error) {
      // Revert on failure
      setRawListings((prev) =>
        prev.map((l) =>
          l.id === listingId ? { ...l, is_favorited: wasFavorited } : l
        )
      );
      toast.error(result.error || "Failed to update favorite");
      return;
    }

    toast.success(
      result.isFavorited ? "Added to favorites" : "Removed from favorites"
    );
  };

  /**
   * Handle search submission
   */
  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    loadListings();
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Hero Section */}
      <div className="px-4 md:px-6 pt-4 pb-4">
        <MarketplaceHero
          listingsCount={total}
          sellersCount={uniqueSellers}
          categoriesCount={CATEGORY_TABS.length - 1}
        />
      </div>

      {/* Search Bar */}
      <div className="px-4 md:px-6 pb-4">
        <form onSubmit={handleSearch} className="max-w-2xl mx-auto">
          <div className="relative flex gap-2">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
              <Input
                type="text"
                placeholder="Search listings..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-10"
              />
              {searchQuery && (
                <button
                  type="button"
                  onClick={() => {
                    setSearchQuery("");
                  }}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground transition-colors"
                >
                  <X className="h-4 w-4" />
                </button>
              )}
            </div>
            <Button type="submit" variant="secondary">
              Search
            </Button>
          </div>
        </form>
      </div>

      {/* Category Filter Tabs */}
      <div className="px-4 md:px-6 pb-6">
        <div className="flex justify-center gap-2 flex-wrap">
          {CATEGORY_TABS.map((tab) => {
            const isActive = selectedCategory === tab.id;
            return (
              <button
                key={tab.id}
                onClick={() => setSelectedCategory(tab.id)}
                className={cn(
                  "px-4 py-2 rounded-full text-sm font-medium transition-all border",
                  isActive
                    ? "bg-foreground text-background border-foreground"
                    : "bg-muted/50 text-foreground/70 border-border/50 hover:bg-muted hover:text-foreground"
                )}
              >
                {tab.label}
              </button>
            );
          })}
        </div>
      </div>

      {/* Active Filters */}
      {(searchQuery || selectedCategory !== "all") && (
        <div className="px-4 md:px-6 pb-4">
          <div className="flex items-center gap-2 flex-wrap justify-center">
            <span className="text-xs text-muted-foreground">Filters:</span>
            {searchQuery && (
              <Badge variant="secondary" className="gap-1 text-xs">
                &quot;{searchQuery}&quot;
                <button onClick={() => setSearchQuery("")}>
                  <X className="h-3 w-3" />
                </button>
              </Badge>
            )}
            {selectedCategory !== "all" && (
              <Badge variant="secondary" className="gap-1 text-xs capitalize">
                {selectedCategory}
                <button onClick={() => setSelectedCategory("all")}>
                  <X className="h-3 w-3" />
                </button>
              </Badge>
            )}
          </div>
        </div>
      )}

      {/* Create Listing Button (inline) */}
      <div className="px-4 md:px-6 pb-4 flex justify-center">
        <Button asChild>
          <Link href="/marketplace/create">
            <Plus className="h-4 w-4 mr-2" />
            Create Listing
          </Link>
        </Button>
      </div>

      {/* Main Content */}
      <div className="px-4 md:px-6 pb-32">
        {/* Error State */}
        {error && (
          <div className="flex items-start gap-3 p-4 rounded-xl border border-red-200 bg-red-50 dark:border-red-800 dark:bg-red-900/20 mb-6 max-w-2xl mx-auto">
            <AlertCircle className="h-4 w-4 text-red-600 dark:text-red-400 shrink-0 mt-0.5" />
            <div>
              <p className="text-sm text-red-600 dark:text-red-400">{error}</p>
              <Button
                variant="ghost"
                size="sm"
                onClick={loadListings}
                className="mt-2 h-8 text-xs"
              >
                <RefreshCw className="h-3 w-3 mr-1" />
                Try Again
              </Button>
            </div>
          </div>
        )}

        {/* Loading State */}
        {isLoading && (
          <div className="flex items-center justify-center py-16">
            <Loader2 className="h-8 w-8 animate-spin text-primary" />
          </div>
        )}

        {/* Empty State */}
        {!isLoading && listings.length === 0 && !error && (
          <div className="flex flex-col items-center justify-center py-16 text-center">
            <div className="h-14 w-14 rounded-2xl bg-muted/60 flex items-center justify-center mb-4">
              <ShoppingBag className="h-7 w-7 text-muted-foreground" />
            </div>
            <h3 className="font-medium mb-1">No listings found</h3>
            <p className="text-sm text-muted-foreground mb-4 max-w-xs">
              {searchQuery
                ? `No results for "${searchQuery}"`
                : "Be the first to list something on the marketplace!"}
            </p>
            {searchQuery ? (
              <Button
                variant="outline"
                size="sm"
                onClick={() => {
                  setSearchQuery("");
                  setSelectedCategory("all");
                }}
              >
                Clear Filters
              </Button>
            ) : (
              <Button asChild size="sm">
                <Link href="/marketplace/create">
                  <Plus className="h-4 w-4 mr-1" />
                  Create Listing
                </Link>
              </Button>
            )}
          </div>
        )}

        {/* Listings Grid */}
        {!isLoading && listings.length > 0 && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.3 }}
          >
            <p className="text-xs text-muted-foreground text-center mb-4">
              Showing {listings.length} {listings.length === 1 ? "listing" : "listings"}
              {searchQuery && ` matching "${searchQuery}"`}
            </p>
            <MarketplaceGrid
              listings={listings}
              onFavorite={handleFavorite}
            />
          </motion.div>
        )}
      </div>

      {/* Floating Action Button */}
      <motion.div
        initial={{ opacity: 0, scale: 0.8 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ delay: 0.5, type: "spring", stiffness: 200 }}
        className="fixed bottom-24 right-6 z-50"
      >
        <Button
          asChild
          size="lg"
          className="h-14 w-14 rounded-full shadow-lg hover:scale-105 transition-transform"
        >
          <Link href="/marketplace/create">
            <Plus className="h-6 w-6" />
            <span className="sr-only">Create Listing</span>
          </Link>
        </Button>
      </motion.div>
    </div>
  );
}
