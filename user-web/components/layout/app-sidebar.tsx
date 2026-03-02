"use client";

import * as React from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  Home,
  FolderKanban,
  Users,
  Wallet,
  CreditCard,
  User,
  Settings,
  HelpCircle,
  LogOut,
  Sparkles,
} from "lucide-react";
import { logout } from "@/lib/api/auth";
import { useRouter } from "next/navigation";
import { toast } from "sonner";
import { useI18n } from "@/lib/i18n/context";

import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarGroup,
  SidebarGroupContent,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarSeparator,
  useSidebar,
} from "@/components/ui/sidebar";
import { cn } from "@/lib/utils";

/**
 * Static nav data — titles resolved via i18n inside the component
 */
const MAIN_NAV_STATIC = [
  { key: "nav.dashboard" as const, href: "/home", icon: Home },
  { key: "nav.projects" as const, href: "/projects", icon: FolderKanban },
  { key: "nav.campus_connect" as const, href: "/connect", icon: Users },
];

const FINANCE_NAV_STATIC = [
  { key: "nav.wallet" as const, href: "/wallet", icon: Wallet },
  { key: "nav.payment_methods" as const, href: "/payment-methods", icon: CreditCard },
];

const ACCOUNT_NAV_STATIC = [
  { key: "nav.profile" as const, href: "/profile", icon: User },
  { key: "nav.settings" as const, href: "/settings", icon: Settings },
  { key: "nav.help_support" as const, href: "/support", icon: HelpCircle },
];

/**
 * App sidebar component with navigation
 * Follows Notion/Linear style minimalist design
 */
export function AppSidebar() {
  const pathname = usePathname();
  const router = useRouter();
  const { state } = useSidebar();
  const isCollapsed = state === "collapsed";
  const { t } = useI18n();

  const mainNavItems = MAIN_NAV_STATIC.map((item) => ({ ...item, title: t(item.key) }));
  const financeNavItems = FINANCE_NAV_STATIC.map((item) => ({ ...item, title: t(item.key) }));
  const accountNavItems = ACCOUNT_NAV_STATIC.map((item) => ({ ...item, title: t(item.key) }));

  const handleLogout = async () => {
    try {
      logout();
      toast.success("Logged out successfully");
      router.push("/login");
    } catch (error) {
      toast.error("Failed to log out");
    }
  };

  return (
    <Sidebar collapsible="icon" className="border-r border-border/40">
      {/* Header with Logo */}
      <SidebarHeader className="h-14 flex items-center justify-center border-b border-border/40">
        <Link
          href="/home"
          className={cn(
            "flex items-center gap-2.5 transition-opacity hover:opacity-80",
            isCollapsed && "justify-center"
          )}
        >
          <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary text-primary-foreground">
            <Sparkles className="h-4 w-4" />
          </div>
          {!isCollapsed && (
            <span className="font-semibold text-sm tracking-tight">AssignX</span>
          )}
        </Link>
      </SidebarHeader>

      {/* Main Content */}
      <SidebarContent className="px-2 py-4">
        {/* Main Navigation */}
        <SidebarGroup>
          <SidebarGroupContent>
            <SidebarMenu>
              {mainNavItems.map((item) => (
                <SidebarMenuItem key={item.href}>
                  <SidebarMenuButton
                    asChild
                    isActive={pathname === item.href}
                    tooltip={item.title}
                  >
                    <Link href={item.href}>
                      <item.icon className="h-4 w-4" />
                      <span>{item.title}</span>
                    </Link>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              ))}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>

        <SidebarSeparator className="my-2" />

        {/* Finance Navigation */}
        <SidebarGroup>
          <SidebarGroupContent>
            <SidebarMenu>
              {financeNavItems.map((item) => (
                <SidebarMenuItem key={item.href}>
                  <SidebarMenuButton
                    asChild
                    isActive={pathname === item.href}
                    tooltip={item.title}
                  >
                    <Link href={item.href}>
                      <item.icon className="h-4 w-4" />
                      <span>{item.title}</span>
                    </Link>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              ))}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>

        <SidebarSeparator className="my-2" />

        {/* Account Navigation */}
        <SidebarGroup>
          <SidebarGroupContent>
            <SidebarMenu>
              {accountNavItems.map((item) => (
                <SidebarMenuItem key={item.href}>
                  <SidebarMenuButton
                    asChild
                    isActive={pathname === item.href}
                    tooltip={item.title}
                  >
                    <Link href={item.href}>
                      <item.icon className="h-4 w-4" />
                      <span>{item.title}</span>
                    </Link>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              ))}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>
      </SidebarContent>

      {/* Footer with Logout */}
      <SidebarFooter className="border-t border-border/40 p-2">
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton
              onClick={handleLogout}
              tooltip="Log out"
              className="text-muted-foreground hover:text-destructive hover:bg-destructive/10"
            >
              <LogOut className="h-4 w-4" />
              <span>Log out</span>
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarFooter>
    </Sidebar>
  );
}
