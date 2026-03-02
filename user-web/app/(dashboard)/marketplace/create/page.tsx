"use client";

import { useEffect, useState } from "react";
import { ArrowLeft, Loader2 } from "lucide-react";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import { CreateListingForm } from "@/components/marketplace/create-listing-form";
import { useUserStore } from "@/stores/user-store";
import { marketplaceService } from "@/services/marketplace.service";
import type { MarketplaceCategory } from "@/services/marketplace.service";

/**
 * Create Marketplace Listing page
 * Uses the existing CreateListingForm component
 */
export default function CreateListingPage() {
  const { user } = useUserStore();
  const [categories, setCategories] = useState<MarketplaceCategory[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchCategories = async () => {
      try {
        const cats = await marketplaceService.getCategories();
        setCategories(cats);
      } catch (error) {
        console.error("Failed to fetch categories:", error);
      } finally {
        setIsLoading(false);
      }
    };
    fetchCategories();
  }, []);

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <div className="sticky top-0 z-10 flex items-center gap-4 border-b bg-background/95 backdrop-blur p-4">
        <Button variant="ghost" size="icon" asChild>
          <Link href="/marketplace">
            <ArrowLeft className="h-5 w-5" />
          </Link>
        </Button>
        <h1 className="font-semibold text-lg">Create Listing</h1>
      </div>

      {/* Form */}
      <div className="max-w-2xl mx-auto p-6">
        <CreateListingForm
          categories={categories}
          userId={user?.id || ""}
          universityId={user?.students?.university_id}
        />
      </div>
    </div>
  );
}
