import { serverFetch } from "@/lib/admin/auth";
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
  const page = parseInt(params.page || "1");
  const perPage = 20;

  const query = new URLSearchParams();
  if (params.search) query.set("search", params.search);
  if (params.status) query.set("status", params.status);
  query.set("page", String(page));
  query.set("perPage", String(perPage));

  const result = await serverFetch(`/api/admin/projects?${query.toString()}`).catch(() => ({
    projects: [],
    total: 0,
    page: 1,
    totalPages: 1,
  }));

  const rawProjects = result.projects || result.data || [];

  // Normalize camelCase API response to snake_case for component
  const projects = rawProjects.map((p: any) => {
    const userId = p.userId && typeof p.userId === 'object' ? p.userId : null;
    const doerId = p.doerId && typeof p.doerId === 'object' ? p.doerId : null;
    const supervisorId = p.supervisorId && typeof p.supervisorId === 'object' ? p.supervisorId : null;
    return {
      id: p._id || p.id,
      title: p.title || 'Untitled',
      status: p.status || 'unknown',
      service_type: p.serviceType || p.service_type || null,
      price: p.budget ?? p.price ?? null,
      deadline: p.deadline || null,
      created_at: p.createdAt || p.created_at || new Date().toISOString(),
      user: userId ? { full_name: userId.fullName || userId.full_name || null } : null,
      supervisor: supervisorId ? { full_name: supervisorId.fullName || supervisorId.full_name || null } : null,
      doer: doerId ? { full_name: doerId.fullName || doerId.full_name || null } : null,
    };
  });

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
        total={result.total || 0}
        page={result.page || page}
        totalPages={result.totalPages || result.total_pages || Math.ceil((result.total || 0) / perPage)}
      />
    </div>
  );
}
