"use client";

import { useCallback, useEffect, useState } from "react";
import Link from "next/link";
import useEmblaCarousel from "embla-carousel-react";
import Autoplay from "embla-carousel-autoplay";
import { ChevronLeft, ChevronRight, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { getBanners } from "@/lib/actions/data";

/**
 * Banner interface matching Supabase schema
 */
interface Banner {
  id: string;
  title: string;
  subtitle: string | null;
  description: string | null;
  image_url: string | null;
  cta_text: string | null;
  cta_url: string | null;
  background_color: string | null;
  text_color: string | null;
  is_active: boolean;
  display_location: string;
  display_order: number;
  start_date: string | null;
  end_date: string | null;
  created_at: string;
}

/**
 * Banner carousel with autoplay
 * Fetches banners from Supabase and displays with 4s auto-scroll
 */
export function BannerCarousel() {
  const [banners, setBanners] = useState<Banner[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  const [emblaRef, emblaApi] = useEmblaCarousel({ loop: true }, [
    Autoplay({ delay: 4000, stopOnInteraction: false }),
  ]);
  const [selectedIndex, setSelectedIndex] = useState(0);
  const [canScrollPrev, setCanScrollPrev] = useState(false);
  const [canScrollNext, setCanScrollNext] = useState(false);

  // Fetch banners on mount
  useEffect(() => {
    const fetchBannersData = async () => {
      try {
        const data = await getBanners("dashboard");
        setBanners(data);
      } catch {
        // Silently handle fetch error - banners will remain empty
      } finally {
        setIsLoading(false);
      }
    };
    fetchBannersData();
  }, []);

  const scrollPrev = useCallback(() => {
    if (emblaApi) emblaApi.scrollPrev();
  }, [emblaApi]);

  const scrollNext = useCallback(() => {
    if (emblaApi) emblaApi.scrollNext();
  }, [emblaApi]);

  const scrollTo = useCallback(
    (index: number) => {
      if (emblaApi) emblaApi.scrollTo(index);
    },
    [emblaApi]
  );

  const onSelect = useCallback(() => {
    if (!emblaApi) return;
    setSelectedIndex(emblaApi.selectedScrollSnap());
    setCanScrollPrev(emblaApi.canScrollPrev());
    setCanScrollNext(emblaApi.canScrollNext());
  }, [emblaApi]);

  useEffect(() => {
    if (!emblaApi) return;
    onSelect();
    emblaApi.on("select", onSelect);
    emblaApi.on("reInit", onSelect);
  }, [emblaApi, onSelect]);

  // Loading state
  if (isLoading) {
    return (
      <div className="flex min-h-[180px] items-center justify-center rounded-xl bg-muted sm:min-h-[200px]">
        <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
      </div>
    );
  }

  // No banners state - enhanced welcome banner
  if (banners.length === 0) {
    return (
      <div className="relative overflow-hidden rounded-xl bg-gradient-to-br from-primary via-primary/90 to-primary/70 p-6 text-white sm:p-8">
        {/* Decorative elements */}
        <div className="absolute -right-10 -top-10 h-40 w-40 rounded-full bg-white/10 blur-2xl" />
        <div className="absolute -bottom-10 -left-10 h-40 w-40 rounded-full bg-white/10 blur-2xl" />
        <div className="absolute right-20 top-10 h-20 w-20 rounded-full bg-white/5" />

        {/* Content */}
        <div className="relative z-10">
          <div className="mb-1 text-sm font-medium text-white/80">Welcome back</div>
          <h3 className="text-2xl font-bold sm:text-3xl">Ready to excel?</h3>
          <p className="mt-2 max-w-md text-sm text-white/80 sm:text-base">
            Submit your projects, track progress, and connect with expert professionals.
          </p>
          <div className="mt-4 flex flex-wrap gap-4 text-sm">
            <div className="flex items-center gap-2">
              <div className="h-2 w-2 rounded-full bg-green-400" />
              <span className="text-white/90">500+ Experts</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="h-2 w-2 rounded-full bg-blue-400" />
              <span className="text-white/90">On-time Delivery</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="h-2 w-2 rounded-full bg-yellow-400" />
              <span className="text-white/90">24/7 Support</span>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="relative">
      {/* Carousel */}
      <div className="overflow-hidden rounded-xl" ref={emblaRef}>
        <div className="flex">
          {banners.map((banner) => (
            <div key={banner.id} className="min-w-0 flex-[0_0_100%]">
              <div
                className="relative flex min-h-[180px] flex-col justify-center rounded-xl p-6 sm:min-h-[200px] sm:p-8"
                style={{
                  backgroundColor: banner.background_color || "#6366f1",
                  color: banner.text_color || "#ffffff",
                }}
              >
                {/* Content */}
                <div className="max-w-md">
                  {banner.subtitle && (
                    <p className="mb-1 text-sm font-medium opacity-90">
                      {banner.subtitle}
                    </p>
                  )}
                  <h3 className="mb-2 text-2xl font-bold sm:text-3xl">
                    {banner.title}
                  </h3>
                  {banner.description && (
                    <p className="mb-4 text-sm opacity-80">{banner.description}</p>
                  )}
                  {banner.cta_text && banner.cta_url && (
                    <Button
                      asChild
                      variant="secondary"
                      size="sm"
                      className="bg-white/20 text-white hover:bg-white/30"
                    >
                      <Link href={banner.cta_url}>{banner.cta_text}</Link>
                    </Button>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Navigation buttons - only show if more than 1 banner */}
      {banners.length > 1 && (
        <>
          <Button
            variant="outline"
            size="icon"
            className="absolute left-2 top-1/2 h-8 w-8 -translate-y-1/2 rounded-full bg-background/80 backdrop-blur"
            onClick={scrollPrev}
            disabled={!canScrollPrev}
          >
            <ChevronLeft className="h-4 w-4" />
          </Button>
          <Button
            variant="outline"
            size="icon"
            className="absolute right-2 top-1/2 h-8 w-8 -translate-y-1/2 rounded-full bg-background/80 backdrop-blur"
            onClick={scrollNext}
            disabled={!canScrollNext}
          >
            <ChevronRight className="h-4 w-4" />
          </Button>

          {/* Dot indicators */}
          <div className="mt-4 flex justify-center gap-2">
            {banners.map((_, index) => (
              <button
                key={index}
                onClick={() => scrollTo(index)}
                className={cn(
                  "h-2 rounded-full transition-all",
                  index === selectedIndex
                    ? "w-6 bg-primary"
                    : "w-2 bg-muted-foreground/30 hover:bg-muted-foreground/50"
                )}
              />
            ))}
          </div>
        </>
      )}
    </div>
  );
}
