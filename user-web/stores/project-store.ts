import { create } from "zustand";
import { getProjects } from "@/lib/actions/data";
import type { ProjectStatus, ProjectTab } from "@/types/project";

// Re-export types for backwards compatibility
export type { ProjectStatus, ProjectTab } from "@/types/project";

/**
 * Project interface matching Supabase schema
 */
export interface Project {
  id: string;
  project_number: string;
  user_id: string;
  service_type: string;
  title: string;
  description: string | null;
  subject_id: string | null;
  reference_style_id: string | null;
  word_count: number | null;
  page_count: number | null;
  deadline: string | null;
  urgency_level: string | null;
  status: ProjectStatus;
  progress_percentage: number;
  user_quote: number | null;
  system_quote: number | null;
  final_quote: number | null;
  special_instructions: string | null;
  created_at: string;
  updated_at: string;
  submitted_at: string | null;
  delivered_at: string | null;
  completed_at: string | null;
  cancelled_at: string | null;
  // Joined relations
  subject?: {
    id: string;
    name: string;
    icon: string;
    slug: string;
  } | null;
  reference_style?: {
    id: string;
    name: string;
    version: string;
  } | null;
  files?: ProjectFile[];
  deliverables?: ProjectDeliverable[];
  quotes?: ProjectQuote[];
  revisions?: ProjectRevision[];
  timeline?: ProjectTimeline[];
  // Backward compatibility fields
  projectNumber?: string;
  subjectId?: string;
  subjectName?: string;
  subjectIcon?: string;
  progress?: number;
  quoteAmount?: number;
  wordCount?: number;
  referenceStyle?: string;
  createdAt?: string;
  deliveredAt?: string;
  completedAt?: string;
  cancelledAt?: string;
}

export interface ProjectFile {
  id: string;
  project_id: string;
  file_name: string;
  file_url: string;
  file_type: string;
  file_size: number;
  uploaded_by: string;
  created_at: string;
}

export interface ProjectDeliverable {
  id: string;
  project_id: string;
  file_name: string;
  file_url: string;
  version: number;
  created_at: string;
}

export interface ProjectQuote {
  id: string;
  project_id: string;
  amount: number;
  breakdown: Record<string, unknown> | null;
  status: string;
  created_at: string;
}

export interface ProjectRevision {
  id: string;
  project_id: string;
  revision_number: number;
  description: string;
  status: string;
  created_at: string;
}

export interface ProjectTimeline {
  id: string;
  project_id: string;
  event_type: string;
  description: string;
  created_at: string;
}

/** Default number of projects per page */
const PAGE_SIZE = 10;

interface ProjectState {
  projects: Project[];
  activeTab: ProjectTab;
  isLoading: boolean;
  error: string | null;
  hasUnpaidQuotes: boolean;
  unpaidProject: Project | null;
  showPaymentPrompt: boolean;
  // Pagination state
  currentPage: number;
  pageSize: number;

  // Actions
  fetchProjects: (status?: string) => Promise<void>;
  setActiveTab: (tab: ProjectTab) => void;
  getProjectsByTab: (tab: ProjectTab) => Project[];
  getPaginatedProjects: (tab: ProjectTab) => {
    projects: Project[];
    totalCount: number;
    totalPages: number;
    currentPage: number;
  };
  getProjectById: (id: string) => Project | undefined;
  setLoading: (loading: boolean) => void;
  dismissPaymentPrompt: () => void;
  checkUnpaidQuotes: () => void;
  setPage: (page: number) => void;
  setPageSize: (size: number) => void;
}

/**
 * Tab to statuses mapping
 * Maps each tab to the project statuses that should appear in it
 */
const tabStatuses: Record<ProjectTab, ProjectStatus[]> = {
  in_review: ["draft", "submitted", "analyzing", "quoted", "payment_pending"],
  in_progress: [
    "paid",
    "assigning",
    "assigned",
    "in_progress",
    "qc_rejected",
    "in_revision",
  ],
  for_review: [
    "submitted_for_qc",
    "qc_in_progress",
    "qc_approved",
    "delivered",
    "revision_requested",
    "auto_approved",
  ],
  history: ["completed", "cancelled", "refunded"],
};

/**
 * Transforms database project to component format
 */
function transformProject(p: Project): Project {
  return {
    ...p,
    projectNumber: p.project_number,
    subjectId: p.subject_id || undefined,
    subjectName: p.subject?.name,
    subjectIcon: p.subject?.icon,
    progress: p.progress_percentage,
    quoteAmount: p.final_quote || p.user_quote || undefined,
    wordCount: p.word_count || undefined,
    referenceStyle: p.reference_style?.name,
    createdAt: p.created_at,
    deliveredAt: p.delivered_at || undefined,
    completedAt: p.completed_at || undefined,
    cancelledAt: p.cancelled_at || undefined,
  };
}

/**
 * Project store for managing project state with Supabase integration
 */
export const useProjectStore = create<ProjectState>((set, get) => ({
  projects: [],
  activeTab: "in_review",
  isLoading: false,
  error: null,
  hasUnpaidQuotes: false,
  unpaidProject: null,
  showPaymentPrompt: false,
  currentPage: 1,
  pageSize: PAGE_SIZE,

  /**
   * Fetches projects from Supabase
   */
  fetchProjects: async (status?: string) => {
    set({ isLoading: true, error: null });
    try {
      const data = await getProjects(status);
      const projects = data.map(transformProject);

      // Check for unpaid quotes
      const unpaidProject = projects.find(
        (p) => p.status === "payment_pending" || p.status === "quoted"
      );

      set({
        projects,
        isLoading: false,
        hasUnpaidQuotes: !!unpaidProject,
        unpaidProject: unpaidProject || null,
        showPaymentPrompt: !!unpaidProject,
      });
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : "Failed to fetch projects",
        isLoading: false,
      });
    }
  },

  /**
   * Sets active tab and resets pagination to first page
   */
  setActiveTab: (tab) => set({ activeTab: tab, currentPage: 1 }),

  /**
   * Gets projects filtered by tab
   */
  getProjectsByTab: (tab) => {
    const { projects } = get();
    const statuses = tabStatuses[tab];
    return projects.filter((project) => statuses.includes(project.status));
  },

  /**
   * Gets paginated projects for a tab
   */
  getPaginatedProjects: (tab) => {
    const { currentPage, pageSize } = get();
    const allProjects = get().getProjectsByTab(tab);
    const totalCount = allProjects.length;
    const totalPages = Math.ceil(totalCount / pageSize);
    const startIndex = (currentPage - 1) * pageSize;
    const projects = allProjects.slice(startIndex, startIndex + pageSize);

    return { projects, totalCount, totalPages, currentPage };
  },

  /**
   * Gets a single project by ID
   */
  getProjectById: (id) => {
    const { projects } = get();
    return projects.find((project) => project.id === id);
  },

  /**
   * Sets loading state
   */
  setLoading: (loading) => set({ isLoading: loading }),

  /**
   * Dismisses payment prompt
   */
  dismissPaymentPrompt: () => set({ showPaymentPrompt: false }),

  /**
   * Checks for unpaid quotes
   */
  checkUnpaidQuotes: () => {
    const { projects } = get();
    const unpaidProject = projects.find(
      (p) => p.status === "payment_pending" || p.status === "quoted"
    );
    set({
      hasUnpaidQuotes: !!unpaidProject,
      unpaidProject: unpaidProject || null,
    });
  },

  /**
   * Sets current page number
   */
  setPage: (page) => set({ currentPage: page }),

  /**
   * Sets page size and resets to first page
   */
  setPageSize: (size) => set({ pageSize: size, currentPage: 1 }),
}));
