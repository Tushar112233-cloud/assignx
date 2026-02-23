"use server";

import { createClient } from "@/lib/supabase/server";
import { verifyAdmin } from "@/lib/admin/auth";

export async function getBanners(params: {
  search?: string;
  location?: string;
  active?: string;
  page?: number;
  perPage?: number;
}) {
  await verifyAdmin();
  const supabase = await createClient();
  const page = params.page || 1;
  const perPage = params.perPage || 20;
  const from = (page - 1) * perPage;
  const to = from + perPage - 1;

  let query = supabase
    .from("banners")
    .select("*", { count: "exact" })
    .order("display_order", { ascending: true })
    .range(from, to);

  if (params.search) {
    query = query.or(
      `title.ilike.%${params.search}%,subtitle.ilike.%${params.search}%`
    );
  }
  if (params.location) {
    query = query.eq("display_location", params.location);
  }
  if (params.active === "true") {
    query = query.eq("is_active", true);
  } else if (params.active === "false") {
    query = query.eq("is_active", false);
  }

  const { data, count, error } = await query;
  if (error) throw new Error(error.message);

  return {
    data: data || [],
    total: count || 0,
    page,
    perPage,
    totalPages: Math.ceil((count || 0) / perPage),
  };
}

export async function getBannerById(id: string) {
  await verifyAdmin();
  const supabase = await createClient();
  const { data, error } = await supabase
    .from("banners")
    .select("*")
    .eq("id", id)
    .single();
  if (error) throw new Error(error.message);
  return data;
}

export async function createBanner(formData: {
  title: string;
  subtitle?: string;
  image_url?: string;
  image_url_mobile?: string;
  display_location?: string;
  display_order?: number;
  start_date?: string;
  end_date?: string;
  is_active?: boolean;
  target_roles?: string[];
  target_user_types?: string[];
  cta_text?: string;
  cta_url?: string;
  cta_action?: string;
}) {
  const admin = await verifyAdmin();
  const supabase = await createClient();

  const { data, error } = await supabase
    .from("banners")
    .insert(formData)
    .select()
    .single();

  if (error) throw new Error(error.message);

  await supabase.from("admin_audit_logs").insert({
    admin_id: admin.id,
    action: "create_banner",
    target_type: "banner",
    target_id: data.id,
    details: { title: formData.title },
  });

  return data;
}

export async function updateBanner(
  id: string,
  formData: {
    title?: string;
    subtitle?: string;
    image_url?: string;
    image_url_mobile?: string;
    display_location?: string;
    display_order?: number;
    start_date?: string;
    end_date?: string;
    is_active?: boolean;
    target_roles?: string[];
    target_user_types?: string[];
    cta_text?: string;
    cta_url?: string;
    cta_action?: string;
  }
) {
  const admin = await verifyAdmin();
  const supabase = await createClient();

  const { data, error } = await supabase
    .from("banners")
    .update({ ...formData, updated_at: new Date().toISOString() })
    .eq("id", id)
    .select()
    .single();

  if (error) throw new Error(error.message);

  await supabase.from("admin_audit_logs").insert({
    admin_id: admin.id,
    action: "update_banner",
    target_type: "banner",
    target_id: id,
    details: { changes: Object.keys(formData) },
  });

  return data;
}

export async function deleteBanner(id: string) {
  const admin = await verifyAdmin();
  const supabase = await createClient();

  const { error } = await supabase.from("banners").delete().eq("id", id);
  if (error) throw new Error(error.message);

  await supabase.from("admin_audit_logs").insert({
    admin_id: admin.id,
    action: "delete_banner",
    target_type: "banner",
    target_id: id,
  });

  return { success: true };
}

export async function toggleBannerActive(id: string, active: boolean) {
  const admin = await verifyAdmin();
  const supabase = await createClient();

  const { error } = await supabase
    .from("banners")
    .update({ is_active: active, updated_at: new Date().toISOString() })
    .eq("id", id);

  if (error) throw new Error(error.message);

  await supabase.from("admin_audit_logs").insert({
    admin_id: admin.id,
    action: active ? "activate_banner" : "deactivate_banner",
    target_type: "banner",
    target_id: id,
  });

  return { success: true };
}
