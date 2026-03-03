import { apiClient } from '@/lib/api/client'

/**
 * Wallet type
 */
interface Wallet {
  id: string
  profile_id: string
  wallet_type: string | null
  balance: number
  created_at: string | null
  [key: string]: any
}

/**
 * Wallet transaction type
 */
interface WalletTransaction {
  id: string
  wallet_id: string
  amount: number
  transaction_type: string | null
  description: string | null
  created_at: string | null
  [key: string]: any
}

/**
 * Payment method type
 */
interface PaymentMethod {
  id: string
  profile_id: string
  method_type: string | null
  is_default: boolean | null
  is_active: boolean | null
  role_context: string | null
  [key: string]: any
}

/**
 * Payment method insert type
 */
type PaymentMethodInsert = Partial<PaymentMethod>

/**
 * Transaction filters
 */
interface TransactionFilters {
  type?: string
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

/**
 * Wallet service for managing user wallet and transactions.
 * Uses API client instead of API.
 */
export const walletService = {
  /**
   * Gets the user's wallet information.
   */
  async getWallet(_profileId: string): Promise<Wallet | null> {
    try {
      const result = await apiClient<{ wallet: Wallet }>('/api/wallets/me')
      return result.wallet || null
    } catch {
      return null
    }
  },

  /**
   * Gets the user's wallet balance.
   */
  async getBalance(profileId: string): Promise<number> {
    const wallet = await this.getWallet(profileId)
    return wallet?.balance ?? 0
  },

  /**
   * Gets wallet transaction history.
   */
  async getTransactions(
    profileId: string,
    filters?: TransactionFilters
  ): Promise<WalletTransaction[]> {
    const params = new URLSearchParams({ profileId, walletType: 'user' })
    if (filters?.type) params.set('type', filters.type)
    if (filters?.fromDate) params.set('fromDate', filters.fromDate)
    if (filters?.toDate) params.set('toDate', filters.toDate)
    if (filters?.limit) params.set('limit', String(filters.limit))
    if (filters?.offset) params.set('offset', String(filters.offset))

    const result = await apiClient<{ transactions: WalletTransaction[] }>(
      `/api/wallets/transactions?${params.toString()}`
    )
    return result.transactions || result as any
  },

  /**
   * Creates a Razorpay order for wallet top-up.
   */
  async createTopUpOrder(profileId: string, amount: number): Promise<RazorpayOrder> {
    const shortId = profileId.substring(0, 8)
    const shortTime = Date.now().toString().slice(-10)
    const receipt = `tu_${shortId}_${shortTime}`

    const result = await apiClient<RazorpayOrder>('/api/payments/create-order', {
      method: 'POST',
      body: JSON.stringify({
        amount: amount * 100,
        currency: 'INR',
        receipt,
        notes: {
          type: 'wallet_topup',
          profile_id: profileId,
        },
      }),
    })
    return result
  },

  /**
   * Verifies payment and credits wallet.
   */
  async verifyAndCreditWallet(
    profileId: string,
    paymentData: PaymentVerification,
    amount: number,
    projectId?: string
  ): Promise<WalletTransaction> {
    const result = await apiClient<WalletTransaction>('/api/payments/verify', {
      method: 'POST',
      body: JSON.stringify({
        ...paymentData,
        profile_id: profileId,
        amount,
        project_id: projectId,
      }),
    })
    return result
  },

  /**
   * Creates a payment order for a project.
   */
  async createProjectPaymentOrder(
    projectId: string,
    amount: number
  ): Promise<RazorpayOrder> {
    if (!amount || amount <= 0) throw new Error('Invalid amount')
    const shortId = projectId.substring(0, 8)
    const shortTime = Date.now().toString().slice(-10)
    const receipt = `pj_${shortId}_${shortTime}`

    const result = await apiClient<RazorpayOrder>('/api/payments/create-order', {
      method: 'POST',
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
    return result
  },

  /**
   * Pays for a project using wallet balance.
   */
  async payFromWallet(
    profileId: string,
    projectId: string,
    amount: number
  ): Promise<WalletTransaction> {
    const result = await apiClient<WalletTransaction>('/api/payments/wallet-pay', {
      method: 'POST',
      body: JSON.stringify({
        profile_id: profileId,
        project_id: projectId,
        amount,
      }),
    })
    return result
  },

  /**
   * Creates a partial payment order (wallet + Razorpay).
   */
  async createPartialPaymentOrder(
    projectId: string,
    razorpayAmount: number
  ): Promise<RazorpayOrder> {
    const shortId = projectId.substring(0, 8)
    const shortTime = Date.now().toString().slice(-10)
    const receipt = `pp_${shortId}_${shortTime}`

    const result = await apiClient<RazorpayOrder>('/api/payments/create-order', {
      method: 'POST',
      body: JSON.stringify({
        amount: razorpayAmount * 100,
        currency: 'INR',
        receipt,
        notes: {
          type: 'partial_payment',
          project_id: projectId,
        },
      }),
    })
    return result
  },

  /**
   * Processes partial payment (wallet + Razorpay).
   */
  async processPartialPayment(
    profileId: string,
    projectId: string,
    paymentData: PaymentVerification,
    totalAmount: number,
    walletAmount: number,
    razorpayAmount: number
  ): Promise<any> {
    const result = await apiClient('/api/payments/partial-pay', {
      method: 'POST',
      body: JSON.stringify({
        ...paymentData,
        profile_id: profileId,
        project_id: projectId,
        total_amount: totalAmount,
        wallet_amount: walletAmount,
        razorpay_amount: razorpayAmount,
      }),
    })
    return result
  },

  /**
   * Gets user's saved payment methods.
   */
  async getPaymentMethods(profileId: string): Promise<PaymentMethod[]> {
    const result = await apiClient<{ paymentMethods: PaymentMethod[] }>(
      `/api/wallets/payment-methods?profileId=${profileId}&roleContext=user`
    )
    return result.paymentMethods || result as any
  },

  /**
   * Adds a new payment method.
   */
  async addPaymentMethod(paymentMethod: PaymentMethodInsert): Promise<PaymentMethod> {
    const result = await apiClient<{ paymentMethod: PaymentMethod }>('/api/wallets/payment-methods', {
      method: 'POST',
      body: JSON.stringify({ ...paymentMethod, role_context: 'user' }),
    })
    return result.paymentMethod || result as any
  },

  /**
   * Removes a payment method (soft delete).
   */
  async removePaymentMethod(paymentMethodId: string): Promise<void> {
    await apiClient(`/api/wallets/payment-methods/${paymentMethodId}`, {
      method: 'DELETE',
      body: JSON.stringify({ roleContext: 'user' }),
    })
  },

  /**
   * Sets a payment method as default.
   */
  async setDefaultPaymentMethod(
    profileId: string,
    paymentMethodId: string
  ): Promise<void> {
    await apiClient(`/api/wallets/payment-methods/${paymentMethodId}/default`, {
      method: 'PATCH',
      body: JSON.stringify({ profileId, roleContext: 'user' }),
    })
  },

  /**
   * Gets transaction summary for a period.
   */
  async getTransactionSummary(
    profileId: string,
    fromDate: string,
    toDate: string
  ): Promise<{ credits: number; debits: number }> {
    try {
      const result = await apiClient<{ credits: number; debits: number }>(
        `/api/wallets/transaction-summary?profileId=${profileId}&walletType=user&fromDate=${fromDate}&toDate=${toDate}`
      )
      return result
    } catch {
      return { credits: 0, debits: 0 }
    }
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
