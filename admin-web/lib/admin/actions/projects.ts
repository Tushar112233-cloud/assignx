"use server";

import { verifyAdmin, serverFetch } from "@/lib/admin/auth";

export async function getProjects(params: {
  search?: string;
  status?: string;
  dateFrom?: string;
  dateTo?: string;
  supervisorId?: string;
  doerId?: string;
  page?: number;
  perPage?: number;
}) {
  await verifyAdmin();

  const query = new URLSearchParams();
  if (params.search) query.set("search", params.search);
  if (params.status) query.set("status", params.status);
  if (params.dateFrom) query.set("dateFrom", params.dateFrom);
  if (params.dateTo) query.set("dateTo", params.dateTo);
  if (params.supervisorId) query.set("supervisorId", params.supervisorId);
  if (params.doerId) query.set("doerId", params.doerId);
  if (params.page) query.set("page", String(params.page));
  if (params.perPage) query.set("perPage", String(params.perPage));

  return serverFetch(`/api/admin/projects?${query.toString()}`);
}

export async function getProjectById(id: string) {
  await verifyAdmin();
  return serverFetch(`/api/projects/${id}`);
}

export async function updateProjectStatus(
  projectId: string,
  newStatus: string,
  reason?: string
) {
  await verifyAdmin();

  await serverFetch(`/api/projects/${projectId}/status`, {
    method: "PUT",
    body: JSON.stringify({ status: newStatus, reason }),
  });

  return { success: true };
}

export async function updateProjectQuote(
  projectId: string,
  userQuote: number,
  doerPayout: number,
  supervisorCommission?: number
) {
  await verifyAdmin();

  const platformFee = userQuote - doerPayout - (supervisorCommission || 0);

  await serverFetch(`/api/projects/${projectId}`, {
    method: "PUT",
    body: JSON.stringify({
      userQuote,
      doerPayout,
      supervisorCommission: supervisorCommission || 0,
      platformFee,
      status: "quoted",
    }),
  });

  return { success: true };
}

export async function reassignProject(
  projectId: string,
  newDoerId: string,
  reason?: string
) {
  await verifyAdmin();

  await serverFetch(`/api/projects/${projectId}/assign-doer`, {
    method: "PUT",
    body: JSON.stringify({ doerId: newDoerId, reason }),
  });

  return { success: true };
}
