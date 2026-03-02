import { NextResponse } from "next/server";

/**
 * OAuth / Magic-link callback handler (legacy).
 *
 * Auth is now fully JWT-based via the Express API (/api/auth/*).
 * The client calls the Express API directly for magic-link verification
 * and receives JWT tokens that are stored in localStorage.
 *
 * This route is kept as a simple redirect so that any stale emails or
 * bookmarks pointing to /auth/callback still land somewhere sensible.
 */
export async function GET(request: Request) {
  const { origin } = new URL(request.url);

  // Redirect to the login page -- the client-side auth flow will take
  // care of token exchange.
  return NextResponse.redirect(`${origin}/login`);
}
