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
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { IconExternalLink } from "@tabler/icons-react";

type CollegeRow = {
  id: string;
  college_name: string;
  short_name: string | null;
  city: string | null;
  state: string | null;
  total_users: number;
  students: number;
  professionals: number;
  doers: number;
};

export function CollegesDataTable({
  data,
  total,
  page,
  totalPages,
}: {
  data: CollegeRow[];
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
      if (value) {
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

  const columns: ColumnDef<CollegeRow>[] = [
    {
      accessorKey: "college_name",
      header: "College Name",
      cell: ({ row }) => {
        const { id, college_name, city, state } = row.original;
        return (
          <Link
            href={`/colleges/${id}`}
            className="flex flex-col gap-0.5 hover:underline"
          >
            <span className="flex items-center gap-1.5 font-medium">
              {college_name}
              <IconExternalLink className="size-3.5 text-muted-foreground" />
            </span>
            {(city || state) && (
              <span className="text-xs text-muted-foreground">
                {[city, state].filter(Boolean).join(", ")}
              </span>
            )}
          </Link>
        );
      },
    },
    {
      accessorKey: "total_users",
      header: "Total Users",
      cell: ({ getValue }) => (getValue() as number).toLocaleString(),
    },
    {
      accessorKey: "students",
      header: "Students",
      cell: ({ getValue }) => (getValue() as number).toLocaleString(),
    },
    {
      accessorKey: "professionals",
      header: "Professionals",
      cell: ({ getValue }) => (getValue() as number).toLocaleString(),
    },
    {
      accessorKey: "doers",
      header: "Doers",
      cell: ({ getValue }) => (getValue() as number).toLocaleString(),
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
            placeholder="Search colleges..."
            value={searchValue}
            onChange={(e) => setSearchValue(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && handleSearch()}
            className="w-64"
          />
          <Button variant="outline" size="sm" onClick={handleSearch}>
            Search
          </Button>
        </div>
        <span className="ml-auto text-sm text-muted-foreground">
          {total} college{total !== 1 ? "s" : ""} found
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
                  No colleges found.
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
