"use client";

import { useState } from "react";
import { MobileNav } from "./mobile-nav";
import { UploadSheet } from "./upload-sheet";

/**
 * Client-side wrapper for dashboard interactive elements
 * Handles upload sheet state and mobile navigation
 * Used within SidebarInset to add floating elements
 *
 * Note: Children are rendered directly without extra wrapper
 * to avoid nested scrollable containers and layout issues
 */
export function DashboardClientShell({ children }: { children: React.ReactNode }) {
  const [uploadSheetOpen, setUploadSheetOpen] = useState(false);

  return (
    <>
      {/* Main Content - rendered directly without extra wrapper */}
      {children}

      {/* Mobile Bottom Navigation */}
      <MobileNav onFabClick={() => setUploadSheetOpen(true)} />

      {/* Upload Sheet */}
      <UploadSheet open={uploadSheetOpen} onOpenChange={setUploadSheetOpen} />
    </>
  );
}
