/**
 * Financial and payment types
 * @module types/finance
 */

/**
 * Transaction type
 * Types of wallet transactions
 */
export type TransactionType =
  | 'project_earning' // Earnings from completed project
  | 'bonus'           // Bonus payment
  | 'referral'        // Referral bonus
  | 'adjustment'      // Manual adjustment
  | 'payout'          // Withdrawal to bank
  | 'refund'          // Refund from cancelled project
  | 'penalty'         // Penalty deduction
  | 'tax_deduction'   // Tax deductions
  | 'hold'            // Amount on hold
  | 'release'         // Released from hold
  | 'chargeback'      // Chargeback

/**
 * Payout status
 * Status of withdrawal requests
 */
export type PayoutStatus = 'pending' | 'processing' | 'completed' | 'failed' | 'cancelled'

/**
 * Wallet interface
 * User financial wallet - matches database schema
 */
export interface Wallet {
  /** Unique identifier */
  id: string
  /** Owner profile ID */
  profile_id: string
  /** Available balance */
  balance: number
  /** Currency code (INR) */
  currency: string
  /** Total amount credited (lifetime earnings) */
  total_credited: number
  /** Total amount debited */
  total_debited: number
  /** Lifetime withdrawals */
  total_withdrawn: number
  /** Locked/pending amount */
  locked_amount: number
  /** Creation timestamp */
  created_at: string
  /** Last update timestamp */
  updated_at: string
}

/**
 * Wallet transaction interface
 * Individual financial transaction - matches database schema
 */
export interface WalletTransaction {
  /** Unique identifier */
  id: string
  /** Parent wallet */
  wallet_id: string
  /** Transaction type */
  transaction_type: TransactionType
  /** Transaction amount */
  amount: number
  /** Balance before transaction */
  balance_before: number
  /** Balance after transaction */
  balance_after: number
  /** Transaction description */
  description: string | null
  /** External reference ID */
  reference_id: string | null
  /** Reference type */
  reference_type: 'project' | 'payout' | 'bonus' | 'adjustment' | null
  /** Related project ID */
  project_id: string | null
  /** Related project title (for display) */
  project_title?: string | null
  /** Transaction status */
  status: 'pending' | 'completed' | 'failed' | 'reversed'
  /** Creation timestamp */
  created_at: string
  /** Completion timestamp */
  completed_at: string | null
}

/**
 * Payout interface
 * Withdrawal to bank/UPI
 */
export interface Payout {
  /** Unique identifier */
  id: string
  /** Owner profile ID */
  profile_id: string
  /** Source wallet ID */
  wallet_id: string
  /** Requested amount */
  amount: number
  /** Processing fee */
  fee: number
  /** Net amount after fee */
  net_amount: number
  /** Payment method */
  payment_method: 'bank_transfer' | 'upi'
  /** Bank account holder name */
  bank_account_name: string | null
  /** Bank account number */
  bank_account_number: string | null
  /** Bank IFSC code */
  bank_ifsc_code: string | null
  /** Bank name */
  bank_name: string | null
  /** UPI ID */
  upi_id: string | null
  /** Payout status */
  status: PayoutStatus
  /** Bank transaction ID */
  transaction_id: string | null
  /** Failure reason */
  failure_reason: string | null
  /** Request timestamp */
  requested_at: string
  /** Processing timestamp */
  processed_at: string | null
  /** Completion timestamp */
  completed_at: string | null
}

/**
 * Payout request interface
 * User-initiated withdrawal request
 */
export interface PayoutRequest {
  /** Unique identifier */
  id: string
  /** Owner profile ID */
  profile_id: string
  /** Requested amount */
  amount: number
  /** Payment method */
  payment_method: 'bank_transfer' | 'upi'
  /** Request status */
  status: 'pending' | 'approved' | 'rejected' | 'processing' | 'completed'
  /** Rejection reason */
  rejection_reason: string | null
  /** Creation timestamp */
  created_at: string
  /** Review timestamp */
  reviewed_at: string | null
  /** Reviewer ID */
  reviewed_by: string | null
}

/**
 * Earnings data for graphs
 * Daily/monthly earnings summary
 */
export interface EarningsData {
  /** Date string (YYYY-MM-DD) */
  date: string
  /** Earnings amount */
  amount: number
  /** Number of projects */
  projectCount: number
}
