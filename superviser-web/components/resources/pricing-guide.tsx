/**
 * @fileoverview Pricing guide component for supervisor reference.
 * Provides pricing calculator, tiers, multipliers, and commission structure.
 * @module components/resources/pricing-guide
 */

"use client"

import {
  DEFAULT_PRICING,
  PriceCalculator,
  PricingTiers,
  UrgencyTable,
  ComplexityCards,
  CommissionStructure,
} from "./pricing"

/**
 * Main pricing guide component that aggregates all pricing-related UI.
 * Includes calculator, base tiers, urgency/complexity multipliers, and commission breakdown.
 */
export function PricingGuide() {
  return (
    <div className="space-y-6">
      <PriceCalculator pricing={DEFAULT_PRICING} />
      <PricingTiers tiers={DEFAULT_PRICING.tiers} />
      <UrgencyTable multipliers={DEFAULT_PRICING.urgency_multipliers} />
      <ComplexityCards multipliers={DEFAULT_PRICING.complexity_multipliers} />
      <CommissionStructure
        supervisorPercentage={DEFAULT_PRICING.supervisor_commission_percentage}
        platformPercentage={DEFAULT_PRICING.platform_fee_percentage}
        doerPercentage={DEFAULT_PRICING.doer_base_percentage}
      />
    </div>
  )
}
