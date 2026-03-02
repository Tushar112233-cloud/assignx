import { getCustomerDetail, getCustomerNotes } from "@/lib/admin/actions/crm";
import { CrmCustomerDetail } from "@/components/admin/crm/crm-customer-detail";

export const metadata = {
  title: "Customer Detail - CRM - AssignX Admin",
};

export default async function CrmCustomerDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;

  const [data, notes] = await Promise.all([
    getCustomerDetail(id),
    getCustomerNotes(id),
  ]);

  return (
    <div className="flex flex-col gap-4 py-4">
      <div className="px-4 lg:px-6">
        <CrmCustomerDetail data={data} notes={notes} />
      </div>
    </div>
  );
}
