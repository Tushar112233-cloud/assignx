/**
 * Payouts Service
 * Handles payout requests and bank details operations via API
 * @module services/payouts.service
 */

import { apiClient } from '@/lib/api/client'
import { logger } from '@/lib/logger'
import type { Payout } from '@/types/database'

interface PayoutRequestRecord {
  id: string
  doer_id: string
  requester_type: string
  requested_amount: number
  approved_amount: number | null
  status: 'pending' | 'approved' | 'rejected' | 'processing' | 'completed'
  reviewed_by: string | null
  reviewed_at: string | null
  rejection_reason: string | null
  payout_id: string | null
  created_at: string
  updated_at: string
}

interface BankDetailsUpdate {
  bank_account_name: string
  bank_account_number: string
  bank_ifsc_code: string
  bank_name: string
  upi_id?: string
}

export async function getPayoutHistory(): Promise<Payout[]> {
  try {
    const data = await apiClient<{ payouts: Payout[] }>('/api/wallets/payouts')
    return data.payouts || []
  } catch (err) {
    logger.error('Payouts', 'Error fetching payout history:', err)
    return []
  }
}

export async function requestPayout(
  amount: number,
  _paymentMethod: 'bank_transfer' | 'upi'
): Promise<{ success: boolean; error?: string; payout?: PayoutRequestRecord }> {
  if (amount < 500) {
    return { success: false, error: 'Minimum payout amount is ₹500' }
  }

  try {
    const data = await apiClient<PayoutRequestRecord>('/api/wallets/payout-request', {
      method: 'POST',
      body: JSON.stringify({
        amount,
        requester_type: 'doer',
      }),
    })
    return { success: true, payout: data }
  } catch (err) {
    logger.error('Payouts', 'Error requesting payout:', err)
    return { success: false, error: (err as Error).message }
  }
}

export async function updateBankDetails(
  bankDetails: BankDetailsUpdate
): Promise<{ success: boolean; error?: string }> {
  try {
    await apiClient('/api/doers/me/bank-details', {
      method: 'PUT',
      body: JSON.stringify(bankDetails),
    })
    return { success: true }
  } catch (err) {
    logger.error('Payouts', 'Error updating bank details:', err)
    return { success: false, error: (err as Error).message }
  }
}
