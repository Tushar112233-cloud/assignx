/**
 * Profile component constants and mock data
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
  WalletTransaction,
  Wallet,
  FAQ,
  SkillWithVerification,
  DoerReview,
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
 * Mock wallet data for demo
 */
export const mockWallet: Wallet = {
  id: 'w1',
  profile_id: 'd1',
  balance: 15800,
  locked_amount: 1800,
  total_credited: 125000,
  total_debited: 0,
  total_withdrawn: 109200,
  currency: 'INR',
  created_at: new Date().toISOString(),
  updated_at: new Date().toISOString(),
}

/**
 * Mock transactions for demo
 */
export const mockTransactions: WalletTransaction[] = [
  {
    id: '1',
    wallet_id: 'w1',
    transaction_type: 'project_earning',
    amount: 2500,
    balance_before: 10000,
    balance_after: 12500,
    description: 'Payment for Essay Writing project',
    reference_id: 'p1',
    reference_type: 'project',
    project_id: 'p1',
    project_title: 'Marketing Analysis Essay',
    status: 'completed',
    created_at: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000).toISOString(),
    completed_at: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000).toISOString(),
  },
  {
    id: '2',
    wallet_id: 'w1',
    transaction_type: 'payout',
    amount: -5000,
    balance_before: 12500,
    balance_after: 7500,
    description: 'Withdrawal to bank account',
    reference_id: 'pay1',
    reference_type: 'payout',
    project_id: null,
    project_title: null,
    status: 'completed',
    created_at: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000).toISOString(),
    completed_at: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000).toISOString(),
  },
  {
    id: '3',
    wallet_id: 'w1',
    transaction_type: 'project_earning',
    amount: 3500,
    balance_before: 7500,
    balance_after: 11000,
    description: 'Payment for Research Paper',
    reference_id: 'p2',
    reference_type: 'project',
    project_id: 'p2',
    project_title: 'Literature Review',
    status: 'completed',
    created_at: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000).toISOString(),
    completed_at: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000).toISOString(),
  },
  {
    id: '4',
    wallet_id: 'w1',
    transaction_type: 'bonus',
    amount: 500,
    balance_before: 11000,
    balance_after: 11500,
    description: 'Performance bonus for September',
    reference_id: 'b1',
    reference_type: 'bonus',
    project_id: null,
    project_title: null,
    status: 'completed',
    created_at: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString(),
    completed_at: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString(),
  },
  {
    id: '5',
    wallet_id: 'w1',
    transaction_type: 'project_earning',
    amount: 1800,
    balance_before: 11500,
    balance_after: 13300,
    description: 'Payment for Case Study',
    reference_id: 'p3',
    reference_type: 'project',
    project_id: 'p3',
    project_title: 'Business Case Study',
    status: 'pending',
    created_at: new Date().toISOString(),
    completed_at: null,
  },
]

/**
 * Mock FAQs for demo
 */
export const mockFAQs: FAQ[] = [
  {
    id: '1',
    question: 'How do I request a payout?',
    answer: 'Go to your Profile > Payment History > Request Payout. Enter the amount you wish to withdraw (minimum ₹500) and confirm. Payouts are processed within 2-3 business days.',
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
 * Mock skills for demo
 */
export const mockSkills: SkillWithVerification[] = [
  {
    id: '1',
    name: 'Essay Writing',
    category: 'Writing',
    is_active: true,
    proficiency_level: 'pro',
    is_verified: true,
    verified_at: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString(),
  },
  {
    id: '2',
    name: 'Research',
    category: 'Research',
    is_active: true,
    proficiency_level: 'intermediate',
    is_verified: true,
    verified_at: new Date(Date.now() - 60 * 24 * 60 * 60 * 1000).toISOString(),
  },
  {
    id: '3',
    name: 'Data Analysis',
    category: 'Analytics',
    is_active: true,
    proficiency_level: 'intermediate',
    is_verified: false,
    verified_at: null,
  },
  {
    id: '4',
    name: 'PowerPoint',
    category: 'Presentation',
    is_active: true,
    proficiency_level: 'pro',
    is_verified: true,
    verified_at: new Date(Date.now() - 45 * 24 * 60 * 60 * 1000).toISOString(),
  },
  {
    id: '5',
    name: 'Academic Editing',
    category: 'Writing',
    is_active: true,
    proficiency_level: 'beginner',
    is_verified: false,
    verified_at: null,
  },
  {
    id: '6',
    name: 'Literature Review',
    category: 'Research',
    is_active: true,
    proficiency_level: 'intermediate',
    is_verified: false,
    verified_at: null,
  },
]

/**
 * Mock reviews for demo
 */
export const mockReviews: DoerReview[] = [
  {
    id: '1',
    doer_id: 'd1',
    reviewer_id: 'r1',
    reviewer_name: 'Dr. Smith',
    project_id: 'p1',
    project_title: 'Marketing Analysis Essay',
    quality_rating: 5,
    timeliness_rating: 5,
    communication_rating: 5,
    overall_rating: 5,
    feedback: 'Excellent work! Very thorough research and well-structured analysis. Would definitely work with again.',
    is_public: true,
    created_at: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString(),
  },
  {
    id: '2',
    doer_id: 'd1',
    reviewer_id: 'r2',
    reviewer_name: 'Prof. Johnson',
    project_id: 'p2',
    project_title: 'Literature Review',
    quality_rating: 4,
    timeliness_rating: 5,
    communication_rating: 4,
    overall_rating: 4,
    feedback: 'Good quality work delivered on time. Minor formatting issues but overall satisfied.',
    is_public: true,
    created_at: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000).toISOString(),
  },
  {
    id: '3',
    doer_id: 'd1',
    reviewer_id: 'r3',
    reviewer_name: 'Ms. Williams',
    project_id: 'p3',
    project_title: 'Business Case Study',
    quality_rating: 5,
    timeliness_rating: 4,
    communication_rating: 5,
    overall_rating: 5,
    feedback: 'Outstanding attention to detail. Great communication throughout the project.',
    is_public: true,
    created_at: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000).toISOString(),
  },
]

/**
 * Default rating distribution
 */
export const defaultRatingDistribution: Record<number, number> = {
  5: 35,
  4: 8,
  3: 2,
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
