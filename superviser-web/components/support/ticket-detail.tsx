/**
 * @fileoverview Support ticket detail view with conversation thread.
 * Redesigned to match dashboard design system.
 * @module components/support/ticket-detail
 */

"use client"

import { useState, useRef, useEffect } from "react"
import { motion } from "framer-motion"
import {
  ArrowLeft,
  Send,
  Paperclip,
  Clock,
  CheckCircle2,
  RefreshCw,
  User,
  Headphones,
} from "lucide-react"

import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Textarea } from "@/components/ui/textarea"
import { ScrollArea } from "@/components/ui/scroll-area"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog"
import { toast } from "sonner"
import { cn } from "@/lib/utils"
import { useTicket } from "@/hooks/use-support"
import { SupportTicket } from "@/types/database"
import {
  TicketStatus,
  TicketPriority,
  TicketCategory,
  TICKET_STATUS_CONFIG,
  TICKET_PRIORITY_CONFIG,
  TICKET_CATEGORY_CONFIG,
} from "./types"


interface TicketDetailProps {
  ticket: SupportTicket
  onBack: () => void
  onStatusChange?: (ticketId: string, status: string) => void
}

export function TicketDetail({ ticket, onBack, onStatusChange }: TicketDetailProps) {
  const {
    messages,
    isLoading: isLoadingMessages,
    sendMessage,
    updateStatus,
  } = useTicket(ticket.id)
  const [newMessage, setNewMessage] = useState("")
  const [isSending, setIsSending] = useState(false)
  const scrollRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight
    }
  }, [messages])

  const handleSendMessage = async () => {
    if (!newMessage.trim()) return

    setIsSending(true)
    try {
      await sendMessage(newMessage)
      setNewMessage("")
      toast.success("Message sent")
    } catch {
      toast.error("Failed to send message")
    } finally {
      setIsSending(false)
    }
  }

  const handleReopen = async () => {
    try {
      await updateStatus("reopened" as TicketStatus)
      onStatusChange?.(ticket.id, "reopened")
      toast.success("Ticket reopened")
    } catch {
      toast.error("Failed to reopen ticket")
    }
  }

  const handleClose = async () => {
    try {
      await updateStatus("resolved" as TicketStatus)
      onStatusChange?.(ticket.id, "resolved")
      toast.success("Ticket resolved")
    } catch {
      toast.error("Failed to resolve ticket")
    }
  }

  const formatDateTime = (dateString: string) => {
    return new Date(dateString).toLocaleString("en-IN", {
      day: "numeric",
      month: "short",
      hour: "2-digit",
      minute: "2-digit",
    })
  }

  const canReply = ticket.status !== "closed" && ticket.status !== "resolved"

  return (
    <div className="space-y-6">
      {/* Back Button */}
      <button
        onClick={onBack}
        className="group flex items-center gap-2 text-gray-500 hover:text-[#1C1C1C] transition-colors"
      >
        <div className="w-8 h-8 rounded-lg bg-gray-100 group-hover:bg-orange-50 flex items-center justify-center transition-colors">
          <ArrowLeft className="h-4 w-4 group-hover:text-[#F97316] transition-colors" />
        </div>
        <span className="text-sm font-medium">Back to Tickets</span>
      </button>

      {/* Ticket Header */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3 }}
        className="rounded-2xl border border-gray-200 bg-white p-6"
      >
        <div className="flex flex-col lg:flex-row lg:items-start justify-between gap-4">
          <div className="space-y-3">
            <div className="flex items-center gap-2 flex-wrap">
              <span className="text-xs font-mono text-gray-400 bg-gray-50 px-2 py-1 rounded-md">
                {ticket.ticket_number}
              </span>
              {ticket.status && TICKET_STATUS_CONFIG[ticket.status as TicketStatus] && (
                <Badge className={cn("text-xs", TICKET_STATUS_CONFIG[ticket.status as TicketStatus].color)}>
                  {TICKET_STATUS_CONFIG[ticket.status as TicketStatus].label}
                </Badge>
              )}
              {ticket.priority && TICKET_PRIORITY_CONFIG[ticket.priority as TicketPriority] && (
                <Badge variant="outline" className={cn("text-xs", TICKET_PRIORITY_CONFIG[ticket.priority as TicketPriority].color)}>
                  {TICKET_PRIORITY_CONFIG[ticket.priority as TicketPriority].label}
                </Badge>
              )}
            </div>
            <h2 className="text-xl font-semibold text-[#1C1C1C]">{ticket.subject}</h2>
            <div className="flex items-center gap-4 text-xs text-gray-500">
              {ticket.category && TICKET_CATEGORY_CONFIG[ticket.category as TicketCategory] && (
                <span className="px-2 py-0.5 rounded-full bg-gray-100 text-gray-600">
                  {TICKET_CATEGORY_CONFIG[ticket.category as TicketCategory].label}
                </span>
              )}
              {ticket.project_id && (
                <span>Project: {ticket.project_id.slice(0, 8)}...</span>
              )}
              {ticket.created_at && (
                <span className="flex items-center gap-1">
                  <Clock className="h-3 w-3" />
                  Created {formatDateTime(ticket.created_at)}
                </span>
              )}
            </div>
          </div>

          <div className="flex items-center gap-2 shrink-0">
            {(ticket.status === "resolved" || ticket.status === "closed") && (
              <AlertDialog>
                <AlertDialogTrigger asChild>
                  <Button
                    variant="outline"
                    size="sm"
                    className="rounded-xl border-gray-200 text-gray-700 hover:border-orange-200 hover:text-[#F97316]"
                  >
                    <RefreshCw className="h-4 w-4 mr-2" />
                    Reopen
                  </Button>
                </AlertDialogTrigger>
                <AlertDialogContent>
                  <AlertDialogHeader>
                    <AlertDialogTitle>Reopen Ticket?</AlertDialogTitle>
                    <AlertDialogDescription>
                      This will reopen the ticket for further discussion.
                    </AlertDialogDescription>
                  </AlertDialogHeader>
                  <AlertDialogFooter>
                    <AlertDialogCancel>Cancel</AlertDialogCancel>
                    <AlertDialogAction
                      onClick={handleReopen}
                      className="bg-[#F97316] hover:bg-[#EA580C] text-white"
                    >
                      Reopen
                    </AlertDialogAction>
                  </AlertDialogFooter>
                </AlertDialogContent>
              </AlertDialog>
            )}
            {canReply && (
              <AlertDialog>
                <AlertDialogTrigger asChild>
                  <Button
                    variant="outline"
                    size="sm"
                    className="rounded-xl border-gray-200 text-gray-700 hover:border-green-200 hover:text-green-600"
                  >
                    <CheckCircle2 className="h-4 w-4 mr-2" />
                    Mark Resolved
                  </Button>
                </AlertDialogTrigger>
                <AlertDialogContent>
                  <AlertDialogHeader>
                    <AlertDialogTitle>Mark as Resolved?</AlertDialogTitle>
                    <AlertDialogDescription>
                      This will close the ticket. You can reopen it later if needed.
                    </AlertDialogDescription>
                  </AlertDialogHeader>
                  <AlertDialogFooter>
                    <AlertDialogCancel>Cancel</AlertDialogCancel>
                    <AlertDialogAction
                      onClick={handleClose}
                      className="bg-green-600 hover:bg-green-700 text-white"
                    >
                      Resolve
                    </AlertDialogAction>
                  </AlertDialogFooter>
                </AlertDialogContent>
              </AlertDialog>
            )}
          </div>
        </div>
      </motion.div>

      {/* Conversation */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.1, duration: 0.3 }}
        className="rounded-2xl border border-gray-200 bg-white overflow-hidden"
      >
        <div className="p-4 border-b border-gray-100">
          <h3 className="text-sm font-semibold text-[#1C1C1C]">Conversation</h3>
        </div>

        <ScrollArea className="h-[420px] p-5" ref={scrollRef}>
          <div className="space-y-5">
            {/* Initial Description */}
            <div className="flex gap-3">
              <Avatar className="h-8 w-8 shrink-0">
                <AvatarFallback className="bg-orange-100 text-[#F97316] text-xs">
                  <User className="h-4 w-4" />
                </AvatarFallback>
              </Avatar>
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 mb-1.5">
                  <span className="font-medium text-sm text-[#1C1C1C]">You</span>
                  <span className="text-[10px] text-gray-400">
                    {ticket.created_at ? formatDateTime(ticket.created_at) : ""}
                  </span>
                </div>
                <div className="p-3 bg-gray-50 rounded-xl rounded-tl-sm">
                  <p className="text-sm text-gray-700 whitespace-pre-wrap">{ticket.description}</p>
                </div>
              </div>
            </div>

            {/* Messages */}
            {messages.map((message) => {
              const isSupport = message.sender_type === "support"
              return (
                <div
                  key={message.id}
                  className={cn("flex gap-3", !isSupport && "flex-row-reverse")}
                >
                  <Avatar className="h-8 w-8 shrink-0">
                    <AvatarFallback
                      className={cn(
                        "text-xs",
                        isSupport
                          ? "bg-green-100 text-green-600"
                          : "bg-orange-100 text-[#F97316]"
                      )}
                    >
                      {isSupport ? <Headphones className="h-4 w-4" /> : <User className="h-4 w-4" />}
                    </AvatarFallback>
                  </Avatar>
                  <div className={cn("flex-1 max-w-[80%] min-w-0", !isSupport && "text-right")}>
                    <div className={cn("flex items-center gap-2 mb-1.5", !isSupport && "justify-end")}>
                      <span className="font-medium text-sm text-[#1C1C1C]">
                        {isSupport ? "Support" : "You"}
                      </span>
                      <span className="text-[10px] text-gray-400">
                        {message.created_at ? formatDateTime(message.created_at) : ""}
                      </span>
                    </div>
                    <div
                      className={cn(
                        "p-3 rounded-xl text-sm",
                        isSupport
                          ? "bg-green-50 rounded-tl-sm text-gray-700"
                          : "bg-gray-50 rounded-tr-sm text-gray-700"
                      )}
                    >
                      <p className="whitespace-pre-wrap">{message.message}</p>
                    </div>
                  </div>
                </div>
              )
            })}
          </div>
        </ScrollArea>

        {/* Reply Input */}
        <div className="border-t border-gray-100 p-4">
          {canReply ? (
            <div className="flex gap-3">
              <div className="flex-1">
                <Textarea
                  placeholder="Type your message..."
                  value={newMessage}
                  onChange={(e) => setNewMessage(e.target.value)}
                  className="min-h-[80px] resize-none rounded-xl border-gray-200 focus:border-orange-300 focus:ring-orange-200"
                  onKeyDown={(e) => {
                    if (e.key === "Enter" && (e.ctrlKey || e.metaKey)) {
                      handleSendMessage()
                    }
                  }}
                />
                <p className="text-[10px] text-gray-400 mt-1">Press Ctrl+Enter to send</p>
              </div>
              <div className="flex flex-col gap-2">
                <Button
                  variant="outline"
                  size="icon"
                  className="shrink-0 rounded-xl border-gray-200"
                  disabled
                >
                  <Paperclip className="h-4 w-4 text-gray-400" />
                </Button>
                <Button
                  size="icon"
                  className="shrink-0 rounded-xl bg-[#F97316] hover:bg-[#EA580C] text-white"
                  onClick={handleSendMessage}
                  disabled={!newMessage.trim() || isSending}
                >
                  <Send className="h-4 w-4" />
                </Button>
              </div>
            </div>
          ) : (
            <div className="text-center py-4">
              <CheckCircle2 className="h-8 w-8 mx-auto mb-2 text-green-500" />
              <p className="text-sm text-gray-600 font-medium">This ticket has been resolved.</p>
              <p className="text-xs text-gray-400 mt-1">
                Need more help? Click &quot;Reopen&quot; to continue the conversation.
              </p>
            </div>
          )}
        </div>
      </motion.div>
    </div>
  )
}
