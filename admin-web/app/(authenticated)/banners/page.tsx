import { getBanners } from "@/lib/admin/actions/banners";
import { BannersDataTable } from "@/components/admin/banners/banners-data-table";

export const metadata = { title: "Banners - AssignX Admin" };

export default async function BannersPage({
  searchParams,
}: {
  searchParams: Promise<{
    search?: string;
    location?: string;
    active?: string;
    page?: string;
  }>;
}) {
  const params = await searchParams;

  const result = await getBanners({
    search: params.search || undefined,
    location: params.location || undefined,
    active: params.active || undefined,
    page: parseInt(params.page || "1"),
  });

  return (
    <div className="flex flex-col gap-4 py-4">
      <div className="px-4 lg:px-6">
        <h1 className="text-2xl font-bold tracking-tight">Banners</h1>
        <p className="text-muted-foreground">
          Manage promotional banners and announcements
        </p>
      </div>
      <BannersDataTable
        data={result.data}
        total={result.total}
        page={result.page}
        totalPages={result.totalPages}
      />
    </div>
  );
}
