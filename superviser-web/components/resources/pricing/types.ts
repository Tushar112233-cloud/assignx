/**
 * @fileoverview Pricing configuration types for the pricing guide module.
 * @module components/resources/pricing/types
 */

/** Represents a service pricing tier */
export interface PricingTier {
  id: string
  name: string
  description: string
  base_price_per_page: number
  base_price_per_word: number
}

/** Represents an urgency multiplier option */
export interface UrgencyMultiplier {
  id: string
  name: string
  hours: number
  multiplier: number
  description: string
}

/** Represents a complexity multiplier option */
export interface ComplexityMultiplier {
  id: string
  name: string
  multiplier: number
  description: string
  examples: string[]
}

/** Complete pricing configuration */
export interface PricingConfig {
  tiers: PricingTier[]
  urgency_multipliers: UrgencyMultiplier[]
  complexity_multipliers: ComplexityMultiplier[]
  supervisor_commission_percentage: number
  platform_fee_percentage: number
  doer_base_percentage: number
}

/** Calculated price breakdown */
export interface PriceCalculation {
  basePrice: number
  totalPrice: number
  supervisorCommission: number
  platformFee: number
  doerPayout: number
  urgencyMultiplier: number
  complexityMultiplier: number
}
