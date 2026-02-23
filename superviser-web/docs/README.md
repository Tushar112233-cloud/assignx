# AdminX Documentation

> Complete reference documentation for the AdminX Supervisor Panel

## Quick Links

| Document | Description |
|----------|-------------|
| [Architecture](./ARCHITECTURE.md) | System design, patterns, and directory structure |
| [API Reference](./API.md) | Supabase integration, database schema, real-time subscriptions |
| [Components](./COMPONENTS.md) | Complete component library reference with props and examples |
| [Pages](./PAGES.md) | Route structure, page features, and navigation flow |
| [Hooks](./HOOKS.md) | Custom React hooks for state, UI, and utilities |
| [Utilities](./UTILS.md) | Helper functions, Supabase clients, and configurations |

## Documentation Overview

### Architecture
Learn about the overall system design, technology decisions, and how the different parts of the application work together.

- Technology stack
- Directory structure
- Data flow patterns
- Authentication architecture
- Real-time communication

### API Reference
Comprehensive documentation for the Supabase backend integration.

- Authentication flows
- Database schema (tables, columns, relationships)
- Real-time subscriptions
- Query examples
- Error handling

### Components
Reference for all React components in the application.

- Activation components (quiz, training)
- Auth components (login, register)
- Dashboard widgets
- Layout components
- Feature-specific components
- UI component library (shadcn/ui)

### Pages
Documentation for all routes and pages in the application.

- Route groups ((auth), (activation), (dashboard))
- Page features and behaviors
- Loading states
- Error boundaries
- Middleware and protection

### Hooks
Custom React hooks for common patterns.

- State management hooks
- UI interaction hooks
- Utility hooks
- Analytics hooks

### Utilities
Helper functions and service configurations.

- Core utilities (cn, formatCurrency, formatDate)
- Supabase client setup
- Mock data for development
- Store configuration
- Type definitions

## Getting Started

1. Start with [Architecture](./ARCHITECTURE.md) for a high-level overview
2. Review [Pages](./PAGES.md) to understand the user flow
3. Explore [Components](./COMPONENTS.md) for UI building blocks
4. Check [API](./API.md) for data operations
5. Use [Hooks](./HOOKS.md) and [Utilities](./UTILS.md) as needed

## Contributing to Documentation

When adding new features:

1. Add JSDoc comments to all exported functions and components
2. Update the relevant documentation file
3. Add usage examples where applicable
4. Keep component props tables up to date
