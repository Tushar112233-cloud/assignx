"use client";

import { useState, useEffect, useCallback } from "react";
import Link from "next/link";
import { apiClient } from "@/lib/api/client";
import {
  IconPlus,
  IconPencil,
  IconTrash,
  IconCheck,
  IconX,
  IconBriefcase,
  IconMapPin,
  IconWifi,
  IconLoader2,
  IconRefresh,
  IconPlayerPlay,
} from "@tabler/icons-react";

// ============================================================================
// Types
// ============================================================================

interface JobRow {
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

interface JobFormData {
  title: string;
  company: string;
  companyLogo: string;
  location: string;
  type: string;
  category: string;
  isRemote: boolean;
  salaryMin: string;
  salaryMax: string;
  salaryCurrency: string;
  description: string;
  requirements: string;
  skills: string;
  applyUrl: string;
}

const EMPTY_FORM: JobFormData = {
  title: "",
  company: "",
  companyLogo: "",
  location: "",
  type: "full-time",
  category: "engineering",
  isRemote: false,
  salaryMin: "",
  salaryMax: "",
  salaryCurrency: "INR",
  description: "",
  requirements: "",
  skills: "",
  applyUrl: "",
};

const JOB_TYPES = ["full-time", "part-time", "contract", "internship", "freelance"];
const CATEGORIES = [
  "engineering", "design", "marketing", "sales", "finance",
  "product", "data", "operations", "hr", "legal",
];

// ============================================================================
// Component
// ============================================================================

export default function JobsPage() {
  const [jobs, setJobs] = useState<JobRow[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [showForm, setShowForm] = useState(false);
  const [editingJob, setEditingJob] = useState<JobRow | null>(null);
  const [form, setForm] = useState<JobFormData>(EMPTY_FORM);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Fetch jobs
  const fetchJobs = useCallback(async () => {
    setLoading(true);
    try {
      const params = new URLSearchParams({ page: String(page), perPage: "20" });
      const data = await apiClient<{ jobs: JobRow[]; total: number; page: number }>(
        `/api/jobs?${params.toString()}`
      );
      // Normalize field names from API
      const normalized = (data.jobs || []).map((j: any) => ({
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
      }));
      setJobs(normalized);
      setTotal(data.total || 0);
    } catch (err: any) {
      console.error("Failed to fetch jobs:", err);
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, [page]);

  useEffect(() => {
    fetchJobs();
  }, [fetchJobs]);

  // Open create form
  const handleCreate = () => {
    setEditingJob(null);
    setForm(EMPTY_FORM);
    setShowForm(true);
    setError(null);
  };

  // Open edit form
  const handleEdit = (job: JobRow) => {
    setEditingJob(job);
    setForm({
      title: job.title,
      company: job.company,
      companyLogo: "",
      location: job.location,
      type: job.type,
      category: job.category,
      isRemote: job.is_remote,
      salaryMin: job.salary_raw?.min?.toString() || "",
      salaryMax: job.salary_raw?.max?.toString() || "",
      salaryCurrency: job.salary_raw?.currency || "INR",
      description: job.description,
      requirements: job.requirements.join("\n"),
      skills: job.skills.join(", "),
      applyUrl: job.apply_url || "",
    });
    setShowForm(true);
    setError(null);
  };

  // Submit form
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    setError(null);

    try {
      const salary =
        form.salaryMin && form.salaryMax
          ? {
              min: parseInt(form.salaryMin),
              max: parseInt(form.salaryMax),
              currency: form.salaryCurrency,
            }
          : undefined;

      const body = {
        title: form.title,
        company: form.company,
        companyLogo: form.companyLogo || undefined,
        location: form.location,
        type: form.type,
        category: form.category,
        isRemote: form.isRemote,
        salary,
        description: form.description,
        requirements: form.requirements
          .split("\n")
          .map((r) => r.trim())
          .filter(Boolean),
        skills: form.skills
          .split(",")
          .map((s) => s.trim())
          .filter(Boolean),
        applyUrl: form.applyUrl || undefined,
      };

      if (editingJob) {
        await apiClient(`/api/jobs/${editingJob.id}`, {
          method: "PUT",
          body: JSON.stringify(body),
        });
      } else {
        await apiClient("/api/jobs", {
          method: "POST",
          body: JSON.stringify(body),
        });
      }

      setShowForm(false);
      setEditingJob(null);
      setForm(EMPTY_FORM);
      fetchJobs();
    } catch (err: any) {
      setError(err.message || "Failed to save job");
    } finally {
      setSubmitting(false);
    }
  };

  // Delete (deactivate) job
  const handleDelete = async (jobId: string) => {
    if (!confirm("Are you sure you want to deactivate this job?")) return;
    try {
      await apiClient(`/api/jobs/${jobId}`, { method: "DELETE" });
      fetchJobs();
    } catch (err: any) {
      alert(err.message || "Failed to deactivate job");
    }
  };

  // Activate job
  const handleActivate = async (jobId: string) => {
    try {
      await apiClient(`/api/jobs/${jobId}`, {
        method: "PUT",
        body: JSON.stringify({ isActive: true }),
      });
      fetchJobs();
    } catch (err: any) {
      alert(err.message || "Failed to activate job");
    }
  };

  const updateField = (field: keyof JobFormData, value: string | boolean) => {
    setForm((prev) => ({ ...prev, [field]: value }));
  };

  return (
    <div className="flex flex-col gap-4 py-4">
      {/* Header */}
      <div className="px-4 lg:px-6 flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Jobs</h1>
          <p className="text-muted-foreground">
            Manage job listings for the Campus Connect portal ({total} total)
          </p>
        </div>
        <div className="flex gap-2">
          <button
            onClick={() => fetchJobs()}
            className="flex items-center gap-1.5 px-3 py-2 rounded-lg text-sm font-medium border border-border/60 hover:bg-muted transition-colors"
          >
            <IconRefresh className="h-4 w-4" />
            Refresh
          </button>
          <button
            onClick={handleCreate}
            className="flex items-center gap-1.5 px-4 py-2 rounded-lg text-sm font-medium text-white bg-primary hover:bg-primary/90 transition-colors"
          >
            <IconPlus className="h-4 w-4" />
            Create Job
          </button>
        </div>
      </div>

      {/* Error */}
      {error && (
        <div className="mx-4 lg:mx-6 px-4 py-3 rounded-lg bg-red-50 dark:bg-red-500/10 border border-red-200 dark:border-red-500/20 text-red-700 dark:text-red-400 text-sm">
          {error}
        </div>
      )}

      {/* Job Form Modal */}
      {showForm && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm overflow-y-auto">
          <div className="w-full max-w-2xl rounded-2xl border border-border bg-background p-6 shadow-xl my-8">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-lg font-semibold">
                {editingJob ? "Edit Job" : "Create New Job"}
              </h2>
              <button
                onClick={() => { setShowForm(false); setEditingJob(null); }}
                className="text-muted-foreground hover:text-foreground"
              >
                <IconX className="h-5 w-5" />
              </button>
            </div>

            <form onSubmit={handleSubmit} className="space-y-4">
              {/* Title */}
              <div className="space-y-1.5">
                <label className="text-sm font-medium">Job Title *</label>
                <input
                  required
                  value={form.title}
                  onChange={(e) => updateField("title", e.target.value)}
                  placeholder="e.g. Senior Frontend Developer"
                  className="w-full px-3 py-2 rounded-lg border border-border text-sm focus:outline-none focus:ring-2 focus:ring-primary/30"
                />
              </div>

              {/* Company + Location */}
              <div className="grid grid-cols-2 gap-3">
                <div className="space-y-1.5">
                  <label className="text-sm font-medium">Company *</label>
                  <input
                    required
                    value={form.company}
                    onChange={(e) => updateField("company", e.target.value)}
                    placeholder="e.g. Google"
                    className="w-full px-3 py-2 rounded-lg border border-border text-sm focus:outline-none focus:ring-2 focus:ring-primary/30"
                  />
                </div>
                <div className="space-y-1.5">
                  <label className="text-sm font-medium">Location *</label>
                  <input
                    required
                    value={form.location}
                    onChange={(e) => updateField("location", e.target.value)}
                    placeholder="e.g. Bangalore, India"
                    className="w-full px-3 py-2 rounded-lg border border-border text-sm focus:outline-none focus:ring-2 focus:ring-primary/30"
                  />
                </div>
              </div>

              {/* Type + Category + Remote */}
              <div className="grid grid-cols-3 gap-3">
                <div className="space-y-1.5">
                  <label className="text-sm font-medium">Type *</label>
                  <select
                    required
                    value={form.type}
                    onChange={(e) => updateField("type", e.target.value)}
                    className="w-full px-3 py-2 rounded-lg border border-border text-sm focus:outline-none focus:ring-2 focus:ring-primary/30"
                  >
                    {JOB_TYPES.map((t) => (
                      <option key={t} value={t}>{t.charAt(0).toUpperCase() + t.slice(1)}</option>
                    ))}
                  </select>
                </div>
                <div className="space-y-1.5">
                  <label className="text-sm font-medium">Category *</label>
                  <select
                    required
                    value={form.category}
                    onChange={(e) => updateField("category", e.target.value)}
                    className="w-full px-3 py-2 rounded-lg border border-border text-sm focus:outline-none focus:ring-2 focus:ring-primary/30"
                  >
                    {CATEGORIES.map((c) => (
                      <option key={c} value={c}>{c.charAt(0).toUpperCase() + c.slice(1)}</option>
                    ))}
                  </select>
                </div>
                <div className="space-y-1.5">
                  <label className="text-sm font-medium">Remote</label>
                  <div className="flex items-center gap-2 pt-1.5">
                    <button
                      type="button"
                      onClick={() => updateField("isRemote", !form.isRemote)}
                      className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${
                        form.isRemote ? "bg-primary" : "bg-muted"
                      }`}
                    >
                      <span
                        className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                          form.isRemote ? "translate-x-6" : "translate-x-1"
                        }`}
                      />
                    </button>
                    <span className="text-sm text-muted-foreground">{form.isRemote ? "Yes" : "No"}</span>
                  </div>
                </div>
              </div>

              {/* Salary */}
              <div className="grid grid-cols-3 gap-3">
                <div className="space-y-1.5">
                  <label className="text-sm font-medium">Salary Min</label>
                  <input
                    type="number"
                    value={form.salaryMin}
                    onChange={(e) => updateField("salaryMin", e.target.value)}
                    placeholder="e.g. 800000"
                    className="w-full px-3 py-2 rounded-lg border border-border text-sm focus:outline-none focus:ring-2 focus:ring-primary/30"
                  />
                </div>
                <div className="space-y-1.5">
                  <label className="text-sm font-medium">Salary Max</label>
                  <input
                    type="number"
                    value={form.salaryMax}
                    onChange={(e) => updateField("salaryMax", e.target.value)}
                    placeholder="e.g. 1500000"
                    className="w-full px-3 py-2 rounded-lg border border-border text-sm focus:outline-none focus:ring-2 focus:ring-primary/30"
                  />
                </div>
                <div className="space-y-1.5">
                  <label className="text-sm font-medium">Currency</label>
                  <select
                    value={form.salaryCurrency}
                    onChange={(e) => updateField("salaryCurrency", e.target.value)}
                    className="w-full px-3 py-2 rounded-lg border border-border text-sm focus:outline-none focus:ring-2 focus:ring-primary/30"
                  >
                    <option value="INR">INR</option>
                    <option value="USD">USD</option>
                    <option value="EUR">EUR</option>
                    <option value="GBP">GBP</option>
                  </select>
                </div>
              </div>

              {/* Description */}
              <div className="space-y-1.5">
                <label className="text-sm font-medium">Description *</label>
                <textarea
                  required
                  value={form.description}
                  onChange={(e) => updateField("description", e.target.value)}
                  placeholder="Job description..."
                  rows={4}
                  className="w-full px-3 py-2 rounded-lg border border-border text-sm resize-none focus:outline-none focus:ring-2 focus:ring-primary/30"
                />
              </div>

              {/* Requirements */}
              <div className="space-y-1.5">
                <label className="text-sm font-medium">Requirements (one per line)</label>
                <textarea
                  value={form.requirements}
                  onChange={(e) => updateField("requirements", e.target.value)}
                  placeholder="3+ years of experience in React&#10;Strong TypeScript skills&#10;..."
                  rows={3}
                  className="w-full px-3 py-2 rounded-lg border border-border text-sm resize-none focus:outline-none focus:ring-2 focus:ring-primary/30"
                />
              </div>

              {/* Skills */}
              <div className="space-y-1.5">
                <label className="text-sm font-medium">Skills (comma-separated)</label>
                <input
                  value={form.skills}
                  onChange={(e) => updateField("skills", e.target.value)}
                  placeholder="React, TypeScript, Node.js, ..."
                  className="w-full px-3 py-2 rounded-lg border border-border text-sm focus:outline-none focus:ring-2 focus:ring-primary/30"
                />
              </div>

              {/* Apply URL */}
              <div className="space-y-1.5">
                <label className="text-sm font-medium">External Apply URL</label>
                <input
                  type="url"
                  value={form.applyUrl}
                  onChange={(e) => updateField("applyUrl", e.target.value)}
                  placeholder="https://careers.company.com/apply/..."
                  className="w-full px-3 py-2 rounded-lg border border-border text-sm focus:outline-none focus:ring-2 focus:ring-primary/30"
                />
              </div>

              {/* Actions */}
              <div className="flex justify-end gap-2 pt-4 border-t">
                <button
                  type="button"
                  onClick={() => { setShowForm(false); setEditingJob(null); }}
                  className="px-4 py-2 rounded-lg text-sm font-medium text-muted-foreground hover:text-foreground transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={submitting}
                  className="flex items-center gap-2 px-5 py-2 rounded-lg text-sm font-medium text-white bg-primary hover:bg-primary/90 disabled:opacity-50 transition-colors"
                >
                  {submitting && <IconLoader2 className="h-4 w-4 animate-spin" />}
                  {editingJob ? "Update Job" : "Create Job"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Jobs Table */}
      <div className="px-4 lg:px-6">
        {loading ? (
          <div className="flex items-center justify-center py-20">
            <IconLoader2 className="h-6 w-6 animate-spin text-muted-foreground" />
          </div>
        ) : jobs.length === 0 ? (
          <div className="text-center py-20">
            <IconBriefcase className="h-12 w-12 text-muted-foreground/40 mx-auto mb-3" />
            <p className="text-sm font-medium text-foreground mb-1">No jobs yet</p>
            <p className="text-xs text-muted-foreground mb-4">Create your first job listing</p>
            <button
              onClick={handleCreate}
              className="inline-flex items-center gap-1.5 px-4 py-2 rounded-lg text-sm font-medium text-white bg-primary hover:bg-primary/90 transition-colors"
            >
              <IconPlus className="h-4 w-4" />
              Create Job
            </button>
          </div>
        ) : (
          <div className="rounded-xl border border-border overflow-hidden">
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="bg-muted/50 border-b border-border">
                    <th className="text-left px-4 py-3 font-medium text-muted-foreground">Job</th>
                    <th className="text-left px-4 py-3 font-medium text-muted-foreground">Type</th>
                    <th className="text-left px-4 py-3 font-medium text-muted-foreground">Category</th>
                    <th className="text-center px-4 py-3 font-medium text-muted-foreground">Remote</th>
                    <th className="text-center px-4 py-3 font-medium text-muted-foreground">Applications</th>
                    <th className="text-center px-4 py-3 font-medium text-muted-foreground">Status</th>
                    <th className="text-right px-4 py-3 font-medium text-muted-foreground">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {jobs.map((job) => (
                    <tr key={job.id} className="border-b border-border/50 hover:bg-muted/30 transition-colors">
                      <td className="px-4 py-3">
                        <Link href={`/jobs/${job.id}`} className="block group">
                          <p className="font-medium truncate max-w-xs group-hover:text-primary transition-colors">{job.title}</p>
                          <p className="text-xs text-muted-foreground flex items-center gap-1 mt-0.5">
                            {job.company}
                            <span className="mx-0.5">·</span>
                            <IconMapPin className="h-3 w-3" />
                            {job.location}
                          </p>
                        </Link>
                      </td>
                      <td className="px-4 py-3">
                        <span className="px-2 py-0.5 rounded-full text-xs font-medium bg-muted capitalize">
                          {job.type}
                        </span>
                      </td>
                      <td className="px-4 py-3 capitalize text-muted-foreground">{job.category}</td>
                      <td className="px-4 py-3 text-center">
                        {job.is_remote ? (
                          <IconWifi className="h-4 w-4 text-emerald-500 mx-auto" />
                        ) : (
                          <span className="text-muted-foreground/40">-</span>
                        )}
                      </td>
                      <td className="px-4 py-3 text-center font-medium">{job.application_count}</td>
                      <td className="px-4 py-3 text-center">
                        <span
                          className={`px-2 py-0.5 rounded-full text-xs font-medium ${
                            job.is_active
                              ? "bg-emerald-500/15 text-emerald-600 dark:text-emerald-400"
                              : "bg-red-500/15 text-red-600 dark:text-red-400"
                          }`}
                        >
                          {job.is_active ? "Active" : "Inactive"}
                        </span>
                      </td>
                      <td className="px-4 py-3 text-right">
                        <div className="flex items-center justify-end gap-1">
                          <button
                            onClick={() => handleEdit(job)}
                            title="Edit"
                            className="p-1.5 rounded-lg hover:bg-muted transition-colors text-muted-foreground hover:text-foreground"
                          >
                            <IconPencil className="h-4 w-4" />
                          </button>
                          {job.is_active ? (
                            <button
                              onClick={() => handleDelete(job.id)}
                              title="Deactivate"
                              className="p-1.5 rounded-lg hover:bg-red-50 dark:hover:bg-red-500/10 transition-colors text-muted-foreground hover:text-red-600"
                            >
                              <IconTrash className="h-4 w-4" />
                            </button>
                          ) : (
                            <button
                              onClick={() => handleActivate(job.id)}
                              title="Activate"
                              className="p-1.5 rounded-lg hover:bg-emerald-50 dark:hover:bg-emerald-500/10 transition-colors text-muted-foreground hover:text-emerald-600"
                            >
                              <IconPlayerPlay className="h-4 w-4" />
                            </button>
                          )}
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* Pagination */}
            {total > 20 && (
              <div className="flex items-center justify-between px-4 py-3 border-t border-border bg-muted/30">
                <p className="text-xs text-muted-foreground">
                  Page {page} of {Math.ceil(total / 20)}
                </p>
                <div className="flex gap-1">
                  <button
                    onClick={() => setPage((p) => Math.max(1, p - 1))}
                    disabled={page <= 1}
                    className="px-3 py-1.5 rounded-lg text-xs font-medium border border-border hover:bg-muted disabled:opacity-40 transition-colors"
                  >
                    Previous
                  </button>
                  <button
                    onClick={() => setPage((p) => p + 1)}
                    disabled={page >= Math.ceil(total / 20)}
                    className="px-3 py-1.5 rounded-lg text-xs font-medium border border-border hover:bg-muted disabled:opacity-40 transition-colors"
                  >
                    Next
                  </button>
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
