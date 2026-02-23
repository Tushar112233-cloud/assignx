import { NextRequest, NextResponse } from "next/server"
import { createClient } from "@/lib/supabase/server"
import { deleteFromCloudinary, isCloudinaryConfigured } from "@/lib/cloudinary/client"
import {
  apiRateLimiter,
  getClientIdentifier,
  rateLimitHeaders,
} from "@/lib/rate-limit"
import { validateOriginOnly, csrfError } from "@/lib/csrf"

/**
 * Request body type for Cloudinary delete
 */
interface DeleteRequest {
  publicId: string
  resourceType?: "image" | "video" | "raw"
}

/**
 * DELETE /api/cloudinary/delete
 * Deletes a file from Cloudinary via server-side (secure)
 */
export async function DELETE(request: NextRequest) {
  try {
    // Check if Cloudinary is configured
    if (!isCloudinaryConfigured()) {
      console.error("[Cloudinary Delete] Cloudinary not configured")
      return NextResponse.json(
        { error: "File service not configured" },
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
      console.error("[Cloudinary Delete] Auth error:", authError?.message || "No user")
      return NextResponse.json(
        { error: "Unauthorized - please login again" },
        { status: 401 }
      )
    }

    // CSRF protection for web requests
    const origin = request.headers.get("origin")
    const referer = request.headers.get("referer")

    if (origin || referer) {
      const originCheck = validateOriginOnly(request)
      if (!originCheck.valid) {
        console.warn(`[Cloudinary Delete] CSRF rejected - user: ${user.id}`)
        return csrfError(originCheck.error)
      }
    }

    // Apply rate limiting (20 deletes per minute)
    const clientId = getClientIdentifier(user.id, request)
    const rateLimitResult = await apiRateLimiter.check(20, clientId)

    if (!rateLimitResult.success) {
      return NextResponse.json(
        { error: "Too many delete requests. Please try again later." },
        {
          status: 429,
          headers: rateLimitHeaders(rateLimitResult),
        }
      )
    }

    const body: DeleteRequest = await request.json()

    // Validate request
    if (!body.publicId) {
      return NextResponse.json(
        { error: "Public ID is required" },
        { status: 400 }
      )
    }

    // Validate that user is deleting from their own folder
    const publicIdParts = body.publicId.split("/")
    if (publicIdParts.length >= 3 && publicIdParts[0] === "assignx") {
      const folderType = publicIdParts[1] // avatars, projects, marketplace
      const entityId = publicIdParts[2]

      // For avatars and marketplace, entity ID should match user ID
      if ((folderType === "avatars" || folderType === "marketplace") && entityId !== user.id) {
        console.warn(`[Cloudinary Delete] Unauthorized delete - user: ${user.id}, publicId: ${body.publicId}`)
        return NextResponse.json(
          { error: "Unauthorized delete operation" },
          { status: 403 }
        )
      }

      // For projects, verify user has access
      if (folderType === "projects") {
        const { data: project } = await supabase
          .from("projects")
          .select("id, user_id")
          .eq("id", entityId)
          .single()

        if (!project || project.user_id !== user.id) {
          console.warn(`[Cloudinary Delete] Unauthorized project delete - user: ${user.id}, project: ${entityId}`)
          return NextResponse.json(
            { error: "Unauthorized delete operation" },
            { status: 403 }
          )
        }
      }
    }

    console.log(`[Cloudinary Delete] Deleting: ${body.publicId}, user: ${user.id}`)

    // Delete from Cloudinary
    await deleteFromCloudinary(body.publicId, body.resourceType || "image")

    // Log deletion for audit
    await supabase.from("activity_logs").insert({
      profile_id: user.id,
      action: "file_deleted",
      action_category: "file",
      description: `Deleted file: ${body.publicId}`,
      metadata: {
        public_id: body.publicId,
        resource_type: body.resourceType || "image",
      },
      source_role: "user",
    })

    console.log(`[Cloudinary Delete] Success - publicId: ${body.publicId}`)

    return NextResponse.json({ success: true })
  } catch (error: any) {
    console.error("[Cloudinary Delete] Error:", error?.message || error)

    return NextResponse.json(
      { error: "Failed to delete file" },
      { status: 500 }
    )
  }
}
