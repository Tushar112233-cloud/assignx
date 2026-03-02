"use server";

import { verifyAdmin, serverFetch } from "@/lib/admin/auth";

export async function getSettings() {
  await verifyAdmin();
  try {
    const result = await serverFetch(`/api/admin/settings`);
    const arr = result.settings || result || [];
    // Group settings by category for SettingsForm component
    if (Array.isArray(arr)) {
      const grouped: Record<string, { id: string; key: string; value: unknown; description: string | null }[]> = {};
      for (const s of arr) {
        const cat = s.category || "general";
        if (!grouped[cat]) grouped[cat] = [];
        grouped[cat].push({
          id: s._id || s.id || s.key,
          key: s.key,
          value: s.value,
          description: s.description || null,
        });
      }
      return grouped;
    }
    return arr;
  } catch {
    return {};
  }
}

export async function updateSetting(key: string, value: unknown) {
  await verifyAdmin();

  await serverFetch(`/api/admin/settings/${key}`, {
    method: "PUT",
    body: JSON.stringify({ value }),
  });

  return { success: true };
}

export async function updateSettings(
  settings: { key: string; value: unknown }[]
) {
  await verifyAdmin();

  await serverFetch(`/api/admin/settings/batch`, {
    method: "PUT",
    body: JSON.stringify({ settings }),
  });

  return { success: true };
}
