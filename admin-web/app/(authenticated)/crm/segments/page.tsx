import { getCustomerSegments } from "@/lib/admin/actions/crm";
import { CrmSegmentList } from "@/components/admin/crm/crm-segment-list";

export const metadata = { title: "Customer Segments - CRM - AssignX Admin" };

export default async function CrmSegmentsPage() {
  const segments = await getCustomerSegments();

  return (
    <div className="flex flex-col gap-4 py-4">
      <div className="px-4 lg:px-6">
        <h1 className="text-2xl font-bold tracking-tight">
          Customer Segments
        </h1>
        <p className="text-muted-foreground">
          Pre-built customer segments for targeted outreach and analysis
        </p>
      </div>

      <div className="px-4 lg:px-6">
        <CrmSegmentList segments={segments} />
      </div>
    </div>
  );
}
