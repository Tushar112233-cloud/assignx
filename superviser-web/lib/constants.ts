/**
 * @fileoverview Application constants including branding, navigation, and configuration.
 * @module lib/constants
 */

export const APP_NAME = "AdminX"
export const APP_TAGLINE = "Quality. Integrity. Supervision."
export const APP_DESCRIPTION = "AssignX Supervisor Panel"

export const ROUTES = {
  login: "/login",
  dashboard: "/dashboard",
  onboarding: "/onboarding",
  profileSetup: "/onboarding",  // Profile setup is handled by onboarding flow
  projects: "/projects",
  doers: "/doers",
  users: "/users",
  chat: "/chat",
  earnings: "/earnings",
  resources: "/resources",
  profile: "/profile",
  settings: "/settings",
  support: "/support",
} as const

export const BRAND_COLORS = {
  primary: "#1E3A5F", // Dark Blue
  secondary: "#64748B", // Slate Grey
  background: {
    light: "#FFFFFF",
    dark: "#0a0a0a",
  },
} as const

export const STATUS_COLORS = {
  analyzing: { bg: "bg-yellow-100", text: "text-yellow-800", hex: "#FBBF24" },
  payment_pending: { bg: "bg-orange-100", text: "text-orange-800", hex: "#F97316" },
  in_progress: { bg: "bg-blue-100", text: "text-blue-800", hex: "#3B82F6" },
  for_review: { bg: "bg-green-100", text: "text-green-800", hex: "#22C55E" },
  completed: { bg: "bg-gray-100", text: "text-gray-800", hex: "#6B7280" },
  urgent: { bg: "bg-red-100", text: "text-red-800", hex: "#EF4444" },
} as const

export const PROJECT_STATUS_MAP: Record<string, { label: string; color: keyof typeof STATUS_COLORS }> = {
  draft: { label: "Draft", color: "completed" },
  submitted: { label: "Submitted", color: "analyzing" },
  analyzing: { label: "Analyzing", color: "analyzing" },
  quoted: { label: "Quoted", color: "analyzing" },
  payment_pending: { label: "Payment Pending", color: "payment_pending" },
  paid: { label: "Paid", color: "for_review" },
  assigning: { label: "Assigning", color: "in_progress" },
  assigned: { label: "Assigned", color: "in_progress" },
  in_progress: { label: "In Progress", color: "in_progress" },
  submitted_for_qc: { label: "Submitted for QC", color: "for_review" },
  qc_in_progress: { label: "QC In Progress", color: "for_review" },
  qc_approved: { label: "QC Approved", color: "for_review" },
  qc_rejected: { label: "QC Rejected", color: "urgent" },
  delivered: { label: "Delivered", color: "for_review" },
  revision_requested: { label: "Revision Requested", color: "urgent" },
  in_revision: { label: "In Revision", color: "urgent" },
  completed: { label: "Completed", color: "completed" },
  auto_approved: { label: "Auto Approved", color: "completed" },
  cancelled: { label: "Cancelled", color: "completed" },
  refunded: { label: "Refunded", color: "completed" },
} as const

export const PRICING_CONFIG = {
  urgencyMultipliers: {
    "24h": 1.5,
    "48h": 1.3,
    "72h": 1.15,
    default: 1.0,
  },
  complexityMultipliers: {
    easy: 1.0,
    medium: 1.2,
    hard: 1.5,
  },
  supervisorCommissionPercent: 15,
  platformFeePercent: 20,
} as const

export const NAV_ITEMS = [
  { title: "Dashboard", href: "/dashboard", icon: "LayoutDashboard" },
  { title: "Projects", href: "/projects", icon: "FolderKanban" },
  { title: "Doers", href: "/doers", icon: "Users" },
  { title: "Users", href: "/users", icon: "UserCircle" },
  { title: "Chat", href: "/chat", icon: "MessageSquare" },
  { title: "Earnings", href: "/earnings", icon: "Wallet" },
  { title: "Resources", href: "/resources", icon: "BookOpen" },
] as const

export const SECONDARY_NAV_ITEMS = [
  { title: "Profile", href: "/profile", icon: "User" },
  { title: "Settings", href: "/settings", icon: "Settings" },
  { title: "Support", href: "/support", icon: "HelpCircle" },
] as const

export const QUALIFICATIONS = [
  { value: "high_school", label: "High School" },
  { value: "bachelors", label: "Bachelor's Degree" },
  { value: "masters", label: "Master's Degree" },
  { value: "phd", label: "Ph.D. / Doctorate" },
  { value: "postdoc", label: "Post-Doctoral" },
  { value: "professional", label: "Professional Certification" },
] as const

export const EXPERTISE_AREAS = [
  { value: "engineering", label: "Engineering" },
  { value: "computer_science", label: "Computer Science" },
  { value: "mathematics", label: "Mathematics" },
  { value: "physics", label: "Physics" },
  { value: "chemistry", label: "Chemistry" },
  { value: "biology", label: "Biology" },
  { value: "medicine", label: "Medicine" },
  { value: "law", label: "Law" },
  { value: "business", label: "Business" },
  { value: "finance", label: "Finance" },
  { value: "economics", label: "Economics" },
  { value: "psychology", label: "Psychology" },
  { value: "sociology", label: "Sociology" },
  { value: "literature", label: "Literature" },
  { value: "history", label: "History" },
  { value: "arts", label: "Arts & Design" },
  { value: "education", label: "Education" },
  { value: "nursing", label: "Nursing" },
] as const

export const INDIAN_BANKS = [
  { value: "sbi", label: "State Bank of India" },
  { value: "hdfc", label: "HDFC Bank" },
  { value: "icici", label: "ICICI Bank" },
  { value: "axis", label: "Axis Bank" },
  { value: "kotak", label: "Kotak Mahindra Bank" },
  { value: "pnb", label: "Punjab National Bank" },
  { value: "bob", label: "Bank of Baroda" },
  { value: "canara", label: "Canara Bank" },
  { value: "union", label: "Union Bank of India" },
  { value: "idbi", label: "IDBI Bank" },
  { value: "indusind", label: "IndusInd Bank" },
  { value: "yes", label: "Yes Bank" },
  { value: "other", label: "Other" },
] as const

export const VERIFICATION_STATUS = {
  pending: { label: "Pending Review", color: "text-yellow-600", bgColor: "bg-yellow-100" },
  in_review: { label: "Under Review", color: "text-blue-600", bgColor: "bg-blue-100" },
  verified: { label: "Verified", color: "text-green-600", bgColor: "bg-green-100" },
  rejected: { label: "Rejected", color: "text-red-600", bgColor: "bg-red-100" },
} as const
