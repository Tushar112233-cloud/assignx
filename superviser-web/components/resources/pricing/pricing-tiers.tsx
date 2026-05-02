/**
 * @fileoverview Displays pricing tiers with base rates per page and word.
 * @module components/resources/pricing/pricing-tiers
 */

"use client"

import { DollarSign } from "lucide-react"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import type { PricingTier } from "./types"

interface PricingTiersProps {
  tiers: PricingTier[]
}

/**
 * Displays available pricing tiers with their base rates.
 * @param props - Component props containing pricing tiers
 */
export function PricingTiers({ tiers }: PricingTiersProps) {
  return (
    <Card>
      <CardHeader>
        <div className="flex items-center gap-3">
          <div className="h-10 w-10 rounded-lg bg-green-100 flex items-center justify-center">
            <DollarSign className="h-5 w-5 text-green-600" />
          </div>
          <div>
            <CardTitle className="text-base">Base Pricing Tiers</CardTitle>
            <CardDescription>Standard rates per page and word</CardDescription>
          </div>
        </div>
      </CardHeader>
      <CardContent>
        <div className="grid gap-4 md:grid-cols-3">
          {tiers.map((tier) => (
            <Card key={tier.id} className="border-2">
              <CardContent className="pt-6">
                <div className="text-center mb-4">
                  <h4 className="font-semibold text-lg">{tier.name}</h4>
                  <p className="text-sm text-muted-foreground">{tier.description}</p>
                </div>
                <div className="space-y-3">
                  <div className="flex items-center justify-between p-3 rounded-lg bg-muted/30">
                    <span className="text-sm">Per Page</span>
                    <span className="font-bold text-lg">${tier.base_price_per_page}</span>
                  </div>
                  <div className="flex items-center justify-between p-3 rounded-lg bg-muted/30">
                    <span className="text-sm">Per Word</span>
                    <span className="font-bold text-lg">${tier.base_price_per_word}</span>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </CardContent>
    </Card>
  )
}
