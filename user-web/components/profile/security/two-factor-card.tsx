"use client";

import { useState } from "react";
import { Shield, CheckCircle2, AlertTriangle } from "lucide-react";
import { Button } from "@/components/ui/button";
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
import { TwoFactorSetupDialog } from "./two-factor-setup-dialog";
import type { TwoFactorAuth } from "@/types/profile";

/**
 * Props for TwoFactorCard component
 * @property twoFactorAuth - Current 2FA settings
 * @property isToggling - Loading state for toggle
 * @property onToggle - Callback when 2FA is toggled
 */
interface TwoFactorCardProps {
  twoFactorAuth: TwoFactorAuth;
  isToggling: boolean;
  onToggle: (enabled: boolean) => void;
}

/**
 * Two-factor authentication card component
 * Displays 2FA status with setup dialog and disable confirmation
 */
export function TwoFactorCard({
  twoFactorAuth,
  isToggling,
  onToggle,
}: TwoFactorCardProps) {
  const [setupDialogOpen, setSetupDialogOpen] = useState(false);
  const [disableDialogOpen, setDisableDialogOpen] = useState(false);

  const handleEnableClick = () => {
    setSetupDialogOpen(true);
  };

  const handleDisableClick = () => {
    setDisableDialogOpen(true);
  };

  const handleSetupSuccess = () => {
    onToggle(true);
  };

  const handleConfirmDisable = () => {
    onToggle(false);
    setDisableDialogOpen(false);
  };

  return (
    <>
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Shield className="h-5 w-5" />
            Two-Factor Authentication
          </CardTitle>
          <CardDescription>
            Add an extra layer of security to your account
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              {twoFactorAuth.enabled ? (
                <div className="flex items-center gap-2 text-green-600">
                  <CheckCircle2 className="h-5 w-5" />
                  <span className="font-medium">Enabled</span>
                </div>
              ) : (
                <div className="flex items-center gap-2 text-amber-600">
                  <AlertTriangle className="h-5 w-5" />
                  <span className="font-medium">Not enabled</span>
                </div>
              )}
            </div>
            {twoFactorAuth.enabled ? (
              <Button
                variant="outline"
                size="sm"
                onClick={handleDisableClick}
                disabled={isToggling}
              >
                Disable
              </Button>
            ) : (
              <Button
                size="sm"
                onClick={handleEnableClick}
                disabled={isToggling}
              >
                Enable
              </Button>
            )}
          </div>
          {!twoFactorAuth.enabled && (
            <p className="mt-3 text-sm text-muted-foreground">
              We recommend enabling 2FA using an authenticator app like Google
              Authenticator or Authy for enhanced security.
            </p>
          )}
          {twoFactorAuth.enabled && twoFactorAuth.verifiedAt && (
            <p className="mt-3 text-xs text-muted-foreground">
              Enabled on {new Date(twoFactorAuth.verifiedAt).toLocaleDateString()}
            </p>
          )}
        </CardContent>
      </Card>

      {/* Setup Dialog */}
      <TwoFactorSetupDialog
        open={setupDialogOpen}
        onOpenChange={setSetupDialogOpen}
        onSuccess={handleSetupSuccess}
      />

      {/* Disable Confirmation Dialog */}
      <AlertDialog open={disableDialogOpen} onOpenChange={setDisableDialogOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Disable Two-Factor Authentication?</AlertDialogTitle>
            <AlertDialogDescription>
              This will make your account less secure. You will no longer need
              to enter a verification code when signing in.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={handleConfirmDisable}
              className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
            >
              Disable 2FA
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  );
}
