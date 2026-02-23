"use client";

import { useEffect, useState } from "react";
import { useUserStore, useWalletStore, useNotificationStore, useProjectStore } from "@/stores";
import { useAuthStore } from "@/stores/auth-store";
import { Loader2 } from "lucide-react";

interface DataProviderProps {
  children: React.ReactNode;
}

/**
 * Check if login is required based on environment variable
 * In dev mode (REQUIRE_LOGIN=false), we bypass authentication
 */
function isLoginRequired(): boolean {
  return process.env.NEXT_PUBLIC_REQUIRE_LOGIN !== "false";
}

/**
 * Data provider component
 * Fetches initial data from Supabase when the app loads
 *
 * DEV MODE: When NEXT_PUBLIC_REQUIRE_LOGIN=false, automatically loads
 * default user data without requiring authentication
 */
export function DataProvider({ children }: DataProviderProps) {
  const [isHydrated, setIsHydrated] = useState(false);
  const [isInitialized, setIsInitialized] = useState(false);

  const fetchUser = useUserStore((state) => state.fetchUser);
  const setUser = useUserStore((state) => state.setUser);
  const fetchWallet = useWalletStore((state) => state.fetchWallet);
  const fetchNotifications = useNotificationStore((state) => state.fetchNotifications);
  const fetchProjects = useProjectStore((state) => state.fetchProjects);
  const initializeAuth = useAuthStore((state) => state.initializeAuth);

  // Handle hydration
  useEffect(() => {
    setIsHydrated(true);
  }, []);

  // Fetch all data on mount
  useEffect(() => {
    if (!isHydrated) return;

    const initializeData = async () => {
      try {
        // Fetch all data in parallel
        // Note: In dev mode (REQUIRE_LOGIN=false), getProfile() automatically
        // returns the default dev user's data
        await Promise.all([
          fetchUser(),
          fetchWallet(),
          fetchNotifications(20),
          fetchProjects(),
        ]);

        // In dev mode, also initialize auth store with the user data
        if (!isLoginRequired()) {
          const user = useUserStore.getState().user;
          if (user) {
            // Set auth store to authenticated and onboarded state for dev mode
            initializeAuth(
              user,
              user.students || null,
              user.professionals || null,
              user.wallet || null
            );
          }
        }
      } catch {
        // Silently handle initialization errors - stores handle their own error states
      } finally {
        setIsInitialized(true);
      }
    };

    initializeData();
  }, [isHydrated, fetchUser, fetchWallet, fetchNotifications, fetchProjects, initializeAuth, setUser]);

  // Show loading state while hydrating
  if (!isHydrated) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    );
  }

  return <>{children}</>;
}
