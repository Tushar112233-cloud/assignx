"use client";

import { Info } from "lucide-react";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";
import { cn } from "@/lib/utils";

interface PriceEstimateProps {
  wordCount: number;
  urgencyMultiplier?: number;
  baseRatePerWord?: number;
  className?: string;
}

/**
 * Price estimate card - Clean Professional Design
 */
export function PriceEstimate({
  wordCount,
  urgencyMultiplier = 1,
  baseRatePerWord = 0.8, // ₹0.80 per word base rate
  className,
}: PriceEstimateProps) {
  const basePrice = wordCount * baseRatePerWord;
  const urgencyFee = basePrice * (urgencyMultiplier - 1);
  const subtotal = basePrice + urgencyFee;
  const gst = subtotal * 0.18;
  const total = subtotal + gst;

  if (wordCount <= 0) {
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
              Base ({wordCount.toLocaleString()} words × ₹{baseRatePerWord})
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
            <span className="font-semibold">Total</span>
            <span className="text-xl font-bold tabular-nums">
              ₹{Math.round(total).toLocaleString()}
            </span>
          </div>
        </div>

        {/* Disclaimer */}
        <p className="text-[11px] text-muted-foreground pt-1">
          * This is an estimate. Final quote will be provided after review.
        </p>
      </div>
    </div>
  );
}
