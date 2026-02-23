"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";
import type {
  MarketplaceFilters,
  ListingType,
  ProductCondition,
  AnyListing,
  ProductListing,
  HousingListing,
  OpportunityListing,
  CommunityPost,
  DBMarketplaceCategory,
} from "@/types/marketplace";

// Re-export ListingType for convenience
export type { ListingType } from "@/types/marketplace";

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
 * Handles both singular and plural category names
 */
const categoryToDBTypeMap: Record<string, string | string[]> = {
  // Singular (ListingType)
  product: "sell",
  housing: "housing",
  opportunity: "opportunity",
  community: "community_post",
  // Plural (MarketplaceCategory)
  products: "sell",
  opportunities: "opportunity",
  // Additional mappings for all DB enum values
  sell: "sell",
  rent: "rent",
  free: "free",
  community_post: "community_post",
  poll: "poll",
  event: "event",
};

/**
 * Data for creating a new marketplace listing
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

  // Product-specific fields
  itemCondition?: "new" | "like_new" | "good" | "fair" | "poor";

  // Housing-specific fields
  housingType?: "single" | "shared" | "flat" | "pg" | "hostel";
  bedrooms?: number;
  rentPeriod?: string;
  availableFrom?: string;

  // Opportunity-specific fields
  opportunityType?: "internship" | "job" | "event" | "gig" | "workshop" | "competition";
  opportunityUrl?: string;
  applicationDeadline?: string;
  companyName?: string;

  // Community/Poll fields
  pollOptions?: { id: string; text: string; votes: number }[];
  pollEndsAt?: string;
  postContent?: string;

  // Additional metadata
  metadata?: Record<string, unknown>;
}

/**
 * Create listing input type
 */
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

/**
 * Update listing input type
 */
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

/**
 * Options for fetching marketplace listings
 */
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
    imageUrl: dbListing.image_urls?.[0] || dbListing.image_url,
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

/**
 * Get marketplace listings with filtering, search, and pagination
 * Fetches from marketplace_listings table with seller profile relations
 */
export async function getMarketplaceListings(
  options: GetListingsOptions | MarketplaceFilters = {}
): Promise<{ listings?: AnyListing[]; data?: AnyListing[]; total?: number; error: string | null }> {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  console.log("🔧 [getMarketplaceListings] Starting fetch", {
    options,
    userId: user?.id,
    timestamp: new Date().toISOString(),
  });

  try {
    // Build base query with seller relation
    let query = supabase
      .from("marketplace_listings")
      .select(`
        *,
        seller:profiles!seller_id (
          id,
          full_name,
          avatar_url
        ),
        category:marketplace_categories (
          id,
          name,
          slug,
          is_active
        ),
        university:universities!university_id(id, name)
      `)
      .eq("status", "active"); // Filter by status column, not is_active

    console.log("📝 [getMarketplaceListings] Base query built (filtering by status=active)");

    // Handle both GetListingsOptions and MarketplaceFilters
    const opts = options as any;

    // Filter by category/listing_type
    if (opts.category && opts.category !== "all") {
      if (Array.isArray(opts.category)) {
        // Map each category to its DB type
        const dbTypes = opts.category
          .map((cat: string) => categoryToDBTypeMap[cat] || cat)
          .flat();
        query = query.in("listing_type", dbTypes);
      } else {
        // Use the comprehensive category map
        const dbType = categoryToDBTypeMap[opts.category];
        if (dbType) {
          if (Array.isArray(dbType)) {
            query = query.in("listing_type", dbType);
          } else {
            query = query.eq("listing_type", dbType);
          }
        }
        // If no mapping found, don't filter (safer than passing invalid enum)
      }
    }

    // Search in title and description
    if (opts.search) {
      const searchTerm = `%${opts.search}%`;
      query = query.or(`title.ilike.${searchTerm},description.ilike.${searchTerm}`);
    }

    // Price range filters
    if (opts.priceRange) {
      const [minPrice, maxPrice] = opts.priceRange;
      if (minPrice > 0) {
        query = query.gte("price", minPrice);
      }
      if (maxPrice > 0) {
        query = query.lte("price", maxPrice);
      }
    } else {
      if (opts.priceMin !== undefined && opts.priceMin > 0) {
        query = query.gte("price", opts.priceMin);
      }
      if (opts.priceMax !== undefined) {
        query = query.lte("price", opts.priceMax);
      }
    }

    // University-only filter (requires user to be authenticated)
    if (opts.universityOnly && user) {
      console.log("🎓 [getMarketplaceListings] Applying university filter");

      // Get user's university from their student profile
      const { data: studentProfile, error: studentError } = await supabase
        .from("students")
        .select("university_id")
        .eq("profile_id", user.id)
        .single();

      console.log("👤 [getMarketplaceListings] Student profile:", {
        found: !!studentProfile,
        universityId: studentProfile?.university_id,
        error: studentError?.message,
      });

      if (studentProfile?.university_id) {
        query = query.eq("university_id", studentProfile.university_id);
        console.log("✅ [getMarketplaceListings] University filter applied:", studentProfile.university_id);
      } else {
        console.log("⚠️ [getMarketplaceListings] No university_id found, skipping filter");
      }
    }

    // Sorting
    switch (opts.sortBy) {
      case "price_low":
        query = query.order("price", { ascending: true, nullsFirst: false });
        break;
      case "price_high":
        query = query.order("price", { ascending: false, nullsFirst: false });
        break;
      case "popular":
        query = query.order("view_count", { ascending: false });
        break;
      case "recent":
      default:
        query = query.order("created_at", { ascending: false });
    }

    // Pagination
    if (opts.limit) {
      query = query.limit(opts.limit);
    }
    if (opts.offset) {
      query = query.range(opts.offset, opts.offset + (opts.limit || 20) - 1);
    }

    console.log("🚀 [getMarketplaceListings] Executing query...");

    const { data: listings, error, count } = await query;

    console.log("📊 [getMarketplaceListings] Query result:", {
      success: !error,
      listingsCount: listings?.length,
      count,
      error: error?.message,
      errorDetails: error,
    });

    if (error) {
      console.error("❌ [getMarketplaceListings] Database error:", {
        message: error.message,
        details: error.details,
        hint: error.hint,
        code: error.code,
      });
      return { listings: [], data: [], total: 0, error: error.message };
    }

    // Transform listings to frontend format
    let transformedListings = (listings || [])
      .map((listing) => transformListing(listing))
      .filter((l): l is AnyListing => l !== null);

    // Apply client-side sorting if needed
    if (opts.sortBy && (opts.sortBy === "price_low" || opts.sortBy === "price_high")) {
      transformedListings.sort((a, b) => {
        const priceA = "price" in a ? a.price : "monthlyRent" in a ? a.monthlyRent : 0;
        const priceB = "price" in b ? b.price : "monthlyRent" in b ? b.monthlyRent : 0;
        return opts.sortBy === "price_low" ? priceA - priceB : priceB - priceA;
      });
    }

    // If user is authenticated, check for favorites
    if (user && transformedListings.length > 0) {
      const listingIds = transformedListings.map((l) => l.id);
      const { data: favorites } = await supabase
        .from("marketplace_favorites")
        .select("listing_id")
        .eq("user_id", user.id)
        .in("listing_id", listingIds);

      const favoriteIds = new Set(favorites?.map((f) => f.listing_id) || []);
      transformedListings = transformedListings.map((listing) => ({
        ...listing,
        isLiked: favoriteIds.has(listing.id),
      }));
    }

    console.log("✅ [getMarketplaceListings] Success:", {
      transformedCount: transformedListings.length,
      total: count || transformedListings.length || 0,
    });

    return {
      listings: transformedListings,
      data: transformedListings,
      total: count || transformedListings.length || 0,
      error: null,
    };
  } catch (error: any) {
    console.error("💥 [getMarketplaceListings] Unexpected error:", {
      message: error.message,
      stack: error.stack,
    });
    return { listings: [], data: [], total: 0, error: error.message };
  }
}

/**
 * Get a single marketplace listing by ID
 */
export async function getListingById(id: string) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  // Validate UUID format
  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  if (!uuidRegex.test(id)) {
    return null;
  }

  try {
    const { data: listing, error } = await supabase
      .from("marketplace_listings")
      .select(`
        *,
        seller:profiles!seller_id (
          id,
          full_name,
          avatar_url
        ),
        category:marketplace_categories (
          id,
          name,
          slug,
          is_active
        ),
        university:universities!university_id(id, name)
      `)
      .eq("id", id)
      .eq("status", "active")
      .single();

    if (error) {
      return null;
    }

    // Increment view count
    await supabase
      .from("marketplace_listings")
      .update({ view_count: (listing.view_count || 0) + 1 })
      .eq("id", id);

    // Check if favorited by current user
    let isFavorited = false;
    if (user) {
      const { data: favorite } = await supabase
        .from("marketplace_favorites")
        .select("id")
.eq("user_id", user.id)
        .eq("listing_id", id)
        .single();

      isFavorited = !!favorite;
    }

    const transformed = transformListing(listing);
    return transformed ? { ...transformed, isLiked: isFavorited } : null;
  } catch {
    return null;
  }
}

/**
 * Get a single marketplace listing by ID
 */
export async function getMarketplaceListingById(
  id: string
): Promise<{ data: AnyListing | null; error: string | null }> {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  try {
    const { data: listing, error } = await supabase
      .from("marketplace_listings")
      .select(`
        *,
        seller:profiles!seller_id(id, full_name, avatar_url),
        category:marketplace_categories(id, name, slug),
        university:universities!university_id(id, name)
      `)
      .eq("id", id)
      .single();

    if (error) throw error;

    const transformedListing = transformListing(listing);

    // Check if user has favorited this listing
    if (user && transformedListing) {
      const { data: favorite } = await supabase
        .from("marketplace_favorites")
        .select("id")
        .eq("user_id", user.id)
        .eq("listing_id", id)
        .single();

      transformedListing.isLiked = !!favorite;
    }

    // Increment view count
    if (listing) {
      await supabase
        .from("marketplace_listings")
        .update({ view_count: (listing.view_count || 0) + 1 })
        .eq("id", id);
    }

    return { data: transformedListing, error: null };
  } catch (error: any) {
    return { data: null, error: error.message };
  }
}

/**
 * Get listings created by the current user
 */
export async function getUserListings(status?: "active" | "inactive" | "all") {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) return [];

  try {
    let query = supabase
      .from("marketplace_listings")
      .select(`
        *,
        category:marketplace_categories (
          id,
          name,
          slug,
          is_active
        ),
        seller:profiles!seller_id (
          id,
          full_name,
          avatar_url
        ),
        university:universities!university_id(id, name)
      `)
      .eq("seller_id", user.id)
      .order("created_at", { ascending: false });

    if (status === "active") {
      query = query.eq("status", "active");
    } else if (status === "inactive") {
      query = query.in("status", ["sold", "rented", "expired", "removed"]);
    }
    // "all" doesn't filter by status

    const { data: listings, error } = await query;

    if (error) {
      return [];
    }

    return (listings || [])
      .map((l) => transformListing(l))
      .filter((l): l is AnyListing => l !== null);
  } catch {
    return [];
  }
}

/**
 * Create a new marketplace listing
 */
export async function createListing(data: CreateListingData) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { error: "Not authenticated" };
  }

  // Validate required fields
  if (!data.title || data.title.trim().length === 0) {
    return { error: "Title is required" };
  }
  if (!data.listingType) {
    return { error: "Listing type is required" };
  }

  try {
    // Get user's university for university_id if they're a student
    let universityId: string | null = null;
    const { data: studentProfile } = await supabase
      .from("students")
      .select("university_id")
      .eq("profile_id", user.id)
      .single();

    if (studentProfile?.university_id) {
      universityId = studentProfile.university_id;
    }

    const dbListingType = reverseListingTypeMap[data.listingType as ListingType] || data.listingType;

    const { data: listing, error } = await supabase
      .from("marketplace_listings")
      .insert({
        seller_id: user.id,
        listing_type: dbListingType,
        title: data.title.trim(),
        description: data.description?.trim() || null,
        price: data.price || null,
        price_negotiable: data.priceNegotiable ?? true,
        image_url: data.imageUrl || null,
        image_urls: data.imageUrls || [],
        category_id: data.categoryId || null,
        university_id: universityId,
        city: data.city?.trim() || null,
        location_text: data.locationText?.trim() || null,
        location: data.location?.trim() || null,

        // Product-specific fields
        item_condition: data.itemCondition || null,

        // Housing-specific fields
        housing_type: data.housingType || null,
        bedrooms: data.bedrooms || null,
        rent_period: data.rentPeriod || null,
        available_from: data.availableFrom || null,

        // Opportunity-specific fields
        opportunity_type: data.opportunityType || null,
        opportunity_url: data.opportunityUrl || null,
        application_deadline: data.applicationDeadline || null,
        company_name: data.companyName || null,

        // Community/Poll fields
        poll_options: data.pollOptions || null,
        poll_ends_at: data.pollEndsAt || null,
        post_content: data.postContent || null,

        // Metadata and status
        metadata: data.metadata || {},
        status: "active", // Set status to active (no is_active column)
        view_count: 0,
      })
      .select()
      .single();

    if (error) {
      return { error: error.message };
    }

    revalidatePath("/connect");
    return { success: true, listing };
  } catch (error: any) {
    return { error: error.message };
  }
}

/**
 * Create a new marketplace listing (alternative function)
 */
export async function createMarketplaceListing(
  input: CreateListingInput
): Promise<{ data: { id: string } | null; error: string | null }> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return { data: null, error: "Not authenticated" };
  }

  try {
    // Get user's university ID from student profile
    const { data: student } = await supabase
      .from("students")
      .select("university_id")
      .eq("profile_id", user.id)
      .single();

    const dbListingType = reverseListingTypeMap[input.type];

    const { data: listing, error } = await supabase
      .from("marketplace_listings")
      .insert({
        seller_id: user.id,
        title: input.title,
        description: input.description,
        price: input.price || 0,
        listing_type: dbListingType,
        category_id: input.categoryId,
        location: input.location,
        university_id: student?.university_id,
        image_urls: input.imageUrls || [],
        status: "active", // Use status instead of is_active
        view_count: 0,
        metadata: input.metadata || {},
      })
      .select("id")
      .single();

    if (error) throw error;

    revalidatePath("/connect");
    return { data: { id: listing.id }, error: null };
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
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return { success: false, error: "Not authenticated" };
  }

  try {
    // Verify ownership
    const { data: existing } = await supabase
      .from("marketplace_listings")
      .select("seller_id")
      .eq("id", id)
      .single();

    if (!existing || existing.seller_id !== user.id) {
      return { success: false, error: "Listing not found or access denied" };
    }

    const updateData: Record<string, any> = {
      updated_at: new Date().toISOString(),
    };

    if (input.title !== undefined) updateData.title = input.title;
    if (input.description !== undefined) updateData.description = input.description;
    if (input.price !== undefined) updateData.price = input.price;
    if (input.categoryId !== undefined) updateData.category_id = input.categoryId;
    if (input.location !== undefined) updateData.location = input.location;
    if (input.imageUrls !== undefined) updateData.image_urls = input.imageUrls;
    if (input.isActive !== undefined) updateData.status = input.isActive ? "active" : "removed";
    if (input.metadata !== undefined) updateData.metadata = input.metadata;

    const { error } = await supabase
      .from("marketplace_listings")
      .update(updateData)
      .eq("id", id);

    if (error) throw error;

    revalidatePath("/connect");
    return { success: true, error: null };
  } catch (error: any) {
    return { success: false, error: error.message };
  }
}

/**
 * Delete a marketplace listing (soft delete by setting is_active to false)
 */
export async function deleteMarketplaceListing(
  id: string
): Promise<{ success: boolean; error: string | null }> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return { success: false, error: "Not authenticated" };
  }

  try {
    // Verify ownership
    const { data: existing } = await supabase
      .from("marketplace_listings")
      .select("seller_id")
      .eq("id", id)
      .single();

    if (!existing || existing.seller_id !== user.id) {
      return { success: false, error: "Listing not found or access denied" };
    }

    // Soft delete - change status to removed
    const { error } = await supabase
      .from("marketplace_listings")
      .update({ status: "removed", updated_at: new Date().toISOString() })
      .eq("id", id);

    if (error) throw error;

    revalidatePath("/connect");
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
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return { success: false, isFavorited: false, error: "Not authenticated" };
  }

  try {
    // Check if already favorited
    const { data: existing } = await supabase
      .from("marketplace_favorites")
      .select("id")
      .eq("user_id", user.id)
      .eq("listing_id", listingId)
      .single();

    if (existing) {
      // Remove favorite
      const { error } = await supabase
        .from("marketplace_favorites")
        .delete()
        .eq("id", existing.id);

      if (error) throw error;

      revalidatePath("/connect");
      return { success: true, isFavorited: false, error: null };
    } else {
      // Add favorite
      const { error } = await supabase
        .from("marketplace_favorites")
        .insert({ user_id: user.id, listing_id: listingId });

      if (error) throw error;

      revalidatePath("/connect");
      return { success: true, isFavorited: true, error: null };
    }
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
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return { data: null, error: "Not authenticated" };
  }

  try {
    const { data: favorites, error: favError } = await supabase
      .from("marketplace_favorites")
      .select("listing_id")
      .eq("user_id", user.id)
      .order("created_at", { ascending: false });

    if (favError) throw favError;

    if (!favorites || favorites.length === 0) {
      return { data: [], error: null };
    }

    const listingIds = favorites.map((f) => f.listing_id);

    const { data: listings, error } = await supabase
      .from("marketplace_listings")
      .select(`
        *,
        seller:profiles!seller_id(id, full_name, avatar_url),
        category:marketplace_categories(id, name, slug),
        university:universities!university_id(id, name)
      `)
      .in("id", listingIds)
      .eq("status", "active"); // Use status column

    if (error) throw error;

    const transformedListings = (listings || [])
      .map((listing) => transformListing(listing))
      .filter((l): l is AnyListing => l !== null)
      .map((listing) => ({
        ...listing,
        isLiked: true,
      }));

    return { data: transformedListings, error: null };
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
  const supabase = await createClient();

  try {
    const { data: categories, error } = await supabase
      .from("marketplace_categories")
      .select("*")
      .eq("is_active", true)
      .order("display_order", { ascending: true });

    if (error) throw error;

    return { data: categories || [], error: null };
  } catch (error: any) {
    return { data: null, error: error.message };
  }
}

/**
 * Upload image to Cloudinary for marketplace listing
 */
export async function uploadMarketplaceImage(file: {
  name: string;
  type: string;
  size: number;
  base64Data: string;
}): Promise<{ data: { url: string; publicId: string } | null; error: string | null }> {
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

    const folder = `assignx/marketplace/${user.id}`;
    const result = await cloudinary.uploader.upload(
      `data:${file.type};base64,${file.base64Data}`,
      {
        folder,
        resource_type: "image",
        use_filename: true,
        unique_filename: true,
      }
    );

    return {
      data: {
        url: result.secure_url,
        publicId: result.public_id,
      },
      error: null,
    };
  } catch (error: any) {
    console.error("Cloudinary upload error:", error);
    return { data: null, error: error.message || "Failed to upload image" };
  }
}