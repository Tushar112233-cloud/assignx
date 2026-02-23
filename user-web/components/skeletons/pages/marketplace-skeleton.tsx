"use client";

import { cn } from "@/lib/utils";
import { SkeletonBox, SkeletonCircle, SkeletonText } from "../primitives";

interface MarketplaceSkeletonProps {
  className?: string;
}

/**
 * Full page skeleton for Campus Connect (/connect)
 * Matches the exact layout of connect-pro.tsx:
 * - Curved hero banner
 * - Centered illustration
 * - Title "Campus Connect"
 * - Search bar (max-w-3xl)
 * - 4 category tabs
 * - Masonry grid listings
 */
export function MarketplaceSkeleton({ className }: MarketplaceSkeletonProps) {
  return (
    <div className={cn("min-h-[calc(100vh-3.5rem)] bg-background", className)}>
      {/* Curved Hero Banner - matches connect-curved-hero */}
      <div className="relative">
        <div className="connect-curved-hero">
          <div className="relative h-52 md:h-64" />
        </div>
      </div>

      {/* Illustration - Centered at curve boundary */}
      <div className="relative z-10 -mt-16 md:-mt-20 flex justify-center px-6">
        <div className="relative">
          {/* Main illustration box - w-28 h-28 md:w-36 md:h-36 */}
          <div className="relative w-28 h-28 md:w-36 md:h-36 bg-card rounded-3xl shadow-xl shadow-black/10 flex items-center justify-center skeleton-shimmer">
            {/* Icon placeholder */}
            <SkeletonBox width={56} height={56} rounded="lg" className="md:w-18 md:h-18" delay={50} />
          </div>
          {/* Decorative floating dots */}
          <div className="absolute -top-2 -right-2">
            <SkeletonCircle size={16} className="bg-blue-200/50" delay={100} />
          </div>
          <div className="absolute -bottom-1 -left-2">
            <SkeletonCircle size={12} className="bg-orange-200/50" delay={150} />
          </div>
          <div className="absolute top-2 -left-3">
            <SkeletonCircle size={10} className="bg-pink-200/50" delay={200} />
          </div>
        </div>
      </div>

      {/* Title - "Campus Connect" */}
      <div className="text-center pt-6 pb-4 px-6">
        <SkeletonText
          width={220}
          lineHeight={48}
          className="mx-auto md:w-[280px] lg:w-[320px]"
          delay={100}
        />
      </div>

      {/* Search Bar - max-w-3xl centered */}
      <div className="px-6 md:px-8 pb-4">
        <div className="max-w-3xl mx-auto">
          <div className="flex items-center gap-3 px-5 py-4 rounded-2xl bg-card border border-border/30 shadow-lg shadow-black/5">
            <SkeletonCircle size={20} delay={150} />
            <SkeletonBox height={20} className="flex-1" rounded="md" delay={200} />
            <SkeletonCircle size={36} delay={250} />
          </div>
        </div>
      </div>

      {/* Category Tabs - 4 pills centered */}
      <div className="px-6 md:px-8 py-4">
        <div className="flex justify-center gap-2 flex-wrap">
          {["Community", "Opportunities", "Products", "Housing"].map((_, i) => (
            <SkeletonBox
              key={i}
              width={100 + (i % 2) * 20}
              height={40}
              rounded="full"
              delay={300 + i * 50}
            />
          ))}
        </div>
      </div>

      {/* Main Content - Masonry Grid */}
      <div className="px-4 md:px-6 lg:px-10 xl:px-12 pt-2">
        <div className="w-full">
          {/* Results count text */}
          <div className="flex justify-center mb-4">
            <SkeletonText width={150} lineHeight={14} delay={450} />
          </div>

          {/* Masonry Grid - 5 columns optimized */}
          <div className="columns-2 md:columns-3 lg:columns-4 xl:columns-5 gap-4">
            {[220, 280, 200, 320, 250, 180, 300, 240, 260, 190].map((height, i) => (
              <div
                key={i}
                className="break-inside-avoid mb-4"
              >
                <div
                  className="rounded-2xl bg-card border border-border/50 overflow-hidden skeleton-shimmer"
                  style={{ height }}
                >
                  {/* Image area - 60% of card */}
                  <div className="h-[60%] bg-muted" />

                  {/* Content area */}
                  <div className="p-3 space-y-2">
                    <SkeletonText width="85%" lineHeight={16} delay={500 + i * 30} />
                    <SkeletonText width="60%" lineHeight={12} delay={550 + i * 30} />
                    <div className="flex items-center justify-between pt-2">
                      <SkeletonText width={60} lineHeight={14} delay={600 + i * 30} />
                      <SkeletonCircle size={24} delay={650 + i * 30} />
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Floating Action Button placeholder */}
      <div className="fixed bottom-24 right-6 lg:bottom-8 lg:right-8 z-30">
        <SkeletonCircle size={56} className="shadow-lg" delay={700} />
      </div>
    </div>
  );
}
