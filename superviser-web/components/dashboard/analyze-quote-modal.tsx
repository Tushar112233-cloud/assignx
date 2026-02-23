/**
 * @fileoverview Modal for analyzing and creating quotes for project requests.
 * @module components/dashboard/analyze-quote-modal
 */

"use client"

import { useState, useEffect } from "react"
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import { format } from "date-fns"
import {
  Calculator,
  FileText,
  Clock,
  User,
  Download,
  Loader2,
  CheckCircle2,
  Info,
  IndianRupee,
  Globe2,
} from "lucide-react"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Badge } from "@/components/ui/badge"
import { Separator } from "@/components/ui/separator"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form"
import { ScrollArea } from "@/components/ui/scroll-area"
import { toast } from "sonner"
import { submitQuoteAction } from "@/app/actions/quote"
import { getExchangeRate } from "@/app/actions/exchange-rate"
import type { ProjectRequest } from "./request-card"

const CURRENCIES = [
  { code: "INR", name: "Indian Rupee", symbol: "₹", flag: "🇮🇳" },
  { code: "USD", name: "US Dollar", symbol: "$", flag: "🇺🇸" },
  { code: "CAD", name: "Canadian Dollar", symbol: "CA$", flag: "🇨🇦" },
  { code: "GBP", name: "British Pound", symbol: "£", flag: "🇬🇧" },
  { code: "EUR", name: "Euro", symbol: "€", flag: "🇪🇺" },
  { code: "AED", name: "UAE Dirham", symbol: "د.إ", flag: "🇦🇪" },
  { code: "AUD", name: "Australian Dollar", symbol: "A$", flag: "🇦🇺" },
  { code: "SGD", name: "Singapore Dollar", symbol: "S$", flag: "🇸🇬" },
]

const quoteFormSchema = z.object({
  userQuote: z.number().min(100, "Minimum quote is ₹100").max(100000, "Maximum quote is ₹1,00,000"),
  doerPayout: z.number().min(50, "Minimum payout is ₹50"),
  notes: z.string().optional(),
})

type QuoteFormData = z.infer<typeof quoteFormSchema>

interface AnalyzeQuoteModalProps {
  request: ProjectRequest | null
  isOpen: boolean
  onClose: () => void
  onQuoteSubmit: (requestId: string, data: QuoteFormData) => void
}

interface PricingGuide {
  base_price_per_word: number
  base_price_per_page: number
  urgency_24h_multiplier: number
  urgency_48h_multiplier: number
  urgency_72h_multiplier: number
  complexity_medium_multiplier: number
  complexity_hard_multiplier: number
  supervisor_percentage: number
  platform_percentage: number
}

const DEFAULT_PRICING: PricingGuide = {
  base_price_per_word: 0.5,
  base_price_per_page: 150,
  urgency_24h_multiplier: 1.5,
  urgency_48h_multiplier: 1.3,
  urgency_72h_multiplier: 1.15,
  complexity_medium_multiplier: 1.2,
  complexity_hard_multiplier: 1.5,
  supervisor_percentage: 15,
  platform_percentage: 20,
}

export function AnalyzeQuoteModal({
  request,
  isOpen,
  onClose,
  onQuoteSubmit,
}: AnalyzeQuoteModalProps) {
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [suggestedQuote, setSuggestedQuote] = useState(0)
  const [selectedCurrency, setSelectedCurrency] = useState("INR")
  const [exchangeRate, setExchangeRate] = useState(1)
  const [isLoadingRate, setIsLoadingRate] = useState(false)
  const [foreignAmount, setForeignAmount] = useState(0)
  const pricing = DEFAULT_PRICING

  const form = useForm<QuoteFormData>({
    resolver: zodResolver(quoteFormSchema),
    defaultValues: {
      userQuote: 0,
      doerPayout: 0,
      notes: "",
    },
  })

  useEffect(() => {
    if (request && isOpen) {
      calculateSuggestedQuote()
    }
  }, [request, isOpen])

  // Reset currency state when modal opens/closes
  useEffect(() => {
    if (!isOpen) {
      setSelectedCurrency("INR")
      setExchangeRate(1)
      setForeignAmount(0)
    }
  }, [isOpen])

  // Fetch live exchange rate whenever the selected currency changes
  useEffect(() => {
    async function fetchRate() {
      if (selectedCurrency === "INR") {
        setExchangeRate(1)
        setForeignAmount(0)
        return
      }
      setIsLoadingRate(true)
      const result = await getExchangeRate(selectedCurrency)
      if (result.success && result.rate) {
        setExchangeRate(result.rate)
      } else {
        toast.error("Could not fetch exchange rate. Using fallback rate.")
      }
      setIsLoadingRate(false)
    }
    fetchRate()
  }, [selectedCurrency])

  const calculateSuggestedQuote = () => {
    if (!request) return

    let basePrice = 0
    if (request.word_count) {
      basePrice = request.word_count * pricing.base_price_per_word
    } else if (request.page_count) {
      basePrice = request.page_count * pricing.base_price_per_page
    } else {
      basePrice = 500 // Default minimum
    }

    // Apply urgency multiplier
    const deadline = new Date(request.deadline)
    const hoursUntilDeadline = Math.max(
      0,
      (deadline.getTime() - Date.now()) / (1000 * 60 * 60)
    )

    let urgencyMultiplier = 1
    if (hoursUntilDeadline <= 24) {
      urgencyMultiplier = pricing.urgency_24h_multiplier
    } else if (hoursUntilDeadline <= 48) {
      urgencyMultiplier = pricing.urgency_48h_multiplier
    } else if (hoursUntilDeadline <= 72) {
      urgencyMultiplier = pricing.urgency_72h_multiplier
    }

    const suggested = Math.ceil(basePrice * urgencyMultiplier)
    const doerPayout = Math.ceil(
      suggested * (1 - (pricing.supervisor_percentage + pricing.platform_percentage) / 100)
    )

    setSuggestedQuote(suggested)
    form.setValue("userQuote", suggested)
    form.setValue("doerPayout", doerPayout)
  }

  // Called when the INR quote field is edited directly
  const handleQuoteChange = (value: number) => {
    form.setValue("userQuote", value)
    const doerPayout = Math.ceil(
      value * (1 - (pricing.supervisor_percentage + pricing.platform_percentage) / 100)
    )
    form.setValue("doerPayout", doerPayout)
  }

  // Called when the foreign-currency amount input changes
  const handleForeignAmountChange = (value: number) => {
    setForeignAmount(value)
    const inrAmount = Math.ceil(value * exchangeRate)
    form.setValue("userQuote", inrAmount)
    const doerPayout = Math.ceil(
      inrAmount * (1 - (pricing.supervisor_percentage + pricing.platform_percentage) / 100)
    )
    form.setValue("doerPayout", doerPayout)
  }

  const onSubmit = async (data: QuoteFormData) => {
    if (!request) return

    setIsSubmitting(true)
    try {
      // Calculate amounts
      const supervisorCommission = Math.ceil((data.userQuote * pricing.supervisor_percentage) / 100)
      const platformFee = Math.ceil((data.userQuote * pricing.platform_percentage) / 100)

      // Use server action to submit quote (bypasses RLS)
      const result = await submitQuoteAction({
        projectId: request.id,
        userQuote: data.userQuote,
        doerPayout: data.doerPayout,
        supervisorCommission,
        platformFee,
      })

      if (!result.success) {
        toast.error(result.error || "Failed to submit quote")
        return
      }

      toast.success("Quote submitted successfully")
      onQuoteSubmit(request.id, data)
      onClose()
    } catch (error) {
      console.error("Error submitting quote:", error)
      toast.error("Failed to submit quote")
    } finally {
      setIsSubmitting(false)
    }
  }

  const supervisorEarning = form.watch("userQuote")
    ? Math.ceil((form.watch("userQuote") * pricing.supervisor_percentage) / 100)
    : 0

  const activeCurrency = CURRENCIES.find((c) => c.code === selectedCurrency)

  if (!request) return null

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="max-w-3xl max-h-[90vh] p-0 bg-white">
        <DialogHeader className="p-6 pb-4 border-b border-gray-200 bg-white">
          <DialogTitle className="flex items-center gap-3 text-2xl font-bold text-[#1C1C1C]">
            <div className="h-10 w-10 rounded-xl bg-orange-100 flex items-center justify-center">
              <Calculator className="h-5 w-5 text-[#F97316]" />
            </div>
            Analyze &amp; Set Quote
          </DialogTitle>
          <DialogDescription className="text-gray-600 mt-2">
            Review the project requirements and set the client quote
          </DialogDescription>
        </DialogHeader>

        <ScrollArea className="max-h-[60vh] p-6">
          <div className="space-y-4">
            {/* Project Info Section */}
            <div className="bg-white rounded-xl border border-gray-200 p-4 shadow-sm">
              <div className="flex items-start justify-between mb-3">
                <div className="flex-1">
                  <Badge variant="outline" className="mb-1.5 font-mono text-xs bg-gray-100 text-gray-700 border-gray-300">
                    #{request.project_number}
                  </Badge>
                  <h3 className="font-bold text-lg text-[#1C1C1C]">{request.title}</h3>
                  <p className="text-sm text-gray-600 mt-0.5">
                    {request.subject}
                  </p>
                </div>
                <Button variant="outline" size="sm" className="rounded-full border-gray-200 shrink-0">
                  <Download className="h-4 w-4 mr-2" />
                  Files
                </Button>
              </div>

              <div className="border-t border-gray-200 my-3" />

              <div className="grid grid-cols-2 gap-3 text-sm">
                <div className="flex items-center gap-2">
                  <div className="h-8 w-8 rounded-lg bg-blue-100 flex items-center justify-center flex-shrink-0">
                    <User className="h-4 w-4 text-blue-600" />
                  </div>
                  <div>
                    <p className="text-xs text-gray-500">Client</p>
                    <p className="font-semibold text-[#1C1C1C]">{request.user_name}</p>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <div className="h-8 w-8 rounded-lg bg-orange-100 flex items-center justify-center flex-shrink-0">
                    <Clock className="h-4 w-4 text-[#F97316]" />
                  </div>
                  <div>
                    <p className="text-xs text-gray-500">Deadline</p>
                    <p className="font-semibold text-[#1C1C1C]">
                      {format(new Date(request.deadline), "PPp")}
                    </p>
                  </div>
                </div>
                {request.word_count && (
                  <div className="flex items-center gap-2">
                    <div className="h-8 w-8 rounded-lg bg-purple-100 flex items-center justify-center flex-shrink-0">
                      <FileText className="h-4 w-4 text-purple-600" />
                    </div>
                    <div>
                      <p className="text-xs text-gray-500">Words</p>
                      <p className="font-semibold text-[#1C1C1C]">
                        {request.word_count.toLocaleString()}
                      </p>
                    </div>
                  </div>
                )}
                {request.page_count && (
                  <div className="flex items-center gap-2">
                    <div className="h-8 w-8 rounded-lg bg-green-100 flex items-center justify-center flex-shrink-0">
                      <FileText className="h-4 w-4 text-green-600" />
                    </div>
                    <div>
                      <p className="text-xs text-gray-500">Pages</p>
                      <p className="font-semibold text-[#1C1C1C]">{request.page_count}</p>
                    </div>
                  </div>
                )}
              </div>
            </div>

            {/* Suggested Quote */}
            <div className="bg-gradient-to-br from-orange-50 to-amber-50 rounded-xl border border-orange-200 p-4 shadow-sm">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="h-10 w-10 rounded-xl bg-orange-100 flex items-center justify-center">
                    <Info className="h-5 w-5 text-[#F97316]" />
                  </div>
                  <div>
                    <p className="text-sm font-semibold text-[#1C1C1C]">Suggested Quote</p>
                    <p className="text-xs text-gray-600 mt-0.5">
                      Based on word count, deadline, and pricing guidelines
                    </p>
                  </div>
                </div>
                <div className="text-right">
                  <div className="text-3xl font-bold text-[#F97316]">
                    ₹{suggestedQuote.toLocaleString("en-IN")}
                  </div>
                  {selectedCurrency !== "INR" && suggestedQuote > 0 && (
                    <div className="text-sm text-blue-600 font-medium mt-0.5">
                      ≈ {activeCurrency?.symbol}
                      {(suggestedQuote / exchangeRate).toFixed(2)} {selectedCurrency}
                    </div>
                  )}
                </div>
              </div>
            </div>

            {/* Quote Form */}
            <Form {...form}>
              <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
                <div className="bg-white rounded-xl border border-gray-200 p-4 shadow-sm">

                  {/* Currency Selector */}
                  <div className="mb-4">
                    <label className="text-sm font-semibold text-[#1C1C1C] flex items-center gap-2 mb-2">
                      <Globe2 className="h-4 w-4 text-blue-500" />
                      User&apos;s Currency
                      {isLoadingRate && (
                        <span className="text-xs text-gray-400 font-normal">(fetching rate...)</span>
                      )}
                    </label>
                    <Select value={selectedCurrency} onValueChange={setSelectedCurrency}>
                      <SelectTrigger className="border-gray-200 rounded-lg">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        {CURRENCIES.map((c) => (
                          <SelectItem key={c.code} value={c.code}>
                            {c.flag} {c.code} - {c.name} ({c.symbol})
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    {selectedCurrency !== "INR" && (
                      <p className="text-xs text-blue-600 mt-1">
                        Live rate: 1 {selectedCurrency} = ₹{exchangeRate.toFixed(2)}
                      </p>
                    )}
                  </div>

                  {/* Foreign amount input shown only when a non-INR currency is selected */}
                  {selectedCurrency !== "INR" && (
                    <div className="mb-4">
                      <label className="text-sm font-semibold text-[#1C1C1C] mb-2 block">
                        Client Quote ({activeCurrency?.symbol})
                      </label>
                      <div className="relative">
                        <span className="absolute left-3 top-1/2 -translate-y-1/2 text-sm text-gray-400 pointer-events-none">
                          {activeCurrency?.symbol}
                        </span>
                        <input
                          type="number"
                          value={foreignAmount || ""}
                          onChange={(e) =>
                            handleForeignAmountChange(parseFloat(e.target.value) || 0)
                          }
                          placeholder={`Amount in ${selectedCurrency}`}
                          className="w-full pl-9 pr-3 py-2 border border-gray-200 rounded-lg text-sm focus:border-orange-300 focus:ring-1 focus:ring-orange-200 focus:outline-none"
                        />
                      </div>
                      {foreignAmount > 0 && (
                        <p className="text-xs text-emerald-600 mt-1 font-medium">
                          ≈ ₹{Math.ceil(foreignAmount * exchangeRate).toLocaleString("en-IN")} (stored in INR)
                        </p>
                      )}
                    </div>
                  )}

                  <div className="grid grid-cols-2 gap-4">
                    <FormField
                      control={form.control}
                      name="userQuote"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel className="text-sm font-semibold text-[#1C1C1C]">
                            {selectedCurrency !== "INR"
                              ? "Client Quote (₹ — stored amount)"
                              : "Client Quote (₹)"}
                          </FormLabel>
                          <FormControl>
                            <div className="relative">
                              <IndianRupee className="absolute left-3 top-3 h-4 w-4 text-gray-400" />
                              <Input
                                type="number"
                                placeholder="Enter quote amount"
                                className="pl-9 border-gray-200 focus:border-orange-300 focus:ring-orange-200 rounded-lg"
                                readOnly={selectedCurrency !== "INR"}
                                {...field}
                                onChange={(e) =>
                                  selectedCurrency === "INR"
                                    ? handleQuoteChange(parseInt(e.target.value) || 0)
                                    : undefined
                                }
                              />
                            </div>
                          </FormControl>
                          <FormDescription className="text-xs text-gray-500">
                            {selectedCurrency !== "INR"
                              ? "Auto-converted from " + selectedCurrency
                              : "Amount client will pay"}
                          </FormDescription>
                          <FormMessage />
                        </FormItem>
                      )}
                    />

                    <FormField
                      control={form.control}
                      name="doerPayout"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel className="text-sm font-semibold text-[#1C1C1C]">Doer Payout (₹)</FormLabel>
                          <FormControl>
                            <div className="relative">
                              <IndianRupee className="absolute left-3 top-3 h-4 w-4 text-gray-400" />
                              <Input
                                type="number"
                                placeholder="Enter payout amount"
                                className="pl-9 border-gray-200 focus:border-orange-300 focus:ring-orange-200 rounded-lg"
                                {...field}
                                onChange={(e) =>
                                  field.onChange(parseInt(e.target.value) || 0)
                                }
                              />
                            </div>
                          </FormControl>
                          <FormDescription className="text-xs text-gray-500">
                            Amount doer will receive
                          </FormDescription>
                          <FormMessage />
                        </FormItem>
                      )}
                    />
                  </div>
                </div>

                {/* Earnings Breakdown */}
                <div className="bg-white rounded-xl border border-gray-200 p-4 shadow-sm">
                  <h4 className="text-sm font-semibold text-[#1C1C1C] mb-3 flex items-center gap-2">
                    <div className="h-8 w-8 rounded-lg bg-purple-100 flex items-center justify-center">
                      <Calculator className="h-4 w-4 text-purple-600" />
                    </div>
                    Earnings Breakdown
                  </h4>
                  <div className="space-y-2 text-sm">
                    <div className="flex justify-between items-center py-1.5">
                      <span className="text-gray-600">Client Quote</span>
                      <div className="text-right">
                        <span className="font-semibold text-[#1C1C1C]">
                          ₹{form.watch("userQuote")?.toLocaleString("en-IN") || 0}
                        </span>
                        {selectedCurrency !== "INR" && foreignAmount > 0 && (
                          <span className="block text-xs text-blue-600">
                            {activeCurrency?.symbol}
                            {foreignAmount.toLocaleString()} {selectedCurrency}
                          </span>
                        )}
                      </div>
                    </div>
                    <Separator className="bg-gray-200" />
                    <div className="flex justify-between items-center py-1.5">
                      <span className="text-gray-600">
                        Doer Payout ({100 - pricing.supervisor_percentage - pricing.platform_percentage}%)
                      </span>
                      <span className="font-semibold text-red-600">
                        -₹{form.watch("doerPayout")?.toLocaleString("en-IN") || 0}
                      </span>
                    </div>
                    <div className="flex justify-between items-center py-1.5">
                      <span className="text-gray-600">
                        Platform Fee ({pricing.platform_percentage}%)
                      </span>
                      <span className="font-semibold text-red-600">
                        -₹
                        {Math.ceil(
                          (form.watch("userQuote") * pricing.platform_percentage) / 100
                        ).toLocaleString("en-IN") || 0}
                      </span>
                    </div>
                    <Separator className="bg-gray-200" />
                    <div className="flex justify-between items-center py-2 px-3 bg-emerald-50 rounded-lg border border-emerald-200">
                      <span className="font-semibold text-emerald-700">Your Commission ({pricing.supervisor_percentage}%)</span>
                      <span className="text-lg font-bold text-emerald-600">₹{supervisorEarning.toLocaleString("en-IN")}</span>
                    </div>
                  </div>
                </div>

                <div className="bg-white rounded-xl border border-gray-200 p-4 shadow-sm">
                  <FormField
                    control={form.control}
                    name="notes"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel className="text-sm font-semibold text-[#1C1C1C]">Internal Notes (Optional)</FormLabel>
                        <FormControl>
                          <Textarea
                            placeholder="Any notes about pricing decisions..."
                            className="resize-none border-gray-200 focus:border-orange-300 focus:ring-orange-200 rounded-lg min-h-[80px]"
                            {...field}
                          />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                </div>
              </form>
            </Form>
          </div>
        </ScrollArea>

        <DialogFooter className="gap-3 p-6 border-t border-gray-200 bg-white">
          <Button
            variant="outline"
            onClick={onClose}
            disabled={isSubmitting}
            className="rounded-xl border-gray-200 hover:bg-gray-50"
          >
            Cancel
          </Button>
          <Button
            onClick={form.handleSubmit(onSubmit)}
            disabled={isSubmitting}
            className="bg-[#F97316] hover:bg-[#EA580C] text-white rounded-xl shadow-sm"
          >
            {isSubmitting ? (
              <>
                <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                Submitting Quote...
              </>
            ) : (
              <>
                <CheckCircle2 className="h-4 w-4 mr-2" />
                Submit Quote
              </>
            )}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
