"use client";

import { cn } from "@/lib/utils";
import { SkeletonText, SkeletonBox, SkeletonButton } from "../primitives";

interface SettingsSkeletonProps {
  className?: string;
}

/**
 * Helper: Settings Section Skeleton
 * Matches SettingsSection component structure from settings-pro.tsx
 */
function SettingsSectionSkeleton({
  variant,
  delay = 0,
  children,
}: {
  variant?: "danger";
  delay?: number;
  children: React.ReactNode;
}) {
  return (
    <div
      className={cn(
        "rounded-xl border bg-card overflow-hidden",
        variant === "danger" ? "border-red-200 dark:border-red-900/50" : "border-border"
      )}
    >
      {/* Section header */}
      <div className="flex items-center gap-3 p-4 border-b border-border">
        <SkeletonBox
          width={36}
          height={36}
          rounded="lg"
          className={cn(variant === "danger" ? "bg-red-100 dark:bg-red-900/30" : "bg-muted")}
          delay={delay}
        />
        <div className="space-y-1">
          <SkeletonText width={100} lineHeight={14} delay={delay + 20} />
          <SkeletonText width={150} lineHeight={12} delay={delay + 40} />
        </div>
      </div>
      <div className="p-4">{children}</div>
    </div>
  );
}

/**
 * Helper: Toggle row skeleton
 * Matches SettingToggle component structure
 */
function ToggleRowSkeleton({ delay = 0 }: { delay?: number }) {
  return (
    <div className="flex items-center justify-between py-3">
      <div className="flex-1 min-w-0 space-y-1">
        <SkeletonText width={130} lineHeight={14} delay={delay} />
        <SkeletonText width={180} lineHeight={12} delay={delay + 20} />
      </div>
      <SkeletonBox width={44} height={24} rounded="full" className="ml-4 shrink-0" delay={delay + 40} />
    </div>
  );
}

/**
 * Full page skeleton for Settings (/settings)
 * Matches the exact layout of settings-pro.tsx:
 * - Header (title + description)
 * - 2-column grid with 4 sections (Notifications, Appearance, Privacy, About)
 * - Full-width Feedback section
 * - Danger Zone section
 * - pb-24 for mobile nav clearance
 */
export function SettingsSkeleton({ className }: SettingsSkeletonProps) {
  return (
    <main className={cn("flex-1 p-6 md:p-8 max-w-3xl mx-auto space-y-6 pb-24", className)}>
      {/* Header */}
      <div className="space-y-1">
        <SkeletonText width={80} lineHeight={24} delay={0} />
        <SkeletonText width={220} lineHeight={14} delay={50} />
      </div>

      {/* Two Column Grid */}
      <div className="grid lg:grid-cols-2 gap-4">
        {/* Notifications Section */}
        <SettingsSectionSkeleton delay={100}>
          <div className="space-y-1">
            <ToggleRowSkeleton delay={150} />
            <ToggleRowSkeleton delay={200} />
            <ToggleRowSkeleton delay={250} />
            <ToggleRowSkeleton delay={300} />
          </div>
        </SettingsSectionSkeleton>

        {/* Appearance Section */}
        <SettingsSectionSkeleton delay={120}>
          <div className="space-y-4">
            {/* Theme label */}
            <div>
              <SkeletonText width={50} lineHeight={14} className="mb-3" delay={170} />
              {/* Theme options - 2 columns */}
              <div className="grid grid-cols-2 gap-3">
                {[0, 1].map((i) => (
                  <div
                    key={i}
                    className="flex flex-col items-center gap-2 p-4 rounded-xl border border-border"
                  >
                    <SkeletonBox width={20} height={20} rounded="md" delay={190 + i * 30} />
                    <SkeletonText width={40} lineHeight={12} delay={210 + i * 30} />
                  </div>
                ))}
              </div>
            </div>
            {/* Additional toggles */}
            <div className="pt-2 border-t border-border space-y-1">
              <ToggleRowSkeleton delay={280} />
              <ToggleRowSkeleton delay={330} />
            </div>
          </div>
        </SettingsSectionSkeleton>

        {/* Privacy & Data Section */}
        <SettingsSectionSkeleton delay={140}>
          <div className="space-y-4">
            {/* Privacy toggles */}
            <div className="space-y-1">
              <ToggleRowSkeleton delay={190} />
              <ToggleRowSkeleton delay={240} />
            </div>
            {/* Action buttons */}
            <div className="pt-3 border-t border-border space-y-2">
              {/* Export Data row */}
              <div className="flex items-center justify-between p-3 rounded-lg bg-muted/50">
                <div className="flex items-center gap-3">
                  <SkeletonBox width={32} height={32} rounded="lg" className="bg-blue-100 dark:bg-blue-900/30" delay={290} />
                  <div className="space-y-1">
                    <SkeletonText width={80} lineHeight={14} delay={310} />
                    <SkeletonText width={130} lineHeight={12} delay={330} />
                  </div>
                </div>
                <SkeletonBox width={16} height={16} rounded="md" delay={350} />
              </div>
              {/* Clear Cache row */}
              <div className="flex items-center justify-between p-3 rounded-lg bg-muted/50">
                <div className="flex items-center gap-3">
                  <SkeletonBox width={32} height={32} rounded="lg" className="bg-red-100 dark:bg-red-900/30" delay={370} />
                  <div className="space-y-1">
                    <SkeletonText width={70} lineHeight={14} delay={390} />
                    <SkeletonText width={100} lineHeight={12} delay={410} />
                  </div>
                </div>
                <SkeletonBox width={16} height={16} rounded="md" delay={430} />
              </div>
            </div>
          </div>
        </SettingsSectionSkeleton>

        {/* About Section */}
        <SettingsSectionSkeleton delay={160}>
          <div className="space-y-4">
            {/* Version/Build/Status grid - 3 columns */}
            <div className="grid grid-cols-3 gap-2">
              {["Version", "Build", "Status"].map((_, i) => (
                <div key={i} className="p-3 rounded-lg bg-muted/50 text-center space-y-1">
                  <SkeletonText width={50} lineHeight={12} className="mx-auto" delay={210 + i * 30} />
                  <SkeletonText width={40} lineHeight={14} className="mx-auto" delay={230 + i * 30} />
                </div>
              ))}
            </div>
            {/* Updated date */}
            <SkeletonText width={120} lineHeight={12} className="mx-auto" delay={320} />
            {/* Legal links */}
            <div className="space-y-1">
              {[0, 1, 2].map((i) => (
                <div key={i} className="flex items-center justify-between p-3 rounded-lg">
                  <div className="flex items-center gap-3">
                    <SkeletonBox width={32} height={32} rounded="lg" delay={350 + i * 40} />
                    <div className="space-y-1">
                      <SkeletonText width={100} lineHeight={14} delay={370 + i * 40} />
                      <SkeletonText width={80} lineHeight={12} delay={390 + i * 40} />
                    </div>
                  </div>
                  <SkeletonBox width={16} height={16} rounded="md" delay={410 + i * 40} />
                </div>
              ))}
            </div>
          </div>
        </SettingsSectionSkeleton>
      </div>

      {/* Feedback Section - Full Width */}
      <SettingsSectionSkeleton delay={500}>
        <div className="space-y-4">
          {/* Feedback type label */}
          <div>
            <SkeletonText width={90} lineHeight={14} className="mb-3" delay={550} />
            {/* 3-column type selector */}
            <div className="grid grid-cols-3 gap-3">
              {[0, 1, 2].map((i) => (
                <div
                  key={i}
                  className="flex flex-col items-center gap-2 p-3 rounded-xl border border-border"
                >
                  <SkeletonBox width={20} height={20} rounded="md" delay={570 + i * 30} />
                  <SkeletonText width={50} lineHeight={12} delay={590 + i * 30} />
                </div>
              ))}
            </div>
          </div>
          {/* Textarea area */}
          <div>
            <SkeletonText width={90} lineHeight={14} className="mb-2" delay={680} />
            <SkeletonBox height={100} className="w-full" rounded="lg" delay={700} />
          </div>
          {/* Submit button */}
          <SkeletonButton className="w-full" delay={750} />
        </div>
      </SettingsSectionSkeleton>

      {/* Danger Zone Section */}
      <SettingsSectionSkeleton variant="danger" delay={800}>
        <div className="space-y-2">
          {/* Log Out row */}
          <div className="flex items-center justify-between p-3 rounded-lg border border-red-200 dark:border-red-800">
            <div className="space-y-1">
              <SkeletonText width={60} lineHeight={14} delay={850} />
              <SkeletonText width={140} lineHeight={12} delay={870} />
            </div>
            <SkeletonButton size="sm" width={80} delay={890} />
          </div>
          {/* Deactivate row */}
          <div className="flex items-center justify-between p-3 rounded-lg border border-red-200 dark:border-red-800">
            <div className="space-y-1">
              <SkeletonText width={120} lineHeight={14} delay={910} />
              <SkeletonText width={170} lineHeight={12} delay={930} />
            </div>
            <SkeletonButton size="sm" width={90} delay={950} />
          </div>
          {/* Delete row */}
          <div className="flex items-center justify-between p-3 rounded-lg border border-red-200 dark:border-red-800">
            <div className="space-y-1">
              <SkeletonText width={100} lineHeight={14} delay={970} />
              <SkeletonText width={150} lineHeight={12} delay={990} />
            </div>
            <SkeletonButton size="sm" width={70} delay={1010} />
          </div>
        </div>
      </SettingsSectionSkeleton>
    </main>
  );
}
