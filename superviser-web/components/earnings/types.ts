/**
 * @fileoverview Type definitions for the earnings module.
 * @module components/earnings/types
 */

// Re-export shared types from central database types
export type { TransactionType } from "@/types/database"
import type { TransactionType } from "@/types/database"

export interface Transaction {
  id: string
  type: TransactionType
  amount: number
  description: string
  project_id?: string
  project_title?: string
  status: "pending" | "completed" | "failed"
  created_at: string
  reference_id?: string
}

export interface EarningsData {
  period: string
  earnings: number
  projects_completed: number
  commission: number
}

export interface EarningsSummary {
  total_earnings: number
  total_commission: number
  pending_payout: number
  available_balance: number
  last_payout_date?: string
  last_payout_amount?: number
  monthly_earnings: EarningsData[]
  weekly_earnings: EarningsData[]
}

export interface CommissionBreakdown {
  project_id: string
  project_title: string
  user_amount: number
  doer_payout: number
  supervisor_commission: number
  platform_fee: number
  completed_at: string
}

export interface PayoutRequest {
  id: string
  amount: number
  status: "pending" | "processing" | "completed" | "failed"
  requested_at: string
  processed_at?: string
  bank_details: {
    bank_name: string
    account_number: string
    ifsc_code: string
  }
  reference_id?: string
}

export interface ChartDataPoint {
  name: string
  earnings: number
  commission: number
  projects?: number
}

export const TRANSACTION_TYPE_CONFIG: Partial<Record<
  TransactionType,
  { label: string; color: string; icon: string }
>> = {
  project_earning: { label: "Project Earning", color: "text-green-600", icon: "+" },
  commission: { label: "Commission", color: "text-blue-600", icon: "+" },
  bonus: { label: "Bonus", color: "text-purple-600", icon: "+" },
  withdrawal: { label: "Withdrawal", color: "text-orange-600", icon: "-" },
  refund: { label: "Refund", color: "text-red-600", icon: "-" },
  penalty: { label: "Penalty", color: "text-red-600", icon: "-" },
  // Other transaction types (credit, debit, top_up, project_payment, reversal) use defaults
}
