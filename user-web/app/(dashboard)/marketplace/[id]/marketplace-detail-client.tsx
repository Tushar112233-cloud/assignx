"use client";

import { useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { useRouter } from "next/navigation";
import {
  ArrowLeft,
  Heart,
  Share2,
  MapPin,
  Calendar,
  Eye,
  MessageCircle,
  Package,
  Home,
  Briefcase,
  Users,
  Clock,
  BadgeCheck,
  Flag,
  Send,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Skeleton } from "@/components/ui/skeleton";
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet";
import { Textarea } from "@/components/ui/textarea";
import { cn } from "@/lib/utils";
import { toggleMarketplaceFavorite } from "@/lib/actions/marketplace";
import { toast } from "sonner";
import { formatDistanceToNow } from "date-fns";
import type {
  AnyListing,
  ProductListing,
  HousingListing,
  OpportunityListing,
} from "@/types/marketplace";

interface MarketplaceDetailClientProps {
  listing: AnyListing;
  userId?: string;
}

/**
 * Get listing type config for display
 */
function getListingConfig(type: string) {
  switch (type) {
    case "product":
      return {
        icon: Package,
        label: "Product",
        color: "text-blue-600 dark:text-blue-400",
        bg: "bg-blue-50 dark:bg-blue-950",
      };
    case "housing":
      return {
        icon: Home,
        label: "Housing",
        color: "text-emerald-600 dark:text-emerald-400",
        bg: "bg-emerald-50 dark:bg-emerald-950",
      };
    case "opportunity":
      return {
        icon: Briefcase,
        label: "Opportunity",
        color: "text-purple-600 dark:text-purple-400",
        bg: "bg-purple-50 dark:bg-purple-950",
      };
    default:
      return {
        icon: Users,
        label: "Community",
        color: "text-amber-600 dark:text-amber-400",
        bg: "bg-amber-50 dark:bg-amber-950",
      };
  }
}

/**
 * Format price for display
 */
function formatPrice(listing: AnyListing): string | null {
  if (listing.type === "product") {
    const product = listing as ProductListing;
    return product.price === 0 ? "Free" : `₹${product.price.toLocaleString()}`;
  }
  if (listing.type === "housing") {
    const housing = listing as HousingListing;
    return `₹${housing.monthlyRent.toLocaleString()}/month`;
  }
  if (listing.type === "opportunity") {
    const opportunity = listing as OpportunityListing;
    return opportunity.stipend
      ? `₹${opportunity.stipend.toLocaleString()}/month`
      : null;
  }
  return null;
}

/**
 * Marketplace listing detail client component
 */
export function MarketplaceDetailClient({
  listing,
  userId,
}: MarketplaceDetailClientProps) {
  const router = useRouter();
  const [isFavorited, setIsFavorited] = useState(listing.isLiked || false);
  const [isToggling, setIsToggling] = useState(false);
  const [contactSheetOpen, setContactSheetOpen] = useState(false);
  const [message, setMessage] = useState("");

  const config = getListingConfig(listing.type);
  const Icon = config.icon;
  const price = formatPrice(listing);
  const timeAgo = formatDistanceToNow(new Date(listing.createdAt), {
    addSuffix: true,
  });

  const handleFavorite = async () => {
    if (!userId) {
      toast.error("Please sign in to save favorites");
      return;
    }

    setIsToggling(true);
    const prevState = isFavorited;
    setIsFavorited(!isFavorited);

    const {
      success,
      isFavorited: newState,
      error,
    } = await toggleMarketplaceFavorite(listing.id);

    if (!success || error) {
      setIsFavorited(prevState);
      toast.error(error || "Failed to update favorite");
    } else {
      toast.success(newState ? "Added to favorites" : "Removed from favorites");
    }

    setIsToggling(false);
  };

  const handleShare = async () => {
    try {
      await navigator.share({
        title: listing.title,
        text: listing.description || "",
        url: window.location.href,
      });
    } catch {
      await navigator.clipboard.writeText(window.location.href);
      toast.success("Link copied to clipboard");
    }
  };

  const handleSendMessage = () => {
    if (!message.trim()) return;
    toast.success("Message sent to seller");
    setMessage("");
    setContactSheetOpen(false);
  };

  return (
    <div className="flex-1 p-6 md:p-8 max-w-5xl mx-auto">
      {/* Back Button */}
      <div className="flex items-center justify-between mb-6">
        <Button
          variant="ghost"
          size="sm"
          onClick={() => router.back()}
          className="-ml-2"
        >
          <ArrowLeft className="h-4 w-4 mr-2" />
          Back
        </Button>
        <div className="flex items-center gap-2">
          <Button
            variant="outline"
            size="icon"
            onClick={handleFavorite}
            disabled={isToggling}
            className="h-9 w-9"
          >
            <Heart
              className={cn(
                "h-4 w-4 transition-colors",
                isFavorited
                  ? "fill-red-500 text-red-500"
                  : "text-muted-foreground"
              )}
            />
          </Button>
          <Button
            variant="outline"
            size="icon"
            onClick={handleShare}
            className="h-9 w-9"
          >
            <Share2 className="h-4 w-4 text-muted-foreground" />
          </Button>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Main Content */}
        <div className="lg:col-span-2 space-y-6">
          {/* Image */}
          <div className="relative aspect-[4/3] rounded-xl overflow-hidden bg-muted border border-border">
            {listing.imageUrl ? (
              <Image
                src={listing.imageUrl}
                alt={listing.title}
                fill
                className="object-cover"
                priority
              />
            ) : (
              <div className="flex h-full w-full items-center justify-center">
                <Icon
                  className="h-16 w-16 text-muted-foreground/50"
                  strokeWidth={1.5}
                />
              </div>
            )}

            {/* Type badge */}
            <div
              className={cn(
                "absolute bottom-3 right-3 px-3 py-1.5 rounded-lg text-sm font-medium",
                "bg-background/90 border border-border",
                config.color
              )}
            >
              {config.label}
            </div>
          </div>

          {/* Title & Price */}
          <div className="space-y-2">
            <h1 className="text-2xl font-semibold">{listing.title}</h1>
            {price && (
              <p
                className={cn(
                  "text-xl font-bold",
                  listing.type === "product" &&
                    (listing as ProductListing).price === 0
                    ? "text-emerald-600 dark:text-emerald-400"
                    : "text-foreground"
                )}
              >
                {price}
              </p>
            )}
          </div>

          {/* Meta info */}
          <div className="flex flex-wrap items-center gap-3 text-sm text-muted-foreground">
            <span className="flex items-center gap-1">
              <Eye className="h-4 w-4" />
              {listing.views} views
            </span>
            <span className="flex items-center gap-1">
              <Heart className="h-4 w-4" />
              {listing.likes} likes
            </span>
            <span className="flex items-center gap-1">
              <Clock className="h-4 w-4" />
              {timeAgo}
            </span>
          </div>

          {/* Type-specific details */}
          {listing.type === "product" && (
            <div className="flex flex-wrap gap-2">
              <Badge variant="secondary">
                {(listing as ProductListing).condition.replace("_", " ")}
              </Badge>
              <Badge variant="outline">
                {(listing as ProductListing).category}
              </Badge>
              {(listing as ProductListing).isNegotiable && (
                <Badge variant="outline" className="text-emerald-600">
                  Negotiable
                </Badge>
              )}
            </div>
          )}

          {listing.type === "housing" && (
            <div className="flex flex-wrap gap-2">
              <Badge variant="secondary">
                {(listing as HousingListing).roomType}
              </Badge>
              {(listing as HousingListing).location && (
                <Badge variant="outline" className="flex items-center gap-1">
                  <MapPin className="h-3 w-3" />
                  {(listing as HousingListing).location}
                </Badge>
              )}
              {(listing as HousingListing).availableFrom && (
                <Badge variant="outline" className="flex items-center gap-1">
                  <Calendar className="h-3 w-3" />
                  Available {(listing as HousingListing).availableFrom}
                </Badge>
              )}
            </div>
          )}

          {listing.type === "opportunity" && (
            <div className="flex flex-wrap gap-2">
              <Badge variant="secondary">
                {(listing as OpportunityListing).opportunityType}
              </Badge>
              {(listing as OpportunityListing).company && (
                <Badge variant="outline">
                  {(listing as OpportunityListing).company}
                </Badge>
              )}
              {(listing as OpportunityListing).location && (
                <Badge variant="outline" className="flex items-center gap-1">
                  <MapPin className="h-3 w-3" />
                  {(listing as OpportunityListing).location}
                </Badge>
              )}
              {(listing as OpportunityListing).deadline && (
                <Badge variant="outline" className="flex items-center gap-1">
                  <Calendar className="h-3 w-3" />
                  Deadline: {(listing as OpportunityListing).deadline}
                </Badge>
              )}
            </div>
          )}

          {/* Description */}
          {listing.description && (
            <div className="space-y-2">
              <h2 className="font-medium">Description</h2>
              <p className="text-sm text-muted-foreground leading-relaxed whitespace-pre-wrap">
                {listing.description}
              </p>
            </div>
          )}
        </div>

        {/* Sidebar */}
        <div className="space-y-4">
          {/* Seller card */}
          <div className="p-4 rounded-xl border border-border bg-card">
            <div className="flex items-center gap-3 mb-4">
              <Avatar className="h-12 w-12">
                <AvatarImage src={listing.userAvatar} alt={listing.userName} />
                <AvatarFallback>
                  {listing.userName
                    .split(" ")
                    .map((n) => n[0])
                    .join("")
                    .slice(0, 2)}
                </AvatarFallback>
              </Avatar>
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-1.5">
                  <p className="font-medium truncate">{listing.userName}</p>
                  <BadgeCheck className="h-4 w-4 text-primary shrink-0" />
                </div>
                <p className="text-xs text-muted-foreground">
                  {listing.universityName || "Campus Member"}
                </p>
              </div>
            </div>

            <Sheet open={contactSheetOpen} onOpenChange={setContactSheetOpen}>
              <SheetTrigger asChild>
                <Button className="w-full">
                  <MessageCircle className="h-4 w-4 mr-2" />
                  Contact Seller
                </Button>
              </SheetTrigger>
              <SheetContent side="bottom" className="h-auto max-h-[80vh] rounded-t-xl">
                <SheetHeader>
                  <SheetTitle>Contact {listing.userName}</SheetTitle>
                </SheetHeader>
                <div className="mt-6 space-y-4">
                  <div className="flex items-center gap-3 p-3 rounded-lg bg-muted">
                    <Avatar className="h-10 w-10">
                      <AvatarImage src={listing.userAvatar} />
                      <AvatarFallback>
                        {listing.userName
                          .split(" ")
                          .map((n) => n[0])
                          .join("")
                          .slice(0, 2)}
                      </AvatarFallback>
                    </Avatar>
                    <div>
                      <p className="font-medium text-sm">{listing.userName}</p>
                      <p className="text-xs text-muted-foreground">
                        About: {listing.title}
                      </p>
                    </div>
                  </div>
                  <Textarea
                    placeholder={`Hi, I'm interested in "${listing.title}"...`}
                    value={message}
                    onChange={(e) => setMessage(e.target.value)}
                    className="min-h-[120px] resize-none"
                  />
                  <Button
                    className="w-full"
                    onClick={handleSendMessage}
                    disabled={!message.trim()}
                  >
                    <Send className="h-4 w-4 mr-2" />
                    Send Message
                  </Button>
                </div>
              </SheetContent>
            </Sheet>
          </div>

          {/* Safety tips */}
          <div className="p-4 rounded-xl border border-border bg-muted/50">
            <h3 className="font-medium text-sm mb-2">Safety Tips</h3>
            <ul className="text-xs text-muted-foreground space-y-1.5">
              <li>• Meet in public places on campus</li>
              <li>• Don&apos;t share personal financial info</li>
              <li>• Inspect items before paying</li>
              <li>• Trust your instincts</li>
            </ul>
          </div>

          {/* Report button */}
          <Button
            variant="ghost"
            className="w-full text-muted-foreground"
            size="sm"
          >
            <Flag className="h-4 w-4 mr-2" />
            Report this listing
          </Button>
        </div>
      </div>
    </div>
  );
}
