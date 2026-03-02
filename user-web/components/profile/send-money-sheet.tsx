"use client";

import { useState, useEffect, useCallback } from "react";
import {
  Send,
  Loader2,
  CheckCircle2,
  ArrowLeft,
  User,
  IndianRupee,
  AlertCircle,
} from "lucide-react";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import { getStoredUser } from "@/lib/api/auth";
import { searchUserByEmail } from "@/lib/actions/data";

/**
 * Preset amounts for quick selection
 */
const presetAmounts = [50, 100, 200, 500, 1000, 2000];

interface Recipient {
  id: string;
  email: string;
  full_name: string;
  avatar_url: string | null;
}

interface SendMoneySheetProps {
  open?: boolean;
  onOpenChange?: (open: boolean) => void;
}

/**
 * Send Money Sheet Component
 * Bottom sheet with 3-step wizard for wallet-to-wallet transfers
 */
export function SendMoneySheet({ open, onOpenChange }: SendMoneySheetProps) {
  const [step, setStep] = useState<1 | 2 | 3>(1);
  const [recipientEmail, setRecipientEmail] = useState("");
  const [recipient, setRecipient] = useState<Recipient | null>(null);
  const [selectedAmount, setSelectedAmount] = useState<number | null>(null);
  const [customAmount, setCustomAmount] = useState("");
  const [note, setNote] = useState("");
  const [isSearching, setIsSearching] = useState(false);
  const [isSending, setIsSending] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);
  const [searchError, setSearchError] = useState<string | null>(null);
  const [newBalance, setNewBalance] = useState<number | null>(null);
  const [userId, setUserId] = useState("");

  // Get user data on mount
  useEffect(() => {
    const user = getStoredUser();
    if (user) {
      setUserId(user.id);
    }
  }, []);

  const effectiveAmount =
    selectedAmount || (customAmount ? parseInt(customAmount, 10) : 0);

  /**
   * Reset all state when sheet closes
   */
  const handleOpenChange = useCallback(
    (isOpen: boolean) => {
      if (!isOpen) {
        setStep(1);
        setRecipientEmail("");
        setRecipient(null);
        setSelectedAmount(null);
        setCustomAmount("");
        setNote("");
        setIsSearching(false);
        setIsSending(false);
        setIsSuccess(false);
        setSearchError(null);
        setNewBalance(null);
      }
      onOpenChange?.(isOpen);
    },
    [onOpenChange]
  );

  /**
   * Search for recipient by email
   */
  const handleSearchRecipient = async () => {
    if (!recipientEmail.trim() || !recipientEmail.includes("@")) {
      setSearchError("Please enter a valid email address");
      return;
    }

    setIsSearching(true);
    setSearchError(null);

    try {
      const result = await searchUserByEmail(recipientEmail.trim().toLowerCase());

      if (!result || !result.success || !result.user) {
        setSearchError("No user found with this email address");
        setRecipient(null);
        return;
      }

      setRecipient(result.user);
      setStep(2);
    } catch {
      setSearchError("Failed to search user. Please try again.");
    } finally {
      setIsSearching(false);
    }
  };

  /**
   * Handle preset amount click
   */
  const handlePresetClick = (amount: number) => {
    setSelectedAmount(amount);
    setCustomAmount("");
  };

  /**
   * Handle custom amount input
   */
  const handleCustomChange = (value: string) => {
    const numericValue = value.replace(/\D/g, "");
    setCustomAmount(numericValue);
    setSelectedAmount(null);
  };

  /**
   * Proceed to confirmation step
   */
  const handleProceedToConfirm = () => {
    if (!effectiveAmount || effectiveAmount < 1) {
      toast.error("Minimum amount is ₹1");
      return;
    }
    if (effectiveAmount > 50000) {
      toast.error("Maximum amount is ₹50,000");
      return;
    }
    setStep(3);
  };

  /**
   * Execute the transfer
   */
  const handleConfirmSend = async () => {
    if (!recipient || !effectiveAmount || !userId) return;

    setIsSending(true);

    try {
      const response = await fetch("/api/payments/send-money", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          profile_id: userId,
          recipient_email: recipient.email,
          amount: effectiveAmount,
          note: note.trim() || undefined,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || "Transfer failed");
      }

      setNewBalance(data.new_balance);
      setIsSuccess(true);
      toast.success(`₹${effectiveAmount.toLocaleString("en-IN")} sent to ${recipient.full_name}`);
    } catch (err) {
      const message = err instanceof Error ? err.message : "Transfer failed";
      toast.error(message);
    } finally {
      setIsSending(false);
    }
  };

  /**
   * Render success state
   */
  if (isSuccess) {
    return (
      <Sheet open={open} onOpenChange={handleOpenChange}>
        <SheetContent side="bottom" className="h-auto max-h-[90vh] p-6">
          <div className="flex flex-col items-center text-center py-6 space-y-4">
            <div className="w-16 h-16 rounded-full bg-emerald-100 dark:bg-emerald-900/30 flex items-center justify-center">
              <CheckCircle2 className="h-8 w-8 text-emerald-600 dark:text-emerald-400" />
            </div>
            <div>
              <h3 className="text-lg font-semibold">Transfer Successful!</h3>
              <p className="text-2xl font-bold mt-2">
                ₹{effectiveAmount.toLocaleString("en-IN")}
              </p>
              <p className="text-sm text-muted-foreground mt-1">
                sent to {recipient?.full_name}
              </p>
            </div>
            {newBalance !== null && (
              <div className="rounded-xl border bg-muted/30 p-3 w-full max-w-[260px]">
                <p className="text-xs text-muted-foreground">New Balance</p>
                <p className="text-lg font-bold">
                  ₹{newBalance.toLocaleString("en-IN")}
                </p>
              </div>
            )}
            <Button
              className="w-full max-w-[260px]"
              onClick={() => {
                handleOpenChange(false);
                window.location.reload();
              }}
            >
              Done
            </Button>
          </div>
        </SheetContent>
      </Sheet>
    );
  }

  return (
    <Sheet open={open} onOpenChange={handleOpenChange}>
      <SheetContent side="bottom" className="h-auto max-h-[90vh] p-6">
        <SheetHeader className="text-left space-y-1">
          <SheetTitle className="text-base font-medium flex items-center gap-2">
            {step > 1 && (
              <button
                onClick={() => setStep((step - 1) as 1 | 2)}
                className="w-7 h-7 rounded-lg hover:bg-muted flex items-center justify-center transition-colors"
              >
                <ArrowLeft className="h-4 w-4" />
              </button>
            )}
            {step === 1 && "Send Money"}
            {step === 2 && "Enter Amount"}
            {step === 3 && "Confirm Transfer"}
          </SheetTitle>
          <SheetDescription className="text-xs text-muted-foreground">
            {step === 1 && "Enter the recipient's email address"}
            {step === 2 && `Sending to ${recipient?.full_name}`}
            {step === 3 && "Review and confirm your transfer"}
          </SheetDescription>
        </SheetHeader>

        <div className="space-y-4 pt-4 pb-2">
          {/* Step 1: Recipient Email */}
          {step === 1 && (
            <>
              <div className="space-y-2">
                <Label htmlFor="recipient-email" className="text-xs text-muted-foreground">
                  Recipient Email
                </Label>
                <Input
                  id="recipient-email"
                  type="email"
                  placeholder="name@example.com"
                  value={recipientEmail}
                  onChange={(e) => {
                    setRecipientEmail(e.target.value);
                    setSearchError(null);
                  }}
                  onKeyDown={(e) => {
                    if (e.key === "Enter") {
                      e.preventDefault();
                      handleSearchRecipient();
                    }
                  }}
                  disabled={isSearching}
                  className="h-10"
                />
                {searchError && (
                  <div className="flex items-center gap-1.5 text-destructive">
                    <AlertCircle className="h-3.5 w-3.5 flex-shrink-0" />
                    <p className="text-xs">{searchError}</p>
                  </div>
                )}
              </div>

              <Button
                className="w-full h-9 text-sm"
                onClick={handleSearchRecipient}
                disabled={
                  isSearching || !recipientEmail.trim() || !recipientEmail.includes("@")
                }
              >
                {isSearching ? (
                  <>
                    <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                    Searching...
                  </>
                ) : (
                  "Find User"
                )}
              </Button>
            </>
          )}

          {/* Step 2: Amount */}
          {step === 2 && recipient && (
            <>
              {/* Recipient card */}
              <div className="flex items-center gap-3 rounded-xl border bg-muted/30 p-3">
                <div className="w-10 h-10 rounded-full bg-gradient-to-br from-violet-500 to-purple-600 flex items-center justify-center flex-shrink-0 overflow-hidden">
                  {recipient.avatar_url ? (
                    <img
                      src={recipient.avatar_url}
                      alt={recipient.full_name}
                      className="w-full h-full object-cover"
                    />
                  ) : (
                    <User className="h-5 w-5 text-white" />
                  )}
                </div>
                <div className="min-w-0">
                  <p className="text-sm font-semibold truncate">
                    {recipient.full_name}
                  </p>
                  <p className="text-xs text-muted-foreground truncate">
                    {recipient.email}
                  </p>
                </div>
              </div>

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

              {/* Custom amount */}
              {!selectedAmount && (
                <div className="space-y-2">
                  <Label htmlFor="send-amount" className="text-xs text-muted-foreground">
                    Custom Amount
                  </Label>
                  <div className="relative">
                    <div className="absolute left-3 top-1/2 -translate-y-1/2">
                      <IndianRupee className="h-4 w-4 text-muted-foreground" />
                    </div>
                    <Input
                      id="send-amount"
                      type="text"
                      inputMode="numeric"
                      placeholder="0"
                      value={customAmount}
                      onChange={(e) => handleCustomChange(e.target.value)}
                      className="h-9 pl-9 text-sm"
                    />
                  </div>
                  <p className="text-xs text-muted-foreground">Min: ₹1 · Max: ₹50,000</p>
                </div>
              )}

              {/* Optional note */}
              <div className="space-y-2">
                <Label htmlFor="send-note" className="text-xs text-muted-foreground">
                  Note (optional)
                </Label>
                <Input
                  id="send-note"
                  type="text"
                  placeholder="What's this for?"
                  value={note}
                  onChange={(e) => setNote(e.target.value)}
                  maxLength={100}
                  className="h-9 text-sm"
                />
              </div>

              <Button
                className="w-full h-9 text-sm"
                onClick={handleProceedToConfirm}
                disabled={!effectiveAmount || effectiveAmount < 1}
              >
                Continue
              </Button>
            </>
          )}

          {/* Step 3: Confirm */}
          {step === 3 && recipient && (
            <>
              <div className="rounded-xl border bg-muted/30 p-4 space-y-3">
                {/* Recipient */}
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-gradient-to-br from-violet-500 to-purple-600 flex items-center justify-center flex-shrink-0 overflow-hidden">
                    {recipient.avatar_url ? (
                      <img
                        src={recipient.avatar_url}
                        alt={recipient.full_name}
                        className="w-full h-full object-cover"
                      />
                    ) : (
                      <User className="h-5 w-5 text-white" />
                    )}
                  </div>
                  <div className="min-w-0">
                    <p className="text-sm font-semibold truncate">
                      {recipient.full_name}
                    </p>
                    <p className="text-xs text-muted-foreground truncate">
                      {recipient.email}
                    </p>
                  </div>
                </div>

                <div className="border-t pt-3 space-y-2">
                  <div className="flex items-center justify-between text-xs">
                    <span className="text-muted-foreground">Amount</span>
                    <span className="font-medium">
                      ₹{effectiveAmount.toLocaleString("en-IN")}
                    </span>
                  </div>
                  <div className="flex items-center justify-between text-xs">
                    <span className="text-muted-foreground">Fee</span>
                    <span className="font-medium text-green-600">Free</span>
                  </div>
                  {note.trim() && (
                    <div className="flex items-center justify-between text-xs">
                      <span className="text-muted-foreground">Note</span>
                      <span className="font-medium truncate max-w-[160px]">
                        {note.trim()}
                      </span>
                    </div>
                  )}
                  <div className="border-t pt-2 flex items-center justify-between">
                    <span className="text-xs font-medium">Total</span>
                    <span className="text-sm font-semibold">
                      ₹{effectiveAmount.toLocaleString("en-IN")}
                    </span>
                  </div>
                </div>
              </div>

              <Button
                className="w-full h-9 text-sm"
                onClick={handleConfirmSend}
                disabled={isSending}
              >
                {isSending ? (
                  <>
                    <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                    Sending...
                  </>
                ) : (
                  <>
                    <Send className="h-4 w-4 mr-2" />
                    Confirm & Send
                  </>
                )}
              </Button>
            </>
          )}
        </div>
      </SheetContent>
    </Sheet>
  );
}
