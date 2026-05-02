import { getColleges } from "@/lib/admin/actions/colleges";
import { CollegesDataTable } from "@/components/admin/colleges/colleges-data-table";

export const metadata = { title: "Colleges - AssignX Admin" };

export default async function CollegesPage({
  searchParams,
}: {
  searchParams: Promise<{
    search?: string;
    page?: string;
  }>;
}) {
  const params = await searchParams;

  const result = await getColleges({
    search: params.search || undefined,
    page: parseInt(params.page || "1"),
  });

  return (
    <div className="flex flex-col gap-4 py-4">
      <div className="px-4 lg:px-6">
        <h1 className="text-2xl font-bold tracking-tight">Colleges</h1>
        <p className="text-muted-foreground">
          View colleges and their user distribution
        </p>
      </div>
      <CollegesDataTable
        data={result.data}
        total={result.total}
        page={result.page}
        totalPages={result.totalPages}
      />
    </div>
  );
}
