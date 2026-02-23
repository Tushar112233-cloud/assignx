"use client";

import { useEffect } from "react";
import Link from "next/link";
import { Wallet, Loader2 } from "lucide-react";
import { toast } from "sonner";
import { useWalletStore } from "@/stores";
import { createClient } from "@/lib/supabase/client";
import { cn } from "@/lib/utils";

/**
 * Wallet balance pill component - Matches new design system
 * Glass morphism style with cleaner appearance
 * Subscribes to Supabase Realtime for live wallet balance updates
 */
export function WalletPill() {
  const { balance, currency, isLoading, fetchWallet, refreshAll } = useWalletStore();

  // Fetch wallet on mount
  useEffect(() => {
    fetchWallet();
  }, [fetchWallet]);

  // Subscribe to realtime wallet balance updates and new transactions
  useEffect(() => {
    const supabase = createClient();
    let walletChannel: ReturnType<typeof supabase.channel> | null = null;
    let txChannel: ReturnType<typeof supabase.channel> | null = null;

    const setupRealtimeSubscription = async () => {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      // Subscribe to wallet balance updates
      walletChannel = supabase
        .channel(`user_wallet_${user.id}`)
        .on(
          "postgres_changes",
          {
            event: "UPDATE",
            schema: "public",
            table: "wallets",
            filter: `profile_id=eq.${user.id}`,
          },
          () => {
            // Refresh wallet and transactions from server
            refreshAll();
          }
        )
        .subscribe();

      // Get the user's wallet ID to subscribe to transactions
      const { data: wallet } = await supabase
        .from("wallets")
        .select("id")
        .eq("profile_id", user.id)
        .eq("wallet_type", "user")
        .single();

      if (wallet) {
        txChannel = supabase
          .channel(`user_wallet_tx_${wallet.id}`)
          .on(
            "postgres_changes",
            {
              event: "INSERT",
              schema: "public",
              table: "wallet_transactions",
              filter: `wallet_id=eq.${wallet.id}`,
            },
            (payload: any) => {
              // Refresh wallet state from server
              refreshAll();

              // Show toast for new transactions
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
  }, [refreshAll]);

  return (
    <Link
      href="/wallet"
      className={cn(
        "flex items-center gap-2 px-3.5 h-9 rounded-full",
        "bg-card/80 hover:bg-card border border-border/50",
        "backdrop-blur-sm transition-all duration-200",
        "text-sm font-medium text-foreground/90",
        "hover:shadow-sm hover:border-border"
      )}
    >
      {isLoading ? (
        <Loader2 className="h-4 w-4 animate-spin text-muted-foreground" />
      ) : (
        <Wallet className="h-4 w-4 text-muted-foreground" strokeWidth={1.5} />
      )}
      <span className="font-medium">
        Wallet · {currency}{balance.toLocaleString()}
      </span>
    </Link>
  );
}
