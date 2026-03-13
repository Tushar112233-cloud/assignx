"use client";

/**
 * ProfilePro - Glassmorphic Profile Page
 * Matches dashboard bento/glassmorphic design system
 * Coffee bean palette with soft sage green accent
 */

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
  Camera,
  Shield,
  CreditCard,
  GraduationCap,
  Bell,
  ChevronRight,
  Star,
  Edit3,
  Settings,
  HelpCircle,
  Trash2,
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

/** Glassmorphic card base classes - matching dashboard pattern */
const GLASS_CARD =
  "bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 rounded-[20px] shadow-sm hover:shadow-xl hover:shadow-black/5 transition-all duration-300";

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
 * Plan badge color configuration
 */
function getPlanBadgeClasses(tier: string): string {
  switch (tier) {
    case "premium":
      return "bg-gradient-to-r from-amber-400 to-orange-500 text-white shadow-lg shadow-amber-500/20";
    case "pro":
      return "bg-gradient-to-r from-violet-400 to-purple-500 text-white shadow-lg shadow-violet-500/20";
    default:
      return "bg-white/80 dark:bg-white/10 text-muted-foreground border border-white/50 dark:border-white/10";
  }
}

/**
 * Stat mini-card for the stats grid row
 */
function StatMiniCard({
  icon: Icon,
  label,
  value,
  href,
  gradientFrom,
  gradientTo,
  shadowColor,
}: {
  icon: React.ElementType;
  label: string;
  value: string | number;
  href?: string;
  gradientFrom: string;
  gradientTo: string;
  shadowColor: string;
}) {
  const content = (
    <div
      className={cn(
        GLASS_CARD,
        "p-4 group relative overflow-hidden",
        href && "hover:-translate-y-1 cursor-pointer"
      )}
    >
      {/* Subtle tint overlay */}
      <div
        className={cn(
          "absolute inset-0 bg-gradient-to-br opacity-[0.06] dark:opacity-[0.08] pointer-events-none rounded-[20px]",
          gradientFrom,
          gradientTo
        )}
      />

      <div className="relative z-10">
        <div className="flex items-center justify-between mb-3">
          <div
            className={cn(
              "h-9 w-9 rounded-xl bg-gradient-to-br flex items-center justify-center shadow-lg",
              gradientFrom,
              gradientTo
            )}
            style={{ boxShadow: `0 8px 20px -4px ${shadowColor}` }}
          >
            <Icon className="h-4 w-4 text-white" strokeWidth={1.5} />
          </div>
          {href && (
            <ArrowUpRight className="h-3.5 w-3.5 text-muted-foreground/40 opacity-0 group-hover:opacity-100 transition-all duration-300" />
          )}
        </div>
        <p className="text-lg font-semibold text-foreground tracking-tight">
          {value}
        </p>
        <p className="text-[11px] text-muted-foreground/70 mt-0.5">{label}</p>
      </div>
    </div>
  );

  if (href) {
    return (
      <Link href={href} className="block">
        {content}
      </Link>
    );
  }
  return content;
}

/**
 * Settings navigation row item
 */
function SettingsNavItem({
  icon: Icon,
  title,
  subtitle,
  onClick,
  badge,
  href,
}: {
  icon: React.ElementType;
  title: string;
  subtitle: string;
  onClick?: () => void;
  badge?: string;
  href?: string;
}) {
  const inner = (
    <button
      onClick={onClick}
      className="flex items-center gap-3.5 w-full px-4 py-3.5 text-left hover:bg-white/40 dark:hover:bg-white/5 transition-colors duration-200 first:rounded-t-[20px] last:rounded-b-[20px]"
    >
      <div className="h-9 w-9 rounded-xl bg-[#6B8F71]/10 dark:bg-[#6B8F71]/15 flex items-center justify-center shrink-0">
        <Icon className="h-4 w-4 text-[#6B8F71]" strokeWidth={1.5} />
      </div>
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2">
          <span className="text-sm font-medium text-foreground">{title}</span>
          {badge && (
            <span className="px-1.5 py-0.5 rounded-md text-[10px] font-medium bg-[#6B8F71]/10 text-[#6B8F71]">
              {badge}
            </span>
          )}
        </div>
        <p className="text-xs text-muted-foreground/70 truncate mt-0.5">
          {subtitle}
        </p>
      </div>
      <ChevronRight className="h-4 w-4 text-muted-foreground/30 shrink-0" />
    </button>
  );

  if (href) {
    return <Link href={href}>{inner}</Link>;
  }
  return inner;
}

/**
 * ProfilePro - Glassmorphic profile page matching dashboard design
 */
export function ProfilePro({
  profile,
  subscription,
  onAvatarChange,
  onSettingsClick,
}: ProfileProProps) {
  const [uploadDialogOpen, setUploadDialogOpen] = useState(false);
  const [walletBalance, setWalletBalance] = useState<number | null>(null);
  const [projectsCompleted, setProjectsCompleted] = useState<number | null>(
    null
  );
  const [isStatsLoading, setIsStatsLoading] = useState(true);
  const [isCopied, setIsCopied] = useState(false);

  const gradientClass = useMemo(() => getTimeBasedGradientClass(), []);

  const referral = useMemo(
    () => ({
      code: "EXPERT20",
      totalReferrals: 3,
      totalEarnings: 150,
    }),
    []
  );

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

  const getInitials = (fullName: string) => {
    const parts = fullName.trim().split(/\s+/);
    return (
      `${parts[0]?.[0] || ""}${parts[1]?.[0] || ""}`.toUpperCase() || "U"
    );
  };

  const formatDate = (dateString: string | undefined | null) => {
    if (!dateString) return "N/A";
    const d = new Date(dateString);
    if (isNaN(d.getTime())) return "N/A";
    return d.toLocaleDateString("en-US", {
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
        // User cancelled sharing
      }
    } else {
      await navigator.clipboard.writeText(shareText);
      toast.success("Share text copied to clipboard!");
    }
  };

  return (
    <div
      className={cn(
        "mesh-background mesh-gradient-bottom-right-animated min-h-full",
        gradientClass
      )}
    >
      <main className="relative z-10 flex-1 px-4 py-6 md:px-6 md:py-8 max-w-2xl mx-auto space-y-4 pb-24">
        {/* ====== 1. Profile Header Card ====== */}
        <StaggerItem>
          <section
            className={cn(
              GLASS_CARD,
              "p-6 relative overflow-hidden"
            )}
          >
            {/* Subtle sage green tint in the background */}
            <div className="absolute inset-0 bg-gradient-to-br from-[#6B8F71]/[0.04] via-transparent to-[#765341]/[0.03] pointer-events-none rounded-[20px]" />

            {/* Decorative blurred circles */}
            <div className="absolute -top-10 -right-10 w-36 h-36 bg-gradient-to-br from-[#6B8F71]/10 to-transparent rounded-full blur-3xl" />
            <div className="absolute -bottom-8 -left-8 w-28 h-28 bg-gradient-to-tr from-[#765341]/8 to-transparent rounded-full blur-2xl" />

            <div className="relative z-10 flex flex-col sm:flex-row items-center sm:items-start gap-5">
              {/* Avatar with camera overlay */}
              <div className="relative group">
                <div className="h-[88px] w-[88px] rounded-full bg-gradient-to-br from-[#6B8F71] to-[#5a7a60] p-[3px] shadow-lg shadow-[#6B8F71]/15">
                  <Avatar className="h-full w-full border-[3px] border-white dark:border-stone-900">
                    <AvatarImage
                      src={profile.avatar_url || undefined}
                      alt={profile.full_name}
                    />
                    <AvatarFallback className="text-xl bg-[#6B8F71]/10 text-[#6B8F71] font-semibold">
                      {getInitials(profile.full_name)}
                    </AvatarFallback>
                  </Avatar>
                </div>
                <button
                  onClick={() => setUploadDialogOpen(true)}
                  className="absolute -bottom-0.5 -right-0.5 h-8 w-8 rounded-full bg-white dark:bg-stone-800 border-2 border-white dark:border-stone-900 shadow-md flex items-center justify-center hover:bg-[#6B8F71]/10 transition-colors duration-200"
                >
                  <Camera className="h-3.5 w-3.5 text-[#6B8F71]" />
                </button>
              </div>

              {/* User info */}
              <div className="flex-1 text-center sm:text-left">
                <div className="flex flex-col sm:flex-row items-center sm:items-center gap-2.5 mb-2">
                  <h1 className="text-xl font-semibold text-foreground tracking-tight">
                    {profile.full_name}
                  </h1>
                  {/* Plan badge with glow */}
                  <span
                    className={cn(
                      "px-2.5 py-1 rounded-full text-[11px] font-semibold capitalize inline-flex items-center gap-1",
                      getPlanBadgeClasses(subscription.tier)
                    )}
                  >
                    <Star className="h-3 w-3" />
                    {subscription.tier}
                  </span>
                </div>

                <div className="flex flex-col sm:flex-row items-center gap-2 text-sm text-muted-foreground/70 mb-4">
                  <div className="flex items-center gap-1.5">
                    <Mail className="h-3.5 w-3.5" />
                    <span>{profile.email}</span>
                  </div>
                  <span className="hidden sm:inline text-muted-foreground/30">
                    |
                  </span>
                  <div className="flex items-center gap-1.5">
                    <Calendar className="h-3.5 w-3.5" />
                    <span>
                      Joined{" "}
                      {formatDate(
                        profile.createdAt || (profile as any).created_at
                      )}
                    </span>
                  </div>
                </div>

                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => onSettingsClick("personal")}
                  className="h-9 rounded-xl border-[#6B8F71]/20 hover:bg-[#6B8F71]/5 hover:border-[#6B8F71]/30 text-foreground"
                >
                  <Edit3 className="h-3.5 w-3.5 mr-1.5 text-[#6B8F71]" />
                  Edit Profile
                </Button>
              </div>
            </div>
          </section>
        </StaggerItem>

        {/* ====== 2. Stats Grid Row ====== */}
        <StaggerItem>
          <section className="grid grid-cols-2 lg:grid-cols-4 gap-3">
            {isStatsLoading ? (
              Array.from({ length: 4 }).map((_, i) => (
                <div key={i} className={cn(GLASS_CARD, "p-4")}>
                  <Skeleton className="h-9 w-9 rounded-xl mb-3" />
                  <Skeleton className="h-5 w-16 mb-1.5" />
                  <Skeleton className="h-3 w-12" />
                </div>
              ))
            ) : (
              <>
                <StatMiniCard
                  icon={Wallet}
                  label="Balance"
                  value={`₹${(walletBalance || 0).toLocaleString("en-IN")}`}
                  href="/wallet"
                  gradientFrom="from-emerald-400"
                  gradientTo="to-teal-500"
                  shadowColor="rgba(16,185,129,0.25)"
                />
                <StatMiniCard
                  icon={FolderCheck}
                  label="Projects"
                  value={projectsCompleted || 0}
                  href="/projects?tab=history"
                  gradientFrom="from-blue-400"
                  gradientTo="to-indigo-500"
                  shadowColor="rgba(99,102,241,0.25)"
                />
                <StatMiniCard
                  icon={Users}
                  label="Referrals"
                  value={referral.totalReferrals}
                  gradientFrom="from-violet-400"
                  gradientTo="to-purple-500"
                  shadowColor="rgba(139,92,246,0.25)"
                />
                <StatMiniCard
                  icon={Gift}
                  label="Earned"
                  value={`₹${referral.totalEarnings}`}
                  gradientFrom="from-amber-400"
                  gradientTo="to-orange-500"
                  shadowColor="rgba(251,146,60,0.25)"
                />
              </>
            )}
          </section>
        </StaggerItem>

        {/* ====== 3. Add Money to Wallet Banner ====== */}
        <StaggerItem>
          <section
            className={cn(
              GLASS_CARD,
              "p-4 relative overflow-hidden"
            )}
          >
            {/* Green accent tint */}
            <div className="absolute inset-0 bg-gradient-to-r from-emerald-100/30 via-transparent to-teal-50/20 dark:from-emerald-900/10 dark:to-transparent pointer-events-none rounded-[20px]" />

            <div className="relative z-10 flex items-center justify-between gap-4">
              <div className="flex items-center gap-3">
                <div className="h-10 w-10 rounded-xl bg-gradient-to-br from-emerald-400 to-teal-500 flex items-center justify-center shadow-lg shadow-emerald-500/20">
                  <Plus
                    className="h-5 w-5 text-white"
                    strokeWidth={2}
                  />
                </div>
                <div>
                  <p className="text-sm font-medium text-foreground">
                    Add Money to Wallet
                  </p>
                  <p className="text-xs text-muted-foreground/70">
                    Top-up for quick payments
                  </p>
                </div>
              </div>
              <Button
                size="sm"
                asChild
                className="rounded-xl bg-gradient-to-r from-emerald-500 to-teal-500 hover:from-emerald-600 hover:to-teal-600 text-white border-0 shadow-md shadow-emerald-500/15"
              >
                <Link href="/wallet?action=topup">
                  Top Up
                  <ArrowUpRight className="h-3.5 w-3.5 ml-1" />
                </Link>
              </Button>
            </div>
          </section>
        </StaggerItem>

        {/* ====== 4. Refer & Earn Section ====== */}
        <StaggerItem>
          <section
            className={cn(
              GLASS_CARD,
              "p-5 relative overflow-hidden"
            )}
          >
            {/* Warm amber tint */}
            <div className="absolute inset-0 bg-gradient-to-br from-amber-100/20 to-orange-50/10 dark:from-amber-900/5 dark:to-transparent pointer-events-none rounded-[20px]" />

            <div className="relative z-10 space-y-4">
              {/* Header row */}
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="h-10 w-10 rounded-xl bg-gradient-to-br from-amber-400 to-orange-500 flex items-center justify-center shadow-lg shadow-amber-500/20">
                    <Gift
                      className="h-5 w-5 text-white"
                      strokeWidth={1.5}
                    />
                  </div>
                  <div>
                    <p className="text-sm font-semibold text-foreground">
                      Refer & Earn
                    </p>
                    <p className="text-xs text-muted-foreground/70">
                      Earn ₹50 per referral
                    </p>
                  </div>
                </div>
                {/* Mini stats inline */}
                <div className="hidden sm:flex items-center gap-3">
                  <div className="text-right">
                    <p className="text-sm font-semibold text-foreground">
                      {referral.totalReferrals}
                    </p>
                    <p className="text-[10px] text-muted-foreground/60">
                      Referrals
                    </p>
                  </div>
                  <div className="w-px h-8 bg-border/50" />
                  <div className="text-right">
                    <p className="text-sm font-semibold text-foreground">
                      ₹{referral.totalEarnings}
                    </p>
                    <p className="text-[10px] text-muted-foreground/60">
                      Earned
                    </p>
                  </div>
                </div>
              </div>

              {/* Code and action buttons row */}
              <div className="flex gap-2">
                <div className="flex-1 relative">
                  <Input
                    value={referral.code}
                    readOnly
                    className="font-mono text-center font-semibold tracking-[0.2em] bg-white/50 dark:bg-white/5 border-white/40 dark:border-white/10 rounded-xl h-10"
                  />
                </div>
                <Button
                  variant="outline"
                  size="icon"
                  onClick={handleCopyCode}
                  className="h-10 w-10 rounded-xl border-white/40 dark:border-white/10 hover:bg-amber-50 dark:hover:bg-amber-900/20"
                >
                  {isCopied ? (
                    <Check className="h-4 w-4 text-emerald-600" />
                  ) : (
                    <Copy className="h-4 w-4 text-muted-foreground" />
                  )}
                </Button>
                <Button
                  onClick={handleShare}
                  size="icon"
                  className="h-10 w-10 rounded-xl bg-gradient-to-r from-amber-400 to-orange-500 hover:from-amber-500 hover:to-orange-600 text-white border-0 shadow-md shadow-amber-500/15"
                >
                  <Share2 className="h-4 w-4" />
                </Button>
              </div>

              {/* Mobile-only referral stats */}
              <div className="flex sm:hidden gap-3">
                <div className="flex-1 flex items-center gap-2.5 p-2.5 rounded-xl bg-white/40 dark:bg-white/5">
                  <Users className="h-4 w-4 text-amber-600" />
                  <div>
                    <p className="text-sm font-semibold text-foreground">
                      {referral.totalReferrals}
                    </p>
                    <p className="text-[10px] text-muted-foreground/60">
                      Referrals
                    </p>
                  </div>
                </div>
                <div className="flex-1 flex items-center gap-2.5 p-2.5 rounded-xl bg-white/40 dark:bg-white/5">
                  <Wallet className="h-4 w-4 text-emerald-600" />
                  <div>
                    <p className="text-sm font-semibold text-foreground">
                      ₹{referral.totalEarnings}
                    </p>
                    <p className="text-[10px] text-muted-foreground/60">
                      Earned
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </section>
        </StaggerItem>

        {/* ====== 5. Settings Section ====== */}
        <StaggerItem>
          <section className="space-y-3">
            <h2 className="text-xs font-semibold uppercase tracking-wider text-muted-foreground/50 px-1">
              Settings
            </h2>
            <div
              className={cn(
                GLASS_CARD,
                "overflow-hidden divide-y divide-white/30 dark:divide-white/5"
              )}
            >
              <SettingsNavItem
                icon={UserCircle}
                title="Personal Information"
                subtitle="Name, phone, and other details"
                onClick={() => onSettingsClick("personal")}
              />
              <SettingsNavItem
                icon={GraduationCap}
                title="Academic Information"
                subtitle="University and course info"
                onClick={() => onSettingsClick("academic")}
              />
              <SettingsNavItem
                icon={Bell}
                title="Preferences"
                subtitle="Notification preferences"
                onClick={() => onSettingsClick("preferences")}
              />
              <SettingsNavItem
                icon={Shield}
                title="Security"
                subtitle="Password and 2FA settings"
                onClick={() => onSettingsClick("security")}
                badge="2FA"
              />
              <SettingsNavItem
                icon={CreditCard}
                title="Payment Methods"
                subtitle="Manage cards and UPI"
                onClick={() => onSettingsClick("payment")}
              />
              <SettingsNavItem
                icon={Wallet}
                title="Subscription"
                subtitle="Manage your plan"
                onClick={() => onSettingsClick("subscription")}
                badge={
                  subscription.tier === "free" ? "Upgrade" : undefined
                }
              />
              <SettingsNavItem
                icon={Settings}
                title="App Settings"
                subtitle="General app configuration"
                href="/settings"
              />
              <SettingsNavItem
                icon={HelpCircle}
                title="Help & Support"
                subtitle="Get help and contact support"
                href="/support"
              />
            </div>
          </section>
        </StaggerItem>

        {/* ====== 6. Danger Zone ====== */}
        <StaggerItem>
          <section
            className={cn(
              "rounded-[20px] border border-red-200/50 dark:border-red-900/20 bg-red-50/30 dark:bg-red-950/10 backdrop-blur-xl p-4 transition-all duration-300"
            )}
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="h-9 w-9 rounded-xl bg-red-100/80 dark:bg-red-900/20 flex items-center justify-center">
                  <Trash2 className="h-4 w-4 text-red-500" strokeWidth={1.5} />
                </div>
                <div>
                  <p className="text-sm font-medium text-red-700 dark:text-red-400">
                    Delete Account
                  </p>
                  <p className="text-xs text-red-500/60 dark:text-red-400/40">
                    Permanently remove your data
                  </p>
                </div>
              </div>
              <Button
                variant="ghost"
                size="sm"
                className="rounded-xl text-red-500 hover:text-red-600 hover:bg-red-100/50 dark:hover:bg-red-900/20 text-xs"
              >
                Delete
              </Button>
            </div>
          </section>
        </StaggerItem>

        {/* Footer */}
        <StaggerItem>
          <footer className="pt-4 pb-2 text-center">
            <p className="text-[11px] text-muted-foreground/40 mb-1">
              AssignX v1.0.0
            </p>
            <div className="flex items-center justify-center gap-3 text-[11px] text-muted-foreground/40">
              <Link
                href="/terms"
                className="hover:text-foreground/60 transition-colors"
              >
                Terms
              </Link>
              <span>·</span>
              <Link
                href="/privacy"
                className="hover:text-foreground/60 transition-colors"
              >
                Privacy
              </Link>
              <span>·</span>
              <Link
                href="/help"
                className="hover:text-foreground/60 transition-colors"
              >
                Help
              </Link>
            </div>
          </footer>
        </StaggerItem>

        {/* Avatar Upload Dialog */}
        <AvatarUploadDialog
          open={uploadDialogOpen}
          onOpenChange={setUploadDialogOpen}
          onUpload={handleAvatarUpload}
          currentAvatar={profile.avatar_url || undefined}
        />
      </main>
    </div>
  );
}
