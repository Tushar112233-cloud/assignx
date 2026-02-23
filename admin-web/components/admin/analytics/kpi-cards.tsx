"use client";

import { IconTrendingUp, IconUsers, IconFolder, IconChartBar, IconCurrencyRupee, IconTargetArrow } from "@tabler/icons-react";
import {
  Card,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

function formatCurrency(amount: number): string {
  return new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency: "INR",
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  }).format(amount);
}

export function KpiCards({
  totalUsers,
  newUsers,
  totalProjects,
  completionRate,
  totalRevenue,
  avgProjectValue,
}: {
  totalUsers: number;
  newUsers: number;
  totalProjects: number;
  completionRate: string;
  totalRevenue: number;
  avgProjectValue: number;
}) {
  const cards = [
    {
      title: "Total Users",
      value: totalUsers.toLocaleString(),
      icon: IconUsers,
      footer: `${newUsers} new in this period`,
    },
    {
      title: "New Users",
      value: newUsers.toLocaleString(),
      icon: IconTrendingUp,
      footer: "During selected period",
    },
    {
      title: "Total Projects",
      value: totalProjects.toLocaleString(),
      icon: IconFolder,
      footer: "All-time projects",
    },
    {
      title: "Completion Rate",
      value: `${completionRate}%`,
      icon: IconTargetArrow,
      footer: "Projects completed",
    },
    {
      title: "Total Revenue",
      value: formatCurrency(totalRevenue),
      icon: IconCurrencyRupee,
      footer: "From completed payments",
    },
    {
      title: "Avg Project Value",
      value: formatCurrency(avgProjectValue),
      icon: IconChartBar,
      footer: "Per completed project",
    },
  ];

  return (
    <div className="grid grid-cols-1 gap-4 px-4 sm:grid-cols-2 lg:px-6 xl:grid-cols-3 2xl:grid-cols-6">
      {cards.map((card) => (
        <Card key={card.title} className="@container/card">
          <CardHeader>
            <CardDescription className="flex items-center gap-2">
              <card.icon className="size-4" />
              {card.title}
            </CardDescription>
            <CardTitle className="text-2xl font-semibold tabular-nums">
              {card.value}
            </CardTitle>
          </CardHeader>
          <CardFooter className="text-sm text-muted-foreground">
            {card.footer}
          </CardFooter>
        </Card>
      ))}
    </div>
  );
}
