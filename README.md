# AssignX

A full-stack academic services platform connecting students and professionals with expert doers and supervisors. Built with Flutter (mobile), Next.js (web), and Express + MongoDB (backend).

## Architecture

```
AssignX/
├── api-server/          # Express.js API (Node.js + TypeScript + MongoDB)
├── user-web/            # Student/Professional portal (Next.js 16)
├── user_app/            # Student/Professional mobile app (Flutter)
├── superviser-web/      # Supervisor portal (Next.js 16)
├── superviser_app/      # Supervisor mobile app (Flutter)
├── doer-web/            # Doer portal (Next.js 16)
├── doer_app/            # Doer mobile app (Flutter)
├── admin-web/           # Admin dashboard (Next.js 16)
└── docs/                # API docs, plans, architecture
```

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile Apps | Flutter 3.x, Riverpod, GoRouter |
| Web Apps | Next.js 16, React, TypeScript, Tailwind CSS |
| Backend API | Express.js, TypeScript, Mongoose |
| Database | MongoDB Atlas |
| Payments | Razorpay |
| Auth | OTP-based passwordless (JWT) |
| Real-time | Socket.IO |

## Features

### For Students and Professionals (user_app / user-web)
- OTP-based passwordless authentication
- Project creation wizard with type-specific fields (assignment, document, website, app, consultancy)
- Real-time chat with supervisors
- Expert consultation booking with Razorpay payments
- Campus Connect community feed
- Job Portal and Investor directory
- Wallet and payment management

### For Supervisors (superviser_app / superviser-web)
- Dashboard with new requests, quoted, paid, and active projects
- Project quoting and doer assignment
- Quality control review workflow
- Earnings tracking and payout management
- Doer management and blacklisting

### For Doers (doer_app / doer-web)
- Open pool project browsing
- Project workspace with deliverable uploads
- Earnings dashboard and withdrawal requests
- Training resources and skill verification

### Admin Panel (admin-web)
- User, supervisor, and doer management
- Access request approval workflow
- Expert and job/investor management
- Community post moderation
- Platform analytics

## Getting Started

### Prerequisites
- Node.js 18+
- Flutter 3.x SDK
- MongoDB (Atlas or local)
- Razorpay account (for payments)

### API Server
```bash
cd api-server
cp .env.example .env  # Configure MongoDB URI, JWT secrets, Razorpay keys
npm install
npx ts-node-dev --transpile-only --respawn src/index.ts
# Runs on http://localhost:4000
```

### Web Apps
```bash
# User Web
cd user-web && npm install && npx next dev --port 3000 --turbopack

# Supervisor Web
cd superviser-web && npm install && npx next dev --port 3001 --turbopack

# Admin Web
cd admin-web && npm install && npx next dev --port 3002 --turbopack

# Doer Web
cd doer-web && npm install && npx next dev --port 3003 --turbopack
```

### Mobile Apps
```bash
# User App
cd user_app && flutter pub get && flutter run

# Supervisor App
cd superviser_app && flutter pub get && flutter run

# Doer App
cd doer_app && flutter pub get && flutter run
```

## API Endpoints

| Prefix | Description |
|--------|------------|
| `/api/auth` | Authentication (OTP, login, signup) |
| `/api/projects` | Project CRUD and lifecycle |
| `/api/experts` | Expert consultations and bookings |
| `/api/community` | Campus Connect, Pro Network, Business Hub |
| `/api/jobs` | Job listings |
| `/api/investors` | Investor directory |
| `/api/wallets` | Wallet, transactions, withdrawals |
| `/api/supervisor` | Supervisor-specific operations |
| `/api/admin` | Admin panel operations |

Full OpenAPI spec available at `api-server/openapi.yaml`

## Environment Variables

### API Server (.env)
```
MONGODB_URI=mongodb+srv://...
JWT_SECRET=your-jwt-secret
JWT_REFRESH_SECRET=your-refresh-secret
RAZORPAY_KEY_ID=rzp_test_...
RAZORPAY_KEY_SECRET=...
CLOUDINARY_URL=cloudinary://...
```

### Web Apps (.env.local)
```
NEXT_PUBLIC_API_URL=http://localhost:4000
```

## Database

MongoDB with collections: users, doers, supervisors, admins, projects, experts, expert_bookings, community_posts, jobs, investors, wallets, notifications, and more.

## License

Proprietary - All rights reserved
