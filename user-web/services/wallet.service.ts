import { createClient } from '@/lib/supabase/client'
import type { Database } from '@/types/database'

/**
 * Type aliases for wallet-related tables
 */
type Wallet = Database['public']['Tables']['wallets']['Row']
type WalletTransaction = Database['public']['Tables']['wallet_transactions']['Row']
type PaymentMethod = Database['public']['Tables']['payment_methods']['Row']
type PaymentMethodInsert = Database['public']['Tables']['payment_methods']['Insert']

/**
 * Transaction type
 */
type TransactionType = Database['public']['Enums']['transaction_type']

/**
 * Transaction filters
 */
interface TransactionFilters {
  type?: TransactionType
  fromDate?: string
  toDate?: string
  limit?: number
  offset?: number
}

/**
 * Razorpay order response
 */
interface RazorpayOrder {
  id: string
  amount: number
  currency: string
  receipt: string
}

/**
 * Payment verification data
 */
interface PaymentVerification {
  razorpay_order_id: string
  razorpay_payment_id: string
  razorpay_signature: string
}

const supabase = createClient()

/**
 * Wallet service for managing user wallet and transactions.
 * Handles balance queries, top-ups, and payment methods.
 */
export const walletService = {
  /**
   * Gets the user's wallet information.
   * @param profileId - The user's profile ID
   * @returns Wallet data or null
   */
  async getWallet(profileId: string): Promise<Wallet | null> {
    const { data, error } = await supabase
      .from('wallets')
      .select('*')
      .eq('profile_id', profileId)
      .eq('wallet_type', 'user')
      .single()

    if (error) {
      if (error.code === 'PGRST116') return null
      throw error
    }
    return data
  },

  /**
   * Gets the user's wallet balance.
   * @param profileId - The user's profile ID
   * @returns Balance amount
   */
  async getBalance(profileId: string): Promise<number> {
    const wallet = await this.getWallet(profileId)
    return wallet?.balance ?? 0
  },

  /**
   * Gets wallet transaction history.
   * @param profileId - The user's profile ID
   * @param filters - Optional filters
   * @returns Array of transactions
   */
  async getTransactions(
    profileId: string,
    filters?: TransactionFilters
  ): Promise<WalletTransaction[]> {
    // First get the wallet ID
    const wallet = await this.getWallet(profileId)
    if (!wallet) return []

    let query = supabase
      .from('wallet_transactions')
      .select('*')
      .eq('wallet_id', wallet.id)
      .order('created_at', { ascending: false })

    // Apply type filter
    if (filters?.type) {
      query = query.eq('transaction_type', filters.type)
    }

    // Apply date filters
    if (filters?.fromDate) {
      query = query.gte('created_at', filters.fromDate)
    }
    if (filters?.toDate) {
      query = query.lte('created_at', filters.toDate)
    }

    // Apply pagination
    if (filters?.limit) {
      query = query.limit(filters.limit)
    }
    if (filters?.offset) {
      query = query.range(filters.offset, filters.offset + (filters.limit || 10) - 1)
    }

    const { data, error } = await query

    if (error) throw error
    return data
  },

  /**
   * Creates a Razorpay order for wallet top-up.
   * @param profileId - The user's profile ID
   * @param amount - Amount in INR (will be converted to paise)
   * @returns Razorpay order details
   */
  async createTopUpOrder(profileId: string, amount: number): Promise<RazorpayOrder> {
    // Generate short receipt (max 40 chars for Razorpay)
    // Format: tu_<first 8 chars of UUID>_<timestamp last 10 digits>
    const shortId = profileId.substring(0, 8)
    const shortTime = Date.now().toString().slice(-10)
    const receipt = `tu_${shortId}_${shortTime}`

    // Call server action/API route to create Razorpay order
    const response = await fetch('/api/payments/create-order', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        amount: amount * 100, // Convert to paise
        currency: 'INR',
        receipt,
        notes: {
          type: 'wallet_topup',
          profile_id: profileId,
        },
      }),
    })

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}))
      throw new Error(errorData.error || `Failed to create order (${response.status})`)
    }

    return response.json()
  },

  /**
   * Verifies payment and credits wallet.
   * @param profileId - The user's profile ID
   * @param paymentData - Razorpay payment verification data
   * @param amount - Amount to credit
   * @param projectId - Optional project ID for project payments
   */
  async verifyAndCreditWallet(
    profileId: string,
    paymentData: PaymentVerification,
    amount: number,
    projectId?: string
  ): Promise<WalletTransaction> {
    // Verify payment on server
    const response = await fetch('/api/payments/verify', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        ...paymentData,
        profile_id: profileId,
        amount,
        project_id: projectId,
      }),
    })

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}))
      throw new Error(errorData.error || `Payment verification failed (${response.status})`)
    }

    return response.json()
  },

  /**
   * Creates a payment order for a project.
   * @param projectId - The project UUID
   * @param amount - Amount in INR
   * @returns Razorpay order details
   */
  async createProjectPaymentOrder(
    projectId: string,
    amount: number
  ): Promise<RazorpayOrder> {
    // Generate short receipt (max 40 chars for Razorpay)
    // Format: pj_<first 8 chars of UUID>_<timestamp last 10 digits>
    const shortId = projectId.substring(0, 8)
    const shortTime = Date.now().toString().slice(-10)
    const receipt = `pj_${shortId}_${shortTime}`

    const response = await fetch('/api/payments/create-order', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        amount: amount * 100,
        currency: 'INR',
        receipt,
        notes: {
          type: 'project_payment',
          project_id: projectId,
        },
      }),
    })

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}))
      throw new Error(errorData.error || `Failed to create order (${response.status})`)
    }

    return response.json()
  },

  /**
   * Pays for a project using wallet balance.
   * @param profileId - The user's profile ID
   * @param projectId - The project UUID
   * @param amount - Amount to deduct
   */
  async payFromWallet(
    profileId: string,
    projectId: string,
    amount: number
  ): Promise<WalletTransaction> {
    const response = await fetch('/api/payments/wallet-pay', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        profile_id: profileId,
        project_id: projectId,
        amount,
      }),
    })

    if (!response.ok) {
      const error = await response.json()
      throw new Error(error.message || 'Payment failed')
    }

    return response.json()
  },

  /**
   * Creates a partial payment order (wallet + Razorpay).
   * @param projectId - The project UUID
   * @param razorpayAmount - Amount to charge via Razorpay in INR
   * @returns Razorpay order details
   */
  async createPartialPaymentOrder(
    projectId: string,
    razorpayAmount: number
  ): Promise<RazorpayOrder> {
    const shortId = projectId.substring(0, 8)
    const shortTime = Date.now().toString().slice(-10)
    const receipt = `pp_${shortId}_${shortTime}` // pp = partial payment

    const response = await fetch('/api/payments/create-order', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        amount: razorpayAmount * 100, // Convert to paise
        currency: 'INR',
        receipt,
        notes: {
          type: 'partial_payment',
          project_id: projectId,
        },
      }),
    })

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}))
      throw new Error(errorData.error || `Failed to create order (${response.status})`)
    }

    return response.json()
  },

  /**
   * Processes partial payment (wallet + Razorpay).
   * @param profileId - The user's profile ID
   * @param projectId - The project UUID
   * @param paymentData - Razorpay payment verification data
   * @param totalAmount - Total project amount
   * @param walletAmount - Amount to deduct from wallet
   * @param razorpayAmount - Amount charged via Razorpay
   */
  async processPartialPayment(
    profileId: string,
    projectId: string,
    paymentData: PaymentVerification,
    totalAmount: number,
    walletAmount: number,
    razorpayAmount: number
  ): Promise<any> {
    const response = await fetch('/api/payments/partial-pay', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        ...paymentData,
        profile_id: profileId,
        project_id: projectId,
        total_amount: totalAmount,
        wallet_amount: walletAmount,
        razorpay_amount: razorpayAmount,
      }),
    })

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}))
      throw new Error(errorData.error || `Partial payment failed (${response.status})`)
    }

    return response.json()
  },

  /**
   * Gets user's saved payment methods.
   * @param profileId - The user's profile ID
   * @returns Array of payment methods
   */
  async getPaymentMethods(profileId: string): Promise<PaymentMethod[]> {
    const { data, error } = await supabase
      .from('payment_methods')
      .select('*')
      .eq('profile_id', profileId)
      .eq('role_context', 'user')
      .eq('is_active', true)
      .order('is_default', { ascending: false })

    if (error) throw error
    return data
  },

  /**
   * Adds a new payment method.
   * @param paymentMethod - Payment method data
   * @returns The created payment method
   */
  async addPaymentMethod(paymentMethod: PaymentMethodInsert): Promise<PaymentMethod> {
    const { data, error } = await supabase
      .from('payment_methods')
      .insert({ ...paymentMethod, role_context: 'user' })
      .select()
      .single()

    if (error) throw error
    return data
  },

  /**
   * Removes a payment method.
   * @param paymentMethodId - The payment method UUID
   */
  async removePaymentMethod(paymentMethodId: string): Promise<void> {
    const { error } = await supabase
      .from('payment_methods')
      .update({ is_active: false })
      .eq('id', paymentMethodId)
      .eq('role_context', 'user')

    if (error) throw error
  },

  /**
   * Sets a payment method as default.
   * @param profileId - The user's profile ID
   * @param paymentMethodId - The payment method UUID
   */
  async setDefaultPaymentMethod(
    profileId: string,
    paymentMethodId: string
  ): Promise<void> {
    // First, unset all defaults for this role
    await supabase
      .from('payment_methods')
      .update({ is_default: false })
      .eq('profile_id', profileId)
      .eq('role_context', 'user')

    // Set the new default
    const { error } = await supabase
      .from('payment_methods')
      .update({ is_default: true })
      .eq('id', paymentMethodId)
      .eq('role_context', 'user')

    if (error) throw error
  },

  /**
   * Gets transaction summary for a period.
   * @param profileId - The user's profile ID
   * @param fromDate - Start date
   * @param toDate - End date
   */
  async getTransactionSummary(
    profileId: string,
    fromDate: string,
    toDate: string
  ): Promise<{ credits: number; debits: number }> {
    const wallet = await this.getWallet(profileId)
    if (!wallet) return { credits: 0, debits: 0 }

    const { data, error } = await supabase
      .from('wallet_transactions')
      .select('amount, transaction_type')
      .eq('wallet_id', wallet.id)
      .gte('created_at', fromDate)
      .lte('created_at', toDate)

    if (error) throw error

    const summary = { credits: 0, debits: 0 }
    data.forEach((txn: any) => {
      if (txn.transaction_type === 'credit' || txn.transaction_type === 'topup') {
        summary.credits += txn.amount
      } else {
        summary.debits += txn.amount
      }
    })

    return summary
  },
}

// Re-export types
export type {
  Wallet,
  WalletTransaction,
  PaymentMethod,
  TransactionFilters,
  RazorpayOrder,
  PaymentVerification,
}
