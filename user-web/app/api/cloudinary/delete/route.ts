import { NextRequest, NextResponse } from "next/server";
import { extractToken, validateToken } from "@/lib/api/server";
import { deleteFromCloudinary, isCloudinaryConfigured } from "@/lib/cloudinary/client";
import {
  apiRateLimiter,
  getClientIdentifier,
  rateLimitHeaders,
} from "@/lib/rate-limit";
import { validateOriginOnly, csrfError } from "@/lib/csrf";

/**
 * Request body type for Cloudinary delete
 */
interface DeleteRequest {
  publicId: string;
  resourceType?: "image" | "video" | "raw";
}

/**
 * DELETE /api/cloudinary/delete
 * Deletes a file from Cloudinary via server-side (secure).
 * Auth is validated via JWT token from the Express API.
 */
export async function DELETE(request: NextRequest) {
  try {
    if (!isCloudinaryConfigured()) {
      return NextResponse.json(
        { error: "File service not configured" },
        { status: 503 }
      );
    }

    const token = extractToken(request);
    if (!token) {
      return NextResponse.json(
        { error: "Unauthorized - please login again" },
        { status: 401 }
      );
    }

    const user = await validateToken(token);
    if (!user) {
      return NextResponse.json(
        { error: "Unauthorized - please login again" },
        { status: 401 }
      );
    }

    // CSRF protection for web requests
    const origin = request.headers.get("origin");
    const referer = request.headers.get("referer");
    if (origin || referer) {
      const originCheck = validateOriginOnly(request);
      if (!originCheck.valid) {
        return csrfError(originCheck.error);
      }
    }

    // Rate limiting (20 deletes per minute)
    const clientId = getClientIdentifier(user.id, request);
    const rateLimitResult = await apiRateLimiter.check(20, clientId);
    if (!rateLimitResult.success) {
      return NextResponse.json(
        { error: "Too many delete requests. Please try again later." },
        { status: 429, headers: rateLimitHeaders(rateLimitResult) }
      );
    }

    const body: DeleteRequest = await request.json();

    if (!body.publicId) {
      return NextResponse.json(
        { error: "Public ID is required" },
        { status: 400 }
      );
    }

    // Validate folder ownership
    const publicIdParts = body.publicId.split("/");
    if (publicIdParts.length >= 3 && publicIdParts[0] === "assignx") {
      const folderType = publicIdParts[1];
      const entityId = publicIdParts[2];
      if ((folderType === "avatars" || folderType === "marketplace") && entityId !== user.id) {
        return NextResponse.json(
          { error: "Unauthorized delete operation" },
          { status: 403 }
        );
      }
    }

    await deleteFromCloudinary(body.publicId, body.resourceType || "image");

    // Log activity via Express API (best-effort)
    try {
      const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000";
      await fetch(`${API_URL}/api/activity-logs`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({
          action: "file_deleted",
          action_category: "file",
          description: `Deleted file: ${body.publicId}`,
          metadata: {
            public_id: body.publicId,
            resource_type: body.resourceType || "image",
          },
        }),
      });
    } catch {
      // Activity logging is non-critical
    }

    return NextResponse.json({ success: true });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : "Failed to delete file";
    console.error("[Cloudinary Delete] Error:", message);
    return NextResponse.json({ error: "Failed to delete file" }, { status: 500 });
  }
}
