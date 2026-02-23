"use client";

import { useState, useEffect, useMemo } from "react";
import Link from "next/link";
import {
  UserCircle,
  Wallet,
  FolderCheck,
  Gift,
  Users,
  ArrowUpRight,
  Plus,
  Copy,
  Share2,
  Check,
  Mail,
  Calendar,
  CheckCircle2,
  Camera,
  Shield,
  CreditCard,
  GraduationCap,
  Bell,
  ChevronRight,
  Star,
  Edit3,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { StaggerItem } from "@/components/skeletons";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Skeleton } from "@/components/ui/skeleton";
import { AvatarUploadDialog } from "@/components/profile/avatar-upload-dialog";
import { toast } from "sonner";
import { getWallet, getProjects } from "@/lib/actions/data";
import type { UserProfile, UserSubscription } from "@/types/profile";

/**
 * Get time-based gradient class for dynamic theming
 */
function getTimeBasedGradientClass(): string {
  const hour = new Date().getHours();
  if (hour >= 5 && hour < 12) return "mesh-gradient-morning";
  if (hour >= 12 && hour < 18) return "mesh-gradient-afternoon";
  return "mesh-gradient-evening";
}

interface ProfileProProps {
  profile: UserProfile;
  subscription: UserSubscription;
  onAvatarChange: (file: File) => void;
  onSettingsClick: (tab: string) => void;
}

/**
 * Stat card component
 */
function StatCard({
  icon: Icon,
  label,
  value,
  href,
  iconColor = "text-muted-foreground",
}: {
  icon: React.ElementType;
  label: string;
  value: string | number;
  href?: string;
  iconColor?: string;
}) {
  const content = (
    <div className={cn(
      "action-card-glass p-4 rounded-xl",
      href && "hover:border-foreground/20 transition-colors cursor-pointer"
    )}>
      <div className="flex items-center justify-between mb-2">
        <div className="h-8 w-8 rounded-lg bg-muted flex items-center justify-center">
          <Icon className={cn("h-4 w-4", iconColor)} />
        </div>
        {href && <ArrowUpRight className="h-4 w-4 text-muted-foreground" />}
      </div>
      <p className="text-xl font-semibold text-foreground">{value}</p>
      <p className="text-xs text-muted-foreground">{label}</p>
    </div>
  );

  if (href) {
    return <Link href={href} className="block">{content}</Link>;
  }
  return content;
}

/**
 * Quick action button
 */
function QuickAction({
  icon: Icon,
  label,
  description,
  onClick,
  badge,
}: {
  icon: React.ElementType;
  label: string;
  description: string;
  onClick: () => void;
  badge?: string;
}) {
  return (
    <button
      onClick={onClick}
      className="action-card-glass flex items-center gap-3 w-full p-3 rounded-xl hover:border-foreground/20 transition-colors text-left"
    >
      <div className="h-10 w-10 rounded-lg bg-muted flex items-center justify-center shrink-0">
        <Icon className="h-5 w-5 text-muted-foreground" />
      </div>
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2">
          <span className="text-sm font-medium text-foreground">{label}</span>
          {badge && (
            <span className="px-1.5 py-0.5 rounded text-[10px] font-medium bg-muted text-muted-foreground">
              {badge}
            </span>
          )}
        </div>
        <p className="text-xs text-muted-foreground truncate">{description}</p>
      </div>
      <ChevronRight className="h-4 w-4 text-muted-foreground shrink-0" />
    </button>
  );
}

/**
 * ProfilePro - Minimalist profile page
 */
export function ProfilePro({
  profile,
  subscription,
  onAvatarChange,
  onSettingsClick,
}: ProfileProProps) {
  const [uploadDialogOpen, setUploadDialogOpen] = useState(false);
  const [walletBalance, setWalletBalance] = useState<number | null>(null);
  const [projectsCompleted, setProjectsCompleted] = useState<number | null>(null);
  const [isStatsLoading, setIsStatsLoading] = useState(true);
  const [isCopied, setIsCopied] = useState(false);

  // Memoize time-based gradient class
  const gradientClass = useMemo(() => getTimeBasedGradientClass(), []);

  const referral = useMemo(() => ({
    code: "EXPERT20",
    totalReferrals: 3,
    totalEarnings: 150,
  }), []);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const [wallet, projects] = await Promise.all([
          getWallet(),
          getProjects("completed"),
        ]);
        setWalletBalance(wallet?.balance || 0);
        setProjectsCompleted(projects?.length || 0);
      } finally {
        setIsStatsLoading(false);
      }
    };
    fetchStats();
  }, []);

  const getInitials = (firstName: string, lastName: string) => {
    return `${firstName?.[0] || ""}${lastName?.[0] || ""}`.toUpperCase() || "U";
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString("en-US", {
      month: "long",
      year: "numeric",
    });
  };

  const handleAvatarUpload = (file: File) => {
    onAvatarChange(file);
    setUploadDialogOpen(false);
  };

  const handleCopyCode = async () => {
    try {
      await navigator.clipboard.writeText(referral.code);
      setIsCopied(true);
      toast.success("Referral code copied!");
      setTimeout(() => setIsCopied(false), 2000);
    } catch {
      toast.error("Failed to copy code");
    }
  };

  const handleShare = async () => {
    const shareText = `Use my referral code ${referral.code} to get 20% off your first project on AssignX!`;

    if (navigator.share) {
      try {
        await navigator.share({
          title: "Join AssignX",
          text: shareText,
          url: `https://assignx.com/ref/${referral.code}`,
        });
      } catch {
        // User cancelled
      }
    } else {
      await navigator.clipboard.writeText(shareText);
      toast.success("Share text copied to clipboard!");
    }
  };

  return (
    <div className={cn("mesh-background mesh-gradient-bottom-right-animated min-h-full", gradientClass)}>
      <main className="relative z-10 flex-1 p-6 md:p-8 max-w-2xl mx-auto space-y-6 pb-24">
        {/* Profile Header */}
        <StaggerItem>
          <section className="action-card-glass p-5 rounded-xl">
        <div className="flex flex-col sm:flex-row items-center sm:items-start gap-5">
          {/* Avatar */}
          <div className="relative">
            <Avatar className="h-20 w-20">
              <AvatarImage src={profile.avatar} alt={profile.firstName} />
              <AvatarFallback className="text-xl bg-muted text-muted-foreground">
                {getInitials(profile.firstName, profile.lastName)}
              </AvatarFallback>
            </Avatar>
            <button
              onClick={() => setUploadDialogOpen(true)}
              className="absolute -bottom-1 -right-1 h-7 w-7 rounded-full bg-background border border-border flex items-center justify-center hover:bg-muted transition-colors"
            >
              <Camera className="h-3.5 w-3.5 text-muted-foreground" />
            </button>
          </div>

          {/* Info */}
          <div className="flex-1 text-center sm:text-left">
            <div className="flex flex-col sm:flex-row items-center sm:items-start gap-2 mb-2">
              <h1 className="text-xl font-semibold text-foreground">
                {profile.firstName} {profile.lastName}
              </h1>
              <span className={cn(
                "px-2 py-0.5 rounded text-xs font-medium capitalize",
                subscription.tier === "free"
                  ? "bg-muted text-muted-foreground"
                  : "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400"
              )}>
                <Star className="h-3 w-3 inline mr-1" />
                {subscription.tier}
              </span>
            </div>

            <div className="flex flex-col sm:flex-row items-center gap-2 text-sm text-muted-foreground mb-3">
              <div className="flex items-center gap-1.5">
                <Mail className="h-3.5 w-3.5" />
                <span>{profile.email}</span>
                {profile.emailVerified && (
                  <CheckCircle2 className="h-3.5 w-3.5 text-emerald-500" />
                )}
              </div>
              <span className="hidden sm:inline">·</span>
              <div className="flex items-center gap-1.5">
                <Calendar className="h-3.5 w-3.5" />
                <span>Joined {formatDate(profile.createdAt)}</span>
              </div>
            </div>

            <Button
              variant="outline"
              size="sm"
              onClick={() => onSettingsClick("personal")}
              className="h-8"
            >
              <Edit3 className="h-3.5 w-3.5 mr-1.5" />
              Edit Profile
            </Button>
          </div>
        </div>
          </section>
        </StaggerItem>

        {/* Stats Grid */}
        <StaggerItem>
          <section className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        {isStatsLoading ? (
          Array.from({ length: 4 }).map((_, i) => (
            <div key={i} className="p-4 rounded-xl border border-border bg-card">
              <Skeleton className="h-8 w-8 rounded-lg mb-2" />
              <Skeleton className="h-6 w-16 mb-1" />
              <Skeleton className="h-4 w-12" />
            </div>
          ))
        ) : (
          <>
            <StatCard
              icon={Wallet}
              label="Balance"
              value={`₹${(walletBalance || 0).toLocaleString("en-IN")}`}
              href="/wallet"
              iconColor="text-emerald-600"
            />
            <StatCard
              icon={FolderCheck}
              label="Projects"
              value={projectsCompleted || 0}
              href="/projects?tab=history"
              iconColor="text-blue-600"
            />
            <StatCard
              icon={Users}
              label="Referrals"
              value={referral.totalReferrals}
              iconColor="text-purple-600"
            />
            <StatCard
              icon={Gift}
              label="Earned"
              value={`₹${referral.totalEarnings}`}
              iconColor="text-amber-600"
            />
          </>
        )}
          </section>
        </StaggerItem>

        {/* Wallet CTA */}
        <StaggerItem>
          <section className="p-4 rounded-xl bg-emerald-50 dark:bg-emerald-900/20 border border-emerald-200 dark:border-emerald-800">
        <div className="flex items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="h-10 w-10 rounded-lg bg-emerald-100 dark:bg-emerald-900/50 flex items-center justify-center">
              <Plus className="h-5 w-5 text-emerald-600" />
            </div>
            <div>
              <p className="text-sm font-medium text-foreground">Add Money to Wallet</p>
              <p className="text-xs text-muted-foreground">Top-up for quick payments</p>
            </div>
          </div>
          <Button variant="secondary" size="sm" asChild>
            <Link href="/wallet?action=topup">
              Top Up
              <ArrowUpRight className="h-3.5 w-3.5 ml-1" />
            </Link>
          </Button>
        </div>
          </section>
        </StaggerItem>

        {/* Referral Section */}
        <StaggerItem>
          <section className="action-card-glass p-4 rounded-xl space-y-4">
        <div className="flex items-center gap-3">
          <div className="h-10 w-10 rounded-lg bg-amber-100 dark:bg-amber-900/30 flex items-center justify-center">
            <Gift className="h-5 w-5 text-amber-600" />
          </div>
          <div>
            <p className="text-sm font-medium text-foreground">Refer & Earn</p>
            <p className="text-xs text-muted-foreground">Earn ₹50 per referral</p>
          </div>
        </div>

        <div className="flex gap-2">
          <Input
            value={referral.code}
            readOnly
            className="font-mono text-center font-semibold tracking-wider"
          />
          <Button
            variant="outline"
            size="icon"
            onClick={handleCopyCode}
          >
            {isCopied ? (
              <Check className="h-4 w-4 text-emerald-600" />
            ) : (
              <Copy className="h-4 w-4" />
            )}
          </Button>
        </div>

        <div className="flex gap-2">
          <Button variant="outline" className="flex-1" onClick={handleCopyCode}>
            <Copy className="h-4 w-4 mr-2" />
            Copy Code
          </Button>
          <Button className="flex-1" onClick={handleShare}>
            <Share2 className="h-4 w-4 mr-2" />
            Share
          </Button>
        </div>

        <div className="grid grid-cols-2 gap-3 pt-3 border-t border-border">
          <div className="flex items-center gap-3 p-3 rounded-lg bg-muted/50">
            <Users className="h-5 w-5 text-amber-600" />
            <div>
              <p className="text-sm font-semibold text-foreground">{referral.totalReferrals}</p>
              <p className="text-[10px] text-muted-foreground">Referrals</p>
            </div>
          </div>
          <div className="flex items-center gap-3 p-3 rounded-lg bg-muted/50">
            <Wallet className="h-5 w-5 text-emerald-600" />
            <div>
              <p className="text-sm font-semibold text-foreground">₹{referral.totalEarnings}</p>
              <p className="text-[10px] text-muted-foreground">Earned</p>
            </div>
          </div>
        </div>
          </section>
        </StaggerItem>

        {/* Quick Settings */}
        <StaggerItem>
          <section className="space-y-3">
        <h2 className="text-sm font-medium text-foreground">Settings</h2>
        <div className="space-y-2">
          <QuickAction
            icon={UserCircle}
            label="Personal Information"
            description="Name, phone, and other details"
            onClick={() => onSettingsClick("personal")}
          />
          <QuickAction
            icon={GraduationCap}
            label="Academic Details"
            description="University and course info"
            onClick={() => onSettingsClick("academic")}
          />
          <QuickAction
            icon={Bell}
            label="Notifications"
            description="Notification preferences"
            onClick={() => onSettingsClick("preferences")}
          />
          <QuickAction
            icon={Shield}
            label="Security & Privacy"
            description="Password and 2FA"
            onClick={() => onSettingsClick("security")}
            badge="2FA"
          />
          <QuickAction
            icon={CreditCard}
            label="Subscription"
            description="Manage your plan"
            onClick={() => onSettingsClick("subscription")}
            badge={subscription.tier === "free" ? "Upgrade" : undefined}
          />
        </div>
          </section>
        </StaggerItem>

        {/* Footer */}
        <StaggerItem>
          <footer className="pt-4 text-center">
        <p className="text-xs text-muted-foreground mb-1">AssignX v1.0.0</p>
        <div className="flex items-center justify-center gap-3 text-xs text-muted-foreground">
          <Link href="/terms" className="hover:text-foreground transition-colors">Terms</Link>
          <span>·</span>
          <Link href="/privacy" className="hover:text-foreground transition-colors">Privacy</Link>
          <span>·</span>
          <Link href="/help" className="hover:text-foreground transition-colors">Help</Link>
        </div>
          </footer>
        </StaggerItem>

        {/* Avatar Upload Dialog */}
        <AvatarUploadDialog
          open={uploadDialogOpen}
          onOpenChange={setUploadDialogOpen}
          onUpload={handleAvatarUpload}
          currentAvatar={profile.avatar}
        />
      </main>
    </div>
  );
}
