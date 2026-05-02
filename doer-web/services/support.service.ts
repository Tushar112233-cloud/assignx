/**
 * Support Service
 * Handles support tickets and FAQ operations via API
 * @module services/support.service
 */

import { apiClient } from '@/lib/api/client'
import type { SupportTicket, FAQ } from '@/types/database'

interface CreateTicketPayload {
  subject: string
  description: string
  category: 'technical' | 'payment' | 'project' | 'account' | 'other'
  priority?: 'low' | 'medium' | 'high' | 'urgent'
}

export async function createSupportTicket(
  userId: string,
  ticket: CreateTicketPayload
): Promise<{ success: boolean; error?: string; ticket?: SupportTicket }> {
  try {
    const data = await apiClient<{ ticket: SupportTicket }>('/api/support/tickets', {
      method: 'POST',
      body: JSON.stringify({
        subject: ticket.subject,
        description: ticket.description,
        category: ticket.category,
        priority: ticket.priority || 'medium',
      }),
    })
    return { success: true, ticket: data.ticket }
  } catch (err) {
    return { success: false, error: (err as Error).message }
  }
}

export async function getSupportTickets(_userId: string): Promise<SupportTicket[]> {
  try {
    const data = await apiClient<{ tickets: SupportTicket[] }>(
      '/api/support/tickets'
    )
    return data.tickets || []
  } catch {
    return []
  }
}

export async function getFAQs(category?: string): Promise<FAQ[]> {
  try {
    const params = new URLSearchParams()
    params.set('role', 'doer')
    if (category) params.set('category', category)

    const data = await apiClient<{ faqs: FAQ[] }>(`/api/support/faqs?${params}`)
    return data.faqs || []
  } catch {
    return []
  }
}
