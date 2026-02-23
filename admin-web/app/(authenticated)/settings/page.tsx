import { getSettings } from "@/lib/admin/actions/settings";
import { SettingsForm } from "@/components/admin/settings/settings-form";

export const metadata = { title: "Settings - AssignX Admin" };

export default async function SettingsPage() {
  const settings = await getSettings();

  return (
    <div className="flex flex-col gap-4 py-4">
      <div className="px-4 lg:px-6">
        <h1 className="text-2xl font-bold tracking-tight">Settings</h1>
        <p className="text-muted-foreground">
          Configure platform settings and preferences
        </p>
      </div>
      <div className="px-4 lg:px-6">
        <SettingsForm settings={settings} />
      </div>
    </div>
  );
}
