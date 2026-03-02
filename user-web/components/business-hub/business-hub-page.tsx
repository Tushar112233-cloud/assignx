"use client";

/**
 * BusinessHubPage - Main page component for the Business Hub
 *
 * Features:
 * - Business-themed gradient hero section with stats
 * - Search bar with debounced search
 * - Category filter tabs
 * - Post feed with like/save optimistic updates
 * - Empty state handling
 */

import { useState, useEffect, useCallback } from "react";
import Link from "next/link";
import { motion, AnimatePresence } from "framer-motion";
import {
  Loader2,
  RefreshCw,
  AlertCircle,
  Plus,
  Bookmark,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { toast } from "sonner";
import {
  getBusinessHubPosts,
  toggleBusinessHubLike,
  toggleBusinessHubSave,
} from "@/lib/actions/business-hub";
import { BusinessHero } from "./business-hero";
import { BusinessFilterTabs } from "./business-filter-tabs";
import { BusinessSearchBar } from "./business-search-bar";
import { BusinessPostCard } from "./business-post-card";
import type { BusinessHubPost, BusinessHubCategory } from "@/types/business-hub";

export function BusinessHubPage() {
  // Data state
  const [posts, setPosts] = useState<BusinessHubPost[]>([]);
  const [totalPosts, setTotalPosts] = useState(0);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Filter state
  const [activeCategory, setActiveCategory] =
    useState<BusinessHubCategory>("all");
  const [searchQuery, setSearchQuery] = useState("");

  /**
   * Fetch posts from the server
   */
  const fetchPosts = useCallback(async () => {
    setIsLoading(true);
    setError(null);

    const { data, total, error: fetchError } = await getBusinessHubPosts({
      category: activeCategory !== "all" ? activeCategory : undefined,
      search: searchQuery || undefined,
    });

    if (fetchError) {
      setError(fetchError);
    } else {
      setPosts(data);
      setTotalPosts(total);
    }

    setIsLoading(false);
  }, [activeCategory, searchQuery]);

  // Fetch on mount and when filters change
  useEffect(() => {
    fetchPosts();
  }, [fetchPosts]);

  /**
   * Handle like toggle with optimistic update
   */
  const handleLike = useCallback(async (postId: string) => {
    setPosts((prev) =>
      prev.map((p) =>
        p.id === postId
          ? {
              ...p,
              isLiked: !p.isLiked,
              likesCount: p.isLiked ? p.likesCount - 1 : p.likesCount + 1,
            }
          : p
      )
    );

    const { error } = await toggleBusinessHubLike(postId);
    if (error) {
      toast.error("Failed to update like");
      setPosts((prev) =>
        prev.map((p) =>
          p.id === postId
            ? {
                ...p,
                isLiked: !p.isLiked,
                likesCount: p.isLiked ? p.likesCount - 1 : p.likesCount + 1,
              }
            : p
        )
      );
    }
  }, []);

  /**
   * Handle save toggle with optimistic update
   */
  const handleSave = useCallback(async (postId: string) => {
    setPosts((prev) =>
      prev.map((p) =>
        p.id === postId
          ? {
              ...p,
              isSaved: !p.isSaved,
              savesCount: p.isSaved ? p.savesCount - 1 : p.savesCount + 1,
            }
          : p
      )
    );

    const { error } = await toggleBusinessHubSave(postId);
    if (error) {
      toast.error("Failed to update save");
      setPosts((prev) =>
        prev.map((p) =>
          p.id === postId
            ? {
                ...p,
                isSaved: !p.isSaved,
                savesCount: p.isSaved ? p.savesCount - 1 : p.savesCount + 1,
              }
            : p
        )
      );
    }
  }, []);

  return (
    <div className="min-h-[calc(100vh-3.5rem)] bg-background">
      <div className="max-w-6xl mx-auto px-4 md:px-6 py-6 space-y-6">
        {/* Hero Section */}
        <BusinessHero totalPosts={totalPosts} />

        {/* Search */}
        <BusinessSearchBar
          value={searchQuery}
          onSearch={setSearchQuery}
          className="max-w-2xl mx-auto"
        />

        {/* Filter Tabs */}
        <BusinessFilterTabs
          activeCategory={activeCategory}
          onCategoryChange={setActiveCategory}
        />

        {/* Action bar */}
        <div className="flex items-center justify-between">
          <p className="text-sm text-muted-foreground">
            {isLoading
              ? "Loading..."
              : `${totalPosts} ${totalPosts === 1 ? "post" : "posts"} found`}
          </p>
          <div className="flex items-center gap-2">
            <Button variant="ghost" size="sm" asChild>
              <Link href="/business-hub/saved" className="gap-2">
                <Bookmark className="h-4 w-4" />
                Saved
              </Link>
            </Button>
            <Button size="sm" asChild className="gap-2">
              <Link href="/business-hub/create">
                <Plus className="h-4 w-4" />
                Create Post
              </Link>
            </Button>
          </div>
        </div>

        {/* Error State */}
        {error && (
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            className="flex flex-col items-center justify-center py-12 text-center"
          >
            <div className="h-14 w-14 rounded-2xl bg-destructive/10 flex items-center justify-center mb-4">
              <AlertCircle className="h-7 w-7 text-destructive" />
            </div>
            <h3 className="font-semibold mb-2">Something went wrong</h3>
            <p className="text-sm text-muted-foreground mb-4 max-w-sm">
              {error}
            </p>
            <Button variant="outline" onClick={fetchPosts} className="gap-2">
              <RefreshCw className="h-4 w-4" />
              Try Again
            </Button>
          </motion.div>
        )}

        {/* Loading State */}
        {isLoading && !error && (
          <div className="flex items-center justify-center py-12">
            <Loader2 className="h-8 w-8 animate-spin text-primary" />
          </div>
        )}

        {/* Empty State */}
        {!isLoading && !error && posts.length === 0 && (
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-center py-16"
          >
            <div className="h-16 w-16 rounded-2xl bg-muted flex items-center justify-center mx-auto mb-4">
              <AlertCircle className="h-8 w-8 text-muted-foreground" />
            </div>
            <h3 className="font-semibold mb-2">No posts found</h3>
            <p className="text-sm text-muted-foreground mb-6">
              {searchQuery
                ? `No results for "${searchQuery}"`
                : "Be the first to start a discussion"}
            </p>
            <Button asChild>
              <Link href="/business-hub/create">Create the First Post</Link>
            </Button>
          </motion.div>
        )}

        {/* Post Grid */}
        {!isLoading && !error && posts.length > 0 && (
          <AnimatePresence mode="popLayout">
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4"
            >
              {posts.map((post, index) => (
                <motion.div
                  key={post.id}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{
                    opacity: 1,
                    y: 0,
                    transition: { delay: index * 0.05 },
                  }}
                >
                  <BusinessPostCard
                    post={post}
                    onLike={handleLike}
                    onSave={handleSave}
                  />
                </motion.div>
              ))}
            </motion.div>
          </AnimatePresence>
        )}
      </div>
    </div>
  );
}
