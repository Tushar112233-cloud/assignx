"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";
import type {
  CampusConnectCategory,
  CampusConnectFilters,
  CampusConnectPost,
  CampusConnectComment,
  CreatePostInput,
  UpdatePostInput,
  CreateCommentInput,
  DBCampusConnectPostWithRelations,
  DBCommentWithRelations,
  transformDBPostToUI,
  transformDBCommentToUI,
} from "@/types/campus-connect";
import { formatDistanceToNow } from "date-fns";

// =============================================================================
// TRANSFORMATION UTILITIES (Server-side)
// =============================================================================

/**
 * Transform database post to UI format (server-side version)
 * Maps DB column names to UI property names
 */
function transformPost(dbPost: any): CampusConnectPost {
  const content = dbPost.content || "";
  const previewText = content.length > 150
    ? content.substring(0, 150) + "..."
    : content;

  return {
    id: dbPost.id,
    category: dbPost.category,
    title: dbPost.title,
    content: content,
    previewText,
    imageUrls: dbPost.images || [], // DB uses 'images', UI uses 'imageUrls'
    authorId: dbPost.user_id, // DB uses 'user_id', UI uses 'authorId'
    authorName: dbPost.author?.full_name || "Anonymous",
    authorAvatar: dbPost.author?.avatar_url || null,
    isAuthorVerified: dbPost.author?.is_college_verified || false,
    universityId: dbPost.college_id, // DB uses 'college_id', UI uses 'universityId'
    universityName: dbPost.college?.name || null, // DB uses 'college', UI uses 'university'
    likeCount: dbPost.likes_count || 0, // DB uses 'likes_count', UI uses 'likeCount'
    commentCount: dbPost.comments_count || 0, // DB uses 'comments_count'
    saveCount: dbPost.saves_count || 0, // DB uses 'saves_count'
    viewCount: dbPost.views_count || 0, // DB uses 'views_count'
    isLiked: dbPost.is_liked || false,
    isSaved: dbPost.is_saved || false,
    isPinned: dbPost.is_pinned || false,
    isAdminPost: dbPost.is_admin_post || false,
    createdAt: dbPost.created_at,
    timeAgo: formatDistanceToNow(new Date(dbPost.created_at), { addSuffix: true }),
  };
}

/**
 * Transform database comment to UI format (server-side version)
 * Maps DB column names to UI property names
 */
function transformComment(dbComment: any): CampusConnectComment {
  return {
    id: dbComment.id,
    postId: dbComment.post_id,
    authorId: dbComment.user_id, // DB uses 'user_id', UI uses 'authorId'
    authorName: dbComment.author?.full_name || "Anonymous",
    authorAvatar: dbComment.author?.avatar_url || null,
    isAuthorVerified: dbComment.author?.is_college_verified || false,
    parentId: dbComment.parent_id,
    content: dbComment.content,
    likeCount: dbComment.likes_count || 0, // DB uses 'likes_count', UI uses 'likeCount'
    isLiked: dbComment.is_liked || false,
    createdAt: dbComment.created_at,
    timeAgo: formatDistanceToNow(new Date(dbComment.created_at), { addSuffix: true }),
    replies: (dbComment.replies || []).map(transformComment),
  };
}

// =============================================================================
// POST OPERATIONS
// =============================================================================

/**
 * Get campus connect posts with filtering, search, and pagination
 */
export async function getCampusConnectPosts(
  filters: CampusConnectFilters = {}
): Promise<{ data: CampusConnectPost[]; total: number; error: string | null }> {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  try {
    // Build base query - using correct FK column names
    // Note: Foreign key hints use the column name that references the foreign table
    let query = supabase
      .from("campus_posts")
      .select(`
        *,
        author:profiles (
          id,
          full_name,
          avatar_url,
          is_college_verified
        ),
        college:colleges (
          id,
          name,
          short_name,
          city
        )
      `, { count: "exact" })
      // Include active, published posts and also those without status (for backwards compatibility)
      // Database default is 'active', app creates with 'published'
      .or("status.eq.active,status.is.null");

    // Category filter
    if (filters.category && filters.category !== "all") {
      query = query.eq("category", filters.category);
    }

    // Exclude housing for non-students (server-side enforcement)
    // This provides an additional layer of security beyond client-side filtering
    if (filters.excludeHousing) {
      query = query.neq("category", "housing");
    }

    // College filter (UI uses universityId, DB uses college_id)
    if (filters.universityId) {
      query = query.eq("college_id", filters.universityId);
    }

    // Search in title and content
    if (filters.search) {
      const searchTerm = `%${filters.search}%`;
      query = query.or(`title.ilike.${searchTerm},content.ilike.${searchTerm}`);
    }

    // Sorting - use correct DB column names
    switch (filters.sortBy) {
      case "popular":
        query = query.order("likes_count", { ascending: false });
        break;
      case "most_comments":
        query = query.order("comments_count", { ascending: false });
        break;
      case "recent":
      default:
        // Pinned posts first, then by date
        query = query
          .order("is_pinned", { ascending: false })
          .order("created_at", { ascending: false });
    }

    // Pagination
    const limit = filters.limit || 20;
    const offset = filters.offset || 0;
    query = query.range(offset, offset + limit - 1);

    const { data: posts, error, count } = await query;

    if (error) {
      console.error("Error fetching campus connect posts:", error);
      return { data: [], total: 0, error: error.message };
    }

    // Transform posts
    let transformedPosts = (posts || []).map((post: any) => transformPost(post));

    // Check user interactions (likes/saves)
    if (user && transformedPosts.length > 0) {
      const postIds = transformedPosts.map(p => p.id);

      // Get likes
      const { data: likes } = await supabase
        .from("campus_post_likes")
        .select("post_id")
        .eq("user_id", user.id)
        .in("post_id", postIds);

      // Get saves
      const { data: saves } = await supabase
        .from("campus_saved_posts")
        .select("post_id")
        .eq("user_id", user.id)
        .in("post_id", postIds);

      const likedIds = new Set(likes?.map(l => l.post_id) || []);
      const savedIds = new Set(saves?.map(s => s.post_id) || []);

      transformedPosts = transformedPosts.map(post => ({
        ...post,
        isLiked: likedIds.has(post.id),
        isSaved: savedIds.has(post.id),
      }));
    }

    return { data: transformedPosts, total: count || 0, error: null };
  } catch (error: any) {
    console.error("Unexpected error fetching posts:", error);
    return { data: [], total: 0, error: error.message };
  }
}

/**
 * Get a single post by ID
 */
export async function getCampusConnectPostById(
  postId: string
): Promise<{ data: CampusConnectPost | null; error: string | null }> {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  try {
    const { data: post, error } = await supabase
      .from("campus_posts")
      .select(`
        *,
        author:profiles (
          id,
          full_name,
          avatar_url,
          is_college_verified
        ),
        college:colleges (
          id,
          name,
          short_name,
          city
        )
      `)
      .eq("id", postId)
      .or("status.eq.active,status.eq.published,status.is.null")
      .single();

    if (error) {
      return { data: null, error: error.message };
    }

    // Increment view count (using correct DB column name)
    await supabase
      .from("campus_posts")
      .update({ views_count: (post.views_count || 0) + 1 })
      .eq("id", postId);

    let transformedPost = transformPost(post);

    // Check user interactions
    if (user) {
      const [likeResult, saveResult] = await Promise.all([
        supabase
          .from("campus_post_likes")
          .select("id")
          .eq("user_id", user.id)
          .eq("post_id", postId)
          .single(),
        supabase
          .from("campus_saved_posts")
          .select("id")
          .eq("user_id", user.id)
          .eq("post_id", postId)
          .single(),
      ]);

      transformedPost = {
        ...transformedPost,
        isLiked: !!likeResult.data,
        isSaved: !!saveResult.data,
      };
    }

    return { data: transformedPost, error: null };
  } catch (error: any) {
    return { data: null, error: error.message };
  }
}

/**
 * Create a new post
 */
export async function createCampusConnectPost(
  input: CreatePostInput
): Promise<{ data: { id: string } | null; error: string | null }> {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { data: null, error: "Not authenticated" };
  }

  // Check if user is college verified
  const { data: profile } = await supabase
    .from("profiles")
    .select("is_college_verified")
    .eq("id", user.id)
    .single();

  if (!profile?.is_college_verified) {
    return { data: null, error: "Only verified college students can create posts" };
  }

  // Validate input
  if (!input.title || input.title.trim().length === 0) {
    return { data: null, error: "Title is required" };
  }
  if (!input.content || input.content.trim().length === 0) {
    return { data: null, error: "Content is required" };
  }

  try {
    // Get user's college from profile
    const { data: userProfile } = await supabase
      .from("profiles")
      .select("college_id")
      .eq("id", user.id)
      .single();

    const { data: post, error } = await supabase
      .from("campus_posts")
      .insert({
        user_id: user.id, // DB uses 'user_id', not 'author_id'
        category: input.category,
        title: input.title.trim(),
        content: input.content.trim(),
        images: input.imageUrls || [], // DB uses 'images', not 'image_urls'
        college_id: userProfile?.college_id || null, // DB uses 'college_id', not 'university_id'
        status: "active",
        is_pinned: false,
        is_admin_post: false,
        likes_count: 0, // DB uses 'likes_count', not 'like_count'
        comments_count: 0,
        saves_count: 0,
        views_count: 0,
      })
      .select("id")
      .single();

    if (error) {
      return { data: null, error: error.message };
    }

    revalidatePath("/campus-connect");
    return { data: { id: post.id }, error: null };
  } catch (error: any) {
    return { data: null, error: error.message };
  }
}

/**
 * Update a post
 */
export async function updateCampusConnectPost(
  postId: string,
  input: UpdatePostInput
): Promise<{ success: boolean; error: string | null }> {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { success: false, error: "Not authenticated" };
  }

  try {
    // Verify ownership (DB uses 'user_id', not 'author_id')
    const { data: existing } = await supabase
      .from("campus_posts")
      .select("user_id")
      .eq("id", postId)
      .single();

    if (!existing || existing.user_id !== user.id) {
      return { success: false, error: "Post not found or access denied" };
    }

    const updateData: Record<string, any> = {
      updated_at: new Date().toISOString(),
    };

    if (input.title !== undefined) updateData.title = input.title.trim();
    if (input.content !== undefined) updateData.content = input.content.trim();
    if (input.imageUrls !== undefined) updateData.images = input.imageUrls; // DB uses 'images'
    if (input.status !== undefined) updateData.status = input.status;

    const { error } = await supabase
      .from("campus_posts")
      .update(updateData)
      .eq("id", postId);

    if (error) {
      return { success: false, error: error.message };
    }

    revalidatePath("/campus-connect");
    revalidatePath(`/campus-connect/${postId}`);
    return { success: true, error: null };
  } catch (error: any) {
    return { success: false, error: error.message };
  }
}

/**
 * Delete a post (soft delete)
 */
export async function deleteCampusConnectPost(
  postId: string
): Promise<{ success: boolean; error: string | null }> {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { success: false, error: "Not authenticated" };
  }

  try {
    // Verify ownership (DB uses 'user_id', not 'author_id')
    const { data: existing } = await supabase
      .from("campus_posts")
      .select("user_id")
      .eq("id", postId)
      .single();

    if (!existing || existing.user_id !== user.id) {
      return { success: false, error: "Post not found or access denied" };
    }

    const { error } = await supabase
      .from("campus_posts")
      .update({ status: "archived", updated_at: new Date().toISOString() })
      .eq("id", postId);

    if (error) {
      return { success: false, error: error.message };
    }

    revalidatePath("/campus-connect");
    return { success: true, error: null };
  } catch (error: any) {
    return { success: false, error: error.message };
  }
}

// =============================================================================
// INTERACTION OPERATIONS
// =============================================================================

/**
 * Toggle like on a post
 */
export async function togglePostLike(
  postId: string
): Promise<{ success: boolean; isLiked: boolean; error: string | null }> {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { success: false, isLiked: false, error: "Not authenticated" };
  }

  try {
    // Check if already liked
    const { data: existing } = await supabase
      .from("campus_post_likes")
      .select("id")
      .eq("user_id", user.id)
      .eq("post_id", postId)
      .single();

    if (existing) {
      // Unlike - count is updated automatically by trigger
      await supabase
        .from("campus_post_likes")
        .delete()
        .eq("id", existing.id);

      return { success: true, isLiked: false, error: null };
    } else {
      // Like - count is updated automatically by trigger
      await supabase
        .from("campus_post_likes")
        .insert({ user_id: user.id, post_id: postId });

      return { success: true, isLiked: true, error: null };
    }
  } catch (error: any) {
    return { success: false, isLiked: false, error: error.message };
  }
}

/**
 * Toggle save on a post
 */
export async function togglePostSave(
  postId: string
): Promise<{ success: boolean; isSaved: boolean; error: string | null }> {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { success: false, isSaved: false, error: "Not authenticated" };
  }

  try {
    // Check if already saved
    const { data: existing } = await supabase
      .from("campus_saved_posts")
      .select("id")
      .eq("user_id", user.id)
      .eq("post_id", postId)
      .single();

    if (existing) {
      // Unsave - count is updated automatically by trigger
      await supabase
        .from("campus_saved_posts")
        .delete()
        .eq("id", existing.id);

      return { success: true, isSaved: false, error: null };
    } else {
      // Save - count is updated automatically by trigger
      await supabase
        .from("campus_saved_posts")
        .insert({ user_id: user.id, post_id: postId });

      return { success: true, isSaved: true, error: null };
    }
  } catch (error: any) {
    return { success: false, isSaved: false, error: error.message };
  }
}

// =============================================================================
// COMMENT OPERATIONS
// =============================================================================

/**
 * Get comments for a post
 */
export async function getPostComments(
  postId: string
): Promise<{ data: CampusConnectComment[]; error: string | null }> {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  try {
    // Get top-level comments
    const { data: comments, error } = await supabase
      .from("campus_post_comments")
      .select(`
        *,
        author:profiles (
          id,
          full_name,
          avatar_url,
          is_college_verified
        )
      `)
      .eq("post_id", postId)
      .is("parent_id", null)
      .order("created_at", { ascending: true });

    if (error) {
      return { data: [], error: error.message };
    }

    // Get all replies
    const { data: replies } = await supabase
      .from("campus_post_comments")
      .select(`
        *,
        author:profiles (
          id,
          full_name,
          avatar_url,
          is_college_verified
        )
      `)
      .eq("post_id", postId)
      .not("parent_id", "is", null)
      .order("created_at", { ascending: true });

    // Comment likes feature not yet implemented in database
    // Skip checking liked comments for now
    const likedCommentIds = new Set<string>();

    // Build nested structure
    const repliesByParent = new Map<string, any[]>();
    (replies || []).forEach(reply => {
      const parentId = reply.parent_id;
      if (!repliesByParent.has(parentId)) {
        repliesByParent.set(parentId, []);
      }
      repliesByParent.get(parentId)!.push({
        ...reply,
        is_liked: likedCommentIds.has(reply.id),
      });
    });

    const transformedComments = (comments || []).map(comment => {
      const commentReplies = repliesByParent.get(comment.id) || [];
      return transformComment({
        ...comment,
        is_liked: likedCommentIds.has(comment.id),
        replies: commentReplies,
      });
    });

    return { data: transformedComments, error: null };
  } catch (error: any) {
    return { data: [], error: error.message };
  }
}

/**
 * Create a comment
 */
export async function createComment(
  input: CreateCommentInput
): Promise<{ data: CampusConnectComment | null; error: string | null }> {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { data: null, error: "Not authenticated" };
  }

  // Check if user is college verified
  const { data: profile } = await supabase
    .from("profiles")
    .select("is_college_verified, full_name, avatar_url")
    .eq("id", user.id)
    .single();

  if (!profile?.is_college_verified) {
    return { data: null, error: "Only verified college students can comment" };
  }

  if (!input.content || input.content.trim().length === 0) {
    return { data: null, error: "Comment content is required" };
  }

  try {
    const { data: comment, error } = await supabase
      .from("campus_post_comments")
      .insert({
        post_id: input.postId,
        user_id: user.id, // DB uses 'user_id', not 'author_id'
        parent_id: input.parentId || null,
        content: input.content.trim(),
        likes_count: 0, // DB uses 'likes_count', not 'like_count'
      })
      .select()
      .single();

    if (error) {
      return { data: null, error: error.message };
    }

    // Note: Comment count is updated automatically by database trigger

    const transformedComment = transformComment({
      ...comment,
      author: {
        id: user.id,
        full_name: profile.full_name,
        avatar_url: profile.avatar_url,
        is_college_verified: profile.is_college_verified,
      },
      is_liked: false,
      replies: [],
    });

    revalidatePath(`/campus-connect/${input.postId}`);
    return { data: transformedComment, error: null };
  } catch (error: any) {
    return { data: null, error: error.message };
  }
}

/**
 * Toggle like on a comment
 * Note: Comment likes feature is not yet implemented in the database
 */
export async function toggleCommentLike(
  commentId: string
): Promise<{ success: boolean; isLiked: boolean; error: string | null }> {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { success: false, isLiked: false, error: "Not authenticated" };
  }

  // Comment likes feature not yet available
  // The campus_post_comment_likes table doesn't exist in the database
  return {
    success: false,
    isLiked: false,
    error: "Comment likes feature coming soon"
  };
}

// =============================================================================
// UTILITY OPERATIONS
// =============================================================================

/**
 * Get universities for filter dropdown
 */
export async function getUniversities(): Promise<{
  data: Array<{ id: string; name: string; shortName: string | null }>;
  error: string | null;
}> {
  const supabase = await createClient();

  try {
    const { data: universities, error } = await supabase
      .from("universities")
      .select("id, name, short_name")
      .order("name", { ascending: true });

    if (error) {
      return { data: [], error: error.message };
    }

    return {
      data: (universities || []).map(u => ({
        id: u.id,
        name: u.name,
        shortName: u.short_name,
      })),
      error: null,
    };
  } catch (error: any) {
    return { data: [], error: error.message };
  }
}

/**
 * Check if current user is college verified
 */
export async function checkCollegeVerification(): Promise<{
  isVerified: boolean;
  error: string | null;
}> {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { isVerified: false, error: "Not authenticated" };
  }

  try {
    const { data: profile, error } = await supabase
      .from("profiles")
      .select("is_college_verified")
      .eq("id", user.id)
      .single();

    if (error) {
      return { isVerified: false, error: error.message };
    }

    return { isVerified: profile?.is_college_verified || false, error: null };
  } catch (error: any) {
    return { isVerified: false, error: error.message };
  }
}

/**
 * Upload image for campus connect post
 */
export async function uploadCampusConnectImage(file: {
  name: string;
  type: string;
  size: number;
  base64Data: string;
}): Promise<{ data: { url: string } | null; error: string | null }> {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { data: null, error: "Not authenticated" };
  }

  // Validate file
  const MAX_SIZE = 5 * 1024 * 1024; // 5MB
  const ALLOWED_TYPES = ["image/jpeg", "image/png", "image/webp", "image/gif"];

  if (file.size > MAX_SIZE) {
    return { data: null, error: "File size must be less than 5MB" };
  }

  if (!ALLOWED_TYPES.includes(file.type)) {
    return { data: null, error: "Only JPEG, PNG, WebP, and GIF images are allowed" };
  }

  try {
    // Dynamic import for cloudinary (server-side only)
    const { v2: cloudinary } = await import("cloudinary");

    cloudinary.config({
      cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
      api_key: process.env.CLOUDINARY_API_KEY,
      api_secret: process.env.CLOUDINARY_API_SECRET,
      secure: true,
    });

    const folder = `assignx/campus-connect/${user.id}`;
    const result = await cloudinary.uploader.upload(
      `data:${file.type};base64,${file.base64Data}`,
      {
        folder,
        resource_type: "image",
        use_filename: true,
        unique_filename: true,
      }
    );

    return { data: { url: result.secure_url }, error: null };
  } catch (error: any) {
    console.error("Cloudinary upload error:", error);
    return { data: null, error: error.message || "Failed to upload image" };
  }
}

// =============================================================================
// REPORT & SAVED LISTINGS OPERATIONS
// =============================================================================

/**
 * Report a listing
 * @param listingId - The ID of the listing to report
 * @param reason - The reason for reporting (scam, inappropriate, inaccurate, spam, other)
 * @param details - Optional additional details about the report
 */
export async function reportListing(
  listingId: string,
  reason: string,
  details?: string
): Promise<{ success: boolean; error: string | null }> {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { success: false, error: "Not authenticated" };
  }

  // Validate reason
  const validReasons = ["scam", "inappropriate", "inaccurate", "spam", "other"];
  if (!validReasons.includes(reason)) {
    return { success: false, error: "Invalid report reason" };
  }

  try {
    // Check if user already reported this listing
    const { data: existing } = await supabase
      .from("listing_reports")
      .select("id")
      .eq("listing_id", listingId)
      .eq("reporter_id", user.id)
      .single();

    if (existing) {
      return { success: false, error: "You have already reported this listing" };
    }

    // Create report
    const { error } = await supabase
      .from("listing_reports")
      .insert({
        listing_id: listingId,
        reporter_id: user.id,
        reason,
        details: details?.trim() || null,
        status: "pending",
      });

    if (error) {
      console.error("Error creating report:", error);
      return { success: false, error: error.message };
    }

    return { success: true, error: null };
  } catch (error: any) {
    console.error("Unexpected error reporting listing:", error);
    return { success: false, error: error.message };
  }
}

/**
 * Save a listing to user's saved items
 * @param listingId - The ID of the listing to save
 */
export async function saveListing(
  listingId: string
): Promise<{ success: boolean; error: string | null }> {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { success: false, error: "Not authenticated" };
  }

  try {
    // Check if already saved
    const { data: existing } = await supabase
      .from("saved_listings")
      .select("id")
      .eq("listing_id", listingId)
      .eq("user_id", user.id)
      .single();

    if (existing) {
      return { success: false, error: "Listing already saved" };
    }

    // Save the listing
    const { error } = await supabase
      .from("saved_listings")
      .insert({
        listing_id: listingId,
        user_id: user.id,
      });

    if (error) {
      console.error("Error saving listing:", error);
      return { success: false, error: error.message };
    }

    revalidatePath("/campus-connect");
    revalidatePath("/campus-connect/saved");
    return { success: true, error: null };
  } catch (error: any) {
    console.error("Unexpected error saving listing:", error);
    return { success: false, error: error.message };
  }
}

/**
 * Remove a listing from user's saved items
 * @param listingId - The ID of the listing to unsave
 */
export async function unsaveListing(
  listingId: string
): Promise<{ success: boolean; error: string | null }> {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { success: false, error: "Not authenticated" };
  }

  try {
    const { error } = await supabase
      .from("saved_listings")
      .delete()
      .eq("listing_id", listingId)
      .eq("user_id", user.id);

    if (error) {
      console.error("Error unsaving listing:", error);
      return { success: false, error: error.message };
    }

    revalidatePath("/campus-connect");
    revalidatePath("/campus-connect/saved");
    return { success: true, error: null };
  } catch (error: any) {
    console.error("Unexpected error unsaving listing:", error);
    return { success: false, error: error.message };
  }
}

/**
 * Get all saved listings for the current user
 */
export async function getSavedListings(): Promise<{
  data: CampusConnectPost[];
  error: string | null;
}> {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { data: [], error: "Not authenticated" };
  }

  try {
    // Get saved listing IDs for this user
    const { data: savedItems, error: savedError } = await supabase
      .from("saved_listings")
      .select("listing_id, created_at")
      .eq("user_id", user.id)
      .order("created_at", { ascending: false });

    if (savedError) {
      console.error("Error fetching saved listings:", savedError);
      return { data: [], error: savedError.message };
    }

    if (!savedItems || savedItems.length === 0) {
      return { data: [], error: null };
    }

    const listingIds = savedItems.map((s) => s.listing_id);

    // Fetch the full post data for saved listings
    const { data: posts, error: postsError } = await supabase
      .from("campus_posts")
      .select(`
        *,
        author:profiles (
          id,
          full_name,
          avatar_url,
          is_college_verified
        ),
        college:colleges (
          id,
          name,
          short_name,
          city
        )
      `)
      .in("id", listingIds)
      .or("status.eq.active,status.is.null");

    if (postsError) {
      console.error("Error fetching saved posts:", postsError);
      return { data: [], error: postsError.message };
    }

    // Transform posts and mark as saved
    const transformedPosts = (posts || []).map((post: any) => {
      const content = post.content || "";
      const previewText = content.length > 150
        ? content.substring(0, 150) + "..."
        : content;

      return {
        id: post.id,
        category: post.category,
        title: post.title,
        content: content,
        previewText,
        imageUrls: post.images || [],
        authorId: post.user_id,
        authorName: post.author?.full_name || "Anonymous",
        authorAvatar: post.author?.avatar_url || null,
        isAuthorVerified: post.author?.is_college_verified || false,
        universityId: post.college_id,
        universityName: post.college?.name || null,
        likeCount: post.likes_count || 0,
        commentCount: post.comments_count || 0,
        saveCount: post.saves_count || 0,
        viewCount: post.views_count || 0,
        isLiked: false, // Will check below
        isSaved: true, // These are saved posts
        isPinned: post.is_pinned || false,
        isAdminPost: post.is_admin_post || false,
        createdAt: post.created_at,
        timeAgo: formatDistanceToNow(new Date(post.created_at), { addSuffix: true }),
      };
    });

    // Check likes for these posts
    if (transformedPosts.length > 0) {
      const { data: likes } = await supabase
        .from("campus_post_likes")
        .select("post_id")
        .eq("user_id", user.id)
        .in("post_id", listingIds);

      const likedIds = new Set(likes?.map((l) => l.post_id) || []);

      transformedPosts.forEach((post) => {
        post.isLiked = likedIds.has(post.id);
      });
    }

    // Sort by saved order (most recently saved first)
    const savedOrder = new Map(savedItems.map((s, i) => [s.listing_id, i]));
    transformedPosts.sort((a, b) => {
      const orderA = savedOrder.get(a.id) ?? 999;
      const orderB = savedOrder.get(b.id) ?? 999;
      return orderA - orderB;
    });

    return { data: transformedPosts, error: null };
  } catch (error: any) {
    console.error("Unexpected error fetching saved listings:", error);
    return { data: [], error: error.message };
  }
}

/**
 * Check if a listing has been reported by the current user
 * @param listingId - The ID of the listing to check
 */
export async function hasUserReportedListing(
  listingId: string
): Promise<{ isReported: boolean; error: string | null }> {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { isReported: false, error: null };
  }

  try {
    const { data: report } = await supabase
      .from("listing_reports")
      .select("id")
      .eq("listing_id", listingId)
      .eq("reporter_id", user.id)
      .single();

    return { isReported: !!report, error: null };
  } catch (error: any) {
    return { isReported: false, error: null };
  }
}

/**
 * Check if a listing is saved by the current user
 * @param listingId - The ID of the listing to check
 */
export async function isListingSaved(
  listingId: string
): Promise<{ isSaved: boolean; error: string | null }> {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { isSaved: false, error: null };
  }

  try {
    const { data: saved } = await supabase
      .from("saved_listings")
      .select("id")
      .eq("listing_id", listingId)
      .eq("user_id", user.id)
      .single();

    return { isSaved: !!saved, error: null };
  } catch (error: any) {
    return { isSaved: false, error: null };
  }
}
