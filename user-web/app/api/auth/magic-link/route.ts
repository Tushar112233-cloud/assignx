import { createClient } from "@/lib/supabase/server";
import { NextRequest, NextResponse } from "next/server";

/**
 * Magic Link expiry time in seconds (10 minutes)
 */
const MAGIC_LINK_EXPIRY = 600;

/**
 * Supported college email domain patterns
 */
const COLLEGE_EMAIL_PATTERNS = [
  /\.edu$/i,
  /\.edu\.in$/i,
  /\.ac\.in$/i,
  /\.ac\.uk$/i,
  /\.edu\.au$/i,
  /\.edu\.ca$/i,
  /\.edu\.[a-z]{2}$/i,
];

/**
 * Validates if email is from a college domain
 */
function isCollegeEmail(email: string): boolean {
  const domain = email.toLowerCase().split("@")[1];
  if (!domain) return false;
  return COLLEGE_EMAIL_PATTERNS.some(pattern => pattern.test(domain));
}

/**
 * POST /api/auth/magic-link
 *
 * Sends a magic link to the provided email address for passwordless authentication.
 * The link redirects to /auth/callback after successful verification.
 * For student role, validates that email is from an educational institution.
 *
 * @param request - Contains email, optional role, and optional redirectTo path
 * @returns Success message or error
 */
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { email, redirectTo, role } = body;

    // Validate email
    if (!email || typeof email !== "string") {
      return NextResponse.json(
        { error: "Email is required" },
        { status: 400 }
      );
    }

    // Basic email format validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return NextResponse.json(
        { error: "Please enter a valid email address" },
        { status: 400 }
      );
    }

    // For student role, validate educational email domain
    if (role === "student" && !isCollegeEmail(email)) {
      return NextResponse.json(
        {
          error: "Student accounts require a valid educational email address (.edu, .ac.in, .ac.uk, etc.)"
        },
        { status: 400 }
      );
    }

    const supabase = await createClient();
    const normalizedEmail = email.toLowerCase().trim();

    // For login flow (no role), verify the account exists before sending magic link
    const isLoginFlow = !role;
    if (isLoginFlow) {
      const { data: existingProfile } = await supabase
        .from("profiles")
        .select("id, user_type")
        .eq("email", normalizedEmail)
        .single();

      if (!existingProfile || !existingProfile.user_type) {
        return NextResponse.json(
          { error: "No account found with this email. Please sign up first." },
          { status: 404 }
        );
      }
    }

    // Determine the callback URL with role parameter
    const siteUrl = process.env.NEXT_PUBLIC_SITE_URL || "http://localhost:3000";
    let callbackUrl = `${siteUrl}/auth/callback`;

    // Build query params
    const params = new URLSearchParams();
    if (redirectTo) params.set("next", redirectTo);
    if (role) params.set("role", role);

    if (params.toString()) {
      callbackUrl += `?${params.toString()}`;
    }

    // Send magic link
    // Login flow: don't create new users; Signup flow: allow user creation
    const { error } = await supabase.auth.signInWithOtp({
      email: normalizedEmail,
      options: {
        emailRedirectTo: callbackUrl,
        shouldCreateUser: !isLoginFlow,
      },
    });

    if (error) {
      console.error("[Magic Link Error]", error.message);

      // Handle rate limiting
      if (error.message.includes("rate limit")) {
        return NextResponse.json(
          { error: "Too many requests. Please wait a few minutes before trying again." },
          { status: 429 }
        );
      }

      return NextResponse.json(
        { error: error.message },
        { status: 400 }
      );
    }

    return NextResponse.json({
      success: true,
      message: "Magic link sent successfully",
      expiresIn: MAGIC_LINK_EXPIRY,
    });
  } catch (error) {
    console.error("[Magic Link Error]", error);
    return NextResponse.json(
      { error: "An unexpected error occurred" },
      { status: 500 }
    );
  }
}
