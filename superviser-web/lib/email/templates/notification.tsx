/**
 * @fileoverview Generic notification email template.
 * Used for project updates, messages, and other notification types.
 * @module lib/email/templates/notification
 */

import {
  Body,
  Container,
  Head,
  Heading,
  Html,
  Link,
  Preview,
  Section,
  Text,
} from "@react-email/components"

interface NotificationEmailProps {
  title: string
  body: string
  actionUrl?: string
  actionLabel?: string
}

export function NotificationEmail({ title, body, actionUrl, actionLabel }: NotificationEmailProps) {
  return (
    <Html>
      <Head />
      <Preview>{title}</Preview>
      <Body style={main}>
        <Container style={container}>
          <Heading style={heading}>{title}</Heading>
          <Text style={text}>{body}</Text>
          {actionUrl && (
            <Section style={buttonContainer}>
              <Link href={actionUrl} style={button}>
                {actionLabel || "View Details"}
              </Link>
            </Section>
          )}
          <Text style={footer}>
            You received this email because you have notifications enabled on AssignX.
          </Text>
        </Container>
      </Body>
    </Html>
  )
}

const main = {
  backgroundColor: "#f6f6f6",
  fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
}

const container = {
  backgroundColor: "#ffffff",
  margin: "40px auto",
  padding: "40px",
  borderRadius: "12px",
  maxWidth: "480px",
}

const heading = {
  fontSize: "24px",
  fontWeight: "700" as const,
  color: "#1C1C1C",
  marginBottom: "24px",
}

const text = {
  fontSize: "15px",
  lineHeight: "24px",
  color: "#4B5563",
}

const buttonContainer = {
  textAlign: "center" as const,
  marginTop: "24px",
  marginBottom: "24px",
}

const button = {
  backgroundColor: "#1C1C1C",
  borderRadius: "10px",
  color: "#ffffff",
  display: "inline-block",
  fontSize: "15px",
  fontWeight: "600" as const,
  padding: "12px 32px",
  textDecoration: "none",
}

const footer = {
  fontSize: "13px",
  color: "#9CA3AF",
  marginTop: "32px",
}

export default NotificationEmail
