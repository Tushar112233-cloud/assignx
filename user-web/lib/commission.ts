/**
 * Commission calculator for expert consultations
 * Commission Model:
 * - Client pays: $30 (100%)
 * - Expert receives: $20 (66.7%)
 * - Platform fee: $10 (33.3%)
 */

import { formatINR } from "@/lib/utils";
import type { CommissionBreakdown } from "@/types/expert";

/**
 * Commission rates as constants
 */
export const COMMISSION_CONFIG = {
  /** Expert receives 66.67% of the total */
  EXPERT_RATE: 0.6667,
  /** Platform receives 33.33% of the total */
  PLATFORM_RATE: 0.3333,
} as const;

/**
 * Calculates commission breakdown for a consultation
 * @param totalAmount - Total amount charged to client
 * @param currency - Currency code (default: INR)
 * @returns Commission breakdown with formatted values
 */
export function calculateCommission(
  totalAmount: number,
  currency: string = "INR"
): CommissionBreakdown {
  const expertAmount = Math.round(totalAmount * COMMISSION_CONFIG.EXPERT_RATE * 100) / 100;
  const platformFee = Math.round(totalAmount * COMMISSION_CONFIG.PLATFORM_RATE * 100) / 100;

  // Ensure amounts add up exactly (handle rounding)
  const adjustedExpertAmount = totalAmount - platformFee;

  const formatAmount = (amount: number): string => {
    if (currency === "INR") {
      return formatINR(amount);
    }
    return new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: currency,
      minimumFractionDigits: 0,
      maximumFractionDigits: 2,
    }).format(amount);
  };

  return {
    totalAmount,
    expertAmount: adjustedExpertAmount,
    platformFee,
    expertPercentage: COMMISSION_CONFIG.EXPERT_RATE * 100,
    platformPercentage: COMMISSION_CONFIG.PLATFORM_RATE * 100,
    currency,
    formattedTotal: formatAmount(totalAmount),
    formattedExpertAmount: formatAmount(adjustedExpertAmount),
    formattedPlatformFee: formatAmount(platformFee),
  };
}

/**
 * Calculates expert earnings from total amount
 * @param totalAmount - Total amount charged to client
 * @returns Amount expert receives
 */
export function calculateExpertEarnings(totalAmount: number): number {
  return Math.round(totalAmount * COMMISSION_CONFIG.EXPERT_RATE * 100) / 100;
}

/**
 * Calculates platform fee from total amount
 * @param totalAmount - Total amount charged to client
 * @returns Platform fee amount
 */
export function calculatePlatformFee(totalAmount: number): number {
  return Math.round(totalAmount * COMMISSION_CONFIG.PLATFORM_RATE * 100) / 100;
}

/**
 * Calculates total amount from expert's desired earnings
 * @param expertDesiredEarnings - Amount expert wants to receive
 * @returns Total amount to charge client
 */
export function calculateTotalFromExpertEarnings(expertDesiredEarnings: number): number {
  return Math.round((expertDesiredEarnings / COMMISSION_CONFIG.EXPERT_RATE) * 100) / 100;
}

/**
 * Formats price breakdown as a readable string
 * @param breakdown - Commission breakdown object
 * @returns Formatted price breakdown string
 */
export function formatPriceBreakdown(breakdown: CommissionBreakdown): string {
  return `Total: ${breakdown.formattedTotal} (Expert: ${breakdown.formattedExpertAmount} | Platform: ${breakdown.formattedPlatformFee})`;
}

/**
 * Validates if an amount is valid for commission calculation
 * @param amount - Amount to validate
 * @returns True if amount is valid
 */
export function isValidAmount(amount: number): boolean {
  return typeof amount === "number" && amount > 0 && isFinite(amount);
}
