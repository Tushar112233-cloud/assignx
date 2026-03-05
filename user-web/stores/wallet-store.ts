import { create } from "zustand";
import { getWallet, getWalletTransactions } from "@/lib/actions/data";
import { getCurrencySymbol } from "@/lib/utils";

/**
 * Wallet interface matching API schema
 */
export interface Wallet {
  id: string;
  user_id: string;
  balance: number;
  currency: string;
  total_credited: number;
  total_debited: number;
  created_at: string;
  updated_at: string;
}

/**
 * Wallet transaction interface
 */
export interface WalletTransaction {
  id: string;
  wallet_id: string;
  transaction_type: "credit" | "debit";
  amount: number;
  description: string | null;
  reference_type: string | null;
  reference_id: string | null;
  balance_after: number;
  created_at: string;
}

interface WalletState {
  wallet: Wallet | null;
  transactions: WalletTransaction[];
  balance: number;
  currency: string;
  isLoading: boolean;
  error: string | null;
  fetchWallet: () => Promise<void>;
  fetchTransactions: (limit?: number) => Promise<void>;
  refreshAll: () => Promise<void>;
  setBalance: (balance: number) => void;
  addCredits: (amount: number) => void;
  deductCredits: (amount: number) => void;
  setLoading: (isLoading: boolean) => void;
}

/**
 * Wallet state store
 * Manages user wallet balance and transactions with API integration
 */
export const useWalletStore = create<WalletState>((set) => ({
  wallet: null,
  transactions: [],
  balance: 0,
  currency: "₹",
  isLoading: false,
  error: null,

  /**
   * Fetches wallet from API
   */
  fetchWallet: async () => {
    set({ isLoading: true, error: null });
    try {
      const wallet = await getWallet();
      if (wallet) {
        set({
          wallet,
          balance: wallet.balance,
          currency: getCurrencySymbol(wallet.currency || "INR"),
          isLoading: false,
        });
      } else {
        set({ isLoading: false });
      }
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : "Failed to fetch wallet",
        isLoading: false,
      });
    }
  },

  /**
   * Fetches wallet transactions from API
   */
  fetchTransactions: async (limit = 20) => {
    set({ isLoading: true, error: null });
    try {
      const transactions = await getWalletTransactions(limit);
      set({ transactions, isLoading: false });
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : "Failed to fetch transactions",
        isLoading: false,
      });
    }
  },

  /**
   * Refreshes both wallet and transactions (used by realtime handlers)
   */
  refreshAll: async () => {
    try {
      const [wallet, transactions] = await Promise.all([
        getWallet(),
        getWalletTransactions(20),
      ]);
      if (wallet) {
        set({
          wallet,
          balance: wallet.balance,
          currency: getCurrencySymbol(wallet.currency || "INR"),
          transactions,
        });
      } else {
        set({ transactions });
      }
    } catch {
      // Silently fail on refresh - don't overwrite existing state with error
    }
  },

  /**
   * Sets wallet balance
   */
  setBalance: (balance) => set({ balance }),

  /**
   * Adds credits to wallet (optimistic update)
   */
  addCredits: (amount) =>
    set((state) => ({ balance: state.balance + amount })),

  /**
   * Deducts credits from wallet (optimistic update)
   */
  deductCredits: (amount) =>
    set((state) => ({ balance: Math.max(0, state.balance - amount) })),

  /**
   * Sets loading state
   */
  setLoading: (isLoading) => set({ isLoading }),
}));
