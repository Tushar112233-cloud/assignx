/**
 * @fileoverview Custom hooks for support tickets and help system.
 * @module hooks/use-support
 */

"use client"

import { useEffect, useState, useCallback } from "react"
import { createClient, getAuthUser } from "@/lib/supabase/client"
import type {
  SupportTicket,
  SupportTicketWithMessages,
  TicketMessage,
  TicketStatus,
  TicketPriority
} from "@/types/database"

interface UseTicketsOptions {
  status?: TicketStatus | TicketStatus[]
  limit?: number
  offset?: number
}

interface UseTicketsReturn {
  tickets: SupportTicket[]
  isLoading: boolean
  error: Error | null
  totalCount: number
  refetch: () => Promise<void>
}

export function useTickets(options: UseTicketsOptions = {}): UseTicketsReturn {
  const { status, limit = 50, offset = 0 } = options
  const [tickets, setTickets] = useState<SupportTicket[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)
  const [totalCount, setTotalCount] = useState(0)

  const fetchTickets = useCallback(async () => {
    const supabase = createClient()

    try {
      setIsLoading(true)
      setError(null)

      const user = await getAuthUser()
      if (!user) throw new Error("Not authenticated")

      // Build query
      let query = supabase
        .from("support_tickets")
        .select("*", { count: "exact" })
        .eq("requester_id", user.id)
        .eq("source_role", "supervisor")
        .order("created_at", { ascending: false })
        .range(offset, offset + limit - 1)

      // Filter by status
      if (status) {
        if (Array.isArray(status)) {
          query = query.in("status", status)
        } else {
          query = query.eq("status", status)
        }
      }

      const { data, error: queryError, count } = await query

      if (queryError) throw queryError

      setTickets(data || [])
      setTotalCount(count || 0)
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Failed to fetch tickets"))
    } finally {
      setIsLoading(false)
    }
  }, [status, limit, offset])

  useEffect(() => {
    fetchTickets()
  }, [fetchTickets])

  return {
    tickets,
    isLoading,
    error,
    totalCount,
    refetch: fetchTickets,
  }
}

interface UseTicketReturn {
  ticket: SupportTicketWithMessages | null
  messages: TicketMessage[]
  isLoading: boolean
  error: Error | null
  refetch: () => Promise<void>
  sendMessage: (content: string) => Promise<void>
  updateStatus: (status: TicketStatus) => Promise<void>
}

export function useTicket(ticketId: string): UseTicketReturn {
  const [ticket, setTicket] = useState<SupportTicketWithMessages | null>(null)
  const [messages, setMessages] = useState<TicketMessage[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  const fetchTicket = useCallback(async () => {
    if (!ticketId) return

    const supabase = createClient()

    try {
      setIsLoading(true)
      setError(null)

      // Fetch ticket
      const { data: ticketData, error: ticketError } = await supabase
        .from("support_tickets")
        .select("*")
        .eq("id", ticketId)
        .single()

      if (ticketError) throw ticketError
      setTicket(ticketData)

      // Fetch messages
      const { data: messagesData, error: messagesError } = await supabase
        .from("ticket_messages")
        .select(`
          *,
          profiles!sender_id (*)
        `)
        .eq("ticket_id", ticketId)
        .order("created_at", { ascending: true })

      if (messagesError) throw messagesError

      // Transform for type compatibility
      const transformedMessages = (messagesData || []).map(msg => ({
        ...msg,
        profiles: msg.profiles || undefined,
      }))
      setMessages(transformedMessages)
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Failed to fetch ticket"))
    } finally {
      setIsLoading(false)
    }
  }, [ticketId])

  const sendMessage = useCallback(async (content: string) => {
    if (!ticketId || !content.trim()) return

    const supabase = createClient()
    const user = await getAuthUser()
    if (!user) throw new Error("Not authenticated")

    const { data, error: sendError } = await supabase
      .from("ticket_messages")
      .insert({
        ticket_id: ticketId,
        sender_id: user.id,
        message: content.trim(),
        sender_type: "supervisor",
      })
      .select("*")
      .single()

    if (sendError) throw sendError

    setMessages(prev => [...prev, data])

    // Update ticket's last message time
    await supabase
      .from("support_tickets")
      .update({
        updated_at: new Date().toISOString(),
        last_message_at: new Date().toISOString(),
      })
      .eq("id", ticketId)
  }, [ticketId])

  const updateStatus = useCallback(async (status: TicketStatus) => {
    if (!ticketId) return

    const supabase = createClient()

    const updateData: Partial<SupportTicket> = {
      status,
      updated_at: new Date().toISOString(),
    }

    if (status === "resolved" || status === "closed") {
      updateData.resolved_at = new Date().toISOString()
    }

    const { error: updateError } = await supabase
      .from("support_tickets")
      .update(updateData)
      .eq("id", ticketId)

    if (updateError) throw updateError

    setTicket(prev => prev ? { ...prev, ...updateData } : null)
  }, [ticketId])

  useEffect(() => {
    fetchTicket()
  }, [fetchTicket])

  // Real-time subscription for new messages
  useEffect(() => {
    if (!ticketId) return

    const supabase = createClient()

    const channel = supabase
      .channel(`ticket_${ticketId}`)
      .on(
        "postgres_changes",
        {
          event: "INSERT",
          schema: "public",
          table: "ticket_messages",
          filter: `ticket_id=eq.${ticketId}`,
        },
        async (payload) => {
          // Fetch with profile
          const { data } = await supabase
            .from("ticket_messages")
            .select(`
              *,
              profiles!sender_id (*)
            `)
            .eq("id", payload.new.id)
            .single()

          if (data) {
            const transformedData = {
              ...data,
              profiles: data.profiles || undefined,
            }
            setMessages(prev => {
              // Avoid duplicates
              if (prev.some(m => m.id === transformedData.id)) return prev
              return [...prev, transformedData]
            })
          }
        }
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [ticketId])

  return {
    ticket,
    messages,
    isLoading,
    error,
    refetch: fetchTicket,
    sendMessage,
    updateStatus,
  }
}

interface CreateTicketData {
  subject: string
  description: string
  category: string
  priority: TicketPriority
  project_id?: string
}

interface UseCreateTicketReturn {
  createTicket: (data: CreateTicketData) => Promise<SupportTicket>
  isCreating: boolean
  error: Error | null
}

export function useCreateTicket(): UseCreateTicketReturn {
  const [isCreating, setIsCreating] = useState(false)
  const [error, setError] = useState<Error | null>(null)

  const createTicket = useCallback(async (data: CreateTicketData): Promise<SupportTicket> => {
    const supabase = createClient()

    try {
      setIsCreating(true)
      setError(null)

      const user = await getAuthUser()
      if (!user) throw new Error("Not authenticated")

      // Generate ticket number
      const ticketNumber = `TKT-${new Date().getFullYear()}-${String(Date.now()).slice(-5)}`

      const { data: ticket, error: createError } = await supabase
        .from("support_tickets")
        .insert({
          ticket_number: ticketNumber,
          requester_id: user.id,
          subject: data.subject,
          description: data.description,
          category: data.category,
          priority: data.priority,
          project_id: data.project_id || null,
          status: "open",
          source_role: "supervisor",
        })
        .select()
        .single()

      if (createError) throw createError

      return ticket
    } catch (err) {
      const error = err instanceof Error ? err : new Error("Failed to create ticket")
      setError(error)
      throw error
    } finally {
      setIsCreating(false)
    }
  }, [])

  return {
    createTicket,
    isCreating,
    error,
  }
}

interface UseTicketStatsReturn {
  stats: {
    total: number
    open: number
    inProgress: number
    resolved: number
    unreadCount: number
  } | null
  isLoading: boolean
  refetch: () => Promise<void>
}

export function useTicketStats(): UseTicketStatsReturn {
  const [stats, setStats] = useState<UseTicketStatsReturn["stats"]>(null)
  const [isLoading, setIsLoading] = useState(true)

  const fetchStats = useCallback(async () => {
    const supabase = createClient()

    try {
      const user = await getAuthUser()
      if (!user) return

      // Fetch tickets with their messages
      const { data: tickets } = await supabase
        .from("support_tickets")
        .select(`
          id,
          status,
          ticket_messages (
            id,
            sender_id,
            sender_type,
            created_at
          )
        `)
        .eq("requester_id", user.id)
        .eq("source_role", "supervisor")

      if (!tickets) return

      const openStatuses: TicketStatus[] = ["open", "reopened"]
      const inProgressStatuses: TicketStatus[] = ["in_progress", "waiting_response"]
      const resolvedStatuses: TicketStatus[] = ["resolved", "closed"]

      // Calculate unread count
      let unreadCount = 0
      tickets.forEach(ticket => {
        const messages = ticket.ticket_messages as Array<{
          id: string
          sender_id: string
          sender_type: string
          created_at: string
        }> | null

        if (!messages || messages.length === 0) return

        const sortedMessages = [...messages].sort(
          (a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
        )

        const lastMessage = sortedMessages[0]
        if (lastMessage.sender_id !== user.id && lastMessage.sender_type !== "supervisor") {
          unreadCount++
        }
      })

      setStats({
        total: tickets.length,
        open: tickets.filter(t => openStatuses.includes(t.status as TicketStatus)).length,
        inProgress: tickets.filter(t => inProgressStatuses.includes(t.status as TicketStatus)).length,
        resolved: tickets.filter(t => resolvedStatuses.includes(t.status as TicketStatus)).length,
        unreadCount,
      })
    } catch (err) {
      console.error("Failed to fetch ticket stats:", err)
    } finally {
      setIsLoading(false)
    }
  }, [])

  useEffect(() => {
    fetchStats()
  }, [fetchStats])

  return { stats, isLoading, refetch: fetchStats }
}
