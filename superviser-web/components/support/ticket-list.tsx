/**
 * @fileoverview Support ticket listing - redesigned to match dashboard design system.
 * @module components/support/ticket-list
 */

"use client"

import { useState, useMemo } from "react"
import { motion } from "framer-motion"
import {
  Search,
  Plus,
  MessageSquare,
  Clock,
  ChevronRight,
  Filter,
  Inbox,
  CircleDot,
  Loader2,
  CheckCircle2,
} from "lucide-react"

import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { cn } from "@/lib/utils"
import { useTickets } from "@/hooks/use-support"
import { SupportTicket as DatabaseSupportTicket } from "@/types/database"
import {
  TicketStatus,
  TicketPriority,
  TicketCategory,
  TICKET_STATUS_CONFIG,
  TICKET_PRIORITY_CONFIG,
  TICKET_CATEGORY_CONFIG,
} from "./types"


interface TicketListProps {
  onTicketSelect?: (ticket: DatabaseSupportTicket) => void
  onCreateNew?: () => void
}

export function TicketList({ onTicketSelect, onCreateNew }: TicketListProps) {
  const [searchQuery, setSearchQuery] = useState("")
  const [statusFilter, setStatusFilter] = useState<TicketStatus | "all">("all")

  const { tickets, isLoading } = useTickets()

  const filteredTickets = useMemo(() => {
    let result = [...tickets]

    if (searchQuery) {
      const query = searchQuery.toLowerCase()
      result = result.filter(
        (ticket) =>
          ticket.ticket_number.toLowerCase().includes(query) ||
          ticket.subject.toLowerCase().includes(query)
      )
    }

    if (statusFilter !== "all") {
      if (statusFilter === "open") {
        result = result.filter((ticket) => ticket.status === "open" || ticket.status === "reopened")
      } else {
        result = result.filter((ticket) => ticket.status === statusFilter)
      }
    }

    return result.sort(
      (a, b) => new Date(b.updated_at || 0).getTime() - new Date(a.updated_at || 0).getTime()
    )
  }, [tickets, searchQuery, statusFilter])

  const stats = useMemo(() => ({
    total: tickets.length,
    open: tickets.filter((t) => t.status === "open" || t.status === "reopened").length,
    inProgress: tickets.filter((t) => t.status === "in_progress" || t.status === "waiting_response").length,
    resolved: tickets.filter((t) => t.status === "resolved" || t.status === "closed").length,
  }), [tickets])

  const formatDate = (dateString: string) => {
    const date = new Date(dateString)
    const now = new Date()
    const diff = now.getTime() - date.getTime()
    const days = Math.floor(diff / (1000 * 60 * 60 * 24))

    if (days === 0) {
      return date.toLocaleTimeString("en-IN", { hour: "2-digit", minute: "2-digit" })
    } else if (days === 1) {
      return "Yesterday"
    } else if (days < 7) {
      return `${days}d ago`
    } else {
      return date.toLocaleDateString("en-IN", { day: "numeric", month: "short" })
    }
  }

  const statItems = [
    {
      label: "Total",
      value: stats.total,
      icon: Inbox,
      filter: "all" as const,
      iconColor: "text-gray-600",
      iconBg: "bg-gray-100",
    },
    {
      label: "Open",
      value: stats.open,
      icon: CircleDot,
      filter: "open" as const,
      iconColor: "text-blue-600",
      iconBg: "bg-blue-100",
    },
    {
      label: "In Progress",
      value: stats.inProgress,
      icon: Loader2,
      filter: "in_progress" as const,
      iconColor: "text-amber-600",
      iconBg: "bg-amber-100",
    },
    {
      label: "Resolved",
      value: stats.resolved,
      icon: CheckCircle2,
      filter: "resolved" as const,
      iconColor: "text-green-600",
      iconBg: "bg-green-100",
    },
  ]

  if (isLoading) {
    return (
      <div className="space-y-4">
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
          {[1, 2, 3, 4].map((i) => (
            <div key={i} className="bg-white rounded-2xl border border-gray-200 p-4 animate-pulse">
              <div className="h-4 w-16 bg-gray-200 rounded mb-2" />
              <div className="h-8 w-12 bg-gray-200 rounded" />
            </div>
          ))}
        </div>
        <div className="bg-white rounded-2xl border border-gray-200 p-8 animate-pulse">
          <div className="h-6 w-48 bg-gray-200 rounded mx-auto" />
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Stats Row */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        {statItems.map((item, index) => (
          <motion.button
            key={item.label}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.05 * index, duration: 0.3 }}
            onClick={() => setStatusFilter(item.filter)}
            className={cn(
              "flex items-center gap-3 p-4 rounded-2xl border transition-all duration-200 text-left",
              statusFilter === item.filter
                ? "bg-[#1C1C1C] border-[#1C1C1C] text-white"
                : "bg-white border-gray-200 hover:border-gray-300 hover:shadow-md"
            )}
          >
            <div className={cn(
              "w-10 h-10 rounded-xl flex items-center justify-center",
              statusFilter === item.filter ? "bg-white/10" : item.iconBg
            )}>
              <item.icon className={cn(
                "h-5 w-5",
                statusFilter === item.filter ? "text-white" : item.iconColor
              )} />
            </div>
            <div>
              <p className={cn(
                "text-xs font-medium",
                statusFilter === item.filter ? "text-white/70" : "text-gray-500"
              )}>
                {item.label}
              </p>
              <p className={cn(
                "text-lg font-bold",
                statusFilter === item.filter ? "text-white" : "text-[#1C1C1C]"
              )}>
                {item.value}
              </p>
            </div>
          </motion.button>
        ))}
      </div>

      {/* Search & Filter */}
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2, duration: 0.3 }}
        className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between"
      >
        <div className="flex flex-col gap-3 md:flex-row md:items-center flex-1">
          <div className="relative flex-1 max-w-md">
            <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
            <Input
              placeholder="Search tickets..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="pl-10 rounded-xl border-gray-200 bg-white h-10 focus:border-orange-300 focus:ring-orange-200"
            />
          </div>
          <Select
            value={statusFilter}
            onValueChange={(v) => setStatusFilter(v as TicketStatus | "all")}
          >
            <SelectTrigger className="w-full md:w-[170px] rounded-xl border-gray-200 bg-white h-10">
              <Filter className="h-4 w-4 mr-2 text-gray-400" />
              <SelectValue placeholder="Status" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Status</SelectItem>
              <SelectItem value="open">Open</SelectItem>
              <SelectItem value="in_progress">In Progress</SelectItem>
              <SelectItem value="waiting_response">Waiting Response</SelectItem>
              <SelectItem value="resolved">Resolved</SelectItem>
              <SelectItem value="closed">Closed</SelectItem>
            </SelectContent>
          </Select>
        </div>
        <Button
          onClick={onCreateNew}
          className="bg-[#1C1C1C] hover:bg-[#2D2D2D] text-white rounded-xl px-5 h-10 font-medium md:hidden"
        >
          <Plus className="h-4 w-4 mr-2" />
          New Ticket
        </Button>
      </motion.div>

      {/* Ticket List */}
      {filteredTickets.length === 0 ? (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.25, duration: 0.3 }}
          className="bg-white rounded-2xl border border-gray-200 p-12 text-center"
        >
          <div className="w-16 h-16 rounded-full bg-gray-100 flex items-center justify-center mx-auto mb-4">
            <MessageSquare className="h-8 w-8 text-gray-400" />
          </div>
          <h3 className="text-lg font-semibold text-[#1C1C1C]">No tickets found</h3>
          <p className="text-sm text-gray-500 mt-1 max-w-sm mx-auto">
            {searchQuery || statusFilter !== "all"
              ? "Try adjusting your search or filters"
              : "You haven't created any support tickets yet. Click below to get started."}
          </p>
          {!searchQuery && statusFilter === "all" && (
            <Button
              className="mt-6 bg-[#F97316] hover:bg-[#EA580C] text-white rounded-full px-6 font-medium shadow-lg shadow-orange-500/20 transition-all duration-200"
              onClick={onCreateNew}
            >
              <Plus className="h-4 w-4 mr-2" />
              Create Your First Ticket
            </Button>
          )}
        </motion.div>
      ) : (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.25, duration: 0.3 }}
          className="bg-white rounded-2xl border border-gray-200 overflow-hidden"
        >
          <div className="divide-y divide-gray-100">
            {filteredTickets.map((ticket, index) => (
              <motion.div
                key={ticket.id}
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.03 * index }}
                className="flex items-center gap-4 p-4 cursor-pointer hover:bg-gray-50 transition-colors"
                onClick={() => onTicketSelect?.(ticket)}
              >
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 mb-1">
                    <span className="text-xs font-mono text-gray-400">
                      {ticket.ticket_number}
                    </span>
                    {ticket.status && TICKET_STATUS_CONFIG[ticket.status as TicketStatus] && (
                      <Badge className={cn("text-[10px] font-medium px-2 py-0", TICKET_STATUS_CONFIG[ticket.status as TicketStatus].color)}>
                        {TICKET_STATUS_CONFIG[ticket.status as TicketStatus].label}
                      </Badge>
                    )}
                    {ticket.priority && TICKET_PRIORITY_CONFIG[ticket.priority as TicketPriority] && (
                      <Badge variant="outline" className={cn("text-[10px] font-medium px-2 py-0", TICKET_PRIORITY_CONFIG[ticket.priority as TicketPriority].color)}>
                        {TICKET_PRIORITY_CONFIG[ticket.priority as TicketPriority].label}
                      </Badge>
                    )}
                  </div>
                  <p className="font-medium text-[#1C1C1C] truncate text-sm">{ticket.subject}</p>
                  <div className="flex items-center gap-2 mt-1">
                    {ticket.category && TICKET_CATEGORY_CONFIG[ticket.category as TicketCategory] && (
                      <span className="text-[10px] px-2 py-0.5 rounded-full bg-gray-100 text-gray-600">
                        {TICKET_CATEGORY_CONFIG[ticket.category as TicketCategory].label}
                      </span>
                    )}
                    {ticket.project_id && (
                      <span className="text-[10px] text-gray-400">
                        Project: {ticket.project_id.slice(0, 8)}...
                      </span>
                    )}
                  </div>
                </div>
                <div className="flex items-center gap-3 text-sm text-gray-400 shrink-0">
                  {ticket.updated_at && (
                    <div className="flex items-center gap-1 text-xs">
                      <Clock className="h-3.5 w-3.5" />
                      <span>{formatDate(ticket.updated_at)}</span>
                    </div>
                  )}
                  <ChevronRight className="h-4 w-4" />
                </div>
              </motion.div>
            ))}
          </div>
        </motion.div>
      )}
    </div>
  )
}
