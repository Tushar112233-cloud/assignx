"use client";

import {
  IconCash,
  IconCoin,
  IconMoneybag,
  IconReceipt,
  IconReceiptRefund,
  IconTrendingUp,
} from "@tabler/icons-react";
import {
  Card,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

function formatCurrency(amount: number) {
  return new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency: "INR",
    maximumFractionDigits: 0,
  }).format(amount);
}

interface FinancialSummary {
  total_revenue: number;
  refunds: number;
  payouts: number;
  platform_fees: number;
  net_revenue: number;
  avg_project_value: number;
}

const cardConfigs = [
  {
    key: "total_revenue" as const,
    label: "Total Revenue",
    icon: IconMoneybag,
    format: formatCurrency,
  },
  {
    key: "refunds" as const,
    label: "Refunds",
    icon: IconReceiptRefund,
    format: formatCurrency,
  },
  {
    key: "payouts" as const,
    label: "Payouts",
    icon: IconCash,
    format: formatCurrency,
  },
  {
    key: "platform_fees" as const,
    label: "Platform Fees",
    icon: IconReceipt,
    format: formatCurrency,
  },
  {
    key: "net_revenue" as const,
    label: "Net Revenue",
    icon: IconTrendingUp,
    format: formatCurrency,
  },
  {
    key: "avg_project_value" as const,
    label: "Avg Project Value",
    icon: IconCoin,
    format: formatCurrency,
  },
];

export function FinancialSummaryCards({
  summary,
}: {
  summary: FinancialSummary;
}) {
  return (
    <div className="*:data-[slot=card]:from-primary/5 *:data-[slot=card]:to-card dark:*:data-[slot=card]:bg-card grid grid-cols-1 gap-4 px-4 *:data-[slot=card]:bg-gradient-to-t *:data-[slot=card]:shadow-xs lg:px-6 @xl/main:grid-cols-2 @5xl/main:grid-cols-3">
      {cardConfigs.map((config) => {
        const Icon = config.icon;
        const value = summary[config.key] || 0;
        return (
          <Card key={config.key} className="@container/card">
            <CardHeader>
              <CardDescription>{config.label}</CardDescription>
              <CardTitle className="text-2xl font-semibold tabular-nums @[250px]/card:text-3xl">
                {config.format(value)}
              </CardTitle>
            </CardHeader>
            <CardFooter className="text-sm text-muted-foreground">
              <Icon className="size-4 mr-2" />
              Last 30 days
            </CardFooter>
          </Card>
        );
      })}
    </div>
  );
}
