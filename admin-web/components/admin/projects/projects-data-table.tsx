"use client";

import * as React from "react";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { format } from "date-fns";
import {
  IconChevronLeft,
  IconChevronRight,
  IconDotsVertical,
  IconSearch,
} from "@tabler/icons-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
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
import { ProjectStatusBadge } from "./project-status-badge";

interface ProjectListItem {
  id: string;
  title: string;
  status: string;
  service_type: string | null;
  price: number | string | null;
  deadline: string | null;
  created_at: string;
  user?: { full_name: string | null } | null;
  supervisor?: { full_name: string | null } | null;
  doer?: { full_name: string | null } | null;
}

interface ProjectsDataTableProps {
  data: ProjectListItem[];
  total: number;
  page: number;
  totalPages: number;
}

const PROJECT_STATUSES = [
  "draft", "submitted", "analyzing", "quoted", "payment_pending",
  "paid", "assigning", "assigned", "in_progress", "submitted_for_qc",
  "qc_in_progress", "qc_approved", "qc_rejected", "delivered",
  "revision_requested", "in_revision", "completed", "auto_approved",
  "cancelled", "refunded",
];

export function ProjectsDataTable({
  data,
  total,
  page,
  totalPages,
}: ProjectsDataTableProps) {
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
              placeholder="Search projects..."
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
            {PROJECT_STATUSES.map((s) => (
              <SelectItem key={s} value={s}>
                {s.replace(/_/g, " ")}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
        <div className="ml-auto text-sm text-muted-foreground">
          {total} project{total !== 1 ? "s" : ""}
        </div>
      </div>

      <div className="overflow-hidden rounded-lg border">
        <Table>
          <TableHeader className="bg-muted">
            <TableRow>
              <TableHead>Title</TableHead>
              <TableHead>User</TableHead>
              <TableHead>Supervisor</TableHead>
              <TableHead>Doer</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Service</TableHead>
              <TableHead className="text-right">Price</TableHead>
              <TableHead>Deadline</TableHead>
              <TableHead>Created</TableHead>
              <TableHead className="w-10" />
            </TableRow>
          </TableHeader>
          <TableBody>
            {data.length > 0 ? (
              data.map((project) => (
                <TableRow key={project.id}>
                  <TableCell className="max-w-[200px]">
                    <Link
                      href={`/projects/${project.id}`}
                      className="font-medium hover:underline truncate block"
                    >
                      {project.title}
                    </Link>
                  </TableCell>
                  <TableCell className="text-muted-foreground">
                    {project.user?.full_name || "-"}
                  </TableCell>
                  <TableCell className="text-muted-foreground">
                    {project.supervisor?.full_name || "-"}
                  </TableCell>
                  <TableCell className="text-muted-foreground">
                    {project.doer?.full_name || "-"}
                  </TableCell>
                  <TableCell>
                    <ProjectStatusBadge status={project.status} />
                  </TableCell>
                  <TableCell>
                    {project.service_type && (
                      <Badge variant="outline">{project.service_type}</Badge>
                    )}
                  </TableCell>
                  <TableCell className="text-right font-medium tabular-nums">
                    {project.price != null
                      ? new Intl.NumberFormat("en-IN", {
                          style: "currency",
                          currency: "INR",
                        }).format(Number(project.price))
                      : "-"}
                  </TableCell>
                  <TableCell className="text-muted-foreground">
                    {project.deadline
                      ? format(new Date(project.deadline), "dd MMM yyyy")
                      : "-"}
                  </TableCell>
                  <TableCell className="text-muted-foreground">
                    {format(new Date(project.created_at), "dd MMM yyyy")}
                  </TableCell>
                  <TableCell>
                    <DropdownMenu>
                      <DropdownMenuTrigger asChild>
                        <Button
                          variant="ghost"
                          size="icon"
                          className="size-8 text-muted-foreground"
                        >
                          <IconDotsVertical className="size-4" />
                        </Button>
                      </DropdownMenuTrigger>
                      <DropdownMenuContent align="end" className="w-40">
                        <DropdownMenuItem asChild>
                          <Link href={`/projects/${project.id}`}>
                            View Details
                          </Link>
                        </DropdownMenuItem>
                      </DropdownMenuContent>
                    </DropdownMenu>
                  </TableCell>
                </TableRow>
              ))
            ) : (
              <TableRow>
                <TableCell
                  colSpan={10}
                  className="h-24 text-center text-muted-foreground"
                >
                  No projects found.
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
