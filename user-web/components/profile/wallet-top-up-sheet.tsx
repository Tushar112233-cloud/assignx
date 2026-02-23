"use client";

import { useState, useEffect } from "react";
import { IndianRupee, CreditCard, Loader2, Shield, CheckCircle2 } from "lucide-react";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import { RazorpayCheckout } from "@/components/payments/razorpay-checkout";
import { createClient } from "@/lib/supabase/client";

/**
 * Preset amounts for quick selection
 */
const presetAmounts = [100, 500, 1000, 2000, 5000, 10000];

interface WalletTopUpSheetProps {
  children?: React.ReactNode;
  open?: boolean;
  onOpenChange?: (open: boolean) => void;
}

/**
 * Wallet Top-Up Sheet Component
 * Slide-up modal for adding money to wallet
 * Implements U99 from feature spec
 */
export function WalletTopUpSheet({
  children,
  open,
  onOpenChange,
}: WalletTopUpSheetProps) {
  const [selectedAmount, setSelectedAmount] = useState<number | null>(null);
  const [customAmount, setCustomAmount] = useState("");
  const [isProcessing, setIsProcessing] = useState(false);
  const [showRazorpay, setShowRazorpay] = useState(false);
  const [userId, setUserId] = useState<string>("");
  const [userEmail, setUserEmail] = useState<string | undefined>();
  const [userName, setUserName] = useState<string | undefined>();

  // Get user data on mount
  useEffect(() => {
    const supabase = createClient();
    supabase.auth.getUser().then(({ data }: any) => {
      if (data.user) {
        setUserId(data.user.id);
        setUserEmail(data.user.email);
        setUserName(data.user.user_metadata?.full_name);
      }
    });
  }, []);

  const effectiveAmount = selectedAmount || (customAmount ? parseInt(customAmount, 10) : 0);

  const handlePresetClick = (amount: number) => {
    setSelectedAmount(amount);
    setCustomAmount("");
  };

  const handleCustomChange = (value: string) => {
    // Only allow numbers
    const numericValue = value.replace(/\D/g, "");
    setCustomAmount(numericValue);
    setSelectedAmount(null);
  };

  const handleProceed = async () => {
    if (!effectiveAmount || effectiveAmount < 10) {
      toast.error("Minimum amount is ₹10");
      return;
    }

    if (effectiveAmount > 50000) {
      toast.error("Maximum amount is ₹50,000");
      return;
    }

    if (!userId) {
      toast.error("Please login to continue");
      return;
    }

    console.log("🔵 [WalletTopUp] Opening Razorpay for amount:", effectiveAmount);

    // Close the sheet and open Razorpay modal
    onOpenChange?.(false);
    setShowRazorpay(true);
  };

  const content = (
    <div className="space-y-4 pt-4 pb-2">
      {/* Preset amounts */}
      <div className="space-y-2">
        <Label className="text-xs text-muted-foreground">Quick Select</Label>
        <div className="grid grid-cols-3 gap-1.5">
          {presetAmounts.map((amount) => (
            <button
              key={amount}
              type="button"
              onClick={() => handlePresetClick(amount)}
              className={cn(
                "relative h-9 rounded-md border text-xs transition-all",
                "hover:border-primary/50",
                "focus-visible:outline-hidden focus-visible:ring-1 focus-visible:ring-primary",
                selectedAmount === amount
                  ? "border-primary bg-primary/5 text-primary"
                  : "border-border"
              )}
            >
              ₹{amount >= 1000 ? `${amount / 1000}k` : amount}
              {selectedAmount === amount && (
                <div className="absolute top-0.5 right-0.5">
                  <CheckCircle2 className="h-3 w-3 text-primary" />
                </div>
              )}
            </button>
          ))}
        </div>
      </div>

      {/* Custom amount - Only show when no preset selected */}
      {!selectedAmount && (
        <div className="space-y-2">
          <Label htmlFor="custom-amount" className="text-xs text-muted-foreground">
            Custom Amount
          </Label>
          <div className="relative">
            <div className="absolute left-3 top-1/2 -translate-y-1/2">
              <IndianRupee className="h-4 w-4 text-muted-foreground" />
            </div>
            <Input
              id="custom-amount"
              type="text"
              inputMode="numeric"
              placeholder="0"
              value={customAmount}
              onChange={(e) => handleCustomChange(e.target.value)}
              className="h-9 pl-9 text-sm"
            />
          </div>
          <p className="text-xs text-muted-foreground">Min: ₹10 • Max: ₹50,000</p>
        </div>
      )}

      {/* Summary */}
      {effectiveAmount > 0 && (
        <div className="rounded-md border bg-muted/30 p-3 space-y-1.5">
          <div className="flex items-center justify-between text-xs">
            <span className="text-muted-foreground">Amount</span>
            <span className="font-medium">₹{effectiveAmount.toLocaleString("en-IN")}</span>
          </div>
          <div className="flex items-center justify-between text-xs">
            <span className="text-muted-foreground">Platform Fee</span>
            <span className="font-medium text-green-600">Free</span>
          </div>
          <div className="border-t pt-1.5 flex items-center justify-between">
            <span className="text-xs font-medium">Total</span>
            <span className="text-sm font-semibold">₹{effectiveAmount.toLocaleString("en-IN")}</span>
          </div>
        </div>
      )}

      {/* Proceed button */}
      <Button
        className="w-full h-9 text-sm"
        onClick={handleProceed}
        disabled={!effectiveAmount || effectiveAmount < 10 || isProcessing}
      >
        {isProcessing ? (
          <>
            <Loader2 className="h-4 w-4 mr-2 animate-spin" />
            Processing...
          </>
        ) : (
          <>
            <CreditCard className="h-4 w-4 mr-2" />
            Proceed to Pay
          </>
        )}
      </Button>

      {/* Trust indicators */}
      <div className="flex items-center justify-center gap-3 text-xs text-muted-foreground">
        <div className="flex items-center gap-1">
          <Shield className="h-3 w-3" />
          <span>Secure</span>
        </div>
        <span>•</span>
        <div className="flex items-center gap-1">
          <CheckCircle2 className="h-3 w-3" />
          <span>Instant</span>
        </div>
      </div>
    </div>
  );

  // If children provided, use as trigger
  if (children) {
    return (
      <>
        <Sheet open={open} onOpenChange={onOpenChange}>
          <SheetTrigger asChild>{children}</SheetTrigger>
          <SheetContent side="bottom" className="h-auto max-h-[90vh] p-6">
            <SheetHeader className="text-left space-y-1">
              <SheetTitle className="text-base font-medium">Add Money</SheetTitle>
              <SheetDescription className="text-xs text-muted-foreground">
                Top up your wallet for faster payments
              </SheetDescription>
            </SheetHeader>
            {content}
          </SheetContent>
        </Sheet>

        {/* Razorpay Checkout Modal - Also needed in trigger mode */}
        <RazorpayCheckout
          open={showRazorpay}
          onOpenChange={setShowRazorpay}
          amount={effectiveAmount}
          type="wallet_topup"
          userId={userId}
          userEmail={userEmail}
          userName={userName}
          onSuccess={() => {
            toast.success("Payment successful! Your wallet has been updated.");
            setSelectedAmount(null);
            setCustomAmount("");
            window.location.reload();
          }}
          onError={(error) => {
            toast.error(error || "Payment failed. Please try again.");
          }}
        />
      </>
    );
  }

  // Controlled mode
  return (
    <>
      <Sheet open={open} onOpenChange={onOpenChange}>
        <SheetContent side="bottom" className="h-auto max-h-[90vh] p-6">
          <SheetHeader className="text-left space-y-1">
            <SheetTitle className="text-base font-medium">Add Money</SheetTitle>
            <SheetDescription className="text-xs text-muted-foreground">
              Top up your wallet for faster payments
            </SheetDescription>
          </SheetHeader>
          {content}
        </SheetContent>
      </Sheet>

      {/* Razorpay Checkout Modal */}
      <RazorpayCheckout
        open={showRazorpay}
        onOpenChange={setShowRazorpay}
        amount={effectiveAmount}
        type="wallet_topup"
        userId={userId}
        userEmail={userEmail}
        userName={userName}
        onSuccess={() => {
          toast.success("Payment successful! Your wallet has been updated.");
          setSelectedAmount(null);
          setCustomAmount("");
          window.location.reload(); // Refresh to show updated balance
        }}
        onError={(error) => {
          toast.error(error || "Payment failed. Please try again.");
        }}
      />
    </>
  );
}
