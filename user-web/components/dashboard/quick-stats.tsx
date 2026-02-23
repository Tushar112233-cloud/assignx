"use client";

/**
 * QuickStats Component
 * Displays key metrics in a row of glass-morphism pills
 * Shows: Active Projects | Pending Actions | Wallet Balance
 */

import { FolderKanban, Clock, Wallet } from "lucide-react";
import { cn } from "@/lib/utils";

interface QuickStatsProps {
  activeProjects: number;
  pendingActions: number;
  walletBalance: number;
  className?: string;
}

/**
 * Individual stat pill component
 */
function StatPill({
  icon: Icon,
  label,
  value,
  highlight = false,
}: {
  icon: React.ElementType;
  label: string;
  value: string | number;
  highlight?: boolean;
}) {
  return (
    <div
      className={cn(
        "flex items-center gap-2 px-3 py-1.5 rounded-full",
        "bg-card/60 backdrop-blur-sm border border-border/50",
        "text-sm",
        highlight && "border-primary/30 bg-primary/5"
      )}
    >
      <Icon
        className={cn(
          "h-3.5 w-3.5",
          highlight ? "text-primary" : "text-muted-foreground"
        )}
        strokeWidth={1.5}
      />
      <span className="text-muted-foreground">{label}</span>
      <span className={cn("font-medium", highlight ? "text-primary" : "text-foreground")}>
        {value}
      </span>
    </div>
  );
}

/**
 * QuickStats - Row of stat pills for dashboard
 */
export function QuickStats({
  activeProjects,
  pendingActions,
  walletBalance,
  className,
}: QuickStatsProps) {
  // Format wallet balance
  const formattedBalance = new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency: "INR",
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  }).format(walletBalance);

  return (
    <div className={cn("flex flex-wrap items-center gap-2", className)}>
      <StatPill
        icon={FolderKanban}
        label="Active"
        value={activeProjects}
        highlight={activeProjects > 0}
      />
      <StatPill
        icon={Clock}
        label="Pending"
        value={pendingActions}
        highlight={pendingActions > 0}
      />
      <StatPill
        icon={Wallet}
        label="Wallet"
        value={formattedBalance}
      />
    </div>
  );
}
