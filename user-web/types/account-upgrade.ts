/**
 * Account Upgrade type definitions
 * Types for account type management and upgrade flows
 */

/**
 * Account type representing user categories
 */
export type AccountType = 'student' | 'professional' | 'business_owner';

/**
 * Account tier with detailed information
 */
export interface AccountTier {
  type: AccountType;
  displayName: string;
  description: string;
  benefits: string[];
  requirements: string[];
  canUpgradeTo: AccountType[];
  icon: string;
  color: string;
}

/**
 * Upgrade step in the multi-step flow
 */
export type UpgradeStep = 'select' | 'verify' | 'confirm' | 'success';

/**
 * Verification document types
 */
export type VerificationDocType =
  | 'graduation_certificate'
  | 'degree_certificate'
  | 'id_card'
  | 'business_registration'
  | 'tax_certificate'
  | 'professional_license';

/**
 * Verification requirement for account upgrade
 */
export interface VerificationRequirement {
  id: string;
  type: VerificationDocType;
  label: string;
  description: string;
  required: boolean;
  accepted: boolean;
  file?: File;
}

/**
 * Upgrade request data
 */
export interface UpgradeRequest {
  currentType: AccountType;
  targetType: AccountType;
  verificationDocuments: VerificationRequirement[];
  paymentRequired: boolean;
  paymentAmount?: number;
}

/**
 * Upgrade status after submission
 */
export type UpgradeStatus = 'pending' | 'approved' | 'rejected' | 'requires_action';

/**
 * Upgrade history entry
 */
export interface UpgradeHistoryEntry {
  id: string;
  fromType: AccountType;
  toType: AccountType;
  requestedAt: string;
  processedAt?: string;
  status: UpgradeStatus;
  rejectionReason?: string;
}

/**
 * Feature comparison item for benefits table
 */
export interface FeatureComparison {
  feature: string;
  student: string | boolean;
  professional: string | boolean;
  business: string | boolean;
}
