"use client";

import Link from "next/link";
import { SidebarTrigger, useSidebar } from "@/components/ui/sidebar";
import { WalletPill } from "@/components/dashboard/wallet-pill";
import { NotificationBell } from "@/components/dashboard/notification-bell";
import { AnimatedThemeToggler } from "@/components/ui/animated-theme-toggler";
import { Separator } from "@/components/ui/separator";
import { LanguageSelector } from "@/components/language-selector";
import { cn } from "@/lib/utils";

/**
 * Page title configuration for each route
 */
const pageTitles: Record<string, string> = {
  "/home": "Dashboard",
  "/projects": "Projects",
  "/profile": "Profile",
  "/settings": "Settings",
  "/connect": "Campus Connect",
  "/support": "Help & Support",
  "/payment-methods": "Payment Methods",
  "/wallet": "Wallet",
};

interface PageHeaderProps {
  /** Current page path (e.g., "/home", "/projects") */
  pathname?: string;
  /** Custom title override */
  title?: string;
  /** Additional className for the header */
  className?: string;
}

/**
 * Unified page header component with sidebar toggle, page title, and action icons
 * Follows Notion/Linear style minimalist design
 */
export function PageHeader({ pathname = "/home", title, className }: PageHeaderProps) {
  const pageTitle = title || pageTitles[pathname] || "Dashboard";

  return (
    <header
      className={cn(
        "sticky top-0 z-50",
        "bg-background/80 backdrop-blur-xl backdrop-saturate-150",
        "border-b border-border/40",
        "transition-all duration-200",
        className
      )}
    >
      <div className="flex h-14 items-center justify-between px-4 lg:px-6">
        {/* Left: Sidebar Toggle + Page Title */}
        <div className="flex items-center gap-3">
          <SidebarTrigger className="h-8 w-8 hover:bg-accent/80 transition-colors" />
          <Separator orientation="vertical" className="h-5 bg-border/60" />
          <h1 className="text-sm font-medium text-foreground/90 tracking-tight">
            {pageTitle}
          </h1>
        </div>

        {/* Right: Action Icons */}
        <div className="flex items-center gap-2">
          <LanguageSelector />
          <Separator orientation="vertical" className="h-5 bg-border/60 mx-1" />
          <WalletPill />
          <Separator orientation="vertical" className="h-5 bg-border/60 mx-1" />
          <NotificationBell />
          <AnimatedThemeToggler />
        </div>
      </div>
    </header>
  );
}
