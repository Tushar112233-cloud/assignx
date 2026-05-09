# AssignX

Academic services marketplace connecting students with expert doers and supervisors.

## Architecture

```
AssignX/
├── api-server/            Express.js API         :4000
├── user-web/              Student portal (web)    :3000
├── superviser-web/        Supervisor portal (web) :3001
├── admin-web/             Admin dashboard (web)   :3002
├── doer-web/              Doer portal (web)       :3003
├── user_app/              Student app (mobile)
├── superviser_app/        Supervisor app (mobile)
└── doer_app/              Doer app (mobile)
```

## Tech Stack

| Layer    | Technology                                        |
| -------- | ------------------------------------------------- |
| Backend  | Express.js, TypeScript, Mongoose, MongoDB Atlas   |
| Web      | Next.js 16.1.1, React 19, TypeScript, Tailwind CSS, Turbopack |
| Mobile   | Flutter 3.x, Riverpod, GoRouter                   |
| Auth     | OTP-based passwordless login (JWT access + refresh tokens) |
| Payments | Razorpay                                          |
| Realtime | Socket.IO                                         |
| Storage  | Cloudinary                                        |
| Email    | Resend                                            |

## Prerequisites

- Node.js 18+
- npm 9+
- Flutter 3.x SDK (for mobile apps)
- MongoDB Atlas cluster (or local MongoDB 7+)
- Razorpay test/live keys (for payment flows)
- Cloudinary account (for file uploads)

## Getting Started

### 1. API Server

```bash
cd api-server
npm install

# Create .env from the template below, then:
npm run dev
# => http://localhost:4000
```

The dev script runs `ts-node-dev --respawn --transpile-only src/index.ts` with auto-restart on file changes.

For production:

```bash
npm run build
npm start
```

### 2. Web Apps

Each web app is an independent Next.js 16 project. Install and run them separately:

```bash
# Student portal
cd user-web
npm install
npx next dev --port 3000 --turbopack

# Supervisor portal
cd superviser-web
npm install
npx next dev --port 3001 --turbopack

# Admin dashboard
cd admin-web
npm install
npx next dev --port 3002 --turbopack

# Doer portal
cd doer-web
npm install
npx next dev --port 3003 --turbopack
```

Each web app requires a `.env.local` file (see Environment Variables below).

### 3. Mobile Apps

```bash
# Student app
cd user_app
flutter pub get
flutter run

# Supervisor app
cd superviser_app
flutter pub get
flutter run

# Doer app
cd doer_app
flutter pub get
flutter run
```

### 4. Mobile Release Builds (All 3 Apps)

Use the root build script to generate release APK + AAB for `user_app`, `doer_app`, and `superviser_app` in one go:

```powershell
cd D:\SoftwareEngineering\assignx
.\build_all_release.ps1
```

Release artifacts are copied to:

- `release/user_app`
- `release/doer_app`
- `release/superviser_app`

## Environment Variables

### API Server (`api-server/.env`)

| Variable                | Description                          |
| ----------------------- | ------------------------------------ |
| `NODE_ENV`              | `development` or `production`        |
| `PORT`                  | Server port (default: 4000)          |
| `MONGODB_URI`           | MongoDB connection string            |
| `JWT_SECRET`            | Access token signing secret          |
| `JWT_REFRESH_SECRET`    | Refresh token signing secret         |
| `JWT_ACCESS_EXPIRY`     | Access token TTL (e.g. `15m`)        |
| `JWT_REFRESH_EXPIRY`    | Refresh token TTL (e.g. `7d`)        |
| `RAZORPAY_KEY_ID`       | Razorpay key ID                      |
| `RAZORPAY_KEY_SECRET`   | Razorpay key secret                  |
| `CLOUDINARY_CLOUD_NAME` | Cloudinary cloud name                |
| `CLOUDINARY_API_KEY`    | Cloudinary API key                   |
| `CLOUDINARY_API_SECRET` | Cloudinary API secret                |
| `RESEND_API_KEY`        | Resend email API key                 |
| `RESEND_FROM_EMAIL`     | Sender email address                 |
| `CORS_ORIGINS`          | Comma-separated allowed origins      |
| `USER_WEB_URL`          | User web app URL for email links     |

### Web Apps (`<app>/.env.local`)

| Variable               | Description                          |
| ---------------------- | ------------------------------------ |
| `NEXT_PUBLIC_API_URL`  | API server URL (e.g. `http://localhost:4000`) |

## API Overview

All endpoints are prefixed with `/api`. The route structure:

| Prefix              | Description                              |
| ------------------- | ---------------------------------------- |
| `/api/auth`         | Authentication (send OTP, verify, refresh) |
| `/api/users`        | User/student profiles                    |
| `/api/doers`        | Doer profiles and management             |
| `/api/supervisors`  | Supervisor profiles and operations       |
| `/api/projects`     | Project CRUD and lifecycle               |
| `/api/chat`         | Real-time messaging                      |
| `/api/wallets`      | Wallet balances, transactions, withdrawals |
| `/api/payments`     | Razorpay payment processing              |
| `/api/experts`      | Expert consultations and bookings        |
| `/api/community`    | Campus Connect social feed               |
| `/api/connect`      | Pro Network and Business Hub             |
| `/api/jobs`         | Job portal listings                      |
| `/api/investors`    | Investor directory                       |
| `/api/marketplace`  | Service marketplace                      |
| `/api/training`     | Doer training resources                  |
| `/api/resources`    | Reference materials and guides           |
| `/api/notifications`| Push and in-app notifications            |
| `/api/upload`       | File uploads (Cloudinary)                |
| `/api/support`      | Support tickets                          |
| `/api/admin`        | Admin panel operations                   |
| `/api/access-requests` | Role access request workflow          |

## License

Proprietary. All rights reserved.
