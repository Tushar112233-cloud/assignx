/**
 * Support Service
 * Handles support tickets and FAQ operations
 * @module services/support.service
 */

import { createClient } from '@/lib/supabase/client'
import type { SupportTicket, FAQ } from '@/types/database'

/**
 * Ticket creation payload
 */
interface CreateTicketPayload {
  /** Ticket subject */
  subject: string
  /** Detailed description of the issue */
  description: string
  /** Issue category */
  category: 'technical' | 'payment' | 'project' | 'account' | 'other'
  /** Optional priority level */
  priority?: 'low' | 'medium' | 'high' | 'urgent'
}

/**
 * Create support ticket
 * @param userId - The user ID
 * @param ticket - Ticket details
 * @returns Success status with created ticket or error
 */
export async function createSupportTicket(
  userId: string,
  ticket: CreateTicketPayload
): Promise<{ success: boolean; error?: string; ticket?: SupportTicket }> {
  const supabase = createClient()

  const { data, error } = await supabase
    .from('support_tickets')
    .insert({
      requester_id: userId,
      subject: ticket.subject,
      description: ticket.description,
      category: ticket.category,
      priority: ticket.priority || 'medium',
      status: 'open',
      source_role: 'doer',
    })
    .select()
    .single()

  if (error) {
    console.error('Error creating support ticket:', error)
    return { success: false, error: error.message }
  }

  return { success: true, ticket: data }
}

/**
 * Get support tickets for user
 * @param userId - The user ID
 * @returns Array of support tickets
 */
export async function getSupportTickets(userId: string): Promise<SupportTicket[]> {
  const supabase = createClient()

  const { data } = await supabase
    .from('support_tickets')
    .select('*')
    .eq('requester_id', userId)
    .eq('source_role', 'doer')
    .order('created_at', { ascending: false })

  return data || []
}

/**
 * Get FAQs with optional category filter
 * @param category - Optional category to filter by
 * @returns Array of active FAQs
 */
export async function getFAQs(category?: string): Promise<FAQ[]> {
  const supabase = createClient()

  let query = supabase
    .from('faqs')
    .select('*')
    .eq('is_active', true)
    .or('target_role.is.null,target_role.eq.doer')
    .order('display_order', { ascending: true })

  if (category) {
    query = query.eq('category', category)
  }

  const { data } = await query

  return data || []
}
