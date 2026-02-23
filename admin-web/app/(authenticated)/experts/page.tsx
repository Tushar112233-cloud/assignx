import { getExperts } from "@/lib/admin/actions/experts";
import { ExpertsDataTable } from "@/components/admin/experts/experts-data-table";

export const metadata = { title: "Experts - AssignX Admin" };

export default async function ExpertsPage({
  searchParams,
}: {
  searchParams: Promise<{
    search?: string;
    status?: string;
    category?: string;
    page?: string;
  }>;
}) {
  const params = await searchParams;

  const result = await getExperts({
    search: params.search || undefined,
    status: params.status || undefined,
    category: params.category || undefined,
    page: parseInt(params.page || "1"),
    perPage: 20,
  });

  return (
    <div className="flex flex-col gap-4 py-4">
      <div className="px-4 lg:px-6">
        <h1 className="text-2xl font-bold tracking-tight">Experts</h1>
        <p className="text-muted-foreground">
          Manage and verify platform experts
        </p>
      </div>
      <ExpertsDataTable
        data={result.data}
        total={result.total}
        page={result.page}
        totalPages={result.total_pages}
      />
    </div>
  );
}
