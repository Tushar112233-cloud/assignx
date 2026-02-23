"use client";

import Link from "next/link";
import {
  Avatar,
  AvatarFallback,
  AvatarImage,
} from "@/components/ui/avatar";
import { useUserStore } from "@/stores/user-store";

/**
 * Gets user initials from name
 */
function getInitials(name: string): string {
  if (!name) return "U";
  const parts = name.split(" ").filter(Boolean);
  if (parts.length >= 2) {
    return `${parts[0][0]}${parts[1][0]}`.toUpperCase();
  }
  return parts[0]?.[0]?.toUpperCase() || "U";
}

/**
 * Dock Profile Component
 * Displays user avatar that links directly to profile page
 */
export function DockProfile() {
  const user = useUserStore((state) => state.user);

  const userData = {
    name: user?.full_name || user?.fullName || "User",
    avatar: user?.avatar_url || user?.avatarUrl || "",
  };

  return (
    <Link
      href="/profile"
      className="flex items-center justify-center rounded-full outline-none focus:ring-2 focus:ring-primary/50 focus:ring-offset-2 transition-all"
    >
      <Avatar className="h-full w-full rounded-full">
        <AvatarImage src={userData.avatar} alt={userData.name} />
        <AvatarFallback className="rounded-full bg-primary/10 text-primary text-xs font-medium">
          {getInitials(userData.name)}
        </AvatarFallback>
      </Avatar>
    </Link>
  );
}
