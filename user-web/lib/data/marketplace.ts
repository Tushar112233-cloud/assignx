"use server";

/**
 * Marketplace data functions using server actions
 * Connects to Supabase marketplace_listings table via server actions
 *
 * NOTE: Mock data exports are kept for backward compatibility during migration.
 * Components should migrate to using the async functions.
 */

import { createClient } from "@/lib/supabase/server";
import type {
  ProductListing,
  HousingListing,
  OpportunityListing,
  CommunityPost,
  AnyListing,
  MarketplaceFilters,
  ListingType,
  ProductCondition,
} from "@/types/marketplace";

/**
 * Database listing type mapping
 */
const listingTypeMap: Record<string, ListingType> = {
  sell: "product",
  housing: "housing",
  opportunity: "opportunity",
  community_post: "community",
};

const reverseListingTypeMap: Record<ListingType, string> = {
  product: "sell",
  housing: "housing",
  opportunity: "opportunity",
  community: "community_post",
};

/**
 * Map UI category names to database listing_type values
 */
const categoryToDBTypeMap: Record<string, string> = {
  products: "sell",
  housing: "housing",
  opportunities: "opportunity",
  community: "community_post",
  // Direct DB values
  sell: "sell",
  opportunity: "opportunity",
  community_post: "community_post",
};

/**
 * Transform database listing to frontend type
 */
function transformListing(dbListing: any): AnyListing | null {
  if (!dbListing) return null;

  const type = listingTypeMap[dbListing.listing_type] || "product";
  const baseListing = {
    id: dbListing.id,
    type,
    title: dbListing.title,
    description: dbListing.description,
    userId: dbListing.seller_id,
    userName: dbListing.seller?.full_name || "Unknown",
    userAvatar: dbListing.seller?.avatar_url,
    universityId: dbListing.university_id,
    universityName: dbListing.university?.name,
    createdAt: dbListing.created_at,
    imageUrl: dbListing.image_urls?.[0],
    likes: dbListing.favorite_count || 0,
    isLiked: dbListing.is_favorited || false,
    comments: dbListing.comment_count || 0,
    views: dbListing.view_count || 0,
  };

  // Type-specific fields
  const metadata = dbListing.metadata || {};

  switch (type) {
    case "product":
      return {
        ...baseListing,
        type: "product",
        price: dbListing.price || 0,
        condition: (metadata.condition as ProductCondition) || "good",
        category: dbListing.category?.name || metadata.category || "Other",
        distance: metadata.distance,
        isSold: metadata.is_sold || false,
        isNegotiable: metadata.is_negotiable || false,
      } as ProductListing;

    case "housing":
      return {
        ...baseListing,
        type: "housing",
        monthlyRent: dbListing.price || 0,
        roomType: metadata.room_type || "single",
        location: dbListing.location || "",
        distance: metadata.distance,
        availableFrom: metadata.available_from,
        amenities: metadata.amenities || [],
        isAvailable: metadata.is_available !== false,
      } as HousingListing;

    case "opportunity":
      return {
        ...baseListing,
        type: "opportunity",
        opportunityType: metadata.opportunity_type || "internship",
        company: metadata.company,
        location: dbListing.location,
        isRemote: metadata.is_remote || false,
        deadline: metadata.deadline,
        stipend: metadata.stipend,
        duration: metadata.duration,
      } as OpportunityListing;

    case "community":
      return {
        ...baseListing,
        type: "community",
        postType: metadata.post_type || "discussion",
        pollOptions: metadata.poll_options,
        tags: metadata.tags || [],
      } as CommunityPost;

    default:
      return null;
  }
}

// ============================================================================
// LEGACY EXPORTS - Data now fetched from database via server actions
// ============================================================================

/**
 * Product listings - use getProducts() server action
 * @deprecated
 */
export const mockProducts: ProductListing[] = [];

/**
 * Housing listings - use getHousing() server action
 * @deprecated
 */
export const mockHousing: HousingListing[] = [];

/**
 * Opportunity listings - use getOpportunities() server action
 * @deprecated
 */
export const mockOpportunities: OpportunityListing[] = [];

/**
 * Community posts - use getCommunityPosts() server action
 * @deprecated
 */
export const mockCommunityPosts: CommunityPost[] = [];

// ============================================================================
// SERVER ACTIONS - Database-backed functions for production use
// ============================================================================

/**
 * Get all listings from database
 * Replaces static mock data with database query
 */
export async function getAllListings(): Promise<AnyListing[]> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  try {
    const { data: listings, error } = await supabase
      .from("marketplace_listings")
      .select(
        `
        *,
        seller:profiles!seller_id(id, full_name, avatar_url),
        category:marketplace_categories!category_id(id, name, slug),
        university:universities!university_id(id, name)
      `
      )
      .eq("is_active", true)
      .order("created_at", { ascending: false });

    if (error) {
      return [];
    }

    // Transform listings to frontend format
    const transformedListings = (listings || [])
      .map((listing) => transformListing(listing))
      .filter((l): l is AnyListing => l !== null);

    // Check if user has favorited listings
    if (user && transformedListings.length > 0) {
      const listingIds = transformedListings.map((l) => l.id);
      const { data: favorites } = await supabase
        .from("marketplace_favorites")
        .select("listing_id")
        .eq("user_id", user.id)
        .in("listing_id", listingIds);

      const favoriteIds = new Set(favorites?.map((f) => f.listing_id) || []);
      transformedListings.forEach((listing) => {
        listing.isLiked = favoriteIds.has(listing.id);
      });
    }

    return transformedListings;
  } catch {
    return [];
  }
}

/**
 * Get listings by category from database
 * Replaces static mock data filtering with database query
 */
export async function getListingsByCategory(
  category: string
): Promise<AnyListing[]> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  try {
    let query = supabase
      .from("marketplace_listings")
      .select(
        `
        *,
        seller:profiles!seller_id(id, full_name, avatar_url),
        category:marketplace_categories!category_id(id, name, slug),
        university:universities!university_id(id, name)
      `
      )
      .eq("is_active", true)
      .order("created_at", { ascending: false });

    // Apply category filter
    if (category !== "all") {
      const dbType = categoryToDBTypeMap[category];
      if (dbType) {
        query = query.eq("listing_type", dbType);
      }
    }

    const { data: listings, error } = await query;

    if (error) {
      return [];
    }

    // Transform listings to frontend format
    const transformedListings = (listings || [])
      .map((listing) => transformListing(listing))
      .filter((l): l is AnyListing => l !== null);

    // Check if user has favorited listings
    if (user && transformedListings.length > 0) {
      const listingIds = transformedListings.map((l) => l.id);
      const { data: favorites } = await supabase
        .from("marketplace_favorites")
        .select("listing_id")
        .eq("user_id", user.id)
        .in("listing_id", listingIds);

      const favoriteIds = new Set(favorites?.map((f) => f.listing_id) || []);
      transformedListings.forEach((listing) => {
        listing.isLiked = favoriteIds.has(listing.id);
      });
    }

    return transformedListings;
  } catch {
    return [];
  }
}

/**
 * Get product listings from database
 */
export async function getProducts(): Promise<ProductListing[]> {
  const listings = await getListingsByCategory("products");
  return listings.filter((l): l is ProductListing => l.type === "product");
}

/**
 * Get housing listings from database
 */
export async function getHousing(): Promise<HousingListing[]> {
  const listings = await getListingsByCategory("housing");
  return listings.filter((l): l is HousingListing => l.type === "housing");
}

/**
 * Get opportunity listings from database
 */
export async function getOpportunities(): Promise<OpportunityListing[]> {
  const listings = await getListingsByCategory("opportunities");
  return listings.filter(
    (l): l is OpportunityListing => l.type === "opportunity"
  );
}

/**
 * Get community posts from database
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
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  try {
    let query = supabase
      .from("marketplace_listings")
      .select(
        `
        *,
        seller:profiles!seller_id(id, full_name, avatar_url),
        category:marketplace_categories!category_id(id, name, slug),
        university:universities!university_id(id, name)
      `
      )
      .eq("is_active", true)
      .order("created_at", { ascending: false });

    // Apply category filter
    if (filters?.category && filters.category !== "all") {
      const dbType = categoryToDBTypeMap[filters.category] || reverseListingTypeMap[filters.category as ListingType];
      if (dbType) {
        query = query.eq("listing_type", dbType);
      }
    }

    // Apply price range filter
    if (filters?.priceRange) {
      const [minPrice, maxPrice] = filters.priceRange;
      if (minPrice > 0) {
        query = query.gte("price", minPrice);
      }
      if (maxPrice > 0) {
        query = query.lte("price", maxPrice);
      }
    }

    // Apply university filter
    if (filters?.universityOnly && user) {
      const { data: profile } = await supabase
        .from("students")
        .select("university_id")
        .eq("profile_id", user.id)
        .single();

      if (profile?.university_id) {
        query = query.eq("university_id", profile.university_id);
      }
    }

    const { data: listings, error } = await query;

    if (error) {
      return [];
    }

    // Transform listings to frontend format
    const transformedListings = (listings || [])
      .map((listing) => transformListing(listing))
      .filter((l): l is AnyListing => l !== null);

    // Apply sorting
    if (filters?.sortBy) {
      switch (filters.sortBy) {
        case "price_low":
          transformedListings.sort((a, b) => {
            const priceA =
              "price" in a ? a.price : "monthlyRent" in a ? a.monthlyRent : 0;
            const priceB =
              "price" in b ? b.price : "monthlyRent" in b ? b.monthlyRent : 0;
            return priceA - priceB;
          });
          break;
        case "price_high":
          transformedListings.sort((a, b) => {
            const priceA =
              "price" in a ? a.price : "monthlyRent" in a ? a.monthlyRent : 0;
            const priceB =
              "price" in b ? b.price : "monthlyRent" in b ? b.monthlyRent : 0;
            return priceB - priceA;
          });
          break;
        case "popular":
          transformedListings.sort((a, b) => b.views - a.views);
          break;
        // 'recent' is default from DB ordering
      }
    }

    // Check if user has favorited listings
    if (user && transformedListings.length > 0) {
      const listingIds = transformedListings.map((l) => l.id);
      const { data: favorites } = await supabase
        .from("marketplace_favorites")
        .select("listing_id")
        .eq("user_id", user.id)
        .in("listing_id", listingIds);

      const favoriteIds = new Set(favorites?.map((f) => f.listing_id) || []);
      transformedListings.forEach((listing) => {
        listing.isLiked = favoriteIds.has(listing.id);
      });
    }

    return transformedListings;
  } catch {
    return [];
  }
}
