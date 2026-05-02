"use client";

import * as React from "react";
import { useRouter, useSearchParams, usePathname } from "next/navigation";
import { Area, AreaChart, CartesianGrid, XAxis } from "recharts";
import {
  Card,
  CardAction,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
  type ChartConfig,
} from "@/components/ui/chart";
import {
  ToggleGroup,
  ToggleGroupItem,
} from "@/components/ui/toggle-group";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

const chartConfig = {
  users: { label: "Users" },
  students: { label: "Students", color: "var(--primary)" },
  professionals: { label: "Professionals", color: "var(--chart-2)" },
  businesses: { label: "Businesses", color: "var(--chart-3)" },
} satisfies ChartConfig;

export function UserGrowthChart({
  data,
  initialPeriod,
}: {
  data: { date: string; students: number; professionals: number; businesses: number }[];
  initialPeriod: string;
}) {
  const router = useRouter();
  const searchParams = useSearchParams();
  const pathname = usePathname();
  const [period, setPeriod] = React.useState(initialPeriod);

  const handlePeriodChange = React.useCallback(
    (value: string) => {
      if (!value) return;
      setPeriod(value);
      const params = new URLSearchParams(searchParams.toString());
      params.set("period", value);
      router.push(`${pathname}?${params.toString()}`);
    },
    [router, pathname, searchParams]
  );

  return (
    <Card className="@container/card">
      <CardHeader>
        <CardTitle>User Growth</CardTitle>
        <CardDescription>
          <span className="hidden @[540px]/card:block">
            New user registrations over time
          </span>
          <span className="@[540px]/card:hidden">User growth</span>
        </CardDescription>
        <CardAction>
          <ToggleGroup
            type="single"
            value={period}
            onValueChange={handlePeriodChange}
            variant="outline"
            className="hidden *:data-[slot=toggle-group-item]:!px-4 @[767px]/card:flex"
          >
            <ToggleGroupItem value="90d">3 months</ToggleGroupItem>
            <ToggleGroupItem value="30d">30 days</ToggleGroupItem>
            <ToggleGroupItem value="7d">7 days</ToggleGroupItem>
          </ToggleGroup>
          <Select value={period} onValueChange={handlePeriodChange}>
            <SelectTrigger
              className="flex w-40 **:data-[slot=select-value]:block **:data-[slot=select-value]:truncate @[767px]/card:hidden"
              size="sm"
              aria-label="Select time range"
            >
              <SelectValue placeholder="30 days" />
            </SelectTrigger>
            <SelectContent className="rounded-xl">
              <SelectItem value="90d" className="rounded-lg">3 months</SelectItem>
              <SelectItem value="30d" className="rounded-lg">30 days</SelectItem>
              <SelectItem value="7d" className="rounded-lg">7 days</SelectItem>
            </SelectContent>
          </Select>
        </CardAction>
      </CardHeader>
      <CardContent className="px-2 pt-4 sm:px-6 sm:pt-6">
        <ChartContainer
          config={chartConfig}
          className="aspect-auto h-[300px] w-full"
        >
          <AreaChart data={data}>
            <defs>
              <linearGradient id="analyticsStudents" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="var(--color-students)" stopOpacity={1.0} />
                <stop offset="95%" stopColor="var(--color-students)" stopOpacity={0.1} />
              </linearGradient>
              <linearGradient id="analyticsProfessionals" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="var(--color-professionals)" stopOpacity={0.8} />
                <stop offset="95%" stopColor="var(--color-professionals)" stopOpacity={0.1} />
              </linearGradient>
              <linearGradient id="analyticsBusinesses" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="var(--color-businesses)" stopOpacity={0.6} />
                <stop offset="95%" stopColor="var(--color-businesses)" stopOpacity={0.1} />
              </linearGradient>
            </defs>
            <CartesianGrid vertical={false} />
            <XAxis
              dataKey="date"
              tickLine={false}
              axisLine={false}
              tickMargin={8}
              minTickGap={32}
              tickFormatter={(value) =>
                new Date(value).toLocaleDateString("en-US", {
                  month: "short",
                  day: "numeric",
                })
              }
            />
            <ChartTooltip
              cursor={false}
              content={
                <ChartTooltipContent
                  labelFormatter={(value) =>
                    new Date(value).toLocaleDateString("en-US", {
                      month: "short",
                      day: "numeric",
                    })
                  }
                  indicator="dot"
                />
              }
            />
            <Area
              dataKey="businesses"
              type="natural"
              fill="url(#analyticsBusinesses)"
              stroke="var(--color-businesses)"
              stackId="a"
            />
            <Area
              dataKey="professionals"
              type="natural"
              fill="url(#analyticsProfessionals)"
              stroke="var(--color-professionals)"
              stackId="a"
            />
            <Area
              dataKey="students"
              type="natural"
              fill="url(#analyticsStudents)"
              stroke="var(--color-students)"
              stackId="a"
            />
          </AreaChart>
        </ChartContainer>
      </CardContent>
    </Card>
  );
}
