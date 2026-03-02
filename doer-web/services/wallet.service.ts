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

export async function getWallet(profileId: string): Promise<Wallet | null> {
  try {
    return await apiClient<Wallet>('/api/wallets/me')
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
  profileId: string,
  period: 'week' | 'month' | 'year' = 'month'
): Promise<EarningsData[]> {
  try {
    const data = await apiClient<{ earnings: EarningsData[] }>(
      `/api/wallets/earnings/data?period=${period}`
    )
    return data.earnings || []
  } catch (err) {
    logger.error('Wallet', 'Error fetching earnings data:', err)
    return []
  }
}

export async function getEarningsSummary(profileId: string): Promise<{
  totalEarnings: number
  pendingPayout: number
  completedPayouts: number
  currentBalance: number
}> {
  try {
    return await apiClient<{
      totalEarnings: number
      pendingPayout: number
      completedPayouts: number
      currentBalance: number
    }>('/api/wallets/earnings/summary')
  } catch {
    return {
      totalEarnings: 0,
      pendingPayout: 0,
      completedPayouts: 0,
      currentBalance: 0,
    }
  }
}
