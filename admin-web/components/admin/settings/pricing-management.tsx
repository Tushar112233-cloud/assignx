"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { TurnitinPricing } from "@/components/admin/settings/turnitin-pricing";
import { ProjectPricing } from "@/components/admin/settings/project-pricing";
import { QuotePricing } from "@/components/admin/settings/quote-pricing";
import { updateSettings } from "@/lib/admin/actions/settings";
import { toast } from "sonner";

type SettingsGroup = Record<
  string,
  { id: string; key: string; value: unknown; description: string | null }[]
>;

export function PricingManagement({ settings }: { settings: SettingsGroup }) {
  const router = useRouter();
  const [saving, setSaving] = useState(false);

  const handleSave = async (
    updates: { key: string; value: unknown }[],
    successMessage: string
  ) => {
    setSaving(true);
    try {
      await updateSettings(updates);
      toast.success(successMessage);
      router.refresh();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to save");
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="grid gap-6 xl:grid-cols-2">
      <div className="xl:col-span-2">
        <ProjectPricing
          settings={settings}
          onSave={(updates) => handleSave(updates, "Project pricing saved")}
          saving={saving}
        />
      </div>
      <QuotePricing
        settings={settings}
        onSave={(updates) => handleSave(updates, "Quote settings saved")}
        saving={saving}
      />
      <TurnitinPricing
        settings={settings}
        onSave={(updates) => handleSave(updates, "Turnitin pricing saved")}
        saving={saving}
      />
    </div>
  );
}
