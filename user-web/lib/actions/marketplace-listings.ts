"use server";

import { cookies } from "next/headers";
import { revalidatePath } from "next/cache";
import { serverApiClient } from "@/lib/api/client";

export interface MarketplaceListingData {
  id: string;
  title: string;
  description: string | null;
  price: number | null;
  listing_type: string;
  status: string;
  view_count: number | null;
  city: string | null;
  image_url: string | null;
  created_at: string;
  updated_at: string;
  seller_id: string;
  seller: {
    id: string;
    full_name: string | null;
    avatar_url: string | null;
  } | null;
  category: {
    id: string;
    name: string;
    slug: string;
    is_active: boolean;
  } | null;
  is_favorited?: boolean;
}

async function getToken(): Promise<string | null> {
  const cookieStore = await cookies();
  return cookieStore.get("accessToken")?.value || null;
}

/**
 * Fetch marketplace listings with optional category and search filters
 */
export async function fetchListings(
  category?: string,
  search?: string
): Promise<{ data: MarketplaceListingData[]; total: number; error: string | null }> {
  const token = await getToken();

  try {
    const params = new URLSearchParams();
    if (category && category !== "all") params.set("category", category);
    if (search && search.trim()) params.set("search", search.trim());
    params.set("limit", "50");

    const result = await serverApiClient(
      `/api/marketplace/listings?${params.toString()}`,
      {},
      token || undefined
    );

    const listings = result.listings || result.data || [];
    return { data: listings, total: result.total || listings.length, error: null };
  } catch (error: any) {
    return { data: [], total: 0, error: error.message };
  }
}

/**
 * Create a new marketplace listing
 */
export async function createMarketplaceListing(data: {
  listing_type: string;
  title: string;
  description?: string;
  price?: number;
  category_id?: string;
  city?: string;
}): Promise<{ success: boolean; id?: string; error: string | null }> {
  const token = await getToken();
  if (!token) return { success: false, error: "Not authenticated" };

  try {
    const result = await serverApiClient("/api/marketplace/listings", {
      method: "POST",
      body: JSON.stringify(data),
    }, token);

    revalidatePath("/campus-connect");
    return { success: true, id: result.listing?.id || result.data?.id || result.id, error: null };
  } catch (error: any) {
    return { success: false, error: error.message };
  }
}

/**
 * Toggle favorite status for a marketplace listing
 */
export async function toggleListingFavorite(
  listingId: string
): Promise<{ success: boolean; isFavorited: boolean; error: string | null }> {
  const token = await getToken();
  if (!token) return { success: false, isFavorited: false, error: "Not authenticated" };

  try {
    const result = await serverApiClient(`/api/marketplace/listings/${listingId}/favorite`, {
      method: "POST",
    }, token);

    revalidatePath("/campus-connect");
    return { success: true, isFavorited: result.isFavorited ?? true, error: null };
  } catch (error: any) {
    return { success: false, isFavorited: false, error: error.message };
  }
}
