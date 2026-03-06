"use server";

import { cookies } from "next/headers";
import { revalidatePath } from "next/cache";
import { serverApiClient } from "@/lib/api/client";
import type {
  MarketplaceFilters,
  ListingType,
  AnyListing,
  DBMarketplaceCategory,
} from "@/types/marketplace";

export type { ListingType } from "@/types/marketplace";

async function getToken(): Promise<string | null> {
  const cookieStore = await cookies();
  return cookieStore.get("accessToken")?.value || null;
}

/**
 * Types for creating listings
 */
export interface CreateListingData {
  listingType?: string;
  title: string;
  description?: string;
  price?: number;
  priceNegotiable?: boolean;
  imageUrl?: string;
  imageUrls?: string[];
  categoryId?: string;
  city?: string;
  location?: string;
  locationText?: string;
  itemCondition?: "new" | "like_new" | "good" | "fair" | "poor";
  housingType?: "single" | "shared" | "flat" | "pg" | "hostel";
  bedrooms?: number;
  rentPeriod?: string;
  availableFrom?: string;
  opportunityType?: "internship" | "job" | "event" | "gig" | "workshop" | "competition";
  opportunityUrl?: string;
  applicationDeadline?: string;
  companyName?: string;
  pollOptions?: { id: string; text: string; votes: number }[];
  pollEndsAt?: string;
  postContent?: string;
  metadata?: Record<string, unknown>;
}

export interface CreateListingInput {
  type: ListingType;
  title: string;
  description?: string;
  price?: number;
  categoryId?: string;
  location?: string;
  imageUrls?: string[];
  metadata?: Record<string, any>;
}

export interface UpdateListingInput {
  title?: string;
  description?: string;
  price?: number;
  categoryId?: string;
  location?: string;
  imageUrls?: string[];
  isActive?: boolean;
  metadata?: Record<string, any>;
}

export interface GetListingsOptions {
  category?: string | string[] | "all";
  search?: string;
  limit?: number;
  offset?: number;
  priceMin?: number;
  priceMax?: number;
  sortBy?: "recent" | "price_low" | "price_high" | "popular";
  universityOnly?: boolean;
}

/**
 * Get marketplace listings with filtering
 */
export async function getMarketplaceListings(
  options: GetListingsOptions | MarketplaceFilters = {}
): Promise<{ listings?: AnyListing[]; data?: AnyListing[]; total?: number; error: string | null }> {
  const token = await getToken();

  try {
    const params = new URLSearchParams();
    const opts = options as any;

    if (opts.category && opts.category !== "all") {
      if (Array.isArray(opts.category)) {
        params.set("category", opts.category.join(","));
      } else {
        params.set("category", opts.category);
      }
    }
    if (opts.search) params.set("search", opts.search);
    if (opts.limit) params.set("limit", String(opts.limit));
    if (opts.offset) params.set("offset", String(opts.offset));
    if (opts.priceMin) params.set("priceMin", String(opts.priceMin));
    if (opts.priceMax) params.set("priceMax", String(opts.priceMax));
    if (opts.sortBy) params.set("sortBy", opts.sortBy);
    if (opts.universityOnly) params.set("universityOnly", "true");
    if (opts.priceRange) {
      params.set("priceMin", String(opts.priceRange[0]));
      params.set("priceMax", String(opts.priceRange[1]));
    }

    const result = await serverApiClient(
      `/api/marketplace/listings?${params.toString()}`,
      {},
      token || undefined
    );

    const listings = result.listings || result.data || [];
    return { listings, data: listings, total: result.total || listings.length, error: null };
  } catch (error: any) {
    return { listings: [], data: [], total: 0, error: error.message };
  }
}

/**
 * Get a single marketplace listing by ID
 */
export async function getListingById(id: string) {
  const token = await getToken();

  try {
    const result = await serverApiClient(
      `/api/marketplace/listings/${id}`,
      {},
      token || undefined
    );
    return result.listing || result.data || result;
  } catch {
    return null;
  }
}

/**
 * Get a single marketplace listing by ID (alternative)
 */
export async function getMarketplaceListingById(
  id: string
): Promise<{ data: AnyListing | null; error: string | null }> {
  try {
    const listing = await getListingById(id);
    return { data: listing, error: null };
  } catch (error: any) {
    return { data: null, error: error.message };
  }
}

/**
 * Get listings created by the current user
 */
export async function getUserListings(status?: "active" | "inactive" | "all") {
  const token = await getToken();
  if (!token) return [];

  try {
    const params = status ? `?status=${status}` : "";
    const result = await serverApiClient(`/api/marketplace/listings/mine${params}`, {}, token);
    return result.listings || result.data || [];
  } catch {
    return [];
  }
}

/**
 * Create a new marketplace listing
 */
export async function createListing(data: CreateListingData) {
  const token = await getToken();
  if (!token) return { error: "Not authenticated" };

  try {
    const result = await serverApiClient("/api/marketplace/listings", {
      method: "POST",
      body: JSON.stringify(data),
    }, token);

    revalidatePath("/campus-connect");
    revalidatePath("/campus-connect");
    return { success: true, listing: result.listing || result.data || result };
  } catch (error: any) {
    return { error: error.message };
  }
}

/**
 * Create a new marketplace listing (alternative)
 */
export async function createMarketplaceListing(
  input: CreateListingInput
): Promise<{ data: { id: string } | null; error: string | null }> {
  const token = await getToken();
  if (!token) return { data: null, error: "Not authenticated" };

  try {
    const result = await serverApiClient("/api/marketplace/listings", {
      method: "POST",
      body: JSON.stringify(input),
    }, token);

    revalidatePath("/campus-connect");
    revalidatePath("/campus-connect");
    return { data: { id: result.listing?.id || result.data?.id || result.id }, error: null };
  } catch (error: any) {
    return { data: null, error: error.message };
  }
}

/**
 * Update an existing marketplace listing
 */
export async function updateMarketplaceListing(
  id: string,
  input: UpdateListingInput
): Promise<{ success: boolean; error: string | null }> {
  const token = await getToken();
  if (!token) return { success: false, error: "Not authenticated" };

  try {
    await serverApiClient(`/api/marketplace/listings/${id}`, {
      method: "PUT",
      body: JSON.stringify(input),
    }, token);

    revalidatePath("/campus-connect");
    revalidatePath("/campus-connect");
    return { success: true, error: null };
  } catch (error: any) {
    return { success: false, error: error.message };
  }
}

/**
 * Delete a marketplace listing (soft delete)
 */
export async function deleteMarketplaceListing(
  id: string
): Promise<{ success: boolean; error: string | null }> {
  const token = await getToken();
  if (!token) return { success: false, error: "Not authenticated" };

  try {
    await serverApiClient(`/api/marketplace/listings/${id}`, {
      method: "DELETE",
    }, token);

    revalidatePath("/campus-connect");
    revalidatePath("/campus-connect");
    return { success: true, error: null };
  } catch (error: any) {
    return { success: false, error: error.message };
  }
}

/**
 * Toggle favorite status for a listing
 */
export async function toggleMarketplaceFavorite(
  listingId: string
): Promise<{ success: boolean; isFavorited: boolean; error: string | null }> {
  const token = await getToken();
  if (!token) return { success: false, isFavorited: false, error: "Not authenticated" };

  try {
    const result = await serverApiClient(`/api/marketplace/listings/${listingId}/favorite`, {
      method: "POST",
    }, token);

    revalidatePath("/campus-connect");
    revalidatePath("/campus-connect");
    return { success: true, isFavorited: result.isFavorited ?? true, error: null };
  } catch (error: any) {
    return { success: false, isFavorited: false, error: error.message };
  }
}

/**
 * Get user's favorite listings
 */
export async function getUserFavoriteListings(): Promise<{
  data: AnyListing[] | null;
  error: string | null;
}> {
  const token = await getToken();
  if (!token) return { data: null, error: "Not authenticated" };

  try {
    const result = await serverApiClient("/api/marketplace/favorites", {}, token);
    return { data: result.listings || result.data || [], error: null };
  } catch (error: any) {
    return { data: null, error: error.message };
  }
}

/**
 * Get marketplace categories
 */
export async function getMarketplaceCategories(): Promise<{
  data: DBMarketplaceCategory[] | null;
  error: string | null;
}> {
  try {
    const result = await serverApiClient("/api/marketplace/categories");
    return { data: result.categories || result.data || [], error: null };
  } catch (error: any) {
    return { data: null, error: error.message };
  }
}

/**
 * Upload image for marketplace listing
 */
export async function uploadMarketplaceImage(file: {
  name: string;
  type: string;
  size: number;
  base64Data: string;
}): Promise<{ data: { url: string; publicId: string } | null; error: string | null }> {
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
        folder: "marketplace",
      }),
    }, token);

    return { data: { url: result.url, publicId: result.publicId }, error: null };
  } catch (error: any) {
    return { data: null, error: error.message || "Failed to upload image" };
  }
}
