"use client"

import { useState, useCallback, useRef } from "react"
import { toast } from "sonner"
import { walletService, type RazorpayOrder } from "@/services"
import {
  withRetry,
  PAYMENT_RETRY_OPTIONS,
  generateIdempotencyKey,
} from "@/lib/retry"

/**
 * Payment state
 */
interface PaymentState {
  isLoading: boolean
  orderId: string | null
  error: string | null
  retryCount: number
}

/**
 * usePayment hook
 * Manages payment flow state and operations with retry logic
 */
export function usePayment() {
  const [state, setState] = useState<PaymentState>({
    isLoading: false,
    orderId: null,
    error: null,
    retryCount: 0,
  })

  // Track idempotency keys to prevent duplicate operations
  const idempotencyKeysRef = useRef<Set<string>>(new Set())

  /**
   * Create a top-up order with retry logic
   */
  const createTopUpOrder = useCallback(
    async (profileId: string, amount: number): Promise<RazorpayOrder | null> => {
      // Generate idempotency key
      const idempotencyKey = generateIdempotencyKey(profileId, "topup", String(amount))

      // Check for duplicate request
      if (idempotencyKeysRef.current.has(idempotencyKey)) {
        toast.warning("Request already in progress")
        return null
      }

      idempotencyKeysRef.current.add(idempotencyKey)
      setState((prev) => ({ ...prev, isLoading: true, error: null, retryCount: 0 }))

      try {
        const result = await withRetry(
          () => walletService.createTopUpOrder(profileId, amount),
          {
            ...PAYMENT_RETRY_OPTIONS,
            onRetry: (attempt, error, delayMs) => {
              setState((prev) => ({ ...prev, retryCount: attempt }))
              console.log(
                `Retrying order creation (attempt ${attempt}), waiting ${delayMs}ms`,
                error
              )
              toast.info(`Retrying... (attempt ${attempt})`)
            },
          }
        )

        if (result.success && result.data) {
          setState((prev) => ({
            ...prev,
            orderId: result.data!.id,
            isLoading: false,
            retryCount: 0,
          }))
          return result.data
        } else {
          const message = getErrorMessage(result.error)
          setState((prev) => ({ ...prev, error: message, isLoading: false }))
          toast.error(message)
          return null
        }
      } finally {
        // Clean up idempotency key after a delay
        setTimeout(() => {
          idempotencyKeysRef.current.delete(idempotencyKey)
        }, 5000)
      }
    },
    []
  )

  /**
   * Create a project payment order with retry logic
   */
  const createProjectOrder = useCallback(
    async (projectId: string, amount: number): Promise<RazorpayOrder | null> => {
      const idempotencyKey = generateIdempotencyKey(projectId, "project_order", String(amount))

      if (idempotencyKeysRef.current.has(idempotencyKey)) {
        toast.warning("Request already in progress")
        return null
      }

      idempotencyKeysRef.current.add(idempotencyKey)
      setState((prev) => ({ ...prev, isLoading: true, error: null, retryCount: 0 }))

      try {
        const result = await withRetry(
          () => walletService.createProjectPaymentOrder(projectId, amount),
          {
            ...PAYMENT_RETRY_OPTIONS,
            onRetry: (attempt) => {
              setState((prev) => ({ ...prev, retryCount: attempt }))
              toast.info(`Retrying... (attempt ${attempt})`)
            },
          }
        )

        if (result.success && result.data) {
          setState((prev) => ({
            ...prev,
            orderId: result.data!.id,
            isLoading: false,
            retryCount: 0,
          }))
          return result.data
        } else {
          const message = getErrorMessage(result.error)
          setState((prev) => ({ ...prev, error: message, isLoading: false }))
          toast.error(message)
          return null
        }
      } finally {
        setTimeout(() => {
          idempotencyKeysRef.current.delete(idempotencyKey)
        }, 5000)
      }
    },
    []
  )

  /**
   * Pay from wallet with retry logic
   */
  const payFromWallet = useCallback(
    async (profileId: string, projectId: string, amount: number): Promise<boolean> => {
      const idempotencyKey = generateIdempotencyKey(
        profileId,
        "wallet_pay",
        `${projectId}_${amount}`
      )

      if (idempotencyKeysRef.current.has(idempotencyKey)) {
        toast.warning("Payment already in progress")
        return false
      }

      idempotencyKeysRef.current.add(idempotencyKey)
      setState((prev) => ({ ...prev, isLoading: true, error: null, retryCount: 0 }))

      try {
        const result = await withRetry(
          () => walletService.payFromWallet(profileId, projectId, amount),
          {
            ...PAYMENT_RETRY_OPTIONS,
            maxAttempts: 2, // Fewer retries for wallet payments (already atomic)
            onRetry: (attempt) => {
              setState((prev) => ({ ...prev, retryCount: attempt }))
              toast.info(`Retrying payment... (attempt ${attempt})`)
            },
          }
        )

        if (result.success) {
          setState((prev) => ({ ...prev, isLoading: false, retryCount: 0 }))
          toast.success("Payment successful!")
          return true
        } else {
          const message = getErrorMessage(result.error)
          setState((prev) => ({ ...prev, error: message, isLoading: false }))
          toast.error(message)
          return false
        }
      } finally {
        setTimeout(() => {
          idempotencyKeysRef.current.delete(idempotencyKey)
        }, 5000)
      }
    },
    []
  )

  /**
   * Verify payment with retry logic
   */
  const verifyPayment = useCallback(
    async (
      profileId: string,
      paymentData: {
        razorpay_order_id: string
        razorpay_payment_id: string
        razorpay_signature: string
      },
      amount: number,
      projectId?: string
    ): Promise<boolean> => {
      const idempotencyKey = generateIdempotencyKey(
        profileId,
        "verify",
        paymentData.razorpay_payment_id
      )

      if (idempotencyKeysRef.current.has(idempotencyKey)) {
        toast.warning("Verification already in progress")
        return false
      }

      idempotencyKeysRef.current.add(idempotencyKey)
      setState((prev) => ({ ...prev, isLoading: true, error: null, retryCount: 0 }))

      try {
        const result = await withRetry(
          () =>
            walletService.verifyAndCreditWallet(profileId, paymentData, amount, projectId),
          {
            ...PAYMENT_RETRY_OPTIONS,
            onRetry: (attempt) => {
              setState((prev) => ({ ...prev, retryCount: attempt }))
              toast.info(`Verifying payment... (attempt ${attempt})`)
            },
          }
        )

        if (result.success) {
          setState((prev) => ({ ...prev, isLoading: false, retryCount: 0 }))
          toast.success(projectId ? "Project payment verified!" : "Wallet topped up!")
          return true
        } else {
          const message = getErrorMessage(result.error)
          setState((prev) => ({ ...prev, error: message, isLoading: false }))
          toast.error(message)
          return false
        }
      } finally {
        setTimeout(() => {
          idempotencyKeysRef.current.delete(idempotencyKey)
        }, 10000) // Longer timeout for verification
      }
    },
    []
  )

  /**
   * Reset state
   */
  const reset = useCallback(() => {
    setState({
      isLoading: false,
      orderId: null,
      error: null,
      retryCount: 0,
    })
  }, [])

  return {
    ...state,
    createTopUpOrder,
    createProjectOrder,
    payFromWallet,
    verifyPayment,
    reset,
  }
}

/**
 * Extract error message from various error types
 */
function getErrorMessage(error: unknown): string {
  if (!error) return "An error occurred"

  if (typeof error === "string") return error

  if (error instanceof Error) return error.message

  if (typeof error === "object" && "message" in error) {
    return String((error as { message: unknown }).message)
  }

  if (typeof error === "object" && "error" in error) {
    return String((error as { error: unknown }).error)
  }

  return "An unexpected error occurred"
}
