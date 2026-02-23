"use client";

import { useState } from "react";
import { Loader2, Sun, Moon, Monitor, Bell, Globe } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Separator } from "@/components/ui/separator";
import { toast } from "sonner";
import { languageOptions, themeOptions } from "@/lib/data/profile";
import type {
  UserPreferences,
  ThemeOption,
  LanguageOption,
  NotificationPreferences,
} from "@/types/profile";

interface PreferencesSectionProps {
  preferences: UserPreferences;
  onSave: (data: UserPreferences) => Promise<void>;
}

const ThemeIcon = ({ theme }: { theme: ThemeOption }) => {
  switch (theme) {
    case "light":
      return <Sun className="h-4 w-4" />;
    case "dark":
      return <Moon className="h-4 w-4" />;
    case "system":
      return <Monitor className="h-4 w-4" />;
  }
};

/**
 * User preferences section component
 */
export function PreferencesSection({
  preferences,
  onSave,
}: PreferencesSectionProps) {
  const [formData, setFormData] = useState<UserPreferences>({
    ...preferences,
    notifications: { ...preferences.notifications },
  });
  const [isSaving, setIsSaving] = useState(false);
  const [hasChanges, setHasChanges] = useState(false);

  const handleThemeChange = (theme: ThemeOption) => {
    setFormData((prev) => ({ ...prev, theme }));
    setHasChanges(true);
  };

  const handleLanguageChange = (language: LanguageOption) => {
    setFormData((prev) => ({ ...prev, language }));
    setHasChanges(true);
  };

  const handleNotificationChange = <K extends keyof NotificationPreferences>(
    key: K,
    value: boolean
  ) => {
    setFormData((prev) => ({
      ...prev,
      notifications: {
        ...prev.notifications,
        [key]: value,
      },
    }));
    setHasChanges(true);
  };

  const handleSubmit = async () => {
    setIsSaving(true);
    try {
      await onSave(formData);
      toast.success("Preferences updated");
      setHasChanges(false);
    } catch {
      toast.error("Failed to update preferences");
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Appearance */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <ThemeIcon theme={formData.theme} />
            Appearance
          </CardTitle>
          <CardDescription>
            Customize how the app looks on your device
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-2">
            <Label>Theme</Label>
            <div className="grid grid-cols-3 gap-2">
              {themeOptions.map((option) => (
                <Button
                  key={option.value}
                  variant={
                    formData.theme === option.value ? "default" : "outline"
                  }
                  className="w-full"
                  onClick={() => handleThemeChange(option.value as ThemeOption)}
                >
                  <ThemeIcon theme={option.value as ThemeOption} />
                  <span className="ml-2">{option.label}</span>
                </Button>
              ))}
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Language */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Globe className="h-5 w-5" />
            Language
          </CardTitle>
          <CardDescription>
            Choose your preferred language for the interface
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Select
            value={formData.language}
            onValueChange={(value: LanguageOption) =>
              handleLanguageChange(value)
            }
          >
            <SelectTrigger className="w-full sm:w-64">
              <SelectValue placeholder="Select language" />
            </SelectTrigger>
            <SelectContent>
              {languageOptions.map((option) => (
                <SelectItem key={option.value} value={option.value}>
                  <span className="flex items-center gap-2">
                    <span>{option.flag}</span>
                    <span>{option.label}</span>
                  </span>
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </CardContent>
      </Card>

      {/* Notifications */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Bell className="h-5 w-5" />
            Notifications
          </CardTitle>
          <CardDescription>
            Manage how you receive updates and alerts
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          {/* Notification Channels */}
          <div className="space-y-4">
            <h4 className="text-sm font-medium">Notification Channels</h4>
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <div className="space-y-0.5">
                  <Label htmlFor="email-notifications">Email Notifications</Label>
                  <p className="text-sm text-muted-foreground">
                    Receive updates via email
                  </p>
                </div>
                <Switch
                  id="email-notifications"
                  checked={formData.notifications.emailNotifications}
                  onCheckedChange={(checked) =>
                    handleNotificationChange("emailNotifications", checked)
                  }
                />
              </div>
              <div className="flex items-center justify-between">
                <div className="space-y-0.5">
                  <Label htmlFor="push-notifications">Push Notifications</Label>
                  <p className="text-sm text-muted-foreground">
                    Browser push notifications
                  </p>
                </div>
                <Switch
                  id="push-notifications"
                  checked={formData.notifications.pushNotifications}
                  onCheckedChange={(checked) =>
                    handleNotificationChange("pushNotifications", checked)
                  }
                />
              </div>
              <div className="flex items-center justify-between">
                <div className="space-y-0.5">
                  <Label htmlFor="in-app-notifications">In-App Notifications</Label>
                  <p className="text-sm text-muted-foreground">
                    Notifications within the app
                  </p>
                </div>
                <Switch
                  id="in-app-notifications"
                  checked={formData.notifications.inAppNotifications}
                  onCheckedChange={(checked) =>
                    handleNotificationChange("inAppNotifications", checked)
                  }
                />
              </div>
            </div>
          </div>

          <Separator />

          {/* Notification Types */}
          <div className="space-y-4">
            <h4 className="text-sm font-medium">Notification Types</h4>
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <div className="space-y-0.5">
                  <Label htmlFor="project-updates">Project Updates</Label>
                  <p className="text-sm text-muted-foreground">
                    Status changes, deliverables, messages
                  </p>
                </div>
                <Switch
                  id="project-updates"
                  checked={formData.notifications.projectUpdates}
                  onCheckedChange={(checked) =>
                    handleNotificationChange("projectUpdates", checked)
                  }
                />
              </div>
              <div className="flex items-center justify-between">
                <div className="space-y-0.5">
                  <Label htmlFor="weekly-digest">Weekly Digest</Label>
                  <p className="text-sm text-muted-foreground">
                    Summary of your weekly activity
                  </p>
                </div>
                <Switch
                  id="weekly-digest"
                  checked={formData.notifications.weeklyDigest}
                  onCheckedChange={(checked) =>
                    handleNotificationChange("weeklyDigest", checked)
                  }
                />
              </div>
              <div className="flex items-center justify-between">
                <div className="space-y-0.5">
                  <Label htmlFor="marketing-emails">Marketing Emails</Label>
                  <p className="text-sm text-muted-foreground">
                    Tips, promotions, and announcements
                  </p>
                </div>
                <Switch
                  id="marketing-emails"
                  checked={formData.notifications.marketingEmails}
                  onCheckedChange={(checked) =>
                    handleNotificationChange("marketingEmails", checked)
                  }
                />
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Save button */}
      <div className="flex justify-end">
        <Button onClick={handleSubmit} disabled={!hasChanges || isSaving}>
          {isSaving ? (
            <>
              <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              Saving...
            </>
          ) : (
            "Save Preferences"
          )}
        </Button>
      </div>
    </div>
  );
}
