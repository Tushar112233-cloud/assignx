"use client";

import { useState, useEffect } from "react";
import { Gift, Copy, Share2, Users, IndianRupee, Check } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Skeleton } from "@/components/ui/skeleton";
import { toast } from "sonner";

/**
 * Referral data interface
 */
interface ReferralData {
  code: string;
  totalReferrals: number;
  totalEarnings: number;
  pendingEarnings: number;
}

/**
 * Referral Section Component
 * Shows referral code with copy/share functionality
 * Implements U94 from feature spec
 */
export function ReferralSection() {
  const [referral, setReferral] = useState<ReferralData | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isCopied, setIsCopied] = useState(false);

  useEffect(() => {
    const fetchReferralData = async () => {
      try {
        // In production: fetch from referral_codes table
        // For now, use mock data
        await new Promise((resolve) => setTimeout(resolve, 300));
        setReferral({
          code: "EXPERT20",
          totalReferrals: 3,
          totalEarnings: 150,
          pendingEarnings: 50,
        });
      } finally {
        setIsLoading(false);
      }
    };
    fetchReferralData();
  }, []);

  const handleCopy = async () => {
    if (!referral) return;

    try {
      await navigator.clipboard.writeText(referral.code);
      setIsCopied(true);
      toast.success("Referral code copied!");
      setTimeout(() => setIsCopied(false), 2000);
    } catch {
      toast.error("Failed to copy code");
    }
  };

  const handleShare = async () => {
    if (!referral) return;

    const shareText = `Use my referral code ${referral.code} to get 20% off your first project on AssignX!`;

    if (navigator.share) {
      try {
        await navigator.share({
          title: "Join AssignX",
          text: shareText,
          url: `https://assignx.com/ref/${referral.code}`,
        });
      } catch {
        // User cancelled or error
      }
    } else {
      // Fallback to copying the share text
      await navigator.clipboard.writeText(shareText);
      toast.success("Share text copied to clipboard!");
    }
  };

  if (isLoading) {
    return (
      <Card>
        <CardHeader className="pb-3">
          <Skeleton className="h-5 w-32" />
        </CardHeader>
        <CardContent className="space-y-4">
          <Skeleton className="h-12 w-full" />
          <div className="flex gap-2">
            <Skeleton className="h-10 w-1/2" />
            <Skeleton className="h-10 w-1/2" />
          </div>
        </CardContent>
      </Card>
    );
  }

  if (!referral) return null;

  return (
    <Card className="overflow-hidden">
      <CardHeader className="pb-3 bg-gradient-to-r from-amber-50 to-orange-50 dark:from-amber-950/20 dark:to-orange-950/20">
        <CardTitle className="flex items-center gap-2 text-base">
          <Gift className="h-5 w-5 text-amber-600" />
          Refer & Earn
        </CardTitle>
      </CardHeader>
      <CardContent className="pt-4 space-y-4">
        {/* Referral Code */}
        <div>
          <p className="text-xs text-muted-foreground mb-2">Your Referral Code</p>
          <div className="flex gap-2">
            <Input
              value={referral.code}
              readOnly
              className="font-mono text-lg font-bold tracking-wider text-center bg-muted"
            />
            <Button
              variant="outline"
              size="icon"
              onClick={handleCopy}
              className="shrink-0"
            >
              {isCopied ? (
                <Check className="h-4 w-4 text-green-600" />
              ) : (
                <Copy className="h-4 w-4" />
              )}
            </Button>
          </div>
        </div>

        {/* Share buttons */}
        <div className="flex gap-2">
          <Button
            variant="outline"
            className="flex-1"
            onClick={handleCopy}
          >
            <Copy className="h-4 w-4 mr-2" />
            Copy Code
          </Button>
          <Button
            variant="default"
            className="flex-1"
            onClick={handleShare}
          >
            <Share2 className="h-4 w-4 mr-2" />
            Share
          </Button>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-2 gap-4 pt-2">
          <div className="flex items-center gap-2 p-3 rounded-lg bg-muted/50">
            <Users className="h-5 w-5 text-muted-foreground" />
            <div>
              <p className="text-lg font-bold">{referral.totalReferrals}</p>
              <p className="text-[10px] text-muted-foreground">Referrals</p>
            </div>
          </div>
          <div className="flex items-center gap-2 p-3 rounded-lg bg-muted/50">
            <IndianRupee className="h-5 w-5 text-green-600" />
            <div>
              <p className="text-lg font-bold">₹{referral.totalEarnings}</p>
              <p className="text-[10px] text-muted-foreground">Earned</p>
            </div>
          </div>
        </div>

        {/* Pending earnings note */}
        {referral.pendingEarnings > 0 && (
          <p className="text-xs text-muted-foreground text-center">
            ₹{referral.pendingEarnings} pending (credited after referral&apos;s first project)
          </p>
        )}
      </CardContent>
    </Card>
  );
}
