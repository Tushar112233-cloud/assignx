# AssignX: Supabase to MongoDB Migration Design

## 1. Overview

Migrate the entire AssignX platform (7 apps/websites) from Supabase (PostgreSQL + Auth + Storage + Realtime) to MongoDB with JWT authentication, Cloudinary file storage, Socket.IO realtime, and a shared Express.js API server.

### Platforms
1. **user-web** (Next.js) - Student/User portal
2. **doer-web** (Next.js) - Task doer portal
3. **superviser-web** (Next.js) - Supervisor portal
4. **admin-web** (Next.js) - Admin panel
5. **user_app** (Flutter) - User mobile app
6. **doer_app** (Flutter) - Doer mobile app
7. **superviser_app** (Flutter) - Supervisor mobile app

### Technology Stack (Post-Migration)
- **Database**: MongoDB Atlas (connection: `mongodb+srv://omrajpal:1122334455@cluster0.tva2yqz.mongodb.net/AssignX`)
- **Auth**: Custom JWT (access + refresh tokens) with magic link via Resend
- **File Storage**: Cloudinary (already configured)
- **Realtime**: Socket.IO server
- **API Layer**: Shared Express.js + Mongoose + Socket.IO
- **Token Storage**: localStorage (web), SharedPreferences (Flutter)

---

## 2. Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                      CLIENT PLATFORMS                         │
├───────────┬───────────┬───────────┬───────────┬──────────────┤
│ user-web  │ doer-web  │ super-web │ admin-web │  Flutter x3  │
│ (Next.js) │ (Next.js) │ (Next.js) │ (Next.js) │ (user/doer/  │
│ :3001     │ :3000     │ :3000     │ :3002     │  supervisor)  │
└─────┬─────┴─────┬─────┴─────┬─────┴─────┬─────┴──────┬───────┘
      │           │           │           │            │
      └───────────┴───────────┴───────────┴────────────┘
                              │
                       ┌──────┴───────┐
                       │  Shared API  │
                       │  Express.js  │
                       │  :4000       │
                       ├──────────────┤
                       │  Socket.IO   │
                       │  (realtime)  │
                       ├──────────────┤
                       │  Mongoose    │
                       │  (MongoDB)   │
                       ├──────────────┤
                       │  JWT Auth    │
                       │  Middleware  │
                       └──────┬───────┘
                              │
                 ┌────────────┼────────────┐
                 │            │            │
            ┌────┴────┐ ┌────┴────┐ ┌────┴──────┐
            │ MongoDB │ │Cloudinary│ │  Resend   │
            │ Atlas   │ │ (files)  │ │  (email)  │
            │ AssignX │ │          │ │           │
            └─────────┘ └─────────┘ └───────────┘
```

### API Server Structure (`api-server/`)
```
api-server/
├── package.json
├── tsconfig.json
├── src/
│   ├── index.ts                    # Entry point
│   ├── config/
│   │   ├── database.ts             # MongoDB connection
│   │   ├── cloudinary.ts           # Cloudinary config
│   │   ├── resend.ts               # Resend email config
│   │   └── socket.ts               # Socket.IO setup
│   ├── middleware/
│   │   ├── auth.ts                 # JWT validation
│   │   ├── roleGuard.ts            # Role-based access
│   │   ├── rateLimiter.ts          # Rate limiting
│   │   └── errorHandler.ts         # Global error handler
│   ├── models/                     # Mongoose schemas
│   │   ├── Profile.ts
│   │   ├── Doer.ts
│   │   ├── Supervisor.ts
│   │   ├── Admin.ts
│   │   ├── Project.ts
│   │   ├── ChatRoom.ts
│   │   ├── ChatMessage.ts
│   │   ├── Wallet.ts
│   │   ├── WalletTransaction.ts
│   │   ├── Notification.ts
│   │   ├── SupportTicket.ts
│   │   ├── AuthToken.ts
│   │   ├── ... (remaining models)
│   │   └── index.ts
│   ├── routes/
│   │   ├── auth.routes.ts          # Auth endpoints
│   │   ├── profile.routes.ts       # Profile CRUD
│   │   ├── project.routes.ts       # Project management
│   │   ├── chat.routes.ts          # Chat operations
│   │   ├── wallet.routes.ts        # Financial operations
│   │   ├── notification.routes.ts  # Notification endpoints
│   │   ├── support.routes.ts       # Support tickets
│   │   ├── admin.routes.ts         # Admin operations
│   │   ├── community.routes.ts     # Campus/Pro/Business posts
│   │   ├── marketplace.routes.ts   # Marketplace
│   │   ├── upload.routes.ts        # File uploads
│   │   └── index.ts
│   ├── services/
│   │   ├── auth.service.ts         # Auth logic
│   │   ├── email.service.ts        # Resend integration
│   │   ├── jwt.service.ts          # JWT generation/validation
│   │   ├── upload.service.ts       # Cloudinary uploads
│   │   └── ... (business logic)
│   ├── socket/
│   │   ├── index.ts                # Socket.IO init
│   │   ├── chat.handler.ts         # Chat events
│   │   ├── notification.handler.ts # Notification events
│   │   ├── presence.handler.ts     # Online presence
│   │   └── typing.handler.ts       # Typing indicators
│   └── utils/
│       ├── constants.ts
│       ├── validators.ts
│       └── helpers.ts
```

---

## 3. Authentication System

### Magic Link Flow
```
1. POST /api/auth/magic-link { email }
   → Generate 6-digit OTP
   → Store in auth_tokens collection (TTL: 10 min)
   → Send email via Resend API
   → Return { success: true, message: "Check your email" }

2. POST /api/auth/verify { email, otp }
   → Validate OTP from auth_tokens
   → Find or create profile in profiles collection
   → Generate JWT access token (7 days) + refresh token (30 days)
   → Store refresh token hash in profiles.refresh_tokens[]
   → Return { accessToken, refreshToken, profile }

3. POST /api/auth/refresh { refreshToken }
   → Validate refresh token
   → Generate new access + refresh tokens
   → Return { accessToken, refreshToken }

4. POST /api/auth/logout { refreshToken }
   → Remove refresh token from profiles.refresh_tokens[]
   → Return { success: true }
```

### JWT Structure
```json
{
  "sub": "ObjectId",
  "email": "user@example.com",
  "role": "user|doer|supervisor|admin",
  "iat": 1234567890,
  "exp": 1234567890
}
```

### Auth Middleware
```typescript
// Every request:
// 1. Extract Bearer token from Authorization header
// 2. Verify JWT signature
// 3. Check expiration
// 4. Attach user to request: req.user = { id, email, role }
// 5. Role guard: check req.user.role against allowed roles
```

### Token Storage
- **Web (Next.js)**: localStorage for tokens, httpOnly cookie for SSR
- **Flutter**: SharedPreferences (encrypted with flutter_secure_storage)

---

## 4. MongoDB Collections Schema

### 4.1 Authentication
```javascript
// auth_tokens (TTL collection - auto-deletes after 10 min)
{
  _id: ObjectId,
  email: String,
  otp: String,          // hashed 6-digit code
  type: "magic_link",
  expiresAt: Date,      // TTL index
  createdAt: Date
}
```

### 4.2 User Management
```javascript
// profiles
{
  _id: ObjectId,
  email: String,         // unique index
  fullName: String,
  phone: String,
  phoneVerified: Boolean,
  avatarUrl: String,
  userType: "user" | "doer" | "supervisor" | "admin",
  onboardingStep: Number,
  onboardingCompleted: Boolean,
  twoFactorEnabled: Boolean,
  twoFactorSecret: String,
  refreshTokens: [{ token: String, expiresAt: Date }],
  lastLoginAt: Date,
  createdAt: Date,
  updatedAt: Date
}

// students (embedded or separate based on user_type)
{
  _id: ObjectId,
  profileId: ObjectId,   // ref → profiles
  universityId: ObjectId,
  courseId: ObjectId,
  semester: Number,
  yearOfStudy: Number,
  studentIdNumber: String,
  expectedGraduationYear: Number,
  collegeEmail: String,
  collegeEmailVerified: Boolean,
  preferredSubjects: [ObjectId]
}

// professionals
{
  _id: ObjectId,
  profileId: ObjectId,
  professionalType: String,
  industryId: ObjectId,
  jobTitle: String,
  companyName: String,
  linkedinUrl: String,
  businessType: String,
  gstNumber: String
}

// doers
{
  _id: ObjectId,
  profileId: ObjectId,      // ref → profiles
  qualification: "high_school" | "undergraduate" | "postgraduate" | "phd",
  universityName: String,
  experienceLevel: "beginner" | "intermediate" | "pro",
  yearsOfExperience: Number,
  bio: String,
  isAvailable: Boolean,
  maxConcurrentProjects: Number,
  isActivated: Boolean,
  activatedAt: Date,
  totalEarnings: Number,
  totalProjectsCompleted: Number,
  averageRating: Number,
  totalReviews: Number,
  successRate: Number,
  onTimeDeliveryRate: Number,
  bankDetails: {
    accountName: String,
    accountNumber: String,  // encrypted
    ifscCode: String,
    bankName: String,
    upiId: String,
    verified: Boolean
  },
  skills: [{ skillId: ObjectId, proficiencyLevel: String, isVerified: Boolean }],
  subjects: [{ subjectId: ObjectId, isPrimary: Boolean }],
  isFlagged: Boolean,
  flagReason: String,
  isAccessGranted: Boolean,
  createdAt: Date,
  updatedAt: Date
}

// supervisors
{
  _id: ObjectId,
  profileId: ObjectId,
  qualification: String,
  yearsOfExperience: Number,
  bio: String,
  isActive: Boolean,
  isAccessGranted: Boolean,
  // ... similar structure to doers
}

// admins
{
  _id: ObjectId,
  profileId: ObjectId,
  email: String,
  adminRole: "super_admin" | "admin" | "moderator" | "support" | "viewer",
  permissions: Object,
  isActive: Boolean,
  lastActiveAt: Date,
  createdAt: Date,
  updatedAt: Date
}
```

### 4.3 Projects
```javascript
// projects
{
  _id: ObjectId,
  projectNumber: String,
  userId: ObjectId,          // ref → profiles (client)
  serviceType: String,
  title: String,
  subjectId: ObjectId,
  topic: String,
  description: String,
  wordCount: Number,
  pageCount: Number,
  referenceStyleId: ObjectId,
  specificInstructions: String,
  focusAreas: [String],
  deadline: Date,
  originalDeadline: Date,
  deadlineExtended: Boolean,
  status: String,            // see enum list
  statusUpdatedAt: Date,
  supervisorId: ObjectId,
  doerId: ObjectId,
  pricing: {
    userQuote: Number,
    doerPayout: Number,
    supervisorCommission: Number,
    platformFee: Number
  },
  payment: {
    isPaid: Boolean,
    paidAt: Date,
    paymentId: String
  },
  delivery: {
    deliveredAt: Date,
    expectedDeliveryAt: Date,
    autoApproveAt: Date,
    completedAt: Date,
    completionNotes: String
  },
  qualityCheck: {
    aiReportUrl: String,
    aiScore: Number,
    plagiarismReportUrl: String,
    plagiarismScore: Number,
    liveDocumentUrl: String
  },
  progressPercentage: Number,
  userApproval: {
    approved: Boolean,
    approvedAt: Date,
    feedback: String,
    grade: String
  },
  cancellation: {
    cancelledAt: Date,
    cancelledBy: ObjectId,
    reason: String
  },
  files: [{
    fileName: String,
    fileUrl: String,
    fileType: String,
    fileSizeBytes: Number,
    fileCategory: String,
    uploadedBy: ObjectId,
    createdAt: Date
  }],
  deliverables: [{
    fileName: String,
    fileUrl: String,
    fileType: String,
    fileSizeBytes: Number,
    version: Number,
    qcStatus: "pending" | "in_review" | "approved" | "rejected",
    qcNotes: String,
    qcAt: Date,
    qcBy: ObjectId,
    uploadedBy: ObjectId,
    createdAt: Date
  }],
  revisions: [{
    requestedBy: ObjectId,
    requestedByType: String,
    revisionNumber: Number,
    feedback: String,
    specificChanges: String,
    responseNotes: String,
    status: "pending" | "in_progress" | "completed" | "cancelled",
    createdAt: Date,
    completedAt: Date
  }],
  statusHistory: [{
    fromStatus: String,
    toStatus: String,
    changedBy: ObjectId,
    notes: String,
    createdAt: Date
  }],
  source: String,
  createdAt: Date,
  updatedAt: Date
}
```

### 4.4 Chat
```javascript
// chat_rooms
{
  _id: ObjectId,
  projectId: ObjectId,
  roomType: "project_user_supervisor" | "project_supervisor_doer" | "project_all" | "support" | "direct",
  name: String,
  participants: [{
    profileId: ObjectId,
    role: "user" | "supervisor" | "doer" | "admin",
    joinedAt: Date,
    lastSeenAt: Date,
    lastReadMessageId: ObjectId,
    isMuted: Boolean,
    isActive: Boolean
  }],
  lastMessageAt: Date,
  createdAt: Date,
  updatedAt: Date
}

// chat_messages
{
  _id: ObjectId,
  chatRoomId: ObjectId,     // ref → chat_rooms
  senderId: ObjectId,       // ref → profiles
  messageType: "text" | "file" | "image" | "system" | "revision" | "action",
  content: String,
  file: {
    url: String,
    name: String,
    type: String,
    sizeBytes: Number
  },
  replyToId: ObjectId,
  isEdited: Boolean,
  isDeleted: Boolean,
  isFlagged: Boolean,
  flaggedReason: String,
  containsContactInfo: Boolean,
  readBy: [ObjectId],
  createdAt: Date
}
```

### 4.5 Financial
```javascript
// wallets
{
  _id: ObjectId,
  profileId: ObjectId,      // unique ref → profiles
  balance: Number,
  currency: "INR",
  totalCredited: Number,
  totalDebited: Number,
  totalWithdrawn: Number,
  lockedAmount: Number,
  createdAt: Date,
  updatedAt: Date
}

// wallet_transactions
{
  _id: ObjectId,
  walletId: ObjectId,
  transactionType: String,  // project_earning, bonus, payout, refund, etc.
  amount: Number,
  status: "pending" | "completed" | "failed" | "reversed",
  description: String,
  referenceId: String,
  referenceType: String,
  balanceBefore: Number,
  balanceAfter: Number,
  createdAt: Date
}

// payout_requests
{
  _id: ObjectId,
  recipientId: ObjectId,
  amount: Number,
  payoutMethod: "bank_transfer" | "upi",
  status: "pending" | "approved" | "rejected" | "processing" | "completed",
  rejectionReason: String,
  createdAt: Date,
  reviewedAt: Date,
  reviewedBy: ObjectId
}
```

### 4.6 Notifications & Support
```javascript
// notifications
{
  _id: ObjectId,
  userId: ObjectId,
  type: String,
  title: String,
  message: String,
  data: Object,
  isRead: Boolean,
  createdAt: Date,
  readAt: Date
}

// support_tickets
{
  _id: ObjectId,
  userId: ObjectId,
  userName: String,
  subject: String,
  description: String,
  category: String,
  priority: String,
  status: "open" | "in_progress" | "resolved" | "closed",
  assignedTo: ObjectId,
  messages: [{
    senderId: ObjectId,
    senderName: String,
    senderRole: String,
    message: String,
    attachmentUrl: String,
    createdAt: Date
  }],
  createdAt: Date,
  updatedAt: Date,
  resolvedAt: Date
}
```

### 4.7 Community
```javascript
// community_posts (unified for campus, pro_network, business_hub)
{
  _id: ObjectId,
  userId: ObjectId,
  postType: "campus" | "pro_network" | "business_hub",
  title: String,
  content: String,
  imageUrl: String,
  category: String,
  tags: [String],
  viewCount: Number,
  likeCount: Number,
  commentCount: Number,
  saveCount: Number,
  isFlagged: Boolean,
  isActive: Boolean,
  comments: [{
    userId: ObjectId,
    content: String,
    parentId: ObjectId,
    likeCount: Number,
    isFlagged: Boolean,
    createdAt: Date
  }],
  createdAt: Date,
  updatedAt: Date
}

// post_interactions (likes, saves - separate for query performance)
{
  _id: ObjectId,
  postId: ObjectId,
  userId: ObjectId,
  type: "like" | "save",
  createdAt: Date
}
```

### 4.8 Reference Data
```javascript
// subjects, skills, universities, colleges, reference_styles,
// training_modules, quiz_questions, faqs, banners, app_settings,
// learning_resources, format_templates, marketplace_categories
// → All stay as separate collections with same fields as Supabase
```

### 4.9 Activation & Training
```javascript
// doer_activation, supervisor_activation, training_progress, quiz_attempts
// → Stay as separate collections with same fields
```

---

## 5. Socket.IO Events

### Channels
```
chat:${roomId}          → New messages, edits, deletes
typing:${roomId}        → Typing indicators
presence:${roomId}      → Online/offline status
notifications:${userId} → Push notifications
wallet:${userId}        → Balance updates
projects:${userId}      → Project status changes
```

### Authentication
```
// Client connects with JWT token
const socket = io('http://localhost:4000', {
  auth: { token: jwtToken }
});

// Server validates on connection
io.use((socket, next) => {
  const token = socket.handshake.auth.token;
  // verify JWT, attach user to socket
});
```

---

## 6. API Routes

### Auth
- `POST /api/auth/magic-link` - Send magic link email
- `POST /api/auth/verify` - Verify OTP and get tokens
- `POST /api/auth/refresh` - Refresh access token
- `POST /api/auth/logout` - Invalidate refresh token
- `GET  /api/auth/me` - Get current user profile

### Profiles
- `GET    /api/profiles/:id` - Get profile
- `PUT    /api/profiles/:id` - Update profile
- `POST   /api/profiles/avatar` - Upload avatar
- `POST   /api/profiles/student` - Create student profile
- `POST   /api/profiles/professional` - Create professional profile

### Projects
- `GET    /api/projects` - List projects (filtered by role)
- `POST   /api/projects` - Create project
- `GET    /api/projects/:id` - Get project detail
- `PUT    /api/projects/:id` - Update project
- `PUT    /api/projects/:id/status` - Update status
- `POST   /api/projects/:id/files` - Upload files
- `POST   /api/projects/:id/deliverables` - Submit deliverable
- `POST   /api/projects/:id/revisions` - Request revision

### Chat
- `GET    /api/chat/rooms` - List chat rooms
- `GET    /api/chat/rooms/:id/messages` - Get messages
- `POST   /api/chat/rooms/:id/messages` - Send message
- `PUT    /api/chat/rooms/:id/read` - Mark as read

### Wallets
- `GET    /api/wallets/me` - Get wallet
- `GET    /api/wallets/me/transactions` - Transaction history
- `POST   /api/wallets/transfer` - Transfer funds
- `POST   /api/wallets/payout-request` - Request payout

### Admin
- `GET    /api/admin/dashboard` - Dashboard stats
- `GET    /api/admin/users` - User management
- `GET    /api/admin/projects` - Project oversight
- `GET    /api/admin/financial-summary` - Financial reports
- `POST   /api/admin/refund` - Process refund
- (... remaining admin endpoints)

---

## 7. Migration Phases

### Phase 0: Foundation (api-server setup)
- Create `api-server/` directory
- Set up Express + TypeScript + Mongoose
- Connect to MongoDB Atlas
- Set up Socket.IO
- Implement JWT auth middleware
- Implement magic link auth flow with Resend
- Create all Mongoose models
- Set up Cloudinary upload service
- **Test**: Auth flow works end-to-end

### Phase 1: Auth Migration (all platforms)
- Replace Supabase auth with JWT in all Next.js apps
- Replace Supabase auth in all Flutter apps
- Implement token storage (localStorage/SharedPreferences)
- Update middleware in all web apps
- **Test**: Login/logout works on all 7 platforms

### Phase 2: Profiles & User Management
- Migrate profiles, students, professionals tables
- Migrate doers, supervisors, admins tables
- Migrate skills, subjects, universities tables
- Update all profile CRUD operations
- **Test**: Profile creation, editing, onboarding flows

### Phase 3: Projects
- Migrate projects, project_files, project_deliverables
- Migrate project_revisions, project_status_history
- Update all project operations across platforms
- **Test**: Create, assign, deliver, review projects

### Phase 4: Chat & Realtime
- Implement Socket.IO chat handlers
- Migrate chat_rooms, chat_messages, chat_participants
- Replace Supabase realtime with Socket.IO
- Implement typing indicators, presence
- **Test**: Real-time chat works across platforms

### Phase 5: Financial
- Migrate wallets, wallet_transactions
- Migrate payout_requests, payouts, payment_methods
- Implement wallet RPC equivalents as API routes
- **Test**: Wallet balance, transactions, payouts

### Phase 6: Community & Social
- Migrate campus_posts, pro_network_posts, business_hub_posts
- Migrate all likes, comments, saves
- Migrate marketplace_listings
- **Test**: Post, like, comment, save across platforms

### Phase 7: Support & Admin
- Migrate support_tickets, ticket_messages, faqs
- Migrate notifications
- Migrate admin-specific tables (audit_logs, settings)
- Migrate banners, learning_resources, training
- **Test**: Full admin panel, support system

### Phase 8: Cleanup & Verification
- Remove all Supabase dependencies
- Remove Supabase env variables
- Run comprehensive E2E tests
- Performance testing
- **Test**: Everything works without Supabase

---

## 8. Environment Variables (Post-Migration)

### All Web Apps
```env
# MongoDB
MONGODB_URI=mongodb+srv://omrajpal:1122334455@cluster0.tva2yqz.mongodb.net/AssignX
# API Server
NEXT_PUBLIC_API_URL=http://localhost:4000
# JWT
JWT_SECRET=<generate-strong-secret>
JWT_REFRESH_SECRET=<generate-strong-secret>
# Resend
RESEND_API_KEY=re_bycmvGEm_FbmHX43jsqBaz5Krt7czJnkJ
RESEND_FROM_EMAIL=AssignX <noreply@assignx.com>
# Cloudinary
CLOUDINARY_CLOUD_NAME=drknn3ujj
CLOUDINARY_API_KEY=<key>
CLOUDINARY_API_SECRET=<secret>
# Razorpay (unchanged)
RAZORPAY_KEY_ID=rzp_test_Rv45IObrwfKRyf
RAZORPAY_KEY_SECRET=p2ZIwNBpnf1Gh7icvCm6oicD
```

### Flutter Apps
```env
API_BASE_URL=http://localhost:4000
```

---

## 9. MongoDB Indexes

```javascript
// Critical indexes for performance
db.profiles.createIndex({ email: 1 }, { unique: true });
db.profiles.createIndex({ userType: 1 });
db.doers.createIndex({ profileId: 1 }, { unique: true });
db.doers.createIndex({ isAvailable: 1, isActivated: 1 });
db.supervisors.createIndex({ profileId: 1 }, { unique: true });
db.projects.createIndex({ userId: 1, status: 1 });
db.projects.createIndex({ doerId: 1, status: 1 });
db.projects.createIndex({ supervisorId: 1, status: 1 });
db.projects.createIndex({ deadline: 1 });
db.projects.createIndex({ createdAt: -1 });
db.chat_messages.createIndex({ chatRoomId: 1, createdAt: -1 });
db.chat_rooms.createIndex({ projectId: 1 });
db.wallets.createIndex({ profileId: 1 }, { unique: true });
db.wallet_transactions.createIndex({ walletId: 1, createdAt: -1 });
db.notifications.createIndex({ userId: 1, isRead: 1, createdAt: -1 });
db.auth_tokens.createIndex({ expiresAt: 1 }, { expireAfterSeconds: 0 });
db.community_posts.createIndex({ postType: 1, createdAt: -1 });
db.post_interactions.createIndex({ postId: 1, userId: 1, type: 1 }, { unique: true });
db.support_tickets.createIndex({ userId: 1, status: 1 });
```

---

## 10. RPC Function Equivalents

Supabase RPC functions become Express API endpoints:

| Supabase RPC | API Endpoint | Method |
|---|---|---|
| `admin_get_dashboard_stats` | `/api/admin/dashboard` | GET |
| `admin_get_users` | `/api/admin/users` | GET |
| `admin_get_projects` | `/api/admin/projects` | GET |
| `admin_get_financial_summary` | `/api/admin/financial-summary` | GET |
| `admin_get_transaction_ledger` | `/api/admin/transactions/:profileId` | GET |
| `admin_process_refund` | `/api/admin/refund` | POST |
| `admin_get_ticket_stats` | `/api/admin/support/stats` | GET |
| `get_user_growth_chart_data` | `/api/admin/analytics/user-growth` | GET |
| `get_revenue_chart_data` | `/api/admin/analytics/revenue` | GET |
| `admin_projects_by_status` | `/api/admin/analytics/projects-by-status` | GET |
| `process_wallet_transfer` | `/api/wallets/transfer` | POST |
| `process_wallet_topup` | `/api/wallets/topup` | POST |
| `process_wallet_project_payment` | `/api/payments/wallet-pay` | POST |
| `process_razorpay_project_payment` | `/api/payments/razorpay-verify` | POST |
| `mark_messages_as_read` | `/api/chat/rooms/:id/read` | PUT |
| `increment_field` / `decrement_field` | Handled in respective POST/DELETE routes | - |
| `get_monthly_earnings` | `/api/wallets/earnings/monthly` | GET |
| `get_earnings_summary` | `/api/wallets/earnings/summary` | GET |
