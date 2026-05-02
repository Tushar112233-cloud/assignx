/**
 * @fileoverview API route for sending emails via Resend.
 * POST-only, server-side endpoint. Accepts template type, recipient, and data.
 * Auth validated via JWT from cookie.
 * @module app/api/email/send/route
 */

import { NextRequest, NextResponse } from "next/server"
import { sendEmail } from "@/lib/email/resend"
import { AccessRequestConfirmedEmail } from "@/lib/email/templates/access-request-confirmed"
import { AccessApprovedEmail } from "@/lib/email/templates/access-approved"
import { AccessRejectedEmail } from "@/lib/email/templates/access-rejected"
import { NotificationEmail } from "@/lib/email/templates/notification"

const API_BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000"

type TemplateType =
  | "access-request-confirmed"
  | "access-approved"
  | "access-rejected"
  | "notification"

interface EmailRequestBody {
  template: TemplateType
  to: string
  data: Record<string, string>
}

function getTemplateAndSubject(
  template: TemplateType,
  data: Record<string, string>
): { react: React.ReactElement; subject: string } {
  switch (template) {
    case "access-request-confirmed":
      return {
        react: AccessRequestConfirmedEmail({ email: data.email }),
        subject: "We received your access request",
      }
    case "access-approved":
      return {
        react: AccessApprovedEmail({ email: data.email, loginUrl: data.loginUrl }),
        subject: "Your AssignX access has been approved!",
      }
    case "access-rejected":
      return {
        react: AccessRejectedEmail({ email: data.email, reason: data.reason }),
        subject: "Update on your AssignX access request",
      }
    case "notification":
      return {
        react: NotificationEmail({
          title: data.title,
          body: data.body,
          actionUrl: data.actionUrl,
          actionLabel: data.actionLabel,
        }),
        subject: data.title || "New notification from AssignX",
      }
    default:
      throw new Error(`Unknown template: ${template}`)
  }
}

export async function POST(request: NextRequest) {
  try {
    // Validate JWT from cookie
    const token = request.cookies.get("supervisor_token")?.value
    if (!token) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
    }

    // Validate token with API
    const authRes = await fetch(`${API_BASE}/api/auth/me`, {
      headers: { Authorization: `Bearer ${token}` },
    })
    if (!authRes.ok) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
    }

    const body = (await request.json()) as EmailRequestBody

    if (!body.template || !body.to) {
      return NextResponse.json(
        { error: "Missing required fields: template, to" },
        { status: 400 }
      )
    }

    const { react, subject } = getTemplateAndSubject(body.template, body.data || {})

    const result = await sendEmail({ to: body.to, subject, react })

    return NextResponse.json({ success: true, id: result?.id })
  } catch (error) {
    console.error("[API /email/send] Error:", error)
    return NextResponse.json(
      { error: error instanceof Error ? error.message : "Failed to send email" },
      { status: 500 }
    )
  }
}
