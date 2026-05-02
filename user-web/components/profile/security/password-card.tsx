"use client";

import { Key } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { formatDistanceToNow } from "date-fns";

/**
 * Props for PasswordCard component
 * @property passwordLastChanged - ISO date string of last password change
 * @property onChangeClick - Callback when change password button is clicked
 */
interface PasswordCardProps {
  passwordLastChanged: string;
  onChangeClick: () => void;
}

/**
 * Password management card component
 * Displays last password change date and change button
 */
export function PasswordCard({
  passwordLastChanged,
  onChangeClick,
}: PasswordCardProps) {
  const lastChanged = formatDistanceToNow(new Date(passwordLastChanged), {
    addSuffix: true,
  });

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Key className="h-5 w-5" />
          Password
        </CardTitle>
        <CardDescription>
          Change your password to keep your account secure
        </CardDescription>
      </CardHeader>
      <CardContent>
        <div className="flex items-center justify-between">
          <p className="text-sm">
            Last changed{" "}
            <span className="text-muted-foreground">{lastChanged}</span>
          </p>
          <Button variant="outline" onClick={onChangeClick}>
            Change Password
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}
