export const PROJECT_STATUSES = [
  'draft',
  'pending_payment',
  'pending',
  'assigned',
  'in_progress',
  'under_review',
  'revision_requested',
  'revision_in_progress',
  'qc_review',
  'delivered',
  'completed',
  'cancelled',
  'on_hold',
] as const;

export const USER_TYPES = ['user', 'doer', 'supervisor', 'admin'] as const;

export const TRANSACTION_TYPES = [
  'project_payment',
  'project_earning',
  'topup',
  'transfer_in',
  'transfer_out',
  'payout',
  'refund',
  'bonus',
  'commission',
  'platform_fee',
] as const;
