"use server";

import { cookies } from "next/headers";
import { revalidatePath } from "next/cache";
import { serverApiClient } from "@/lib/api/client";
import {
  transformProNetworkPost,
  type ProNetworkPost,
  type ProNetworkFilters,
  type CreateProNetworkPostInput,
} from "@/types/pro-network";

async function getToken(): Promise<string | null> {
  const cookieStore = await cookies();
  return cookieStore.get("accessToken")?.value || null;
}

export async function getProNetworkPosts(
  filters: ProNetworkFilters = {}
): Promise<{ data: ProNetworkPost[]; total: number; error: string | null }> {
  const token = await getToken();

  try {
    const params = new URLSearchParams();
    params.set("postType", "pro_network");
    if (filters.category && filters.category !== "all") params.set("category", filters.category);
    if (filters.search) params.set("search", filters.search);
    if (filters.limit) params.set("limit", String(filters.limit));
    if (filters.offset) params.set("offset", String(filters.offset));

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

export async function getProNetworkPostById(
  postId: string
): Promise<{ data: ProNetworkPost | null; error: string | null }> {
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

export async function createProNetworkPost(
  input: CreateProNetworkPostInput
): Promise<{ data: { id: string } | null; error: string | null }> {
  const token = await getToken();
  if (!token) return { data: null, error: "Not authenticated" };

  try {
    const result = await serverApiClient("/api/community/posts", {
      method: "POST",
      body: JSON.stringify({ ...input, postType: "pro_network" }),
    }, token);

    revalidatePath("/pro-network");
    return { data: { id: result.post?.id || result.data?.id || result.id }, error: null };
  } catch (error: any) {
    return { data: null, error: error.message };
  }
}

export async function toggleProNetworkLike(
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

export async function toggleProNetworkSave(
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

export async function getSavedProNetworkPosts(): Promise<{
  data: ProNetworkPost[];
  error: string | null;
}> {
  const token = await getToken();
  if (!token) return { data: [], error: "Not authenticated" };

  try {
    const result = await serverApiClient("/api/community/posts/saved?postType=pro_network", {}, token);
    return { data: result.posts || result.data || [], error: null };
  } catch (error: any) {
    return { data: [], error: error.message };
  }
}
