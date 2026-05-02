"use client";

import Link from "next/link";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import {
  Table,
  TableHeader,
  TableRow,
  TableHead,
  TableBody,
  TableCell,
} from "@/components/ui/table";

type TopCustomer = {
  id: string;
  name: string;
  email: string;
  avatar_url: string | null;
  user_type: string;
  total: number;
};

const userTypeColors: Record<string, string> = {
  student: "bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400",
  professional: "bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-400",
  business: "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400",
};

function formatCurrency(amount: number): string {
  return new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency: "INR",
    maximumFractionDigits: 0,
  }).format(amount);
}

function getInitials(name: string): string {
  if (!name || name === "Unknown") return "?";
  return name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);
}

export function CrmTopCustomers({
  customers,
}: {
  customers: TopCustomer[];
}) {
  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-base">Top Customers by Spend</CardTitle>
        <p className="text-sm text-muted-foreground">
          Top 10 customers ranked by total project value
        </p>
      </CardHeader>
      <CardContent>
        <div className="rounded-md border">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-8">#</TableHead>
                <TableHead>Customer</TableHead>
                <TableHead>Type</TableHead>
                <TableHead className="text-right">Total Spend</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {customers.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={4} className="h-24 text-center text-muted-foreground">
                    No customer data yet.
                  </TableCell>
                </TableRow>
              ) : (
                customers.map((customer, idx) => (
                  <TableRow key={customer.id}>
                    <TableCell className="font-medium text-muted-foreground">
                      {idx + 1}
                    </TableCell>
                    <TableCell>
                      <Link
                        href={`/crm/customers/${customer.id}`}
                        className="flex items-center gap-3 hover:underline"
                      >
                        <Avatar className="h-8 w-8">
                          {customer.avatar_url && (
                            <AvatarImage src={customer.avatar_url} />
                          )}
                          <AvatarFallback className="text-xs">
                            {getInitials(customer.name)}
                          </AvatarFallback>
                        </Avatar>
                        <div>
                          <div className="font-medium text-sm">
                            {customer.name}
                          </div>
                          <div className="text-xs text-muted-foreground">
                            {customer.email}
                          </div>
                        </div>
                      </Link>
                    </TableCell>
                    <TableCell>
                      <Badge
                        variant="secondary"
                        className={userTypeColors[customer.user_type] || ""}
                      >
                        {customer.user_type}
                      </Badge>
                    </TableCell>
                    <TableCell className="text-right font-medium">
                      {formatCurrency(customer.total)}
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </div>
      </CardContent>
    </Card>
  );
}
