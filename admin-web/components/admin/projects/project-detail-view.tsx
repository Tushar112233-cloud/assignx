"use client";

import * as React from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { format } from "date-fns";
import {
  IconArrowLeft,
  IconDownload,
  IconFile,
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
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { ProjectStatusBadge } from "./project-status-badge";
import { ProjectTimeline } from "./project-timeline";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { updateProjectStatus } from "@/lib/admin/actions/projects";
import { toast } from "sonner";

interface PersonInfo {
  full_name: string | null;
  email: string | null;
  avatar_url: string | null;
}

function PersonCard({ label, person }: { label: string; person: PersonInfo | null }) {
  if (!person) {
    return (
      <Card>
        <CardHeader className="pb-3">
          <CardDescription>{label}</CardDescription>
          <CardTitle className="text-sm">Not assigned</CardTitle>
        </CardHeader>
      </Card>
    );
  }

  const initials = person.full_name
    ? person.full_name
        .split(" ")
        .map((n: string) => n[0])
        .join("")
        .toUpperCase()
    : "?";

  return (
    <Card>
      <CardHeader className="pb-3">
        <CardDescription>{label}</CardDescription>
      </CardHeader>
      <CardContent className="flex items-center gap-3">
        <Avatar className="size-9">
          <AvatarImage src={person.avatar_url ?? undefined} />
          <AvatarFallback>{initials}</AvatarFallback>
        </Avatar>
        <div>
          <p className="text-sm font-medium">{person.full_name}</p>
          <p className="text-xs text-muted-foreground">{person.email}</p>
        </div>
      </CardContent>
    </Card>
  );
}

const PROJECT_STATUSES = [
  "draft", "submitted", "analyzing", "quoted", "payment_pending",
  "paid", "assigning", "assigned", "in_progress", "submitted_for_qc",
  "qc_in_progress", "qc_approved", "qc_rejected", "delivered",
  "revision_requested", "in_revision", "completed", "auto_approved",
  "cancelled", "refunded",
];

interface ProjectDetail {
  id: string;
  title: string;
  description: string | null;
  status: string;
  service_type: string | null;
  subject: string | null;
  price: number | string | null;
  deadline: string | null;
  created_at: string;
  updated_at: string | null;
  user: PersonInfo | null;
  supervisor: PersonInfo | null;
  doer: PersonInfo | null;
}

interface ProjectStatusHistoryEntry {
  id: string;
  old_status: string;
  new_status: string;
  reason?: string;
  created_at: string;
  changed_by_profile?: { full_name: string } | null;
}

interface ProjectFile {
  id: string;
  file_name: string | null;
  name: string | null;
  file_url: string | null;
  created_at: string;
}

interface ProjectPayment {
  id: string;
  type: string | null;
  amount: number | string;
  status: string;
  description: string | null;
  created_at: string;
}

export function ProjectDetailView({
  project,
  statusHistory,
  files,
  payments,
}: {
  project: ProjectDetail;
  statusHistory: ProjectStatusHistoryEntry[];
  files: ProjectFile[];
  payments: ProjectPayment[];
}) {
  const router = useRouter();
  const [newStatus, setNewStatus] = React.useState("");
  const [statusReason, setStatusReason] = React.useState("");
  const [updating, setUpdating] = React.useState(false);

  async function handleStatusUpdate() {
    if (!newStatus || newStatus === project.status) return;
    setUpdating(true);
    try {
      await updateProjectStatus(project.id, newStatus, statusReason);
      toast.success("Project status updated");
      router.refresh();
      setNewStatus("");
      setStatusReason("");
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to update status");
    } finally {
      setUpdating(false);
    }
  }

  return (
    <>
      <div className="flex items-center gap-4 px-4 lg:px-6">
        <Button variant="ghost" size="icon" asChild>
          <Link href="/projects">
            <IconArrowLeft className="size-4" />
          </Link>
        </Button>
        <div className="flex-1">
          <h1 className="text-2xl font-bold tracking-tight">
            {project.title}
          </h1>
          <div className="flex items-center gap-2 mt-1">
            <ProjectStatusBadge status={project.status} />
            {project.service_type && (
              <Badge variant="outline">{project.service_type}</Badge>
            )}
          </div>
        </div>
      </div>

      <Tabs defaultValue="overview" className="px-4 lg:px-6">
        <TabsList>
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="timeline">Timeline</TabsTrigger>
          <TabsTrigger value="files">
            Files ({files.length})
          </TabsTrigger>
          <TabsTrigger value="payments">
            Payments ({payments.length})
          </TabsTrigger>
        </TabsList>

        <TabsContent value="overview" className="space-y-4 mt-4">
          <div className="grid gap-4 md:grid-cols-2">
            <Card>
              <CardHeader>
                <CardTitle>Project Details</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                {project.description && (
                  <div>
                    <p className="text-sm font-medium text-muted-foreground">
                      Description
                    </p>
                    <p className="text-sm mt-1">{project.description}</p>
                  </div>
                )}
                <Separator />
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <p className="text-sm font-medium text-muted-foreground">
                      Subject
                    </p>
                    <p className="text-sm mt-1">
                      {project.subject || "-"}
                    </p>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-muted-foreground">
                      Service Type
                    </p>
                    <p className="text-sm mt-1">
                      {project.service_type || "-"}
                    </p>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-muted-foreground">
                      Price
                    </p>
                    <p className="text-sm mt-1 font-medium tabular-nums">
                      {project.price != null
                        ? new Intl.NumberFormat("en-IN", {
                            style: "currency",
                            currency: "INR",
                          }).format(Number(project.price))
                        : "-"}
                    </p>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-muted-foreground">
                      Deadline
                    </p>
                    <p className="text-sm mt-1">
                      {project.deadline
                        ? format(new Date(project.deadline), "dd MMM yyyy")
                        : "-"}
                    </p>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-muted-foreground">
                      Created
                    </p>
                    <p className="text-sm mt-1">
                      {format(new Date(project.created_at), "dd MMM yyyy, HH:mm")}
                    </p>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-muted-foreground">
                      Updated
                    </p>
                    <p className="text-sm mt-1">
                      {project.updated_at
                        ? format(new Date(project.updated_at), "dd MMM yyyy, HH:mm")
                        : "-"}
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <div className="space-y-4">
              <Card>
                <CardHeader>
                  <CardTitle>Update Status</CardTitle>
                  <CardDescription>
                    Change the project status
                  </CardDescription>
                </CardHeader>
                <CardContent className="space-y-3">
                  <Select value={newStatus} onValueChange={setNewStatus}>
                    <SelectTrigger>
                      <SelectValue placeholder="Select new status" />
                    </SelectTrigger>
                    <SelectContent>
                      {PROJECT_STATUSES.filter(
                        (s) => s !== project.status
                      ).map((s) => (
                        <SelectItem key={s} value={s}>
                          {s.replace(/_/g, " ")}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                  <Textarea
                    placeholder="Reason (optional)"
                    value={statusReason}
                    onChange={(e) => setStatusReason(e.target.value)}
                    rows={2}
                  />
                  <Button
                    onClick={handleStatusUpdate}
                    disabled={!newStatus || updating}
                    className="w-full"
                  >
                    {updating ? "Updating..." : "Update Status"}
                  </Button>
                </CardContent>
              </Card>
            </div>
          </div>

          <div className="grid gap-4 md:grid-cols-3">
            <PersonCard label="User" person={project.user} />
            <PersonCard label="Supervisor" person={project.supervisor} />
            <PersonCard label="Doer" person={project.doer} />
          </div>
        </TabsContent>

        <TabsContent value="timeline" className="mt-4">
          <Card>
            <CardHeader>
              <CardTitle>Status History</CardTitle>
              <CardDescription>
                Timeline of status changes for this project
              </CardDescription>
            </CardHeader>
            <CardContent>
              <ProjectTimeline history={statusHistory} />
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="files" className="mt-4">
          <Card>
            <CardHeader>
              <CardTitle>Project Files</CardTitle>
              <CardDescription>
                Files uploaded for this project
              </CardDescription>
            </CardHeader>
            <CardContent>
              {files.length > 0 ? (
                <div className="space-y-2">
                  {files.map((file) => (
                    <div
                      key={file.id}
                      className="flex items-center justify-between rounded-lg border p-3"
                    >
                      <div className="flex items-center gap-3">
                        <IconFile className="size-5 text-muted-foreground" />
                        <div>
                          <p className="text-sm font-medium">
                            {file.file_name || file.name || "Untitled"}
                          </p>
                          <p className="text-xs text-muted-foreground">
                            {format(
                              new Date(file.created_at),
                              "dd MMM yyyy, HH:mm"
                            )}
                          </p>
                        </div>
                      </div>
                      {file.file_url && (
                        <Button variant="ghost" size="icon" asChild>
                          <a
                            href={file.file_url}
                            target="_blank"
                            rel="noopener noreferrer"
                          >
                            <IconDownload className="size-4" />
                          </a>
                        </Button>
                      )}
                    </div>
                  ))}
                </div>
              ) : (
                <p className="text-sm text-muted-foreground py-8 text-center">
                  No files uploaded.
                </p>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="payments" className="mt-4">
          <Card>
            <CardHeader>
              <CardTitle>Payment History</CardTitle>
              <CardDescription>
                Transactions related to this project
              </CardDescription>
            </CardHeader>
            <CardContent>
              {payments.length > 0 ? (
                <div className="overflow-hidden rounded-lg border">
                  <Table>
                    <TableHeader className="bg-muted">
                      <TableRow>
                        <TableHead>Type</TableHead>
                        <TableHead>Amount</TableHead>
                        <TableHead>Status</TableHead>
                        <TableHead>Description</TableHead>
                        <TableHead>Date</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {payments.map((txn) => (
                        <TableRow key={txn.id}>
                          <TableCell>
                            <Badge variant="outline">
                              {txn.type?.replace(/_/g, " ")}
                            </Badge>
                          </TableCell>
                          <TableCell className="font-medium tabular-nums">
                            {new Intl.NumberFormat("en-IN", {
                              style: "currency",
                              currency: "INR",
                            }).format(Number(txn.amount))}
                          </TableCell>
                          <TableCell>
                            <Badge
                              variant={
                                txn.status === "completed"
                                  ? "default"
                                  : txn.status === "failed"
                                    ? "destructive"
                                    : "secondary"
                              }
                            >
                              {txn.status}
                            </Badge>
                          </TableCell>
                          <TableCell className="max-w-[200px] truncate text-muted-foreground">
                            {txn.description || "-"}
                          </TableCell>
                          <TableCell className="text-muted-foreground">
                            {format(
                              new Date(txn.created_at),
                              "dd MMM yyyy, HH:mm"
                            )}
                          </TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </div>
              ) : (
                <p className="text-sm text-muted-foreground py-8 text-center">
                  No payment transactions found.
                </p>
              )}
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </>
  );
}
