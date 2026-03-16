"use server";

import { verifyAdmin, serverFetch } from "@/lib/admin/auth";

/** Convert a period string like "30d", "90d", "12m" to months for the API */
function periodToMonths(period: string): number {
  const match = period.match(/^(\d+)(d|m)$/);
  if (!match) return 12;
  const value = parseInt(match[1], 10);
  return match[2] === "d" ? Math.max(1, Math.ceil(value / 30)) : value;
}

export async function getAnalyticsOverview(period: string = "30d") {
  await verifyAdmin();

  try {
    return await serverFetch(`/api/admin/analytics/overview?period=${period}`);
  } catch {
    return {
      totalUsers: 0,
      newUsers: 0,
      totalProjects: 0,
      completedProjects: 0,
      completionRate: "0",
      totalRevenue: 0,
      userTypeDistribution: {},
      topSubjects: [],
      pendingDoerApprovals: 0,
      activeDoers: 0,
      openSupportTickets: 0,
      inProgressTickets: 0,
      activeProjects: 0,
      projectStatusBreakdown: {},
    };
  }
}

export async function getUserGrowthData(period: string = "30d") {
  await verifyAdmin();

  try {
    const data = await serverFetch(`/api/admin/analytics/user-growth?months=${periodToMonths(period)}`);
    const raw = Array.isArray(data) ? data : (data?.growth || []);
    return raw.map((g: any) => ({
      date: g.date || `${g._id?.year || 2026}-${String(g._id?.month || 1).padStart(2, '0')}-01`,
      students: g.students ?? g.count ?? 0,
      professionals: g.professionals ?? 0,
      businesses: g.businesses ?? 0,
    }));
  } catch {
    return [];
  }
}

export async function getRevenueData(period: string = "30d") {
  await verifyAdmin();

  try {
    const data = await serverFetch(`/api/admin/analytics/revenue?months=${periodToMonths(period)}`);
    const raw = Array.isArray(data) ? data : (data?.revenue || []);
    return raw.map((r: any) => ({
      date: r.date || `${r._id?.year || 2026}-${String(r._id?.month || 1).padStart(2, '0')}-01`,
      revenue: r.revenue ?? r.total ?? 0,
      refunds: r.refunds ?? 0,
    }));
  } catch {
    return [];
  }
}
