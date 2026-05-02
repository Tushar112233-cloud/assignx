import { NextRequest, NextResponse } from "next/server";
import { extractToken, validateToken } from "@/lib/api/server";
import { uploadToCloudinary, isCloudinaryConfigured } from "@/lib/cloudinary/client";
import {
  apiRateLimiter,
  getClientIdentifier,
  rateLimitHeaders,
} from "@/lib/rate-limit";
import { validateOriginOnly, csrfError } from "@/lib/csrf";

/**
 * Request body type for Cloudinary upload
 */
interface UploadRequest {
  base64Data: string;
  folder: string;
  publicId?: string;
  resourceType?: "auto" | "image" | "video" | "raw";
}

/**
 * POST /api/cloudinary/upload
 * Uploads a file to Cloudinary via server-side (secure).
 * Auth is validated via JWT token from the Express API.
 */
export async function POST(request: NextRequest) {
  try {
    if (!isCloudinaryConfigured()) {
      console.error("[Cloudinary Upload] Cloudinary not configured");
      return NextResponse.json(
        { error: "File upload service not configured" },
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

    // Rate limiting (10 uploads per minute)
    const clientId = getClientIdentifier(user.id, request);
    const rateLimitResult = await apiRateLimiter.check(10, clientId);
    if (!rateLimitResult.success) {
      return NextResponse.json(
        { error: "Too many upload requests. Please try again later." },
        { status: 429, headers: rateLimitHeaders(rateLimitResult) }
      );
    }

    const body: UploadRequest = await request.json();

    if (!body.base64Data) {
      return NextResponse.json({ error: "No file data provided" }, { status: 400 });
    }
    if (!body.folder) {
      return NextResponse.json({ error: "Folder path is required" }, { status: 400 });
    }
    if (!body.folder.startsWith("assignx/")) {
      return NextResponse.json({ error: "Invalid folder path" }, { status: 400 });
    }

    // Validate folder ownership
    const folderParts = body.folder.split("/");
    if (folderParts.length >= 3) {
      const folderType = folderParts[1];
      const entityId = folderParts[2];
      if ((folderType === "avatars" || folderType === "marketplace") && entityId !== user.id) {
        return NextResponse.json({ error: "Unauthorized folder access" }, { status: 403 });
      }
    }

    // Check file size (~5MB max)
    const maxBase64Size = 5 * 1024 * 1024 * 1.37;
    if (body.base64Data.length > maxBase64Size) {
      return NextResponse.json(
        { error: "File too large. Maximum size is 5MB." },
        { status: 400 }
      );
    }

    // Upload to Cloudinary
    const result = await uploadToCloudinary(body.base64Data, {
      folder: body.folder,
      publicId: body.publicId,
      resourceType: body.resourceType || "image",
    });

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
          action: "file_uploaded",
          action_category: "file",
          description: `Uploaded file to ${body.folder}`,
          metadata: {
            folder: body.folder,
            public_id: result.publicId,
            format: result.format,
            bytes: result.bytes,
          },
        }),
      });
    } catch {
      // Activity logging is non-critical
    }

    return NextResponse.json({
      url: result.url,
      publicId: result.publicId,
      format: result.format,
      bytes: result.bytes,
    });
  } catch (err: unknown) {
    const error = err as { http_code?: number; message?: string };
    console.error("[Cloudinary Upload] Error:", error?.message || err);

    if (error?.http_code) {
      return NextResponse.json(
        { error: `Upload failed: ${error.message || "Unknown error"}` },
        { status: error.http_code }
      );
    }

    return NextResponse.json({ error: "Failed to upload file" }, { status: 500 });
  }
}
