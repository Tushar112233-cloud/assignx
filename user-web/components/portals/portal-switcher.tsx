"use client";

import { motion } from "framer-motion";
import { Users, Briefcase, Building2 } from "lucide-react";
import { cn } from "@/lib/utils";
import type { PortalRole } from "@/types/portals";

const portalConfig: Record<PortalRole, { label: string; icon: React.ElementType }> = {
  student: { label: "Campus Connect", icon: Users },
  professional: { label: "Job Portal", icon: Briefcase },
  business: { label: "Business Portal", icon: Building2 },
};

interface PortalSwitcherProps {
  roles: PortalRole[];
  activePortal: PortalRole;
  onSwitch: (portal: PortalRole) => void;
}

/**
 * Horizontal tab switcher for multi-role portal navigation
 * Hidden when user has only 1 role
 * Uses Framer Motion layoutId for animated pill background
 */
export function PortalSwitcher({ roles, activePortal, onSwitch }: PortalSwitcherProps) {
  if (roles.length <= 1) return null;

  return (
    <div className="flex items-center gap-1 p-1 rounded-xl bg-muted/60 backdrop-blur-sm border border-border/40 w-fit mx-auto">
      {roles.map((role) => {
        const { label, icon: Icon } = portalConfig[role];
        const isActive = activePortal === role;

        return (
          <button
            key={role}
            onClick={() => onSwitch(role)}
            className={cn(
              "relative flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium transition-colors",
              isActive
                ? "text-primary-foreground"
                : "text-muted-foreground hover:text-foreground"
            )}
          >
            {isActive && (
              <motion.div
                layoutId="portal-pill"
                className="absolute inset-0 bg-primary rounded-lg"
                transition={{ type: "spring", bounce: 0.2, duration: 0.4 }}
              />
            )}
            <span className="relative z-10 flex items-center gap-2">
              <Icon className="h-4 w-4" />
              <span className="hidden sm:inline">{label}</span>
            </span>
          </button>
        );
      })}
    </div>
  );
}
