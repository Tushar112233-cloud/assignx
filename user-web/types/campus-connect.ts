/**
 * Campus Connect Types
 * Pinterest-inspired community platform for verified college students
 *
 * Categories match database enum: campus_post_category
 */

// =============================================================================
// POST CATEGORIES - Must match database enum exactly
// =============================================================================

/**
 * Campus Connect post categories
 * These values MUST match the database enum 'campus_post_category'
 */
export type CampusConnectCategory =
  | "events"        // Campus events, fests, workshops
  | "opportunities" // Jobs, internships, gigs
  | "resources"     // Study materials, notes, tips
  | "lost_found"    // Lost & found items
  | "marketplace"   // Buy/sell items
  | "housing"       // PG, hostel, flat listings
  | "rides"         // Carpool, ride sharing
  | "study_groups"  // Study groups, project teams
  | "clubs"         // Club activities, societies
  | "announcements" // Official announcements
  | "discussions"   // General discussions
  | "questions";    // Academic Q&A, doubts

/**
 * Category configuration with display info
 */
export interface CategoryConfig {
  id: CampusConnectCategory;
  label: string;
  description: string;
  icon: string;
  gradient: string;
  lightBg: string;
  darkBg: string;
  textColor: string;
}

/**
 * All category configurations with gradients for UI
 */
export const CAMPUS_CONNECT_CATEGORIES: CategoryConfig[] = [
  {
    id: "questions",
    label: "Questions",
    description: "Academic Q&A & doubts",
    icon: "HelpCircle",
    gradient: "from-blue-400 to-cyan-500",
    lightBg: "bg-blue-50",
    darkBg: "dark:bg-blue-950/30",
    textColor: "text-blue-700 dark:text-blue-300",
  },
  {
    id: "housing",
    label: "Housing",
    description: "PG, hostel & flat listings",
    icon: "Home",
    gradient: "from-emerald-400 to-teal-500",
    lightBg: "bg-emerald-50",
    darkBg: "dark:bg-emerald-950/30",
    textColor: "text-emerald-700 dark:text-emerald-300",
  },
  {
    id: "opportunities",
    label: "Opportunities",
    description: "Jobs, internships & gigs",
    icon: "Briefcase",
    gradient: "from-purple-400 to-violet-500",
    lightBg: "bg-purple-50",
    darkBg: "dark:bg-purple-950/30",
    textColor: "text-purple-700 dark:text-purple-300",
  },
  {
    id: "resources",
    label: "Resources",
    description: "Study tips & materials",
    icon: "BookOpen",
    gradient: "from-pink-400 to-rose-500",
    lightBg: "bg-pink-50",
    darkBg: "dark:bg-pink-950/30",
    textColor: "text-pink-700 dark:text-pink-300",
  },
  {
    id: "events",
    label: "Events",
    description: "Campus events & fests",
    icon: "Calendar",
    gradient: "from-cyan-400 to-blue-500",
    lightBg: "bg-cyan-50",
    darkBg: "dark:bg-cyan-950/30",
    textColor: "text-cyan-700 dark:text-cyan-300",
  },
  {
    id: "marketplace",
    label: "Marketplace",
    description: "Buy & sell items",
    icon: "ShoppingBag",
    gradient: "from-amber-400 to-orange-500",
    lightBg: "bg-amber-50",
    darkBg: "dark:bg-amber-950/30",
    textColor: "text-amber-700 dark:text-amber-300",
  },
  {
    id: "lost_found",
    label: "Lost & Found",
    description: "Lost or found items",
    icon: "Search",
    gradient: "from-red-400 to-rose-500",
    lightBg: "bg-red-50",
    darkBg: "dark:bg-red-950/30",
    textColor: "text-red-700 dark:text-red-300",
  },
  {
    id: "rides",
    label: "Rides",
    description: "Carpool & ride sharing",
    icon: "Car",
    gradient: "from-indigo-400 to-blue-500",
    lightBg: "bg-indigo-50",
    darkBg: "dark:bg-indigo-950/30",
    textColor: "text-indigo-700 dark:text-indigo-300",
  },
  {
    id: "study_groups",
    label: "Study Groups",
    description: "Study groups & teams",
    icon: "Users",
    gradient: "from-violet-400 to-purple-500",
    lightBg: "bg-violet-50",
    darkBg: "dark:bg-violet-950/30",
    textColor: "text-violet-700 dark:text-violet-300",
  },
  {
    id: "clubs",
    label: "Clubs",
    description: "Club activities & societies",
    icon: "Trophy",
    gradient: "from-yellow-400 to-amber-500",
    lightBg: "bg-yellow-50",
    darkBg: "dark:bg-yellow-950/30",
    textColor: "text-yellow-700 dark:text-yellow-300",
  },
  {
    id: "announcements",
    label: "Announcements",
    description: "Official announcements",
    icon: "Megaphone",
    gradient: "from-slate-400 to-gray-500",
    lightBg: "bg-slate-50",
    darkBg: "dark:bg-slate-950/30",
    textColor: "text-slate-700 dark:text-slate-300",
  },
  {
    id: "discussions",
    label: "Discussions",
    description: "General discussions",
    icon: "MessageSquare",
    gradient: "from-teal-400 to-emerald-500",
    lightBg: "bg-teal-50",
    darkBg: "dark:bg-teal-950/30",
    textColor: "text-teal-700 dark:text-teal-300",
  },
];

// =============================================================================
// DATABASE TYPES
// =============================================================================

/**
 * Database post status
 */
export type PostStatus = "draft" | "published" | "archived" | "flagged" | "active";

/**
 * Database campus connect post
 */
export interface DBCampusConnectPost {
  id: string;
  user_id: string;
  category: CampusConnectCategory;
  title: string;
  content: string;
  images: string[] | null;
  college_id: string | null;
  status: PostStatus;
  is_pinned: boolean;
  is_admin_post: boolean;
  likes_count: number;
  comments_count: number;
  saves_count: number;
  views_count: number;
  location: string | null;
  event_date: string | null;
  event_venue: string | null;
  deadline: string | null;
  price: number | null;
  created_at: string;
  updated_at: string;
}

/**
 * Author profile (joined data)
 */
export interface PostAuthor {
  id: string;
  full_name: string | null;
  avatar_url: string | null;
  is_college_verified: boolean;
}

/**
 * College info (joined data)
 */
export interface PostCollege {
  id: string;
  name: string;
  short_name: string | null;
  city: string | null;
}

/**
 * Database post with relations
 */
export interface DBCampusConnectPostWithRelations extends DBCampusConnectPost {
  author: PostAuthor | null;
  college: PostCollege | null;
  is_liked?: boolean;
  is_saved?: boolean;
}

// =============================================================================
// COMMENT TYPES
// =============================================================================

/**
 * Database comment
 */
export interface DBCampusConnectComment {
  id: string;
  post_id: string;
  user_id: string;
  parent_id: string | null;
  content: string;
  likes_count: number;
  created_at: string;
  updated_at: string;
}

/**
 * Comment with relations
 */
export interface DBCommentWithRelations extends DBCampusConnectComment {
  author: PostAuthor | null;
  replies?: DBCommentWithRelations[];
  is_liked?: boolean;
}

// =============================================================================
// UI TYPES
// =============================================================================

/**
 * Post display type for UI
 */
export interface CampusConnectPost {
  id: string;
  category: CampusConnectCategory;
  title: string;
  content: string;
  previewText: string;
  imageUrls: string[];
  authorId: string;
  authorName: string;
  authorAvatar: string | null;
  isAuthorVerified: boolean;
  universityId: string | null;
  universityName: string | null;
  likeCount: number;
  commentCount: number;
  saveCount: number;
  viewCount: number;
  isLiked: boolean;
  isSaved: boolean;
  isPinned: boolean;
  isAdminPost: boolean;
  createdAt: string;
  timeAgo: string;
  // Optional fields for specific categories
  location?: string | null;
  eventDate?: string | null;
  eventVenue?: string | null;
  deadline?: string | null;
  price?: number | null;
}

/**
 * Comment display type for UI
 */
export interface CampusConnectComment {
  id: string;
  postId: string;
  authorId: string;
  authorName: string;
  authorAvatar: string | null;
  isAuthorVerified: boolean;
  parentId: string | null;
  content: string;
  likeCount: number;
  isLiked: boolean;
  createdAt: string;
  timeAgo: string;
  replies: CampusConnectComment[];
}

// =============================================================================
// FILTER & INPUT TYPES
// =============================================================================

/**
 * Filter options for fetching posts
 */
export interface CampusConnectFilters {
  category?: CampusConnectCategory | "all";
  universityId?: string | null;
  search?: string;
  sortBy?: "recent" | "popular" | "most_comments";
  limit?: number;
  offset?: number;
  /**
   * If true, exclude housing posts from results.
   * Used for non-student users who should not see housing listings.
   */
  excludeHousing?: boolean;
}

/**
 * Input for creating a new post
 */
export interface CreatePostInput {
  category: CampusConnectCategory;
  title: string;
  content: string;
  imageUrls?: string[];
  location?: string;
  eventDate?: string;
  eventVenue?: string;
  deadline?: string;
  price?: number;
}

/**
 * Input for updating a post
 */
export interface UpdatePostInput {
  title?: string;
  content?: string;
  imageUrls?: string[];
  status?: PostStatus;
}

/**
 * Input for creating a comment
 */
export interface CreateCommentInput {
  postId: string;
  content: string;
  parentId?: string | null;
}

// =============================================================================
// TRANSFORMATION UTILITIES
// =============================================================================

import { formatDistanceToNow } from "date-fns";

/**
 * Transform database post to UI format
 */
export function transformDBPostToUI(
  dbPost: DBCampusConnectPostWithRelations
): CampusConnectPost {
  const previewText = dbPost.content.length > 150
    ? dbPost.content.substring(0, 150) + "..."
    : dbPost.content;

  return {
    id: dbPost.id,
    category: dbPost.category,
    title: dbPost.title,
    content: dbPost.content,
    previewText,
    imageUrls: dbPost.images || [],
    authorId: dbPost.user_id,
    authorName: dbPost.author?.full_name || "Anonymous",
    authorAvatar: dbPost.author?.avatar_url || null,
    isAuthorVerified: dbPost.author?.is_college_verified || false,
    universityId: dbPost.college_id,
    universityName: dbPost.college?.name || null,
    likeCount: dbPost.likes_count,
    commentCount: dbPost.comments_count,
    saveCount: dbPost.saves_count,
    viewCount: dbPost.views_count,
    isLiked: dbPost.is_liked || false,
    isSaved: dbPost.is_saved || false,
    isPinned: dbPost.is_pinned,
    isAdminPost: dbPost.is_admin_post,
    createdAt: dbPost.created_at,
    timeAgo: formatDistanceToNow(new Date(dbPost.created_at), { addSuffix: true }),
    location: dbPost.location,
    eventDate: dbPost.event_date,
    eventVenue: dbPost.event_venue,
    deadline: dbPost.deadline,
    price: dbPost.price,
  };
}

/**
 * Transform database comment to UI format
 */
export function transformDBCommentToUI(
  dbComment: DBCommentWithRelations
): CampusConnectComment {
  return {
    id: dbComment.id,
    postId: dbComment.post_id,
    authorId: dbComment.user_id,
    authorName: dbComment.author?.full_name || "Anonymous",
    authorAvatar: dbComment.author?.avatar_url || null,
    isAuthorVerified: dbComment.author?.is_college_verified || false,
    parentId: dbComment.parent_id,
    content: dbComment.content,
    likeCount: dbComment.likes_count,
    isLiked: dbComment.is_liked || false,
    createdAt: dbComment.created_at,
    timeAgo: formatDistanceToNow(new Date(dbComment.created_at), { addSuffix: true }),
    replies: (dbComment.replies || []).map(transformDBCommentToUI),
  };
}

/**
 * Get category config by ID
 */
export function getCategoryConfig(categoryId: CampusConnectCategory): CategoryConfig {
  return CAMPUS_CONNECT_CATEGORIES.find(c => c.id === categoryId) || CAMPUS_CONNECT_CATEGORIES[0];
}

/**
 * Get featured categories for hero section (most commonly used)
 */
export function getFeaturedCategories(): CategoryConfig[] {
  const featured: CampusConnectCategory[] = ["questions", "housing", "opportunities", "events", "marketplace", "resources"];
  return featured.map(id => getCategoryConfig(id));
}
