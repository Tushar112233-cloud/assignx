"use client";

import { useState, useEffect, useRef } from "react";
import { useParams, useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { getProjectById } from "@/lib/actions/data";
import { ProjectDetailClient } from "./project-detail-client";
import type { ProjectDetail } from "@/types/project";
import type { ProjectStatus } from "@/types/project";
import { Loader2 } from "lucide-react";

/**
 * Transform database project to component-friendly format
 */
function transformProjectToDetail(dbProject: Awaited<ReturnType<typeof getProjectById>>): ProjectDetail | null {
  if (!dbProject) return null;

  // Map database status to component status
  const status = dbProject.status as ProjectStatus;

  return {
    id: dbProject.id,
    projectNumber: dbProject.project_number,
    title: dbProject.title,
    subjectId: dbProject.subject_id || "",
    subjectName: dbProject.subject?.name || "Unknown Subject",
    subjectIcon: dbProject.subject?.icon || "BookOpen",
    status,
    progress: dbProject.progress_percentage || 0,
    deadline: dbProject.deadline,
    createdAt: dbProject.created_at,
    wordCount: dbProject.word_count || undefined,
    referenceStyle: dbProject.reference_style?.name,
    quoteAmount: dbProject.final_quote || dbProject.user_quote || undefined,
    deliveredAt: dbProject.delivered_at || undefined,
    completedAt: dbProject.completed_at || undefined,
    cancelledAt: dbProject.cancelled_at || undefined,
    instructions: dbProject.specific_instructions || "",
    budget: dbProject.user_quote ? `₹${dbProject.user_quote}` : undefined,
    liveDocUrl: dbProject.live_document_url || undefined,
    supervisorName: undefined, // Will be fetched from chat room participants
    unreadMessages: 0, // Will be calculated from chat messages
    attachedFiles: (dbProject.files || []).map((file: {
      id: string;
      file_name: string;
      file_size_bytes?: number | null;
      file_type?: string | null;
      created_at?: string | null;
    }) => ({
      id: file.id,
      name: file.file_name,
      size: formatFileSize(file.file_size_bytes || 0),
      type: getFileType(file.file_type || ""),
      uploadedAt: file.created_at || "",
    })),
    deliverables: (dbProject.deliverables || []).map((del: {
      id: string;
      file_name: string;
      file_size_bytes?: number | null;
      version?: number | null;
      created_at?: string | null;
      is_final?: boolean | null;
    }) => ({
      id: del.id,
      name: del.file_name,
      size: formatFileSize(del.file_size_bytes || 0),
      version: del.version || 1,
      uploadedAt: del.created_at || "",
      isFinal: del.is_final || false,
    })),
    qualityReports: [
      {
        type: "ai" as const,
        status: dbProject.ai_score !== null ? "passed" : "locked",
        score: dbProject.ai_score || undefined,
        reportUrl: dbProject.ai_report_url || undefined,
      },
      {
        type: "plagiarism" as const,
        status: dbProject.plagiarism_score !== null ? "passed" : "locked",
        score: dbProject.plagiarism_score || undefined,
        reportUrl: dbProject.plagiarism_report_url || undefined,
      },
    ],
    chatMessages: [], // Will be fetched separately from chat_messages table
  };
}

/**
 * Format file size to human readable string
 */
function formatFileSize(bytes: number): string {
  if (bytes === 0) return "0 B";
  const k = 1024;
  const sizes = ["B", "KB", "MB", "GB"];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return `${parseFloat((bytes / Math.pow(k, i)).toFixed(1))} ${sizes[i]}`;
}

/**
 * Get file type from mime type or extension
 */
function getFileType(mimeType: string): "pdf" | "doc" | "docx" | "image" {
  if (mimeType.includes("pdf")) return "pdf";
  if (mimeType.includes("word") || mimeType.includes("docx")) return "docx";
  if (mimeType.includes("doc")) return "doc";
  if (mimeType.includes("image")) return "image";
  return "doc";
}

/**
 * Loading skeleton for project detail
 */
function LoadingSkeleton() {
  return (
    <div className="flex items-center justify-center min-h-[60vh]">
      <div className="flex flex-col items-center gap-3">
        <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
        <p className="text-sm text-muted-foreground">Loading project...</p>
      </div>
    </div>
  );
}

/**
 * Not found state
 */
function NotFoundState() {
  const router = useRouter();

  return (
    <div className="flex items-center justify-center min-h-[60vh]">
      <div className="flex flex-col items-center gap-4 text-center">
        <div className="h-16 w-16 rounded-full bg-muted flex items-center justify-center">
          <span className="text-2xl">🔍</span>
        </div>
        <h2 className="text-xl font-semibold">Project Not Found</h2>
        <p className="text-sm text-muted-foreground max-w-sm">
          The project you&apos;re looking for doesn&apos;t exist or you don&apos;t have access to it.
        </p>
        <button
          onClick={() => router.push("/projects")}
          className="px-4 py-2 bg-primary text-primary-foreground rounded-lg text-sm font-medium hover:bg-primary/90 transition-colors"
        >
          Back to Projects
        </button>
      </div>
    </div>
  );
}

/**
 * Project Detail Page - Client Component
 * Uses client-side auth for consistent session handling
 */
export default function ProjectDetailPage() {
  const params = useParams();
  const router = useRouter();
  const id = params.id as string;

  const [project, setProject] = useState<ProjectDetail | null>(null);
  const [userId, setUserId] = useState<string>("");
  const [isLoading, setIsLoading] = useState(true);
  const [notFound, setNotFound] = useState(false);

  // Track if initial fetch has been done
  const hasFetched = useRef(false);

  useEffect(() => {
    if (hasFetched.current || !id) return;
    hasFetched.current = true;

    const loadData = async () => {
      const supabase = createClient();

      // Check auth first
      const { data: { user } } = await supabase.auth.getUser();

      if (!user) {
        router.push("/login");
        return;
      }

      setUserId(user.id);

      // Fetch project
      try {
        const dbProject = await getProjectById(id);
        const transformedProject = transformProjectToDetail(dbProject);

        if (!transformedProject) {
          setNotFound(true);
        } else {
          setProject(transformedProject);
        }
      } catch (error) {
        console.error("Error fetching project:", error);
        setNotFound(true);
      }

      setIsLoading(false);
    };

    loadData();
  }, [id, router]);

  if (isLoading) {
    return <LoadingSkeleton />;
  }

  if (notFound || !project) {
    return <NotFoundState />;
  }

  return <ProjectDetailClient project={project} userId={userId} />;
}
