/**
 * @fileoverview Email template sent when an access request is approved.
 * @module lib/email/templates/access-approved
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

interface AccessApprovedEmailProps {
  email: string
  loginUrl?: string
}

export function AccessApprovedEmail({ email, loginUrl }: AccessApprovedEmailProps) {
  const url = loginUrl || `${process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000"}/login`

  return (
    <Html>
      <Head />
      <Preview>Your AssignX access has been approved!</Preview>
      <Body style={main}>
        <Container style={container}>
          <Heading style={heading}>You&apos;re In!</Heading>
          <Text style={text}>
            Hi {email},
          </Text>
          <Text style={text}>
            Great news — your request to join AssignX as a supervisor has been approved.
            You can now sign in and start managing your projects.
          </Text>
          <Section style={buttonContainer}>
            <Link href={url} style={button}>
              Sign In Now
            </Link>
          </Section>
          <Text style={footer}>
            If you didn&apos;t request access, please contact support.
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

export default AccessApprovedEmail
