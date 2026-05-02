"use client";

import {
  IconUsers,
  IconUserPlus,
  IconActivity,
  IconTrendingDown,
} from "@tabler/icons-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

function formatNumber(n: number): string {
  if (n >= 1000) return `${(n / 1000).toFixed(1)}k`;
  return String(n);
}

export function CrmOverviewCards({
  totalCustomers,
  activeThisMonth,
  newThisMonth,
  churnRate,
}: {
  totalCustomers: number;
  activeThisMonth: number;
  newThisMonth: number;
  churnRate: number;
}) {
  const cards = [
    {
      title: "Total Customers",
      value: formatNumber(totalCustomers),
      icon: IconUsers,
      description: "All registered users",
      color: "text-blue-600",
      bg: "bg-blue-50 dark:bg-blue-950/30",
    },
    {
      title: "Active This Month",
      value: formatNumber(activeThisMonth),
      icon: IconActivity,
      description: "Logged in this month",
      color: "text-green-600",
      bg: "bg-green-50 dark:bg-green-950/30",
    },
    {
      title: "New This Month",
      value: formatNumber(newThisMonth),
      icon: IconUserPlus,
      description: "Joined this month",
      color: "text-purple-600",
      bg: "bg-purple-50 dark:bg-purple-950/30",
    },
    {
      title: "Churn Rate",
      value: `${churnRate}%`,
      icon: IconTrendingDown,
      description: "vs last month",
      color: churnRate > 10 ? "text-red-600" : "text-amber-600",
      bg: churnRate > 10 ? "bg-red-50 dark:bg-red-950/30" : "bg-amber-50 dark:bg-amber-950/30",
    },
  ];

  return (
    <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
      {cards.map((card) => {
        const Icon = card.icon;
        return (
          <Card key={card.title}>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                {card.title}
              </CardTitle>
              <div className={`rounded-lg p-2 ${card.bg}`}>
                <Icon className={`h-4 w-4 ${card.color}`} />
              </div>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{card.value}</div>
              <p className="text-xs text-muted-foreground mt-1">
                {card.description}
              </p>
            </CardContent>
          </Card>
        );
      })}
    </div>
  );
}
