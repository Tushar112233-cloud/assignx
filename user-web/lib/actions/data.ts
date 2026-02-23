"use server";

import { createClient, createAdminClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";
import {
  createProjectSchema,
  fileUploadSchema,
  createSupportTicketSchema,
} from "@/lib/validations";

/**
 * Check if login is required based on environment variable
 */
function isLoginRequired(): boolean {
  return process.env.NEXT_PUBLIC_REQUIRE_LOGIN !== "false";
}

/**
 * Get the dev user email from environment
 */
function getDevUserEmail(): string {
  return process.env.NEXT_PUBLIC_DEV_USER_EMAIL || "omrajpal.exe@gmail.com";
}

/**
 * Get user ID for data fetching - handles both authenticated and dev mode
 * @returns User ID or null if not available
 */
async function getUserIdForDataFetch(): Promise<string | null> {
  if (!isLoginRequired()) {
    // In dev mode, use admin client to bypass RLS
    const adminClient = createAdminClient();

    if (!adminClient) {
      console.error("❌ [getUserIdForDataFetch] Admin client not available - SUPABASE_SERVICE_ROLE_KEY may not be set");
      return null;
    }

    const devEmail = getDevUserEmail();
    console.log("🔧 [getUserIdForDataFetch] Dev mode - fetching user:", devEmail);

    const { data: profile, error } = await adminClient
      .from("profiles")
      .select("id")
      .eq("email", devEmail)
      .single();

    if (error) {
      console.error("❌ [getUserIdForDataFetch] Error fetching dev user:", error);
      return null;
    }

    console.log("✅ [getUserIdForDataFetch] Found user ID:", profile?.id);
    return profile?.id || null;
  }

  // Normal auth flow
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  return user?.id || null;
}

/**
 * Get current user's profile with related data
 */
export async function getProfile() {
  // Check if login is required
  const requireLogin = process.env.NEXT_PUBLIC_REQUIRE_LOGIN !== "false";

  console.log("🔧 [getProfile] Config:", {
    requireLogin,
    devEmail: process.env.NEXT_PUBLIC_DEV_USER_EMAIL,
    hasServiceKey: !!process.env.SUPABASE_SERVICE_ROLE_KEY,
    serviceKeyLength: process.env.SUPABASE_SERVICE_ROLE_KEY?.length || 0,
  });

  if (!requireLogin) {
    // Use default dev user email
    const devEmail = process.env.NEXT_PUBLIC_DEV_USER_EMAIL || "omrajpal.exe@gmail.com";
    console.log("🔧 [getProfile] Dev mode - fetching profile for:", devEmail);
    const profile = await getProfileByEmail(devEmail);
    console.log("🔧 [getProfile] Dev mode result:", profile ? "Found" : "Not found", profile?.id);
    return profile;
  }

  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) return null;

  const { data: profile } = await supabase
    .from("profiles")
    .select(`
      *,
      students (
        *,
        university:universities (*),
        course:courses (*)
      ),
      professionals (
        *,
        industry:industries (*)
      ),
      wallet:wallets (*)
    `)
    .eq("id", user.id)
    .single();

  return profile;
}

/**
 * Get profile by email address
 * Used for dev mode when authentication is bypassed
 * Uses admin client to bypass RLS
 * @param email - The email address to look up
 */
export async function getProfileByEmail(email: string) {
  console.log("🔧 [getProfileByEmail] Starting for email:", email);

  // Use admin client to bypass RLS in dev mode
  const adminClient = createAdminClient();

  if (!adminClient) {
    console.error("❌ [getProfileByEmail] Admin client not available");
    console.error("❌ [getProfileByEmail] SUPABASE_SERVICE_ROLE_KEY length:", process.env.SUPABASE_SERVICE_ROLE_KEY?.length || 0);
    return null;
  }

  console.log("🔧 [getProfileByEmail] Admin client created, querying...");

  const { data: profile, error } = await adminClient
    .from("profiles")
    .select(`
      *,
      students (
        *,
        university:universities (*),
        course:courses (*)
      ),
      professionals (
        *,
        industry:industries (*)
      ),
      wallet:wallets (*)
    `)
    .eq("email", email)
    .single();

  if (error) {
    console.error("❌ [getProfileByEmail] Query error:", error.message, error.code);
    return null;
  }

  console.log("✅ [getProfileByEmail] Found profile:", profile?.id, profile?.full_name);
  return profile;
}

/**
 * Get user's projects with filtering
 */
export async function getProjects(status?: string) {
  const supabase = await createClient();
  const userId = await getUserIdForDataFetch();

  if (!userId) return [];

  let query = supabase
    .from("projects")
    .select(`
      *,
      subject:subjects (id, name, icon, slug),
      reference_style:reference_styles (id, name, version)
    `)
    .eq("user_id", userId)
    .order("created_at", { ascending: false });

  if (status) {
    query = query.eq("status", status);
  }

  const { data: projects, error } = await query;

  if (error) {
    return [];
  }

  return projects || [];
}

/**
 * Get single project by ID
 */
export async function getProjectById(id: string) {
  const supabase = await createClient();
  const userId = await getUserIdForDataFetch();

  if (!userId) return null;

  const { data: project, error } = await supabase
    .from("projects")
    .select(`
      *,
      subject:subjects (id, name, icon, slug),
      reference_style:reference_styles (id, name, version),
      files:project_files (*),
      deliverables:project_deliverables (*),
      quotes:project_quotes (*),
      revisions:project_revisions (*),
      timeline:project_timeline (*)
    `)
    .eq("id", id)
    .eq("user_id", userId)
    .single();

  if (error) {
    return null;
  }

  return project;
}

/**
 * Get user's notifications
 */
export async function getNotifications(limit = 20) {
  const supabase = await createClient();
  const userId = await getUserIdForDataFetch();

  if (!userId) return [];

  const { data: notifications, error } = await supabase
    .from("notifications")
    .select("*")
    .eq("profile_id", userId)
    .eq("target_role", "user")
    .order("created_at", { ascending: false })
    .limit(limit);

  if (error) {
    return [];
  }

  return notifications || [];
}

/**
 * Mark notification as read
 */
export async function markNotificationRead(id: string) {
  const supabase = await createClient();
  const userId = await getUserIdForDataFetch();

  if (!userId) return { error: "Not authenticated" };

  const { error } = await supabase
    .from("notifications")
    .update({ is_read: true, read_at: new Date().toISOString() })
    .eq("id", id)
    .eq("profile_id", userId)
    .eq("target_role", "user");

  if (error) {
    return { error: error.message };
  }

  revalidatePath("/", "layout");
  return { success: true };
}

/**
 * Mark all notifications as read
 */
export async function markAllNotificationsRead() {
  const supabase = await createClient();
  const userId = await getUserIdForDataFetch();

  if (!userId) return { error: "Not authenticated" };

  const { error } = await supabase
    .from("notifications")
    .update({ is_read: true, read_at: new Date().toISOString() })
    .eq("profile_id", userId)
    .eq("target_role", "user")
    .eq("is_read", false);

  if (error) {
    return { error: error.message };
  }

  revalidatePath("/", "layout");
  return { success: true };
}

/**
 * Get user's wallet
 */
export async function getWallet() {
  const supabase = await createClient();
  const userId = await getUserIdForDataFetch();

  if (!userId) return null;

  const { data: wallet, error } = await supabase
    .from("wallets")
    .select("*")
    .eq("profile_id", userId)
    .eq("wallet_type", "user")
    .single();

  if (error) {
    return null;
  }

  return wallet;
}

/**
 * Get wallet transactions
 */
export async function getWalletTransactions(limit = 20) {
  const supabase = await createClient();
  const userId = await getUserIdForDataFetch();

  if (!userId) return [];

  const { data: wallet } = await supabase
    .from("wallets")
    .select("id")
    .eq("profile_id", userId)
    .eq("wallet_type", "user")
    .single();

  if (!wallet) return [];

  const { data: transactions, error } = await supabase
    .from("wallet_transactions")
    .select(`
      id,
      wallet_id,
      amount,
      transaction_type,
      description,
      reference_type,
      reference_id,
      balance_after,
      status,
      created_at
    `)
    .eq("wallet_id", wallet.id)
    .order("created_at", { ascending: false })
    .limit(limit);

  if (error) {
    return [];
  }

  return transactions || [];
}

/**
 * Search for a user by email address
 * Used for wallet-to-wallet transfer recipient lookup
 * Returns null (not error) for not-found to prevent email enumeration
 */
export async function searchUserByEmail(email: string): Promise<{
  success: boolean;
  user: { id: string; email: string; full_name: string; avatar_url: string | null } | null;
} | null> {
  const supabase = await createClient();
  const userId = await getUserIdForDataFetch();

  if (!userId) return null;

  const trimmedEmail = email.trim().toLowerCase();
  if (!trimmedEmail || !trimmedEmail.includes("@")) return null;

  const { data: profile } = await supabase
    .from("profiles")
    .select("id, email, full_name, avatar_url, is_active")
    .eq("email", trimmedEmail)
    .eq("is_active", true)
    .single();

  if (!profile || profile.id === userId) return null;

  return {
    success: true,
    user: {
      id: profile.id,
      email: profile.email,
      full_name: profile.full_name,
      avatar_url: profile.avatar_url,
    },
  };
}

/**
 * Get active banners
 */
export async function getBanners(location = "dashboard") {
  const supabase = await createClient();

  const now = new Date().toISOString();

  const { data: banners, error } = await supabase
    .from("banners")
    .select("*")
    .eq("display_location", location)
    .eq("is_active", true)
    .or(`start_date.is.null,start_date.lte.${now}`)
    .or(`end_date.is.null,end_date.gte.${now}`)
    .or('target_roles.is.null,target_roles.cs.{"user"}')
    .order("display_order", { ascending: true });

  if (error) {
    return [];
  }

  return banners || [];
}

/**
 * Get FAQs
 */
export async function getFAQs(category?: string) {
  const supabase = await createClient();

  let query = supabase
    .from("faqs")
    .select("*")
    .eq("is_active", true)
    .or('target_role.is.null,target_role.eq.user')
    .order("display_order", { ascending: true });

  if (category) {
    query = query.eq("category", category);
  }

  const { data: faqs, error } = await query;

  if (error) {
    return [];
  }

  return faqs || [];
}

/**
 * Get support tickets
 */
export async function getSupportTickets() {
  const supabase = await createClient();
  const userId = await getUserIdForDataFetch();

  if (!userId) return [];

  const { data: tickets, error } = await supabase
    .from("support_tickets")
    .select("*")
    .eq("requester_id", userId)
    .eq("source_role", "user")
    .order("created_at", { ascending: false });

  if (error) {
    return [];
  }

  return tickets || [];
}

/**
 * Create support ticket
 */
export async function createSupportTicket(data: {
  subject: string;
  description: string;
  category?: string;
  projectId?: string;
}) {
  const supabase = await createClient();
  const userId = await getUserIdForDataFetch();

  if (!userId) return { error: "Not authenticated" };

  // Generate ticket number
  const ticketNumber = `TKT-${Date.now().toString(36).toUpperCase()}`;

  const { data: ticket, error } = await supabase
    .from("support_tickets")
    .insert({
      ticket_number: ticketNumber,
      requester_id: userId,
      subject: data.subject,
      description: data.description,
      category: data.category,
      project_id: data.projectId,
      status: "open",
      priority: "medium",
      source_role: "user",
    })
    .select()
    .single();

  if (error) {
    return { error: error.message };
  }

  revalidatePath("/support");
  return { success: true, ticket };
}

/**
 * Get universities list
 */
export async function getUniversities() {
  const supabase = await createClient();

  const { data: universities, error } = await supabase
    .from("universities")
    .select("*")
    .eq("is_active", true)
    .order("name");

  if (error) {
    return [];
  }

  return universities || [];
}

/**
 * Get courses list
 */
export async function getCourses() {
  const supabase = await createClient();

  const { data: courses, error } = await supabase
    .from("courses")
    .select("*")
    .eq("is_active", true)
    .order("name");

  if (error) {
    return [];
  }

  return courses || [];
}

/**
 * Get subjects list
 */
export async function getSubjects() {
  const supabase = await createClient();

  const { data: subjects, error } = await supabase
    .from("subjects")
    .select("*")
    .eq("is_active", true)
    .order("display_order", { ascending: true });

  if (error) {
    return [];
  }

  return subjects || [];
}

/**
 * Get industries list
 */
export async function getIndustries() {
  const supabase = await createClient();

  const { data: industries, error } = await supabase
    .from("industries")
    .select("*")
    .eq("is_active", true)
    .order("name");

  if (error) {
    return [];
  }

  return industries || [];
}

/**
 * Get reference styles
 * Orders by name alphabetically since display_order column doesn't exist
 */
export async function getReferenceStyles() {
  const supabase = await createClient();

  const { data: styles, error } = await supabase
    .from("reference_styles")
    .select("*")
    .eq("is_active", true)
    .order("name", { ascending: true });

  if (error) {
    return [];
  }

  return styles || [];
}

/**
 * Submit user feedback
 * Matches user_feedback table schema from database
 */
export async function submitFeedback(data: {
  overallSatisfaction: number;
  feedbackText?: string;
  wouldRecommend?: boolean;
  improvementSuggestions?: string;
  npsScore?: number;
  projectId?: string;
}) {
  const supabase = await createClient();
  const userId = await getUserIdForDataFetch();

  if (!userId) return { error: "Not authenticated" };

  const { error } = await supabase
    .from("user_feedback")
    .insert({
      user_id: userId,
      overall_satisfaction: data.overallSatisfaction,
      feedback_text: data.feedbackText,
      would_recommend: data.wouldRecommend,
      improvement_suggestions: data.improvementSuggestions,
      nps_score: data.npsScore,
      project_id: data.projectId,
    });

  if (error) {
    return { error: error.message };
  }

  return { success: true };
}

/**
 * Update profile
 */
export async function updateProfile(data: {
  fullName?: string;
  phone?: string;
  city?: string;
  state?: string;
  country?: string;
}) {
  const supabase = await createClient();
  const userId = await getUserIdForDataFetch();

  if (!userId) return { error: "Not authenticated" };

  const { error } = await supabase
    .from("profiles")
    .update({
      full_name: data.fullName,
      phone: data.phone,
      city: data.city,
      state: data.state,
      country: data.country,
      updated_at: new Date().toISOString(),
    })
    .eq("id", userId);

  if (error) {
    return { error: error.message };
  }

  revalidatePath("/profile");
  return { success: true };
}

/**
 * Update student profile
 */
export async function updateStudentProfile(data: {
  universityId?: string;
  courseId?: string;
  semester?: number;
  yearOfStudy?: number;
  expectedGraduationYear?: number;
  studentId?: string;
  dateOfBirth?: string;
}) {
  const supabase = await createClient();
  const userId = await getUserIdForDataFetch();

  if (!userId) return { error: "Not authenticated" };

  const { error } = await supabase
    .from("students")
    .update({
      university_id: data.universityId,
      course_id: data.courseId,
      semester: data.semester,
      year_of_study: data.yearOfStudy,
      expected_graduation_year: data.expectedGraduationYear,
      student_id_number: data.studentId,
      date_of_birth: data.dateOfBirth,
    })
    .eq("profile_id", userId);

  if (error) {
    return { error: error.message };
  }

  revalidatePath("/profile");
  return { success: true };
}

/**
 * Helper to check if a string is a valid UUID
 */
function isUUID(str: string): boolean {
  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  return uuidRegex.test(str);
}

/**
 * Create a new project
 * Handles project creation with server-side validation
 * Supports both UUID and slug identifiers for subjects and reference styles
 */
export async function createProject(data: {
  serviceType: "new_project" | "proofreading" | "plagiarism_check" | "ai_detection" | "expert_opinion";
  title: string;
  subjectId?: string;
  topic?: string;
  wordCount?: number;
  referenceStyleId?: string;
  deadline: string;
  urgencyLevel?: string;
  instructions?: string;
}) {
  // Validate input data
  const validationResult = createProjectSchema.safeParse(data);
  if (!validationResult.success) {
    const errors = validationResult.error.issues.map((e) => e.message).join(", ");
    return { error: `Validation failed: ${errors}` };
  }

  const validatedData = validationResult.data;
  const supabase = await createClient();
  const userId = await getUserIdForDataFetch();

  if (!userId) return { error: "Not authenticated" };

  // Resolve subject ID - lookup by slug if not a UUID
  let resolvedSubjectId: string | null = null;
  if (validatedData.subjectId) {
    if (isUUID(validatedData.subjectId)) {
      resolvedSubjectId = validatedData.subjectId;
    } else {
      // Look up subject by slug
      const { data: subject } = await supabase
        .from("subjects")
        .select("id")
        .eq("slug", validatedData.subjectId)
        .eq("is_active", true)
        .single();

      if (subject) {
        resolvedSubjectId = subject.id;
      }
      // If not found, leave as null (optional field)
    }
  }

  // Resolve reference style ID - lookup by slug if not a UUID
  let resolvedReferenceStyleId: string | null = null;
  if (validatedData.referenceStyleId) {
    if (isUUID(validatedData.referenceStyleId)) {
      resolvedReferenceStyleId = validatedData.referenceStyleId;
    } else {
      // Look up reference style by slug (try slug first, then name match)
      const { data: refStyle } = await supabase
        .from("reference_styles")
        .select("id")
        .or(`slug.eq.${validatedData.referenceStyleId},name.ilike.%${validatedData.referenceStyleId}%`)
        .eq("is_active", true)
        .limit(1)
        .single();

      if (refStyle) {
        resolvedReferenceStyleId = refStyle.id;
      }
      // If not found, leave as null (optional field)
    }
  }

  // Generate project number (format: AX-YYYYYY)
  // Note: The database trigger should handle this, but we provide a fallback
  const projectNumber = `AX-${Date.now().toString().slice(-6)}`;

  // Insert project record with validated and resolved data
  const { data: project, error: projectError } = await supabase
    .from("projects")
    .insert({
      user_id: userId,
      project_number: projectNumber,
      service_type: validatedData.serviceType,
      title: validatedData.title,
      subject_id: resolvedSubjectId,
      topic: validatedData.topic || null,
      word_count: validatedData.wordCount || null,
      reference_style_id: resolvedReferenceStyleId,
      deadline: validatedData.deadline,
      specific_instructions: validatedData.instructions || null,
      status: "submitted",
      source: "website",
    })
    .select("id, project_number")
    .single();

  if (projectError) {
    return { error: "Failed to create project. Please try again." };
  }

  revalidatePath("/projects");
  return {
    success: true,
    projectId: project.id,
    projectNumber: project.project_number,
  };
}

/**
 * Upload file for a project
 * Uses Cloudinary for storage, saves URL to Supabase
 */
export async function uploadProjectFile(
  projectId: string,
  file: {
    name: string;
    type: string;
    size: number;
    base64Data: string;
  }
) {
  // Validate projectId format (UUID)
  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  if (!uuidRegex.test(projectId)) {
    return { error: "Invalid project ID" };
  }

  // Validate file data
  const validationResult = fileUploadSchema.safeParse(file);
  if (!validationResult.success) {
    const errors = validationResult.error.issues.map((e) => e.message).join(", ");
    return { error: `File validation failed: ${errors}` };
  }

  const validatedFile = validationResult.data;
  const supabase = await createClient();
  const userId = await getUserIdForDataFetch();

  if (!userId) return { error: "Not authenticated" };

  // Verify user has a profile (required for FK constraint on uploaded_by)
  const { data: profile, error: profileError } = await supabase
    .from("profiles")
    .select("id")
    .eq("id", userId)
    .single();

  if (profileError || !profile) {
    console.error("[uploadProjectFile] Profile not found for user:", userId, profileError);
    return { error: "User profile not found. Please complete your profile setup first." };
  }

  // Verify project belongs to user
  const { data: projectOwner } = await supabase
    .from("projects")
    .select("user_id")
    .eq("id", projectId)
    .single();

  if (!projectOwner || projectOwner.user_id !== userId) {
    return { error: "Project not found or access denied" };
  }

  // Sanitize file name (remove path separators and special chars)
  const sanitizedFileName = validatedFile.name.replace(/[/\\:*?"<>|]/g, "_");

  // Get clean base64 data (remove data URL prefix if present)
  const base64Data = validatedFile.base64Data.split(",")[1] || validatedFile.base64Data;

  try {
    // Dynamic import of Cloudinary to avoid server-side issues
    const { uploadToCloudinary, getProjectFolder } = await import("@/lib/cloudinary/client");

    // Upload to Cloudinary
    const uploadResult = await uploadToCloudinary(base64Data, {
      folder: getProjectFolder(projectId),
      publicId: `${Date.now()}_${sanitizedFileName.replace(/\.[^/.]+$/, "")}`,
      resourceType: "auto",
    });

    // Create project_files record with Cloudinary URL
    const { error: fileError } = await supabase
      .from("project_files")
      .insert({
        project_id: projectId,
        file_name: sanitizedFileName,
        file_url: uploadResult.url,
        file_type: validatedFile.type,
        file_size_bytes: validatedFile.size,
        file_category: "user_upload",
        uploaded_by: userId,
      });

    if (fileError) {
      console.error("[uploadProjectFile] Database insert error:", {
        error: fileError,
        projectId,
        userId,
        fileName: sanitizedFileName,
      });
      return { error: `Failed to save file record: ${fileError.message || "Unknown error"}` };
    }

    return { success: true, fileUrl: uploadResult.url };
  } catch (uploadError) {
    console.error("Cloudinary upload error:", uploadError);
    return { error: "Failed to upload file. Please try again." };
  }
}

// =============================================================================
// USER PREFERENCES ACTIONS
// =============================================================================

/**
 * Notification preferences structure (matches frontend interface)
 */
interface NotificationPreferencesData {
  emailNotifications: boolean;
  pushNotifications: boolean;
  inAppNotifications: boolean;
  projectUpdates: boolean;
  marketingEmails: boolean;
  weeklyDigest: boolean;
}

/**
 * User preferences data structure (matches frontend interface)
 */
interface UserPreferencesData {
  id?: string;
  theme: "light" | "dark" | "system";
  language: "en" | "es" | "fr";
  notifications: NotificationPreferencesData;
  createdAt?: string;
  updatedAt?: string;
}

/**
 * Default preferences when not set in database
 */
const defaultPreferences: Omit<UserPreferencesData, "id" | "createdAt" | "updatedAt"> = {
  theme: "system",
  language: "en",
  notifications: {
    emailNotifications: true,
    pushNotifications: true,
    inAppNotifications: true,
    projectUpdates: true,
    marketingEmails: false,
    weeklyDigest: true,
  },
};

/**
 * Get user's preferences
 * Returns default preferences if none are stored in database
 */
export async function getUserPreferences(): Promise<UserPreferencesData> {
  const supabase = await createClient();
  const userId = await getUserIdForDataFetch();

  if (!userId) {
    return defaultPreferences as UserPreferencesData;
  }

  const { data: preferences, error } = await supabase
    .from("user_preferences")
    .select("*")
    .eq("user_id", userId)
    .maybeSingle();

  if (error || !preferences) {
    // Return defaults if no preferences found
    return defaultPreferences as UserPreferencesData;
  }

  // Transform database format to frontend format
  return {
    id: preferences.id,
    theme: preferences.theme || defaultPreferences.theme,
    language: preferences.language || defaultPreferences.language,
    notifications: preferences.notifications || defaultPreferences.notifications,
    createdAt: preferences.created_at,
    updatedAt: preferences.updated_at,
  };
}

/**
 * Update user preferences
 * Creates preferences if they don't exist (upsert)
 */
export async function updateUserPreferences(data: {
  theme?: "light" | "dark" | "system";
  language?: "en" | "es" | "fr";
  notifications?: Partial<NotificationPreferencesData>;
}) {
  const supabase = await createClient();
  const userId = await getUserIdForDataFetch();

  if (!userId) return { error: "Not authenticated" };

  // Get existing preferences to merge with updates
  const { data: existing } = await supabase
    .from("user_preferences")
    .select("*")
    .eq("user_id", userId)
    .maybeSingle();

  const now = new Date().toISOString();

  // Merge notifications with existing or defaults
  const currentNotifications = existing?.notifications || defaultPreferences.notifications;
  const mergedNotifications = data.notifications
    ? { ...currentNotifications, ...data.notifications }
    : currentNotifications;

  if (existing) {
    // Update existing preferences
    const { error } = await supabase
      .from("user_preferences")
      .update({
        theme: data.theme || existing.theme,
        language: data.language || existing.language,
        notifications: mergedNotifications,
        updated_at: now,
      })
      .eq("id", existing.id)
      .eq("user_id", userId);

    if (error) {
      return { error: error.message };
    }
  } else {
    // Create new preferences record
    const { error } = await supabase
      .from("user_preferences")
      .insert({
        user_id: userId,
        theme: data.theme || defaultPreferences.theme,
        language: data.language || defaultPreferences.language,
        notifications: mergedNotifications,
        created_at: now,
        updated_at: now,
      });

    if (error) {
      return { error: error.message };
    }
  }

  revalidatePath("/profile");
  return { success: true };
}

/**
 * Update theme preference only
 * Convenience method for theme toggle
 */
export async function updateThemePreference(theme: "light" | "dark" | "system") {
  return updateUserPreferences({ theme });
}

/**
 * Update language preference only
 * Convenience method for language selector
 */
export async function updateLanguagePreference(language: "en" | "es" | "fr") {
  return updateUserPreferences({ language });
}

/**
 * Update notification preferences
 * Convenience method for notification settings
 */
export async function updateNotificationPreferences(
  notifications: Partial<NotificationPreferencesData>
) {
  return updateUserPreferences({ notifications });
}

/**
 * Reset user preferences to defaults
 * Deletes the user_preferences record, falling back to defaults
 */
export async function resetUserPreferences() {
  const supabase = await createClient();
  const userId = await getUserIdForDataFetch();

  if (!userId) return { error: "Not authenticated" };

  const { error } = await supabase
    .from("user_preferences")
    .delete()
    .eq("user_id", userId);

  if (error) {
    return { error: error.message };
  }

  revalidatePath("/profile");
  return { success: true };
}

// =============================================================================
// AVATAR UPLOAD
// =============================================================================

/**
 * Upload user avatar to Cloudinary
 * Updates profile.avatar_url in Supabase
 */
export async function uploadAvatar(base64Data: string, fileName: string) {
  const supabase = await createClient();
  const userId = await getUserIdForDataFetch();

  if (!userId) return { error: "Not authenticated" };

  try {
    const { uploadToCloudinary } = await import("@/lib/cloudinary/client");

    // Upload to Cloudinary
    const uploadResult = await uploadToCloudinary(base64Data, {
      folder: `assignx/avatars/${userId}`,
      publicId: `avatar_${Date.now()}`,
      resourceType: "image",
    });

    // Update profile with new avatar URL
    const { error: updateError } = await supabase
      .from("profiles")
      .update({
        avatar_url: uploadResult.url,
        updated_at: new Date().toISOString(),
      })
      .eq("id", userId);

    if (updateError) {
      return { error: "Failed to update profile" };
    }

    revalidatePath("/profile");
    return { success: true, avatarUrl: uploadResult.url };
  } catch {
    return { error: "Failed to upload avatar" };
  }
}

// =============================================================================
// REVISION REQUESTS
// =============================================================================

/**
 * Create a revision request for a project
 */
export async function createRevisionRequest(projectId: string, feedback: string) {
  const supabase = await createClient();
  const userId = await getUserIdForDataFetch();

  if (!userId) return { error: "Not authenticated" };

  // Verify project belongs to user
  const { data: project } = await supabase
    .from("projects")
    .select("id, user_id, status")
    .eq("id", projectId)
    .single();

  if (!project || project.user_id !== userId) {
    return { error: "Project not found" };
  }

  // Create revision request
  const { data: revision, error } = await supabase
    .from("project_revisions")
    .insert({
      project_id: projectId,
      requested_by: userId,
      revision_notes: feedback,
      status: "pending",
    })
    .select()
    .single();

  if (error) {
    return { error: "Failed to create revision request" };
  }

  // Update project status to indicate revision requested
  await supabase
    .from("projects")
    .update({ status: "revision_requested" })
    .eq("id", projectId);

  // Create notification
  await supabase.from("notifications").insert({
    profile_id: userId,
    type: "revision",
    title: "Revision Request Submitted",
    message: "Your revision request has been submitted and will be reviewed shortly.",
    related_id: projectId,
    is_read: false,
    target_role: "user",
  });

  revalidatePath(`/projects/${projectId}`);
  return { success: true, revisionId: revision.id };
}

// =============================================================================
// DATA EXPORT
// =============================================================================

/**
 * Export all user data as JSON
 */
export async function exportUserData() {
  const supabase = await createClient();
  const userId = await getUserIdForDataFetch();

  if (!userId) return { error: "Not authenticated" };

  try {
    // Fetch all user data
    const [
      profileResult,
      projectsResult,
      walletsResult,
      transactionsResult,
      notificationsResult,
    ] = await Promise.all([
      supabase.from("profiles").select("*").eq("id", userId).single(),
      supabase.from("projects").select("*").eq("user_id", userId),
      supabase.from("wallets").select("*").eq("profile_id", userId).eq("wallet_type", "user").single(),
      supabase.from("wallet_transactions").select("*").eq("wallet_id", userId),
      supabase.from("notifications").select("*").eq("profile_id", userId).eq("target_role", "user"),
    ]);

    const exportData = {
      exportDate: new Date().toISOString(),
      profile: profileResult.data,
      projects: projectsResult.data || [],
      wallet: walletsResult.data,
      transactions: transactionsResult.data || [],
      notifications: notificationsResult.data || [],
    };

    return { success: true, data: exportData };
  } catch {
    return { error: "Failed to export data" };
  }
}

// =============================================================================
// PROJECT COMPLETION
// =============================================================================

/**
 * Mark a project as complete
 * User confirms they are satisfied with the deliverables
 */
export async function markProjectComplete(projectId: string) {
  const supabase = await createClient();
  const userId = await getUserIdForDataFetch();

  if (!userId) return { error: "Not authenticated" };

  // Verify project belongs to user and is in deliverable state
  const { data: project } = await supabase
    .from("projects")
    .select("id, user_id, status, project_number")
    .eq("id", projectId)
    .single();

  if (!project || project.user_id !== userId) {
    return { error: "Project not found" };
  }

  // Only allow completion from delivered or for_review states
  const completableStatuses = ["delivered", "qc_approved", "auto_approved"];
  if (!completableStatuses.includes(project.status)) {
    return { error: "Project cannot be marked complete at this stage" };
  }

  // Update project status to completed
  const { error } = await supabase
    .from("projects")
    .update({
      status: "completed",
      completed_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    })
    .eq("id", projectId);

  if (error) {
    return { error: "Failed to mark project as complete" };
  }

  // Create notification
  await supabase.from("notifications").insert({
    profile_id: userId,
    type: "project",
    title: "Project Completed",
    message: `Project ${project.project_number} has been marked as complete. Thank you for using AssignX!`,
    related_id: projectId,
    is_read: false,
    target_role: "user",
  });

  // Log activity
  await supabase.from("activity_logs").insert({
    profile_id: userId,
    action: "project_completed",
    action_category: "project",
    target_type: "project",
    target_id: projectId,
    description: `Marked project ${project.project_number} as complete`,
    source_role: "user",
  });

  revalidatePath(`/project/${projectId}`);
  revalidatePath("/projects");
  return { success: true };
}

// =============================================================================
// EXPERT SESSIONS (CONNECT)
// =============================================================================

/**
 * Book an expert session
 */
export async function bookExpertSession(data: {
  expertId: string;
  sessionType: string;
  date: string;
  time: string;
  topic: string;
  notes?: string;
  hourlyRate?: number;
}) {
  const supabase = await createClient();
  const userId = await getUserIdForDataFetch();

  if (!userId) return { error: "Not authenticated" };

  // Build scheduled timestamps from date + time strings
  const scheduledStart = new Date(`${data.date}T${data.time.padStart(5, "0")}:00+05:30`);
  const scheduledEnd = new Date(scheduledStart.getTime() + 60 * 60 * 1000); // +60 min
  const hourlyRate = data.hourlyRate || 499;
  const platformFeeRate = 0.333; // ~33.3%
  const sessionAmount = Math.round(hourlyRate * (1 - platformFeeRate));
  const platformFee = hourlyRate - sessionAmount;

  // Create booking record with correct schema
  const { data: booking, error } = await supabase
    .from("expert_bookings")
    .insert({
      user_id: userId,
      expert_id: data.expertId,
      topic: data.topic,
      description: data.notes || null,
      scheduled_start: scheduledStart.toISOString(),
      scheduled_end: scheduledEnd.toISOString(),
      duration_minutes: 60,
      hourly_rate: hourlyRate,
      session_amount: sessionAmount,
      platform_fee: platformFee,
      total_amount: hourlyRate,
      payment_status: "captured",
      status: "pending",
    })
    .select()
    .single();

  if (error) {
    return { error: "Failed to create booking: " + error.message };
  }

  // Create notification
  await supabase.from("notifications").insert({
    profile_id: userId,
    type: "booking",
    title: "Session Booked",
    message: `Your consultation session has been booked for ${data.date} at ${data.time}.`,
    is_read: false,
    target_role: "user",
  });

  revalidatePath("/experts");
  return { success: true, bookingId: booking?.id };
}

/**
 * Submit a question in Connect
 */
export async function submitConnectQuestion(data: {
  expertId?: string;
  question: string;
  category?: string;
}) {
  const supabase = await createClient();
  const userId = await getUserIdForDataFetch();

  if (!userId) return { error: "Not authenticated" };

  // Try to insert into questions table, fall back to support tickets
  const { data: question, error } = await supabase
    .from("connect_questions")
    .insert({
      user_id: userId,
      expert_id: data.expertId,
      question: data.question,
      category: data.category,
      status: "pending",
    })
    .select()
    .single();

  if (error) {
    // If table doesn't exist, use support_tickets as fallback
    if (error.code === "42P01") {
      const { data: ticket, error: ticketError } = await supabase
        .from("support_tickets")
        .insert({
          requester_id: userId,
          ticket_number: `Q-${Date.now().toString(36).toUpperCase()}`,
          subject: "Expert Question",
          description: data.question,
          category: data.category || "expert_question",
          status: "open",
          priority: "medium",
          source_role: "user",
        })
        .select()
        .single();

      if (ticketError) {
        return { error: "Failed to submit question" };
      }

      return { success: true, questionId: ticket.id };
    }
    return { error: "Failed to submit question" };
  }

  revalidatePath("/connect");
  return { success: true, questionId: question.id };
}

// =============================================================================
// ONBOARDING TOUR
// =============================================================================

/**
 * Mark the onboarding tour as completed for the current user
 * Saves the completion status to user_preferences in the database
 */
export async function markTourCompleted() {
  const supabase = await createClient();
  const userId = await getUserIdForDataFetch();

  if (!userId) return { error: "Not authenticated" };

  const now = new Date().toISOString();

  // Get existing preferences
  const { data: existing } = await supabase
    .from("user_preferences")
    .select("*")
    .eq("user_id", userId)
    .maybeSingle();

  if (existing) {
    // Update existing preferences
    const { error } = await supabase
      .from("user_preferences")
      .update({
        has_completed_tour: true,
        tour_completed_at: now,
        updated_at: now,
      })
      .eq("id", existing.id)
      .eq("user_id", userId);

    if (error) {
      // If column doesn't exist, just return success (graceful degradation)
      if (error.code === "42703") {
        return { success: true };
      }
      return { error: error.message };
    }
  } else {
    // Create new preferences record with tour completion
    const { error } = await supabase
      .from("user_preferences")
      .insert({
        user_id: userId,
        theme: "system",
        language: "en",
        notifications: {
          emailNotifications: true,
          pushNotifications: true,
          inAppNotifications: true,
          projectUpdates: true,
          marketingEmails: false,
          weeklyDigest: true,
        },
        has_completed_tour: true,
        tour_completed_at: now,
        created_at: now,
        updated_at: now,
      });

    if (error) {
      // If column doesn't exist, just return success (graceful degradation)
      if (error.code === "42703") {
        return { success: true };
      }
      return { error: error.message };
    }
  }

  return { success: true };
}

/**
 * Check if the current user has completed the onboarding tour
 * Returns from user_preferences in the database
 */
export async function getTourCompletionStatus(): Promise<{ completed: boolean; completedAt?: string }> {
  const supabase = await createClient();
  const userId = await getUserIdForDataFetch();

  if (!userId) return { completed: false };

  const { data: preferences, error } = await supabase
    .from("user_preferences")
    .select("has_completed_tour, tour_completed_at")
    .eq("user_id", userId)
    .maybeSingle();

  if (error || !preferences) {
    return { completed: false };
  }

  return {
    completed: preferences.has_completed_tour ?? false,
    completedAt: preferences.tour_completed_at ?? undefined,
  };
}
