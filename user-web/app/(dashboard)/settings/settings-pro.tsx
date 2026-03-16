"use client";

import { useState, useMemo, type ReactNode } from "react";
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
  LogOut,
  ChevronRight,
  Users,
  Briefcase,
  Building2,
  X,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Switch } from "@/components/ui/switch";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
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

/* ─── Settings row that opens a dialog ─── */
function SettingsRow({
  icon: Icon,
  title,
  description,
  onClick,
  variant,
  trailing,
}: {
  icon: React.ElementType;
  title: string;
  description: string;
  onClick?: () => void;
  variant?: "danger";
  trailing?: ReactNode;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={cn(
        "flex items-center gap-4 w-full p-4 text-left rounded-2xl transition-all duration-200",
        "bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10",
        "hover:shadow-lg hover:shadow-black/5 hover:-translate-y-0.5 active:translate-y-0",
        variant === "danger" && "bg-red-50/50 dark:bg-red-950/10 border-red-200/50"
      )}
    >
      <div
        className={cn(
          "h-10 w-10 rounded-xl flex items-center justify-center shrink-0",
          variant === "danger"
            ? "bg-red-100 dark:bg-red-900/30"
            : "bg-[#765341]/10 dark:bg-[#765341]/20"
        )}
      >
        <Icon
          className={cn(
            "h-5 w-5",
            variant === "danger"
              ? "text-red-600 dark:text-red-400"
              : "text-[#765341] dark:text-[#E4E1C7]"
          )}
        />
      </div>
      <div className="flex-1 min-w-0">
        <p className={cn(
          "text-sm font-semibold",
          variant === "danger" ? "text-red-600" : "text-foreground"
        )}>
          {title}
        </p>
        <p className="text-xs text-muted-foreground">{description}</p>
      </div>
      {trailing || <ChevronRight className="h-4 w-4 text-muted-foreground shrink-0" />}
    </button>
  );
}

/* ─── Toggle row inside dialogs ─── */
function ToggleRow({
  label,
  description,
  checked,
  onCheckedChange,
}: {
  label: string;
  description: string;
  checked: boolean;
  onCheckedChange: (v: boolean) => void;
}) {
  return (
    <div className="flex items-center justify-between py-3">
      <div>
        <p className="text-sm font-medium">{label}</p>
        <p className="text-xs text-muted-foreground">{description}</p>
      </div>
      <Switch checked={checked} onCheckedChange={onCheckedChange} className="ml-4 shrink-0" />
    </div>
  );
}

export function SettingsPro() {
  const [activeDialog, setActiveDialog] = useState<string | null>(null);
  const [isExporting, setIsExporting] = useState(false);
  const [clearDialogOpen, setClearDialogOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [feedback, setFeedback] = useState<FeedbackData>({ type: "general", message: "" });
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

  const { preferences, updateNotifications, updatePrivacy, updateAppearance } = useUserPreferences();
  const lastUpdated = format(new Date(appVersion.lastUpdated), "MMM d, yyyy");

  const open = (id: string) => setActiveDialog(id);
  const close = () => setActiveDialog(null);

  /* ─── Handlers ─── */
  const handleExportData = async () => {
    setIsExporting(true);
    try {
      const result = await exportUserData();
      if (result.error) { toast.error(result.error); return; }
      const blob = new Blob([JSON.stringify(result.data, null, 2)], { type: "application/json" });
      const url = URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = `assignx-data-${Date.now()}.json`;
      a.click();
      URL.revokeObjectURL(url);
      toast.success("Data exported successfully");
    } catch { toast.error("Failed to export data"); }
    finally { setIsExporting(false); }
  };

  const handleRoleToggle = (role: PortalRole, enabled: boolean) => {
    if (enabled) { storeAddRole(role); toast.success(`${role} role added`); }
    else {
      if (role === primaryRole) { toast.error("Cannot remove your primary role"); return; }
      storeRemoveRole(role); toast.success(`${role} role removed`);
    }
    (enabled ? addUserRole(role) : removeUserRole(role)).catch(() => {});
  };

  const handleSubmitFeedback = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!feedback.message.trim()) { toast.error("Please enter your feedback"); return; }
    setIsSubmitting(true);
    try {
      const map = { bug: 2, feature: 4, general: 3 };
      const result = await submitFeedback({
        overallSatisfaction: map[feedback.type as keyof typeof map] || 3,
        feedbackText: feedback.message,
        improvementSuggestions: feedback.type === "feature" ? feedback.message : undefined,
      });
      if (result.error) { toast.error(result.error); return; }
      toast.success("Thank you for your feedback!");
      setFeedback({ type: "general", message: "" });
      close();
    } catch { toast.error("Failed to submit feedback"); }
    finally { setIsSubmitting(false); }
  };

  const toggle = async (fn: (k: any) => Promise<boolean>, key: string) => {
    const ok = await fn(key);
    toast[ok ? "success" : "error"](ok ? "Updated" : "Failed to save");
  };

  return (
    <div className="min-h-full bg-background">
      <main className="max-w-lg mx-auto px-4 py-8 pb-28 space-y-3">
        {/* Header */}
        <div className="mb-6">
          <h1 className="text-2xl font-semibold tracking-tight">Settings</h1>
          <p className="text-sm text-muted-foreground mt-1">Manage your preferences</p>
        </div>

        {/* ─── Setting Rows ─── */}
        <SettingsRow icon={Bell} title="Notifications" description="Push, email & project updates" onClick={() => open("notifications")} />
        <SettingsRow icon={Lock} title="Privacy & Data" description="Analytics, visibility & export" onClick={() => open("privacy")} />
        <SettingsRow icon={Paintbrush} title="Appearance" description="Motion & compact mode" onClick={() => open("appearance")} />
        <SettingsRow icon={Users} title="My Roles" description="Manage portal access" onClick={() => open("roles")} />
        <SettingsRow icon={MessageSquare} title="Send Feedback" description="Bug reports & feature requests" onClick={() => open("feedback")} />
        <SettingsRow icon={Info} title="About AssignX" description={`v${appVersion.version} · ${lastUpdated}`} onClick={() => open("about")} />

        <div className="pt-2" />

        <SettingsRow
          icon={LogOut}
          title="Log Out"
          description="Sign out of your account"
          variant="danger"
          onClick={async () => { setIsLoggingOut(true); try { await signOut(); } catch { toast.error("Failed"); setIsLoggingOut(false); } }}
          trailing={isLoggingOut ? <Loader2 className="h-4 w-4 animate-spin text-red-500" /> : <ChevronRight className="h-4 w-4 text-red-400" />}
        />
        <SettingsRow icon={Trash2} title="Delete Account" description="Permanently remove all data" variant="danger" onClick={() => setDeleteDialogOpen(true)} />
      </main>

      {/* ════════════════ DIALOGS ════════════════ */}

      {/* Notifications */}
      <Dialog open={activeDialog === "notifications"} onOpenChange={(o) => !o && close()}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2"><Bell className="h-5 w-5 text-[#765341]" /> Notifications</DialogTitle>
            <DialogDescription>Choose what updates you receive</DialogDescription>
          </DialogHeader>
          <div className="divide-y">
            <ToggleRow label="Push Notifications" description="On your device" checked={preferences.notifications.pushNotifications} onCheckedChange={() => toggle(updateNotifications, "pushNotifications")} />
            <ToggleRow label="Email Notifications" description="Important updates via email" checked={preferences.notifications.emailNotifications} onCheckedChange={() => toggle(updateNotifications, "emailNotifications")} />
            <ToggleRow label="Project Updates" description="When projects change status" checked={preferences.notifications.projectUpdates} onCheckedChange={() => toggle(updateNotifications, "projectUpdates")} />
            <ToggleRow label="Marketing Emails" description="Promotions and offers" checked={preferences.notifications.marketingEmails} onCheckedChange={() => toggle(updateNotifications, "marketingEmails")} />
          </div>
        </DialogContent>
      </Dialog>

      {/* Privacy & Data */}
      <Dialog open={activeDialog === "privacy"} onOpenChange={(o) => !o && close()}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2"><Lock className="h-5 w-5 text-[#765341]" /> Privacy & Data</DialogTitle>
            <DialogDescription>Control your data and visibility</DialogDescription>
          </DialogHeader>
          <div className="divide-y">
            <ToggleRow label="Analytics Opt-out" description="Disable usage analytics" checked={preferences.privacy.analyticsOptOut} onCheckedChange={() => toggle(updatePrivacy, "analyticsOptOut")} />
            <ToggleRow label="Show Online Status" description="Others can see when you're online" checked={preferences.privacy.showOnlineStatus} onCheckedChange={() => toggle(updatePrivacy, "showOnlineStatus")} />
          </div>
          <div className="space-y-2 pt-2 border-t">
            <button onClick={handleExportData} disabled={isExporting} className="flex items-center gap-3 w-full p-3 rounded-xl hover:bg-muted/50 transition-colors">
              <div className="h-8 w-8 rounded-lg bg-blue-100 flex items-center justify-center"><FileJson className="h-4 w-4 text-blue-600" /></div>
              <div className="flex-1 text-left">
                <p className="text-sm font-medium">Export Data</p>
                <p className="text-xs text-muted-foreground">Download as JSON</p>
              </div>
              {isExporting ? <Loader2 className="h-4 w-4 animate-spin" /> : <Download className="h-4 w-4 text-muted-foreground" />}
            </button>
            <button onClick={() => { close(); setClearDialogOpen(true); }} className="flex items-center gap-3 w-full p-3 rounded-xl hover:bg-muted/50 transition-colors">
              <div className="h-8 w-8 rounded-lg bg-red-100 flex items-center justify-center"><Trash2 className="h-4 w-4 text-red-600" /></div>
              <div className="flex-1 text-left">
                <p className="text-sm font-medium">Clear Cache</p>
                <p className="text-xs text-muted-foreground">Clear local data</p>
              </div>
              <ChevronRight className="h-4 w-4 text-muted-foreground" />
            </button>
          </div>
        </DialogContent>
      </Dialog>

      {/* Appearance */}
      <Dialog open={activeDialog === "appearance"} onOpenChange={(o) => !o && close()}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2"><Paintbrush className="h-5 w-5 text-[#765341]" /> Appearance</DialogTitle>
            <DialogDescription>Customize how the app looks</DialogDescription>
          </DialogHeader>
          <div className="divide-y">
            <ToggleRow label="Reduced Motion" description="Minimize animations" checked={preferences.appearance.reducedMotion} onCheckedChange={() => toggle(updateAppearance, "reducedMotion")} />
            <ToggleRow label="Compact Mode" description="Less spacing throughout" checked={preferences.appearance.compactMode} onCheckedChange={() => toggle(updateAppearance, "compactMode")} />
          </div>
        </DialogContent>
      </Dialog>

      {/* My Roles */}
      <Dialog open={activeDialog === "roles"} onOpenChange={(o) => !o && close()}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2"><Users className="h-5 w-5 text-[#765341]" /> My Roles</DialogTitle>
            <DialogDescription>Toggle portal access for your account</DialogDescription>
          </DialogHeader>
          <div className="divide-y">
            {([
              { role: "student" as PortalRole, label: "Student", desc: "Campus Connect", icon: Users },
              { role: "professional" as PortalRole, label: "Professional", desc: "Job Portal", icon: Briefcase },
              { role: "business" as PortalRole, label: "Business", desc: "Business Portal & VC", icon: Building2 },
            ] as const).map(({ role, label, desc, icon: RIcon }) => {
              const isActive = userRoles.includes(role);
              const isPrimary = primaryRole === role;
              return (
                <div key={role} className="flex items-center justify-between py-3">
                  <div className="flex items-center gap-3">
                    <div className="h-8 w-8 rounded-lg bg-[#765341]/10 flex items-center justify-center">
                      <RIcon className="h-4 w-4 text-[#765341]" />
                    </div>
                    <div>
                      <div className="flex items-center gap-2">
                        <p className="text-sm font-medium">{label}</p>
                        {isPrimary && <span className="text-[10px] font-medium px-1.5 py-0.5 rounded-md bg-[#765341]/10 text-[#765341]">Primary</span>}
                      </div>
                      <p className="text-xs text-muted-foreground">{desc}</p>
                    </div>
                  </div>
                  <Switch checked={isActive} onCheckedChange={(c) => handleRoleToggle(role, c)} disabled={isPrimary} className="ml-4" />
                </div>
              );
            })}
          </div>
        </DialogContent>
      </Dialog>

      {/* Feedback */}
      <Dialog open={activeDialog === "feedback"} onOpenChange={(o) => !o && close()}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2"><MessageSquare className="h-5 w-5 text-[#765341]" /> Send Feedback</DialogTitle>
            <DialogDescription>Help us improve AssignX</DialogDescription>
          </DialogHeader>
          <form onSubmit={handleSubmitFeedback} className="space-y-4">
            <div className="flex gap-2">
              {([
                { type: "bug", icon: Bug, label: "Bug" },
                { type: "feature", icon: Lightbulb, label: "Feature" },
                { type: "general", icon: MessageSquare, label: "General" },
              ] as const).map(({ type, icon: FIcon, label }) => (
                <button
                  key={type}
                  type="button"
                  onClick={() => setFeedback((p) => ({ ...p, type }))}
                  className={cn(
                    "flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium border transition-all",
                    feedback.type === type
                      ? "bg-[#765341] text-white border-[#765341]"
                      : "bg-muted/40 text-muted-foreground border-border/50 hover:border-[#765341]/40"
                  )}
                >
                  <FIcon className="h-3.5 w-3.5" />{label}
                </button>
              ))}
            </div>
            <Textarea
              value={feedback.message}
              onChange={(e) => setFeedback((p) => ({ ...p, message: e.target.value }))}
              placeholder={feedback.type === "bug" ? "Describe the issue..." : feedback.type === "feature" ? "Describe the feature..." : "Share your thoughts..."}
              rows={4}
              className="resize-none rounded-xl"
            />
            <Button type="submit" disabled={isSubmitting} className="w-full bg-[#765341] hover:bg-[#5e4233] text-white rounded-xl">
              {isSubmitting ? <><Loader2 className="h-4 w-4 mr-2 animate-spin" />Sending...</> : <><Send className="h-4 w-4 mr-2" />Send Feedback</>}
            </Button>
          </form>
        </DialogContent>
      </Dialog>

      {/* About */}
      <Dialog open={activeDialog === "about"} onOpenChange={(o) => !o && close()}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2"><Info className="h-5 w-5 text-[#765341]" /> About AssignX</DialogTitle>
          </DialogHeader>
          <div className="grid grid-cols-3 gap-2 mb-4">
            {[
              { label: "Version", value: appVersion.version },
              { label: "Build", value: appVersion.buildNumber },
              { label: "Status", value: "Beta" },
            ].map((s) => (
              <div key={s.label} className="p-3 rounded-xl bg-muted/40 text-center">
                <p className="text-[10px] uppercase tracking-wider text-muted-foreground mb-0.5">{s.label}</p>
                <p className="text-sm font-mono font-semibold">{s.value}</p>
              </div>
            ))}
          </div>
          <p className="text-xs text-center text-muted-foreground mb-3">Last updated {lastUpdated}</p>
          <div className="space-y-1">
            {([
              { icon: FileText, label: "Terms of Service", desc: "Read our terms", href: "/terms" },
              { icon: Shield, label: "Privacy Policy", desc: "How we handle data", href: "/privacy" },
              { icon: Scale, label: "Open Source", desc: "Third-party licenses", href: "/open-source" },
            ] as const).map((link) => (
              <a key={link.href} href={link.href} target="_blank" rel="noopener noreferrer" className="flex items-center justify-between p-3 rounded-xl hover:bg-muted/50 transition-colors">
                <div className="flex items-center gap-3">
                  <div className="h-8 w-8 rounded-lg bg-muted/60 flex items-center justify-center"><link.icon className="h-4 w-4 text-muted-foreground" /></div>
                  <div>
                    <p className="text-sm font-medium">{link.label}</p>
                    <p className="text-xs text-muted-foreground">{link.desc}</p>
                  </div>
                </div>
                <ExternalLink className="h-4 w-4 text-muted-foreground" />
              </a>
            ))}
          </div>
        </DialogContent>
      </Dialog>

      {/* ─── Alert Dialogs ─── */}
      <AlertDialog open={clearDialogOpen} onOpenChange={setClearDialogOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Clear cache?</AlertDialogTitle>
            <AlertDialogDescription>This will clear all locally stored data. You may need to log in again.</AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={() => { localStorage.clear(); sessionStorage.clear(); toast.success("Cache cleared"); setClearDialogOpen(false); }}>Clear Cache</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      <AlertDialog open={deleteDialogOpen} onOpenChange={setDeleteDialogOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete your account?</AlertDialogTitle>
            <AlertDialogDescription>This action cannot be undone. All your data will be permanently deleted.</AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={() => { toast.error("Account deletion is not available in beta"); setDeleteDialogOpen(false); }} className="bg-red-600 hover:bg-red-700">Delete Account</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
