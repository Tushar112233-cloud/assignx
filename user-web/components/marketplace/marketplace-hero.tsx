"use client";

import { motion } from "framer-motion";
import { ShoppingBag, Users, Tag } from "lucide-react";
import { Badge } from "@/components/ui/badge";

interface MarketplaceHeroProps {
  listingsCount: number;
  sellersCount: number;
  categoriesCount: number;
}

/**
 * MarketplaceHero - Gradient hero card with stats
 * Displays marketplace title and key statistics
 */
export function MarketplaceHero({
  listingsCount,
  sellersCount,
  categoriesCount,
}: MarketplaceHeroProps) {
  return (
    <motion.div
      initial={{ opacity: 0, y: -10 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.4 }}
      className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-primary/10 via-primary/5 to-background border border-border/50 p-6 md:p-8"
    >
      {/* Background decoration */}
      <div className="absolute -right-8 -top-8 h-32 w-32 rounded-full bg-primary/5 blur-3xl" />
      <div className="absolute -left-4 -bottom-4 h-24 w-24 rounded-full bg-primary/10 blur-2xl" />

      <div className="relative z-10">
        <div className="flex items-center gap-3 mb-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary/10">
            <ShoppingBag className="h-5 w-5 text-primary" />
          </div>
          <div>
            <h1 className="text-2xl md:text-3xl font-bold tracking-tight text-foreground">
              Campus Marketplace
            </h1>
            <p className="text-sm text-muted-foreground mt-0.5">
              Buy, sell, and trade with your campus community
            </p>
          </div>
        </div>

        {/* Stats badges */}
        <div className="flex flex-wrap gap-2 mt-4">
          <Badge variant="secondary" className="gap-1.5 px-3 py-1">
            <ShoppingBag className="h-3 w-3" />
            {listingsCount} Listings
          </Badge>
          <Badge variant="secondary" className="gap-1.5 px-3 py-1">
            <Users className="h-3 w-3" />
            {sellersCount} Active Sellers
          </Badge>
          <Badge variant="secondary" className="gap-1.5 px-3 py-1">
            <Tag className="h-3 w-3" />
            {categoriesCount} Categories
          </Badge>
        </div>
      </div>
    </motion.div>
  );
}
