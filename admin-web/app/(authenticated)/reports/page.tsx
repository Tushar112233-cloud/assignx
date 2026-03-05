import { serverFetch } from "@/lib/admin/auth";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

export const metadata = { title: "Reports - AssignX Admin" };

const STATUS_COLORS: Record<string, string> = {
  completed: "text-green-600 border-green-200 bg-green-50",
  in_progress: "text-blue-600 border-blue-200 bg-blue-50",
  quoted: "text-yellow-600 border-yellow-200 bg-yellow-50",
  analyzing: "text-purple-600 border-purple-200 bg-purple-50",
  cancelled: "text-red-600 border-red-200 bg-red-50",
  delivered: "text-emerald-600 border-emerald-200 bg-emerald-50",
  paid: "text-indigo-600 border-indigo-200 bg-indigo-50",
};

export default async function ReportsPage() {
  const [
    countsData,
    projectsByStatusData,
    recentProjectsData,
    topSupervisorsData,
  ] = await Promise.all([
    serverFetch("/api/admin/analytics/overview?period=all").catch(() => ({
      totalUsers: 0,
      totalProjects: 0,
      totalSupervisors: 0,
      totalDoers: 0,
      totalExperts: 0,
      projectStatusBreakdown: {},
    })),
    serverFetch("/api/admin/analytics/projects-by-status").catch(() => []),
    serverFetch("/api/admin/projects?perPage=10&sort=-createdAt").catch(() => ({ data: [] })),
    serverFetch("/api/supervisors?perPage=5").catch(() => ({ data: [] })),
  ]);

  // Build status counts from projectsByStatus or countsData
  const statusCounts: Record<string, number> = {};
  if (Array.isArray(projectsByStatusData)) {
    for (const p of projectsByStatusData as any[]) {
      const s = p.status || p._id || "unknown";
      statusCounts[s] = (statusCounts[s] || 0) + (p.count || 1);
    }
  } else if (countsData.projectStatusBreakdown) {
    Object.assign(statusCounts, countsData.projectStatusBreakdown);
  }

  const recentProjects = recentProjectsData?.projects || recentProjectsData?.data || [];
  const topSupervisors = topSupervisorsData?.supervisors || topSupervisorsData?.data || [];

  const summaryCards = [
    { label: "Total Users", value: countsData.totalUsers ?? 0 },
    { label: "Total Projects", value: countsData.totalProjects ?? 0 },
    { label: "Supervisors", value: countsData.totalSupervisors ?? 0 },
    { label: "Doers", value: countsData.totalDoers ?? 0 },
    { label: "Experts", value: countsData.totalExperts ?? 0 },
  ];

  return (
    <div className="flex flex-col gap-6 py-4 px-4 lg:px-6">
      <div>
        <h1 className="text-2xl font-bold tracking-tight">Reports</h1>
        <p className="text-muted-foreground">Platform-wide summary and analytics</p>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
        {summaryCards.map((c) => (
          <Card key={c.label}>
            <CardHeader className="pb-1 pt-4 px-4">
              <CardTitle className="text-xs font-medium text-muted-foreground">{c.label}</CardTitle>
            </CardHeader>
            <CardContent className="px-4 pb-4">
              <span className="text-2xl font-bold tabular-nums">{c.value}</span>
            </CardContent>
          </Card>
        ))}
      </div>

      <div className="grid md:grid-cols-2 gap-6">
        {/* Projects by Status */}
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Projects by Status</CardTitle>
          </CardHeader>
          <CardContent>
            {Object.keys(statusCounts).length === 0 ? (
              <p className="text-sm text-muted-foreground">No project data yet.</p>
            ) : (
              <div className="space-y-2">
                {Object.entries(statusCounts)
                  .sort((a, b) => b[1] - a[1])
                  .map(([status, count]) => (
                    <div key={status} className="flex items-center justify-between">
                      <Badge
                        variant="outline"
                        className={STATUS_COLORS[status] || "text-gray-600 border-gray-200 bg-gray-50"}
                      >
                        {status.replace(/_/g, " ")}
                      </Badge>
                      <span className="text-sm font-semibold tabular-nums">{count}</span>
                    </div>
                  ))}
              </div>
            )}
          </CardContent>
        </Card>

        {/* Recent Projects */}
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Recent Projects</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {recentProjects.slice(0, 8).map((p: any) => (
                <div key={p._id || p.id} className="flex items-start justify-between gap-2">
                  <div className="min-w-0">
                    <p className="text-sm font-medium truncate">{p.title}</p>
                    <p className="text-xs text-muted-foreground">
                      {p.user?.full_name || p.user?.fullName || p.userName || "-"}
                    </p>
                  </div>
                  <Badge
                    variant="outline"
                    className={`shrink-0 text-xs ${STATUS_COLORS[p.status] || "text-gray-600 border-gray-200 bg-gray-50"}`}
                  >
                    {p.status?.replace(/_/g, " ")}
                  </Badge>
                </div>
              ))}
              {recentProjects.length === 0 && (
                <p className="text-sm text-muted-foreground">No projects yet.</p>
              )}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Supervisors */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base">Registered Supervisors</CardTitle>
        </CardHeader>
        <CardContent>
          {topSupervisors.length === 0 ? (
            <p className="text-sm text-muted-foreground">No supervisors yet.</p>
          ) : (
            <div className="divide-y">
              {topSupervisors.map((s: any) => (
                <div key={s._id || s.id} className="py-2 flex items-center gap-3">
                  <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center text-xs font-bold text-primary">
                    {(s.full_name || s.fullName || "?")[0].toUpperCase()}
                  </div>
                  <div>
                    <p className="text-sm font-medium">
                      {s.full_name || s.fullName || "-"}
                    </p>
                    <p className="text-xs text-muted-foreground">
                      {s.email || ""}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
