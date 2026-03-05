"use client";

import { useRouter, useSearchParams, usePathname } from "next/navigation";
import { useCallback, useState } from "react";
import {
  useReactTable,
  getCoreRowModel,
  flexRender,
  type ColumnDef,
} from "@tanstack/react-table";
import Link from "next/link";
import {
  Table,
  TableHeader,
  TableRow,
  TableHead,
  TableBody,
  TableCell,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar";
import {
  DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
} from "@/components/ui/dropdown-menu";
import {
  Select,
  SelectTrigger,
  SelectValue,
  SelectContent,
  SelectItem,
} from "@/components/ui/select";
import { Input } from "@/components/ui/input";
import { IconDotsVertical, IconEye, IconBan, IconCheck, IconUserCheck, IconUserX } from "@tabler/icons-react";
import { suspendUser, activateUser } from "@/lib/admin/actions/users";
import { approveDoer, rejectDoer } from "@/lib/admin/actions/doers";
import { toast } from "sonner";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";

type Doer = {
  id: string;
  full_name: string | null;
  email: string | null;
  avatar_url: string | null;
  is_active: boolean;
  is_activated: boolean;
  phone: string | null;
  city: string | null;
  created_at: string;
  tasks_assigned: number;
  tasks_completed: number;
  completion_rate: number;
};

function getInitials(name: string | null): string {
  if (!name) return "?";
  return name.split(" ").map((n) => n[0]).join("").toUpperCase().slice(0, 2);
}

function formatDate(dateStr: string): string {
  return new Date(dateStr).toLocaleDateString("en-IN", {
    day: "numeric",
    month: "short",
    year: "numeric",
  });
}

export function DoersDataTable({
  data,
  total,
  page,
  totalPages,
}: {
  data: Doer[];
  total: number;
  page: number;
  totalPages: number;
}) {
  const router = useRouter();
  const searchParams = useSearchParams();
  const pathname = usePathname();
  const [searchValue, setSearchValue] = useState(searchParams.get("search") || "");
  const [rejectDialog, setRejectDialog] = useState<{ open: boolean; doerId: string; doerName: string }>({
    open: false,
    doerId: "",
    doerName: "",
  });
  const [rejectReason, setRejectReason] = useState("");
  const [isActioning, setIsActioning] = useState(false);

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

  const handleSearch = useCallback(() => {
    updateParams("search", searchValue || null);
  }, [updateParams, searchValue]);

  const handleAction = useCallback(
    async (userId: string, action: "suspend" | "activate") => {
      try {
        if (action === "suspend") {
          await suspendUser(userId, "Suspended by admin");
          toast.success("Doer suspended");
        } else {
          await activateUser(userId);
          toast.success("Doer activated");
        }
        router.refresh();
      } catch (err) {
        toast.error(err instanceof Error ? err.message : "Action failed");
      }
    },
    [router]
  );

  const handleApprove = useCallback(
    async (doerId: string) => {
      setIsActioning(true);
      try {
        await approveDoer(doerId);
        toast.success("Doer approved and access granted");
        router.refresh();
      } catch (err) {
        toast.error(err instanceof Error ? err.message : "Approval failed");
      } finally {
        setIsActioning(false);
      }
    },
    [router]
  );

  const handleRejectConfirm = useCallback(async () => {
    if (!rejectReason.trim()) {
      toast.error("Please provide a rejection reason");
      return;
    }
    setIsActioning(true);
    try {
      await rejectDoer(rejectDialog.doerId, rejectReason);
      toast.success("Doer rejected");
      setRejectDialog({ open: false, doerId: "", doerName: "" });
      setRejectReason("");
      router.refresh();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Rejection failed");
    } finally {
      setIsActioning(false);
    }
  }, [rejectDialog.doerId, rejectReason, router]);

  const columns: ColumnDef<Doer>[] = [
    {
      accessorKey: "full_name",
      header: "Doer",
      cell: ({ row }) => {
        const d = row.original;
        return (
          <div className="flex items-center gap-3">
            <Avatar size="default">
              {d.avatar_url && <AvatarImage src={d.avatar_url} alt={d.full_name || ""} />}
              <AvatarFallback>{getInitials(d.full_name)}</AvatarFallback>
            </Avatar>
            <div className="flex flex-col">
              <span className="font-medium">{d.full_name || "Unnamed"}</span>
              <span className="text-xs text-muted-foreground">{d.email || "-"}</span>
            </div>
          </div>
        );
      },
    },
    {
      accessorKey: "tasks_assigned",
      header: "Assigned",
      cell: ({ getValue }) => getValue() as number,
    },
    {
      accessorKey: "tasks_completed",
      header: "Completed",
      cell: ({ getValue }) => getValue() as number,
    },
    {
      accessorKey: "completion_rate",
      header: "Completion %",
      cell: ({ getValue }) => {
        const rate = getValue() as number;
        return (
          <Badge
            variant="outline"
            className={
              rate >= 80
                ? "text-green-600 border-green-200 bg-green-50 dark:bg-green-900/20"
                : rate >= 50
                  ? "text-yellow-600 border-yellow-200 bg-yellow-50 dark:bg-yellow-900/20"
                  : "text-red-600 border-red-200 bg-red-50 dark:bg-red-900/20"
            }
          >
            {rate}%
          </Badge>
        );
      },
    },
    {
      accessorKey: "is_active",
      header: "Status",
      cell: ({ row }) => {
        const d = row.original;
        if (!d.is_activated) {
          return (
            <Badge variant="outline" className="text-amber-600 border-amber-200 bg-amber-50 dark:bg-amber-900/20">
              Pending Approval
            </Badge>
          );
        }
        return (
          <Badge variant={d.is_active ? "outline" : "destructive"}>
            {d.is_active ? "Active" : "Suspended"}
          </Badge>
        );
      },
    },
    {
      accessorKey: "created_at",
      header: "Joined",
      cell: ({ getValue }) => formatDate(getValue() as string),
    },
    {
      id: "actions",
      header: "",
      cell: ({ row }) => {
        const d = row.original;
        return (
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" size="icon" className="size-8">
                <IconDotsVertical className="size-4" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem asChild>
                <Link href={`/doers/${d.id}`}>
                  <IconEye className="size-4" />
                  View Details
                </Link>
              </DropdownMenuItem>
              <DropdownMenuSeparator />
              {!d.is_activated ? (
                <>
                  <DropdownMenuItem
                    onClick={() => handleApprove(d.id)}
                    className="text-green-600 focus:text-green-600 focus:bg-green-50"
                  >
                    <IconUserCheck className="size-4" />
                    Approve Doer
                  </DropdownMenuItem>
                  <DropdownMenuItem
                    variant="destructive"
                    onClick={() => setRejectDialog({ open: true, doerId: d.id, doerName: d.full_name || "this doer" })}
                  >
                    <IconUserX className="size-4" />
                    Reject Doer
                  </DropdownMenuItem>
                </>
              ) : d.is_active ? (
                <DropdownMenuItem
                  variant="destructive"
                  onClick={() => handleAction(d.id, "suspend")}
                >
                  <IconBan className="size-4" />
                  Suspend
                </DropdownMenuItem>
              ) : (
                <DropdownMenuItem onClick={() => handleAction(d.id, "activate")}>
                  <IconCheck className="size-4" />
                  Activate
                </DropdownMenuItem>
              )}
            </DropdownMenuContent>
          </DropdownMenu>
        );
      },
    },
  ];

  const table = useReactTable({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
  });

  return (
    <div className="flex flex-col gap-4 px-4 lg:px-6">
      <div className="flex flex-wrap items-center gap-3">
        <div className="flex items-center gap-2">
          <Input
            placeholder="Search doers..."
            value={searchValue}
            onChange={(e) => setSearchValue(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && handleSearch()}
            className="w-64"
          />
          <Button variant="outline" size="sm" onClick={handleSearch}>
            Search
          </Button>
        </div>
        <Select
          value={searchParams.get("status") || "all"}
          onValueChange={(v) => updateParams("status", v)}
        >
          <SelectTrigger className="w-36">
            <SelectValue placeholder="Status" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Status</SelectItem>
            <SelectItem value="pending">Pending Approval</SelectItem>
            <SelectItem value="active">Active</SelectItem>
            <SelectItem value="suspended">Suspended</SelectItem>
          </SelectContent>
        </Select>
        <span className="ml-auto text-sm text-muted-foreground">
          {total} doer{total !== 1 ? "s" : ""} total
        </span>
      </div>

      <div className="rounded-md border">
        <Table>
          <TableHeader>
            {table.getHeaderGroups().map((headerGroup) => (
              <TableRow key={headerGroup.id}>
                {headerGroup.headers.map((header) => (
                  <TableHead key={header.id}>
                    {header.isPlaceholder
                      ? null
                      : flexRender(header.column.columnDef.header, header.getContext())}
                  </TableHead>
                ))}
              </TableRow>
            ))}
          </TableHeader>
          <TableBody>
            {table.getRowModel().rows.length ? (
              table.getRowModel().rows.map((row) => (
                <TableRow key={row.id}>
                  {row.getVisibleCells().map((cell) => (
                    <TableCell key={cell.id}>
                      {flexRender(cell.column.columnDef.cell, cell.getContext())}
                    </TableCell>
                  ))}
                </TableRow>
              ))
            ) : (
              <TableRow>
                <TableCell colSpan={columns.length} className="h-24 text-center">
                  No doers found.
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>

      <div className="flex items-center justify-between">
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

      {/* Reject Doer Dialog */}
      <Dialog open={rejectDialog.open} onOpenChange={(open) => setRejectDialog((prev) => ({ ...prev, open }))}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Reject Doer Application</DialogTitle>
            <DialogDescription>
              Rejecting <strong>{rejectDialog.doerName}</strong>&apos;s doer application. Please provide a reason.
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-2">
            <Label htmlFor="reject-reason">Rejection Reason <span className="text-red-500">*</span></Label>
            <Textarea
              id="reject-reason"
              placeholder="e.g. Incomplete profile, insufficient qualifications..."
              value={rejectReason}
              onChange={(e) => setRejectReason(e.target.value)}
              rows={3}
            />
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setRejectDialog({ open: false, doerId: "", doerName: "" })}>
              Cancel
            </Button>
            <Button variant="destructive" onClick={handleRejectConfirm} disabled={isActioning || !rejectReason.trim()}>
              {isActioning ? "Rejecting..." : "Reject Doer"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
