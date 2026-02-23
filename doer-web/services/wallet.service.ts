/**
 * Wallet Service
 * Handles wallet, transactions, and earnings operations
 * @module services/wallet.service
 */

import { createClient } from '@/lib/supabase/client'
import { verifyProfileOwnership, getAuthenticatedUser, ForbiddenError } from '@/lib/auth-helpers'
import { logger } from '@/lib/logger'
import type { Wallet, WalletTransaction, EarningsData, TransactionType } from '@/types/database'

/**
 * Transaction filter options
 */
interface TransactionFilter {
  /** Transaction type */
  type?: TransactionType
  /** Transaction status */
  status?: 'pending' | 'completed' | 'failed' | 'reversed'
  /** Start date for filtering */
  startDate?: string
  /** End date for filtering */
  endDate?: string
  /** Maximum number of results */
  limit?: number
}

/**
 * Get wallet by profile ID
 * @param profileId - The profile ID
 * @returns Wallet data or null if not found
 * @security Verifies ownership before returning data
 */
export async function getWallet(profileId: string): Promise<Wallet | null> {
  // SECURITY: Verify the authenticated user owns this profile
  await verifyProfileOwnership(profileId)

  const supabase = createClient()

  const { data, error } = await supabase
    .from('wallets')
    .select('*')
    .eq('profile_id', profileId)
    .eq('wallet_type', 'doer')
    .maybeSingle()

  if (error) {
    logger.error('Wallet', 'Error fetching wallet:', error)
    return null
  }

  return data
}

/**
 * Get wallet transactions with optional filtering
 * @param walletId - The wallet ID
 * @param filter - Optional filter options
 * @returns Array of wallet transactions
 * @security Verifies wallet ownership before returning data
 */
export async function getWalletTransactions(
  walletId: string,
  filter?: TransactionFilter
): Promise<WalletTransaction[]> {
  const supabase = createClient()

  // SECURITY: Verify the authenticated user owns this wallet
  const user = await getAuthenticatedUser()
  const { data: wallet } = await supabase
    .from('wallets')
    .select('profile_id')
    .eq('id', walletId)
    .single()

  if (!wallet || wallet.profile_id !== user.id) {
    throw new ForbiddenError('You do not have permission to access this wallet')
  }

  let query = supabase
    .from('wallet_transactions')
    .select('*')
    .eq('wallet_id', walletId)
    .order('created_at', { ascending: false })

  if (filter?.type) {
    query = query.eq('transaction_type', filter.type)
  }
  if (filter?.status) {
    query = query.eq('status', filter.status)
  }
  if (filter?.startDate) {
    query = query.gte('created_at', filter.startDate)
  }
  if (filter?.endDate) {
    query = query.lte('created_at', filter.endDate)
  }
  if (filter?.limit) {
    query = query.limit(filter.limit)
  }

  const { data, error } = await query

  if (error) {
    logger.error('Wallet', 'Error fetching transactions:', error)
    return []
  }

  return data || []
}

/**
 * Get earnings data for graph visualization
 * @param profileId - The profile ID
 * @param period - Time period (week, month, year)
 * @returns Array of earnings data points
 * @security Verifies ownership before returning data (via getWallet)
 */
export async function getEarningsData(
  profileId: string,
  period: 'week' | 'month' | 'year' = 'month'
): Promise<EarningsData[]> {
  const supabase = createClient()

  // First get the wallet (this also verifies ownership)
  const wallet = await getWallet(profileId)
  if (!wallet) {
    return []
  }

  // Calculate date range
  const now = new Date()
  const startDate = new Date()
  if (period === 'week') {
    startDate.setDate(now.getDate() - 7)
  } else if (period === 'month') {
    startDate.setDate(now.getDate() - 30)
  } else {
    startDate.setFullYear(now.getFullYear() - 1)
  }

  // Get transactions in the date range
  const { data: transactions } = await supabase
    .from('wallet_transactions')
    .select('*')
    .eq('wallet_id', wallet.id)
    .eq('transaction_type', 'project_earning')
    .gte('created_at', startDate.toISOString())
    .lte('created_at', now.toISOString())
    .order('created_at', { ascending: true })

  if (!transactions || transactions.length === 0) {
    return []
  }

  // Group by date
  const earningsByDate = new Map<string, { amount: number; projectCount: number }>()

  for (const tx of transactions) {
    const date = new Date(tx.created_at).toISOString().split('T')[0]
    const existing = earningsByDate.get(date) || { amount: 0, projectCount: 0 }
    earningsByDate.set(date, {
      amount: existing.amount + Number(tx.amount),
      projectCount: existing.projectCount + 1,
    })
  }

  // Convert to array
  const result: EarningsData[] = []
  earningsByDate.forEach((value, date) => {
    result.push({
      date,
      amount: value.amount,
      projectCount: value.projectCount,
    })
  })

  return result.sort((a, b) => a.date.localeCompare(b.date))
}

/**
 * Get total earnings summary
 * @param profileId - The profile ID
 * @returns Summary of earnings
 * @security Verifies ownership before returning data (via getWallet)
 */
export async function getEarningsSummary(profileId: string): Promise<{
  totalEarnings: number
  pendingPayout: number
  completedPayouts: number
  currentBalance: number
}> {
  // getWallet includes ownership verification
  const wallet = await getWallet(profileId)

  if (!wallet) {
    return {
      totalEarnings: 0,
      pendingPayout: 0,
      completedPayouts: 0,
      currentBalance: 0,
    }
  }

  return {
    totalEarnings: Number(wallet.total_credited) || 0,
    pendingPayout: Number(wallet.locked_amount) || 0,
    completedPayouts: Number(wallet.total_withdrawn) || 0,
    currentBalance: Number(wallet.balance) || 0,
  }
}
