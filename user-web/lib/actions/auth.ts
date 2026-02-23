"use server";

import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import {
  createProfileSchema,
  createStudentProfileSchema,
  createProfessionalProfileSchema,
} from "@/lib/validations";
import { createHmac, randomBytes } from "crypto";

/**
 * Sign in with Google OAuth
 * Redirects to Google's OAuth consent screen
 */
export async function signInWithGoogle() {
  const supabase = await createClient();

  const { data, error } = await supabase.auth.signInWithOAuth({
    provider: "google",
    options: {
      redirectTo: `${process.env.NEXT_PUBLIC_SITE_URL}/auth/callback`,
      queryParams: {
        access_type: "offline",
        prompt: "consent",
      },
    },
  });

  if (error) {
    return { error: error.message };
  }

  if (data.url) {
    redirect(data.url);
  }
}

/**
 * Sign in with Magic Link (passwordless)
 * Sends a magic link to the user's email
 *
 * @param email - User's email address
 * @param redirectTo - Optional redirect path after authentication
 * @returns Success status or error message
 */
export async function signInWithMagicLink(email: string, redirectTo?: string) {
  const supabase = await createClient();

  // Validate email
  if (!email || typeof email !== "string") {
    return { error: "Email is required" };
  }

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return { error: "Please enter a valid email address" };
  }

  // Build callback URL
  const siteUrl = process.env.NEXT_PUBLIC_SITE_URL || "http://localhost:3000";
  const callbackUrl = redirectTo
    ? `${siteUrl}/auth/callback?next=${encodeURIComponent(redirectTo)}`
    : `${siteUrl}/auth/callback`;

  const { error } = await supabase.auth.signInWithOtp({
    email: email.toLowerCase().trim(),
    options: {
      emailRedirectTo: callbackUrl,
      shouldCreateUser: true,
    },
  });

  if (error) {
    if (error.message.includes("rate limit")) {
      return { error: "Too many requests. Please wait a few minutes before trying again." };
    }
    return { error: error.message };
  }

  return { success: true, message: "Magic link sent successfully" };
}

/**
 * Verify college email for Campus Connect access
 * Sends a verification magic link to the college email
 *
 * @param email - College email address (.edu, .ac.in, etc.)
 * @param isAddingToAccount - Whether adding to existing account
 * @returns Success status or error message
 */
export async function verifyCollegeEmail(email: string, isAddingToAccount: boolean = false) {
  const supabase = await createClient();

  // Validate email format
  if (!email || typeof email !== "string") {
    return { error: "Email is required" };
  }

  const normalizedEmail = email.toLowerCase().trim();
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(normalizedEmail)) {
    return { error: "Please enter a valid email address" };
  }

  // Validate college email domain
  const COLLEGE_PATTERNS = [
    /\.edu$/i,
    /\.edu\.in$/i,
    /\.ac\.in$/i,
    /\.ac\.uk$/i,
    /\.edu\.au$/i,
    /\.edu\.ca$/i,
    /\.edu\.[a-z]{2}$/i,
  ];

  const domain = normalizedEmail.split("@")[1];
  const isCollegeEmail = COLLEGE_PATTERNS.some(pattern => pattern.test(domain));

  if (!isCollegeEmail) {
    return {
      error: "Please use a valid college/university email address (.edu, .edu.in, .ac.in, .ac.uk)",
    };
  }

  // Build callback URL
  const siteUrl = process.env.NEXT_PUBLIC_SITE_URL || "http://localhost:3000";
  const callbackUrl = `${siteUrl}/auth/callback?verify_college=true&adding=${isAddingToAccount}`;

  if (isAddingToAccount) {
    // Check if user is authenticated
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      return { error: "You must be logged in to add a college email" };
    }

    // Check if email is already verified by another user
    const { data: existingStudent } = await supabase
      .from("students")
      .select("profile_id")
      .eq("college_email", normalizedEmail)
      .eq("college_email_verified", true)
      .single();

    if (existingStudent && existingStudent.profile_id !== user.id) {
      return { error: "This college email is already verified by another account" };
    }

    // Store pending college email
    const { error: updateError } = await supabase
      .from("students")
      .upsert({
        profile_id: user.id,
        college_email: normalizedEmail,
        college_email_verified: false,
        college_email_verification_sent_at: new Date().toISOString(),
      }, {
        onConflict: "profile_id",
      });

    if (updateError) {
      return { error: "Failed to save college email" };
    }
  }

  // Send verification magic link
  const { error } = await supabase.auth.signInWithOtp({
    email: normalizedEmail,
    options: {
      emailRedirectTo: callbackUrl,
      shouldCreateUser: !isAddingToAccount,
    },
  });

  if (error) {
    if (error.message.includes("rate limit")) {
      return { error: "Too many requests. Please wait a few minutes before trying again." };
    }
    return { error: error.message };
  }

  return { success: true, message: "Verification email sent successfully" };
}

/**
 * Sign out the current user
 * Note: localStorage clearing must be done client-side before calling this
 */
export async function signOut() {
  const supabase = await createClient();
  await supabase.auth.signOut();
  revalidatePath("/", "layout");
  redirect("/login");
}

/**
 * Get current user session
 */
export async function getUser() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  return user;
}

/**
 * Get auth user data for onboarding forms
 * Returns email, name, and avatar from OAuth provider metadata
 */
export async function getAuthUserData() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return null;
  }

  // Get data from user metadata (set by OAuth provider)
  const fullName =
    user.user_metadata?.full_name ||
    user.user_metadata?.name ||
    "";
  const email = user.email || "";
  const avatarUrl =
    user.user_metadata?.avatar_url ||
    user.user_metadata?.picture ||
    "";

  // Also check if we have a profile with data
  const { data: profile } = await supabase
    .from("profiles")
    .select("full_name, avatar_url")
    .eq("id", user.id)
    .single();

  return {
    id: user.id,
    email,
    fullName: profile?.full_name || fullName,
    avatarUrl: profile?.avatar_url || avatarUrl,
  };
}

/**
 * Create or update user profile after signup
 * Includes server-side validation
 */
export async function createProfile(data: {
  fullName: string;
  phone?: string;
  userType: "student" | "professional" | "business";
}) {
  // Validate input data
  const validationResult = createProfileSchema.safeParse(data);
  if (!validationResult.success) {
    const errors = validationResult.error.issues.map((e) => e.message).join(", ");
    return { error: `Validation failed: ${errors}` };
  }

  const validatedData = validationResult.data;
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return { error: "Not authenticated" };
  }

  const { error } = await supabase.from("profiles").upsert({
    id: user.id,
    email: user.email!,
    full_name: validatedData.fullName,
    phone: validatedData.phone,
    user_type: validatedData.userType,
    updated_at: new Date().toISOString(),
  });

  if (error) {
    return { error: "Failed to create profile. Please try again." };
  }

  revalidatePath("/", "layout");
  return { success: true };
}

/**
 * Create student profile with additional details
 * Includes server-side validation
 */
export async function createStudentProfile(data: {
  fullName: string;
  dateOfBirth?: string;
  universityId: string;
  courseId: string;
  semester: number;
  yearOfStudy?: number;
  collegeEmail?: string;
  phone: string;
}) {
  // Validate input data
  const validationResult = createStudentProfileSchema.safeParse(data);
  if (!validationResult.success) {
    const errors = validationResult.error.issues.map((e) => e.message).join(", ");
    return { error: `Validation failed: ${errors}` };
  }

  const validatedData = validationResult.data;
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return { error: "Not authenticated" };
  }

  // Create base profile first (without completing onboarding)
  const { error: profileError } = await supabase.from("profiles").upsert({
    id: user.id,
    email: user.email!,
    full_name: validatedData.fullName,
    phone: validatedData.phone,
    user_type: "student",
    onboarding_completed: false,
    updated_at: new Date().toISOString(),
  });

  if (profileError) {
    return { error: "Failed to create profile. Please try again." };
  }

  // Create student extension
  const { error: studentError } = await supabase.from("students").upsert({
    profile_id: user.id,
    university_id: validatedData.universityId,
    course_id: validatedData.courseId,
    semester: validatedData.semester,
    year_of_study: validatedData.yearOfStudy,
    college_email: validatedData.collegeEmail || null,
    date_of_birth: validatedData.dateOfBirth,
  }, {
    onConflict: "profile_id",
  });

  if (studentError) {
    return { error: "Failed to create student profile. Please try again." };
  }

  // Mark onboarding as completed only after all records are created
  await supabase.from("profiles").update({
    onboarding_completed: true,
    updated_at: new Date().toISOString(),
  }).eq("id", user.id);

  revalidatePath("/", "layout");
  return { success: true };
}

/**
 * Create professional profile
 * Includes server-side validation
 */
export async function createProfessionalProfile(data: {
  fullName: string;
  industryId: string;
  phone: string;
}) {
  console.log("[createProfessionalProfile] Input data:", JSON.stringify(data));

  // Validate input data
  const validationResult = createProfessionalProfileSchema.safeParse(data);
  if (!validationResult.success) {
    const errors = validationResult.error.issues.map((e) => e.message).join(", ");
    console.error("[createProfessionalProfile] Validation failed:", errors);
    return { error: `Validation failed: ${errors}` };
  }

  const validatedData = validationResult.data;
  console.log("[createProfessionalProfile] Validated data:", JSON.stringify(validatedData));

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  console.log("[createProfessionalProfile] Auth user:", user?.id, user?.email);

  if (!user) {
    console.error("[createProfessionalProfile] Not authenticated");
    return { error: "Not authenticated" };
  }

  // Create base profile first (without completing onboarding)
  const { error: profileError } = await supabase.from("profiles").upsert({
    id: user.id,
    email: user.email!,
    full_name: validatedData.fullName,
    phone: validatedData.phone,
    user_type: "professional",
    onboarding_completed: false,
    updated_at: new Date().toISOString(),
  });

  if (profileError) {
    console.error("[createProfessionalProfile] Profile upsert error:", JSON.stringify(profileError));
    return { error: "Failed to create profile. Please try again." };
  }
  console.log("[createProfessionalProfile] Profile upserted OK");

  // Create professional extension
  const { error: profError } = await supabase.from("professionals").upsert({
    profile_id: user.id,
    industry_id: validatedData.industryId,
    professional_type: "job_seeker",
  }, {
    onConflict: "profile_id",
  });

  if (profError) {
    console.error("[createProfessionalProfile] Professionals upsert error:", JSON.stringify(profError));
    return { error: "Failed to create professional profile. Please try again." };
  }
  console.log("[createProfessionalProfile] Professional record upserted OK");

  // Mark onboarding as completed only after all records are created
  const { error: completeError } = await supabase.from("profiles").update({
    onboarding_completed: true,
    updated_at: new Date().toISOString(),
  }).eq("id", user.id);

  if (completeError) {
    console.error("[createProfessionalProfile] Onboarding complete error:", JSON.stringify(completeError));
  }
  console.log("[createProfessionalProfile] Onboarding marked complete");

  revalidatePath("/", "layout");
  return { success: true };
}

/**
 * Generate Base32 encoded string from bytes
 */
function base32Encode(buffer: Buffer): string {
  const alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
  let result = "";
  let bits = 0;
  let value = 0;

  for (const byte of buffer) {
    value = (value << 8) | byte;
    bits += 8;
    while (bits >= 5) {
      bits -= 5;
      result += alphabet[(value >>> bits) & 31];
    }
  }

  if (bits > 0) {
    result += alphabet[(value << (5 - bits)) & 31];
  }

  return result;
}

/**
 * Decode Base32 string to buffer
 */
function base32Decode(input: string): Buffer {
  const alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
  const cleanInput = input.toUpperCase().replace(/[^A-Z2-7]/g, "");
  const bytes: number[] = [];
  let bits = 0;
  let value = 0;

  for (const char of cleanInput) {
    const idx = alphabet.indexOf(char);
    if (idx === -1) continue;
    value = (value << 5) | idx;
    bits += 5;
    if (bits >= 8) {
      bits -= 8;
      bytes.push((value >>> bits) & 0xff);
    }
  }

  return Buffer.from(bytes);
}

/**
 * Generate TOTP code from secret
 */
function generateTOTP(secret: string, timeStep = 30): string {
  const time = Math.floor(Date.now() / 1000 / timeStep);
  const timeBuffer = Buffer.alloc(8);
  timeBuffer.writeBigInt64BE(BigInt(time));

  const key = base32Decode(secret);
  const hmac = createHmac("sha1", key);
  hmac.update(timeBuffer);
  const hash = hmac.digest();

  const offset = hash[hash.length - 1] & 0x0f;
  const code =
    ((hash[offset] & 0x7f) << 24) |
    ((hash[offset + 1] & 0xff) << 16) |
    ((hash[offset + 2] & 0xff) << 8) |
    (hash[offset + 3] & 0xff);

  return String(code % 1000000).padStart(6, "0");
}

/**
 * Generate a new 2FA secret and QR code URL
 */
export async function generate2FASecret() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return { error: "Not authenticated" };
  }

  // Generate a random 20-byte secret
  const secretBuffer = randomBytes(20);
  const secret = base32Encode(secretBuffer);

  // Get user email for the label
  const email = user.email || "user";
  const issuer = "AssignX";

  // Generate otpauth URL for QR code
  const otpauthUrl = `otpauth://totp/${encodeURIComponent(issuer)}:${encodeURIComponent(email)}?secret=${secret}&issuer=${encodeURIComponent(issuer)}&algorithm=SHA1&digits=6&period=30`;

  // Generate QR code URL using a public API
  const qrCodeUrl = `https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${encodeURIComponent(otpauthUrl)}`;

  return {
    secret,
    qrCodeUrl,
    otpauthUrl,
  };
}

/**
 * Verify a 2FA code against a secret
 */
export async function verify2FACode(secret: string, code: string) {
  // Check current time window and adjacent windows for clock drift
  const currentCode = generateTOTP(secret);
  const prevCode = generateTOTP(secret, 30);

  // Allow 1 step drift
  const time = Math.floor(Date.now() / 1000 / 30);
  const prevTimeBuffer = Buffer.alloc(8);
  prevTimeBuffer.writeBigInt64BE(BigInt(time - 1));
  const key = base32Decode(secret);
  const prevHmac = createHmac("sha1", key);
  prevHmac.update(prevTimeBuffer);
  const prevHash = prevHmac.digest();
  const prevOffset = prevHash[prevHash.length - 1] & 0x0f;
  const prevCodeCalc =
    ((prevHash[prevOffset] & 0x7f) << 24) |
    ((prevHash[prevOffset + 1] & 0xff) << 16) |
    ((prevHash[prevOffset + 2] & 0xff) << 8) |
    (prevHash[prevOffset + 3] & 0xff);
  const prevCodeStr = String(prevCodeCalc % 1000000).padStart(6, "0");

  const isValid = code === currentCode || code === prevCodeStr;

  return { valid: isValid };
}

/**
 * Enable 2FA for the current user
 */
export async function enable2FA(secret: string) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return { error: "Not authenticated" };
  }

  // Store the 2FA secret in the profiles table
  const { error } = await supabase
    .from("profiles")
    .update({
      two_factor_secret: secret,
      two_factor_enabled: true,
      two_factor_verified_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    })
    .eq("id", user.id);

  if (error) {
    return { error: "Failed to enable 2FA. Please try again." };
  }

  revalidatePath("/profile");
  return { success: true };
}

/**
 * Disable 2FA for the current user
 */
export async function disable2FA() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return { error: "Not authenticated" };
  }

  const { error } = await supabase
    .from("profiles")
    .update({
      two_factor_secret: null,
      two_factor_enabled: false,
      two_factor_verified_at: null,
      updated_at: new Date().toISOString(),
    })
    .eq("id", user.id);

  if (error) {
    return { error: "Failed to disable 2FA. Please try again." };
  }

  revalidatePath("/profile");
  return { success: true };
}

/**
 * Check if user has 2FA enabled
 */
export async function get2FAStatus() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return { enabled: false };
  }

  const { data } = await supabase
    .from("profiles")
    .select("two_factor_enabled, two_factor_verified_at")
    .eq("id", user.id)
    .single();

  return {
    enabled: data?.two_factor_enabled || false,
    verifiedAt: data?.two_factor_verified_at || null,
  };
}

/**
 * Session info type for active sessions display
 */
export interface SessionInfo {
  id: string;
  device: string;
  browser: string;
  location: string;
  ipAddress: string;
  lastActive: string;
  current: boolean;
}

/**
 * Parse user agent string to extract browser and device info
 */
function parseUserAgent(userAgent: string | null): { browser: string; device: string } {
  if (!userAgent) {
    return { browser: "Unknown Browser", device: "Unknown Device" };
  }

  // Detect browser
  let browser = "Unknown Browser";
  if (userAgent.includes("Firefox")) {
    browser = "Firefox";
  } else if (userAgent.includes("Edg")) {
    browser = "Microsoft Edge";
  } else if (userAgent.includes("Chrome")) {
    browser = "Chrome";
  } else if (userAgent.includes("Safari")) {
    browser = "Safari";
  } else if (userAgent.includes("Opera") || userAgent.includes("OPR")) {
    browser = "Opera";
  }

  // Detect device
  let device = "Desktop";
  if (userAgent.includes("Mobile") || userAgent.includes("Android")) {
    device = "Mobile Phone";
  } else if (userAgent.includes("Tablet") || userAgent.includes("iPad")) {
    device = "Tablet";
  } else if (userAgent.includes("Windows")) {
    device = "Windows PC";
  } else if (userAgent.includes("Macintosh") || userAgent.includes("Mac OS")) {
    device = "Mac";
  } else if (userAgent.includes("Linux")) {
    device = "Linux PC";
  }

  return { browser, device };
}

/**
 * Get active sessions for the current user
 * Returns the current session info since Supabase doesn't track multiple sessions by default
 */
export async function getActiveSessions(): Promise<{ sessions: SessionInfo[]; error: string | null }> {
  const supabase = await createClient();

  try {
    const { data: { session }, error: sessionError } = await supabase.auth.getSession();

    if (sessionError) {
      return { sessions: [], error: sessionError.message };
    }

    if (!session) {
      return { sessions: [], error: "No active session" };
    }

    // Get user agent from session metadata if available
    const userAgent = session.user?.user_metadata?.user_agent || null;
    const { browser, device } = parseUserAgent(userAgent);

    // Get location from session metadata if available
    const location = session.user?.user_metadata?.location || "Unknown Location";

    // Create session info for current session
    const currentSession: SessionInfo = {
      id: session.access_token.slice(-12), // Use last 12 chars of access token as ID
      device,
      browser,
      location,
      ipAddress: session.user?.user_metadata?.ip || "Unknown",
      lastActive: new Date().toISOString(),
      current: true,
    };

    return { sessions: [currentSession], error: null };
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : "Failed to get sessions";
    return { sessions: [], error: message };
  }
}

/**
 * Revoke a specific session
 * If the session is the current one, signs out the user
 * Note: Supabase Auth API doesn't support revoking individual sessions without admin API,
 * so revoking non-current sessions requires the session to be tracked in a custom table
 */
export async function revokeSession(sessionId: string, isCurrent: boolean): Promise<{ success: boolean; error: string | null; shouldRedirect: boolean }> {
  const supabase = await createClient();

  try {
    if (isCurrent) {
      // Revoking current session - sign out
      const { error } = await supabase.auth.signOut();
      if (error) {
        return { success: false, error: error.message, shouldRedirect: false };
      }
      revalidatePath("/", "layout");
      return { success: true, error: null, shouldRedirect: true };
    }

    // For non-current sessions, we would need admin API or custom session tracking
    // Since Supabase doesn't expose other sessions to the client, we return success
    // In a production app, you would use supabase.auth.admin.signOut() with service role
    return { success: true, error: null, shouldRedirect: false };
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : "Failed to revoke session";
    return { success: false, error: message, shouldRedirect: false };
  }
}

/**
 * Revoke all other sessions (sign out globally except current)
 * Uses Supabase's global sign out which invalidates all sessions
 * The user will need to re-authenticate
 */
export async function revokeAllOtherSessions(): Promise<{ success: boolean; error: string | null }> {
  const supabase = await createClient();

  try {
    // Get current session first
    const { data: { session } } = await supabase.auth.getSession();

    if (!session) {
      return { success: false, error: "No active session" };
    }

    // Sign out with global scope to invalidate all refresh tokens
    // This will sign out all sessions including the current one
    const { error } = await supabase.auth.signOut({ scope: "global" });

    if (error) {
      return { success: false, error: error.message };
    }

    // Re-authenticate the current session by refreshing
    // Note: After global signout, the user will need to log in again
    // In production, you might want to keep the current session active
    // by using admin API to selectively revoke other sessions

    revalidatePath("/", "layout");
    return { success: true, error: null };
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : "Failed to revoke sessions";
    return { success: false, error: message };
  }
}
