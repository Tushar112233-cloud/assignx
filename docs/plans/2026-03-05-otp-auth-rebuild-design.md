# OTP Auth Rebuild Design

## Overview

Rebuild the authentication system across api-server, user-web, and user_app (Flutter) to use a pure OTP-based flow. Remove all magic link code. Add account existence checks, multi-role support, attempt lockouts, and seamless onboarding.

## Platforms

- **api-server** (Express + MongoDB)
- **user-web** (Next.js)
- **user_app** (Flutter)

## Auth Flows

### Signup

```
Role Selection -> Email Entry -> Send OTP -> Enter OTP -> Onboarding Details -> Dashboard
```

1. User chooses primary role: Student | Professional | Business
2. User enters email address (student role validates .edu/.ac.in domains)
3. API sends 6-digit OTP to email, stores bcrypt hash with 10-min TTL
4. User enters OTP, API verifies and creates Profile + JWT tokens
5. User fills role-specific onboarding form (student details, professional details, etc.)
6. During onboarding, user can optionally add additional roles
7. Profile marked as onboarding complete, user lands on dashboard

### Login

```
Email Entry -> Check Account -> [exists] -> Send OTP -> Enter OTP -> Dashboard
                              -> [not found] -> "No account found. Sign up?"
```

1. User enters email
2. Frontend calls `POST /auth/check-account` to verify account exists
3. If account exists: send OTP, verify, return JWT, redirect to dashboard
4. If no account: show message with link to signup page

## API Changes

### New Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/auth/check-account` | POST | Check if email has a registered profile. Returns `{ exists: boolean }` |

### Modified Endpoints

| Endpoint | Change |
|----------|--------|
| `POST /auth/send-otp` | Replaces `/auth/magic-link`. Accepts `{ email, purpose: 'login' \| 'signup' }`. For login: requires existing account. For signup: rejects if account exists. Enforces 60s resend cooldown server-side. |
| `POST /auth/verify` | Accepts `{ email, otp, purpose: 'login' \| 'signup', role?: string }`. For signup: creates Profile with role. For login: requires existing Profile. Max 5 attempts per OTP, then 15-min lockout. |

### Removed Endpoints

| Endpoint | Reason |
|----------|--------|
| `POST /auth/magic-link` | Replaced by `/auth/send-otp` |
| `POST /auth/magic-link/verify` | Magic link removed |
| `POST /auth/magic-link/check` | Magic link polling removed |

### Removed Code

- Magic link email template in email.service.ts
- `AuthToken.sessionId` and `AuthToken.verified` fields
- `sendMagicLink`, `verifyMagicLink`, `checkMagicLinkStatus` in auth.service.ts

## Schema Changes

### Profile Collection

```
userType: String  ->  userTypes: [String]    // ['student', 'professional', 'business']
                      primaryUserType: String // first role chosen during signup
```

### AuthToken Collection

```
Remove: sessionId, verified
Add:    attempts: Number (default: 0)
        lockedUntil: Date (null unless locked out)
        purpose: String ('login' | 'signup')
Keep:   email, otp (bcrypt hash), type, role, expiresAt, createdAt
```

## OTP Security

- 6-digit numeric code
- Bcrypt hashed before storage
- 10-minute expiry (TTL index)
- Max 5 verification attempts per OTP; after 5 fails, lock for 15 minutes
- 60-second server-enforced resend cooldown
- Rate limit on send-otp endpoint (existing)

## Email Template

Simple plain-text style email:

```
Subject: Your AssignX verification code

Your verification code is: 123456

This code expires in 10 minutes. If you didn't request this, ignore this email.
```

No clickable links. Just the code.

## User-Web Changes

### Remove
- `components/auth/magic-link-form.tsx`
- `app/api/auth/magic-link/route.ts` (proxy route)
- `app/auth/callback/route.ts` (legacy OAuth callback)
- All magic link references in `lib/api/auth.ts`

### Modify
- `app/(auth)/login/page.tsx` — email input -> check account -> OTP entry -> dashboard
- `app/(auth)/signup/page.tsx` — role selection -> email -> OTP -> onboarding, all as stepper
- `lib/api/auth.ts` — replace sendMagicLink with sendOTP, add checkAccount
- `stores/auth-store.ts` — update onboarding logic for multi-role (userTypes array)
- `lib/auth/middleware.ts` — no changes needed (cookie-based gating stays)

### New/Updated Components
- OTP input component (6-digit pin input with auto-focus, paste support)
- Unified stepper component for signup flow
- "Account not found" prompt on login page

## User App (Flutter) Changes

### Remove
- `features/auth/screens/magic_link_screen.dart`
- `features/auth/widgets/google_sign_in_button.dart`
- Magic link references in `core/api/auth_api.dart`

### Modify
- `features/auth/screens/login_screen.dart` — email -> check account -> OTP -> dashboard
- `features/auth/screens/signin_screen.dart` — merge into login or remove if redundant
- `core/api/auth_api.dart` — replace sendMagicLink with sendOTP, add checkAccount
- `core/router/app_router.dart` — remove magicLink/authCallback routes
- `providers/auth_provider.dart` — update for multi-role
- `features/onboarding/screens/role_selection_screen.dart` — update for multi-role

### New Widgets
- OTP input widget (6 boxes, auto-advance, paste support)
- Countdown timer widget for resend cooldown

## Multi-Role Support

- Profile stores `userTypes: ['student']` initially
- During onboarding step 5, after primary role form, show: "Also register as Professional/Business?"
- If yes, collect that role's details too
- Later, users can add roles from profile settings (existing `/profiles/roles` endpoint)
- All role-specific collections (students, professionals) linked via `profileId`

## Edge Cases

1. **OTP expired**: Show "Code expired, request a new one" with resend button
2. **Too many attempts**: Show "Too many attempts. Try again in 15 minutes"
3. **Email already registered (signup)**: "Account already exists. Log in instead?"
4. **Email not found (login)**: "No account found. Sign up?"
5. **Network failure during OTP verify**: Allow retry without re-sending OTP
6. **Multiple OTP requests**: Each new OTP invalidates the previous one
7. **Browser/app closed mid-flow**: OTP remains valid for 10 min; user can re-enter
8. **Concurrent sessions**: Multiple devices can authenticate; each gets own JWT pair
9. **Token refresh race**: Existing refresh token rotation handles this
