import { apiClient } from '@/lib/api/client'

/**
 * Marketplace listing type
 */
interface MarketplaceListing {
  id: string
  seller_id: string
  title: string
  description: string | null
  price: number | null
  listing_type: string | null
  status: string | null
  is_active: boolean | null
  view_count: number | null
  city: string | null
  image_url: string | null
  images: string[] | null
  category_id: string | null
  created_at: string | null
  updated_at: string | null
  [key: string]: any
}

/**
 * Marketplace listing insert type
 */
type MarketplaceListingInsert = Partial<MarketplaceListing>

/**
 * Marketplace listing update type
 */
type MarketplaceListingUpdate = Partial<MarketplaceListing>

/**
 * Marketplace category type
 */
interface MarketplaceCategory {
  id: string
  name: string
  slug: string
  is_active: boolean
  display_order: number | null
  [key: string]: any
}

/**
 * Listing type enum
 */
type ListingType = 'sell' | 'rent' | 'free' | 'opportunity' | 'housing' | 'community_post' | 'poll' | 'event'

/**
 * Listing with seller info
 */
interface ListingWithSeller extends MarketplaceListing {
  seller?: {
    id: string
    full_name: string
    avatar_url: string | null
  }
  category?: MarketplaceCategory | null
  is_favorited?: boolean
  is_featured?: boolean
}

/**
 * Filter options for listings
 */
interface ListingFilters {
  type?: ListingType
  categoryId?: string
  city?: string
  university?: string
  minPrice?: number
  maxPrice?: number
  searchTerm?: string
  sellerId?: string
  isFeatured?: boolean
}

/**
 * Marketplace service for campus connect features.
 * Uses API client instead of API.
 */
export const marketplaceService = {
  /**
   * Gets marketplace listings with filters.
   */
  async getListings(
    filters?: ListingFilters,
    pagination?: { page?: number; limit?: number },
    userId?: string
  ): Promise<{ listings: ListingWithSeller[]; total: number }> {
    const params = new URLSearchParams()
    const page = pagination?.page || 1
    const limit = pagination?.limit || 20

    params.set('page', String(page))
    params.set('limit', String(limit))

    if (filters?.type) params.set('type', filters.type)
    if (filters?.categoryId) params.set('categoryId', filters.categoryId)
    if (filters?.city) params.set('city', filters.city)
    if (filters?.university) params.set('universityId', filters.university)
    if (filters?.minPrice !== undefined) params.set('minPrice', String(filters.minPrice))
    if (filters?.maxPrice !== undefined) params.set('maxPrice', String(filters.maxPrice))
    if (filters?.searchTerm) params.set('search', filters.searchTerm)
    if (filters?.sellerId) params.set('sellerId', filters.sellerId)
    if (filters?.isFeatured) params.set('isFeatured', 'true')
    if (userId) params.set('userId', userId)

    const result = await apiClient<{ listings: ListingWithSeller[]; total: number }>(
      `/api/marketplace/listings?${params.toString()}`
    )
    return {
      listings: result.listings || [],
      total: result.total || 0,
    }
  },

  /**
   * Gets a single listing by ID.
   */
  async getListingById(
    listingId: string,
    userId?: string
  ): Promise<ListingWithSeller | null> {
    try {
      const params = userId ? `?userId=${userId}` : ''
      const result = await apiClient<{ listing: ListingWithSeller }>(
        `/api/marketplace/listings/${listingId}${params}`
      )
      return result.listing || result as any
    } catch {
      return null
    }
  },

  /**
   * Creates a new listing.
   */
  async createListing(
    listing: MarketplaceListingInsert,
    images?: File[]
  ): Promise<MarketplaceListing> {
    // Upload images first if provided
    const imageUrls: string[] = []
    if (images && images.length > 0) {
      for (const image of images) {
        const formData = new FormData()
        formData.append('file', image)
        formData.append('folder', 'marketplace-images')

        const uploadResult = await apiClient<{ url: string }>('/api/upload', {
          method: 'POST',
          body: formData,
          isFormData: true,
        })
        imageUrls.push(uploadResult.url)
      }
    }

    const result = await apiClient<{ listing: MarketplaceListing }>('/api/marketplace/listings', {
      method: 'POST',
      body: JSON.stringify({
        ...listing,
        images: imageUrls,
        image_url: imageUrls[0] || null,
      }),
    })
    return result.listing || result as any
  },

  /**
   * Updates an existing listing.
   */
  async updateListing(
    listingId: string,
    updates: MarketplaceListingUpdate
  ): Promise<MarketplaceListing> {
    const result = await apiClient<{ listing: MarketplaceListing }>(
      `/api/marketplace/listings/${listingId}`,
      {
        method: 'PATCH',
        body: JSON.stringify(updates),
      }
    )
    return result.listing || result as any
  },

  /**
   * Deletes a listing (soft delete).
   */
  async deleteListing(listingId: string): Promise<void> {
    await apiClient(`/api/marketplace/listings/${listingId}`, {
      method: 'DELETE',
    })
  },

  /**
   * Gets all marketplace categories.
   */
  async getCategories(): Promise<MarketplaceCategory[]> {
    const result = await apiClient<{ categories: MarketplaceCategory[] }>(
      '/api/marketplace/categories'
    )
    return result.categories || result as any
  },

  /**
   * Toggles favorite status for a listing.
   */
  async toggleFavorite(listingId: string, _userId: string): Promise<boolean> {
    const result = await apiClient<{ isFavorited: boolean }>(
      `/api/marketplace/listings/${listingId}/favorite`,
      { method: 'POST' }
    )
    return result.isFavorited ?? true
  },

  /**
   * Gets user's favorite listings.
   */
  async getFavorites(userId: string): Promise<ListingWithSeller[]> {
    const result = await apiClient<{ listings: ListingWithSeller[] }>(
      `/api/marketplace/favorites?userId=${userId}`
    )
    return result.listings || result as any
  },

  /**
   * Gets user's own listings.
   */
  async getMyListings(userId: string): Promise<MarketplaceListing[]> {
    const result = await apiClient<{ listings: MarketplaceListing[] }>(
      `/api/marketplace/listings?sellerId=${userId}`
    )
    return result.listings || result as any
  },

  /**
   * Reports a listing.
   */
  async reportListing(
    listingId: string,
    _reporterId: string,
    reason: string
  ): Promise<void> {
    await apiClient(`/api/marketplace/listings/${listingId}/report`, {
      method: 'POST',
      body: JSON.stringify({ reason }),
    })
  },

  /**
   * Gets trending listings (most viewed).
   */
  async getTrending(limit: number = 10): Promise<ListingWithSeller[]> {
    const result = await apiClient<{ listings: ListingWithSeller[] }>(
      `/api/marketplace/listings?sort=trending&limit=${limit}`
    )
    return result.listings || result as any
  },

  /**
   * Gets nearby listings based on university.
   */
  async getNearby(
    universityId: string,
    limit: number = 10
  ): Promise<ListingWithSeller[]> {
    const result = await apiClient<{ listings: ListingWithSeller[] }>(
      `/api/marketplace/listings?universityId=${universityId}&limit=${limit}`
    )
    return result.listings || result as any
  },
}

// Re-export types
export type {
  MarketplaceListing,
  MarketplaceListingInsert,
  MarketplaceListingUpdate,
  MarketplaceCategory,
  ListingWithSeller,
  ListingFilters,
  ListingType,
}
