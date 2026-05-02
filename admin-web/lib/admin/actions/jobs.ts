"use server";

import { verifyAdmin, serverFetch } from "@/lib/admin/auth";

/**
 * Normalize a raw job object from the API into a consistent format
 * for admin components.
 */
function normalizeJob(raw: Record<string, unknown>) {
  return {
    id: (raw._id || raw.id || "") as string,
    title: (raw.title || "") as string,
    company: (raw.company || "") as string,
    company_logo: (raw.company_logo || raw.companyLogo || null) as string | null,
    location: (raw.location || "") as string,
    type: (raw.type || "full-time") as string,
    category: (raw.category || "") as string,
    is_remote: Boolean(raw.is_remote !== undefined ? raw.is_remote : raw.isRemote),
    salary_raw: (raw.salary_raw || raw.salaryRaw || raw.salary || null) as {
      min: number;
      max: number;
      currency: string;
    } | null,
    salary_display: (raw.salary || null) as string | null,
    description: (raw.description || "") as string,
    requirements: (raw.requirements || []) as string[],
    skills: (raw.skills || raw.tags || []) as string[],
    apply_url: (raw.apply_url || raw.applyUrl || null) as string | null,
    is_active: Boolean(
      raw.is_active !== undefined ? raw.is_active : raw.isActive !== undefined ? raw.isActive : true
    ),
    application_count: (raw.application_count ?? raw.applicationCount ?? 0) as number,
    created_at: (raw.created_at || raw.createdAt || "") as string,
    updated_at: (raw.updated_at || raw.updatedAt || "") as string,
  };
}

export async function getJobs(params: {
  search?: string;
  category?: string;
  type?: string;
  page?: number;
  perPage?: number;
}) {
  await verifyAdmin();

  const query = new URLSearchParams();
  if (params.search) query.set("search", params.search);
  if (params.category) query.set("category", params.category);
  if (params.type) query.set("type", params.type);
  if (params.page) query.set("page", String(params.page));
  if (params.perPage) query.set("perPage", String(params.perPage));

  try {
    const result = await serverFetch(`/api/jobs?${query.toString()}`);
    const arr = result.jobs || result.data || [];
    return {
      data: arr.map((j: Record<string, unknown>) => normalizeJob(j)),
      total: result.total || arr.length,
      page: result.page || params.page || 1,
      total_pages:
        result.totalPages ||
        result.total_pages ||
        Math.ceil((result.total || arr.length) / (params.perPage || 20)),
    };
  } catch {
    return { data: [], total: 0, page: params.page || 1, total_pages: 1 };
  }
}

export async function getJobById(id: string) {
  await verifyAdmin();

  try {
    const result = await serverFetch(`/api/jobs/${id}`);
    const raw = result.job || result;
    return normalizeJob(raw);
  } catch {
    return null;
  }
}

export async function createJob(params: {
  title: string;
  company: string;
  companyLogo?: string;
  location: string;
  type: string;
  category: string;
  isRemote: boolean;
  salary?: { min: number; max: number; currency: string } | null;
  description: string;
  requirements: string[];
  skills: string[];
  applyUrl?: string;
}) {
  await verifyAdmin();

  const result = await serverFetch(`/api/jobs`, {
    method: "POST",
    body: JSON.stringify({
      title: params.title,
      company: params.company,
      companyLogo: params.companyLogo || undefined,
      location: params.location,
      type: params.type,
      category: params.category,
      isRemote: params.isRemote,
      salary: params.salary || undefined,
      description: params.description,
      requirements: params.requirements,
      skills: params.skills,
      applyUrl: params.applyUrl || undefined,
    }),
  });

  return { success: true, jobId: result.job?.id || result.job?._id };
}

export async function updateJob(
  id: string,
  params: Record<string, unknown>
) {
  await verifyAdmin();

  await serverFetch(`/api/jobs/${id}`, {
    method: "PUT",
    body: JSON.stringify(params),
  });

  return { success: true };
}

export async function deactivateJob(id: string) {
  await verifyAdmin();

  await serverFetch(`/api/jobs/${id}`, {
    method: "DELETE",
  });

  return { success: true };
}

export type JobApplication = {
  id: string;
  job_id: string;
  user_id: string;
  applicant_name: string;
  applicant_email: string;
  resume_url: string;
  cover_letter: string | null;
  status: string;
  created_at: string;
  updated_at: string;
};

function normalizeApplication(raw: Record<string, unknown>): JobApplication {
  return {
    id: (raw._id || raw.id || "") as string,
    job_id: (raw.job_id || raw.jobId || "") as string,
    user_id: (raw.user_id || raw.userId || "") as string,
    applicant_name: (raw.applicant_name || raw.applicantName || "Unknown") as string,
    applicant_email: (raw.applicant_email || raw.applicantEmail || "") as string,
    resume_url: (raw.resume_url || raw.resumeUrl || "") as string,
    cover_letter: (raw.cover_letter || raw.coverLetter || null) as string | null,
    status: (raw.status || "applied") as string,
    created_at: (raw.created_at || raw.createdAt || "") as string,
    updated_at: (raw.updated_at || raw.updatedAt || "") as string,
  };
}

export async function getJobApplications(jobId: string) {
  await verifyAdmin();

  try {
    const result = await serverFetch(`/api/jobs/${jobId}/applications`);
    const arr = result.applications || [];
    return {
      data: arr.map((a: Record<string, unknown>) => normalizeApplication(a)),
      total: result.total || arr.length,
    };
  } catch {
    return { data: [], total: 0 };
  }
}

export async function updateApplicationStatus(jobId: string, applicationId: string, status: string) {
  await verifyAdmin();

  await serverFetch(`/api/jobs/${jobId}/applications/${applicationId}/status`, {
    method: "PUT",
    body: JSON.stringify({ status }),
  });

  return { success: true };
}

export async function activateJob(id: string) {
  await verifyAdmin();

  await serverFetch(`/api/jobs/${id}`, {
    method: "PUT",
    body: JSON.stringify({ isActive: true }),
  });

  return { success: true };
}
