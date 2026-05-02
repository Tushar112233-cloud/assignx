"use client";

import { useState, useCallback, useTransition } from "react";
import { useRouter, useSearchParams, usePathname } from "next/navigation";
import {
  IconSend,
  IconTicket,
  IconBell,
  IconTemplate,
  IconCheck,
} from "@tabler/icons-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import {
  Select,
  SelectTrigger,
  SelectValue,
  SelectContent,
  SelectItem,
} from "@/components/ui/select";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Label } from "@/components/ui/label";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Table,
  TableHeader,
  TableRow,
  TableHead,
  TableBody,
  TableCell,
} from "@/components/ui/table";
import { toast } from "sonner";
import { sendAnnouncementNotification } from "@/lib/admin/actions/crm";

type Communication = {
  id: string;
  comm_type: "ticket" | "notification";
  title: string;
  subject?: string;
  body?: string;
  status?: string;
  priority?: string;
  notification_type?: string;
  is_read?: boolean;
  user_name: string;
  user_email: string;
  created_at: string;
};

const templates = [
  {
    name: "Welcome Message",
    title: "Welcome to AssignX!",
    body: "Thank you for joining AssignX. We are excited to have you on board! Explore our platform and submit your first project to get started.",
  },
  {
    name: "Payment Reminder",
    title: "Payment Pending",
    body: "You have a pending payment for your project. Please complete the payment to proceed with your project.",
  },
  {
    name: "Feedback Request",
    title: "How was your experience?",
    body: "Your project has been completed. We would love to hear your feedback! Please rate your experience and help us improve.",
  },
  {
    name: "Re-engagement",
    title: "We miss you!",
    body: "It has been a while since you visited AssignX. Check out our latest features and submit a new project today!",
  },
];

function formatDate(dateStr: string): string {
  return new Date(dateStr).toLocaleDateString("en-IN", {
    day: "numeric",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

function CommunicationTimeline({
  communications,
  total,
  page,
  totalPages,
}: {
  communications: Communication[];
  total: number;
  page: number;
  totalPages: number;
}) {
  const router = useRouter();
  const searchParams = useSearchParams();
  const pathname = usePathname();

  const updateParams = useCallback(
    (key: string, value: string | null) => {
      const params = new URLSearchParams(searchParams.toString());
      if (value && value !== "all") {
        params.set(key, value);
      } else {
        params.delete(key);
      }
      if (key !== "page") params.delete("page");
      router.push(`${pathname}?${params.toString()}`);
    },
    [router, pathname, searchParams]
  );

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between">
        <div>
          <CardTitle className="text-base">Communication History</CardTitle>
          <p className="text-sm text-muted-foreground">
            {total} total communications
          </p>
        </div>
        <Select
          value={searchParams.get("type") || "all"}
          onValueChange={(v) => updateParams("type", v)}
        >
          <SelectTrigger className="w-40">
            <SelectValue placeholder="Filter" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Types</SelectItem>
            <SelectItem value="tickets">Tickets</SelectItem>
            <SelectItem value="notifications">Notifications</SelectItem>
          </SelectContent>
        </Select>
      </CardHeader>
      <CardContent>
        <div className="rounded-md border">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-10">Type</TableHead>
                <TableHead>Content</TableHead>
                <TableHead>User</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Date</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {communications.length === 0 ? (
                <TableRow>
                  <TableCell
                    colSpan={5}
                    className="h-24 text-center text-muted-foreground"
                  >
                    No communications found.
                  </TableCell>
                </TableRow>
              ) : (
                communications.map((comm) => (
                  <TableRow key={`${comm.comm_type}-${comm.id}`}>
                    <TableCell>
                      {comm.comm_type === "ticket" ? (
                        <IconTicket className="h-4 w-4 text-orange-500" />
                      ) : (
                        <IconBell className="h-4 w-4 text-blue-500" />
                      )}
                    </TableCell>
                    <TableCell>
                      <div className="max-w-md">
                        <div className="font-medium text-sm truncate">
                          {comm.title || comm.subject || "Untitled"}
                        </div>
                        {comm.body && (
                          <div className="text-xs text-muted-foreground truncate mt-0.5">
                            {comm.body}
                          </div>
                        )}
                      </div>
                    </TableCell>
                    <TableCell>
                      <div>
                        <div className="text-sm">{comm.user_name}</div>
                        <div className="text-xs text-muted-foreground">
                          {comm.user_email}
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>
                      {comm.comm_type === "ticket" && comm.status && (
                        <Badge
                          variant={
                            comm.status === "open"
                              ? "destructive"
                              : comm.status === "resolved"
                                ? "outline"
                                : "secondary"
                          }
                        >
                          {comm.status}
                        </Badge>
                      )}
                      {comm.comm_type === "notification" && (
                        <Badge variant={comm.is_read ? "outline" : "secondary"}>
                          {comm.is_read ? "Read" : "Unread"}
                        </Badge>
                      )}
                    </TableCell>
                    <TableCell className="text-sm text-muted-foreground">
                      {formatDate(comm.created_at)}
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </div>

        {totalPages > 1 && (
          <div className="flex items-center justify-between mt-4">
            <p className="text-sm text-muted-foreground">
              Page {page} of {totalPages}
            </p>
            <div className="flex gap-2">
              <Button
                variant="outline"
                size="sm"
                disabled={page <= 1}
                onClick={() => updateParams("page", String(page - 1))}
              >
                Previous
              </Button>
              <Button
                variant="outline"
                size="sm"
                disabled={page >= totalPages}
                onClick={() => updateParams("page", String(page + 1))}
              >
                Next
              </Button>
            </div>
          </div>
        )}
      </CardContent>
    </Card>
  );
}

function SendAnnouncementDialog() {
  const router = useRouter();
  const [isPending, startTransition] = useTransition();
  const [open, setOpen] = useState(false);
  const [title, setTitle] = useState("");
  const [body, setBody] = useState("");
  const [segment, setSegment] = useState("all");

  const handleSend = () => {
    if (!title.trim() || !body.trim()) {
      toast.error("Title and body are required");
      return;
    }

    startTransition(async () => {
      try {
        const result = await sendAnnouncementNotification({
          title,
          body,
          targetSegment: segment,
        });
        if (result.success) {
          toast.success(`Announcement sent to ${result.sent} users`);
          setOpen(false);
          setTitle("");
          setBody("");
          router.refresh();
        } else {
          toast.error(result.message || "Failed to send");
        }
      } catch (err) {
        toast.error(err instanceof Error ? err.message : "Failed to send announcement");
      }
    });
  };

  const applyTemplate = (template: (typeof templates)[number]) => {
    setTitle(template.title);
    setBody(template.body);
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button>
          <IconSend className="h-4 w-4 mr-2" />
          Send Announcement
        </Button>
      </DialogTrigger>
      <DialogContent className="sm:max-w-lg">
        <DialogHeader>
          <DialogTitle>Send Announcement</DialogTitle>
          <DialogDescription>
            Send a notification to a segment of users.
          </DialogDescription>
        </DialogHeader>

        <Tabs defaultValue="compose">
          <TabsList className="mb-4">
            <TabsTrigger value="compose">Compose</TabsTrigger>
            <TabsTrigger value="templates">Templates</TabsTrigger>
          </TabsList>

          <TabsContent value="compose" className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="segment">Target Segment</Label>
              <Select value={segment} onValueChange={setSegment}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Customers</SelectItem>
                  <SelectItem value="students">Students</SelectItem>
                  <SelectItem value="professionals">Professionals</SelectItem>
                  <SelectItem value="business">Business</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <Label htmlFor="title">Title</Label>
              <Input
                id="title"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder="Announcement title"
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="body">Message</Label>
              <Textarea
                id="body"
                value={body}
                onChange={(e) => setBody(e.target.value)}
                placeholder="Write your announcement message..."
                rows={4}
              />
            </div>
          </TabsContent>

          <TabsContent value="templates">
            <div className="space-y-3">
              {templates.map((template) => (
                <button
                  key={template.name}
                  type="button"
                  onClick={() => applyTemplate(template)}
                  className="w-full text-left rounded-lg border p-3 hover:bg-muted/50 transition-colors"
                >
                  <div className="flex items-center gap-2 mb-1">
                    <IconTemplate className="h-4 w-4 text-muted-foreground" />
                    <span className="font-medium text-sm">
                      {template.name}
                    </span>
                  </div>
                  <p className="text-xs text-muted-foreground line-clamp-2">
                    {template.body}
                  </p>
                </button>
              ))}
            </div>
          </TabsContent>
        </Tabs>

        <DialogFooter>
          <Button variant="outline" onClick={() => setOpen(false)}>
            Cancel
          </Button>
          <Button onClick={handleSend} disabled={isPending}>
            {isPending ? (
              "Sending..."
            ) : (
              <>
                <IconCheck className="h-4 w-4 mr-1" />
                Send
              </>
            )}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

export function CrmCommunications({
  communications,
  total,
  page,
  totalPages,
}: {
  communications: Communication[];
  total: number;
  page: number;
  totalPages: number;
}) {
  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-lg font-semibold">Communications</h2>
          <p className="text-sm text-muted-foreground">
            Manage platform communications and send announcements
          </p>
        </div>
        <SendAnnouncementDialog />
      </div>

      <CommunicationTimeline
        communications={communications}
        total={total}
        page={page}
        totalPages={totalPages}
      />
    </div>
  );
}
