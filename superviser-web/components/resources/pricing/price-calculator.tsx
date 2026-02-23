/**
 * @fileoverview Price calculator component for estimating project quotes.
 * @module components/resources/pricing/price-calculator
 */

"use client"

import { useState, useMemo } from "react"
import { Calculator, FileText, Users, Building } from "lucide-react"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Separator } from "@/components/ui/separator"
import type { PricingConfig, PriceCalculation } from "./types"

interface PriceCalculatorProps {
  pricing: PricingConfig
}

/**
 * Calculator component for estimating project quotes with multipliers.
 * @param props - Component props containing pricing configuration
 */
export function PriceCalculator({ pricing }: PriceCalculatorProps) {
  const [selectedTier, setSelectedTier] = useState("standard")
  const [pageCount, setPageCount] = useState("")
  const [wordCount, setWordCount] = useState("")
  const [urgency, setUrgency] = useState("standard")
  const [complexity, setComplexity] = useState("medium")
  const [calculationMode, setCalculationMode] = useState<"pages" | "words">("pages")

  const calculation = useMemo((): PriceCalculation | null => {
    const tier = pricing.tiers.find((t) => t.id === selectedTier)
    const urgencyMult = pricing.urgency_multipliers.find((u) => u.id === urgency)
    const complexityMult = pricing.complexity_multipliers.find((c) => c.id === complexity)

    if (!tier || !urgencyMult || !complexityMult) return null

    let basePrice = 0
    if (calculationMode === "pages" && pageCount) {
      basePrice = tier.base_price_per_page * parseInt(pageCount)
    } else if (calculationMode === "words" && wordCount) {
      basePrice = tier.base_price_per_word * parseInt(wordCount)
    }

    if (basePrice === 0) return null

    const totalPrice = basePrice * urgencyMult.multiplier * complexityMult.multiplier
    return {
      basePrice,
      totalPrice,
      supervisorCommission: (totalPrice * pricing.supervisor_commission_percentage) / 100,
      platformFee: (totalPrice * pricing.platform_fee_percentage) / 100,
      doerPayout: (totalPrice * pricing.doer_base_percentage) / 100,
      urgencyMultiplier: urgencyMult.multiplier,
      complexityMultiplier: complexityMult.multiplier,
    }
  }, [selectedTier, pageCount, wordCount, urgency, complexity, calculationMode, pricing])

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center gap-3">
          <div className="h-10 w-10 rounded-lg bg-primary/10 flex items-center justify-center">
            <Calculator className="h-5 w-5 text-primary" />
          </div>
          <div>
            <CardTitle className="text-base">Price Calculator</CardTitle>
            <CardDescription>Calculate project quotes with multipliers</CardDescription>
          </div>
        </div>
      </CardHeader>
      <CardContent>
        <div className="grid gap-4 md:grid-cols-2">
          <div className="space-y-4">
            <div className="space-y-2">
              <Label>Service Tier</Label>
              <Select value={selectedTier} onValueChange={setSelectedTier}>
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  {pricing.tiers.map((tier) => (
                    <SelectItem key={tier.id} value={tier.id}>
                      {tier.name} (${tier.base_price_per_page}/page)
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <Label>Calculate By</Label>
              <div className="flex gap-2">
                <Button variant={calculationMode === "pages" ? "default" : "outline"} size="sm" className="flex-1" onClick={() => setCalculationMode("pages")}>
                  <FileText className="h-4 w-4 mr-2" />Pages
                </Button>
                <Button variant={calculationMode === "words" ? "default" : "outline"} size="sm" className="flex-1" onClick={() => setCalculationMode("words")}>
                  <FileText className="h-4 w-4 mr-2" />Words
                </Button>
              </div>
            </div>
            <div className="space-y-2">
              <Label>{calculationMode === "pages" ? "Number of Pages" : "Word Count"}</Label>
              <Input
                type="number"
                placeholder={calculationMode === "pages" ? "e.g., 5" : "e.g., 2500"}
                value={calculationMode === "pages" ? pageCount : wordCount}
                onChange={(e) => calculationMode === "pages" ? setPageCount(e.target.value) : setWordCount(e.target.value)}
                min={calculationMode === "pages" ? 1 : 100}
              />
            </div>
            <div className="space-y-2">
              <Label>Urgency</Label>
              <Select value={urgency} onValueChange={setUrgency}>
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  {pricing.urgency_multipliers.map((u) => (
                    <SelectItem key={u.id} value={u.id}>
                      {u.name} <Badge variant="outline" className="ml-2">{u.multiplier}x</Badge>
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <Label>Complexity</Label>
              <Select value={complexity} onValueChange={setComplexity}>
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  {pricing.complexity_multipliers.map((c) => (
                    <SelectItem key={c.id} value={c.id}>
                      {c.name} <Badge variant="outline" className="ml-2">{c.multiplier}x</Badge>
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>
          <div className="space-y-4">
            {calculation ? (
              <div className="space-y-4 p-4 rounded-lg bg-muted/30">
                <div className="text-center">
                  <p className="text-sm text-muted-foreground mb-1">Recommended Quote</p>
                  <p className="text-4xl font-bold text-primary">${calculation.totalPrice.toFixed(2)}</p>
                </div>
                <Separator />
                <div className="space-y-2 text-sm">
                  <div className="flex justify-between"><span className="text-muted-foreground">Base Price</span><span>${calculation.basePrice.toFixed(2)}</span></div>
                  <div className="flex justify-between"><span className="text-muted-foreground">Urgency ({calculation.urgencyMultiplier}x)</span><span>+${(calculation.basePrice * (calculation.urgencyMultiplier - 1)).toFixed(2)}</span></div>
                  <div className="flex justify-between"><span className="text-muted-foreground">Complexity ({calculation.complexityMultiplier}x)</span><span>+${(calculation.basePrice * calculation.urgencyMultiplier * (calculation.complexityMultiplier - 1)).toFixed(2)}</span></div>
                </div>
                <Separator />
                <div className="space-y-2 text-sm">
                  <div className="flex justify-between"><span className="flex items-center gap-2"><Users className="h-4 w-4 text-green-600" />Your Commission (15%)</span><span className="text-green-600">${calculation.supervisorCommission.toFixed(2)}</span></div>
                  <div className="flex justify-between"><span className="flex items-center gap-2"><Users className="h-4 w-4 text-blue-600" />Doer Payout (65%)</span><span className="text-blue-600">${calculation.doerPayout.toFixed(2)}</span></div>
                  <div className="flex justify-between"><span className="flex items-center gap-2"><Building className="h-4 w-4" />Platform Fee (20%)</span><span className="text-muted-foreground">${calculation.platformFee.toFixed(2)}</span></div>
                </div>
              </div>
            ) : (
              <div className="flex flex-col items-center justify-center h-full p-8 text-center text-muted-foreground">
                <Calculator className="h-12 w-12 mb-4 opacity-50" />
                <p className="text-sm">Enter project details to calculate the recommended quote</p>
              </div>
            )}
          </div>
        </div>
      </CardContent>
    </Card>
  )
}
