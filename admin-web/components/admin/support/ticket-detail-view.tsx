"use client";

import * as React from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { format, formatDistanceToNow } from "date-fns";
import {
  IconArrowLeft,
  IconCheck,
  IconLock,
  IconUserPlus,
} from "@tabler/icons-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Textarea } from "@/components/ui/textarea";
import { TicketReplyForm } from "./ticket-reply-form";
import { TicketAssignDialog } from "./ticket-assign-dialog";
import { resolveTicket } from "@/lib/admin/actions/support";
import { toast } from "sonner";

function getStatusVariant(status: string) {
  switch (status) {
    case "open":
    case "reopened":
      return "secondary" as const;
    case "in_progress":
      return "default" as const;
    case "waiting_response":
      return "outline" as const;
    case "resolved":
    case "closed":
      return "default" as const;
    default:
      return "outline" as const;
  }
}

function getStatusClassName(status: string) {
  switch (status) {
    case "resolved":
    case "closed":
      return "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400";
    case "in_progress":
      return "bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400";
    case "waiting_response":
      return "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-400";
    default:
      return "";
  }
}

function getPriorityVariant(priority: string) {
  switch (priority) {
    case "urgent":
      return "destructive" as const;
    case "high":
      return "secondary" as const;
    default:
      return "outline" as const;
  }
}

interface TicketMessage {
  _id: string;
  message: string;
  senderRole: string;
  senderName: string | null;
  isInternal?: boolean;
  createdAt: string;
}

function MessageBubble({ message }: { message: TicketMessage }) {
  const isAdmin = message.senderRole === "admin";
  const senderName = message.senderName || "Unknown";
  const initials = senderName
    .split(" ")
    .map((n: string) => n[0])
    .join("")
    .toUpperCase();

  return (
    <div
      className={`flex gap-3 ${isAdmin ? "flex-row-reverse" : ""} ${
        message.isInternal ? "opacity-70" : ""
      }`}
    >
      <Avatar className="size-8 shrink-0">
        <AvatarFallback className="text-xs">{initials}</AvatarFallback>
      </Avatar>
      <div
        className={`max-w-[70%] space-y-1 ${isAdmin ? "items-end text-right" : ""}`}
      >
        <div className="flex items-center gap-2">
          <span className="text-sm font-medium">
            {senderName}
          </span>
          {message.isInternal && (
            <Badge variant="outline" className="text-xs gap-1">
              <IconLock className="size-3" />
              Internal
            </Badge>
          )}
        </div>
        <div
          className={`rounded-lg p-3 text-sm ${
            isAdmin
              ? "bg-primary/10 border border-primary/20"
              : "bg-muted border"
          } ${message.isInternal ? "border-dashed border-yellow-500/50 bg-yellow-50/50 dark:bg-yellow-950/20" : ""}`}
        >
          <p className="whitespace-pre-wrap text-left">{message.message}</p>
        </div>
        <p className="text-xs text-muted-foreground">
          {formatDistanceToNow(new Date(message.createdAt), {
            addSuffix: true,
          })}
        </p>
      </div>
    </div>
  );
}

interface TicketDetail {
  _id?: string;
  id?: string;
  subject: string;
  description: string | null;
  status: string;
  priority: string;
  createdAt: string;
  resolvedAt?: string | null;
  resolutionNotes?: string | null;
  assignedTo: string | null;
  raisedById?: string | null;
  userName?: string | null;
}

interface AdminListItem {
  id: string;
  role: string | null;
  full_name: string | null;
  email: string | null;
  avatar_url?: string | null;
}

export function TicketDetailView({
  ticket,
  messages,
  admins,
}: {
  ticket: TicketDetail;
  messages: TicketMessage[];
  admins: AdminListItem[];
}) {
  const router = useRouter();
  const ticketId = ticket._id || ticket.id || "";
  const [resolving, setResolving] = React.useState(false);
  const [resolutionNotes, setResolutionNotes] = React.useState("");
  const [showResolve, setShowResolve] = React.useState(false);

  const requesterName = ticket.userName || "User";
  const isResolved = ticket.status === "resolved" || ticket.status === "closed";

  async function handleResolve() {
    setResolving(true);
    try {
      await resolveTicket(ticketId, resolutionNotes);
      toast.success("Ticket resolved");
      setShowResolve(false);
      router.refresh();
    } catch (err) {
      toast.error(
        err instanceof Error ? err.message : "Failed to resolve ticket"
      );
    } finally {
      setResolving(false);
    }
  }

  return (
    <>
      <div className="flex items-center gap-4 px-4 lg:px-6">
        <Button variant="ghost" size="icon" asChild>
          <Link href="/support">
            <IconArrowLeft className="size-4" />
          </Link>
        </Button>
        <div className="flex-1">
          <div className="flex items-center gap-2">
            <h1 className="text-2xl font-bold tracking-tight">
              {ticket.subject}
            </h1>
          </div>
          <div className="flex items-center gap-2 mt-1">
            <span className="text-sm text-muted-foreground font-mono">
              {ticketId.slice(0, 8)}
            </span>
            <Badge
              variant={getStatusVariant(ticket.status)}
              className={getStatusClassName(ticket.status)}
            >
              {ticket.status?.replace(/_/g, " ")}
            </Badge>
            <Badge variant={getPriorityVariant(ticket.priority)}>
              {ticket.priority}
            </Badge>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <TicketAssignDialog
            ticketId={ticketId}
            admins={admins}
            currentAssignee={ticket.assignedTo ?? undefined}
          >
            <Button variant="outline" size="sm">
              <IconUserPlus className="size-4 mr-1" />
              {ticket.assignedTo ? "Reassign" : "Assign"}
            </Button>
          </TicketAssignDialog>
          {!isResolved && (
            <Button
              variant="default"
              size="sm"
              onClick={() => setShowResolve(!showResolve)}
            >
              <IconCheck className="size-4 mr-1" />
              Resolve
            </Button>
          )}
        </div>
      </div>

      <div className="grid gap-4 px-4 lg:px-6 lg:grid-cols-3">
        <div className="lg:col-span-2 space-y-4">
          {showResolve && (
            <Card>
              <CardHeader>
                <CardTitle>Resolve Ticket</CardTitle>
                <CardDescription>
                  Add resolution notes and close the ticket
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-3">
                <Textarea
                  placeholder="Resolution notes..."
                  value={resolutionNotes}
                  onChange={(e) => setResolutionNotes(e.target.value)}
                  rows={3}
                />
                <div className="flex gap-2">
                  <Button onClick={handleResolve} disabled={resolving}>
                    {resolving ? "Resolving..." : "Mark as Resolved"}
                  </Button>
                  <Button
                    variant="outline"
                    onClick={() => setShowResolve(false)}
                  >
                    Cancel
                  </Button>
                </div>
              </CardContent>
            </Card>
          )}

          <Card>
            <CardHeader>
              <CardTitle>Conversation</CardTitle>
              <CardDescription>
                {messages.length} message{messages.length !== 1 ? "s" : ""}
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              {ticket.description && (
                <>
                  <div className="flex gap-3">
                    <Avatar className="size-8 shrink-0">
                      <AvatarFallback className="text-xs">
                        {requesterName
                          .split(" ")
                          .map((n: string) => n[0])
                          .join("")
                          .toUpperCase()}
                      </AvatarFallback>
                    </Avatar>
                    <div className="space-y-1">
                      <span className="text-sm font-medium">
                        {requesterName}
                      </span>
                      <div className="rounded-lg bg-muted border p-3 text-sm">
                        <p className="whitespace-pre-wrap">
                          {ticket.description}
                        </p>
                      </div>
                      <p className="text-xs text-muted-foreground">
                        {formatDistanceToNow(new Date(ticket.createdAt), {
                          addSuffix: true,
                        })}
                      </p>
                    </div>
                  </div>
                  {messages.length > 0 && <Separator />}
                </>
              )}

              {messages.map((msg) => (
                <MessageBubble key={msg._id} message={msg} />
              ))}

              {!isResolved && (
                <>
                  <Separator />
                  <TicketReplyForm ticketId={ticketId} />
                </>
              )}
            </CardContent>
          </Card>
        </div>

        <div className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Ticket Info</CardTitle>
            </CardHeader>
            <CardContent className="space-y-3 text-sm">
              <div className="flex justify-between">
                <span className="text-muted-foreground">Status</span>
                <Badge
                  variant={getStatusVariant(ticket.status)}
                  className={getStatusClassName(ticket.status)}
                >
                  {ticket.status?.replace(/_/g, " ")}
                </Badge>
              </div>
              <Separator />
              <div className="flex justify-between">
                <span className="text-muted-foreground">Priority</span>
                <Badge variant={getPriorityVariant(ticket.priority)}>
                  {ticket.priority}
                </Badge>
              </div>
              <Separator />
              <div className="flex justify-between">
                <span className="text-muted-foreground">Requester</span>
                <span className="font-medium">
                  {requesterName}
                </span>
              </div>
              <Separator />
              <div className="flex justify-between">
                <span className="text-muted-foreground">Assigned To</span>
                <span className="font-medium">
                  {ticket.assignedTo
                    ? admins.find((a) => a.id === ticket.assignedTo)?.full_name ||
                      ticket.assignedTo.slice(0, 8) + "..."
                    : "Unassigned"}
                </span>
              </div>
              <Separator />
              <div className="flex justify-between">
                <span className="text-muted-foreground">Created</span>
                <span>
                  {format(new Date(ticket.createdAt), "dd MMM yyyy, HH:mm")}
                </span>
              </div>
              {ticket.resolvedAt && (
                <>
                  <Separator />
                  <div className="flex justify-between">
                    <span className="text-muted-foreground">Resolved</span>
                    <span>
                      {format(
                        new Date(ticket.resolvedAt),
                        "dd MMM yyyy, HH:mm"
                      )}
                    </span>
                  </div>
                </>
              )}
            </CardContent>
          </Card>

          {ticket.resolutionNotes && (
            <Card>
              <CardHeader>
                <CardTitle>Resolution Notes</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-sm whitespace-pre-wrap">
                  {ticket.resolutionNotes}
                </p>
              </CardContent>
            </Card>
          )}
        </div>
      </div>
    </>
  );
}
