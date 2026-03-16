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

  // Use POST upsert-by-key endpoint; PUT /settings/:id expects a MongoDB ObjectId
  await serverFetch(`/api/admin/settings`, {
    method: "POST",
    body: JSON.stringify({ key, value }),
  });

  return { success: true };
}

export async function updateSettings(
  settings: { key: string; value: unknown }[]
) {
  await verifyAdmin();

  // No batch endpoint exists; upsert each setting individually via POST
  for (const s of settings) {
    await serverFetch(`/api/admin/settings`, {
      method: "POST",
      body: JSON.stringify({ key: s.key, value: s.value }),
    });
  }

  return { success: true };
}
