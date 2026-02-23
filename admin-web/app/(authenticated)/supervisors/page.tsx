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

  return (
    <div className="flex flex-col gap-4 py-4">
      <div className="px-4 lg:px-6">
        <h1 className="text-2xl font-bold tracking-tight">Supervisors</h1>
        <p className="text-muted-foreground">
          Manage platform supervisors and their performance
        </p>
      </div>
      <SupervisorsDataTable
        data={result.data}
        total={result.total}
        page={result.page}
        totalPages={result.total_pages}
      />
    </div>
  );
}
