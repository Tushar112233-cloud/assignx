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
  IconEdit,
  IconTrash,
  IconToggleLeft,
  IconToggleRight,
  IconPlus,
} from "@tabler/icons-react";
import { deleteBanner, toggleBannerActive } from "@/lib/admin/actions/banners";
import { toast } from "sonner";
import type { AdminBanner } from "@/lib/admin/types";

function formatDate(dateStr: string | null): string {
  if (!dateStr) return "-";
  return new Date(dateStr).toLocaleDateString("en-IN", {
    day: "numeric",
    month: "short",
    year: "numeric",
  });
}

export function BannersDataTable({
  data,
  total,
  page,
  totalPages,
}: {
  data: AdminBanner[];
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

  const handleDelete = useCallback(
    async (id: string) => {
      try {
        await deleteBanner(id);
        toast.success("Banner deleted successfully");
        router.refresh();
      } catch (err) {
        toast.error(err instanceof Error ? err.message : "Delete failed");
      }
    },
    [router]
  );

  const handleToggleActive = useCallback(
    async (id: string, current: boolean) => {
      try {
        await toggleBannerActive(id, !current);
        toast.success(!current ? "Banner activated" : "Banner deactivated");
        router.refresh();
      } catch (err) {
        toast.error(err instanceof Error ? err.message : "Action failed");
      }
    },
    [router]
  );

  const columns: ColumnDef<AdminBanner>[] = [
    {
      accessorKey: "image_url",
      header: "Preview",
      cell: ({ row }) => {
        const banner = row.original;
        return banner.image_url ? (
          <img
            src={banner.image_url}
            alt={banner.title}
            className="h-10 w-20 rounded object-cover"
          />
        ) : (
          <div className="flex h-10 w-20 items-center justify-center rounded bg-muted text-xs text-muted-foreground">
            No image
          </div>
        );
      },
    },
    {
      accessorKey: "title",
      header: "Title",
      cell: ({ getValue }) => (
        <span className="font-medium">{getValue() as string}</span>
      ),
    },
    {
      accessorKey: "display_location",
      header: "Location",
      cell: ({ getValue }) => (
        <Badge variant="outline">{(getValue() as string) || "global"}</Badge>
      ),
    },
    {
      accessorKey: "is_active",
      header: "Status",
      cell: ({ getValue }) => {
        const active = getValue() as boolean;
        return (
          <Badge variant={active ? "outline" : "destructive"}>
            {active ? "Active" : "Inactive"}
          </Badge>
        );
      },
    },
    {
      accessorKey: "start_date",
      header: "Start",
      cell: ({ getValue }) => formatDate(getValue() as string | null),
    },
    {
      accessorKey: "end_date",
      header: "End",
      cell: ({ getValue }) => formatDate(getValue() as string | null),
    },
    {
      accessorKey: "impression_count",
      header: "Impressions",
      cell: ({ getValue }) =>
        ((getValue() as number) || 0).toLocaleString(),
    },
    {
      accessorKey: "click_count",
      header: "Clicks",
      cell: ({ getValue }) =>
        ((getValue() as number) || 0).toLocaleString(),
    },
    {
      id: "ctr",
      header: "CTR",
      cell: ({ row }) => {
        const impressions = row.original.impression_count || 0;
        const clicks = row.original.click_count || 0;
        const ctr = impressions > 0 ? ((clicks / impressions) * 100).toFixed(1) : "0.0";
        return `${ctr}%`;
      },
    },
    {
      id: "actions",
      header: "",
      cell: ({ row }) => {
        const banner = row.original;
        return (
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" size="icon" className="size-8">
                <IconDotsVertical className="size-4" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem asChild>
                <Link href={`/banners/create?edit=${banner.id}`}>
                  <IconEdit className="size-4" />
                  Edit
                </Link>
              </DropdownMenuItem>
              <DropdownMenuItem
                onClick={() =>
                  handleToggleActive(banner.id, banner.is_active)
                }
              >
                {banner.is_active ? (
                  <>
                    <IconToggleLeft className="size-4" />
                    Deactivate
                  </>
                ) : (
                  <>
                    <IconToggleRight className="size-4" />
                    Activate
                  </>
                )}
              </DropdownMenuItem>
              <DropdownMenuSeparator />
              <DropdownMenuItem
                variant="destructive"
                onClick={() => handleDelete(banner.id)}
              >
                <IconTrash className="size-4" />
                Delete
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
            placeholder="Search banners..."
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
          value={searchParams.get("active") || "all"}
          onValueChange={(v) => updateParams("active", v)}
        >
          <SelectTrigger className="w-36">
            <SelectValue placeholder="Status" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Status</SelectItem>
            <SelectItem value="true">Active</SelectItem>
            <SelectItem value="false">Inactive</SelectItem>
          </SelectContent>
        </Select>
        <Button asChild size="sm" className="ml-auto">
          <Link href="/banners/create">
            <IconPlus className="size-4" />
            Add Banner
          </Link>
        </Button>
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
              table.getRowModel().rows.map((row) => (
                <TableRow key={row.id}>
                  {row.getVisibleCells().map((cell) => (
                    <TableCell key={cell.id}>
                      {flexRender(
                        cell.column.columnDef.cell,
                        cell.getContext()
                      )}
                    </TableCell>
                  ))}
                </TableRow>
              ))
            ) : (
              <TableRow>
                <TableCell
                  colSpan={columns.length}
                  className="h-24 text-center"
                >
                  No banners found.
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>

      <div className="flex items-center justify-between">
        <p className="text-sm text-muted-foreground">
          {total} banner{total !== 1 ? "s" : ""} total &middot; Page {page} of{" "}
          {totalPages}
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
