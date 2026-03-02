# Supabase to MongoDB Migration - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Migrate the entire AssignX platform (7 apps) from Supabase to MongoDB with JWT auth, Cloudinary storage, Socket.IO realtime, and a shared Express.js API server.

**Architecture:** A shared Express.js API server (`api-server/`) sits between all clients and MongoDB. All 7 platforms (3 Next.js web apps, 1 admin panel, 3 Flutter apps) call this API. Auth uses JWT tokens with magic link email via Resend. Realtime uses Socket.IO. Files go to Cloudinary.

**Tech Stack:** Express.js, Mongoose, Socket.IO, JWT (jsonwebtoken), bcryptjs, Resend, Cloudinary, MongoDB Atlas, Next.js (existing), Flutter (existing)

**Design Doc:** `docs/plans/2026-03-02-supabase-to-mongodb-migration-design.md`

**MongoDB Connection:** `mongodb+srv://omrajpal:1122334455@cluster0.tva2yqz.mongodb.net/AssignX`

---

## Phase 0: API Server Foundation

### Task 0.1: Initialize api-server project

**Files:**
- Create: `api-server/package.json`
- Create: `api-server/tsconfig.json`
- Create: `api-server/.env`
- Create: `api-server/src/index.ts`

**Step 1: Create project structure**

```bash
cd "/Volumes/Crucial X9/AssignX"
mkdir -p api-server/src/{config,middleware,models,routes,services,socket,utils}
cd api-server
npm init -y
```

**Step 2: Install dependencies**

```bash
npm install express mongoose socket.io jsonwebtoken bcryptjs resend cloudinary multer cors dotenv helmet morgan express-rate-limit cookie-parser
npm install -D typescript @types/express @types/jsonwebtoken @types/bcryptjs @types/cors @types/multer @types/cookie-parser @types/morgan ts-node-dev @types/node
```

**Step 3: Create tsconfig.json**

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

**Step 4: Create .env**

```env
PORT=4000
NODE_ENV=development
MONGODB_URI=mongodb+srv://omrajpal:1122334455@cluster0.tva2yqz.mongodb.net/AssignX?retryWrites=true&w=majority&appName=Cluster0
JWT_SECRET=assignx-jwt-secret-change-in-production-2026
JWT_REFRESH_SECRET=assignx-refresh-secret-change-in-production-2026
JWT_ACCESS_EXPIRY=7d
JWT_REFRESH_EXPIRY=30d
RESEND_API_KEY=re_bycmvGEm_FbmHX43jsqBaz5Krt7czJnkJ
RESEND_FROM_EMAIL=AssignX <noreply@assignx.com>
CLOUDINARY_CLOUD_NAME=drknn3ujj
CLOUDINARY_API_KEY=
CLOUDINARY_API_SECRET=
RAZORPAY_KEY_ID=rzp_test_Rv45IObrwfKRyf
RAZORPAY_KEY_SECRET=p2ZIwNBpnf1Gh7icvCm6oicD
CORS_ORIGINS=http://localhost:3000,http://localhost:3001,http://localhost:3002,http://localhost:3003
```

**Step 5: Create src/index.ts (entry point)**

```typescript
import express from 'express';
import http from 'http';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import cookieParser from 'cookie-parser';
import dotenv from 'dotenv';
import { connectDB } from './config/database';
import { initSocket } from './config/socket';
import { errorHandler } from './middleware/errorHandler';
import routes from './routes';

dotenv.config();

const app = express();
const server = http.createServer(app);

// Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.CORS_ORIGINS?.split(',') || ['http://localhost:3000'],
  credentials: true,
}));
app.use(morgan('dev'));
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());

// Routes
app.use('/api', routes);

// Health check
app.get('/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Error handler
app.use(errorHandler);

// Start
const PORT = process.env.PORT || 4000;

async function start() {
  await connectDB();
  initSocket(server);
  server.listen(PORT, () => {
    console.log(`API server running on port ${PORT}`);
  });
}

start().catch(console.error);

export default app;
```

**Step 6: Update package.json scripts**

Add to `api-server/package.json`:
```json
{
  "scripts": {
    "dev": "ts-node-dev --respawn --transpile-only src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js"
  }
}
```

**Step 7: Commit**

```bash
git add api-server/
git commit -m "feat: initialize api-server with Express + TypeScript scaffold"
```

---

### Task 0.2: Database connection + Mongoose setup

**Files:**
- Create: `api-server/src/config/database.ts`
- Create: `api-server/src/config/cloudinary.ts`
- Create: `api-server/src/config/resend.ts`
- Create: `api-server/src/config/socket.ts`

**Step 1: Create database.ts**

```typescript
import mongoose from 'mongoose';

export async function connectDB(): Promise<void> {
  const uri = process.env.MONGODB_URI;
  if (!uri) throw new Error('MONGODB_URI not set');

  try {
    await mongoose.connect(uri);
    console.log('MongoDB connected to AssignX database');
  } catch (error) {
    console.error('MongoDB connection error:', error);
    process.exit(1);
  }

  mongoose.connection.on('error', (err) => {
    console.error('MongoDB connection error:', err);
  });

  mongoose.connection.on('disconnected', () => {
    console.warn('MongoDB disconnected');
  });
}
```

**Step 2: Create cloudinary.ts**

```typescript
import { v2 as cloudinary } from 'cloudinary';

export function initCloudinary() {
  cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
  });
  return cloudinary;
}

export { cloudinary };
```

**Step 3: Create resend.ts**

```typescript
import { Resend } from 'resend';

let resendClient: Resend;

export function getResend(): Resend {
  if (!resendClient) {
    const apiKey = process.env.RESEND_API_KEY;
    if (!apiKey) throw new Error('RESEND_API_KEY not set');
    resendClient = new Resend(apiKey);
  }
  return resendClient;
}
```

**Step 4: Create socket.ts**

```typescript
import { Server as SocketIOServer } from 'socket.io';
import http from 'http';
import { verifyToken } from '../services/jwt.service';

let io: SocketIOServer;

export function initSocket(server: http.Server): SocketIOServer {
  io = new SocketIOServer(server, {
    cors: {
      origin: process.env.CORS_ORIGINS?.split(',') || ['http://localhost:3000'],
      credentials: true,
    },
  });

  // Auth middleware for socket connections
  io.use(async (socket, next) => {
    const token = socket.handshake.auth.token;
    if (!token) return next(new Error('Authentication required'));

    try {
      const payload = verifyToken(token);
      (socket as any).user = payload;
      next();
    } catch {
      next(new Error('Invalid token'));
    }
  });

  io.on('connection', (socket) => {
    const user = (socket as any).user;
    console.log(`User connected: ${user.sub} (${user.role})`);

    // Join user-specific room for notifications
    socket.join(`user:${user.sub}`);

    socket.on('disconnect', () => {
      console.log(`User disconnected: ${user.sub}`);
    });
  });

  return io;
}

export function getIO(): SocketIOServer {
  if (!io) throw new Error('Socket.IO not initialized');
  return io;
}
```

**Step 5: Test MongoDB connection**

```bash
cd api-server && npm run dev
# Expected: "MongoDB connected to AssignX database"
# Expected: "API server running on port 4000"
# Test: curl http://localhost:4000/health
# Expected: {"status":"ok","timestamp":"..."}
```

**Step 6: Commit**

```bash
git add api-server/src/config/
git commit -m "feat: add database, cloudinary, resend, and socket.io configs"
```

---

### Task 0.3: Core middleware

**Files:**
- Create: `api-server/src/middleware/auth.ts`
- Create: `api-server/src/middleware/roleGuard.ts`
- Create: `api-server/src/middleware/rateLimiter.ts`
- Create: `api-server/src/middleware/errorHandler.ts`
- Create: `api-server/src/services/jwt.service.ts`

**Step 1: Create jwt.service.ts**

```typescript
import jwt from 'jsonwebtoken';

export interface JWTPayload {
  sub: string;       // user ID
  email: string;
  role: 'user' | 'doer' | 'supervisor' | 'admin';
}

export function generateAccessToken(payload: JWTPayload): string {
  return jwt.sign(payload, process.env.JWT_SECRET!, {
    expiresIn: process.env.JWT_ACCESS_EXPIRY || '7d',
  });
}

export function generateRefreshToken(payload: JWTPayload): string {
  return jwt.sign(payload, process.env.JWT_REFRESH_SECRET!, {
    expiresIn: process.env.JWT_REFRESH_EXPIRY || '30d',
  });
}

export function verifyToken(token: string): JWTPayload {
  return jwt.verify(token, process.env.JWT_SECRET!) as JWTPayload;
}

export function verifyRefreshToken(token: string): JWTPayload {
  return jwt.verify(token, process.env.JWT_REFRESH_SECRET!) as JWTPayload;
}
```

**Step 2: Create auth.ts middleware**

```typescript
import { Request, Response, NextFunction } from 'express';
import { verifyToken, JWTPayload } from '../services/jwt.service';

declare global {
  namespace Express {
    interface Request {
      user?: JWTPayload;
    }
  }
}

export function authenticate(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'No token provided' });
  }

  const token = authHeader.substring(7);
  try {
    req.user = verifyToken(token);
    next();
  } catch {
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
}

// Optional auth - doesn't fail if no token
export function optionalAuth(req: Request, _res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;
  if (authHeader?.startsWith('Bearer ')) {
    try {
      req.user = verifyToken(authHeader.substring(7));
    } catch { /* ignore */ }
  }
  next();
}
```

**Step 3: Create roleGuard.ts**

```typescript
import { Request, Response, NextFunction } from 'express';

export function requireRole(...roles: string[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required' });
    }
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }
    next();
  };
}
```

**Step 4: Create rateLimiter.ts**

```typescript
import rateLimit from 'express-rate-limit';

export const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10,
  message: { error: 'Too many auth attempts, try again later' },
});

export const apiLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 100,
  message: { error: 'Too many requests, try again later' },
});

export const paymentLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 5,
  message: { error: 'Too many payment requests, try again later' },
});
```

**Step 5: Create errorHandler.ts**

```typescript
import { Request, Response, NextFunction } from 'express';

export class AppError extends Error {
  statusCode: number;
  constructor(message: string, statusCode: number = 500) {
    super(message);
    this.statusCode = statusCode;
  }
}

export function errorHandler(err: Error, _req: Request, res: Response, _next: NextFunction) {
  console.error('Error:', err.message);

  if (err instanceof AppError) {
    return res.status(err.statusCode).json({ error: err.message });
  }

  // Mongoose validation error
  if (err.name === 'ValidationError') {
    return res.status(400).json({ error: err.message });
  }

  // Mongoose duplicate key
  if ((err as any).code === 11000) {
    return res.status(409).json({ error: 'Duplicate entry' });
  }

  res.status(500).json({ error: 'Internal server error' });
}
```

**Step 6: Create routes/index.ts placeholder**

```typescript
import { Router } from 'express';

const router = Router();

// Routes will be added as we build each module
// router.use('/auth', authRoutes);
// router.use('/profiles', profileRoutes);
// etc.

export default router;
```

**Step 7: Commit**

```bash
git add api-server/src/middleware/ api-server/src/services/jwt.service.ts api-server/src/routes/index.ts
git commit -m "feat: add JWT, auth middleware, role guards, rate limiting, error handler"
```

---

### Task 0.4: Mongoose Models - Auth & Profiles

**Files:**
- Create: `api-server/src/models/AuthToken.ts`
- Create: `api-server/src/models/Profile.ts`
- Create: `api-server/src/models/Student.ts`
- Create: `api-server/src/models/Professional.ts`
- Create: `api-server/src/models/Doer.ts`
- Create: `api-server/src/models/Supervisor.ts`
- Create: `api-server/src/models/Admin.ts`
- Create: `api-server/src/models/index.ts`

**Step 1: Create each model file**

Refer to the design doc section 4.1 and 4.2 for exact field schemas. Each model follows Mongoose schema pattern:

```typescript
// Example: api-server/src/models/Profile.ts
import mongoose, { Schema, Document } from 'mongoose';

export interface IProfile extends Document {
  email: string;
  fullName: string;
  phone?: string;
  phoneVerified: boolean;
  avatarUrl?: string;
  userType: 'user' | 'doer' | 'supervisor' | 'admin';
  onboardingStep: number;
  onboardingCompleted: boolean;
  twoFactorEnabled: boolean;
  twoFactorSecret?: string;
  refreshTokens: { token: string; expiresAt: Date }[];
  lastLoginAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

const profileSchema = new Schema<IProfile>({
  email: { type: String, required: true, unique: true, lowercase: true, trim: true },
  fullName: { type: String, default: '' },
  phone: String,
  phoneVerified: { type: Boolean, default: false },
  avatarUrl: String,
  userType: { type: String, enum: ['user', 'doer', 'supervisor', 'admin'], required: true },
  onboardingStep: { type: Number, default: 0 },
  onboardingCompleted: { type: Boolean, default: false },
  twoFactorEnabled: { type: Boolean, default: false },
  twoFactorSecret: String,
  refreshTokens: [{ token: String, expiresAt: Date }],
  lastLoginAt: Date,
}, { timestamps: true });

profileSchema.index({ email: 1 }, { unique: true });
profileSchema.index({ userType: 1 });

export const Profile = mongoose.model<IProfile>('Profile', profileSchema);
```

Create similar models for AuthToken (with TTL index), Student, Professional, Doer (with embedded skills/subjects), Supervisor, Admin. See design doc for all fields.

**Step 2: Create models/index.ts barrel export**

```typescript
export { Profile } from './Profile';
export { AuthToken } from './AuthToken';
export { Student } from './Student';
export { Professional } from './Professional';
export { Doer } from './Doer';
export { Supervisor } from './Supervisor';
export { Admin } from './Admin';
```

**Step 3: Test models compile**

```bash
cd api-server && npm run dev
# Expected: No compilation errors, server starts
```

**Step 4: Commit**

```bash
git add api-server/src/models/
git commit -m "feat: add Mongoose models for auth and user profiles"
```

---

### Task 0.5: Mongoose Models - Projects, Chat, Financial, Community

**Files:**
- Create: `api-server/src/models/Project.ts`
- Create: `api-server/src/models/ChatRoom.ts`
- Create: `api-server/src/models/ChatMessage.ts`
- Create: `api-server/src/models/Wallet.ts`
- Create: `api-server/src/models/WalletTransaction.ts`
- Create: `api-server/src/models/PayoutRequest.ts`
- Create: `api-server/src/models/Notification.ts`
- Create: `api-server/src/models/SupportTicket.ts`
- Create: `api-server/src/models/CommunityPost.ts`
- Create: `api-server/src/models/PostInteraction.ts`
- Create: `api-server/src/models/Subject.ts`
- Create: `api-server/src/models/Skill.ts`
- Create: `api-server/src/models/University.ts`
- Create: `api-server/src/models/Banner.ts`
- Create: `api-server/src/models/FAQ.ts`
- Create: `api-server/src/models/AppSetting.ts`
- Create: `api-server/src/models/TrainingModule.ts`
- Create: `api-server/src/models/TrainingProgress.ts`
- Create: `api-server/src/models/QuizQuestion.ts`
- Create: `api-server/src/models/QuizAttempt.ts`
- Create: `api-server/src/models/DoerActivation.ts`
- Create: `api-server/src/models/DoerReview.ts`
- Create: `api-server/src/models/MarketplaceListing.ts`
- Create: `api-server/src/models/Expert.ts`
- Create: `api-server/src/models/ExpertBooking.ts`
- Create: `api-server/src/models/LearningResource.ts`
- Create: `api-server/src/models/AuditLog.ts`

Refer to design doc sections 4.3-4.8 for all schemas. Follow same Mongoose pattern as Task 0.4.

**Step 1: Create all model files per design doc schemas**

**Step 2: Update models/index.ts with all exports**

**Step 3: Test compilation**

```bash
cd api-server && npm run dev
```

**Step 4: Commit**

```bash
git add api-server/src/models/
git commit -m "feat: add all remaining Mongoose models (projects, chat, financial, community)"
```

---

### Task 0.6: Auth routes + email service

**Files:**
- Create: `api-server/src/services/email.service.ts`
- Create: `api-server/src/services/auth.service.ts`
- Create: `api-server/src/routes/auth.routes.ts`
- Modify: `api-server/src/routes/index.ts`

**Step 1: Create email.service.ts**

```typescript
import { getResend } from '../config/resend';

export async function sendMagicLinkEmail(email: string, otp: string): Promise<void> {
  const resend = getResend();
  const fromEmail = process.env.RESEND_FROM_EMAIL || 'AssignX <noreply@assignx.com>';

  await resend.emails.send({
    from: fromEmail,
    to: email,
    subject: `Your AssignX login code: ${otp}`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2>Welcome to AssignX</h2>
        <p>Your login code is:</p>
        <h1 style="font-size: 36px; letter-spacing: 8px; text-align: center; background: #f0f0f0; padding: 20px; border-radius: 8px;">${otp}</h1>
        <p>This code expires in 10 minutes.</p>
        <p>If you didn't request this, you can safely ignore this email.</p>
      </div>
    `,
  });
}
```

**Step 2: Create auth.service.ts**

```typescript
import crypto from 'crypto';
import bcrypt from 'bcryptjs';
import { AuthToken } from '../models/AuthToken';
import { Profile } from '../models/Profile';
import { generateAccessToken, generateRefreshToken, verifyRefreshToken } from './jwt.service';
import { sendMagicLinkEmail } from './email.service';

export async function sendMagicLink(email: string): Promise<void> {
  // Generate 6-digit OTP
  const otp = crypto.randomInt(100000, 999999).toString();
  const hashedOtp = await bcrypt.hash(otp, 10);

  // Delete any existing tokens for this email
  await AuthToken.deleteMany({ email });

  // Store token with TTL
  await AuthToken.create({
    email: email.toLowerCase().trim(),
    otp: hashedOtp,
    type: 'magic_link',
    expiresAt: new Date(Date.now() + 10 * 60 * 1000), // 10 minutes
  });

  // Send email
  await sendMagicLinkEmail(email, otp);
}

export async function verifyOTP(email: string, otp: string): Promise<{
  accessToken: string;
  refreshToken: string;
  profile: any;
  isNewUser: boolean;
}> {
  const normalizedEmail = email.toLowerCase().trim();

  // Find token
  const authToken = await AuthToken.findOne({
    email: normalizedEmail,
    expiresAt: { $gt: new Date() },
  });

  if (!authToken) {
    throw new Error('Invalid or expired OTP');
  }

  // Verify OTP
  const isValid = await bcrypt.compare(otp, authToken.otp);
  if (!isValid) {
    throw new Error('Invalid OTP');
  }

  // Delete used token
  await AuthToken.deleteOne({ _id: authToken._id });

  // Find or create profile
  let profile = await Profile.findOne({ email: normalizedEmail });
  let isNewUser = false;

  if (!profile) {
    profile = await Profile.create({
      email: normalizedEmail,
      userType: 'user', // default, can be changed during onboarding
      onboardingStep: 0,
      onboardingCompleted: false,
    });
    isNewUser = true;
  }

  // Update last login
  profile.lastLoginAt = new Date();

  // Generate tokens
  const payload = {
    sub: profile._id.toString(),
    email: profile.email,
    role: profile.userType as 'user' | 'doer' | 'supervisor' | 'admin',
  };

  const accessToken = generateAccessToken(payload);
  const refreshToken = generateRefreshToken(payload);

  // Store refresh token hash
  const refreshHash = await bcrypt.hash(refreshToken, 10);
  profile.refreshTokens.push({
    token: refreshHash,
    expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
  });

  // Cleanup expired refresh tokens
  profile.refreshTokens = profile.refreshTokens.filter(
    (rt) => rt.expiresAt > new Date()
  );

  await profile.save();

  return { accessToken, refreshToken, profile, isNewUser };
}

export async function refreshTokens(refreshToken: string): Promise<{
  accessToken: string;
  refreshToken: string;
}> {
  const payload = verifyRefreshToken(refreshToken);

  const profile = await Profile.findById(payload.sub);
  if (!profile) throw new Error('User not found');

  // Verify refresh token exists in stored tokens
  const validToken = await Promise.all(
    profile.refreshTokens.map(rt => bcrypt.compare(refreshToken, rt.token))
  );

  if (!validToken.some(Boolean)) {
    throw new Error('Invalid refresh token');
  }

  // Remove old token
  const idx = validToken.indexOf(true);
  profile.refreshTokens.splice(idx, 1);

  // Generate new tokens
  const newPayload = {
    sub: profile._id.toString(),
    email: profile.email,
    role: profile.userType as 'user' | 'doer' | 'supervisor' | 'admin',
  };

  const newAccessToken = generateAccessToken(newPayload);
  const newRefreshToken = generateRefreshToken(newPayload);

  const refreshHash = await bcrypt.hash(newRefreshToken, 10);
  profile.refreshTokens.push({
    token: refreshHash,
    expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
  });

  await profile.save();

  return { accessToken: newAccessToken, refreshToken: newRefreshToken };
}

export async function logout(userId: string, refreshToken: string): Promise<void> {
  const profile = await Profile.findById(userId);
  if (!profile) return;

  const validToken = await Promise.all(
    profile.refreshTokens.map(rt => bcrypt.compare(refreshToken, rt.token))
  );

  const idx = validToken.indexOf(true);
  if (idx >= 0) {
    profile.refreshTokens.splice(idx, 1);
    await profile.save();
  }
}
```

**Step 3: Create auth.routes.ts**

```typescript
import { Router, Request, Response } from 'express';
import { sendMagicLink, verifyOTP, refreshTokens, logout } from '../services/auth.service';
import { authenticate } from '../middleware/auth';
import { authLimiter } from '../middleware/rateLimiter';

const router = Router();

// POST /api/auth/magic-link
router.post('/magic-link', authLimiter, async (req: Request, res: Response) => {
  try {
    const { email } = req.body;
    if (!email) return res.status(400).json({ error: 'Email is required' });

    await sendMagicLink(email);
    res.json({ success: true, message: 'Check your email for the login code' });
  } catch (error: any) {
    res.status(500).json({ error: error.message || 'Failed to send magic link' });
  }
});

// POST /api/auth/verify
router.post('/verify', authLimiter, async (req: Request, res: Response) => {
  try {
    const { email, otp } = req.body;
    if (!email || !otp) return res.status(400).json({ error: 'Email and OTP are required' });

    const result = await verifyOTP(email, otp);
    res.json(result);
  } catch (error: any) {
    res.status(401).json({ error: error.message || 'Verification failed' });
  }
});

// POST /api/auth/refresh
router.post('/refresh', async (req: Request, res: Response) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) return res.status(400).json({ error: 'Refresh token required' });

    const tokens = await refreshTokens(refreshToken);
    res.json(tokens);
  } catch (error: any) {
    res.status(401).json({ error: error.message || 'Token refresh failed' });
  }
});

// POST /api/auth/logout
router.post('/logout', authenticate, async (req: Request, res: Response) => {
  try {
    const { refreshToken } = req.body;
    await logout(req.user!.sub, refreshToken);
    res.json({ success: true });
  } catch {
    res.json({ success: true }); // always succeed for logout
  }
});

// GET /api/auth/me
router.get('/me', authenticate, async (req: Request, res: Response) => {
  try {
    const { Profile } = require('../models');
    const profile = await Profile.findById(req.user!.sub).select('-refreshTokens -twoFactorSecret');
    if (!profile) return res.status(404).json({ error: 'Profile not found' });
    res.json(profile);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

export default router;
```

**Step 4: Wire up in routes/index.ts**

```typescript
import { Router } from 'express';
import authRoutes from './auth.routes';

const router = Router();
router.use('/auth', authRoutes);

export default router;
```

**Step 5: Test the auth flow**

```bash
# Start server
cd api-server && npm run dev

# Test magic link
curl -X POST http://localhost:4000/api/auth/magic-link \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}'
# Expected: {"success":true,"message":"Check your email for the login code"}

# Check MongoDB for auth_tokens collection
```

**Step 6: Commit**

```bash
git add api-server/src/services/ api-server/src/routes/
git commit -m "feat: implement JWT auth with magic link via Resend"
```

---

### Task 0.7: Upload service (Cloudinary)

**Files:**
- Create: `api-server/src/services/upload.service.ts`
- Create: `api-server/src/routes/upload.routes.ts`
- Modify: `api-server/src/routes/index.ts`

**Step 1: Create upload.service.ts**

```typescript
import { v2 as cloudinary } from 'cloudinary';
import { initCloudinary } from '../config/cloudinary';

initCloudinary();

export async function uploadFile(
  fileBuffer: Buffer,
  folder: string,
  options?: { resourceType?: 'image' | 'raw' | 'auto'; publicId?: string }
): Promise<{ url: string; publicId: string }> {
  return new Promise((resolve, reject) => {
    cloudinary.uploader.upload_stream(
      {
        folder: `assignx/${folder}`,
        resource_type: options?.resourceType || 'auto',
        public_id: options?.publicId,
      },
      (error, result) => {
        if (error) return reject(error);
        resolve({ url: result!.secure_url, publicId: result!.public_id });
      }
    ).end(fileBuffer);
  });
}

export async function deleteFile(publicId: string): Promise<void> {
  await cloudinary.uploader.destroy(publicId);
}
```

**Step 2: Create upload.routes.ts**

```typescript
import { Router, Request, Response } from 'express';
import multer from 'multer';
import { authenticate } from '../middleware/auth';
import { uploadFile, deleteFile } from '../services/upload.service';

const router = Router();
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 50 * 1024 * 1024 } });

router.post('/', authenticate, upload.single('file'), async (req: Request, res: Response) => {
  try {
    if (!req.file) return res.status(400).json({ error: 'No file provided' });
    const folder = req.body.folder || 'general';
    const result = await uploadFile(req.file.buffer, folder);
    res.json(result);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

router.delete('/', authenticate, async (req: Request, res: Response) => {
  try {
    const { publicId } = req.body;
    if (!publicId) return res.status(400).json({ error: 'publicId required' });
    await deleteFile(publicId);
    res.json({ success: true });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

export default router;
```

**Step 3: Wire up and commit**

```bash
git add api-server/src/services/upload.service.ts api-server/src/routes/upload.routes.ts
git commit -m "feat: add Cloudinary upload service and routes"
```

---

## Phase 1: Auth Migration - All Platforms

### Task 1.1: Create shared API client for Next.js web apps

**Files:**
- Create: `shared/api-client.ts` (or copy into each web app's `lib/` folder)

**Step 1: Create API client**

For each Next.js app (user-web, doer-web, superviser-web, admin-web), create `lib/api/client.ts`:

```typescript
const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000';

export async function apiClient(
  endpoint: string,
  options: RequestInit = {}
): Promise<any> {
  const token = typeof window !== 'undefined' ? localStorage.getItem('accessToken') : null;

  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...(options.headers as Record<string, string>),
  };

  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  const res = await fetch(`${API_URL}/api${endpoint}`, {
    ...options,
    headers,
  });

  if (res.status === 401) {
    // Try refresh
    const refreshed = await refreshAccessToken();
    if (refreshed) {
      headers['Authorization'] = `Bearer ${localStorage.getItem('accessToken')}`;
      const retryRes = await fetch(`${API_URL}/api${endpoint}`, { ...options, headers });
      if (!retryRes.ok) throw new Error(await retryRes.text());
      return retryRes.json();
    }
    // Redirect to login
    if (typeof window !== 'undefined') window.location.href = '/login';
    throw new Error('Session expired');
  }

  if (!res.ok) {
    const error = await res.json().catch(() => ({ error: 'Request failed' }));
    throw new Error(error.error || 'Request failed');
  }

  return res.json();
}

async function refreshAccessToken(): Promise<boolean> {
  const refreshToken = localStorage.getItem('refreshToken');
  if (!refreshToken) return false;

  try {
    const res = await fetch(`${API_URL}/api/auth/refresh`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refreshToken }),
    });
    if (!res.ok) return false;

    const data = await res.json();
    localStorage.setItem('accessToken', data.accessToken);
    localStorage.setItem('refreshToken', data.refreshToken);
    return true;
  } catch {
    return false;
  }
}
```

**Step 2: Create auth helpers for each web app**

For each web app, create `lib/api/auth.ts`:

```typescript
import { apiClient } from './client';

export async function sendMagicLink(email: string) {
  return apiClient('/auth/magic-link', {
    method: 'POST',
    body: JSON.stringify({ email }),
  });
}

export async function verifyOTP(email: string, otp: string) {
  const result = await apiClient('/auth/verify', {
    method: 'POST',
    body: JSON.stringify({ email, otp }),
  });

  // Store tokens
  localStorage.setItem('accessToken', result.accessToken);
  localStorage.setItem('refreshToken', result.refreshToken);

  return result;
}

export async function logout() {
  const refreshToken = localStorage.getItem('refreshToken');
  try {
    await apiClient('/auth/logout', {
      method: 'POST',
      body: JSON.stringify({ refreshToken }),
    });
  } finally {
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
  }
}

export function getAccessToken(): string | null {
  return typeof window !== 'undefined' ? localStorage.getItem('accessToken') : null;
}

export function isLoggedIn(): boolean {
  return !!getAccessToken();
}
```

**Step 3: Apply to each web app and update login pages**

For each web app:
1. Copy `lib/api/client.ts` and `lib/api/auth.ts`
2. Update login page/form to use new `sendMagicLink()` and `verifyOTP()` instead of Supabase auth
3. Update middleware to check JWT instead of Supabase session
4. Add `NEXT_PUBLIC_API_URL=http://localhost:4000` to `.env.local`

**Step 4: Test login on each web app**

```bash
# Start api-server
cd api-server && npm run dev

# Start user-web
cd user-web && npm run dev

# Navigate to login page, enter email, check for magic link email
# Enter OTP, verify login works
```

**Step 5: Commit per web app**

```bash
git commit -m "feat: migrate user-web auth from Supabase to JWT magic link"
git commit -m "feat: migrate doer-web auth from Supabase to JWT magic link"
git commit -m "feat: migrate superviser-web auth from Supabase to JWT magic link"
git commit -m "feat: migrate admin-web auth from Supabase to JWT magic link"
```

---

### Task 1.2: Create Flutter API client

**Files:**
- Create: `user_app/lib/core/api/api_client.dart`
- Create: `user_app/lib/core/api/auth_api.dart`
- Create: `user_app/lib/core/storage/token_storage.dart`
- (Same for doer_app and superviser_app)

**Step 1: Add dependencies to pubspec.yaml for each Flutter app**

```yaml
dependencies:
  http: ^1.2.0
  shared_preferences: ^2.2.0
  flutter_secure_storage: ^9.0.0
  socket_io_client: ^2.0.3
```

**Step 2: Create token_storage.dart**

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  static Future<String?> getAccessToken() => _storage.read(key: _accessKey);
  static Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);

  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
```

**Step 3: Create api_client.dart**

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/token_storage.dart';

class ApiClient {
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:4000');

  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(String endpoint) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api$endpoint'),
      headers: await _headers(),
    );
    return _handleResponse(res, endpoint, 'GET');
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api$endpoint'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _handleResponse(res, endpoint, 'POST', body);
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final res = await http.put(
      Uri.parse('$baseUrl/api$endpoint'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _handleResponse(res, endpoint, 'PUT', body);
  }

  static Future<dynamic> delete(String endpoint) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/api$endpoint'),
      headers: await _headers(),
    );
    return _handleResponse(res, endpoint, 'DELETE');
  }

  static Future<dynamic> _handleResponse(
    http.Response res,
    String endpoint,
    String method, [
    Map<String, dynamic>? body,
  ]) async {
    if (res.statusCode == 401) {
      // Try refresh
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry original request
        final retryRes = await http.Request(method, Uri.parse('$baseUrl/api$endpoint'))
          ..headers.addAll(await _headers());
        if (body != null) {
          final request = http.Request(method, Uri.parse('$baseUrl/api$endpoint'));
          request.headers.addAll(await _headers());
          request.body = jsonEncode(body);
          final streamedRes = await request.send();
          final retryResponse = await http.Response.fromStream(streamedRes);
          if (retryResponse.statusCode >= 200 && retryResponse.statusCode < 300) {
            return jsonDecode(retryResponse.body);
          }
        }
      }
      throw Exception('Session expired');
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    }

    final error = jsonDecode(res.body);
    throw Exception(error['error'] ?? 'Request failed');
  }

  static Future<bool> _refreshToken() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );
      if (res.statusCode != 200) return false;

      final data = jsonDecode(res.body);
      await TokenStorage.saveTokens(data['accessToken'], data['refreshToken']);
      return true;
    } catch (_) {
      return false;
    }
  }
}
```

**Step 4: Create auth_api.dart**

```dart
import 'api_client.dart';
import '../storage/token_storage.dart';

class AuthApi {
  static Future<void> sendMagicLink(String email) async {
    await ApiClient.post('/auth/magic-link', {'email': email});
  }

  static Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    final result = await ApiClient.post('/auth/verify', {'email': email, 'otp': otp});
    await TokenStorage.saveTokens(result['accessToken'], result['refreshToken']);
    return result;
  }

  static Future<void> logout() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    try {
      await ApiClient.post('/auth/logout', {'refreshToken': refreshToken ?? ''});
    } finally {
      await TokenStorage.clearTokens();
    }
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      return await ApiClient.get('/auth/me');
    } catch (_) {
      return null;
    }
  }
}
```

**Step 5: Repeat for doer_app and superviser_app**

Copy same files into each app's `lib/core/api/` and `lib/core/storage/`.

**Step 6: Update each app's login screen to use AuthApi instead of Supabase**

**Step 7: Commit per app**

---

## Phase 2-7: Remaining Migrations

Each subsequent phase follows the same pattern:

1. **Create API routes** in `api-server/src/routes/` for the module
2. **Create service layer** in `api-server/src/services/` with business logic
3. **Update each web app** - replace Supabase calls with `apiClient()` calls
4. **Update each Flutter app** - replace Supabase repository calls with `ApiClient` calls
5. **Add Socket.IO events** where realtime was used
6. **Test on each platform** - verify data flows correctly
7. **Commit per module per platform**

### Phase 2 Tasks (Profiles):
- Task 2.1: Profile API routes (CRUD, avatar upload)
- Task 2.2: Student/Professional profile creation routes
- Task 2.3: Doer profile + activation routes
- Task 2.4: Supervisor profile + activation routes
- Task 2.5: Skills, subjects, universities reference data routes
- Task 2.6: Migrate user-web profile operations
- Task 2.7: Migrate doer-web profile operations
- Task 2.8: Migrate superviser-web profile operations
- Task 2.9: Migrate admin-web user management
- Task 2.10: Migrate user_app profile operations
- Task 2.11: Migrate doer_app profile operations
- Task 2.12: Migrate superviser_app profile operations

### Phase 3 Tasks (Projects):
- Task 3.1: Project API routes (CRUD, status transitions, file uploads)
- Task 3.2: Project assignment + delivery routes
- Task 3.3: Revision + QC routes
- Task 3.4-3.10: Migrate each platform's project operations

### Phase 4 Tasks (Chat + Realtime):
- Task 4.1: Socket.IO chat event handlers
- Task 4.2: Chat API routes (rooms, messages, read status)
- Task 4.3: Typing indicator + presence handlers
- Task 4.4-4.10: Migrate each platform's chat
- Task 4.11: Replace all Supabase realtime with Socket.IO client

### Phase 5 Tasks (Financial):
- Task 5.1: Wallet API routes
- Task 5.2: Transaction + payout routes
- Task 5.3: Payment processing routes (Razorpay integration)
- Task 5.4-5.10: Migrate each platform

### Phase 6 Tasks (Community):
- Task 6.1: Community posts API (campus, pro, business)
- Task 6.2: Likes, comments, saves API
- Task 6.3: Marketplace API
- Task 6.4-6.10: Migrate each platform

### Phase 7 Tasks (Support + Admin):
- Task 7.1: Support ticket API
- Task 7.2: Notification API + Socket.IO push
- Task 7.3: Admin dashboard + analytics API
- Task 7.4: Admin CRM + moderation API
- Task 7.5: Banners, FAQs, settings, training API
- Task 7.6-7.12: Migrate each platform
- Task 7.13: Remove all Supabase dependencies
- Task 7.14: Remove Supabase env variables
- Task 7.15: Final E2E testing across all platforms

---

## Testing Strategy

### Per-Phase Testing
After each phase migration:
1. **API tests**: Test each endpoint with curl/Postman
2. **Web app tests**: Navigate through flows in browser
3. **Flutter tests**: Run on simulator
4. **Data integrity**: Verify MongoDB documents match expected schema
5. **Cross-platform**: Test that user-created data appears correctly in doer/supervisor views

### E2E Verification (Phase 8)
1. Create user account via magic link on user-web
2. Create project on user-web
3. Assign to doer on admin panel
4. Accept project on doer-web
5. Chat between user and supervisor on superviser-web
6. Submit deliverable on doer_app
7. Review on superviser_app
8. Approve and pay on user_app
9. Check wallet balances across all platforms
10. Verify notifications received on all platforms

---

## Risk Mitigation

- **Data Loss**: No existing data migration needed (fresh MongoDB, not migrating Supabase data)
- **Rollback**: Keep Supabase credentials in env files until Phase 8 cleanup
- **Incremental**: Each phase is independently testable
- **Auth Transition**: New JWT auth works alongside existing until fully switched
