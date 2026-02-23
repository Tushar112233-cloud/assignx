/**
 * @fileoverview Central export file for all custom React hooks.
 * @module hooks
 */

// Authentication
export { useAuth } from "./use-auth"

// Analytics
export {
  usePageTracking,
  useEventTracking,
  useComponentTracking,
  useFormTracking,
  useClickTracking,
} from "./use-analytics"

// Accessibility
export { useFocusTrap, useRovingFocus, useAnnounce } from "./use-focus-trap"
export {
  useKeyboardNavigation,
  useEscapeKey,
  useClickOutside,
  useKeyboardShortcut,
} from "./use-keyboard-navigation"

// Responsive Design
export {
  useMediaQuery,
  useIsMobile,
  useIsTablet,
  useIsDesktop,
  useIsLargeDesktop,
  useBreakpoint,
  useOrientation,
  usePrefersReducedMotion,
  usePrefersColorScheme,
  usePrefersContrast,
  useIsTouchDevice,
  useViewportSize,
  useScrollPosition,
  useIsScrolled,
} from "./use-media-query"

// Supervisor Data
export { useSupervisor, useSupervisorStats, useSupervisorExpertise } from "./use-supervisor"

// Projects
export {
  useProjects,
  useProject,
  useProjectsByStatus,
  useNewRequests,
  useReadyToAssign,
  claimProject,
  PROJECT_STATUS_GROUPS,
} from "./use-projects"

// Doers
export {
  useDoers,
  useDoer,
  useDoerStats,
  useBlacklistedDoers,
} from "./use-doers"

// Wallet & Earnings
export {
  useWallet,
  useTransactions,
  useEarningsStats,
  usePayoutRequests,
} from "./use-wallet"

// Chat & Messaging
export {
  useChatRooms,
  useChatMessages,
  useUnreadMessages,
} from "./use-chat"

// Notifications
export {
  useNotifications,
  useNotificationsByGroup,
  NOTIFICATION_GROUPS,
} from "./use-notifications"

// Support Tickets
export {
  useTickets,
  useTicket,
  useCreateTicket,
  useTicketStats,
} from "./use-support"

// Users (Clients)
export {
  useUsers,
  useUserProjects,
  useUserStats,
} from "./use-users"
export type { UserWithStats, UserProject } from "./use-users"
