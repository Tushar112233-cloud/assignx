"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { LucideIcon } from "lucide-react";
import { cn } from "@/lib/utils";

interface SidebarNavLinkProps {
  href: string;
  icon: LucideIcon;
  title: string;
  /** Whether to apply active styling when route matches */
  showActiveState?: boolean;
}

/**
 * Client-side navigation link with active state detection
 * Used in sidebar for route-aware styling
 */
export function SidebarNavLink({
  href,
  icon: Icon,
  title,
  showActiveState = true,
}: SidebarNavLinkProps) {
  const pathname = usePathname();
  const isActive = showActiveState && pathname === href;

  return (
    <Link
      href={href}
      className={cn(
        "flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors",
        isActive
          ? "bg-primary text-primary-foreground"
          : "text-muted-foreground hover:bg-muted hover:text-foreground"
      )}
    >
      <Icon className="h-5 w-5" />
      {title}
    </Link>
  );
}
