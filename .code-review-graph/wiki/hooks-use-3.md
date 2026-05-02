# hooks-use

## Overview

Directory-based community: user-web/hooks

- **Size**: 19 nodes
- **Cohesion**: 0.0259
- **Dominant Language**: typescript

## Members

| Name | Kind | File | Lines |
|------|------|------|-------|
| useMinimumLoadingTime | Function | /Volumes/Crucial X9/AssignX/user-web/hooks/use-minimum-loading-time.ts | 18-60 |
| useReducedMotion | Function | /Volumes/Crucial X9/AssignX/user-web/hooks/use-reduced-motion.ts | 9-25 |
| handleChange | Function | /Volumes/Crucial X9/AssignX/user-web/hooks/use-reduced-motion.ts | 16-18 |
| useStaggeredReveal | Function | /Volumes/Crucial X9/AssignX/user-web/hooks/use-staggered-reveal.ts | 17-55 |
| useUserPreferences | Function | /Volumes/Crucial X9/AssignX/user-web/hooks/use-user-preferences.ts | 57-172 |
| loadPreferences | Function | /Volumes/Crucial X9/AssignX/user-web/hooks/use-user-preferences.ts | 70-89 |
| useChat | Function | /Volumes/Crucial X9/AssignX/user-web/hooks/useChat.ts | 22-225 |
| initChat | Function | /Volumes/Crucial X9/AssignX/user-web/hooks/useChat.ts | 44-107 |
| m | Function | /Volumes/Crucial X9/AssignX/user-web/hooks/useChat.ts | 84-84 |
| useModeration | Function | /Volumes/Crucial X9/AssignX/user-web/hooks/useModeration.ts | 111-296 |
| useContentValidation | Function | /Volumes/Crucial X9/AssignX/user-web/hooks/useModeration.ts | 324-350 |
| useModerationStatus | Function | /Volumes/Crucial X9/AssignX/user-web/hooks/useModeration.ts | 362-396 |
| useContentMonitor | Function | /Volumes/Crucial X9/AssignX/user-web/hooks/useModeration.ts | 409-457 |
| urlBase64ToUint8Array | Function | /Volumes/Crucial X9/AssignX/user-web/hooks/useNotifications.ts | 27-37 |
| useNotifications | Function | /Volumes/Crucial X9/AssignX/user-web/hooks/useNotifications.ts | 43-332 |
| loadNotifications | Function | /Volumes/Crucial X9/AssignX/user-web/hooks/useNotifications.ts | 73-109 |
| checkPushStatus | Function | /Volumes/Crucial X9/AssignX/user-web/hooks/useNotifications.ts | 128-136 |
| usePayment | Function | /Volumes/Crucial X9/AssignX/user-web/hooks/usePayment.ts | 26-275 |
| getErrorMessage | Function | /Volumes/Crucial X9/AssignX/user-web/hooks/usePayment.ts | 280-296 |

## Execution Flows

- **ProfilePage** (criticality: 0.96, depth: 6)
- **WalletPage** (criticality: 0.96, depth: 6)
- **ProjectDetailPage** (criticality: 0.95, depth: 5)
- **SettingsPage** (criticality: 0.95, depth: 5)
- **FloatingChatButton** (criticality: 0.95, depth: 5)
- **ProjectsDashboard** (criticality: 0.92, depth: 2)
- **NotificationPanel** (criticality: 0.92, depth: 2)

## Dependencies

### Outgoing

- `setState` (55 edge(s))
- `error` (30 edge(s))
- `useCallback` (29 edge(s))
- `useState` (19 edge(s))
- `useEffect` (10 edge(s))
- `useRef` (7 edge(s))
- `setTimeout` (7 edge(s))
- `clearTimeout` (6 edge(s))
- `setIsLoading` (4 edge(s))
- `map` (4 edge(s))
- `success` (4 edge(s))
- `String` (4 edge(s))
- `/Volumes/Crucial X9/AssignX/user-web/lib/retry.ts::generateIdempotencyKey` (4 edge(s))
- `has` (4 edge(s))
- `warning` (4 edge(s))

### Incoming

- `/Volumes/Crucial X9/AssignX/user-web/hooks/useModeration.ts` (4 edge(s))
- `/Volumes/Crucial X9/AssignX/user-web/hooks/useNotifications.ts` (4 edge(s))
- `/Volumes/Crucial X9/AssignX/user-web/components/skeletons/page-skeleton-provider.tsx::PageSkeletonProvider` (3 edge(s))
- `/Volumes/Crucial X9/AssignX/user-web/hooks/useChat.ts` (3 edge(s))
- `/Volumes/Crucial X9/AssignX/user-web/hooks/use-reduced-motion.ts` (2 edge(s))
- `/Volumes/Crucial X9/AssignX/user-web/hooks/use-user-preferences.ts` (2 edge(s))
- `/Volumes/Crucial X9/AssignX/user-web/hooks/usePayment.ts` (2 edge(s))
- `/Volumes/Crucial X9/AssignX/user-web/hooks/use-minimum-loading-time.ts` (1 edge(s))
- `/Volumes/Crucial X9/AssignX/user-web/components/layout/content-grid.tsx::ContentGrid` (1 edge(s))
- `/Volumes/Crucial X9/AssignX/user-web/components/layout/hero-section.tsx::HeroSection` (1 edge(s))
- `/Volumes/Crucial X9/AssignX/user-web/components/layout/masonry-grid.tsx::MasonryGrid` (1 edge(s))
- `/Volumes/Crucial X9/AssignX/user-web/components/layout/page-layout.tsx::PageLayout` (1 edge(s))
- `/Volumes/Crucial X9/AssignX/user-web/components/layout/page-section.tsx::PageSection` (1 edge(s))
- `/Volumes/Crucial X9/AssignX/user-web/components/layout/quick-actions-bar.tsx::QuickActionsBar` (1 edge(s))
- `/Volumes/Crucial X9/AssignX/user-web/components/layout/stats-row.tsx::StatsRow` (1 edge(s))
