"use client";

import { cn } from "@/lib/utils";
import { SkeletonCircle, SkeletonText, SkeletonBox, SkeletonButton } from "../primitives";

interface ProfileSkeletonProps {
  className?: string;
}

/**
 * Full page skeleton for Profile (/profile)
 * Matches the exact layout of profile-pro.tsx:
 * - Profile header card (avatar, name, tier, email, join date, edit button)
 * - Stats grid (2-col mobile, 4-col desktop)
 * - Wallet CTA (emerald accent)
 * - Referral section (code input, buttons, stats)
 * - Quick settings (5 action rows)
 * - Footer
 */
export function ProfileSkeleton({ className }: ProfileSkeletonProps) {
  return (
    <main className={cn("flex-1 p-6 md:p-8 max-w-2xl mx-auto space-y-6", className)}>
      {/* Profile Header Card */}
      <section className="p-5 rounded-xl border border-border bg-card">
        <div className="flex flex-col sm:flex-row items-center sm:items-start gap-5">
          {/* Avatar with camera button */}
          <div className="relative">
            <SkeletonCircle size={80} delay={0} />
            <div className="absolute -bottom-1 -right-1">
              <SkeletonCircle size={28} delay={50} />
            </div>
          </div>

          {/* Info section */}
          <div className="flex-1 text-center sm:text-left space-y-3">
            {/* Name + Tier badge row */}
            <div className="flex flex-col sm:flex-row items-center sm:items-start gap-2">
              <SkeletonText width={180} lineHeight={24} delay={100} />
              <SkeletonBox width={70} height={22} rounded="md" delay={150} />
            </div>

            {/* Email and join date row */}
            <div className="flex flex-col sm:flex-row items-center gap-2">
              <div className="flex items-center gap-1.5">
                <SkeletonCircle size={14} delay={200} />
                <SkeletonText width={160} lineHeight={14} delay={220} />
                <SkeletonCircle size={14} delay={240} />
              </div>
              <SkeletonText width={8} lineHeight={14} className="hidden sm:block" delay={260} />
              <div className="flex items-center gap-1.5">
                <SkeletonCircle size={14} delay={280} />
                <SkeletonText width={100} lineHeight={14} delay={300} />
              </div>
            </div>

            {/* Edit Profile button */}
            <SkeletonButton size="sm" width={110} delay={350} />
          </div>
        </div>
      </section>

      {/* Stats Grid - 2-col mobile, 4-col desktop */}
      <section className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        {[
          { color: "emerald", label: "Balance" },
          { color: "blue", label: "Projects" },
          { color: "purple", label: "Referrals" },
          { color: "amber", label: "Earned" },
        ].map((stat, i) => (
          <div key={i} className="p-4 rounded-xl border border-border bg-card">
            <div className="flex items-center justify-between mb-2">
              <SkeletonBox width={32} height={32} rounded="lg" delay={400 + i * 50} />
              <SkeletonCircle size={16} delay={420 + i * 50} />
            </div>
            <SkeletonText width={80} lineHeight={24} delay={440 + i * 50} />
            <SkeletonText width={50} lineHeight={12} className="mt-1" delay={460 + i * 50} />
          </div>
        ))}
      </section>

      {/* Wallet CTA - Emerald accent */}
      <section className="p-4 rounded-xl bg-emerald-50 dark:bg-emerald-900/20 border border-emerald-200 dark:border-emerald-800">
        <div className="flex items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <SkeletonBox
              width={40}
              height={40}
              rounded="lg"
              className="bg-emerald-100 dark:bg-emerald-900/50"
              delay={600}
            />
            <div className="space-y-1">
              <SkeletonText width={140} lineHeight={14} delay={620} />
              <SkeletonText width={110} lineHeight={12} delay={640} />
            </div>
          </div>
          <SkeletonButton size="sm" width={70} delay={660} />
        </div>
      </section>

      {/* Referral Section */}
      <section className="p-4 rounded-xl border border-border bg-card space-y-4">
        {/* Header with icon */}
        <div className="flex items-center gap-3">
          <SkeletonBox
            width={40}
            height={40}
            rounded="lg"
            className="bg-amber-100 dark:bg-amber-900/30"
            delay={700}
          />
          <div className="space-y-1">
            <SkeletonText width={100} lineHeight={14} delay={720} />
            <SkeletonText width={120} lineHeight={12} delay={740} />
          </div>
        </div>

        {/* Code input + copy button */}
        <div className="flex gap-2">
          <SkeletonBox height={40} className="flex-1" rounded="md" delay={760} />
          <SkeletonBox width={40} height={40} rounded="md" delay={780} />
        </div>

        {/* Copy Code + Share buttons */}
        <div className="flex gap-2">
          <SkeletonButton className="flex-1" delay={800} />
          <SkeletonButton className="flex-1" delay={820} />
        </div>

        {/* Stats row */}
        <div className="grid grid-cols-2 gap-3 pt-3 border-t border-border">
          {[0, 1].map((i) => (
            <div key={i} className="flex items-center gap-3 p-3 rounded-lg bg-muted/50">
              <SkeletonCircle size={20} delay={840 + i * 40} />
              <div className="space-y-1">
                <SkeletonText width={30} lineHeight={14} delay={860 + i * 40} />
                <SkeletonText width={50} lineHeight={10} delay={880 + i * 40} />
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Quick Settings */}
      <section className="space-y-3">
        <SkeletonText width={60} lineHeight={14} delay={920} />
        <div className="space-y-2">
          {[
            "Personal Information",
            "Academic Details",
            "Notifications",
            "Security & Privacy",
            "Subscription",
          ].map((_, i) => (
            <div
              key={i}
              className="flex items-center gap-3 w-full p-3 rounded-xl border border-border bg-card"
            >
              <SkeletonBox width={40} height={40} rounded="lg" delay={950 + i * 40} />
              <div className="flex-1 min-w-0 space-y-1">
                <div className="flex items-center gap-2">
                  <SkeletonText width={140} lineHeight={14} delay={970 + i * 40} />
                  {(i === 3 || i === 4) && (
                    <SkeletonBox width={40} height={18} rounded="md" delay={990 + i * 40} />
                  )}
                </div>
                <SkeletonText width={180} lineHeight={12} delay={1010 + i * 40} />
              </div>
              <SkeletonCircle size={16} delay={1030 + i * 40} />
            </div>
          ))}
        </div>
      </section>

      {/* Footer */}
      <footer className="pt-4 text-center space-y-2">
        <SkeletonText width={100} lineHeight={12} className="mx-auto" delay={1200} />
        <div className="flex items-center justify-center gap-3">
          <SkeletonText width={40} lineHeight={12} delay={1220} />
          <SkeletonText width={8} lineHeight={12} delay={1240} />
          <SkeletonText width={50} lineHeight={12} delay={1260} />
          <SkeletonText width={8} lineHeight={12} delay={1280} />
          <SkeletonText width={30} lineHeight={12} delay={1300} />
        </div>
      </footer>
    </main>
  );
}
