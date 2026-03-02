"use client";

/**
 * SavedBusinessPosts - Displays the user's saved Business Hub posts
 */

import { useState, useEffect, useCallback } from "react";
import Link from "next/link";
import { ArrowLeft, Loader2, Bookmark } from "lucide-react";
import { Button } from "@/components/ui/button";
import { toast } from "sonner";
import {
  getSavedBusinessHubPosts,
  toggleBusinessHubLike,
  toggleBusinessHubSave,
} from "@/lib/actions/business-hub";
import { BusinessPostCard } from "./business-post-card";
import type { BusinessHubPost } from "@/types/business-hub";

export function SavedBusinessPosts() {
  const [posts, setPosts] = useState<BusinessHubPost[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    async function load() {
      setIsLoading(true);
      const { data, error } = await getSavedBusinessHubPosts();
      if (error) {
        toast.error("Failed to load saved posts");
      }
      setPosts(data);
      setIsLoading(false);
    }
    load();
  }, []);

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

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-[50vh]">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center gap-3">
        <Button variant="ghost" size="icon" asChild>
          <Link href="/business-hub">
            <ArrowLeft className="h-5 w-5" />
          </Link>
        </Button>
        <h2 className="text-xl font-semibold">Saved Posts</h2>
      </div>

      {/* Posts */}
      {posts.length === 0 ? (
        <div className="text-center py-16">
          <div className="h-16 w-16 rounded-2xl bg-muted flex items-center justify-center mx-auto mb-4">
            <Bookmark className="h-8 w-8 text-muted-foreground" />
          </div>
          <h3 className="font-semibold mb-2">No saved posts yet</h3>
          <p className="text-sm text-muted-foreground mb-6">
            Save posts to read them later
          </p>
          <Button asChild>
            <Link href="/business-hub">Browse Posts</Link>
          </Button>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {posts.map((post) => (
            <BusinessPostCard
              key={post.id}
              post={post}
              onLike={handleLike}
              onSave={handleSave}
            />
          ))}
        </div>
      )}
    </div>
  );
}
