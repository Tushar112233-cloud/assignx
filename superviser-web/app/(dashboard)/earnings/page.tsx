/**
 * @fileoverview Redesigned Earnings page - Modern minimal design
 * Charcoal + Orange/Amber accent palette with illustrations
 * @module app/(dashboard)/earnings/page
 */

"use client"

import { useState, useMemo } from "react"
import { motion } from "framer-motion"
import { useAuth } from "@/hooks"
import { useWallet, useEarningsStats } from "@/hooks/use-wallet"
import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import {
  ArrowUpRight,
  Download,
  TrendingUp,
  Wallet,
  Loader2,
} from "lucide-react"
import { cn } from "@/lib/utils"
import { toast } from "sonner"
import { Skeleton } from "@/components/ui/skeleton"
import {
  EarningsSummaryV2,
  EarningsChartV2,
  TransactionTimeline,
  CommissionBreakdownV2,
  QuickActions,
} from "@/components/earnings"

// Performance Insights Component (inline to fix hook usage issue)
function PerformanceInsightsSection() {
  const { stats, isLoading } = useEarningsStats()

  // TODO: Fetch monthly goal from supervisor settings/profile in database
  const monthlyGoal = 50000

  // Get earnings from stats
  const currentEarnings = stats?.thisMonth || 0
  const progress = Math.min((currentEarnings / monthlyGoal) * 100, 100)
  const monthlyGrowth = stats?.monthlyGrowth || 0
  const isPositiveTrend = monthlyGrowth >= 0

  const getMotivationalMessage = (prog: number, trend: number): string => {
    if (prog >= 100) {
      return "Congratulations! You've achieved your monthly goal!"
    } else if (prog >= 75) {
      return "Almost there! Keep up the excellent work!"
    } else if (prog >= 50) {
      return "Halfway to your goal! You're doing great!"
    } else if (prog >= 25) {
      return "Good start! Stay consistent to reach your goal."
    } else if (trend > 0) {
      return "You're on the right track! Keep the momentum going."
    } else {
      return "Let's build momentum! Every project counts."
    }
  }

  if (isLoading) {
    return (
      <div className="rounded-2xl border border-gray-200 bg-white p-6">
        <div className="space-y-4">
          <Skeleton className="h-6 w-48" />
          <Skeleton className="h-4 w-32" />
          <Skeleton className="h-16 w-full" />
          <Skeleton className="h-8 w-full" />
        </div>
      </div>
    )
  }

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5 }}
      className="rounded-2xl border border-gray-200 bg-white p-6"
    >
      {/* Header */}
      <div className="mb-6">
        <div className="flex items-center justify-between mb-2">
          <h3 className="text-lg font-semibold text-gray-900">
            Performance Insights
          </h3>
          <TrendingUp className="w-5 h-5 text-orange-500" />
        </div>
        <p className="text-sm text-gray-600">Your monthly progress</p>
      </div>

      {/* Earnings Progress */}
      <div className="mb-6">
        <div className="flex items-end justify-between mb-3">
          <div>
            <motion.div
              initial={{ scale: 0.5, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              transition={{ duration: 0.5, delay: 0.2 }}
              className="text-4xl font-bold text-gray-900"
            >
              ₹{currentEarnings.toLocaleString("en-IN")}
            </motion.div>
            <p className="text-sm text-gray-600 mt-1">
              of ₹{monthlyGoal.toLocaleString("en-IN")} goal
            </p>
          </div>

          <motion.div
            initial={{ scale: 0, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            transition={{ duration: 0.5, delay: 0.3 }}
            className="px-3 py-1 rounded-full bg-orange-100 text-orange-700 text-sm font-semibold"
          >
            {progress.toFixed(0)}%
          </motion.div>
        </div>

        {/* Progress Bar */}
        <div className="relative h-3 bg-gray-100 rounded-full overflow-hidden">
          <motion.div
            initial={{ width: 0 }}
            animate={{ width: `${progress}%` }}
            transition={{ duration: 1, delay: 0.4, ease: "easeOut" }}
            className="absolute top-0 left-0 h-full bg-gradient-to-r from-orange-500 to-orange-400 rounded-full"
          />
        </div>
      </div>

      {/* Trend Comparison */}
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, delay: 0.6 }}
        className="p-4 rounded-xl bg-gray-50"
      >
        <div className="flex items-center gap-2 mb-2">
          <div className={cn(
            "flex items-center",
            isPositiveTrend ? "text-green-600" : "text-red-600"
          )}>
            <TrendingUp className={cn("w-5 h-5 mr-1", !isPositiveTrend && "rotate-180")} />
            <span className="font-semibold">
              {isPositiveTrend ? "+" : ""}{monthlyGrowth.toFixed(1)}%
            </span>
          </div>
          <span className="text-sm text-gray-600">vs last month</span>
        </div>

        <p className="text-sm text-gray-700">
          {getMotivationalMessage(progress, monthlyGrowth)}
        </p>
      </motion.div>
    </motion.div>
  )
}

// Withdrawal Dialog Component
function WithdrawalDialog({
  open,
  onOpenChange,
  availableBalance,
  onWithdraw,
}: {
  open: boolean
  onOpenChange: (open: boolean) => void
  availableBalance: number
  onWithdraw: (amount: number) => Promise<void>
}) {
  const [amount, setAmount] = useState("")
  const [isSubmitting, setIsSubmitting] = useState(false)

  const handleSubmit = async () => {
    const numAmount = parseFloat(amount)
    if (isNaN(numAmount) || numAmount <= 0) {
      toast.error("Please enter a valid amount")
      return
    }
    if (numAmount < 500) {
      toast.error("Minimum withdrawal is Rs. 500")
      return
    }
    if (numAmount > availableBalance) {
      toast.error("Insufficient balance")
      return
    }

    setIsSubmitting(true)
    try {
      await onWithdraw(numAmount)
      toast.success("Withdrawal request submitted successfully!")
      onOpenChange(false)
      setAmount("")
    } catch (error) {
      toast.error("Failed to submit withdrawal request")
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>Request Withdrawal</DialogTitle>
          <DialogDescription>
            Enter the amount you would like to withdraw. Minimum amount is Rs. 500.
          </DialogDescription>
        </DialogHeader>
        <div className="grid gap-4 py-4">
          <div className="space-y-2">
            <Label htmlFor="amount">Withdrawal Amount</Label>
            <div className="relative">
              <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500">₹</span>
              <Input
                id="amount"
                type="number"
                placeholder="0.00"
                value={amount}
                onChange={(e) => setAmount(e.target.value)}
                className="pl-8"
                min={500}
                max={availableBalance}
              />
            </div>
            <p className="text-xs text-gray-500">
              Available balance: ₹{availableBalance.toLocaleString("en-IN")}
            </p>
          </div>

          {/* Quick amount buttons */}
          <div className="flex gap-2">
            {[1000, 2000, 5000].map((preset) => (
              <Button
                key={preset}
                type="button"
                variant="outline"
                size="sm"
                onClick={() => setAmount(preset.toString())}
                disabled={preset > availableBalance}
                className="flex-1"
              >
                ₹{preset.toLocaleString("en-IN")}
              </Button>
            ))}
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={() => setAmount(availableBalance.toString())}
              className="flex-1"
            >
              Max
            </Button>
          </div>
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)}>
            Cancel
          </Button>
          <Button
            onClick={handleSubmit}
            disabled={isSubmitting}
            className="bg-[#F97316] hover:bg-[#EA580C] text-white"
          >
            {isSubmitting ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Processing...
              </>
            ) : (
              "Submit Request"
            )}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}

export default function EarningsPage() {
  const { user } = useAuth()
  const firstName = user?.full_name?.split(" ")[0] || "Supervisor"

  const { wallet, requestWithdrawal } = useWallet()
  const { stats } = useEarningsStats()

  const [withdrawDialogOpen, setWithdrawDialogOpen] = useState(false)

  // Calculate available balance
  const availableBalance = useMemo(() => {
    const balance = wallet?.balance || 0
    const pending = stats?.pendingPayouts || 0
    return Math.max(balance - pending, 0)
  }, [wallet?.balance, stats?.pendingPayouts])

  // Dynamic message based on earnings
  const earningsMessage = useMemo(() => {
    const thisMonth = stats?.thisMonth || 0
    const growth = stats?.monthlyGrowth || 0

    if (thisMonth === 0) {
      return "Ready to start earning this month"
    } else if (growth > 20) {
      return `Great progress! You're up ${growth}% this month`
    } else if (growth > 0) {
      return `Steady growth of ${growth}% this month`
    } else if (thisMonth > 0) {
      return `You've earned ₹${thisMonth.toLocaleString("en-IN")} this month`
    }
    return "Track your income and manage withdrawals"
  }, [stats?.thisMonth, stats?.monthlyGrowth])

  const handleExportClick = () => {
    // TODO: Implement CSV/PDF export of earnings statements
    toast.info("Export feature is not yet available. It will be added in a future update.")
  }

  // TODO: Fetch monthly goal from supervisor settings/profile in database
  const monthlyGoal = 50000
  const monthlyProgress = Math.min(((stats?.thisMonth || 0) / monthlyGoal) * 100, 100)
  const monthlyGrowth = stats?.monthlyGrowth || 0
  const monthlyGrowthLabel = monthlyGrowth === 0
    ? "No change yet"
    : `${monthlyGrowth > 0 ? "+" : ""}${monthlyGrowth.toFixed(1)}% vs last month`
  const goalRemaining = Math.max(monthlyGoal - (stats?.thisMonth || 0), 0)
  const balanceStatus = availableBalance < 500 ? "Below minimum withdrawal" : "Ready for payout"

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="relative">
        <div className="pointer-events-none absolute inset-0">
          <div className="absolute -top-32 left-8 h-64 w-64 rounded-full bg-orange-100/60 blur-3xl" />
          <div className="absolute top-32 right-10 h-56 w-56 rounded-full bg-amber-100/50 blur-3xl" />
          <div className="absolute bottom-8 left-1/3 h-48 w-48 rounded-full bg-orange-50/70 blur-3xl" />
        </div>

        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.4 }}
          className="relative max-w-[1400px] mx-auto p-8 lg:p-10"
        >
          {/* Hero Section */}
          <motion.section
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1, duration: 0.5 }}
            className="relative overflow-hidden rounded-3xl border border-gray-200 bg-white p-8 lg:p-10 mb-10"
          >
            <div className="pointer-events-none absolute -top-24 right-0 h-52 w-52 rounded-full bg-orange-100/60 blur-3xl" />
            <div className="pointer-events-none absolute bottom-0 left-6 h-40 w-40 rounded-full bg-amber-100/40 blur-3xl" />

            <div className="grid gap-8 lg:grid-cols-[1.05fr_0.95fr] items-start">
              {/* Left - Narrative + Snapshot */}
              <div className="space-y-6">
                <div className="inline-flex items-center gap-2 rounded-full border border-gray-200 bg-white px-3 py-1 text-xs font-semibold uppercase tracking-[0.2em] text-gray-600">
                  Earnings Command Center
                </div>

                <div>
                  <h1 className="text-4xl lg:text-5xl font-bold text-[#1C1C1C] tracking-tight">
                    Earnings, {firstName}
                  </h1>
                  <p className="text-lg text-gray-600 mt-2">
                    {earningsMessage}
                  </p>
                </div>

                <div className="flex flex-wrap gap-3">
                  <Button
                    onClick={() => setWithdrawDialogOpen(true)}
                    disabled={availableBalance < 500}
                    className="bg-[#F97316] hover:bg-[#EA580C] text-white rounded-full px-6 h-11 font-medium shadow-lg shadow-orange-500/20 hover:shadow-xl hover:shadow-orange-500/30 hover:-translate-y-0.5 active:translate-y-0 transition-all duration-200"
                  >
                    <ArrowUpRight className="mr-2 h-4 w-4" />
                    Request Payout
                  </Button>
                  <Button
                    variant="outline"
                    onClick={handleExportClick}
                    className="rounded-full px-6 h-11 border-gray-200 text-gray-700 hover:bg-gray-100"
                  >
                    <Download className="mr-2 h-4 w-4" />
                    Download Statement
                  </Button>
                </div>

                <div className="grid gap-3 sm:grid-cols-3">
                  <div className="rounded-2xl border border-gray-200 bg-white p-4">
                    <p className="text-xs font-semibold uppercase tracking-wide text-gray-500">This Month</p>
                    <p className="text-2xl font-bold text-[#1C1C1C]">
                      ₹{(stats?.thisMonth || 0).toLocaleString("en-IN")}
                    </p>
                    <p className="text-xs text-gray-500 mt-1">{monthlyGrowthLabel}</p>
                  </div>
                  <div className="rounded-2xl border border-gray-200 bg-white p-4">
                    <p className="text-xs font-semibold uppercase tracking-wide text-gray-500">Available</p>
                    <p className="text-2xl font-bold text-[#1C1C1C]">
                      ₹{availableBalance.toLocaleString("en-IN")}
                    </p>
                    <p className="text-xs text-gray-500 mt-1">{balanceStatus}</p>
                  </div>
                  <div className="rounded-2xl border border-gray-200 bg-white p-4">
                    <p className="text-xs font-semibold uppercase tracking-wide text-gray-500">Pending</p>
                    <p className="text-2xl font-bold text-[#1C1C1C]">
                      ₹{(stats?.pendingPayouts || 0).toLocaleString("en-IN")}
                    </p>
                    <p className="text-xs text-gray-500 mt-1">In processing</p>
                  </div>
                </div>
              </div>

              {/* Right - Balance Vault Stack */}
              <div className="grid gap-4">
                <div className="relative overflow-hidden rounded-2xl bg-[#111827] p-6 text-white">
                  <div className="pointer-events-none absolute -right-10 -top-10 h-24 w-24 rounded-full bg-orange-500/30 blur-2xl" />
                  <div className="flex items-start justify-between">
                    <div>
                      <p className="text-xs font-semibold uppercase tracking-wide text-white/60">Available Balance</p>
                      <p className="text-3xl font-bold">₹{availableBalance.toLocaleString("en-IN")}</p>
                      <p className="text-xs text-white/60 mt-1">{balanceStatus}</p>
                    </div>
                    <div className="h-12 w-12 rounded-xl bg-white/10 flex items-center justify-center">
                      <Wallet className="h-6 w-6 text-orange-300" />
                    </div>
                  </div>

                  <div className="mt-5 rounded-xl border border-white/10 bg-white/5 p-3">
                    <div className="flex items-center justify-between text-xs text-white/60">
                      <span>Pending payouts</span>
                      <span>₹{(stats?.pendingPayouts || 0).toLocaleString("en-IN")}</span>
                    </div>
                    <div className="mt-2 flex items-center justify-between text-xs text-white/60">
                      <span>Monthly goal</span>
                      <span>₹{monthlyGoal.toLocaleString("en-IN")}</span>
                    </div>
                    <div className="mt-3 h-2 rounded-full bg-white/10 overflow-hidden">
                      <div
                        className="h-full bg-gradient-to-r from-orange-400 to-amber-300"
                        style={{ width: `${monthlyProgress}%` }}
                      />
                    </div>
                    <div className="mt-3 flex items-center gap-2 text-xs text-white/70">
                      <span
                        className={cn(
                          "inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-xs font-semibold",
                          monthlyGrowth >= 0
                            ? "bg-emerald-500/20 text-emerald-200"
                            : "bg-rose-500/20 text-rose-200"
                        )}
                      >
                        <TrendingUp className={cn("h-3 w-3", monthlyGrowth < 0 && "rotate-180")} />
                        {monthlyGrowth > 0 ? "+" : ""}{monthlyGrowth.toFixed(1)}%
                      </span>
                      <span>{monthlyGrowthLabel}</span>
                    </div>
                  </div>
                </div>

                <div className="rounded-2xl border border-gray-200 bg-white p-5">
                  <div className="flex items-center justify-between">
                    <div>
                      <h3 className="text-sm font-semibold text-[#1C1C1C]">Goal Tracker</h3>
                      <p className="text-xs text-gray-500 mt-1">
                        ₹{goalRemaining.toLocaleString("en-IN")} to reach your goal
                      </p>
                    </div>
                    <span className="text-xs font-semibold text-gray-500">
                      {monthlyProgress.toFixed(0)}%
                    </span>
                  </div>
                  <div className="mt-4 h-2 rounded-full bg-gray-100 overflow-hidden">
                    <div
                      className="h-full bg-gradient-to-r from-orange-500 to-orange-400"
                      style={{ width: `${monthlyProgress}%` }}
                    />
                  </div>
                  <div className="mt-3 flex items-center justify-between text-xs text-gray-500">
                    <span>Target: ₹{monthlyGoal.toLocaleString("en-IN")}</span>
                    <span>Progress updated today</span>
                  </div>
                </div>

              </div>
            </div>
          </motion.section>

          {/* Earnings Snapshot */}
          <motion.section
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2, duration: 0.5 }}
            className="mb-10"
          >
            <div className="flex items-center justify-between mb-4">
              <div>
                <h2 className="text-lg font-semibold text-[#1C1C1C]">Earnings Snapshot</h2>
                <p className="text-sm text-gray-500">Balances and totals at a glance</p>
              </div>
              <span className="hidden sm:inline-flex items-center rounded-full border border-gray-200 bg-white px-3 py-1 text-xs text-gray-500">
                Updated moments ago
              </span>
            </div>
            <div className="rounded-3xl border border-gray-200 bg-white/90 p-4 shadow-sm">
              <EarningsSummaryV2 className="gap-4" />
            </div>
          </motion.section>

          {/* Analytics Row */}
          <motion.section
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3, duration: 0.5 }}
            className="grid grid-cols-1 lg:grid-cols-[1.2fr_0.8fr] gap-6 mb-10"
          >
            <EarningsChartV2 />
            <div className="space-y-6">
              <PerformanceInsightsSection />
              <div className="rounded-2xl border border-gray-200 bg-white p-5">
                <div className="flex items-center justify-between mb-4">
                  <h3 className="text-sm font-semibold text-[#1C1C1C]">Action Rail</h3>
                  <span className="text-xs text-gray-400">Payouts & reports</span>
                </div>
                <QuickActions
                  onWithdrawClick={() => setWithdrawDialogOpen(true)}
                  onExportClick={handleExportClick}
                />
              </div>
            </div>
          </motion.section>

          {/* Ledger + Mix */}
          <motion.section
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.4, duration: 0.5 }}
            className="grid grid-cols-1 lg:grid-cols-[360px_1fr] gap-6 mb-8"
          >
            <CommissionBreakdownV2 />
            <div id="transactions">
              <TransactionTimeline limit={10} />
            </div>
          </motion.section>

          {/* Withdrawal Dialog */}
          <WithdrawalDialog
            open={withdrawDialogOpen}
            onOpenChange={setWithdrawDialogOpen}
            availableBalance={availableBalance}
            onWithdraw={requestWithdrawal}
          />
        </motion.div>
      </div>
    </div>
  )
}
