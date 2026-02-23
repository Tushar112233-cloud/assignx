# Authentication Architecture Migration Blueprint

## Document Purpose
This document provides a comprehensive analysis of the authentication architectures in both doer-web and user-web applications, along with a detailed migration plan to align user-web authentication patterns with doer-web.

---

## 1. ARCHITECTURE COMPARISON

### 1.1 Supabase Client Configuration

| Component | doer-web | user-web | Status |
|-----------|----------|----------|--------|
| `lib/supabase/client.ts` | Browser client with `@supabase/ssr` | Identical implementation | ALIGNED |
| `lib/supabase/server.ts` | Server client with cookie handling | Identical implementation | ALIGNED |
| `lib/supabase/middleware.ts` | Session update with route protection | Similar but different route logic | NEEDS UPDATE |
| `lib/supabase/index.ts` | Not present | Barrel export file | user-web EXTRA |

**Assessment**: Supabase client setup is nearly identical. The key difference is in route protection logic within middleware.

### 1.2 Middleware Route Protection

#### doer-web Pattern (Reference)
```
Location: D:\assign-x\doer-web\lib\supabase\middleware.ts

Route Classification:
- Auth Routes: /login, /register
- Public Routes: /, /auth/*
- Onboarding Routes: /welcome, /profile-setup, /training, /quiz, /bank-details
- Protected Routes: Everything else

Redirect Logic:
- No user + protected route -> /login
- Has user + auth route -> /dashboard
```

#### user-web Current Pattern
```
Location: D:\assign-x\user-web\lib\supabase\middleware.ts

Route Classification:
- Auth Routes: /login, /signup, /onboarding (redirects to /)
- Protected Routes: /home, /projects, /project/*, /profile, /connect, /settings, /support

Redirect Logic:
- No user + protected route -> /login
- Has user + auth route -> / (root)
```

**Key Differences**:
1. doer-web uses inverse logic (all routes protected unless explicitly public)
2. user-web uses explicit list of protected routes
3. doer-web redirects authenticated users to `/dashboard`, user-web to `/`
4. doer-web handles doer-specific onboarding routes (training, quiz, bank-details)

### 1.3 Authentication Services

#### doer-web: Service Layer Pattern
```
Location: D:\assign-x\doer-web\services\auth.service.ts

Exports:
- authService.getSession()
- authService.getUser()
- authService.signUp(email, password, fullName, phone)
- authService.signIn(email, password)
- authService.signInWithGoogle()
- authService.signOut()
- authService.resetPassword(email)
- authService.updatePassword(newPassword)

- doerService.getDoerByProfileId()
- doerService.createDoer()
- doerService.createDoerActivation()
- doerService.updateProfileSetup()
- doerService.updateSkills()
- doerService.updateSubjects()
- doerService.getSkills()
- doerService.getSubjects()
- doerService.getUniversities()
```

#### user-web: Server Actions Pattern
```
Location: D:\assign-x\user-web\lib\actions\auth.ts

Exports:
- signInWithGoogle() - server action with redirect
- signOut() - with revalidatePath
- getUser() - returns Supabase user
- createProfile() - base profile creation
- createStudentProfile() - extended student profile
- createProfessionalProfile() - extended professional profile
```

**Key Differences**:
1. doer-web uses client-side service layer with browser Supabase client
2. user-web uses server actions with server Supabase client
3. doer-web handles more auth methods (email/password, password reset)
4. user-web has role-specific profile creation (student, professional)

### 1.4 Auth Callback Route

#### doer-web Flow
```
Location: D:\assign-x\doer-web\app\auth\callback\route.ts

Flow:
1. Exchange code for session
2. Check if profile exists
   - NO: Create profile with user metadata, redirect to /profile-setup
   - YES: Check if doer record exists
     - NO: Redirect to /profile-setup
     - YES: Check activation status
       - Not training_completed -> /training
       - Not quiz_passed -> /quiz
       - Not bank_details_added -> /bank-details
       - Fully activated -> /dashboard
```

#### user-web Flow
```
Location: D:\assign-x\user-web\app\auth\callback\route.ts

Flow:
1. Exchange code for session
2. Check if profile exists
   - NO: Redirect to /onboarding
   - YES: Check if user_type is set
     - NO: Redirect to /onboarding
     - YES: Redirect to requested next path or /
```

**Key Differences**:
1. doer-web creates profile automatically in callback with user metadata
2. user-web defers profile creation to onboarding flow
3. doer-web has multi-step activation check (training, quiz, bank)
4. user-web only checks for user_type presence

### 1.5 State Management

#### doer-web: Zustand with Persistence
```
Location: D:\assign-x\doer-web\stores\authStore.ts

State:
- user: Profile | null
- doer: Doer | null
- isLoading: boolean
- isAuthenticated: boolean
- isOnboarded: boolean

Persisted: isOnboarded only
```

#### user-web: Zustand with Full Persistence
```
Location: D:\assign-x\user-web\stores\user-store.ts

State:
- user: User | null (includes students, professionals, wallet relations)
- isLoading: boolean
- error: string | null

Persisted: Entire user object
```

**Key Differences**:
1. doer-web separates auth state (profile/doer) from user store
2. user-web combines all user data in single store
3. doer-web tracks onboarding status explicitly
4. user-web persists full user object (may cause stale data issues)

### 1.6 Auth Components

#### doer-web
```
Location: D:\assign-x\doer-web\app\(auth)\*

Components:
- layout.tsx - Minimal wrapper
- login/page.tsx - Google OAuth button with loading/error states
- register/page.tsx - Google OAuth button with navigation to login

Pattern: Direct authService.signInWithGoogle() call in component
```

#### user-web
```
Location: D:\assign-x\user-web\app\(auth)\*
            D:\assign-x\user-web\components\auth\*

Components:
- layout.tsx - Theme toggle header
- login/page.tsx - Uses GoogleSignInButton component
- onboarding/page.tsx - Splash -> Carousel -> Role selection
- signup/student/page.tsx - Multi-step form
- signup/professional/page.tsx - Multi-step form

Reusable Components:
- GoogleSignInButton - Server action trigger
- SplashScreen, OnboardingCarousel, RoleSelection
- StudentSignupForm, ProfessionalSignupForm
- ProgressSteps, UniversitySelector, CourseSelector
- IndustrySelector, TermsModal, SuccessAnimation
```

**Key Differences**:
1. user-web has much richer onboarding flow with role-based signup
2. doer-web has simpler auth pages (Google only)
3. user-web uses component composition with reusable auth components
4. user-web uses server actions; doer-web uses client-side service

---

## 2. MIGRATION BLUEPRINT

### 2.1 Files to COPY/ADAPT from doer-web

| Source File | Target Location | Adaptation Required |
|-------------|-----------------|---------------------|
| `services/auth.service.ts` | `services/auth.service.ts` | Adapt for user roles (student/professional) |
| `stores/authStore.ts` | `stores/auth-store.ts` | Keep isOnboarded pattern, adapt user type |
| `lib/constants.ts` | Merge into existing | Only ROUTES and auth-related constants |

### 2.2 Files to MODIFY in user-web

| File | Changes Required |
|------|-----------------|
| `lib/supabase/middleware.ts` | Align route classification pattern with doer-web |
| `app/auth/callback/route.ts` | Add automatic profile creation like doer-web |
| `components/auth/google-signin-button.tsx` | Optional: Consider using auth service pattern |
| `stores/user-store.ts` | Add isOnboarded flag, optimize persistence |
| `lib/actions/auth.ts` | Keep but may coexist with service layer |

### 2.3 Files to DELETE (Static/Mock Data)

None identified that need deletion. Both apps are using Supabase for data.

### 2.4 Order of Operations

```
Phase 1: Foundation (Non-breaking)
  1.1 Create services/auth.service.ts (new file, coexists with actions)
  1.2 Create stores/auth-store.ts (new file, supplement user-store)
  1.3 Add auth-related constants to lib/constants.ts

Phase 2: Callback Enhancement (Critical)
  2.1 Update app/auth/callback/route.ts to create profile automatically
  2.2 Handle user_type selection in callback or redirect properly

Phase 3: Middleware Alignment (Critical)
  3.1 Update lib/supabase/middleware.ts with doer-web pattern
  3.2 Update route classifications for user-web specific routes
  3.3 Test all route protection scenarios

Phase 4: Component Updates (Optional)
  4.1 Consider adding auth service to GoogleSignInButton
  4.2 Update onboarding flow to use auth store
  4.3 Add isOnboarded tracking

Phase 5: State Management Optimization
  5.1 Reduce user-store persistence scope
  5.2 Implement auth-store for session tracking
  5.3 Add session sync between stores
```

---

## 3. COMPONENT MAPPING

### 3.1 Auth Components Map

| doer-web Component | user-web Equivalent | Reusability |
|--------------------|---------------------|-------------|
| Login page (inline Google button) | GoogleSignInButton component | user-web more modular |
| Register page (inline Google button) | Not needed (onboarding handles) | N/A |
| N/A | SplashScreen | Keep as-is |
| N/A | OnboardingCarousel | Keep as-is |
| N/A | RoleSelection | Keep as-is |
| N/A | StudentSignupForm | Keep as-is |
| N/A | ProfessionalSignupForm | Keep as-is |

### 3.2 Reusable Components in user-web (No Changes Needed)

```
components/auth/
  - splash-screen.tsx
  - onboarding-slide.tsx
  - onboarding-carousel.tsx
  - role-selection.tsx
  - google-signin-button.tsx (may enhance with service pattern)
  - progress-steps.tsx
  - university-selector.tsx
  - course-selector.tsx
  - student-signup-form.tsx
  - terms-modal.tsx
  - success-animation.tsx
  - industry-selector.tsx
  - professional-signup-form.tsx
  - index.ts
```

### 3.3 User-Specific Customizations

1. **User Type Handling**: user-web must maintain student/professional/business distinction
2. **Profile Extensions**: student/professional tables are user-web specific
3. **Onboarding Flow**: user-web has role-based multi-step signup, keep this
4. **No Activation Flow**: user-web doesn't need doer activation (training/quiz/bank)

---

## 4. DATA FLOW DESIGN

### 4.1 Auth State Management Flow

```
                    RECOMMENDED ARCHITECTURE

+------------------+     +------------------+     +------------------+
|   Supabase       |     |   Auth Store     |     |   User Store     |
|   Auth Session   | --> |   (New)          | --> |   (Existing)     |
+------------------+     +------------------+     +------------------+
        |                        |                        |
        |                        |                        |
        v                        v                        v
  - Session token          - isAuthenticated         - User profile
  - Supabase user          - isOnboarded             - Student/Professional
  - Refresh token          - isLoading               - Wallet data
                           - session metadata        - Related entities
```

### 4.2 Protected Route Handling

```
Request Flow:

  [Request] --> [middleware.ts] --> [Route Classification]
                      |
                      v
              [updateSession()]
                      |
                      v
              [supabase.auth.getUser()]
                      |
        +-------------+-------------+
        |             |             |
        v             v             v
   [Public]      [Auth Route]   [Protected]
        |             |             |
        v             v             v
   [Continue]   [Has User?]    [Has User?]
                     |             |
              +------+------+  +---+---+
              |             |  |       |
              v             v  v       v
          [Redirect]   [Continue] [Redirect]
          [to /home]             [to /login]
```

### 4.3 User Data Fetching Pattern

```
CURRENT: user-web

  [Login] --> [Callback] --> [Check Profile] --> [Redirect]
                                    |
                                    v
                             [Onboarding Creates Profile]
                                    |
                                    v
                             [User Store fetchUser()]
                                    |
                                    v
                             [Server Action getProfile()]


RECOMMENDED: Hybrid (doer-web pattern with user-web extensions)

  [Login] --> [Callback] --> [Auto-Create Base Profile]
                                    |
                                    +---> [Has user_type?]
                                    |           |
                                    |     [NO]  v
                                    |     [Redirect /onboarding]
                                    |           |
                                    |     [YES] v
                                    +---> [Redirect /home]

  [App Load] --> [Auth Store init] --> [Fetch Session]
                        |
                        v
                 [User Store fetchUser()]
                        |
                        v
                 [Profile + Relations from Server Action]
```

---

## 5. IMPLEMENTATION PRIORITY

### HIGH PRIORITY (Must Do)

1. **Auth Callback Profile Creation**
   - Auto-create profile with Google metadata on first login
   - Prevents edge cases of missing profiles

2. **Middleware Route Protection**
   - Align with doer-web inverse protection pattern
   - Clearer security model

3. **Auth Store Addition**
   - Track isAuthenticated and isOnboarded
   - Reduces localStorage persistence issues

### MEDIUM PRIORITY (Should Do)

4. **Auth Service Layer**
   - Provides consistent auth API
   - Easier testing and mocking

5. **User Store Optimization**
   - Reduce persistence scope
   - Prevent stale data issues

### LOW PRIORITY (Nice to Have)

6. **Component Migration**
   - Consider service pattern in GoogleSignInButton
   - Mostly cosmetic changes

---

## 6. RISK ASSESSMENT

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking existing auth flow | HIGH | Phase migrations with feature flags |
| Session persistence issues | MEDIUM | Test thoroughly with incognito mode |
| Route protection gaps | HIGH | Comprehensive route testing checklist |
| Store synchronization bugs | MEDIUM | Implement proper state hydration |
| Profile creation race conditions | LOW | Use upsert operations |

---

## 7. TESTING CHECKLIST

### Auth Flow Tests
- [ ] New user Google login creates profile
- [ ] Existing user login redirects correctly
- [ ] Logout clears all state
- [ ] Session refresh works
- [ ] Protected routes block unauthenticated access
- [ ] Auth routes redirect authenticated users

### Onboarding Tests
- [ ] New user goes to onboarding
- [ ] Student signup creates profile + student record
- [ ] Professional signup creates profile + professional record
- [ ] Onboarding completion sets user_type

### State Management Tests
- [ ] Auth store initializes correctly
- [ ] User store syncs with auth
- [ ] localStorage persistence works
- [ ] Page refresh maintains state
- [ ] Cross-tab sync works

---

## Document Metadata

- **Created**: 2025-12-27
- **Author**: System Architecture Designer (AI)
- **Version**: 1.0
- **Status**: Draft for Review

---

## Appendix: File Locations Reference

### doer-web (Reference Implementation)
```
D:\assign-x\doer-web\
  app\
    (auth)\
      layout.tsx
      login\page.tsx
      register\page.tsx
    auth\
      callback\route.ts
  lib\
    supabase\
      client.ts
      server.ts
      middleware.ts
    constants.ts
  middleware.ts
  services\
    auth.service.ts
  stores\
    authStore.ts
  types\
    database.ts
```

### user-web (Target Implementation)
```
D:\assign-x\user-web\
  app\
    (auth)\
      layout.tsx
      login\page.tsx
      onboarding\page.tsx
      signup\
        student\page.tsx
        professional\page.tsx
    auth\
      callback\route.ts
  lib\
    supabase\
      client.ts
      server.ts
      middleware.ts
      index.ts
    actions\
      auth.ts
      data.ts
      index.ts
  middleware.ts
  components\
    auth\
      [13 components]
      index.ts
  stores\
    user-store.ts
    [other stores]
  types\
    [type files]
```
