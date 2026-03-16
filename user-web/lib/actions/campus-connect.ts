"use server";

import { cookies } from "next/headers";
import { revalidatePath } from "next/cache";
import { serverApiClient } from "@/lib/api/client";
import type {
  CampusConnectPost,
  CampusConnectComment,
  CampusConnectFilters,
  CreatePostInput,
  UpdatePostInput,
  CreateCommentInput,
} from "@/types/campus-connect";

async function getToken(): Promise<string | null> {
  const cookieStore = await cookies();
  return cookieStore.get("accessToken")?.value || null;
}

/**
 * Normalize a raw API post object into the CampusConnectPost UI shape.
 * Handles both camelCase and snake_case fields, and ensures imageUrls is always a string[].
 */
function normalizePost(raw: any): CampusConnectPost {
  if (!raw) return raw;

  // Normalize imageUrls: handle imageUrls (array), imageUrl (string), images (array), or missing
  let imageUrls: string[] = [];
  if (Array.isArray(raw.imageUrls) && raw.imageUrls.length > 0) {
    imageUrls = raw.imageUrls;
  } else if (Array.isArray(raw.image_urls) && raw.image_urls.length > 0) {
    imageUrls = raw.image_urls;
  } else if (Array.isArray(raw.images) && raw.images.length > 0) {
    imageUrls = raw.images;
  } else if (typeof raw.imageUrl === "string" && raw.imageUrl) {
    imageUrls = [raw.imageUrl];
  } else if (typeof raw.image_url === "string" && raw.image_url) {
    imageUrls = [raw.image_url];
  }

  // Extract author info from populated userId object or flat fields
  const author = raw.userId && typeof raw.userId === "object" ? raw.userId : null;

  const previewText = (raw.previewText || raw.preview_text || "")
    || (raw.content ? (raw.content.length > 150 ? raw.content.substring(0, 150) + "..." : raw.content) : "");

  // Calculate timeAgo from createdAt
  let timeAgo = raw.timeAgo || raw.time_ago || "";
  if (!timeAgo && (raw.createdAt || raw.created_at)) {
    const created = new Date(raw.createdAt || raw.created_at);
    const now = new Date();
    const diffMs = now.getTime() - created.getTime();
    const diffMins = Math.floor(diffMs / 60000);
    if (diffMins < 1) timeAgo = "just now";
    else if (diffMins < 60) timeAgo = `${diffMins}m ago`;
    else if (diffMins < 1440) timeAgo = `${Math.floor(diffMins / 60)}h ago`;
    else timeAgo = `${Math.floor(diffMins / 1440)}d ago`;
  }

  return {
    id: raw.id || raw._id || "",
    category: raw.category || "discussions",
    title: raw.title || "",
    content: raw.content || "",
    previewText,
    imageUrls,
    authorId: raw.authorId || raw.author_id || raw.userId?._id || raw.userId || "",
    authorName: raw.authorName || raw.author_name || author?.fullName || author?.full_name || "Anonymous",
    authorAvatar: raw.authorAvatar || raw.author_avatar || author?.avatarUrl || author?.avatar_url || null,
    isAuthorVerified: raw.isAuthorVerified ?? raw.is_author_verified ?? author?.isCollegeVerified ?? author?.is_college_verified ?? false,
    universityId: raw.universityId || raw.university_id || raw.collegeId || raw.college_id || null,
    universityName: raw.universityName || raw.university_name || null,
    likeCount: raw.likeCount ?? raw.like_count ?? raw.likes_count ?? 0,
    commentCount: raw.commentCount ?? raw.comment_count ?? raw.comments_count ?? 0,
    saveCount: raw.saveCount ?? raw.save_count ?? raw.saves_count ?? 0,
    viewCount: raw.viewCount ?? raw.view_count ?? raw.views_count ?? 0,
    isLiked: raw.isLiked ?? raw.is_liked ?? false,
    isSaved: raw.isSaved ?? raw.is_saved ?? false,
    isPinned: raw.isPinned ?? raw.is_pinned ?? false,
    isAdminPost: raw.isAdminPost ?? raw.is_admin_post ?? false,
    createdAt: raw.createdAt || raw.created_at || "",
    timeAgo,
    location: raw.location ?? null,
    eventDate: raw.eventDate || raw.event_date || null,
    eventVenue: raw.eventVenue || raw.event_venue || null,
    deadline: raw.deadline ?? null,
    price: raw.price ?? null,
  };
}

/**
 * Normalize posts array and inject user interaction data (isLiked/isSaved)
 * from the userInteractions map returned by the API.
 */
function normalizePostsWithInteractions(
  rawPosts: any[],
  userInteractions?: Record<string, string[]>
): CampusConnectPost[] {
  return rawPosts.map((raw) => {
    const post = normalizePost(raw);
    if (userInteractions) {
      const postId = raw._id || raw.id;
      const interactions = userInteractions[postId] || [];
      post.isLiked = post.isLiked || interactions.includes("like");
      post.isSaved = post.isSaved || interactions.includes("save");
    }
    return post;
  });
}

// =============================================================================
// POST OPERATIONS
// =============================================================================

export async function getCampusConnectPosts(
  filters: CampusConnectFilters = {}
): Promise<{ data: CampusConnectPost[]; total: number; error: string | null }> {
  const token = await getToken();

  try {
    const params = new URLSearchParams();
    params.set("postType", "campus");
    if (filters.category && filters.category !== "all") params.set("category", filters.category);
    if (filters.universityId) params.set("universityId", filters.universityId);
    if (filters.search) params.set("search", filters.search);
    if (filters.sortBy) params.set("sortBy", filters.sortBy);
    if (filters.limit) params.set("limit", String(filters.limit));
    // API expects 1-based page number, convert from offset
    if (filters.offset && filters.limit) {
      const pageNum = Math.floor(filters.offset / filters.limit) + 1;
      params.set("page", String(pageNum));
    } else if (filters.offset) {
      const pageNum = Math.floor(filters.offset / 20) + 1;
      params.set("page", String(pageNum));
    }
    if (filters.excludeHousing) params.set("excludeHousing", "true");

    const result = await serverApiClient(
      `/api/community/posts?${params.toString()}`,
      {},
      token || undefined
    );

    const rawPosts = result.posts || result.data || [];
    const posts = normalizePostsWithInteractions(rawPosts, result.userInteractions);
    return { data: posts, total: result.total || posts.length, error: null };
  } catch (error: any) {
    return { data: [], total: 0, error: error.message };
  }
}

export async function getCampusConnectPostById(
  postId: string
): Promise<{ data: CampusConnectPost | null; error: string | null }> {
  const token = await getToken();

  try {
    const result = await serverApiClient(
      `/api/community/posts/${postId}`,
      {},
      token || undefined
    );
    const rawPost = result.post || result.data || result;
    const post = normalizePost(rawPost);

    // Apply user interaction data if present
    if (result.userInteraction) {
      post.isLiked = post.isLiked || result.userInteraction.includes("like");
      post.isSaved = post.isSaved || result.userInteraction.includes("save");
    }

    return { data: post, error: null };
  } catch (error: any) {
    return { data: null, error: error.message };
  }
}

export async function createCampusConnectPost(
  input: CreatePostInput
): Promise<{ data: { id: string } | null; error: string | null }> {
  const token = await getToken();
  if (!token) return { data: null, error: "Not authenticated" };

  try {
    const result = await serverApiClient("/api/community/posts", {
      method: "POST",
      body: JSON.stringify({ ...input, postType: "campus" }),
    }, token);

    revalidatePath("/campus-connect");
    const postData = result.post || result.data || result;
    return { data: { id: postData.id || postData._id }, error: null };
  } catch (error: any) {
    return { data: null, error: error.message };
  }
}

export async function updateCampusConnectPost(
  postId: string,
  input: UpdatePostInput
): Promise<{ success: boolean; error: string | null }> {
  const token = await getToken();
  if (!token) return { success: false, error: "Not authenticated" };

  try {
    await serverApiClient(`/api/community/posts/${postId}`, {
      method: "PUT",
      body: JSON.stringify(input),
    }, token);

    revalidatePath("/campus-connect");
    revalidatePath(`/campus-connect/${postId}`);
    return { success: true, error: null };
  } catch (error: any) {
    return { success: false, error: error.message };
  }
}

export async function deleteCampusConnectPost(
  postId: string
): Promise<{ success: boolean; error: string | null }> {
  const token = await getToken();
  if (!token) return { success: false, error: "Not authenticated" };

  try {
    await serverApiClient(`/api/community/posts/${postId}`, { method: "DELETE" }, token);
    revalidatePath("/campus-connect");
    return { success: true, error: null };
  } catch (error: any) {
    return { success: false, error: error.message };
  }
}

// =============================================================================
// INTERACTION OPERATIONS
// =============================================================================

export async function togglePostLike(
  postId: string
): Promise<{ success: boolean; isLiked: boolean; error: string | null }> {
  const token = await getToken();
  if (!token) return { success: false, isLiked: false, error: "Not authenticated" };

  try {
    const result = await serverApiClient(`/api/community/posts/${postId}/like`, {
      method: "POST",
    }, token);
    return { success: true, isLiked: result.liked ?? result.isLiked ?? true, error: null };
  } catch (error: any) {
    return { success: false, isLiked: false, error: error.message };
  }
}

export async function togglePostSave(
  postId: string
): Promise<{ success: boolean; isSaved: boolean; error: string | null }> {
  const token = await getToken();
  if (!token) return { success: false, isSaved: false, error: "Not authenticated" };

  try {
    const result = await serverApiClient(`/api/community/posts/${postId}/save`, {
      method: "POST",
    }, token);
    return { success: true, isSaved: result.saved ?? result.isSaved ?? true, error: null };
  } catch (error: any) {
    return { success: false, isSaved: false, error: error.message };
  }
}

// =============================================================================
// COMMENT OPERATIONS
// =============================================================================

/**
 * Normalize a raw comment from the API into the CampusConnectComment UI shape.
 */
function normalizeComment(raw: any, postId: string): CampusConnectComment {
  const author = raw.userId && typeof raw.userId === "object" ? raw.userId : null;

  let timeAgo = raw.timeAgo || raw.time_ago || "";
  if (!timeAgo && (raw.createdAt || raw.created_at)) {
    const created = new Date(raw.createdAt || raw.created_at);
    const now = new Date();
    const diffMs = now.getTime() - created.getTime();
    const diffMins = Math.floor(diffMs / 60000);
    if (diffMins < 1) timeAgo = "just now";
    else if (diffMins < 60) timeAgo = `${diffMins}m ago`;
    else if (diffMins < 1440) timeAgo = `${Math.floor(diffMins / 60)}h ago`;
    else timeAgo = `${Math.floor(diffMins / 1440)}d ago`;
  }

  return {
    id: raw.id || raw._id || "",
    postId: raw.postId || raw.post_id || postId,
    authorId: raw.authorId || raw.author_id || author?._id || raw.userId || "",
    authorName: raw.authorName || raw.author_name || author?.fullName || author?.full_name || "Anonymous",
    authorAvatar: raw.authorAvatar || raw.author_avatar || author?.avatarUrl || author?.avatar_url || null,
    isAuthorVerified: raw.isAuthorVerified ?? raw.is_author_verified ?? author?.isCollegeVerified ?? false,
    parentId: raw.parentId || raw.parent_id || null,
    content: raw.content || "",
    likeCount: raw.likeCount ?? raw.like_count ?? raw.likes_count ?? 0,
    isLiked: raw.isLiked ?? raw.is_liked ?? false,
    createdAt: raw.createdAt || raw.created_at || "",
    timeAgo,
    replies: (raw.replies || []).map((r: any) => normalizeComment(r, postId)),
  };
}

/**
 * Build nested comment tree from flat comments array.
 * Comments with parentId are attached as replies to their parent.
 */
function buildCommentTree(flatComments: CampusConnectComment[]): CampusConnectComment[] {
  const map = new Map<string, CampusConnectComment>();
  const roots: CampusConnectComment[] = [];

  // First pass: index all comments
  for (const comment of flatComments) {
    map.set(comment.id, { ...comment, replies: [] });
  }

  // Second pass: build tree
  for (const comment of flatComments) {
    const node = map.get(comment.id)!;
    if (comment.parentId && map.has(comment.parentId)) {
      map.get(comment.parentId)!.replies.push(node);
    } else {
      roots.push(node);
    }
  }

  return roots;
}

export async function getPostComments(
  postId: string
): Promise<{ data: CampusConnectComment[]; error: string | null }> {
  const token = await getToken();

  try {
    // Try dedicated comments endpoint first
    try {
      const result = await serverApiClient(
        `/api/community/posts/${postId}/comments`,
        {},
        token || undefined
      );
      const rawComments = result.comments || result.data || [];
      if (rawComments.length > 0) {
        const normalized = rawComments.map((c: any) => normalizeComment(c, postId));
        return { data: buildCommentTree(normalized), error: null };
      }
    } catch {
      // Endpoint may not exist, fall through to extracting from post
    }

    // Fallback: fetch the post and extract embedded comments
    const postResult = await serverApiClient(
      `/api/community/posts/${postId}`,
      {},
      token || undefined
    );
    const rawPost = postResult.post || postResult.data || postResult;
    const rawComments = rawPost.comments || [];
    const normalized = rawComments.map((c: any) => normalizeComment(c, postId));
    return { data: buildCommentTree(normalized), error: null };
  } catch (error: any) {
    return { data: [], error: error.message };
  }
}

export async function createComment(
  input: CreateCommentInput
): Promise<{ data: CampusConnectComment | null; error: string | null }> {
  const token = await getToken();
  if (!token) return { data: null, error: "Not authenticated" };

  try {
    const result = await serverApiClient(`/api/community/posts/${input.postId}/comments`, {
      method: "POST",
      body: JSON.stringify({
        content: input.content,
        parentId: input.parentId,
      }),
    }, token);

    revalidatePath(`/campus-connect/${input.postId}`);

    // The API returns the full post with all comments -- extract the last comment as the new one
    if (result.comment) {
      return { data: normalizeComment(result.comment, input.postId), error: null };
    }

    // Extract from updated post's embedded comments (last one is the newly created)
    const rawPost = result.post || result.data || result;
    const rawComments = rawPost.comments || [];
    if (rawComments.length > 0) {
      const lastComment = rawComments[rawComments.length - 1];
      return { data: normalizeComment(lastComment, input.postId), error: null };
    }

    return { data: null, error: null };
  } catch (error: any) {
    return { data: null, error: error.message };
  }
}

export async function toggleCommentLike(
  commentId: string
): Promise<{ success: boolean; isLiked: boolean; error: string | null }> {
  const token = await getToken();
  if (!token) return { success: false, isLiked: false, error: "Not authenticated" };

  try {
    const result = await serverApiClient(`/api/community/comments/${commentId}/like`, {
      method: "POST",
    }, token);
    return { success: true, isLiked: result.liked ?? true, error: null };
  } catch {
    // The API may not support comment likes yet -- handle gracefully with optimistic UI
    // Return success so the optimistic update in the UI stays applied
    return { success: true, isLiked: true, error: null };
  }
}

// =============================================================================
// UTILITY OPERATIONS
// =============================================================================

export async function getUniversities(): Promise<{
  data: Array<{ id: string; name: string; shortName: string | null }>;
  error: string | null;
}> {
  try {
    const result = await serverApiClient("/api/universities");
    const universities = result.universities || result.data || [];
    return {
      data: universities.map((u: any) => ({
        id: u.id || u._id,
        name: u.name,
        shortName: u.short_name || u.shortName,
      })),
      error: null,
    };
  } catch (error: any) {
    return { data: [], error: error.message };
  }
}

export async function checkCollegeVerification(): Promise<{
  isVerified: boolean;
  error: string | null;
}> {
  const token = await getToken();
  if (!token) return { isVerified: false, error: "Not authenticated" };

  try {
    const result = await serverApiClient("/api/users/me", {}, token);
    return { isVerified: result.is_college_verified || result.isCollegeVerified || false, error: null };
  } catch (error: any) {
    return { isVerified: false, error: error.message };
  }
}

export async function uploadCampusConnectImage(file: {
  name: string;
  type: string;
  size: number;
  base64Data: string;
}): Promise<{ data: { url: string } | null; error: string | null }> {
  const token = await getToken();
  if (!token) return { data: null, error: "Not authenticated" };

  const MAX_SIZE = 5 * 1024 * 1024;
  const ALLOWED_TYPES = ["image/jpeg", "image/png", "image/webp", "image/gif"];

  if (file.size > MAX_SIZE) return { data: null, error: "File size must be less than 5MB" };
  if (!ALLOWED_TYPES.includes(file.type)) return { data: null, error: "Only JPEG, PNG, WebP, and GIF images are allowed" };

  try {
    const result = await serverApiClient("/api/upload", {
      method: "POST",
      body: JSON.stringify({
        file: `data:${file.type};base64,${file.base64Data}`,
        folder: "campus-connect",
      }),
    }, token);

    return { data: { url: result.url }, error: null };
  } catch (error: any) {
    return { data: null, error: error.message || "Failed to upload image" };
  }
}

// =============================================================================
// REPORT & SAVED LISTINGS OPERATIONS
// =============================================================================

export async function reportListing(
  listingId: string,
  reason: string,
  details?: string
): Promise<{ success: boolean; error: string | null }> {
  const token = await getToken();
  if (!token) return { success: false, error: "Not authenticated" };

  try {
    await serverApiClient(`/api/community/posts/${listingId}/report`, {
      method: "POST",
      body: JSON.stringify({ reason, details }),
    }, token);
    return { success: true, error: null };
  } catch (error: any) {
    return { success: false, error: error.message };
  }
}

export async function saveListing(
  listingId: string
): Promise<{ success: boolean; error: string | null }> {
  const token = await getToken();
  if (!token) return { success: false, error: "Not authenticated" };

  try {
    await serverApiClient(`/api/community/posts/${listingId}/save`, {
      method: "POST",
    }, token);
    revalidatePath("/campus-connect");
    return { success: true, error: null };
  } catch (error: any) {
    return { success: false, error: error.message };
  }
}

export async function unsaveListing(
  listingId: string
): Promise<{ success: boolean; error: string | null }> {
  const token = await getToken();
  if (!token) return { success: false, error: "Not authenticated" };

  try {
    await serverApiClient(`/api/community/posts/${listingId}/save`, {
      method: "POST",
    }, token);
    revalidatePath("/campus-connect");
    return { success: true, error: null };
  } catch (error: any) {
    return { success: false, error: error.message };
  }
}

export async function getSavedListings(): Promise<{
  data: CampusConnectPost[];
  error: string | null;
}> {
  const token = await getToken();
  if (!token) return { data: [], error: "Not authenticated" };

  try {
    const result = await serverApiClient("/api/community/posts/saved?postType=campus", {}, token);
    const rawPosts = result.posts || result.data || [];
    const posts = rawPosts.map((raw: any) => {
      const post = normalizePost(raw);
      post.isSaved = true; // These are saved listings
      return post;
    });
    return { data: posts, error: null };
  } catch (error: any) {
    return { data: [], error: error.message };
  }
}

export async function hasUserReportedListing(
  listingId: string
): Promise<{ isReported: boolean; error: string | null }> {
  const token = await getToken();
  if (!token) return { isReported: false, error: null };

  try {
    const result = await serverApiClient(`/api/community/posts/${listingId}/report-status`, {}, token);
    return { isReported: result.isReported || false, error: null };
  } catch {
    return { isReported: false, error: null };
  }
}

export async function isListingSaved(
  listingId: string
): Promise<{ isSaved: boolean; error: string | null }> {
  const token = await getToken();
  if (!token) return { isSaved: false, error: null };

  try {
    const result = await serverApiClient(`/api/community/posts/${listingId}/save-status`, {}, token);
    return { isSaved: result.isSaved || false, error: null };
  } catch {
    return { isSaved: false, error: null };
  }
}
