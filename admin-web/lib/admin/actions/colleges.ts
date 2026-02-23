"use server";

import { createClient } from "@/lib/supabase/server";
import { verifyAdmin } from "@/lib/admin/auth";

export async function getColleges(params: {
  search?: string;
  page?: number;
  perPage?: number;
}) {
  await verifyAdmin();
  const supabase = await createClient();

  // Get universities with student counts via students table
  const { data: universities, error: uniError } = await supabase
    .from("universities")
    .select("id, name, short_name, city, state, is_active")
    .eq("is_active", true)
    .order("name");

  if (uniError) throw new Error(uniError.message);

  // Get student counts per university
  const { data: students, error: studError } = await supabase
    .from("students")
    .select("university_id");

  if (studError) throw new Error(studError.message);

  // Also get profiles linked via college_id
  const { data: collegeProfiles, error: cpError } = await supabase
    .from("profiles")
    .select("college_id, user_type")
    .not("college_id", "is", null);

  if (cpError) throw new Error(cpError.message);

  // Build counts per university
  const studentCounts: Record<string, number> = {};
  students?.forEach((s) => {
    if (s.university_id) {
      studentCounts[s.university_id] = (studentCounts[s.university_id] || 0) + 1;
    }
  });

  const profileCounts: Record<string, { total: number; student: number; professional: number; doer: number }> = {};
  collegeProfiles?.forEach((p) => {
    if (p.college_id) {
      if (!profileCounts[p.college_id]) {
        profileCounts[p.college_id] = { total: 0, student: 0, professional: 0, doer: 0 };
      }
      profileCounts[p.college_id].total++;
      const type = p.user_type as string;
      if (type === "student") profileCounts[p.college_id].student++;
      else if (type === "professional") profileCounts[p.college_id].professional++;
      else if (type === "doer") profileCounts[p.college_id].doer++;
    }
  });

  let colleges = (universities || []).map((u) => ({
    id: u.id,
    college_name: u.name,
    short_name: u.short_name,
    city: u.city,
    state: u.state,
    total_users: (profileCounts[u.id]?.total || 0) + (studentCounts[u.id] || 0),
    students: (profileCounts[u.id]?.student || 0) + (studentCounts[u.id] || 0),
    professionals: profileCounts[u.id]?.professional || 0,
    doers: profileCounts[u.id]?.doer || 0,
  }));

  if (params.search) {
    const search = params.search.toLowerCase();
    colleges = colleges.filter((c) =>
      c.college_name.toLowerCase().includes(search) ||
      (c.short_name && c.short_name.toLowerCase().includes(search)) ||
      (c.city && c.city.toLowerCase().includes(search))
    );
  }

  colleges.sort((a, b) => b.total_users - a.total_users);

  const page = params.page || 1;
  const perPage = params.perPage || 20;
  const total = colleges.length;
  const totalPages = Math.ceil(total / perPage);
  const sliced = colleges.slice((page - 1) * perPage, page * perPage);

  return { data: sliced, total, page, perPage, totalPages };
}

export async function getCollegeDetail(collegeId: string) {
  await verifyAdmin();
  const supabase = await createClient();

  // Get university info
  const { data: university, error: uniError } = await supabase
    .from("universities")
    .select("id, name, short_name, city, state, country, is_active")
    .eq("id", collegeId)
    .single();

  if (uniError) throw new Error(uniError.message);

  // Get users linked via college_id
  const { data: users, error } = await supabase
    .from("profiles")
    .select("id, full_name, email, user_type, avatar_url, created_at, is_active")
    .eq("college_id", collegeId)
    .order("created_at", { ascending: false });

  if (error) throw new Error(error.message);

  const breakdown: Record<string, number> = {};
  users?.forEach((u) => {
    const type = u.user_type || "unknown";
    breakdown[type] = (breakdown[type] || 0) + 1;
  });

  return {
    collegeName: university.name,
    shortName: university.short_name,
    city: university.city,
    state: university.state,
    totalUsers: users?.length || 0,
    typeBreakdown: breakdown,
    users: users || [],
  };
}
