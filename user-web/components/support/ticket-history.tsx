"use client";

import { useState, useEffect } from "react";
import { Ticket, Clock, CheckCircle2, AlertCircle, XCircle, Loader2 } from "lucide-react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { formatDistanceToNow } from "date-fns";
import { getSupportTickets } from "@/lib/actions/data";

/**
 * Ticket status type
 */
type TicketStatus = "open" | "in_progress" | "resolved" | "closed";

/**
 * Support ticket interface matching Supabase schema
 */
interface SupportTicket {
  id: string;
  ticket_number: string;
  requester_id: string;
  assigned_to: string | null;
  subject: string;
  description: string;
  category: string | null;
  status: TicketStatus;
  priority: string;
  project_id: string | null;
  resolved_at: string | null;
  closed_at: string | null;
  created_at: string;
  updated_at: string;
}

/**
 * Returns status icon based on ticket status
 */
function getStatusIcon(status: TicketStatus) {
  switch (status) {
    case "open":
      return <AlertCircle className="h-4 w-4 text-blue-500" />;
    case "in_progress":
      return <Clock className="h-4 w-4 text-yellow-500" />;
    case "resolved":
      return <CheckCircle2 className="h-4 w-4 text-green-500" />;
    case "closed":
      return <XCircle className="h-4 w-4 text-gray-500" />;
    default:
      return <AlertCircle className="h-4 w-4 text-blue-500" />;
  }
}

/**
 * Returns badge variant based on ticket status
 */
function getStatusBadge(status: TicketStatus): "default" | "secondary" | "outline" {
  switch (status) {
    case "open":
      return "default";
    case "in_progress":
      return "secondary";
    case "resolved":
    case "closed":
      return "outline";
    default:
      return "outline";
  }
}

/**
 * Ticket history section showing past support tickets
 * Fetches tickets from Supabase
 */
export function TicketHistory() {
  const [tickets, setTickets] = useState<SupportTicket[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  // Fetch tickets on mount
  useEffect(() => {
    const fetchTicketsData = async () => {
      try {
        const data = await getSupportTickets();
        setTickets(data);
      } catch {
        // Silently handle fetch error - tickets will remain empty
      } finally {
        setIsLoading(false);
      }
    };
    fetchTicketsData();
  }, []);

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Ticket className="h-5 w-5" />
          Your Tickets
        </CardTitle>
        <CardDescription>View your support ticket history</CardDescription>
      </CardHeader>
      <CardContent>
        {isLoading ? (
          <div className="flex items-center justify-center py-8">
            <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
          </div>
        ) : tickets.length === 0 ? (
          <p className="text-center text-muted-foreground py-8">No tickets yet</p>
        ) : (
          <div className="space-y-4">
            {tickets.map((ticket) => (
              <div
                key={ticket.id}
                className="flex items-start justify-between gap-4 p-4 rounded-lg border"
              >
                <div className="flex items-start gap-3">
                  {getStatusIcon(ticket.status)}
                  <div>
                    <p className="font-medium">{ticket.subject}</p>
                    <p className="text-sm text-muted-foreground">
                      {ticket.category || "General"} • Updated{" "}
                      {formatDistanceToNow(new Date(ticket.updated_at), {
                        addSuffix: true,
                      })}
                    </p>
                    <p className="text-xs text-muted-foreground mt-1">
                      #{ticket.ticket_number}
                    </p>
                  </div>
                </div>
                <Badge
                  variant={getStatusBadge(ticket.status)}
                  className="capitalize"
                >
                  {ticket.status.replace("_", " ")}
                </Badge>
              </div>
            ))}
            {tickets.length >= 5 && (
              <Button variant="outline" className="w-full">
                View All Tickets
              </Button>
            )}
          </div>
        )}
      </CardContent>
    </Card>
  );
}
