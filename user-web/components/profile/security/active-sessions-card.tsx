"use client";

import { LogOut } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import { SessionItem } from "./session-item";
import type { ActiveSession } from "@/types/profile";

/**
 * Props for ActiveSessionsCard component
 * @property sessions - List of active sessions
 * @property revokingSessionId - ID of session being revoked
 * @property onRevokeSession - Callback to revoke single session
 * @property onRevokeAllClick - Callback when revoke all is clicked
 */
interface ActiveSessionsCardProps {
  sessions: ActiveSession[];
  revokingSessionId: string | null;
  onRevokeSession: (sessionId: string) => void;
  onRevokeAllClick: () => void;
}

/**
 * Active sessions card component
 * Displays list of logged-in devices with revoke options
 */
export function ActiveSessionsCard({
  sessions,
  revokingSessionId,
  onRevokeSession,
  onRevokeAllClick,
}: ActiveSessionsCardProps) {
  const hasOtherSessions = sessions.filter((s) => !s.current).length > 0;

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center justify-between">
          <div>
            <CardTitle>Active Sessions</CardTitle>
            <CardDescription>
              Devices currently logged into your account
            </CardDescription>
          </div>
          {hasOtherSessions && (
            <Button variant="outline" size="sm" onClick={onRevokeAllClick}>
              <LogOut className="mr-2 h-4 w-4" />
              Revoke All
            </Button>
          )}
        </div>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {sessions.map((session, index) => (
            <div key={session.id}>
              {index > 0 && <Separator className="my-4" />}
              <SessionItem
                session={session}
                onRevoke={() => onRevokeSession(session.id)}
                isRevoking={revokingSessionId === session.id}
              />
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  );
}
