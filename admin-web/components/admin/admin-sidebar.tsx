"use client";

import { useState, useEffect, type ComponentType } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { motion, AnimatePresence } from "framer-motion";
import {
  IconBook2,
  IconChartBar,
  IconChevronRight,
  IconCreditCard,
  IconDashboard,
  IconDotsVertical,
  IconEye,
  IconFolder,
  IconHelp,
  IconLogout,
  IconMessage,
  IconPhoto,
  IconReport,
  IconSchool,
  IconSettings,
  IconShield,
  IconStar,
  IconUser,
  IconUsers,
  IconLayersLinked,
  IconUserScan,
  IconTools,
} from "@tabler/icons-react";
import { cn } from "@/lib/utils";

import { logoutAdmin } from "@/app/login/actions";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import {
  Collapsible,
  CollapsibleTrigger,
} from "@/components/ui/collapsible";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarHeader,
  SidebarGroup,
  SidebarGroupContent,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarSeparator,
  useSidebar,
} from "@/components/ui/sidebar";
import type { AdminSession } from "@/lib/admin/auth";

// ============================================================================
// Animation Configuration
// ============================================================================

const smoothEase = [0.16, 1, 0.3, 1] as const;

// ============================================================================
// Types
// ============================================================================

interface NavItem {
  title: string;
  url: string;
  icon: ComponentType<{ className?: string }>;
  exact?: boolean;
}

interface NavSection {
  label: string;
  icon: ComponentType<{ className?: string }>;
  items: NavItem[];
}

// ============================================================================
// Navigation Configuration
// ============================================================================

const mainNav: NavItem[] = [
  { title: "Dashboard", url: "/", icon: IconDashboard, exact: true },
];

const sections: NavSection[] = [
  {
    label: "Management",
    icon: IconLayersLinked,
    items: [
      { title: "Users", url: "/users", icon: IconUsers },
      { title: "Projects", url: "/projects", icon: IconFolder },
      { title: "Messages", url: "/messages", icon: IconMessage },
      { title: "Wallets", url: "/wallets", icon: IconCreditCard },
      { title: "Support", url: "/support", icon: IconHelp },
    ],
  },
  {
    label: "People",
    icon: IconUserScan,
    items: [
      { title: "Supervisors", url: "/supervisors", icon: IconShield },
      { title: "Doers", url: "/doers", icon: IconUser },
      { title: "Experts", url: "/experts", icon: IconStar },
    ],
  },
  {
    label: "Content & Tools",
    icon: IconTools,
    items: [
      { title: "Moderation", url: "/moderation", icon: IconEye },
      { title: "Banners", url: "/banners", icon: IconPhoto },
      { title: "Colleges", url: "/colleges", icon: IconSchool },
      { title: "Learning", url: "/learning", icon: IconBook2 },
      { title: "Analytics", url: "/analytics", icon: IconChartBar },
      { title: "Reports", url: "/reports", icon: IconReport },
    ],
  },
];

// ============================================================================
// Helper
// ============================================================================

function getInitials(name: string): string {
  return name
    .split(/[\s@]+/)
    .slice(0, 2)
    .map((s) => s[0])
    .join("")
    .toUpperCase();
}

// ============================================================================
// Nav Link - Clean, No Icon Backgrounds
// ============================================================================

function NavLink({
  item,
  isActive,
}: {
  item: NavItem;
  isActive: boolean;
}) {
  const Icon = item.icon;

  return (
    <Link
      href={item.url}
      className={cn(
        "group flex items-center gap-2.5 px-2.5 py-1.5 rounded-lg text-sm font-medium transition-colors duration-150",
        isActive
          ? "text-primary bg-primary/8"
          : "text-muted-foreground hover:text-foreground hover:bg-muted/50"
      )}
    >
      <Icon
        className={cn(
          "h-4 w-4 shrink-0 transition-colors",
          isActive
            ? "text-primary"
            : "text-muted-foreground/60 group-hover:text-foreground"
        )}
      />
      <span className="flex-1">{item.title}</span>
    </Link>
  );
}

// ============================================================================
// Sub Nav Link - With Tree Connector Lines
// ============================================================================

function SubNavLink({
  item,
  isActive,
  isLast,
}: {
  item: NavItem;
  isActive: boolean;
  isLast: boolean;
}) {
  return (
    <div className="relative">
      {/* Tree connector - vertical line */}
      <div
        className={cn(
          "absolute left-[11px] top-0 w-px",
          isLast ? "h-[14px]" : "h-full",
          isActive ? "bg-primary/40" : "bg-border"
        )}
      />
      {/* Tree connector - horizontal branch */}
      <div
        className={cn(
          "absolute left-[11px] top-[14px] w-2 h-px",
          isActive ? "bg-primary/40" : "bg-border"
        )}
      />

      <Link
        href={item.url}
        className={cn(
          "block pl-6 pr-2.5 py-1 text-sm transition-colors duration-150 rounded-md mx-0.5",
          isActive
            ? "text-primary font-medium"
            : "text-muted-foreground hover:text-foreground font-normal"
        )}
      >
        {item.title}
      </Link>
    </div>
  );
}

// ============================================================================
// Section Header - Icon + Label + Chevron
// ============================================================================

function SectionHeader({
  icon: Icon,
  label,
  isOpen,
}: {
  icon: ComponentType<{ className?: string }>;
  label: string;
  isOpen: boolean;
}) {
  return (
    <CollapsibleTrigger className="flex w-full items-center gap-2.5 px-2.5 py-1.5 rounded-lg text-sm font-medium text-muted-foreground hover:text-foreground transition-colors duration-150">
      <Icon className="h-4 w-4 shrink-0 text-muted-foreground/60" />
      <span className="flex-1 text-left">{label}</span>
      <IconChevronRight
        className={cn(
          "h-3.5 w-3.5 shrink-0 text-muted-foreground/40 transition-transform duration-200",
          isOpen && "rotate-90"
        )}
      />
    </CollapsibleTrigger>
  );
}

// ============================================================================
// Collapsible Nav Section
// ============================================================================

function CollapsibleSection({
  section,
  isOpen,
  onToggle,
  isActiveFn,
  mounted,
}: {
  section: NavSection;
  isOpen: boolean;
  onToggle: () => void;
  isActiveFn: (url: string, exact?: boolean) => boolean;
  mounted: boolean;
}) {
  if (!mounted) {
    // Static SSR render to prevent hydration mismatch
    return (
      <div>
        <div className="flex items-center gap-2.5 px-2.5 py-1.5 text-sm font-medium text-muted-foreground">
          <section.icon className="h-4 w-4 shrink-0 text-muted-foreground/60" />
          <span>{section.label}</span>
        </div>
        <div className="mt-0.5 ml-0.5">
          {section.items.map((item, idx) => (
            <SubNavLink
              key={item.url}
              item={item}
              isActive={isActiveFn(item.url, item.exact)}
              isLast={idx === section.items.length - 1}
            />
          ))}
        </div>
      </div>
    );
  }

  return (
    <Collapsible open={isOpen} onOpenChange={onToggle}>
      <SectionHeader
        icon={section.icon}
        label={section.label}
        isOpen={isOpen}
      />
      <AnimatePresence initial={false}>
        {isOpen && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: "auto", opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.15, ease: smoothEase }}
            className="overflow-hidden mt-0.5 ml-0.5"
          >
            {section.items.map((item, idx) => (
              <SubNavLink
                key={item.url}
                item={item}
                isActive={isActiveFn(item.url, item.exact)}
                isLast={idx === section.items.length - 1}
              />
            ))}
          </motion.div>
        )}
      </AnimatePresence>
    </Collapsible>
  );
}

// ============================================================================
// Admin Nav User - Footer with Dropdown
// ============================================================================

function AdminNavUser({ admin }: { admin: AdminSession }) {
  const { isMobile } = useSidebar();
  const router = useRouter();
  const name = admin.email.split("@")[0];
  const initials = getInitials(admin.email);

  return (
    <SidebarMenu>
      <SidebarMenuItem>
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <SidebarMenuButton
              size="lg"
              className="data-[state=open]:bg-sidebar-accent data-[state=open]:text-sidebar-accent-foreground group/user hover:bg-sidebar-accent/50 transition-colors"
            >
              <Avatar className="h-8 w-8 rounded-lg">
                <AvatarFallback className="rounded-lg text-xs bg-primary/10 text-primary font-medium">
                  {initials}
                </AvatarFallback>
              </Avatar>
              <div className="grid flex-1 text-left text-sm leading-tight">
                <span className="truncate font-medium">{name}</span>
                <span className="text-muted-foreground truncate text-xs">
                  {admin.email}
                </span>
              </div>
              <IconDotsVertical className="ml-auto size-4 text-muted-foreground/60" />
            </SidebarMenuButton>
          </DropdownMenuTrigger>
          <DropdownMenuContent
            className="w-(--radix-dropdown-menu-trigger-width) min-w-56 rounded-xl"
            side={isMobile ? "bottom" : "right"}
            align="end"
            sideOffset={4}
          >
            <DropdownMenuLabel className="p-0 font-normal">
              <div className="flex items-center gap-3 px-2 py-2.5 text-left text-sm">
                <Avatar className="h-9 w-9 rounded-lg">
                  <AvatarFallback className="rounded-lg text-xs bg-primary/10 text-primary font-medium">
                    {initials}
                  </AvatarFallback>
                </Avatar>
                <div className="grid flex-1 text-left text-sm leading-tight">
                  <span className="truncate font-medium">{name}</span>
                  <span className="text-muted-foreground truncate text-xs">
                    {admin.email}
                  </span>
                </div>
              </div>
            </DropdownMenuLabel>
            <DropdownMenuSeparator />
            <DropdownMenuGroup>
              <DropdownMenuItem
                onClick={() => router.push("/settings")}
                className="cursor-pointer"
              >
                <IconSettings className="mr-2 h-4 w-4" />
                Settings
              </DropdownMenuItem>
            </DropdownMenuGroup>
            <DropdownMenuSeparator />
            <DropdownMenuItem
              onClick={() => logoutAdmin()}
              className="cursor-pointer text-red-600 focus:text-red-600 focus:bg-red-50"
            >
              <IconLogout className="mr-2 h-4 w-4" />
              Log out
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </SidebarMenuItem>
    </SidebarMenu>
  );
}

// ============================================================================
// Main Sidebar Component
// ============================================================================

export function AdminSidebar({
  admin,
  ...props
}: { admin: AdminSession } & React.ComponentProps<typeof Sidebar>) {
  const pathname = usePathname();
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  const isActive = (url: string, exact?: boolean) => {
    if (exact || url === "/") return pathname === url;
    return pathname.startsWith(url);
  };

  // Auto-open sections that have an active child
  const [openSections, setOpenSections] = useState<Record<string, boolean>>({
    Management: true,
    People: true,
    "Content & Tools": true,
  });

  // Auto-open section when navigating to a child
  useEffect(() => {
    for (const section of sections) {
      const hasActive = section.items.some((item) =>
        isActive(item.url, item.exact)
      );
      if (hasActive) {
        setOpenSections((prev) => ({ ...prev, [section.label]: true }));
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [pathname]);

  const toggleSection = (label: string) => {
    setOpenSections((prev) => ({ ...prev, [label]: !prev[label] }));
  };

  return (
    <Sidebar collapsible="offcanvas" {...props} className="border-r border-border/60">
      {/* Header */}
      <SidebarHeader className="px-3 py-2.5">
        <Link
          href="/"
          className="flex items-center gap-2.5 px-1 py-1"
        >
          <IconShield className="h-5 w-5 text-primary" />
          <span className="text-base font-semibold">AssignX Admin</span>
        </Link>
      </SidebarHeader>

      <SidebarSeparator className="bg-border/60" />

      {/* Main Navigation */}
      <SidebarContent className="px-2 py-2">
        <SidebarGroup>
          <SidebarGroupContent className="space-y-0.5">
            {/* Top-level items (Dashboard) */}
            {mainNav.map((item) => (
              <NavLink
                key={item.url}
                item={item}
                isActive={isActive(item.url, item.exact)}
              />
            ))}

            {/* Spacer */}
            <div className="h-2" />

            {/* Collapsible Sections */}
            {sections.map((section, idx) => (
              <div key={section.label}>
                <CollapsibleSection
                  section={section}
                  isOpen={openSections[section.label] ?? false}
                  onToggle={() => toggleSection(section.label)}
                  isActiveFn={isActive}
                  mounted={mounted}
                />
                {idx < sections.length - 1 && <div className="h-1" />}
              </div>
            ))}
          </SidebarGroupContent>
        </SidebarGroup>
      </SidebarContent>

      <SidebarSeparator className="bg-border/60" />

      {/* Footer with User */}
      <SidebarFooter className="px-3 py-2">
        <AdminNavUser admin={admin} />
      </SidebarFooter>
    </Sidebar>
  );
}
