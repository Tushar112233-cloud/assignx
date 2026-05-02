"use client"

import { useCallback, useMemo, useState } from "react"
import { Loader2, CreditCard, Wallet, ArrowRight } from "lucide-react"
import { toast } from "sonner"
import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Checkbox } from "@/components/ui/checkbox"
import { Label } from "@/components/ui/label"
import { walletService } from "@/services"
import { cn } from "@/lib/utils"

/**
 * Razorpay checkout options
 */
interface RazorpayOptions {
  key: string
  amount: number
  currency: string
  name: string
  description: string
  order_id: string
  prefill?: {
    name?: string
    email?: string
    contact?: string
  }
  theme?: {
    color?: string
  }
  handler: (response: RazorpayResponse) => void
  modal?: {
    ondismiss?: () => void
  }
}

/**
 * Razorpay response
 */
interface RazorpayResponse {
  razorpay_order_id: string
  razorpay_payment_id: string
  razorpay_signature: string
}

/**
 * Declare Razorpay on window
 */
declare global {
  interface Window {
    Razorpay: new (options: RazorpayOptions) => {
      open: () => void
      close: () => void
    }
  }
}

/**
 * Props for RazorpayCheckout component
 */
interface RazorpayCheckoutProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  amount: number // Amount in rupees
  type: "wallet_topup" | "project_payment"
  projectId?: string
  userId: string
  userEmail?: string
  userName?: string
  userPhone?: string
  walletBalance?: number
  onSuccess?: () => void
  onError?: (error: string) => void
}

/**
 * RazorpayCheckout component - Redesigned minimal UI with partial payment support
 * Now allows using wallet balance even if insufficient, with remainder charged via Razorpay
 */
export function RazorpayCheckout({
  open,
  onOpenChange,
  amount,
  type,
  projectId,
  userId,
  userEmail,
  userName,
  userPhone,
  walletBalance = 0,
  onSuccess,
  onError,
}: RazorpayCheckoutProps) {
  // State for checkbox
  const [useWallet, setUseWallet] = useState(walletBalance > 0)

  // Calculate payment amounts based on checkbox state
  const paymentCalculation = useMemo(() => {
    const hasWalletBalance = walletBalance > 0
    const canPayFull = walletBalance >= amount

    // Only use wallet if checkbox is enabled
    const walletAmount = useWallet ? (canPayFull ? amount : walletBalance) : 0
    const razorpayAmount = amount - walletAmount

    return {
      hasWalletBalance,
      canPayFull,
      walletAmount,
      razorpayAmount,
      isPartialPayment: useWallet && hasWalletBalance && !canPayFull,
      isFullWalletPayment: useWallet && canPayFull,
    }
  }, [amount, walletBalance, useWallet])

  /**
   * Load Razorpay script
   */
  const loadRazorpayScript = useCallback((): Promise<boolean> => {
    return new Promise((resolve) => {
      if (window.Razorpay) {
        resolve(true)
        return
      }

      const script = document.createElement("script")
      script.src = "https://checkout.razorpay.com/v1/checkout.js"
      script.onload = () => resolve(true)
      script.onerror = () => resolve(false)
      document.body.appendChild(script)
    })
  }, [])

  /**
   * Handle full wallet payment (wallet balance >= amount)
   */
  const handleFullWalletPayment = useCallback(async () => {
    if (!projectId) return

    try {
      await walletService.payFromWallet(userId, projectId, amount)
      toast.success("Payment successful!")
      onOpenChange(false)
      onSuccess?.()
    } catch (error: any) {
      console.error("Wallet payment error:", error)
      toast.error(error.message || "Failed to process payment")
      onError?.(error.message || "Failed to process payment")
    }
  }, [amount, onError, onOpenChange, onSuccess, projectId, userId])

  /**
   * Handle partial payment (wallet + Razorpay)
   */
  const handlePartialPayment = useCallback(async () => {
    if (!projectId) return

    try {
      console.log("🟣 [Partial Payment] Starting flow...", {
        total: amount,
        wallet: paymentCalculation.walletAmount,
        razorpay: paymentCalculation.razorpayAmount,
      })

      // Load Razorpay script
      const loaded = await loadRazorpayScript()
      if (!loaded) {
        toast.error("Failed to load payment gateway")
        onError?.("Failed to load payment gateway")
        return
      }

      const razorpayKey = process.env.NEXT_PUBLIC_RAZORPAY_KEY_ID
      if (!razorpayKey) {
        toast.error("Payment gateway not configured. Please contact support.")
        onError?.("Payment gateway not configured")
        return
      }

      // Create order for the Razorpay portion
      console.log("🟣 [Partial Payment] Creating Razorpay order for remaining amount...")
      const order = await walletService.createPartialPaymentOrder(
        projectId,
        paymentCalculation.razorpayAmount
      )
      console.log("✅ [Partial Payment] Order created:", order)

      // Open Razorpay checkout for remaining amount
      const options: RazorpayOptions = {
        key: razorpayKey,
        amount: order.amount,
        currency: order.currency,
        name: "AssignX",
        description: "Project Payment",
        order_id: order.id,
        prefill: {
          name: userName,
          email: userEmail,
          contact: userPhone,
        },
        theme: {
          color: "#2563EB",
        },
        handler: async (response: RazorpayResponse) => {
          try {
            console.log("✅ [Partial Payment] Razorpay success, processing both payments...")

            // Process partial payment (wallet + razorpay) atomically
            await walletService.processPartialPayment(
              userId,
              projectId,
              response,
              amount,
              paymentCalculation.walletAmount,
              paymentCalculation.razorpayAmount
            )

            toast.success("Payment successful!")
            onOpenChange(false)
            onSuccess?.()
          } catch (error: any) {
            console.error("❌ [Partial Payment] Processing error:", error)
            toast.error(error?.message || "Payment processing failed")
            onError?.(error?.message || "Payment processing failed")
          }
        },
        modal: {
          ondismiss: () => {
            console.log("⚠️ [Partial Payment] User cancelled")
            toast.info("Payment cancelled")
          },
        },
      }

      const razorpay = new window.Razorpay(options)
      razorpay.open()
    } catch (error: any) {
      console.error("❌ [Partial Payment] Error:", error)
      toast.error(error.message || "Failed to initiate payment")
      onError?.(error.message || "Failed to initiate payment")
    }
  }, [
    amount,
    loadRazorpayScript,
    onError,
    onOpenChange,
    onSuccess,
    paymentCalculation,
    projectId,
    userEmail,
    userName,
    userPhone,
    userId,
  ])

  /**
   * Handle full Razorpay payment (no wallet balance)
   */
  const handleRazorpayPayment = useCallback(async () => {
    try {
      console.log("🔵 [Razorpay] Starting payment flow...")

      const loaded = await loadRazorpayScript()
      if (!loaded) {
        toast.error("Failed to load payment gateway")
        onError?.("Failed to load payment gateway")
        return
      }

      const razorpayKey = process.env.NEXT_PUBLIC_RAZORPAY_KEY_ID
      if (!razorpayKey) {
        toast.error("Payment gateway not configured. Please contact support.")
        onError?.("Payment gateway not configured")
        return
      }

      const order = type === "wallet_topup"
        ? await walletService.createTopUpOrder(userId, amount)
        : await walletService.createProjectPaymentOrder(projectId!, amount)

      const options: RazorpayOptions = {
        key: razorpayKey,
        amount: order.amount,
        currency: order.currency,
        name: "AssignX",
        description: type === "wallet_topup" ? "Wallet Top-up" : "Project Payment",
        order_id: order.id,
        prefill: {
          name: userName,
          email: userEmail,
          contact: userPhone,
        },
        theme: {
          color: "#2563EB",
        },
        handler: async (response: RazorpayResponse) => {
          try {
            await walletService.verifyAndCreditWallet(
              userId,
              response,
              amount,
              type === "project_payment" ? projectId : undefined
            )
            toast.success(
              type === "wallet_topup"
                ? "Wallet topped up successfully!"
                : "Payment successful!"
            )
            onOpenChange(false)
            onSuccess?.()
          } catch (error: any) {
            toast.error(error?.message || "Payment verification failed")
            onError?.(error?.message || "Payment verification failed")
          }
        },
        modal: {
          ondismiss: () => {
            toast.info("Payment cancelled")
          },
        },
      }

      const razorpay = new window.Razorpay(options)
      razorpay.open()
    } catch (error: any) {
      console.error("❌ [Razorpay] Error:", error)
      toast.error(error.message || "Failed to initiate payment")
      onError?.(error.message || "Failed to initiate payment")
    }
  }, [
    amount,
    loadRazorpayScript,
    onError,
    onOpenChange,
    onSuccess,
    projectId,
    type,
    userEmail,
    userName,
    userPhone,
    userId,
  ])

  // Determine which handler to use
  const handlePayment = useCallback(async () => {
    if (paymentCalculation.isFullWalletPayment) {
      await handleFullWalletPayment()
    } else if (paymentCalculation.isPartialPayment) {
      await handlePartialPayment()
    } else {
      await handleRazorpayPayment()
    }
  }, [paymentCalculation, handleFullWalletPayment, handlePartialPayment, handleRazorpayPayment])

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle className="text-base font-medium">
            {type === "wallet_topup" ? "Top Up Wallet" : "Complete Payment"}
          </DialogTitle>
          <DialogDescription className="text-xs text-muted-foreground">
            {type === "wallet_topup"
              ? "Add funds to your wallet"
              : "Choose your payment method"}
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-4 py-3">
          {/* Amount Display */}
          <div className="p-4 rounded-lg border border-border bg-muted/30">
            <p className="text-xs text-muted-foreground mb-1">Total amount</p>
            <p className="text-2xl font-semibold tabular-nums">₹{amount.toLocaleString()}</p>
          </div>

          {/* Wallet Checkbox (only for project payments with balance) */}
          {type === "project_payment" && paymentCalculation.hasWalletBalance && (
            <div className="space-y-3">
              <div className="flex items-center space-x-3 p-3 rounded-lg border border-border bg-card">
                <Checkbox
                  id="use-wallet"
                  checked={useWallet}
                  onCheckedChange={(checked) => setUseWallet(checked === true)}
                />
                <div className="flex-1">
                  <Label
                    htmlFor="use-wallet"
                    className="text-sm font-medium cursor-pointer flex items-center gap-2"
                  >
                    <Wallet className="h-4 w-4" />
                    Use wallet balance
                  </Label>
                  <p className="text-xs text-muted-foreground mt-0.5">
                    Available: ₹{walletBalance.toLocaleString()}
                  </p>
                </div>
              </div>

              {/* Payment Breakdown (if wallet is enabled) */}
              {useWallet && (
                <div className="p-3 rounded-lg border border-border bg-muted/20 space-y-2 text-xs">
                  <div className="flex items-center justify-between">
                    <span className="text-muted-foreground">Wallet</span>
                    <span className="font-medium">-₹{paymentCalculation.walletAmount.toLocaleString()}</span>
                  </div>
                  {paymentCalculation.razorpayAmount > 0 && (
                    <div className="flex items-center justify-between">
                      <span className="text-muted-foreground">Card/UPI</span>
                      <span className="font-medium">₹{paymentCalculation.razorpayAmount.toLocaleString()}</span>
                    </div>
                  )}
                  <div className="pt-2 border-t border-border flex items-center justify-between font-medium">
                    <span>You pay</span>
                    <span>₹{paymentCalculation.razorpayAmount.toLocaleString()}</span>
                  </div>
                </div>
              )}
            </div>
          )}

          {/* Pay Button */}
          <Button
            onClick={handlePayment}
            className="w-full h-10"
          >
            <CreditCard className="h-4 w-4 mr-2" />
            {paymentCalculation.isFullWalletPayment
              ? "Pay from Wallet"
              : paymentCalculation.isPartialPayment
              ? `Pay ₹${paymentCalculation.razorpayAmount.toLocaleString()}`
              : "Pay Now"}
          </Button>

          {/* Payment Method Info */}
          <div className="flex items-center justify-center gap-2 text-xs text-muted-foreground">
            {paymentCalculation.isFullWalletPayment ? (
              <>
                <Wallet className="h-3 w-3" />
                <span>Full payment from wallet</span>
              </>
            ) : (
              <>
                <CreditCard className="h-3 w-3" />
                <span>Credit/Debit Card, UPI, Net Banking</span>
              </>
            )}
          </div>

          {/* Security Note */}
          <p className="text-center text-xs text-muted-foreground pt-2 border-t">
            Secured by Razorpay • Your payment is encrypted
          </p>
        </div>
      </DialogContent>
    </Dialog>
  )
}
