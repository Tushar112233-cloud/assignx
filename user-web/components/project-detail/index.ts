/**
 * Project detail page components
 * Batch 5: Project Detail Page
 */

export { ProjectDetailHeader } from "./project-detail-header";
export { StatusBanner } from "./status-banner";
export { DeadlineCountdown } from "./deadline-countdown";
export { LiveDraftTracker } from "./live-draft-tracker";
export { ProjectBriefAccordion } from "./project-brief-accordion";
export { AttachedFiles } from "./attached-files";
export { DeliverablesSection } from "./deliverables-section";
export { DeliverableItem } from "./deliverable-item";
export { QualityReportBadge } from "./quality-report-badge";
export { FloatingChatButton } from "./floating-chat-button";
export { ChatWindow } from "./chat-window";

// Message approval components
export {
  MessageApprovalBadge,
  MessageApprovalBadgeInline,
  type MessageApprovalStatus,
} from "./message-approval-badge";
export {
  SupervisorMessageActions,
  SupervisorMessageActionsCompact,
} from "./supervisor-message-actions";

// Typing and presence components
export { TypingIndicator, useTypingIndicator } from "./typing-indicator";
export {
  ChatPresenceBanner,
  OnlineUsersIndicator,
  useChatPresence,
} from "./chat-presence";
