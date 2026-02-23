"use client";

import {
  Home,
  FolderKanban,
  Users,
  User,
  Settings,
  HelpCircle,
} from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { SidebarNavLink } from "./sidebar-nav-link";
import { LogoutButton } from "./logout-button";

const mainNavItems = [
  {
    title: "Home",
    href: "/home",
    icon: Home,
  },
  {
    title: "My Projects",
    href: "/projects",
    icon: FolderKanban,
  },
  {
    title: "Connect",
    href: "/connect",
    icon: Users,
  },
  {
    title: "Profile",
    href: "/profile",
    icon: User,
  },
];

const bottomNavItems = [
  {
    title: "Settings",
    href: "/settings",
    icon: Settings,
  },
  {
    title: "Help & Support",
    href: "/support",
    icon: HelpCircle,
  },
];

/**
 * Desktop sidebar navigation
 * Fixed left sidebar with nav items and user actions
 */
export function Sidebar() {
  return (
    <aside className="fixed left-0 top-0 z-40 hidden h-screen w-64 bg-sidebar lg:block overflow-hidden">
      <div className="flex h-full flex-col">
        {/* Logo */}
        <div className="flex h-16 items-center gap-2 px-6">
          <span className="text-xl font-bold text-primary">AssignX</span>
          <Badge variant="secondary" className="text-xs">
            Beta
          </Badge>
        </div>

        {/* Main Navigation */}
        <nav className="flex-1 space-y-1 p-4">
          {mainNavItems.map((item) => (
            <SidebarNavLink
              key={item.href}
              href={item.href}
              icon={item.icon}
              title={item.title}
            />
          ))}
        </nav>


        {/* Bottom Navigation */}
        <nav className="space-y-1 p-4">
          {bottomNavItems.map((item) => (
            <SidebarNavLink
              key={item.href}
              href={item.href}
              icon={item.icon}
              title={item.title}
              showActiveState={false}
            />
          ))}

          <LogoutButton />
        </nav>
      </div>
    </aside>
  );
}
