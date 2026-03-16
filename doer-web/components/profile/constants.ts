/**
 * Profile component constants and configuration
 * @module components/profile/constants
 */

import {
  ArrowDownLeft,
  ArrowUpRight,
  Clock,
  CheckCircle2,
  XCircle,
  RefreshCw,
  MessageCircle,
  Mail,
  FileText,
} from 'lucide-react'
import type {
  TransactionType,
  Wallet,
  FAQ,
} from '@/types/database'

/**
 * Transaction type display configuration
 * Maps transaction types to UI properties
 */
export const transactionTypeConfig: Record<
  TransactionType,
  { label: string; icon: typeof ArrowDownLeft; color: string; bgColor: string }
> = {
  project_earning: { label: 'Project Earning', icon: ArrowDownLeft, color: 'text-green-600', bgColor: 'bg-green-500/10' },
  bonus: { label: 'Bonus', icon: ArrowDownLeft, color: 'text-blue-600', bgColor: 'bg-blue-500/10' },
  referral: { label: 'Referral Bonus', icon: ArrowDownLeft, color: 'text-purple-600', bgColor: 'bg-purple-500/10' },
  adjustment: { label: 'Adjustment', icon: RefreshCw, color: 'text-orange-600', bgColor: 'bg-orange-500/10' },
  payout: { label: 'Payout', icon: ArrowUpRight, color: 'text-red-600', bgColor: 'bg-red-500/10' },
  refund: { label: 'Refund', icon: ArrowDownLeft, color: 'text-cyan-600', bgColor: 'bg-cyan-500/10' },
  penalty: { label: 'Penalty', icon: ArrowUpRight, color: 'text-red-600', bgColor: 'bg-red-500/10' },
  tax_deduction: { label: 'Tax Deduction', icon: ArrowUpRight, color: 'text-gray-600', bgColor: 'bg-gray-500/10' },
  hold: { label: 'Hold', icon: Clock, color: 'text-yellow-600', bgColor: 'bg-yellow-500/10' },
  release: { label: 'Released', icon: CheckCircle2, color: 'text-green-600', bgColor: 'bg-green-500/10' },
  chargeback: { label: 'Chargeback', icon: XCircle, color: 'text-red-600', bgColor: 'bg-red-500/10' },
}

/**
 * Transaction status configuration
 */
export const statusConfig = {
  pending: { label: 'Pending', color: 'text-yellow-600', bgColor: 'bg-yellow-500/10', icon: Clock },
  completed: { label: 'Completed', color: 'text-green-600', bgColor: 'bg-green-500/10', icon: CheckCircle2 },
  failed: { label: 'Failed', color: 'text-red-600', bgColor: 'bg-red-500/10', icon: XCircle },
  reversed: { label: 'Reversed', color: 'text-gray-600', bgColor: 'bg-gray-500/10', icon: RefreshCw },
}

/**
 * Support options configuration
 */
export const supportOptions = [
  {
    id: 'whatsapp',
    title: 'WhatsApp Support',
    description: 'Chat with us instantly',
    icon: MessageCircle,
    color: 'text-green-600',
    bgColor: 'bg-green-500/10',
    action: 'Chat Now',
  },
  {
    id: 'ticket',
    title: 'Raise a Ticket',
    description: 'Submit a support request',
    icon: FileText,
    color: 'text-blue-600',
    bgColor: 'bg-blue-500/10',
    action: 'Create Ticket',
  },
  {
    id: 'email',
    title: 'Email Support',
    description: 'support@talentconnect.com',
    icon: Mail,
    color: 'text-purple-600',
    bgColor: 'bg-purple-500/10',
    action: 'Send Email',
  },
]

/**
 * Ticket category options
 */
export const ticketCategories = [
  { value: 'technical', label: 'Technical Issue' },
  { value: 'payment', label: 'Payment Related' },
  { value: 'project', label: 'Project Help' },
  { value: 'account', label: 'Account Issue' },
  { value: 'other', label: 'Other' },
]

/**
 * Empty wallet defaults (no mock data)
 */
export const emptyWallet: Wallet = {
  id: '',
  doer_id: '',
  balance: 0,
  locked_amount: 0,
  total_credited: 0,
  total_debited: 0,
  total_withdrawn: 0,
  currency: 'INR',
  created_at: new Date().toISOString(),
  updated_at: new Date().toISOString(),
}

/**
 * Static FAQs - these are legitimate static content, not mock data
 */
export const mockFAQs: FAQ[] = [
  {
    id: '1',
    question: 'How do I request a payout?',
    answer: 'Go to your Profile > Payment History > Request Payout. Enter the amount you wish to withdraw (minimum \u20B9500) and confirm. Payouts are processed within 2-3 business days.',
    category: 'payment',
    display_order: 1,
    is_active: true,
    target_role: null,
    helpful_count: 0,
    not_helpful_count: 0,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  },
  {
    id: '2',
    question: 'What if I miss a deadline?',
    answer: 'Missing deadlines affects your success rate. Contact your supervisor immediately if you foresee any delays. Repeated missed deadlines may result in account restrictions.',
    category: 'project',
    display_order: 2,
    is_active: true,
    target_role: null,
    helpful_count: 0,
    not_helpful_count: 0,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  },
  {
    id: '3',
    question: 'How are projects assigned?',
    answer: 'Projects are assigned based on your skills, ratings, and availability. You can also grab tasks from the Open Pool if they match your expertise.',
    category: 'project',
    display_order: 3,
    is_active: true,
    target_role: null,
    helpful_count: 0,
    not_helpful_count: 0,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  },
  {
    id: '4',
    question: 'How do I update my bank details?',
    answer: 'Go to Profile > Bank Settings > Update Bank Details. Enter your new account information and save. Changes take effect immediately for future payouts.',
    category: 'account',
    display_order: 4,
    is_active: true,
    target_role: null,
    helpful_count: 0,
    not_helpful_count: 0,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  },
  {
    id: '5',
    question: 'What is the AI Report Generator?',
    answer: 'The AI Report Generator checks your work for AI-generated content before submission. This helps ensure your work meets quality standards and originality requirements.',
    category: 'technical',
    display_order: 5,
    is_active: true,
    target_role: null,
    helpful_count: 0,
    not_helpful_count: 0,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  },
]

/**
 * Empty rating distribution (all zeros)
 */
export const emptyRatingDistribution: Record<number, number> = {
  5: 0,
  4: 0,
  3: 0,
  2: 0,
  1: 0,
}

/**
 * Proficiency level configuration
 */
export const proficiencyConfig = {
  beginner: { label: 'Beginner', color: 'text-blue-600', bgColor: 'bg-blue-500/10' },
  intermediate: { label: 'Intermediate', color: 'text-yellow-600', bgColor: 'bg-yellow-500/10' },
  pro: { label: 'Professional', color: 'text-green-600', bgColor: 'bg-green-500/10' },
}
