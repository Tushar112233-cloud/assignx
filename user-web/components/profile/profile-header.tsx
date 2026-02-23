"use client";

import { useState } from "react";
import { Camera, Mail, Calendar, CheckCircle2 } from "lucide-react";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { AvatarUploadDialog } from "./avatar-upload-dialog";
import { AccountBadge, type AccountType } from "./account-badge";
import type { UserProfile, UserSubscription } from "@/types/profile";

interface ProfileHeaderProps {
  profile: UserProfile & { accountType?: AccountType };
  subscription: UserSubscription;
  onAvatarChange: (file: File) => void;
}

/**
 * Profile header component with avatar and basic info
 */
export function ProfileHeader({
  profile,
  subscription,
  onAvatarChange,
}: ProfileHeaderProps) {
  const [uploadDialogOpen, setUploadDialogOpen] = useState(false);

  const getInitials = (firstName: string, lastName: string) => {
    return `${firstName[0]}${lastName[0]}`.toUpperCase();
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString("en-US", {
      month: "long",
      year: "numeric",
    });
  };

  const getTierBadgeVariant = (tier: UserSubscription["tier"]) => {
    switch (tier) {
      case "premium":
        return "default";
      case "pro":
        return "secondary";
      default:
        return "outline";
    }
  };

  const handleAvatarUpload = (file: File) => {
    onAvatarChange(file);
    setUploadDialogOpen(false);
  };

  return (
    <>
      <div className="flex flex-col sm:flex-row items-center sm:items-start gap-6 p-6 rounded-xl border bg-card">
        {/* Avatar with upload button */}
        <div className="relative">
          <Avatar className="h-24 w-24 border-4 border-background shadow-lg">
            <AvatarImage src={profile.avatar} alt={profile.firstName} />
            <AvatarFallback className="text-2xl">
              {getInitials(profile.firstName, profile.lastName)}
            </AvatarFallback>
          </Avatar>
          <Button
            size="icon"
            variant="secondary"
            className="absolute -bottom-1 -right-1 h-8 w-8 rounded-full shadow-md"
            onClick={() => setUploadDialogOpen(true)}
          >
            <Camera className="h-4 w-4" />
            <span className="sr-only">Change avatar</span>
          </Button>
        </div>

        {/* User info */}
        <div className="flex-1 text-center sm:text-left">
          <div className="flex flex-col sm:flex-row items-center sm:items-start gap-2 mb-2">
            <h1 className="text-2xl font-bold">
              {profile.firstName} {profile.lastName}
            </h1>
            <div className="flex items-center gap-2">
              {profile.accountType && (
                <AccountBadge
                  accountType={profile.accountType}
                  isVerified={profile.emailVerified}
                  size="md"
                />
              )}
              <Badge variant={getTierBadgeVariant(subscription.tier)} className="capitalize">
                {subscription.tier}
              </Badge>
            </div>
          </div>

          <div className="flex flex-col sm:flex-row items-center gap-3 text-sm text-muted-foreground">
            <div className="flex items-center gap-1.5">
              <Mail className="h-4 w-4" />
              <span>{profile.email}</span>
              {profile.emailVerified && (
                <CheckCircle2 className="h-4 w-4 text-green-500" />
              )}
            </div>
            <span className="hidden sm:inline">•</span>
            <div className="flex items-center gap-1.5">
              <Calendar className="h-4 w-4" />
              <span>Member since {formatDate(profile.createdAt)}</span>
            </div>
          </div>
        </div>
      </div>

      <AvatarUploadDialog
        open={uploadDialogOpen}
        onOpenChange={setUploadDialogOpen}
        onUpload={handleAvatarUpload}
        currentAvatar={profile.avatar}
      />
    </>
  );
}
