import { getAnalyticsOverview, getUserGrowthData, getRevenueData } from "@/lib/admin/actions/analytics";
import { AnalyticsOverview } from "@/components/admin/analytics/analytics-overview";

export const metadata = { title: "Analytics - AssignX Admin" };

export default async function AnalyticsPage({
  searchParams,
}: {
  searchParams: Promise<{ period?: string }>;
}) {
  const params = await searchParams;
  const period = params.period || "30d";

  const [overview, userGrowth, revenue] = await Promise.all([
    getAnalyticsOverview(period),
    getUserGrowthData(period),
    getRevenueData(period),
  ]);

  return (
    <div className="flex flex-col gap-4 py-4">
      <div className="px-4 lg:px-6">
        <h1 className="text-2xl font-bold tracking-tight">Analytics</h1>
        <p className="text-muted-foreground">
          Platform metrics and insights
        </p>
      </div>
      <AnalyticsOverview
        overview={overview}
        userGrowthData={userGrowth}
        revenueData={revenue}
        period={period}
      />
    </div>
  );
}
