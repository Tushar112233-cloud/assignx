import { createClient } from "@/lib/supabase/server";
import { NextResponse } from "next/server";
import { validateStudentEmail } from "@/lib/validations/student-email";

/**
 * Helper to parse cookies from cookie header
 */
function getCookieValue(cookieHeader: string | null, name: string): string | null {
  if (!cookieHeader) return null;
  const match = cookieHeader.match(new RegExp(`(^|;\\s*)${name}=([^;]*)`));
  return match ? match[2] : null;
}

/**
 * Helper to create redirect response with cleared signup cookies
 */
function createRedirectResponse(url: string, clearSignupCookies: boolean = false): NextResponse {
  const response = NextResponse.redirect(url);
  if (clearSignupCookies) {
    // Clear the signup cookies by setting them to expire immediately
    response.cookies.set("signup_intent", "", { maxAge: 0, path: "/" });
    response.cookies.set("signup_role", "", { maxAge: 0, path: "/" });
  }
  return response;
}

/**
 * Check if email is from a college domain
 */
function isCollegeEmail(email: string): boolean {
  const COLLEGE_EMAIL_PATTERNS = [
    /\.edu$/i,
    /\.edu\.in$/i,
    /\.ac\.in$/i,
    /\.ac\.uk$/i,
    /\.edu\.au$/i,
    /\.edu\.ca$/i,
    /\.edu\.[a-z]{2}$/i,
  ];
  const domain = email.toLowerCase().split("@")[1];
  if (!domain) return false;
  return COLLEGE_EMAIL_PATTERNS.some(pattern => pattern.test(domain));
}

/**
 * OAuth and Magic Link callback handler
 *
 * Handles multiple auth flows:
 *
 * 1. OAuth Login (Google):
 *    - New users -> onboarding
 *    - Existing users with profile -> dashboard
 *
 * 2. OAuth Signup (with signup cookies):
 *    - Validates student email for students
 *    - Creates profile with selected role
 *    - Redirects to registration form
 *
 * 3. Magic Link Login:
 *    - Same as OAuth login flow
 *
 * 4. College Email Verification:
 *    - Updates student record with verified college email
 *    - Redirects to dashboard or profile
 */
export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get("code");
  const next = searchParams.get("next");
  const verifyCollege = searchParams.get("verify_college") === "true";
  const isAddingCollege = searchParams.get("adding") === "true";
  const roleFromUrl = searchParams.get("role"); // Role from magic link URL

  // Read signup intent from cookies (set by role-selection component)
  const cookieHeader = request.headers.get("cookie");
  const isSignupFromCookie = getCookieValue(cookieHeader, "signup_intent") === "true";
  const roleFromCookie = getCookieValue(cookieHeader, "signup_role");

  // Use URL role first (magic link), then cookie role (OAuth)
  const validRoles = ['student', 'professional', 'business'];
  const rawRole = roleFromUrl || roleFromCookie;
  const role = rawRole && validRoles.includes(rawRole) ? rawRole : (rawRole ? 'student' : null);
  const isSignup = isSignupFromCookie || !!roleFromUrl;

  if (code) {
    const supabase = await createClient();
    const { error } = await supabase.auth.exchangeCodeForSession(code);

    if (!error) {
      const {
        data: { user },
      } = await supabase.auth.getUser();

      if (user) {
        const userEmail = user.email || "";

        // COLLEGE EMAIL VERIFICATION FLOW
        if (verifyCollege && isCollegeEmail(userEmail)) {
          // Update the student record with verified college email
          const { error: updateError } = await supabase
            .from("students")
            .update({
              college_email: userEmail,
              college_email_verified: true,
              college_email_verified_at: new Date().toISOString(),
            })
            .eq("profile_id", user.id);

          if (updateError) {
            console.error("[College Verify Callback Error]", updateError);
          }

          // Redirect based on whether they were adding to account or new signup
          if (isAddingCollege) {
            return NextResponse.redirect(`${origin}/profile?college_verified=true`);
          } else {
            // New user with college email - go to onboarding
            return NextResponse.redirect(`${origin}/onboarding?step=role&college_verified=true`);
          }
        }

        // SIGNUP FLOW (with signup cookies)
        if (isSignup && role) {
          // For students, validate that they're using an educational email
          if (role === "student") {
            const emailValidation = validateStudentEmail(userEmail);
            if (!emailValidation.isValid) {
              // Sign out the user since they don't have a valid student email
              await supabase.auth.signOut();
              // Redirect back to signup with error (clear cookies)
              return createRedirectResponse(
                `${origin}/signup?error=invalid_student_email&message=${encodeURIComponent(
                  emailValidation.error || "Please use a valid college/university email address"
                )}`,
                true
              );
            }
          }

          // Check for existing profile
          const { data: existingProfile } = await supabase
            .from("profiles")
            .select("id, user_type, onboarding_completed")
            .eq("id", user.id)
            .single();

          // If user already has a completed profile, redirect to home (clear cookies)
          if (existingProfile?.onboarding_completed) {
            return createRedirectResponse(`${origin}/home`, true);
          }

          // Create or update profile with selected role
          const profileData = {
            id: user.id,
            email: userEmail,
            full_name:
              user.user_metadata?.full_name ||
              user.user_metadata?.name ||
              null,
            avatar_url:
              user.user_metadata?.avatar_url ||
              user.user_metadata?.picture ||
              null,
            user_type: role === "business" ? "professional" : role,
            updated_at: new Date().toISOString(),
          };

          if (existingProfile) {
            // Update existing profile
            await supabase
              .from("profiles")
              .update(profileData)
              .eq("id", user.id);
          } else {
            // Create new profile
            await supabase.from("profiles").insert({
              ...profileData,
              created_at: new Date().toISOString(),
            });
          }

          // Redirect to appropriate registration form (clear cookies)
          if (role === "student") {
            return createRedirectResponse(`${origin}/signup/student`, true);
          } else {
            const typeParam = role === "business" ? "?type=business" : "";
            return createRedirectResponse(
              `${origin}/signup/professional${typeParam}`,
              true
            );
          }
        }

        // LOGIN FLOW (OAuth or Magic Link without signup cookies)
        // Check for existing profile with user_type set
        const { data: profile } = await supabase
          .from("profiles")
          .select("user_type, onboarding_completed")
          .eq("id", user.id)
          .single();

        // If no profile exists or no user_type, user has no account - redirect to signup
        if (!profile || !profile.user_type) {
          await supabase.auth.signOut();
          return NextResponse.redirect(
            `${origin}/signup?error=no_account&message=${encodeURIComponent("No account found. Please sign up to create your account.")}`
          );
        }

        // Check if user has completed onboarding
        if (!profile.onboarding_completed) {
          // Has user_type but not completed - redirect to appropriate signup form
          if (profile.user_type === "student") {
            return NextResponse.redirect(`${origin}/signup/student`);
          } else {
            return NextResponse.redirect(`${origin}/signup/professional`);
          }
        }

        // User has completed profile, redirect to custom next path or dashboard
        const redirectPath = next || "/home";
        return NextResponse.redirect(`${origin}${redirectPath}`);
      }
    }
  }

  // Return to login with error
  return NextResponse.redirect(`${origin}/login?error=auth_failed`);
}
