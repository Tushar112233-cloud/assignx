"use client";

import { useEffect, useState, useMemo, Suspense, useRef } from "react";
import { useSearchParams } from "next/navigation";
import Image from "next/image";
import {
  Plus,
  ArrowUpRight,
  ArrowDownLeft,
  Loader2,
  Wallet,
  Trophy,
  Clock,
  CreditCard,
  Send,
  ChevronRight,
  Utensils,
  Coffee,
  Gift,
  ShoppingBag,
  Car,
  Music,
  Search,
} from "lucide-react";
import { PageSkeletonProvider, StaggerItem, WalletSkeleton } from "@/components/skeletons";
import { WalletTopUpSheet } from "@/components/profile/wallet-top-up-sheet";
import { SendMoneySheet } from "@/components/profile/send-money-sheet";
import { getWallet, getWalletTransactions } from "@/lib/actions/data";
import { createClient } from "@/lib/supabase/client";
import { cn } from "@/lib/utils";
import { useUserStore } from "@/stores/user-store";
import { toast } from "sonner";

/**
 * All possible transaction types from database enum
 */
type TransactionType =
  | "credit"
  | "debit"
  | "refund"
  | "withdrawal"
  | "top_up"
  | "project_payment"
  | "project_earning"
  | "commission"
  | "bonus"
  | "penalty"
  | "reversal";

/**
 * Transaction interface
 */
interface Transaction {
  id: string;
  transaction_type: TransactionType;
  amount: number;
  description: string;
  status: "completed" | "pending" | "failed";
  created_at: string;
  reference_id?: string;
}

/**
 * Incoming transaction types (money coming into wallet)
 */
const INCOMING_TYPES: TransactionType[] = [
  "credit",
  "top_up",
  "refund",
  "project_earning",
  "bonus",
];

/**
 * Check if transaction is incoming
 */
function isIncomingTransaction(type: TransactionType): boolean {
  return INCOMING_TYPES.includes(type);
}

/**
 * Format currency
 */
function formatCurrency(amount: number): string {
  return `₹${amount.toLocaleString("en-IN")}`;
}

/**
 * Format date for display
 */
function formatDate(dateString: string): string {
  const date = new Date(dateString);
  return date.toLocaleDateString("en-IN", {
    month: "short",
    day: "numeric",
    year: "numeric",
  });
}

/**
 * Get icon for transaction description
 */
function getTransactionIcon(description: string) {
  const desc = description.toLowerCase();
  if (desc.includes("coffee") || desc.includes("cafe")) return Coffee;
  if (desc.includes("food") || desc.includes("cafeteria")) return Utensils;
  if (desc.includes("uber") || desc.includes("ride") || desc.includes("ola")) return Car;
  if (desc.includes("spotify") || desc.includes("music")) return Music;
  if (desc.includes("amazon") || desc.includes("shop")) return ShoppingBag;
  return null;
}

/**
 * Wallet content inner component - renders the actual wallet UI
 * Used inside PageSkeletonProvider for choreographed reveal with staggered animations
 */
interface WalletContentInnerProps {
  wallet: { balance: number } | null;
  stats: { monthlySpend: number; pendingAmount: number; rewardPoints: number };
  lastMonthTransactions: Transaction[];
  userName: string;
  topUpOpen: boolean;
  setTopUpOpen: (open: boolean) => void;
  sendMoneyOpen: boolean;
  setSendMoneyOpen: (open: boolean) => void;
}

function WalletContentInner({
  wallet,
  stats,
  lastMonthTransactions,
  userName,
  topUpOpen,
  setTopUpOpen,
  sendMoneyOpen,
  setSendMoneyOpen,
}: WalletContentInnerProps) {
  const offersRef = useRef<HTMLDivElement>(null);

  // Scroll offers
  const scrollOffers = (direction: "left" | "right") => {
    if (offersRef.current) {
      const scrollAmount = direction === "left" ? -200 : 200;
      offersRef.current.scrollBy({ left: scrollAmount, behavior: "smooth" });
    }
  };

  return (
    <>
      <div className="relative min-h-full pb-32 mesh-background mesh-gradient-bottom-right-animated">
        {/* 2-Column Layout */}
        <div className="container max-w-[1400px] mx-auto px-6 py-8">
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">

            {/* LEFT COLUMN - Credit Card & Quick Actions */}
            <div className="lg:col-span-4 space-y-6">

              {/* Credit Card with Quick Action Buttons - Aligned */}
              <StaggerItem>
                <div className="space-y-4">
                  {/* Wallet Card - Premium Credit Card Design with assignX Branding */}
                  <div className="relative w-full max-w-[380px] h-[270px] rounded-[24px] bg-gradient-to-br from-stone-700 via-stone-800 to-stone-900 overflow-hidden shadow-[0_20px_60px_-15px_rgba(0,0,0,0.4)] hover:shadow-[0_25px_70px_-15px_rgba(0,0,0,0.5)] transition-all duration-500 group">
                    {/* Premium gradient mesh overlays */}
                    <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_top_right,_var(--tw-gradient-stops))] from-amber-500/20 via-transparent to-transparent" />
                    <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_bottom_left,_var(--tw-gradient-stops))] from-orange-600/15 via-transparent to-transparent" />
                    <div className="absolute top-0 right-0 w-[200px] h-[200px] bg-gradient-to-br from-amber-400/10 to-transparent rounded-full blur-3xl" />
                    <div className="absolute bottom-0 left-0 w-[160px] h-[160px] bg-gradient-to-tr from-violet-500/8 to-transparent rounded-full blur-2xl" />

                    {/* Subtle texture overlay */}
                    <div className="absolute inset-0 opacity-[0.03]" style={{
                      backgroundImage: 'url("data:image/svg+xml,%3Csvg width="100" height="100" xmlns="http://www.w3.org/2000/svg"%3E%3Cfilter id="noise"%3E%3CfeTurbulence type="fractalNoise" baseFrequency="0.9" numOctaves="4" /%3E%3C/filter%3E%3Crect width="100" height="100" filter="url(%23noise)" opacity="0.4"/%3E%3C/svg%3E")'
                    }} />

                    {/* Card Content - Proper Spacing */}
                    <div className="relative z-10 h-full px-7 py-6 flex flex-col">
                      {/* Top Row: EMV Chip & Contactless Icon */}
                      <div className="flex items-start justify-between mb-8">
                        {/* Premium EMV Chip with realistic shadow */}
                        <div className="relative">
                          <div className="w-[52px] h-[40px] rounded-[8px] bg-gradient-to-br from-[#E5C158] via-[#D4AF37] to-[#B8941F] shadow-[0_4px_12px_rgba(0,0,0,0.4),inset_0_1px_1px_rgba(255,255,255,0.3)] border border-[#C5A028]/40">
                            {/* Chip realistic pattern */}
                            <div className="absolute inset-[3px] grid grid-cols-4 grid-rows-3 gap-[1px]">
                              {Array.from({ length: 12 }).map((_, i) => (
                                <div key={i} className="bg-[#9D8420]/40 rounded-[1px]" />
                              ))}
                            </div>
                            {/* Shine effect */}
                            <div className="absolute inset-0 bg-gradient-to-br from-white/20 via-transparent to-transparent rounded-[8px]" />
                          </div>
                        </div>

                        {/* Contactless Icon - Enhanced */}
                        <div className="flex items-center gap-1">
                          <div className="rotate-90">
                            <svg className="w-6 h-6 text-white/40" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
                              <path d="M5 12h.01M10 12h.01M15 12h.01M20 12h.01" />
                            </svg>
                          </div>
                        </div>
                      </div>

                      {/* Middle: Card Number Dots */}
                      <div className="mb-6">
                        <div className="flex items-center gap-3">
                          <div className="flex gap-1">
                            {Array.from({ length: 4 }).map((_, i) => (
                              <div key={i} className="w-1.5 h-1.5 rounded-full bg-white/30" />
                            ))}
                          </div>
                          <div className="flex gap-1">
                            {Array.from({ length: 4 }).map((_, i) => (
                              <div key={i} className="w-1.5 h-1.5 rounded-full bg-white/30" />
                            ))}
                          </div>
                          <div className="flex gap-1">
                            {Array.from({ length: 4 }).map((_, i) => (
                              <div key={i} className="w-1.5 h-1.5 rounded-full bg-white/30" />
                            ))}
                          </div>
                          <span className="text-white/50 text-sm font-mono tracking-wider">4242</span>
                        </div>
                      </div>

                      {/* Balance Section */}
                      <div className="mb-auto">
                        <p className="text-white/50 text-[11px] mb-2 uppercase tracking-[0.1em] font-semibold">Available Balance</p>
                        <p className="text-white text-[36px] leading-none font-bold tabular-nums tracking-tight drop-shadow-[0_2px_8px_rgba(0,0,0,0.3)]">
                          {formatCurrency(wallet?.balance || 0)}
                        </p>
                      </div>

                      {/* Bottom Row: Card Holder, Valid Thru & assignX Logo */}
                      <div className="flex items-end justify-between mt-auto">
                        {/* Left: Card Holder */}
                        <div className="flex items-end gap-6">
                          <div>
                            <p className="text-white/40 text-[9px] uppercase tracking-[0.15em] font-bold mb-1.5">Card Holder</p>
                            <p className="text-white/95 text-[15px] font-bold uppercase tracking-[0.08em] drop-shadow-sm">
                              {userName}
                            </p>
                          </div>

                          {/* Valid Thru */}
                          <div>
                            <p className="text-white/40 text-[9px] uppercase tracking-[0.15em] font-bold mb-1.5">Valid Thru</p>
                            <p className="text-white/60 text-[13px] font-mono tracking-wide">
                              {String(new Date().getMonth() + 1).padStart(2, '0')}/{String(new Date().getFullYear() % 100 + 5).padStart(2, '0')}
                            </p>
                          </div>
                        </div>

                        {/* Right: assignX Logo */}
                        <div className="relative">
                          <div className="absolute inset-0 bg-gradient-to-br from-amber-500/20 to-orange-600/20 blur-xl rounded-xl" />
                          <div className="relative px-4 py-2.5 rounded-xl bg-gradient-to-br from-white/10 to-white/5 backdrop-blur-md border border-white/20 shadow-[0_4px_16px_rgba(0,0,0,0.2)]">
                            <div className="flex items-center gap-1.5">
                              <div className="w-1.5 h-1.5 rounded-full bg-gradient-to-br from-amber-400 to-orange-500 shadow-[0_0_8px_rgba(245,158,11,0.6)]" />
                              <span className="text-white text-[17px] font-black tracking-[0.12em] bg-gradient-to-r from-white via-amber-100 to-white bg-clip-text text-transparent drop-shadow-[0_2px_12px_rgba(245,158,11,0.4)]">
                                assignX
                              </span>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>

                    {/* Hover glow effect */}
                    <div className="absolute inset-0 rounded-[24px] opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none">
                      <div className="absolute inset-0 rounded-[24px] bg-gradient-to-tr from-amber-500/5 via-transparent to-violet-500/5" />
                    </div>
                  </div>

                  {/* Quick Action Buttons - Aligned with Card */}
                  <div className="grid grid-cols-2 gap-4 max-w-[340px]">
                    <button
                      onClick={() => setTopUpOpen(true)}
                      className="relative overflow-hidden rounded-[16px] p-5 bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 transition-all duration-300 hover:shadow-xl hover:shadow-black/5 hover:bg-white/90 dark:hover:bg-white/10 group"
                    >
                      <div className="absolute inset-0 bg-gradient-to-br from-emerald-100/30 to-green-50/10 dark:from-emerald-900/10 dark:to-transparent pointer-events-none rounded-[16px]" />
                      <div className="relative z-10 flex flex-col items-center gap-3">
                        <div className="w-11 h-11 rounded-2xl bg-gradient-to-br from-emerald-500 to-green-600 flex items-center justify-center shadow-lg shadow-emerald-500/20 group-hover:shadow-emerald-500/30 transition-all">
                          <Plus className="h-5 w-5 text-white" strokeWidth={2.5} />
                        </div>
                        <span className="text-xs font-semibold text-foreground">Add Balance</span>
                      </div>
                    </button>
                    <button
                      onClick={() => setSendMoneyOpen(true)}
                      className="relative overflow-hidden rounded-[16px] p-5 bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 transition-all duration-300 hover:shadow-xl hover:shadow-black/5 hover:bg-white/90 dark:hover:bg-white/10 group"
                    >
                      <div className="absolute inset-0 bg-gradient-to-br from-violet-100/30 to-purple-50/10 dark:from-violet-900/10 dark:to-transparent pointer-events-none rounded-[16px]" />
                      <div className="relative z-10 flex flex-col items-center gap-3">
                        <div className="w-11 h-11 rounded-2xl bg-gradient-to-br from-violet-500 to-purple-600 flex items-center justify-center shadow-lg shadow-violet-500/20 group-hover:shadow-violet-500/30 transition-all">
                          <Send className="h-5 w-5 text-white" strokeWidth={2.5} />
                        </div>
                        <span className="text-xs font-semibold text-foreground">Send Money</span>
                      </div>
                    </button>
                  </div>
                </div>
              </StaggerItem>

              {/* Stats Cards - Glassmorphic Grid */}
              <StaggerItem>
                <div className="grid grid-cols-2 gap-3">
                  {/* Rewards */}
                  <div className="relative overflow-hidden rounded-[16px] p-4 bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 transition-all duration-300 hover:shadow-lg hover:shadow-black/5">
                    <div className="absolute inset-0 bg-gradient-to-br from-amber-100/40 to-orange-50/20 dark:from-amber-900/10 dark:to-transparent pointer-events-none rounded-[16px]" />
                    <div className="relative z-10">
                      <div className="flex items-center gap-2 mb-2">
                        <div className="w-8 h-8 rounded-xl bg-gradient-to-br from-amber-500 to-orange-500 flex items-center justify-center shadow-lg shadow-amber-500/20">
                          <Trophy className="h-4 w-4 text-white" strokeWidth={2.5} />
                        </div>
                      </div>
                      <p className="text-[10px] text-muted-foreground mb-1 uppercase tracking-wide">Rewards</p>
                      <p className="text-lg font-bold tabular-nums">
                        {stats.rewardPoints.toLocaleString()}
                      </p>
                    </div>
                  </div>

                  {/* Wallet Balance */}
                  <div className="relative overflow-hidden rounded-[16px] p-4 bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 transition-all duration-300 hover:shadow-lg hover:shadow-black/5">
                    <div className="absolute inset-0 bg-gradient-to-br from-blue-100/40 to-indigo-50/20 dark:from-blue-900/10 dark:to-transparent pointer-events-none rounded-[16px]" />
                    <div className="relative z-10">
                      <div className="flex items-center gap-2 mb-2">
                        <div className="w-8 h-8 rounded-xl bg-gradient-to-br from-blue-500 to-indigo-500 flex items-center justify-center shadow-lg shadow-blue-500/20">
                          <Wallet className="h-4 w-4 text-white" strokeWidth={2.5} />
                        </div>
                      </div>
                      <p className="text-[10px] text-muted-foreground mb-1 uppercase tracking-wide">Wallet Balance</p>
                      <p className="text-lg font-bold tabular-nums">
                        {formatCurrency(wallet?.balance || 0)}
                      </p>
                    </div>
                  </div>

                  {/* Monthly Spend - Full Width */}
                  <div className="relative overflow-hidden rounded-[16px] p-4 bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 transition-all duration-300 hover:shadow-lg hover:shadow-black/5 col-span-2">
                    <div className="absolute inset-0 bg-gradient-to-br from-violet-100/40 to-purple-50/20 dark:from-violet-900/10 dark:to-transparent pointer-events-none rounded-[16px]" />
                    <div className="relative z-10 flex items-center justify-between">
                      <div>
                        <div className="flex items-center gap-2 mb-1">
                          <div className="w-8 h-8 rounded-xl bg-gradient-to-br from-violet-500 to-purple-500 flex items-center justify-center shadow-lg shadow-violet-500/20">
                            <CreditCard className="h-4 w-4 text-white" strokeWidth={2.5} />
                          </div>
                        </div>
                        <p className="text-[10px] text-muted-foreground uppercase tracking-wide">Monthly Spend</p>
                      </div>
                      <p className="text-xl font-bold tabular-nums">
                        {formatCurrency(stats.monthlySpend)}
                      </p>
                    </div>
                  </div>
                </div>
              </StaggerItem>
            </div>

            {/* RIGHT COLUMN - Payment Templates & History */}
            <div className="lg:col-span-8 space-y-5">

              {/* Payment Templates - Glassmorphic Design */}
              <StaggerItem>
                <div>
                  <div className="flex items-center justify-between mb-5">
                    <h2 className="text-base font-bold tracking-tight">Offers</h2>
                  </div>
                  <div className="relative">
                    <div
                      ref={offersRef}
                      className="flex gap-4 overflow-x-auto scrollbar-hide pb-2"
                      style={{ scrollbarWidth: "none", msOverflowStyle: "none" }}
                    >
                      {/* Internet & TV - Blue glassmorphic */}
                      <div className="min-w-[180px] relative overflow-hidden rounded-[20px] p-5 cursor-pointer transition-all duration-300 hover:scale-[1.02] hover:shadow-xl hover:shadow-blue-500/10 bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 group">
                        <div className="absolute inset-0 bg-gradient-to-br from-blue-100/50 to-indigo-50/30 dark:from-blue-900/20 dark:to-indigo-900/10 pointer-events-none rounded-[20px]" />
                        <div className="relative z-10 flex flex-col items-center gap-3 text-center">
                          <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-blue-500 to-indigo-500 flex items-center justify-center shadow-lg shadow-blue-500/20 group-hover:shadow-blue-500/30 transition-all">
                            <Gift className="h-5 w-5 text-white" strokeWidth={2} />
                          </div>
                          <div>
                            <h3 className="text-sm font-semibold text-foreground mb-0.5">Internet & TV</h3>
                            <p className="text-xs text-muted-foreground">Airtel</p>
                          </div>
                        </div>
                      </div>

                      {/* Electricity - Green glassmorphic */}
                      <div className="min-w-[180px] relative overflow-hidden rounded-[20px] p-5 cursor-pointer transition-all duration-300 hover:scale-[1.02] hover:shadow-xl hover:shadow-emerald-500/10 bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 group">
                        <div className="absolute inset-0 bg-gradient-to-br from-emerald-100/50 to-green-50/30 dark:from-emerald-900/20 dark:to-green-900/10 pointer-events-none rounded-[20px]" />
                        <div className="relative z-10 flex flex-col items-center gap-3 text-center">
                          <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-emerald-500 to-green-500 flex items-center justify-center shadow-lg shadow-emerald-500/20 group-hover:shadow-emerald-500/30 transition-all">
                            <Gift className="h-5 w-5 text-white" strokeWidth={2} />
                          </div>
                          <div>
                            <h3 className="text-sm font-semibold text-foreground mb-0.5">Electricity</h3>
                            <p className="text-xs text-muted-foreground">Energy Board</p>
                          </div>
                        </div>
                      </div>

                      {/* Shopping - Purple glassmorphic */}
                      <div className="min-w-[180px] relative overflow-hidden rounded-[20px] p-5 cursor-pointer transition-all duration-300 hover:scale-[1.02] hover:shadow-xl hover:shadow-violet-500/10 bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 group">
                        <div className="absolute inset-0 bg-gradient-to-br from-violet-100/50 to-purple-50/30 dark:from-violet-900/20 dark:to-purple-900/10 pointer-events-none rounded-[20px]" />
                        <div className="relative z-10 flex flex-col items-center gap-3 text-center">
                          <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-violet-500 to-purple-500 flex items-center justify-center shadow-lg shadow-violet-500/20 group-hover:shadow-violet-500/30 transition-all">
                            <ShoppingBag className="h-5 w-5 text-white" strokeWidth={2} />
                          </div>
                          <div>
                            <h3 className="text-sm font-semibold text-foreground mb-0.5">Shopping</h3>
                            <p className="text-xs text-muted-foreground">Amazon</p>
                          </div>
                        </div>
                      </div>

                      {/* Food - Orange glassmorphic */}
                      <div className="min-w-[180px] relative overflow-hidden rounded-[20px] p-5 cursor-pointer transition-all duration-300 hover:scale-[1.02] hover:shadow-xl hover:shadow-amber-500/10 bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 group">
                        <div className="absolute inset-0 bg-gradient-to-br from-amber-100/50 to-orange-50/30 dark:from-amber-900/20 dark:to-orange-900/10 pointer-events-none rounded-[20px]" />
                        <div className="relative z-10 flex flex-col items-center gap-3 text-center">
                          <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-amber-500 to-orange-500 flex items-center justify-center shadow-lg shadow-amber-500/20 group-hover:shadow-amber-500/30 transition-all">
                            <Utensils className="h-5 w-5 text-white" strokeWidth={2} />
                          </div>
                          <div>
                            <h3 className="text-sm font-semibold text-foreground mb-0.5">Food & Dining</h3>
                            <p className="text-xs text-muted-foreground">Cafeteria</p>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </StaggerItem>

              {/* Payment History - Glassmorphic Design */}
              <StaggerItem>
                <div>
                  <div className="flex items-center justify-between mb-5">
                    <h2 className="text-base font-bold tracking-tight">Payment History</h2>
                    <button
                      onClick={() => toast.info("Transaction search coming soon!")}
                      className="w-9 h-9 rounded-xl bg-white/50 dark:bg-white/5 border border-white/50 dark:border-white/10 hover:bg-white/80 dark:hover:bg-white/10 flex items-center justify-center transition-all duration-200"
                    >
                      <Search className="h-4 w-4 text-muted-foreground" strokeWidth={2} />
                    </button>
                  </div>

                  {lastMonthTransactions.length === 0 ? (
                    <div className="relative overflow-hidden rounded-[20px] p-16 text-center bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10">
                      <div className="absolute inset-0 bg-gradient-to-br from-violet-100/20 to-purple-50/10 dark:from-violet-900/5 dark:to-transparent pointer-events-none rounded-[20px]" />
                      <div className="relative z-10">
                        <div className="h-16 w-16 rounded-[20px] bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 flex items-center justify-center mx-auto mb-5 shadow-lg">
                          <CreditCard className="h-7 w-7 text-muted-foreground" strokeWidth={1.5} />
                        </div>
                        <p className="text-sm font-semibold mb-1.5">No transactions yet</p>
                        <p className="text-xs text-muted-foreground max-w-[220px] mx-auto leading-relaxed">
                          Your transaction history will appear here
                        </p>
                      </div>
                    </div>
                  ) : (
                    <div className="relative overflow-hidden rounded-[20px] p-2 bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10">
                      <div className="absolute inset-0 bg-gradient-to-br from-violet-100/20 to-purple-50/10 dark:from-violet-900/5 dark:to-transparent pointer-events-none rounded-[20px]" />
                      <div className="relative z-10 space-y-0.5">
                        {lastMonthTransactions.map((tx, index) => {
                          const isIncoming = isIncomingTransaction(tx.transaction_type);
                          const CustomIcon = getTransactionIcon(tx.description);

                          return (
                            <div
                              key={tx.id}
                              className="flex items-center gap-4 p-4 rounded-[16px] hover:bg-white/50 dark:hover:bg-white/5 transition-all duration-200 group"
                            >
                              {/* Icon */}
                              <div
                                className={cn(
                                  "w-11 h-11 rounded-2xl flex items-center justify-center flex-shrink-0 transition-all shadow-sm",
                                  isIncoming
                                    ? "bg-gradient-to-br from-emerald-500 to-green-600 shadow-emerald-500/20"
                                    : "bg-gradient-to-br from-gray-400 to-gray-500 dark:from-gray-600 dark:to-gray-700 shadow-gray-400/20"
                                )}
                              >
                                {CustomIcon ? (
                                  <CustomIcon className="h-5 w-5 text-white" strokeWidth={2} />
                                ) : isIncoming ? (
                                  <ArrowDownLeft className="h-5 w-5 text-white" strokeWidth={2} />
                                ) : (
                                  <ArrowUpRight className="h-5 w-5 text-white" strokeWidth={2} />
                                )}
                              </div>

                              {/* Details */}
                              <div className="flex-1 min-w-0">
                                <p className="text-sm font-semibold truncate mb-0.5">
                                  {tx.description}
                                </p>
                                <p className="text-[11px] text-muted-foreground">
                                  {new Date(tx.created_at).toLocaleDateString("en-US", {
                                    day: "2-digit",
                                    month: "short",
                                    year: "numeric",
                                    hour: "2-digit",
                                    minute: "2-digit",
                                  })}
                                </p>
                              </div>

                              {/* Amount */}
                              <div className="text-right flex-shrink-0">
                                <p
                                  className={cn(
                                    "text-sm font-bold tabular-nums mb-0.5",
                                    isIncoming
                                      ? "text-emerald-600 dark:text-emerald-500"
                                      : "text-foreground/90"
                                  )}
                                >
                                  {isIncoming ? "+" : "−"} {formatCurrency(tx.amount)}
                                </p>
                                {tx.status !== "completed" && (
                                  <span
                                    className={cn(
                                      "text-[10px] px-2 py-0.5 rounded-full font-medium inline-block",
                                      tx.status === "pending"
                                        ? "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400"
                                        : "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400"
                                    )}
                                  >
                                    {tx.status === "pending" ? "Pending" : "Failed"}
                                  </span>
                                )}
                              </div>
                            </div>
                          );
                        })}
                      </div>
                    </div>
                  )}
                </div>
              </StaggerItem>
            </div>
          </div>
        </div>
      </div>

      <WalletTopUpSheet open={topUpOpen} onOpenChange={setTopUpOpen} />
      <SendMoneySheet open={sendMoneyOpen} onOpenChange={setSendMoneyOpen} />
    </>
  );
}

/**
 * Wallet page with data fetching and skeleton provider
 * Manages loading state and provides choreographed reveal
 */
function WalletPageContent() {
  const searchParams = useSearchParams();
  const { user } = useUserStore();
  const [wallet, setWallet] = useState<{ balance: number } | null>(null);
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [topUpOpen, setTopUpOpen] = useState(false);
  const [sendMoneyOpen, setSendMoneyOpen] = useState(false);

  // Handle topup action from URL
  useEffect(() => {
    if (searchParams.get("action") === "topup") {
      setTopUpOpen(true);
    }
  }, [searchParams]);

  // Fetch wallet data
  useEffect(() => {
    const fetchData = async () => {
      try {
        const [walletData, transactionsData] = await Promise.all([
          getWallet(),
          getWalletTransactions(50),
        ]);
        setWallet(walletData);
        setTransactions(transactionsData as Transaction[]);
      } finally {
        setIsLoading(false);
      }
    };
    fetchData();
  }, []);

  // Subscribe to realtime wallet and transaction updates
  useEffect(() => {
    const supabase = createClient();
    let walletChannel: ReturnType<typeof supabase.channel> | null = null;
    let txChannel: ReturnType<typeof supabase.channel> | null = null;

    const setupRealtimeSubscription = async () => {
      const { data: { user: authUser } } = await supabase.auth.getUser();
      if (!authUser) return;

      // Subscribe to wallet balance updates
      walletChannel = supabase
        .channel(`wallet_page_balance_${authUser.id}`)
        .on(
          "postgres_changes",
          {
            event: "UPDATE",
            schema: "public",
            table: "wallets",
            filter: `profile_id=eq.${authUser.id}`,
          },
          async () => {
            const walletData = await getWallet();
            if (walletData) {
              setWallet(walletData);
            }
          }
        )
        .subscribe();

      // Get the user's wallet ID to subscribe to transactions
      const { data: walletRow } = await supabase
        .from("wallets")
        .select("id")
        .eq("profile_id", authUser.id)
        .eq("wallet_type", "user")
        .single();

      if (walletRow) {
        txChannel = supabase
          .channel(`wallet_page_tx_${walletRow.id}`)
          .on(
            "postgres_changes",
            {
              event: "INSERT",
              schema: "public",
              table: "wallet_transactions",
              filter: `wallet_id=eq.${walletRow.id}`,
            },
            async (payload: any) => {
              // Refresh transactions list
              const transactionsData = await getWalletTransactions(50);
              setTransactions(transactionsData as Transaction[]);

              // Show toast for the new transaction
              const tx = payload.new as {
                transaction_type?: string;
                amount?: number;
                description?: string;
              };
              if (tx.amount) {
                const isCredit = ["credit", "top_up", "refund", "project_earning", "bonus"].includes(
                  tx.transaction_type || ""
                );
                toast(isCredit ? "Wallet Credited" : "Wallet Debited", {
                  description: tx.description || `${isCredit ? "+" : "-"}${tx.amount}`,
                });
              }
            }
          )
          .subscribe();
      }
    };

    setupRealtimeSubscription();

    return () => {
      const supabaseCleanup = createClient();
      if (walletChannel) {
        supabaseCleanup.removeChannel(walletChannel);
      }
      if (txChannel) {
        supabaseCleanup.removeChannel(txChannel);
      }
    };
  }, []);

  // Calculate stats
  const stats = useMemo(() => {
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    let monthlySpend = 0;
    let pendingAmount = 0;

    transactions.forEach((tx) => {
      const txDate = new Date(tx.created_at);
      if (!isIncomingTransaction(tx.transaction_type) && txDate >= startOfMonth) {
        monthlySpend += tx.amount;
      }
      if (tx.status === "pending") {
        pendingAmount += tx.amount;
      }
    });

    return { monthlySpend, pendingAmount, rewardPoints: 0 };
  }, [transactions]);

  // Get last month's transactions
  const lastMonthTransactions = useMemo(() => {
    return transactions.slice(0, 10);
  }, [transactions]);

  // Get user display name
  const userName = user?.fullName || user?.full_name || "User";

  return (
    <PageSkeletonProvider
      isLoading={isLoading}
      skeleton={<WalletSkeleton />}
      minimumDuration={1000}
      className="flex-1"
    >
      <WalletContentInner
        wallet={wallet}
        stats={stats}
        lastMonthTransactions={lastMonthTransactions}
        userName={userName}
        topUpOpen={topUpOpen}
        setTopUpOpen={setTopUpOpen}
        sendMoneyOpen={sendMoneyOpen}
        setSendMoneyOpen={setSendMoneyOpen}
      />
    </PageSkeletonProvider>
  );
}

/**
 * Wallet Page - Main export with Suspense boundary
 */
export default function WalletPage() {
  return (
    <div className="flex-1">
      <Suspense
        fallback={
          <div className="flex items-center justify-center py-12">
            <Loader2 className="h-5 w-5 animate-spin text-muted-foreground" />
          </div>
        }
      >
        <WalletPageContent />
      </Suspense>
    </div>
  );
}
