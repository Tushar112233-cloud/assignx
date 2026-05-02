# lib-user

## Overview

Directory-based community: doer-web/lib

- **Size**: 56 nodes
- **Cohesion**: 0.0467
- **Dominant Language**: typescript

## Members

| Name | Kind | File | Lines |
|------|------|------|-------|
| getStoredUser | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/api/auth.ts | 22-31 |
| storeUser | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/api/auth.ts | 33-40 |
| clearStoredUser | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/api/auth.ts | 42-49 |
| isDevBypassEmail | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/api/auth.ts | 54-56 |
| devLogin | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/api/auth.ts | 58-74 |
| sendOTP | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/api/auth.ts | 77-87 |
| verifyOTP | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/api/auth.ts | 90-106 |
| doerSignup | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/api/auth.ts | 109-120 |
| checkAccessStatus | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/api/auth.ts | 123-131 |
| logout | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/api/auth.ts | 133-141 |
| getCurrentUser | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/api/auth.ts | 143-150 |
| getTokens | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/api/client.ts | 3-9 |
| setTokens | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/api/client.ts | 11-14 |
| clearTokens | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/api/client.ts | 16-19 |
| getAccessToken | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/api/client.ts | 21-24 |
| refreshAccessToken | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/api/client.ts | 29-58 |
| apiClient | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/api/client.ts | 64-117 |
| apiUpload | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/api/client.ts | 119-132 |
| AuthenticationError | Class | /Volumes/Crucial X9/AssignX/doer-web/lib/auth-helpers.ts | 9-14 |
| constructor | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/auth-helpers.ts | 10-13 |
| ForbiddenError | Class | /Volumes/Crucial X9/AssignX/doer-web/lib/auth-helpers.ts | 16-21 |
| constructor | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/auth-helpers.ts | 17-20 |
| NotFoundError | Class | /Volumes/Crucial X9/AssignX/doer-web/lib/auth-helpers.ts | 23-28 |
| constructor | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/auth-helpers.ts | 24-27 |
| getAuthenticatedUser | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/auth-helpers.ts | 34-46 |
| verifyDoerOwnership | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/auth-helpers.ts | 52-54 |
| verifyProjectAccess | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/auth-helpers.ts | 56-58 |
| getAuthenticatedDoer | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/auth-helpers.ts | 60-63 |
| sendEmail | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/email/resend.ts | 16-36 |
| validateFile | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/file-validation.ts | 58-128 |
| generateSafeFileName | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/file-validation.ts | 136-146 |
| formatFileSize | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/file-validation.ts | 153-161 |
| useSubjects | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/hooks/use-subjects.ts | 21-62 |
| fetchSubjects | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/hooks/use-subjects.ts | 34-52 |
| key | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/i18n/context.tsx | 17-17 |
| I18nProvider | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/i18n/context.tsx | 26-73 |
| useI18n | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/i18n/context.tsx | 78-80 |
| sanitize | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/logger.ts | 12-20 |
| debug | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/logger.ts | 30-36 |
| arg | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/logger.ts | 62-68 |
| info | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/logger.ts | 41-47 |
| warn | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/logger.ts | 52-55 |
| error | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/logger.ts | 61-70 |
| calculateQuizScore | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/quiz-utils.ts | 20-42 |
| isQuizPassed | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/quiz-utils.ts | 50-52 |
| isAnswerCorrect | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/quiz-utils.ts | 60-66 |
| getRemainingAttempts | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/quiz-utils.ts | 74-76 |
| getTrainingModules | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/services/training.ts | 3-16 |
| getTrainingProgress | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/services/training.ts | 18-26 |
| markModuleComplete | Function | /Volumes/Crucial X9/AssignX/doer-web/lib/services/training.ts | 28-35 |

*... and 6 more members.*

## Execution Flows

- **QuizPage** (criticality: 0.95, depth: 5)
- **TrainingPage** (criticality: 0.95, depth: 5)
- **RegisterPage** (criticality: 0.95, depth: 5)
- **MainLayout** (criticality: 0.95, depth: 5)
- **ProfileSetupPage** (criticality: 0.95, depth: 5)
- **MainLayout** (criticality: 0.95, depth: 5)
- **LoginPage** (criticality: 0.94, depth: 4)
- **DashboardPage** (criticality: 0.94, depth: 4)
- **BankDetailsPage** (criticality: 0.93, depth: 3)
- **ProfilePage** (criticality: 0.93, depth: 3)
- *... and 25 more flows.*

## Dependencies

### Outgoing

- `setItem` (8 edge(s))
- `stringify` (7 edge(s))
- `includes` (7 edge(s))
- `removeItem` (5 edge(s))
- `getItem` (5 edge(s))
- `useState` (5 edge(s))
- `map` (5 edge(s))
- `startsWith` (4 edge(s))
- `toLowerCase` (3 edge(s))
- `fetch` (3 edge(s))
- `json` (3 edge(s))
- `split` (3 edge(s))
- `toString` (3 edge(s))
- `useCallback` (3 edge(s))
- `useEffect` (3 edge(s))

### Incoming

- `/Volumes/Crucial X9/AssignX/doer-web/lib/api/auth.ts` (11 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/components/reviews/ReviewCard.tsx::ReviewCard` (10 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/components/help/FAQSection.tsx::FAQSection` (9 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/components/onboarding/ProfileSetupForm.tsx::ProfileSetupForm` (9 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/components/app-sidebar.tsx::AppSidebar` (8 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/lib/logger.ts` (8 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/components/projects/WorkspaceView.tsx::WorkspaceView` (8 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/components/projects/redesign/FilterControls.tsx::FilterControls` (8 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/lib/api/client.ts` (7 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/lib/auth-helpers.ts` (7 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/components/projects/MetricsDashboard.tsx::MetricCard` (7 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/components/projects/redesign/ProjectCard.tsx::ProjectCard` (7 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/components/reviews/AchievementCards.tsx::AchievementCards` (7 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/components/landing/navigation.tsx::Navigation` (6 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/components/dashboard/ProjectCard.tsx::ProjectCard` (6 edge(s))
