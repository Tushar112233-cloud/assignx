/**
 * @fileoverview Custom hooks for wallet and earnings management.
 * @module hooks/use-wallet
 */

"use client"

import { useEffect, useState, useCallback, useRef } from "react"
import { createClient, getAuthUser } from "@/lib/supabase/client"
import type {
  Tables,
  WalletTransaction,
  WalletWithTransactions,
  TransactionType
} from "@/types/database"

type PayoutRequest = Tables<"payout_requests">

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
  const walletIdRef = useRef<string | null>(null)

  const fetchWallet = useCallback(async () => {
    const supabase = createClient()

    try {
      setIsLoading(true)
      setError(null)

      const user = await getAuthUser()

      if (!user) {
        setWallet(null)
        return
      }

      // Get wallet with recent transactions
      const { data: walletData, error: walletError } = await supabase
        .from("wallets")
        .select(`
          *,
          wallet_transactions (*)
        `)
        .eq("profile_id", user.id)
        .eq("wallet_type", "supervisor")
        .maybeSingle()

      if (walletError && walletError.code !== "PGRST116") {
        throw walletError
      }

      if (walletData) {
        // Sort transactions by date
        walletData.wallet_transactions = walletData.wallet_transactions?.sort(
          (a: WalletTransaction, b: WalletTransaction) =>
            new Date(b.created_at!).getTime() - new Date(a.created_at!).getTime()
        )
        walletIdRef.current = walletData.id
      }

      setWallet(walletData)
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

    const supabase = createClient()
    const user = await getAuthUser()
    if (!user) throw new Error("Not authenticated")

    // Create withdrawal request
    const { error: withdrawalError } = await supabase
      .from("payout_requests")
      .insert({
        profile_id: user.id,
        requester_type: "supervisor",
        requested_amount: amount,
        status: "pending",
      })

    if (withdrawalError) throw withdrawalError
    await fetchWallet()
  }, [wallet, fetchWallet])

  useEffect(() => {
    fetchWallet()
  }, [fetchWallet])

  // Realtime: wallet balance updates and new transactions
  useEffect(() => {
    const supabase = createClient()
    let walletChannel: ReturnType<typeof supabase.channel> | null = null
    let txnChannel: ReturnType<typeof supabase.channel> | null = null
    let cancelled = false

    const setup = async () => {
      const user = await getAuthUser()
      if (!user || cancelled) return

      // Subscribe to wallet updates (balance changes)
      walletChannel = supabase
        .channel(`supervisor_wallet_${user.id}`)
        .on(
          "postgres_changes",
          {
            event: "UPDATE",
            schema: "public",
            table: "wallets",
            filter: `profile_id=eq.${user.id}`,
          },
          (payload) => {
            const updated = payload.new as WalletWithTransactions & { wallet_type?: string }
            // Only apply if it matches the supervisor wallet type
            if (updated.wallet_type !== "supervisor") return
            setWallet(prev => prev ? { ...prev, ...updated, wallet_transactions: prev.wallet_transactions } : prev)
          }
        )
        .subscribe()

      // Subscribe to new transactions using ref for stable wallet ID
      const wId = walletIdRef.current
      if (wId && !cancelled) {
        txnChannel = supabase
          .channel(`supervisor_wallet_txns_${wId}`)
          .on(
            "postgres_changes",
            {
              event: "INSERT",
              schema: "public",
              table: "wallet_transactions",
              filter: `wallet_id=eq.${wId}`,
            },
            (payload) => {
              const newTxn = payload.new as WalletTransaction
              setWallet(prev => {
                if (!prev) return prev
                const existing = prev.wallet_transactions || []
                return {
                  ...prev,
                  wallet_transactions: [newTxn, ...existing],
                }
              })
            }
          )
          .subscribe()
      }
    }

    setup().catch(() => {})

    return () => {
      cancelled = true
      if (walletChannel) supabase.removeChannel(walletChannel)
      if (txnChannel) supabase.removeChannel(txnChannel)
    }
  }, [wallet?.id])

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
  const [walletId, setWalletId] = useState<string | null>(null)

  const fetchTransactions = useCallback(async () => {
    const supabase = createClient()

    try {
      setIsLoading(true)
      setError(null)

      const user = await getAuthUser()

      if (!user) {
        setTransactions([])
        setTotalCount(0)
        return
      }

      // Get wallet ID
      const { data: wallet } = await supabase
        .from("wallets")
        .select("id")
        .eq("profile_id", user.id)
        .eq("wallet_type", "supervisor")
        .maybeSingle()

      if (!wallet) {
        setTransactions([])
        return
      }

      setWalletId(wallet.id)

      // Build query
      let query = supabase
        .from("wallet_transactions")
        .select("*", { count: "exact" })
        .eq("wallet_id", wallet.id)
        .order("created_at", { ascending: false })
        .range(offset, offset + limit - 1)

      // Filter by type
      if (type) {
        if (Array.isArray(type)) {
          query = query.in("transaction_type", type)
        } else {
          query = query.eq("transaction_type", type)
        }
      }

      // Filter by date range
      if (startDate) {
        query = query.gte("created_at", startDate.toISOString())
      }
      if (endDate) {
        query = query.lte("created_at", endDate.toISOString())
      }

      const { data, error: queryError, count } = await query

      if (queryError) throw queryError

      setTransactions(data || [])
      setTotalCount(count || 0)
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Failed to fetch transactions"))
    } finally {
      setIsLoading(false)
    }
  }, [type, limit, offset, startDate, endDate])

  useEffect(() => {
    fetchTransactions()
  }, [fetchTransactions])

  // Realtime: new transactions
  useEffect(() => {
    if (!walletId) return

    const supabase = createClient()

    const channel = supabase
      .channel(`supervisor_txns_list_${walletId}`)
      .on(
        "postgres_changes",
        {
          event: "INSERT",
          schema: "public",
          table: "wallet_transactions",
          filter: `wallet_id=eq.${walletId}`,
        },
        (payload) => {
          const newTxn = payload.new as WalletTransaction
          setTransactions(prev => [newTxn, ...prev])
          setTotalCount(prev => prev + 1)
        }
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [walletId])

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
    const supabase = createClient()

    try {
      const user = await getAuthUser()

      if (!user) {
        setStats(null)
        return
      }

      // Get wallet
      const { data: wallet, error: walletError } = await supabase
        .from("wallets")
        .select("id, total_credited, balance")
        .eq("profile_id", user.id)
        .eq("wallet_type", "supervisor")
        .maybeSingle()

      if (!wallet) {
        setStats({
          thisMonth: 0,
          lastMonth: 0,
          thisYear: 0,
          allTime: 0,
          pendingPayouts: 0,
          averagePerProject: 0,
          monthlyGrowth: 0,
        })
        return
      }

      // Get transactions for calculations
      const now = new Date()
      const thisMonthStart = new Date(now.getFullYear(), now.getMonth(), 1)
      const lastMonthStart = new Date(now.getFullYear(), now.getMonth() - 1, 1)
      const lastMonthEnd = new Date(now.getFullYear(), now.getMonth(), 0)
      const thisYearStart = new Date(now.getFullYear(), 0, 1)

      const { data: transactions } = await supabase
        .from("wallet_transactions")
        .select("amount, transaction_type, created_at")
        .eq("wallet_id", wallet.id)
        .in("transaction_type", ["commission", "project_earning", "bonus"])

      const earningTxns = transactions || []

      // Calculate stats
      const thisMonth = earningTxns
        .filter(t => new Date(t.created_at!) >= thisMonthStart)
        .reduce((sum, t) => sum + (t.amount || 0), 0)

      const lastMonth = earningTxns
        .filter(t => {
          const date = new Date(t.created_at!)
          return date >= lastMonthStart && date <= lastMonthEnd
        })
        .reduce((sum, t) => sum + (t.amount || 0), 0)

      const thisYear = earningTxns
        .filter(t => new Date(t.created_at!) >= thisYearStart)
        .reduce((sum, t) => sum + (t.amount || 0), 0)

      // Get pending payouts
      const { data: pendingPayouts } = await supabase
        .from("payout_requests")
        .select("requested_amount")
        .eq("profile_id", user.id)
        .in("status", ["pending", "processing"])

      const pendingAmount = pendingPayouts?.reduce((sum, p) => sum + (p.requested_amount || 0), 0) || 0

      // Get project count for average
      const { data: supervisor } = await supabase
        .from("supervisors")
        .select("total_projects_managed")
        .eq("profile_id", user.id)
        .single()

      const projectCount = supervisor?.total_projects_managed || 1
      const averagePerProject = (wallet.total_credited || 0) / projectCount

      // Calculate monthly growth
      const monthlyGrowth = lastMonth > 0
        ? ((thisMonth - lastMonth) / lastMonth) * 100
        : thisMonth > 0 ? 100 : 0

      setStats({
        thisMonth,
        lastMonth,
        thisYear,
        allTime: wallet.total_credited || 0,
        pendingPayouts: pendingAmount,
        averagePerProject: Math.round(averagePerProject),
        monthlyGrowth: Math.round(monthlyGrowth),
      })
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Failed to fetch earnings stats"))
    } finally {
      setIsLoading(false)
    }
  }, [])

  useEffect(() => {
    fetchStats()
  }, [fetchStats])

  // Realtime: refetch stats when wallet is updated
  useEffect(() => {
    const supabase = createClient()
    let channel: ReturnType<typeof supabase.channel> | null = null
    let cancelled = false

    const setup = async () => {
      const user = await getAuthUser()
      if (!user || cancelled) return

      channel = supabase
        .channel(`supervisor_earnings_stats_${user.id}`)
        .on(
          "postgres_changes",
          {
            event: "UPDATE",
            schema: "public",
            table: "wallets",
            filter: `profile_id=eq.${user.id}`,
          },
          (payload) => {
            // Only react to supervisor wallet updates
            const updated = payload.new as { wallet_type?: string }
            if (updated.wallet_type !== "supervisor") return
            fetchStats()
          }
        )
        .subscribe()
    }

    setup().catch(() => {})

    return () => {
      cancelled = true
      if (channel) supabase.removeChannel(channel)
    }
  }, [fetchStats])

  return { stats, isLoading, error }
}

export function usePayoutRequests() {
  const [requests, setRequests] = useState<PayoutRequest[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  const fetchRequests = useCallback(async () => {
    const supabase = createClient()

    try {
      setIsLoading(true)

      const user = await getAuthUser()

      if (!user) {
        setRequests([])
        return
      }

      const { data, error: queryError } = await supabase
        .from("payout_requests")
        .select("*")
        .eq("profile_id", user.id)
        .order("created_at", { ascending: false })

      if (queryError) throw queryError
      setRequests(data || [])
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
