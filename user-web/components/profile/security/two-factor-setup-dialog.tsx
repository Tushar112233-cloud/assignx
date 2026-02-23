"use client";

import { useState } from "react";
import { Loader2, Copy, Check, Shield, Smartphone } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { toast } from "sonner";
import { generate2FASecret, verify2FACode, enable2FA } from "@/lib/actions/auth";

interface TwoFactorSetupDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onSuccess: () => void;
}

/**
 * Two-factor authentication setup dialog
 * Displays QR code and allows user to verify TOTP code
 */
export function TwoFactorSetupDialog({
  open,
  onOpenChange,
  onSuccess,
}: TwoFactorSetupDialogProps) {
  const [step, setStep] = useState<"generate" | "verify">("generate");
  const [isLoading, setIsLoading] = useState(false);
  const [secret, setSecret] = useState("");
  const [qrCodeUrl, setQrCodeUrl] = useState("");
  const [verificationCode, setVerificationCode] = useState("");
  const [copied, setCopied] = useState(false);

  const handleGenerateSecret = async () => {
    setIsLoading(true);
    try {
      const result = await generate2FASecret();
      if (result.error) {
        toast.error(result.error);
        return;
      }
      setSecret(result.secret || "");
      setQrCodeUrl(result.qrCodeUrl || "");
      setStep("verify");
    } catch {
      toast.error("Failed to generate 2FA secret");
    } finally {
      setIsLoading(false);
    }
  };

  const handleVerifyCode = async () => {
    if (verificationCode.length !== 6) {
      toast.error("Please enter a 6-digit code");
      return;
    }

    setIsLoading(true);
    try {
      const result = await verify2FACode(secret, verificationCode);
      if (!result.valid) {
        toast.error("Invalid verification code. Please try again.");
        setVerificationCode("");
        return;
      }

      // Enable 2FA in database
      const enableResult = await enable2FA(secret);
      if (enableResult.error) {
        toast.error(enableResult.error);
        return;
      }

      toast.success("Two-factor authentication enabled!");
      onSuccess();
      handleClose();
    } catch {
      toast.error("Failed to verify code");
    } finally {
      setIsLoading(false);
    }
  };

  const handleCopySecret = async () => {
    await navigator.clipboard.writeText(secret);
    setCopied(true);
    toast.success("Secret copied to clipboard");
    setTimeout(() => setCopied(false), 2000);
  };

  const handleClose = () => {
    setStep("generate");
    setSecret("");
    setQrCodeUrl("");
    setVerificationCode("");
    onOpenChange(false);
  };

  return (
    <Dialog open={open} onOpenChange={handleClose}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <Shield className="h-5 w-5" />
            Set Up Two-Factor Authentication
          </DialogTitle>
          <DialogDescription>
            {step === "generate"
              ? "Add an extra layer of security to your account"
              : "Scan the QR code with your authenticator app"}
          </DialogDescription>
        </DialogHeader>

        {step === "generate" && (
          <div className="space-y-4 pt-4">
            <div className="rounded-lg border bg-muted/50 p-4">
              <div className="flex items-start gap-3">
                <Smartphone className="h-5 w-5 mt-0.5 text-primary" />
                <div>
                  <p className="font-medium text-sm">Before you begin</p>
                  <p className="text-sm text-muted-foreground mt-1">
                    Download an authenticator app like Google Authenticator, Authy,
                    or Microsoft Authenticator on your phone.
                  </p>
                </div>
              </div>
            </div>

            <Button
              className="w-full"
              onClick={handleGenerateSecret}
              disabled={isLoading}
            >
              {isLoading ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Generating...
                </>
              ) : (
                "Continue Setup"
              )}
            </Button>
          </div>
        )}

        {step === "verify" && (
          <div className="space-y-4 pt-4">
            {/* QR Code */}
            {qrCodeUrl && (
              <div className="flex justify-center">
                <div className="rounded-lg border bg-white p-4">
                  <img
                    src={qrCodeUrl}
                    alt="2FA QR Code"
                    className="h-48 w-48"
                  />
                </div>
              </div>
            )}

            {/* Manual entry secret */}
            <div className="space-y-2">
              <Label className="text-sm text-muted-foreground">
                Can&apos;t scan? Enter this code manually:
              </Label>
              <div className="flex gap-2">
                <Input
                  value={secret}
                  readOnly
                  className="font-mono text-sm"
                />
                <Button
                  variant="outline"
                  size="icon"
                  onClick={handleCopySecret}
                >
                  {copied ? (
                    <Check className="h-4 w-4 text-green-500" />
                  ) : (
                    <Copy className="h-4 w-4" />
                  )}
                </Button>
              </div>
            </div>

            {/* Verification code input */}
            <div className="space-y-2">
              <Label htmlFor="verification-code">
                Enter the 6-digit code from your app
              </Label>
              <Input
                id="verification-code"
                placeholder="000000"
                value={verificationCode}
                onChange={(e) => {
                  const value = e.target.value.replace(/\D/g, "").slice(0, 6);
                  setVerificationCode(value);
                }}
                className="text-center text-2xl tracking-widest font-mono"
                maxLength={6}
              />
            </div>

            <Button
              className="w-full"
              onClick={handleVerifyCode}
              disabled={isLoading || verificationCode.length !== 6}
            >
              {isLoading ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Verifying...
                </>
              ) : (
                "Verify & Enable 2FA"
              )}
            </Button>
          </div>
        )}
      </DialogContent>
    </Dialog>
  );
}
