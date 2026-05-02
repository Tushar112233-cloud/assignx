"use client";

import { KpiCards } from "@/components/admin/analytics/kpi-cards";
import { UserGrowthChart } from "@/components/admin/analytics/user-growth-chart";
import { RevenueBreakdown } from "@/components/admin/analytics/revenue-breakdown";
import { PlatformHealthCards } from "@/components/admin/analytics/platform-health-cards";

interface AnalyticsData {
  totalUsers: number;
  newUsers: number;
  totalProjects: number;
  completedProjects: number;
  completionRate: string;
  totalRevenue: number;
  userTypeDistribution: Record<string, number>;
  topSubjects: { name: string; count: number }[];
  pendingDoerApprovals: number;
  activeDoers: number;
  openSupportTickets: number;
  inProgressTickets: number;
  activeProjects: number;
  projectStatusBreakdown: Record<string, number>;
}

export function AnalyticsOverview({
  overview,
  userGrowthData,
  revenueData,
  period,
}: {
  overview: AnalyticsData;
  userGrowthData: { date: string; students: number; professionals: number; businesses: number }[];
  revenueData: { date: string; revenue: number; refunds: number }[];
  period: string;
}) {
  const avgProjectValue =
    overview.completedProjects > 0
      ? overview.totalRevenue / overview.completedProjects
      : 0;

  return (
    <div className="flex flex-col gap-4">
      <KpiCards
        totalUsers={overview.totalUsers}
        newUsers={overview.newUsers}
        totalProjects={overview.totalProjects}
        completionRate={overview.completionRate}
        totalRevenue={overview.totalRevenue}
        avgProjectValue={avgProjectValue}
      />
      <div className="px-4 lg:px-6">
        <PlatformHealthCards
          pendingDoerApprovals={overview.pendingDoerApprovals}
          activeDoers={overview.activeDoers}
          openSupportTickets={overview.openSupportTickets}
          inProgressTickets={overview.inProgressTickets}
          activeProjects={overview.activeProjects}
          projectStatusBreakdown={overview.projectStatusBreakdown}
        />
      </div>
      <div className="px-4 lg:px-6">
        <UserGrowthChart data={userGrowthData} initialPeriod={period} />
      </div>
      <div className="px-4 lg:px-6">
        <RevenueBreakdown
          userTypeDistribution={overview.userTypeDistribution}
          topSubjects={overview.topSubjects}
        />
      </div>
    </div>
  );
}
