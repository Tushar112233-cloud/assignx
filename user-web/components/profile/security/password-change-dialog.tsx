"use client";

import { Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { cn } from "@/lib/utils";
import type { PasswordChangeData, FormErrors } from "@/types/profile";

/**
 * Props for PasswordChangeDialog component
 * @property open - Dialog open state
 * @property onOpenChange - Callback when dialog state changes
 * @property form - Password form data
 * @property errors - Form validation errors
 * @property isLoading - Loading state for submit
 * @property onFormChange - Callback when form field changes
 * @property onSubmit - Callback when form is submitted
 */
interface PasswordChangeDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  form: PasswordChangeData;
  errors: FormErrors;
  isLoading: boolean;
  onFormChange: (field: keyof PasswordChangeData, value: string) => void;
  onSubmit: () => void;
}

/**
 * Password change dialog component
 * Form for updating user password
 */
export function PasswordChangeDialog({
  open,
  onOpenChange,
  form,
  errors,
  isLoading,
  onFormChange,
  onSubmit,
}: PasswordChangeDialogProps) {
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Change Password</DialogTitle>
          <DialogDescription>
            Enter your current password and choose a new one
          </DialogDescription>
        </DialogHeader>
        <div className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="current-password">Current Password</Label>
            <Input
              id="current-password"
              type="password"
              value={form.currentPassword}
              onChange={(e) => onFormChange("currentPassword", e.target.value)}
              className={cn(errors.currentPassword && "border-destructive")}
            />
            {errors.currentPassword && (
              <p className="text-sm text-destructive">{errors.currentPassword}</p>
            )}
          </div>
          <div className="space-y-2">
            <Label htmlFor="new-password">New Password</Label>
            <Input
              id="new-password"
              type="password"
              value={form.newPassword}
              onChange={(e) => onFormChange("newPassword", e.target.value)}
              className={cn(errors.newPassword && "border-destructive")}
            />
            {errors.newPassword && (
              <p className="text-sm text-destructive">{errors.newPassword}</p>
            )}
          </div>
          <div className="space-y-2">
            <Label htmlFor="confirm-password">Confirm New Password</Label>
            <Input
              id="confirm-password"
              type="password"
              value={form.confirmPassword}
              onChange={(e) => onFormChange("confirmPassword", e.target.value)}
              className={cn(errors.confirmPassword && "border-destructive")}
            />
            {errors.confirmPassword && (
              <p className="text-sm text-destructive">{errors.confirmPassword}</p>
            )}
          </div>
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)}>
            Cancel
          </Button>
          <Button onClick={onSubmit} disabled={isLoading}>
            {isLoading ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Changing...
              </>
            ) : (
              "Change Password"
            )}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
