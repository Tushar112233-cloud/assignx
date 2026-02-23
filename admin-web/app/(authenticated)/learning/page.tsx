import { getLearningResources } from "@/lib/admin/actions/learning";
import { LearningDataTable } from "@/components/admin/learning/learning-data-table";

export const metadata = { title: "Learning Resources - AssignX Admin" };

export default async function LearningPage({
  searchParams,
}: {
  searchParams: Promise<{
    search?: string;
    contentType?: string;
    category?: string;
    page?: string;
  }>;
}) {
  const params = await searchParams;

  const result = await getLearningResources({
    search: params.search || undefined,
    contentType: params.contentType || undefined,
    category: params.category || undefined,
    page: parseInt(params.page || "1"),
  });

  return (
    <div className="flex flex-col gap-4 py-4">
      <div className="px-4 lg:px-6">
        <h1 className="text-2xl font-bold tracking-tight">
          Learning Resources
        </h1>
        <p className="text-muted-foreground">
          Manage educational content for users
        </p>
      </div>
      <LearningDataTable
        data={result.data}
        total={result.total}
        page={result.page}
        totalPages={result.totalPages}
      />
    </div>
  );
}
