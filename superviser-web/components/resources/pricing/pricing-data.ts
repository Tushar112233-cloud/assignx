/**
 * @fileoverview Default pricing configuration data.
 * @module components/resources/pricing/pricing-data
 */

import type { PricingConfig } from "./types"

/** Default pricing configuration with tiers, multipliers, and commission structure */
export const DEFAULT_PRICING: PricingConfig = {
  tiers: [
    {
      id: "basic",
      name: "Basic",
      description: "Standard academic writing and editing",
      base_price_per_page: 15,
      base_price_per_word: 0.06,
    },
    {
      id: "standard",
      name: "Standard",
      description: "Research papers and technical writing",
      base_price_per_page: 20,
      base_price_per_word: 0.08,
    },
    {
      id: "premium",
      name: "Premium",
      description: "Advanced research and specialized topics",
      base_price_per_page: 30,
      base_price_per_word: 0.12,
    },
  ],
  urgency_multipliers: [
    { id: "standard", name: "Standard (7+ days)", hours: 168, multiplier: 1.0, description: "Regular delivery timeline" },
    { id: "72h", name: "Fast (72 hours)", hours: 72, multiplier: 1.15, description: "15% urgency premium" },
    { id: "48h", name: "Express (48 hours)", hours: 48, multiplier: 1.3, description: "30% urgency premium" },
    { id: "24h", name: "Rush (24 hours)", hours: 24, multiplier: 1.5, description: "50% urgency premium" },
    { id: "12h", name: "Critical (12 hours)", hours: 12, multiplier: 2.0, description: "100% urgency premium" },
  ],
  complexity_multipliers: [
    { id: "easy", name: "Easy", multiplier: 1.0, description: "Simple topics with widely available sources", examples: ["General essays", "Book reports", "Basic summaries"] },
    { id: "medium", name: "Medium", multiplier: 1.2, description: "Topics requiring moderate research depth", examples: ["Case studies", "Literature reviews", "Research papers"] },
    { id: "hard", name: "Hard", multiplier: 1.5, description: "Complex topics requiring specialized expertise", examples: ["Technical analysis", "Statistical research", "Advanced theory"] },
    { id: "expert", name: "Expert", multiplier: 2.0, description: "Highly specialized topics", examples: ["PhD-level research", "Proprietary analysis", "Novel methodologies"] },
  ],
  supervisor_commission_percentage: 15,
  platform_fee_percentage: 20,
  doer_base_percentage: 65,
}
