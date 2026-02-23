"use client";

import { useState, useEffect, useCallback } from "react";
import { useRouter } from "next/navigation";
import { toast } from "sonner";
import {
  PasswordCard,
  TwoFactorCard,
  ActiveSessionsCard,
  PasswordChangeDialog,
  RevokeAllDialog,
} from "./security";
import {
  getActiveSessions,
  revokeSession,
  revokeAllOtherSessions,
  type SessionInfo,
} from "@/lib/actions/auth";
import type {
  SecuritySettings,
  PasswordChangeData,
  FormErrors,
  ActiveSession,
} from "@/types/profile";

/**
 * Props for SecuritySection component
 * @property security - Current security settings
 * @property onPasswordChange - Callback for password change
 * @property onToggle2FA - Callback for 2FA toggle
 * @property onRevokeSession - Callback to revoke single session
 * @property onRevokeAllSessions - Callback to revoke all sessions
 */
interface SecuritySectionProps {
  security: SecuritySettings;
  onPasswordChange: (data: PasswordChangeData) => Promise<void>;
  onToggle2FA: (enabled: boolean) => Promise<void>;
  onRevokeSession: (sessionId: string) => Promise<void>;
  onRevokeAllSessions: () => Promise<void>;
}

/**
 * Convert SessionInfo from server action to ActiveSession for UI
 */
function toActiveSession(session: SessionInfo): ActiveSession {
  return {
    id: session.id,
    device: session.device,
    browser: session.browser,
    location: session.location,
    ipAddress: session.ipAddress,
    lastActive: session.lastActive,
    current: session.current,
  };
}

/**
 * Security settings section component
 * Manages password, 2FA, and active sessions
 * Fetches real session data from Supabase Auth API
 */
export function SecuritySection({
  security,
  onPasswordChange,
  onToggle2FA,
}: SecuritySectionProps) {
  const router = useRouter();
  const [passwordDialogOpen, setPasswordDialogOpen] = useState(false);
  const [revokeAllDialogOpen, setRevokeAllDialogOpen] = useState(false);
  const [passwordForm, setPasswordForm] = useState<PasswordChangeData>({
    currentPassword: "",
    newPassword: "",
    confirmPassword: "",
  });
  const [passwordErrors, setPasswordErrors] = useState<FormErrors>({});
  const [isChangingPassword, setIsChangingPassword] = useState(false);
  const [isToggling2FA, setIsToggling2FA] = useState(false);
  const [revokingSessionId, setRevokingSessionId] = useState<string | null>(null);
  const [isRevokingAll, setIsRevokingAll] = useState(false);

  // Session state - fetched from Supabase Auth API
  const [sessions, setSessions] = useState<ActiveSession[]>(security.activeSessions);
  const [isLoadingSessions, setIsLoadingSessions] = useState(true);

  /** Fetch active sessions from Supabase Auth API */
  const fetchSessions = useCallback(async () => {
    setIsLoadingSessions(true);
    try {
      const result = await getActiveSessions();
      if (result.error) {
        // Use default session on error
        setSessions(security.activeSessions);
      } else {
        setSessions(result.sessions.map(toActiveSession));
      }
    } catch {
      // Use default session on error
      setSessions(security.activeSessions);
    } finally {
      setIsLoadingSessions(false);
    }
  }, [security.activeSessions]);

  // Fetch sessions on mount
  useEffect(() => {
    fetchSessions();
  }, [fetchSessions]);

  /** Validates password form fields */
  const validatePassword = (): boolean => {
    const errors: FormErrors = {};
    if (!passwordForm.currentPassword) {
      errors.currentPassword = "Current password is required";
    }
    if (!passwordForm.newPassword) {
      errors.newPassword = "New password is required";
    } else if (passwordForm.newPassword.length < 8) {
      errors.newPassword = "Password must be at least 8 characters";
    }
    if (passwordForm.newPassword !== passwordForm.confirmPassword) {
      errors.confirmPassword = "Passwords do not match";
    }
    setPasswordErrors(errors);
    return Object.keys(errors).length === 0;
  };

  /** Handles password change submission */
  const handlePasswordChange = async () => {
    if (!validatePassword()) return;
    setIsChangingPassword(true);
    try {
      await onPasswordChange(passwordForm);
      toast.success("Password changed successfully");
      setPasswordDialogOpen(false);
      setPasswordForm({ currentPassword: "", newPassword: "", confirmPassword: "" });
    } catch {
      toast.error("Failed to change password");
    } finally {
      setIsChangingPassword(false);
    }
  };

  /** Handles 2FA toggle */
  const handleToggle2FA = async (enabled: boolean) => {
    setIsToggling2FA(true);
    try {
      await onToggle2FA(enabled);
      toast.success(enabled ? "2FA enabled" : "2FA disabled");
    } catch {
      toast.error("Failed to update 2FA settings");
    } finally {
      setIsToggling2FA(false);
    }
  };

  /** Handles single session revocation via Supabase Auth API */
  const handleRevokeSession = async (sessionId: string) => {
    // Find the session to check if it's current
    const session = sessions.find((s) => s.id === sessionId);
    if (!session) {
      toast.error("Session not found");
      return;
    }

    setRevokingSessionId(sessionId);
    try {
      const result = await revokeSession(sessionId, session.current);

      if (result.error) {
        toast.error(result.error);
        return;
      }

      if (result.shouldRedirect) {
        // Current session was revoked, redirect to login
        toast.success("Session revoked. Redirecting to login...");
        // Clear local storage before redirect
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
        router.push("/login");
        return;
      }

      // Update local state for non-current sessions
      setSessions((prev) => prev.filter((s) => s.id !== sessionId));
      toast.success("Session revoked");
    } catch {
      toast.error("Failed to revoke session");
    } finally {
      setRevokingSessionId(null);
    }
  };

  /** Handles all sessions revocation via Supabase Auth API */
  const handleRevokeAllSessions = async () => {
    setIsRevokingAll(true);
    try {
      const result = await revokeAllOtherSessions();

      if (result.error) {
        toast.error(result.error);
        return;
      }

      // Global signout was performed - redirect to login
      toast.success("All sessions revoked. Redirecting to login...");
      setRevokeAllDialogOpen(false);

      // Clear local storage before redirect
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

      router.push("/login");
    } catch {
      toast.error("Failed to revoke sessions");
    } finally {
      setIsRevokingAll(false);
    }
  };

  /** Updates password form field */
  const handleFormChange = (field: keyof PasswordChangeData, value: string) => {
    setPasswordForm((prev) => ({ ...prev, [field]: value }));
  };

  return (
    <div className="space-y-6">
      <PasswordCard
        passwordLastChanged={security.passwordLastChanged}
        onChangeClick={() => setPasswordDialogOpen(true)}
      />
      <TwoFactorCard
        twoFactorAuth={security.twoFactorAuth}
        isToggling={isToggling2FA}
        onToggle={handleToggle2FA}
      />
      <ActiveSessionsCard
        sessions={sessions}
        revokingSessionId={revokingSessionId}
        onRevokeSession={handleRevokeSession}
        onRevokeAllClick={() => setRevokeAllDialogOpen(true)}
      />
      <PasswordChangeDialog
        open={passwordDialogOpen}
        onOpenChange={setPasswordDialogOpen}
        form={passwordForm}
        errors={passwordErrors}
        isLoading={isChangingPassword}
        onFormChange={handleFormChange}
        onSubmit={handlePasswordChange}
      />
      <RevokeAllDialog
        open={revokeAllDialogOpen}
        onOpenChange={setRevokeAllDialogOpen}
        isLoading={isRevokingAll}
        onConfirm={handleRevokeAllSessions}
      />
    </div>
  );
}
