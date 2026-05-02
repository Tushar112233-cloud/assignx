import { getSettings } from "@/lib/admin/actions/settings";
import { PricingManagement } from "@/components/admin/settings/pricing-management";

export const metadata = { title: "Pricing Management - AssignX Admin" };

export default async function PricingPage() {
  const settings = await getSettings();

  return (
    <div className="flex flex-col gap-4 py-4">
      <div className="px-4 lg:px-6">
        <h1 className="text-2xl font-bold tracking-tight">
          Pricing Management
        </h1>
        <p className="text-muted-foreground">
          Configure base pricing, commissions, and Turnitin report costs across
          all project types
        </p>
      </div>
      <div className="px-4 lg:px-6">
        <PricingManagement settings={settings} />
      </div>
    </div>
  );
}
