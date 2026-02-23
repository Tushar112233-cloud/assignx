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
import { IconDotsVertical, IconEye, IconBan, IconCheck } from "@tabler/icons-react";
import { suspendUser, activateUser } from "@/lib/admin/actions/users";
import { toast } from "sonner";

type User = {
  id: string;
  full_name: string | null;
  email: string | null;
  avatar_url: string | null;
  user_type: string | null;
  is_active: boolean;
  project_count?: number;
  wallet_balance?: number;
  created_at: string;
};

const userTypeColors: Record<string, string> = {
  student: "bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400",
  professional: "bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-400",
  business: "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400",
  supervisor: "bg-orange-100 text-orange-800 dark:bg-orange-900/30 dark:text-orange-400",
  doer: "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-400",
};

function getInitials(name: string | null): string {
  if (!name) return "?";
  return name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);
}

function formatCurrency(amount: number | undefined): string {
  if (amount == null) return "\u20B90.00";
  return new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency: "INR",
    minimumFractionDigits: 2,
  }).format(amount);
}

function formatDate(dateStr: string): string {
  return new Date(dateStr).toLocaleDateString("en-IN", {
    day: "numeric",
    month: "short",
    year: "numeric",
  });
}

export function UsersDataTable({
  data,
  total,
  page,
  totalPages,
}: {
  data: User[];
  total: number;
  page: number;
  totalPages: number;
}) {
  const router = useRouter();
  const searchParams = useSearchParams();
  const pathname = usePathname();
  const [searchValue, setSearchValue] = useState(searchParams.get("search") || "");

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
          toast.success("User suspended successfully");
        } else {
          await activateUser(userId);
          toast.success("User activated successfully");
        }
        router.refresh();
      } catch (err) {
        toast.error(err instanceof Error ? err.message : "Action failed");
      }
    },
    [router]
  );

  const columns: ColumnDef<User>[] = [
    {
      accessorKey: "full_name",
      header: "User",
      cell: ({ row }) => {
        const user = row.original;
        return (
          <div className="flex items-center gap-3">
            <Avatar size="default">
              {user.avatar_url && <AvatarImage src={user.avatar_url} alt={user.full_name || ""} />}
              <AvatarFallback>{getInitials(user.full_name)}</AvatarFallback>
            </Avatar>
            <span className="font-medium">{user.full_name || "Unnamed"}</span>
          </div>
        );
      },
    },
    {
      accessorKey: "email",
      header: "Email",
      cell: ({ getValue }) => (
        <span className="text-muted-foreground">{(getValue() as string) || "-"}</span>
      ),
    },
    {
      accessorKey: "user_type",
      header: "Type",
      cell: ({ getValue }) => {
        const type = (getValue() as string) || "unknown";
        return (
          <Badge variant="secondary" className={userTypeColors[type] || ""}>
            {type}
          </Badge>
        );
      },
    },
    {
      accessorKey: "is_active",
      header: "Status",
      cell: ({ getValue }) => {
        const active = getValue() as boolean;
        return (
          <Badge variant={active ? "outline" : "destructive"}>
            {active ? "Active" : "Suspended"}
          </Badge>
        );
      },
    },
    {
      accessorKey: "project_count",
      header: "Projects",
      cell: ({ getValue }) => (getValue() as number) ?? 0,
    },
    {
      accessorKey: "wallet_balance",
      header: "Balance",
      cell: ({ getValue }) => formatCurrency(getValue() as number | undefined),
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
        const user = row.original;
        return (
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" size="icon" className="size-8">
                <IconDotsVertical className="size-4" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem asChild>
                <Link href={`/users/${user.id}`}>
                  <IconEye className="size-4" />
                  View Details
                </Link>
              </DropdownMenuItem>
              <DropdownMenuSeparator />
              {user.is_active ? (
                <DropdownMenuItem
                  variant="destructive"
                  onClick={() => handleAction(user.id, "suspend")}
                >
                  <IconBan className="size-4" />
                  Suspend User
                </DropdownMenuItem>
              ) : (
                <DropdownMenuItem onClick={() => handleAction(user.id, "activate")}>
                  <IconCheck className="size-4" />
                  Activate User
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
            placeholder="Search users..."
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
          value={searchParams.get("type") || "all"}
          onValueChange={(v) => updateParams("type", v)}
        >
          <SelectTrigger className="w-40">
            <SelectValue placeholder="User Type" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Types</SelectItem>
            <SelectItem value="student">Student</SelectItem>
            <SelectItem value="professional">Professional</SelectItem>
            <SelectItem value="business">Business</SelectItem>
            <SelectItem value="supervisor">Supervisor</SelectItem>
            <SelectItem value="doer">Doer</SelectItem>
          </SelectContent>
        </Select>
        <Select
          value={searchParams.get("status") || "all"}
          onValueChange={(v) => updateParams("status", v)}
        >
          <SelectTrigger className="w-36">
            <SelectValue placeholder="Status" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Status</SelectItem>
            <SelectItem value="active">Active</SelectItem>
            <SelectItem value="suspended">Suspended</SelectItem>
          </SelectContent>
        </Select>
        <span className="ml-auto text-sm text-muted-foreground">
          {total} user{total !== 1 ? "s" : ""} total
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
                  No users found.
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
    </div>
  );
}
