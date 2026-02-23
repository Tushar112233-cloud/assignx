# Architecture Documentation

## Overview

Doer Web is a **Next.js 16** application with **React 19**, using **Supabase** as the backend-as-a-service platform. The architecture follows modern React patterns with a focus on modularity, type safety, and scalability.

---

## Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Framework** | Next.js 16 (App Router) | Full-stack React framework |
| **UI Library** | React 19 | Component-based UI |
| **Language** | TypeScript 5 | Type safety |
| **Styling** | Tailwind CSS 4 | Utility-first CSS |
| **UI Components** | shadcn/ui (New York) | Pre-built components |
| **Backend** | Supabase | PostgreSQL + Auth + Storage + Realtime |
| **State Management** | Zustand | Lightweight global state |
| **Animations** | Framer Motion | Smooth animations |
| **Icons** | Lucide React | Icon library |
| **Forms** | React Hook Form + Zod | Form handling + validation |

---

## Project Structure

```
doer-web/
├── app/                          # Next.js App Router pages
│   ├── layout.tsx               # Root layout with providers
│   ├── page.tsx                 # Home/splash screen
│   ├── (auth)/                  # Auth route group
│   │   ├── layout.tsx          # Auth layout (centered)
│   │   ├── login/page.tsx      # Login page
│   │   └── register/page.tsx   # Registration page
│   ├── (onboarding)/            # Onboarding route group
│   │   ├── layout.tsx          # Onboarding layout
│   │   ├── welcome/page.tsx    # Welcome carousel
│   │   └── profile-setup/page.tsx
│   ├── (activation)/            # Activation route group
│   │   ├── layout.tsx          # Activation gate layout
│   │   ├── training/page.tsx   # Training modules
│   │   ├── quiz/page.tsx       # Activation quiz
│   │   └── bank-details/page.tsx
│   └── (main)/                  # Main app route group
│       ├── layout.tsx          # Main layout (sidebar + header)
│       ├── dashboard/page.tsx  # Dashboard
│       ├── projects/
│       │   ├── page.tsx        # Projects list
│       │   └── [id]/page.tsx   # Project workspace
│       ├── resources/page.tsx  # Resources center
│       ├── profile/page.tsx    # Profile & settings
│       ├── statistics/page.tsx # Stats page
│       └── reviews/page.tsx    # Reviews page
│
├── components/                   # React components
│   ├── ui/                      # shadcn/ui base components
│   │   ├── button.tsx
│   │   ├── card.tsx
│   │   ├── input.tsx
│   │   └── ...
│   ├── providers/               # Context providers
│   │   └── ThemeProvider.tsx
│   ├── shared/                  # Shared components
│   │   ├── Logo.tsx
│   │   └── AvailabilityToggle.tsx
│   ├── layout/                  # Layout components
│   │   ├── Header.tsx
│   │   ├── Sidebar.tsx
│   │   ├── MainLayout.tsx
│   │   └── index.ts
│   ├── onboarding/              # Onboarding components
│   │   ├── SplashScreen.tsx
│   │   ├── OnboardingCarousel.tsx
│   │   ├── RegistrationForm.tsx
│   │   └── ProfileSetupForm.tsx
│   ├── activation/              # Activation components
│   │   ├── ActivationGate.tsx
│   │   ├── TrainingModule.tsx
│   │   ├── QuizComponent.tsx
│   │   ├── BankDetailsForm.tsx
│   │   └── index.ts
│   ├── dashboard/               # Dashboard components
│   │   ├── ProjectCard.tsx
│   │   ├── TaskPoolList.tsx
│   │   ├── AssignedTaskList.tsx
│   │   └── index.ts
│   ├── projects/                # Project components
│   │   ├── FileUpload.tsx
│   │   ├── ChatPanel.tsx
│   │   ├── WorkspaceView.tsx
│   │   ├── ActiveProjectsTab.tsx
│   │   ├── UnderReviewTab.tsx
│   │   ├── CompletedTab.tsx
│   │   ├── RevisionBanner.tsx
│   │   ├── utils.ts            # Shared utilities
│   │   └── index.ts
│   ├── resources/               # Resource components
│   │   ├── ResourcesGrid.tsx
│   │   ├── CitationBuilder.tsx
│   │   ├── FormatTemplates.tsx
│   │   ├── TrainingCenter.tsx
│   │   ├── AIReportGenerator.tsx
│   │   ├── constants.ts        # Shared constants
│   │   └── index.ts
│   └── profile/                 # Profile components
│       ├── Scorecard.tsx
│       ├── EditProfile.tsx
│       ├── BankSettings.tsx
│       ├── EarningsGraph.tsx
│       ├── PaymentHistory.tsx
│       ├── SupportSection.tsx
│       ├── RatingBreakdown.tsx
│       ├── SkillVerification.tsx
│       ├── RequestPayout.tsx
│       ├── constants.ts        # Shared constants/mock data
│       └── index.ts
│
├── services/                     # API service layer
│   ├── auth.service.ts          # Authentication
│   ├── activation.service.ts    # Activation flow
│   ├── project.service.ts       # Project operations
│   ├── chat.service.ts          # Real-time chat
│   ├── resources.service.ts     # Resources & tools
│   ├── profile.service.ts       # Profile (barrel export)
│   ├── skills.service.ts        # Skills management
│   ├── wallet.service.ts        # Wallet operations
│   ├── payouts.service.ts       # Payout requests
│   ├── reviews.service.ts       # Reviews
│   └── support.service.ts       # Support tickets
│
├── hooks/                        # Custom React hooks
│   ├── useAuth.ts               # Authentication hook
│   ├── useActivation.ts         # Activation state hook
│   ├── useProjects.ts           # Projects Zustand store
│   └── useChat.ts               # Chat hook
│
├── stores/                       # Zustand stores
│   ├── authStore.ts             # Auth state
│   └── uiStore.ts               # UI state (sidebar, theme)
│
├── types/                        # TypeScript types
│   ├── database.ts              # Barrel export for all types
│   ├── common.types.ts          # Base types & enums
│   ├── profile.types.ts         # Profile, Doer, Skills
│   ├── activation.types.ts      # Training, Quiz
│   ├── project.types.ts         # Projects, Deliverables
│   ├── chat.types.ts            # Chat, Messages
│   ├── finance.types.ts         # Wallet, Transactions
│   ├── support.types.ts         # Support tickets
│   └── resources.types.ts       # Citations, Templates
│
├── lib/                          # Utilities
│   ├── utils.ts                 # General utilities (cn)
│   ├── constants.ts             # App constants
│   └── supabase/                # Supabase configuration
│       ├── client.ts            # Browser client
│       ├── server.ts            # Server client
│       └── middleware.ts        # Auth middleware
│
└── docs/                         # Documentation
    ├── API.md
    ├── ARCHITECTURE.md
    ├── COMPONENTS.md
    ├── PAGES.md
    └── README.md
```

---

## Architectural Patterns

### 1. Route Groups (App Router)

Next.js App Router uses **route groups** (parentheses folders) to organize routes without affecting URL structure:

```
(auth)/login → /login
(main)/dashboard → /dashboard
```

Each group has its own layout for shared UI patterns.

### 2. Service Layer Pattern

All Supabase operations go through service modules:

```typescript
// Component
import { getDoerProjects } from '@/services/project.service'

// Usage
const projects = await getDoerProjects(doerId, { status: 'in_progress' })
```

Benefits:
- Centralized API logic
- Easy to mock for testing
- Consistent error handling

### 3. Zustand State Management

Global state is managed with Zustand stores:

```typescript
// stores/authStore.ts
export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  isLoading: true,
  setUser: (user) => set({ user }),
}))
```

Used for:
- Authentication state
- UI state (sidebar, modals)
- Project state (via hooks)

### 4. Component Composition

Components follow the **composition pattern**:

```
Page → Layout → Feature Component → UI Components
```

Example:
```
DashboardPage
  └── MainLayout
       ├── Header
       ├── Sidebar
       └── AssignedTaskList
            └── ProjectCard
                 ├── Card (shadcn)
                 ├── Badge (shadcn)
                 └── Button (shadcn)
```

### 5. Barrel Exports

Each component folder has an `index.ts` for clean imports:

```typescript
// components/dashboard/index.ts
export * from './ProjectCard'
export * from './TaskPoolList'
export * from './AssignedTaskList'

// Usage
import { ProjectCard, TaskPoolList } from '@/components/dashboard'
```

---

## Data Flow

### Authentication Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Login Form │────▶│ Auth Service│────▶│  Supabase   │
└─────────────┘     └─────────────┘     │    Auth     │
                          │              └─────────────┘
                          ▼                     │
                    ┌─────────────┐             │
                    │ Auth Store  │◀────────────┘
                    │  (Zustand)  │
                    └─────────────┘
                          │
                          ▼
                    ┌─────────────┐
                    │ Components  │
                    │ (useAuth)   │
                    └─────────────┘
```

### Project Data Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Dashboard  │────▶│ useProjects │────▶│  Project    │
│    Page     │     │   (Store)   │     │  Service    │
└─────────────┘     └─────────────┘     └─────────────┘
       ▲                   │                   │
       │                   │                   ▼
       │                   │            ┌─────────────┐
       │                   │            │  Supabase   │
       │                   │            │  Database   │
       │                   │            └─────────────┘
       │                   │                   │
       └───────────────────┴───────────────────┘
                     State Update
```

### Real-time Chat Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ Chat Panel  │────▶│Chat Service │────▶│  Supabase   │
└─────────────┘     └─────────────┘     │  Realtime   │
       ▲                                └─────────────┘
       │                                       │
       │          ┌─────────────┐              │
       └──────────│  Websocket  │◀─────────────┘
                  │ Subscription│
                  └─────────────┘
```

---

## User Journey

### New User Flow

```
1. Splash Screen (/)
       ↓
2. Onboarding Carousel (/welcome)
       ↓
3. Registration (/register)
       ↓
4. Profile Setup (/profile-setup)
       ↓
5. Activation Gate
   ├── Training (/training)
   ├── Quiz (/quiz)
   └── Bank Details (/bank-details)
       ↓
6. Dashboard (/dashboard) ← Main App Entry
```

### Returning User Flow

```
1. Login (/login)
       ↓
2. Activation Check
   ├── Not Activated → Activation Gate
   └── Activated → Dashboard (/dashboard)
```

---

## Security Considerations

### Row Level Security (RLS)

Supabase RLS policies ensure data isolation:

```sql
-- Example: Doers can only see their own projects
CREATE POLICY "doers_own_projects" ON projects
  FOR SELECT USING (doer_id = auth.uid());
```

### Authentication Flow

1. JWT tokens managed by Supabase
2. Session stored in HTTP-only cookies
3. Middleware validates sessions on protected routes

### Input Validation

- Zod schemas for form validation
- Server-side validation in services
- Parameterized queries via Supabase SDK

---

## Performance Optimizations

### 1. Code Splitting

Next.js automatically code-splits by route. Each page loads only required JavaScript.

### 2. Image Optimization

```typescript
import Image from 'next/image'
<Image src="/logo.svg" alt="Logo" width={40} height={40} />
```

### 3. Lazy Loading

Components loaded on demand:

```typescript
const HeavyComponent = dynamic(() => import('./HeavyComponent'), {
  loading: () => <Skeleton />
})
```

### 4. Memoization

Prevent unnecessary re-renders:

```typescript
const MemoizedCard = memo(ProjectCard)
```

### 5. Parallel Data Fetching

```typescript
const [project, files, messages] = await Promise.all([
  getProjectById(id),
  getProjectFiles(id),
  getChatMessages(roomId),
])
```

---

## Deployment Architecture

```
┌─────────────────────────────────────────────────────┐
│                    Vercel Edge                       │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐       │
│  │   CDN     │  │   SSR     │  │  API      │       │
│  │  Static   │  │  Render   │  │  Routes   │       │
│  └───────────┘  └───────────┘  └───────────┘       │
└─────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────┐
│                    Supabase                          │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐       │
│  │PostgreSQL │  │   Auth    │  │  Storage  │       │
│  │  Database │  │  Service  │  │  Buckets  │       │
│  └───────────┘  └───────────┘  └───────────┘       │
│  ┌───────────┐  ┌───────────┐                      │
│  │ Realtime  │  │Edge Funcs │                      │
│  │  (Chat)   │  │(Optional) │                      │
│  └───────────┘  └───────────┘                      │
└─────────────────────────────────────────────────────┘
```

---

## Scaling Considerations

### Horizontal Scaling

- Vercel handles automatic scaling
- Supabase connection pooling for database
- Real-time channels scale with Supabase infrastructure

### Caching Strategy

```typescript
// SWR or React Query for data caching
const { data, mutate } = useSWR(`/api/projects/${id}`, fetcher)
```

### Database Optimization

- Proper indexes on frequently queried columns
- Pagination for large datasets
- Connection pooling via Supabase
