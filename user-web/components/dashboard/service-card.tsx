"use client";

import { memo } from "react";
import Link from "next/link";
import { ArrowRight } from "lucide-react";
import { Card, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";
import type { Service } from "@/lib/data/services";

interface ServiceCardProps {
  service: Service;
}

/**
 * Individual service card component
 * Displays service info with icon and optional badge
 * Memoized for list rendering performance
 */
export const ServiceCard = memo(function ServiceCard({ service }: ServiceCardProps) {
  const CardWrapper = service.disabled ? "div" : Link;

  return (
    <CardWrapper
      href={service.disabled ? undefined! : service.href}
      className={cn(
        "block group/card",
        service.disabled && "cursor-not-allowed opacity-50"
      )}
    >
      <Card
        className={cn(
          "relative h-full overflow-hidden transition-all duration-300",
          !service.disabled && "card-hover hover:border-primary/40"
        )}
      >
        {/* Subtle gradient overlay on hover */}
        {!service.disabled && (
          <div className="absolute inset-0 bg-gradient-to-br from-primary/[0.02] via-transparent to-accent/[0.02] opacity-0 group-hover/card:opacity-100 transition-opacity duration-500" />
        )}

        <CardHeader className="relative space-y-4 p-5">
          {/* Icon & Badge row */}
          <div className="flex items-start justify-between">
            <div
              className={cn(
                "flex h-11 w-11 items-center justify-center rounded-xl transition-all duration-300",
                service.color,
                !service.disabled && "group-hover/card:scale-105 group-hover/card:shadow-md"
              )}
            >
              <service.icon className="h-5 w-5" />
            </div>
            {service.badge && (
              <Badge
                variant={service.disabled ? "outline" : "secondary"}
                className={cn(
                  "text-[10px] font-medium px-2 py-0.5",
                  !service.disabled && "bg-primary/10 text-primary border-0"
                )}
              >
                {service.badge}
              </Badge>
            )}
          </div>

          {/* Title & Description */}
          <div className="space-y-1.5">
            <CardTitle className="text-base font-semibold leading-tight">
              {service.title}
            </CardTitle>
            <CardDescription className="text-sm leading-relaxed line-clamp-2">
              {service.description}
            </CardDescription>
          </div>

          {/* Arrow indicator */}
          {!service.disabled && (
            <div className="flex items-center justify-end pt-1">
              <div className="flex items-center gap-1 text-xs text-muted-foreground group-hover/card:text-primary transition-colors">
                <span className="opacity-0 group-hover/card:opacity-100 transition-opacity">Get started</span>
                <ArrowRight className="h-3.5 w-3.5 transition-transform group-hover/card:translate-x-0.5" />
              </div>
            </div>
          )}
        </CardHeader>
      </Card>
    </CardWrapper>
  );
});
