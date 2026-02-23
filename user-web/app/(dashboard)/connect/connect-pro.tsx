"use client";

import { useState, useEffect, useCallback, useMemo, useRef } from "react";
import Link from "next/link";
import { motion } from "framer-motion";
import {
  Search,
  SlidersHorizontal,
  Plus,
  Package,
  Home,
  Briefcase,
  Users,
  X,
  AlertCircle,
  RefreshCw,
  HelpCircle,
  Clock,
  ArrowRight,
  Tag,
  MessageCircle,
  MessageSquare,
} from "lucide-react";
import { AnimatedCounter } from "@/components/ui/animated-counter";
import { MasonryGrid, type ListingDisplay } from "@/components/marketplace";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet";
import { Slider } from "@/components/ui/slider";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { cn } from "@/lib/utils";
import { useUserStore } from "@/stores/user-store";
import { toast } from "sonner";
import { formatDistanceToNow } from "date-fns";
import {
  getMarketplaceListings,
  toggleMarketplaceFavorite,
} from "@/lib/actions/marketplace";
import type { AnyListing, ListingType, MarketplaceCategory } from "@/types/marketplace";
import type { Tutor, Question } from "@/types/connect";
import { BookSessionSheet } from "@/components/connect/book-session-sheet";
import { TutorProfileSheet } from "@/components/connect/tutor-profile-sheet";
import { AskQuestionSheet } from "@/components/connect/ask-question-sheet";
import { QuestionDetailSheet } from "@/components/connect/question-detail-sheet";
import { PageSkeletonProvider, StaggerItem } from "@/components/skeletons";
import { MarketplaceSkeleton } from "@/components/skeletons/pages";

// Type Maps
const listingTypeToDbType: Record<ListingType, string> = {
  product: "sell",
  housing: "housing",
  opportunity: "opportunity",
  community: "community_post",
};

type CategoryTab = "all" | "community" | "opportunity" | "product" | "housing";

const categoryTabToMarketplace: Record<CategoryTab, MarketplaceCategory> = {
  all: "all",
  community: "community",
  opportunity: "opportunities",
  product: "products",
  housing: "housing",
};

// Category Configuration matching design order
interface CategoryConfig {
  id: CategoryTab;
  label: string;
  icon: React.ElementType;
}

const categories: CategoryConfig[] = [
  { id: "community", label: "Community", icon: Users },
  { id: "opportunity", label: "Opportunities", icon: Briefcase },
  { id: "product", label: "Products", icon: Package },
  { id: "housing", label: "Housing", icon: Home },
];

// Transform Function
function transformToListingDisplay(listing: AnyListing): ListingDisplay {
  const dbListingType = listingTypeToDbType[listing.type];

  let price: number | undefined;
  if (listing.type === "product") {
    price = listing.price;
  } else if (listing.type === "housing") {
    price = listing.monthlyRent;
  } else if (listing.type === "opportunity") {
    price = listing.stipend;
  }

  return {
    id: listing.id,
    title: listing.title,
    description: listing.description,
    price,
    listing_type: dbListingType,
    is_active: true,
    view_count: listing.views,
    created_at: listing.createdAt,
    updated_at: listing.createdAt,
    seller_id: listing.userId,
    seller: {
      id: listing.userId,
      full_name: listing.userName,
      avatar_url: listing.userAvatar || null,
    },
    category: listing.type === "product" && "category" in listing
      ? { id: "", name: listing.category, slug: listing.category.toLowerCase(), is_active: true }
      : undefined,
    is_favorited: listing.isLiked,
    image_url: listing.imageUrl,
  };
}

/**
 * Campus Connect - New Design System
 * Matching the design with hero banner, large search, category tabs, and masonry grid
 * Integrates PageSkeletonProvider for minimum 1s skeleton display with staggered reveal
 */
export function ConnectPro() {
  const { user } = useUserStore();

  // Marketplace state
  const [allListings, setAllListings] = useState<AnyListing[]>([]);
  const [listings, setListings] = useState<ListingDisplay[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedCategory, setSelectedCategory] = useState<CategoryTab>("all");
  const [priceRange, setPriceRange] = useState<[number, number]>([0, 50000]);
  const [universityOnly, setUniversityOnly] = useState(false);
  const [filterSheetOpen, setFilterSheetOpen] = useState(false);

  // Tutors state
  const [tutors] = useState<Tutor[]>([]);
  const [selectedTutor, setSelectedTutor] = useState<Tutor | null>(null);
  const [showBookSession, setShowBookSession] = useState(false);
  const [showTutorProfile, setShowTutorProfile] = useState(false);
  const tutorScrollRef = useRef<HTMLDivElement>(null);

  // Q&A state
  const [qaList] = useState<Question[]>([]);
  const [showAskQuestion, setShowAskQuestion] = useState(false);
  const [selectedQuestion, setSelectedQuestion] = useState<Question | null>(null);
  const [showQuestionDetail, setShowQuestionDetail] = useState(false);

  // Stats calculations
  const stats = useMemo(() => ({
    listings: allListings.length,
    tutors: tutors.length,
    questions: qaList.length,
  }), [allListings, tutors, qaList]);

  // Fetch listings
  const fetchListings = useCallback(async () => {
    try {
      setIsLoading(true);
      setError(null);

      const filters = {
        category: categoryTabToMarketplace[selectedCategory],
        priceRange: priceRange[0] > 0 || priceRange[1] < 50000
          ? (priceRange as [number, number])
          : undefined,
        universityOnly,
      };

      const { data, error: fetchError } = await getMarketplaceListings(filters);

      if (fetchError) {
        setError(`Failed to load listings: ${fetchError}`);
        toast.error(`Failed to load listings: ${fetchError}`);
        return;
      }

      const fetchedListings = data || [];
      let filtered = fetchedListings;
      if (searchQuery) {
        const query = searchQuery.toLowerCase();
        filtered = filtered.filter(
          (l) =>
            l.title?.toLowerCase().includes(query) ||
            l.description?.toLowerCase().includes(query)
        );
      }

      setAllListings(filtered);
      const displayListings = filtered.map(transformToListingDisplay);
      setListings(displayListings);
    } catch (err) {
      const message = err instanceof Error ? err.message : "Failed to load listings";
      setError(message);
      toast.error(message);
    } finally {
      setIsLoading(false);
    }
  }, [selectedCategory, searchQuery, priceRange, universityOnly]);

  useEffect(() => {
    fetchListings();
  }, [fetchListings]);

  // Handle favorite toggle
  const handleFavorite = async (listingId: string) => {
    if (!user?.id) {
      toast.error("Please sign in to save favorites");
      return;
    }

    const listing = listings.find((l) => l.id === listingId);
    const wasLiked = listing?.is_favorited;

    setListings((prev) =>
      prev.map((l) =>
        l.id === listingId ? { ...l, is_favorited: !l.is_favorited } : l
      )
    );

    const { success, isFavorited, error } = await toggleMarketplaceFavorite(listingId);

    if (!success || error) {
      setListings((prev) =>
        prev.map((l) =>
          l.id === listingId ? { ...l, is_favorited: wasLiked } : l
        )
      );
      toast.error(error || "Failed to update favorite");
      return;
    }

    setAllListings((prev) =>
      prev.map((l) =>
        l.id === listingId ? { ...l, isLiked: isFavorited } : l
      )
    );

    toast.success(isFavorited ? "Added to favorites" : "Removed from favorites");
  };

  // Clear filters
  const clearFilters = () => {
    setSearchQuery("");
    setSelectedCategory("all");
    setPriceRange([0, 50000]);
    setUniversityOnly(false);
    setFilterSheetOpen(false);
  };

  const hasActiveFilters =
    searchQuery ||
    selectedCategory !== "all" ||
    priceRange[0] > 0 ||
    priceRange[1] < 50000 ||
    universityOnly;

  // Handle tutor actions
  const handleBookSession = (tutor: Tutor) => {
    setSelectedTutor(tutor);
    setShowBookSession(true);
  };

  const handleViewTutor = (tutor: Tutor) => {
    setSelectedTutor(tutor);
    setShowTutorProfile(true);
  };

  // Page content component - wrapped in stagger items for animation
  const PageContent = () => (
    <div className="min-h-[calc(100vh-3.5rem)] bg-background">
      {/* Curved Hero Banner */}
      <StaggerItem>
        <div className="connect-curved-hero">
          {/* Spacer - Pushes content to align illustration center with curve boundary */}
          <div className="relative h-52 md:h-64" />
        </div>
      </StaggerItem>

      {/* Illustration - Centered exactly at curve boundary (50% inside, 50% outside) */}
      <StaggerItem>
        <div className="relative z-10 -mt-16 md:-mt-20 flex justify-center px-6">
          <motion.div
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            className="relative"
          >
            {/* Illustration container */}
            <div className="relative w-28 h-28 md:w-36 md:h-36 bg-white rounded-3xl shadow-xl shadow-black/10 flex items-center justify-center">
              {/* Person with chat bubble illustration */}
              <div className="relative">
                <MessageSquare className="h-14 w-14 md:h-18 md:w-18 text-foreground/50" strokeWidth={1.5} fill="currentColor" fillOpacity={0.08} />
                <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2">
                  <div className="w-5 h-5 md:w-6 md:h-6 rounded-full bg-foreground/30" />
                </div>
              </div>
              {/* Decorative floating dots */}
              <div className="absolute -top-2 -right-2">
                <div className="h-4 w-4 rounded-full bg-blue-400/70 shadow-sm" />
              </div>
              <div className="absolute -bottom-1 -left-2">
                <div className="h-3 w-3 rounded-full bg-orange-400/70 shadow-sm" />
              </div>
              <div className="absolute top-2 -left-3">
                <div className="h-2.5 w-2.5 rounded-full bg-pink-400/60" />
              </div>
            </div>
          </motion.div>
        </div>
      </StaggerItem>

      {/* Title - Below the illustration */}
      <StaggerItem>
        <div className="text-center pt-6 pb-4 px-6">
          <h1 className="text-3xl md:text-4xl lg:text-5xl font-light tracking-tight text-foreground/90">
            &ldquo;Campus Connect&rdquo;
          </h1>
        </div>
      </StaggerItem>

      {/* Search Bar - Below title */}
      <StaggerItem>
        <div className="px-6 md:px-8 pb-4">
          <div className="max-w-3xl mx-auto">
            <div className="flex items-center gap-3 px-5 py-4 rounded-2xl bg-white border border-border/30 shadow-lg shadow-black/5">
              <Search className="h-5 w-5 text-muted-foreground shrink-0" />
              <input
                type="text"
                placeholder="Search campus posts, housing, opportunities..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="flex-1 bg-transparent border-none outline-none text-base text-foreground placeholder:text-muted-foreground"
              />
              {searchQuery && (
                <button
                  onClick={() => setSearchQuery("")}
                  className="text-muted-foreground hover:text-foreground transition-colors"
                >
                  <X className="h-4 w-4" />
                </button>
              )}
              <Sheet open={filterSheetOpen} onOpenChange={setFilterSheetOpen}>
                <SheetTrigger asChild>
                  <button className="relative p-2 rounded-lg hover:bg-muted/50 transition-colors">
                    <SlidersHorizontal className="h-5 w-5 text-muted-foreground" />
                    {hasActiveFilters && (
                      <span className="absolute top-1 right-1 h-2 w-2 rounded-full bg-primary" />
                    )}
                  </button>
                </SheetTrigger>
                <SheetContent side="bottom" className="h-auto max-h-[80vh] rounded-t-xl">
                  <SheetHeader className="pb-4">
                    <SheetTitle>Filters</SheetTitle>
                  </SheetHeader>
                  <div className="space-y-6">
                    <div className="flex items-center justify-between gap-4">
                      <div className="space-y-0.5">
                        <Label className="text-sm font-medium">My Campus Only</Label>
                        <p className="text-xs text-muted-foreground">Show listings from your university</p>
                      </div>
                      <Switch checked={universityOnly} onCheckedChange={setUniversityOnly} />
                    </div>
                    <div className="space-y-4">
                      <Label className="text-sm font-medium">Price Range</Label>
                      <Slider
                        value={priceRange}
                        onValueChange={(value) => setPriceRange(value as [number, number])}
                        min={0}
                        max={50000}
                        step={100}
                      />
                      <div className="flex justify-between text-xs text-muted-foreground">
                        <span>₹{priceRange[0].toLocaleString()}</span>
                        <span>₹{priceRange[1].toLocaleString()}</span>
                      </div>
                    </div>
                    <div className="flex gap-3 pt-2">
                      <Button variant="outline" className="flex-1" onClick={clearFilters}>
                        Clear All
                      </Button>
                      <Button className="flex-1" onClick={() => setFilterSheetOpen(false)}>
                        Apply
                      </Button>
                    </div>
                  </div>
                </SheetContent>
              </Sheet>
            </div>
          </div>
        </div>
      </StaggerItem>

      {/* Category Tabs */}
      <StaggerItem>
        <div className="px-6 md:px-8 py-4">
          <div className="flex justify-center gap-2 flex-wrap">
            {categories.map((cat) => {
              const isActive = selectedCategory === cat.id;
              return (
                <button
                  key={cat.id}
                  onClick={() => setSelectedCategory(isActive ? "all" : cat.id)}
                  className={cn(
                    "px-5 py-2.5 rounded-full text-sm font-medium transition-all border",
                    isActive
                      ? "bg-foreground text-background border-foreground"
                      : "bg-muted/50 text-foreground/70 border-border/50 hover:bg-muted hover:text-foreground"
                  )}
                >
                  {cat.label}
                </button>
              );
            })}
          </div>
        </div>
      </StaggerItem>

      {/* Main Content - Wide grid for 5 columns */}
      <StaggerItem>
        <div className="px-4 md:px-6 lg:px-10 xl:px-12 pt-2">
          <div className="w-full">

            {/* Active Filters */}
            {hasActiveFilters && (
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                className="flex items-center gap-2 flex-wrap mb-6 justify-center"
              >
                <span className="text-xs text-muted-foreground">Filters:</span>
                {searchQuery && (
                  <Badge variant="secondary" className="gap-1 text-xs">
                    &quot;{searchQuery}&quot;
                    <button onClick={() => setSearchQuery("")}>
                      <X className="h-3 w-3" />
                    </button>
                  </Badge>
                )}
                {selectedCategory !== "all" && (
                  <Badge variant="secondary" className="gap-1 text-xs">
                    {categories.find((c) => c.id === selectedCategory)?.label}
                    <button onClick={() => setSelectedCategory("all")}>
                      <X className="h-3 w-3" />
                    </button>
                  </Badge>
                )}
                {(priceRange[0] > 0 || priceRange[1] < 50000) && (
                  <Badge variant="secondary" className="gap-1 text-xs">
                    ₹{priceRange[0]} - ₹{priceRange[1]}
                    <button onClick={() => setPriceRange([0, 50000])}>
                      <X className="h-3 w-3" />
                    </button>
                  </Badge>
                )}
                {universityOnly && (
                  <Badge variant="secondary" className="gap-1 text-xs">
                    My Campus
                    <button onClick={() => setUniversityOnly(false)}>
                      <X className="h-3 w-3" />
                    </button>
                  </Badge>
                )}
              </motion.div>
            )}

            {/* Error State */}
            {error && (
              <div className="flex items-start gap-3 p-4 rounded-xl border border-red-200 bg-red-50 dark:border-red-800 dark:bg-red-900/20 mb-6">
                <AlertCircle className="h-4 w-4 text-red-600 dark:text-red-400 shrink-0 mt-0.5" />
                <div>
                  <p className="text-sm text-red-600 dark:text-red-400">{error}</p>
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => fetchListings()}
                    className="mt-2 h-8 text-xs"
                  >
                    <RefreshCw className="h-3 w-3 mr-1" />
                    Try Again
                  </Button>
                </div>
              </div>
            )}

            {/* Listings Grid - Note: internal loading handled by skeleton provider */}
            {listings.length === 0 && !isLoading ? (
              <div className="flex flex-col items-center justify-center py-16 text-center">
                <div className="h-14 w-14 rounded-2xl bg-muted/60 flex items-center justify-center mb-4">
                  <Package className="h-7 w-7 text-muted-foreground" />
                </div>
                <h3 className="font-medium mb-1">No listings found</h3>
                <p className="text-sm text-muted-foreground mb-4 max-w-xs">
                  {searchQuery
                    ? `No results for "${searchQuery}"`
                    : "Be the first to post something for your campus community!"}
                </p>
                {searchQuery ? (
                  <Button variant="outline" size="sm" onClick={clearFilters}>
                    Clear Search
                  </Button>
                ) : (
                  <Button asChild size="sm">
                    <Link href="/connect/create">
                      <Plus className="h-4 w-4 mr-1" />
                      Create Listing
                    </Link>
                  </Button>
                )}
              </div>
            ) : (
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ duration: 0.3 }}
                className="space-y-4 pb-8"
              >
                <p className="text-xs text-muted-foreground text-center">
                  Showing {listings.length} {listings.length === 1 ? "listing" : "listings"}
                  {searchQuery && ` matching "${searchQuery}"`}
                </p>
                <MasonryGrid listings={listings} onFavorite={handleFavorite} isLoading={false} />
              </motion.div>
            )}

            {/* Floating Create Button */}
            <motion.div
              initial={{ opacity: 0, scale: 0.8 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: 0.5, type: "spring", stiffness: 200 }}
              className="fixed bottom-24 right-6 lg:bottom-8 lg:right-8 z-30"
            >
              <Button
                asChild
                size="lg"
                className="h-14 w-14 rounded-full shadow-lg hover:scale-105 transition-transform"
              >
                <Link href="/connect/create">
                  <Plus className="h-6 w-6" />
                  <span className="sr-only">Post Listing</span>
                </Link>
              </Button>
            </motion.div>
          </div>
        </div>
      </StaggerItem>

      {/* Sheets */}
      {selectedTutor && (
        <>
          <BookSessionSheet
            open={showBookSession}
            onOpenChange={setShowBookSession}
            tutor={selectedTutor}
          />
          <TutorProfileSheet
            open={showTutorProfile}
            onOpenChange={setShowTutorProfile}
            tutor={selectedTutor}
            onBook={() => {
              setShowTutorProfile(false);
              setShowBookSession(true);
            }}
          />
        </>
      )}
      <AskQuestionSheet open={showAskQuestion} onOpenChange={setShowAskQuestion} />
      <QuestionDetailSheet
        question={selectedQuestion}
        open={showQuestionDetail}
        onOpenChange={setShowQuestionDetail}
      />
    </div>
  );

  return (
    <PageSkeletonProvider
      isLoading={isLoading}
      skeleton={<MarketplaceSkeleton />}
      minimumDuration={1000}
    >
      <PageContent />
    </PageSkeletonProvider>
  );
}
