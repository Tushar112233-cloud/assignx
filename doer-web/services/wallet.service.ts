/**
 * Wallet Service
 * Handles wallet, transactions, and earnings operations via API
 * @module services/wallet.service
 */

import { apiClient } from '@/lib/api/client'
import { logger } from '@/lib/logger'
import type { Wallet, WalletTransaction, EarningsData, TransactionType } from '@/types/database'

interface TransactionFilter {
  type?: TransactionType
  status?: 'pending' | 'completed' | 'failed' | 'reversed'
  startDate?: string
  endDate?: string
  limit?: number
}

export async function getWallet(): Promise<Wallet | null> {
  try {
    const data = await apiClient<{ wallet: Wallet }>('/api/wallets/me')
    return data.wallet || null
  } catch (err) {
    logger.error('Wallet', 'Error fetching wallet:', err)
    return null
  }
}

export async function getWalletTransactions(
  walletId: string,
  filter?: TransactionFilter
): Promise<WalletTransaction[]> {
  const params = new URLSearchParams()
  if (filter?.type) params.set('type', filter.type)
  if (filter?.status) params.set('status', filter.status)
  if (filter?.startDate) params.set('start_date', filter.startDate)
  if (filter?.endDate) params.set('end_date', filter.endDate)
  if (filter?.limit) params.set('limit', filter.limit.toString())

  try {
    const data = await apiClient<{ transactions: WalletTransaction[] }>(
      `/api/wallets/me/transactions?${params}`
    )
    return data.transactions || []
  } catch (err) {
    logger.error('Wallet', 'Error fetching transactions:', err)
    return []
  }
}

export async function getEarningsData(
  _period: 'week' | 'month' | 'year' = 'month'
): Promise<EarningsData[]> {
  try {
    const data = await apiClient<{ earnings: Array<{ _id: { year: number; month: number }; total: number; count: number }> }>(
      `/api/wallets/earnings/monthly`
    )
    // Transform the monthly aggregation into EarningsData format
    return (data.earnings || []).map(item => ({
      date: `${item._id.year}-${String(item._id.month).padStart(2, '0')}-01`,
      amount: item.total,
      projectCount: item.count,
    }))
  } catch (err) {
    logger.error('Wallet', 'Error fetching earnings data:', err)
    return []
  }
}

export async function getEarningsSummary(): Promise<{
  totalEarnings: number
  pendingPayout: number
  completedPayouts: number
  currentBalance: number
}> {
  try {
    const data = await apiClient<{
      summary: {
        balance: number
        totalCredited: number
        totalDebited: number
        totalWithdrawn: number
        lockedAmount: number
        thisMonthEarnings: number
      }
    }>('/api/wallets/earnings/summary')
    const s = data.summary
    return {
      totalEarnings: s.totalCredited || 0,
      pendingPayout: s.lockedAmount || 0,
      completedPayouts: s.totalWithdrawn || 0,
      currentBalance: s.balance || 0,
    }
  } catch {
    return {
      totalEarnings: 0,
      pendingPayout: 0,
      completedPayouts: 0,
      currentBalance: 0,
    }
  }
}
