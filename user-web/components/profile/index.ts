/**
 * Profile module components
 * Batch 8: Profile Settings
 */

export { ProfileHeader } from "./profile-header";
export { AvatarUploadDialog } from "./avatar-upload-dialog";
export { PersonalInfoForm } from "./personal-info-form";
export { AcademicInfoSection } from "./academic-info-section";
export { PreferencesSection } from "./preferences-section";
export { SecuritySection } from "./security-section";
export { SubscriptionCard } from "./subscription-card";
export { DangerZone } from "./danger-zone";
export { SettingsTabs, SettingsSection } from "./settings-tabs";

// New components for feature parity
export { StatsCard } from "./stats-card";
export { ReferralSection } from "./referral-section";
export { WalletTopUpSheet } from "./wallet-top-up-sheet";
export { AppInfoFooter } from "./app-info-footer";

// Account upgrade components
export { AccountUpgradeSection } from "./account-upgrade-section";
export { UpgradeDialog } from "./upgrade-dialog";

// Account type badge
export {
  AccountBadge,
  CompactAccountBadge,
  getAccountType,
  badgeConfig,
  type AccountType,
  type BadgeSize,
} from "./account-badge";
