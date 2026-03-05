"use client";

import { useRouter, useSearchParams, usePathname } from "next/navigation";
import { useCallback, useState } from "react";
import {
  useReactTable,
  getCoreRowModel,
  flexRender,
  type ColumnDef,
} from "@tanstack/react-table";
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
import {
  IconDotsVertical,
  IconCheck,
  IconX,
} from "@tabler/icons-react";
import { approveApplication, rejectApplication } from "@/lib/admin/actions/applications";
import { toast } from "sonner";

interface AccessRequest {
  _id: string;
  email: string;
  role: string;
  fullName: string;
  status: "pending" | "approved" | "rejected";
  metadata?: Record<string, unknown>;
  createdAt: string;
  reviewedAt?: string;
}

function formatDate(dateStr: string | null): string {
  if (!dateStr) return "-";
  return new Date(dateStr).toLocaleDateString("en-IN", {
    day: "numeric",
    month: "short",
    year: "numeric",
  });
}

function statusBadge(status: string) {
  switch (status) {
    case "approved":
      return <Badge className="bg-emerald-100 text-emerald-700 border-emerald-200">Approved</Badge>;
    case "rejected":
      return <Badge variant="destructive">Rejected</Badge>;
    default:
      return <Badge className="bg-amber-100 text-amber-700 border-amber-200">Pending</Badge>;
  }
}

export function ApplicationsDataTable({
  data,
  total,
  page,
  totalPages,
}: {
  data: AccessRequest[];
  total: number;
  page: number;
  totalPages: number;
}) {
  const router = useRouter();
  const searchParams = useSearchParams();
  const pathname = usePathname();
  const [searchValue, setSearchValue] = useState(
    searchParams.get("search") || ""
  );
  const [expandedId, setExpandedId] = useState<string | null>(null);

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

  const handleApprove = useCallback(
    async (id: string) => {
      try {
        await approveApplication(id);
        toast.success("Application approved");
        router.refresh();
      } catch (err) {
        toast.error(err instanceof Error ? err.message : "Approve failed");
      }
    },
    [router]
  );

  const handleReject = useCallback(
    async (id: string) => {
      try {
        await rejectApplication(id);
        toast.success("Application rejected");
        router.refresh();
      } catch (err) {
        toast.error(err instanceof Error ? err.message : "Reject failed");
      }
    },
    [router]
  );

  const columns: ColumnDef<AccessRequest>[] = [
    {
      accessorKey: "fullName",
      header: "Name",
      cell: ({ getValue }) => (
        <span className="font-medium">{getValue() as string}</span>
      ),
    },
    {
      accessorKey: "email",
      header: "Email",
      cell: ({ getValue }) => (
        <span className="text-muted-foreground">{getValue() as string}</span>
      ),
    },
    {
      accessorKey: "role",
      header: "Role",
      cell: ({ getValue }) => (
        <Badge variant="outline" className="capitalize">
          {getValue() as string}
        </Badge>
      ),
    },
    {
      accessorKey: "status",
      header: "Status",
      cell: ({ getValue }) => statusBadge(getValue() as string),
    },
    {
      id: "details",
      header: "Details",
      cell: ({ row }) => {
        const m = row.original.metadata || {};
        const expertise = (m.expertiseAreas as string[]) || (m.skills as string[]) || [];
        const qualification = m.qualification as string || "";
        const years = m.yearsOfExperience as number;
        const parts: string[] = [];
        if (qualification) parts.push(qualification.replace(/_/g, " "));
        if (years) parts.push(`${years}y exp`);
        if (expertise.length) parts.push(expertise.map(e => (e as string).replace(/_/g, " ")).join(", "));
        if (!parts.length) return <span className="text-muted-foreground">-</span>;
        return (
          <span className="text-xs text-muted-foreground max-w-64 truncate block" title={parts.join(" · ")}>
            {parts.join(" · ")}
          </span>
        );
      },
    },
    {
      accessorKey: "createdAt",
      header: "Applied",
      cell: ({ getValue }) => formatDate(getValue() as string),
    },
    {
      id: "actions",
      header: "",
      cell: ({ row }) => {
        const request = row.original;
        if (request.status !== "pending") return null;
        return (
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" size="icon" className="size-8">
                <IconDotsVertical className="size-4" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem onClick={() => handleApprove(request._id)}>
                <IconCheck className="size-4" />
                Approve
              </DropdownMenuItem>
              <DropdownMenuSeparator />
              <DropdownMenuItem
                variant="destructive"
                onClick={() => handleReject(request._id)}
              >
                <IconX className="size-4" />
                Reject
              </DropdownMenuItem>
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
            placeholder="Search by name or email..."
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
            <SelectItem value="pending">Pending</SelectItem>
            <SelectItem value="approved">Approved</SelectItem>
            <SelectItem value="rejected">Rejected</SelectItem>
          </SelectContent>
        </Select>
        <Select
          value={searchParams.get("role") || "all"}
          onValueChange={(v) => updateParams("role", v)}
        >
          <SelectTrigger className="w-36">
            <SelectValue placeholder="Role" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Roles</SelectItem>
            <SelectItem value="doer">Doer</SelectItem>
            <SelectItem value="supervisor">Supervisor</SelectItem>
          </SelectContent>
        </Select>
      </div>

      <div className="overflow-x-auto rounded-md border">
        <Table>
          <TableHeader>
            {table.getHeaderGroups().map((headerGroup) => (
              <TableRow key={headerGroup.id}>
                {headerGroup.headers.map((header) => (
                  <TableHead key={header.id}>
                    {header.isPlaceholder
                      ? null
                      : flexRender(
                          header.column.columnDef.header,
                          header.getContext()
                        )}
                  </TableHead>
                ))}
              </TableRow>
            ))}
          </TableHeader>
          <TableBody>
            {table.getRowModel().rows.length ? (
              table.getRowModel().rows.map((row) => {
                const req = row.original;
                const isExpanded = expandedId === req._id;
                const m = req.metadata || {};
                return (
                  <>
                    <TableRow
                      key={row.id}
                      className="cursor-pointer hover:bg-muted/50"
                      onClick={() => setExpandedId(isExpanded ? null : req._id)}
                    >
                      {row.getVisibleCells().map((cell) => (
                        <TableCell key={cell.id}>
                          {flexRender(
                            cell.column.columnDef.cell,
                            cell.getContext()
                          )}
                        </TableCell>
                      ))}
                    </TableRow>
                    {isExpanded && (
                      <TableRow key={`${row.id}-detail`}>
                        <TableCell colSpan={columns.length} className="bg-muted/30 px-6 py-4">
                          <div className="grid grid-cols-2 md:grid-cols-3 gap-4 text-sm">
                            {m.qualification && (
                              <div>
                                <p className="text-muted-foreground text-xs font-medium">Qualification</p>
                                <p className="capitalize">{(m.qualification as string).replace(/_/g, " ")}</p>
                              </div>
                            )}
                            {m.yearsOfExperience != null && (
                              <div>
                                <p className="text-muted-foreground text-xs font-medium">Experience</p>
                                <p>{m.yearsOfExperience as number} years</p>
                              </div>
                            )}
                            {((m.expertiseAreas as string[]) || []).length > 0 && (
                              <div>
                                <p className="text-muted-foreground text-xs font-medium">Expertise</p>
                                <div className="flex flex-wrap gap-1 mt-1">
                                  {((m.expertiseAreas as string[]) || []).map((e) => (
                                    <Badge key={e as string} variant="secondary" className="text-xs capitalize">
                                      {(e as string).replace(/_/g, " ")}
                                    </Badge>
                                  ))}
                                </div>
                              </div>
                            )}
                            {m.bio && (
                              <div className="col-span-full">
                                <p className="text-muted-foreground text-xs font-medium">Bio</p>
                                <p>{m.bio as string}</p>
                              </div>
                            )}
                            {m.bankName && (
                              <div>
                                <p className="text-muted-foreground text-xs font-medium">Bank</p>
                                <p className="uppercase">{m.bankName as string}</p>
                              </div>
                            )}
                            {m.accountNumber && (
                              <div>
                                <p className="text-muted-foreground text-xs font-medium">Account Number</p>
                                <p>{"*".repeat(Math.max(0, (m.accountNumber as string).length - 4)) + (m.accountNumber as string).slice(-4)}</p>
                              </div>
                            )}
                            {m.ifscCode && (
                              <div>
                                <p className="text-muted-foreground text-xs font-medium">IFSC Code</p>
                                <p>{m.ifscCode as string}</p>
                              </div>
                            )}
                            {m.upiId && (
                              <div>
                                <p className="text-muted-foreground text-xs font-medium">UPI ID</p>
                                <p>{m.upiId as string}</p>
                              </div>
                            )}
                          </div>
                        </TableCell>
                      </TableRow>
                    )}
                  </>
                );
              })
            ) : (
              <TableRow>
                <TableCell
                  colSpan={columns.length}
                  className="h-24 text-center"
                >
                  No applications found.
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>

      <div className="flex items-center justify-between">
        <p className="text-sm text-muted-foreground">
          {total} application{total !== 1 ? "s" : ""} total &middot; Page {page}{" "}
          of {totalPages}
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
    </div>
  );
}
