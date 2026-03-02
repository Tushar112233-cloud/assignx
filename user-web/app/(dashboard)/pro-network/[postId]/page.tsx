"use client";

/**
 * Pro Network Post Detail Page
 * Full view of a pro network post with content and interactions
 */

import { use, useState, useEffect, useCallback } from "react";
import Link from "next/link";
import Image from "next/image";
import { motion } from "framer-motion";
import {
  ArrowLeft,
  Heart,
  MessageCircle,
  Bookmark,
  Eye,
  Loader2,
  AlertCircle,
  Share2,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import {
  getProNetworkPostById,
  toggleProNetworkLike,
  toggleProNetworkSave,
} from "@/lib/actions/pro-network";
import { getProNetworkCategoryConfig, type ProNetworkPost } from "@/types/pro-network";

interface PostDetailPageProps {
  params: Promise<{
    postId: string;
  }>;
}

export default function ProNetworkPostDetailPage({
  params,
}: PostDetailPageProps) {
  const { postId } = use(params);
  const [post, setPost] = useState<ProNetworkPost | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function load() {
      setIsLoading(true);
      const { data, error: fetchError } = await getProNetworkPostById(postId);
      if (fetchError) {
        setError(fetchError);
      } else {
        setPost(data);
      }
      setIsLoading(false);
    }
    load();
  }, [postId]);

  const handleLike = useCallback(async () => {
    if (!post) return;
    setPost((prev) =>
      prev
        ? {
            ...prev,
            isLiked: !prev.isLiked,
            likesCount: prev.isLiked
              ? prev.likesCount - 1
              : prev.likesCount + 1,
          }
        : prev
    );

    const { error } = await toggleProNetworkLike(postId);
    if (error) {
      toast.error("Failed to update like");
      setPost((prev) =>
        prev
          ? {
              ...prev,
              isLiked: !prev.isLiked,
              likesCount: prev.isLiked
                ? prev.likesCount - 1
                : prev.likesCount + 1,
            }
          : prev
      );
    }
  }, [post, postId]);

  const handleSave = useCallback(async () => {
    if (!post) return;
    setPost((prev) =>
      prev
        ? {
            ...prev,
            isSaved: !prev.isSaved,
            savesCount: prev.isSaved
              ? prev.savesCount - 1
              : prev.savesCount + 1,
          }
        : prev
    );

    const { error } = await toggleProNetworkSave(postId);
    if (error) {
      toast.error("Failed to update save");
      setPost((prev) =>
        prev
          ? {
              ...prev,
              isSaved: !prev.isSaved,
              savesCount: prev.isSaved
                ? prev.savesCount - 1
                : prev.savesCount + 1,
            }
          : prev
      );
    }
  }, [post, postId]);

  const handleShare = useCallback(() => {
    if (typeof window !== "undefined" && navigator.share) {
      navigator.share({
        title: post?.title,
        url: window.location.href,
      });
    } else {
      navigator.clipboard.writeText(window.location.href);
      toast.success("Link copied to clipboard");
    }
  }, [post]);

  // Loading
  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-[50vh]">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    );
  }

  // Error
  if (error || !post) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[50vh] text-center px-4">
        <div className="h-14 w-14 rounded-2xl bg-destructive/10 flex items-center justify-center mb-4">
          <AlertCircle className="h-7 w-7 text-destructive" />
        </div>
        <h3 className="font-semibold mb-2">Post not found</h3>
        <p className="text-sm text-muted-foreground mb-4">
          {error || "This post may have been removed."}
        </p>
        <Button asChild>
          <Link href="/pro-network">Back to Pro Network</Link>
        </Button>
      </div>
    );
  }

  const categoryConfig = getProNetworkCategoryConfig(post.category);

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="max-w-3xl mx-auto px-4 md:px-6 py-6 space-y-6"
    >
      {/* Back button */}
      <Button variant="ghost" size="sm" asChild className="gap-2">
        <Link href="/pro-network">
          <ArrowLeft className="h-4 w-4" />
          Back
        </Link>
      </Button>

      {/* Post Card */}
      <article className="bg-white dark:bg-slate-900 rounded-2xl border border-border/50 overflow-hidden shadow-sm">
        {/* Image */}
        {post.images.length > 0 && (
          <div className="relative aspect-[2/1] overflow-hidden">
            <Image
              src={post.images[0]}
              alt={post.title}
              fill
              className="object-cover"
              priority
            />
          </div>
        )}

        <div className="p-6 space-y-5">
          {/* Category and tags */}
          <div className="flex items-center gap-2 flex-wrap">
            {post.category && (
              <Badge
                className={cn(
                  "rounded-full",
                  categoryConfig.lightBg,
                  categoryConfig.darkBg,
                  categoryConfig.textColor
                )}
              >
                {categoryConfig.label}
              </Badge>
            )}
            {post.tags.map((tag) => (
              <Badge key={tag} variant="secondary" className="rounded-full">
                {tag}
              </Badge>
            ))}
          </div>

          {/* Title */}
          <h1 className="text-2xl font-bold tracking-tight">{post.title}</h1>

          {/* Author */}
          <div className="flex items-center gap-3">
            <Avatar className="h-10 w-10">
              <AvatarImage
                src={post.author.avatarUrl || undefined}
                alt={post.author.fullName}
              />
              <AvatarFallback>
                {post.author.fullName.slice(0, 2).toUpperCase()}
              </AvatarFallback>
            </Avatar>
            <div>
              <p className="font-medium text-sm">{post.author.fullName}</p>
              <p className="text-xs text-muted-foreground">{post.timeAgo}</p>
            </div>
          </div>

          {/* Content */}
          <div className="prose prose-sm dark:prose-invert max-w-none whitespace-pre-wrap">
            {post.content}
          </div>

          {/* Actions */}
          <div className="flex items-center justify-between pt-4 border-t border-border/50">
            <div className="flex items-center gap-4">
              <button
                onClick={handleLike}
                className="flex items-center gap-1.5 text-muted-foreground hover:text-red-500 transition-colors"
              >
                <Heart
                  className={cn(
                    "h-5 w-5",
                    post.isLiked && "fill-red-500 text-red-500"
                  )}
                />
                <span className="text-sm font-medium tabular-nums">
                  {post.likesCount}
                </span>
              </button>

              <div className="flex items-center gap-1.5 text-muted-foreground">
                <MessageCircle className="h-5 w-5" />
                <span className="text-sm font-medium tabular-nums">
                  {post.commentsCount}
                </span>
              </div>

              <div className="flex items-center gap-1.5 text-muted-foreground">
                <Eye className="h-5 w-5" />
                <span className="text-sm font-medium tabular-nums">
                  {post.viewsCount}
                </span>
              </div>
            </div>

            <div className="flex items-center gap-2">
              <button
                onClick={handleSave}
                className="p-2 rounded-lg hover:bg-muted transition-colors"
              >
                <Bookmark
                  className={cn(
                    "h-5 w-5",
                    post.isSaved
                      ? "fill-blue-500 text-blue-500"
                      : "text-muted-foreground"
                  )}
                />
              </button>
              <button
                onClick={handleShare}
                className="p-2 rounded-lg hover:bg-muted transition-colors"
              >
                <Share2 className="h-5 w-5 text-muted-foreground" />
              </button>
            </div>
          </div>
        </div>
      </article>
    </motion.div>
  );
}
