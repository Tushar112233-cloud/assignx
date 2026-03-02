"use client";

import { useState, useCallback } from "react";
import {
  CreditCard,
  Smartphone,
  Plus,
  Trash2,
  Check,
  Shield,
  Loader2,
  MoreVertical,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { cn } from "@/lib/utils";
import { toast } from "sonner";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

/** Supported payment method types */
type PaymentMethodType = "card" | "upi";

/**
 * Represents a saved payment method (card or UPI).
 * Mirrors the data model from the mobile `payment_methods_screen.dart`.
 */
interface PaymentMethod {
  id: string;
  type: PaymentMethodType;
  isDefault: boolean;
  /** Last 4 digits of the card number (card only) */
  cardLast4?: string;
  /** Card network brand, e.g. "visa", "mastercard" (card only) */
  cardBrand?: string;
  /** Expiry in MM/YY format (card only) */
  cardExpiry?: string;
  /** Name printed on the card (card only) */
  cardholderName?: string;
  /** Full UPI ID, e.g. "user@okaxis" (UPI only) */
  upiId?: string;
}

/** Props accepted by the add-card dialog form */
interface AddCardFormData {
  cardNumber: string;
  expiry: string;
  cvv: string;
  cardholderName: string;
}

/** Props accepted by the add-UPI dialog form */
interface AddUpiFormData {
  upiId: string;
}

// ---------------------------------------------------------------------------
// Mock data -- replaced with real API calls in production
// ---------------------------------------------------------------------------

const MOCK_METHODS: PaymentMethod[] = [
  {
    id: "card-1",
    type: "card",
    isDefault: true,
    cardLast4: "4242",
    cardBrand: "visa",
    cardExpiry: "12/26",
    cardholderName: "John Doe",
  },
  {
    id: "upi-1",
    type: "upi",
    isDefault: false,
    upiId: "john@okaxis",
  },
];

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/**
 * Returns a human-readable label for a card brand.
 * @param brand - The card brand identifier (e.g. "visa", "mastercard")
 */
function formatCardBrand(brand?: string): string {
  if (!brand) return "Card";
  const brands: Record<string, string> = {
    visa: "Visa",
    mastercard: "Mastercard",
    amex: "Amex",
    rupay: "RuPay",
  };
  return brands[brand.toLowerCase()] ?? brand;
}

/**
 * Formats a raw numeric string into groups of 4 digits separated by spaces.
 * @param value - Raw card number input
 */
function formatCardNumber(value: string): string {
  const cleaned = value.replace(/\D/g, "").slice(0, 16);
  return cleaned.replace(/(.{4})/g, "$1 ").trim();
}

/**
 * Formats a raw numeric string into MM/YY expiry format.
 * @param value - Raw expiry input
 */
function formatExpiry(value: string): string {
  const cleaned = value.replace(/\D/g, "").slice(0, 4);
  if (cleaned.length >= 2) {
    return `${cleaned.slice(0, 2)}/${cleaned.slice(2)}`;
  }
  return cleaned;
}

// ---------------------------------------------------------------------------
// Sub-components
// ---------------------------------------------------------------------------

/**
 * Renders a single saved payment method row.
 */
function PaymentMethodRow({
  method,
  onSetDefault,
  onDelete,
}: {
  method: PaymentMethod;
  onSetDefault: (id: string) => void;
  onDelete: (method: PaymentMethod) => void;
}) {
  const isCard = method.type === "card";

  return (
    <div
      className={cn(
        "flex items-center gap-4 p-4 rounded-xl border transition-colors",
        method.isDefault
          ? "border-primary/40 bg-primary/5"
          : "border-border hover:border-foreground/20"
      )}
    >
      {/* Icon */}
      <div
        className={cn(
          "h-11 w-11 rounded-lg flex items-center justify-center shrink-0",
          isCard
            ? "bg-slate-100 dark:bg-slate-800"
            : "bg-emerald-100 dark:bg-emerald-900/30"
        )}
      >
        {isCard ? (
          <CreditCard className="h-5 w-5 text-slate-600 dark:text-slate-400" />
        ) : (
          <Smartphone className="h-5 w-5 text-emerald-600 dark:text-emerald-400" />
        )}
      </div>

      {/* Details */}
      <div className="flex-1 min-w-0">
        {isCard ? (
          <>
            <p className="text-sm font-medium text-foreground">
              {formatCardBrand(method.cardBrand)} ending in {method.cardLast4}
            </p>
            <p className="text-xs text-muted-foreground truncate">
              {method.cardholderName} &middot; Expires {method.cardExpiry}
            </p>
          </>
        ) : (
          <>
            <p className="text-sm font-medium text-foreground">
              {method.upiId}
            </p>
            <p className="text-xs text-muted-foreground">UPI ID</p>
          </>
        )}
      </div>

      {/* Default badge / actions */}
      <div className="flex items-center gap-2 shrink-0">
        {method.isDefault && (
          <Badge
            variant="secondary"
            className="bg-primary/10 text-primary border-0 text-[10px]"
          >
            <Check className="h-3 w-3 mr-1" />
            Default
          </Badge>
        )}

        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="ghost" size="icon" className="h-8 w-8">
              <MoreVertical className="h-4 w-4" />
              <span className="sr-only">Payment method actions</span>
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            {!method.isDefault && (
              <DropdownMenuItem onClick={() => onSetDefault(method.id)}>
                <Check className="h-4 w-4 mr-2" />
                Set as default
              </DropdownMenuItem>
            )}
            <DropdownMenuItem
              className="text-destructive focus:text-destructive"
              onClick={() => onDelete(method)}
            >
              <Trash2 className="h-4 w-4 mr-2" />
              Remove
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </div>
  );
}

/**
 * Empty state shown when no payment methods are saved.
 */
function EmptyState() {
  return (
    <div className="flex flex-col items-center justify-center py-10 text-center">
      <div className="h-16 w-16 rounded-full bg-muted flex items-center justify-center mb-4">
        <CreditCard className="h-8 w-8 text-muted-foreground" />
      </div>
      <p className="text-sm font-medium text-foreground">
        No payment methods saved
      </p>
      <p className="text-xs text-muted-foreground mt-1">
        Add a card or UPI ID for faster checkout
      </p>
    </div>
  );
}

/**
 * Security disclaimer footer.
 */
function SecurityNote() {
  return (
    <div className="flex items-start gap-3 p-3 rounded-lg bg-emerald-50 dark:bg-emerald-900/20 border border-emerald-200 dark:border-emerald-800">
      <Shield className="h-4 w-4 text-emerald-600 dark:text-emerald-400 mt-0.5 shrink-0" />
      <p className="text-xs text-muted-foreground">
        Your payment information is encrypted and securely stored via Razorpay
        (PCI DSS Compliant). We never store full card numbers.
      </p>
    </div>
  );
}

// ---------------------------------------------------------------------------
// Add Card Dialog
// ---------------------------------------------------------------------------

/**
 * Dialog for adding a new debit / credit card.
 */
function AddCardDialog({
  open,
  onOpenChange,
  onAdd,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onAdd: (method: PaymentMethod) => void;
}) {
  const [form, setForm] = useState<AddCardFormData>({
    cardNumber: "",
    expiry: "",
    cvv: "",
    cardholderName: "",
  });
  const [errors, setErrors] = useState<Partial<Record<keyof AddCardFormData, string>>>({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  /** Reset the form whenever the dialog opens/closes */
  const handleOpenChange = (nextOpen: boolean) => {
    if (!nextOpen) {
      setForm({ cardNumber: "", expiry: "", cvv: "", cardholderName: "" });
      setErrors({});
    }
    onOpenChange(nextOpen);
  };

  /** Validate the form fields and return true if valid */
  const validate = (): boolean => {
    const next: Partial<Record<keyof AddCardFormData, string>> = {};
    const rawCard = form.cardNumber.replace(/\s/g, "");
    if (rawCard.length < 16) next.cardNumber = "Enter a valid 16-digit card number";
    if (form.expiry.length < 5) next.expiry = "Enter a valid expiry (MM/YY)";
    if (form.cvv.length < 3) next.cvv = "Enter a valid CVV";
    if (!form.cardholderName.trim()) next.cardholderName = "Enter cardholder name";
    setErrors(next);
    return Object.keys(next).length === 0;
  };

  /** Submit the card details. In production this would tokenize via Razorpay. */
  const handleSubmit = async () => {
    if (!validate()) return;
    setIsSubmitting(true);
    try {
      // Production: tokenize via Razorpay SDK
      await new Promise((r) => setTimeout(r, 800));

      const rawCard = form.cardNumber.replace(/\s/g, "");
      const card: PaymentMethod = {
        id: `card-${Date.now()}`,
        type: "card",
        isDefault: false,
        cardLast4: rawCard.slice(-4),
        cardBrand: "visa",
        cardExpiry: form.expiry,
        cardholderName: form.cardholderName.trim(),
      };

      onAdd(card);
      handleOpenChange(false);
      toast.success("Card added successfully");
    } catch {
      toast.error("Failed to add card");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={handleOpenChange}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>Add Debit/Credit Card</DialogTitle>
          <DialogDescription>
            Your card details are securely stored via Razorpay
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-4 py-2">
          {/* Card Number */}
          <div className="space-y-2">
            <Label htmlFor="card-number">Card Number</Label>
            <Input
              id="card-number"
              placeholder="1234 5678 9012 3456"
              value={form.cardNumber}
              maxLength={19}
              onChange={(e) =>
                setForm((p) => ({
                  ...p,
                  cardNumber: formatCardNumber(e.target.value),
                }))
              }
            />
            {errors.cardNumber && (
              <p className="text-xs text-destructive">{errors.cardNumber}</p>
            )}
          </div>

          {/* Expiry + CVV */}
          <div className="grid grid-cols-2 gap-3">
            <div className="space-y-2">
              <Label htmlFor="card-expiry">Expiry</Label>
              <Input
                id="card-expiry"
                placeholder="MM/YY"
                value={form.expiry}
                maxLength={5}
                onChange={(e) =>
                  setForm((p) => ({
                    ...p,
                    expiry: formatExpiry(e.target.value),
                  }))
                }
              />
              {errors.expiry && (
                <p className="text-xs text-destructive">{errors.expiry}</p>
              )}
            </div>
            <div className="space-y-2">
              <Label htmlFor="card-cvv">CVV</Label>
              <Input
                id="card-cvv"
                placeholder="***"
                type="password"
                value={form.cvv}
                maxLength={4}
                onChange={(e) =>
                  setForm((p) => ({
                    ...p,
                    cvv: e.target.value.replace(/\D/g, "").slice(0, 4),
                  }))
                }
              />
              {errors.cvv && (
                <p className="text-xs text-destructive">{errors.cvv}</p>
              )}
            </div>
          </div>

          {/* Cardholder Name */}
          <div className="space-y-2">
            <Label htmlFor="cardholder-name">Cardholder Name</Label>
            <Input
              id="cardholder-name"
              placeholder="Name on card"
              value={form.cardholderName}
              onChange={(e) =>
                setForm((p) => ({ ...p, cardholderName: e.target.value }))
              }
            />
            {errors.cardholderName && (
              <p className="text-xs text-destructive">
                {errors.cardholderName}
              </p>
            )}
          </div>
        </div>

        <DialogFooter>
          <Button
            variant="outline"
            onClick={() => handleOpenChange(false)}
            disabled={isSubmitting}
          >
            Cancel
          </Button>
          <Button onClick={handleSubmit} disabled={isSubmitting}>
            {isSubmitting ? (
              <>
                <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                Adding...
              </>
            ) : (
              "Add Card"
            )}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

// ---------------------------------------------------------------------------
// Add UPI Dialog
// ---------------------------------------------------------------------------

/**
 * Dialog for adding a new UPI ID.
 */
function AddUpiDialog({
  open,
  onOpenChange,
  onAdd,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onAdd: (method: PaymentMethod) => void;
}) {
  const [form, setForm] = useState<AddUpiFormData>({ upiId: "" });
  const [error, setError] = useState<string | undefined>();
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleOpenChange = (nextOpen: boolean) => {
    if (!nextOpen) {
      setForm({ upiId: "" });
      setError(undefined);
    }
    onOpenChange(nextOpen);
  };

  const validate = (): boolean => {
    if (!form.upiId.includes("@")) {
      setError("Enter a valid UPI ID (e.g. name@okaxis)");
      return false;
    }
    setError(undefined);
    return true;
  };

  /** Submit the UPI ID. In production this would verify via payment gateway. */
  const handleSubmit = async () => {
    if (!validate()) return;
    setIsSubmitting(true);
    try {
      // Production: verify UPI ID via gateway
      await new Promise((r) => setTimeout(r, 500));

      const upi: PaymentMethod = {
        id: `upi-${Date.now()}`,
        type: "upi",
        isDefault: false,
        upiId: form.upiId.toLowerCase().trim(),
      };

      onAdd(upi);
      handleOpenChange(false);
      toast.success("UPI ID added successfully");
    } catch {
      toast.error("Failed to add UPI ID");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={handleOpenChange}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>Add UPI ID</DialogTitle>
          <DialogDescription>
            Link your UPI ID for quick payments
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-4 py-2">
          <div className="space-y-2">
            <Label htmlFor="upi-id">UPI ID</Label>
            <Input
              id="upi-id"
              placeholder="yourname@upi"
              value={form.upiId}
              onChange={(e) => setForm({ upiId: e.target.value })}
            />
            <p className="text-xs text-muted-foreground">
              Example: name@okaxis, name@ybl, name@paytm
            </p>
            {error && <p className="text-xs text-destructive">{error}</p>}
          </div>
        </div>

        <DialogFooter>
          <Button
            variant="outline"
            onClick={() => handleOpenChange(false)}
            disabled={isSubmitting}
          >
            Cancel
          </Button>
          <Button onClick={handleSubmit} disabled={isSubmitting}>
            {isSubmitting ? (
              <>
                <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                Adding...
              </>
            ) : (
              "Add UPI ID"
            )}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

// ---------------------------------------------------------------------------
// Main Component
// ---------------------------------------------------------------------------

/**
 * Payment Methods section for the profile page.
 *
 * Displays saved cards and UPI IDs with the ability to add, remove, and set
 * a default method. Mirrors the mobile `PaymentMethodsScreen` functionality
 * for feature parity.
 *
 * In production the mock data and simulated delays should be replaced with
 * real calls to a payment gateway (Razorpay) and the API backend.
 */
export function PaymentMethodsSection() {
  const [methods, setMethods] = useState<PaymentMethod[]>(MOCK_METHODS);
  const [isLoading, setIsLoading] = useState(false);
  const [addCardOpen, setAddCardOpen] = useState(false);
  const [addUpiOpen, setAddUpiOpen] = useState(false);
  const [deleteTarget, setDeleteTarget] = useState<PaymentMethod | null>(null);

  /** Set a method as the default payment method */
  const handleSetDefault = useCallback(
    (id: string) => {
      setMethods((prev) =>
        prev.map((m) => ({ ...m, isDefault: m.id === id }))
      );
      toast.success("Default payment method updated");
    },
    []
  );

  /** Remove a payment method after confirmation */
  const handleDelete = useCallback(() => {
    if (!deleteTarget) return;

    if (deleteTarget.isDefault && methods.length > 1) {
      toast.error("Set another method as default first");
      setDeleteTarget(null);
      return;
    }

    setMethods((prev) => prev.filter((m) => m.id !== deleteTarget.id));
    toast.success("Payment method removed");
    setDeleteTarget(null);
  }, [deleteTarget, methods.length]);

  /** Add a newly created payment method to the list */
  const handleAddMethod = useCallback(
    (method: PaymentMethod) => {
      setMethods((prev) => {
        // If this is the first method, make it default
        const isFirst = prev.length === 0;
        return [...prev, { ...method, isDefault: isFirst }];
      });
    },
    []
  );

  return (
    <>
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <CreditCard className="h-5 w-5" />
            Payment Methods
          </CardTitle>
          <CardDescription>
            Manage your saved cards and UPI IDs for faster checkout
          </CardDescription>
        </CardHeader>

        <CardContent className="space-y-4">
          {/* Payment methods list */}
          {isLoading ? (
            <div className="flex items-center justify-center py-10">
              <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
            </div>
          ) : methods.length === 0 ? (
            <EmptyState />
          ) : (
            <div className="space-y-3">
              {methods.map((method) => (
                <PaymentMethodRow
                  key={method.id}
                  method={method}
                  onSetDefault={handleSetDefault}
                  onDelete={setDeleteTarget}
                />
              ))}
            </div>
          )}

          {/* Add buttons */}
          <div className="flex flex-col sm:flex-row gap-3 pt-2">
            <Button
              className="flex-1"
              onClick={() => setAddCardOpen(true)}
            >
              <Plus className="h-4 w-4 mr-2" />
              Add Card
            </Button>
            <Button
              variant="outline"
              className="flex-1"
              onClick={() => setAddUpiOpen(true)}
            >
              <Smartphone className="h-4 w-4 mr-2" />
              Add UPI
            </Button>
          </div>

          {/* Security note */}
          <SecurityNote />
        </CardContent>
      </Card>

      {/* Add Card Dialog */}
      <AddCardDialog
        open={addCardOpen}
        onOpenChange={setAddCardOpen}
        onAdd={handleAddMethod}
      />

      {/* Add UPI Dialog */}
      <AddUpiDialog
        open={addUpiOpen}
        onOpenChange={setAddUpiOpen}
        onAdd={handleAddMethod}
      />

      {/* Delete Confirmation Dialog */}
      <AlertDialog
        open={!!deleteTarget}
        onOpenChange={(open) => {
          if (!open) setDeleteTarget(null);
        }}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Remove Payment Method?</AlertDialogTitle>
            <AlertDialogDescription>
              {deleteTarget?.type === "card"
                ? `Remove card ending in ${deleteTarget.cardLast4}?`
                : `Remove UPI ID ${deleteTarget?.upiId}?`}{" "}
              This action cannot be undone.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={handleDelete}
              className="bg-destructive hover:bg-destructive/90 text-destructive-foreground"
            >
              Remove
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  );
}
