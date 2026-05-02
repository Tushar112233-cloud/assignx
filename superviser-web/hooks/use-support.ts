/**
 * @fileoverview Custom hooks for support tickets and help system.
 * Uses Express API + Socket.IO instead of Supabase.
 * @module hooks/use-support
 */

"use client"

import { useEffect, useState, useCallback } from "react"
import { apiFetch } from "@/lib/api/client"
import { getStoredUser } from "@/lib/api/auth"
import { getSocket } from "@/lib/socket/client"
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
    try {
      setIsLoading(true)
      setError(null)

      const params = new URLSearchParams()
      params.set("role", "supervisor")
      params.set("limit", String(limit))
      params.set("offset", String(offset))

      if (status) {
        const statuses = Array.isArray(status) ? status.join(",") : status
        params.set("status", statuses)
      }

      const data = await apiFetch<{ tickets: SupportTicket[]; total: number }>(
        `/api/support/tickets?${params.toString()}`
      )

      setTickets(data.tickets || [])
      setTotalCount(data.total || 0)
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

    try {
      setIsLoading(true)
      setError(null)

      // The API returns ticket and messages from separate endpoints
      const [ticketData, messagesData] = await Promise.all([
        apiFetch<{ ticket: SupportTicketWithMessages }>(`/api/support/tickets/${ticketId}`),
        apiFetch<{ messages: TicketMessage[] }>(`/api/support/tickets/${ticketId}/messages`),
      ])

      setTicket(ticketData.ticket)
      setMessages(messagesData.messages || [])
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Failed to fetch ticket"))
    } finally {
      setIsLoading(false)
    }
  }, [ticketId])

  const sendMessage = useCallback(async (content: string) => {
    if (!ticketId || !content.trim()) return

    const data = await apiFetch<{ ticket: SupportTicketWithMessages }>(
      `/api/support/tickets/${ticketId}/messages`,
      {
        method: "POST",
        body: JSON.stringify({
          message: content.trim(),
        }),
      }
    )

    // The API returns the full updated ticket; extract the last message
    const ticketMessages = (data.ticket as any)?.messages || []
    if (ticketMessages.length > 0) {
      const lastMsg = ticketMessages[ticketMessages.length - 1]
      setMessages(prev => [...prev, lastMsg])
    }
  }, [ticketId])

  const updateStatus = useCallback(async (status: TicketStatus) => {
    if (!ticketId) return

    await apiFetch(`/api/support/tickets/${ticketId}/status`, {
      method: "PUT",
      body: JSON.stringify({ status }),
    })

    setTicket(prev => prev ? { ...prev, status, updated_at: new Date().toISOString() } : null)
  }, [ticketId])

  useEffect(() => {
    fetchTicket()
  }, [fetchTicket])

  // Real-time: new messages via Socket.IO
  useEffect(() => {
    if (!ticketId) return

    try {
      const socket = getSocket()

      const handleNewMessage = (message: TicketMessage) => {
        setMessages(prev => {
          if (prev.some(m => m.id === message.id)) return prev
          return [...prev, message]
        })
      }

      socket.on(`support:${ticketId}`, handleNewMessage)

      return () => {
        socket.off(`support:${ticketId}`, handleNewMessage)
      }
    } catch {
      return undefined
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
    try {
      setIsCreating(true)
      setError(null)

      const ticket = await apiFetch<SupportTicket>("/api/support/tickets", {
        method: "POST",
        body: JSON.stringify({
          ...data,
          sourceRole: "supervisor",
        }),
      })

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
    try {
      const user = getStoredUser()
      if (!user) return

      // The API provides /support/tickets/count for individual status counts.
      // Fetch total and open counts separately.
      const [totalData, openData, inProgressData, resolvedData] = await Promise.all([
        apiFetch<{ count: number }>("/api/support/tickets/count").catch(() => ({ count: 0 })),
        apiFetch<{ count: number }>("/api/support/tickets/count?status=open").catch(() => ({ count: 0 })),
        apiFetch<{ count: number }>("/api/support/tickets/count?status=in_progress").catch(() => ({ count: 0 })),
        apiFetch<{ count: number }>("/api/support/tickets/count?status=resolved").catch(() => ({ count: 0 })),
      ])

      setStats({
        total: totalData.count,
        open: openData.count,
        inProgress: inProgressData.count,
        resolved: resolvedData.count,
        unreadCount: openData.count,
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
