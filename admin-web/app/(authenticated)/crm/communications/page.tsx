import { getRecentCommunications } from "@/lib/admin/actions/crm";
import { CrmCommunications } from "@/components/admin/crm/crm-communications";

export const metadata = {
  title: "Communications - CRM - AssignX Admin",
};

export default async function CrmCommunicationsPage({
  searchParams,
}: {
  searchParams: Promise<{
    type?: string;
    page?: string;
  }>;
}) {
  const params = await searchParams;

  const result = await getRecentCommunications({
    type: params.type || undefined,
    page: parseInt(params.page || "1"),
    perPage: 20,
  });

  return (
    <div className="flex flex-col gap-4 py-4">
      <div className="px-4 lg:px-6">
        <h1 className="text-2xl font-bold tracking-tight">Communications</h1>
        <p className="text-muted-foreground">
          View platform communications and send announcements
        </p>
      </div>

      <div className="px-4 lg:px-6">
        <CrmCommunications
          communications={result.data}
          total={result.total}
          page={result.page}
          totalPages={result.totalPages}
        />
      </div>
    </div>
  );
}
