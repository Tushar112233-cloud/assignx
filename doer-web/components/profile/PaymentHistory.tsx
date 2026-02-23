'use client'

/**
 * Payment History component
 * Displays transaction history with filtering and search
 * @module components/profile/PaymentHistory
 */

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
  Calendar,
  Download,
  Filter,
  Search,
  CreditCard,
  Clock,
  AlertCircle,
} from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import { cn } from '@/lib/utils'
import { transactionTypeConfig, statusConfig, mockTransactions } from './constants'
import type { WalletTransaction, TransactionType } from '@/types/database'

/**
 * PaymentHistory component props
 */
interface PaymentHistoryProps {
  /** Wallet transactions */
  transactions?: WalletTransaction[]
  /** Current balance */
  balance?: number
  /** Pending balance */
  pendingBalance?: number
  /** Loading state */
  isLoading?: boolean
  /** Callback to load more */
  onLoadMore?: () => void
  /** Additional class name */
  className?: string
}

/**
 * Format date for display
 * @param date - ISO date string
 * @returns Formatted date string
 */
const formatDate = (date: string): string => {
  return new Date(date).toLocaleDateString('en-IN', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  })
}

/**
 * Format time for display
 * @param date - ISO date string
 * @returns Formatted time string
 */
const formatTime = (date: string): string => {
  return new Date(date).toLocaleTimeString('en-IN', {
    hour: '2-digit',
    minute: '2-digit',
  })
}

/**
 * Payment History component
 * Displays transaction history with filtering
 */
export function PaymentHistory({
  transactions = mockTransactions,
  balance = 15800,
  pendingBalance = 1800,
  isLoading,
  onLoadMore,
  className,
}: PaymentHistoryProps) {
  const [activeTab, setActiveTab] = useState<'all' | 'completed' | 'pending'>('all')
  const [searchQuery, setSearchQuery] = useState('')
  const [typeFilter, setTypeFilter] = useState<TransactionType | 'all'>('all')

  /** Filter transactions based on current filters */
  const filteredTransactions = transactions.filter((tx) => {
    if (activeTab === 'completed' && tx.status !== 'completed') return false
    if (activeTab === 'pending' && tx.status !== 'pending') return false
    if (typeFilter !== 'all' && tx.transaction_type !== typeFilter) return false

    if (searchQuery) {
      const query = searchQuery.toLowerCase()
      return (
        tx.description?.toLowerCase().includes(query) ||
        tx.project_title?.toLowerCase().includes(query)
      )
    }
    return true
  })

  /** Calculate tab totals */
  const totals = {
    all: transactions.length,
    completed: transactions.filter((t) => t.status === 'completed').length,
    pending: transactions.filter((t) => t.status === 'pending').length,
  }

  return (
    <div className={cn('space-y-6', className)}>
      {/* Balance cards */}
      <div className="grid gap-4 sm:grid-cols-2">
        <Card className="w-full max-w-full overflow-hidden border-blue-200/60 bg-gradient-to-br from-blue-50/80 to-blue-100/40 rounded-[28px] shadow-sm hover:shadow-md transition-shadow">
          <CardContent className="p-6">
            <div className="flex items-center gap-4">
              <div className="h-12 w-12 flex-shrink-0 rounded-2xl bg-blue-500/15 flex items-center justify-center">
                <CreditCard className="h-6 w-6 text-blue-600" />
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-blue-700/70 truncate">Available Balance</p>
                <p className="text-3xl font-bold text-blue-700 tracking-tight truncate">
                  ₹{balance.toLocaleString()}
                </p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="w-full max-w-full overflow-hidden border-sky-200/60 bg-gradient-to-br from-sky-50/80 to-sky-100/40 rounded-[28px] shadow-sm hover:shadow-md transition-shadow">
          <CardContent className="p-6">
            <div className="flex items-center gap-4">
              <div className="h-12 w-12 flex-shrink-0 rounded-2xl bg-sky-500/15 flex items-center justify-center">
                <Clock className="h-6 w-6 text-sky-600" />
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-sky-700/70 truncate">Pending Earnings</p>
                <p className="text-3xl font-bold text-sky-700 tracking-tight truncate">
                  ₹{pendingBalance.toLocaleString()}
                </p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Transaction history */}
      <Card className="w-full max-w-full overflow-hidden rounded-[28px] shadow-lg border-blue-100/60">
        <CardHeader className="p-6 space-y-4">
          <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
            <div className="space-y-1.5 flex-1 min-w-0">
              <CardTitle className="text-2xl font-bold tracking-tight text-gray-900 truncate">
                Transaction History
              </CardTitle>
              <CardDescription className="text-base text-gray-600 line-clamp-2">
                View all your payment transactions
              </CardDescription>
            </div>
            <div className="flex flex-wrap items-center gap-2">
              <Badge variant="secondary" className="bg-blue-100 text-blue-700 hover:bg-blue-200 border-blue-200 font-medium">
                {totals.all} total
              </Badge>
              <Badge variant="secondary" className="bg-green-100 text-green-700 hover:bg-green-200 border-green-200 font-medium">
                {totals.completed} completed
              </Badge>
              <Button variant="outline" size="sm" className="gap-2 border-blue-200 hover:bg-blue-50 hover:text-blue-700 transition-colors">
                <Download className="h-4 w-4" />
                Export
              </Button>
            </div>
          </div>
        </CardHeader>
        <CardContent className="p-6 space-y-4">
          {/* Tabs */}
          <Tabs value={activeTab} onValueChange={(v) => setActiveTab(v as typeof activeTab)}>
            <TabsList className="bg-blue-50/50 border border-blue-100">
              <TabsTrigger
                value="all"
                className="gap-1 data-[state=active]:bg-blue-600 data-[state=active]:text-white data-[state=active]:shadow-sm"
              >
                All
                <Badge variant="secondary" className="ml-1 text-xs bg-white/20 text-current border-0">
                  {totals.all}
                </Badge>
              </TabsTrigger>
              <TabsTrigger
                value="completed"
                className="gap-1 data-[state=active]:bg-blue-600 data-[state=active]:text-white data-[state=active]:shadow-sm"
              >
                Completed
                <Badge variant="secondary" className="ml-1 text-xs bg-white/20 text-current border-0">
                  {totals.completed}
                </Badge>
              </TabsTrigger>
              <TabsTrigger
                value="pending"
                className="gap-1 data-[state=active]:bg-blue-600 data-[state=active]:text-white data-[state=active]:shadow-sm"
              >
                Pending
                <Badge variant="secondary" className="ml-1 text-xs bg-white/20 text-current border-0">
                  {totals.pending}
                </Badge>
              </TabsTrigger>
            </TabsList>
          </Tabs>

          {/* Filters */}
          <div className="flex flex-col lg:flex-row gap-3">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-blue-400" />
              <Input
                placeholder="Search transactions..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-9 border-blue-200 focus-visible:ring-blue-500 h-10"
              />
            </div>
            <Select value={typeFilter} onValueChange={(v) => setTypeFilter(v as typeof typeFilter)}>
              <SelectTrigger className="w-full lg:w-56 border-blue-200 focus:ring-blue-500 h-10">
                <Filter className="h-4 w-4 mr-2 text-blue-500" />
                <SelectValue placeholder="Filter by type" />
              </SelectTrigger>
              <SelectContent className="border-blue-200">
                <SelectItem value="all">All Types</SelectItem>
                {(Object.keys(transactionTypeConfig) as TransactionType[]).map((type) => (
                  <SelectItem key={type} value={type}>
                    {transactionTypeConfig[type].label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {/* Transaction table */}
          <div className="rounded-2xl border border-blue-100 overflow-hidden bg-white shadow-sm">
            <Table>
              <TableHeader>
                <TableRow className="bg-gradient-to-r from-blue-50 to-sky-50 hover:bg-gradient-to-r hover:from-blue-50 hover:to-sky-50 border-blue-100">
                  <TableHead className="font-semibold text-blue-900">Transaction</TableHead>
                  <TableHead className="hidden sm:table-cell font-semibold text-blue-900">Date</TableHead>
                  <TableHead className="hidden md:table-cell font-semibold text-blue-900">Status</TableHead>
                  <TableHead className="text-right font-semibold text-blue-900">Amount</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                <AnimatePresence>
                  {filteredTransactions.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={4} className="text-center py-8">
                        <AlertCircle className="h-8 w-8 mx-auto text-muted-foreground mb-2" />
                        <p className="text-muted-foreground">No transactions found</p>
                      </TableCell>
                    </TableRow>
                  ) : (
                    filteredTransactions.map((tx, index) => {
                      const typeConfig = transactionTypeConfig[tx.transaction_type]
                      const status = statusConfig[tx.status]
                      const TypeIcon = typeConfig.icon
                      const StatusIcon = status.icon
                      const isCredit = tx.amount > 0

                      return (
                        <motion.tr
                          key={tx.id}
                          initial={{ opacity: 0, y: 10 }}
                          animate={{ opacity: 1, y: 0 }}
                          exit={{ opacity: 0 }}
                          transition={{ delay: index * 0.05 }}
                          className="hover:bg-muted/50"
                        >
                          <TableCell className="py-4">
                            <div className="flex items-center gap-3">
                              <div className={cn('h-11 w-11 rounded-xl flex items-center justify-center shadow-sm', typeConfig.bgColor)}>
                                <TypeIcon className={cn('h-5 w-5', typeConfig.color)} />
                              </div>
                              <div>
                                <p className="font-semibold text-gray-900">{typeConfig.label}</p>
                                <p className="text-sm text-gray-500 line-clamp-1">
                                  {tx.description || tx.project_title || 'No description'}
                                </p>
                              </div>
                            </div>
                          </TableCell>
                          <TableCell className="hidden sm:table-cell py-4">
                            <p className="text-sm font-medium text-gray-900">{formatDate(tx.created_at)}</p>
                            <p className="text-xs text-gray-500">{formatTime(tx.created_at)}</p>
                          </TableCell>
                          <TableCell className="hidden md:table-cell py-4">
                            <Badge
                              variant="outline"
                              className={cn(
                                'gap-1.5 px-3 py-1 font-medium border-2',
                                tx.status === 'completed' && 'bg-blue-50 text-blue-700 border-blue-200',
                                tx.status === 'pending' && 'bg-sky-50 text-sky-700 border-sky-200',
                                tx.status === 'failed' && 'bg-red-50 text-red-700 border-red-200'
                              )}
                            >
                              <StatusIcon className="h-3.5 w-3.5" />
                              {status.label}
                            </Badge>
                          </TableCell>
                          <TableCell className="text-right py-4">
                            <p className={cn('font-bold text-base', isCredit ? 'text-green-600' : 'text-red-600')}>
                              {isCredit ? '+' : ''}₹{Math.abs(tx.amount).toLocaleString()}
                            </p>
                            <p className="text-xs text-gray-500 font-medium">
                              Balance: ₹{tx.balance_after.toLocaleString()}
                            </p>
                          </TableCell>
                        </motion.tr>
                      )
                    })
                  )}
                </AnimatePresence>
              </TableBody>
            </Table>
          </div>

          {/* Load more */}
          {filteredTransactions.length > 0 && onLoadMore && (
            <div className="text-center pt-6">
              <Button
                variant="outline"
                onClick={onLoadMore}
                className="border-blue-200 hover:bg-blue-50 hover:text-blue-700 hover:border-blue-300 font-medium px-8"
              >
                Load More
              </Button>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  )
}
