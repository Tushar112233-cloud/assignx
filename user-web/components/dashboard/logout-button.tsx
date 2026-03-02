"use client";

import { useState } from "react";
import { LogOut, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { logout } from "@/lib/api/auth";
import { useUserStore } from "@/stores/user-store";
import { useAuthStore } from "@/stores/auth-store";

/**
 * Clears all auth tokens and persisted stores from localStorage
 */
function clearAuthTokens() {
  if (typeof window === "undefined") return;

  const keysToRemove: string[] = [
    "accessToken",
    "refreshToken",
    "user",
    // Also clear zustand persisted stores
    "user-storage",
    "auth-storage",
    "wallet-storage",
    "notification-storage",
    "project-storage",
  ];

  // Remove any legacy sb-* keys that may still exist
  for (let i = 0; i < localStorage.length; i++) {
    const key = localStorage.key(i);
    if (key && key.startsWith("sb-") && key.includes("-auth-token")) {
      keysToRemove.push(key);
    }
  }

  keysToRemove.forEach((key) => {
    localStorage.removeItem(key);
  });

  // Clear the loggedIn cookie
  document.cookie = "loggedIn=; path=/; max-age=0";
  document.cookie = "accessToken=; path=/; max-age=0";
}

/**
 * Logout button with client-side signOut action.
 * Clears localStorage tokens and zustand stores before signing out.
 */
export function LogoutButton() {
  const [isLoading, setIsLoading] = useState(false);
  const clearUser = useUserStore((state) => state.clearUser);
  const clearAuth = useAuthStore((state) => state.clearAuth);

  const handleLogout = async () => {
    setIsLoading(true);
    try {
      // Clear zustand stores
      clearUser();
      clearAuth();

      // Clear localStorage tokens and cookies
      clearAuthTokens();

      // Call the Express API logout endpoint
      await logout();

      // Redirect to login page
      window.location.href = "/login";
    } catch (error) {
      // Even if API call fails, localStorage is already cleared
      window.location.href = "/login";
    }
  };

  return (
    <Button
      variant="ghost"
      className="w-full justify-start gap-3 px-3 text-muted-foreground hover:bg-destructive/10 hover:text-destructive"
      onClick={handleLogout}
      disabled={isLoading}
    >
      {isLoading ? (
        <Loader2 className="h-5 w-5 animate-spin" />
      ) : (
        <LogOut className="h-5 w-5" />
      )}
      {isLoading ? "Logging out..." : "Logout"}
    </Button>
  );
}
