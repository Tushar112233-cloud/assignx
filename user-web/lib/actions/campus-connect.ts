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
    if (filters.offset) params.set("offset", String(filters.offset));
    if (filters.excludeHousing) params.set("excludeHousing", "true");

    const result = await serverApiClient(
      `/api/community/posts?${params.toString()}`,
      {},
      token || undefined
    );

    const posts = result.posts || result.data || [];
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
    return { data: result.post || result.data || result, error: null };
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
    return { data: { id: result.post?.id || result.data?.id || result.id }, error: null };
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
    return { success: true, isLiked: result.isLiked ?? true, error: null };
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
    return { success: true, isSaved: result.isSaved ?? true, error: null };
  } catch (error: any) {
    return { success: false, isSaved: false, error: error.message };
  }
}

// =============================================================================
// COMMENT OPERATIONS
// =============================================================================

export async function getPostComments(
  postId: string
): Promise<{ data: CampusConnectComment[]; error: string | null }> {
  const token = await getToken();

  try {
    const result = await serverApiClient(
      `/api/community/posts/${postId}/comments`,
      {},
      token || undefined
    );
    return { data: result.comments || result.data || [], error: null };
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
    return { data: result.comment || result.data || result, error: null };
  } catch (error: any) {
    return { data: null, error: error.message };
  }
}

export async function toggleCommentLike(
  commentId: string
): Promise<{ success: boolean; isLiked: boolean; error: string | null }> {
  return { success: false, isLiked: false, error: "Comment likes feature coming soon" };
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
    await serverApiClient(`/api/community/posts/${listingId}/unsave`, {
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
    return { data: result.posts || result.data || [], error: null };
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
