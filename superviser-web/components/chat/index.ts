/**
 * @fileoverview Barrel exports for the chat module.
 * @module components/chat
 */

// Type definitions and constants
export * from "./types"
export { CHAT_ROOM_TYPE_CONFIG } from "./types"

// Chat window components
export { ChatWindow } from "./chat-window"
export { MessageList } from "./message-list"
export { MessageInput } from "./message-input"

// UI components
export { MessageIllustration } from "./message-illustration"
export { MessagesHero } from "./messages-hero"
export { MessagesStats } from "./messages-stats"
export { CategoryTabs } from "./category-tabs"
export type { CategoryTab } from "./category-tabs"
export { MessagesEmptyState } from "./messages-empty-state"
export { MessagesQuickActions } from "./messages-quick-actions"
export { CategoryBadge } from "./category-badge"
export { UnreadIndicator } from "./unread-indicator"

// Conversation components
export { ConversationItem } from "./conversation-item"
export { ConversationsTimeline } from "./conversations-timeline"

// Legacy exports (kept for backwards compatibility)
/** @deprecated Use MessagesHero instead */
export { MessagesHeader } from "./messages-header"
/** @deprecated Use ConversationItem instead */
export { ConversationCard } from "./conversation-card"
/** @deprecated Use CategoryTabs instead */
export { CategoryCards } from "./category-cards"
/** @deprecated Use ConversationsTimeline instead */
export { ConversationsGrid } from "./conversations-grid"
