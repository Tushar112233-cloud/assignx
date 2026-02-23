"use client";

import { type ReactNode } from "react";
import { cn } from "@/lib/utils";
import { TrendingUp, TrendingDown, Minus } from "lucide-react";
import { Skeleton } from "@/components/ui/skeleton";

export type StatColor =
  | "sage"
  | "terracotta"
  | "gray"
  | "blue"
  | "primary"
  | "secondary"
  | "accent"
  | "muted";

export interface StatTrend {
  direction: "up" | "down" | "neutral";
  value: number;
}

export interface SparklineDataPoint {
  value: number;
}

export interface StatCardProps {
  label: string;
  value: string | number;
  icon: ReactNode;
  color: StatColor;
  trend?: StatTrend;
  sparklineData?: SparklineDataPoint[];
  loading?: boolean;
  className?: string;
}

const colorClasses: Record<StatColor, string> = {
  sage: "bg-[var(--color-sage)]/10 text-[var(--color-sage)]",
  terracotta: "bg-[var(--color-terracotta)]/10 text-[var(--color-terracotta)]",
  gray: "bg-gray-100 text-gray-600 dark:bg-gray-800 dark:text-gray-300",
  blue: "bg-blue-50 text-blue-600 dark:bg-blue-950/50 dark:text-blue-400",
  primary: "bg-primary/10 text-primary",
  secondary: "bg-secondary text-secondary-foreground",
  accent: "bg-accent/30 text-accent-foreground",
  muted: "bg-muted text-muted-foreground",
};

const sparklineColors: Record<StatColor, string> = {
  sage: "var(--color-sage)",
  terracotta: "var(--color-terracotta)",
  gray: "var(--color-text-muted)",
  blue: "var(--color-info)",
  primary: "var(--color-sage)",
  secondary: "var(--color-text-muted)",
  accent: "var(--color-terracotta)",
  muted: "var(--color-text-placeholder)",
};

function Sparkline({
  data,
  width = 80,
  height = 40,
  color,
}: {
  data: SparklineDataPoint[];
  width?: number;
  height?: number;
  color: string;
}) {
  if (!data || data.length < 2) return null;

  const values = data.map((d) => d.value);
  const min = Math.min(...values);
  const max = Math.max(...values);
  const range = max - min || 1;

  const points = data
    .map((d, i) => {
      const x = (i / (data.length - 1)) * width;
      const y = height - ((d.value - min) / range) * height * 0.8 - height * 0.1;
      return `${x},${y}`;
    })
    .join(" ");

  const areaPath = `M0,${height} L${points} L${width},${height} Z`;

  return (
    <svg width={width} height={height} className="overflow-visible">
      <defs>
        <linearGradient id={`sparklineGradient-${color}`} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor={color} stopOpacity={0.3} />
          <stop offset="100%" stopColor={color} stopOpacity={0} />
        </linearGradient>
      </defs>
      <path d={areaPath} fill={`url(#sparklineGradient-${color})`} />
      <polyline
        points={points}
        fill="none"
        stroke={color}
        strokeWidth={2}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function TrendBadge({ trend }: { trend: StatTrend }) {
  const Icon =
    trend.direction === "up"
      ? TrendingUp
      : trend.direction === "down"
        ? TrendingDown
        : Minus;

  const colorClass =
    trend.direction === "up"
      ? "text-emerald-600 bg-emerald-50 dark:text-emerald-400 dark:bg-emerald-950/50"
      : trend.direction === "down"
        ? "text-red-600 bg-red-50 dark:text-red-400 dark:bg-red-950/50"
        : "text-amber-600 bg-amber-50 dark:text-amber-400 dark:bg-amber-950/50";

  return (
    <span
      className={cn(
        "inline-flex items-center gap-0.5 px-2 py-1 rounded-full text-xs font-semibold",
        colorClass
      )}
    >
      <Icon className="w-3.5 h-3.5" strokeWidth={2.5} />
      {trend.direction !== "neutral" && (trend.value > 0 ? "+" : "")}
      {Math.abs(trend.value).toFixed(1)}%
    </span>
  );
}

export function StatCardSkeleton({ className }: { className?: string }) {
  return (
    <div
      className={cn(
        "bg-white dark:bg-gray-900 rounded-xl border border-border/50 p-4",
        className
      )}
    >
      <div className="flex items-start justify-between">
        <Skeleton className="h-10 w-10 rounded-lg" />
        <Skeleton className="h-5 w-12 rounded-full" />
      </div>
      <div className="mt-3 space-y-2">
        <Skeleton className="h-4 w-20 rounded" />
        <Skeleton className="h-8 w-16 rounded" />
      </div>
    </div>
  );
}

export default function StatCard({
  label,
  value,
  icon,
  color,
  trend,
  sparklineData,
  loading,
  className,
}: StatCardProps) {
  if (loading) {
    return <StatCardSkeleton className={className} />;
  }

  const displayValue =
    typeof value === "number" ? value.toLocaleString() : value;

  return (
    <div
      className={cn(
        "bg-white dark:bg-gray-900 rounded-xl border border-border/50 p-4",
        className
      )}
    >
      <div className="flex items-start justify-between">
        <div
          className={cn(
            "w-10 h-10 rounded-lg flex items-center justify-center",
            colorClasses[color]
          )}
        >
          <div className="w-5 h-5">{icon}</div>
        </div>
        {trend && <TrendBadge trend={trend} />}
      </div>

      <div className="mt-3">
        <div className="flex items-end justify-between gap-3">
          <div className="flex-1">
            <p className="text-sm text-muted-foreground">{label}</p>
            <p className="text-2xl font-semibold text-foreground">{displayValue}</p>
          </div>
          {sparklineData && sparklineData.length > 1 && (
            <div className="flex-shrink-0">
              <Sparkline
                data={sparklineData}
                color={sparklineColors[color]}
              />
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
