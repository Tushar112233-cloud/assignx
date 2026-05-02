import { serverFetch } from "@/lib/admin/auth";
import { AdminSectionCards } from "@/components/admin/admin-section-cards";
import { AdminCharts } from "@/components/admin/admin-charts";
import { AdminRecentActivity } from "@/components/admin/admin-recent-activity";

export default async function AdminDashboardPage() {
  const [dashboardData, userGrowthRaw, revenueRaw, recentTickets] = await Promise.all([
    serverFetch("/api/admin/dashboard").catch(() => ({
      stats: {
        totalUsers: 0,
        totalProjects: 0,
        activeProjects: 0,
        totalRevenue: 0,
        openTickets: 0,
      },
    })),
    serverFetch("/api/admin/analytics/user-growth?period=30d").catch(() => ({ growth: [] })),
    serverFetch("/api/admin/analytics/revenue?period=30d").catch(() => ({ revenue: [] })),
    serverFetch("/api/support/tickets?limit=5&sort=-createdAt").catch(() => ({ data: [] })),
  ]);

  // Normalize camelCase API response to snake_case for component
  const raw = dashboardData?.stats || dashboardData || {};
  const stats = {
    total_users: raw.totalUsers ?? raw.total_users ?? 0,
    new_users_month: raw.newUsersMonth ?? raw.new_users_month ?? 0,
    active_projects: raw.activeProjects ?? raw.active_projects ?? 0,
    total_revenue: raw.totalRevenue ?? raw.total_revenue ?? 0,
    pending_tickets: raw.openTickets ?? raw.pending_tickets ?? 0,
  };

  // Transform user growth data: { growth: [{_id: {year, month}, count}] } → [{date, students, professionals, businesses}]
  const rawGrowth = Array.isArray(userGrowthRaw) ? userGrowthRaw : (userGrowthRaw?.growth || []);
  const userGrowthData = rawGrowth.map((g: any) => ({
    date: g.date || `${g._id?.year || 2026}-${String(g._id?.month || 1).padStart(2, '0')}-01`,
    students: g.students ?? g.count ?? 0,
    professionals: g.professionals ?? 0,
    businesses: g.businesses ?? 0,
  }));

  // Transform revenue data: { revenue: [{_id: {year, month}, total, count}] } → [{date, revenue, refunds}]
  const rawRevenue = Array.isArray(revenueRaw) ? revenueRaw : (revenueRaw?.revenue || []);
  const revenueData = rawRevenue.map((r: any) => ({
    date: r.date || `${r._id?.year || 2026}-${String(r._id?.month || 1).padStart(2, '0')}-01`,
    revenue: r.revenue ?? r.total ?? 0,
    refunds: r.refunds ?? 0,
  }));

  return (
    <div className="flex flex-1 flex-col gap-4 py-4">
      <AdminSectionCards stats={stats} />
      <div className="px-4 lg:px-6">
        <AdminCharts userGrowthData={userGrowthData} revenueData={revenueData} />
      </div>
      <div className="px-4 lg:px-6">
        <AdminRecentActivity tickets={recentTickets.tickets || recentTickets.data || (Array.isArray(recentTickets) ? recentTickets : [])} />
      </div>
    </div>
  );
}
