# ADR-001: Authentication Architecture Migration

## Status
PROPOSED

## Date
2025-12-27

## Context

The user-web application currently has a working authentication system using Supabase Auth with Google OAuth. However, after developing the doer-web application, patterns were established that provide better:

1. **Profile creation handling** - Automatic profile creation in OAuth callback
2. **Route protection clarity** - Inverse protection model (all routes protected unless explicitly public)
3. **State management** - Separation of auth state from user data
4. **Service layer abstraction** - Client-side auth service for consistent API

The goal is to align user-web authentication patterns with doer-web to:
- Reduce cognitive load when working across both codebases
- Apply lessons learned from doer-web implementation
- Prepare for potential shared authentication module

## Decision

We will migrate user-web authentication to match doer-web patterns, with the following key decisions:

### Decision 1: Adopt Automatic Profile Creation in OAuth Callback

**Current State**: Profile creation deferred to onboarding flow
**Target State**: Base profile created automatically in callback using Google metadata

```typescript
// In app/auth/callback/route.ts
if (!profile) {
  await supabase.from('profiles').insert({
    id: user.id,
    email: user.email!,
    full_name: user.user_metadata?.full_name || user.email?.split('@')[0],
    avatar_url: user.user_metadata?.avatar_url,
    // user_type left null - set during onboarding
  })
}
```

**Rationale**:
- Eliminates edge cases where users exist in auth but not profiles table
- Captures Google metadata immediately
- Simpler error handling in onboarding flow

### Decision 2: Maintain Server Actions Pattern (Diverge from doer-web)

**doer-web Pattern**: Client-side auth service using browser Supabase client
**user-web Pattern**: Server actions using server Supabase client

**Decision**: Keep server actions pattern in user-web

**Rationale**:
- Server actions are the modern Next.js pattern
- Better security (no client-side Supabase operations for mutations)
- Already working well in user-web
- Can add optional service layer for client-side reads

### Decision 3: Add Auth Store for Session State

**Current State**: User store manages all user data with full persistence
**Target State**: Separate auth store for session state, user store for profile data

```typescript
// New: stores/auth-store.ts
interface AuthState {
  isAuthenticated: boolean
  isOnboarded: boolean
  isLoading: boolean
  session: { userId: string; email: string } | null
}
```

**Rationale**:
- Cleaner separation of concerns
- Reduces localStorage size (only persist minimal auth state)
- Matches doer-web pattern
- Easier to reason about authentication vs user data

### Decision 4: Align Middleware Route Protection Model

**Current State**: Explicit list of protected routes
**Target State**: Inverse model - all routes protected unless explicitly public/auth

```typescript
// Target pattern
const isAuthRoute = ['/login', '/signup', '/onboarding'].some(...)
const isPublicRoute = ['/', '/terms', '/privacy'].some(...)
// Everything else is protected
const isProtected = !isAuthRoute && !isPublicRoute
```

**Rationale**:
- Safer default (new routes are protected)
- Matches doer-web pattern
- Easier to audit security

### Decision 5: Keep user-web Specific Features

The following user-web features are NOT in doer-web and will be preserved:

1. **Role-based signup flows** (student, professional, business)
2. **Extended profile types** (students, professionals tables)
3. **Rich onboarding components** (splash, carousel, role selection)
4. **Theme toggle in auth layout**

These are appropriate for the user-web domain and should not be changed.

## Consequences

### Positive
- Consistent patterns across both applications
- Better error handling for missing profiles
- Cleaner state management
- Safer route protection default
- Easier maintenance and debugging

### Negative
- Migration effort required
- Potential for regressions during migration
- Need to update tests
- Temporary complexity while both patterns coexist

### Neutral
- Auth service layer optional (can be added later if needed)
- doer-web specific features (training, quiz, bank) not applicable

## Alternatives Considered

### Alternative 1: Full Pattern Migration
Copy doer-web auth exactly, including client-side service layer.

**Rejected because**: Server actions are more secure and modern. No benefit to changing working pattern.

### Alternative 2: No Migration
Keep current patterns, accept differences between apps.

**Rejected because**: Profile creation edge cases are a real problem. Route protection model is less secure.

### Alternative 3: Shared Auth Package
Create shared npm package for auth logic.

**Deferred because**: Not enough shared code to justify overhead. Consider after migration.

## Implementation Plan

See AUTH_MIGRATION_BLUEPRINT.md for detailed implementation phases.

Summary:
1. Phase 1: Add auth store (non-breaking)
2. Phase 2: Update callback for auto profile creation
3. Phase 3: Align middleware route protection
4. Phase 4: Optional component updates
5. Phase 5: State management optimization

## References

- AUTH_MIGRATION_BLUEPRINT.md - Detailed migration plan
- doer-web codebase - Reference implementation
- Supabase SSR documentation
- Next.js Server Actions documentation
