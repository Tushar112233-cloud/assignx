# AdminX - Supervisor Panel

> Quality Control Hub for AssignX Academic Services Platform

[![Next.js](https://img.shields.io/badge/Next.js-16-black?logo=next.js)](https://nextjs.org/)
[![React](https://img.shields.io/badge/React-19-61DAFB?logo=react)](https://react.dev/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.8-3178C6?logo=typescript)](https://www.typescriptlang.org/)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind-4.0-06B6D4?logo=tailwindcss)](https://tailwindcss.com/)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3FCF8E?logo=supabase)](https://supabase.com/)

## Overview

AdminX is the supervisor panel for the AssignX platform, enabling supervisors to manage academic projects, coordinate with doers (experts), handle quality control, and track earnings.

### Key Features

- **Project Management** - Quote analysis, doer assignment, progress tracking
- **Quality Control** - Review submissions, request revisions, approve deliverables
- **Doer Coordination** - Manage expert pool, track performance, handle blacklisting
- **Real-time Chat** - Communicate with clients and doers
- **Earnings Dashboard** - Track commissions, view payment history
- **Training & Activation** - Onboarding flow with video training and certification quiz

## Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Next.js 16 (App Router) |
| Language | TypeScript 5.8 |
| UI | React 19, Tailwind CSS 4, shadcn/ui |
| Backend | Supabase (Auth, Database, Realtime, Storage) |
| State | Zustand, React Query |
| Forms | React Hook Form, Zod |
| Charts | Recharts |
| Animations | Framer Motion |

## Getting Started

### Prerequisites

- Node.js 20+
- npm or pnpm
- Supabase project

### Installation

```bash
# Clone the repository
git clone https://github.com/your-org/superviser-web.git
cd superviser-web

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env.local
```

### Environment Variables

```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key

# App
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

### Development

```bash
# Start development server
npm run dev

# Run linting
npm run lint

# Run type checking
npm run type-check

# Build for production
npm run build
```

## Project Structure

```
superviser-web/
├── app/                    # Next.js App Router pages
│   ├── (auth)/            # Authentication pages
│   ├── (activation)/      # Activation flow pages
│   ├── (dashboard)/       # Protected dashboard pages
│   └── api/               # API routes
├── components/            # React components
│   ├── ui/               # shadcn/ui components
│   ├── layout/           # Layout components
│   ├── dashboard/        # Dashboard widgets
│   ├── projects/         # Project management
│   ├── chat/             # Chat components
│   ├── doers/            # Doer management
│   ├── earnings/         # Earnings & payments
│   └── ...               # Feature-specific components
├── hooks/                # Custom React hooks
├── lib/                  # Utilities & configurations
│   ├── supabase/        # Supabase client setup
│   └── mock-data/       # Development mock data
├── store/               # Zustand state management
├── types/               # TypeScript type definitions
└── docs/                # Documentation
```

## Documentation

Detailed documentation is available in the `/docs` directory:

- [Architecture Overview](./docs/ARCHITECTURE.md) - System design and patterns
- [API Reference](./docs/API.md) - Supabase integration and database schema
- [Components](./docs/COMPONENTS.md) - Component library reference
- [Pages](./docs/PAGES.md) - Route structure and page documentation
- [Hooks](./docs/HOOKS.md) - Custom React hooks
- [Utilities](./docs/UTILS.md) - Helper functions and configurations

## Features

### Dashboard
- Overview statistics (active projects, pending requests, earnings)
- New project requests requiring quotes
- Projects ready for doer assignment
- Recent activity feed

### Projects
- Tabbed view: All, Ongoing, For Review, Completed
- Search and filter capabilities
- QC review workflow with approve/revision actions
- Project detail sheets

### Chat
- Real-time messaging with clients and doers
- File attachment support
- Project context integration
- Unread message indicators

### Doers
- Expert pool management
- Performance metrics and ratings
- Availability tracking
- Blacklist management

### Earnings
- Earnings overview with charts
- Transaction history ledger
- Commission breakdown
- CSV export

### Resources
- Plagiarism checker tool
- AI content detector
- Pricing guide and calculator
- Training video library

## Authentication Flow

1. **Registration** - New supervisors create account
2. **Onboarding** - Complete professional profile and banking details
3. **Verification** - Admin reviews and approves application
4. **Activation** - Complete training videos and pass certification quiz
5. **Dashboard Access** - Full access to supervisor features

## Development Guidelines

### Code Style

- Use TypeScript strict mode
- Follow React hooks best practices
- Use JSDoc comments for all exports
- Keep component files under 400 lines

### Component Structure

```tsx
/**
 * @fileoverview Component description.
 * @module components/module/component-name
 */

"use client" // if needed

import { ... } from "..."

interface ComponentProps {
  // props
}

export function Component({ ...props }: ComponentProps) {
  // implementation
}
```

### Commit Convention

```
type(scope): description

feat: new feature
fix: bug fix
refactor: code improvement
docs: documentation
style: formatting
test: testing
chore: maintenance
```

## Scripts

| Script | Description |
|--------|-------------|
| `npm run dev` | Start development server |
| `npm run build` | Build for production |
| `npm run start` | Start production server |
| `npm run lint` | Run ESLint |
| `npm run type-check` | Run TypeScript compiler |

## Contributing

1. Create a feature branch from `master`
2. Make your changes
3. Ensure linting and type-checking pass
4. Submit a pull request

## License

Proprietary - All rights reserved.

---

Built with care by the AssignX Team
