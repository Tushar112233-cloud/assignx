'use client'

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
  Building2,
  CreditCard,
  Smartphone,
  Shield,
  CheckCircle2,
  AlertTriangle,
  Edit2,
  Save,
  X,
  Loader2,
  Eye,
  EyeOff,
  Lock,
  BadgeCheck,
} from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Badge } from '@/components/ui/badge'
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { cn } from '@/lib/utils'
import type { Doer } from '@/types/database'

interface BankSettingsProps {
  /** Doer data with bank details */
  doer: Doer
  /** Callback when bank details are saved */
  onSave?: (details: BankDetails) => Promise<void>
  /** Loading state */
  isLoading?: boolean
  /** Additional class name */
  className?: string
}

interface BankDetails {
  bank_account_name: string
  bank_account_number: string
  bank_ifsc_code: string
  bank_name: string
  upi_id: string
}

/**
 * Bank Settings component
 * Displays and allows editing of bank details
 */
export function BankSettings({
  doer,
  onSave,
  isLoading,
  className,
}: BankSettingsProps) {
  const [isEditing, setIsEditing] = useState(false)
  const [isSaving, setIsSaving] = useState(false)
  const [showAccountNumber, setShowAccountNumber] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState(false)

  // Form state
  const [formData, setFormData] = useState<BankDetails>({
    bank_account_name: doer.bank_account_name || '',
    bank_account_number: doer.bank_account_number || '',
    bank_ifsc_code: doer.bank_ifsc_code || '',
    bank_name: doer.bank_name || '',
    upi_id: doer.upi_id || '',
  })

  /** Mask account number */
  const maskAccountNumber = (number: string) => {
    if (!number || number.length < 4) return number
    return '*'.repeat(number.length - 4) + number.slice(-4)
  }

  /** Handle input change */
  const handleChange = (field: keyof BankDetails, value: string) => {
    setFormData((prev) => ({ ...prev, [field]: value }))
    setError(null)
  }

  /** Validate IFSC code */
  const validateIFSC = (code: string) => {
    const ifscRegex = /^[A-Z]{4}0[A-Z0-9]{6}$/
    return ifscRegex.test(code.toUpperCase())
  }

  /** Fetch bank name from IFSC */
  const fetchBankName = async (ifsc: string) => {
    if (!validateIFSC(ifsc)) return
    // In production, would fetch from actual API
    // Simulating bank name lookup
    const bankNames: Record<string, string> = {
      SBIN: 'State Bank of India',
      HDFC: 'HDFC Bank',
      ICIC: 'ICICI Bank',
      KKBK: 'Kotak Mahindra Bank',
      UTIB: 'Axis Bank',
    }
    const prefix = ifsc.substring(0, 4)
    handleChange('bank_name', bankNames[prefix] || 'Unknown Bank')
  }

  /** Handle save */
  const handleSave = async () => {
    setError(null)

    // Validate
    if (!formData.bank_account_name.trim()) {
      setError('Account holder name is required')
      return
    }
    if (!formData.bank_account_number.trim()) {
      setError('Account number is required')
      return
    }
    if (!validateIFSC(formData.bank_ifsc_code)) {
      setError('Invalid IFSC code format')
      return
    }

    setIsSaving(true)
    try {
      if (onSave) {
        await onSave(formData)
      } else {
        await new Promise((resolve) => setTimeout(resolve, 1000))
      }
      setSuccess(true)
      setIsEditing(false)
      setTimeout(() => setSuccess(false), 3000)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to save bank details')
    } finally {
      setIsSaving(false)
    }
  }

  /** Check if bank details are complete */
  const hasCompleteDetails = Boolean(
    doer.bank_account_name &&
      doer.bank_account_number &&
      doer.bank_ifsc_code
  )

  return (
    <div className={cn('space-y-6', className)}>
      {/* Success alert */}
      <AnimatePresence>
        {success && (
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
          >
            <Alert className="border-blue-500/50 bg-gradient-to-r from-blue-50/80 to-blue-100/80 dark:from-blue-950/30 dark:to-blue-900/30">
              <CheckCircle2 className="h-4 w-4 text-blue-600 dark:text-blue-400" />
              <AlertDescription className="text-blue-700 dark:text-blue-300 font-medium">
                Bank details updated successfully!
              </AlertDescription>
            </Alert>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Verification status */}
      {!hasCompleteDetails && (
        <Alert variant="default" className="border-amber-500/50 bg-gradient-to-r from-amber-50/80 to-orange-50/80 dark:from-amber-950/30 dark:to-orange-950/30">
          <AlertTriangle className="h-4 w-4 text-amber-600 dark:text-amber-400" />
          <AlertTitle className="text-amber-700 dark:text-amber-300 font-semibold">Incomplete Bank Details</AlertTitle>
          <AlertDescription className="text-amber-600 dark:text-amber-400">
            Add your bank details to receive payouts. This is required for withdrawing earnings.
          </AlertDescription>
        </Alert>
      )}

      <div className="grid gap-6 xl:grid-cols-2">
        {/* Bank details card */}
        <Card className="w-full max-w-full overflow-hidden border-blue-200/60 dark:border-blue-800/40 bg-gradient-to-br from-white via-blue-50/30 to-white dark:from-gray-900 dark:via-blue-950/20 dark:to-gray-900 shadow-xl shadow-blue-500/5">
          <CardHeader className="p-6 pb-4">
            <div className="flex items-center justify-between gap-3 flex-wrap">
              <div className="flex items-center gap-3 flex-1 min-w-0">
                <div className="p-2.5 flex-shrink-0 rounded-xl bg-gradient-to-br from-blue-500 to-blue-600 shadow-lg shadow-blue-500/30">
                  <Building2 className="h-5 w-5 text-white" />
                </div>
                <div className="flex-1 min-w-0">
                  <CardTitle className="text-lg bg-gradient-to-r from-blue-600 to-blue-800 dark:from-blue-400 dark:to-blue-300 bg-clip-text text-transparent truncate">
                    Bank Account
                  </CardTitle>
                  <CardDescription className="text-sm truncate">Your primary payout account</CardDescription>
                </div>
              </div>
              {hasCompleteDetails && (
                <Badge className="gap-1.5 bg-gradient-to-r from-blue-500 to-blue-600 text-white border-0 shadow-lg shadow-blue-500/30 px-3 py-1">
                  <BadgeCheck className="h-3.5 w-3.5" />
                  Verified
                </Badge>
              )}
            </div>
          </CardHeader>
          <CardContent className="p-6 space-y-4">
            {hasCompleteDetails ? (
              <div className="w-full space-y-4">
                <div className="flex items-center justify-between p-4 rounded-xl bg-gradient-to-br from-blue-50/80 to-blue-100/40 dark:from-blue-950/40 dark:to-blue-900/20 border border-blue-200/40 dark:border-blue-800/30">
                  <div>
                    <p className="text-xs font-medium text-blue-600 dark:text-blue-400 mb-1 uppercase tracking-wide">Account Holder</p>
                    <p className="font-semibold text-gray-900 dark:text-gray-100">{doer.bank_account_name}</p>
                  </div>
                </div>

                <div className="flex items-center justify-between p-4 rounded-xl bg-gradient-to-br from-blue-50/80 to-blue-100/40 dark:from-blue-950/40 dark:to-blue-900/20 border border-blue-200/40 dark:border-blue-800/30 group">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <Lock className="h-3 w-3 text-blue-600 dark:text-blue-400" />
                      <p className="text-xs font-medium text-blue-600 dark:text-blue-400 uppercase tracking-wide">Account Number</p>
                    </div>
                    <p className="font-mono font-semibold text-gray-900 dark:text-gray-100 tracking-wider">
                      {showAccountNumber
                        ? doer.bank_account_number
                        : maskAccountNumber(doer.bank_account_number || '')}
                    </p>
                  </div>
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={() => setShowAccountNumber(!showAccountNumber)}
                    className="hover:bg-blue-100 dark:hover:bg-blue-900/50 transition-colors"
                  >
                    {showAccountNumber ? (
                      <EyeOff className="h-4 w-4 text-blue-600 dark:text-blue-400" />
                    ) : (
                      <Eye className="h-4 w-4 text-blue-600 dark:text-blue-400" />
                    )}
                  </Button>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div className="p-4 rounded-xl bg-gradient-to-br from-blue-50/80 to-blue-100/40 dark:from-blue-950/40 dark:to-blue-900/20 border border-blue-200/40 dark:border-blue-800/30">
                    <p className="text-xs font-medium text-blue-600 dark:text-blue-400 mb-1 uppercase tracking-wide">IFSC Code</p>
                    <p className="font-mono font-semibold text-gray-900 dark:text-gray-100 text-sm">{doer.bank_ifsc_code}</p>
                  </div>
                  <div className="p-4 rounded-xl bg-gradient-to-br from-blue-50/80 to-blue-100/40 dark:from-blue-950/40 dark:to-blue-900/20 border border-blue-200/40 dark:border-blue-800/30">
                    <p className="text-xs font-medium text-blue-600 dark:text-blue-400 mb-1 uppercase tracking-wide">Bank</p>
                    <p className="font-semibold text-gray-900 dark:text-gray-100 text-sm truncate">{doer.bank_name || 'N/A'}</p>
                  </div>
                </div>

                <Button
                  variant="outline"
                  onClick={() => setIsEditing(true)}
                  className="w-full gap-2 border-blue-300 dark:border-blue-700 hover:bg-blue-50 dark:hover:bg-blue-950/30 text-blue-700 dark:text-blue-300 font-medium transition-all hover:shadow-md hover:shadow-blue-500/10"
                >
                  <Edit2 className="h-4 w-4" />
                  Update Bank Details
                </Button>
              </div>
            ) : (
              <div className="text-center py-8">
                <div className="w-20 h-20 mx-auto mb-4 rounded-2xl bg-gradient-to-br from-blue-100 to-blue-200 dark:from-blue-900/30 dark:to-blue-800/30 flex items-center justify-center">
                  <CreditCard className="h-10 w-10 text-blue-600 dark:text-blue-400" />
                </div>
                <p className="text-gray-600 dark:text-gray-400 mb-6 font-medium">
                  No bank account linked yet
                </p>
                <Button
                  onClick={() => setIsEditing(true)}
                  className="gap-2 bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white shadow-lg shadow-blue-500/30 transition-all hover:shadow-xl hover:shadow-blue-500/40"
                >
                  <Building2 className="h-4 w-4" />
                  Add Bank Account
                </Button>
              </div>
            )}
          </CardContent>
        </Card>

        {/* UPI card */}
        <Card className="w-full max-w-full overflow-hidden border-blue-200/60 dark:border-blue-800/40 bg-gradient-to-br from-white via-blue-50/30 to-white dark:from-gray-900 dark:via-blue-950/20 dark:to-gray-900 shadow-xl shadow-blue-500/5">
          <CardHeader className="p-6 pb-4">
            <div className="flex items-center gap-3">
              <div className="p-2.5 flex-shrink-0 rounded-xl bg-gradient-to-br from-blue-500 to-blue-600 shadow-lg shadow-blue-500/30">
                <Smartphone className="h-5 w-5 text-white" />
              </div>
              <div className="flex-1 min-w-0">
                <CardTitle className="text-lg bg-gradient-to-r from-blue-600 to-blue-800 dark:from-blue-400 dark:to-blue-300 bg-clip-text text-transparent truncate">
                  UPI ID
                </CardTitle>
                <CardDescription className="text-sm truncate">Alternative payment method</CardDescription>
              </div>
            </div>
          </CardHeader>
          <CardContent className="p-6">
            {doer.upi_id ? (
              <div className="flex items-center justify-between p-4 rounded-xl bg-gradient-to-br from-blue-50/80 to-blue-100/40 dark:from-blue-950/40 dark:to-blue-900/20 border border-blue-200/40 dark:border-blue-800/30">
                <div>
                  <p className="text-xs font-medium text-blue-600 dark:text-blue-400 mb-1 uppercase tracking-wide">UPI ID</p>
                  <p className="font-semibold text-gray-900 dark:text-gray-100">{doer.upi_id}</p>
                </div>
                <Badge className="gap-1.5 bg-gradient-to-r from-blue-500 to-blue-600 text-white border-0 shadow-lg shadow-blue-500/30 px-3 py-1">
                  <CheckCircle2 className="h-3.5 w-3.5" />
                  Active
                </Badge>
              </div>
            ) : (
              <div className="text-center py-8">
                <div className="w-16 h-16 mx-auto mb-4 rounded-2xl bg-gradient-to-br from-blue-100 to-blue-200 dark:from-blue-900/30 dark:to-blue-800/30 flex items-center justify-center">
                  <Smartphone className="h-8 w-8 text-blue-600 dark:text-blue-400" />
                </div>
                <p className="text-sm text-gray-600 dark:text-gray-400 font-medium">
                  No UPI ID added (optional)
                </p>
              </div>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Edit dialog */}
      <Dialog open={isEditing} onOpenChange={setIsEditing}>
        <DialogContent className="sm:max-w-md border-blue-200 dark:border-blue-800">
          <DialogHeader>
            <div className="flex items-center gap-3 mb-2">
              <div className="p-2 rounded-lg bg-gradient-to-br from-blue-500 to-blue-600 shadow-lg shadow-blue-500/30">
                <Building2 className="h-5 w-5 text-white" />
              </div>
              <DialogTitle className="text-xl bg-gradient-to-r from-blue-600 to-blue-800 dark:from-blue-400 dark:to-blue-300 bg-clip-text text-transparent">
                {hasCompleteDetails ? 'Update Bank Details' : 'Add Bank Account'}
              </DialogTitle>
            </div>
            <DialogDescription className="text-sm">
              Enter your bank account details for receiving payouts
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-4 py-4">
            {error && (
              <Alert variant="destructive" className="border-red-300 dark:border-red-800">
                <AlertTriangle className="h-4 w-4" />
                <AlertDescription>{error}</AlertDescription>
              </Alert>
            )}

            <div className="space-y-2">
              <Label htmlFor="bank_account_name" className="text-sm font-semibold text-gray-700 dark:text-gray-300">
                Account Holder Name
              </Label>
              <Input
                id="bank_account_name"
                value={formData.bank_account_name}
                onChange={(e) => handleChange('bank_account_name', e.target.value)}
                placeholder="As per bank records"
                className="border-blue-200 dark:border-blue-800 focus:border-blue-500 focus:ring-blue-500/20 bg-blue-50/30 dark:bg-blue-950/20"
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="bank_account_number" className="text-sm font-semibold text-gray-700 dark:text-gray-300 flex items-center gap-2">
                <Lock className="h-3.5 w-3.5 text-blue-600 dark:text-blue-400" />
                Account Number
              </Label>
              <Input
                id="bank_account_number"
                value={formData.bank_account_number}
                onChange={(e) => handleChange('bank_account_number', e.target.value)}
                placeholder="Enter account number"
                type="text"
                inputMode="numeric"
                className="border-blue-200 dark:border-blue-800 focus:border-blue-500 focus:ring-blue-500/20 bg-blue-50/30 dark:bg-blue-950/20 font-mono"
              />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="bank_ifsc_code" className="text-sm font-semibold text-gray-700 dark:text-gray-300">
                  IFSC Code
                </Label>
                <Input
                  id="bank_ifsc_code"
                  value={formData.bank_ifsc_code}
                  onChange={(e) => {
                    const value = e.target.value.toUpperCase()
                    handleChange('bank_ifsc_code', value)
                    if (value.length === 11) {
                      fetchBankName(value)
                    }
                  }}
                  placeholder="e.g., SBIN0001234"
                  maxLength={11}
                  className="uppercase border-blue-200 dark:border-blue-800 focus:border-blue-500 focus:ring-blue-500/20 bg-blue-50/30 dark:bg-blue-950/20 font-mono"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="bank_name" className="text-sm font-semibold text-gray-700 dark:text-gray-300">
                  Bank Name
                </Label>
                <Input
                  id="bank_name"
                  value={formData.bank_name}
                  onChange={(e) => handleChange('bank_name', e.target.value)}
                  placeholder="Auto-detected"
                  readOnly
                  className="bg-blue-100/50 dark:bg-blue-900/30 border-blue-200 dark:border-blue-800"
                />
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="upi_id" className="text-sm font-semibold text-gray-700 dark:text-gray-300">
                UPI ID (Optional)
              </Label>
              <Input
                id="upi_id"
                value={formData.upi_id}
                onChange={(e) => handleChange('upi_id', e.target.value)}
                placeholder="yourname@upi"
                className="border-blue-200 dark:border-blue-800 focus:border-blue-500 focus:ring-blue-500/20 bg-blue-50/30 dark:bg-blue-950/20"
              />
            </div>
          </div>

          <DialogFooter className="gap-2 sm:gap-2">
            <Button
              variant="outline"
              onClick={() => setIsEditing(false)}
              className="border-blue-300 dark:border-blue-700 hover:bg-blue-50 dark:hover:bg-blue-950/30 text-blue-700 dark:text-blue-300"
            >
              Cancel
            </Button>
            <Button
              onClick={handleSave}
              disabled={isSaving}
              className="gap-2 bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white shadow-lg shadow-blue-500/30 transition-all hover:shadow-xl hover:shadow-blue-500/40"
            >
              {isSaving ? (
                <>
                  <Loader2 className="h-4 w-4 animate-spin" />
                  Saving...
                </>
              ) : (
                <>
                  <Save className="h-4 w-4" />
                  Save Details
                </>
              )}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
