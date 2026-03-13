"use client";

import { useState, useMemo } from "react";
import {
  Download,
  Trash2,
  Loader2,
  MessageSquare,
  Info,
  ExternalLink,
  Shield,
  Bell,
  Bug,
  Lightbulb,
  Send,
  FileJson,
  Lock,
  FileText,
  Scale,
  Paintbrush,
  Skull,
  UserX,
  LogOut,
  ChevronRight,
  Users,
  Briefcase,
  Building2,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { StaggerItem } from "@/components/skeletons";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Switch } from "@/components/ui/switch";
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
import { toast } from "sonner";
import { exportUserData, submitFeedback } from "@/lib/actions/data";
import { appVersion } from "@/lib/data/settings";
import { format } from "date-fns";
import type { FeedbackData } from "@/types/settings";
import { signOut } from "@/lib/actions/auth";
import { useUserPreferences } from "@/hooks/use-user-preferences";
import { useUserStore } from "@/stores/user-store";
import { addUserRole, removeUserRole } from "@/lib/actions/portals";
import type { PortalRole } from "@/types/portals";

/**
 * Get time-based gradient class for dynamic theming
 */
function getTimeBasedGradientClass(): string {
  const hour = new Date().getHours();
  if (hour >= 5 && hour < 12) return "mesh-gradient-morning";
  if (hour >= 12 && hour < 18) return "mesh-gradient-afternoon";
  return "mesh-gradient-evening";
}

/* ─── Glassmorphic card wrapper ─── */
const GLASS_CARD =
  "bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 rounded-[20px] shadow-sm hover:shadow-xl hover:shadow-black/5 transition-all duration-300";

/**
 * Glassmorphic settings section card
 */
function SettingsSection({
  icon: Icon,
  title,
  description,
  variant,
  children,
  className,
}: {
  icon: React.ElementType;
  title: string;
  description?: string;
  variant?: "danger";
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <div
      className={cn(
        GLASS_CARD,
        "overflow-hidden",
        variant === "danger" && "bg-red-50/50 dark:bg-red-950/10 border-red-200/50 dark:border-red-900/30",
        className
      )}
    >
      {/* Header */}
      <div className="flex items-center gap-3 px-5 pt-5 pb-4">
        <div
          className={cn(
            "h-9 w-9 rounded-xl flex items-center justify-center shrink-0",
            variant === "danger"
              ? "bg-red-100 dark:bg-red-900/30"
              : "bg-[#765341]/10 dark:bg-[#765341]/20"
          )}
        >
          <Icon
            className={cn(
              "h-[18px] w-[18px]",
              variant === "danger"
                ? "text-red-600 dark:text-red-400"
                : "text-[#765341] dark:text-[#E4E1C7]"
            )}
          />
        </div>
        <div>
          <h3
            className={cn(
              "text-sm font-semibold",
              variant === "danger"
                ? "text-red-600 dark:text-red-400"
                : "text-foreground"
            )}
          >
            {title}
          </h3>
          {description && (
            <p className="text-xs text-muted-foreground">{description}</p>
          )}
        </div>
      </div>
      {/* Content */}
      <div className="px-5 pb-5">{children}</div>
    </div>
  );
}

/**
 * Toggle row: label + description left, switch right
 */
function SettingToggle({
  label,
  description,
  checked,
  onCheckedChange,
}: {
  label: string;
  description: string;
  checked: boolean;
  onCheckedChange: (checked: boolean) => void;
}) {
  return (
    <div className="flex items-center justify-between py-3">
      <div>
        <p className="text-sm font-medium text-foreground">{label}</p>
        <p className="text-xs text-muted-foreground">{description}</p>
      </div>
      <Switch
        checked={checked}
        onCheckedChange={onCheckedChange}
        className="ml-4 shrink-0"
      />
    </div>
  );
}

/**
 * Feedback type pill button
 */
function FeedbackTypePill({
  icon: Icon,
  label,
  isSelected,
  onClick,
}: {
  icon: React.ElementType;
  label: string;
  isSelected: boolean;
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={cn(
        "flex items-center gap-2 px-4 py-2 rounded-full text-xs font-medium transition-all duration-200 border",
        isSelected
          ? "bg-[#765341] text-white border-[#765341] shadow-md shadow-[#765341]/20"
          : "bg-white/60 dark:bg-white/5 text-muted-foreground border-border/50 hover:border-[#765341]/40 hover:text-foreground"
      )}
    >
      <Icon className="h-3.5 w-3.5" />
      {label}
    </button>
  );
}

/**
 * Legal / info link row
 */
function LegalLink({
  icon: Icon,
  label,
  description,
  href,
}: {
  icon: React.ElementType;
  label: string;
  description: string;
  href: string;
}) {
  return (
    <a
      href={href}
      target="_blank"
      rel="noopener noreferrer"
      className="flex items-center justify-between p-3 rounded-xl hover:bg-muted/50 transition-colors group"
    >
      <div className="flex items-center gap-3">
        <div className="h-8 w-8 rounded-lg bg-muted/60 flex items-center justify-center">
          <Icon className="h-4 w-4 text-muted-foreground" />
        </div>
        <div>
          <p className="text-sm font-medium text-foreground">{label}</p>
          <p className="text-xs text-muted-foreground">{description}</p>
        </div>
      </div>
      <ExternalLink className="h-4 w-4 text-muted-foreground group-hover:text-foreground transition-colors" />
    </a>
  );
}

/**
 * Danger-zone action row
 */
function DangerRow({
  label,
  description,
  button,
}: {
  label: string;
  description: string;
  button: React.ReactNode;
}) {
  return (
    <div className="flex items-center justify-between p-3 rounded-xl border border-red-200/60 dark:border-red-800/40">
      <div>
        <p className="text-sm font-medium text-red-600 dark:text-red-400">
          {label}
        </p>
        <p className="text-xs text-muted-foreground">{description}</p>
      </div>
      {button}
    </div>
  );
}

/**
 * Settings Page Component - Glassmorphic Bento Layout
 */
export function SettingsPro() {
  const [isExporting, setIsExporting] = useState(false);
  const [clearDialogOpen, setClearDialogOpen] = useState(false);
  const [deleteAccountDialogOpen, setDeleteAccountDialogOpen] = useState(false);
  const [feedback, setFeedback] = useState<FeedbackData>({
    type: "general",
    message: "",
  });
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isLoggingOut, setIsLoggingOut] = useState(false);

  const user = useUserStore((s) => s.user);
  const storeAddRole = useUserStore((s) => s.addRole);
  const storeRemoveRole = useUserStore((s) => s.removeRole);

  const userRoles: PortalRole[] = useMemo(() => {
    if (!user) return [];
    if (user.user_roles && user.user_roles.length > 0) return user.user_roles;
    return [user.user_type];
  }, [user]);

  const primaryRole = user?.user_type as PortalRole | undefined;

  const handleRoleToggle = (role: PortalRole, enabled: boolean) => {
    if (enabled) {
      storeAddRole(role);
      toast.success(`${role} role added`);
    } else {
      if (role === primaryRole) {
        toast.error("Cannot remove your primary role");
        return;
      }
      storeRemoveRole(role);
      toast.success(`${role} role removed`);
    }
    (enabled ? addUserRole(role) : removeUserRole(role)).catch(() => {});
  };

  const gradientClass = useMemo(() => getTimeBasedGradientClass(), []);

  const {
    preferences,
    isLoading: prefsLoading,
    isSaving,
    updateNotifications,
    updatePrivacy,
    updateAppearance,
  } = useUserPreferences();

  const lastUpdated = format(new Date(appVersion.lastUpdated), "MMM d, yyyy");

  /* ─── Handlers ─── */

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
      const a = document.createElement("a");
      a.href = url;
      a.download = "assignx-data-" + Date.now() + ".json";
      a.click();
      URL.revokeObjectURL(url);
      toast.success("Data exported successfully");
    } catch {
      toast.error("Failed to export data");
    } finally {
      setIsExporting(false);
    }
  };

  const handleClearCache = () => {
    localStorage.clear();
    sessionStorage.clear();
    toast.success("Cache cleared successfully");
    setClearDialogOpen(false);
  };

  const handleLogout = async () => {
    setIsLoggingOut(true);
    try {
      await signOut();
    } catch {
      toast.error("Failed to log out");
      setIsLoggingOut(false);
    }
  };

  const handleSubmitFeedback = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!feedback.message.trim()) {
      toast.error("Please enter your feedback");
      return;
    }
    setIsSubmitting(true);
    try {
      const satisfactionMap = { bug: 2, feature: 4, general: 3 };
      const result = await submitFeedback({
        overallSatisfaction:
          satisfactionMap[feedback.type as keyof typeof satisfactionMap] || 3,
        feedbackText: feedback.message,
        improvementSuggestions:
          feedback.type === "feature" ? feedback.message : undefined,
      });
      if (result.error) {
        toast.error(result.error);
        return;
      }
      toast.success("Thank you for your feedback!");
      setFeedback({ type: "general", message: "" });
    } catch {
      toast.error("Failed to submit feedback");
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleNotificationToggle = async (
    key:
      | "pushNotifications"
      | "emailNotifications"
      | "projectUpdates"
      | "marketingEmails"
      | "weeklyDigest"
  ) => {
    const success = await updateNotifications(key);
    if (success) {
      toast.success("Preference updated");
    } else {
      toast.error("Failed to save preference");
    }
  };

  const handlePrivacyToggle = async (
    key: "analyticsOptOut" | "showOnlineStatus"
  ) => {
    const success = await updatePrivacy(key);
    if (success) {
      toast.success("Setting updated");
    } else {
      toast.error("Failed to save setting");
    }
  };

  const handleAppearanceToggle = async (
    key: "reducedMotion" | "compactMode"
  ) => {
    const success = await updateAppearance(key);
    if (success) {
      toast.success("Setting updated");
    } else {
      toast.error("Failed to save setting");
    }
  };

  /* ─── Render ─── */

  return (
    <div
      className={cn(
        "mesh-background mesh-gradient-bottom-right-animated min-h-full",
        gradientClass
      )}
    >
      <main className="relative z-10 p-6 md:p-8 max-w-6xl mx-auto pb-24">
        {/* Page Header */}
        <StaggerItem>
          <div className="mb-8">
            <h1 className="text-2xl md:text-3xl font-semibold tracking-tight text-foreground">
              Settings
            </h1>
            <p className="text-sm text-muted-foreground mt-1">
              Manage your preferences and account
            </p>
          </div>
        </StaggerItem>

        {/* Two-column bento layout */}
        <div className="grid grid-cols-1 lg:grid-cols-[1fr_380px] gap-4 lg:gap-5">
          {/* ═══════════ LEFT COLUMN ═══════════ */}
          <div className="space-y-4 lg:space-y-5">
            {/* Notifications */}
            <StaggerItem>
              <SettingsSection
                icon={Bell}
                title="Notifications"
                description="Manage how you receive updates"
              >
                <div className="divide-y divide-border/30">
                  <SettingToggle
                    label="Push Notifications"
                    description="Get push notifications on your device"
                    checked={preferences.notifications.pushNotifications}
                    onCheckedChange={() =>
                      handleNotificationToggle("pushNotifications")
                    }
                  />
                  <SettingToggle
                    label="Email Notifications"
                    description="Receive important updates via email"
                    checked={preferences.notifications.emailNotifications}
                    onCheckedChange={() =>
                      handleNotificationToggle("emailNotifications")
                    }
                  />
                  <SettingToggle
                    label="Project Updates"
                    description="Get notified when projects are updated"
                    checked={preferences.notifications.projectUpdates}
                    onCheckedChange={() =>
                      handleNotificationToggle("projectUpdates")
                    }
                  />
                  <SettingToggle
                    label="Marketing Emails"
                    description="Receive promotional offers"
                    checked={preferences.notifications.marketingEmails}
                    onCheckedChange={() =>
                      handleNotificationToggle("marketingEmails")
                    }
                  />
                </div>
              </SettingsSection>
            </StaggerItem>

            {/* Privacy & Data */}
            <StaggerItem>
              <SettingsSection
                icon={Lock}
                title="Privacy & Data"
                description="Control your data and visibility"
              >
                <div className="divide-y divide-border/30">
                  <SettingToggle
                    label="Analytics Opt-out"
                    description="Disable anonymous usage analytics"
                    checked={preferences.privacy.analyticsOptOut}
                    onCheckedChange={() =>
                      handlePrivacyToggle("analyticsOptOut")
                    }
                  />
                  <SettingToggle
                    label="Show Online Status"
                    description="Let others see when you are online"
                    checked={preferences.privacy.showOnlineStatus}
                    onCheckedChange={() =>
                      handlePrivacyToggle("showOnlineStatus")
                    }
                  />
                </div>

                {/* Action buttons */}
                <div className="mt-4 pt-4 border-t border-border/30 space-y-2">
                  <button
                    onClick={handleExportData}
                    disabled={isExporting}
                    className="flex items-center justify-between w-full p-3 rounded-xl bg-muted/40 hover:bg-muted/70 transition-colors"
                  >
                    <div className="flex items-center gap-3">
                      <div className="h-8 w-8 rounded-lg bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center">
                        <FileJson className="h-4 w-4 text-blue-600" />
                      </div>
                      <div className="text-left">
                        <p className="text-sm font-medium text-foreground">
                          Export Data
                        </p>
                        <p className="text-xs text-muted-foreground">
                          Download your data as JSON
                        </p>
                      </div>
                    </div>
                    {isExporting ? (
                      <Loader2 className="h-4 w-4 animate-spin text-muted-foreground" />
                    ) : (
                      <Download className="h-4 w-4 text-muted-foreground" />
                    )}
                  </button>

                  <button
                    onClick={() => setClearDialogOpen(true)}
                    className="flex items-center justify-between w-full p-3 rounded-xl bg-muted/40 hover:bg-muted/70 transition-colors"
                  >
                    <div className="flex items-center gap-3">
                      <div className="h-8 w-8 rounded-lg bg-red-100 dark:bg-red-900/30 flex items-center justify-center">
                        <Trash2 className="h-4 w-4 text-red-600" />
                      </div>
                      <div className="text-left">
                        <p className="text-sm font-medium text-foreground">
                          Clear Cache
                        </p>
                        <p className="text-xs text-muted-foreground">
                          Clear local storage and session data
                        </p>
                      </div>
                    </div>
                    <ChevronRight className="h-4 w-4 text-muted-foreground" />
                  </button>
                </div>
              </SettingsSection>
            </StaggerItem>

            {/* Send Feedback */}
            <StaggerItem>
              <SettingsSection
                icon={MessageSquare}
                title="Send Feedback"
                description="Help us improve AssignX"
              >
                <form onSubmit={handleSubmitFeedback} className="space-y-4">
                  {/* Pill selectors */}
                  <div className="flex flex-wrap gap-2">
                    <FeedbackTypePill
                      icon={Bug}
                      label="Bug"
                      isSelected={feedback.type === "bug"}
                      onClick={() =>
                        setFeedback((p) => ({ ...p, type: "bug" }))
                      }
                    />
                    <FeedbackTypePill
                      icon={Lightbulb}
                      label="Feature"
                      isSelected={feedback.type === "feature"}
                      onClick={() =>
                        setFeedback((p) => ({ ...p, type: "feature" }))
                      }
                    />
                    <FeedbackTypePill
                      icon={MessageSquare}
                      label="General"
                      isSelected={feedback.type === "general"}
                      onClick={() =>
                        setFeedback((p) => ({ ...p, type: "general" }))
                      }
                    />
                  </div>

                  <Textarea
                    value={feedback.message}
                    onChange={(e) =>
                      setFeedback((p) => ({ ...p, message: e.target.value }))
                    }
                    placeholder={
                      feedback.type === "bug"
                        ? "Describe the issue..."
                        : feedback.type === "feature"
                          ? "Describe the feature..."
                          : "Share your thoughts..."
                    }
                    rows={4}
                    className="resize-none bg-white/50 dark:bg-white/5 border-border/40 rounded-xl"
                  />

                  <Button
                    type="submit"
                    disabled={isSubmitting}
                    className="w-full bg-[#765341] hover:bg-[#5e4233] text-white rounded-xl"
                  >
                    {isSubmitting ? (
                      <>
                        <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                        Sending...
                      </>
                    ) : (
                      <>
                        <Send className="h-4 w-4 mr-2" />
                        Send Feedback
                      </>
                    )}
                  </Button>
                </form>
              </SettingsSection>
            </StaggerItem>

            {/* Danger Zone */}
            <StaggerItem>
              <SettingsSection
                icon={Skull}
                title="Danger Zone"
                description="Irreversible actions"
                variant="danger"
              >
                <div className="space-y-2">
                  <DangerRow
                    label="Log Out"
                    description="Sign out of your account"
                    button={
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={handleLogout}
                        disabled={isLoggingOut}
                        className="border-red-200 text-red-600 hover:bg-red-50 dark:border-red-800 dark:hover:bg-red-900/20 rounded-xl"
                      >
                        {isLoggingOut ? (
                          <Loader2 className="h-4 w-4 animate-spin" />
                        ) : (
                          <LogOut className="h-4 w-4 mr-1" />
                        )}
                        Log Out
                      </Button>
                    }
                  />
                  <DangerRow
                    label="Deactivate Account"
                    description="Temporarily disable your account"
                    button={
                      <Button
                        variant="outline"
                        size="sm"
                        className="border-red-200 text-red-600 hover:bg-red-50 dark:border-red-800 dark:hover:bg-red-900/20 rounded-xl"
                      >
                        <UserX className="h-4 w-4 mr-1" />
                        Deactivate
                      </Button>
                    }
                  />
                  <DangerRow
                    label="Delete Account"
                    description="Permanently delete all data"
                    button={
                      <Button
                        variant="destructive"
                        size="sm"
                        onClick={() => setDeleteAccountDialogOpen(true)}
                        className="rounded-xl"
                      >
                        <Trash2 className="h-4 w-4 mr-1" />
                        Delete
                      </Button>
                    }
                  />
                </div>
              </SettingsSection>
            </StaggerItem>
          </div>

          {/* ═══════════ RIGHT COLUMN ═══════════ */}
          <div className="space-y-4 lg:space-y-5">
            {/* Appearance */}
            <StaggerItem>
              <SettingsSection
                icon={Paintbrush}
                title="Appearance"
                description="Customize how the app looks"
              >
                <div className="divide-y divide-border/30">
                  <SettingToggle
                    label="Reduced Motion"
                    description="Minimize animations throughout the app"
                    checked={preferences.appearance.reducedMotion}
                    onCheckedChange={() =>
                      handleAppearanceToggle("reducedMotion")
                    }
                  />
                  <SettingToggle
                    label="Compact Mode"
                    description="Use a more compact layout with less spacing"
                    checked={preferences.appearance.compactMode}
                    onCheckedChange={() =>
                      handleAppearanceToggle("compactMode")
                    }
                  />
                </div>
              </SettingsSection>
            </StaggerItem>

            {/* About AssignX */}
            <StaggerItem>
              <SettingsSection
                icon={Info}
                title="About AssignX"
                description="App information and legal"
              >
                {/* Version / Build / Status mini grid */}
                <div className="grid grid-cols-3 gap-2 mb-3">
                  <div className="p-3 rounded-xl bg-muted/40 text-center">
                    <p className="text-[10px] uppercase tracking-wider text-muted-foreground mb-0.5">
                      Version
                    </p>
                    <p className="text-sm font-mono font-semibold text-foreground">
                      {appVersion.version}
                    </p>
                  </div>
                  <div className="p-3 rounded-xl bg-muted/40 text-center">
                    <p className="text-[10px] uppercase tracking-wider text-muted-foreground mb-0.5">
                      Build
                    </p>
                    <p className="text-sm font-mono font-semibold text-foreground">
                      {appVersion.buildNumber}
                    </p>
                  </div>
                  <div className="p-3 rounded-xl bg-muted/40 text-center">
                    <p className="text-[10px] uppercase tracking-wider text-muted-foreground mb-0.5">
                      Status
                    </p>
                    <p className="text-sm font-semibold text-foreground">
                      Beta
                    </p>
                  </div>
                </div>

                <p className="text-xs text-center text-muted-foreground mb-4">
                  Last updated {lastUpdated}
                </p>

                <div className="space-y-1">
                  <LegalLink
                    icon={FileText}
                    label="Terms of Service"
                    description="Read our terms"
                    href="/terms"
                  />
                  <LegalLink
                    icon={Shield}
                    label="Privacy Policy"
                    description="How we handle data"
                    href="/privacy"
                  />
                  <LegalLink
                    icon={Scale}
                    label="Open Source"
                    description="Third-party licenses"
                    href="/open-source"
                  />
                </div>
              </SettingsSection>
            </StaggerItem>

            {/* My Roles */}
            <StaggerItem>
              <SettingsSection
                icon={Users}
                title="My Roles"
                description="Manage your portal access"
              >
                <div className="divide-y divide-border/30">
                  {(
                    [
                      {
                        role: "student" as PortalRole,
                        label: "Student",
                        desc: "Access Campus Connect",
                        icon: Users,
                      },
                      {
                        role: "professional" as PortalRole,
                        label: "Professional",
                        desc: "Access Job Portal",
                        icon: Briefcase,
                      },
                      {
                        role: "business" as PortalRole,
                        label: "Business",
                        desc: "Access Business Portal & VC Funding",
                        icon: Building2,
                      },
                    ] as const
                  ).map(({ role, label, desc, icon: RoleIcon }) => {
                    const isActive = userRoles.includes(role);
                    const isPrimary = primaryRole === role;

                    return (
                      <div
                        key={role}
                        className="flex items-center justify-between py-3"
                      >
                        <div className="flex items-center gap-3 flex-1 min-w-0">
                          <div className="h-8 w-8 rounded-lg bg-[#765341]/10 dark:bg-[#765341]/20 flex items-center justify-center shrink-0">
                            <RoleIcon className="h-4 w-4 text-[#765341] dark:text-[#E4E1C7]" />
                          </div>
                          <div className="min-w-0">
                            <div className="flex items-center gap-2">
                              <p className="text-sm font-medium text-foreground">
                                {label}
                              </p>
                              {isPrimary && (
                                <span className="text-[10px] font-medium px-1.5 py-0.5 rounded-md bg-[#765341]/10 text-[#765341] dark:text-[#E4E1C7]">
                                  Primary
                                </span>
                              )}
                            </div>
                            <p className="text-xs text-muted-foreground">
                              {desc}
                            </p>
                          </div>
                        </div>
                        <Switch
                          checked={isActive}
                          onCheckedChange={(checked) =>
                            handleRoleToggle(role, checked)
                          }
                          disabled={isPrimary}
                          className="ml-4 shrink-0"
                        />
                      </div>
                    );
                  })}
                </div>
              </SettingsSection>
            </StaggerItem>
          </div>
        </div>
      </main>

      {/* ─── Dialogs ─── */}

      <AlertDialog open={clearDialogOpen} onOpenChange={setClearDialogOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Clear cache?</AlertDialogTitle>
            <AlertDialogDescription>
              This will clear all locally stored data. You may need to log in
              again.
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

      <AlertDialog
        open={deleteAccountDialogOpen}
        onOpenChange={setDeleteAccountDialogOpen}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete your account?</AlertDialogTitle>
            <AlertDialogDescription>
              This action cannot be undone. All your data will be permanently
              deleted.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={() => {
                toast.error("Account deletion is not available in beta");
                setDeleteAccountDialogOpen(false);
              }}
              className="bg-red-600 hover:bg-red-700"
            >
              Delete Account
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
