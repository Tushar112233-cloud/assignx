"use client";

import { Info } from "lucide-react";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";
import { cn } from "@/lib/utils";
import type { ProjectType } from "@/types/add-project";
import type { ProjectStep2Schema } from "@/lib/validations/project";

interface PriceEstimateProps {
  projectType: ProjectType;
  requirements: Partial<ProjectStep2Schema>;
  urgencyMultiplier?: number;
  className?: string;
}

/** Computes base price and description label based on project type and requirements */
function computeBasePrice(
  projectType: ProjectType,
  requirements: Partial<ProjectStep2Schema>
): { basePrice: number; label: string } {
  switch (projectType) {
    case "assignment":
    case "document": {
      const wordCount = requirements.wordCount || 0;
      const rate = 0.8;
      return {
        basePrice: wordCount * rate,
        label: `${wordCount.toLocaleString()} words × ₹${rate}`,
      };
    }
    case "website": {
      const pageCount = requirements.pageCount || 0;
      const rate = 2000;
      return {
        basePrice: pageCount * rate,
        label: `${pageCount} page${pageCount !== 1 ? "s" : ""} × ₹${rate.toLocaleString()}`,
      };
    }
    case "app": {
      const platform = requirements.platform || "";
      const isBoth = platform === "both";
      const basePrice = isBoth ? 40000 : 25000;
      const platformLabel = isBoth ? "iOS & Android" : platform || "Single platform";
      return {
        basePrice,
        label: `${platformLabel} — base`,
      };
    }
    case "consultancy": {
      const duration = requirements.consultationDuration || "";
      const priceMap: Record<string, number> = {
        "30min": 500,
        "1hr": 800,
        "2hr": 1500,
      };
      const durationLabelMap: Record<string, string> = {
        "30min": "30 minutes",
        "1hr": "1 hour",
        "2hr": "2 hours",
      };
      const basePrice = priceMap[duration] || 0;
      const durationLabel = durationLabelMap[duration] || duration;
      return {
        basePrice,
        label: durationLabel,
      };
    }
    default:
      return { basePrice: 0, label: "" };
  }
}

/**
 * Price estimate card supporting all project types
 */
export function PriceEstimate({
  projectType,
  requirements,
  urgencyMultiplier = 1,
  className,
}: PriceEstimateProps) {
  const { basePrice, label } = computeBasePrice(projectType, requirements);
  const urgencyFee = basePrice * (urgencyMultiplier - 1);
  const subtotal = basePrice + urgencyFee;
  const gst = subtotal * 0.18;
  const total = subtotal + gst;

  if (basePrice <= 0) {
    return null;
  }

  return (
    <div className={cn("rounded-lg border bg-muted/30 p-4", className)}>
      <div className="space-y-3">
        {/* Header */}
        <div className="flex items-center justify-between">
          <h4 className="text-sm font-semibold">Price Estimate</h4>
          <TooltipProvider>
            <Tooltip>
              <TooltipTrigger>
                <Info className="h-3.5 w-3.5 text-muted-foreground" />
              </TooltipTrigger>
              <TooltipContent side="top" className="max-w-xs">
                <p className="text-xs">
                  Final price may vary based on complexity and requirements.
                  You&apos;ll receive an exact quote before payment.
                </p>
              </TooltipContent>
            </Tooltip>
          </TooltipProvider>
        </div>

        {/* Breakdown */}
        <div className="space-y-2 text-sm">
          <div className="flex justify-between">
            <span className="text-muted-foreground">
              Base ({label})
            </span>
            <span className="font-medium tabular-nums">₹{Math.round(basePrice).toLocaleString()}</span>
          </div>

          {urgencyMultiplier > 1 && (
            <div className="flex justify-between">
              <span className="text-muted-foreground">
                Urgency Fee ({Math.round((urgencyMultiplier - 1) * 100)}%)
              </span>
              <span className="font-medium tabular-nums">
                +₹{Math.round(urgencyFee).toLocaleString()}
              </span>
            </div>
          )}

          <div className="flex justify-between">
            <span className="text-muted-foreground">GST (18%)</span>
            <span className="font-medium tabular-nums">₹{Math.round(gst).toLocaleString()}</span>
          </div>
        </div>

        {/* Total */}
        <div className="border-t pt-3">
          <div className="flex items-center justify-between">
            <span className="font-semibold">Estimated Total</span>
            <span className="text-xl font-bold tabular-nums">
              ₹{Math.round(total).toLocaleString()}
            </span>
          </div>
        </div>

        {/* Disclaimer */}
        <p className="text-[11px] text-muted-foreground pt-1">
          * This is an estimate only. Final quote will be provided by our team after review.
        </p>
      </div>
    </div>
  );
}
