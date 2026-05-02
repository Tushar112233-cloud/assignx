import { getContentOverview } from "@/lib/admin/actions/crm";
import { CrmContentControl } from "@/components/admin/crm/crm-content-control";

export const metadata = {
  title: "Content Control - CRM - AssignX Admin",
};

export default async function CrmContentPage() {
  const content = await getContentOverview();

  return (
    <div className="flex flex-col gap-4 py-4">
      <div className="px-4 lg:px-6">
        <h1 className="text-2xl font-bold tracking-tight">Content Control</h1>
        <p className="text-muted-foreground">
          Manage all platform content from one place
        </p>
      </div>

      <div className="px-4 lg:px-6">
        <CrmContentControl content={content} />
      </div>
    </div>
  );
}
