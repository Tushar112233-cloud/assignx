import { getApplications } from "@/lib/admin/actions/applications";
import { ApplicationsDataTable } from "@/components/admin/applications/applications-data-table";

export const metadata = { title: "Applications - AssignX Admin" };

export default async function ApplicationsPage({
  searchParams,
}: {
  searchParams: Promise<{
    search?: string;
    status?: string;
    role?: string;
    page?: string;
  }>;
}) {
  const params = await searchParams;

  const result = await getApplications({
    search: params.search || undefined,
    status: params.status || undefined,
    role: params.role || undefined,
    page: parseInt(params.page || "1"),
  });

  return (
    <div className="flex flex-col gap-4 py-4">
      <div className="px-4 lg:px-6">
        <h1 className="text-2xl font-bold tracking-tight">Applications</h1>
        <p className="text-muted-foreground">
          Review and manage doer & supervisor access requests
        </p>
      </div>
      <ApplicationsDataTable
        data={result.data}
        total={result.total}
        page={result.page}
        totalPages={result.totalPages}
      />
    </div>
  );
}
