import type { Metadata } from 'next'
import { Geist, Geist_Mono } from 'next/font/google'
import { ThemeProvider } from '@/components/providers/ThemeProvider'
import { Toaster } from '@/components/ui/sonner'
import { I18nProvider } from '@/lib/i18n/context'
import './globals.css'

const geistSans = Geist({
  variable: '--font-geist-sans',
  subsets: ['latin'],
})

const geistMono = Geist_Mono({
  variable: '--font-geist-mono',
  subsets: ['latin'],
})

export const metadata: Metadata = {
  title: 'DOLANCER - Your Skills, Your Earnings',
  description: 'Talent Connect platform for skilled professionals to earn by completing tasks',
  keywords: ['freelance', 'tasks', 'earn', 'skills', 'talent'],
  icons: {
    icon: [{ url: '/logo.svg', type: 'image/svg+xml' }],
    apple: [{ url: '/logo.svg', type: 'image/svg+xml' }],
  },
}

/**
 * Root layout component for the Dolancer Web application
 */
export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body
        className={`${geistSans.variable} ${geistMono.variable} font-sans antialiased`}
      >
        <I18nProvider>
          <ThemeProvider
            attribute="class"
            defaultTheme="light"
            forcedTheme="light"
            disableTransitionOnChange
          >
            {children}
            <Toaster position="top-center" richColors />
          </ThemeProvider>
        </I18nProvider>
      </body>
    </html>
  )
}
