"use client";

import Link from "next/link";
import {
  IconUsers,
  IconClockHour4,
  IconHelp,
  IconFolder,
  IconUserCheck,
  IconChartPie,
} from "@tabler/icons-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";

const STATUS_COLORS: Record<string, string> = {
  completed: "bg-emerald-500",
  in_progress: "bg-blue-500",
  analysing: "bg-purple-500",
  analyzing: "bg-purple-500",
  quoted: "bg-amber-500",
  pending: "bg-slate-400",
  cancelled: "bg-red-400",
};

const STATUS_LABELS: Record<string, string> = {
  completed: "Completed",
  in_progress: "In Progress",
  analysing: "Analysing",
  analyzing: "Analyzing",
  quoted: "Quoted",
  pending: "Pending",
  cancelled: "Cancelled",
};

interface PlatformHealthCardsProps {
  pendingDoerApprovals: number;
  activeDoers: number;
  openSupportTickets: number;
  inProgressTickets: number;
  activeProjects: number;
  projectStatusBreakdown: Record<string, number>;
}

export function PlatformHealthCards({
  pendingDoerApprovals,
  activeDoers,
  openSupportTickets,
  inProgressTickets,
  activeProjects,
  projectStatusBreakdown,
}: PlatformHealthCardsProps) {
  const totalProjectsCount = Object.values(projectStatusBreakdown).reduce((a, b) => a + b, 0);

  const quickStats = [
    {
      label: "Pending Doer Approvals",
      value: pendingDoerApprovals,
      icon: IconClockHour4,
      href: "/doers?status=pending",
      urgent: pendingDoerApprovals > 0,
      color: pendingDoerApprovals > 0 ? "text-amber-600" : "text-muted-foreground",
      bg: pendingDoerApprovals > 0 ? "bg-amber-50 dark:bg-amber-900/20" : "bg-muted/30",
    },
    {
      label: "Active Doers",
      value: activeDoers,
      icon: IconUserCheck,
      href: "/doers?status=active",
      urgent: false,
      color: "text-emerald-600",
      bg: "bg-emerald-50 dark:bg-emerald-900/20",
    },
    {
      label: "Open Support Tickets",
      value: openSupportTickets,
      icon: IconHelp,
      href: "/support?status=open",
      urgent: openSupportTickets > 5,
      color: openSupportTickets > 5 ? "text-red-600" : "text-blue-600",
      bg: openSupportTickets > 5 ? "bg-red-50 dark:bg-red-900/20" : "bg-blue-50 dark:bg-blue-900/20",
    },
    {
      label: "In-Progress Tickets",
      value: inProgressTickets,
      icon: IconUsers,
      href: "/support?status=in_progress",
      urgent: false,
      color: "text-indigo-600",
      bg: "bg-indigo-50 dark:bg-indigo-900/20",
    },
    {
      label: "Active Projects",
      value: activeProjects,
      icon: IconFolder,
      href: "/projects",
      urgent: false,
      color: "text-violet-600",
      bg: "bg-violet-50 dark:bg-violet-900/20",
    },
  ];

  return (
    <div className="flex flex-col gap-4">
      <div>
        <h2 className="text-base font-semibold mb-1">Platform Health</h2>
        <p className="text-sm text-muted-foreground">Real-time operational metrics requiring attention</p>
      </div>

      {/* Quick stat cards */}
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-5">
        {quickStats.map((stat) => {
          const Icon = stat.icon;
          return (
            <Link key={stat.label} href={stat.href}>
              <Card className="hover:shadow-md transition-shadow cursor-pointer h-full">
                <CardContent className="pt-4 pb-3 px-4">
                  <div className={`inline-flex h-8 w-8 items-center justify-center rounded-lg mb-2 ${stat.bg}`}>
                    <Icon className={`size-4 ${stat.color}`} />
                  </div>
                  <p className={`text-2xl font-bold tabular-nums ${stat.color}`}>{stat.value}</p>
                  <p className="text-xs text-muted-foreground leading-tight mt-0.5">{stat.label}</p>
                  {stat.urgent && (
                    <Badge variant="outline" className="mt-1.5 text-[10px] px-1.5 py-0 border-amber-300 text-amber-700 bg-amber-50">
                      Needs attention
                    </Badge>
                  )}
                </CardContent>
              </Card>
            </Link>
          );
        })}
      </div>

      {/* Project Status Funnel */}
      {totalProjectsCount > 0 && (
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-semibold flex items-center gap-2">
              <IconChartPie className="size-4" />
              Project Status Breakdown
            </CardTitle>
            <CardDescription>{totalProjectsCount} total projects</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-2.5">
              {Object.entries(projectStatusBreakdown)
                .sort((a, b) => b[1] - a[1])
                .map(([status, count]) => {
                  const pct = totalProjectsCount > 0 ? Math.round((count / totalProjectsCount) * 100) : 0;
                  return (
                    <div key={status} className="flex items-center gap-3">
                      <div className="w-24 shrink-0 text-xs text-muted-foreground capitalize">
                        {STATUS_LABELS[status] || status.replace(/_/g, " ")}
                      </div>
                      <div className="flex-1 h-2 bg-muted rounded-full overflow-hidden">
                        <div
                          className={`h-full rounded-full ${STATUS_COLORS[status] || "bg-slate-400"}`}
                          style={{ width: `${pct}%` }}
                        />
                      </div>
                      <div className="w-14 text-right text-xs tabular-nums text-muted-foreground">
                        {count} <span className="text-muted-foreground/60">({pct}%)</span>
                      </div>
                    </div>
                  );
                })}
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
