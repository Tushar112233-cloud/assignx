/**
 * Marketplace service layer for business logic
 * Wraps server actions and provides client-side utilities
 *
 * This service provides:
 * - Typed wrappers around server actions
 * - Client-side caching and optimistic updates
 * - Business logic for marketplace operations
 * - Error handling and retry logic
 */

import {
  getMarketplaceListings,
  getMarketplaceListingById,
  createMarketplaceListing,
  updateMarketplaceListing,
  deleteMarketplaceListing,
  toggleMarketplaceFavorite,
  getUserFavoriteListings,
  getUserListings,
  getMarketplaceCategories,
  uploadMarketplaceImage,
  type CreateListingInput,
  type UpdateListingInput,
} from "@/lib/actions/marketplace";
import type {
  MarketplaceFilters,
  AnyListing,
  ListingType,
  ProductCondition,
} from "@/types/marketplace";

/**
 * Result type for service operations
 */
interface ServiceResult<T> {
  data: T | null;
  error: string | null;
  success: boolean;
}

/**
 * Pagination options for listing queries
 */
interface PaginationOptions {
  page?: number;
  limit?: number;
}

/**
 * Create listing request with image files
 */
interface CreateListingRequest {
  type: ListingType;
  title: string;
  description?: string;
  price?: number;
  categoryId?: string;
  location?: string;
  images?: Array<{
    name: string;
    type: string;
    size: number;
    base64Data: string;
  }>;
  metadata?: {
    // Product specific
    condition?: ProductCondition;
    isNegotiable?: boolean;
    // Housing specific
    roomType?: "single" | "shared" | "flat";
    availableFrom?: string;
    amenities?: string[];
    // Opportunity specific
    opportunityType?: "internship" | "job" | "event" | "gig" | "workshop";
    company?: string;
    isRemote?: boolean;
    deadline?: string;
    stipend?: number;
    duration?: string;
    // Community specific
    postType?: "question" | "review" | "poll" | "discussion";
    pollOptions?: Array<{ text: string }>;
    tags?: string[];
  };
}

/**
 * Category with listing count
 */
interface CategoryWithCount {
  id: string;
  name: string;
  slug: string;
  icon?: string;
  count?: number;
}

/**
 * Marketplace service for client-side business logic
 */
export const marketplaceService = {
  /**
   * Fetches marketplace listings with filters
   * @param filters - Optional filters for listings
   * @param pagination - Pagination options
   * @returns Paginated listings with metadata
   */
  async fetchListings(
    filters?: MarketplaceFilters,
    pagination?: PaginationOptions
  ): Promise<ServiceResult<{ listings: AnyListing[]; hasMore: boolean }>> {
    try {
      const result = await getMarketplaceListings(filters);

      if (result.error) {
        return { data: null, error: result.error, success: false };
      }

      const listings = result.data || [];
      const page = pagination?.page || 1;
      const limit = pagination?.limit || 20;

      // Client-side pagination (server already returns all matching)
      const startIndex = (page - 1) * limit;
      const paginatedListings = listings.slice(startIndex, startIndex + limit);
      const hasMore = startIndex + limit < listings.length;

      return {
        data: { listings: paginatedListings, hasMore },
        error: null,
        success: true,
      };
    } catch (error) {
      return {
        data: null,
        error: error instanceof Error ? error.message : "Failed to fetch listings",
        success: false,
      };
    }
  },

  /**
   * Fetches a single listing by ID
   * @param id - Listing UUID
   * @returns The listing or null
   */
  async fetchListingById(id: string): Promise<ServiceResult<AnyListing>> {
    try {
      const result = await getMarketplaceListingById(id);

      if (result.error) {
        return { data: null, error: result.error, success: false };
      }

      return { data: result.data, error: null, success: true };
    } catch (error) {
      return {
        data: null,
        error: error instanceof Error ? error.message : "Failed to fetch listing",
        success: false,
      };
    }
  },

  /**
   * Creates a new listing with image uploads
   * @param request - Listing data with images
   * @returns Created listing ID
   */
  async createListing(
    request: CreateListingRequest
  ): Promise<ServiceResult<{ id: string }>> {
    try {
      // Upload images first if provided
      const imageUrls: string[] = [];
      if (request.images && request.images.length > 0) {
        for (const image of request.images) {
          const uploadResult = await uploadMarketplaceImage(image);
          if (uploadResult.error) {
            return { data: null, error: `Failed to upload image: ${uploadResult.error}`, success: false };
          }
          if (uploadResult.data) {
            imageUrls.push(uploadResult.data.url);
          }
        }
      }

      // Prepare listing input
      const input: CreateListingInput = {
        type: request.type,
        title: request.title,
        description: request.description,
        price: request.price,
        categoryId: request.categoryId,
        location: request.location,
        imageUrls,
        metadata: request.metadata,
      };

      const result = await createMarketplaceListing(input);

      if (result.error) {
        return { data: null, error: result.error, success: false };
      }

      return { data: result.data, error: null, success: true };
    } catch (error) {
      return {
        data: null,
        error: error instanceof Error ? error.message : "Failed to create listing",
        success: false,
      };
    }
  },

  /**
   * Updates an existing listing
   * @param id - Listing UUID
   * @param updates - Fields to update
   * @returns Success status
   */
  async updateListing(
    id: string,
    updates: UpdateListingInput
  ): Promise<ServiceResult<void>> {
    try {
      const result = await updateMarketplaceListing(id, updates);

      if (result.error) {
        return { data: null, error: result.error, success: false };
      }

      return { data: undefined, error: null, success: result.success };
    } catch (error) {
      return {
        data: null,
        error: error instanceof Error ? error.message : "Failed to update listing",
        success: false,
      };
    }
  },

  /**
   * Deletes (soft delete) a listing
   * @param id - Listing UUID
   * @returns Success status
   */
  async deleteListing(id: string): Promise<ServiceResult<void>> {
    try {
      const result = await deleteMarketplaceListing(id);

      if (result.error) {
        return { data: null, error: result.error, success: false };
      }

      return { data: undefined, error: null, success: result.success };
    } catch (error) {
      return {
        data: null,
        error: error instanceof Error ? error.message : "Failed to delete listing",
        success: false,
      };
    }
  },

  /**
   * Toggles favorite status for a listing
   * @param listingId - Listing UUID
   * @returns New favorite status
   */
  async toggleFavorite(
    listingId: string
  ): Promise<ServiceResult<{ isFavorited: boolean }>> {
    try {
      const result = await toggleMarketplaceFavorite(listingId);

      if (result.error) {
        return { data: null, error: result.error, success: false };
      }

      return {
        data: { isFavorited: result.isFavorited },
        error: null,
        success: result.success,
      };
    } catch (error) {
      return {
        data: null,
        error: error instanceof Error ? error.message : "Failed to toggle favorite",
        success: false,
      };
    }
  },

  /**
   * Fetches user's favorite listings
   * @returns Array of favorited listings
   */
  async fetchFavorites(): Promise<ServiceResult<AnyListing[]>> {
    try {
      const result = await getUserFavoriteListings();

      if (result.error) {
        return { data: null, error: result.error, success: false };
      }

      return { data: result.data || [], error: null, success: true };
    } catch (error) {
      return {
        data: null,
        error: error instanceof Error ? error.message : "Failed to fetch favorites",
        success: false,
      };
    }
  },

  /**
   * Fetches user's own listings
   * @returns Array of user's listings
   */
  async fetchMyListings(): Promise<ServiceResult<AnyListing[]>> {
    try {
      // getUserListings returns AnyListing[] directly, not { data, error }
      const listings = await getUserListings();

      return { data: listings || [], error: null, success: true };
    } catch (error) {
      return {
        data: null,
        error: error instanceof Error ? error.message : "Failed to fetch my listings",
        success: false,
      };
    }
  },

  /**
   * Fetches marketplace categories
   * @returns Array of categories
   */
  async fetchCategories(): Promise<ServiceResult<CategoryWithCount[]>> {
    try {
      const result = await getMarketplaceCategories();

      if (result.error) {
        return { data: null, error: result.error, success: false };
      }

      // Transform DB categories to CategoryWithCount (handle null vs undefined)
      const categories: CategoryWithCount[] = (result.data || []).map((cat) => ({
        id: cat.id,
        name: cat.name,
        slug: cat.slug,
        icon: cat.icon ?? undefined,
        count: undefined,
      }));

      return { data: categories, error: null, success: true };
    } catch (error) {
      return {
        data: null,
        error: error instanceof Error ? error.message : "Failed to fetch categories",
        success: false,
      };
    }
  },

  /**
   * Uploads an image for a listing
   * @param file - Image file data
   * @returns Uploaded image URL
   */
  async uploadImage(file: {
    name: string;
    type: string;
    size: number;
    base64Data: string;
  }): Promise<ServiceResult<{ url: string }>> {
    try {
      const result = await uploadMarketplaceImage(file);

      if (result.error) {
        return { data: null, error: result.error, success: false };
      }

      return { data: result.data, error: null, success: true };
    } catch (error) {
      return {
        data: null,
        error: error instanceof Error ? error.message : "Failed to upload image",
        success: false,
      };
    }
  },

  /**
   * Validates listing data before submission
   * @param data - Listing data to validate
   * @returns Validation errors or null
   */
  validateListing(data: CreateListingRequest): string[] {
    const errors: string[] = [];

    if (!data.title || data.title.trim().length < 3) {
      errors.push("Title must be at least 3 characters");
    }

    if (data.title && data.title.length > 100) {
      errors.push("Title must be less than 100 characters");
    }

    if (data.description && data.description.length > 2000) {
      errors.push("Description must be less than 2000 characters");
    }

    // Type-specific validation
    switch (data.type) {
      case "product":
        if (data.price === undefined || data.price < 0) {
          errors.push("Price must be a positive number");
        }
        break;
      case "housing":
        if (data.price === undefined || data.price < 0) {
          errors.push("Monthly rent must be a positive number");
        }
        if (!data.location || data.location.trim().length < 3) {
          errors.push("Location is required for housing listings");
        }
        break;
      case "opportunity":
        if (data.metadata?.deadline) {
          const deadline = new Date(data.metadata.deadline);
          if (deadline < new Date()) {
            errors.push("Deadline must be in the future");
          }
        }
        break;
      case "community":
        if (data.metadata?.postType === "poll") {
          if (!data.metadata.pollOptions || data.metadata.pollOptions.length < 2) {
            errors.push("Polls must have at least 2 options");
          }
        }
        break;
    }

    // Image validation
    if (data.images) {
      const maxImageSize = 5 * 1024 * 1024; // 5MB
      const allowedTypes = ["image/jpeg", "image/png", "image/webp", "image/gif"];

      for (const image of data.images) {
        if (image.size > maxImageSize) {
          errors.push(`Image "${image.name}" exceeds 5MB limit`);
        }
        if (!allowedTypes.includes(image.type)) {
          errors.push(`Image "${image.name}" has invalid format`);
        }
      }
    }

    return errors;
  },

  /**
   * Formats price for display
   * @param price - Price in number
   * @param currency - Currency code (default: INR)
   * @returns Formatted price string
   */
  formatPrice(price: number, currency = "INR"): string {
    return new Intl.NumberFormat("en-IN", {
      style: "currency",
      currency,
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
    }).format(price);
  },

  /**
   * Gets relative time string for listing
   * @param dateString - ISO date string
   * @returns Relative time string (e.g., "2 hours ago")
   */
  getRelativeTime(dateString: string): string {
    const date = new Date(dateString);
    const now = new Date();
    const diffInSeconds = Math.floor((now.getTime() - date.getTime()) / 1000);

    if (diffInSeconds < 60) {
      return "Just now";
    }

    const diffInMinutes = Math.floor(diffInSeconds / 60);
    if (diffInMinutes < 60) {
      return `${diffInMinutes} minute${diffInMinutes === 1 ? "" : "s"} ago`;
    }

    const diffInHours = Math.floor(diffInMinutes / 60);
    if (diffInHours < 24) {
      return `${diffInHours} hour${diffInHours === 1 ? "" : "s"} ago`;
    }

    const diffInDays = Math.floor(diffInHours / 24);
    if (diffInDays < 7) {
      return `${diffInDays} day${diffInDays === 1 ? "" : "s"} ago`;
    }

    const diffInWeeks = Math.floor(diffInDays / 7);
    if (diffInWeeks < 4) {
      return `${diffInWeeks} week${diffInWeeks === 1 ? "" : "s"} ago`;
    }

    const diffInMonths = Math.floor(diffInDays / 30);
    if (diffInMonths < 12) {
      return `${diffInMonths} month${diffInMonths === 1 ? "" : "s"} ago`;
    }

    const diffInYears = Math.floor(diffInMonths / 12);
    return `${diffInYears} year${diffInYears === 1 ? "" : "s"} ago`;
  },

  /**
   * Filters listings by search term (client-side)
   * @param listings - Array of listings
   * @param searchTerm - Search term
   * @returns Filtered listings
   */
  searchListings(listings: AnyListing[], searchTerm: string): AnyListing[] {
    if (!searchTerm || searchTerm.trim().length === 0) {
      return listings;
    }

    const term = searchTerm.toLowerCase().trim();
    return listings.filter((listing) => {
      const titleMatch = listing.title.toLowerCase().includes(term);
      const descriptionMatch = listing.description?.toLowerCase().includes(term);
      const userMatch = listing.userName.toLowerCase().includes(term);
      return titleMatch || descriptionMatch || userMatch;
    });
  },

  /**
   * Groups listings by type for display
   * @param listings - Array of listings
   * @returns Grouped listings by type
   */
  groupByType(listings: AnyListing[]): Record<ListingType, AnyListing[]> {
    return listings.reduce(
      (acc, listing) => {
        if (!acc[listing.type]) {
          acc[listing.type] = [];
        }
        acc[listing.type].push(listing);
        return acc;
      },
      {} as Record<ListingType, AnyListing[]>
    );
  },

  /**
   * Gets display label for listing type
   * @param type - Listing type
   * @returns Human-readable label
   */
  getTypeLabel(type: ListingType): string {
    const labels: Record<ListingType, string> = {
      product: "Products",
      housing: "Housing",
      opportunity: "Opportunities",
      community: "Community",
    };
    return labels[type] || type;
  },

  /**
   * Gets condition label for products
   * @param condition - Product condition
   * @returns Human-readable label
   */
  getConditionLabel(condition: ProductCondition): string {
    const labels: Record<ProductCondition, string> = {
      new: "Brand New",
      like_new: "Like New",
      good: "Good",
      fair: "Fair",
    };
    return labels[condition] || condition;
  },
};

// Re-export types for convenience
export type {
  ServiceResult,
  PaginationOptions,
  CreateListingRequest,
  CategoryWithCount,
};
