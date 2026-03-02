"use server";

/**
 * Marketplace data functions using server actions.
 * Fetches data from the Express API via server actions.
 */

import { serverApiClient } from "@/lib/api/client";
import { extractTokenFromCookies } from "@/lib/api/server";
import type {
  ProductListing,
  HousingListing,
  OpportunityListing,
  CommunityPost,
  AnyListing,
  MarketplaceFilters,
} from "@/types/marketplace";

// ============================================================================
// LEGACY EXPORTS - Kept for backward compatibility during migration.
// ============================================================================

/** @deprecated Use getProducts() */
export const mockProducts: ProductListing[] = [];

/** @deprecated Use getHousing() */
export const mockHousing: HousingListing[] = [];

/** @deprecated Use getOpportunities() */
export const mockOpportunities: OpportunityListing[] = [];

/** @deprecated Use getCommunityPosts() */
export const mockCommunityPosts: CommunityPost[] = [];

// ============================================================================
// SERVER ACTIONS - API-backed functions
// ============================================================================

/**
 * Get all listings from Express API
 */
export async function getAllListings(): Promise<AnyListing[]> {
  try {
    const token = await extractTokenFromCookies();
    const data = await serverApiClient<AnyListing[]>(
      "/api/marketplace/listings",
      {},
      token ?? undefined
    );
    return data ?? [];
  } catch {
    return [];
  }
}

/**
 * Get listings by category from Express API
 */
export async function getListingsByCategory(
  category: string
): Promise<AnyListing[]> {
  try {
    const token = await extractTokenFromCookies();
    const query = category !== "all" ? `?category=${encodeURIComponent(category)}` : "";
    const data = await serverApiClient<AnyListing[]>(
      `/api/marketplace/listings${query}`,
      {},
      token ?? undefined
    );
    return data ?? [];
  } catch {
    return [];
  }
}

/**
 * Get product listings
 */
export async function getProducts(): Promise<ProductListing[]> {
  const listings = await getListingsByCategory("products");
  return listings.filter((l): l is ProductListing => l.type === "product");
}

/**
 * Get housing listings
 */
export async function getHousing(): Promise<HousingListing[]> {
  const listings = await getListingsByCategory("housing");
  return listings.filter((l): l is HousingListing => l.type === "housing");
}

/**
 * Get opportunity listings
 */
export async function getOpportunities(): Promise<OpportunityListing[]> {
  const listings = await getListingsByCategory("opportunities");
  return listings.filter(
    (l): l is OpportunityListing => l.type === "opportunity"
  );
}

/**
 * Get community posts
 */
export async function getCommunityPosts(): Promise<CommunityPost[]> {
  const listings = await getListingsByCategory("community");
  return listings.filter((l): l is CommunityPost => l.type === "community");
}

/**
 * Get filtered listings with advanced options
 */
export async function getFilteredListings(
  filters?: MarketplaceFilters
): Promise<AnyListing[]> {
  try {
    const token = await extractTokenFromCookies();
    const params = new URLSearchParams();

    if (filters?.category && filters.category !== "all") {
      params.set("category", filters.category);
    }
    if (filters?.priceRange) {
      const [min, max] = filters.priceRange;
      if (min > 0) params.set("minPrice", String(min));
      if (max > 0) params.set("maxPrice", String(max));
    }
    if (filters?.sortBy) {
      params.set("sortBy", filters.sortBy);
    }
    if (filters?.universityOnly) {
      params.set("universityOnly", "true");
    }

    const query = params.toString() ? `?${params.toString()}` : "";
    const data = await serverApiClient<AnyListing[]>(
      `/api/marketplace/listings${query}`,
      {},
      token ?? undefined
    );
    return data ?? [];
  } catch {
    return [];
  }
}
