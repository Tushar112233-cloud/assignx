"use client";

/**
 * ProPostCard - Card component for a professional network post
 * Displays author info, content preview, category badge, tags, and interaction buttons
 */

import { memo, useState, useCallback } from "react";
import Image from "next/image";
import Link from "next/link";
import {
  Heart,
  MessageCircle,
  Bookmark,
  Eye,
  ChevronRight,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { getProNetworkCategoryConfig, type ProNetworkPost } from "@/types/pro-network";

interface ProPostCardProps {
  post: ProNetworkPost;
  onLike?: (postId: string) => void;
  onSave?: (postId: string) => void;
  className?: string;
}

export const ProPostCard = memo(function ProPostCard({
  post,
  onLike,
  onSave,
  className,
}: ProPostCardProps) {
  const [isLikeAnimating, setIsLikeAnimating] = useState(false);
  const [isSaveAnimating, setIsSaveAnimating] = useState(false);

  const handleLike = useCallback(
    (e: React.MouseEvent) => {
      e.preventDefault();
      e.stopPropagation();
      setIsLikeAnimating(true);
      setTimeout(() => setIsLikeAnimating(false), 300);
      onLike?.(post.id);
    },
    [onLike, post.id]
  );

  const handleSave = useCallback(
    (e: React.MouseEvent) => {
      e.preventDefault();
      e.stopPropagation();
      setIsSaveAnimating(true);
      setTimeout(() => setIsSaveAnimating(false), 300);
      onSave?.(post.id);
    },
    [onSave, post.id]
  );

  const categoryConfig = getProNetworkCategoryConfig(post.category);
  const hasImage = post.images.length > 0;

  return (
    <Link href={`/pro-network/${post.id}`} className="block group">
      <article
        className={cn(
          "relative overflow-hidden rounded-2xl",
          "bg-white dark:bg-slate-900",
          "border border-slate-200/80 dark:border-slate-700/50",
          "shadow-sm hover:shadow-xl hover:shadow-slate-200/50 dark:hover:shadow-slate-900/50",
          "transition-all duration-300",
          "hover:-translate-y-1",
          className
        )}
      >
        {/* Image Section */}
        {hasImage && (
          <div className="relative aspect-[16/9] overflow-hidden">
            <Image
              src={post.images[0]}
              alt={post.title}
              fill
              className="object-cover transition-transform duration-500 group-hover:scale-105"
              sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-black/30 via-transparent to-transparent" />

            {/* Save Button overlay */}
            <button
              onClick={handleSave}
              className={cn(
                "absolute bottom-3 right-3 p-2.5 rounded-xl",
                "bg-white/95 dark:bg-slate-900/90 backdrop-blur-sm shadow-lg",
                "opacity-0 group-hover:opacity-100 transition-all duration-200",
                "hover:scale-110",
                post.isSaved && "opacity-100"
              )}
            >
              <Bookmark
                className={cn(
                  "h-4 w-4 transition-transform",
                  isSaveAnimating && "scale-125",
                  post.isSaved
                    ? "fill-blue-500 text-blue-500"
                    : "text-slate-500"
                )}
              />
            </button>
          </div>
        )}

        {/* Content */}
        <div className="p-4 space-y-3">
          {/* Category and Tags */}
          <div className="flex items-center gap-2 flex-wrap">
            {post.category && (
              <Badge
                className={cn(
                  "rounded-full text-xs",
                  categoryConfig.lightBg,
                  categoryConfig.darkBg,
                  categoryConfig.textColor
                )}
              >
                {categoryConfig.label}
              </Badge>
            )}
            {post.tags.slice(0, 2).map((tag) => (
              <Badge
                key={tag}
                variant="secondary"
                className="rounded-full text-xs"
              >
                {tag}
              </Badge>
            ))}
            {post.tags.length > 2 && (
              <span className="text-xs text-muted-foreground">
                +{post.tags.length - 2}
              </span>
            )}
          </div>

          {/* Title */}
          <h3 className="font-semibold text-[15px] leading-snug line-clamp-2 text-foreground group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors">
            {post.title}
          </h3>

          {/* Preview */}
          <p className="text-xs text-muted-foreground line-clamp-2 leading-relaxed">
            {post.previewText}
          </p>

          {/* Author */}
          <div className="flex items-center gap-2.5 pt-1">
            <Avatar className="h-7 w-7 ring-2 ring-white dark:ring-slate-800">
              <AvatarImage
                src={post.author.avatarUrl || undefined}
                alt={post.author.fullName}
              />
              <AvatarFallback className="text-[10px] bg-gradient-to-br from-blue-100 to-indigo-200 dark:from-blue-900 dark:to-indigo-800">
                {post.author.fullName.slice(0, 2).toUpperCase()}
              </AvatarFallback>
            </Avatar>
            <div className="flex-1 min-w-0">
              <span className="text-xs font-medium text-foreground/80 truncate block">
                {post.author.fullName}
              </span>
              {post.author.headline && (
                <p className="text-[10px] text-muted-foreground truncate">
                  {post.author.headline}
                </p>
              )}
            </div>
          </div>

          {/* Stats Row */}
          <div className="flex items-center justify-between pt-3 border-t border-slate-100 dark:border-slate-800">
            <div className="flex items-center gap-4">
              {/* Like */}
              <button
                onClick={handleLike}
                className="flex items-center gap-1.5 text-muted-foreground hover:text-red-500 transition-colors"
              >
                <Heart
                  className={cn(
                    "h-4 w-4 transition-transform",
                    isLikeAnimating && "scale-125",
                    post.isLiked && "fill-red-500 text-red-500"
                  )}
                />
                <span className="text-xs font-medium tabular-nums">
                  {post.likesCount}
                </span>
              </button>

              {/* Comments */}
              <div className="flex items-center gap-1.5 text-muted-foreground">
                <MessageCircle className="h-4 w-4" />
                <span className="text-xs font-medium tabular-nums">
                  {post.commentsCount}
                </span>
              </div>

              {/* Views */}
              <div className="flex items-center gap-1.5 text-muted-foreground">
                <Eye className="h-3.5 w-3.5" />
                <span className="text-xs font-medium tabular-nums">
                  {post.viewsCount}
                </span>
              </div>

              {/* Save (when no image) */}
              {!hasImage && (
                <button
                  onClick={handleSave}
                  className="flex items-center gap-1.5 text-muted-foreground hover:text-blue-500 transition-colors"
                >
                  <Bookmark
                    className={cn(
                      "h-4 w-4 transition-transform",
                      isSaveAnimating && "scale-125",
                      post.isSaved
                        ? "fill-blue-500 text-blue-500"
                        : ""
                    )}
                  />
                </button>
              )}
            </div>

            {/* Time and arrow */}
            <div className="flex items-center gap-2">
              <span className="text-[10px] text-muted-foreground">
                {post.timeAgo}
              </span>
              <ChevronRight className="h-4 w-4 text-muted-foreground/40 opacity-0 group-hover:opacity-100 transition-all duration-300 group-hover:translate-x-0.5" />
            </div>
          </div>
        </div>
      </article>
    </Link>
  );
});
