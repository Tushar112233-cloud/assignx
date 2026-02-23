"use client";

/**
 * PostCard - Premium Community Card Design
 *
 * Pinterest-style card with:
 * - Clean white backgrounds with subtle shadows
 * - Category-specific gradient badges
 * - Smooth hover animations
 * - Premium rounded corners
 */

import { memo, useState } from "react";
import Image from "next/image";
import Link from "next/link";
import {
  Heart,
  MessageCircle,
  Bookmark,
  HelpCircle,
  Home,
  Briefcase,
  BookOpen,
  Calendar,
  BadgeCheck,
  Pin,
  ChevronRight,
  ShoppingBag,
  Car,
  Users,
  Trophy,
  Megaphone,
  MessageSquare,
  Search,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import type { CampusConnectPost, CampusConnectCategory } from "@/types/campus-connect";

interface PostCardProps {
  post: CampusConnectPost;
  onLike?: (postId: string) => void;
  onSave?: (postId: string) => void;
  className?: string;
}

/**
 * Category configuration with icons and gradients
 * Must match database enum values exactly
 */
interface CategoryUIConfig {
  label: string;
  icon: React.ElementType;
  gradient: string;
  lightBg: string;
  darkBg: string;
  textColor: string;
}

const categoryConfigs: Record<CampusConnectCategory, CategoryUIConfig> = {
  questions: {
    label: "Question",
    icon: HelpCircle,
    gradient: "from-blue-400 to-cyan-500",
    lightBg: "bg-blue-50",
    darkBg: "dark:bg-blue-950/30",
    textColor: "text-blue-700 dark:text-blue-300",
  },
  housing: {
    label: "Housing",
    icon: Home,
    gradient: "from-emerald-400 to-teal-500",
    lightBg: "bg-emerald-50",
    darkBg: "dark:bg-emerald-950/30",
    textColor: "text-emerald-700 dark:text-emerald-300",
  },
  opportunities: {
    label: "Opportunity",
    icon: Briefcase,
    gradient: "from-purple-400 to-violet-500",
    lightBg: "bg-purple-50",
    darkBg: "dark:bg-purple-950/30",
    textColor: "text-purple-700 dark:text-purple-300",
  },
  resources: {
    label: "Resource",
    icon: BookOpen,
    gradient: "from-pink-400 to-rose-500",
    lightBg: "bg-pink-50",
    darkBg: "dark:bg-pink-950/30",
    textColor: "text-pink-700 dark:text-pink-300",
  },
  events: {
    label: "Event",
    icon: Calendar,
    gradient: "from-cyan-400 to-blue-500",
    lightBg: "bg-cyan-50",
    darkBg: "dark:bg-cyan-950/30",
    textColor: "text-cyan-700 dark:text-cyan-300",
  },
  marketplace: {
    label: "Marketplace",
    icon: ShoppingBag,
    gradient: "from-amber-400 to-orange-500",
    lightBg: "bg-amber-50",
    darkBg: "dark:bg-amber-950/30",
    textColor: "text-amber-700 dark:text-amber-300",
  },
  lost_found: {
    label: "Lost & Found",
    icon: Search,
    gradient: "from-red-400 to-rose-500",
    lightBg: "bg-red-50",
    darkBg: "dark:bg-red-950/30",
    textColor: "text-red-700 dark:text-red-300",
  },
  rides: {
    label: "Ride",
    icon: Car,
    gradient: "from-indigo-400 to-blue-500",
    lightBg: "bg-indigo-50",
    darkBg: "dark:bg-indigo-950/30",
    textColor: "text-indigo-700 dark:text-indigo-300",
  },
  study_groups: {
    label: "Study Group",
    icon: Users,
    gradient: "from-violet-400 to-purple-500",
    lightBg: "bg-violet-50",
    darkBg: "dark:bg-violet-950/30",
    textColor: "text-violet-700 dark:text-violet-300",
  },
  clubs: {
    label: "Club",
    icon: Trophy,
    gradient: "from-yellow-400 to-amber-500",
    lightBg: "bg-yellow-50",
    darkBg: "dark:bg-yellow-950/30",
    textColor: "text-yellow-700 dark:text-yellow-300",
  },
  announcements: {
    label: "Announcement",
    icon: Megaphone,
    gradient: "from-slate-400 to-gray-500",
    lightBg: "bg-slate-50",
    darkBg: "dark:bg-slate-950/30",
    textColor: "text-slate-700 dark:text-slate-300",
  },
  discussions: {
    label: "Discussion",
    icon: MessageSquare,
    gradient: "from-teal-400 to-emerald-500",
    lightBg: "bg-teal-50",
    darkBg: "dark:bg-teal-950/30",
    textColor: "text-teal-700 dark:text-teal-300",
  },
};

/**
 * Get category config with fallback
 */
function getCategoryUIConfig(category: CampusConnectCategory): CategoryUIConfig {
  return categoryConfigs[category] || categoryConfigs.questions;
}

/**
 * PostCard - Premium Pinterest-style card
 */
export const PostCard = memo(function PostCard({
  post,
  onLike,
  onSave,
  className,
}: PostCardProps) {
  const [isLikeAnimating, setIsLikeAnimating] = useState(false);
  const [isSaveAnimating, setIsSaveAnimating] = useState(false);

  const handleLike = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsLikeAnimating(true);
    setTimeout(() => setIsLikeAnimating(false), 300);
    onLike?.(post.id);
  };

  const handleSave = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsSaveAnimating(true);
    setTimeout(() => setIsSaveAnimating(false), 300);
    onSave?.(post.id);
  };

  const categoryConfig = getCategoryUIConfig(post.category);
  const CategoryIcon = categoryConfig.icon;
  const hasImage = post.imageUrls.length > 0;

  return (
    <Link href={`/campus-connect/${post.id}`} className="block group">
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
          <div className="relative aspect-[4/3] overflow-hidden">
            <Image
              src={post.imageUrls[0]}
              alt={post.title}
              fill
              className="object-cover transition-transform duration-500 group-hover:scale-105"
              sizes="(max-width: 640px) 50vw, (max-width: 1024px) 33vw, 25vw"
            />

            {/* Gradient overlay on image */}
            <div className="absolute inset-0 bg-gradient-to-t from-black/30 via-transparent to-transparent" />

            {/* Pinned Badge */}
            {post.isPinned && (
              <div className="absolute top-3 left-3">
                <Badge className="gap-1 bg-white/90 dark:bg-slate-900/90 backdrop-blur-sm text-foreground border-0 shadow-sm">
                  <Pin className="h-3 w-3" />
                  Pinned
                </Badge>
              </div>
            )}

            {/* Category Badge - Top Right */}
            <div className="absolute top-3 right-3">
              <div className={cn(
                "flex items-center gap-1.5 px-2.5 py-1.5 rounded-full backdrop-blur-md",
                "bg-white/95 dark:bg-slate-900/90 shadow-sm"
              )}>
                <div className={cn(
                  "h-5 w-5 rounded-lg bg-gradient-to-br flex items-center justify-center",
                  categoryConfig.gradient
                )}>
                  <CategoryIcon className="h-3 w-3 text-white" strokeWidth={2} />
                </div>
                <span className="text-xs font-medium text-foreground">{categoryConfig.label}</span>
              </div>
            </div>

            {/* Save Button - Overlay */}
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

        {/* Content Section */}
        <div className="relative p-4 space-y-3">
          {/* Category Badge (when no image) */}
          {!hasImage && (
            <div className="flex items-center gap-2 mb-2">
              <div className={cn(
                "flex items-center gap-1.5 px-2.5 py-1.5 rounded-full",
                categoryConfig.lightBg,
                categoryConfig.darkBg
              )}>
                <div className={cn(
                  "h-5 w-5 rounded-lg bg-gradient-to-br flex items-center justify-center",
                  categoryConfig.gradient
                )}>
                  <CategoryIcon className="h-3 w-3 text-white" strokeWidth={2} />
                </div>
                <span className={cn("text-xs font-medium", categoryConfig.textColor)}>
                  {categoryConfig.label}
                </span>
              </div>
              {post.isPinned && (
                <Badge variant="secondary" className="gap-1 rounded-full text-xs">
                  <Pin className="h-3 w-3" />
                  Pinned
                </Badge>
              )}
            </div>
          )}

          {/* Title */}
          <h3 className="font-semibold text-[15px] leading-snug line-clamp-2 text-foreground group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors">
            {post.title}
          </h3>

          {/* Preview Text */}
          <p className="text-xs text-muted-foreground line-clamp-2 leading-relaxed">
            {post.previewText}
          </p>

          {/* Author Info */}
          <div className="flex items-center gap-2.5 pt-1">
            <Avatar className="h-7 w-7 ring-2 ring-white dark:ring-slate-800">
              <AvatarImage src={post.authorAvatar || undefined} alt={post.authorName} />
              <AvatarFallback className="text-[10px] bg-gradient-to-br from-slate-100 to-slate-200 dark:from-slate-700 dark:to-slate-800">
                {post.authorName.slice(0, 2).toUpperCase()}
              </AvatarFallback>
            </Avatar>
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-1">
                <span className="text-xs font-medium text-foreground/80 truncate">
                  {post.authorName}
                </span>
                {post.isAuthorVerified && (
                  <BadgeCheck className="h-3.5 w-3.5 text-blue-500 shrink-0" />
                )}
              </div>
              {post.universityName && (
                <p className="text-[10px] text-muted-foreground truncate">
                  {post.universityName}
                </p>
              )}
            </div>
          </div>

          {/* Stats Row */}
          <div className="flex items-center justify-between pt-3 border-t border-slate-100 dark:border-slate-800">
            <div className="flex items-center gap-4">
              {/* Like Button */}
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
                <span className="text-xs font-medium tabular-nums">{post.likeCount}</span>
              </button>

              {/* Comments */}
              <div className="flex items-center gap-1.5 text-muted-foreground">
                <MessageCircle className="h-4 w-4" />
                <span className="text-xs font-medium tabular-nums">{post.commentCount}</span>
              </div>
            </div>

            {/* Time Ago + Arrow */}
            <div className="flex items-center gap-2">
              <span className="text-[10px] text-muted-foreground">{post.timeAgo}</span>
              <ChevronRight className="h-4 w-4 text-muted-foreground/40 opacity-0 group-hover:opacity-100 transition-all duration-300 group-hover:translate-x-0.5" />
            </div>
          </div>
        </div>
      </article>
    </Link>
  );
});

export default PostCard;
