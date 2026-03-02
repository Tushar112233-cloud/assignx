"use client";

import { useState } from "react";
import Link from "next/link";
import {
  IconCrown,
  IconAlertTriangle,
  IconSparkles,
  IconRepeat,
  IconChevronDown,
  IconChevronUp,
} from "@tabler/icons-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import {
  Table,
  TableHeader,
  TableRow,
  TableHead,
  TableBody,
  TableCell,
} from "@/components/ui/table";

type SegmentUser = {
  id: string;
  full_name: string | null;
  email: string;
  avatar_url: string | null;
  user_type: string;
  created_at: string;
  last_login_at: string | null;
  total_spend?: number;
  project_count?: number;
};

type SegmentData = {
  count: number;
  users: SegmentUser[];
};

type Segments = {
  highValue: SegmentData;
  atRisk: SegmentData;
  newUsers: SegmentData;
  repeat: SegmentData;
};

const segmentConfig = [
  {
    key: "highValue" as const,
    label: "High Value",
    description: "Customers who spent more than Rs 10,000",
    icon: IconCrown,
    color: "text-amber-600",
    bg: "bg-amber-50 dark:bg-amber-950/30",
    badgeColor: "bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-400",
    extraCol: "Total Spend",
  },
  {
    key: "atRisk" as const,
    label: "At Risk",
    description: "No login in 30 days but has previous projects",
    icon: IconAlertTriangle,
    color: "text-red-600",
    bg: "bg-red-50 dark:bg-red-950/30",
    badgeColor: "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400",
    extraCol: "Last Active",
  },
  {
    key: "newUsers" as const,
    label: "New Users",
    description: "Joined within the last 7 days",
    icon: IconSparkles,
    color: "text-blue-600",
    bg: "bg-blue-50 dark:bg-blue-950/30",
    badgeColor: "bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400",
    extraCol: "Joined",
  },
  {
    key: "repeat" as const,
    label: "Repeat Customers",
    description: "Customers with 3 or more projects",
    icon: IconRepeat,
    color: "text-green-600",
    bg: "bg-green-50 dark:bg-green-950/30",
    badgeColor: "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400",
    extraCol: "Projects",
  },
];

function formatCurrency(amount: number): string {
  return new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency: "INR",
    maximumFractionDigits: 0,
  }).format(amount);
}

function formatDate(dateStr: string | null): string {
  if (!dateStr) return "Never";
  return new Date(dateStr).toLocaleDateString("en-IN", {
    day: "numeric",
    month: "short",
    year: "numeric",
  });
}

function getInitials(name: string | null): string {
  if (!name) return "?";
  return name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);
}

function SegmentCard({
  config,
  data,
}: {
  config: (typeof segmentConfig)[number];
  data: SegmentData;
}) {
  const [expanded, setExpanded] = useState(false);
  const Icon = config.icon;

  return (
    <Card>
      <CardHeader className="pb-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className={`rounded-lg p-2 ${config.bg}`}>
              <Icon className={`h-5 w-5 ${config.color}`} />
            </div>
            <div>
              <CardTitle className="text-base">{config.label}</CardTitle>
              <p className="text-sm text-muted-foreground mt-0.5">
                {config.description}
              </p>
            </div>
          </div>
          <div className="flex items-center gap-3">
            <Badge variant="secondary" className={config.badgeColor}>
              {data.count} users
            </Badge>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => setExpanded(!expanded)}
            >
              {expanded ? (
                <IconChevronUp className="h-4 w-4" />
              ) : (
                <IconChevronDown className="h-4 w-4" />
              )}
              {expanded ? "Collapse" : "View Users"}
            </Button>
          </div>
        </div>
      </CardHeader>

      {expanded && (
        <CardContent>
          {data.users.length === 0 ? (
            <p className="text-sm text-muted-foreground text-center py-6">
              No users in this segment.
            </p>
          ) : (
            <div className="rounded-md border">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>User</TableHead>
                    <TableHead>Type</TableHead>
                    <TableHead>{config.extraCol}</TableHead>
                    <TableHead className="w-20" />
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {data.users.map((user) => (
                    <TableRow key={user.id}>
                      <TableCell>
                        <div className="flex items-center gap-3">
                          <Avatar className="h-8 w-8">
                            {user.avatar_url && (
                              <AvatarImage src={user.avatar_url} />
                            )}
                            <AvatarFallback className="text-xs">
                              {getInitials(user.full_name)}
                            </AvatarFallback>
                          </Avatar>
                          <div>
                            <div className="font-medium text-sm">
                              {user.full_name || "Unnamed"}
                            </div>
                            <div className="text-xs text-muted-foreground">
                              {user.email}
                            </div>
                          </div>
                        </div>
                      </TableCell>
                      <TableCell>
                        <Badge variant="secondary">
                          {user.user_type}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        {config.key === "highValue" &&
                          formatCurrency(user.total_spend || 0)}
                        {config.key === "atRisk" &&
                          formatDate(user.last_login_at)}
                        {config.key === "newUsers" &&
                          formatDate(user.created_at)}
                        {config.key === "repeat" &&
                          `${user.project_count || 0} projects`}
                      </TableCell>
                      <TableCell>
                        <Button variant="outline" size="sm" asChild>
                          <Link href={`/crm/customers/${user.id}`}>
                            View
                          </Link>
                        </Button>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>
          )}
        </CardContent>
      )}
    </Card>
  );
}

export function CrmSegmentList({ segments }: { segments: Segments }) {
  return (
    <div className="space-y-4">
      {segmentConfig.map((config) => (
        <SegmentCard
          key={config.key}
          config={config}
          data={segments[config.key]}
        />
      ))}
    </div>
  );
}
