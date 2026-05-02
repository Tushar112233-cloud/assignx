"use client";

import { useState } from "react";
import {
  Shield,
  Eye,
  EyeOff,
  BarChart3,
  Download,
  Trash2,
  Loader2,
  FileJson,
  ChevronRight,
} from "lucide-react";
import { Switch } from "@/components/ui/switch";
import { Label } from "@/components/ui/label";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { Separator } from "@/components/ui/separator";
import { toast } from "sonner";
import { exportUserData } from "@/lib/actions/data";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

/** Props for the privacy controls section */
interface PrivacyControlsSectionProps {
  /**
   * Whether the user has opted out of anonymous usage analytics.
   * When true, no analytics events are sent.
   */
  analyticsOptOut: boolean;
  /**
   * Whether to show the user's online status to other users.
   * When false, the user appears offline to others.
   */
  showOnlineStatus: boolean;
  /**
   * Callback fired when the analytics opt-out toggle changes.
   * Expected to persist the value and return a boolean indicating success.
   */
  onAnalyticsOptOutChange: () => Promise<boolean>;
  /**
   * Callback fired when the online status toggle changes.
   * Expected to persist the value and return a boolean indicating success.
   */
  onOnlineStatusChange: () => Promise<boolean>;
}

// ---------------------------------------------------------------------------
// Sub-components
// ---------------------------------------------------------------------------

/**
 * A single privacy toggle row with an icon, label, description, and switch.
 */
function PrivacyToggle({
  id,
  icon: Icon,
  label,
  description,
  checked,
  onCheckedChange,
}: {
  id: string;
  icon: React.ElementType;
  label: string;
  description: string;
  checked: boolean;
  onCheckedChange: (checked: boolean) => void;
}) {
  return (
    <div className="flex items-center justify-between py-3">
      <div className="flex items-start gap-3 flex-1 min-w-0">
        <div className="h-8 w-8 rounded-lg bg-muted flex items-center justify-center shrink-0 mt-0.5">
          <Icon className="h-4 w-4 text-muted-foreground" />
        </div>
        <div className="space-y-0.5">
          <Label htmlFor={id} className="text-sm font-medium cursor-pointer">
            {label}
          </Label>
          <p className="text-xs text-muted-foreground">{description}</p>
        </div>
      </div>
      <Switch
        id={id}
        checked={checked}
        onCheckedChange={onCheckedChange}
        className="ml-4 shrink-0"
      />
    </div>
  );
}

/**
 * An action button row for data operations (export, clear cache).
 */
function DataAction({
  icon: Icon,
  label,
  description,
  iconClassName,
  isLoading,
  onClick,
}: {
  icon: React.ElementType;
  label: string;
  description: string;
  iconClassName?: string;
  isLoading?: boolean;
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      disabled={isLoading}
      className="flex items-center justify-between w-full p-3 rounded-lg bg-muted/50 hover:bg-muted transition-colors disabled:opacity-60 disabled:cursor-not-allowed"
    >
      <div className="flex items-center gap-3">
        <div className="h-8 w-8 rounded-lg bg-background flex items-center justify-center border border-border">
          <Icon className={iconClassName ?? "h-4 w-4 text-muted-foreground"} />
        </div>
        <div className="text-left">
          <p className="text-sm font-medium text-foreground">{label}</p>
          <p className="text-xs text-muted-foreground">{description}</p>
        </div>
      </div>
      {isLoading ? (
        <Loader2 className="h-4 w-4 animate-spin text-muted-foreground shrink-0" />
      ) : (
        <ChevronRight className="h-4 w-4 text-muted-foreground shrink-0" />
      )}
    </button>
  );
}

// ---------------------------------------------------------------------------
// Main Component
// ---------------------------------------------------------------------------

/**
 * Privacy Controls section for the settings page.
 *
 * Provides toggles for analytics opt-out and online status visibility, plus
 * data management actions (export data, clear cache). This mirrors the mobile
 * `PrivacyDataSection` widget from `privacy_data_section.dart` for full
 * feature parity between the mobile app and web app.
 *
 * @example
 * ```tsx
 * <PrivacyControlsSection
 *   analyticsOptOut={preferences.privacy.analyticsOptOut}
 *   showOnlineStatus={preferences.privacy.showOnlineStatus}
 *   onAnalyticsOptOutChange={() => updatePrivacy("analyticsOptOut")}
 *   onOnlineStatusChange={() => updatePrivacy("showOnlineStatus")}
 * />
 * ```
 */
export function PrivacyControlsSection({
  analyticsOptOut,
  showOnlineStatus,
  onAnalyticsOptOutChange,
  onOnlineStatusChange,
}: PrivacyControlsSectionProps) {
  const [isExporting, setIsExporting] = useState(false);
  const [clearDialogOpen, setClearDialogOpen] = useState(false);

  /**
   * Handles the analytics opt-out toggle.
   * Delegates persistence to the parent callback and shows a toast on failure.
   */
  const handleAnalyticsToggle = async () => {
    const success = await onAnalyticsOptOutChange();
    if (success) {
      toast.success("Analytics preference updated");
    } else {
      toast.error("Failed to update analytics preference");
    }
  };

  /**
   * Handles the online status toggle.
   * Delegates persistence to the parent callback and shows a toast on failure.
   */
  const handleOnlineStatusToggle = async () => {
    const success = await onOnlineStatusChange();
    if (success) {
      toast.success("Online status preference updated");
    } else {
      toast.error("Failed to update online status preference");
    }
  };

  /**
   * Exports all user data as a downloadable JSON file.
   * Uses the shared `exportUserData` server action.
   */
  const handleExportData = async () => {
    setIsExporting(true);
    try {
      const result = await exportUserData();
      if (result.error) {
        toast.error(result.error);
        return;
      }
      const blob = new Blob([JSON.stringify(result.data, null, 2)], {
        type: "application/json",
      });
      const url = URL.createObjectURL(blob);
      const anchor = document.createElement("a");
      anchor.href = url;
      anchor.download = `assignx-data-${Date.now()}.json`;
      anchor.click();
      URL.revokeObjectURL(url);
      toast.success("Data exported successfully");
    } catch {
      toast.error("Failed to export data");
    } finally {
      setIsExporting(false);
    }
  };

  /**
   * Clears local browser storage (localStorage and sessionStorage).
   * Shows a confirmation dialog before proceeding.
   */
  const handleClearCache = () => {
    try {
      localStorage.clear();
      sessionStorage.clear();
      toast.success("Cache cleared successfully");
    } catch {
      toast.error("Failed to clear cache");
    } finally {
      setClearDialogOpen(false);
    }
  };

  return (
    <>
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Shield className="h-5 w-5" />
            Privacy & Data
          </CardTitle>
          <CardDescription>
            Control your privacy settings and manage your data
          </CardDescription>
        </CardHeader>

        <CardContent className="space-y-4">
          {/* Privacy Toggles */}
          <div className="space-y-1">
            <PrivacyToggle
              id="analytics-opt-out"
              icon={BarChart3}
              label="Analytics Opt-out"
              description="Disable anonymous usage analytics. When enabled, no usage data is collected."
              checked={analyticsOptOut}
              onCheckedChange={handleAnalyticsToggle}
            />
            <PrivacyToggle
              id="show-online-status"
              icon={showOnlineStatus ? Eye : EyeOff}
              label="Show Online Status"
              description="Let other users see when you are online. Turn off to appear offline."
              checked={showOnlineStatus}
              onCheckedChange={handleOnlineStatusToggle}
            />
          </div>

          <Separator />

          {/* Data Management Actions */}
          <div className="space-y-3">
            <p className="text-sm font-medium text-foreground">
              Data Management
            </p>
            <DataAction
              icon={FileJson}
              label="Export Data"
              description="Download all your data as JSON"
              iconClassName="h-4 w-4 text-blue-600"
              isLoading={isExporting}
              onClick={handleExportData}
            />
            <DataAction
              icon={Trash2}
              label="Clear Cache"
              description="Clear local storage and cached data"
              iconClassName="h-4 w-4 text-red-500"
              onClick={() => setClearDialogOpen(true)}
            />
          </div>
        </CardContent>
      </Card>

      {/* Clear Cache Confirmation Dialog */}
      <AlertDialog open={clearDialogOpen} onOpenChange={setClearDialogOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Clear cache?</AlertDialogTitle>
            <AlertDialogDescription>
              This will clear all locally stored data including cached
              preferences and session tokens. You may need to log in again.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={handleClearCache}>
              Clear Cache
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  );
}
