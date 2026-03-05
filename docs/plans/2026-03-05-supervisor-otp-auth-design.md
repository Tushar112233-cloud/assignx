# Supervisor OTP-Based Auth with Approval & Training Modules

## Overview
Replace magic link auth with OTP-based login/signup for supervisor-web (Next.js) and superviser_app (Flutter). Add admin approval workflow and training module gate before dashboard access.

## Flows

### Signup (4 Steps)
1. Email & Full Name
2. Professional Profile (qualification, experience, expertise, bio)
3. Bank Details (bank name, account number, IFSC, UPI)
4. OTP sent to email -> user enters OTP -> AccessRequest created (status: pending) -> redirect to "under review" page

### Login
- Enter email -> API checks supervisor status
  - **Not found**: redirect to register
  - **Pending**: show "Your application is under review. You'll receive an email once approved."
  - **Rejected**: show "Your application was rejected" with re-apply option
  - **Approved + not activated**: send OTP -> verify -> redirect to training modules
  - **Approved + activated**: send OTP -> verify -> dashboard

## API Changes

### New Endpoints
- `GET /auth/supervisor-status?email=` — Returns `{ status: 'not_found'|'pending'|'rejected'|'approved', isActivated: bool }`
- `GET /supervisors/me/modules` — Returns training module completion status
- `PUT /supervisors/me/modules/:moduleId/complete` — Mark module completed; set isActivated=true when all done

### Modified Endpoints
- `POST /admin/access-requests/:id/approve` — Auto-create Supervisor record from AccessRequest metadata
- `POST /access-requests` — Require OTP verification before creating request (pass verified email token)
- `POST /auth/send-otp` — Reuse for supervisor, add rate limiting (60s cooldown)
- `POST /auth/verify` — Return status info alongside tokens for supervisors

### Removed
- All magic link endpoints usage for supervisor flow

## Models

### SupervisorModule (new)
- `_id`, `title`, `description`, `order`, `type` (video/document/quiz), `content`, `isRequired`, `createdAt`

### SupervisorModuleProgress (new)
- `_id`, `supervisorId` (ref Supervisor), `moduleId` (ref SupervisorModule), `completedAt`, `score` (for quizzes)

### Supervisor (modified)
- `isActivated` already exists — set to true when all required modules completed

## Frontend Changes

### superviser-web (Next.js)
- Rewrite login page: email input -> status check -> OTP input -> route based on status
- Rewrite register page: keep 4-step form, Step 4 = OTP entry (not review)
- Simplify pending page to plain message
- Add rejected state with re-apply link
- Add training modules page (gated route before dashboard)
- Remove all magic link code and references

### superviser_app (Flutter)
- Replace email/password + Google + magic link with OTP-only flow
- Login screen: email -> status check -> OTP screen -> route based on status
- Register screen: 4-step form matching web, Step 4 = OTP
- Add pending/rejected screens
- Add training modules screen (gated before dashboard)
- Update AuthNotifier/AuthRepository for OTP flow

## Edge Cases
1. OTP expiry during signup — show "OTP expired, resend" button
2. Re-registration after rejection — allow new AccessRequest, old stays rejected
3. Multiple OTP requests — rate limit 60s cooldown, delete old OTP before new
4. Browser/app closed during OTP — stateless, user restarts flow
5. Admin approves while on pending page — no live update, user retries login
6. Concurrent signup with same email — upsert pattern on AccessRequest
7. OTP brute force — max 5 attempts, lock 15 minutes

## Architecture Decision
- Supervisor record created at admin approval time (from AccessRequest metadata)
- isActivated=false until training modules completed
- Both app and web gate dashboard behind isActivated check
