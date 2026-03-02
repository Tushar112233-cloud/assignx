"use client";

import { useEffect } from "react";
import Link from "next/link";
import { Wallet, Loader2 } from "lucide-react";
import { toast } from "sonner";
import { useWalletStore } from "@/stores";
import { getSocket } from "@/lib/socket/client";
import { getStoredUser } from "@/lib/api/auth";
import { cn } from "@/lib/utils";

/**
 * Wallet balance pill component - Matches new design system
 * Glass morphism style with cleaner appearance
 * Subscribes to API Realtime for live wallet balance updates
 */
export function WalletPill() {
  const { balance, currency, isLoading, fetchWallet, refreshAll } = useWalletStore();

  // Fetch wallet on mount
  useEffect(() => {
    fetchWallet();
  }, [fetchWallet]);

  // Subscribe to realtime wallet updates via Socket.IO
  useEffect(() => {
    const user = getStoredUser();
    if (!user?.id) return;

    const socket = getSocket();
    const walletEvent = `wallet:${user.id}`;
    const txEvent = `wallet-tx:${user.id}`;

    const walletHandler = () => {
      refreshAll();
    };

    const txHandler = (tx: any) => {
      refreshAll();

      if (tx.amount) {
        const isCredit = ["credit", "top_up", "refund", "project_earning", "bonus"].includes(
          tx.transaction_type || ""
        );
        toast(isCredit ? "Wallet Credited" : "Wallet Debited", {
          description: tx.description || `${isCredit ? "+" : "-"}${tx.amount}`,
        });
      }
    };

    socket.on(walletEvent, walletHandler);
    socket.on(txEvent, txHandler);

    return () => {
      socket.off(walletEvent, walletHandler);
      socket.off(txEvent, txHandler);
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
