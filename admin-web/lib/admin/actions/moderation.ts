"use server";

import { createClient } from "@/lib/supabase/server";
import { verifyAdmin } from "@/lib/admin/auth";

export async function getFlaggedContent(params: {
  contentType?: string;
  status?: string;
  page?: number;
  perPage?: number;
}) {
  await verifyAdmin();
  const supabase = await createClient();
  const page = params.page || 1;
  const perPage = params.perPage || 20;
  const offset = (page - 1) * perPage;

  let items: any[] = [];
  let total = 0;

  try {
    if (!params.contentType || params.contentType === "campus_posts") {
      const { data, count } = await supabase
        .from("campus_posts")
        .select(
          "id, content, is_flagged, created_at, author_id, profiles!author_id(full_name, email)",
          { count: "exact" }
        )
        .eq("is_flagged", true)
        .range(offset, offset + perPage - 1)
        .order("created_at", { ascending: false });
      if (data)
        items.push(
          ...data.map((d: any) => ({ ...d, content_type: "campus_post" }))
        );
      total += count || 0;
    }

    if (!params.contentType || params.contentType === "listings") {
      const { data, count } = await supabase
        .from("marketplace_listings")
        .select(
          "id, title, description, is_flagged, created_at, seller_id, profiles!seller_id(full_name, email)",
          { count: "exact" }
        )
        .eq("is_flagged", true)
        .range(offset, offset + perPage - 1)
        .order("created_at", { ascending: false });
      if (data)
        items.push(
          ...data.map((d: any) => ({
            ...d,
            content_type: "listing",
            content: d.title + ": " + d.description,
          }))
        );
      total += count || 0;
    }
  } catch {
    // Tables may not exist yet, return empty
  }

  return {
    data: items,
    total,
    page,
    per_page: perPage,
    total_pages: Math.ceil(total / perPage) || 1,
  };
}

export async function moderateContent(
  contentType: string,
  contentId: string,
  action: string,
  reason: string
) {
  const admin = await verifyAdmin();
  const supabase = await createClient();

  const table =
    contentType === "campus_post"
      ? "campus_posts"
      : contentType === "listing"
        ? "marketplace_listings"
        : "chat_messages";

  try {
    if (action === "remove") {
      await supabase.from(table).delete().eq("id", contentId);
    } else if (action === "approve") {
      await supabase.from(table).update({ is_flagged: false }).eq("id", contentId);
    } else if (action === "warn") {
      await supabase.from(table).update({ is_flagged: false }).eq("id", contentId);
    }
  } catch {
    // Table may not exist
  }

  await supabase.from("admin_audit_logs").insert({
    admin_id: admin.id,
    action: `moderate_${action}`,
    target_type: contentType,
    target_id: contentId,
    details: { reason, action },
  });

  return { success: true };
}
