/**
 * Services barrel export
 * Central export point for all service modules
 *
 * Note: Auth operations use server actions in lib/actions/auth.ts
 * Profile types are defined in types/database.ts
 */

export { projectService } from './project.service'
export type {
  Project,
  ProjectInsert,
  ProjectUpdate,
  ProjectFile,
  ProjectDeliverable,
  ProjectRevision,
  ProjectStatusHistory,
  ProjectWithDetails,
  ProjectFilters,
  ProjectStatus,
  ServiceType,
  ProjectQuote,
  TimelineEvent,
} from './project.service'

export { walletService } from './wallet.service'
export type {
  WalletTransaction,
  PaymentMethod,
  TransactionFilters,
  RazorpayOrder,
  PaymentVerification,
} from './wallet.service'

export { chatService } from './chat.service'
export type {
  ChatRoom,
  ChatMessage,
  ChatMessageInsert,
  ChatParticipant,
  ChatRoomWithDetails,
  MessageWithSender,
  MessageCallback,
} from './chat.service'

export { marketplaceService } from './marketplace.service'
export type {
  MarketplaceListing,
  MarketplaceListingInsert,
  MarketplaceListingUpdate,
  MarketplaceCategory,
  ListingWithSeller,
  ListingFilters,
  ListingType,
} from './marketplace.service'

export { notificationService } from './notification.service'
export type {
  Notification,
  NotificationType,
  NotificationFilters,
  NotificationCallback,
} from './notification.service'
