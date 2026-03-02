"use client";

import Link from "next/link";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { IconArrowRight } from "@tabler/icons-react";

const typeConfig: Record<string, { label: string; color: string }> = {
  student: {
    label: "Students",
    color: "bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400",
  },
  professional: {
    label: "Professionals",
    color: "bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-400",
  },
  business: {
    label: "Business",
    color: "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400",
  },
};

export function CrmSegmentsOverview({
  segments,
}: {
  segments: Record<string, number>;
}) {
  const total = Object.values(segments).reduce((sum, n) => sum + n, 0);

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between">
        <div>
          <CardTitle className="text-base">Customer Segments</CardTitle>
          <p className="text-sm text-muted-foreground mt-1">
            Distribution by user type
          </p>
        </div>
        <Button variant="outline" size="sm" asChild>
          <Link href="/crm/segments">
            View All
            <IconArrowRight className="ml-1 h-4 w-4" />
          </Link>
        </Button>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {Object.entries(typeConfig).map(([type, config]) => {
            const count = segments[type] || 0;
            const pct = total > 0 ? (count / total) * 100 : 0;
            return (
              <div key={type} className="space-y-2">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <Badge variant="secondary" className={config.color}>
                      {config.label}
                    </Badge>
                    <span className="text-sm text-muted-foreground">
                      {count} users
                    </span>
                  </div>
                  <span className="text-sm font-medium">
                    {Math.round(pct)}%
                  </span>
                </div>
                <div className="h-2 rounded-full bg-muted overflow-hidden">
                  <div
                    className={`h-full rounded-full transition-all ${
                      type === "student"
                        ? "bg-blue-500"
                        : type === "professional"
                          ? "bg-purple-500"
                          : "bg-green-500"
                    }`}
                    style={{ width: `${pct}%` }}
                  />
                </div>
              </div>
            );
          })}
        </div>
      </CardContent>
    </Card>
  );
}
