/**
 * @fileoverview Barrel exports for the earnings module.
 * @module components/earnings
 */

// ============================================================================
// V2 Components (New - Enhanced UI/UX)
// ============================================================================
export { EarningsIllustration } from "./earnings-illustration"
export { EarningsSummaryV2 } from "./earnings-summary-v2"
export { EarningsChartV2 } from "./earnings-chart-v2"
export { TransactionTimeline } from "./transaction-timeline"
export { CommissionBreakdownV2 } from "./commission-breakdown-v2"
export { QuickActions } from "./quick-actions"
export { PerformanceInsights } from "./performance-insights"
// WithdrawalModal export removed - file does not exist yet

// ============================================================================
// V1 Components (Legacy - Maintained for backward compatibility)
// ============================================================================
export { EarningsSummary } from "./earnings-summary"
export { EarningsGraph } from "./earnings-graph"
export { PaymentLedger } from "./payment-ledger"
export { CommissionTracking } from "./commission-tracking"

// ============================================================================
// Types
// ============================================================================
export type * from "./types"
