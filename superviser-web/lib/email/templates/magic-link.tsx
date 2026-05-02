/**
 * @fileoverview Branded magic link email template.
 * Used when Supabase sends magic link auth emails via Resend SMTP.
 * NOTE: To use this template, configure Resend SMTP in Supabase Dashboard:
 *   Auth → SMTP Settings → Enable Custom SMTP
 *   Host: smtp.resend.com | Port: 465 | Username: resend | Password: <RESEND_API_KEY>
 * @module lib/email/templates/magic-link
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

interface MagicLinkEmailProps {
  magicLink: string
  email?: string
}

export function MagicLinkEmail({ magicLink, email }: MagicLinkEmailProps) {
  return (
    <Html>
      <Head />
      <Preview>Sign in to AssignX</Preview>
      <Body style={main}>
        <Container style={container}>
          <Heading style={heading}>Sign in to AssignX</Heading>
          <Text style={text}>
            Hi{email ? ` ${email}` : ""},
          </Text>
          <Text style={text}>
            Click the button below to sign in to your AssignX supervisor account.
            This link expires in 10 minutes.
          </Text>
          <Section style={buttonContainer}>
            <Link href={magicLink} style={button}>
              Sign In
            </Link>
          </Section>
          <Text style={footer}>
            If you didn&apos;t request this email, you can safely ignore it.
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

export default MagicLinkEmail
