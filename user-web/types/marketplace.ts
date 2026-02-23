/**
 * Marketplace types for Student Connect / Campus Marketplace
 * Implements U73-U85 from feature spec
 *
 * This file contains both:
 * - Database types (DB*) matching Supabase schema exactly
 * - UI types for frontend display
 */

// =============================================================================
// DATABASE TYPES - Match Supabase schema exactly
// =============================================================================

/**
 * Database listing_type enum - matches Supabase enum exactly
 */
export type DBListingType =
  | "sell" // Items for sale
  | "rent" // Items/housing for rent
  | "free" // Free items/giveaways
  | "opportunity" // Jobs, internships, events
  | "housing" // Housing listings
  | "community_post" // Community posts
  | "poll" // Polls
  | "event"; // Events

/**
 * Database listing_status enum - matches Supabase enum exactly
 */
export type ListingStatus =
  | "draft"
  | "pending_review"
  | "active"
  | "sold"
  | "rented"
  | "expired"
  | "rejected"
  | "removed";

/**
 * Item condition values for products
 */
export type ItemCondition = "new" | "like_new" | "good" | "fair" | "poor";

/**
 * Housing type values
 */
export type HousingType = "single" | "shared" | "flat" | "pg" | "hostel";

/**
 * Opportunity type values
 */
export type OpportunityType =
  | "internship"
  | "job"
  | "event"
  | "gig"
  | "workshop"
  | "competition";

/**
 * Seller profile from profiles table (joined data)
 */
export interface DBSeller {
  id: string;
  full_name: string | null;
  avatar_url: string | null;
}

/**
 * Marketplace category from marketplace_categories table
 */
export interface DBMarketplaceCategory {
  id: string;
  name: string;
  slug: string;
  description: string | null;
  icon: string | null;
  parent_id: string | null;
  display_order: number | null;
  is_active: boolean | null;
  created_at: string | null;
}

/**
 * Database marketplace listing - matches marketplace_listings table schema
 */
export interface DBMarketplaceListing {
  id: string;
  seller_id: string;
  title: string;
  description: string | null;
  price: number | null;
  price_negotiable: boolean | null;
  listing_type: DBListingType;
  status: ListingStatus;
  category_id: string | null;
  university_id: string | null;

  // Item-specific fields
  item_condition: string | null;

  // Housing-specific fields
  housing_type: string | null;
  bedrooms: number | null;
  rent_period: string | null;
  available_from: string | null;

  // Opportunity-specific fields
  opportunity_type: string | null;
  opportunity_url: string | null;
  application_deadline: string | null;
  company_name: string | null;

  // Poll/Community fields
  poll_options: PollOption[] | null;
  poll_ends_at: string | null;
  total_votes: number | null;
  post_content: string | null;

  // Location fields
  location_text: string | null;
  city: string | null;
  latitude: number | null;
  longitude: number | null;
  distance_km: number | null;

  // Metadata fields
  view_count: number | null;
  favorites_count: number | null;
  inquiry_count: number | null;
  expires_at: string | null;
  created_at: string | null;
  updated_at: string | null;

  // Review fields
  reviewed_by: string | null;
  reviewed_at: string | null;
  rejection_reason: string | null;
}

/**
 * Marketplace listing with joined relations (from Supabase query)
 * This is the shape returned by getMarketplaceListings() and getListingById()
 */
export interface DBMarketplaceListingWithRelations extends DBMarketplaceListing {
  seller: DBSeller | null;
  category: DBMarketplaceCategory | null;
  is_favorited?: boolean;
}

/**
 * Marketplace favorite from marketplace_favorites table
 */
export interface DBMarketplaceFavorite {
  id: string;
  profile_id: string;
  listing_id: string;
  created_at: string | null;
}

// =============================================================================
// UI TYPES - For frontend display and backward compatibility
// =============================================================================

/**
 * Listing types per spec (UI-friendly names)
 * @deprecated Use DBListingType for database operations
 */
export type ListingType =
  | "product" // Hard goods: books, drafters, calculators
  | "housing" // Flatmates, room availability
  | "opportunity" // Internships, gigs, events
  | "community"; // Polls, reviews, questions

/**
 * Marketplace categories for filtering (UI-friendly)
 */
export type MarketplaceCategory =
  | "all"
  | "products"
  | "housing"
  | "opportunities"
  | "community";

/**
 * Listing condition for products (UI-friendly alias)
 */
export type ProductCondition = "new" | "like_new" | "good" | "fair";

/**
 * Base listing interface (UI representation)
 */
export interface MarketplaceListing {
  id: string;
  type: ListingType;
  title: string;
  description?: string;
  userId: string;
  userName: string;
  userAvatar?: string;
  universityId?: string;
  universityName?: string;
  createdAt: string;
  imageUrl?: string;
  likes: number;
  isLiked?: boolean;
  comments: number;
  views: number;
}

/**
 * Product listing (U77: Hard Goods)
 */
export interface ProductListing extends MarketplaceListing {
  type: "product";
  price: number;
  condition: ProductCondition;
  category: string;
  distance?: string;
  isSold?: boolean;
  isNegotiable?: boolean;
}

/**
 * Housing listing (U78: Housing)
 */
export interface HousingListing extends MarketplaceListing {
  type: "housing";
  monthlyRent: number;
  roomType: "single" | "shared" | "flat";
  location: string;
  distance?: string;
  availableFrom?: string;
  amenities?: string[];
  isAvailable: boolean;
}

/**
 * Opportunity listing (U79: Opportunities)
 */
export interface OpportunityListing extends MarketplaceListing {
  type: "opportunity";
  opportunityType: "internship" | "job" | "event" | "gig" | "workshop";
  company?: string;
  location?: string;
  isRemote?: boolean;
  deadline?: string;
  stipend?: number;
  duration?: string;
}

/**
 * Community post (U80: Community)
 */
export interface CommunityPost extends MarketplaceListing {
  type: "community";
  postType: "question" | "review" | "poll" | "discussion";
  pollOptions?: PollOption[];
  tags?: string[];
}

/**
 * Poll option for community posts
 */
export interface PollOption {
  id: string;
  text: string;
  votes: number;
  percentage?: number;
}

/**
 * Filter state for marketplace
 */
export interface MarketplaceFilters {
  category: MarketplaceCategory;
  priceRange?: [number, number];
  condition?: ProductCondition[];
  distance?: number; // km
  sortBy?: "recent" | "price_low" | "price_high" | "popular";
  universityOnly?: boolean;
}

/**
 * Union type for all listing types (UI)
 */
export type AnyListing =
  | ProductListing
  | HousingListing
  | OpportunityListing
  | CommunityPost;

// =============================================================================
// MAPPING UTILITIES
// =============================================================================

/**
 * Map database listing type to UI listing type
 */
export function mapDBListingTypeToUI(dbType: DBListingType): ListingType {
  switch (dbType) {
    case "sell":
    case "rent":
    case "free":
      return "product";
    case "housing":
      return "housing";
    case "opportunity":
      return "opportunity";
    default:
      return "community";
  }
}

/**
 * Map UI listing type to database listing type
 */
export function mapUIListingTypeToDB(uiType: ListingType): DBListingType {
  switch (uiType) {
    case "product":
      return "sell";
    case "housing":
      return "housing";
    case "opportunity":
      return "opportunity";
    case "community":
      return "free"; // Community posts typically free
    default:
      return "sell";
  }
}

/**
 * Map UI category to database listing types
 */
export function mapCategoryToDBTypes(
  category: MarketplaceCategory
): DBListingType[] | null {
  switch (category) {
    case "all":
      return null; // No filter
    case "products":
      return ["sell"];
    case "housing":
      return ["housing"];
    case "opportunities":
      return ["opportunity"];
    case "community":
      return ["community_post"];
    default:
      return null;
  }
}

/**
 * Convert database listing to UI listing format
 */
export function convertDBListingToUI(
  dbListing: DBMarketplaceListingWithRelations
): MarketplaceListing {
  return {
    id: dbListing.id,
    type: mapDBListingTypeToUI(dbListing.listing_type),
    title: dbListing.title,
    description: dbListing.description ?? undefined,
    userId: dbListing.seller_id,
    userName: dbListing.seller?.full_name ?? "Unknown",
    userAvatar: dbListing.seller?.avatar_url ?? undefined,
    universityId: dbListing.university_id ?? undefined,
    createdAt: dbListing.created_at ?? new Date().toISOString(),
    likes: dbListing.favorites_count ?? 0,
    isLiked: dbListing.is_favorited,
    comments: dbListing.inquiry_count ?? 0,
    views: dbListing.view_count ?? 0,
  };
}
