# Architecture Documentation

> **AdminX Supervisor Panel** - System Architecture Overview

## Table of Contents

1. [System Overview](#system-overview)
2. [Technology Stack](#technology-stack)
3. [Directory Structure](#directory-structure)
4. [Data Flow](#data-flow)
5. [Authentication Flow](#authentication-flow)
6. [State Management](#state-management)
7. [API Architecture](#api-architecture)

---

## System Overview

AdminX is a Next.js 16 application designed for supervisors in the AssignX ecosystem. It serves as the quality control hub where supervisors:

- Analyze and quote project requests
- Assign expert doers to projects
- Perform quality control reviews
- Manage communications between users and doers
- Track earnings and performance metrics

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      Client Browser                          │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Next.js 16 App Router                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Pages     │  │  Layouts    │  │  Server Components  │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │ Middleware  │  │  API Routes │  │  Client Components  │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       Supabase                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │  PostgreSQL  │  │     Auth     │  │     Realtime     │   │
│  └──────────────┘  └──────────────┘  └──────────────────┘   │
│  ┌──────────────┐  ┌──────────────┐                         │
│  │   Storage    │  │  Edge Funcs  │                         │
│  └──────────────┘  └──────────────┘                         │
└─────────────────────────────────────────────────────────────┘
```

---

## Technology Stack

### Frontend

| Technology | Version | Purpose |
|------------|---------|---------|
| Next.js | 16.1.1 | React framework with App Router |
| React | 19.2.3 | UI library |
| TypeScript | 5.x | Type safety |
| Tailwind CSS | 4.x | Utility-first styling |
| shadcn/ui | Latest | UI component library (New York style) |

### State Management

| Technology | Purpose |
|------------|---------|
| Zustand | Global client state |
| React Query | Server state & caching |
| React Hook Form | Form state management |

### Backend Services

| Service | Purpose |
|---------|---------|
| Supabase Auth | Authentication & authorization |
| Supabase Database | PostgreSQL database |
| Supabase Realtime | Live subscriptions |
| Supabase Storage | File storage |

### UI Components

| Library | Purpose |
|---------|---------|
| Radix UI | Accessible primitives |
| Lucide React | Icon library |
| Recharts | Data visualization |
| Framer Motion | Animations |
| Sonner | Toast notifications |

---

## Directory Structure

```
superviser-web/
├── app/                      # Next.js App Router
│   ├── (activation)/         # Activation flow pages
│   │   ├── activation/       # Quiz and training
│   │   └── layout.tsx        # Activation layout
│   ├── (auth)/               # Authentication pages
│   │   ├── login/            # Login page
│   │   ├── register/         # Registration page
│   │   ├── onboarding/       # Multi-step onboarding
│   │   └── layout.tsx        # Auth layout
│   ├── (dashboard)/          # Protected dashboard pages
│   │   ├── dashboard/        # Main dashboard
│   │   ├── projects/         # Projects management
│   │   ├── chat/             # Chat rooms
│   │   ├── doers/            # Doer management
│   │   ├── earnings/         # Earnings & payments
│   │   ├── profile/          # User profile
│   │   ├── resources/        # Tools & training
│   │   ├── settings/         # App settings
│   │   ├── support/          # Help & support
│   │   ├── users/            # User management
│   │   ├── notifications/    # Notifications center
│   │   └── layout.tsx        # Dashboard layout with sidebar
│   ├── api/                  # API routes
│   │   └── auth/             # Auth callback handler
│   ├── layout.tsx            # Root layout
│   ├── page.tsx              # Landing/redirect page
│   ├── error.tsx             # Global error boundary
│   └── not-found.tsx         # 404 page
├── components/               # React components
│   ├── activation/           # Activation flow components
│   ├── auth/                 # Auth forms
│   ├── chat/                 # Chat components
│   ├── dashboard/            # Dashboard widgets
│   ├── doers/                # Doer management
│   ├── earnings/             # Earnings components
│   ├── layout/               # Layout components
│   ├── notifications/        # Notification components
│   ├── onboarding/           # Onboarding flow
│   ├── profile/              # Profile components
│   ├── projects/             # Project components
│   ├── providers/            # Context providers
│   ├── resources/            # Resource tools
│   ├── settings/             # Settings components
│   ├── shared/               # Shared components
│   ├── support/              # Support components
│   ├── users/                # User components
│   └── ui/                   # shadcn/ui components
├── hooks/                    # Custom React hooks
├── lib/                      # Utilities & configurations
│   ├── mock-data/            # Development mock data
│   ├── supabase/             # Supabase client setup
│   ├── analytics.ts          # Analytics utilities
│   ├── metadata.ts           # SEO metadata
│   └── utils.ts              # Helper functions
├── store/                    # Zustand stores
├── types/                    # TypeScript definitions
├── public/                   # Static assets
└── docs/                     # Documentation
```

---

## Data Flow

### Request Lifecycle

```
User Action → Component → Hook/Store → Supabase → Database
     ↑                                              │
     └──────────────── Response ←──────────────────┘
```

### State Flow

1. **Server State**: Managed by React Query
   - API data fetching
   - Caching and invalidation
   - Optimistic updates

2. **Client State**: Managed by Zustand
   - UI state (modals, sidebars)
   - User preferences
   - Session data

3. **Form State**: Managed by React Hook Form
   - Form validation (Zod schemas)
   - Error handling
   - Submission state

---

## Authentication Flow

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│    Login     │────▶│   Supabase   │────▶│   Callback   │
│    Page      │     │     Auth     │     │    Route     │
└──────────────┘     └──────────────┘     └──────────────┘
                                                 │
                           ┌─────────────────────┤
                           ▼                     ▼
                    ┌──────────────┐     ┌──────────────┐
                    │  Onboarding  │     │  Dashboard   │
                    │  (New User)  │     │  (Existing)  │
                    └──────────────┘     └──────────────┘
```

### Middleware Protection

The middleware (`middleware.ts`) handles:
- Route protection for authenticated pages
- Redirect unauthenticated users to login
- Session refresh and validation

---

## State Management

### Zustand Store Structure

```typescript
// store/index.ts
interface AppStore {
  // User state
  user: User | null
  setUser: (user: User) => void

  // UI state
  sidebarOpen: boolean
  toggleSidebar: () => void

  // Modal state
  activeModal: string | null
  openModal: (id: string) => void
  closeModal: () => void
}
```

### React Query Configuration

```typescript
// Queries are organized by domain
- useProjects()      // Project data
- useDoers()         // Doer list
- useEarnings()      // Earnings data
- useNotifications() // Notifications
- useChats()         // Chat rooms
```

---

## API Architecture

### Supabase Client Setup

```typescript
// lib/supabase/client.ts - Browser client
// lib/supabase/server.ts - Server client
// lib/supabase/middleware.ts - Middleware client
```

### Data Access Patterns

| Pattern | Use Case |
|---------|----------|
| Direct Query | Simple CRUD operations |
| RPC Functions | Complex business logic |
| Realtime | Live updates (chat, notifications) |
| Storage | File uploads/downloads |

### Security

- Row Level Security (RLS) on all tables
- JWT-based authentication
- Role-based access control
- Input validation with Zod schemas

---

## Performance Optimizations

### Code Splitting

- Dynamic imports for heavy components
- Route-based code splitting via App Router
- Lazy loading for modals and dialogs

### Caching Strategy

- React Query for API response caching
- Static generation for public pages
- Incremental Static Regeneration where applicable

### Image Optimization

- Next.js Image component
- WebP format with fallbacks
- Responsive image sizes

---

## Development Guidelines

### Component Structure

```typescript
// Standard component pattern
"use client" // If client-side interactivity needed

import { ... } from "..." // External imports
import { ... } from "@/..." // Internal imports

interface ComponentProps { ... }

export function Component({ ...props }: ComponentProps) {
  // Hooks
  // State
  // Effects
  // Handlers
  // Render
}
```

### File Naming

- Components: `PascalCase.tsx`
- Utilities: `kebab-case.ts`
- Types: `types.ts` in each module
- Index: `index.ts` for barrel exports

### Code Style

- ESLint for linting
- TypeScript strict mode
- Functional components only
- Custom hooks for logic extraction
