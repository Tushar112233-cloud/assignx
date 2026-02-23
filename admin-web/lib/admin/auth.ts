import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

export type AdminSession = {
  id: string;
  profileId: string;
  email: string;
  role: string;
  permissions: Record<string, boolean> | null;
};

/**
 * Verifies the current user is an admin.
 * Redirects to /login if not authenticated or not an admin.
 * Updates last_active_at on each verification.
 */
export async function verifyAdmin(): Promise<AdminSession> {
  const supabase = await createClient();

  const { data: { user }, error: authError } = await supabase.auth.getUser();

  if (authError || !user) {
    redirect("/login");
  }

  const { data: admin, error: adminError } = await supabase
    .from("admins")
    .select("id, profile_id, email, admin_role, permissions, is_active")
    .eq("profile_id", user.id)
    .single();

  if (adminError || !admin || admin.is_active === false) {
    redirect("/login");
  }

  // Update last_active_at
  await supabase
    .from("admins")
    .update({ last_active_at: new Date().toISOString() })
    .eq("id", admin.id);

  return {
    id: admin.id,
    profileId: admin.profile_id,
    email: admin.email || user.email || "",
    role: admin.admin_role,
    permissions: admin.permissions as Record<string, boolean> | null,
  };
}
