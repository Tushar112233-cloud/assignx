/**
 * Account Upgrade static data
 * Contains account tiers, benefits, and requirements
 */

import type {
  AccountTier,
  AccountType,
  FeatureComparison,
  VerificationRequirement,
  VerificationDocType,
} from "@/types/account-upgrade";

/**
 * Account tier definitions with benefits and requirements
 */
export const accountTiers: Record<AccountType, AccountTier> = {
  student: {
    type: "student",
    displayName: "Student",
    description: "Perfect for students working on academic projects",
    benefits: [
      "5 projects per month",
      "Standard support",
      "Access to study resources",
      "Student discounts",
      "Basic AI assistance",
    ],
    requirements: [],
    canUpgradeTo: ["professional"],
    icon: "GraduationCap",
    color: "blue",
  },
  professional: {
    type: "professional",
    displayName: "Professional",
    description: "For working professionals and graduates",
    benefits: [
      "Unlimited projects",
      "Priority support",
      "Advanced AI assistance",
      "1 team member seat",
      "Extended revision period",
      "Plagiarism reports included",
    ],
    requirements: [
      "Graduation proof (degree certificate or transcript)",
      "Valid ID verification",
    ],
    canUpgradeTo: ["business_owner"],
    icon: "Briefcase",
    color: "purple",
  },
  business_owner: {
    type: "business_owner",
    displayName: "Business",
    description: "For businesses and teams",
    benefits: [
      "Unlimited projects",
      "24/7 priority support",
      "Premium AI assistance",
      "Up to 10 team members",
      "Dedicated account manager",
      "Custom integrations",
      "Invoice billing",
      "API access",
    ],
    requirements: [
      "Business registration document",
      "Tax certificate or ID",
    ],
    canUpgradeTo: [],
    icon: "Building2",
    color: "amber",
  },
};

/**
 * Feature comparison table data
 */
export const featureComparison: FeatureComparison[] = [
  {
    feature: "Projects per month",
    student: "5",
    professional: "Unlimited",
    business: "Unlimited",
  },
  {
    feature: "Priority Support",
    student: false,
    professional: true,
    business: true,
  },
  {
    feature: "Team Members",
    student: "1",
    professional: "1",
    business: "10",
  },
  {
    feature: "AI Assistance",
    student: "Basic",
    professional: "Advanced",
    business: "Premium",
  },
  {
    feature: "Revision Period",
    student: "7 days",
    professional: "14 days",
    business: "30 days",
  },
  {
    feature: "Plagiarism Reports",
    student: false,
    professional: true,
    business: true,
  },
  {
    feature: "Dedicated Manager",
    student: false,
    professional: false,
    business: true,
  },
  {
    feature: "API Access",
    student: false,
    professional: false,
    business: true,
  },
  {
    feature: "Invoice Billing",
    student: false,
    professional: false,
    business: true,
  },
];

/**
 * Get verification requirements for an upgrade path
 */
export function getVerificationRequirements(
  fromType: AccountType,
  toType: AccountType
): VerificationRequirement[] {
  if (fromType === "student" && toType === "professional") {
    return [
      {
        id: "graduation_proof",
        type: "graduation_certificate",
        label: "Graduation Proof",
        description: "Degree certificate, transcript, or graduation letter",
        required: true,
        accepted: false,
      },
      {
        id: "id_verification",
        type: "id_card",
        label: "ID Verification",
        description: "Government-issued ID (passport, driver's license, or national ID)",
        required: true,
        accepted: false,
      },
    ];
  }

  if (fromType === "student" && toType === "business_owner") {
    return [
      {
        id: "business_registration",
        type: "business_registration",
        label: "Business Registration",
        description: "Certificate of incorporation or business license",
        required: true,
        accepted: false,
      },
      {
        id: "tax_certificate",
        type: "tax_certificate",
        label: "Tax Certificate",
        description: "Tax registration certificate or business tax ID",
        required: false,
        accepted: false,
      },
      {
        id: "id_verification",
        type: "id_card",
        label: "ID Verification",
        description: "Government-issued ID of the business owner",
        required: true,
        accepted: false,
      },
    ];
  }

  if (fromType === "professional" && toType === "business_owner") {
    return [
      {
        id: "business_registration",
        type: "business_registration",
        label: "Business Registration",
        description: "Certificate of incorporation or business license",
        required: true,
        accepted: false,
      },
      {
        id: "tax_certificate",
        type: "tax_certificate",
        label: "Tax Certificate",
        description: "Tax registration certificate or business tax ID",
        required: false,
        accepted: false,
      },
    ];
  }

  return [];
}

/**
 * Check if upgrade requires payment
 */
export function upgradeRequiresPayment(
  fromType: AccountType,
  toType: AccountType
): { required: boolean; amount?: number } {
  // Currently, account type upgrades are verification-based only
  // Payment is handled separately through subscription plans
  return { required: false };
}

/**
 * Get estimated processing time for upgrade
 */
export function getProcessingTime(toType: AccountType): string {
  switch (toType) {
    case "professional":
      return "1-2 business days";
    case "business_owner":
      return "2-3 business days";
    default:
      return "Instant";
  }
}

/**
 * Validate if upgrade path is allowed
 */
export function isUpgradeAllowed(
  fromType: AccountType,
  toType: AccountType
): boolean {
  const tier = accountTiers[fromType];
  return tier.canUpgradeTo.includes(toType);
}
