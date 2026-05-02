"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import {
  IconUser,
  IconMail,
  IconPhone,
  IconMapPin,
  IconCalendar,
  IconHeart,
  IconSend,
  IconNote,
  IconBan,
  IconCheck,
  IconFolder,
  IconCreditCard,
  IconTicket,
  IconBell,
  IconActivity,
  IconArrowLeft,
} from "@tabler/icons-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Table,
  TableHeader,
  TableRow,
  TableHead,
  TableBody,
  TableCell,
} from "@/components/ui/table";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { toast } from "sonner";
import { suspendUser, activateUser } from "@/lib/admin/actions/users";
import {
  addCustomerNote,
  sendCustomerNotification,
} from "@/lib/admin/actions/crm";

type CustomerData = {
  profile: any;
  wallet: any;
  projects: any[];
  tickets: any[];
  transactions: any[];
  notifications: any[];
  activity: any[];
  stats: {
    totalSpend: number;
    completedProjects: number;
    totalProjects: number;
    healthScore: number;
  };
};

function formatCurrency(amount: number): string {
  return new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency: "INR",
    maximumFractionDigits: 0,
  }).format(amount);
}

function formatDate(dateStr: string | null): string {
  if (!dateStr) return "N/A";
  return new Date(dateStr).toLocaleDateString("en-IN", {
    day: "numeric",
    month: "short",
    year: "numeric",
  });
}

function formatDateTime(dateStr: string | null): string {
  if (!dateStr) return "N/A";
  return new Date(dateStr).toLocaleDateString("en-IN", {
    day: "numeric",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

function getInitials(name: string | null): string {
  if (!name) return "?";
  return name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);
}

function getHealthColor(score: number): string {
  if (score >= 70) return "text-green-600";
  if (score >= 40) return "text-amber-600";
  return "text-red-600";
}

function getHealthBg(score: number): string {
  if (score >= 70) return "bg-green-500";
  if (score >= 40) return "bg-amber-500";
  return "bg-red-500";
}

function getHealthLabel(score: number): string {
  if (score >= 70) return "Healthy";
  if (score >= 40) return "Moderate";
  return "At Risk";
}

const statusColors: Record<string, string> = {
  draft: "bg-gray-100 text-gray-800",
  submitted: "bg-blue-100 text-blue-800",
  analyzing: "bg-purple-100 text-purple-800",
  quoted: "bg-amber-100 text-amber-800",
  payment_pending: "bg-yellow-100 text-yellow-800",
  paid: "bg-teal-100 text-teal-800",
  assigned: "bg-indigo-100 text-indigo-800",
  in_progress: "bg-cyan-100 text-cyan-800",
  completed: "bg-green-100 text-green-800",
  auto_approved: "bg-green-100 text-green-800",
  cancelled: "bg-red-100 text-red-800",
  refunded: "bg-red-100 text-red-800",
};

// ---- Health Score Ring ----
function HealthScoreRing({ score }: { score: number }) {
  const circumference = 2 * Math.PI * 36;
  const offset = circumference - (score / 100) * circumference;

  return (
    <div className="relative inline-flex items-center justify-center">
      <svg className="w-24 h-24 -rotate-90">
        <circle
          cx="48"
          cy="48"
          r="36"
          stroke="currentColor"
          strokeWidth="6"
          fill="none"
          className="text-muted/30"
        />
        <circle
          cx="48"
          cy="48"
          r="36"
          stroke="currentColor"
          strokeWidth="6"
          fill="none"
          strokeLinecap="round"
          className={getHealthColor(score)}
          strokeDasharray={circumference}
          strokeDashoffset={offset}
        />
      </svg>
      <div className="absolute text-center">
        <div className={`text-lg font-bold ${getHealthColor(score)}`}>
          {score}
        </div>
        <div className="text-[10px] text-muted-foreground">
          {getHealthLabel(score)}
        </div>
      </div>
    </div>
  );
}

// ---- Send Message Dialog ----
function SendMessageDialog({ customerId }: { customerId: string }) {
  const router = useRouter();
  const [isPending, startTransition] = useTransition();
  const [open, setOpen] = useState(false);
  const [title, setTitle] = useState("");
  const [body, setBody] = useState("");

  const handleSend = () => {
    if (!title.trim() || !body.trim()) {
      toast.error("Title and message are required");
      return;
    }
    startTransition(async () => {
      try {
        await sendCustomerNotification(customerId, title, body);
        toast.success("Message sent successfully");
        setOpen(false);
        setTitle("");
        setBody("");
        router.refresh();
      } catch (err) {
        toast.error(err instanceof Error ? err.message : "Failed to send");
      }
    });
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button variant="outline" size="sm">
          <IconSend className="h-4 w-4 mr-1" />
          Send Message
        </Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Send Notification</DialogTitle>
          <DialogDescription>
            Send a notification to this customer.
          </DialogDescription>
        </DialogHeader>
        <div className="space-y-3">
          <div className="space-y-2">
            <Label>Title</Label>
            <Input
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="Notification title"
            />
          </div>
          <div className="space-y-2">
            <Label>Message</Label>
            <Textarea
              value={body}
              onChange={(e) => setBody(e.target.value)}
              placeholder="Write your message..."
              rows={3}
            />
          </div>
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={() => setOpen(false)}>
            Cancel
          </Button>
          <Button onClick={handleSend} disabled={isPending}>
            {isPending ? "Sending..." : "Send"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

// ---- Add Note Dialog ----
function AddNoteDialog({ customerId }: { customerId: string }) {
  const router = useRouter();
  const [isPending, startTransition] = useTransition();
  const [open, setOpen] = useState(false);
  const [note, setNote] = useState("");

  const handleAdd = () => {
    if (!note.trim()) {
      toast.error("Note cannot be empty");
      return;
    }
    startTransition(async () => {
      try {
        await addCustomerNote(customerId, note);
        toast.success("Note added");
        setOpen(false);
        setNote("");
        router.refresh();
      } catch (err) {
        toast.error(err instanceof Error ? err.message : "Failed to add note");
      }
    });
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button variant="outline" size="sm">
          <IconNote className="h-4 w-4 mr-1" />
          Add Note
        </Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Add Admin Note</DialogTitle>
          <DialogDescription>
            Add an internal note about this customer.
          </DialogDescription>
        </DialogHeader>
        <div className="space-y-2">
          <Label>Note</Label>
          <Textarea
            value={note}
            onChange={(e) => setNote(e.target.value)}
            placeholder="Write your note..."
            rows={4}
          />
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={() => setOpen(false)}>
            Cancel
          </Button>
          <Button onClick={handleAdd} disabled={isPending}>
            {isPending ? "Adding..." : "Add Note"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

// ---- Main Component ----
export function CrmCustomerDetail({
  data,
  notes,
}: {
  data: CustomerData;
  notes: any[];
}) {
  const router = useRouter();
  const [isPending, startTransition] = useTransition();
  const { profile, wallet, projects, tickets, transactions, stats } = data;

  const handleSuspendActivate = () => {
    startTransition(async () => {
      try {
        if (profile.is_active) {
          await suspendUser(profile.id, "Suspended via CRM");
          toast.success("User suspended");
        } else {
          await activateUser(profile.id);
          toast.success("User activated");
        }
        router.refresh();
      } catch (err) {
        toast.error(err instanceof Error ? err.message : "Action failed");
      }
    });
  };

  return (
    <div className="space-y-6">
      {/* Back button */}
      <Button variant="ghost" size="sm" asChild>
        <Link href="/crm">
          <IconArrowLeft className="h-4 w-4 mr-1" />
          Back to CRM
        </Link>
      </Button>

      {/* Profile Header */}
      <Card>
        <CardContent className="pt-6">
          <div className="flex flex-col sm:flex-row items-start gap-6">
            <Avatar className="h-20 w-20">
              {profile.avatar_url && (
                <AvatarImage src={profile.avatar_url} />
              )}
              <AvatarFallback className="text-xl">
                {getInitials(profile.full_name)}
              </AvatarFallback>
            </Avatar>

            <div className="flex-1 space-y-3">
              <div className="flex items-start justify-between">
                <div>
                  <h2 className="text-xl font-bold">
                    {profile.full_name || "Unnamed User"}
                  </h2>
                  <div className="flex items-center gap-4 mt-1 text-sm text-muted-foreground">
                    {profile.email && (
                      <span className="flex items-center gap-1">
                        <IconMail className="h-3.5 w-3.5" />
                        {profile.email}
                      </span>
                    )}
                    {profile.phone && (
                      <span className="flex items-center gap-1">
                        <IconPhone className="h-3.5 w-3.5" />
                        {profile.phone}
                      </span>
                    )}
                  </div>
                  {(profile.city || profile.state) && (
                    <div className="flex items-center gap-1 text-sm text-muted-foreground mt-0.5">
                      <IconMapPin className="h-3.5 w-3.5" />
                      {[profile.city, profile.state, profile.country]
                        .filter(Boolean)
                        .join(", ")}
                    </div>
                  )}
                </div>

                <HealthScoreRing score={stats.healthScore} />
              </div>

              <div className="flex flex-wrap items-center gap-2">
                <Badge
                  variant="secondary"
                  className={
                    profile.user_type === "student"
                      ? "bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400"
                      : profile.user_type === "professional"
                        ? "bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-400"
                        : "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400"
                  }
                >
                  {profile.user_type}
                </Badge>
                <Badge variant={profile.is_active ? "outline" : "destructive"}>
                  {profile.is_active ? "Active" : "Suspended"}
                </Badge>
                {profile.is_college_verified && (
                  <Badge variant="secondary" className="bg-teal-100 text-teal-800 dark:bg-teal-900/30 dark:text-teal-400">
                    College Verified
                  </Badge>
                )}
                <span className="text-xs text-muted-foreground ml-2">
                  Joined {formatDate(profile.created_at)} | Last active{" "}
                  {formatDate(profile.last_login_at)}
                </span>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Quick Stats */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
        <Card>
          <CardContent className="pt-4 pb-3 px-4">
            <div className="flex items-center gap-2 mb-1">
              <IconCreditCard className="h-4 w-4 text-green-600" />
              <span className="text-xs text-muted-foreground">Total Spend</span>
            </div>
            <div className="text-lg font-bold">
              {formatCurrency(stats.totalSpend)}
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-4 pb-3 px-4">
            <div className="flex items-center gap-2 mb-1">
              <IconFolder className="h-4 w-4 text-blue-600" />
              <span className="text-xs text-muted-foreground">Projects</span>
            </div>
            <div className="text-lg font-bold">
              {stats.completedProjects}/{stats.totalProjects}
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-4 pb-3 px-4">
            <div className="flex items-center gap-2 mb-1">
              <IconCreditCard className="h-4 w-4 text-purple-600" />
              <span className="text-xs text-muted-foreground">Wallet</span>
            </div>
            <div className="text-lg font-bold">
              {formatCurrency(Number(wallet?.balance) || 0)}
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-4 pb-3 px-4">
            <div className="flex items-center gap-2 mb-1">
              <IconTicket className="h-4 w-4 text-orange-600" />
              <span className="text-xs text-muted-foreground">Tickets</span>
            </div>
            <div className="text-lg font-bold">{tickets.length}</div>
          </CardContent>
        </Card>
      </div>

      {/* Quick Actions */}
      <div className="flex flex-wrap items-center gap-2">
        <SendMessageDialog customerId={profile.id} />
        <AddNoteDialog customerId={profile.id} />
        <Button
          variant={profile.is_active ? "destructive" : "outline"}
          size="sm"
          onClick={handleSuspendActivate}
          disabled={isPending}
        >
          {profile.is_active ? (
            <>
              <IconBan className="h-4 w-4 mr-1" />
              Suspend
            </>
          ) : (
            <>
              <IconCheck className="h-4 w-4 mr-1" />
              Activate
            </>
          )}
        </Button>
        <Button variant="outline" size="sm" asChild>
          <Link href={`/users/${profile.id}`}>
            <IconUser className="h-4 w-4 mr-1" />
            View in Users
          </Link>
        </Button>
      </div>

      {/* Tabbed Detail Views */}
      <Tabs defaultValue="projects">
        <TabsList>
          <TabsTrigger value="projects">
            Projects ({projects.length})
          </TabsTrigger>
          <TabsTrigger value="transactions">
            Transactions ({transactions.length})
          </TabsTrigger>
          <TabsTrigger value="tickets">
            Tickets ({tickets.length})
          </TabsTrigger>
          <TabsTrigger value="notes">
            Notes ({notes.length})
          </TabsTrigger>
          <TabsTrigger value="activity">
            Activity
          </TabsTrigger>
        </TabsList>

        {/* Projects Tab */}
        <TabsContent value="projects" className="mt-4">
          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Title</TableHead>
                  <TableHead>Type</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Value</TableHead>
                  <TableHead>Deadline</TableHead>
                  <TableHead>Created</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {projects.length === 0 ? (
                  <TableRow>
                    <TableCell
                      colSpan={6}
                      className="h-20 text-center text-muted-foreground"
                    >
                      No projects yet.
                    </TableCell>
                  </TableRow>
                ) : (
                  projects.map((project) => (
                    <TableRow key={project.id}>
                      <TableCell>
                        <Link
                          href={`/projects/${project.id}`}
                          className="font-medium text-sm hover:underline"
                        >
                          {project.title || "Untitled"}
                        </Link>
                      </TableCell>
                      <TableCell>
                        <Badge variant="secondary">
                          {project.service_type || "N/A"}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        <Badge
                          variant="secondary"
                          className={statusColors[project.status] || ""}
                        >
                          {project.status}
                        </Badge>
                      </TableCell>
                      <TableCell className="text-sm">
                        {project.user_quote
                          ? formatCurrency(Number(project.user_quote))
                          : "-"}
                      </TableCell>
                      <TableCell className="text-sm text-muted-foreground">
                        {formatDate(project.deadline)}
                      </TableCell>
                      <TableCell className="text-sm text-muted-foreground">
                        {formatDate(project.created_at)}
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </div>
        </TabsContent>

        {/* Transactions Tab */}
        <TabsContent value="transactions" className="mt-4">
          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Type</TableHead>
                  <TableHead>Amount</TableHead>
                  <TableHead>Balance After</TableHead>
                  <TableHead>Description</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Date</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {transactions.length === 0 ? (
                  <TableRow>
                    <TableCell
                      colSpan={6}
                      className="h-20 text-center text-muted-foreground"
                    >
                      No transactions yet.
                    </TableCell>
                  </TableRow>
                ) : (
                  transactions.map((txn) => (
                    <TableRow key={txn.id}>
                      <TableCell>
                        <Badge variant="secondary">
                          {txn.transaction_type || txn.type || "N/A"}
                        </Badge>
                      </TableCell>
                      <TableCell
                        className={`text-sm font-medium ${
                          Number(txn.amount) >= 0
                            ? "text-green-600"
                            : "text-red-600"
                        }`}
                      >
                        {formatCurrency(Number(txn.amount))}
                      </TableCell>
                      <TableCell className="text-sm text-muted-foreground">
                        {txn.balance_after
                          ? formatCurrency(Number(txn.balance_after))
                          : "-"}
                      </TableCell>
                      <TableCell className="text-sm text-muted-foreground max-w-xs truncate">
                        {txn.description || "-"}
                      </TableCell>
                      <TableCell>
                        <Badge
                          variant={
                            txn.status === "completed"
                              ? "outline"
                              : "secondary"
                          }
                        >
                          {txn.status || "N/A"}
                        </Badge>
                      </TableCell>
                      <TableCell className="text-sm text-muted-foreground">
                        {formatDateTime(txn.created_at)}
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </div>
        </TabsContent>

        {/* Tickets Tab */}
        <TabsContent value="tickets" className="mt-4">
          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Ticket #</TableHead>
                  <TableHead>Subject</TableHead>
                  <TableHead>Priority</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Created</TableHead>
                  <TableHead>Resolved</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {tickets.length === 0 ? (
                  <TableRow>
                    <TableCell
                      colSpan={6}
                      className="h-20 text-center text-muted-foreground"
                    >
                      No support tickets.
                    </TableCell>
                  </TableRow>
                ) : (
                  tickets.map((ticket) => (
                    <TableRow key={ticket.id}>
                      <TableCell className="text-sm font-mono">
                        <Link
                          href={`/support/${ticket.id}`}
                          className="hover:underline"
                        >
                          {ticket.ticket_number}
                        </Link>
                      </TableCell>
                      <TableCell className="text-sm font-medium">
                        {ticket.subject}
                      </TableCell>
                      <TableCell>
                        <Badge
                          variant={
                            ticket.priority === "urgent" ||
                            ticket.priority === "high"
                              ? "destructive"
                              : "secondary"
                          }
                        >
                          {ticket.priority}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        <Badge
                          variant={
                            ticket.status === "open"
                              ? "destructive"
                              : ticket.status === "resolved"
                                ? "outline"
                                : "secondary"
                          }
                        >
                          {ticket.status}
                        </Badge>
                      </TableCell>
                      <TableCell className="text-sm text-muted-foreground">
                        {formatDate(ticket.created_at)}
                      </TableCell>
                      <TableCell className="text-sm text-muted-foreground">
                        {formatDate(ticket.resolved_at)}
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </div>
        </TabsContent>

        {/* Notes Tab */}
        <TabsContent value="notes" className="mt-4">
          <div className="space-y-3">
            {notes.length === 0 ? (
              <Card>
                <CardContent className="py-8 text-center text-muted-foreground">
                  No admin notes yet. Add the first note above.
                </CardContent>
              </Card>
            ) : (
              notes.map((note) => (
                <Card key={note.id}>
                  <CardContent className="py-3 px-4">
                    <div className="flex items-start justify-between">
                      <p className="text-sm">
                        {(note.details as any)?.note || ""}
                      </p>
                      <span className="text-xs text-muted-foreground whitespace-nowrap ml-4">
                        {formatDateTime(note.created_at)}
                      </span>
                    </div>
                  </CardContent>
                </Card>
              ))
            )}
          </div>
        </TabsContent>

        {/* Activity Tab */}
        <TabsContent value="activity" className="mt-4">
          <div className="space-y-2">
            {data.activity.length === 0 ? (
              <Card>
                <CardContent className="py-8 text-center text-muted-foreground">
                  No activity logs found.
                </CardContent>
              </Card>
            ) : (
              data.activity.map((log: any) => (
                <div
                  key={log.id}
                  className="flex items-start gap-3 py-2 px-3 rounded-lg border"
                >
                  <IconActivity className="h-4 w-4 text-muted-foreground mt-0.5" />
                  <div className="flex-1">
                    <div className="text-sm">
                      {log.action || log.event_type || "Activity"}
                    </div>
                    {log.details && (
                      <div className="text-xs text-muted-foreground mt-0.5">
                        {typeof log.details === "string"
                          ? log.details
                          : JSON.stringify(log.details)}
                      </div>
                    )}
                  </div>
                  <span className="text-xs text-muted-foreground whitespace-nowrap">
                    {formatDateTime(log.created_at)}
                  </span>
                </div>
              ))
            )}
          </div>
        </TabsContent>
      </Tabs>
    </div>
  );
}
