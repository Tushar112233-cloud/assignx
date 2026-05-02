/**
 * @fileoverview Payment ledger showing transaction history and balances.
 * @module components/earnings/payment-ledger
 */

"use client"

import { useState, useMemo } from "react"
import {
  ArrowDownLeft,
  ArrowUpRight,
  Search,
  Filter,
  Calendar,
  Download,
  ChevronLeft,
  ChevronRight,
} from "lucide-react"
import { format } from "date-fns"

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import { ScrollArea } from "@/components/ui/scroll-area"
import { Skeleton } from "@/components/ui/skeleton"
import { cn } from "@/lib/utils"
import { TransactionType, TRANSACTION_TYPE_CONFIG } from "./types"
import { useTransactions } from "@/hooks/use-wallet"

/**
 * Maps database transaction type to local TransactionType for display
 */
function mapTransactionType(dbType: string): TransactionType {
  const typeMap: Record<string, TransactionType> = {
    project_earning: "project_earning",
    commission: "commission",
    bonus: "bonus",
    withdrawal: "withdrawal",
    refund: "refund",
    penalty: "penalty",
    credit: "project_earning",
    debit: "withdrawal",
    top_up: "bonus",
    project_payment: "project_earning",
    reversal: "refund",
  }
  return typeMap[dbType] || "project_earning"
}

/**
 * Determines if a transaction type is a credit (income)
 */
function isCreditType(type: string): boolean {
  return ["project_earning", "commission", "bonus", "credit", "top_up", "project_payment"].includes(type)
}

/**
 * Loading skeleton for balance cards
 */
function BalanceCardSkeleton() {
  return (
    <Card>
      <CardContent className="pt-6">
        <div className="flex items-center gap-2 mb-1">
          <Skeleton className="h-4 w-4" />
          <Skeleton className="h-4 w-24" />
        </div>
        <Skeleton className="h-8 w-32 mt-1" />
      </CardContent>
    </Card>
  )
}

/**
 * Loading skeleton for table rows
 */
function TableRowSkeleton() {
  return (
    <TableRow>
      <TableCell><Skeleton className="h-4 w-20" /></TableCell>
      <TableCell><Skeleton className="h-4 w-40" /></TableCell>
      <TableCell><Skeleton className="h-4 w-24" /></TableCell>
      <TableCell><Skeleton className="h-4 w-28" /></TableCell>
      <TableCell><Skeleton className="h-4 w-16" /></TableCell>
      <TableCell className="text-right"><Skeleton className="h-4 w-20 ml-auto" /></TableCell>
    </TableRow>
  )
}

export function PaymentLedger() {
  const { transactions: walletTransactions, isLoading, error } = useTransactions({ limit: 100 })
  const [searchQuery, setSearchQuery] = useState("")
  const [typeFilter, setTypeFilter] = useState<string>("all")
  const [statusFilter, setStatusFilter] = useState<string>("all")
  const [currentPage, setCurrentPage] = useState(1)
  const itemsPerPage = 10

  // Memoized filtered transactions
  const filteredTransactions = useMemo(() => {
    return walletTransactions.filter((t) => {
      const description = t.description || ""
      const referenceId = t.reference_id || ""
      const transactionType = t.transaction_type || ""
      const status = t.status || "pending"

      const matchesSearch =
        searchQuery === "" ||
        description.toLowerCase().includes(searchQuery.toLowerCase()) ||
        referenceId.toLowerCase().includes(searchQuery.toLowerCase())
      const matchesType = typeFilter === "all" || transactionType === typeFilter
      const matchesStatus = statusFilter === "all" || status === statusFilter
      return matchesSearch && matchesType && matchesStatus
    })
  }, [walletTransactions, searchQuery, typeFilter, statusFilter])

  // Calculate summary statistics
  const summaryStats = useMemo(() => {
    const completed = walletTransactions.filter((t) => t.status === "completed")
    const totalCredited = completed
      .filter((t) => isCreditType(t.transaction_type || ""))
      .reduce((acc, t) => acc + (t.amount || 0), 0)
    const totalWithdrawn = completed
      .filter((t) => t.transaction_type === "withdrawal")
      .reduce((acc, t) => acc + (t.amount || 0), 0)
    const pending = walletTransactions
      .filter((t) => t.status === "pending")
      .reduce((acc, t) => acc + (t.amount || 0), 0)
    return { totalCredited, totalWithdrawn, pending }
  }, [walletTransactions])

  const totalPages = Math.ceil(filteredTransactions.length / itemsPerPage)
  const paginatedTransactions = filteredTransactions.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  )

  // Reset to page 1 when filters change
  const handleFilterChange = (setter: (value: string) => void) => (value: string) => {
    setter(value)
    setCurrentPage(1)
  }

  if (error) {
    return (
      <Card>
        <CardContent className="pt-6">
          <div className="text-center py-8">
            <p className="text-destructive">Failed to load transactions</p>
            <p className="text-sm text-muted-foreground mt-1">{error.message}</p>
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header with Balance Summary */}
      <div className="grid gap-6 md:grid-cols-3">
        {isLoading ? (
          <>
            <BalanceCardSkeleton />
            <BalanceCardSkeleton />
            <BalanceCardSkeleton />
          </>
        ) : (
          <>
            <Card className="bg-gradient-to-br from-green-50 to-emerald-50 dark:from-green-950/30 dark:to-emerald-950/30 border-green-200 dark:border-green-900 rounded-xl">
              <CardContent className="p-6">
                <div className="flex items-center gap-2 mb-2">
                  <div className="h-9 w-9 rounded-lg bg-green-100 dark:bg-green-900/50 flex items-center justify-center">
                    <ArrowDownLeft className="h-4 w-4 text-green-600" />
                  </div>
                  <span className="text-sm font-medium text-green-700 dark:text-green-300">Total Credited</span>
                </div>
                <p className="text-3xl font-bold text-green-700 dark:text-green-300 tracking-tight">
                  {summaryStats.totalCredited.toLocaleString("en-IN", {
                    style: "currency",
                    currency: "INR",
                    maximumFractionDigits: 0,
                  })}
                </p>
              </CardContent>
            </Card>
            <Card className="bg-gradient-to-br from-orange-50 to-amber-50 dark:from-orange-950/30 dark:to-amber-950/30 border-orange-200 dark:border-orange-900 rounded-xl">
              <CardContent className="p-6">
                <div className="flex items-center gap-2 mb-2">
                  <div className="h-9 w-9 rounded-lg bg-orange-100 dark:bg-orange-900/50 flex items-center justify-center">
                    <ArrowUpRight className="h-4 w-4 text-orange-600" />
                  </div>
                  <span className="text-sm font-medium text-orange-700 dark:text-orange-300">Total Withdrawn</span>
                </div>
                <p className="text-3xl font-bold text-orange-700 dark:text-orange-300 tracking-tight">
                  {summaryStats.totalWithdrawn.toLocaleString("en-IN", {
                    style: "currency",
                    currency: "INR",
                    maximumFractionDigits: 0,
                  })}
                </p>
              </CardContent>
            </Card>
            <Card className="bg-gradient-to-br from-blue-50 to-indigo-50 dark:from-blue-950/30 dark:to-indigo-950/30 border-blue-200 dark:border-blue-900 rounded-xl">
              <CardContent className="p-6">
                <div className="flex items-center gap-2 mb-2">
                  <div className="h-9 w-9 rounded-lg bg-blue-100 dark:bg-blue-900/50 flex items-center justify-center">
                    <Calendar className="h-4 w-4 text-blue-600" />
                  </div>
                  <span className="text-sm font-medium text-blue-700 dark:text-blue-300">Pending</span>
                </div>
                <p className="text-3xl font-bold text-blue-700 dark:text-blue-300 tracking-tight">
                  {summaryStats.pending.toLocaleString("en-IN", {
                    style: "currency",
                    currency: "INR",
                    maximumFractionDigits: 0,
                  })}
                </p>
              </CardContent>
            </Card>
          </>
        )}
      </div>

      {/* Filters */}
      <Card className="rounded-xl">
        <CardContent className="p-6">
          <div className="flex flex-col md:flex-row gap-4">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Search by description, project ID, or reference..."
                value={searchQuery}
                onChange={(e) => {
                  setSearchQuery(e.target.value)
                  setCurrentPage(1)
                }}
                className="pl-9"
              />
            </div>
            <Select value={typeFilter} onValueChange={handleFilterChange(setTypeFilter)}>
              <SelectTrigger className="w-[180px]">
                <Filter className="h-4 w-4 mr-2" />
                <SelectValue placeholder="Transaction Type" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Types</SelectItem>
                <SelectItem value="project_earning">Project Earnings</SelectItem>
                <SelectItem value="commission">Commission</SelectItem>
                <SelectItem value="bonus">Bonus</SelectItem>
                <SelectItem value="withdrawal">Withdrawal</SelectItem>
                <SelectItem value="refund">Refund</SelectItem>
                <SelectItem value="penalty">Penalty</SelectItem>
              </SelectContent>
            </Select>
            <Select value={statusFilter} onValueChange={handleFilterChange(setStatusFilter)}>
              <SelectTrigger className="w-[140px]">
                <SelectValue placeholder="Status" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Status</SelectItem>
                <SelectItem value="completed">Completed</SelectItem>
                <SelectItem value="pending">Pending</SelectItem>
                <SelectItem value="failed">Failed</SelectItem>
              </SelectContent>
            </Select>
            <Button variant="outline" disabled={isLoading || walletTransactions.length === 0}>
              <Download className="h-4 w-4 mr-2" />
              Export
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Transactions Table */}
      <Card className="rounded-xl">
        <CardHeader className="pb-2">
          <CardTitle className="text-lg font-semibold">Transaction History</CardTitle>
          <CardDescription>
            {isLoading ? (
              "Loading transactions..."
            ) : (
              `Showing ${paginatedTransactions.length} of ${filteredTransactions.length} transactions`
            )}
          </CardDescription>
        </CardHeader>
        <CardContent>
          <ScrollArea className="h-[calc(100vh-34rem)]">
            <Table>
              <TableHeader>
                <TableRow className="bg-muted/50 hover:bg-muted/50">
                  <TableHead className="font-medium px-4 py-3">Date</TableHead>
                  <TableHead className="font-medium px-4 py-3">Description</TableHead>
                  <TableHead className="font-medium px-4 py-3">Type</TableHead>
                  <TableHead className="font-medium px-4 py-3">Reference</TableHead>
                  <TableHead className="font-medium px-4 py-3">Status</TableHead>
                  <TableHead className="font-medium px-4 py-3 text-right">Amount</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {isLoading ? (
                  <>
                    <TableRowSkeleton />
                    <TableRowSkeleton />
                    <TableRowSkeleton />
                    <TableRowSkeleton />
                    <TableRowSkeleton />
                  </>
                ) : paginatedTransactions.length > 0 ? (
                  paginatedTransactions.map((transaction) => {
                    const transactionType = mapTransactionType(transaction.transaction_type || "")
                    const config = TRANSACTION_TYPE_CONFIG[transactionType] || { label: transactionType, color: "text-gray-600", icon: "•" }
                    const credit = isCreditType(transaction.transaction_type || "")
                    const status = transaction.status || "pending"
                    return (
                      <TableRow key={transaction.id} className="hover:bg-muted/30 transition-colors">
                        <TableCell className="whitespace-nowrap px-4 py-3">
                          {transaction.created_at && (
                            <>
                              {format(new Date(transaction.created_at), "dd MMM yyyy")}
                              <p className="text-xs text-muted-foreground">
                                {format(new Date(transaction.created_at), "hh:mm a")}
                              </p>
                            </>
                          )}
                        </TableCell>
                        <TableCell className="px-4 py-3">
                          <p className="font-medium">{transaction.description || "Transaction"}</p>
                        </TableCell>
                        <TableCell className="px-4 py-3">
                          <Badge variant="outline" className={cn("font-normal", config.color)}>
                            {config.label}
                          </Badge>
                        </TableCell>
                        <TableCell className="px-4 py-3">
                          <span className="text-xs font-mono text-muted-foreground">
                            {transaction.reference_id || "-"}
                          </span>
                        </TableCell>
                        <TableCell className="px-4 py-3">
                          <Badge
                            variant={
                              status === "completed"
                                ? "default"
                                : status === "pending"
                                  ? "secondary"
                                  : "destructive"
                            }
                            className={cn(
                              status === "completed" && "bg-green-600 hover:bg-green-700",
                              status === "pending" && "bg-amber-100 text-amber-700 hover:bg-amber-200",
                              status === "failed" && "bg-red-100 text-red-700 hover:bg-red-200"
                            )}
                          >
                            {status}
                          </Badge>
                        </TableCell>
                        <TableCell className="text-right px-4 py-3">
                          <span
                            className={cn(
                              "font-semibold",
                              credit ? "text-green-600" : "text-red-600"
                            )}
                          >
                            {credit ? "+" : "-"}
                            {(transaction.amount || 0).toLocaleString("en-IN", {
                              style: "currency",
                              currency: "INR",
                              maximumFractionDigits: 0,
                            })}
                          </span>
                        </TableCell>
                      </TableRow>
                    )
                  })
                ) : (
                  <TableRow>
                    <TableCell colSpan={6} className="text-center py-8">
                      <p className="text-muted-foreground">
                        {walletTransactions.length === 0
                          ? "No transactions yet"
                          : "No transactions match your filters"}
                      </p>
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </ScrollArea>

          {/* Pagination */}
          {!isLoading && totalPages > 1 && (
            <div className="flex items-center justify-between mt-4 pt-4 border-t">
              <p className="text-sm text-muted-foreground">
                Page {currentPage} of {totalPages}
              </p>
              <div className="flex items-center gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
                  disabled={currentPage === 1}
                >
                  <ChevronLeft className="h-4 w-4" />
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
                  disabled={currentPage === totalPages}
                >
                  <ChevronRight className="h-4 w-4" />
                </Button>
              </div>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  )
}
