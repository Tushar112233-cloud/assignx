import { createClient } from "@/lib/supabase/server";
import { ProjectsDataTable } from "@/components/admin/projects/projects-data-table";

export const metadata = { title: "Projects - AssignX Admin" };

export default async function ProjectsPage({
  searchParams,
}: {
  searchParams: Promise<{
    search?: string;
    status?: string;
    page?: string;
  }>;
}) {
  const params = await searchParams;
  const supabase = await createClient();
  const page = parseInt(params.page || "1");
  const perPage = 20;
  const offset = (page - 1) * perPage;

  // supervisor_id → supervisors.id → profiles, doer_id → doers.id → profiles
  let query = supabase
    .from("projects")
    .select(
      "*, user:profiles!user_id(full_name, email, avatar_url), supervisor:supervisors!supervisor_id(profiles!profile_id(full_name, email)), doer:doers!doer_id(profiles!profile_id(full_name, email))",
      { count: "exact" }
    )
    .order("created_at", { ascending: false })
    .range(offset, offset + perPage - 1);

  if (params.search) {
    query = query.or(
      `title.ilike.%${params.search}%,description.ilike.%${params.search}%`
    );
  }
  if (params.status) query = query.eq("status", params.status);

  const { data: rawProjects, count } = await query;

  // Flatten nested profile joins so ProjectsDataTable gets { supervisor: { full_name } }
  const projects = (rawProjects || []).map((p: any) => ({
    ...p,
    supervisor: p.supervisor?.profiles ?? null,
    doer: p.doer?.profiles ?? null,
  }));

  return (
    <div className="flex flex-col gap-4 py-4">
      <div className="px-4 lg:px-6">
        <h1 className="text-2xl font-bold tracking-tight">Projects</h1>
        <p className="text-muted-foreground">
          Manage all platform projects and assignments
        </p>
      </div>
      <ProjectsDataTable
        data={projects}
        total={count || 0}
        page={page}
        totalPages={Math.ceil((count || 0) / perPage)}
      />
    </div>
  );
}
