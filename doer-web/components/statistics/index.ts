/**
 * Statistics components for doer-web
 *
 * Comprehensive suite of components for the redesigned statistics page,
 * including hero banners, charts, heatmaps, and analytics visualizations.
 */

// Hero & Header Components
export { PerformanceHeroBanner } from "./PerformanceHeroBanner";

// Stat Cards
export { EnhancedStatCard } from "./EnhancedStatCard";
export type { EnhancedStatCardProps } from "./EnhancedStatCard";

// Charts
export { InteractiveEarningsChart } from "./InteractiveEarningsChart";
export type { InteractiveEarningsChartProps, EarningsDataPoint } from "./InteractiveEarningsChart";

export { RatingBreakdownCard } from "./RatingBreakdownCard";
export type { RatingBreakdownCardProps } from "./RatingBreakdownCard";

export { ProjectDistributionChart } from "./ProjectDistributionChart";
export { TopSubjectsRanking } from "./TopSubjectsRanking";

// Heatmap & Advanced Visualizations
export { MonthlyPerformanceHeatmap } from "./MonthlyPerformanceHeatmap";

// Insights & Recommendations
export { InsightsPanel } from "./InsightsPanel";

// Loading States
export { default as StatisticsLoadingSkeletons } from "./StatisticsLoadingSkeletons";
