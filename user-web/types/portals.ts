/**
 * Portal role types for multi-role user system
 */
export type PortalRole = "student" | "professional" | "business";

/**
 * Job listing categories
 */
export type JobCategory =
  | "engineering"
  | "design"
  | "marketing"
  | "sales"
  | "finance"
  | "product"
  | "data"
  | "operations"
  | "hr"
  | "legal";

/**
 * Job type classifications
 */
export type JobType =
  | "full-time"
  | "part-time"
  | "contract"
  | "internship"
  | "freelance";

/**
 * Funding stage for business portal
 */
export type FundingStage =
  | "pre-seed"
  | "seed"
  | "series-a"
  | "series-b"
  | "series-c"
  | "growth";

/**
 * Job listing interface
 */
export interface JobListing {
  id: string;
  title: string;
  company: string;
  companyLogo?: string;
  location: string;
  type: JobType;
  category: JobCategory;
  salary: string | null;
  salaryRaw?: { min: number; max: number; currency: string } | null;
  description: string;
  requirements?: string[];
  skills?: string[];
  postedAt: string;
  isRemote: boolean;
  tags: string[];
  applyUrl?: string | null;
  applicationCount?: number;
  isActive?: boolean;
}

/**
 * Job application interface
 */
export interface JobApplicationEntry {
  id: string;
  jobId: string;
  job?: JobListing;
  resumeUrl: string;
  coverLetter?: string | null;
  status: 'applied' | 'reviewing' | 'shortlisted' | 'rejected';
  created_at: string;
}

/**
 * Investor/VC card interface
 */
export interface InvestorCard {
  id: string;
  name: string;
  firm: string;
  avatar?: string;
  fundingStages: FundingStage[];
  sectors: string[];
  ticketSize: string;
  portfolio: number;
  bio: string;
}

/**
 * Pitch deck entry
 */
export interface PitchDeck {
  id: string;
  name: string;
  uploadedAt: string;
  status: "pending" | "reviewed" | "shortlisted" | "rejected";
  fileUrl?: string;
  description?: string;
  feedback?: string;
}
