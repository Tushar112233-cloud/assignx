/**
 * @fileoverview Earnings visualization graphs with multiple chart types.
 * @module components/earnings/earnings-graph
 */

"use client"

import { useState } from "react"
import {
  Area,
  AreaChart,
  Bar,
  BarChart,
  CartesianGrid,
  Line,
  LineChart,
  XAxis,
  YAxis,
} from "recharts"
import { TrendingUp, Calendar } from "lucide-react"

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import {
  ChartConfig,
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
} from "@/components/ui/chart"
import { ChartDataPoint } from "./types"

const MONTHLY_DATA: ChartDataPoint[] = []
const WEEKLY_DATA: ChartDataPoint[] = []

const chartConfig = {
  earnings: {
    label: "Earnings",
    color: "hsl(142, 76%, 36%)",
  },
  commission: {
    label: "Commission",
    color: "hsl(221, 83%, 53%)",
  },
  projects: {
    label: "Projects",
    color: "hsl(262, 83%, 58%)",
  },
} satisfies ChartConfig

type ViewMode = "monthly" | "weekly"
type ChartType = "area" | "bar" | "line"

export function EarningsGraph() {
  const [viewMode, setViewMode] = useState<ViewMode>("monthly")
  const [chartType, setChartType] = useState<ChartType>("area")

  const data = viewMode === "monthly" ? MONTHLY_DATA : WEEKLY_DATA

  const totalEarnings = data.reduce((acc, d) => acc + d.earnings, 0)
  const totalCommission = data.reduce((acc, d) => acc + d.commission, 0)
  const totalProjects = data.reduce((acc, d) => acc + (d.projects || 0), 0)

  const avgMonthlyEarnings = totalEarnings / data.length

  return (
    <div className="space-y-6">
      {/* Summary Stats */}
      <div className="grid gap-6 md:grid-cols-4">
        <Card className="rounded-xl">
          <CardContent className="p-6">
            <p className="text-sm font-medium text-muted-foreground mb-1">
              {viewMode === "monthly" ? "6-Month" : "4-Week"} Total
            </p>
            <p className="text-3xl font-bold tracking-tight">
              {totalEarnings.toLocaleString("en-IN", {
                style: "currency",
                currency: "INR",
                maximumFractionDigits: 0,
              })}
            </p>
          </CardContent>
        </Card>
        <Card className="rounded-xl">
          <CardContent className="p-6">
            <p className="text-sm font-medium text-muted-foreground mb-1">Total Commission</p>
            <p className="text-3xl font-bold text-blue-600 tracking-tight">
              {totalCommission.toLocaleString("en-IN", {
                style: "currency",
                currency: "INR",
                maximumFractionDigits: 0,
              })}
            </p>
          </CardContent>
        </Card>
        <Card className="rounded-xl">
          <CardContent className="p-6">
            <p className="text-sm font-medium text-muted-foreground mb-1">Projects Completed</p>
            <p className="text-3xl font-bold tracking-tight">{totalProjects}</p>
          </CardContent>
        </Card>
        <Card className="rounded-xl">
          <CardContent className="p-6">
            <p className="text-sm font-medium text-muted-foreground mb-1">
              Avg {viewMode === "monthly" ? "Monthly" : "Weekly"}
            </p>
            <p className="text-3xl font-bold tracking-tight">
              {avgMonthlyEarnings.toLocaleString("en-IN", {
                style: "currency",
                currency: "INR",
                maximumFractionDigits: 0,
              })}
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Main Chart */}
      <Card className="rounded-xl">
        <CardHeader className="pb-2">
          <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
            <div>
              <CardTitle className="text-lg font-semibold flex items-center gap-2">
                <TrendingUp className="h-5 w-5 text-green-600" />
                Earnings Overview
              </CardTitle>
              <CardDescription>
                Your earnings and commission trends
              </CardDescription>
            </div>
            <div className="flex items-center gap-2">
              {/* View Mode Toggle */}
              <div className="flex items-center bg-muted rounded-lg p-1">
                <Button
                  variant={viewMode === "monthly" ? "default" : "ghost"}
                  size="sm"
                  onClick={() => setViewMode("monthly")}
                >
                  <Calendar className="h-4 w-4 mr-1" />
                  Monthly
                </Button>
                <Button
                  variant={viewMode === "weekly" ? "default" : "ghost"}
                  size="sm"
                  onClick={() => setViewMode("weekly")}
                >
                  Weekly
                </Button>
              </div>
              {/* Chart Type Toggle */}
              <div className="flex items-center bg-muted rounded-lg p-1">
                <Button
                  variant={chartType === "area" ? "default" : "ghost"}
                  size="sm"
                  onClick={() => setChartType("area")}
                >
                  Area
                </Button>
                <Button
                  variant={chartType === "bar" ? "default" : "ghost"}
                  size="sm"
                  onClick={() => setChartType("bar")}
                >
                  Bar
                </Button>
                <Button
                  variant={chartType === "line" ? "default" : "ghost"}
                  size="sm"
                  onClick={() => setChartType("line")}
                >
                  Line
                </Button>
              </div>
            </div>
          </div>
        </CardHeader>
        <CardContent className="p-6 pt-4">
          <ChartContainer config={chartConfig} className="h-[350px] w-full">
            {chartType === "area" ? (
              <AreaChart
                data={data}
                margin={{ top: 10, right: 10, left: 0, bottom: 0 }}
              >
                <CartesianGrid strokeDasharray="3 3" vertical={false} />
                <XAxis
                  dataKey="name"
                  tickLine={false}
                  axisLine={false}
                  tickMargin={8}
                />
                <YAxis
                  tickLine={false}
                  axisLine={false}
                  tickMargin={8}
                  tickFormatter={(value) => `₹${(value / 1000).toFixed(0)}k`}
                />
                <ChartTooltip
                  content={
                    <ChartTooltipContent
                      formatter={(value, name) => (
                        <span>
                          {typeof value === "number"
                            ? value.toLocaleString("en-IN", {
                                style: "currency",
                                currency: "INR",
                                maximumFractionDigits: 0,
                              })
                            : value}
                        </span>
                      )}
                    />
                  }
                />
                <defs>
                  <linearGradient id="fillEarnings" x1="0" y1="0" x2="0" y2="1">
                    <stop
                      offset="5%"
                      stopColor="var(--color-earnings)"
                      stopOpacity={0.8}
                    />
                    <stop
                      offset="95%"
                      stopColor="var(--color-earnings)"
                      stopOpacity={0.1}
                    />
                  </linearGradient>
                  <linearGradient id="fillCommission" x1="0" y1="0" x2="0" y2="1">
                    <stop
                      offset="5%"
                      stopColor="var(--color-commission)"
                      stopOpacity={0.8}
                    />
                    <stop
                      offset="95%"
                      stopColor="var(--color-commission)"
                      stopOpacity={0.1}
                    />
                  </linearGradient>
                </defs>
                <Area
                  type="monotone"
                  dataKey="earnings"
                  stroke="var(--color-earnings)"
                  fill="url(#fillEarnings)"
                  strokeWidth={2}
                />
                <Area
                  type="monotone"
                  dataKey="commission"
                  stroke="var(--color-commission)"
                  fill="url(#fillCommission)"
                  strokeWidth={2}
                />
              </AreaChart>
            ) : chartType === "bar" ? (
              <BarChart
                data={data}
                margin={{ top: 10, right: 10, left: 0, bottom: 0 }}
              >
                <CartesianGrid strokeDasharray="3 3" vertical={false} />
                <XAxis
                  dataKey="name"
                  tickLine={false}
                  axisLine={false}
                  tickMargin={8}
                />
                <YAxis
                  tickLine={false}
                  axisLine={false}
                  tickMargin={8}
                  tickFormatter={(value) => `₹${(value / 1000).toFixed(0)}k`}
                />
                <ChartTooltip
                  content={
                    <ChartTooltipContent
                      formatter={(value, name) => (
                        <span>
                          {typeof value === "number"
                            ? value.toLocaleString("en-IN", {
                                style: "currency",
                                currency: "INR",
                                maximumFractionDigits: 0,
                              })
                            : value}
                        </span>
                      )}
                    />
                  }
                />
                <Bar
                  dataKey="earnings"
                  fill="var(--color-earnings)"
                  radius={[4, 4, 0, 0]}
                />
                <Bar
                  dataKey="commission"
                  fill="var(--color-commission)"
                  radius={[4, 4, 0, 0]}
                />
              </BarChart>
            ) : (
              <LineChart
                data={data}
                margin={{ top: 10, right: 10, left: 0, bottom: 0 }}
              >
                <CartesianGrid strokeDasharray="3 3" vertical={false} />
                <XAxis
                  dataKey="name"
                  tickLine={false}
                  axisLine={false}
                  tickMargin={8}
                />
                <YAxis
                  tickLine={false}
                  axisLine={false}
                  tickMargin={8}
                  tickFormatter={(value) => `₹${(value / 1000).toFixed(0)}k`}
                />
                <ChartTooltip
                  content={
                    <ChartTooltipContent
                      formatter={(value, name) => (
                        <span>
                          {typeof value === "number"
                            ? value.toLocaleString("en-IN", {
                                style: "currency",
                                currency: "INR",
                                maximumFractionDigits: 0,
                              })
                            : value}
                        </span>
                      )}
                    />
                  }
                />
                <Line
                  type="monotone"
                  dataKey="earnings"
                  stroke="var(--color-earnings)"
                  strokeWidth={2}
                  dot={{ fill: "var(--color-earnings)", strokeWidth: 2 }}
                />
                <Line
                  type="monotone"
                  dataKey="commission"
                  stroke="var(--color-commission)"
                  strokeWidth={2}
                  dot={{ fill: "var(--color-commission)", strokeWidth: 2 }}
                />
              </LineChart>
            )}
          </ChartContainer>

          {/* Legend */}
          <div className="flex items-center justify-center gap-8 mt-6 pt-4 border-t">
            <div className="flex items-center gap-2">
              <div className="h-3 w-3 rounded-full bg-[hsl(142,76%,36%)]" />
              <span className="text-sm font-medium text-muted-foreground">Earnings</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="h-3 w-3 rounded-full bg-[hsl(221,83%,53%)]" />
              <span className="text-sm font-medium text-muted-foreground">Commission</span>
            </div>
          </div>
        </CardContent>
      </Card>

    </div>
  )
}
