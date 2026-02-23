"use server";

import { createClient } from "@/lib/supabase/server";
import { verifyAdmin } from "@/lib/admin/auth";

export async function getSettings() {
  await verifyAdmin();
  const supabase = await createClient();

  const { data, error } = await supabase
    .from("app_settings")
    .select("*")
    .order("category", { ascending: true });

  if (error) throw new Error(error.message);

  const grouped: Record<
    string,
    { id: string; key: string; value: unknown; description: string | null }[]
  > = {};

  data?.forEach((s) => {
    const cat = s.category || "general";
    if (!grouped[cat]) grouped[cat] = [];
    grouped[cat].push({
      id: s.id,
      key: s.key,
      value: s.value,
      description: s.description,
    });
  });

  return grouped;
}

export async function updateSetting(key: string, value: unknown) {
  const admin = await verifyAdmin();
  const supabase = await createClient();

  const { error } = await supabase
    .from("app_settings")
    .update({ value, updated_at: new Date().toISOString() })
    .eq("key", key);

  if (error) throw new Error(error.message);

  await supabase.from("admin_audit_logs").insert({
    admin_id: admin.id,
    action: "update_setting",
    target_type: "app_setting",
    target_id: key,
    details: { value },
  });

  return { success: true };
}

export async function updateSettings(
  settings: { key: string; value: unknown }[]
) {
  const admin = await verifyAdmin();
  const supabase = await createClient();

  const now = new Date().toISOString();

  for (const setting of settings) {
    const { error } = await supabase
      .from("app_settings")
      .update({ value: setting.value, updated_at: now })
      .eq("key", setting.key);

    if (error) throw new Error(error.message);
  }

  await supabase.from("admin_audit_logs").insert({
    admin_id: admin.id,
    action: "batch_update_settings",
    target_type: "app_settings",
    details: { keys: settings.map((s) => s.key) },
  });

  return { success: true };
}
