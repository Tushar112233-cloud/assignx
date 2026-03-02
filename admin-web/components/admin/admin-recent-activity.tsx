"use client";

import { Badge } from "@/components/ui/badge";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";

interface SupportTicket {
  id: string;
  ticket_number: string;
  subject: string;
  status: string;
  priority: string;
  created_at: string;
  profiles?: { full_name: string } | null;
}

function statusVariant(
  status: string
): "default" | "secondary" | "destructive" | "outline" {
  switch (status) {
    case "open":
      return "default";
    case "in_progress":
      return "secondary";
    case "resolved":
    case "closed":
      return "outline";
    default:
      return "secondary";
  }
}

function priorityVariant(
  priority: string
): "default" | "secondary" | "destructive" | "outline" {
  switch (priority) {
    case "urgent":
    case "high":
      return "destructive";
    case "medium":
      return "secondary";
    case "low":
      return "outline";
    default:
      return "secondary";
  }
}

export function AdminRecentActivity({
  tickets,
}: {
  tickets: SupportTicket[];
}) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Recent Support Tickets</CardTitle>
        <CardDescription>Latest tickets requiring attention</CardDescription>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Ticket</TableHead>
              <TableHead>Subject</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Priority</TableHead>
              <TableHead>Requester</TableHead>
              <TableHead>Created</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {tickets.length === 0 ? (
              <TableRow>
                <TableCell colSpan={6} className="text-center text-muted-foreground">
                  No recent tickets
                </TableCell>
              </TableRow>
            ) : (
              tickets.map((ticket: any) => (
                <TableRow key={ticket.id || ticket._id}>
                  <TableCell className="font-medium">
                    {ticket.ticket_number || ticket.ticketNumber || "-"}
                  </TableCell>
                  <TableCell className="max-w-[200px] truncate">
                    {ticket.subject}
                  </TableCell>
                  <TableCell>
                    <Badge variant={statusVariant(ticket.status)}>
                      {(ticket.status || "").replace("_", " ")}
                    </Badge>
                  </TableCell>
                  <TableCell>
                    <Badge variant={priorityVariant(ticket.priority)}>
                      {ticket.priority}
                    </Badge>
                  </TableCell>
                  <TableCell>
                    {ticket.userName || ticket.fullName || ticket.profiles?.full_name || ticket.user?.fullName || "Unknown"}
                  </TableCell>
                  <TableCell className="text-muted-foreground">
                    {new Date(ticket.createdAt || ticket.created_at).toLocaleDateString("en-US", {
                      month: "short",
                      day: "numeric",
                    })}
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
}
