"use server";

import { verifyAdmin, serverFetch } from "@/lib/admin/auth";

/** Normalized investor shape for admin components */
export type AdminInvestor = {
  id: string;
  name: string;
  firm: string;
  avatar_url: string | null;
  bio: string;
  funding_stages: string[];
  sectors: string[];
  ticket_size: { min: number; max: number; currency: string } | null;
  ticket_size_formatted: string;
  deal_count: number;
  linkedin_url: string | null;
  website_url: string | null;
  contact_email: string | null;
  is_active: boolean;
  created_at: string;
};

/** Normalized pitch deck shape for admin components */
export type AdminPitchDeck = {
  id: string;
  user_id: string;
  submitter_name: string;
  submitter_email: string;
  title: string;
  description: string | null;
  file_url: string;
  investor_id: string | null;
  status: string;
  feedback: string | null;
  created_at: string;
};

function normalizeInvestor(raw: Record<string, unknown>): AdminInvestor {
  return {
    id: (raw._id || raw.id || "") as string,
    name: (raw.name || "") as string,
    firm: (raw.firm || "") as string,
    avatar_url: (raw.avatar_url || raw.avatarUrl || null) as string | null,
    bio: (raw.bio || "") as string,
    funding_stages: (raw.funding_stages || raw.fundingStages || []) as string[],
    sectors: (raw.sectors || []) as string[],
    ticket_size: (raw.ticket_size || raw.ticketSize || null) as { min: number; max: number; currency: string } | null,
    ticket_size_formatted: (raw.ticket_size_formatted || raw.ticketSize || "Undisclosed") as string,
    deal_count: (raw.deal_count ?? raw.dealCount ?? raw.portfolio ?? 0) as number,
    linkedin_url: (raw.linkedin_url || raw.linkedinUrl || null) as string | null,
    website_url: (raw.website_url || raw.websiteUrl || null) as string | null,
    contact_email: (raw.contact_email || raw.contactEmail || null) as string | null,
    is_active: Boolean(raw.is_active !== undefined ? raw.is_active : raw.isActive !== undefined ? raw.isActive : true),
    created_at: (raw.created_at || raw.createdAt || "") as string,
  };
}

function normalizePitchDeck(raw: Record<string, unknown>): AdminPitchDeck {
  return {
    id: (raw._id || raw.id || "") as string,
    user_id: (raw.user_id || raw.userId || "") as string,
    submitter_name: (raw.submitter_name || raw.submitterName || "") as string,
    submitter_email: (raw.submitter_email || raw.submitterEmail || "") as string,
    title: (raw.title || raw.name || "") as string,
    description: (raw.description || null) as string | null,
    file_url: (raw.file_url || raw.fileUrl || "") as string,
    investor_id: (raw.investor_id || raw.investorId || null) as string | null,
    status: (raw.status || "pending") as string,
    feedback: (raw.feedback || null) as string | null,
    created_at: (raw.created_at || raw.createdAt || raw.uploaded_at || raw.uploadedAt || "") as string,
  };
}

export async function getInvestors(params: {
  search?: string;
  stage?: string;
  sector?: string;
  page?: number;
  perPage?: number;
}) {
  await verifyAdmin();

  const query = new URLSearchParams();
  if (params.search) query.set("search", params.search);
  if (params.stage) query.set("stage", params.stage);
  if (params.sector) query.set("sector", params.sector);
  if (params.page) query.set("page", String(params.page));
  if (params.perPage) query.set("perPage", String(params.perPage));

  try {
    const result = await serverFetch(`/api/investors?${query.toString()}`);
    const arr = result.investors || [];
    return {
      data: arr.map((e: Record<string, unknown>) => normalizeInvestor(e)),
      total: result.total || arr.length,
      page: result.page || params.page || 1,
      total_pages: result.totalPages || Math.ceil((result.total || arr.length) / (params.perPage || 20)),
    };
  } catch {
    return { data: [], total: 0, page: params.page || 1, total_pages: 1 };
  }
}

export async function createInvestor(params: {
  name: string;
  firm: string;
  bio: string;
  fundingStages: string[];
  sectors: string[];
  ticketSize?: { min: number; max: number; currency: string };
  dealCount?: number;
  linkedinUrl?: string;
  websiteUrl?: string;
  contactEmail?: string;
  avatarUrl?: string;
}) {
  await verifyAdmin();

  const result = await serverFetch(`/api/investors`, {
    method: "POST",
    body: JSON.stringify(params),
  });

  return { success: true, investorId: result.investor?.id || result.investor?._id };
}

export async function updateInvestor(id: string, params: Record<string, unknown>) {
  await verifyAdmin();

  await serverFetch(`/api/investors/${id}`, {
    method: "PUT",
    body: JSON.stringify(params),
  });

  return { success: true };
}

export async function deactivateInvestor(id: string) {
  await verifyAdmin();

  await serverFetch(`/api/investors/${id}`, {
    method: "DELETE",
  });

  return { success: true };
}

export async function toggleInvestorActive(id: string, isActive: boolean) {
  await verifyAdmin();

  await serverFetch(`/api/investors/${id}`, {
    method: "PUT",
    body: JSON.stringify({ isActive }),
  });

  return { success: true };
}

export async function getPitchDecks(params: {
  status?: string;
  page?: number;
  perPage?: number;
}) {
  await verifyAdmin();

  const query = new URLSearchParams();
  if (params.status) query.set("status", params.status);
  if (params.page) query.set("page", String(params.page));
  if (params.perPage) query.set("perPage", String(params.perPage));

  try {
    const result = await serverFetch(`/api/investors/pitch-decks/all?${query.toString()}`);
    const arr = result.pitchDecks || [];
    return {
      data: arr.map((d: Record<string, unknown>) => normalizePitchDeck(d)),
      total: result.total || arr.length,
      page: result.page || params.page || 1,
      total_pages: result.totalPages || Math.ceil((result.total || arr.length) / (params.perPage || 20)),
    };
  } catch {
    return { data: [], total: 0, page: params.page || 1, total_pages: 1 };
  }
}

export async function getInvestorById(id: string) {
  await verifyAdmin();

  try {
    const result = await serverFetch(`/api/investors/${id}`);
    const raw = result.investor || result;
    return normalizeInvestor(raw);
  } catch {
    return null;
  }
}

export async function getInvestorPitchDecks(investorId: string) {
  await verifyAdmin();

  try {
    const result = await serverFetch(`/api/investors/pitch-decks/by-investor/${investorId}`);
    const arr = result.pitchDecks || [];
    return {
      data: arr.map((d: Record<string, unknown>) => normalizePitchDeck(d)),
      total: result.total || arr.length,
    };
  } catch {
    return { data: [], total: 0 };
  }
}

export async function updatePitchDeckStatus(id: string, status: string, feedback?: string) {
  await verifyAdmin();

  await serverFetch(`/api/investors/pitch-decks/${id}/status`, {
    method: "PUT",
    body: JSON.stringify({ status, feedback }),
  });

  return { success: true };
}
