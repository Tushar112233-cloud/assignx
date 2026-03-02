# AssignX Superviser-Web QA Test Results
**Platform**: superviser-web (Next.js) | **Expected URL**: http://localhost:3003 | **Date**: 2026-02-25
**Login method**: Magic link email (admin@gmail.com bypass available in code)

---

## Summary

| # | Test | Status | Notes |
|---|------|--------|-------|
| 1 | Server Running | FAIL | superviser-web is NOT running. Port 3003 is occupied by a different project (Finova/SecondBrain/finance) |

**Overall**: BLOCKED - Cannot test. Server not running.

---

## Details

### Server Check
- Port 3003 is occupied by `/Volumes/Crucial X9/SecondBrain/finance` (Finova app - unrelated project)
- The superviser-web project exists at `/Volumes/Crucial X9/AssignX/superviser-web/` but is not started
- The superviser-web `package.json` has `"dev": "next dev"` with no specific port configured
- Would need to be started manually with a custom port (e.g., `next dev --port 3004`)

### Login Page (from source code review)
The superviser-web login uses **magic link authentication** (email only, no password):
- Email field with "you@company.com" placeholder
- "Send sign-in link" button
- Admin bypass: `admin@gmail.com` triggers `signInWithPassword` with `Admin@123` (hardcoded in `components/auth/login-form.tsx` line 43)
- Non-admin users go through email access request → admin approval → magic link flow
- Trust badges: Encrypted (End-to-end), Passwordless (Magic link), Instant (No wait time)
- Activity card: "12 supervisors active now"
- Register CTA: "New to AssignX? Apply for supervisor access"

### Features Found (from code review)
Based on the route structure (`app/(dashboard)/`), the platform should have:
- Dashboard
- Projects
- Doers
- Users (Clients)
- Messages/Chat
- Earnings
- Resources
- Profile
- Settings
- Support
- Notifications
- Pending Approval page

### Action Required
To test superviser-web:
1. Stop the Finova app on port 3003, OR
2. Start superviser-web on a different port: `cd superviser-web && npx next dev --port 3004`
3. Navigate to the running URL and use admin@gmail.com for bypass login
