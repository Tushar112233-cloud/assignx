/**
 * Shared TypeScript interfaces for Help & Support components
 */

export interface HelpCategory {
  id: string
  title: string
  description: string
  icon: string
  itemCount: number
  href: string
}

export interface FAQItem {
  id: string
  question: string
  answer: string
  category: string
  helpful?: number
  views?: number
}

export interface ContactMethod {
  id: string
  type: 'email' | 'chat' | 'phone' | 'ticket'
  title: string
  description: string
  icon: string
  availability: string
  responseTime: string
  action: {
    label: string
    href?: string
    onClick?: () => void
  }
}
