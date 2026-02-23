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
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
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

interface MessageSender {
  full_name: string | null;
  avatar_url: string | null;
}

interface TicketMessage {
  id: string;
  message: string;
  sender_type: string;
  sender: MessageSender | null;
  is_internal: boolean;
  created_at: string;
}

function MessageBubble({ message }: { message: TicketMessage }) {
  const sender = message.sender;
  const isAdmin = message.sender_type === "admin";
  const initials = sender?.full_name
    ? sender.full_name
        .split(" ")
        .map((n: string) => n[0])
        .join("")
        .toUpperCase()
    : "?";

  return (
    <div
      className={`flex gap-3 ${isAdmin ? "flex-row-reverse" : ""} ${
        message.is_internal ? "opacity-70" : ""
      }`}
    >
      <Avatar className="size-8 shrink-0">
        <AvatarImage src={sender?.avatar_url ?? undefined} />
        <AvatarFallback className="text-xs">{initials}</AvatarFallback>
      </Avatar>
      <div
        className={`max-w-[70%] space-y-1 ${isAdmin ? "items-end text-right" : ""}`}
      >
        <div className="flex items-center gap-2">
          <span className="text-sm font-medium">
            {sender?.full_name || "Unknown"}
          </span>
          {message.is_internal && (
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
          } ${message.is_internal ? "border-dashed border-yellow-500/50 bg-yellow-50/50 dark:bg-yellow-950/20" : ""}`}
        >
          <p className="whitespace-pre-wrap text-left">{message.message}</p>
        </div>
        <p className="text-xs text-muted-foreground">
          {formatDistanceToNow(new Date(message.created_at), {
            addSuffix: true,
          })}
        </p>
      </div>
    </div>
  );
}

interface TicketProfile {
  full_name: string | null;
  email: string | null;
  avatar_url?: string | null;
}

interface TicketProject {
  id: string;
  title: string;
  status: string | null;
}

interface TicketDetail {
  id: string;
  subject: string;
  description: string | null;
  status: string;
  priority: string;
  ticket_number: string | null;
  created_at: string;
  first_response_at: string | null;
  resolved_at: string | null;
  satisfaction_rating: number | null;
  resolution_notes: string | null;
  assigned_to: string | null;
  assigned_admin: { profiles: TicketProfile | null } | null;
  requester: TicketProfile | null;
  project: TicketProject | null;
}

interface AdminListItem {
  id: string;
  role: string | null;
  profiles: TicketProfile | TicketProfile[] | null;
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
  const [resolving, setResolving] = React.useState(false);
  const [resolutionNotes, setResolutionNotes] = React.useState("");
  const [showResolve, setShowResolve] = React.useState(false);

  const assignedProfile = ticket.assigned_admin?.profiles;
  const requester = ticket.requester;
  const isResolved = ticket.status === "resolved" || ticket.status === "closed";

  async function handleResolve() {
    setResolving(true);
    try {
      await resolveTicket(ticket.id, resolutionNotes);
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
              {ticket.ticket_number || ticket.id.slice(0, 8)}
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
            ticketId={ticket.id}
            admins={admins}
            currentAssignee={ticket.assigned_to ?? undefined}
          >
            <Button variant="outline" size="sm">
              <IconUserPlus className="size-4 mr-1" />
              {assignedProfile ? "Reassign" : "Assign"}
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
                      <AvatarImage src={requester?.avatar_url ?? undefined} />
                      <AvatarFallback className="text-xs">
                        {requester?.full_name
                          ?.split(" ")
                          .map((n: string) => n[0])
                          .join("")
                          .toUpperCase() || "?"}
                      </AvatarFallback>
                    </Avatar>
                    <div className="space-y-1">
                      <span className="text-sm font-medium">
                        {requester?.full_name || "User"}
                      </span>
                      <div className="rounded-lg bg-muted border p-3 text-sm">
                        <p className="whitespace-pre-wrap">
                          {ticket.description}
                        </p>
                      </div>
                      <p className="text-xs text-muted-foreground">
                        {formatDistanceToNow(new Date(ticket.created_at), {
                          addSuffix: true,
                        })}
                      </p>
                    </div>
                  </div>
                  {messages.length > 0 && <Separator />}
                </>
              )}

              {messages.map((msg) => (
                <MessageBubble key={msg.id} message={msg} />
              ))}

              {!isResolved && (
                <>
                  <Separator />
                  <TicketReplyForm ticketId={ticket.id} />
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
                  {requester?.full_name || "-"}
                </span>
              </div>
              <Separator />
              <div className="flex justify-between">
                <span className="text-muted-foreground">Assigned To</span>
                <span className="font-medium">
                  {assignedProfile?.full_name || "Unassigned"}
                </span>
              </div>
              <Separator />
              <div className="flex justify-between">
                <span className="text-muted-foreground">Created</span>
                <span>
                  {format(new Date(ticket.created_at), "dd MMM yyyy, HH:mm")}
                </span>
              </div>
              {ticket.first_response_at && (
                <>
                  <Separator />
                  <div className="flex justify-between">
                    <span className="text-muted-foreground">First Response</span>
                    <span>
                      {format(
                        new Date(ticket.first_response_at),
                        "dd MMM yyyy, HH:mm"
                      )}
                    </span>
                  </div>
                </>
              )}
              {ticket.resolved_at && (
                <>
                  <Separator />
                  <div className="flex justify-between">
                    <span className="text-muted-foreground">Resolved</span>
                    <span>
                      {format(
                        new Date(ticket.resolved_at),
                        "dd MMM yyyy, HH:mm"
                      )}
                    </span>
                  </div>
                </>
              )}
              {ticket.satisfaction_rating && (
                <>
                  <Separator />
                  <div className="flex justify-between">
                    <span className="text-muted-foreground">Satisfaction</span>
                    <span>{ticket.satisfaction_rating}/5</span>
                  </div>
                </>
              )}
            </CardContent>
          </Card>

          {ticket.project && (
            <Card>
              <CardHeader>
                <CardTitle>Related Project</CardTitle>
              </CardHeader>
              <CardContent className="text-sm">
                <Link
                  href={`/projects/${ticket.project.id}`}
                  className="font-medium hover:underline"
                >
                  {ticket.project.title}
                </Link>
                <p className="text-muted-foreground mt-1">
                  Status: {ticket.project.status?.replace(/_/g, " ")}
                </p>
              </CardContent>
            </Card>
          )}

          {ticket.resolution_notes && (
            <Card>
              <CardHeader>
                <CardTitle>Resolution Notes</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-sm whitespace-pre-wrap">
                  {ticket.resolution_notes}
                </p>
              </CardContent>
            </Card>
          )}
        </div>
      </div>
    </>
  );
}
