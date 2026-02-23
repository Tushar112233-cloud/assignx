import { createClient } from "@/lib/supabase/server";
import { AdminSectionCards } from "@/components/admin/admin-section-cards";
import { AdminCharts } from "@/components/admin/admin-charts";
import { AdminRecentActivity } from "@/components/admin/admin-recent-activity";

export default async function AdminDashboardPage() {
  const supabase = await createClient();

  const [statsResult, userGrowthResult, revenueResult, ticketsResult] =
    await Promise.all([
      supabase.rpc("get_admin_dashboard_stats"),
      supabase.rpc("get_user_growth_chart_data", { period: "30d" }),
      supabase.rpc("get_revenue_chart_data", { period: "30d" }),
      supabase
        .from("support_tickets")
        .select("*, profiles!requester_id(full_name)")
        .order("created_at", { ascending: false })
        .limit(5),
    ]);

  const stats = statsResult.data ?? {
    total_users: 0,
    new_users_month: 0,
    active_projects: 0,
    total_revenue: 0,
    pending_tickets: 0,
  };

  const userGrowth = userGrowthResult.data ?? [];
  const revenue = revenueResult.data ?? [];
  const recentTickets = ticketsResult.data ?? [];

  return (
    <div className="flex flex-1 flex-col gap-4 py-4">
      <AdminSectionCards stats={stats} />
      <div className="px-4 lg:px-6">
        <AdminCharts userGrowthData={userGrowth} revenueData={revenue} />
      </div>
      <div className="px-4 lg:px-6">
        <AdminRecentActivity tickets={recentTickets} />
      </div>
    </div>
  );
}
