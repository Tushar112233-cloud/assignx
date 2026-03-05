# Database Restructure Design — Eliminate Centralized Profiles

## Goal

Remove the `profiles` God collection. Each role (user, doer, supervisor, admin) becomes a fully independent collection with its own auth fields. No shared identity layer.

## Current Problem

- `profiles` is referenced by 18+ collections
- Two-level ID system causes confusion (profile `_id` vs role collection `_id`)
- JWT `sub` points to profiles, but business logic needs role-specific IDs
- A doer signup creates 2 documents unnecessarily

## New Architecture

### Principle

Each role collection owns its identity: email, fullName, phone, refreshTokens, lastLoginAt. JWT `sub` = role collection `_id`. No cross-collection identity.

Same email can exist across roles (user + doer). Auth tokens scoped by `email + role`.

### Collections

#### Auth & Identity

| Collection | Purpose | Signup |
|-----------|---------|--------|
| `users` | Clients (student/professional/business) | Free, `userType` enum |
| `doers` | Workers | Needs admin approval + training |
| `supervisors` | QC reviewers | Needs admin approval + training |
| `admins` | System admins | Standalone, no profile link |
| `auth_tokens` | OTP tokens | Scoped by `email + role` |
| `access_requests` | Pending applications | `role`: doer/supervisor |

#### Projects & Work

| Collection | References |
|-----------|-----------|
| `projects` | `userId` -> users, `doerId` -> doers, `supervisorId` -> supervisors |
| `user_doer_reviews` | `userId` -> users, `doerId` -> doers |
| `supervisor_doer_reviews` | `supervisorId` -> supervisors, `doerId` -> doers |

#### Chat

| Collection | Pattern |
|-----------|---------|
| `chat_rooms` | `participants: [{ id, role, joinedAt, lastSeenAt }]` |
| `chat_messages` | `senderId` + `senderRole`, `readBy: [{ id, role }]` |

#### Financial

| Collection | Owner |
|-----------|-------|
| `user_wallets` | `userId` -> users |
| `doer_wallets` | `doerId` -> doers |
| `supervisor_wallets` | `supervisorId` -> supervisors |
| `wallet_transactions` | `walletId` + `walletType` (user/doer/supervisor) |
| `payout_requests` | `recipientId` + `recipientRole` (doer/supervisor) |

#### Training & Activation (doers + supervisors only)

| Collection | Pattern |
|-----------|---------|
| `training_modules` | `targetRole`: doer/supervisor |
| `quiz_questions` | `targetRole`: doer/supervisor |
| `training_progress` | `userId` + `userRole` |
| `quiz_attempts` | `userId` + `userRole` |
| `doer_activations` | `doerId` -> doers |
| `supervisor_activations` | `supervisorId` -> supervisors |

#### Notifications & Support

| Collection | Pattern |
|-----------|---------|
| `notifications` | `recipientId` + `recipientRole` |
| `support_tickets` | `raisedById` + `raisedByRole`, `assignedTo` -> admins |

#### Community & Marketplace (users only)

| Collection | References |
|-----------|-----------|
| `community_posts` | `userId` -> users |
| `post_interactions` | `userId` -> users |
| `marketplace_listings` | `userId` -> users |
| `experts` | standalone |
| `expert_bookings` | `userId` -> users |

#### Admin & Audit

| Collection | Pattern |
|-----------|---------|
| `audit_logs` | `actorId` + `actorRole` |

#### Reference Data (unchanged)

`skills`, `subjects`, `universities`, `colleges`, `reference_styles`, `format_templates`, `learning_resources`, `banners`, `faqs`, `app_settings`, `marketplace_categories`

### Key Design Decisions

1. **No shared profiles** — each role owns auth fields
2. **Same email across roles** — allowed, separate accounts
3. **auth_tokens scoped** — `email + role` composite
4. **Chat uses `{ id, role }`** — flexible for multi-role rooms
5. **Split wallets** — `user_wallets`, `doer_wallets`, `supervisor_wallets`
6. **Unified transactions** — one `wallet_transactions` with `walletType`
7. **Split reviews** — `user_doer_reviews` vs `supervisor_doer_reviews`
8. **Community = users only** — no role field needed
9. **Training = role-specific** — `targetRole` on modules/questions
10. **Audit = all roles** — `actorId + actorRole`

### Migration Impact

- Delete `profiles` collection after migration
- Delete `students` collection (merged into `users`)
- Delete `professionals` collection (merged into `users`)
- Update all 4 frontends (user-web, doer-web, supervisor-web, admin-web)
- Update API server: models, routes, middleware, JWT payload
- JWT payload changes: `sub` = role collection `_id`, `role` = user/doer/supervisor/admin
