import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

import { MotionProvider } from "@/components/providers/motion-provider";
import { Toaster } from "@/components/ui/sonner";
import { WhatsAppFab } from "@/components/shared/whatsapp-fab";
import { I18nProvider } from "@/lib/i18n/context";

const inter = Inter({
  variable: "--font-inter",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "AssignX - Your Task, Our Expertise",
  description:
    "Get expert help with your academic projects, professional tasks, and business needs. AssignX connects you with skilled professionals.",
  keywords: [
    "assignment help",
    "project support",
    "academic assistance",
    "professional help",
  ],
  icons: {
    icon: [{ url: "/logo.svg", type: "image/svg+xml" }],
    apple: [{ url: "/logo.svg", type: "image/svg+xml" }],
  },
};

/**
 * Root layout component that wraps all pages
 * Includes fonts and toast notifications (light mode only)
 */
export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="h-full light">
      <body className={`${inter.variable} font-sans antialiased h-full`}>
        <I18nProvider>
          <MotionProvider>
            {children}
            <WhatsAppFab />
          </MotionProvider>
          <Toaster />
        </I18nProvider>
      </body>
    </html>
  );
}
