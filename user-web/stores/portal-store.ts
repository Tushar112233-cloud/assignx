import { create } from "zustand";
import { persist } from "zustand/middleware";
import type { PortalRole } from "@/types/portals";

interface PortalState {
  activePortal: PortalRole;
  setActivePortal: (portal: PortalRole) => void;
}

/**
 * Portal state store
 * Tracks which portal tab is active, persisted to localStorage
 */
export const usePortalStore = create<PortalState>()(
  persist(
    (set) => ({
      activePortal: "student",
      setActivePortal: (portal) => set({ activePortal: portal }),
    }),
    {
      name: "portal-storage",
    }
  )
);
