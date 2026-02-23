import { createClient } from '@/lib/supabase/client'
import type { Database } from '@/types/database'

/**
 * Type aliases for marketplace-related tables
 */
type MarketplaceListing = Database['public']['Tables']['marketplace_listings']['Row']
type MarketplaceListingInsert = Database['public']['Tables']['marketplace_listings']['Insert']
type MarketplaceListingUpdate = Database['public']['Tables']['marketplace_listings']['Update']
type MarketplaceCategory = Database['public']['Tables']['marketplace_categories']['Row']

/**
 * Listing type enum (matches database enum)
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
  images?: string[]
  is_favorited?: boolean
  image_url?: string | null
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
 * Pagination options
 */
interface PaginationOptions {
  page?: number
  limit?: number
}

const supabase = createClient()

/**
 * Marketplace service for campus connect features.
 * Handles listings, categories, favorites, and search.
 */
export const marketplaceService = {
  /**
   * Gets marketplace listings with filters.
   * @param filters - Optional filters
   * @param pagination - Pagination options
   * @param userId - Current user ID (for favorites check)
   * @returns Array of listings with seller info
   */
  async getListings(
    filters?: ListingFilters,
    pagination?: PaginationOptions,
    userId?: string
  ): Promise<{ listings: ListingWithSeller[]; total: number }> {
    const page = pagination?.page || 1
    const limit = pagination?.limit || 20
    const offset = (page - 1) * limit

    let query = supabase
      .from('marketplace_listings')
      .select(`
        *,
        seller:profiles!marketplace_listings_seller_id_fkey(id, full_name, avatar_url),
        category:marketplace_categories(*)
      `, { count: 'exact' })
      .eq('is_active', true)
      .order('created_at', { ascending: false })

    // Apply filters
    if (filters?.type) {
      query = query.eq('listing_type', filters.type)
    }
    if (filters?.categoryId) {
      query = query.eq('category_id', filters.categoryId)
    }
    if (filters?.city) {
      query = query.eq('city', filters.city)
    }
    if (filters?.university) {
      query = query.eq('university_id', filters.university)
    }
    if (filters?.minPrice !== undefined) {
      query = query.gte('price', filters.minPrice)
    }
    if (filters?.maxPrice !== undefined) {
      query = query.lte('price', filters.maxPrice)
    }
    if (filters?.searchTerm) {
      query = query.or(`title.ilike.%${filters.searchTerm}%,description.ilike.%${filters.searchTerm}%`)
    }
    if (filters?.sellerId) {
      query = query.eq('seller_id', filters.sellerId)
    }
    if (filters?.isFeatured) {
      query = query.eq('is_featured', true)
    }

    // Apply pagination
    query = query.range(offset, offset + limit - 1)

    const { data, error, count } = await query

    if (error) throw error

    // Check favorites if user is logged in
    let listings = data as ListingWithSeller[]
    if (userId && listings.length > 0) {
      const listingIds = listings.map((l) => l.id)
      const { data: favorites } = await supabase
        .from('marketplace_favorites')
        .select('listing_id')
        .eq('profile_id', userId)
        .in('listing_id', listingIds)

      const favoriteIds = new Set(favorites?.map((f: any) => f.listing_id) || [])
      listings = listings.map((l) => ({
        ...l,
        is_favorited: favoriteIds.has(l.id),
      }))
    }

    return { listings, total: count || 0 }
  },

  /**
   * Gets a single listing by ID.
   * @param listingId - The listing UUID
   * @param userId - Current user ID (for favorites check)
   * @returns Listing with full details
   */
  async getListingById(
    listingId: string,
    userId?: string
  ): Promise<ListingWithSeller | null> {
    const { data, error } = await supabase
      .from('marketplace_listings')
      .select(`
        *,
        seller:profiles!marketplace_listings_seller_id_fkey(id, full_name, avatar_url),
        category:marketplace_categories(*)
      `)
      .eq('id', listingId)
      .single()

    if (error) {
      if (error.code === 'PGRST116') return null
      throw error
    }

    // Increment view count
    await supabase
      .from('marketplace_listings')
      .update({ view_count: (data.view_count || 0) + 1 })
      .eq('id', listingId)

    // Check if favorited
    let isFavorited = false
    if (userId) {
      const { data: fav } = await supabase
        .from('marketplace_favorites')
        .select('id')
        .eq('profile_id', userId)
        .eq('listing_id', listingId)
        .single()
      isFavorited = !!fav
    }

    return {
      ...data,
      is_favorited: isFavorited,
    } as ListingWithSeller
  },

  /**
   * Creates a new listing.
   * @param listing - The listing data
   * @param images - Array of images to upload
   * @returns The created listing
   */
  async createListing(
    listing: MarketplaceListingInsert,
    images?: File[]
  ): Promise<MarketplaceListing> {
    // Upload images first if provided
    const imageUrls: string[] = []
    if (images && images.length > 0) {
      for (const image of images) {
        const fileName = `${listing.seller_id}/${Date.now()}_${image.name}`
        const { error: uploadError } = await supabase.storage
          .from('marketplace-images')
          .upload(fileName, image)

        if (uploadError) throw uploadError

        const { data: urlData } = supabase.storage
          .from('marketplace-images')
          .getPublicUrl(fileName)

        imageUrls.push(urlData.publicUrl)
      }
    }

    // Create listing with image URLs
    const { data, error } = await supabase
      .from('marketplace_listings')
      .insert({
        ...listing,
        images: imageUrls,
        image_url: imageUrls[0] || null,
      })
      .select()
      .single()

    if (error) throw error
    return data
  },

  /**
   * Updates an existing listing.
   * @param listingId - The listing UUID
   * @param updates - The fields to update
   * @returns The updated listing
   */
  async updateListing(
    listingId: string,
    updates: MarketplaceListingUpdate
  ): Promise<MarketplaceListing> {
    const { data, error } = await supabase
      .from('marketplace_listings')
      .update({
        ...updates,
        updated_at: new Date().toISOString(),
      })
      .eq('id', listingId)
      .select()
      .single()

    if (error) throw error
    return data
  },

  /**
   * Deletes a listing (soft delete).
   * @param listingId - The listing UUID
   */
  async deleteListing(listingId: string): Promise<void> {
    const { error } = await supabase
      .from('marketplace_listings')
      .update({ is_active: false })
      .eq('id', listingId)

    if (error) throw error
  },

  /**
   * Gets all marketplace categories.
   * @returns Array of categories
   */
  async getCategories(): Promise<MarketplaceCategory[]> {
    const { data, error } = await supabase
      .from('marketplace_categories')
      .select('*')
      .eq('is_active', true)
      .order('display_order')

    if (error) throw error
    return data
  },

  /**
   * Toggles favorite status for a listing.
   * @param listingId - The listing UUID
   * @param userId - The user's profile ID
   * @returns Whether the listing is now favorited
   */
  async toggleFavorite(listingId: string, userId: string): Promise<boolean> {
    // Check if already favorited
    const { data: existing } = await supabase
      .from('marketplace_favorites')
      .select('id')
      .eq('profile_id', userId)
      .eq('listing_id', listingId)
      .single()

    if (existing) {
      // Remove favorite
      await supabase
        .from('marketplace_favorites')
        .delete()
        .eq('id', existing.id)
      return false
    } else {
      // Add favorite
      await supabase.from('marketplace_favorites').insert({
        profile_id: userId,
        listing_id: listingId,
      })
      return true
    }
  },

  /**
   * Gets user's favorite listings.
   * @param userId - The user's profile ID
   * @returns Array of favorited listings
   */
  async getFavorites(userId: string): Promise<ListingWithSeller[]> {
    const { data: favorites, error } = await supabase
      .from('marketplace_favorites')
      .select(`
        listing:marketplace_listings(
          *,
          seller:profiles!marketplace_listings_seller_id_fkey(id, full_name, avatar_url),
          category:marketplace_categories(*)
        )
      `)
      .eq('profile_id', userId)

    if (error) throw error

    const results = (favorites || [])
      .filter((f: any) => f.listing !== null)
      .map((f: any) => ({ ...f.listing, is_favorited: true }))

    return results as unknown as ListingWithSeller[]
  },

  /**
   * Gets user's own listings.
   * @param userId - The user's profile ID
   * @returns Array of user's listings
   */
  async getMyListings(userId: string): Promise<MarketplaceListing[]> {
    const { data, error } = await supabase
      .from('marketplace_listings')
      .select('*')
      .eq('seller_id', userId)
      .order('created_at', { ascending: false })

    if (error) throw error
    return data
  },

  /**
   * Reports a listing.
   * @param listingId - The listing UUID
   * @param reporterId - The reporter's profile ID
   * @param reason - The report reason
   */
  async reportListing(
    listingId: string,
    reporterId: string,
    reason: string
  ): Promise<void> {
    const { error } = await supabase.from('marketplace_reports').insert({
      listing_id: listingId,
      reporter_id: reporterId,
      reason,
    })

    if (error) throw error
  },

  /**
   * Gets trending listings (most viewed).
   * @param limit - Number of listings to fetch
   * @returns Array of trending listings
   */
  async getTrending(limit: number = 10): Promise<ListingWithSeller[]> {
    const { data, error } = await supabase
      .from('marketplace_listings')
      .select(`
        *,
        seller:profiles!marketplace_listings_seller_id_fkey(id, full_name, avatar_url)
      `)
      .eq('is_active', true)
      .order('view_count', { ascending: false })
      .limit(limit)

    if (error) throw error
    return data as ListingWithSeller[]
  },

  /**
   * Gets nearby listings based on university.
   * @param universityId - The university UUID
   * @param limit - Number of listings to fetch
   * @returns Array of nearby listings
   */
  async getNearby(
    universityId: string,
    limit: number = 10
  ): Promise<ListingWithSeller[]> {
    const { data, error } = await supabase
      .from('marketplace_listings')
      .select(`
        *,
        seller:profiles!marketplace_listings_seller_id_fkey(id, full_name, avatar_url)
      `)
      .eq('is_active', true)
      .eq('university_id', universityId)
      .order('created_at', { ascending: false })
      .limit(limit)

    if (error) throw error
    return data as ListingWithSeller[]
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
