"use client";

import { Shield, Info, HelpCircle } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";
import { Separator } from "@/components/ui/separator";
import { cn } from "@/lib/utils";
import { calculateCommission } from "@/lib/commission";

interface PriceBreakdownProps {
  totalAmount: number;
  currency?: string;
  showDetails?: boolean;
  className?: string;
}

/**
 * Price breakdown component showing commission split
 * Displays total, expert amount, and platform fee
 */
export function PriceBreakdown({
  totalAmount,
  currency = "INR",
  showDetails = true,
  className,
}: PriceBreakdownProps) {
  const breakdown = calculateCommission(totalAmount, currency);

  return (
    <Card className={cn("", className)}>
      <CardHeader className="pb-3">
        <CardTitle className="text-base flex items-center gap-2">
          Price Breakdown
          <TooltipProvider>
            <Tooltip>
              <TooltipTrigger asChild>
                <HelpCircle className="h-4 w-4 text-muted-foreground cursor-help" />
              </TooltipTrigger>
              <TooltipContent className="max-w-xs">
                <p>
                  The platform fee helps us maintain quality service, verify experts,
                  and provide customer support.
                </p>
              </TooltipContent>
            </Tooltip>
          </TooltipProvider>
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-3">
        {showDetails && (
          <>
            <div className="flex items-center justify-between text-sm">
              <span className="text-muted-foreground">Consultation Fee</span>
              <span>{breakdown.formattedExpertAmount}</span>
            </div>
            <div className="flex items-center justify-between text-sm">
              <div className="flex items-center gap-1">
                <span className="text-muted-foreground">Platform Fee</span>
                <TooltipProvider>
                  <Tooltip>
                    <TooltipTrigger asChild>
                      <Info className="h-3 w-3 text-muted-foreground cursor-help" />
                    </TooltipTrigger>
                    <TooltipContent>
                      <p>Includes payment processing, support, and guarantees</p>
                    </TooltipContent>
                  </Tooltip>
                </TooltipProvider>
              </div>
              <span>{breakdown.formattedPlatformFee}</span>
            </div>
            <Separator />
          </>
        )}

        <div className="flex items-center justify-between font-medium">
          <span>Total</span>
          <span className="text-lg">{breakdown.formattedTotal}</span>
        </div>

        {/* Trust badges */}
        <div className="pt-3 space-y-2">
          <div className="flex items-center gap-2 text-xs text-muted-foreground">
            <Shield className="h-4 w-4 text-green-500" />
            <span>Secure payment through Razorpay</span>
          </div>
          <div className="flex items-center gap-2 text-xs text-muted-foreground">
            <Shield className="h-4 w-4 text-green-500" />
            <span>100% money-back guarantee if expert doesn&apos;t show up</span>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
