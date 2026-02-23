/**
 * @fileoverview Hook for managing user preferences with Supabase persistence.
 * @module hooks/use-user-preferences
 */

"use client";

import { useState, useEffect, useCallback } from "react";
import { createClient } from "@/lib/supabase/client";
import { useUserStore } from "@/stores/user-store";

export interface NotificationPreferences {
  pushNotifications: boolean;
  emailNotifications: boolean;
  projectUpdates: boolean;
  marketingEmails: boolean;
  weeklyDigest: boolean;
}

export interface PrivacySettings {
  analyticsOptOut: boolean;
  showOnlineStatus: boolean;
}

export interface AppearanceSettings {
  reducedMotion: boolean;
  compactMode: boolean;
}

export interface UserPreferences {
  notifications: NotificationPreferences;
  privacy: PrivacySettings;
  appearance: AppearanceSettings;
}

const DEFAULT_PREFERENCES: UserPreferences = {
  notifications: {
    pushNotifications: true,
    emailNotifications: true,
    projectUpdates: true,
    marketingEmails: false,
    weeklyDigest: true,
  },
  privacy: {
    analyticsOptOut: false,
    showOnlineStatus: true,
  },
  appearance: {
    reducedMotion: false,
    compactMode: false,
  },
};

/**
 * Hook to manage user preferences with Supabase persistence
 */
export function useUserPreferences() {
  const { user } = useUserStore();
  const [preferences, setPreferences] = useState<UserPreferences>(DEFAULT_PREFERENCES);
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);

  // Load preferences from Supabase on mount
  useEffect(() => {
    if (!user?.id) {
      setIsLoading(false);
      return;
    }

    const loadPreferences = async () => {
      const supabase = createClient();

      try {
        const { data, error } = await supabase
          .from("profiles")
          .select("notification_preferences, settings")
          .eq("id", user.id)
          .single();

        if (error) {
          console.error("Error loading preferences:", error);
          return;
        }

        if (data) {
          const notificationPrefs = data.notification_preferences as Partial<NotificationPreferences> | null;
          const settingsData = data.settings as { privacy?: Partial<PrivacySettings>; appearance?: Partial<AppearanceSettings> } | null;

          setPreferences({
            notifications: { ...DEFAULT_PREFERENCES.notifications, ...notificationPrefs },
            privacy: { ...DEFAULT_PREFERENCES.privacy, ...settingsData?.privacy },
            appearance: { ...DEFAULT_PREFERENCES.appearance, ...settingsData?.appearance },
          });
        }
      } catch (err) {
        console.error("Failed to load preferences:", err);
      } finally {
        setIsLoading(false);
      }
    };

    loadPreferences();
  }, [user?.id]);

  // Save preferences to Supabase
  const savePreferences = useCallback(async (newPreferences: UserPreferences) => {
    if (!user?.id) return false;

    setIsSaving(true);
    const supabase = createClient();

    try {
      const { error } = await supabase
        .from("profiles")
        .update({
          notification_preferences: newPreferences.notifications,
          settings: {
            privacy: newPreferences.privacy,
            appearance: newPreferences.appearance,
          },
          updated_at: new Date().toISOString(),
        })
        .eq("id", user.id);

      if (error) {
        console.error("Error saving preferences:", error);
        return false;
      }

      setPreferences(newPreferences);
      return true;
    } catch (err) {
      console.error("Failed to save preferences:", err);
      return false;
    } finally {
      setIsSaving(false);
    }
  }, [user?.id]);

  // Update notification preferences
  const updateNotifications = useCallback(async (key: keyof NotificationPreferences) => {
    const newPreferences = {
      ...preferences,
      notifications: {
        ...preferences.notifications,
        [key]: !preferences.notifications[key],
      },
    };

    const success = await savePreferences(newPreferences);
    return success;
  }, [preferences, savePreferences]);

  // Update privacy settings
  const updatePrivacy = useCallback(async (key: keyof PrivacySettings) => {
    const newPreferences = {
      ...preferences,
      privacy: {
        ...preferences.privacy,
        [key]: !preferences.privacy[key],
      },
    };

    const success = await savePreferences(newPreferences);
    return success;
  }, [preferences, savePreferences]);

  // Update appearance settings
  const updateAppearance = useCallback(async (key: keyof AppearanceSettings) => {
    const newPreferences = {
      ...preferences,
      appearance: {
        ...preferences.appearance,
        [key]: !preferences.appearance[key],
      },
    };

    const success = await savePreferences(newPreferences);
    return success;
  }, [preferences, savePreferences]);

  return {
    preferences,
    isLoading,
    isSaving,
    updateNotifications,
    updatePrivacy,
    updateAppearance,
  };
}
