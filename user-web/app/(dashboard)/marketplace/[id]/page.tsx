import { notFound } from "next/navigation";
import { getMarketplaceListingById } from "@/lib/actions/marketplace";
import { getUser } from "@/lib/actions/auth";
import { MarketplaceDetailClient } from "./marketplace-detail-client";

interface MarketplaceDetailPageProps {
  params: Promise<{ id: string }>;
}

/**
 * Marketplace listing detail page
 */
export default async function MarketplaceDetailPage({
  params,
}: MarketplaceDetailPageProps) {
  const { id } = await params;

  // Get current user (optional - can view without auth)
  const user = await getUser();

  // Fetch listing from database
  const { data: listing, error } = await getMarketplaceListingById(id);

  // 404 if listing not found
  if (!listing || error) {
    notFound();
  }

  return <MarketplaceDetailClient listing={listing} userId={user?.id} />;
}
