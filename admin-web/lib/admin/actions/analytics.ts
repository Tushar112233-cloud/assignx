"use server";

import { createClient } from "@/lib/supabase/server";
import { verifyAdmin } from "@/lib/admin/auth";

export async function getAnalyticsOverview(period: string = "30d") {
  await verifyAdmin();
  const supabase = await createClient();

  const daysBack = period === "7d" ? 7 : period === "90d" ? 90 : 30;
  const startDate = new Date();
  startDate.setDate(startDate.getDate() - daysBack);

  const [
    { count: totalUsers },
    { count: newUsers },
    { data: typeData },
    { count: totalProjects },
    { count: completedProjects },
    { data: revenueData },
    { data: subjects },
    { count: pendingDoers },
    { count: activeDoers },
    { count: openTickets },
    { count: inProgressTickets },
    { count: activeProjects },
    { data: projectStatusData },
  ] = await Promise.all([
    supabase.from("profiles").select("*", { count: "exact", head: true }),
    supabase
      .from("profiles")
      .select("*", { count: "exact", head: true })
      .gte("created_at", startDate.toISOString()),
    supabase.from("profiles").select("user_type"),
    supabase.from("projects").select("*", { count: "exact", head: true }),
    supabase
      .from("projects")
      .select("*", { count: "exact", head: true })
      .eq("status", "completed"),
    supabase
      .from("wallet_transactions")
      .select("amount")
      .eq("type", "project_payment")
      .eq("status", "completed"),
    supabase.from("projects").select("subject").not("subject", "is", null),
    supabase.from("doers").select("*", { count: "exact", head: true }).eq("is_activated", false),
    supabase.from("doers").select("*", { count: "exact", head: true }).eq("is_activated", true),
    supabase.from("support_tickets").select("*", { count: "exact", head: true }).eq("status", "open"),
    supabase.from("support_tickets").select("*", { count: "exact", head: true }).eq("status", "in_progress"),
    supabase.from("projects").select("*", { count: "exact", head: true }).not("status", "in", '("completed","cancelled")'),
    supabase.from("projects").select("status"),
  ]);

  const distribution: Record<string, number> = {};
  typeData?.forEach((p) => {
    distribution[p.user_type] = (distribution[p.user_type] || 0) + 1;
  });

  const totalRevenue =
    revenueData?.reduce((sum, t) => sum + (t.amount || 0), 0) || 0;

  const subjectCounts: Record<string, number> = {};
  subjects?.forEach((p) => {
    if (p.subject)
      subjectCounts[p.subject] = (subjectCounts[p.subject] || 0) + 1;
  });
  const topSubjects = Object.entries(subjectCounts)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 5)
    .map(([name, count]) => ({ name, count }));

  // Project status breakdown
  const projectStatusCounts: Record<string, number> = {};
  projectStatusData?.forEach((p) => {
    projectStatusCounts[p.status] = (projectStatusCounts[p.status] || 0) + 1;
  });

  return {
    totalUsers: totalUsers || 0,
    newUsers: newUsers || 0,
    totalProjects: totalProjects || 0,
    completedProjects: completedProjects || 0,
    completionRate: totalProjects
      ? ((completedProjects || 0) / totalProjects * 100).toFixed(1)
      : "0",
    totalRevenue,
    userTypeDistribution: distribution,
    topSubjects,
    // Platform health metrics
    pendingDoerApprovals: pendingDoers || 0,
    activeDoers: activeDoers || 0,
    openSupportTickets: openTickets || 0,
    inProgressTickets: inProgressTickets || 0,
    activeProjects: activeProjects || 0,
    projectStatusBreakdown: projectStatusCounts,
  };
}

export async function getUserGrowthData(period: string = "30d") {
  await verifyAdmin();
  const supabase = await createClient();
  const { data } = await supabase.rpc("get_user_growth_chart_data", {
    period,
  });
  return data || [];
}

export async function getRevenueData(period: string = "30d") {
  await verifyAdmin();
  const supabase = await createClient();
  const { data } = await supabase.rpc("get_revenue_chart_data", { period });
  return data || [];
}
