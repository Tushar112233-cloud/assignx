/** Admin role types */
export type AdminRole = "super_admin" | "admin" | "moderator" | "support" | "viewer";

/** Admin user record from the admins table */
export type AdminUser = {
  id: string;
  profile_id: string;
  email: string | null;
  admin_role: AdminRole;
  permissions: AdminPermissions | null;
  is_active: boolean;
  last_active_at: string | null;
  created_at: string;
  updated_at: string;
};

/** Granular admin permissions */
export type AdminPermissions = {
  manage_users?: boolean;
  manage_projects?: boolean;
  manage_wallets?: boolean;
  manage_tickets?: boolean;
  manage_banners?: boolean;
  manage_settings?: boolean;
  manage_content?: boolean;
  manage_experts?: boolean;
  manage_learning?: boolean;
  view_analytics?: boolean;
  process_refunds?: boolean;
  moderate_content?: boolean;
};

/** Dashboard stats returned by get_admin_dashboard_stats() */
export type DashboardStats = {
  total_users: number;
  active_projects: number;
  total_revenue: number;
  pending_tickets: number;
  new_users_today: number;
  new_users_week: number;
  new_users_month: number;
  total_supervisors: number;
  total_doers: number;
  total_wallet_balance: number;
};

/** User growth chart data point */
export type UserGrowthData = {
  date: string;
  students: number;
  professionals: number;
  businesses: number;
  total: number;
};

/** Revenue chart data point */
export type RevenueData = {
  date: string;
  revenue: number;
  refunds: number;
};

/** Generic paginated response */
export type PaginatedResponse<T> = {
  data: T[];
  total: number;
  page: number;
  per_page: number;
  total_pages: number;
};

/** Admin audit log entry */
export type AdminAuditLog = {
  id: string;
  admin_id: string;
  action: string;
  target_type: string | null;
  target_id: string | null;
  details: Record<string, unknown> | null;
  ip_address: string | null;
  created_at: string;
};

/** Admin user list item (returned by admin_get_users) */
export type AdminUserListItem = {
  id: string;
  full_name: string;
  email: string;
  avatar_url: string | null;
  user_type: string;
  is_active: boolean;
  city: string | null;
  created_at: string;
  wallet_balance: number;
  project_count: number;
};

/** Admin project list item (returned by admin_get_projects) */
export type AdminProjectListItem = {
  id: string;
  title: string;
  description: string | null;
  status: string;
  payment_status: string | null;
  budget: number | null;
  final_amount: number | null;
  deadline: string | null;
  created_at: string;
  updated_at: string;
  user_id: string;
  user_name: string;
  supervisor_id: string | null;
  supervisor_name: string | null;
  doer_id: string | null;
  doer_name: string | null;
};

/** Financial summary (returned by admin_get_financial_summary) */
export type FinancialSummary = {
  total_revenue: number;
  refunds: number;
  payouts: number;
  platform_fees: number;
  net_revenue: number;
  avg_project_value: number;
  transaction_count: number;
};

/** Transaction ledger item */
export type TransactionLedgerItem = {
  id: string;
  wallet_id: string;
  transaction_type: string;
  amount: number;
  status: string;
  description: string | null;
  reference_id: string | null;
  created_at: string;
  profile_name: string | null;
  profile_email: string | null;
};

/** Ticket stats (returned by admin_get_ticket_stats) */
export type TicketStats = {
  open_count: number;
  in_progress_count: number;
  waiting_response_count: number;
  resolved_count: number;
  closed_count: number;
  total_count: number;
  avg_resolution_time_hours: number;
  by_priority: {
    low: number;
    medium: number;
    high: number;
    urgent: number;
  };
  avg_satisfaction: number;
};

/** Flagged content item */
export type FlaggedContentItem = {
  id: string;
  content_type: string;
  content: string | null;
  title: string | null;
  reported_by_id: string | null;
  reported_by_name: string | null;
  flagged_at: string;
  status: string;
};

/** Expert application item */
export type ExpertApplicationItem = {
  id: string;
  user_id: string;
  full_name: string;
  email: string;
  avatar_url: string | null;
  headline: string;
  designation: string;
  organization: string | null;
  category: string;
  specializations: string[];
  hourly_rate: number;
  verification_status: string;
  avg_rating: number;
  session_count: number;
  total_reviews: number;
  is_active: boolean;
  created_at: string;
};

/** Supervisor overview item */
export type SupervisorOverviewItem = {
  id: string;
  full_name: string;
  email: string;
  avatar_url: string | null;
  is_active: boolean;
  created_at: string;
  total_projects: number;
  completed_projects: number;
  active_projects: number;
  completion_rate: number;
};

/** Doer overview item */
export type DoerOverviewItem = {
  id: string;
  full_name: string;
  email: string;
  avatar_url: string | null;
  is_active: boolean;
  created_at: string;
  total_tasks: number;
  completed_tasks: number;
  active_tasks: number;
  completion_rate: number;
  avg_rating: number;
};

/** Analytics overview (returned by admin_get_analytics_overview) */
export type AnalyticsOverview = {
  user_growth: {
    current_period: number;
    previous_period: number;
    total: number;
  };
  revenue_trend: {
    current_period: number;
    previous_period: number;
  };
  project_completion_rate: number;
  avg_project_duration_days: number;
  top_subjects: { subject: string; count: number }[];
  user_type_distribution: {
    student: number;
    professional: number;
    business: number;
    supervisor: number;
    doer: number;
  };
};

/** College stats (returned by admin_get_college_stats) */
export type CollegeStats = {
  total_colleges: number;
  colleges: {
    id: string;
    college_name: string;
    city: string | null;
    state: string | null;
    user_count: number;
    student_count: number;
    professional_count: number;
    doer_count: number;
  }[];
};

/** Learning resource record */
export type LearningResource = {
  id: string;
  title: string;
  description: string | null;
  content_type: string;
  content_url: string | null;
  thumbnail_url: string | null;
  category: string | null;
  tags: string[];
  target_audience: string[];
  is_active: boolean;
  is_featured: boolean;
  view_count: number;
  created_by: string | null;
  created_at: string;
  updated_at: string;
};

/** Banner record */
export type AdminBanner = {
  id: string;
  title: string;
  subtitle: string | null;
  image_url: string | null;
  image_url_mobile: string | null;
  display_location: string | null;
  display_order: number;
  start_date: string | null;
  end_date: string | null;
  is_active: boolean;
  target_roles: string[];
  target_user_types: string[];
  cta_text: string | null;
  cta_url: string | null;
  cta_action: string | null;
  click_count: number;
  impression_count: number;
  created_at: string;
  updated_at: string;
};

/** App setting record */
export type AppSetting = {
  id: string;
  key: string;
  value: Record<string, unknown>;
  category: string | null;
  description: string | null;
  created_at: string;
  updated_at: string;
};
