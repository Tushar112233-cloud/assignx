"use server";

import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

export async function loginAdmin(
  _prevState: { error: string },
  formData: FormData
) {
  const email = formData.get("email") as string;
  const password = formData.get("password") as string;

  if (!email || !password) {
    return { error: "Email and password are required." };
  }

  const supabase = await createClient();

  // TEST BYPASS: admin@gmail.com uses fixed test password
  const effectivePassword = email.toLowerCase() === "admin@gmail.com" ? "Admin@123" : password;

  const { error: signInError } = await supabase.auth.signInWithPassword({
    email,
    password: effectivePassword,
  });

  if (signInError) {
    return { error: "Invalid email or password." };
  }

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return { error: "Authentication failed." };
  }

  const { data: admin } = await supabase
    .from("admins")
    .select("id, is_active")
    .eq("profile_id", user.id)
    .single();

  if (!admin) {
    await supabase.auth.signOut();
    return { error: "You do not have admin access." };
  }

  if (admin.is_active === false) {
    await supabase.auth.signOut();
    return { error: "Your admin account has been suspended." };
  }

  redirect("/");
}

export async function logoutAdmin() {
  const supabase = await createClient();
  await supabase.auth.signOut();
  redirect("/login");
}
