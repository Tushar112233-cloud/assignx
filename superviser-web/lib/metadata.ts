/**
 * @fileoverview SEO metadata configuration and helper functions for Next.js pages.
 * @module lib/metadata
 */

import type { Metadata, Viewport } from "next"

const APP_NAME = "AdminX"
const APP_DESCRIPTION = "AssignX Supervisor Panel - Quality. Integrity. Supervision."
const APP_URL = process.env.NEXT_PUBLIC_APP_URL || "https://admin.assignx.com"

export const siteConfig = {
  name: APP_NAME,
  description: APP_DESCRIPTION,
  url: APP_URL,
  ogImage: `${APP_URL}/og-image.png`,
  links: {
    support: "mailto:support@assignx.com",
  },
  creator: "AssignX Team",
}

export const baseMetadata: Metadata = {
  metadataBase: new URL(APP_URL),
  title: {
    default: `${APP_NAME} - Supervisor Panel`,
    template: `%s | ${APP_NAME}`,
  },
  description: APP_DESCRIPTION,
  keywords: [
    "supervisor",
    "project management",
    "quality control",
    "assignment",
    "academic",
    "expert panel",
  ],
  authors: [{ name: siteConfig.creator }],
  creator: siteConfig.creator,
  openGraph: {
    type: "website",
    locale: "en_IN",
    url: APP_URL,
    title: `${APP_NAME} - Supervisor Panel`,
    description: APP_DESCRIPTION,
    siteName: APP_NAME,
    images: [
      {
        url: siteConfig.ogImage,
        width: 1200,
        height: 630,
        alt: `${APP_NAME} - Supervisor Panel`,
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: `${APP_NAME} - Supervisor Panel`,
    description: APP_DESCRIPTION,
    images: [siteConfig.ogImage],
  },
  icons: {
    icon: "/favicon.ico",
    shortcut: "/favicon-16x16.png",
    apple: "/apple-touch-icon.png",
  },
  manifest: "/site.webmanifest",
  robots: {
    index: false,
    follow: false,
  },
  appleWebApp: {
    capable: true,
    statusBarStyle: "default",
    title: APP_NAME,
  },
  formatDetection: {
    telephone: false,
  },
}

export const viewport: Viewport = {
  themeColor: [
    { media: "(prefers-color-scheme: light)", color: "#ffffff" },
    { media: "(prefers-color-scheme: dark)", color: "#0f172a" },
  ],
  width: "device-width",
  initialScale: 1,
  maximumScale: 5,
  userScalable: true,
  viewportFit: "cover",
}

// Helper to generate page-specific metadata
export function generatePageMetadata({
  title,
  description,
  noIndex = true,
}: {
  title: string
  description?: string
  noIndex?: boolean
}): Metadata {
  return {
    title,
    description: description || APP_DESCRIPTION,
    openGraph: {
      title: `${title} | ${APP_NAME}`,
      description: description || APP_DESCRIPTION,
    },
    robots: noIndex ? { index: false, follow: false } : undefined,
  }
}
