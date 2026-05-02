import { getCrmDashboard } from "@/lib/admin/actions/crm";
import { CrmOverviewCards } from "@/components/admin/crm/crm-overview-cards";
import { CrmRevenuePipeline } from "@/components/admin/crm/crm-revenue-pipeline";
import { CrmSegmentsOverview } from "@/components/admin/crm/crm-segments-overview";
import { CrmTopCustomers } from "@/components/admin/crm/crm-top-customers";

export const metadata = { title: "CRM - AssignX Admin" };

export default async function CrmDashboardPage() {
  const data = await getCrmDashboard();

  return (
    <div className="flex flex-col gap-6 py-4">
      <div className="px-4 lg:px-6">
        <h1 className="text-2xl font-bold tracking-tight">CRM Dashboard</h1>
        <p className="text-muted-foreground">
          Customer relationship management and platform insights
        </p>
      </div>

      <div className="px-4 lg:px-6">
        <CrmOverviewCards
          totalCustomers={data.totalCustomers}
          activeThisMonth={data.activeThisMonth}
          newThisMonth={data.newThisMonth}
          churnRate={data.churnRate}
        />
      </div>

      <div className="px-4 lg:px-6">
        <CrmRevenuePipeline pipeline={data.pipeline} />
      </div>

      <div className="grid gap-6 px-4 lg:px-6 lg:grid-cols-2">
        <CrmSegmentsOverview segments={data.segments} />
        <CrmTopCustomers customers={data.topCustomers} />
      </div>
    </div>
  );
}
