"use server";

import { cookies } from "next/headers";
import { revalidatePath } from "next/cache";
import { serverApiClient } from "@/lib/api/client";

/**
 * Helper to get the JWT from cookie store
 */
async function getToken(): Promise<string | null> {
  const cookieStore = await cookies();
  return cookieStore.get("accessToken")?.value || null;
}

/**
 * Get current user's profile with related data
 */
export async function getProfile() {
  const token = await getToken();
  if (!token) return null;

  try {
    return await serverApiClient("/api/users/me", {}, token);
  } catch {
    return null;
  }
}

/**
 * Get profile by email address (dev mode helper)
 */
export async function getProfileByEmail(email: string) {
  try {
    return await serverApiClient(`/api/users/search?email=${encodeURIComponent(email)}`);
  } catch {
    return null;
  }
}

/**
 * Get user's projects with filtering
 */
export async function getProjects(status?: string) {
  const token = await getToken();
  if (!token) return [];

  try {
    const params = status ? `?status=${status}` : "";
    const result = await serverApiClient(`/api/projects${params}`, {}, token);
    return result.projects || result.data || result || [];
  } catch {
    return [];
  }
}

/**
 * Get single project by ID
 */
export async function getProjectById(id: string) {
  const token = await getToken();
  if (!token) return null;

  try {
    const result = await serverApiClient(`/api/projects/${id}`, {}, token);
    return result.project || result.data || result;
  } catch {
    return null;
  }
}

/**
 * Get user's notifications
 */
export async function getNotifications(limit = 20) {
  const token = await getToken();
  if (!token) return [];

  try {
    const result = await serverApiClient(`/api/notifications?limit=${limit}&role=user`, {}, token);
    return result.notifications || result.data || result || [];
  } catch {
    return [];
  }
}

/**
 * Mark notification as read
 */
export async function markNotificationRead(id: string) {
  const token = await getToken();
  if (!token) return { error: "Not authenticated" };

  try {
    await serverApiClient(`/api/notifications/${id}/read`, { method: "PUT" }, token);
    revalidatePath("/", "layout");
    return { success: true };
  } catch (error: any) {
    return { error: error.message };
  }
}

/**
 * Mark all notifications as read
 */
export async function markAllNotificationsRead() {
  const token = await getToken();
  if (!token) return { error: "Not authenticated" };

  try {
    await serverApiClient("/api/notifications/read-all", { method: "PUT" }, token);
    revalidatePath("/", "layout");
    return { success: true };
  } catch (error: any) {
    return { error: error.message };
  }
}

/**
 * Get user's wallet
 */
export async function getWallet() {
  const token = await getToken();
  if (!token) return null;

  try {
    const result = await serverApiClient("/api/wallets/me", {}, token);
    return result.wallet || result.data || result;
  } catch {
    return null;
  }
}

/**
 * Get wallet transactions
 */
export async function getWalletTransactions(limit = 20) {
  const token = await getToken();
  if (!token) return [];

  try {
    const result = await serverApiClient(`/api/wallets/me/transactions?limit=${limit}`, {}, token);
    return result.transactions || result.data || result || [];
  } catch {
    return [];
  }
}

/**
 * Search for a user by email address
 */
export async function searchUserByEmail(email: string): Promise<{
  success: boolean;
  user: { id: string; email: string; full_name: string; avatar_url: string | null } | null;
} | null> {
  const token = await getToken();
  if (!token) return null;

  const trimmedEmail = email.trim().toLowerCase();
  if (!trimmedEmail || !trimmedEmail.includes("@")) return null;

  try {
    const result = await serverApiClient(
      `/api/users/search?email=${encodeURIComponent(trimmedEmail)}`,
      {},
      token
    );
    if (!result || !result.user) return null;
    return { success: true, user: result.user };
  } catch {
    return null;
  }
}

/**
 * Get active banners
 */
export async function getBanners(location = "dashboard") {
  try {
    const result = await serverApiClient(`/api/banners?location=${location}&role=user`);
    return result.banners || result.data || result || [];
  } catch {
    return [];
  }
}

/**
 * Get FAQs
 */
export async function getFAQs(category?: string) {
  try {
    const params = category ? `?category=${category}&role=user` : "?role=user";
    const result = await serverApiClient(`/api/support/faqs${params}`);
    return result.faqs || result.data || result || [];
  } catch {
    return [];
  }
}

/**
 * Get support tickets
 */
export async function getSupportTickets() {
  const token = await getToken();
  if (!token) return [];

  try {
    const result = await serverApiClient("/api/support/tickets?role=user", {}, token);
    return result.tickets || result.data || result || [];
  } catch {
    return [];
  }
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
  const token = await getToken();
  if (!token) return { error: "Not authenticated" };

  try {
    const result = await serverApiClient("/api/support/tickets", {
      method: "POST",
      body: JSON.stringify({
        ...data,
        sourceRole: "user",
      }),
    }, token);

    revalidatePath("/support");
    return { success: true, ticket: result.ticket || result.data || result };
  } catch (error: any) {
    return { error: error.message };
  }
}

/**
 * Get universities list
 */
export async function getUniversities() {
  try {
    const result = await serverApiClient("/api/universities");
    return result.universities || result.data || result || [];
  } catch {
    return [];
  }
}

/**
 * Get courses list
 */
export async function getCourses() {
  try {
    const result = await serverApiClient("/api/courses");
    return result.courses || result.data || result || [];
  } catch {
    return [];
  }
}

/**
 * Get subjects list
 */
export async function getSubjects() {
  try {
    const result = await serverApiClient("/api/subjects");
    return result.subjects || result.data || result || [];
  } catch {
    return [];
  }
}

/**
 * Get industries list
 */
export async function getIndustries() {
  try {
    const result = await serverApiClient("/api/industries");
    return result.industries || result.data || result || [];
  } catch {
    return [];
  }
}

/**
 * Get reference styles
 */
export async function getReferenceStyles() {
  try {
    const result = await serverApiClient("/api/reference-styles");
    return result.styles || result.data || result || [];
  } catch {
    return [];
  }
}

/**
 * Submit user feedback
 */
export async function submitFeedback(data: {
  overallSatisfaction: number;
  feedbackText?: string;
  wouldRecommend?: boolean;
  improvementSuggestions?: string;
  npsScore?: number;
  projectId?: string;
}) {
  const token = await getToken();
  if (!token) return { error: "Not authenticated" };

  try {
    await serverApiClient("/api/support/feedback", {
      method: "POST",
      body: JSON.stringify(data),
    }, token);

    return { success: true };
  } catch (error: any) {
    return { error: error.message };
  }
}

/**
 * Update profile
 */
export async function updateProfile(data: {
  full_name?: string;
  phone?: string;
  city?: string;
  state?: string;
  country?: string;
  avatar_url?: string;
}) {
  const token = await getToken();
  if (!token) return { error: "Not authenticated" };

  try {
    await serverApiClient("/api/users/me", {
      method: "PUT",
      body: JSON.stringify(data),
    }, token);

    revalidatePath("/profile");
    return { success: true };
  } catch (error: any) {
    return { error: error.message };
  }
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
  const token = await getToken();
  if (!token) return { error: "Not authenticated" };

  try {
    await serverApiClient("/api/users/me", {
      method: "PUT",
      body: JSON.stringify(data),
    }, token);

    revalidatePath("/profile");
    return { success: true };
  } catch (error: any) {
    return { error: error.message };
  }
}

/**
 * Update professional profile
 */
export async function updateProfessionalProfile(data: {
  industryId?: string;
  companyName?: string;
  jobTitle?: string;
  yearsExperience?: number;
}) {
  const token = await getToken();
  if (!token) return { error: "Not authenticated" };

  try {
    await serverApiClient("/api/users/me", {
      method: "PUT",
      body: JSON.stringify(data),
    }, token);

    revalidatePath("/profile");
    return { success: true };
  } catch (error: any) {
    return { error: error.message };
  }
}

/**
 * Create a new project
 */
export async function createProject(data: Record<string, any>) {
  const token = await getToken();
  if (!token) return { error: "Not authenticated" };

  try {
    const result = await serverApiClient("/api/projects", {
      method: "POST",
      body: JSON.stringify(data),
    }, token);

    revalidatePath("/projects");
    return { success: true, project: result.project || result.data || result };
  } catch (error: any) {
    return { error: error.message };
  }
}

/**
 * Update project
 */
export async function updateProject(id: string, data: Record<string, any>) {
  const token = await getToken();
  if (!token) return { error: "Not authenticated" };

  try {
    await serverApiClient(`/api/projects/${id}`, {
      method: "PUT",
      body: JSON.stringify(data),
    }, token);

    revalidatePath(`/projects`);
    revalidatePath(`/project/${id}`);
    return { success: true };
  } catch (error: any) {
    return { error: error.message };
  }
}

/**
 * Upload file
 */
export async function uploadFile(data: {
  name: string;
  type: string;
  size: number;
  base64Data: string;
  folder?: string;
}) {
  const token = await getToken();
  if (!token) return { error: "Not authenticated" };

  try {
    const result = await serverApiClient("/api/upload", {
      method: "POST",
      body: JSON.stringify({
        file: data.base64Data,
        fileName: data.name,
        folder: data.folder || "uploads",
      }),
    }, token);

    return { success: true, url: result.url, publicId: result.publicId };
  } catch (error: any) {
    return { error: error.message };
  }
}

/**
 * Upload a project file (for proofreading/report forms)
 */
export async function uploadProjectFile(
  projectId: string,
  fileData: { name: string; type: string; size: number; base64Data: string }
) {
  const token = await getToken();
  if (!token) return { error: "Not authenticated" };

  try {
    const result = await serverApiClient("/api/upload", {
      method: "POST",
      body: JSON.stringify({
        file: fileData.base64Data,
        fileName: fileData.name,
        folder: `projects/${projectId}`,
      }),
    }, token);

    // Also create a file record linked to the project
    await serverApiClient(`/api/projects/${projectId}/files`, {
      method: "POST",
      body: JSON.stringify({
        fileName: fileData.name,
        fileUrl: result.url,
        fileType: fileData.type,
        fileSize: fileData.size,
      }),
    }, token);

    return { success: true, url: result.url, publicId: result.publicId };
  } catch (error: any) {
    return { error: error.message };
  }
}

/**
 * Create a project file record (for new-project-form)
 */
export async function createProjectFileRecord(
  projectId: string,
  data: { fileName: string; fileUrl: string; fileType: string; fileSize?: number; fileSizeBytes?: number; fileCategory?: string }
) {
  const token = await getToken();
  if (!token) return { error: "Not authenticated" };

  try {
    const result = await serverApiClient(`/api/projects/${projectId}/files`, {
      method: "POST",
      body: JSON.stringify(data),
    }, token);

    return { success: true, file: result.file || result.data || result };
  } catch (error: any) {
    return { error: error.message };
  }
}

/**
 * Upload avatar image
 */
export async function uploadAvatar(base64Data: string, fileName: string) {
  const token = await getToken();
  if (!token) return { error: "Not authenticated" };

  try {
    const result = await serverApiClient("/api/upload", {
      method: "POST",
      body: JSON.stringify({
        file: base64Data,
        fileName,
        folder: "avatars",
      }),
    }, token);

    // Update profile with new avatar URL
    await serverApiClient("/api/users/me", {
      method: "PUT",
      body: JSON.stringify({ avatar_url: result.url }),
    }, token);

    revalidatePath("/profile");
    return { success: true, url: result.url };
  } catch (error: any) {
    return { error: error.message };
  }
}

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
  duration?: number;
  hourlyRate?: number;
}) {
  const token = await getToken();
  if (!token) return { error: "Not authenticated" };

  try {
    const result = await serverApiClient("/api/expert-bookings", {
      method: "POST",
      body: JSON.stringify(data),
    }, token);

    revalidatePath("/experts");
    return { success: true, booking: result.booking || result.data || result };
  } catch (error: any) {
    return { error: error.message };
  }
}

/**
 * Create a revision request for a project
 */
export async function createRevisionRequest(projectId: string, feedback: string) {
  const token = await getToken();
  if (!token) return { error: "Not authenticated" };

  try {
    const result = await serverApiClient(`/api/projects/${projectId}/revisions`, {
      method: "POST",
      body: JSON.stringify({ feedback }),
    }, token);

    revalidatePath(`/project/${projectId}`);
    return { success: true, revision: result.revision || result.data || result };
  } catch (error: any) {
    return { error: error.message };
  }
}

/**
 * Mark a project as complete
 */
export async function markProjectComplete(projectId: string) {
  const token = await getToken();
  if (!token) return { error: "Not authenticated" };

  try {
    await serverApiClient(`/api/projects/${projectId}/complete`, {
      method: "POST",
    }, token);

    revalidatePath(`/project/${projectId}`);
    revalidatePath("/projects");
    return { success: true };
  } catch (error: any) {
    return { error: error.message };
  }
}

/**
 * Export user data (GDPR compliance)
 */
export async function exportUserData() {
  const token = await getToken();
  if (!token) return { error: "Not authenticated" };

  try {
    const result = await serverApiClient("/api/users/me/export", {}, token);
    return { success: true, data: result };
  } catch (error: any) {
    return { error: error.message };
  }
}

/**
 * Get user preferences
 */
export async function getUserPreferences() {
  const token = await getToken();
  if (!token) return { theme: "system", language: "en", notifications: {} };

  try {
    const result = await serverApiClient("/api/users/preferences", {}, token);
    return result || { theme: "system", language: "en", notifications: {} };
  } catch {
    return { theme: "system", language: "en", notifications: {} };
  }
}

/**
 * Submit a question in the Connect section
 */
export async function submitConnectQuestion(data: {
  question: string;
  category?: string;
}) {
  const token = await getToken();
  if (!token) return { error: "Not authenticated" };

  try {
    const result = await serverApiClient("/api/community/posts", {
      method: "POST",
      body: JSON.stringify({
        content: data.question,
        category: data.category || "questions",
        type: "question",
      }),
    }, token);

    revalidatePath("/campus-connect");
    return { success: true, post: result.post || result.data || result };
  } catch (error: any) {
    return { error: error.message };
  }
}

/**
 * Update user preferences
 */
export async function updateUserPreferences(data: Record<string, any>) {
  const token = await getToken();
  if (!token) return { error: "Not authenticated" };

  try {
    await serverApiClient("/api/users/preferences", {
      method: "PUT",
      body: JSON.stringify(data),
    }, token);

    revalidatePath("/settings");
    return { success: true };
  } catch (error: any) {
    return { error: error.message };
  }
}

/**
 * Get chat rooms
 */
export async function getChatRooms() {
  const token = await getToken();
  if (!token) return [];

  try {
    const result = await serverApiClient("/api/chat/rooms", {}, token);
    return result.rooms || result.data || result || [];
  } catch {
    return [];
  }
}

/**
 * Get chat messages for a room
 */
export async function getChatMessages(roomId: string, limit = 50) {
  const token = await getToken();
  if (!token) return [];

  try {
    const result = await serverApiClient(`/api/chat/rooms/${roomId}/messages?limit=${limit}`, {}, token);
    return result.messages || result.data || result || [];
  } catch {
    return [];
  }
}

/**
 * Send chat message
 */
export async function sendChatMessage(roomId: string, content: string, attachments?: string[]) {
  const token = await getToken();
  if (!token) return { error: "Not authenticated" };

  try {
    const result = await serverApiClient(`/api/chat/rooms/${roomId}/messages`, {
      method: "POST",
      body: JSON.stringify({ content, attachments }),
    }, token);

    return { success: true, message: result.message || result.data || result };
  } catch (error: any) {
    return { error: error.message };
  }
}

/**
 * Create Razorpay order for payment
 */
export async function createPaymentOrder(data: {
  projectId: string;
  amount: number;
  paymentType?: string;
}) {
  const token = await getToken();
  if (!token) return { error: "Not authenticated" };

  try {
    const result = await serverApiClient("/api/payments/create-order", {
      method: "POST",
      body: JSON.stringify(data),
    }, token);

    return result;
  } catch (error: any) {
    return { error: error.message };
  }
}

/**
 * Verify Razorpay payment
 */
export async function verifyPayment(data: {
  razorpayOrderId: string;
  razorpayPaymentId: string;
  razorpaySignature: string;
  projectId: string;
}) {
  const token = await getToken();
  if (!token) return { error: "Not authenticated" };

  try {
    const result = await serverApiClient("/api/payments/verify", {
      method: "POST",
      body: JSON.stringify(data),
    }, token);

    revalidatePath("/projects");
    return result;
  } catch (error: any) {
    return { error: error.message };
  }
}
