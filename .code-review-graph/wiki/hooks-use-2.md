# hooks-use

## Overview

Directory-based community: doer-web/hooks

- **Size**: 27 nodes
- **Cohesion**: 0.0106
- **Dominant Language**: typescript

## Members

| Name | Kind | File | Lines |
|------|------|------|-------|
| useIsMobile | Function | /Volumes/Crucial X9/AssignX/doer-web/hooks/use-mobile.ts | 5-19 |
| onChange | Function | /Volumes/Crucial X9/AssignX/doer-web/hooks/use-mobile.ts | 10-12 |
| useActivation | Function | /Volumes/Crucial X9/AssignX/doer-web/hooks/useActivation.ts | 79-377 |
| loadActivation | Function | /Volumes/Crucial X9/AssignX/doer-web/hooks/useActivation.ts | 316-346 |
| useAuth | Function | /Volumes/Crucial X9/AssignX/doer-web/hooks/useAuth.ts | 16-224 |
| initAuth | Function | /Volumes/Crucial X9/AssignX/doer-web/hooks/useAuth.ts | 72-140 |
| handleStorageChange | Function | /Volumes/Crucial X9/AssignX/doer-web/hooks/useAuth.ts | 160-168 |
| signUp | Function | /Volumes/Crucial X9/AssignX/doer-web/hooks/useAuth.ts | 174-178 |
| signIn | Function | /Volumes/Crucial X9/AssignX/doer-web/hooks/useAuth.ts | 180-183 |
| signOut | Function | /Volumes/Crucial X9/AssignX/doer-web/hooks/useAuth.ts | 185-201 |
| sendPhoneOtp | Function | /Volumes/Crucial X9/AssignX/doer-web/hooks/useAuth.ts | 203-205 |
| verifyPhoneOtp | Function | /Volumes/Crucial X9/AssignX/doer-web/hooks/useAuth.ts | 207-209 |
| useAuthToken | Function | /Volumes/Crucial X9/AssignX/doer-web/hooks/useAuthToken.ts | 22-87 |
| validateToken | Function | /Volumes/Crucial X9/AssignX/doer-web/hooks/useAuthToken.ts | 34-66 |
| hasAuthToken | Function | /Volumes/Crucial X9/AssignX/doer-web/hooks/useAuthToken.ts | 89-91 |
| getAuthToken | Function | /Volumes/Crucial X9/AssignX/doer-web/hooks/useAuthToken.ts | 93-95 |
| useChat | Function | /Volumes/Crucial X9/AssignX/doer-web/hooks/useChat.ts | 212-242 |
| useNotifications | Function | /Volumes/Crucial X9/AssignX/doer-web/hooks/useNotifications.ts | 32-125 |
| prev | Function | /Volumes/Crucial X9/AssignX/doer-web/hooks/useNotifications.ts | 105-105 |
| n | Function | /Volumes/Crucial X9/AssignX/doer-web/hooks/useNotifications.ts | 74-74 |
| handleNew | Function | /Volumes/Crucial X9/AssignX/doer-web/hooks/useNotifications.ts | 89-108 |
| useProjectSubscription | Function | /Volumes/Crucial X9/AssignX/doer-web/hooks/useProjectSubscription.ts | 20-71 |
| handleProjectUpdate | Function | /Volumes/Crucial X9/AssignX/doer-web/hooks/useProjectSubscription.ts | 39-47 |
| handleProjectAssigned | Function | /Volumes/Crucial X9/AssignX/doer-web/hooks/useProjectSubscription.ts | 49-52 |
| useNewProjectsSubscription | Function | /Volumes/Crucial X9/AssignX/doer-web/hooks/useProjectSubscription.ts | 73-100 |
| handleNewProject | Function | /Volumes/Crucial X9/AssignX/doer-web/hooks/useProjectSubscription.ts | 88-92 |
| updateProjectInList | Function | /Volumes/Crucial X9/AssignX/doer-web/hooks/useProjects.ts | 231-232 |

## Execution Flows

- **QuizPage** (criticality: 0.95, depth: 5)
- **MainLayout** (criticality: 0.95, depth: 5)
- **ProfileSetupPage** (criticality: 0.95, depth: 5)
- **MainLayout** (criticality: 0.95, depth: 5)
- **DashboardPage** (criticality: 0.94, depth: 4)
- **BankDetailsPage** (criticality: 0.93, depth: 3)
- **ProfilePage** (criticality: 0.93, depth: 3)
- **ProjectWorkspacePage** (criticality: 0.93, depth: 3)
- **ResourcesPage** (criticality: 0.93, depth: 3)
- **ReviewsPage** (criticality: 0.93, depth: 3)
- *... and 6 more flows.*

## Dependencies

### Outgoing

- `current` (19 edge(s))
- `useCallback` (18 edge(s))
- `toISOString` (13 edge(s))
- `useRef` (13 edge(s))
- `useEffect` (12 edge(s))
- `useState` (8 edge(s))
- `startsWith` (8 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/lib/api/client.ts::getAccessToken` (7 edge(s))
- `map` (7 edge(s))
- `debug` (6 edge(s))
- `off` (6 edge(s))
- `error` (5 edge(s))
- `setActivation` (5 edge(s))
- `setHasToken` (5 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/lib/api/client.ts::apiClient` (4 edge(s))

### Incoming

- `/Volumes/Crucial X9/AssignX/doer-web/hooks/useNotifications.ts` (9 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/hooks/useAuth.ts` (8 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/hooks/useProjectSubscription.ts` (5 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/hooks/useAuthToken.ts` (4 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/app/(main)/dashboard/dashboard-client.tsx::DashboardClient` (3 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/hooks/useProjects.ts` (3 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/hooks/use-mobile.ts` (2 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/hooks/useActivation.ts` (2 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/components/ui/sidebar.tsx::SidebarProvider` (1 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/app/(activation)/bank-details/page.tsx::BankDetailsPage` (1 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/app/(main)/layout.tsx::MainLayout` (1 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/app/(main)/profile/page.tsx::ProfilePage` (1 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/app/(main)/projects/[id]/page.tsx::ProjectWorkspacePage` (1 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/app/(main)/projects/page.tsx::ProjectsPage` (1 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/app/(main)/resources/page.tsx::ResourcesPage` (1 edge(s))
