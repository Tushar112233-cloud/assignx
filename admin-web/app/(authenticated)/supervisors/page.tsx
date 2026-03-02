import { getSupervisors } from "@/lib/admin/actions/supervisors";
import { SupervisorsDataTable } from "@/components/admin/supervisors/supervisors-data-table";

export const metadata = { title: "Supervisors - AssignX Admin" };

export default async function SupervisorsPage({
  searchParams,
}: {
  searchParams: Promise<{
    search?: string;
    status?: string;
    page?: string;
  }>;
}) {
  const params = await searchParams;

  const result = await getSupervisors({
    search: params.search || undefined,
    status: params.status || undefined,
    page: parseInt(params.page || "1"),
    perPage: 20,
  });

  // Normalize camelCase API response to snake_case for component
  const supervisors = (result.data || []).map((s: any) => {
    const profile = s.profileId && typeof s.profileId === 'object' ? s.profileId : null;
    return {
      id: s._id || s.id,
      profile_id: profile?._id || s.profileId || s.profile_id,
      full_name: profile?.fullName || s.fullName || s.full_name || null,
      email: profile?.email || s.email || null,
      avatar_url: profile?.avatarUrl || s.avatarUrl || s.avatar_url || null,
      is_active: s.isAccessGranted ?? s.isActive ?? s.is_active ?? false,
      phone: profile?.phone || s.phone || null,
      city: s.city || null,
      created_at: s.createdAt || s.created_at || new Date().toISOString(),
      projects_assigned: s.projectsAssigned ?? s.projects_assigned ?? 0,
      projects_completed: s.projectsCompleted ?? s.projects_completed ?? 0,
      completion_rate: s.completionRate ?? s.completion_rate ?? 0,
    };
  });

  return (
    <div className="flex flex-col gap-4 py-4">
      <div className="px-4 lg:px-6">
        <h1 className="text-2xl font-bold tracking-tight">Supervisors</h1>
        <p className="text-muted-foreground">
          Manage platform supervisors and their performance
        </p>
      </div>
      <SupervisorsDataTable
        data={supervisors}
        total={result.total}
        page={result.page}
        totalPages={result.total_pages}
      />
    </div>
  );
}
