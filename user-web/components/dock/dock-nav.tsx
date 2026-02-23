"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  Home,
  FolderKanban,
  Users,
  Wallet,
  Settings,
  GraduationCap,
} from "lucide-react";
import { motion } from "framer-motion";

import { Dock, DockIcon } from "@/components/ui/dock";
import { DockProfile } from "./dock-profile";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";
import { cn } from "@/lib/utils";

/**
 * Navigation items configuration
 * tourId is used for onboarding tour targeting
 */
const navItems = [
  {
    title: "Dashboard",
    url: "/home",
    icon: Home,
    tourId: "create-project",
  },
  {
    title: "Projects",
    url: "/projects",
    icon: FolderKanban,
    tourId: "projects",
  },
  {
    title: "Campus Connect",
    url: "/campus-connect",
    icon: Users,
    tourId: "connect",
  },
  {
    title: "Experts",
    url: "/experts",
    icon: GraduationCap,
    tourId: "experts",
  },
  {
    title: "Wallet",
    url: "/wallet",
    icon: Wallet,
    tourId: "wallet",
  },
];

/**
 * DockNav Component
 * macOS-style dock navigation positioned at the bottom of the screen
 */
export function DockNav() {
  const pathname = usePathname();

  return (
    <div className="dock-container">
      <TooltipProvider delayDuration={0}>
        <Dock
          className="dock-glass"
          iconSize={40}
          iconMagnification={60}
          iconDistance={140}
          direction="bottom"
        >
          {navItems.map((item) => {
            const isActive = pathname === item.url;
            const Icon = item.icon;

            return (
              <DockIcon key={item.url} className="relative" data-tour={item.tourId}>
                <Tooltip>
                  <TooltipTrigger asChild>
                    <Link
                      href={item.url}
                      className="flex h-full w-full items-center justify-center"
                    >
                      {/* Active background - clean prominent indicator */}
                      {isActive && (
                        <motion.div
                          layoutId="dock-active-bg"
                          className="absolute inset-0 rounded-xl bg-primary"
                          initial={{ scale: 0.85, opacity: 0 }}
                          animate={{ scale: 1, opacity: 1 }}
                          transition={{
                            duration: 0.25,
                            ease: [0.34, 1.56, 0.64, 1],
                          }}
                        />
                      )}
                      <motion.div
                        className={cn(
                          "relative z-10 flex items-center justify-center",
                          isActive
                            ? "text-primary-foreground"
                            : "text-muted-foreground hover:text-foreground"
                        )}
                        whileHover={{ scale: 1.1 }}
                        whileTap={{ scale: 0.95 }}
                      >
                        <Icon className="size-5" strokeWidth={isActive ? 2.5 : 1.5} />
                      </motion.div>
                    </Link>
                  </TooltipTrigger>
                  <TooltipContent
                    side="top"
                    sideOffset={8}
                    className="rounded-lg px-3 py-1.5 text-xs font-medium"
                  >
                    {item.title}
                  </TooltipContent>
                </Tooltip>
              </DockIcon>
            );
          })}

          {/* Separator */}
          <div className="mx-1 h-8 w-px bg-border/50" />

          {/* Settings */}
          <DockIcon className="relative">
            <Tooltip>
              <TooltipTrigger asChild>
                <Link
                  href="/settings"
                  className="flex h-full w-full items-center justify-center"
                >
                  {pathname === "/settings" && (
                    <motion.div
                      layoutId="dock-active-bg"
                      className="absolute inset-0 rounded-xl bg-primary"
                      initial={{ scale: 0.85, opacity: 0 }}
                      animate={{ scale: 1, opacity: 1 }}
                      transition={{
                        duration: 0.25,
                        ease: [0.34, 1.56, 0.64, 1],
                      }}
                    />
                  )}
                  <motion.div
                    className={cn(
                      "relative z-10 flex items-center justify-center",
                      pathname === "/settings"
                        ? "text-primary-foreground"
                        : "text-muted-foreground hover:text-foreground"
                    )}
                    whileHover={{ scale: 1.1 }}
                    whileTap={{ scale: 0.95 }}
                  >
                    <Settings className="size-5" strokeWidth={pathname === "/settings" ? 2.5 : 1.5} />
                  </motion.div>
                </Link>
              </TooltipTrigger>
              <TooltipContent
                side="top"
                sideOffset={8}
                className="rounded-lg px-3 py-1.5 text-xs font-medium"
              >
                Settings
              </TooltipContent>
            </Tooltip>
          </DockIcon>

          {/* Profile */}
          <DockIcon data-tour="profile">
            <Tooltip>
              <TooltipTrigger asChild>
                <div className="flex h-full w-full items-center justify-center">
                  <DockProfile />
                </div>
              </TooltipTrigger>
              <TooltipContent
                side="top"
                sideOffset={8}
                className="rounded-lg px-3 py-1.5 text-xs font-medium"
              >
                Profile
              </TooltipContent>
            </Tooltip>
          </DockIcon>
        </Dock>
      </TooltipProvider>
    </div>
  );
}
