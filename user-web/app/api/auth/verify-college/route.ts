import { createClient } from "@/lib/supabase/server";
import { NextRequest, NextResponse } from "next/server";

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
 * POST /api/auth/verify-college
 *
 * Sends a verification magic link to a college email address.
 * Used to verify student status for Campus Connect features.
 *
 * If isAddingToAccount is true, links the college email to existing user.
 * Otherwise, creates a new user with the college email.
 *
 * @param request - Contains email and isAddingToAccount flag
 * @returns Success message or error
 */
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { email, isAddingToAccount = false } = body;

    // Validate email
    if (!email || typeof email !== "string") {
      return NextResponse.json(
        { error: "Email is required" },
        { status: 400 }
      );
    }

    const normalizedEmail = email.toLowerCase().trim();

    // Basic email format validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(normalizedEmail)) {
      return NextResponse.json(
        { error: "Please enter a valid email address" },
        { status: 400 }
      );
    }

    // Validate college email domain
    if (!isCollegeEmail(normalizedEmail)) {
      return NextResponse.json(
        {
          error: "Please use a valid college/university email address (.edu, .edu.in, .ac.in, .ac.uk)",
        },
        { status: 400 }
      );
    }

    const supabase = await createClient();

    // Determine the callback URL with college verification flag
    const siteUrl = process.env.NEXT_PUBLIC_SITE_URL || "http://localhost:3000";
    const callbackUrl = `${siteUrl}/auth/callback?verify_college=true&adding=${isAddingToAccount}`;

    if (isAddingToAccount) {
      // User is adding a college email to their existing account
      // First check if user is authenticated
      const { data: { user } } = await supabase.auth.getUser();

      if (!user) {
        return NextResponse.json(
          { error: "You must be logged in to add a college email" },
          { status: 401 }
        );
      }

      // Check if this college email is already verified by another user
      const { data: existingStudent } = await supabase
        .from("students")
        .select("profile_id")
        .eq("college_email", normalizedEmail)
        .eq("college_email_verified", true)
        .single();

      if (existingStudent && existingStudent.profile_id !== user.id) {
        return NextResponse.json(
          { error: "This college email is already verified by another account" },
          { status: 400 }
        );
      }

      // Store the pending college email in the students table
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
        console.error("[College Verify Error]", updateError);
        return NextResponse.json(
          { error: "Failed to save college email" },
          { status: 500 }
        );
      }

      // Send verification email (OTP magic link)
      const { error: otpError } = await supabase.auth.signInWithOtp({
        email: normalizedEmail,
        options: {
          emailRedirectTo: callbackUrl,
          shouldCreateUser: false, // Don't create new user, just verify email
        },
      });

      if (otpError) {
        console.error("[College Verify OTP Error]", otpError.message);

        if (otpError.message.includes("rate limit")) {
          return NextResponse.json(
            { error: "Too many requests. Please wait a few minutes before trying again." },
            { status: 429 }
          );
        }

        return NextResponse.json(
          { error: otpError.message },
          { status: 400 }
        );
      }
    } else {
      // New user verification - send magic link to create account with college email
      const { error } = await supabase.auth.signInWithOtp({
        email: normalizedEmail,
        options: {
          emailRedirectTo: callbackUrl,
          shouldCreateUser: true,
        },
      });

      if (error) {
        console.error("[College Verify Error]", error.message);

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
    }

    return NextResponse.json({
      success: true,
      message: "Verification email sent successfully",
    });
  } catch (error) {
    console.error("[College Verify Error]", error);
    return NextResponse.json(
      { error: "An unexpected error occurred" },
      { status: 500 }
    );
  }
}
