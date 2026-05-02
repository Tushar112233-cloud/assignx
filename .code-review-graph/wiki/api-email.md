# api-email

## Overview

Directory-based community: superviser-web/lib

- **Size**: 81 nodes
- **Cohesion**: 0.0458
- **Dominant Language**: typescript

## Members

| Name | Kind | File | Lines |
|------|------|------|-------|
| captureException | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/analytics.ts | 16-29 |
| captureMessage | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/analytics.ts | 31-40 |
| trackEvent | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/analytics.ts | 43-52 |
| trackPageView | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/analytics.ts | 54-56 |
| identifyUser | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/analytics.ts | 59-69 |
| resetUser | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/analytics.ts | 71-80 |
| measurePerformance | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/analytics.ts | 83-95 |
| getFeatureFlag | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/analytics.ts | 98-102 |
| startSessionRecording | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/analytics.ts | 105-110 |
| handleBoundaryError | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/analytics.ts | 113-118 |
| getStoredUser | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/api/auth.ts | 28-37 |
| storeUser | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/api/auth.ts | 39-46 |
| clearStoredUser | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/api/auth.ts | 48-55 |
| isDevBypassEmail | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/api/auth.ts | 62-64 |
| devLogin | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/api/auth.ts | 69-80 |
| verifyOTP | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/api/auth.ts | 86-103 |
| getCurrentUser | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/api/auth.ts | 108-120 |
| logout | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/api/auth.ts | 125-133 |
| hasSession | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/api/auth.ts | 138-140 |
| checkSupervisorStatus | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/api/auth.ts | 145-149 |
| sendSupervisorOTP | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/api/auth.ts | 154-162 |
| verifySupervisorOTP | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/api/auth.ts | 167-181 |
| supervisorSignup | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/api/auth.ts | 186-196 |
| getAccessToken | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/api/client.ts | 14-17 |
| getRefreshToken | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/api/client.ts | 19-22 |
| setTokens | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/api/client.ts | 24-30 |
| clearTokens | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/api/client.ts | 32-37 |
| refreshAccessToken | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/api/client.ts | 43-74 |
| createApiError | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/api/client.ts | 83-88 |
| apiFetch | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/api/client.ts | 94-156 |
| sendEmail | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/email/resend.ts | 25-45 |
| AccessApprovedEmail | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/email/templates/access-approved.tsx | 23-52 |
| AccessRejectedEmail | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/email/templates/access-rejected.tsx | 21-52 |
| AccessRequestConfirmedEmail | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/email/templates/access-request-confirmed.tsx | 21-46 |
| MagicLinkEmail | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/email/templates/magic-link.tsx | 27-54 |
| NotificationEmail | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/email/templates/notification.tsx | 26-49 |
| useSubjects | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/hooks/use-subjects.ts | 21-62 |
| fetchSubjects | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/hooks/use-subjects.ts | 34-52 |
| key | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/i18n/context.tsx | 17-17 |
| I18nProvider | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/i18n/context.tsx | 26-73 |
| useI18n | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/i18n/context.tsx | 78-80 |
| generatePageMetadata | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/metadata.ts | 95-113 |
| isPushSupported | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/notifications/push.ts | 19-25 |
| getPermissionStatus | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/notifications/push.ts | 30-35 |
| requestNotificationPermission | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/notifications/push.ts | 40-47 |
| registerServiceWorker | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/notifications/push.ts | 52-72 |
| subscribeToPush | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/notifications/push.ts | 78-118 |
| unsubscribeFromPush | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/notifications/push.ts | 123-140 |
| getPushSubscription | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/notifications/push.ts | 145-157 |
| savePushSubscription | Function | /Volumes/Crucial X9/AssignX/superviser-web/lib/notifications/push.ts | 162-175 |

*... and 31 more members.*

## Execution Flows

- **RegisterPage** (criticality: 0.96, depth: 6)
- **SupportPage** (criticality: 0.96, depth: 6)
- **LoginPage** (criticality: 0.95, depth: 5)
- **DashboardLayoutV2** (criticality: 0.95, depth: 5)
- **NotificationsPage** (criticality: 0.95, depth: 5)
- **ResourcesPage** (criticality: 0.95, depth: 5)
- **SettingsPage** (criticality: 0.95, depth: 5)
- **ChatRoomPage** (criticality: 0.94, depth: 4)
- **ChatPage** (criticality: 0.94, depth: 4)
- **DashboardPage** (criticality: 0.94, depth: 4)
- *... and 43 more flows.*

## Dependencies

### Outgoing

- `Text` (17 edge(s))
- `trim` (14 edge(s))
- `split` (13 edge(s))
- `filter` (12 edge(s))
- `max` (10 edge(s))
- `log` (9 edge(s))
- `stringify` (9 edge(s))
- `round` (8 edge(s))
- `forEach` (8 edge(s))
- `error` (7 edge(s))
- `toLowerCase` (7 edge(s))
- `min` (7 edge(s))
- `removeItem` (5 edge(s))
- `startsWith` (5 edge(s))
- `Html` (5 edge(s))

### Incoming

- `/Volumes/Crucial X9/AssignX/superviser-web/lib/services/content-analysis.ts` (27 edge(s))
- `/Volumes/Crucial X9/AssignX/superviser-web/lib/api/auth.ts` (13 edge(s))
- `/Volumes/Crucial X9/AssignX/superviser-web/lib/notifications/push.ts` (11 edge(s))
- `/Volumes/Crucial X9/AssignX/superviser-web/lib/analytics.ts` (10 edge(s))
- `/Volumes/Crucial X9/AssignX/superviser-web/components/chat/message-list.tsx::MessageBubble` (9 edge(s))
- `/Volumes/Crucial X9/AssignX/superviser-web/components/projects/v2/project-stat-card.tsx::ProjectStatCard` (8 edge(s))
- `/Volumes/Crucial X9/AssignX/superviser-web/components/projects/v2/project-status-pills.tsx::ProjectStatusPills` (8 edge(s))
- `/Volumes/Crucial X9/AssignX/superviser-web/lib/api/client.ts` (7 edge(s))
- `/Volumes/Crucial X9/AssignX/superviser-web/components/earnings/earnings-summary-v2.tsx::EarningsSummaryV2` (7 edge(s))
- `/Volumes/Crucial X9/AssignX/superviser-web/components/support/ticket-detail.tsx::TicketDetail` (7 edge(s))
- `/Volumes/Crucial X9/AssignX/superviser-web/components/support/ticket-list.tsx::TicketList` (7 edge(s))
- `/Volumes/Crucial X9/AssignX/superviser-web/components/dashboard/ready-to-assign-card-v2.tsx::ReadyToAssignCardV2` (6 edge(s))
- `/Volumes/Crucial X9/AssignX/superviser-web/components/dashboard/request-card-v2.tsx::RequestCardV2` (6 edge(s))
- `/Volumes/Crucial X9/AssignX/superviser-web/components/ui/chart.tsx::ChartTooltipContent` (6 edge(s))
- `/Volumes/Crucial X9/AssignX/superviser-web/hooks/use-notifications.ts::useNotifications` (5 edge(s))
