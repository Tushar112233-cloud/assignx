"use client";

import * as React from "react";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { format } from "date-fns";
import {
  IconChevronLeft,
  IconChevronRight,
} from "@tabler/icons-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
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

const TRANSACTION_TYPES = [
  "credit", "debit", "refund", "withdrawal", "top_up",
  "project_payment", "project_earning", "commission", "bonus",
  "penalty", "reversal",
];

const TRANSACTION_STATUSES = [
  "initiated", "pending", "processing", "completed",
  "failed", "cancelled", "refunded", "partially_refunded",
];

function getTypeVariant(type: string) {
  switch (type) {
    case "credit":
    case "top_up":
    case "bonus":
    case "project_earning":
      return "default" as const;
    case "debit":
    case "withdrawal":
    case "project_payment":
    case "commission":
      return "secondary" as const;
    case "refund":
    case "reversal":
    case "penalty":
      return "destructive" as const;
    default:
      return "outline" as const;
  }
}

function getStatusVariant(status: string) {
  switch (status) {
    case "completed":
      return "default" as const;
    case "pending":
    case "processing":
    case "initiated":
      return "secondary" as const;
    case "failed":
    case "cancelled":
      return "destructive" as const;
    default:
      return "outline" as const;
  }
}

interface TransactionListItem {
  id: string;
  transaction_type: string;
  amount: number | string;
  status: string;
  description: string | null;
  wallet_id: string | null;
  created_at: string;
  wallet?: {
    profiles: {
      full_name: string | null;
      email: string | null;
    } | null;
  } | null;
}

interface TransactionsDataTableProps {
  data: TransactionListItem[];
  total: number;
  page: number;
  totalPages: number;
}

export function TransactionsDataTable({
  data,
  total,
  page,
  totalPages,
}: TransactionsDataTableProps) {
  const router = useRouter();
  const searchParams = useSearchParams();

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

  return (
    <div className="flex flex-col gap-4 px-4 lg:px-6">
      <div className="flex flex-wrap items-center gap-2">
        <Select
          value={searchParams.get("type") || "all"}
          onValueChange={(v) => updateParams("type", v === "all" ? "" : v)}
        >
          <SelectTrigger className="w-44" size="sm">
            <SelectValue placeholder="Filter by type" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Types</SelectItem>
            {TRANSACTION_TYPES.map((t) => (
              <SelectItem key={t} value={t}>
                {t.replace(/_/g, " ")}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
        <Select
          value={searchParams.get("status") || "all"}
          onValueChange={(v) => updateParams("status", v === "all" ? "" : v)}
        >
          <SelectTrigger className="w-44" size="sm">
            <SelectValue placeholder="Filter by status" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Statuses</SelectItem>
            {TRANSACTION_STATUSES.map((s) => (
              <SelectItem key={s} value={s}>
                {s.replace(/_/g, " ")}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
        <div className="ml-auto text-sm text-muted-foreground">
          {total} transaction{total !== 1 ? "s" : ""}
        </div>
      </div>

      <div className="overflow-hidden rounded-lg border">
        <Table>
          <TableHeader className="bg-muted">
            <TableRow>
              <TableHead>Type</TableHead>
              <TableHead className="text-right">Amount</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Description</TableHead>
              <TableHead>Wallet Owner</TableHead>
              <TableHead>Date</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {data.length > 0 ? (
              data.map((txn) => {
                const walletProfile = txn.wallet?.profiles;
                return (
                  <TableRow key={txn.id}>
                    <TableCell>
                      <Badge variant={getTypeVariant(txn.transaction_type)}>
                        {txn.transaction_type?.replace(/_/g, " ")}
                      </Badge>
                    </TableCell>
                    <TableCell className="text-right font-medium tabular-nums">
                      {new Intl.NumberFormat("en-IN", {
                        style: "currency",
                        currency: "INR",
                      }).format(Number(txn.amount))}
                    </TableCell>
                    <TableCell>
                      <Badge variant={getStatusVariant(txn.status)}>
                        {txn.status}
                      </Badge>
                    </TableCell>
                    <TableCell className="max-w-[200px] truncate text-muted-foreground">
                      {txn.description || "-"}
                    </TableCell>
                    <TableCell>
                      {walletProfile?.full_name ? (
                        <Link
                          href={`/wallets/${txn.wallet_id}`}
                          className="text-sm hover:underline"
                        >
                          {walletProfile.full_name}
                        </Link>
                      ) : txn.wallet_id ? (
                        <Link
                          href={`/wallets/${txn.wallet_id}`}
                          className="text-sm text-muted-foreground hover:underline"
                        >
                          View wallet
                        </Link>
                      ) : (
                        <span className="text-muted-foreground">-</span>
                      )}
                    </TableCell>
                    <TableCell className="text-muted-foreground">
                      {format(new Date(txn.created_at), "dd MMM yyyy, HH:mm")}
                    </TableCell>
                  </TableRow>
                );
              })
            ) : (
              <TableRow>
                <TableCell
                  colSpan={6}
                  className="h-24 text-center text-muted-foreground"
                >
                  No transactions found.
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
