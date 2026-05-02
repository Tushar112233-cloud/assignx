"use client";

import { useEffect, useMemo } from "react";
import { AnimatePresence, motion } from "framer-motion";
import { useUserStore } from "@/stores/user-store";
import { usePortalStore } from "@/stores/portal-store";
import { PortalSwitcher } from "./portal-switcher";
import { JobPortal } from "./job-portal";
import { BusinessPortal } from "./business-portal";
import { CampusConnectPage } from "@/components/campus-connect";
import type { PortalRole } from "@/types/portals";

const portalTransition = {
  initial: { opacity: 0, y: 12 },
  animate: { opacity: 1, y: 0, transition: { duration: 0.3 } },
  exit: { opacity: 0, y: -8, transition: { duration: 0.18 } },
};

/**
 * Portal Page Orchestrator
 * Reads user roles and renders the active portal with tab switching
 * - Single role: renders portal directly, no switcher
 * - Multiple roles: shows PortalSwitcher + active portal content
 */
export function PortalPage() {
  const user = useUserStore((s) => s.user);
  const { activePortal, setActivePortal } = usePortalStore();

  // Determine available roles from user profile
  const roles: PortalRole[] = useMemo(() => {
    const VALID: PortalRole[] = ["student", "professional", "business"];

    if (!user) return ["student"];

    // Prefer user_roles array, fallback to user_type — filter to known portal roles only
    if (user.user_roles && user.user_roles.length > 0) {
      const valid = user.user_roles.filter((r): r is PortalRole => VALID.includes(r as PortalRole));
      if (valid.length > 0) return valid;
    }

    const fallback = user.user_type as PortalRole;
    return VALID.includes(fallback) ? [fallback] : ["student"];
  }, [user]);

  // Ensure active portal is a valid role for this user
  useEffect(() => {
    if (!roles.includes(activePortal)) {
      setActivePortal(roles[0]);
    }
  }, [roles, activePortal, setActivePortal]);

  // Resolved active portal (guaranteed to be in roles)
  const current = roles.includes(activePortal) ? activePortal : roles[0];

  const hasMultipleRoles = roles.length > 1;

  return (
    <div>
      {/* Tab Switcher (hidden for single-role users) */}
      {hasMultipleRoles && (
        <div className="pt-4 pb-2 px-4 md:px-6">
          <PortalSwitcher
            roles={roles}
            activePortal={current}
            onSwitch={setActivePortal}
          />
        </div>
      )}

      {/* Portal Content */}
      <AnimatePresence mode="wait">
        <motion.div
          key={current}
          {...portalTransition}
        >
          {current === "student" && <CampusConnectPage />}
          {current === "professional" && (
            <div className="px-4 md:px-6 pb-8">
              <JobPortal />
            </div>
          )}
          {current === "business" && (
            <div className="px-4 md:px-6 pb-8">
              <BusinessPortal />
            </div>
          )}
        </motion.div>
      </AnimatePresence>
    </div>
  );
}
