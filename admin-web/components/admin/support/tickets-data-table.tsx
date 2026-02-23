"use client";

import * as React from "react";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { format } from "date-fns";
import {
  IconChevronLeft,
  IconChevronRight,
  IconSearch,
} from "@tabler/icons-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";

const TICKET_STATUSES = [
  "open", "in_progress", "waiting_response", "resolved", "closed", "reopened",
];

const TICKET_PRIORITIES = ["low", "medium", "high", "urgent"];

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
      return "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400 border-green-200 dark:border-green-800";
    case "in_progress":
      return "bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400 border-blue-200 dark:border-blue-800";
    case "waiting_response":
      return "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-400 border-yellow-200 dark:border-yellow-800";
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
    case "medium":
      return "outline" as const;
    case "low":
      return "outline" as const;
    default:
      return "outline" as const;
  }
}

function getPriorityClassName(priority: string) {
  switch (priority) {
    case "urgent":
      return "";
    case "high":
      return "bg-orange-100 text-orange-800 dark:bg-orange-900/30 dark:text-orange-400 border-orange-200 dark:border-orange-800";
    default:
      return "";
  }
}

interface TicketListItem {
  id: string;
  ticket_number: string | null;
  subject: string;
  status: string;
  priority: string;
  created_at: string;
  requester: { full_name: string | null } | null;
  assigned_admin: {
    profiles: { full_name: string | null } | null;
  } | null;
}

interface TicketsDataTableProps {
  data: TicketListItem[];
  total: number;
  page: number;
  totalPages: number;
}

export function TicketsDataTable({
  data,
  total,
  page,
  totalPages,
}: TicketsDataTableProps) {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [search, setSearch] = React.useState(searchParams.get("search") || "");

  function updateParams(key: string, value: string) {
    const params = new URLSearchParams(searchParams.toString());
    if (value) {
      params.set(key, value);
    } else {
      params.delete(key);
    }
    if (key !== "page") params.set("page", "1");
    router.push(`?${params.toString()}`);
  }

  function handleSearch(e: React.FormEvent) {
    e.preventDefault();
    updateParams("search", search);
  }

  return (
    <div className="flex flex-col gap-4 px-4 lg:px-6">
      <div className="flex flex-wrap items-center gap-2">
        <form onSubmit={handleSearch} className="flex items-center gap-2">
          <div className="relative">
            <IconSearch className="absolute left-2.5 top-2.5 size-4 text-muted-foreground" />
            <Input
              placeholder="Search tickets..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="pl-8 w-64"
            />
          </div>
        </form>
        <Select
          value={searchParams.get("status") || "all"}
          onValueChange={(v) => updateParams("status", v === "all" ? "" : v)}
        >
          <SelectTrigger className="w-44" size="sm">
            <SelectValue placeholder="Filter by status" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Statuses</SelectItem>
            {TICKET_STATUSES.map((s) => (
              <SelectItem key={s} value={s}>
                {s.replace(/_/g, " ")}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
        <Select
          value={searchParams.get("priority") || "all"}
          onValueChange={(v) => updateParams("priority", v === "all" ? "" : v)}
        >
          <SelectTrigger className="w-36" size="sm">
            <SelectValue placeholder="Priority" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Priorities</SelectItem>
            {TICKET_PRIORITIES.map((p) => (
              <SelectItem key={p} value={p}>
                {p}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
        <div className="ml-auto text-sm text-muted-foreground">
          {total} ticket{total !== 1 ? "s" : ""}
        </div>
      </div>

      <div className="overflow-hidden rounded-lg border">
        <Table>
          <TableHeader className="bg-muted">
            <TableRow>
              <TableHead>Ticket #</TableHead>
              <TableHead>Subject</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Priority</TableHead>
              <TableHead>Requester</TableHead>
              <TableHead>Assigned To</TableHead>
              <TableHead>Created</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {data.length > 0 ? (
              data.map((ticket) => {
                const assignedProfile = ticket.assigned_admin?.profiles;
                return (
                  <TableRow key={ticket.id}>
                    <TableCell className="font-mono text-sm">
                      <Link
                        href={`/support/${ticket.id}`}
                        className="font-medium hover:underline"
                      >
                        {ticket.ticket_number || ticket.id.slice(0, 8)}
                      </Link>
                    </TableCell>
                    <TableCell className="max-w-[250px]">
                      <Link
                        href={`/support/${ticket.id}`}
                        className="hover:underline truncate block"
                      >
                        {ticket.subject}
                      </Link>
                    </TableCell>
                    <TableCell>
                      <Badge
                        variant={getStatusVariant(ticket.status)}
                        className={getStatusClassName(ticket.status)}
                      >
                        {ticket.status?.replace(/_/g, " ")}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <Badge
                        variant={getPriorityVariant(ticket.priority)}
                        className={getPriorityClassName(ticket.priority)}
                      >
                        {ticket.priority}
                      </Badge>
                    </TableCell>
                    <TableCell className="text-muted-foreground">
                      {ticket.requester?.full_name || "-"}
                    </TableCell>
                    <TableCell className="text-muted-foreground">
                      {assignedProfile?.full_name || "Unassigned"}
                    </TableCell>
                    <TableCell className="text-muted-foreground">
                      {format(new Date(ticket.created_at), "dd MMM yyyy")}
                    </TableCell>
                  </TableRow>
                );
              })
            ) : (
              <TableRow>
                <TableCell
                  colSpan={7}
                  className="h-24 text-center text-muted-foreground"
                >
                  No tickets found.
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>

      {totalPages > 1 && (
        <div className="flex items-center justify-between">
          <p className="text-sm text-muted-foreground">
            Page {page} of {totalPages}
          </p>
          <div className="flex items-center gap-2">
            <Button
              variant="outline"
              size="icon"
              className="size-8"
              disabled={page <= 1}
              onClick={() => updateParams("page", String(page - 1))}
            >
              <IconChevronLeft className="size-4" />
            </Button>
            <Button
              variant="outline"
              size="icon"
              className="size-8"
              disabled={page >= totalPages}
              onClick={() => updateParams("page", String(page + 1))}
            >
              <IconChevronRight className="size-4" />
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}
