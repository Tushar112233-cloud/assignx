/**
 * @fileoverview Email template sent when an access request is rejected.
 * @module lib/email/templates/access-rejected
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

interface AccessRejectedEmailProps {
  email: string
  reason?: string
}

export function AccessRejectedEmail({ email, reason }: AccessRejectedEmailProps) {
  return (
    <Html>
      <Head />
      <Preview>Update on your AssignX access request</Preview>
      <Body style={main}>
        <Container style={container}>
          <Heading style={heading}>Access Request Update</Heading>
          <Text style={text}>
            Hi {email},
          </Text>
          <Text style={text}>
            Thank you for your interest in AssignX. Unfortunately, we&apos;re unable to
            approve your request at this time.
          </Text>
          {reason && (
            <Text style={text}>
              Reason: {reason}
            </Text>
          )}
          <Text style={text}>
            If you believe this was a mistake or have questions, please contact our
            support team.
          </Text>
          <Text style={footer}>
            Thank you for your understanding.
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

export default AccessRejectedEmail
