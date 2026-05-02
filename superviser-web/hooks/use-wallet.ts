/**
 * @fileoverview Custom hooks for wallet and earnings management.
 * Uses Express API + Socket.IO instead of Supabase.
 * @module hooks/use-wallet
 */

"use client"

import { useEffect, useState, useCallback } from "react"
import { apiFetch } from "@/lib/api/client"
import { getStoredUser } from "@/lib/api/auth"
import { getSocket } from "@/lib/socket/client"
import type {
  PayoutRequest,
  WalletTransaction,
  WalletWithTransactions,
  TransactionType
} from "@/types/database"

interface UseWalletReturn {
  wallet: WalletWithTransactions | null
  isLoading: boolean
  error: Error | null
  refetch: () => Promise<void>
  requestWithdrawal: (amount: number) => Promise<void>
}

export function useWallet(): UseWalletReturn {
  const [wallet, setWallet] = useState<WalletWithTransactions | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  const fetchWallet = useCallback(async () => {
    try {
      setIsLoading(true)
      setError(null)

      const user = getStoredUser()
      if (!user) {
        setWallet(null)
        return
      }

      const response = await apiFetch<{ wallet: WalletWithTransactions } | WalletWithTransactions>("/api/wallets/me")

      // API wraps response in { wallet: ... }
      const data = (response as { wallet: WalletWithTransactions }).wallet || response as WalletWithTransactions

      if (data) {
        // Sort transactions by date
        if (data.wallet_transactions) {
          data.wallet_transactions = data.wallet_transactions.sort(
            (a: WalletTransaction, b: WalletTransaction) =>
              new Date(b.created_at!).getTime() - new Date(a.created_at!).getTime()
          )
        }
      }

      setWallet(data)
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Failed to fetch wallet"))
    } finally {
      setIsLoading(false)
    }
  }, [])

  const requestWithdrawal = useCallback(async (amount: number) => {
    if (!wallet) throw new Error("Wallet not found")
    if (amount > wallet.balance) throw new Error("Insufficient balance")
    if (amount < 500) throw new Error("Minimum withdrawal is Rs. 500")

    await apiFetch("/api/wallets/me/withdraw", {
      method: "POST",
      body: JSON.stringify({ amount, requesterType: "supervisor" }),
    })

    await fetchWallet()
  }, [wallet, fetchWallet])

  useEffect(() => {
    fetchWallet()
  }, [fetchWallet])

  // Realtime: wallet updates via Socket.IO
  useEffect(() => {
    const user = getStoredUser()
    if (!user) return

    try {
      const socket = getSocket()
      const handler = () => fetchWallet()
      socket.on(`wallet:${user.id}`, handler)
      return () => { socket.off(`wallet:${user.id}`, handler) }
    } catch {
      return undefined
    }
  }, [fetchWallet])

  return {
    wallet,
    isLoading,
    error,
    refetch: fetchWallet,
    requestWithdrawal,
  }
}

interface UseTransactionsOptions {
  type?: TransactionType | TransactionType[]
  limit?: number
  offset?: number
  startDate?: Date
  endDate?: Date
}

interface UseTransactionsReturn {
  transactions: WalletTransaction[]
  isLoading: boolean
  error: Error | null
  totalCount: number
  refetch: () => Promise<void>
}

export function useTransactions(options: UseTransactionsOptions = {}): UseTransactionsReturn {
  const { type, limit = 50, offset = 0, startDate, endDate } = options
  const [transactions, setTransactions] = useState<WalletTransaction[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)
  const [totalCount, setTotalCount] = useState(0)

  const fetchTransactions = useCallback(async () => {
    try {
      setIsLoading(true)
      setError(null)

      const user = getStoredUser()
      if (!user) {
        setTransactions([])
        setTotalCount(0)
        return
      }

      const params = new URLSearchParams()
      params.set("type", "supervisor")
      params.set("limit", String(limit))
      params.set("page", String(Math.floor(offset / limit) + 1))

      if (type) {
        const types = Array.isArray(type) ? type.join(",") : type
        params.set("type", types)
      }
      if (startDate) params.set("startDate", startDate.toISOString())
      if (endDate) params.set("endDate", endDate.toISOString())

      const data = await apiFetch<{ transactions: WalletTransaction[]; total: number }>(
        `/api/wallets/me/transactions?${params.toString()}`
      )

      setTransactions(data.transactions || [])
      setTotalCount(data.total || 0)
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Failed to fetch transactions"))
    } finally {
      setIsLoading(false)
    }
  }, [type, limit, offset, startDate, endDate])

  useEffect(() => {
    fetchTransactions()
  }, [fetchTransactions])

  // Realtime: new transactions via Socket.IO
  useEffect(() => {
    const user = getStoredUser()
    if (!user) return

    try {
      const socket = getSocket()
      const handler = () => fetchTransactions()
      socket.on(`wallet:${user.id}`, handler)
      return () => { socket.off(`wallet:${user.id}`, handler) }
    } catch {
      return undefined
    }
  }, [fetchTransactions])

  return {
    transactions,
    isLoading,
    error,
    totalCount,
    refetch: fetchTransactions,
  }
}

interface UseEarningsStatsReturn {
  stats: {
    thisMonth: number
    lastMonth: number
    thisYear: number
    allTime: number
    pendingPayouts: number
    averagePerProject: number
    monthlyGrowth: number
  } | null
  isLoading: boolean
  error: Error | null
}

export function useEarningsStats(): UseEarningsStatsReturn {
  const [stats, setStats] = useState<UseEarningsStatsReturn["stats"]>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  const fetchStats = useCallback(async () => {
    try {
      const user = getStoredUser()
      if (!user) {
        setStats(null)
        return
      }

      const data = await apiFetch<{
        summary: {
          balance: number
          totalCredited: number
          totalDebited: number
          totalWithdrawn: number
          lockedAmount: number
          thisMonthEarnings: number
        }
      }>("/api/wallets/earnings/summary?type=supervisor")

      const s = data.summary
      setStats(s ? {
        thisMonth: s.thisMonthEarnings || 0,
        lastMonth: 0,
        thisYear: s.totalCredited || 0,
        allTime: s.totalCredited || 0,
        pendingPayouts: s.lockedAmount || 0,
        averagePerProject: 0,
        monthlyGrowth: 0,
      } : null)
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Failed to fetch earnings stats"))
    } finally {
      setIsLoading(false)
    }
  }, [])

  useEffect(() => {
    fetchStats()
  }, [fetchStats])

  // Realtime: stats update via Socket.IO
  useEffect(() => {
    const user = getStoredUser()
    if (!user) return

    try {
      const socket = getSocket()
      const handler = () => fetchStats()
      socket.on(`wallet:${user.id}`, handler)
      return () => { socket.off(`wallet:${user.id}`, handler) }
    } catch {
      return undefined
    }
  }, [fetchStats])

  return { stats, isLoading, error }
}

export function usePayoutRequests() {
  const [requests, setRequests] = useState<PayoutRequest[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  const fetchRequests = useCallback(async () => {
    try {
      setIsLoading(true)

      const user = getStoredUser()
      if (!user) {
        setRequests([])
        return
      }

      // No dedicated payout-requests listing endpoint exists.
      // Fetch withdrawal transactions as a proxy for payout history.
      const data = await apiFetch<{ transactions: PayoutRequest[]; requests?: PayoutRequest[] }>(
        "/api/wallets/me/transactions?type=withdrawal"
      )

      setRequests(data.requests || data.transactions || [])
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Failed to fetch payout requests"))
    } finally {
      setIsLoading(false)
    }
  }, [])

  useEffect(() => {
    fetchRequests()
  }, [fetchRequests])

  return {
    requests,
    isLoading,
    error,
    refetch: fetchRequests,
  }
}
