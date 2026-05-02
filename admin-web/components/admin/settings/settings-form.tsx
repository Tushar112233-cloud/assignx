"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Switch } from "@/components/ui/switch";
import { Separator } from "@/components/ui/separator";
import { FeatureFlags } from "@/components/admin/settings/feature-flags";
import { CommissionSettings } from "@/components/admin/settings/commission-settings";
import { updateSetting, updateSettings } from "@/lib/admin/actions/settings";
import { toast } from "sonner";

type SettingsGroup = Record<
  string,
  { id: string; key: string; value: unknown; description: string | null }[]
>;

function getSettingValue(
  settings: SettingsGroup,
  category: string,
  key: string,
  fallback: unknown = null
): unknown {
  const group = settings[category] || [];
  const item = group.find((s) => s.key === key);
  return item?.value ?? fallback;
}

export function SettingsForm({ settings }: { settings: SettingsGroup }) {
  const router = useRouter();
  const [saving, setSaving] = useState(false);

  const [appName, setAppName] = useState(
    (getSettingValue(settings, "general", "app_name") as string) || "AssignX"
  );
  const [supportEmail, setSupportEmail] = useState(
    (getSettingValue(settings, "general", "support_email") as string) || ""
  );
  const [maintenanceMode, setMaintenanceMode] = useState(
    (getSettingValue(settings, "general", "maintenance_mode") as boolean) || false
  );

  const [maxFileSize, setMaxFileSize] = useState(
    String((getSettingValue(settings, "limits", "max_file_size_mb") as number) || 10)
  );
  const [maxProjectsPerUser, setMaxProjectsPerUser] = useState(
    String((getSettingValue(settings, "limits", "max_projects_per_user") as number) || 50)
  );

  const [emailOnNewUser, setEmailOnNewUser] = useState(
    (getSettingValue(settings, "notifications", "email_on_new_user") as boolean) || false
  );
  const [emailOnNewProject, setEmailOnNewProject] = useState(
    (getSettingValue(settings, "notifications", "email_on_new_project") as boolean) || false
  );
  const [emailOnPayment, setEmailOnPayment] = useState(
    (getSettingValue(settings, "notifications", "email_on_payment") as boolean) || false
  );
  const [emailOnTicket, setEmailOnTicket] = useState(
    (getSettingValue(settings, "notifications", "email_on_ticket") as boolean) || false
  );

  const handleSaveGeneral = async () => {
    setSaving(true);
    try {
      await updateSettings([
        { key: "app_name", value: appName },
        { key: "support_email", value: supportEmail },
        { key: "maintenance_mode", value: maintenanceMode },
      ]);
      toast.success("General settings saved");
      router.refresh();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to save");
    } finally {
      setSaving(false);
    }
  };

  const handleSaveLimits = async () => {
    setSaving(true);
    try {
      await updateSettings([
        { key: "max_file_size_mb", value: parseInt(maxFileSize) || 10 },
        { key: "max_projects_per_user", value: parseInt(maxProjectsPerUser) || 50 },
      ]);
      toast.success("Limit settings saved");
      router.refresh();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to save");
    } finally {
      setSaving(false);
    }
  };

  const handleSaveNotifications = async () => {
    setSaving(true);
    try {
      await updateSettings([
        { key: "email_on_new_user", value: emailOnNewUser },
        { key: "email_on_new_project", value: emailOnNewProject },
        { key: "email_on_payment", value: emailOnPayment },
        { key: "email_on_ticket", value: emailOnTicket },
      ]);
      toast.success("Notification settings saved");
      router.refresh();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to save");
    } finally {
      setSaving(false);
    }
  };

  return (
    <Tabs defaultValue="general" className="w-full">
      <TabsList className="mb-4">
        <TabsTrigger value="general">General</TabsTrigger>
        <TabsTrigger value="features">Features</TabsTrigger>
        <TabsTrigger value="payments">Payments</TabsTrigger>
        <TabsTrigger value="limits">Limits</TabsTrigger>
        <TabsTrigger value="notifications">Notifications</TabsTrigger>
      </TabsList>

      <TabsContent value="general">
        <Card>
          <CardHeader>
            <CardTitle>General Settings</CardTitle>
            <CardDescription>
              Basic platform configuration
            </CardDescription>
          </CardHeader>
          <CardContent className="flex flex-col gap-6">
            <div className="grid gap-4 sm:grid-cols-2">
              <div className="flex flex-col gap-2">
                <Label htmlFor="app_name">App Name</Label>
                <Input
                  id="app_name"
                  value={appName}
                  onChange={(e) => setAppName(e.target.value)}
                />
              </div>
              <div className="flex flex-col gap-2">
                <Label htmlFor="support_email">Support Email</Label>
                <Input
                  id="support_email"
                  type="email"
                  value={supportEmail}
                  onChange={(e) => setSupportEmail(e.target.value)}
                  placeholder="support@assignx.com"
                />
              </div>
            </div>
            <div className="flex items-center justify-between rounded-lg border p-4">
              <div>
                <p className="font-medium">Maintenance Mode</p>
                <p className="text-sm text-muted-foreground">
                  When enabled, users will see a maintenance page
                </p>
              </div>
              <Switch
                checked={maintenanceMode}
                onCheckedChange={setMaintenanceMode}
              />
            </div>
            <Button onClick={handleSaveGeneral} disabled={saving} className="w-fit">
              {saving ? "Saving..." : "Save General Settings"}
            </Button>
          </CardContent>
        </Card>
      </TabsContent>

      <TabsContent value="features">
        <FeatureFlags
          settings={settings}
          onSave={async (flags) => {
            setSaving(true);
            try {
              await updateSettings(flags);
              toast.success("Feature flags saved");
              router.refresh();
            } catch (err) {
              toast.error(
                err instanceof Error ? err.message : "Failed to save"
              );
            } finally {
              setSaving(false);
            }
          }}
          saving={saving}
        />
      </TabsContent>

      <TabsContent value="payments">
        <CommissionSettings
          settings={settings}
          onSave={async (commissions) => {
            setSaving(true);
            try {
              await updateSettings(commissions);
              toast.success("Commission settings saved");
              router.refresh();
            } catch (err) {
              toast.error(
                err instanceof Error ? err.message : "Failed to save"
              );
            } finally {
              setSaving(false);
            }
          }}
          saving={saving}
        />
      </TabsContent>

      <TabsContent value="limits">
        <Card>
          <CardHeader>
            <CardTitle>Platform Limits</CardTitle>
            <CardDescription>
              Configure usage limits and thresholds
            </CardDescription>
          </CardHeader>
          <CardContent className="flex flex-col gap-6">
            <div className="grid gap-4 sm:grid-cols-2">
              <div className="flex flex-col gap-2">
                <Label htmlFor="max_file_size">Max File Size (MB)</Label>
                <Input
                  id="max_file_size"
                  type="number"
                  value={maxFileSize}
                  onChange={(e) => setMaxFileSize(e.target.value)}
                  min={1}
                  max={100}
                />
              </div>
              <div className="flex flex-col gap-2">
                <Label htmlFor="max_projects">Max Projects per User</Label>
                <Input
                  id="max_projects"
                  type="number"
                  value={maxProjectsPerUser}
                  onChange={(e) => setMaxProjectsPerUser(e.target.value)}
                  min={1}
                  max={1000}
                />
              </div>
            </div>
            <Button onClick={handleSaveLimits} disabled={saving} className="w-fit">
              {saving ? "Saving..." : "Save Limits"}
            </Button>
          </CardContent>
        </Card>
      </TabsContent>

      <TabsContent value="notifications">
        <Card>
          <CardHeader>
            <CardTitle>Notification Settings</CardTitle>
            <CardDescription>
              Configure email notifications for admin events
            </CardDescription>
          </CardHeader>
          <CardContent className="flex flex-col gap-4">
            <div className="flex items-center justify-between rounded-lg border p-4">
              <div>
                <p className="font-medium">New User Registration</p>
                <p className="text-sm text-muted-foreground">
                  Send email when a new user registers
                </p>
              </div>
              <Switch checked={emailOnNewUser} onCheckedChange={setEmailOnNewUser} />
            </div>
            <div className="flex items-center justify-between rounded-lg border p-4">
              <div>
                <p className="font-medium">New Project Created</p>
                <p className="text-sm text-muted-foreground">
                  Send email when a new project is created
                </p>
              </div>
              <Switch checked={emailOnNewProject} onCheckedChange={setEmailOnNewProject} />
            </div>
            <div className="flex items-center justify-between rounded-lg border p-4">
              <div>
                <p className="font-medium">Payment Received</p>
                <p className="text-sm text-muted-foreground">
                  Send email when a payment is completed
                </p>
              </div>
              <Switch checked={emailOnPayment} onCheckedChange={setEmailOnPayment} />
            </div>
            <div className="flex items-center justify-between rounded-lg border p-4">
              <div>
                <p className="font-medium">Support Ticket</p>
                <p className="text-sm text-muted-foreground">
                  Send email when a new ticket is submitted
                </p>
              </div>
              <Switch checked={emailOnTicket} onCheckedChange={setEmailOnTicket} />
            </div>
            <Separator />
            <Button onClick={handleSaveNotifications} disabled={saving} className="w-fit">
              {saving ? "Saving..." : "Save Notification Settings"}
            </Button>
          </CardContent>
        </Card>
      </TabsContent>
    </Tabs>
  );
}
