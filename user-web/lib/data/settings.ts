/**
 * Settings and support static data
 * Contains app version and static UI options
 * Support tickets and FAQs are fetched from Supabase via lib/actions/data.ts
 */

import type { AppVersion } from "@/types/settings";

/**
 * Current app version
 * Static app metadata
 */
export const appVersion: AppVersion = {
  version: "1.0.0-beta",
  buildNumber: "2024.12.26",
  lastUpdated: "2024-12-26T00:00:00Z",
};

/**
 * Contact form categories
 * Static options for support contact form
 */
export const contactCategories = [
  { value: "general", label: "General Inquiry" },
  { value: "billing", label: "Billing & Payments" },
  { value: "technical", label: "Technical Support" },
  { value: "account", label: "Account Issues" },
];
