"use client";

import Link from "next/link";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Table,
  TableHeader,
  TableRow,
  TableHead,
  TableBody,
  TableCell,
} from "@/components/ui/table";
import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar";
import { IconArrowLeft } from "@tabler/icons-react";

type User = {
  id: string;
  full_name: string | null;
  email: string | null;
  user_type: string | null;
  avatar_url: string | null;
  created_at: string;
  is_active: boolean;
};

const userTypeColors: Record<string, string> = {
  student: "bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400",
  professional: "bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-400",
  business: "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400",
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

export function CollegeDetailView({
  detail,
}: {
  detail: {
    collegeName: string;
    totalUsers: number;
    typeBreakdown: Record<string, number>;
    users: User[];
  };
}) {
  return (
    <div className="flex flex-col gap-4 px-4 lg:px-6">
      <Button asChild variant="ghost" size="sm" className="w-fit">
        <Link href="/colleges">
          <IconArrowLeft className="size-4" />
          Back to Colleges
        </Link>
      </Button>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader>
            <CardDescription>Total Users</CardDescription>
            <CardTitle className="text-2xl tabular-nums">
              {detail.totalUsers}
            </CardTitle>
          </CardHeader>
        </Card>
        {Object.entries(detail.typeBreakdown).map(([type, count]) => (
          <Card key={type}>
            <CardHeader>
              <CardDescription className="capitalize">{type}s</CardDescription>
              <CardTitle className="text-2xl tabular-nums">{count}</CardTitle>
            </CardHeader>
          </Card>
        ))}
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Users from {detail.collegeName}</CardTitle>
          <CardDescription>
            {detail.totalUsers} user{detail.totalUsers !== 1 ? "s" : ""}
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>User</TableHead>
                  <TableHead>Email</TableHead>
                  <TableHead>Type</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Joined</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {detail.users.length > 0 ? (
                  detail.users.map((user) => (
                    <TableRow key={user.id}>
                      <TableCell>
                        <Link
                          href={`/users/${user.id}`}
                          className="flex items-center gap-3 hover:underline"
                        >
                          <Avatar>
                            {user.avatar_url && (
                              <AvatarImage
                                src={user.avatar_url}
                                alt={user.full_name || ""}
                              />
                            )}
                            <AvatarFallback>
                              {getInitials(user.full_name)}
                            </AvatarFallback>
                          </Avatar>
                          <span className="font-medium">
                            {user.full_name || "Unnamed"}
                          </span>
                        </Link>
                      </TableCell>
                      <TableCell className="text-muted-foreground">
                        {user.email || "-"}
                      </TableCell>
                      <TableCell>
                        <Badge
                          variant="secondary"
                          className={
                            userTypeColors[user.user_type || ""] || ""
                          }
                        >
                          {user.user_type || "unknown"}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        <Badge
                          variant={user.is_active ? "outline" : "destructive"}
                        >
                          {user.is_active ? "Active" : "Suspended"}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        {new Date(user.created_at).toLocaleDateString("en-IN", {
                          day: "numeric",
                          month: "short",
                          year: "numeric",
                        })}
                      </TableCell>
                    </TableRow>
                  ))
                ) : (
                  <TableRow>
                    <TableCell colSpan={5} className="h-24 text-center">
                      No users found.
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
