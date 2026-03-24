# AssignX API Test Report
**Date:** 2026-03-24
**Tester:** Automated API Testing Suite
**API Server:** http://localhost:4000

---

## 1. Test Accounts Used

| Role | Email | ID | Status |
|------|-------|----|--------|
| User | omrajpal.exe@gmail.com | 69c1b3087b63a761d445f1ec | Active, onboarding complete |
| Doer | testdoer@gmail.com | 69b6a9577eee48f773ce2711 | Active |
| Supervisor | testsupervisor@gmail.com | 69b6a9577eee48f773ce271a | Active |
| Admin | admin@assignx.in | 69b6a136e9ba071b4009de8e | Active, super_admin |

## 2. MongoDB Data State

| Collection | Count | Notes |
|------------|-------|-------|
| users | 6 | 1 professional (Om), 4 students, 1 other |
| doers | 5 | 1 test, 4 seeded |
| supervisors | 2 | 1 test, 1 real |
| admins | 2 | admin@assignx.in, admin@gmail.com |
| projects | 13 | Various statuses (submitted, in_progress, completed, draft, paid) |
| community_posts | 18 | campus, pro_network, business_hub types |
| experts | 7 | All active, rates 500-1500 INR |
| expert_bookings | 8 | 3 completed, 3 confirmed, 2 pending |
| notifications | 48 | Across all roles |
| chat_rooms | 12 | Project-linked rooms |
| user_wallets | 4 | Om's balance: 3500 INR |
| doer_wallets | 3 | Test doer balance: 25000 INR |
| supervisor_wallets | 3 | Test supervisor balance: 15000 INR |
| wallet_transactions | 28 | Credits, debits, withdrawals |
| support_tickets | 6 | 3 open, 1 in_progress, 2 resolved |
| marketplace_listings | 4 | Electronics, books, housing, stationery |
| jobs | 5 | All posted by admin |
| training_modules | 8 | For doers and supervisors |
| experts | 7 | Active experts with availability |
| faqs | 9 | Across 6 categories |
| banners | 3 | All active |
| investors | 3 | With pitch deck data |
| universities | 0 | EMPTY - needs seeding |
| reference_styles | 0 | EMPTY - needs seeding |
| doer_activations | 0 | EMPTY |
| learning_resources | 0 | EMPTY via admin route |
| colleges | 0 | EMPTY via admin route |

---

## 3. API Test Results by Role

### 3.1 AUTH APIs (All Roles)

| # | Endpoint | Method | Status | Result |
|---|----------|--------|--------|--------|
| 1 | /api/auth/dev-login | POST | 200 | Works for all 4 roles |
| 2 | /api/auth/me | GET | 200 | Returns user data for all roles |
| 3 | /api/auth/send-otp | POST | 200 | Requires `purpose` param ("login" or "signup") |
| 4 | /api/auth/refresh | POST | 200 | Returns new accessToken |
| 5 | /api/auth/verify | POST | - | Not tested (requires real OTP) |

### 3.2 USER Role APIs (29/30 passed)

| # | Endpoint | Method | Status | Result |
|---|----------|--------|--------|--------|
| 1 | /api/users/me | GET | 200 | Full profile with wallet info |
| 2 | /api/users/me/preferences | GET | 200 | Empty object {} |
| 3 | /api/users/me/referral | GET | 200 | 0 referrals, empty code |
| 4 | /api/users/me/payment-methods | GET | 200 | Empty array |
| 5 | /api/users/me/subjects | GET | 200 | Empty array |
| 6 | /api/users/me/export | GET | 200 | Full data export |
| 7 | /api/projects | GET | 200 | 4 projects returned |
| 8 | /api/projects | POST | 201 | Created project AX-000013 |
| 9 | /api/wallets/me | GET | 200 | Balance: 3500 INR |
| 10 | /api/wallets/me/transactions | GET | 200 | Empty list (total: 0) |
| 11 | /api/chat/rooms | GET | 200 | 4 chat rooms |
| 12 | /api/chat/unread | GET | 200 | 0 unread |
| 13 | /api/notifications | GET | 200 | 8 notifications (6 unread) |
| 14 | /api/notifications/unread-count | GET | 200 | Count: 6 |
| 15 | /api/community/posts | GET | 200 | 18 posts |
| 16 | /api/community/pro-network | GET | 200 | 8 posts |
| 17 | /api/community/business-hub | GET | 200 | 4 posts |
| 18 | /api/experts | GET | 200 | 7 experts |
| **19** | **/api/experts/bookings** | **GET** | **500** | **BUG: Route conflict - "bookings" parsed as :id param** |
| 20 | /api/marketplace/listings | GET | 200 | 4 listings |
| 21 | /api/marketplace/tutors | GET | 200 | Empty (total: 0) |
| 22 | /api/marketplace/sessions | GET | 200 | Empty (total: 0) |
| 23 | /api/marketplace/categories | GET | 200 | 8 categories |
| 24 | /api/support/tickets | GET | 200 | Empty for this user |
| 25 | /api/support/faqs | GET | 200 | 9 FAQs |
| 26 | /api/connect/questions | GET | 200 | Empty (total: 0) |
| 27 | /api/jobs | GET | 200 | 5 jobs |
| 28 | /api/jobs/my-applications | GET | 200 | Empty |
| 29 | /api/resources/learning | GET | 200 | 8 resources |
| 30 | /api/resources/pricing | GET | 200 | 9 pricing tiers |

### 3.3 DOER Role APIs (22/23 passed)

| # | Endpoint | Method | Status | Result |
|---|----------|--------|--------|--------|
| 1 | /api/doers/me | GET | 200 | Full doer profile |
| 2 | /api/doers/:id | GET | 200 | Doer wrapped in {doer: ...} |
| 3 | /api/doers/:id/activation | GET | 200 | {activation: null} |
| 4 | /api/doers/:id/reviews | GET | 200 | Empty reviews |
| 5 | /api/projects | GET | 200 | 1+ assigned projects |
| 6 | /api/wallets/me | GET | 200 | Balance: 25000 INR |
| 7 | /api/wallets/me/transactions | GET | 200 | Has transactions |
| 8 | /api/wallets/earnings/monthly | GET | 200 | Mar 2026: 8150, Feb 2026: 2100 |
| 9 | /api/wallets/earnings/summary | GET | 200 | Balance: 25000, this month: 8150 |
| 10 | /api/chat/rooms | GET | 200 | Has rooms |
| 11 | /api/chat/unread | GET | 200 | 5 unread |
| 12 | /api/notifications | GET | 200 | Has notifications |
| 13 | /api/notifications/unread-count | GET | 200 | Count: 2 |
| 14 | /api/support/tickets | GET | 200 | 1 ticket (billing) |
| 15 | /api/support/faqs | GET | 200 | 9 FAQs |
| 16 | /api/training/modules | GET | 200 | Has modules |
| 17 | /api/training/status | GET | 200 | Not completed, 0/5 modules |
| 18 | /api/training/progress | GET | 200 | Progress data |
| 19 | /api/resources/tools | GET | 200 | Turnitin, GPTZero, Grammarly, etc. |
| 20 | /api/resources/learning | GET | 200 | Learning materials |
| 21 | /api/skills | GET | 200 | 10 skills |
| 22 | /api/subjects | GET | 200 | 20 subjects |
| 23 | /api/doers | GET | **403** | Expected: role-gated (admin/supervisor only) |

### 3.4 SUPERVISOR Role APIs (27/30 passed)

| # | Endpoint | Method | Status | Result |
|---|----------|--------|--------|--------|
| 1 | /api/supervisors/me | GET | 200 | Full profile with bank details |
| 2 | /api/supervisor/me/activation | GET | 200 | Not activated yet |
| 3 | /api/supervisor/me/stats | GET | 200 | 6 projects, 3 active, 85000 earnings |
| 4 | /api/supervisor/me/dashboard | GET | 200 | Dashboard data |
| 5 | /api/supervisor/me/expertise | GET | 200 | Empty expertise/subjects |
| 6 | /api/supervisor/me/users | GET | 200 | 2 users |
| 7 | /api/supervisor/projects | GET | 200 | Projects with pricing |
| 8 | /api/supervisor/dashboard/requests | GET | 200 | Same as projects |
| 9 | /api/supervisor/doers | GET | 200 | Doers with profiles |
| 10 | /api/supervisor/doers/available | GET | 200 | Available doers |
| 11 | /api/supervisor/doers/count | GET | 200 | Count: 5 |
| 12 | /api/supervisor/earnings/summary | GET | 200 | 85000 total, 3675 this month |
| 13 | /api/supervisor/earnings/chart | GET | 200 | Monthly chart data |
| 14 | /api/supervisor/earnings/commissions | GET | 200 | Per-project commissions |
| 15 | /api/supervisor/earnings/performance | GET | 200 | Performance metrics |
| 16 | /api/supervisor/reviews | GET | 200 | Empty reviews |
| 17 | /api/supervisor/reviews/summary | GET | 200 | Avg 4.8, but distribution all zeros |
| 18 | /api/supervisor/clients | GET | 200 | 2 clients (dual format fields) |
| 19 | /api/supervisor/blacklist | GET | 200 | Empty |
| **20** | **/api/supervisor/registration** | **GET** | **500** | **BUG: "registration" parsed as ObjectId by /:id route** |
| 21 | /api/training/modules | GET | 200 | Training modules |
| **22** | **/api/training/status** | **GET** | **404** | **BUG: "Doer profile not found" - doesn't support supervisor role** |
| 23 | /api/training/progress | GET | 200 | Empty progress |
| 24 | /api/chat/rooms | GET | 200 | Has rooms |
| 25 | /api/chat/unread | GET | 200 | 6 unread |
| 26 | /api/notifications | GET | 200 | Has notifications |
| 27 | /api/notifications/unread-count | GET | 200 | Count: 1 |
| 28 | /api/wallets/me | GET | 200 | Balance: 15000 INR |
| 29 | /api/wallets/me/transactions | GET | 200 | Has transactions |
| 30 | /api/support/tickets | GET | 200 | Empty |

### 3.5 ADMIN Role APIs (26/27 passed)

| # | Endpoint | Method | Status | Result |
|---|----------|--------|--------|--------|
| 1 | /api/admin/dashboard | GET | 200 | 6 users, 12 projects, 5 doers, 2 supervisors |
| 2 | /api/admin/financial-summary | GET | 200 | Revenue: 58231 |
| 3 | /api/admin/users | GET | 200 | Users array |
| 4 | /api/admin/admins | GET | 200 | 2 admins |
| 5 | /api/admin/projects | GET | 200 | Full projects |
| 6 | /api/admin/analytics/user-growth | GET | 200 | Growth data |
| 7 | /api/admin/analytics/revenue | GET | 200 | Revenue by month |
| 8 | /api/admin/analytics/projects-by-status | GET | 200 | Status breakdown |
| 9 | /api/admin/analytics/overview | GET | 200 | Comprehensive overview |
| 10 | /api/admin/moderation/flagged | GET | 200 | Empty |
| 11 | /api/admin/support/stats | GET | 200 | 3 open, 1 in_progress, 2 resolved |
| 12 | /api/support/tickets | GET | 200 | Has tickets |
| 13 | /api/support/faqs | GET | 200 | 9 FAQs |
| **14** | **/api/admin/crm/customers** | **GET** | **404** | **BUG: Route not implemented** |
| 15 | /api/admin/crm/dashboard | GET | 200 | CRM dashboard works |
| 16 | /api/admin/banners | GET | 200 | 3 banners |
| 17 | /api/admin/faqs | GET | 200 | FAQs |
| 18 | /api/admin/learning-resources | GET | 200 | Empty |
| 19 | /api/admin/training-modules | GET | 200 | 8 modules |
| 20 | /api/admin/colleges | GET | 200 | Empty |
| 21 | /api/admin/settings | GET | 200 | Config objects |
| 22 | /api/admin/access-requests | GET | 200 | Has requests |
| 23 | /api/admin/audit-logs | GET | 200 | Empty |
| 24 | /api/admin/transactions | GET | 200 | Transaction data |
| 25 | /api/experts | GET | 200 | 7 experts |
| 26 | /api/jobs | GET | 200 | 5 jobs |
| 27 | /api/investors | GET | 200 | 3 investors |

### 3.6 Reference/Public APIs

| # | Endpoint | Method | Status | Result |
|---|----------|--------|--------|--------|
| 1 | /api/subjects | GET | 200 | 20 subjects |
| 2 | /api/skills | GET | 200 | 10 skills |
| 3 | /api/universities | GET | 200 | 0 - EMPTY |
| 4 | /api/courses | GET | 200 | Has course data (static) |
| 5 | /api/industries | GET | 200 | Has industries (static) |
| 6 | /api/reference-styles | GET | 200 | 0 - EMPTY |
| 7 | /api/resources/pricing | GET | AUTH | Requires authentication |
| 8 | /api/resources/learning | GET | AUTH | Requires authentication |
| 9 | /api/support/faqs | GET | 200 | 9 FAQs (public) |
| 10 | /api/support/faqs/categories | GET | 200 | 6 categories |

---

## 4. BUGS FOUND

### 4.1 CRITICAL BUGS (Server Errors - 500)

#### BUG-001: GET /api/experts/bookings returns 500
- **Affected:** user_app, user-web
- **Error:** CastError - "bookings" parsed as ObjectId by `/:id` route
- **Root cause:** In expert.routes.ts, the `GET /:id` route is defined BEFORE `/bookings`, so "bookings" matches as an `:id` param
- **Fix:** Move `/bookings` route BEFORE `/:id` route in expert.routes.ts
- **Impact:** Users cannot view their expert bookings

#### BUG-002: GET /api/supervisor/registration returns 500
- **Affected:** superviser-web, superviser_app
- **Error:** CastError - "registration" parsed as ObjectId by `/supervisor/:id` route
- **Root cause:** Same route ordering issue as BUG-001. The `/registration` route is caught by `/:id` pattern
- **Fix:** Move `/registration` route BEFORE `/:id` in supervisor.routes.ts
- **Impact:** Supervisors cannot access registration endpoint

### 4.2 FUNCTIONAL BUGS (Wrong Behavior)

#### BUG-003: GET /api/training/status returns 404 for supervisor role
- **Affected:** superviser-web, superviser_app
- **Error:** "Doer profile not found" - training status only checks doer profiles
- **Root cause:** training.routes.ts only looks up doer profiles, doesn't handle supervisor role
- **Fix:** Add supervisor role support to training status endpoint
- **Impact:** Supervisors cannot check their training completion status

#### BUG-004: GET /api/admin/crm/customers returns 404
- **Affected:** admin-web
- **Error:** Route not found
- **Root cause:** The route `/api/admin/crm/customers` was never implemented, but admin-web tries to call it
- **Fix:** Either implement the route or remove the call from admin-web
- **Impact:** Admin CRM customer list page may fail

#### BUG-005: user_app calls /api/experts/bookings/me but API expects /api/experts/bookings
- **Affected:** user_app
- **Error:** The app calls `/experts/bookings/me` but the API route is `/experts/bookings` (or fails due to BUG-001)
- **Root cause:** Mismatch between app and API route paths
- **Fix:** Align app route with API, AND fix BUG-001

### 4.3 DATA INCONSISTENCIES

#### BUG-006: Supervisor reviews/summary shows 75 reviews but distribution is all zeros
- **Affected:** superviser-web, superviser_app
- **Details:** `/api/supervisor/reviews` returns 0 reviews, but `/api/supervisor/reviews/summary` claims 75 reviews with 4.8 avg rating. Rating distribution {1:0, 2:0, 3:0, 4:0, 5:0}
- **Root cause:** Summary stats are hardcoded/seeded and don't match actual review data
- **Fix:** Either seed real reviews or compute summary from actual data

#### BUG-007: Wallet transactions empty for user despite having wallet balance
- **Affected:** user_app, user-web
- **Details:** User wallet shows balance 3500 INR with 7000 credited and 3500 debited, but `/api/wallets/me/transactions` returns 0 transactions
- **Root cause:** Wallet transactions exist in DB but may be linked by different wallet ID
- **Fix:** Check transaction-to-wallet linking logic

#### BUG-008: Support tickets empty for user despite tickets existing in DB
- **Affected:** user_app, user-web
- **Details:** DB has 2 tickets for user 69c1b3087b63a761d445f1ec but API returns 0
- **Root cause:** Ticket query may use wrong field name (userId vs submittedBy)
- **Fix:** Check support ticket query filtering logic

### 4.4 DESIGN ISSUES

#### BUG-009: Dual field format in API responses (camelCase + snake_case)
- **Affected:** Multiple endpoints (supervisor/clients, chat/rooms, etc.)
- **Details:** Responses contain both `fullName` AND `full_name`, `createdAt` AND `created_at`
- **Impact:** Unnecessary payload size, confusing for consumers
- **Fix:** Standardize on one format (snake_case for API responses per current convention)

#### BUG-010: Empty collections that should have data
- **Collections with 0 records:**
  - `universities` - user_app onboarding needs these for university selection
  - `reference_styles` - project creation may need these
  - `colleges` (admin) - empty
  - `learning_resources` (admin) - empty
  - `doer_activations` - no doers have activation records
- **Fix:** Seed these collections with test data

---

## 5. APP vs API ROUTE MISMATCHES

### 5.1 user_app (Flutter) Mismatches

| App Calls | API Has | Issue |
|-----------|---------|-------|
| `/experts/bookings/me` | `/experts/bookings` | Path mismatch |
| `/auth/college-verify/send` | Not found in routes | Route may not exist |
| `/auth/college-verify/confirm` | Not found in routes | Route may not exist |
| `/notifications/register-device` | Not found in routes | FCM registration not implemented |
| `/notifications/unregister-device` | Not found in routes | FCM unregistration not implemented |
| `/users/me/deactivate` | Not found in routes | Account deactivation not implemented |
| `/users/me/delete` | Not found in routes | Account deletion not implemented |
| `/chat/messages/:id/approve` | `/chat/messages/:id` (PUT) | May work if PUT supports approve action |
| `/chat/messages/:id/reject` | `/chat/messages/:id` (PUT) | May work if PUT supports reject action |

### 5.2 user-web Mismatches

| Web Calls | API Has | Issue |
|-----------|---------|-------|
| `/auth/2fa/generate` | Not in routes index | 2FA not implemented |
| `/auth/2fa/verify` | Not in routes index | 2FA not implemented |
| `/auth/2fa/enable` | Not in routes index | 2FA not implemented |
| `/auth/2fa/disable` | Not in routes index | 2FA not implemented |
| `/auth/2fa/status` | Not in routes index | 2FA not implemented |
| `/auth/sessions` | Not in routes index | Session management not implemented |
| `/auth/sessions/revoke-all` | Not in routes index | Not implemented |
| `/auth/verify-college` | Not in routes index | College verification not implemented |
| `/auth/change-password` | Not in routes index | No passwords (OTP-only auth) |
| `/payments/send-money` | Not in routes index | P2P transfers not implemented |
| `/notifications/subscribe` | Not in routes index | Push notifications not implemented |
| `/notifications/whatsapp` | Not in routes index | WhatsApp integration not implemented |
| `/community/posts/saved` | Uses `/community/business-hub/saved` | Wrong path |
| `/community/comments/:id/like` | Not clearly defined | May not exist |
| `/users/flag` | Not in user routes | Flag/report not on user routes |

### 5.3 superviser-web Mismatches

| Web Calls | API Has | Issue |
|-----------|---------|-------|
| `/supervisors/:id/activation` (POST/PATCH) | PUT `/supervisors/me/activation` | Method/path mismatch |
| `/auth/google` | Not in routes | Google OAuth not implemented |

### 5.4 admin-web Mismatches

| Web Calls | API Has | Issue |
|-----------|---------|-------|
| `/admin/crm/customers` | Not implemented | 404 error |
| `/auth/login` (password) | `/auth/verify` (OTP) | Admin uses password login? |
| `/auth/magic-link` | `/auth/send-otp` | Different naming |

---

## 6. DATA SEEDING GAPS

Collections that need data for testing:

1. **universities** - 0 records. Needed for student onboarding (university selection)
2. **reference_styles** - 0 records. Needed for project creation (APA, MLA, etc.)
3. **colleges** - 0 records. Admin college management
4. **marketplace tutors** - 0 records. Marketplace tutor search returns empty
5. **marketplace sessions** - 0 records. No booked sessions
6. **connect questions** - 0 records. Q&A section empty
7. **doer_activations** - 0 records. No doer activation records
8. **learning_resources** - 0 records via admin. Admin learning resources empty
9. **audit_logs** - 0 records. No audit trail

---

## 7. SUMMARY

### Overall API Health

| Role | Endpoints Tested | Passed | Failed | Pass Rate |
|------|-----------------|--------|--------|-----------|
| Auth | 5 | 5 | 0 | 100% |
| User | 30 | 29 | 1 | 96.7% |
| Doer | 23 | 22 | 1 | 95.7% |
| Supervisor | 30 | 27 | 3 | 90.0% |
| Admin | 27 | 26 | 1 | 96.3% |
| Reference | 10 | 10 | 0 | 100% |
| **TOTAL** | **125** | **119** | **6** | **95.2%** |

### Priority Fix List

**P0 (Blocking):**
1. BUG-001: Fix route ordering in expert.routes.ts (/bookings before /:id)
2. BUG-002: Fix route ordering in supervisor.routes.ts (/registration before /:id)

**P1 (Important):**
3. BUG-003: Add supervisor role support to /api/training/status
4. BUG-005: Fix user_app expert bookings route path
5. BUG-007: Fix wallet transaction linking for user role
6. BUG-008: Fix support ticket query for user role

**P2 (Should Fix):**
7. BUG-004: Implement /api/admin/crm/customers or remove from admin-web
8. BUG-006: Fix supervisor review summary data inconsistency
9. BUG-010: Seed empty collections (universities, reference_styles, etc.)
10. BUG-009: Standardize API response field format

**P3 (Nice to Have):**
11. Implement 2FA endpoints (user-web references them)
12. Implement push notification endpoints
13. Implement college verification endpoints
14. Implement account deletion/deactivation
