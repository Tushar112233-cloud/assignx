# AssignX Architecture Documentation

## Overview

AssignX User Web is a Next.js 16 application built with React 19, TypeScript, and Tailwind CSS. It provides a platform for students and professionals to submit academic projects, connect with tutors, and access various educational services.

## Tech Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| Next.js | 16.1.1 | React framework with App Router |
| React | 19.0.0 | UI library |
| TypeScript | 5.x | Type safety |
| Tailwind CSS | 4.x | Styling |
| Zustand | 5.x | State management |
| Supabase | - | Backend as a Service |
| React Hook Form | 7.x | Form handling |
| Zod | 3.x | Schema validation |
| Framer Motion | 12.x | Animations |
| date-fns | 4.x | Date utilities |
| Lucide React | - | Icons |
| shadcn/ui | - | UI components |

## Project Structure

```
user-web/
├── app/                      # Next.js App Router pages
│   ├── (auth)/              # Auth route group (login, signup, onboarding)
│   │   ├── layout.tsx       # Auth layout (no sidebar)
│   │   ├── login/
│   │   ├── onboarding/
│   │   └── signup/
│   ├── (dashboard)/         # Dashboard route group (protected)
│   │   ├── layout.tsx       # Dashboard layout with sidebar
│   │   ├── home/
│   │   ├── projects/
│   │   ├── connect/
│   │   ├── profile/
│   │   ├── settings/
│   │   └── support/
│   ├── auth/
│   │   └── callback/        # OAuth callback handler
│   ├── project/[id]/        # Dynamic project detail
│   ├── projects/new/        # New project wizard
│   └── services/            # Service pages
├── components/              # React components
│   ├── add-project/         # Project creation components
│   ├── auth/                # Authentication components
│   ├── connect/             # Student Connect/Marketplace
│   ├── dashboard/           # Dashboard components
│   ├── profile/             # Profile settings components
│   ├── project-detail/      # Project detail view
│   ├── projects/            # Projects list components
│   ├── settings/            # Settings page components
│   ├── shared/              # Shared utilities
│   ├── support/             # Support page components
│   └── ui/                  # shadcn/ui primitives
├── lib/                     # Utilities and configurations
│   ├── actions/             # Server actions
│   ├── data/                # Mock data files
│   ├── supabase/            # Supabase client setup
│   └── validations/         # Zod schemas
├── stores/                  # Zustand state stores
├── types/                   # TypeScript type definitions
├── public/                  # Static assets
└── docs/                    # Documentation
```

## Route Groups

### Auth Group `(auth)`
- No sidebar navigation
- Centered layouts for auth flows
- Routes: `/login`, `/signup/*`, `/onboarding`

### Dashboard Group `(dashboard)`
- Sidebar navigation (desktop)
- Bottom navigation (mobile)
- Protected routes requiring authentication
- Routes: `/home`, `/projects`, `/connect`, `/profile`, `/settings`, `/support`

## Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         User Interface                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐ │
│  │  Components │  │   Pages     │  │  UI Components (shadcn) │ │
│  └──────┬──────┘  └──────┬──────┘  └────────────┬────────────┘ │
│         │                │                       │              │
│         └────────────────┼───────────────────────┘              │
│                          │                                       │
│  ┌───────────────────────▼───────────────────────────────────┐  │
│  │                   Zustand Stores                           │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────┐  │  │
│  │  │  User    │ │  Project │ │  Wallet  │ │ Notification │  │  │
│  │  │  Store   │ │  Store   │ │  Store   │ │    Store     │  │  │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────────┘  │  │
│  └───────────────────────┬───────────────────────────────────┘  │
│                          │                                       │
│  ┌───────────────────────▼───────────────────────────────────┐  │
│  │                   Server Actions                           │  │
│  │  ┌──────────────────────────────────────────────────────┐ │  │
│  │  │  auth.ts - signIn, signOut, createProfile            │ │  │
│  │  └──────────────────────────────────────────────────────┘ │  │
│  └───────────────────────┬───────────────────────────────────┘  │
│                          │                                       │
└──────────────────────────┼───────────────────────────────────────┘
                           │
┌──────────────────────────▼───────────────────────────────────────┐
│                        Supabase                                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐   │
│  │    Auth     │  │  Database   │  │       Storage           │   │
│  │   (OAuth)   │  │ (Postgres)  │  │  (File uploads)         │   │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘   │
└───────────────────────────────────────────────────────────────────┘
```

## Component Architecture

### Module Pattern
Each feature module follows this structure:
```
components/{module}/
├── index.ts           # Barrel exports
├── {component}.tsx    # Main components
└── {subcomponent}/    # Sub-components (if > 400 lines)
```

### Component Guidelines
1. **Single Responsibility**: Each component handles one concern
2. **JSDoc Comments**: All components have documentation
3. **Props Interface**: TypeScript interfaces for all props
4. **File Size Limit**: Components under 400 lines (refactored if larger)
5. **Barrel Exports**: Each module has an index.ts for clean imports

## Authentication Flow

```
┌────────────┐     ┌────────────┐     ┌────────────┐
│   Login    │────▶│   Google   │────▶│  Callback  │
│   Page     │     │   OAuth    │     │   Route    │
└────────────┘     └────────────┘     └─────┬──────┘
                                            │
                   ┌────────────────────────┼────────────────────────┐
                   │                        ▼                        │
                   │  ┌──────────────────────────────────────────┐  │
                   │  │         Check Profile Exists?             │  │
                   │  └────────────────┬─────────────────────────┘  │
                   │                   │                             │
              ┌────┴────┐         ┌────┴────┐                       │
              │   Yes   │         │   No    │                       │
              └────┬────┘         └────┬────┘                       │
                   │                   │                             │
              ┌────▼────┐         ┌────▼────┐                       │
              │  /home  │         │/onboard │                       │
              └─────────┘         └─────────┘                       │
                                                                     │
└────────────────────────────────────────────────────────────────────┘
```

## Environment Variables

```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=your-supabase-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key

# Site
NEXT_PUBLIC_SITE_URL=http://localhost:3000
```

## Performance Considerations

1. **Code Splitting**: Automatic via Next.js App Router
2. **Image Optimization**: Next.js Image component
3. **State Persistence**: User store persisted to localStorage
4. **Memoization**: useMemo for filtered lists
5. **Lazy Loading**: Dynamic imports where appropriate

## Security

1. **Server Actions**: Sensitive operations on server
2. **Supabase RLS**: Row Level Security on database
3. **OAuth Only**: No password storage
4. **CSRF Protection**: Built into Next.js
5. **Input Validation**: Zod schemas for all forms
