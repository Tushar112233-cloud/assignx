"use client";

/**
 * SavedListings - Grid of user's saved campus connect listings
 *
 * Features:
 * - Grid layout of saved posts
 * - Remove from saved functionality
 * - Empty state when no saved items
 * - Loading skeleton states
 */

import { useState, useEffect, useTransition } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  Bookmark,
  BookmarkX,
  Loader2,
  RefreshCw,
  Inbox,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { PostCard } from "./post-card";
import { getSavedListings, togglePostSave } from "@/lib/actions/campus-connect";
import type { CampusConnectPost } from "@/types/campus-connect";
import { cn } from "@/lib/utils";

interface SavedListingsProps {
  /** Initial saved listings (for SSR) */
  initialListings?: CampusConnectPost[];
  /** Additional CSS classes */
  className?: string;
}

/**
 * SavedListings - Display grid of saved posts
 */
export function SavedListings({
  initialListings,
  className,
}: SavedListingsProps) {
  const [listings, setListings] = useState<CampusConnectPost[]>(initialListings || []);
  const [isLoading, setIsLoading] = useState(!initialListings);
  const [error, setError] = useState<string | null>(null);
  const [isPending, startTransition] = useTransition();
  const [removingIds, setRemovingIds] = useState<Set<string>>(new Set());

  // Fetch saved listings on mount if not provided
  useEffect(() => {
    if (!initialListings) {
      fetchSavedListings();
    }
  }, [initialListings]);

  const fetchSavedListings = async () => {
    setIsLoading(true);
    setError(null);

    try {
      const result = await getSavedListings();
      if (result.error) {
        setError(result.error);
      } else {
        setListings(result.data);
      }
    } catch (err) {
      setError("Failed to load saved listings");
    } finally {
      setIsLoading(false);
    }
  };

  const handleRemoveSaved = async (postId: string) => {
    // Add to removing set for animation
    setRemovingIds((prev) => new Set(prev).add(postId));

    startTransition(async () => {
      try {
        const result = await togglePostSave(postId);
        if (result.success && !result.isSaved) {
          // Remove from local state after animation
          setTimeout(() => {
            setListings((prev) => prev.filter((p) => p.id !== postId));
            setRemovingIds((prev) => {
              const next = new Set(prev);
              next.delete(postId);
              return next;
            });
          }, 300);
        } else {
          // Failed, remove from removing set
          setRemovingIds((prev) => {
            const next = new Set(prev);
            next.delete(postId);
            return next;
          });
        }
      } catch (err) {
        setRemovingIds((prev) => {
          const next = new Set(prev);
          next.delete(postId);
          return next;
        });
      }
    });
  };

  const handleLike = async (postId: string) => {
    // Toggle like state optimistically
    setListings((prev) =>
      prev.map((p) =>
        p.id === postId
          ? {
              ...p,
              isLiked: !p.isLiked,
              likeCount: p.isLiked ? p.likeCount - 1 : p.likeCount + 1,
            }
          : p
      )
    );
  };

  // Loading state
  if (isLoading) {
    return (
      <div className={cn("space-y-6", className)}>
        <SavedListingsHeader count={0} onRefresh={fetchSavedListings} isLoading />
        <SavedListingsSkeleton />
      </div>
    );
  }

  // Error state
  if (error) {
    return (
      <div className={cn("space-y-6", className)}>
        <SavedListingsHeader count={0} onRefresh={fetchSavedListings} />
        <div className="flex flex-col items-center justify-center py-12 px-6 text-center">
          <div className="h-12 w-12 rounded-full bg-destructive/10 flex items-center justify-center mb-4">
            <BookmarkX className="h-6 w-6 text-destructive" />
          </div>
          <h3 className="text-lg font-semibold text-foreground mb-2">
            Failed to Load
          </h3>
          <p className="text-muted-foreground text-sm mb-4 max-w-xs">
            {error}
          </p>
          <Button
            variant="outline"
            onClick={fetchSavedListings}
            className="rounded-full"
          >
            <RefreshCw className="h-4 w-4 mr-2" />
            Try Again
          </Button>
        </div>
      </div>
    );
  }

  // Empty state
  if (listings.length === 0) {
    return (
      <div className={cn("space-y-6", className)}>
        <SavedListingsHeader count={0} onRefresh={fetchSavedListings} />
        <SavedListingsEmptyState />
      </div>
    );
  }

  return (
    <div className={cn("space-y-6", className)}>
      <SavedListingsHeader
        count={listings.length}
        onRefresh={fetchSavedListings}
        isRefreshing={isPending}
      />

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        <AnimatePresence mode="popLayout">
          {listings.map((listing) => (
            <motion.div
              key={listing.id}
              layout
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{
                opacity: removingIds.has(listing.id) ? 0.5 : 1,
                scale: removingIds.has(listing.id) ? 0.95 : 1,
              }}
              exit={{ opacity: 0, scale: 0.9 }}
              transition={{ duration: 0.2 }}
              className="relative group"
            >
              <PostCard
                post={listing}
                onLike={handleLike}
                onSave={() => handleRemoveSaved(listing.id)}
              />

              {/* Remove button overlay */}
              <button
                onClick={(e) => {
                  e.preventDefault();
                  e.stopPropagation();
                  handleRemoveSaved(listing.id);
                }}
                disabled={removingIds.has(listing.id)}
                className={cn(
                  "absolute top-3 right-3 p-2 rounded-full",
                  "bg-white/90 dark:bg-slate-900/90 backdrop-blur-sm shadow-lg",
                  "opacity-0 group-hover:opacity-100 transition-opacity duration-200",
                  "hover:bg-red-50 dark:hover:bg-red-950/30",
                  "disabled:cursor-not-allowed"
                )}
                title="Remove from saved"
              >
                {removingIds.has(listing.id) ? (
                  <Loader2 className="h-4 w-4 animate-spin text-muted-foreground" />
                ) : (
                  <BookmarkX className="h-4 w-4 text-red-500" />
                )}
              </button>
            </motion.div>
          ))}
        </AnimatePresence>
      </div>
    </div>
  );
}

/**
 * Header component for saved listings section
 */
function SavedListingsHeader({
  count,
  onRefresh,
  isLoading = false,
  isRefreshing = false,
}: {
  count: number;
  onRefresh: () => void;
  isLoading?: boolean;
  isRefreshing?: boolean;
}) {
  return (
    <div className="flex items-center justify-between">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-full bg-primary/10 flex items-center justify-center">
          <Bookmark className="h-5 w-5 text-primary" />
        </div>
        <div>
          <h2 className="text-lg font-semibold text-foreground">Saved Listings</h2>
          <p className="text-sm text-muted-foreground">
            {isLoading ? (
              "Loading..."
            ) : count === 0 ? (
              "No saved listings yet"
            ) : (
              `${count} saved ${count === 1 ? "listing" : "listings"}`
            )}
          </p>
        </div>
      </div>

      <Button
        variant="ghost"
        size="icon"
        onClick={onRefresh}
        disabled={isLoading || isRefreshing}
        className="rounded-full"
        title="Refresh"
      >
        <RefreshCw className={cn(
          "h-4 w-4",
          (isLoading || isRefreshing) && "animate-spin"
        )} />
      </Button>
    </div>
  );
}

/**
 * Empty state component
 */
function SavedListingsEmptyState() {
  return (
    <div className="flex flex-col items-center justify-center py-16 px-6 text-center bg-muted/30 rounded-2xl border border-dashed">
      <div className="h-16 w-16 rounded-full bg-muted flex items-center justify-center mb-4">
        <Inbox className="h-8 w-8 text-muted-foreground" />
      </div>
      <h3 className="text-lg font-semibold text-foreground mb-2">
        No Saved Listings
      </h3>
      <p className="text-muted-foreground text-sm max-w-xs mb-6">
        Save listings by clicking the bookmark icon. They'll appear here for easy access.
      </p>
      <Button variant="outline" className="rounded-full" asChild>
        <a href="/campus-connect">Browse Listings</a>
      </Button>
    </div>
  );
}

/**
 * Loading skeleton grid
 */
function SavedListingsSkeleton() {
  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
      {Array.from({ length: 8 }).map((_, i) => (
        <div
          key={i}
          className="bg-card rounded-2xl border overflow-hidden animate-pulse"
        >
          {/* Image placeholder */}
          <div className="aspect-[4/3] bg-muted" />

          {/* Content placeholder */}
          <div className="p-4 space-y-3">
            <div className="h-4 bg-muted rounded w-3/4" />
            <div className="h-3 bg-muted rounded w-full" />
            <div className="h-3 bg-muted rounded w-2/3" />

            <div className="flex items-center gap-2 pt-2">
              <div className="h-7 w-7 bg-muted rounded-full" />
              <div className="h-3 bg-muted rounded w-24" />
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}

export default SavedListings;
