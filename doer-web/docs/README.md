# Doer Web Documentation

## Overview

**Doer Web** is a Next.js web application for the **AssignX Doer Platform** - a freelance marketplace where "Doers" (freelancers) complete academic and professional assignments for clients.

---

## Quick Links

| Document | Description |
|----------|-------------|
| [API Documentation](./API.md) | Service layer, endpoints, and data operations |
| [Architecture](./ARCHITECTURE.md) | System design, patterns, and data flow |
| [Components](./COMPONENTS.md) | React component library and usage |
| [Pages](./PAGES.md) | Application pages and navigation |
| [Database Schema](./DATABASE.md) | Supabase table structures |

---

## Application Overview

### What is Doer Web?

Doer Web is the freelancer-facing application of the AssignX platform. It enables:

1. **Registration & Onboarding** - New doers sign up and complete their profiles
2. **Activation** - Training modules, quiz, and bank details for payment
3. **Task Management** - Browse open tasks, accept assignments, submit work
4. **Communication** - Real-time chat with supervisors
5. **Resources** - Citation tools, templates, AI content checker
6. **Earnings** - Track payments, request payouts

### Tech Stack

| Category | Technology |
|----------|------------|
| Frontend | Next.js 16, React 19, TypeScript |
| Styling | Tailwind CSS 4, shadcn/ui |
| Backend | Supabase (PostgreSQL + Auth + Storage + Realtime) |
| State | Zustand |
| Animations | Framer Motion |

---

## Project Structure

```
doer-web/
├── app/                    # Next.js App Router (Pages)
├── components/             # React Components
│   ├── ui/                # shadcn/ui base components
│   ├── layout/            # Layout components
│   ├── onboarding/        # Onboarding flow
│   ├── activation/        # Activation flow
│   ├── dashboard/         # Dashboard components
│   ├── projects/          # Project components
│   ├── resources/         # Resource center
│   └── profile/           # Profile & settings
├── services/              # API service layer
├── hooks/                 # Custom React hooks
├── stores/                # Zustand stores
├── types/                 # TypeScript types
├── lib/                   # Utilities
│   └── supabase/         # Supabase clients
└── docs/                  # Documentation
```

---

## User Flows

### 1. New User Registration

```
Splash → Welcome Carousel → Register → OTP Verify → Profile Setup
```

See: [Onboarding Pages](./PAGES.md#onboarding-pages)

### 2. Doer Activation

```
Training Modules → Quiz (80% pass) → Bank Details → Dashboard
```

See: [Activation Pages](./PAGES.md#activation-pages)

### 3. Task Lifecycle

```
Open Pool → Accept → In Progress → Submit → Under Review → Completed
                        ↓
              Revision Requested → Revision Submitted
```

See: [Project Service](./API.md#3-project-service)

### 4. Project Workspace

```
Project Details → Upload Deliverable → Chat with Supervisor → Submit
```

See: [WorkspaceView Component](./COMPONENTS.md#workspaceview)

---

## Key Features

### Authentication

- Email/password authentication
- Phone OTP verification
- Session management with Supabase Auth
- Protected routes with middleware

**Relevant Docs:**
- [Auth Service](./API.md#1-authentication-service)
- [useAuth Hook](./ARCHITECTURE.md#zustand-state-management)

### Real-time Chat

- Project-based chat rooms
- Text and file messages
- Read receipts
- WebSocket subscriptions

**Relevant Docs:**
- [Chat Service](./API.md#4-chat-service)
- [ChatPanel Component](./COMPONENTS.md#chatpanel)

### File Management

- Drag-and-drop uploads
- Progress tracking
- File preview
- Deliverable versioning

**Relevant Docs:**
- [FileUpload Component](./COMPONENTS.md#fileupload)
- [Storage Buckets](./API.md#storage-buckets)

### Resource Center

- Citation builder (APA, MLA, Harvard, Chicago, IEEE, Vancouver)
- Document templates
- AI content detection
- Training videos

**Relevant Docs:**
- [Resources Service](./API.md#11-resources-service)
- [Resource Components](./COMPONENTS.md#resource-components)

---

## Development

### Prerequisites

- Node.js 18+
- npm or pnpm
- Supabase account

### Environment Variables

```env
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
```

### Getting Started

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Run production server
npm start
```

### Code Quality

```bash
# Type checking
npm run type-check

# Linting
npm run lint

# Format code
npm run format
```

---

## Database Schema

### Core Tables

| Table | Purpose |
|-------|---------|
| `profiles` | User profiles |
| `doers` | Doer-specific data |
| `skills` / `doer_skills` | Skill management |
| `subjects` / `doer_subjects` | Subject expertise |
| `universities` | University lookup |
| `projects` | Project/task data |
| `project_files` | Reference files |
| `project_deliverables` | Submitted work |
| `project_revisions` | Revision requests |
| `chat_rooms` | Chat rooms |
| `chat_messages` | Messages |
| `chat_participants` | Room membership |
| `training_modules` | Training content |
| `training_progress` | Progress tracking |
| `quiz_questions` | Quiz bank |
| `quiz_attempts` | Quiz attempts |
| `doer_activation` | Activation status |

See: [Database Types](./API.md) and [Types Structure](./ARCHITECTURE.md#project-structure)

---

## Type System

Types are organized by domain:

```
types/
├── database.ts          # Barrel export (main entry)
├── common.types.ts      # Base types & enums
├── profile.types.ts     # Profile, Doer, Skills
├── activation.types.ts  # Training, Quiz
├── project.types.ts     # Projects, Deliverables
├── chat.types.ts        # Chat, Messages
├── finance.types.ts     # Wallet, Transactions
├── support.types.ts     # Support tickets
└── resources.types.ts   # Citations, Templates
```

**Usage:**
```typescript
import type { Project, ChatMessage, DoerStats } from '@/types/database'
```

---

## Component Library

### shadcn/ui Components

Base components from shadcn/ui (New York variant):

- Button, Card, Input, Select
- Dialog, Sheet, Tabs
- Badge, Avatar, Progress
- Accordion, Table, Form

### Custom Components

Feature-specific components organized by domain:

- `components/dashboard/` - Task lists, cards
- `components/projects/` - Workspace, chat, upload
- `components/resources/` - Citation, templates, AI
- `components/profile/` - Settings, earnings, support

See: [Components Documentation](./COMPONENTS.md)

---

## Service Architecture

```
Component → Hook → Service → Supabase
```

**Services:**
- `auth.service.ts` - Authentication
- `project.service.ts` - Projects
- `chat.service.ts` - Real-time chat
- `profile.service.ts` - Profile (barrel export)
- `resources.service.ts` - Resources

See: [API Documentation](./API.md)

---

## Deployment

### Vercel (Recommended)

```bash
# Deploy to Vercel
vercel

# Production deployment
vercel --prod
```

### Environment Setup

1. Create Supabase project
2. Run database migrations
3. Set environment variables
4. Deploy to Vercel

---

## Contributing

### Code Style

- TypeScript strict mode
- ESLint + Prettier
- JSDoc comments on all exports
- Barrel exports for modules

### File Size Limits

- Components: < 400 lines
- Services: < 200 lines
- Extract constants and utilities to separate files

### Git Workflow

1. Create feature branch
2. Make changes with tests
3. Submit PR with description
4. Code review
5. Merge to main

---

## Support

- **Issues**: GitHub Issues
- **Documentation**: This docs folder
- **API Reference**: [API.md](./API.md)

---

## License

Proprietary - AssignX Technologies
