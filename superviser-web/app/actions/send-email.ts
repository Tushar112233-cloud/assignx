"use server"

/**
 * @fileoverview Server action for sending emails via Resend.
 * Used by server components, other server actions, and notification workflows.
 * @module app/actions/send-email
 */

import { sendEmail } from "@/lib/email/resend"
import { AccessRequestConfirmedEmail } from "@/lib/email/templates/access-request-confirmed"
import { AccessApprovedEmail } from "@/lib/email/templates/access-approved"
import { AccessRejectedEmail } from "@/lib/email/templates/access-rejected"
import { NotificationEmail } from "@/lib/email/templates/notification"

type TemplateType =
  | "access-request-confirmed"
  | "access-approved"
  | "access-rejected"
  | "notification"

interface SendEmailActionParams {
  template: TemplateType
  to: string
  data: Record<string, string>
}

interface SendEmailResult {
  success: boolean
  error?: string
}

export async function sendEmailAction(params: SendEmailActionParams): Promise<SendEmailResult> {
  try {
    const { template, to, data } = params

    if (!template || !to) {
      return { success: false, error: "Missing required fields: template, to" }
    }

    let react: React.ReactElement
    let subject: string

    switch (template) {
      case "access-request-confirmed":
        react = AccessRequestConfirmedEmail({ email: data.email })
        subject = "We received your access request"
        break
      case "access-approved":
        react = AccessApprovedEmail({ email: data.email, loginUrl: data.loginUrl })
        subject = "Your AssignX access has been approved!"
        break
      case "access-rejected":
        react = AccessRejectedEmail({ email: data.email, reason: data.reason })
        subject = "Update on your AssignX access request"
        break
      case "notification":
        react = NotificationEmail({
          title: data.title,
          body: data.body,
          actionUrl: data.actionUrl,
          actionLabel: data.actionLabel,
        })
        subject = data.title || "New notification from AssignX"
        break
      default:
        return { success: false, error: `Unknown template: ${template}` }
    }

    await sendEmail({ to, subject, react })

    return { success: true }
  } catch (error) {
    console.error("[sendEmailAction] Error:", error)
    return { success: false, error: error instanceof Error ? error.message : "Failed to send email" }
  }
}
