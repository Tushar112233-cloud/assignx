"use client";

/**
 * @fileoverview Premium Campus Pulse Section
 *
 * Redesigned with glassmorphism cards and premium styling
 * matching the SAAS dashboard design system.
 */

import { useEffect, useState } from "react";
import Link from "next/link";
import { motion, useReducedMotion } from "framer-motion";
import {
  ChevronRight,
  ArrowRight,
  TrendingUp,
  Loader2,
  Package,
  Home,
  Briefcase,
  Users,
  Flame,
} from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { useUserStore } from "@/stores/user-store";
import { getMarketplaceListings } from "@/lib/actions/marketplace";
import type { AnyListing } from "@/types/marketplace";

/**
 * Campus Pulse item interface
 */
interface PulseItem {
  id: string;
  title: string;
  price?: number;
  category: "product" | "housing" | "opportunity" | "community";
  imageUrl?: string;
  isHot?: boolean;
}

/**
 * Category configuration with premium colors
 */
const categoryConfig = {
  product: {
    color: "bg-primary/10 text-primary dark:bg-primary/20",
    label: "For Sale",
    icon: Package,
    gradient: "from-primary/5 to-primary/15",
  },
  housing: {
    color: "bg-emerald-600/10 text-emerald-700 dark:bg-emerald-600/20 dark:text-emerald-400",
    label: "Housing",
    icon: Home,
    gradient: "from-emerald-50 to-emerald-100 dark:from-emerald-950/50 dark:to-emerald-900/50",
  },
  opportunity: {
    color: "bg-accent/15 text-amber-800 dark:bg-accent/20 dark:text-accent",
    label: "Opportunity",
    icon: Briefcase,
    gradient: "from-accent/10 to-accent/20",
  },
  community: {
    color: "bg-amber-700/10 text-amber-800 dark:bg-amber-700/20 dark:text-amber-400",
    label: "Community",
    icon: Users,
    gradient: "from-amber-50 to-amber-100 dark:from-amber-950/50 dark:to-amber-900/50",
  },
};

// Animation variants
const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.06,
    },
  },
};

const itemVariants = {
  hidden: { opacity: 0, x: 20 },
  visible: {
    opacity: 1,
    x: 0,
    transition: {
      duration: 0.4,
      ease: [0.16, 1, 0.3, 1] as const,
    },
  },
};

/**
 * Campus Pulse Section
 */
export function CampusPulse() {
  const { user } = useUserStore();
  const [items, setItems] = useState<PulseItem[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const prefersReducedMotion = useReducedMotion();

  const universityName = user?.students?.university?.name || "Your Campus";

  useEffect(() => {
    const fetchPulseItems = async () => {
      try {
        const { listings, error } = await getMarketplaceListings({
          limit: 6,
          sortBy: "recent",
        });

        if (error || !listings) {
          setItems([]);
          return;
        }

        const pulseItems: PulseItem[] = listings.map((listing: AnyListing) => ({
          id: listing.id,
          title: listing.title,
          price: "price" in listing ? listing.price : "monthlyRent" in listing ? listing.monthlyRent : undefined,
          category: listing.type as PulseItem["category"],
          imageUrl: listing.imageUrl || undefined,
          isHot: listing.likes > 5,
        }));

        setItems(pulseItems);
      } finally {
        setIsLoading(false);
      }
    };

    fetchPulseItems();
  }, []);

  if (isLoading) {
    return (
      <div className="dashboard-activity-card">
        <div className="dashboard-activity-header">
          <div className="dashboard-activity-title">
            <TrendingUp className="h-5 w-5 text-primary" />
            Campus Pulse
          </div>
        </div>
        <div className="flex items-center justify-center py-12">
          <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
        </div>
      </div>
    );
  }

  if (items.length === 0) {
    return null;
  }

  return (
    <div className="dashboard-activity-card">
      <div className="dashboard-activity-header">
        <div className="dashboard-activity-title">
          <TrendingUp className="h-5 w-5 text-primary" />
          <div>
            <span>Campus Pulse</span>
            <p className="text-xs font-normal text-muted-foreground mt-0.5">
              Trending at {universityName}
            </p>
          </div>
        </div>
        <Button variant="ghost" size="sm" asChild className="text-xs h-8">
          <Link href="/connect" className="flex items-center gap-1 text-muted-foreground hover:text-primary transition-colors">
            See all
            <ChevronRight className="h-3.5 w-3.5" />
          </Link>
        </Button>
      </div>

      {/* Horizontal scroll container */}
      <div className="relative -mx-2">
        <motion.div
          variants={prefersReducedMotion ? {} : containerVariants}
          initial="hidden"
          animate="visible"
          className="flex gap-3 overflow-x-auto pb-2 px-2 scrollbar-hide"
        >
          {items.map((item) => (
            <motion.div
              key={item.id}
              variants={prefersReducedMotion ? {} : itemVariants}
            >
              <PulseCard item={item} />
            </motion.div>
          ))}
        </motion.div>
      </div>

      <Link href="/connect" className="dashboard-view-all">
        Explore marketplace
        <ArrowRight className="h-4 w-4" />
      </Link>
    </div>
  );
}

/**
 * Individual pulse item card with premium styling
 */
function PulseCard({ item }: { item: PulseItem }) {
  const config = categoryConfig[item.category];
  const Icon = config.icon;

  return (
    <Link href={`/connect?item=${item.id}`}>
      <div className="group relative min-w-[150px] max-w-[150px] cursor-pointer overflow-hidden rounded-xl border border-border/60 bg-card transition-all duration-300 hover:shadow-lg hover:-translate-y-1 hover:border-primary/30">
        {/* Image / gradient background */}
        <div
          className={cn(
            "flex h-20 items-center justify-center bg-gradient-to-br",
            config.gradient
          )}
        >
          {item.imageUrl ? (
            <img
              src={item.imageUrl}
              alt={item.title}
              className="h-full w-full object-cover"
            />
          ) : (
            <div className="opacity-50">
              <Icon className="h-8 w-8 text-primary" />
            </div>
          )}
        </div>

        {/* Hot badge */}
        {item.isHot && (
          <Badge className="absolute right-2 top-2 bg-gradient-to-r from-red-500 to-orange-500 text-[10px] text-white border-0 gap-1">
            <Flame className="h-3 w-3" />
            Hot
          </Badge>
        )}

        {/* Content */}
        <div className="p-3 space-y-2">
          <p className="line-clamp-2 text-xs font-medium leading-tight group-hover:text-primary transition-colors">
            {item.title}
          </p>

          <div className="flex items-center justify-between">
            {item.price !== undefined && (
              <span className="text-sm font-semibold text-primary tabular-nums">
                ₹{item.price.toLocaleString()}
              </span>
            )}
          </div>

          <Badge
            variant="secondary"
            className={cn("text-[9px] px-1.5 py-0 rounded-md font-medium", config.color)}
          >
            {config.label}
          </Badge>
        </div>
      </div>
    </Link>
  );
}
