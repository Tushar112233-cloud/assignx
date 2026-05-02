"use client";

import { memo } from "react";
import { Loader2, Smartphone, Monitor, LogOut } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { formatDistanceToNow } from "date-fns";
import type { ActiveSession } from "@/types/profile";

/**
 * Props for SessionItem component
 * @property session - Session data to display
 * @property onRevoke - Callback when session is revoked
 * @property isRevoking - Loading state for revoke action
 */
interface SessionItemProps {
  session: ActiveSession;
  onRevoke: () => void;
  isRevoking: boolean;
}

/**
 * Returns appropriate device icon based on device name
 */
function getDeviceIcon(device: string) {
  const lowerDevice = device.toLowerCase();
  if (lowerDevice.includes("phone") || lowerDevice.includes("mobile")) {
    return <Smartphone className="h-5 w-5" />;
  }
  return <Monitor className="h-5 w-5" />;
}

/**
 * Individual session item component
 * Displays device info with revoke option
 * Memoized for list rendering performance
 */
export const SessionItem = memo(function SessionItem({
  session,
  onRevoke,
  isRevoking,
}: SessionItemProps) {
  const lastActive = formatDistanceToNow(new Date(session.lastActive), {
    addSuffix: true,
  });

  return (
    <div className="flex items-start justify-between gap-4">
      <div className="flex items-start gap-3">
        <div className="mt-0.5 text-muted-foreground">
          {getDeviceIcon(session.device)}
        </div>
        <div>
          <div className="flex items-center gap-2">
            <span className="font-medium">{session.device}</span>
            {session.current && (
              <Badge variant="secondary" className="text-xs">
                Current
              </Badge>
            )}
          </div>
          <p className="text-sm text-muted-foreground">
            {session.browser} • {session.location}
          </p>
          <p className="text-xs text-muted-foreground">
            {session.current ? "Active now" : `Last active ${lastActive}`}
          </p>
        </div>
      </div>
      {!session.current && (
        <Button
          variant="ghost"
          size="sm"
          onClick={onRevoke}
          disabled={isRevoking}
        >
          {isRevoking ? (
            <Loader2 className="h-4 w-4 animate-spin" />
          ) : (
            <LogOut className="h-4 w-4" />
          )}
        </Button>
      )}
    </div>
  );
});
