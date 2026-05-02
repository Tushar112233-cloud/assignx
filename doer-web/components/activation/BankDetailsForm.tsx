'use client'

import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import * as z from 'zod'
import { motion } from 'framer-motion'
import { CreditCard, Building2, CheckCircle2, Loader2, Info } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Alert, AlertDescription } from '@/components/ui/alert'
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form'
import { IFSC_REGEX, UPI_REGEX } from '@/lib/constants'

/** Form validation schema */
const bankDetailsSchema = z.object({
  accountHolderName: z
    .string()
    .min(2, 'Name must be at least 2 characters')
    .max(100, 'Name is too long')
    .regex(/^[a-zA-Z\s]+$/, 'Name can only contain letters and spaces'),
  accountNumber: z
    .string()
    .min(9, 'Account number must be at least 9 digits')
    .max(18, 'Account number is too long')
    .regex(/^\d+$/, 'Account number must contain only digits'),
  confirmAccountNumber: z
    .string()
    .min(9, 'Please confirm your account number'),
  ifscCode: z
    .string()
    .length(11, 'IFSC code must be exactly 11 characters')
    .regex(IFSC_REGEX, 'Invalid IFSC code format (e.g., SBIN0001234)'),
  upiId: z
    .string()
    .regex(UPI_REGEX, 'Invalid UPI ID format (e.g., name@upi)')
    .optional()
    .or(z.literal('')),
}).refine((data) => data.accountNumber === data.confirmAccountNumber, {
  message: 'Account numbers do not match',
  path: ['confirmAccountNumber'],
})

type BankDetailsFormData = z.infer<typeof bankDetailsSchema>

interface BankDetailsFormProps {
  /** Callback when form is submitted successfully */
  onComplete: (data: BankDetailsFormData) => void
  /** Initial form values */
  defaultValues?: Partial<BankDetailsFormData>
}

/**
 * Bank details form component
 * Collects bank account information for payouts
 */
export function BankDetailsForm({
  onComplete,
  defaultValues,
}: BankDetailsFormProps) {
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [bankName, setBankName] = useState<string | null>(null)
  const [isValidatingIfsc, setIsValidatingIfsc] = useState(false)

  const form = useForm<BankDetailsFormData>({
    resolver: zodResolver(bankDetailsSchema),
    defaultValues: {
      accountHolderName: defaultValues?.accountHolderName || '',
      accountNumber: defaultValues?.accountNumber || '',
      confirmAccountNumber: defaultValues?.confirmAccountNumber || '',
      ifscCode: defaultValues?.ifscCode || '',
      upiId: defaultValues?.upiId || '',
    },
  })

  /** Validate IFSC and fetch bank name */
  const validateIfsc = async (ifscCode: string) => {
    if (!IFSC_REGEX.test(ifscCode)) {
      setBankName(null)
      return
    }

    setIsValidatingIfsc(true)
    try {
      // TODO: Integrate with actual IFSC API
      // For demo, we'll simulate API call
      await new Promise(resolve => setTimeout(resolve, 500))

      // Mock bank names based on first 4 characters
      const bankCodes: Record<string, string> = {
        'SBIN': 'State Bank of India',
        'HDFC': 'HDFC Bank',
        'ICIC': 'ICICI Bank',
        'PUNB': 'Punjab National Bank',
        'BARB': 'Bank of Baroda',
        'UTIB': 'Axis Bank',
        'KKBK': 'Kotak Mahindra Bank',
      }

      const prefix = ifscCode.substring(0, 4).toUpperCase()
      setBankName(bankCodes[prefix] || 'Unknown Bank')
    } catch {
      setBankName(null)
    } finally {
      setIsValidatingIfsc(false)
    }
  }

  /** Handle form submission */
  const onSubmit = async (data: BankDetailsFormData) => {
    setIsSubmitting(true)
    try {
      // TODO: Submit to backend
      await new Promise(resolve => setTimeout(resolve, 1000))
      onComplete(data)
    } catch (error) {
      console.error('Failed to submit bank details:', error)
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <div className="max-w-lg mx-auto space-y-6">
      {/* Header */}
      <div className="text-center space-y-2">
        <h1 className="text-2xl font-bold">Bank Details</h1>
        <p className="text-muted-foreground">
          Add your bank account for receiving payments
        </p>
      </div>

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
      >
        <Card>
          <CardHeader>
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center">
                <CreditCard className="w-5 h-5 text-primary" />
              </div>
              <div>
                <CardTitle className="text-lg">Payment Information</CardTitle>
                <CardDescription>
                  Your earnings will be transferred to this account
                </CardDescription>
              </div>
            </div>
          </CardHeader>

          <Form {...form}>
            <form onSubmit={form.handleSubmit(onSubmit)}>
              <CardContent className="space-y-4">
                {/* Account Holder Name */}
                <FormField
                  control={form.control}
                  name="accountHolderName"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Account Holder Name</FormLabel>
                      <FormControl>
                        <Input
                          placeholder="Enter name as per bank records"
                          {...field}
                        />
                      </FormControl>
                      <FormDescription>
                        Name should match exactly with your bank account
                      </FormDescription>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                {/* Account Number */}
                <FormField
                  control={form.control}
                  name="accountNumber"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Account Number</FormLabel>
                      <FormControl>
                        <Input
                          type="password"
                          placeholder="Enter account number"
                          {...field}
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                {/* Confirm Account Number */}
                <FormField
                  control={form.control}
                  name="confirmAccountNumber"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Confirm Account Number</FormLabel>
                      <FormControl>
                        <Input
                          placeholder="Re-enter account number"
                          {...field}
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                {/* IFSC Code */}
                <FormField
                  control={form.control}
                  name="ifscCode"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>IFSC Code</FormLabel>
                      <FormControl>
                        <div className="relative">
                          <Input
                            placeholder="e.g., SBIN0001234"
                            {...field}
                            onChange={(e) => {
                              const value = e.target.value.toUpperCase()
                              field.onChange(value)
                              if (value.length === 11) {
                                validateIfsc(value)
                              } else {
                                setBankName(null)
                              }
                            }}
                            className="uppercase"
                          />
                          {isValidatingIfsc && (
                            <Loader2 className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 animate-spin text-muted-foreground" />
                          )}
                        </div>
                      </FormControl>
                      {bankName && (
                        <div className="flex items-center gap-2 text-sm text-green-600">
                          <Building2 className="w-4 h-4" />
                          <span>{bankName}</span>
                        </div>
                      )}
                      <FormMessage />
                    </FormItem>
                  )}
                />

                {/* UPI ID */}
                <FormField
                  control={form.control}
                  name="upiId"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>
                        UPI ID
                        <span className="text-muted-foreground font-normal ml-1">
                          (Optional)
                        </span>
                      </FormLabel>
                      <FormControl>
                        <Input
                          placeholder="e.g., yourname@upi"
                          {...field}
                        />
                      </FormControl>
                      <FormDescription>
                        Recommended for faster payments
                      </FormDescription>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                {/* Security notice */}
                <Alert>
                  <Info className="h-4 w-4" />
                  <AlertDescription>
                    Your bank details are encrypted and stored securely. We never share
                    your financial information with third parties.
                  </AlertDescription>
                </Alert>
              </CardContent>

              <CardFooter>
                <Button
                  type="submit"
                  className="w-full"
                  size="lg"
                  disabled={isSubmitting}
                >
                  {isSubmitting ? (
                    <>
                      <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                      Saving...
                    </>
                  ) : (
                    <>
                      <CheckCircle2 className="w-4 h-4 mr-2" />
                      Complete Setup
                    </>
                  )}
                </Button>
              </CardFooter>
            </form>
          </Form>
        </Card>
      </motion.div>
    </div>
  )
}
