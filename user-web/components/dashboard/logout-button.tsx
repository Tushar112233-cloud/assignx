"use client";

import { useState } from "react";
import { LogOut, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { signOut } from "@/lib/actions/auth";
import { useUserStore } from "@/stores/user-store";
import { useAuthStore } from "@/stores/auth-store";

/**
 * Clears all Supabase auth tokens from localStorage
 * Tokens are stored as sb-<project-ref>-auth-token
 */
function clearSupabaseAuthTokens() {
  if (typeof window === "undefined") return;

  const keysToRemove: string[] = [];

  for (let i = 0; i < localStorage.length; i++) {
    const key = localStorage.key(i);
    if (key && (key.startsWith("sb-") && key.includes("-auth-token"))) {
      keysToRemove.push(key);
    }
  }

  // Also clear zustand persisted stores
  keysToRemove.push("user-storage", "auth-storage", "wallet-storage", "notification-storage", "project-storage");

  keysToRemove.forEach((key) => {
    localStorage.removeItem(key);
  });
}

/**
 * Logout button with client-side signOut action
 * Clears localStorage tokens and zustand stores before signing out
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

      // Clear localStorage tokens
      clearSupabaseAuthTokens();

      // Sign out from Supabase (server action)
      await signOut();
    } catch (error) {
      // Even if server action fails, the localStorage is cleared
      // Redirect manually if needed
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
