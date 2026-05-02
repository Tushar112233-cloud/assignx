"use client";

import { Bar, BarChart, CartesianGrid, XAxis, YAxis, Pie, PieChart, Cell } from "recharts";
import {
  Card,
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

const PIE_COLORS = [
  "var(--primary)",
  "var(--chart-2)",
  "var(--chart-3)",
  "var(--chart-4)",
  "var(--chart-5)",
];

const pieConfig = {
  users: { label: "Users" },
  student: { label: "Students", color: PIE_COLORS[0] },
  professional: { label: "Professionals", color: PIE_COLORS[1] },
  business: { label: "Businesses", color: PIE_COLORS[2] },
  supervisor: { label: "Supervisors", color: PIE_COLORS[3] },
  doer: { label: "Doers", color: PIE_COLORS[4] },
} satisfies ChartConfig;

const barConfig = {
  count: { label: "Projects", color: "var(--primary)" },
} satisfies ChartConfig;

export function RevenueBreakdown({
  userTypeDistribution,
  topSubjects,
}: {
  userTypeDistribution: Record<string, number>;
  topSubjects: { name: string; count: number }[];
}) {
  const pieData = Object.entries(userTypeDistribution).map(([name, value], i) => ({
    name,
    value,
    fill: PIE_COLORS[i % PIE_COLORS.length],
  }));

  return (
    <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
      <Card>
        <CardHeader>
          <CardTitle>User Distribution</CardTitle>
          <CardDescription>Users by type</CardDescription>
        </CardHeader>
        <CardContent>
          <ChartContainer config={pieConfig} className="mx-auto aspect-square h-[280px]">
            <PieChart>
              <ChartTooltip content={<ChartTooltipContent hideLabel />} />
              <Pie
                data={pieData}
                dataKey="value"
                nameKey="name"
                cx="50%"
                cy="50%"
                innerRadius={60}
                outerRadius={100}
                paddingAngle={2}
              >
                {pieData.map((entry, index) => (
                  <Cell key={entry.name} fill={entry.fill} />
                ))}
              </Pie>
            </PieChart>
          </ChartContainer>
          <div className="mt-2 flex flex-wrap justify-center gap-4 text-sm">
            {pieData.map((entry) => (
              <div key={entry.name} className="flex items-center gap-2">
                <div
                  className="size-3 rounded-full"
                  style={{ backgroundColor: entry.fill }}
                />
                <span className="capitalize">{entry.name}</span>
                <span className="text-muted-foreground">({entry.value})</span>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Top Subjects</CardTitle>
          <CardDescription>Most popular project subjects</CardDescription>
        </CardHeader>
        <CardContent>
          {topSubjects.length > 0 ? (
            <ChartContainer config={barConfig} className="h-[300px] w-full">
              <BarChart
                data={topSubjects}
                layout="vertical"
                margin={{ left: 20 }}
              >
                <CartesianGrid horizontal={false} />
                <XAxis type="number" />
                <YAxis
                  dataKey="name"
                  type="category"
                  tickLine={false}
                  axisLine={false}
                  width={100}
                  tickFormatter={(value) =>
                    value.length > 15 ? value.slice(0, 15) + "..." : value
                  }
                />
                <ChartTooltip content={<ChartTooltipContent />} />
                <Bar
                  dataKey="count"
                  fill="var(--color-count)"
                  radius={[0, 4, 4, 0]}
                />
              </BarChart>
            </ChartContainer>
          ) : (
            <div className="flex h-[300px] items-center justify-center text-muted-foreground">
              No subject data available
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
