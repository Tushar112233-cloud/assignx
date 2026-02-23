"use client";

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { cn } from "@/lib/utils";
import {
  AccountBadge,
  CompactAccountBadge,
  type AccountType,
} from "@/components/profile/account-badge";

/**
 * Props for UserBadge component
 */
interface UserBadgeProps {
  /** User's name */
  name: string;
  /** User's avatar URL */
  avatar?: string;
  /** User's account type */
  accountType?: AccountType;
  /** Whether the account is verified */
  isVerified?: boolean;
  /** Size variant */
  size?: "sm" | "md" | "lg";
  /** Additional text (e.g., email, role) */
  subtitle?: string;
  /** Whether to show the full badge or compact icon */
  compact?: boolean;
  /** Click handler */
  onClick?: () => void;
  /** Additional CSS classes */
  className?: string;
}

/**
 * Size configurations for UserBadge
 */
const sizeConfig = {
  sm: {
    avatar: "h-8 w-8",
    avatarText: "text-xs",
    name: "text-sm",
    subtitle: "text-xs",
  },
  md: {
    avatar: "h-10 w-10",
    avatarText: "text-sm",
    name: "text-sm font-medium",
    subtitle: "text-xs",
  },
  lg: {
    avatar: "h-12 w-12",
    avatarText: "text-base",
    name: "text-base font-medium",
    subtitle: "text-sm",
  },
};

/**
 * Gets initials from a name
 */
function getInitials(name: string): string {
  const parts = name.split(" ").filter(Boolean);
  if (parts.length >= 2) {
    return `${parts[0][0]}${parts[1][0]}`.toUpperCase();
  }
  return parts[0]?.[0]?.toUpperCase() || "?";
}

/**
 * UserBadge component displays user info with avatar and account type badge.
 *
 * Use this in chat headers, project cards, and user lists to show
 * consistent user information with their account type.
 *
 * @example
 * ```tsx
 * // In a chat header
 * <UserBadge
 *   name="John Doe"
 *   avatar="/avatars/john.jpg"
 *   accountType="professional"
 *   isVerified
 *   subtitle="Last seen 2m ago"
 * />
 *
 * // Compact version for lists
 * <UserBadge
 *   name="Jane Smith"
 *   accountType="student"
 *   compact
 *   size="sm"
 * />
 * ```
 */
export function UserBadge({
  name,
  avatar,
  accountType,
  isVerified = false,
  size = "md",
  subtitle,
  compact = false,
  onClick,
  className,
}: UserBadgeProps) {
  const sizes = sizeConfig[size];

  const content = (
    <div className={cn("flex items-center gap-3", className)}>
      {/* Avatar */}
      <div className="relative">
        <Avatar className={sizes.avatar}>
          <AvatarImage src={avatar} alt={name} />
          <AvatarFallback className={sizes.avatarText}>
            {getInitials(name)}
          </AvatarFallback>
        </Avatar>

        {/* Compact badge overlaid on avatar */}
        {compact && accountType && (
          <div className="absolute -bottom-1 -right-1">
            <CompactAccountBadge
              accountType={accountType}
              isVerified={isVerified}
            />
          </div>
        )}
      </div>

      {/* User info */}
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2">
          <span className={cn("truncate", sizes.name)}>{name}</span>

          {/* Full badge next to name */}
          {!compact && accountType && (
            <AccountBadge
              accountType={accountType}
              isVerified={isVerified}
              size="sm"
              showTooltip
            />
          )}
        </div>

        {subtitle && (
          <p className={cn("text-muted-foreground truncate", sizes.subtitle)}>
            {subtitle}
          </p>
        )}
      </div>
    </div>
  );

  if (onClick) {
    return (
      <button
        type="button"
        onClick={onClick}
        className="w-full text-left hover:bg-accent/50 rounded-lg p-2 -m-2 transition-colors"
      >
        {content}
      </button>
    );
  }

  return content;
}

/**
 * Props for UserAvatarWithBadge component
 */
interface UserAvatarWithBadgeProps {
  /** User's name */
  name: string;
  /** User's avatar URL */
  avatar?: string;
  /** User's account type */
  accountType?: AccountType;
  /** Whether the account is verified */
  isVerified?: boolean;
  /** Avatar size class */
  size?: string;
  /** Additional CSS classes */
  className?: string;
}

/**
 * Standalone avatar with account badge overlay.
 * Useful for places where you only need the avatar, not full user info.
 *
 * @example
 * ```tsx
 * <UserAvatarWithBadge
 *   name="John Doe"
 *   avatar="/avatars/john.jpg"
 *   accountType="student"
 *   isVerified
 *   size="h-16 w-16"
 * />
 * ```
 */
export function UserAvatarWithBadge({
  name,
  avatar,
  accountType,
  isVerified = false,
  size = "h-10 w-10",
  className,
}: UserAvatarWithBadgeProps) {
  return (
    <div className={cn("relative inline-block", className)}>
      <Avatar className={size}>
        <AvatarImage src={avatar} alt={name} />
        <AvatarFallback>{getInitials(name)}</AvatarFallback>
      </Avatar>

      {accountType && (
        <div className="absolute -bottom-1 -right-1">
          <CompactAccountBadge
            accountType={accountType}
            isVerified={isVerified}
          />
        </div>
      )}
    </div>
  );
}

export type { UserBadgeProps, UserAvatarWithBadgeProps };
