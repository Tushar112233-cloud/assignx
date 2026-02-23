# Doer Web

A modern web application for the **AssignX Doer Platform** - enabling freelancers to complete academic and professional assignments.

## Features

- **User Registration & Onboarding** - Complete profile setup with skills and qualifications
- **Activation Flow** - Training modules, quiz verification, and bank details
- **Task Management** - Browse open pool, accept tasks, track deadlines
- **Project Workspace** - Upload deliverables, real-time chat with supervisors
- **Resource Center** - Citation builder, templates, AI content checker
- **Earnings Dashboard** - Track payments, request payouts

## Tech Stack

| Category | Technology |
|----------|------------|
| Framework | [Next.js 16](https://nextjs.org/) (App Router) |
| Language | [TypeScript 5](https://www.typescriptlang.org/) |
| UI Library | [React 19](https://react.dev/) |
| Styling | [Tailwind CSS 4](https://tailwindcss.com/) |
| Components | [shadcn/ui](https://ui.shadcn.com/) (New York) |
| Backend | [Supabase](https://supabase.com/) (PostgreSQL + Auth + Storage + Realtime) |
| State | [Zustand](https://zustand-demo.pmnd.rs/) |
| Animations | [Framer Motion](https://www.framer.com/motion/) |
| Icons | [Lucide React](https://lucide.dev/) |

## Getting Started

### Prerequisites

- Node.js 18+
- npm, yarn, or pnpm
- Supabase account

### Installation

```bash
# Clone the repository
git clone https://github.com/assign-x/doer-web.git
cd doer-web

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env.local
# Edit .env.local with your Supabase credentials
```

### Environment Variables

```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
```

### Development

```bash
# Run development server
npm run dev

# Open http://localhost:3000
```

### Production Build

```bash
# Build for production
npm run build

# Start production server
npm start
```

## Project Structure

```
doer-web/
├── app/                    # Next.js App Router pages
│   ├── (auth)/            # Authentication pages
│   ├── (onboarding)/      # Onboarding flow
│   ├── (activation)/      # Activation flow
│   └── (main)/            # Main application
├── components/             # React components
│   ├── ui/                # Base UI components
│   ├── layout/            # Layout components
│   ├── dashboard/         # Dashboard components
│   ├── projects/          # Project components
│   ├── resources/         # Resource components
│   └── profile/           # Profile components
├── services/              # API service layer
├── hooks/                 # Custom React hooks
├── stores/                # Zustand state stores
├── types/                 # TypeScript types
├── lib/                   # Utilities & config
│   └── supabase/         # Supabase clients
└── docs/                  # Documentation
```

## Documentation

| Document | Description |
|----------|-------------|
| [Overview](./docs/README.md) | Full documentation index |
| [API Reference](./docs/API.md) | Service layer & endpoints |
| [Architecture](./docs/ARCHITECTURE.md) | System design & patterns |
| [Components](./docs/COMPONENTS.md) | Component library reference |
| [Pages](./docs/PAGES.md) | Application pages & routes |

## User Flow

```
Registration → Profile Setup → Training → Quiz → Bank Details → Dashboard
                                                                    │
                  ┌─────────────────────────────────────────────────┤
                  ▼                                                 ▼
            Open Pool ──────────────────────────────────────▶ Active Projects
            (Browse)                                              │
                                                                  │
                        ┌─────────────────────────────────────────┤
                        ▼                                         ▼
                  Project Workspace ───────────────────────▶ Submit Work
                  (Chat, Upload)                                  │
                                                                  ▼
                                                           Under Review
                                                                  │
                                          ┌───────────────────────┼───────────────────┐
                                          ▼                       ▼                   ▼
                                    Revision ───────────▶    Approved ───────▶  Completed
                                    Requested                                         │
                                                                                      ▼
                                                                                   Payment
```

## Scripts

```bash
npm run dev          # Start development server
npm run build        # Build for production
npm run start        # Start production server
npm run lint         # Run ESLint
npm run type-check   # TypeScript checking
```

## Key Features Implemented

### Core Features (D01-D20)

- [x] D01: Splash Screen with Animation
- [x] D02: Onboarding Carousel
- [x] D03: Phone/Email Registration
- [x] D04: OTP Verification
- [x] D05: Profile Setup Wizard
- [x] D06: Activation Gate Flow
- [x] D07: Training Video Modules
- [x] D08: Activation Quiz
- [x] D09: Bank Details Form
- [x] D10: Dashboard Layout
- [x] D11-12: Task Pool & Assigned Tasks
- [x] D13: Project Workspace
- [x] D14: File Upload System
- [x] D15: Real-time Chat
- [x] D16: Revision Handling
- [x] D17: Projects List Tabs
- [x] D18-20: Project Detail Views

### Extended Features (D21-D40)

- [x] D21-22: Earnings & Statistics
- [x] D23: Wallet & Transactions
- [x] D24-25: Payout Requests
- [x] D26-28: Skill Management
- [x] D29-30: Rating & Reviews
- [x] D31-34: Resource Center
- [x] D35-37: Profile Settings
- [x] D38-40: Support System

### Advanced Features (D41-D57)

- [x] D41-45: Citation Builder
- [x] D46-50: Format Templates
- [x] D51-54: Training Center
- [x] D55-57: AI Content Checker

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style

- TypeScript strict mode enabled
- ESLint + Prettier for formatting
- JSDoc comments on all exports
- Maximum file size: 400 lines

## Deployment

The easiest way to deploy is using [Vercel](https://vercel.com):

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/assign-x/doer-web)

## License

Proprietary - AssignX Technologies

## Support

For support, please contact the development team or open an issue in this repository.

---

Built with Next.js by AssignX
