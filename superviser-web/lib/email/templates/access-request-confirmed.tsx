/**
 * @fileoverview Email template sent when a user submits an access request.
 * Confirms receipt and sets expectations on the review timeline.
 * @module lib/email/templates/access-request-confirmed
 */

import {
  Body,
  Container,
  Head,
  Heading,
  Html,
  Preview,
  Text,
} from "@react-email/components"

interface AccessRequestConfirmedEmailProps {
  email: string
}

export function AccessRequestConfirmedEmail({ email }: AccessRequestConfirmedEmailProps) {
  return (
    <Html>
      <Head />
      <Preview>We received your access request</Preview>
      <Body style={main}>
        <Container style={container}>
          <Heading style={heading}>Request Received</Heading>
          <Text style={text}>
            Hi {email},
          </Text>
          <Text style={text}>
            We&apos;ve received your request to join AssignX as a supervisor. Our team
            will review your application and get back to you shortly.
          </Text>
          <Text style={text}>
            You&apos;ll receive an email once your access has been approved.
          </Text>
          <Text style={footer}>
            If you didn&apos;t submit this request, you can safely ignore this email.
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

const footer = {
  fontSize: "13px",
  color: "#9CA3AF",
  marginTop: "32px",
}

export default AccessRequestConfirmedEmail
