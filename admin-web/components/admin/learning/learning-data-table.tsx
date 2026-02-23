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
  IconStar,
  IconStarOff,
  IconPlus,
} from "@tabler/icons-react";
import {
  deleteLearningResource,
  toggleLearningFeatured,
} from "@/lib/admin/actions/learning";
import { toast } from "sonner";
import type { LearningResource } from "@/lib/admin/types";

const contentTypeColors: Record<string, string> = {
  article: "bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400",
  video: "bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-400",
  pdf: "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400",
  link: "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400",
};

export function LearningDataTable({
  data,
  total,
  page,
  totalPages,
}: {
  data: LearningResource[];
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
        await deleteLearningResource(id);
        toast.success("Resource deleted successfully");
        router.refresh();
      } catch (err) {
        toast.error(err instanceof Error ? err.message : "Delete failed");
      }
    },
    [router]
  );

  const handleToggleFeatured = useCallback(
    async (id: string, current: boolean) => {
      try {
        await toggleLearningFeatured(id, !current);
        toast.success(
          !current ? "Resource featured" : "Resource unfeatured"
        );
        router.refresh();
      } catch (err) {
        toast.error(err instanceof Error ? err.message : "Action failed");
      }
    },
    [router]
  );

  const columns: ColumnDef<LearningResource>[] = [
    {
      accessorKey: "title",
      header: "Title",
      cell: ({ getValue }) => (
        <span className="font-medium">{getValue() as string}</span>
      ),
    },
    {
      accessorKey: "content_type",
      header: "Type",
      cell: ({ getValue }) => {
        const type = (getValue() as string) || "unknown";
        return (
          <Badge variant="secondary" className={contentTypeColors[type] || ""}>
            {type}
          </Badge>
        );
      },
    },
    {
      accessorKey: "category",
      header: "Category",
      cell: ({ getValue }) => (getValue() as string) || "-",
    },
    {
      accessorKey: "target_audience",
      header: "Audience",
      cell: ({ getValue }) => {
        const audience = (getValue() as string[]) || [];
        return (
          <div className="flex flex-wrap gap-1">
            {audience.map((a) => (
              <Badge key={a} variant="outline" className="text-xs">
                {a}
              </Badge>
            ))}
          </div>
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
            {active ? "Active" : "Inactive"}
          </Badge>
        );
      },
    },
    {
      accessorKey: "is_featured",
      header: "Featured",
      cell: ({ getValue }) =>
        (getValue() as boolean) ? (
          <IconStar className="size-4 text-yellow-500 fill-yellow-500" />
        ) : (
          <span className="text-muted-foreground">-</span>
        ),
    },
    {
      accessorKey: "view_count",
      header: "Views",
      cell: ({ getValue }) =>
        ((getValue() as number) || 0).toLocaleString(),
    },
    {
      id: "actions",
      header: "",
      cell: ({ row }) => {
        const resource = row.original;
        return (
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" size="icon" className="size-8">
                <IconDotsVertical className="size-4" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem asChild>
                <Link href={`/learning/create?edit=${resource.id}`}>
                  <IconEdit className="size-4" />
                  Edit
                </Link>
              </DropdownMenuItem>
              <DropdownMenuItem
                onClick={() =>
                  handleToggleFeatured(resource.id, resource.is_featured)
                }
              >
                {resource.is_featured ? (
                  <>
                    <IconStarOff className="size-4" />
                    Unfeature
                  </>
                ) : (
                  <>
                    <IconStar className="size-4" />
                    Feature
                  </>
                )}
              </DropdownMenuItem>
              <DropdownMenuSeparator />
              <DropdownMenuItem
                variant="destructive"
                onClick={() => handleDelete(resource.id)}
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
            placeholder="Search resources..."
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
          value={searchParams.get("contentType") || "all"}
          onValueChange={(v) => updateParams("contentType", v)}
        >
          <SelectTrigger className="w-40">
            <SelectValue placeholder="Content Type" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Types</SelectItem>
            <SelectItem value="article">Article</SelectItem>
            <SelectItem value="video">Video</SelectItem>
            <SelectItem value="pdf">PDF</SelectItem>
            <SelectItem value="link">Link</SelectItem>
          </SelectContent>
        </Select>
        <Button asChild size="sm" className="ml-auto">
          <Link href="/learning/create">
            <IconPlus className="size-4" />
            Add Resource
          </Link>
        </Button>
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
                  No learning resources found.
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>

      <div className="flex items-center justify-between">
        <p className="text-sm text-muted-foreground">
          {total} resource{total !== 1 ? "s" : ""} total &middot; Page {page} of{" "}
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
