"use client";

import { cn } from "@/lib/utils";
import { SkeletonTransactionItem } from "../composites";
import { SkeletonBox, SkeletonText, SkeletonButton } from "../primitives";

interface WalletSkeletonProps {
  className?: string;
}

/**
 * Full page skeleton for Wallet (/wallet)
 * Matches the 2-column layout with credit card, quick actions, offers, and payment history
 */
export function WalletSkeleton({ className }: WalletSkeletonProps) {
  return (
    <div className={cn("relative min-h-full pb-32", className)}>
      <div className="container max-w-7xl mx-auto px-6 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">

          {/* LEFT COLUMN - Credit Card & Quick Actions */}
          <div className="lg:col-span-4 space-y-6">

            {/* Credit Card Container */}
            <div className="space-y-4">
              {/* Credit Card Skeleton */}
              <div className="w-full max-w-[340px] aspect-[1.7/1] bg-gradient-to-br from-zinc-800 to-zinc-900 rounded-xl shadow-xl p-5 relative overflow-hidden">
                {/* Card shimmer overlay */}
                <div className="skeleton-shimmer absolute inset-0" />

                {/* Mastercard logo placeholder */}
                <div className="absolute top-4 right-4 flex items-center gap-0">
                  <SkeletonBox width={24} height={24} rounded="full" animate="pulse" delay={50} />
                  <div className="-ml-2.5">
                    <SkeletonBox width={24} height={24} rounded="full" animate="pulse" delay={100} />
                  </div>
                </div>

                {/* Card content skeleton */}
                <div className="relative z-10 h-full flex flex-col justify-between">
                  {/* Balance */}
                  <div>
                    <SkeletonText width={50} lineHeight={12} animate="pulse" delay={150} className="mb-1" />
                    <SkeletonText width={120} lineHeight={24} animate="pulse" delay={200} />
                  </div>

                  {/* Card Number */}
                  <div className="flex items-center gap-2.5">
                    <SkeletonText width={30} lineHeight={14} animate="pulse" delay={250} />
                    <SkeletonText width={30} lineHeight={14} animate="pulse" delay={280} />
                    <SkeletonText width={30} lineHeight={14} animate="pulse" delay={310} />
                    <SkeletonText width={40} lineHeight={16} animate="pulse" delay={340} />
                  </div>

                  {/* Card Footer */}
                  <div className="flex items-center justify-between">
                    <div>
                      <SkeletonText width={60} lineHeight={10} animate="pulse" delay={370} className="mb-1" />
                      <SkeletonText width={80} lineHeight={12} animate="pulse" delay={400} />
                    </div>
                    <div>
                      <SkeletonText width={40} lineHeight={10} animate="pulse" delay={430} className="mb-1" />
                      <SkeletonText width={35} lineHeight={12} animate="pulse" delay={460} />
                    </div>
                  </div>
                </div>
              </div>

              {/* Quick Action Buttons */}
              <div className="grid grid-cols-2 gap-4 max-w-[340px]">
                <SkeletonBox width="100%" height={100} rounded="xl" animate="pulse" delay={500} className="glass-card border border-border/30" />
                <SkeletonBox width="100%" height={100} rounded="xl" animate="pulse" delay={550} className="glass-card border border-border/30" />
              </div>
            </div>

            {/* Stats Cards Grid */}
            <div className="grid grid-cols-2 gap-3">
              {/* Rewards */}
              <div className="glass-card border border-border/30 p-4 rounded-xl">
                <SkeletonBox width={28} height={28} rounded="lg" animate="pulse" delay={620} className="mb-2" />
                <SkeletonText width={50} lineHeight={10} animate="pulse" delay={640} className="mb-1" />
                <SkeletonText width={40} lineHeight={18} animate="pulse" delay={660} />
              </div>

              {/* Wallet Balance */}
              <div className="glass-card border border-border/30 p-4 rounded-xl">
                <SkeletonBox width={28} height={28} rounded="lg" animate="pulse" delay={670} className="mb-2" />
                <SkeletonText width={70} lineHeight={10} animate="pulse" delay={690} className="mb-1" />
                <SkeletonText width={50} lineHeight={18} animate="pulse" delay={710} />
              </div>

              {/* Monthly Spend - Full Width */}
              <div className="glass-card border border-border/30 p-4 col-span-2 rounded-xl">
                <div className="flex items-center justify-between">
                  <div>
                    <SkeletonBox width={28} height={28} rounded="lg" animate="pulse" delay={720} className="mb-1" />
                    <SkeletonText width={80} lineHeight={10} animate="pulse" delay={740} />
                  </div>
                  <SkeletonText width={70} lineHeight={20} animate="pulse" delay={760} />
                </div>
              </div>
            </div>
          </div>

          {/* RIGHT COLUMN - Offers & Payment History */}
          <div className="lg:col-span-8 space-y-5">

            {/* Offers Section */}
            <div>
              <div className="flex items-center justify-between mb-5">
                <SkeletonText width={100} lineHeight={16} animate="pulse" delay={800} />
              </div>

              <div className="flex gap-4 overflow-x-auto scrollbar-hide pb-2">
                {[1, 2, 3, 4].map((i) => (
                  <div
                    key={i}
                    className="min-w-[180px] p-5 rounded-2xl bg-muted/50 animate-pulse"
                  >
                    <div className="flex flex-col items-center gap-3">
                      <SkeletonBox width={48} height={48} rounded="xl" animate="pulse" delay={870 + i * 50} />
                      <div className="text-center space-y-1">
                        <SkeletonText width={100} lineHeight={14} animate="pulse" delay={890 + i * 50} />
                        <SkeletonText width={60} lineHeight={12} animate="pulse" delay={910 + i * 50} />
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Payment History Section */}
            <div>
              <div className="flex items-center justify-between mb-5">
                <SkeletonText width={130} lineHeight={16} animate="pulse" delay={1050} />
                <SkeletonBox width={36} height={36} rounded="xl" animate="pulse" delay={1100} />
              </div>

              {/* Transaction List */}
              <div className="glass-card rounded-2xl p-2 border border-border/20">
                <div className="space-y-0.5">
                  {[1, 2, 3, 4, 5, 6, 7].map((i) => (
                    <SkeletonTransactionItem key={i} delay={1150 + i * 60} />
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
