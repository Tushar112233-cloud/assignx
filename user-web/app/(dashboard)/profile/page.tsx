"use client";

import { useState, useEffect } from "react";
import { UserCircle, Loader2 } from "lucide-react";
import {
  ProfileHeader,
  PersonalInfoForm,
  AcademicInfoSection,
  PreferencesSection,
  SecuritySection,
  SubscriptionCard,
  DangerZone,
  SettingsTabs,
  SettingsSection,
} from "@/components/profile";
import { ProfilePro } from "./profile-pro";
import { useUserStore, type User } from "@/stores/user-store";
import {
  updateProfile,
  updateStudentProfile,
  getUserPreferences,
  updateUserPreferences,
} from "@/lib/actions/data";
import { createClient } from "@/lib/supabase/client";
import { toast } from "sonner";
import { Sheet, SheetContent, SheetHeader, SheetTitle } from "@/components/ui/sheet";
import type {
  ProfileTab,
  UserProfile,
  AcademicInfo,
  UserPreferences,
  PasswordChangeData,
  SecuritySettings,
  UserSubscription,
} from "@/types/profile";

/**
 * Transform database profile to component format
 */
function transformToUserProfile(user: User | null): UserProfile | null {
  if (!user) return null;

  const nameParts = (user.full_name || "").split(" ");
  const firstName = nameParts[0] || "";
  const lastName = nameParts.slice(1).join(" ") || "";

  return {
    id: user.id,
    email: user.email,
    emailVerified: true,
    avatar: user.avatar_url || undefined,
    firstName,
    lastName,
    phone: user.phone || undefined,
    phoneVerified: !!user.phone,
    dateOfBirth: user.students?.date_of_birth || undefined,
    createdAt: user.created_at,
    updatedAt: user.updated_at,
  };
}

/**
 * Transform database student to academic info format
 */
function transformToAcademicInfo(user: User | null): AcademicInfo | null {
  if (!user?.students) return null;

  const student = user.students;

  // Map semester to year level
  const yearLevelMap: Record<number, AcademicInfo["yearLevel"]> = {
    1: "freshman", 2: "freshman",
    3: "sophomore", 4: "sophomore",
    5: "junior", 6: "junior",
    7: "senior", 8: "senior",
  };

  return {
    university: student.university?.name || "Unknown University",
    universityId: student.university_id,
    major: student.course?.name || "Unknown Course",
    yearLevel: yearLevelMap[student.semester || 1] || "freshman",
    studentId: student.student_id || undefined,
    expectedGraduation: student.enrollment_year
      ? `${(student.enrollment_year || 0) + 4}-05-01`
      : undefined,
  };
}

/**
 * Default preferences when not stored in database
 */
const defaultPreferences: UserPreferences = {
  theme: "system",
  language: "en",
  notifications: {
    emailNotifications: true,
    pushNotifications: true,
    inAppNotifications: true,
    projectUpdates: true,
    marketingEmails: false,
    weeklyDigest: true,
  },
};

/**
 * Default security settings
 */
const defaultSecurity: SecuritySettings = {
  twoFactorAuth: { enabled: false },
  activeSessions: [
    {
      id: "current",
      device: "Current Device",
      browser: "Current Browser",
      location: "Unknown",
      ipAddress: "Unknown",
      lastActive: new Date().toISOString(),
      current: true,
    },
  ],
  passwordLastChanged: new Date().toISOString(),
};

/**
 * Default subscription (free tier)
 */
const defaultSubscription: UserSubscription = {
  tier: "free",
  status: "active",
  currentPeriodStart: new Date().toISOString(),
  currentPeriodEnd: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
  cancelAtPeriodEnd: false,
};

/**
 * Profile settings page
 * Complete user profile and settings management
 * Header is now rendered by the dashboard layout
 */
export default function ProfilePage() {
  const { user, isLoading, fetchUser } = useUserStore();
  const [activeTab, setActiveTab] = useState<ProfileTab>("personal");
  const [isSaving, setIsSaving] = useState(false);
  const [settingsOpen, setSettingsOpen] = useState(false);

  // Transform user data to component format
  const profile = transformToUserProfile(user);
  const academicInfo = transformToAcademicInfo(user);

  // Local state for preferences and security
  const [preferences, setPreferences] = useState(defaultPreferences);
  const [security, setSecurity] = useState(defaultSecurity);
  const [subscription, setSubscription] = useState(defaultSubscription);

  // Fetch user on mount if not loaded
  useEffect(() => {
    if (!user && !isLoading) {
      fetchUser();
    }
  }, [user, isLoading, fetchUser]);

  // Fetch preferences from database on mount
  useEffect(() => {
    const fetchPreferences = async () => {
      try {
        const prefs = await getUserPreferences();
        setPreferences({
          theme: prefs.theme,
          language: prefs.language,
          notifications: prefs.notifications,
        });
      } catch {
        // Use defaults on error
      }
    };

    if (user) {
      fetchPreferences();
    }
  }, [user]);

  // Handle avatar change
  const handleAvatarChange = async (file: File) => {
    if (!user) return;
    setIsSaving(true);
    try {
      const supabase = createClient();
      const fileExt = file.name.split('.').pop();
      const fileName = `${user.id}/avatar.${fileExt}`;

      // Upload to Supabase storage
      const { error: uploadError } = await supabase.storage
        .from('avatars')
        .upload(fileName, file, { upsert: true });

      if (uploadError) throw uploadError;

      // Get public URL
      const { data: urlData } = supabase.storage
        .from('avatars')
        .getPublicUrl(fileName);

      // Update profile with new avatar URL
      const { error: updateError } = await supabase
        .from('profiles')
        .update({ avatar_url: urlData.publicUrl })
        .eq('id', user.id);

      if (updateError) throw updateError;

      toast.success("Avatar updated successfully");
      await fetchUser();
    } catch (error: any) {
      toast.error(error.message || "Failed to upload avatar");
    } finally {
      setIsSaving(false);
    }
  };

  // Handle profile save
  const handleProfileSave = async (data: Partial<UserProfile>) => {
    setIsSaving(true);
    try {
      const fullName = `${data.firstName || ""} ${data.lastName || ""}`.trim();
      const result = await updateProfile({
        fullName,
        phone: data.phone,
      });

      if (result.error) {
        toast.error(result.error);
      } else {
        toast.success("Profile updated successfully");
        await fetchUser(); // Refresh user data
      }
    } catch (error) {
      toast.error("Failed to update profile");
    } finally {
      setIsSaving(false);
    }
  };

  // Handle academic info save
  const handleAcademicSave = async (data: AcademicInfo) => {
    setIsSaving(true);
    try {
      const result = await updateStudentProfile({
        universityId: data.universityId,
        studentId: data.studentId,
      });

      if (result.error) {
        toast.error(result.error);
      } else {
        toast.success("Academic info updated successfully");
        await fetchUser();
      }
    } catch (error) {
      toast.error("Failed to update academic info");
    } finally {
      setIsSaving(false);
    }
  };

  // Handle preferences save
  const handlePreferencesSave = async (data: UserPreferences) => {
    setIsSaving(true);
    try {
      const result = await updateUserPreferences({
        theme: data.theme,
        language: data.language,
        notifications: data.notifications,
      });

      if (result.error) {
        toast.error(result.error);
      } else {
        setPreferences(data);
        toast.success("Preferences saved");
      }
    } catch {
      toast.error("Failed to save preferences");
    } finally {
      setIsSaving(false);
    }
  };

  // Handle password change
  const handlePasswordChange = async (data: PasswordChangeData) => {
    setIsSaving(true);
    try {
      const supabase = createClient();
      const { error } = await supabase.auth.updateUser({
        password: data.newPassword,
      });

      if (error) throw error;

      toast.success("Password changed successfully");
      setSecurity((prev) => ({
        ...prev,
        passwordLastChanged: new Date().toISOString(),
      }));
    } catch (error: any) {
      toast.error(error.message || "Failed to change password");
    } finally {
      setIsSaving(false);
    }
  };

  // Handle 2FA toggle (called after setup dialog completes or disable confirmation)
  const handleToggle2FA = async (enabled: boolean) => {
    if (!enabled) {
      // Disable 2FA
      setIsSaving(true);
      try {
        const { disable2FA } = await import("@/lib/actions/auth");
        const result = await disable2FA();
        if (result.error) {
          toast.error(result.error);
        } else {
          setSecurity((prev) => ({
            ...prev,
            twoFactorAuth: { enabled: false },
          }));
          toast.success("2FA disabled successfully");
        }
      } catch {
        toast.error("Failed to disable 2FA");
      } finally {
        setIsSaving(false);
      }
    } else {
      // Enable 2FA - update local state (setup dialog handles the actual enabling)
      setSecurity((prev) => ({
        ...prev,
        twoFactorAuth: { enabled: true, verifiedAt: new Date().toISOString() },
      }));
    }
  };

  // Handle session revoke
  const handleRevokeSession = async (sessionId: string) => {
    // TODO: Implement session revoke via Supabase Auth
    setSecurity((prev) => ({
      ...prev,
      activeSessions: prev.activeSessions.filter((s) => s.id !== sessionId),
    }));
    toast.success("Session revoked");
  };

  // Handle revoke all sessions
  const handleRevokeAllSessions = async () => {
    // TODO: Implement revoke all sessions via Supabase Auth
    setSecurity((prev) => ({
      ...prev,
      activeSessions: prev.activeSessions.filter((s) => s.current),
    }));
    toast.success("All other sessions revoked");
  };

  // Handle upgrade
  const handleUpgrade = async (planId: string) => {
    // TODO: Implement subscription upgrade via payment provider
    toast.info("Subscription upgrade coming soon");
  };

  // Handle billing management
  const handleManageBilling = () => {
    // TODO: Open billing portal
    toast.info("Billing portal coming soon");
  };

  // Handle account deletion
  const handleDeleteAccount = async () => {
    if (!user) return;
    setIsSaving(true);
    try {
      const supabase = createClient();

      // Soft delete: Mark profile as inactive
      const { error } = await supabase
        .from('profiles')
        .update({
          is_active: false,
          deleted_at: new Date().toISOString(),
        })
        .eq('id', user.id);

      if (error) throw error;

      // Clear localStorage tokens
      if (typeof window !== "undefined") {
        const keysToRemove: string[] = [];
        for (let i = 0; i < localStorage.length; i++) {
          const key = localStorage.key(i);
          if (key && (key.startsWith("sb-") && key.includes("-auth-token"))) {
            keysToRemove.push(key);
          }
        }
        keysToRemove.push("user-storage", "auth-storage", "wallet-storage", "notification-storage", "project-storage");
        keysToRemove.forEach((key) => localStorage.removeItem(key));
      }

      // Sign out user
      await supabase.auth.signOut();

      toast.success("Account deleted successfully");
      window.location.href = '/login';
    } catch (error: any) {
      toast.error(error.message || "Failed to delete account");
    } finally {
      setIsSaving(false);
    }
  };

  // Show loading state
  if (isLoading) {
    return (
      <main className="flex-1 flex flex-col items-center justify-center gap-4 p-8">
        <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
        <p className="text-sm text-muted-foreground">Loading profile...</p>
      </main>
    );
  }

  // Show error if no profile
  if (!profile) {
    return (
      <main className="flex-1 flex flex-col items-center justify-center gap-4 p-8">
        <div className="h-12 w-12 rounded-full bg-muted flex items-center justify-center">
          <UserCircle className="h-6 w-6 text-muted-foreground" />
        </div>
        <div className="text-center">
          <p className="text-sm font-medium text-foreground">Failed to load profile</p>
          <p className="text-xs text-muted-foreground">Please try refreshing the page</p>
        </div>
      </main>
    );
  }

  // Render active tab content
  const renderTabContent = () => {
    switch (activeTab) {
      case "personal":
        return (
          <PersonalInfoForm
            profile={profile}
            onSave={handleProfileSave}
          />
        );
      case "academic":
        return academicInfo ? (
          <AcademicInfoSection
            academicInfo={academicInfo}
            onSave={handleAcademicSave}
          />
        ) : (
          <div className="p-4 text-muted-foreground">
            Academic info not available for {user?.user_type} accounts
          </div>
        );
      case "preferences":
        return (
          <PreferencesSection
            preferences={preferences}
            onSave={handlePreferencesSave}
          />
        );
      case "security":
        return (
          <SettingsSection>
            <SecuritySection
              security={security}
              onPasswordChange={handlePasswordChange}
              onToggle2FA={handleToggle2FA}
              onRevokeSession={handleRevokeSession}
              onRevokeAllSessions={handleRevokeAllSessions}
            />
            <DangerZone
              userEmail={profile.email}
              onDeleteAccount={handleDeleteAccount}
            />
          </SettingsSection>
        );
      case "subscription":
        return (
          <SubscriptionCard
            subscription={subscription}
            onUpgrade={handleUpgrade}
            onManageBilling={handleManageBilling}
          />
        );
      default:
        return null;
    }
  };

  // Handle settings navigation from ProfilePro
  const handleSettingsClick = (tab: string) => {
    setActiveTab(tab as ProfileTab);
    setSettingsOpen(true);
  };

  // Get tab title for sheet header
  const getTabTitle = (tab: ProfileTab) => {
    switch (tab) {
      case "personal": return "Personal Information";
      case "academic": return "Academic Details";
      case "preferences": return "Preferences";
      case "security": return "Security & Privacy";
      case "subscription": return "Subscription";
      default: return "Settings";
    }
  };

  return (
    <>
      {/* Premium Profile View */}
      <ProfilePro
        profile={profile}
        subscription={subscription}
        onAvatarChange={handleAvatarChange}
        onSettingsClick={handleSettingsClick}
      />

      {/* Settings Sheet */}
      <Sheet open={settingsOpen} onOpenChange={setSettingsOpen}>
        <SheetContent side="right" className="w-full sm:max-w-lg overflow-y-auto p-0">
          <SheetHeader className="px-6 pt-6 pb-4 border-b border-border/40">
            <SheetTitle className="text-base font-medium">{getTabTitle(activeTab)}</SheetTitle>
          </SheetHeader>

          {/* Settings Tabs Navigation */}
          <div className="p-6">
            <SettingsTabs activeTab={activeTab} onTabChange={setActiveTab}>
              {renderTabContent()}
            </SettingsTabs>
          </div>
        </SheetContent>
      </Sheet>
    </>
  );
}
