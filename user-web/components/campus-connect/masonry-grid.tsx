"use client";

/**
 * CampusConnectMasonryGrid - Premium Masonry Layout
 *
 * Pinterest-style masonry grid with:
 * - Premium loading states
 * - Glassmorphic empty states
 * - Infinite scroll support
 */

import { useCallback, useEffect, useRef } from "react";
import Masonry from "react-masonry-css";
import { Loader2, Users, Plus } from "lucide-react";
import Link from "next/link";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { PostCard } from "./post-card";
import type { CampusConnectPost } from "@/types/campus-connect";

/**
 * Props for CampusConnectMasonryGrid component
 */
interface MasonryGridProps {
  posts: CampusConnectPost[];
  onLike?: (postId: string) => void;
  onSave?: (postId: string) => void;
  onLoadMore?: () => void;
  hasMore?: boolean;
  isLoading?: boolean;
  className?: string;
}

/**
 * Breakpoint configuration for Masonry columns
 */
const breakpointColumns = {
  default: 4,
  1280: 4,
  1024: 3,
  768: 2,
  640: 1,
};

/**
 * CampusConnectMasonryGrid - Pinterest-style masonry layout
 */
export function CampusConnectMasonryGrid({
  posts,
  onLike,
  onSave,
  onLoadMore,
  hasMore = false,
  isLoading = false,
  className,
}: MasonryGridProps) {
  const observerRef = useRef<IntersectionObserver | null>(null);
  const loadMoreRef = useRef<HTMLDivElement>(null);

  // Set up intersection observer for infinite scroll
  useEffect(() => {
    if (!onLoadMore || !hasMore) return;

    observerRef.current = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting && !isLoading) {
          onLoadMore();
        }
      },
      { threshold: 0.1 }
    );

    if (loadMoreRef.current) {
      observerRef.current.observe(loadMoreRef.current);
    }

    return () => {
      observerRef.current?.disconnect();
    };
  }, [onLoadMore, hasMore, isLoading]);

  /**
   * Renders a single post card
   */
  const renderPostCard = useCallback(
    (post: CampusConnectPost) => (
      <div key={post.id} className="mb-4">
        <PostCard
          post={post}
          onLike={onLike}
          onSave={onSave}
        />
      </div>
    ),
    [onLike, onSave]
  );

  // Empty state
  if (posts.length === 0 && !isLoading) {
    return (
      <div className="flex flex-col items-center justify-center py-20 text-center">
        <div className="relative mb-5">
          <div className="h-16 w-16 rounded-[20px] bg-gradient-to-br from-blue-400 to-purple-500 flex items-center justify-center shadow-lg">
            <Users className="h-7 w-7 text-white" />
          </div>
          <div className="absolute -inset-4 bg-gradient-to-br from-blue-400/20 to-purple-500/20 rounded-full blur-xl pointer-events-none" />
        </div>
        <h3 className="text-xl font-semibold mb-2">No posts found</h3>
        <p className="text-sm text-muted-foreground max-w-xs mb-6">
          Be the first to share something with your campus community!
        </p>
        <Button asChild className="gap-2 rounded-xl h-11 px-6">
          <Link href="/campus-connect/create">
            <Plus className="h-4 w-4" />
            Create Post
          </Link>
        </Button>
      </div>
    );
  }

  return (
    <div className={cn("w-full", className)}>
      <Masonry
        breakpointCols={breakpointColumns}
        className="flex w-auto -ml-4"
        columnClassName="pl-4 bg-clip-padding"
      >
        {posts.map(renderPostCard)}
      </Masonry>

      {/* Load More Trigger */}
      {hasMore && (
        <div
          ref={loadMoreRef}
          className="flex items-center justify-center py-8"
        >
          {isLoading && (
            <div className="flex items-center gap-3 px-6 py-3 rounded-full bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10">
              <Loader2 className="h-5 w-5 animate-spin text-primary" />
              <span className="text-sm text-muted-foreground">Loading more...</span>
            </div>
          )}
        </div>
      )}

      {/* Loading State - Initial Load */}
      {isLoading && posts.length === 0 && (
        <div className="flex flex-col items-center justify-center py-20">
          <div className="relative mb-5">
            <div className="h-16 w-16 rounded-[20px] bg-gradient-to-br from-blue-400 to-purple-500 flex items-center justify-center shadow-lg animate-pulse">
              <Users className="h-7 w-7 text-white" />
            </div>
            <div className="absolute -inset-4 bg-gradient-to-br from-blue-400/20 to-purple-500/20 rounded-full blur-xl pointer-events-none animate-pulse" />
          </div>
          <p className="text-sm text-muted-foreground">Loading posts...</p>
        </div>
      )}
    </div>
  );
}

export default CampusConnectMasonryGrid;
