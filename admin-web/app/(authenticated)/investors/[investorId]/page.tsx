"use client";

import { useState, useEffect, useCallback } from "react";
import { useParams } from "next/navigation";
import Link from "next/link";
import { apiClient } from "@/lib/api/client";
import {
  IconArrowLeft,
  IconDownload,
  IconExternalLink,
  IconFileText,
  IconLoader2,
  IconBuildingBank,
  IconMail,
  IconBrandLinkedin,
  IconWorld,
  IconChevronDown,
  IconChevronUp,
} from "@tabler/icons-react";

// ============================================================================
// Types
// ============================================================================

interface InvestorDetail {
  id: string;
  name: string;
  firm: string;
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
}

interface PitchDeck {
  id: string;
  submitter_name: string;
  submitter_email: string;
  title: string;
  description: string | null;
  file_url: string;
  status: string;
  feedback: string | null;
  created_at: string;
}

const PITCH_STATUSES = ["pending", "reviewed", "shortlisted", "rejected"];

const statusColors: Record<string, string> = {
  pending: "bg-yellow-500/15 text-yellow-600 dark:text-yellow-400",
  reviewed: "bg-blue-500/15 text-blue-600 dark:text-blue-400",
  shortlisted: "bg-emerald-500/15 text-emerald-600 dark:text-emerald-400",
  rejected: "bg-red-500/15 text-red-600 dark:text-red-400",
};

// ============================================================================
// CSV Export
// ============================================================================

function exportToCSV(data: Record<string, string>[], filename: string) {
  if (data.length === 0) return;
  const headers = Object.keys(data[0]);
  const csv = [
    headers.join(","),
    ...data.map((row) =>
      headers
        .map((h) => `"${(row[h] || "").replace(/"/g, '""')}"`)
        .join(",")
    ),
  ].join("\n");
  const blob = new Blob([csv], { type: "text/csv" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = filename;
  a.click();
  URL.revokeObjectURL(url);
}

function formatDate(dateStr: string): string {
  if (!dateStr) return "N/A";
  return new Date(dateStr).toLocaleDateString("en-US", {
    month: "short",
    day: "numeric",
    year: "numeric",
  });
}

// ============================================================================
// Component
// ============================================================================

export default function InvestorDetailPage() {
  const params = useParams();
  const investorId = params.investorId as string;

  const [investor, setInvestor] = useState<InvestorDetail | null>(null);
  const [pitchDecks, setPitchDecks] = useState<PitchDeck[]>([]);
  const [loading, setLoading] = useState(true);
  const [decksLoading, setDecksLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [expandedFeedback, setExpandedFeedback] = useState<string | null>(null);
  const [editingFeedback, setEditingFeedback] = useState<{ id: string; feedback: string } | null>(null);

  const fetchInvestor = useCallback(async () => {
    try {
      const data = await apiClient<{ investor: any }>(`/api/investors/${investorId}`);
      const inv = data.investor;
      setInvestor({
        id: inv.id || inv._id,
        name: inv.name,
        firm: inv.firm,
        bio: inv.bio || "",
        funding_stages: inv.funding_stages || inv.fundingStages || [],
        sectors: inv.sectors || [],
        ticket_size: inv.ticket_size || inv.ticketSize || null,
        ticket_size_formatted: inv.ticket_size_formatted || inv.ticketSize || "Undisclosed",
        deal_count: inv.deal_count ?? inv.dealCount ?? 0,
        linkedin_url: inv.linkedin_url || inv.linkedinUrl || null,
        website_url: inv.website_url || inv.websiteUrl || null,
        contact_email: inv.contact_email || inv.contactEmail || null,
        is_active: inv.is_active ?? inv.isActive ?? true,
        created_at: inv.created_at || inv.createdAt || "",
      });
    } catch (err: any) {
      setError(err.message || "Failed to load investor");
    } finally {
      setLoading(false);
    }
  }, [investorId]);

  const fetchPitchDecks = useCallback(async () => {
    setDecksLoading(true);
    try {
      const data = await apiClient<{ pitchDecks: any[]; total: number }>(
        `/api/investors/pitch-decks/by-investor/${investorId}`
      );
      setPitchDecks(
        (data.pitchDecks || []).map((d: any) => ({
          id: d.id || d._id,
          submitter_name: d.submitter_name || d.submitterName || "Unknown",
          submitter_email: d.submitter_email || d.submitterEmail || "",
          title: d.title || d.name || "",
          description: d.description || null,
          file_url: d.file_url || d.fileUrl || "",
          status: d.status || "pending",
          feedback: d.feedback || null,
          created_at: d.created_at || d.createdAt || "",
        }))
      );
    } catch {
      setPitchDecks([]);
    } finally {
      setDecksLoading(false);
    }
  }, [investorId]);

  useEffect(() => {
    fetchInvestor();
    fetchPitchDecks();
  }, [fetchInvestor, fetchPitchDecks]);

  const handleStatusChange = async (deckId: string, newStatus: string) => {
    try {
      await apiClient(`/api/investors/pitch-decks/${deckId}/status`, {
        method: "PUT",
        body: JSON.stringify({ status: newStatus }),
      });
      setPitchDecks((prev) =>
        prev.map((d) => (d.id === deckId ? { ...d, status: newStatus } : d))
      );
    } catch (err: any) {
      alert(err.message || "Failed to update status");
    }
  };

  const handleFeedbackSave = async (deckId: string, feedback: string) => {
    try {
      const deck = pitchDecks.find((d) => d.id === deckId);
      await apiClient(`/api/investors/pitch-decks/${deckId}/status`, {
        method: "PUT",
        body: JSON.stringify({ status: deck?.status || "pending", feedback }),
      });
      setPitchDecks((prev) =>
        prev.map((d) => (d.id === deckId ? { ...d, feedback } : d))
      );
      setEditingFeedback(null);
    } catch (err: any) {
      alert(err.message || "Failed to save feedback");
    }
  };

  const handleExport = () => {
    if (pitchDecks.length === 0) return;
    const csvData = pitchDecks.map((d) => ({
      "Submitter Name": d.submitter_name,
      Email: d.submitter_email,
      Title: d.title,
      Status: d.status,
      "Submitted Date": formatDate(d.created_at),
      "File URL": d.file_url,
      Feedback: d.feedback || "",
    }));
    const investorName = investor?.name?.replace(/[^a-zA-Z0-9]/g, "_") || "investor";
    exportToCSV(csvData, `${investorName}_pitch_decks.csv`);
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center py-20">
        <IconLoader2 className="h-6 w-6 animate-spin text-muted-foreground" />
      </div>
    );
  }

  if (error || !investor) {
    return (
      <div className="flex flex-col items-center justify-center py-20 gap-4">
        <p className="text-sm text-red-500">{error || "Investor not found"}</p>
        <Link
          href="/investors"
          className="flex items-center gap-1.5 text-sm text-primary hover:underline"
        >
          <IconArrowLeft className="h-4 w-4" />
          Back to Investors
        </Link>
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-6 py-4">
      {/* Header */}
      <div className="px-4 lg:px-6">
        <Link
          href="/investors"
          className="inline-flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground mb-4 transition-colors"
        >
          <IconArrowLeft className="h-4 w-4" />
          Back to Investors
        </Link>

        <div className="flex items-start justify-between">
          <div>
            <h1 className="text-2xl font-bold tracking-tight">{investor.name}</h1>
            <p className="text-muted-foreground flex items-center gap-2 mt-1">
              <IconBuildingBank className="h-3.5 w-3.5" />
              {investor.firm}
            </p>
          </div>
          <span
            className={`px-3 py-1 rounded-full text-xs font-medium ${
              investor.is_active
                ? "bg-emerald-500/15 text-emerald-600 dark:text-emerald-400"
                : "bg-red-500/15 text-red-600 dark:text-red-400"
            }`}
          >
            {investor.is_active ? "Active" : "Inactive"}
          </span>
        </div>
      </div>

      {/* Investor Details */}
      <div className="px-4 lg:px-6">
        <div className="rounded-xl border border-border p-6">
          <h2 className="text-sm font-semibold text-muted-foreground uppercase tracking-wider mb-4">
            Investor Details
          </h2>

          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
            <div>
              <p className="text-xs text-muted-foreground">Ticket Size</p>
              <p className="text-sm font-medium">
                {typeof investor.ticket_size_formatted === "string"
                  ? investor.ticket_size_formatted
                  : "Undisclosed"}
              </p>
            </div>
            <div>
              <p className="text-xs text-muted-foreground">Deal Count</p>
              <p className="text-sm font-medium">{investor.deal_count}</p>
            </div>
            <div>
              <p className="text-xs text-muted-foreground">Added</p>
              <p className="text-sm font-medium">{formatDate(investor.created_at)}</p>
            </div>
            <div>
              <p className="text-xs text-muted-foreground">Contact</p>
              {investor.contact_email ? (
                <a
                  href={`mailto:${investor.contact_email}`}
                  className="text-sm text-primary hover:underline flex items-center gap-1"
                >
                  <IconMail className="h-3 w-3" />
                  {investor.contact_email}
                </a>
              ) : (
                <p className="text-sm text-muted-foreground">N/A</p>
              )}
            </div>
          </div>

          {/* Links */}
          <div className="flex gap-4 mb-6">
            {investor.linkedin_url && (
              <a
                href={investor.linkedin_url}
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-1.5 text-sm text-primary hover:underline"
              >
                <IconBrandLinkedin className="h-4 w-4" />
                LinkedIn
              </a>
            )}
            {investor.website_url && (
              <a
                href={investor.website_url}
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-1.5 text-sm text-primary hover:underline"
              >
                <IconWorld className="h-4 w-4" />
                Website
              </a>
            )}
          </div>

          {investor.bio && (
            <div className="mb-6">
              <p className="text-xs text-muted-foreground mb-1">Bio</p>
              <p className="text-sm whitespace-pre-wrap">{investor.bio}</p>
            </div>
          )}

          {investor.funding_stages.length > 0 && (
            <div className="mb-4">
              <p className="text-xs text-muted-foreground mb-2">Funding Stages</p>
              <div className="flex flex-wrap gap-1.5">
                {investor.funding_stages.map((s, i) => (
                  <span
                    key={i}
                    className="px-2.5 py-1 rounded-full text-xs font-medium bg-primary/10 text-primary capitalize"
                  >
                    {s}
                  </span>
                ))}
              </div>
            </div>
          )}

          {investor.sectors.length > 0 && (
            <div>
              <p className="text-xs text-muted-foreground mb-2">Sectors</p>
              <div className="flex flex-wrap gap-1.5">
                {investor.sectors.map((s, i) => (
                  <span
                    key={i}
                    className="px-2.5 py-1 rounded-full text-xs font-medium bg-muted"
                  >
                    {s}
                  </span>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Pitch Decks Section */}
      <div className="px-4 lg:px-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold">
            Pitch Decks ({pitchDecks.length})
          </h2>
          {pitchDecks.length > 0 && (
            <button
              onClick={handleExport}
              className="flex items-center gap-1.5 px-4 py-2 rounded-lg text-sm font-medium border border-border/60 hover:bg-muted transition-colors"
            >
              <IconDownload className="h-4 w-4" />
              Export Pitch Decks
            </button>
          )}
        </div>

        {decksLoading ? (
          <div className="flex items-center justify-center py-12">
            <IconLoader2 className="h-5 w-5 animate-spin text-muted-foreground" />
          </div>
        ) : pitchDecks.length === 0 ? (
          <div className="text-center py-12 border border-border rounded-xl">
            <IconFileText className="h-10 w-10 text-muted-foreground/40 mx-auto mb-2" />
            <p className="text-sm text-muted-foreground">
              No pitch decks submitted to this investor
            </p>
          </div>
        ) : (
          <div className="rounded-xl border border-border overflow-hidden">
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="bg-muted/50 border-b border-border">
                    <th className="text-left px-4 py-3 font-medium text-muted-foreground">Submitter</th>
                    <th className="text-left px-4 py-3 font-medium text-muted-foreground">Title</th>
                    <th className="text-left px-4 py-3 font-medium text-muted-foreground">Submitted</th>
                    <th className="text-center px-4 py-3 font-medium text-muted-foreground">Status</th>
                    <th className="text-center px-4 py-3 font-medium text-muted-foreground">File</th>
                    <th className="text-left px-4 py-3 font-medium text-muted-foreground">Feedback</th>
                  </tr>
                </thead>
                <tbody>
                  {pitchDecks.map((deck) => (
                    <tr
                      key={deck.id}
                      className="border-b border-border/50 hover:bg-muted/30 transition-colors"
                    >
                      <td className="px-4 py-3">
                        <div>
                          <p className="font-medium">{deck.submitter_name}</p>
                          <p className="text-xs text-muted-foreground">{deck.submitter_email}</p>
                        </div>
                      </td>
                      <td className="px-4 py-3">
                        <p className="font-medium">{deck.title}</p>
                        {deck.description && (
                          <p className="text-xs text-muted-foreground truncate max-w-xs">
                            {deck.description}
                          </p>
                        )}
                      </td>
                      <td className="px-4 py-3 text-muted-foreground">
                        {formatDate(deck.created_at)}
                      </td>
                      <td className="px-4 py-3 text-center">
                        <select
                          value={deck.status}
                          onChange={(e) => handleStatusChange(deck.id, e.target.value)}
                          className={`px-2 py-1 rounded-lg text-xs font-medium border-0 cursor-pointer focus:outline-none focus:ring-2 focus:ring-primary/30 ${
                            statusColors[deck.status] || "bg-muted"
                          }`}
                        >
                          {PITCH_STATUSES.map((s) => (
                            <option key={s} value={s}>
                              {s.charAt(0).toUpperCase() + s.slice(1)}
                            </option>
                          ))}
                        </select>
                      </td>
                      <td className="px-4 py-3 text-center">
                        {deck.file_url ? (
                          <a
                            href={deck.file_url}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="inline-flex items-center gap-1 px-2.5 py-1 rounded-lg text-xs font-medium bg-primary/10 text-primary hover:bg-primary/20 transition-colors"
                          >
                            <IconExternalLink className="h-3 w-3" />
                            View
                          </a>
                        ) : (
                          <span className="text-muted-foreground/50">-</span>
                        )}
                      </td>
                      <td className="px-4 py-3">
                        {editingFeedback?.id === deck.id ? (
                          <div className="flex flex-col gap-1.5">
                            <textarea
                              value={editingFeedback.feedback}
                              onChange={(e) =>
                                setEditingFeedback({ ...editingFeedback, feedback: e.target.value })
                              }
                              className="w-full px-2 py-1.5 rounded-lg border border-border text-xs resize-none focus:outline-none focus:ring-2 focus:ring-primary/30"
                              rows={2}
                              placeholder="Add feedback..."
                            />
                            <div className="flex gap-1">
                              <button
                                onClick={() => handleFeedbackSave(deck.id, editingFeedback.feedback)}
                                className="px-2 py-0.5 rounded text-xs font-medium bg-primary text-primary-foreground hover:bg-primary/90"
                              >
                                Save
                              </button>
                              <button
                                onClick={() => setEditingFeedback(null)}
                                className="px-2 py-0.5 rounded text-xs font-medium text-muted-foreground hover:text-foreground"
                              >
                                Cancel
                              </button>
                            </div>
                          </div>
                        ) : (
                          <div>
                            {deck.feedback ? (
                              <div>
                                <button
                                  onClick={() =>
                                    setExpandedFeedback(
                                      expandedFeedback === deck.id ? null : deck.id
                                    )
                                  }
                                  className="flex items-center gap-1 text-xs text-primary hover:underline"
                                >
                                  {expandedFeedback === deck.id ? (
                                    <>
                                      <IconChevronUp className="h-3 w-3" />
                                      Collapse
                                    </>
                                  ) : (
                                    <>
                                      <IconChevronDown className="h-3 w-3" />
                                      View
                                    </>
                                  )}
                                </button>
                                {expandedFeedback === deck.id && (
                                  <p className="mt-1 text-xs text-muted-foreground whitespace-pre-wrap max-w-xs">
                                    {deck.feedback}
                                  </p>
                                )}
                              </div>
                            ) : (
                              <span className="text-xs text-muted-foreground/50">-</span>
                            )}
                            <button
                              onClick={() =>
                                setEditingFeedback({ id: deck.id, feedback: deck.feedback || "" })
                              }
                              className="text-xs text-primary hover:underline mt-1 block"
                            >
                              {deck.feedback ? "Edit" : "Add feedback"}
                            </button>
                          </div>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
