/**
 * @fileoverview Earnings summary with balance overview and withdrawal options.
 * @module components/earnings/earnings-summary
 */

"use client"

import { useState } from "react"
import {
  Wallet,
  ArrowUpRight,
  ArrowDownLeft,
  Clock,
  CreditCard,
  Building2,
  AlertCircle,
} from "lucide-react"
import { useWallet, useEarningsStats, usePayoutRequests } from "@/hooks"

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Skeleton } from "@/components/ui/skeleton"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import { Progress } from "@/components/ui/progress"
import { toast } from "sonner"

export function EarningsSummary() {
  const { wallet, isLoading: walletLoading, requestWithdrawal, refetch } = useWallet()
  const { stats, isLoading: statsLoading } = useEarningsStats()
  const { requests, isLoading: requestsLoading } = usePayoutRequests()

  const [withdrawAmount, setWithdrawAmount] = useState("")
  const [isWithdrawing, setIsWithdrawing] = useState(false)
  const [showWithdrawDialog, setShowWithdrawDialog] = useState(false)

  const isLoading = walletLoading || statsLoading || requestsLoading

  const minWithdrawal = 500
  const maxWithdrawal = wallet?.balance || 0
  const availableBalance = wallet?.balance || 0
  const pendingBalance = stats?.pendingPayouts || 0
  const totalEarnings = wallet?.total_credited || stats?.allTime || 0

  const handleWithdraw = async () => {
    const amount = parseFloat(withdrawAmount)
    if (isNaN(amount) || amount < minWithdrawal || amount > maxWithdrawal) {
      toast.error("Please enter a valid amount")
      return
    }

    setIsWithdrawing(true)
    try {
      await requestWithdrawal(amount)
      toast.success(`Withdrawal of Rs.${amount.toLocaleString()} initiated successfully`)
      setShowWithdrawDialog(false)
      setWithdrawAmount("")
      await refetch()
    } catch {
      toast.error("Withdrawal failed. Please try again.")
    } finally {
      setIsWithdrawing(false)
    }
  }

  // Get last completed payout
  const lastPayout = requests?.find(r => r.status === "completed")

  // Calculate monthly goal progress
  const monthlyGoal = 30000
  const monthlyEarnings = stats?.thisMonth || 0
  const goalProgress = Math.min((monthlyEarnings / monthlyGoal) * 100, 100)
  const remainingForGoal = Math.max(monthlyGoal - monthlyEarnings, 0)

  // Recent completed payouts
  const recentPayouts = requests?.filter(r => r.status === "completed").slice(0, 3) || []

  if (isLoading) {
    return (
      <div className="space-y-6">
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          {[1, 2, 3, 4].map(i => (
            <Card key={i}>
              <CardContent className="pt-6">
                <Skeleton className="h-5 w-32 mb-2" />
                <Skeleton className="h-8 w-24 mb-2" />
                <Skeleton className="h-4 w-40" />
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Balance Cards */}
      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
        <Card className="bg-gradient-to-br from-green-50 to-emerald-50 dark:from-green-950/30 dark:to-emerald-950/30 border-green-200 dark:border-green-900 rounded-xl">
          <CardContent className="p-6">
            <div className="flex items-center gap-2 mb-3">
              <div className="h-10 w-10 rounded-lg bg-green-100 dark:bg-green-900/50 flex items-center justify-center">
                <Wallet className="h-5 w-5 text-green-600" />
              </div>
              <span className="text-sm font-medium text-green-700 dark:text-green-300">
                Available Balance
              </span>
            </div>
            <p className="text-3xl font-bold text-green-700 dark:text-green-300 tracking-tight">
              {availableBalance.toLocaleString("en-IN", {
                style: "currency",
                currency: "INR",
                maximumFractionDigits: 0,
              })}
            </p>
            <Dialog open={showWithdrawDialog} onOpenChange={setShowWithdrawDialog}>
              <DialogTrigger asChild>
                <Button className="w-full mt-4" size="sm" disabled={availableBalance < minWithdrawal}>
                  <ArrowUpRight className="h-4 w-4 mr-2" />
                  Withdraw
                </Button>
              </DialogTrigger>
              <DialogContent>
                <DialogHeader>
                  <DialogTitle>Withdraw Funds</DialogTitle>
                  <DialogDescription>
                    Transfer funds to your registered bank account
                  </DialogDescription>
                </DialogHeader>
                <div className="space-y-4 py-4">
                  {/* Available Balance */}
                  <div className="p-4 bg-muted/50 rounded-lg">
                    <p className="text-sm text-muted-foreground">Available to withdraw</p>
                    <p className="text-2xl font-bold">
                      {availableBalance.toLocaleString("en-IN", {
                        style: "currency",
                        currency: "INR",
                        maximumFractionDigits: 0,
                      })}
                    </p>
                  </div>

                  {/* Amount Input */}
                  <div className="space-y-2">
                    <Label htmlFor="amount">Withdrawal Amount</Label>
                    <div className="relative">
                      <span className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground">
                        Rs.
                      </span>
                      <Input
                        id="amount"
                        type="number"
                        placeholder="Enter amount"
                        value={withdrawAmount}
                        onChange={(e) => setWithdrawAmount(e.target.value)}
                        className="pl-10"
                        min={minWithdrawal}
                        max={maxWithdrawal}
                      />
                    </div>
                    <p className="text-xs text-muted-foreground">
                      Min: Rs.{minWithdrawal} | Max: Rs.{maxWithdrawal.toLocaleString()}
                    </p>
                  </div>

                  {/* Quick Amount Buttons */}
                  <div className="flex flex-wrap gap-2">
                    {[1000, 2000, 5000].map((amount) => (
                      <Button
                        key={amount}
                        variant="outline"
                        size="sm"
                        onClick={() => setWithdrawAmount(Math.min(amount, maxWithdrawal).toString())}
                        disabled={amount > maxWithdrawal}
                      >
                        Rs.{amount.toLocaleString()}
                      </Button>
                    ))}
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => setWithdrawAmount(maxWithdrawal.toString())}
                    >
                      Max
                    </Button>
                  </div>

                  {/* Bank Details */}
                  <div className="p-3 border rounded-lg">
                    <div className="flex items-center gap-2 text-sm mb-2">
                      <Building2 className="h-4 w-4 text-muted-foreground" />
                      <span className="font-medium">Transfer to registered bank account</span>
                    </div>
                  </div>

                  {/* Processing Info */}
                  <div className="flex items-start gap-2 p-3 bg-amber-50 dark:bg-amber-950/30 rounded-lg border border-amber-200 dark:border-amber-900">
                    <AlertCircle className="h-4 w-4 text-amber-600 shrink-0 mt-0.5" />
                    <p className="text-xs text-amber-700 dark:text-amber-300">
                      Withdrawals are processed within 24-48 hours on business days.
                    </p>
                  </div>
                </div>
                <DialogFooter>
                  <Button variant="outline" onClick={() => setShowWithdrawDialog(false)}>
                    Cancel
                  </Button>
                  <Button onClick={handleWithdraw} disabled={isWithdrawing}>
                    {isWithdrawing ? "Processing..." : "Confirm Withdrawal"}
                  </Button>
                </DialogFooter>
              </DialogContent>
            </Dialog>
          </CardContent>
        </Card>

        <Card className="rounded-xl">
          <CardContent className="p-6">
            <div className="flex items-center gap-2 mb-3">
              <div className="h-10 w-10 rounded-lg bg-amber-100 dark:bg-amber-900/50 flex items-center justify-center">
                <Clock className="h-5 w-5 text-amber-600" />
              </div>
              <span className="text-sm font-medium text-muted-foreground">Pending</span>
            </div>
            <p className="text-3xl font-bold text-amber-600 dark:text-amber-400 tracking-tight">
              {pendingBalance.toLocaleString("en-IN", {
                style: "currency",
                currency: "INR",
                maximumFractionDigits: 0,
              })}
            </p>
            <p className="text-xs text-muted-foreground mt-1">
              Will be available after project completion
            </p>
          </CardContent>
        </Card>

        <Card className="rounded-xl">
          <CardContent className="p-6">
            <div className="flex items-center gap-2 mb-3">
              <div className="h-10 w-10 rounded-lg bg-blue-100 dark:bg-blue-900/50 flex items-center justify-center">
                <ArrowDownLeft className="h-5 w-5 text-blue-600" />
              </div>
              <span className="text-sm font-medium text-muted-foreground">Total Earnings</span>
            </div>
            <p className="text-3xl font-bold text-blue-600 dark:text-blue-400 tracking-tight">
              {totalEarnings.toLocaleString("en-IN", {
                style: "currency",
                currency: "INR",
                maximumFractionDigits: 0,
              })}
            </p>
            <p className="text-xs text-muted-foreground mt-1">All time</p>
          </CardContent>
        </Card>

        <Card className="rounded-xl">
          <CardContent className="p-6">
            <div className="flex items-center gap-2 mb-3">
              <div className="h-10 w-10 rounded-lg bg-purple-100 dark:bg-purple-900/50 flex items-center justify-center">
                <CreditCard className="h-5 w-5 text-purple-600" />
              </div>
              <span className="text-sm font-medium text-muted-foreground">Last Payout</span>
            </div>
            <p className="text-3xl font-bold text-purple-600 dark:text-purple-400 tracking-tight">
              {(lastPayout?.approved_amount ?? lastPayout?.requested_amount)?.toLocaleString("en-IN", {
                style: "currency",
                currency: "INR",
                maximumFractionDigits: 0,
              }) || "N/A"}
            </p>
            {lastPayout?.created_at && (
              <p className="text-xs text-muted-foreground mt-1">
                {new Date(lastPayout.created_at).toLocaleDateString("en-IN", {
                  day: "numeric",
                  month: "short",
                  year: "numeric",
                })}
              </p>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Monthly Goal Progress */}
      <Card className="rounded-xl">
        <CardHeader className="pb-2">
          <CardTitle className="text-lg font-semibold">Monthly Goal</CardTitle>
          <CardDescription>Track your progress towards your monthly target</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-2xl font-bold">Rs.{monthlyEarnings.toLocaleString()}</p>
                <p className="text-sm text-muted-foreground">of Rs.{monthlyGoal.toLocaleString()} goal</p>
              </div>
              <Badge variant="secondary" className="text-lg px-3 py-1">
                {Math.round(goalProgress)}%
              </Badge>
            </div>
            <Progress value={goalProgress} className="h-3" />
            <p className="text-sm text-muted-foreground">
              {remainingForGoal > 0
                ? `You need Rs.${remainingForGoal.toLocaleString()} more to reach your monthly goal. Keep it up!`
                : "Congratulations! You've reached your monthly goal!"}
            </p>
          </div>
        </CardContent>
      </Card>

      {/* Payout History */}
      <Card className="rounded-xl">
        <CardHeader className="pb-2">
          <CardTitle className="text-lg font-semibold">Recent Payouts</CardTitle>
          <CardDescription>Your recent withdrawal history</CardDescription>
        </CardHeader>
        <CardContent>
          {recentPayouts.length === 0 ? (
            <div className="text-center py-8">
              <CreditCard className="h-12 w-12 text-muted-foreground/50 mx-auto mb-3" />
              <p className="text-muted-foreground">No payouts yet</p>
              <p className="text-sm text-muted-foreground">Your withdrawal history will appear here</p>
            </div>
          ) : (
            <div className="space-y-4">
              {recentPayouts.map((payout, index) => (
                <div
                  key={payout.id || index}
                  className="flex items-center justify-between p-3 bg-muted/30 rounded-lg"
                >
                  <div className="flex items-center gap-3">
                    <div className="h-10 w-10 rounded-full bg-green-100 flex items-center justify-center">
                      <ArrowUpRight className="h-5 w-5 text-green-600" />
                    </div>
                    <div>
                      <p className="font-medium">
                        {(payout.approved_amount ?? payout.requested_amount)?.toLocaleString("en-IN", {
                          style: "currency",
                          currency: "INR",
                          maximumFractionDigits: 0,
                        })}
                      </p>
                      <p className="text-xs text-muted-foreground">
                        {payout.created_at ? new Date(payout.created_at).toLocaleDateString("en-IN", {
                          day: "numeric",
                          month: "short",
                          year: "numeric",
                        }) : "N/A"}
                      </p>
                    </div>
                  </div>
                  <Badge variant="outline" className="text-green-600 border-green-200">
                    {payout.status}
                  </Badge>
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  )
}
