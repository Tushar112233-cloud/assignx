import { getDoers } from "@/lib/admin/actions/doers";
import { DoersDataTable } from "@/components/admin/doers/doers-data-table";

export const metadata = { title: "Doers - AssignX Admin" };

export default async function DoersPage({
  searchParams,
}: {
  searchParams: Promise<{
    search?: string;
    status?: string;
    page?: string;
  }>;
}) {
  const params = await searchParams;

  const result = await getDoers({
    search: params.search || undefined,
    status: params.status || undefined,
    page: parseInt(params.page || "1"),
    perPage: 20,
  });

  return (
    <div className="flex flex-col gap-4 py-4">
      <div className="px-4 lg:px-6">
        <h1 className="text-2xl font-bold tracking-tight">Doers</h1>
        <p className="text-muted-foreground">
          Manage platform doers and track their performance
        </p>
      </div>
      <DoersDataTable
        data={result.data}
        total={result.total}
        page={result.page}
        totalPages={result.total_pages}
      />
    </div>
  );
}
