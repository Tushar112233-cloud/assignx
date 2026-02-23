import { createClient } from "@/lib/supabase/server";
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
  const supabase = await createClient();

  const [
    { count: totalUsers },
    { count: totalProjects },
    { count: totalSupervisors },
    { count: totalDoers },
    { count: totalExperts },
    { data: projectsByStatus },
    { data: recentProjects },
    { data: topSupervisors },
  ] = await Promise.all([
    supabase.from("profiles").select("id", { count: "exact", head: true }),
    supabase.from("projects").select("id", { count: "exact", head: true }),
    supabase.from("supervisors").select("id", { count: "exact", head: true }),
    supabase.from("doers").select("id", { count: "exact", head: true }),
    supabase.from("experts").select("id", { count: "exact", head: true }),
    supabase.rpc("admin_projects_by_status").then((r) => {
      if (r.error) {
        // fallback: manual group
        return supabase.from("projects").select("status");
      }
      return r;
    }),
    supabase
      .from("projects")
      .select("id, title, status, created_at, profiles!user_id(full_name)")
      .order("created_at", { ascending: false })
      .limit(10),
    supabase
      .from("supervisors")
      .select("id, profiles!profile_id(full_name, email)")
      .limit(5),
  ]);

  // Compute project status breakdown from raw data
  const statusCounts: Record<string, number> = {};
  if (Array.isArray(projectsByStatus)) {
    for (const p of projectsByStatus as any[]) {
      const s = p.status || "unknown";
      statusCounts[s] = (statusCounts[s] || 0) + 1;
    }
  }

  const summaryCards = [
    { label: "Total Users", value: totalUsers ?? 0 },
    { label: "Total Projects", value: totalProjects ?? 0 },
    { label: "Supervisors", value: totalSupervisors ?? 0 },
    { label: "Doers", value: totalDoers ?? 0 },
    { label: "Experts", value: totalExperts ?? 0 },
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
              {(recentProjects || []).slice(0, 8).map((p: any) => (
                <div key={p.id} className="flex items-start justify-between gap-2">
                  <div className="min-w-0">
                    <p className="text-sm font-medium truncate">{p.title}</p>
                    <p className="text-xs text-muted-foreground">{p.profiles?.full_name || "—"}</p>
                  </div>
                  <Badge
                    variant="outline"
                    className={`shrink-0 text-xs ${STATUS_COLORS[p.status] || "text-gray-600 border-gray-200 bg-gray-50"}`}
                  >
                    {p.status?.replace(/_/g, " ")}
                  </Badge>
                </div>
              ))}
              {(recentProjects || []).length === 0 && (
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
          {(topSupervisors || []).length === 0 ? (
            <p className="text-sm text-muted-foreground">No supervisors yet.</p>
          ) : (
            <div className="divide-y">
              {(topSupervisors as any[]).map((s) => (
                <div key={s.id} className="py-2 flex items-center gap-3">
                  <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center text-xs font-bold text-primary">
                    {(s.profiles?.full_name || "?")[0].toUpperCase()}
                  </div>
                  <div>
                    <p className="text-sm font-medium">{s.profiles?.full_name || "—"}</p>
                    <p className="text-xs text-muted-foreground">{s.profiles?.email || ""}</p>
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
