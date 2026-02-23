"use client";

import { useState } from "react";
import { MobileNav } from "./mobile-nav";
import { UploadSheet } from "./upload-sheet";
import { SupportButton } from "@/components/shared/support-button";

/**
 * Client-side wrapper for dashboard interactive elements
 * Handles upload sheet state and mobile navigation
 * Extracted to allow dashboard layout to be a server component
 *
 * Note: Desktop FAB removed - using contextual buttons instead
 */
export function DashboardShell({ children }: { children: React.ReactNode }) {
  const [uploadSheetOpen, setUploadSheetOpen] = useState(false);

  return (
    <>
      {/* Main Content */}
      <main className="pb-20 lg:pl-64 lg:pb-0">
        {children}
      </main>

      {/* Mobile Bottom Navigation */}
      <MobileNav onFabClick={() => setUploadSheetOpen(true)} />

      {/* Upload Sheet - Opened by mobile nav or page-specific buttons */}
      <UploadSheet open={uploadSheetOpen} onOpenChange={setUploadSheetOpen} />

      {/* Support Button */}
      <SupportButton />
    </>
  );
}
