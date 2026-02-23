"use server";

import { createClient } from "@/lib/supabase/server";
import { verifyAdmin } from "@/lib/admin/auth";

export async function getExperts(params: {
  search?: string;
  status?: string;
  category?: string;
  page?: number;
  perPage?: number;
}) {
  await verifyAdmin();
  const supabase = await createClient();
  const page = params.page || 1;
  const perPage = params.perPage || 20;
  const offset = (page - 1) * perPage;

  try {
    let query = supabase
      .from("experts")
      .select(
        "id, user_id, category, hourly_rate, verification_status, is_featured, bio, created_at, profiles!user_id(id, full_name, email, avatar_url, is_active)",
        { count: "exact" }
      )
      .range(offset, offset + perPage - 1)
      .order("created_at", { ascending: false });

    if (params.search) {
      query = query.or(
        `bio.ilike.%${params.search}%,profiles.full_name.ilike.%${params.search}%`
      );
    }
    if (params.status && params.status !== "all") {
      query = query.eq("verification_status", params.status);
    }
    if (params.category && params.category !== "all") {
      query = query.eq("category", params.category);
    }

    const { data, count } = await query;

    return {
      data: (data || []).map((e: any) => ({
        id: e.id,
        profile_id: e.user_id,
        full_name: e.profiles?.full_name || "Unknown",
        email: e.profiles?.email || "",
        avatar_url: e.profiles?.avatar_url,
        is_active: e.profiles?.is_active ?? true,
        category: e.category,
        hourly_rate: e.hourly_rate,
        verification_status: e.verification_status || "pending",
        is_featured: e.is_featured || false,
        bio: e.bio,
        qualifications: null,
        created_at: e.created_at,
      })),
      total: count || 0,
      page,
      per_page: perPage,
      total_pages: Math.ceil((count || 0) / perPage) || 1,
    };
  } catch {
    // experts table may not exist, fallback to empty
    return { data: [], total: 0, page, per_page: perPage, total_pages: 1 };
  }
}

export async function getExpertById(id: string) {
  await verifyAdmin();
  const supabase = await createClient();

  try {
    const { data: expert, error } = await supabase
      .from("experts")
      .select(
        "*, profiles!user_id(id, full_name, email, avatar_url, is_active, phone, bio, city, created_at)"
      )
      .eq("id", id)
      .single();

    if (error) throw error;

    const { count: reviewCount } = await supabase
      .from("reviews")
      .select("id", { count: "exact", head: true })
      .eq("expert_id", id);

    const { count: sessionCount } = await supabase
      .from("sessions")
      .select("id", { count: "exact", head: true })
      .eq("expert_id", id);

    return {
      ...expert,
      full_name: expert.profiles?.full_name || "Unknown",
      email: expert.profiles?.email || "",
      avatar_url: expert.profiles?.avatar_url,
      is_active: expert.profiles?.is_active ?? true,
      phone: expert.profiles?.phone,
      city: expert.profiles?.city,
      profile_bio: expert.profiles?.bio,
      profile_created_at: expert.profiles?.created_at,
      review_count: reviewCount || 0,
      session_count: sessionCount || 0,
    };
  } catch {
    return null;
  }
}

export async function verifyExpert(expertId: string) {
  const admin = await verifyAdmin();
  const supabase = await createClient();

  try {
    const { error } = await supabase
      .from("experts")
      .update({ verification_status: "verified" })
      .eq("id", expertId);
    if (error) throw error;
  } catch {
    throw new Error("Failed to verify expert");
  }

  await supabase.from("admin_audit_logs").insert({
    admin_id: admin.id,
    action: "verify_expert",
    target_type: "expert",
    target_id: expertId,
    details: { status: "verified" },
  });

  return { success: true };
}

export async function rejectExpert(expertId: string, reason: string) {
  const admin = await verifyAdmin();
  const supabase = await createClient();

  try {
    const { error } = await supabase
      .from("experts")
      .update({ verification_status: "rejected" })
      .eq("id", expertId);
    if (error) throw error;
  } catch {
    throw new Error("Failed to reject expert");
  }

  await supabase.from("admin_audit_logs").insert({
    admin_id: admin.id,
    action: "reject_expert",
    target_type: "expert",
    target_id: expertId,
    details: { reason },
  });

  return { success: true };
}

export async function suspendExpert(expertId: string) {
  const admin = await verifyAdmin();
  const supabase = await createClient();

  try {
    const { data: expert } = await supabase
      .from("experts")
      .select("profile_id")
      .eq("id", expertId)
      .single();
    if (expert) {
      await supabase
        .from("profiles")
        .update({ is_active: false })
        .eq("id", expert.profile_id);
    }
  } catch {
    throw new Error("Failed to suspend expert");
  }

  await supabase.from("admin_audit_logs").insert({
    admin_id: admin.id,
    action: "suspend_expert",
    target_type: "expert",
    target_id: expertId,
    details: {},
  });

  return { success: true };
}

export async function createExpert(params: {
  email: string;
  full_name: string;
  headline: string;
  designation: string;
  organization?: string;
  category: string;
  hourly_rate: number;
  bio?: string;
  whatsapp_number?: string;
}) {
  const admin = await verifyAdmin();
  const supabase = await createClient();

  // Find existing profile by email
  const { data: profile } = await supabase
    .from("profiles")
    .select("id")
    .eq("email", params.email.toLowerCase().trim())
    .maybeSingle();

  if (!profile) {
    throw new Error(
      `No user found with email "${params.email}". The person must sign up on the platform first before being added as an expert.`
    );
  }

  const profileId = profile.id;

  // Check if expert record already exists
  const { data: existing } = await supabase
    .from("experts")
    .select("id")
    .eq("user_id", profileId)
    .maybeSingle();
  if (existing) throw new Error("An expert with this email already exists.");

  const { data: expert, error } = await supabase
    .from("experts")
    .insert({
      user_id: profileId,
      headline: params.headline,
      designation: params.designation,
      organization: params.organization || null,
      category: params.category,
      hourly_rate: params.hourly_rate,
      bio: params.bio || null,
      whatsapp_number: params.whatsapp_number || null,
      verification_status: "pending",
      specializations: [],
    })
    .select("id")
    .single();

  if (error) throw new Error(error.message);

  await supabase.from("admin_audit_logs").insert({
    admin_id: admin.id,
    action: "create_expert",
    target_type: "expert",
    target_id: expert.id,
    details: { email: params.email },
  });

  return { success: true, expertId: expert.id };
}

export async function featureExpert(expertId: string, featured: boolean) {
  const admin = await verifyAdmin();
  const supabase = await createClient();

  try {
    const { error } = await supabase
      .from("experts")
      .update({ is_featured: featured })
      .eq("id", expertId);
    if (error) throw error;
  } catch {
    throw new Error("Failed to update featured status");
  }

  await supabase.from("admin_audit_logs").insert({
    admin_id: admin.id,
    action: featured ? "feature_expert" : "unfeature_expert",
    target_type: "expert",
    target_id: expertId,
    details: { featured },
  });

  return { success: true };
}
