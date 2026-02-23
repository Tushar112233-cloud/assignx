# AssignX User Web

A modern, mobile-first academic project management platform built with Next.js 16, React 19, and TypeScript.

![Next.js](https://img.shields.io/badge/Next.js-16.1.1-black?logo=next.js)
![React](https://img.shields.io/badge/React-19.0.0-blue?logo=react)
![TypeScript](https://img.shields.io/badge/TypeScript-5.x-blue?logo=typescript)
![Tailwind CSS](https://img.shields.io/badge/Tailwind-4.x-38B2AC?logo=tailwind-css)
![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase)

## Features

### For Students
- **Project Support** - Submit academic projects and get expert assistance
- **AI/Plagiarism Reports** - Check content originality and AI detection
- **Student Connect** - Find tutors, resources, and study groups
- **Q&A Forum** - Ask questions and get answers from the community

### For Professionals
- **Expert Services** - Proofreading, consultation, and review services
- **Resource Marketplace** - Share and access educational resources

## Tech Stack

| Category | Technology |
|----------|------------|
| Framework | [Next.js 16](https://nextjs.org/) with App Router |
| Language | [TypeScript](https://www.typescriptlang.org/) |
| Styling | [Tailwind CSS 4](https://tailwindcss.com/) |
| UI Components | [shadcn/ui](https://ui.shadcn.com/) |
| State Management | [Zustand](https://zustand-demo.pmnd.rs/) |
| Backend | [Supabase](https://supabase.com/) (Auth, Database, Storage) |
| Forms | [React Hook Form](https://react-hook-form.com/) + [Zod](https://zod.dev/) |
| Animations | [Framer Motion](https://www.framer.com/motion/) |
| Icons | [Lucide React](https://lucide.dev/) |
| Dates | [date-fns](https://date-fns.org/) |

## Getting Started

### Prerequisites

- Node.js 18.17 or later
- npm, yarn, or pnpm
- Supabase account (for authentication)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/assignx-user-web.git
   cd assignx-user-web
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env.local
   ```

   Edit `.env.local`:
   ```env
   NEXT_PUBLIC_SUPABASE_URL=your-supabase-url
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
   NEXT_PUBLIC_SITE_URL=http://localhost:3000
   ```

4. **Run the development server**
   ```bash
   npm run dev
   ```

5. **Open [http://localhost:3000](http://localhost:3000)**

## Project Structure

```
user-web/
├── app/                      # Next.js App Router
│   ├── (auth)/              # Auth pages (login, signup, onboarding)
│   ├── (dashboard)/         # Protected dashboard pages
│   │   ├── home/            # Dashboard home
│   │   ├── projects/        # Projects list
│   │   ├── connect/         # Student Connect marketplace
│   │   ├── profile/         # User profile
│   │   ├── settings/        # App settings
│   │   └── support/         # Help & support
│   ├── auth/callback/       # OAuth callback handler
│   ├── project/[id]/        # Project detail (dynamic)
│   ├── projects/new/        # New project wizard
│   └── services/            # Service-specific pages
├── components/              # React components (186 files)
│   ├── add-project/         # Project creation (12 components)
│   ├── auth/                # Authentication (12 components)
│   ├── connect/             # Student marketplace (12 components)
│   ├── dashboard/           # Dashboard layout (12 components)
│   ├── profile/             # User profile (14 components)
│   ├── project-detail/      # Project details (11 components)
│   ├── projects/            # Projects list (14 components)
│   ├── settings/            # App settings (4 components)
│   ├── support/             # Help & support (4 components)
│   ├── shared/              # Shared utilities
│   └── ui/                  # shadcn/ui primitives (26 components)
├── lib/                     # Utilities & configurations
│   ├── actions/             # Server actions (auth)
│   ├── data/                # Mock data files
│   ├── supabase/            # Supabase client setup
│   └── validations/         # Zod validation schemas
├── stores/                  # Zustand state stores
│   ├── user-store.ts        # User authentication
│   ├── project-store.ts     # Project management
│   ├── wallet-store.ts      # Wallet balance
│   └── notification-store.ts # Notifications
├── types/                   # TypeScript definitions
│   ├── index.ts             # Common types
│   ├── project.ts           # Project types
│   ├── profile.ts           # Profile types
│   ├── connect.ts           # Connect/marketplace types
│   ├── settings.ts          # Settings types
│   └── database.ts          # Supabase types
└── docs/                    # Documentation
```

## Documentation

| Document | Description |
|----------|-------------|
| [Architecture](./docs/ARCHITECTURE.md) | Project structure, data flow, and tech decisions |
| [Components](./docs/COMPONENTS.md) | All 186 components with props documentation |
| [State Management](./docs/STATE-MANAGEMENT.md) | Zustand stores and usage patterns |
| [API](./docs/API.md) | Server actions, Supabase setup, and validation |
| [Types](./docs/TYPES.md) | TypeScript type definitions |

## Available Scripts

```bash
# Development
npm run dev          # Start development server (port 3000)
npm run build        # Build for production
npm run start        # Start production server
npm run lint         # Run ESLint

# Type checking
npx tsc --noEmit     # Check TypeScript without emitting
```

## Key Features

### Authentication Flow
```
Login → Google OAuth → Callback → Profile Check → Home/Onboarding
```

### Project Status Flow
```
submitted → analyzing → quoted → payment_pending → paid →
assigned → in_progress → delivered → qc_approved → completed
```

### State Management
- **User Store**: Persisted authentication state
- **Project Store**: Project list with tab filtering
- **Wallet Store**: Balance management
- **Notification Store**: Notifications with read/unread

## Code Quality

- **JSDoc Comments**: All custom components documented
- **File Size Limit**: Components under 400 lines
- **TypeScript Strict**: Full type safety
- **Barrel Exports**: Clean import patterns
- **Component Modules**: Organized by feature

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `NEXT_PUBLIC_SUPABASE_URL` | Supabase project URL | Yes |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Supabase anonymous key | Yes |
| `NEXT_PUBLIC_SITE_URL` | Application URL | Yes |

## Deployment

### Vercel (Recommended)
```bash
npm i -g vercel
vercel
```

### Build Output
```bash
npm run build
# Output in .next/ directory
```

## Browser Support

- Chrome (last 2 versions)
- Firefox (last 2 versions)
- Safari (last 2 versions)
- Edge (last 2 versions)

## Development Batches

| Batch | Features | Status |
|-------|----------|--------|
| 1-3 | Auth, Onboarding, Dashboard | Complete |
| 4 | Projects List | Complete |
| 5 | Project Detail | Complete |
| 6 | Add Project Wizard | Complete |
| 7 | Student Connect Marketplace | Complete |
| 8 | Profile Settings | Complete |
| 9 | Settings, Support, Q&A, Code Audit | Complete |

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'feat: add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Commit Convention
```
feat: new feature
fix: bug fix
docs: documentation
style: formatting
refactor: code refactoring
test: adding tests
chore: maintenance
```

## License

Proprietary - All rights reserved.

## Support

- **Docs**: [./docs/](./docs/)
- **Issues**: GitHub Issues
- **Email**: support@assignx.com

---

Built with Next.js 16 and React 19 by the AssignX Team
