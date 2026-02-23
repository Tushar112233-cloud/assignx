/**
 * @fileoverview Resend email client singleton and reusable send helper.
 * @module lib/email/resend
 */

import { Resend } from "resend"

const resend = process.env.RESEND_API_KEY
  ? new Resend(process.env.RESEND_API_KEY)
  : null

const FROM_EMAIL = process.env.RESEND_FROM_EMAIL || "AssignX <noreply@assignx.com>"

export interface SendEmailOptions {
  to: string | string[]
  subject: string
  react: React.ReactElement
  replyTo?: string
}

/**
 * Send an email via Resend.
 * Must be called server-side only (server actions, API routes).
 */
export async function sendEmail({ to, subject, react, replyTo }: SendEmailOptions) {
  if (!resend) {
    console.warn("[Resend] No API key configured. Skipping email send.")
    return null
  }

  const { data, error } = await resend.emails.send({
    from: FROM_EMAIL,
    to: Array.isArray(to) ? to : [to],
    subject,
    react,
    replyTo,
  })

  if (error) {
    console.error("[Resend] Failed to send email:", error)
    throw new Error(`Failed to send email: ${error.message}`)
  }

  return data
}

export { resend }
