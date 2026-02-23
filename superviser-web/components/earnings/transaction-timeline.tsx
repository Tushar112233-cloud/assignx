/**
 * @fileoverview Vertical transaction timeline showing recent transactions.
 * @module components/earnings/transaction-timeline
 */

"use client"

import { useMemo } from "react"
import { ArrowDownLeft, ArrowUpRight, ChevronRight, Receipt } from "lucide-react"
import { motion } from "framer-motion"
import { formatDistanceToNow, format } from "date-fns"
import Link from "next/link"

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Skeleton } from "@/components/ui/skeleton"
import { cn } from "@/lib/utils"
import { useTransactions } from "@/hooks/use-wallet"
import type { WalletTransaction } from "@/types/database"

/**
 * Determines if a transaction type is a credit (income)
 */
function isCreditType(type: string): boolean {
  return ["project_earning", "commission", "bonus", "credit", "top_up", "project_payment"].includes(type)
}

/**
 * Gets a human-readable description for transaction type
 */
function getTransactionDescription(transaction: WalletTransaction): string {
  if (transaction.description) {
    return transaction.description
  }

  const typeDescriptions: Record<string, string> = {
    project_earning: "Project payment received",
    commission: "Commission earned",
    bonus: "Bonus received",
    withdrawal: "Withdrawal processed",
    refund: "Refund processed",
    penalty: "Penalty applied",
    credit: "Account credited",
    debit: "Account debited",
    top_up: "Account top-up",
    project_payment: "Project payment",
    reversal: "Transaction reversed",
  }

  return typeDescriptions[transaction.transaction_type || ""] || "Transaction"
}

/**
 * Loading skeleton for transaction items
 */
function TransactionItemSkeleton() {
  return (
    <div className="flex gap-4">
      {/* Icon */}
      <Skeleton className="h-10 w-10 rounded-full flex-shrink-0" />

      {/* Content */}
      <div className="flex-1 min-w-0">
        <Skeleton className="h-4 w-3/4 mb-2" />
        <Skeleton className="h-3 w-1/2" />
      </div>

      {/* Amount */}
      <div className="text-right flex-shrink-0">
        <Skeleton className="h-5 w-20 mb-1 ml-auto" />
        <Skeleton className="h-3 w-16 ml-auto" />
      </div>
    </div>
  )
}

/**
 * Individual transaction item component
 */
interface TransactionItemProps {
  transaction: WalletTransaction
  index: number
  isLast: boolean
}

function TransactionItem({ transaction, index, isLast }: TransactionItemProps) {
  const isCredit = isCreditType(transaction.transaction_type || "")
  const amount = transaction.amount || 0
  const description = getTransactionDescription(transaction)
  const createdAt = transaction.created_at ? new Date(transaction.created_at) : new Date()

  return (
    <motion.div
      initial={{ opacity: 0, x: -20 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ duration: 0.3, delay: index * 0.05 }}
      className="relative"
    >
      {/* Timeline connector */}
      {!isLast && (
        <div className="absolute left-5 top-10 bottom-0 w-px bg-gradient-to-b from-gray-200 to-transparent dark:from-gray-700" />
      )}

      {/* Transaction item */}
      <div className="flex gap-4 p-3 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-900/50 transition-colors cursor-pointer group">
        {/* Icon */}
        <div
          className={cn(
            "h-10 w-10 rounded-full flex items-center justify-center flex-shrink-0 z-10 transition-transform group-hover:scale-110",
            isCredit
              ? "bg-orange-100 dark:bg-orange-900/30 text-orange-600 dark:text-orange-400"
              : "bg-gray-100 dark:bg-gray-800 text-gray-600 dark:text-gray-400"
          )}
        >
          {isCredit ? (
            <ArrowDownLeft className="h-5 w-5" />
          ) : (
            <ArrowUpRight className="h-5 w-5" />
          )}
        </div>

        {/* Content */}
        <div className="flex-1 min-w-0">
          <p className="font-medium text-sm text-gray-900 dark:text-gray-100 truncate">
            {description}
          </p>
          <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">
            {formatDistanceToNow(createdAt, { addSuffix: true })} • {format(createdAt, "MMM dd, hh:mm a")}
          </p>
        </div>

        {/* Amount */}
        <div className="text-right flex-shrink-0">
          <p
            className={cn(
              "font-semibold text-sm",
              isCredit
                ? "text-green-600 dark:text-green-400"
                : "text-red-600 dark:text-red-400"
            )}
          >
            {isCredit ? "+" : "-"}
            {amount.toLocaleString("en-IN", {
              style: "currency",
              currency: "INR",
              maximumFractionDigits: 0,
            })}
          </p>
          {transaction.status && transaction.status !== "completed" && (
            <p className="text-xs text-amber-600 dark:text-amber-400 mt-1 capitalize">
              {transaction.status}
            </p>
          )}
        </div>
      </div>
    </motion.div>
  )
}

/**
 * Empty state component
 */
function EmptyState() {
  return (
    <div className="flex flex-col items-center justify-center py-12 px-4">
      <div className="h-16 w-16 rounded-full bg-gray-100 dark:bg-gray-800 flex items-center justify-center mb-4">
        <Receipt className="h-8 w-8 text-gray-400 dark:text-gray-600" />
      </div>
      <p className="text-sm font-medium text-gray-900 dark:text-gray-100 mb-1">
        No transactions yet
      </p>
      <p className="text-xs text-gray-500 dark:text-gray-400 text-center max-w-xs">
        Your transaction history will appear here once you complete your first project
      </p>
    </div>
  )
}

/**
 * Transaction timeline component
 */
interface TransactionTimelineProps {
  limit?: number
  className?: string
}

export function TransactionTimeline({ limit = 7, className }: TransactionTimelineProps) {
  const { transactions, isLoading, error } = useTransactions({ limit: 50 })

  // Get recent transactions (limit)
  const recentTransactions = useMemo(() => {
    return transactions.slice(0, limit)
  }, [transactions, limit])

  if (error) {
    return (
      <Card className={cn("rounded-2xl border border-gray-200 dark:border-gray-800 bg-white dark:bg-gray-950", className)}>
        <CardContent className="p-6">
          <div className="text-center py-8">
            <p className="text-sm text-red-600 dark:text-red-400">Failed to load transactions</p>
            <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">{error.message}</p>
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card className={cn("rounded-2xl border border-gray-200 dark:border-gray-800 bg-white dark:bg-gray-950", className)}>
      <CardHeader className="pb-4">
        <CardTitle className="text-lg font-semibold text-gray-900 dark:text-gray-100">
          Recent Transactions
        </CardTitle>
        <CardDescription className="text-sm text-gray-500 dark:text-gray-400">
          Your latest activity
        </CardDescription>
      </CardHeader>

      <CardContent className="px-6 pb-6">
        {isLoading ? (
          <div className="space-y-6">
            <TransactionItemSkeleton />
            <TransactionItemSkeleton />
            <TransactionItemSkeleton />
            <TransactionItemSkeleton />
            <TransactionItemSkeleton />
          </div>
        ) : recentTransactions.length > 0 ? (
          <>
            <div className="space-y-3">
              {recentTransactions.map((transaction, index) => (
                <TransactionItem
                  key={transaction.id}
                  transaction={transaction}
                  index={index}
                  isLast={index === recentTransactions.length - 1}
                />
              ))}
            </div>

            {/* View all link */}
            {transactions.length > limit && (
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.4 }}
                className="mt-6 pt-4 border-t border-gray-200 dark:border-gray-800"
              >
                <Link
                  href="/earnings"
                  className="flex items-center justify-center gap-2 text-sm font-medium text-orange-600 hover:text-orange-700 dark:text-orange-400 dark:hover:text-orange-300 transition-colors group"
                >
                  View all transactions
                  <ChevronRight className="h-4 w-4 transition-transform group-hover:translate-x-1" />
                </Link>
              </motion.div>
            )}
          </>
        ) : (
          <EmptyState />
        )}
      </CardContent>
    </Card>
  )
}
