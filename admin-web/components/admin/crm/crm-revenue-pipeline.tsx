"use client";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";

function formatCurrency(amount: number): string {
  return new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency: "INR",
    maximumFractionDigits: 0,
  }).format(amount);
}

const stageConfig: Record<string, { label: string; color: string; bg: string }> = {
  quoted: {
    label: "Quoted",
    color: "text-amber-700 dark:text-amber-400",
    bg: "bg-amber-100 dark:bg-amber-900/40",
  },
  paid: {
    label: "Paid",
    color: "text-blue-700 dark:text-blue-400",
    bg: "bg-blue-100 dark:bg-blue-900/40",
  },
  in_progress: {
    label: "In Progress",
    color: "text-purple-700 dark:text-purple-400",
    bg: "bg-purple-100 dark:bg-purple-900/40",
  },
  completed: {
    label: "Completed",
    color: "text-green-700 dark:text-green-400",
    bg: "bg-green-100 dark:bg-green-900/40",
  },
};

export function CrmRevenuePipeline({
  pipeline,
}: {
  pipeline: Record<string, { count: number; value: number }>;
}) {
  const stages = ["quoted", "paid", "in_progress", "completed"];
  const totalValue = stages.reduce(
    (sum, s) => sum + (pipeline[s]?.value || 0),
    0
  );

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-base">Revenue Pipeline</CardTitle>
        <p className="text-sm text-muted-foreground">
          Total pipeline value: {formatCurrency(totalValue)}
        </p>
      </CardHeader>
      <CardContent>
        {/* Pipeline bar */}
        <div className="flex h-8 rounded-lg overflow-hidden mb-6">
          {stages.map((stage) => {
            const data = pipeline[stage];
            const config = stageConfig[stage];
            const pct = totalValue > 0 ? (data?.value / totalValue) * 100 : 25;
            return (
              <div
                key={stage}
                className={`${config.bg} flex items-center justify-center text-xs font-medium ${config.color} transition-all`}
                style={{ width: `${Math.max(pct, 5)}%` }}
                title={`${config.label}: ${formatCurrency(data?.value || 0)}`}
              >
                {pct > 10 ? `${Math.round(pct)}%` : ""}
              </div>
            );
          })}
        </div>

        {/* Stage cards */}
        <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
          {stages.map((stage) => {
            const data = pipeline[stage];
            const config = stageConfig[stage];
            return (
              <div
                key={stage}
                className="rounded-lg border p-3 text-center"
              >
                <Badge
                  variant="secondary"
                  className={`mb-2 ${config.bg} ${config.color} border-0`}
                >
                  {config.label}
                </Badge>
                <div className="text-lg font-bold">
                  {formatCurrency(data?.value || 0)}
                </div>
                <p className="text-xs text-muted-foreground">
                  {data?.count || 0} projects
                </p>
              </div>
            );
          })}
        </div>
      </CardContent>
    </Card>
  );
}
