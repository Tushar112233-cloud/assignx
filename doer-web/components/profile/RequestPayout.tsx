'use client'

/**
 * Request Payout component
 * Allows users to request withdrawal of earnings
 * @module components/profile/RequestPayout
 */

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
  Wallet,
  Building2,
  Smartphone,
  Clock,
  AlertTriangle,
  CheckCircle2,
  Loader2,
  ArrowRight,
} from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Badge } from '@/components/ui/badge'
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert'
import { RadioGroup, RadioGroupItem } from '@/components/ui/radio-group'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog'
import { cn } from '@/lib/utils'
import { mockWallet } from './constants'
import type { Wallet as WalletType, Doer } from '@/types/database'

/**
 * RequestPayout component props
 */
interface RequestPayoutProps {
  /** Wallet data */
  wallet?: WalletType
  /** Doer data with bank details */
  doer: Doer
  /** Minimum payout amount */
  minPayout?: number
  /** Processing fee percentage */
  processingFee?: number
  /** Callback when payout is requested */
  onRequestPayout?: (amount: number, method: 'bank_transfer' | 'upi') => Promise<void>
  /** Additional class name */
  className?: string
}

/**
 * Request Payout component
 * Allows users to request withdrawal of earnings
 */
export function RequestPayout({
  wallet = mockWallet,
  doer,
  minPayout = 500,
  processingFee = 0,
  onRequestPayout,
  className,
}: RequestPayoutProps) {
  const [isOpen, setIsOpen] = useState(false)
  const [step, setStep] = useState(1)
  const [amount, setAmount] = useState('')
  const [paymentMethod, setPaymentMethod] = useState<'bank_transfer' | 'upi'>('bank_transfer')
  const [isProcessing, setIsProcessing] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState(false)

  const availableBalance = wallet.balance - wallet.locked_amount
  const payoutAmount = parseFloat(amount) || 0
  const fee = payoutAmount * (processingFee / 100)
  const netAmount = payoutAmount - fee
  const hasBankDetails = Boolean(doer.bank_account_name && doer.bank_account_number && doer.bank_ifsc_code)
  const hasUPI = Boolean(doer.upi_id)
  const quickAmounts = [1000, 2000, 5000, 10000].filter((amt) => amt <= availableBalance)
  const stepLabels = ['Amount', 'Method', 'Confirm']

  /** Validate amount */
  const validateAmount = () => {
    const amt = parseFloat(amount)
    if (isNaN(amt) || amt <= 0) {
      setError('Please enter a valid amount')
      return false
    }
    if (amt < minPayout) {
      setError(`Minimum payout amount is ₹${minPayout}`)
      return false
    }
    if (amt > availableBalance) {
      setError('Amount exceeds available balance')
      return false
    }
    return true
  }

  /** Handle next step */
  const handleNext = () => {
    if (step === 1) {
      if (!validateAmount()) return
      setError(null)
      setStep(2)
    } else if (step === 2) {
      if (!hasBankDetails && paymentMethod === 'bank_transfer') {
        setError('Please add bank details first')
        return
      }
      if (!hasUPI && paymentMethod === 'upi') {
        setError('Please add UPI ID first')
        return
      }
      setStep(3)
    }
  }

  /** Handle payout request */
  const handleConfirm = async () => {
    setIsProcessing(true)
    setError(null)

    try {
      if (onRequestPayout) {
        await onRequestPayout(payoutAmount, paymentMethod)
      } else {
        await new Promise((resolve) => setTimeout(resolve, 2000))
      }
      setSuccess(true)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to process payout request')
    } finally {
      setIsProcessing(false)
    }
  }

  /** Reset dialog */
  const handleClose = () => {
    setIsOpen(false)
    setTimeout(() => {
      setStep(1)
      setAmount('')
      setPaymentMethod('bank_transfer')
      setError(null)
      setSuccess(false)
    }, 200)
  }

  return (
    <div className={className}>
      <Card className="w-full max-w-full overflow-hidden border-blue-200/60 bg-gradient-to-br from-blue-50/80 via-blue-50/50 to-white shadow-lg shadow-blue-100/50">
        <CardHeader className="p-6 space-y-1">
          <CardTitle className="flex items-center gap-3">
            <div className="p-2.5 flex-shrink-0 rounded-xl bg-gradient-to-br from-blue-500 to-blue-600 shadow-lg shadow-blue-500/30">
              <Wallet className="h-5 w-5 text-white" />
            </div>
            <span className="bg-gradient-to-r from-blue-700 to-blue-600 bg-clip-text text-transparent truncate">
              Available Balance
            </span>
          </CardTitle>
          <CardDescription className="text-blue-600/70 line-clamp-2">Amount available for withdrawal</CardDescription>
        </CardHeader>
        <CardContent className="p-6 space-y-5">
          <div className="text-center py-6 px-4 rounded-2xl bg-gradient-to-br from-blue-500/5 via-blue-500/10 to-blue-600/5 border border-blue-200/50">
            <p className="text-5xl font-bold bg-gradient-to-r from-blue-700 via-blue-600 to-blue-700 bg-clip-text text-transparent">
              ₹{availableBalance.toLocaleString()}
            </p>
            {wallet.locked_amount > 0 && (
              <div className="flex items-center justify-center gap-2 mt-3">
                <div className="h-1.5 w-1.5 rounded-full bg-amber-500 animate-pulse" />
                <p className="text-sm text-blue-600/80 font-medium">
                  ₹{wallet.locked_amount.toLocaleString()} locked (pending clearance)
                </p>
              </div>
            )}
          </div>

          <div className="flex flex-wrap items-center justify-between gap-2 text-sm p-4 rounded-xl bg-white border border-blue-100 shadow-sm">
            <span className="text-blue-600/70 font-medium">Minimum payout</span>
            <span className="font-semibold text-blue-700">₹{minPayout.toLocaleString()}</span>
          </div>

          <Dialog open={isOpen} onOpenChange={setIsOpen}>
            <DialogTrigger asChild>
              <Button
                className="w-full gap-2 h-12 bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 shadow-lg shadow-blue-500/30 hover:shadow-xl hover:shadow-blue-500/40 transition-all duration-300"
                disabled={availableBalance < minPayout || !hasBankDetails}
              >
                <Wallet className="h-5 w-5" />
                <span className="font-semibold">Request Payout</span>
              </Button>
            </DialogTrigger>

            <DialogContent className="sm:max-w-md">
              {/* Progress indicator */}
              <div className="grid grid-cols-3 gap-3 mb-6">
                {stepLabels.map((label, index) => {
                  const stepIndex = index + 1
                  const isActive = step >= stepIndex
                  return (
                    <div key={label} className="space-y-2">
                      <div
                        className={cn(
                          'h-2.5 rounded-full transition-all duration-300',
                          isActive
                            ? 'bg-gradient-to-r from-blue-600 to-blue-700 shadow-sm shadow-blue-500/50'
                            : 'bg-blue-100'
                        )}
                      />
                      <p
                        className={cn(
                          'text-xs text-center font-medium transition-colors',
                          isActive ? 'text-blue-700' : 'text-blue-400'
                        )}
                      >
                        {label}
                      </p>
                    </div>
                  )
                })}
              </div>

              <AnimatePresence mode="wait">
                {success ? (
                  <SuccessState netAmount={netAmount} paymentMethod={paymentMethod} onClose={handleClose} />
                ) : (
                  <>
                    {step === 1 && (
                      <AmountStep
                        amount={amount}
                        setAmount={setAmount}
                        error={error}
                        setError={setError}
                        quickAmounts={quickAmounts}
                        availableBalance={availableBalance}
                        minPayout={minPayout}
                        onNext={handleNext}
                        onClose={handleClose}
                      />
                    )}
                    {step === 2 && (
                      <PaymentMethodStep
                        paymentMethod={paymentMethod}
                        setPaymentMethod={setPaymentMethod}
                        payoutAmount={payoutAmount}
                        doer={doer}
                        hasBankDetails={hasBankDetails}
                        hasUPI={hasUPI}
                        error={error}
                        setError={setError}
                        onBack={() => setStep(1)}
                        onNext={handleNext}
                      />
                    )}
                    {step === 3 && (
                      <ConfirmStep
                        payoutAmount={payoutAmount}
                        fee={fee}
                        netAmount={netAmount}
                        paymentMethod={paymentMethod}
                        doer={doer}
                        error={error}
                        isProcessing={isProcessing}
                        onBack={() => setStep(2)}
                        onConfirm={handleConfirm}
                      />
                    )}
                  </>
                )}
              </AnimatePresence>
            </DialogContent>
          </Dialog>

          {!hasBankDetails && (
            <Alert variant="default" className="border-amber-200 bg-gradient-to-br from-amber-50 to-amber-50/50">
              <AlertTriangle className="h-4 w-4 text-amber-600" />
              <AlertDescription className="text-amber-700 font-medium">
                Add bank details to request payouts
              </AlertDescription>
            </Alert>
          )}
        </CardContent>
      </Card>
    </div>
  )
}

/** Success state component */
function SuccessState({ netAmount, paymentMethod, onClose }: { netAmount: number; paymentMethod: string; onClose: () => void }) {
  return (
    <motion.div
      key="success"
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      className="text-center py-10"
    >
      <div className="relative mx-auto mb-6">
        <div className="w-20 h-20 rounded-full bg-gradient-to-br from-green-500 to-green-600 flex items-center justify-center shadow-xl shadow-green-500/30">
          <CheckCircle2 className="h-10 w-10 text-white" />
        </div>
        <div className="absolute -inset-2 rounded-full bg-green-500/20 animate-ping" />
      </div>
      <DialogTitle className="text-2xl mb-3 bg-gradient-to-r from-green-700 to-green-600 bg-clip-text text-transparent font-bold">
        Payout Request Submitted!
      </DialogTitle>
      <DialogDescription className="text-base">
        <span className="font-bold text-green-700">₹{netAmount.toLocaleString()}</span> will be credited to your{' '}
        {paymentMethod === 'bank_transfer' ? 'bank account' : 'UPI'} within 2-3 business days.
      </DialogDescription>
      <Button
        onClick={onClose}
        className="mt-8 bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 shadow-lg shadow-blue-500/30 px-8"
      >
        Done
      </Button>
    </motion.div>
  )
}

/** Amount step component */
function AmountStep({
  amount, setAmount, error, setError, quickAmounts, availableBalance, minPayout, onNext, onClose
}: {
  amount: string; setAmount: (v: string) => void; error: string | null; setError: (v: string | null) => void
  quickAmounts: number[]; availableBalance: number; minPayout: number; onNext: () => void; onClose: () => void
}) {
  return (
    <motion.div key="step1" initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -20 }}>
      <DialogHeader>
        <DialogTitle>Enter Amount</DialogTitle>
        <DialogDescription>How much would you like to withdraw?</DialogDescription>
      </DialogHeader>

      <div className="py-6 space-y-5">
        {error && (
          <Alert variant="destructive" className="border-red-200 bg-red-50">
            <AlertTriangle className="h-4 w-4" />
            <AlertDescription>{error}</AlertDescription>
          </Alert>
        )}

        <div className="space-y-2.5">
          <Label htmlFor="amount" className="text-blue-700 font-semibold">
            Amount (₹)
          </Label>
          <div className="relative">
            <span className="absolute left-4 top-1/2 -translate-y-1/2 text-blue-600 font-bold text-xl">₹</span>
            <Input
              id="amount"
              type="number"
              value={amount}
              onChange={(e) => {
                setAmount(e.target.value)
                setError(null)
              }}
              placeholder="0"
              className="pl-10 text-3xl font-bold h-16 border-blue-200 focus:border-blue-500 focus:ring-blue-500/20 bg-gradient-to-br from-blue-50/50 to-white"
            />
          </div>
        </div>

        <div className="flex flex-wrap gap-2">
          {quickAmounts.map((amt) => (
            <Button
              key={amt}
              variant="outline"
              size="sm"
              onClick={() => setAmount(amt.toString())}
              className={cn(
                'border-blue-200 hover:border-blue-500 hover:bg-blue-50 transition-all',
                amount === amt.toString() &&
                  'border-blue-600 bg-gradient-to-br from-blue-50 to-blue-100 text-blue-700 font-semibold shadow-sm'
              )}
            >
              ₹{amt.toLocaleString()}
            </Button>
          ))}
          <Button
            variant="outline"
            size="sm"
            onClick={() => setAmount(availableBalance.toString())}
            className={cn(
              'border-blue-200 hover:border-blue-500 hover:bg-blue-50 transition-all',
              amount === availableBalance.toString() &&
                'border-blue-600 bg-gradient-to-br from-blue-50 to-blue-100 text-blue-700 font-semibold shadow-sm'
            )}
          >
            Max (₹{availableBalance.toLocaleString()})
          </Button>
        </div>

        <div className="p-3 rounded-lg bg-blue-50/50 border border-blue-100">
          <p className="text-sm text-blue-600 font-medium">
            Available: ₹{availableBalance.toLocaleString()} • Min: ₹{minPayout.toLocaleString()}
          </p>
        </div>
      </div>

      <DialogFooter>
        <Button variant="outline" onClick={onClose} className="border-blue-200 hover:bg-blue-50">
          Cancel
        </Button>
        <Button
          onClick={onNext}
          className="gap-2 bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 shadow-lg shadow-blue-500/30"
        >
          Continue
          <ArrowRight className="h-4 w-4" />
        </Button>
      </DialogFooter>
    </motion.div>
  )
}

/** Payment method step component */
function PaymentMethodStep({
  paymentMethod, setPaymentMethod, payoutAmount, doer, hasBankDetails, hasUPI, error, setError, onBack, onNext
}: {
  paymentMethod: 'bank_transfer' | 'upi'; setPaymentMethod: (v: 'bank_transfer' | 'upi') => void; payoutAmount: number
  doer: Doer; hasBankDetails: boolean; hasUPI: boolean; error: string | null; setError: (v: string | null) => void
  onBack: () => void; onNext: () => void
}) {
  return (
    <motion.div key="step2" initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -20 }}>
      <DialogHeader>
        <DialogTitle>Select Payment Method</DialogTitle>
        <DialogDescription>Where should we send ₹{payoutAmount.toLocaleString()}?</DialogDescription>
      </DialogHeader>

      <div className="py-6 space-y-4">
        {error && (
          <Alert variant="destructive" className="border-red-200 bg-red-50">
            <AlertTriangle className="h-4 w-4" />
            <AlertDescription>{error}</AlertDescription>
          </Alert>
        )}

        <RadioGroup
          value={paymentMethod}
          onValueChange={(v) => {
            setPaymentMethod(v as typeof paymentMethod)
            setError(null)
          }}
          className="space-y-3"
        >
          <Label
            htmlFor="bank"
            className={cn(
              'flex items-center gap-4 p-5 rounded-xl border-2 cursor-pointer transition-all',
              paymentMethod === 'bank_transfer'
                ? 'border-blue-600 bg-gradient-to-br from-blue-50 to-blue-100/50 shadow-md shadow-blue-500/20'
                : 'border-blue-200 hover:border-blue-400 hover:bg-blue-50/50',
              !hasBankDetails && 'opacity-50 cursor-not-allowed'
            )}
          >
            <RadioGroupItem value="bank_transfer" id="bank" disabled={!hasBankDetails} />
            <div className="p-2.5 rounded-lg bg-gradient-to-br from-blue-500 to-blue-600 shadow-lg shadow-blue-500/30">
              <Building2 className="h-5 w-5 text-white" />
            </div>
            <div className="flex-1">
              <p className="font-semibold text-blue-900">Bank Transfer</p>
              <p className="text-sm text-blue-600/70">
                {hasBankDetails ? `${doer.bank_name} - ****${doer.bank_account_number?.slice(-4)}` : 'No bank account added'}
              </p>
            </div>
            {hasBankDetails && (
              <Badge variant="outline" className="bg-green-50 text-green-700 border-green-300 font-semibold">
                Verified
              </Badge>
            )}
          </Label>

          <Label
            htmlFor="upi"
            className={cn(
              'flex items-center gap-4 p-5 rounded-xl border-2 cursor-pointer transition-all',
              paymentMethod === 'upi'
                ? 'border-blue-600 bg-gradient-to-br from-blue-50 to-blue-100/50 shadow-md shadow-blue-500/20'
                : 'border-blue-200 hover:border-blue-400 hover:bg-blue-50/50',
              !hasUPI && 'opacity-50 cursor-not-allowed'
            )}
          >
            <RadioGroupItem value="upi" id="upi" disabled={!hasUPI} />
            <div className="p-2.5 rounded-lg bg-gradient-to-br from-purple-500 to-purple-600 shadow-lg shadow-purple-500/30">
              <Smartphone className="h-5 w-5 text-white" />
            </div>
            <div className="flex-1">
              <p className="font-semibold text-blue-900">UPI</p>
              <p className="text-sm text-blue-600/70">{hasUPI ? doer.upi_id : 'No UPI ID added'}</p>
            </div>
            {hasUPI && (
              <Badge variant="outline" className="bg-green-50 text-green-700 border-green-300 font-semibold">
                Active
              </Badge>
            )}
          </Label>
        </RadioGroup>
      </div>

      <DialogFooter>
        <Button variant="outline" onClick={onBack} className="border-blue-200 hover:bg-blue-50">
          Back
        </Button>
        <Button
          onClick={onNext}
          className="gap-2 bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 shadow-lg shadow-blue-500/30"
        >
          Continue
          <ArrowRight className="h-4 w-4" />
        </Button>
      </DialogFooter>
    </motion.div>
  )
}

/** Confirm step component */
function ConfirmStep({
  payoutAmount, fee, netAmount, paymentMethod, doer, error, isProcessing, onBack, onConfirm
}: {
  payoutAmount: number; fee: number; netAmount: number; paymentMethod: 'bank_transfer' | 'upi'; doer: Doer
  error: string | null; isProcessing: boolean; onBack: () => void; onConfirm: () => void
}) {
  return (
    <motion.div key="step3" initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -20 }}>
      <DialogHeader>
        <DialogTitle>Confirm Payout</DialogTitle>
        <DialogDescription>Review your payout request details</DialogDescription>
      </DialogHeader>

      <div className="py-6 space-y-5">
        {error && (
          <Alert variant="destructive" className="border-red-200 bg-red-50">
            <AlertTriangle className="h-4 w-4" />
            <AlertDescription>{error}</AlertDescription>
          </Alert>
        )}

        <div className="space-y-4 p-5 rounded-xl bg-gradient-to-br from-blue-50 to-blue-100/50 border-2 border-blue-200 shadow-sm">
          <div className="flex items-center justify-between">
            <span className="text-blue-600/70 font-medium">Payout Amount</span>
            <span className="font-semibold text-blue-900">₹{payoutAmount.toLocaleString()}</span>
          </div>
          {fee > 0 && (
            <div className="flex items-center justify-between">
              <span className="text-blue-600/70 font-medium">Processing Fee</span>
              <span className="font-semibold text-red-600">-₹{fee.toLocaleString()}</span>
            </div>
          )}
          <div className="border-t-2 border-blue-200/50 pt-4 flex items-center justify-between">
            <span className="font-semibold text-blue-900">You'll Receive</span>
            <span className="text-2xl font-bold bg-gradient-to-r from-blue-700 to-blue-600 bg-clip-text text-transparent">
              ₹{netAmount.toLocaleString()}
            </span>
          </div>
        </div>

        <div className="flex items-center gap-4 p-5 rounded-xl border-2 border-blue-200 bg-white shadow-sm">
          {paymentMethod === 'bank_transfer' ? (
            <>
              <div className="p-2.5 rounded-lg bg-gradient-to-br from-blue-500 to-blue-600 shadow-lg shadow-blue-500/30">
                <Building2 className="h-5 w-5 text-white" />
              </div>
              <div>
                <p className="font-semibold text-blue-900">{doer.bank_name}</p>
                <p className="text-sm text-blue-600/70">****{doer.bank_account_number?.slice(-4)}</p>
              </div>
            </>
          ) : (
            <>
              <div className="p-2.5 rounded-lg bg-gradient-to-br from-purple-500 to-purple-600 shadow-lg shadow-purple-500/30">
                <Smartphone className="h-5 w-5 text-white" />
              </div>
              <div>
                <p className="font-semibold text-blue-900">UPI</p>
                <p className="text-sm text-blue-600/70">{doer.upi_id}</p>
              </div>
            </>
          )}
        </div>

        <Alert className="border-blue-200 bg-blue-50/50">
          <Clock className="h-4 w-4 text-blue-600" />
          <AlertTitle className="text-blue-900">Processing Time</AlertTitle>
          <AlertDescription className="text-blue-600/80">
            Payouts are typically processed within 2-3 business days.
          </AlertDescription>
        </Alert>
      </div>

      <DialogFooter>
        <Button variant="outline" onClick={onBack} className="border-blue-200 hover:bg-blue-50">
          Back
        </Button>
        <Button
          onClick={onConfirm}
          disabled={isProcessing}
          className="gap-2 bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 shadow-lg shadow-blue-500/30 disabled:opacity-50"
        >
          {isProcessing ? (
            <>
              <Loader2 className="h-4 w-4 animate-spin" />
              Processing...
            </>
          ) : (
            <>
              <CheckCircle2 className="h-4 w-4" />
              Confirm Payout
            </>
          )}
        </Button>
      </DialogFooter>
    </motion.div>
  )
}
