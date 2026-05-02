"use client";

import { GraduationCap, Briefcase, Building2, CheckCircle, LucideIcon } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import {
  Tooltip,
  TooltipContent,
  TooltipTrigger,
} from "@/components/ui/tooltip";
import { cn } from "@/lib/utils";

/**
 * Account type options
 */
export type AccountType = "student" | "professional" | "business_owner";

/**
 * Badge size variants
 */
export type BadgeSize = "sm" | "md" | "lg";

/**
 * Props for the AccountBadge component
 */
interface AccountBadgeProps {
  /** The type of account to display */
  accountType: AccountType;
  /** Whether the account is verified */
  isVerified?: boolean;
  /** Size variant of the badge */
  size?: BadgeSize;
  /** Whether to show the tooltip on hover */
  showTooltip?: boolean;
  /** Additional CSS classes */
  className?: string;
}

/**
 * Configuration for each account type
 */
interface BadgeConfig {
  label: string;
  icon: LucideIcon;
  className: string;
  description: string;
}

/**
 * Badge configuration mapping for each account type
 */
const badgeConfig: Record<AccountType, BadgeConfig> = {
  student: {
    label: "Student",
    icon: GraduationCap,
    className: "bg-blue-100 text-blue-700 border-blue-200 hover:bg-blue-150 dark:bg-blue-900/30 dark:text-blue-400 dark:border-blue-800",
    description: "Currently pursuing education at a recognized institution",
  },
  professional: {
    label: "Professional",
    icon: Briefcase,
    className: "bg-amber-100 text-amber-700 border-amber-200 hover:bg-amber-150 dark:bg-amber-900/30 dark:text-amber-400 dark:border-amber-800",
    description: "Working professional with verified credentials",
  },
  business_owner: {
    label: "Business",
    icon: Building2,
    className: "bg-purple-100 text-purple-700 border-purple-200 hover:bg-purple-150 dark:bg-purple-900/30 dark:text-purple-400 dark:border-purple-800",
    description: "Registered business owner or entrepreneur",
  },
};

/**
 * Size configuration for icons and text
 */
const sizeConfig: Record<BadgeSize, { icon: string; text: string; padding: string }> = {
  sm: {
    icon: "w-3 h-3",
    text: "text-xs",
    padding: "px-1.5 py-0.5",
  },
  md: {
    icon: "w-3.5 h-3.5",
    text: "text-xs",
    padding: "px-2 py-0.5",
  },
  lg: {
    icon: "w-4 h-4",
    text: "text-sm",
    padding: "px-2.5 py-1",
  },
};

/**
 * AccountBadge component displays a visual badge indicating the user's account type.
 *
 * Features:
 * - Color-coded by account type (Student: Blue, Professional: Amber, Business: Purple)
 * - Optional verification checkmark overlay
 * - Multiple size variants (sm, md, lg)
 * - Hover tooltip with full description
 * - Dark mode support
 *
 * @example
 * ```tsx
 * // Basic usage
 * <AccountBadge accountType="student" />
 *
 * // With verification
 * <AccountBadge accountType="professional" isVerified />
 *
 * // Large size with tooltip
 * <AccountBadge accountType="business_owner" size="lg" showTooltip />
 * ```
 */
export function AccountBadge({
  accountType,
  isVerified = false,
  size = "md",
  showTooltip = true,
  className,
}: AccountBadgeProps) {
  const config = badgeConfig[accountType];
  const sizes = sizeConfig[size];
  const Icon = config.icon;

  const badgeContent = (
    <Badge
      className={cn(
        "inline-flex items-center gap-1 font-medium transition-colors",
        config.className,
        sizes.padding,
        sizes.text,
        className
      )}
    >
      <Icon className={sizes.icon} />
      <span>{config.label}</span>
      {isVerified && (
        <CheckCircle
          className={cn(
            sizes.icon,
            "text-green-500 dark:text-green-400 ml-0.5"
          )}
        />
      )}
    </Badge>
  );

  if (!showTooltip) {
    return badgeContent;
  }

  return (
    <Tooltip>
      <TooltipTrigger asChild>
        {badgeContent}
      </TooltipTrigger>
      <TooltipContent side="bottom" className="max-w-xs">
        <div className="space-y-1">
          <p className="font-medium">{config.label} Account</p>
          <p className="text-xs text-muted-foreground">{config.description}</p>
          {isVerified && (
            <p className="text-xs text-green-500 flex items-center gap-1">
              <CheckCircle className="w-3 h-3" />
              Verified account
            </p>
          )}
        </div>
      </TooltipContent>
    </Tooltip>
  );
}

/**
 * Compact badge variant for use in lists and cards
 */
interface CompactAccountBadgeProps {
  accountType: AccountType;
  isVerified?: boolean;
  className?: string;
}

/**
 * A compact version of AccountBadge that only shows the icon.
 * Useful for tight spaces like project cards and user lists.
 *
 * @example
 * ```tsx
 * <CompactAccountBadge accountType="student" isVerified />
 * ```
 */
export function CompactAccountBadge({
  accountType,
  isVerified = false,
  className,
}: CompactAccountBadgeProps) {
  const config = badgeConfig[accountType];
  const Icon = config.icon;

  return (
    <Tooltip>
      <TooltipTrigger asChild>
        <span
          className={cn(
            "inline-flex items-center justify-center w-6 h-6 rounded-full",
            config.className,
            className
          )}
        >
          <Icon className="w-3.5 h-3.5" />
          {isVerified && (
            <span className="absolute -bottom-0.5 -right-0.5 w-3 h-3 bg-white dark:bg-gray-900 rounded-full flex items-center justify-center">
              <CheckCircle className="w-2.5 h-2.5 text-green-500" />
            </span>
          )}
        </span>
      </TooltipTrigger>
      <TooltipContent side="bottom">
        <span>{config.label}</span>
        {isVerified && <span className="text-green-500 ml-1">(Verified)</span>}
      </TooltipContent>
    </Tooltip>
  );
}

/**
 * Helper function to get account type from string
 */
export function getAccountType(value: string | null | undefined): AccountType {
  if (!value) return "student";

  const normalized = value.toLowerCase().replace(/[_-]/g, "_");
  if (normalized === "professional") return "professional";
  if (normalized === "business_owner" || normalized === "business") return "business_owner";
  return "student";
}

/**
 * Export badge config for external use
 */
export { badgeConfig };
