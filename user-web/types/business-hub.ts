/**
 * Business Hub Types
 * Business networking platform for entrepreneurs and investors
 */

import { formatDistanceToNow } from "date-fns";

// =============================================================================
// CATEGORIES
// =============================================================================

/**
 * Business Hub post categories
 */
export type BusinessHubCategory =
  | "all"
  | "startups"
  | "investments"
  | "marketing"
  | "tech"
  | "finance"
  | "operations"
  | "hr"
  | "strategy";

/**
 * Category display configuration
 */
export interface BusinessHubCategoryConfig {
  id: BusinessHubCategory;
  label: string;
  gradient: string;
  lightBg: string;
  darkBg: string;
  textColor: string;
}

export const BUSINESS_HUB_CATEGORIES: BusinessHubCategoryConfig[] = [
  {
    id: "all",
    label: "All",
    gradient: "from-slate-400 to-gray-500",
    lightBg: "bg-slate-50",
    darkBg: "dark:bg-slate-950/30",
    textColor: "text-slate-700 dark:text-slate-300",
  },
  {
    id: "startups",
    label: "Startups",
    gradient: "from-orange-400 to-red-500",
    lightBg: "bg-orange-50",
    darkBg: "dark:bg-orange-950/30",
    textColor: "text-orange-700 dark:text-orange-300",
  },
  {
    id: "investments",
    label: "Investments",
    gradient: "from-emerald-400 to-teal-500",
    lightBg: "bg-emerald-50",
    darkBg: "dark:bg-emerald-950/30",
    textColor: "text-emerald-700 dark:text-emerald-300",
  },
  {
    id: "marketing",
    label: "Marketing",
    gradient: "from-pink-400 to-rose-500",
    lightBg: "bg-pink-50",
    darkBg: "dark:bg-pink-950/30",
    textColor: "text-pink-700 dark:text-pink-300",
  },
  {
    id: "tech",
    label: "Tech",
    gradient: "from-blue-400 to-cyan-500",
    lightBg: "bg-blue-50",
    darkBg: "dark:bg-blue-950/30",
    textColor: "text-blue-700 dark:text-blue-300",
  },
  {
    id: "finance",
    label: "Finance",
    gradient: "from-amber-400 to-orange-500",
    lightBg: "bg-amber-50",
    darkBg: "dark:bg-amber-950/30",
    textColor: "text-amber-700 dark:text-amber-300",
  },
  {
    id: "operations",
    label: "Operations",
    gradient: "from-indigo-400 to-blue-500",
    lightBg: "bg-indigo-50",
    darkBg: "dark:bg-indigo-950/30",
    textColor: "text-indigo-700 dark:text-indigo-300",
  },
  {
    id: "hr",
    label: "HR",
    gradient: "from-violet-400 to-purple-500",
    lightBg: "bg-violet-50",
    darkBg: "dark:bg-violet-950/30",
    textColor: "text-violet-700 dark:text-violet-300",
  },
  {
    id: "strategy",
    label: "Strategy",
    gradient: "from-cyan-400 to-blue-500",
    lightBg: "bg-cyan-50",
    darkBg: "dark:bg-cyan-950/30",
    textColor: "text-cyan-700 dark:text-cyan-300",
  },
];

// =============================================================================
// POST TYPES
// =============================================================================

/**
 * Business Hub post as stored in the database
 */
export interface DBBusinessHubPost {
  id: string;
  user_id: string;
  title: string;
  content: string;
  category: string | null;
  tags: string[] | null;
  images: string[] | null;
  company_name: string | null;
  industry: string | null;
  likes_count: number;
  comments_count: number;
  saves_count: number;
  views_count: number;
  is_flagged: boolean;
  is_hidden: boolean;
  status: string;
  created_at: string;
  updated_at: string;
}

/**
 * Business Hub post for UI display
 */
export interface BusinessHubPost {
  id: string;
  userId: string;
  title: string;
  content: string;
  previewText: string;
  category: string | null;
  tags: string[];
  images: string[];
  companyName: string | null;
  industry: string | null;
  likesCount: number;
  commentsCount: number;
  savesCount: number;
  viewsCount: number;
  status: string;
  createdAt: string;
  updatedAt: string;
  timeAgo: string;
  isLiked: boolean;
  isSaved: boolean;
  author: {
    id: string;
    fullName: string;
    avatarUrl: string | null;
    headline: string | null;
  };
}

/**
 * Input for creating a business hub post
 */
export interface CreateBusinessHubPostInput {
  title: string;
  content: string;
  category: string;
  tags: string[];
  companyName?: string;
  industry?: string;
  images?: string[];
}

/**
 * Filters for fetching business hub posts
 */
export interface BusinessHubFilters {
  category?: string;
  search?: string;
  limit?: number;
  offset?: number;
}

// =============================================================================
// TRANSFORMATION UTILITIES
// =============================================================================

/**
 * Transform a database post row (with joined author) to UI format
 */
export function transformBusinessHubPost(dbPost: any): BusinessHubPost {
  const content = dbPost.content || "";
  const previewText =
    content.length > 200 ? content.substring(0, 200) + "..." : content;

  return {
    id: dbPost.id,
    userId: dbPost.user_id,
    title: dbPost.title,
    content,
    previewText,
    category: dbPost.category,
    tags: dbPost.tags || [],
    images: dbPost.images || [],
    companyName: dbPost.company_name || null,
    industry: dbPost.industry || null,
    likesCount: dbPost.likes_count || 0,
    commentsCount: dbPost.comments_count || 0,
    savesCount: dbPost.saves_count || 0,
    viewsCount: dbPost.views_count || 0,
    status: dbPost.status,
    createdAt: dbPost.created_at,
    updatedAt: dbPost.updated_at,
    timeAgo: formatDistanceToNow(new Date(dbPost.created_at), {
      addSuffix: true,
    }),
    isLiked: dbPost.is_liked || false,
    isSaved: dbPost.is_saved || false,
    author: {
      id: dbPost.author?.id || dbPost.user_id,
      fullName: dbPost.author?.full_name || "Anonymous",
      avatarUrl: dbPost.author?.avatar_url || null,
      headline: dbPost.author?.headline || null,
    },
  };
}

/**
 * Get category config by ID
 */
export function getBusinessHubCategoryConfig(
  categoryId: string | null
): BusinessHubCategoryConfig {
  return (
    BUSINESS_HUB_CATEGORIES.find((c) => c.id === categoryId) ||
    BUSINESS_HUB_CATEGORIES[0]
  );
}
