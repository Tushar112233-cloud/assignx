"use client";

import * as React from "react";
import { Area, AreaChart, CartesianGrid, XAxis } from "recharts";

import { useIsMobile } from "@/lib/hooks/use-mobile";
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
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  ToggleGroup,
  ToggleGroupItem,
} from "@/components/ui/toggle-group";

interface UserGrowthDataPoint {
  date: string;
  students: number;
  professionals: number;
  businesses: number;
}

interface RevenueDataPoint {
  date: string;
  revenue: number;
  refunds: number;
}

const userGrowthConfig = {
  users: { label: "Users" },
  students: { label: "Students", color: "var(--primary)" },
  professionals: { label: "Professionals", color: "var(--chart-2)" },
  businesses: { label: "Businesses", color: "var(--chart-3)" },
} satisfies ChartConfig;

const revenueConfig = {
  money: { label: "Money" },
  revenue: { label: "Revenue", color: "var(--primary)" },
  refunds: { label: "Refunds", color: "var(--chart-4)" },
} satisfies ChartConfig;

function filterByRange<T extends { date: string }>(
  data: T[],
  range: string
): T[] {
  if (data.length === 0) return data;
  const refDate = new Date(data[data.length - 1].date);
  const days = range === "7d" ? 7 : range === "30d" ? 30 : 90;
  const start = new Date(refDate);
  start.setDate(start.getDate() - days);
  return data.filter((d) => new Date(d.date) >= start);
}

export function AdminCharts({
  userGrowthData,
  revenueData,
}: {
  userGrowthData: UserGrowthDataPoint[];
  revenueData: RevenueDataPoint[];
}) {
  const isMobile = useIsMobile();
  const [userRange, setUserRange] = React.useState("30d");
  const [revenueRange, setRevenueRange] = React.useState("30d");

  React.useEffect(() => {
    if (isMobile) {
      setUserRange("7d");
      setRevenueRange("7d");
    }
  }, [isMobile]);

  const filteredUserData = filterByRange(userGrowthData, userRange);
  const filteredRevenueData = filterByRange(revenueData, revenueRange);

  return (
    <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
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
              value={userRange}
              onValueChange={setUserRange}
              variant="outline"
              className="hidden *:data-[slot=toggle-group-item]:!px-4 @[767px]/card:flex"
            >
              <ToggleGroupItem value="90d">3 months</ToggleGroupItem>
              <ToggleGroupItem value="30d">30 days</ToggleGroupItem>
              <ToggleGroupItem value="7d">7 days</ToggleGroupItem>
            </ToggleGroup>
            <Select value={userRange} onValueChange={setUserRange}>
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
            config={userGrowthConfig}
            className="aspect-auto h-[250px] w-full"
          >
            <AreaChart data={filteredUserData}>
              <defs>
                <linearGradient id="adminGrowth-fillStudents" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="var(--color-students)" stopOpacity={1.0} />
                  <stop offset="95%" stopColor="var(--color-students)" stopOpacity={0.1} />
                </linearGradient>
                <linearGradient id="adminGrowth-fillProfessionals" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="var(--color-professionals)" stopOpacity={0.8} />
                  <stop offset="95%" stopColor="var(--color-professionals)" stopOpacity={0.1} />
                </linearGradient>
                <linearGradient id="adminGrowth-fillBusinesses" x1="0" y1="0" x2="0" y2="1">
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
                fill="url(#adminGrowth-fillBusinesses)"
                stroke="var(--color-businesses)"
                stackId="a"
              />
              <Area
                dataKey="professionals"
                type="natural"
                fill="url(#adminGrowth-fillProfessionals)"
                stroke="var(--color-professionals)"
                stackId="a"
              />
              <Area
                dataKey="students"
                type="natural"
                fill="url(#adminGrowth-fillStudents)"
                stroke="var(--color-students)"
                stackId="a"
              />
            </AreaChart>
          </ChartContainer>
        </CardContent>
      </Card>

      <Card className="@container/card">
        <CardHeader>
          <CardTitle>Revenue</CardTitle>
          <CardDescription>
            <span className="hidden @[540px]/card:block">
              Revenue and refunds over time
            </span>
            <span className="@[540px]/card:hidden">Revenue</span>
          </CardDescription>
          <CardAction>
            <ToggleGroup
              type="single"
              value={revenueRange}
              onValueChange={setRevenueRange}
              variant="outline"
              className="hidden *:data-[slot=toggle-group-item]:!px-4 @[767px]/card:flex"
            >
              <ToggleGroupItem value="90d">3 months</ToggleGroupItem>
              <ToggleGroupItem value="30d">30 days</ToggleGroupItem>
              <ToggleGroupItem value="7d">7 days</ToggleGroupItem>
            </ToggleGroup>
            <Select value={revenueRange} onValueChange={setRevenueRange}>
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
            config={revenueConfig}
            className="aspect-auto h-[250px] w-full"
          >
            <AreaChart data={filteredRevenueData}>
              <defs>
                <linearGradient id="adminRevenue-fillRevenue" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="var(--color-revenue)" stopOpacity={1.0} />
                  <stop offset="95%" stopColor="var(--color-revenue)" stopOpacity={0.1} />
                </linearGradient>
                <linearGradient id="adminRevenue-fillRefunds" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="var(--color-refunds)" stopOpacity={0.8} />
                  <stop offset="95%" stopColor="var(--color-refunds)" stopOpacity={0.1} />
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
                dataKey="refunds"
                type="natural"
                fill="url(#adminRevenue-fillRefunds)"
                stroke="var(--color-refunds)"
                stackId="a"
              />
              <Area
                dataKey="revenue"
                type="natural"
                fill="url(#adminRevenue-fillRevenue)"
                stroke="var(--color-revenue)"
                stackId="a"
              />
            </AreaChart>
          </ChartContainer>
        </CardContent>
      </Card>
    </div>
  );
}
