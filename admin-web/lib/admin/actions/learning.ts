"use server";

import { createClient } from "@/lib/supabase/server";
import { verifyAdmin } from "@/lib/admin/auth";

export async function getLearningResources(params: {
  search?: string;
  contentType?: string;
  category?: string;
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
    .from("learning_resources")
    .select("*", { count: "exact" })
    .order("created_at", { ascending: false })
    .range(from, to);

  if (params.search) {
    query = query.or(
      `title.ilike.%${params.search}%,description.ilike.%${params.search}%`
    );
  }
  if (params.contentType) {
    query = query.eq("content_type", params.contentType);
  }
  if (params.category) {
    query = query.eq("category", params.category);
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

export async function getLearningResourceById(id: string) {
  await verifyAdmin();
  const supabase = await createClient();
  const { data, error } = await supabase
    .from("learning_resources")
    .select("*")
    .eq("id", id)
    .single();
  if (error) throw new Error(error.message);
  return data;
}

export async function createLearningResource(formData: {
  title: string;
  description?: string;
  content_type: string;
  content_url?: string;
  thumbnail_url?: string;
  category?: string;
  tags?: string[];
  target_audience?: string[];
  is_active?: boolean;
  is_featured?: boolean;
}) {
  const admin = await verifyAdmin();
  const supabase = await createClient();

  const { data, error } = await supabase
    .from("learning_resources")
    .insert({
      ...formData,
      created_by: admin.id,
    })
    .select()
    .single();

  if (error) throw new Error(error.message);

  await supabase.from("admin_audit_logs").insert({
    admin_id: admin.id,
    action: "create_learning_resource",
    target_type: "learning_resource",
    target_id: data.id,
    details: { title: formData.title },
  });

  return data;
}

export async function updateLearningResource(
  id: string,
  formData: {
    title?: string;
    description?: string;
    content_type?: string;
    content_url?: string;
    thumbnail_url?: string;
    category?: string;
    tags?: string[];
    target_audience?: string[];
    is_active?: boolean;
    is_featured?: boolean;
  }
) {
  const admin = await verifyAdmin();
  const supabase = await createClient();

  const { data, error } = await supabase
    .from("learning_resources")
    .update({ ...formData, updated_at: new Date().toISOString() })
    .eq("id", id)
    .select()
    .single();

  if (error) throw new Error(error.message);

  await supabase.from("admin_audit_logs").insert({
    admin_id: admin.id,
    action: "update_learning_resource",
    target_type: "learning_resource",
    target_id: id,
    details: { changes: Object.keys(formData) },
  });

  return data;
}

export async function deleteLearningResource(id: string) {
  const admin = await verifyAdmin();
  const supabase = await createClient();

  const { error } = await supabase
    .from("learning_resources")
    .delete()
    .eq("id", id);

  if (error) throw new Error(error.message);

  await supabase.from("admin_audit_logs").insert({
    admin_id: admin.id,
    action: "delete_learning_resource",
    target_type: "learning_resource",
    target_id: id,
  });

  return { success: true };
}

export async function toggleLearningFeatured(id: string, featured: boolean) {
  const admin = await verifyAdmin();
  const supabase = await createClient();

  const { error } = await supabase
    .from("learning_resources")
    .update({ is_featured: featured, updated_at: new Date().toISOString() })
    .eq("id", id);

  if (error) throw new Error(error.message);

  await supabase.from("admin_audit_logs").insert({
    admin_id: admin.id,
    action: featured ? "feature_learning_resource" : "unfeature_learning_resource",
    target_type: "learning_resource",
    target_id: id,
  });

  return { success: true };
}
