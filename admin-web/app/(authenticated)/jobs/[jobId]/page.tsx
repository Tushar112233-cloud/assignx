"use client";

import { useState, useEffect, useCallback } from "react";
import { useParams, useRouter } from "next/navigation";
import Link from "next/link";
import { apiClient } from "@/lib/api/client";
import {
  IconArrowLeft,
  IconDownload,
  IconFileText,
  IconLoader2,
  IconMapPin,
  IconWifi,
  IconChevronDown,
  IconChevronUp,
} from "@tabler/icons-react";

// ============================================================================
// Types
// ============================================================================

interface JobDetail {
  id: string;
  title: string;
  company: string;
  location: string;
  type: string;
  category: string;
  is_remote: boolean;
  is_active: boolean;
  application_count: number;
  salary_raw: { min: number; max: number; currency: string } | null;
  salary_display: string | null;
  description: string;
  requirements: string[];
  skills: string[];
  apply_url: string | null;
  created_at: string;
}

interface Application {
  id: string;
  applicant_name: string;
  applicant_email: string;
  resume_url: string;
  cover_letter: string | null;
  status: string;
  created_at: string;
}

const APPLICATION_STATUSES = ["applied", "reviewing", "shortlisted", "rejected"];

const statusColors: Record<string, string> = {
  applied: "bg-blue-500/15 text-blue-600 dark:text-blue-400",
  reviewing: "bg-yellow-500/15 text-yellow-600 dark:text-yellow-400",
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

export default function JobDetailPage() {
  const params = useParams();
  const router = useRouter();
  const jobId = params.jobId as string;

  const [job, setJob] = useState<JobDetail | null>(null);
  const [applications, setApplications] = useState<Application[]>([]);
  const [loading, setLoading] = useState(true);
  const [appsLoading, setAppsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [expandedCoverLetter, setExpandedCoverLetter] = useState<string | null>(null);

  const fetchJob = useCallback(async () => {
    try {
      const data = await apiClient<{ job: any }>(`/api/jobs/${jobId}`);
      const j = data.job;
      setJob({
        id: j.id || j._id,
        title: j.title,
        company: j.company,
        location: j.location,
        type: j.type,
        category: j.category,
        is_remote: j.is_remote ?? j.isRemote ?? false,
        is_active: j.is_active ?? j.isActive ?? true,
        application_count: j.application_count ?? j.applicationCount ?? 0,
        salary_raw: j.salary_raw ?? j.salaryRaw ?? null,
        salary_display: j.salary ?? null,
        description: j.description ?? "",
        requirements: j.requirements ?? [],
        skills: j.skills ?? j.tags ?? [],
        apply_url: j.apply_url ?? j.applyUrl ?? null,
        created_at: j.created_at ?? j.createdAt ?? "",
      });
    } catch (err: any) {
      setError(err.message || "Failed to load job");
    } finally {
      setLoading(false);
    }
  }, [jobId]);

  const fetchApplications = useCallback(async () => {
    setAppsLoading(true);
    try {
      const data = await apiClient<{ applications: any[]; total: number }>(
        `/api/jobs/${jobId}/applications`
      );
      setApplications(
        (data.applications || []).map((a: any) => ({
          id: a.id || a._id,
          applicant_name: a.applicant_name || a.applicantName || "Unknown",
          applicant_email: a.applicant_email || a.applicantEmail || "",
          resume_url: a.resume_url || a.resumeUrl || "",
          cover_letter: a.cover_letter || a.coverLetter || null,
          status: a.status || "applied",
          created_at: a.created_at || a.createdAt || "",
        }))
      );
    } catch {
      // Applications might fail if no applications exist yet
      setApplications([]);
    } finally {
      setAppsLoading(false);
    }
  }, [jobId]);

  useEffect(() => {
    fetchJob();
    fetchApplications();
  }, [fetchJob, fetchApplications]);

  const handleStatusChange = async (appId: string, newStatus: string) => {
    try {
      await apiClient(`/api/jobs/${jobId}/applications/${appId}/status`, {
        method: "PUT",
        body: JSON.stringify({ status: newStatus }),
      });
      setApplications((prev) =>
        prev.map((a) => (a.id === appId ? { ...a, status: newStatus } : a))
      );
    } catch (err: any) {
      alert(err.message || "Failed to update status");
    }
  };

  const handleExport = () => {
    if (applications.length === 0) return;
    const csvData = applications.map((a) => ({
      Name: a.applicant_name,
      Email: a.applicant_email,
      "Applied Date": formatDate(a.created_at),
      Status: a.status,
      "Resume URL": a.resume_url,
      "Cover Letter": a.cover_letter || "",
    }));
    const jobTitle = job?.title?.replace(/[^a-zA-Z0-9]/g, "_") || "job";
    exportToCSV(csvData, `${jobTitle}_applications.csv`);
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center py-20">
        <IconLoader2 className="h-6 w-6 animate-spin text-muted-foreground" />
      </div>
    );
  }

  if (error || !job) {
    return (
      <div className="flex flex-col items-center justify-center py-20 gap-4">
        <p className="text-sm text-red-500">{error || "Job not found"}</p>
        <Link
          href="/jobs"
          className="flex items-center gap-1.5 text-sm text-primary hover:underline"
        >
          <IconArrowLeft className="h-4 w-4" />
          Back to Jobs
        </Link>
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-6 py-4">
      {/* Header */}
      <div className="px-4 lg:px-6">
        <Link
          href="/jobs"
          className="inline-flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground mb-4 transition-colors"
        >
          <IconArrowLeft className="h-4 w-4" />
          Back to Jobs
        </Link>

        <div className="flex items-start justify-between">
          <div>
            <h1 className="text-2xl font-bold tracking-tight">{job.title}</h1>
            <p className="text-muted-foreground flex items-center gap-2 mt-1">
              {job.company}
              <span>·</span>
              <span className="flex items-center gap-1">
                <IconMapPin className="h-3.5 w-3.5" />
                {job.location}
              </span>
              {job.is_remote && (
                <>
                  <span>·</span>
                  <span className="flex items-center gap-1 text-emerald-600">
                    <IconWifi className="h-3.5 w-3.5" />
                    Remote
                  </span>
                </>
              )}
            </p>
          </div>
          <span
            className={`px-3 py-1 rounded-full text-xs font-medium ${
              job.is_active
                ? "bg-emerald-500/15 text-emerald-600 dark:text-emerald-400"
                : "bg-red-500/15 text-red-600 dark:text-red-400"
            }`}
          >
            {job.is_active ? "Active" : "Inactive"}
          </span>
        </div>
      </div>

      {/* Job Details Grid */}
      <div className="px-4 lg:px-6">
        <div className="rounded-xl border border-border p-6">
          <h2 className="text-sm font-semibold text-muted-foreground uppercase tracking-wider mb-4">
            Job Details
          </h2>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
            <div>
              <p className="text-xs text-muted-foreground">Type</p>
              <p className="text-sm font-medium capitalize">{job.type}</p>
            </div>
            <div>
              <p className="text-xs text-muted-foreground">Category</p>
              <p className="text-sm font-medium capitalize">{job.category}</p>
            </div>
            <div>
              <p className="text-xs text-muted-foreground">Salary</p>
              <p className="text-sm font-medium">
                {job.salary_display || (job.salary_raw
                  ? `${job.salary_raw.currency} ${job.salary_raw.min.toLocaleString()} - ${job.salary_raw.max.toLocaleString()}`
                  : "Not specified")}
              </p>
            </div>
            <div>
              <p className="text-xs text-muted-foreground">Posted</p>
              <p className="text-sm font-medium">{formatDate(job.created_at)}</p>
            </div>
          </div>

          {job.apply_url && (
            <div className="mb-6">
              <p className="text-xs text-muted-foreground mb-1">External Apply URL</p>
              <a
                href={job.apply_url}
                target="_blank"
                rel="noopener noreferrer"
                className="text-sm text-primary hover:underline break-all"
              >
                {job.apply_url}
              </a>
            </div>
          )}

          {job.description && (
            <div className="mb-6">
              <p className="text-xs text-muted-foreground mb-1">Description</p>
              <p className="text-sm whitespace-pre-wrap">{job.description}</p>
            </div>
          )}

          {job.requirements.length > 0 && (
            <div className="mb-6">
              <p className="text-xs text-muted-foreground mb-1">Requirements</p>
              <ul className="list-disc list-inside text-sm space-y-1">
                {job.requirements.map((r, i) => (
                  <li key={i}>{r}</li>
                ))}
              </ul>
            </div>
          )}

          {job.skills.length > 0 && (
            <div>
              <p className="text-xs text-muted-foreground mb-2">Skills</p>
              <div className="flex flex-wrap gap-1.5">
                {job.skills.map((s, i) => (
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

      {/* Applications Section */}
      <div className="px-4 lg:px-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold">
            Applications ({applications.length})
          </h2>
          {applications.length > 0 && (
            <button
              onClick={handleExport}
              className="flex items-center gap-1.5 px-4 py-2 rounded-lg text-sm font-medium border border-border/60 hover:bg-muted transition-colors"
            >
              <IconDownload className="h-4 w-4" />
              Export Applications
            </button>
          )}
        </div>

        {appsLoading ? (
          <div className="flex items-center justify-center py-12">
            <IconLoader2 className="h-5 w-5 animate-spin text-muted-foreground" />
          </div>
        ) : applications.length === 0 ? (
          <div className="text-center py-12 border border-border rounded-xl">
            <IconFileText className="h-10 w-10 text-muted-foreground/40 mx-auto mb-2" />
            <p className="text-sm text-muted-foreground">No applications yet</p>
          </div>
        ) : (
          <div className="rounded-xl border border-border overflow-hidden">
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="bg-muted/50 border-b border-border">
                    <th className="text-left px-4 py-3 font-medium text-muted-foreground">Applicant</th>
                    <th className="text-left px-4 py-3 font-medium text-muted-foreground">Applied Date</th>
                    <th className="text-center px-4 py-3 font-medium text-muted-foreground">Status</th>
                    <th className="text-center px-4 py-3 font-medium text-muted-foreground">Resume</th>
                    <th className="text-left px-4 py-3 font-medium text-muted-foreground">Cover Letter</th>
                  </tr>
                </thead>
                <tbody>
                  {applications.map((app) => (
                    <tr
                      key={app.id}
                      className="border-b border-border/50 hover:bg-muted/30 transition-colors"
                    >
                      <td className="px-4 py-3">
                        <div>
                          <p className="font-medium">{app.applicant_name}</p>
                          <p className="text-xs text-muted-foreground">{app.applicant_email}</p>
                        </div>
                      </td>
                      <td className="px-4 py-3 text-muted-foreground">
                        {formatDate(app.created_at)}
                      </td>
                      <td className="px-4 py-3 text-center">
                        <select
                          value={app.status}
                          onChange={(e) => handleStatusChange(app.id, e.target.value)}
                          className={`px-2 py-1 rounded-lg text-xs font-medium border-0 cursor-pointer focus:outline-none focus:ring-2 focus:ring-primary/30 ${
                            statusColors[app.status] || "bg-muted"
                          }`}
                        >
                          {APPLICATION_STATUSES.map((s) => (
                            <option key={s} value={s}>
                              {s.charAt(0).toUpperCase() + s.slice(1)}
                            </option>
                          ))}
                        </select>
                      </td>
                      <td className="px-4 py-3 text-center">
                        {app.resume_url ? (
                          <a
                            href={app.resume_url}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="inline-flex items-center gap-1 px-2.5 py-1 rounded-lg text-xs font-medium bg-primary/10 text-primary hover:bg-primary/20 transition-colors"
                          >
                            <IconDownload className="h-3 w-3" />
                            Download
                          </a>
                        ) : (
                          <span className="text-muted-foreground/50">-</span>
                        )}
                      </td>
                      <td className="px-4 py-3">
                        {app.cover_letter ? (
                          <div>
                            <button
                              onClick={() =>
                                setExpandedCoverLetter(
                                  expandedCoverLetter === app.id ? null : app.id
                                )
                              }
                              className="flex items-center gap-1 text-xs text-primary hover:underline"
                            >
                              {expandedCoverLetter === app.id ? (
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
                            {expandedCoverLetter === app.id && (
                              <p className="mt-2 text-xs text-muted-foreground whitespace-pre-wrap max-w-md">
                                {app.cover_letter}
                              </p>
                            )}
                          </div>
                        ) : (
                          <span className="text-xs text-muted-foreground/50">-</span>
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
