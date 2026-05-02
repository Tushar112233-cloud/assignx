"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  LayoutGrid,
  FolderKanban,
  Plus,
  Users,
  User,
  Sparkles,
  BarChart3,
  Settings,
  GraduationCap,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { motion } from "framer-motion";

/**
 * Navigation items matching the design
 * Dashboard, Projects, AI Tools (FAB), Analytics, Settings
 */
const navItems = [
  {
    title: "Home",
    href: "/home",
    icon: LayoutGrid,
  },
  {
    title: "Projects",
    href: "/projects",
    icon: FolderKanban,
  },
  {
    title: "Add",
    href: "#",
    icon: Plus,
    isFab: true,
  },
  {
    title: "Campus",
    href: "/campus-connect",
    icon: Users,
  },
  {
    title: "Experts",
    href: "/experts",
    icon: GraduationCap,
  },
];

interface MobileNavProps {
  onFabClick: () => void;
}

/**
 * Mobile bottom navigation bar - Floating Pill Design
 * Matches the new design system with glass morphism floating pill
 */
export function MobileNav({ onFabClick }: MobileNavProps) {
  const pathname = usePathname();

  return (
    <nav className="fixed bottom-4 left-1/2 -translate-x-1/2 z-40 lg:hidden">
      <motion.div
        initial={{ y: 100, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{
          type: "spring",
          stiffness: 260,
          damping: 20,
          delay: 0.2
        }}
        className="floating-nav-pill rounded-full px-2 py-2"
      >
        <div className="flex items-center gap-1">
          {navItems.map((item) => {
            const isActive = pathname === item.href;

            if (item.isFab) {
              return (
                <button
                  key={item.title}
                  onClick={onFabClick}
                  className="flex h-12 w-12 items-center justify-center rounded-full bg-primary text-primary-foreground shadow-lg transition-all hover:scale-105 active:scale-95 mx-1"
                >
                  <item.icon className="h-5 w-5" strokeWidth={2} />
                </button>
              );
            }

            return (
              <Link
                key={item.href}
                href={item.href}
                className={cn(
                  "relative flex flex-col items-center justify-center gap-0.5 px-4 py-2 rounded-full transition-all",
                  isActive
                    ? "bg-muted/80"
                    : "hover:bg-muted/40"
                )}
              >
                <item.icon
                  className={cn(
                    "h-5 w-5 transition-colors",
                    isActive ? "text-primary" : "text-muted-foreground"
                  )}
                  strokeWidth={isActive ? 2 : 1.5}
                />
                <span
                  className={cn(
                    "text-[10px] font-medium transition-colors",
                    isActive ? "text-foreground" : "text-muted-foreground"
                  )}
                >
                  {item.title}
                </span>
                {isActive && (
                  <motion.div
                    layoutId="activeTab"
                    className="absolute inset-0 rounded-full bg-muted/50 -z-10"
                    transition={{ type: "spring", stiffness: 380, damping: 30 }}
                  />
                )}
              </Link>
            );
          })}
        </div>
      </motion.div>
    </nav>
  );
}
