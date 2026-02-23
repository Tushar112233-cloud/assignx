/**
 * Payouts Service
 * Handles payout requests and bank details operations
 * @module services/payouts.service
 */

import { createClient } from '@/lib/supabase/client'
import { verifyProfileOwnership } from '@/lib/auth-helpers'
import { logger } from '@/lib/logger'
import type { Payout, PayoutRequest } from '@/types/database'

/**
 * Bank details update payload
 */
interface BankDetailsUpdate {
  /** Account holder name */
  bank_account_name: string
  /** Bank account number */
  bank_account_number: string
  /** Bank IFSC code */
  bank_ifsc_code: string
  /** Bank name */
  bank_name: string
  /** Optional UPI ID */
  upi_id?: string
}

/**
 * Get payout history for doer
 * @param profileId - The profile ID
 * @returns Array of payout records
 * @security Verifies ownership before returning data
 */
export async function getPayoutHistory(profileId: string): Promise<Payout[]> {
  // SECURITY: Verify the authenticated user owns this profile
  await verifyProfileOwnership(profileId)

  const supabase = createClient()

  const { data, error } = await supabase
    .from('payouts')
    .select('*')
    .eq('profile_id', profileId)
    .order('requested_at', { ascending: false })

  if (error) {
    logger.error('Payouts', 'Error fetching payout history:', error)
    return []
  }

  return data || []
}

/**
 * Request a new payout
 * @param profileId - The profile ID
 * @param amount - Payout amount in INR
 * @param paymentMethod - Payment method (bank_transfer or upi)
 * @returns Success status with payout request or error
 * @security Verifies ownership before creating payout request
 */
export async function requestPayout(
  profileId: string,
  amount: number,
  paymentMethod: 'bank_transfer' | 'upi'
): Promise<{ success: boolean; error?: string; payout?: PayoutRequest }> {
  // SECURITY: Verify the authenticated user owns this profile
  await verifyProfileOwnership(profileId)

  // Validate minimum amount (₹500)
  if (amount < 500) {
    return { success: false, error: 'Minimum payout amount is ₹500' }
  }

  // For now, simulate payout request creation
  const payoutRequest: PayoutRequest = {
    id: `payout-${Date.now()}`,
    profile_id: profileId,
    amount,
    payment_method: paymentMethod,
    status: 'pending',
    rejection_reason: null,
    created_at: new Date().toISOString(),
    reviewed_at: null,
    reviewed_by: null,
  }

  return { success: true, payout: payoutRequest }
}

/**
 * Update bank details for doer
 * @param profileId - The profile ID
 * @param bankDetails - Bank details to update
 * @returns Success status and optional error
 * @security Verifies ownership before updating
 */
export async function updateBankDetails(
  profileId: string,
  bankDetails: BankDetailsUpdate
): Promise<{ success: boolean; error?: string }> {
  // SECURITY: Verify the authenticated user owns this profile
  await verifyProfileOwnership(profileId)

  const supabase = createClient()

  const { error } = await supabase
    .from('doers')
    .update(bankDetails)
    .eq('profile_id', profileId)

  if (error) {
    logger.error('Payouts', 'Error updating bank details:', error)
    return { success: false, error: error.message }
  }

  return { success: true }
}
