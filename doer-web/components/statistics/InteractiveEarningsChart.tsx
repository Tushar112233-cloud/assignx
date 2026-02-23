"use client";

import { useState } from "react";
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts";
import { Button } from "@/components/ui/button";
import { TrendingUp, BarChart3 } from "lucide-react";

/**
 * Data point for the earnings chart
 */
export interface EarningsDataPoint {
  date: string;
  amount: number;
  projects: number;
}

/**
 * Props for InteractiveEarningsChart component
 */
export interface InteractiveEarningsChartProps {
  /** Chart data with date, amount, and project count */
  data: EarningsDataPoint[];
  /** Current chart type to display */
  chartType: "earnings" | "projects";
  /** Callback when chart type changes */
  onChartTypeChange: (type: "earnings" | "projects") => void;
}

/**
 * Custom tooltip component for the chart
 */
const CustomTooltip = ({
  active,
  payload,
  label,
  chartType,
}: {
  active?: boolean;
  payload?: ReadonlyArray<{ value: number }>;
  label?: string | number;
  chartType: "earnings" | "projects";
}) => {
  if (active && payload && payload.length) {
    return (
      <div className="rounded-lg bg-white p-3 shadow-lg border border-gray-200">
        <p className="text-sm font-medium text-gray-900">{label}</p>
        <p className="text-sm text-gray-600">
          {chartType === "earnings" ? (
            <>
              <span className="font-semibold text-teal-600">
                ₹{payload[0].value.toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
              </span>{" "}
              earned
            </>
          ) : (
            <>
              <span className="font-semibold text-emerald-600">
                {payload[0].value}
              </span>{" "}
              projects
            </>
          )}
        </p>
      </div>
    );
  }
  return null;
};

/**
 * InteractiveEarningsChart - Displays earnings or project count over time
 *
 * Features:
 * - Toggle between earnings and project count views
 * - Smooth gradient area chart with animations
 * - Custom tooltip showing exact values
 * - Fully responsive design
 *
 * @example
 * ```tsx
 * <InteractiveEarningsChart
 *   data={earningsData}
 *   chartType="earnings"
 *   onChartTypeChange={(type) => setChartType(type)}
 * />
 * ```
 */
export function InteractiveEarningsChart({
  data,
  chartType,
  onChartTypeChange,
}: InteractiveEarningsChartProps) {
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null);

  const chartConfig = {
    earnings: {
      color: "#14b8a6", // teal-500
      gradientStart: "#14b8a6",
      gradientEnd: "#10b981", // emerald-500
      label: "Earnings",
      icon: TrendingUp,
      formatter: (value: number) => `₹${value.toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`,
    },
    projects: {
      color: "#10b981", // emerald-500
      gradientStart: "#10b981",
      gradientEnd: "#06b6d4", // cyan-500
      label: "Projects",
      icon: BarChart3,
      formatter: (value: number) => `${value}`,
    },
  };

  const config = chartConfig[chartType];
  const Icon = config.icon;

  return (
    <div className="rounded-[24px] bg-white/85 p-6 shadow-[0_16px_35px_rgba(30,58,138,0.08)] backdrop-blur-sm transition-all duration-300 hover:shadow-[0_20px_40px_rgba(30,58,138,0.12)]">
      {/* Header with toggle buttons */}
      <div className="mb-6 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="rounded-xl bg-gradient-to-br from-teal-500 to-emerald-500 p-2.5 shadow-lg">
            <Icon className="h-5 w-5 text-white" />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-gray-900">
              {config.label} Overview
            </h3>
            <p className="text-sm text-gray-500">Last 12 months</p>
          </div>
        </div>

        {/* Toggle buttons */}
        <div className="flex gap-2">
          <Button
            variant={chartType === "earnings" ? "default" : "outline"}
            size="sm"
            onClick={() => onChartTypeChange("earnings")}
            className={`
              rounded-xl transition-all duration-300
              ${
                chartType === "earnings"
                  ? "bg-gradient-to-r from-teal-500 to-emerald-500 text-white shadow-md hover:shadow-lg"
                  : "border-gray-200 text-gray-600 hover:bg-gray-50"
              }
            `}
          >
            <TrendingUp className="mr-1.5 h-4 w-4" />
            Earnings
          </Button>
          <Button
            variant={chartType === "projects" ? "default" : "outline"}
            size="sm"
            onClick={() => onChartTypeChange("projects")}
            className={`
              rounded-xl transition-all duration-300
              ${
                chartType === "projects"
                  ? "bg-gradient-to-r from-emerald-500 to-cyan-500 text-white shadow-md hover:shadow-lg"
                  : "border-gray-200 text-gray-600 hover:bg-gray-50"
              }
            `}
          >
            <BarChart3 className="mr-1.5 h-4 w-4" />
            Projects
          </Button>
        </div>
      </div>

      {/* Chart */}
      <div className="h-[280px] w-full">
        <ResponsiveContainer width="100%" height="100%" minWidth={0} debounce={50}>
          <AreaChart
            data={data}
            margin={{ top: 10, right: 10, left: 0, bottom: 0 }}
            onMouseMove={(state) => {
              if (state.isTooltipActive && typeof state.activeTooltipIndex === 'number') {
                setHoveredIndex(state.activeTooltipIndex);
              } else {
                setHoveredIndex(null);
              }
            }}
            onMouseLeave={() => setHoveredIndex(null)}
          >
            <defs>
              <linearGradient id="colorGradient" x1="0" y1="0" x2="0" y2="1">
                <stop
                  offset="5%"
                  stopColor={config.gradientStart}
                  stopOpacity={0.3}
                />
                <stop
                  offset="95%"
                  stopColor={config.gradientEnd}
                  stopOpacity={0.05}
                />
              </linearGradient>
            </defs>
            <CartesianGrid
              strokeDasharray="3 3"
              stroke="#e5e7eb"
              vertical={false}
            />
            <XAxis
              dataKey="date"
              tick={{ fill: "#6b7280", fontSize: 12 }}
              tickLine={false}
              axisLine={{ stroke: "#e5e7eb" }}
            />
            <YAxis
              tick={{ fill: "#6b7280", fontSize: 12 }}
              tickLine={false}
              axisLine={{ stroke: "#e5e7eb" }}
              tickFormatter={config.formatter}
            />
            <Tooltip
              content={(props) => (
                <CustomTooltip {...props} chartType={chartType} />
              )}
              cursor={{ stroke: config.color, strokeWidth: 2 }}
            />
            <Area
              type="monotone"
              dataKey={chartType === "earnings" ? "amount" : "projects"}
              stroke={config.color}
              strokeWidth={3}
              fill="url(#colorGradient)"
              animationDuration={1000}
              animationEasing="ease-in-out"
            />
          </AreaChart>
        </ResponsiveContainer>
      </div>

      {/* Summary stats */}
      <div className="mt-6 grid grid-cols-3 gap-4 border-t border-gray-100 pt-4">
        <div className="text-center">
          <p className="text-xs font-medium text-gray-500 uppercase tracking-wide">
            Total
          </p>
          <p className="mt-1 text-lg font-bold text-gray-900">
            {chartType === "earnings"
              ? `₹${data.reduce((sum, item) => sum + item.amount, 0).toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
              : data.reduce((sum, item) => sum + item.projects, 0)}
          </p>
        </div>
        <div className="text-center">
          <p className="text-xs font-medium text-gray-500 uppercase tracking-wide">
            Average
          </p>
          <p className="mt-1 text-lg font-bold text-gray-900">
            {chartType === "earnings"
              ? `₹${(data.length > 0 ? data.reduce((sum, item) => sum + item.amount, 0) / data.length : 0).toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
              : data.length > 0 ? Math.round(data.reduce((sum, item) => sum + item.projects, 0) / data.length) : 0}
          </p>
        </div>
        <div className="text-center">
          <p className="text-xs font-medium text-gray-500 uppercase tracking-wide">
            Peak
          </p>
          <p className="mt-1 text-lg font-bold text-gray-900">
            {chartType === "earnings"
              ? `₹${(data.length > 0 ? Math.max(...data.map((item) => item.amount)) : 0).toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
              : data.length > 0 ? Math.max(...data.map((item) => item.projects)) : 0}
          </p>
        </div>
      </div>
    </div>
  );
}
