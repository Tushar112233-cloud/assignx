import { NextRequest, NextResponse } from "next/server"
import { createClient } from "@/lib/supabase/server"
import { uploadToCloudinary, isCloudinaryConfigured } from "@/lib/cloudinary/client"
import {
  apiRateLimiter,
  getClientIdentifier,
  rateLimitHeaders,
} from "@/lib/rate-limit"
import { validateOriginOnly, csrfError } from "@/lib/csrf"

/**
 * Request body type for Cloudinary upload
 */
interface UploadRequest {
  base64Data: string
  folder: string
  publicId?: string
  resourceType?: "auto" | "image" | "video" | "raw"
}

/**
 * POST /api/cloudinary/upload
 * Uploads a file to Cloudinary via server-side (secure)
 *
 * This endpoint handles uploads from the mobile app securely,
 * keeping the Cloudinary API secret on the server side.
 */
export async function POST(request: NextRequest) {
  try {
    // Check if Cloudinary is configured
    if (!isCloudinaryConfigured()) {
      console.error("[Cloudinary Upload] Cloudinary not configured")
      return NextResponse.json(
        { error: "File upload service not configured" },
        { status: 503 }
      )
    }

    const supabase = await createClient()

    // Verify user is authenticated
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser()

    if (authError || !user) {
      console.error("[Cloudinary Upload] Auth error:", authError?.message || "No user")
      return NextResponse.json(
        { error: "Unauthorized - please login again" },
        { status: 401 }
      )
    }

    // CSRF protection: Validate request origin
    // Allow requests from mobile apps (no origin/referer for native apps)
    const origin = request.headers.get("origin")
    const referer = request.headers.get("referer")

    // Only validate CSRF for web requests (those with origin/referer)
    if (origin || referer) {
      const originCheck = validateOriginOnly(request)
      if (!originCheck.valid) {
        console.warn(`[Cloudinary Upload] CSRF rejected - user: ${user.id}, origin: ${origin}, referer: ${referer}`)
        return csrfError(originCheck.error)
      }
    }

    // Apply rate limiting (10 uploads per minute)
    const clientId = getClientIdentifier(user.id, request)
    const rateLimitResult = await apiRateLimiter.check(10, clientId)

    if (!rateLimitResult.success) {
      return NextResponse.json(
        { error: "Too many upload requests. Please try again later." },
        {
          status: 429,
          headers: rateLimitHeaders(rateLimitResult),
        }
      )
    }

    const body: UploadRequest = await request.json()

    // Validate request
    if (!body.base64Data) {
      return NextResponse.json(
        { error: "No file data provided" },
        { status: 400 }
      )
    }

    if (!body.folder) {
      return NextResponse.json(
        { error: "Folder path is required" },
        { status: 400 }
      )
    }

    // Validate folder path format (must start with assignx/)
    if (!body.folder.startsWith("assignx/")) {
      return NextResponse.json(
        { error: "Invalid folder path" },
        { status: 400 }
      )
    }

    // Validate that user is uploading to their own folder (for avatars/marketplace)
    const folderParts = body.folder.split("/")
    if (folderParts.length >= 3) {
      const folderType = folderParts[1] // avatars, projects, marketplace
      const entityId = folderParts[2]

      // For avatars and marketplace, entity ID should match user ID
      if ((folderType === "avatars" || folderType === "marketplace") && entityId !== user.id) {
        console.warn(`[Cloudinary Upload] Unauthorized folder access - user: ${user.id}, folder: ${body.folder}`)
        return NextResponse.json(
          { error: "Unauthorized folder access" },
          { status: 403 }
        )
      }

      // For projects, verify user has access to the project
      if (folderType === "projects") {
        const { data: project } = await supabase
          .from("projects")
          .select("id, user_id")
          .eq("id", entityId)
          .single()

        if (!project || project.user_id !== user.id) {
          console.warn(`[Cloudinary Upload] Unauthorized project access - user: ${user.id}, project: ${entityId}`)
          return NextResponse.json(
            { error: "Unauthorized project access" },
            { status: 403 }
          )
        }
      }
    }

    // Check file size (limit to 5MB base64 which is ~3.75MB actual)
    const maxBase64Size = 5 * 1024 * 1024 * 1.37 // ~6.85MB to account for base64 overhead
    if (body.base64Data.length > maxBase64Size) {
      return NextResponse.json(
        { error: "File too large. Maximum size is 5MB." },
        { status: 400 }
      )
    }

    console.log(`[Cloudinary Upload] Uploading to folder: ${body.folder}, user: ${user.id}`)

    // Upload to Cloudinary
    const result = await uploadToCloudinary(body.base64Data, {
      folder: body.folder,
      publicId: body.publicId,
      resourceType: body.resourceType || "image",
    })

    // Log upload for audit
    await supabase.from("activity_logs").insert({
      profile_id: user.id,
      action: "file_uploaded",
      action_category: "file",
      description: `Uploaded file to ${body.folder}`,
      metadata: {
        folder: body.folder,
        public_id: result.publicId,
        format: result.format,
        bytes: result.bytes,
      },
      source_role: "user",
    })

    console.log(`[Cloudinary Upload] Success - publicId: ${result.publicId}`)

    return NextResponse.json({
      url: result.url,
      publicId: result.publicId,
      format: result.format,
      bytes: result.bytes,
    })
  } catch (error: any) {
    console.error("[Cloudinary Upload] Error:", error?.message || error)

    // Check for Cloudinary-specific errors
    if (error?.http_code) {
      return NextResponse.json(
        { error: `Upload failed: ${error.message || "Unknown Cloudinary error"}` },
        { status: error.http_code }
      )
    }

    return NextResponse.json(
      { error: "Failed to upload file" },
      { status: 500 }
    )
  }
}
