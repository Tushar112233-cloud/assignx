"use client";

import { usePathname } from "next/navigation";
import { Separator } from "@/components/ui/separator";
import { SidebarTrigger } from "@/components/ui/sidebar";
import { LanguageSelector } from "@/components/language-selector";

const pathTitles: Record<string, string> = {
  "/": "Dashboard",
  "/users": "Users",
  "/projects": "Projects",
  "/wallets": "Wallets",
  "/support": "Support Tickets",
  "/supervisors": "Supervisors",
  "/doers": "Doers",
  "/experts": "Experts",
  "/moderation": "Moderation",
  "/banners": "Banners",
  "/colleges": "Colleges",
  "/learning": "Learning",
  "/analytics": "Analytics",
  "/reports": "Reports",
  "/messages": "Messages",
  "/settings": "Settings",
};

function getPageTitle(pathname: string): string {
  if (pathTitles[pathname]) return pathTitles[pathname];
  const prefix = Object.keys(pathTitles)
    .filter((p) => p !== "/")
    .find((p) => pathname.startsWith(p));
  return prefix ? pathTitles[prefix] : "Admin";
}

export function AdminHeader() {
  const pathname = usePathname();
  const title = getPageTitle(pathname);

  return (
    <header className="flex h-(--header-height) shrink-0 items-center gap-2 border-b transition-[width,height] ease-linear group-has-data-[collapsible=icon]/sidebar-wrapper:h-(--header-height)">
      <div className="flex w-full items-center gap-1 px-4 lg:gap-2 lg:px-6">
        <SidebarTrigger className="-ml-1" />
        <Separator
          orientation="vertical"
          className="mx-2 data-[orientation=vertical]:h-4"
        />
        <h1 className="text-base font-medium">{title}</h1>
        <div className="ml-auto">
          <LanguageSelector />
        </div>
      </div>
    </header>
  );
}
