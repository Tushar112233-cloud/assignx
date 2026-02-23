# AssignX Feature Implementation Plan

> **Document Version:** 1.0
> **Created:** January 2026
> **Status:** Planning Phase

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Feature 1: Landing Page Redesign](#feature-1-landing-page-redesign)
3. [Feature 2: Authentication System](#feature-2-authentication-system)
4. [Feature 3: Dashboard Onboarding](#feature-3-dashboard-onboarding)
5. [Feature 4: Campus Connect](#feature-4-campus-connect)
6. [Feature 5: Expert Consultation Flow](#feature-5-expert-consultation-flow)
7. [Database Schema Requirements](#database-schema-requirements)
8. [Implementation Timeline](#implementation-timeline)
9. [Quality Assurance Checklist](#quality-assurance-checklist)

---

## Executive Summary

This document outlines the implementation plan for 5 major features for the AssignX platform:

| Feature | Priority | Complexity | Estimated Components |
|---------|----------|------------|---------------------|
| Landing Page Redesign | High | Medium | 4-5 components |
| Authentication System | Critical | High | 3-4 components + Supabase config |
| Dashboard Onboarding | Medium | Medium | 2-3 components |
| Campus Connect | High | High | 8-10 components + DB tables |
| Expert Consultation | High | High | 6-8 components + DB tables |

---

## Feature 1: Landing Page Redesign

### 1.1 Requirements

**Goal:** Cleaner first impression — simple and beautiful like modern landing pages (Canva, Linear, Vercel style)

#### 1.1.1 Hero Section Updates
- [ ] Simplified, clutter-free design
- [ ] Clear value proposition messaging
- [ ] "Experts handle your tasks end-to-end with proper supervision"
- [ ] Single prominent CTA button

#### 1.1.2 Three User Sections (Card Layout)
Create elegant cards for three user types:

| Card | Target Audience | Key Message |
|------|-----------------|-------------|
| **Students** | College/University students | Assignments, projects, exam prep |
| **Professionals** | Working professionals | Reports, presentations, research |
| **Businessmen** | Entrepreneurs/Business owners | Business plans, proposals, analytics |

**Card Design Specs:**
- Glassmorphism or subtle gradient background
- Icon/illustration representing each category
- 3-4 bullet points of services
- "Get Started" CTA per card

#### 1.1.3 Stats Section
Display trust-building metrics:

| Stat | Value | Icon |
|------|-------|------|
| Success Rate | 98% | CheckCircle |
| Average Delivery | 24 hours | Clock |
| Active Experts | 500+ | Users |
| Projects Completed | 50,000+ | Briefcase |

#### 1.1.4 Banner Messaging
- **Primary Message:** "Expert-handled, Quality-assured"
- **Sub-message:** "Every task supervised by senior specialists"
- Animated text or subtle highlight effect

### 1.2 Files to Create/Modify

```
components/landing/
├── hero-section.tsx          # MODIFY - Simplify design
├── user-type-cards.tsx       # CREATE - Three user cards
├── trust-stats.tsx           # CREATE - Stats banner
└── value-proposition.tsx     # CREATE - Banner messaging
```

---

## Feature 2: Authentication System

### 2.1 Requirements

**Goal:** Modern, passwordless authentication (like Canva, Udemy, Notion)

#### 2.1.1 Magic Link Authentication
- [ ] Email input → Send magic link → User clicks → Logged in
- [ ] No password storage
- [ ] Fresh link generated each login attempt
- [ ] Link expiry: 10 minutes
- [ ] Rate limiting: Max 3 requests per 10 minutes

#### 2.1.2 Google OAuth
- [ ] "Continue with Google" button
- [ ] One-click sign in for returning users
- [ ] Auto-create profile on first Google login

#### 2.1.3 College Email Verification (Students)
- [ ] Student enters college email (.edu, .ac.in, etc.)
- [ ] Magic link sent to college email
- [ ] On verification: `is_college_verified = true`
- [ ] Unlocks Campus Connect features

**Supported College Email Domains:**
```
.edu, .edu.in, .ac.in, .ac.uk, .edu.au, .edu.sg
```

### 2.2 Supabase Configuration

```sql
-- Auth settings to configure in Supabase Dashboard:
-- 1. Enable Email (Magic Link) provider
-- 2. Enable Google OAuth provider
-- 3. Set magic link expiry to 600 seconds
-- 4. Configure redirect URLs
```

### 2.3 Files to Create/Modify

```
app/(auth)/
├── login/
│   └── page.tsx              # MODIFY - Magic link + Google
├── verify-college/
│   └── page.tsx              # CREATE - College verification flow
└── callback/
    └── route.ts              # CREATE - Auth callback handler

components/auth/
├── magic-link-form.tsx       # CREATE - Email input form
├── google-auth-button.tsx    # CREATE - Google sign-in
├── college-verify-form.tsx   # CREATE - College email form
└── auth-layout.tsx           # CREATE - Shared auth layout
```

### 2.4 Database Schema

```sql
-- Add to profiles table
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS
  college_email VARCHAR(255),
  is_college_verified BOOLEAN DEFAULT FALSE,
  college_name VARCHAR(255),
  college_verified_at TIMESTAMP;
```

---

## Feature 3: Dashboard Onboarding

### 3.1 Requirements

**Goal:** Interactive tour/tutorial for first-time users

#### 3.1.1 Tour Steps

| Step | Element | Message |
|------|---------|---------|
| 1 | Welcome | "Welcome to AssignX! Let's show you around." |
| 2 | Create Project | "Start by creating your first project here" |
| 3 | Browse Experts | "Find verified experts for your tasks" |
| 4 | Wallet | "Add funds to start working with experts" |
| 5 | Campus Connect | "Connect with your college community" |
| 6 | Profile | "Complete your profile for better matches" |

#### 3.1.2 Tour Features
- [ ] Step-by-step spotlight highlighting
- [ ] Skip option available
- [ ] Progress indicator (1/6, 2/6, etc.)
- [ ] "Don't show again" checkbox
- [ ] Mobile-responsive tooltips

### 3.2 Files to Create/Modify

```
components/onboarding/
├── tour-provider.tsx         # CREATE - Context provider
├── tour-step.tsx             # CREATE - Individual step component
├── tour-tooltip.tsx          # CREATE - Tooltip UI
└── tour-progress.tsx         # CREATE - Progress indicator

hooks/
└── use-onboarding-tour.ts    # CREATE - Tour state management
```

### 3.3 Database Schema

```sql
-- Track tour completion
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS
  has_completed_tour BOOLEAN DEFAULT FALSE,
  tour_completed_at TIMESTAMP;
```

---

## Feature 4: Campus Connect

### 4.1 Requirements

**Goal:** Pinterest-inspired community platform for verified college students

#### 4.1.1 Content Categories

| Category | Icon | Description |
|----------|------|-------------|
| **Doubts** | HelpCircle | Academic questions & answers |
| **Residentials** | Home | PG, hostel, flat listings |
| **Jobs** | Briefcase | Internships & part-time jobs |
| **Teacher Reviews** | Star | Anonymous-ish faculty reviews |
| **Subject Tips** | BookOpen | Study tips & resources |
| **Events** | Calendar | College events & fests |

#### 4.1.2 Key Features
- [ ] Pinterest-style masonry grid layout
- [ ] College filter (like Zomato location filter)
- [ ] Category tabs/pills
- [ ] Search functionality
- [ ] Create post with images
- [ ] Like, comment, save functionality
- [ ] Report inappropriate content

#### 4.1.3 Access Control
- **Requirement:** Verified college email to post/comment
- **Accountability:** User name visible (no anonymity)
- **Admin:** Can upload event banners/graphics

#### 4.1.4 Card Design

```
┌─────────────────────────────┐
│  [Image/Graphic]            │
├─────────────────────────────┤
│  Category Badge             │
│  Title (2 lines max)        │
│  Preview text...            │
├─────────────────────────────┤
│  👤 User Name  |  🏫 College│
│  ❤️ 24  💬 5   |  🕐 2h ago │
└─────────────────────────────┘
```

### 4.2 Files to Create/Modify

```
app/(dashboard)/campus-connect/
├── page.tsx                  # CREATE - Main page
├── [postId]/
│   └── page.tsx              # CREATE - Post detail
└── create/
    └── page.tsx              # CREATE - Create post

components/campus-connect/
├── post-card.tsx             # CREATE - Pinterest card
├── masonry-grid.tsx          # CREATE - Grid layout
├── category-filter.tsx       # CREATE - Category pills
├── college-filter.tsx        # CREATE - College dropdown
├── create-post-form.tsx      # CREATE - Post creation
├── post-detail.tsx           # CREATE - Full post view
├── comment-section.tsx       # CREATE - Comments
└── event-banner.tsx          # CREATE - Admin banners
```

### 4.3 Database Schema

```sql
-- Campus Connect Posts
CREATE TABLE campus_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  college_id UUID REFERENCES colleges(id),
  category VARCHAR(50) NOT NULL, -- doubts, residentials, jobs, reviews, tips, events
  title VARCHAR(255) NOT NULL,
  content TEXT,
  images TEXT[], -- Array of image URLs
  is_admin_post BOOLEAN DEFAULT FALSE,
  likes_count INT DEFAULT 0,
  comments_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Colleges table
CREATE TABLE colleges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  domain VARCHAR(255), -- e.g., "stanford.edu"
  city VARCHAR(100),
  state VARCHAR(100),
  country VARCHAR(100) DEFAULT 'India',
  is_verified BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Post likes
CREATE TABLE campus_post_likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES campus_posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(post_id, user_id)
);

-- Post comments
CREATE TABLE campus_post_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES campus_posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Saved posts
CREATE TABLE campus_saved_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES campus_posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(post_id, user_id)
);
```

---

## Feature 5: Expert Consultation Flow

### 5.1 Requirements

**Goal:** Professional consultation booking with commission-based payments

#### 5.1.1 Expert Listing Card

```
┌─────────────────────────────────────┐
│  [Profile Photo]                    │
│                                     │
│  Dr. John Smith                     │
│  Senior Software Architect          │
│  ⭐ 4.9 (120 reviews)               │
│                                     │
│  💰 $30/session (30 min)            │
│  📅 Available: Mon-Fri, 9AM-6PM     │
│                                     │
│  [Book Consultation]                │
└─────────────────────────────────────┘
```

#### 5.1.2 Commission Model

| Component | Amount | Percentage |
|-----------|--------|------------|
| Client Pays | $30 | 100% |
| Expert Receives | $20 | 66.7% |
| Platform Fee | $10 | 33.3% |

#### 5.1.3 Booking Flow

```
1. User browses experts → Selects one
2. Chooses available time slot
3. Makes payment (full amount to platform)
4. WhatsApp notification to expert
5. Google Meet link generated/shared
6. After session: Expert marks complete
7. Platform releases payment to expert (minus commission)
8. Money-back guarantee if incomplete
```

#### 5.1.4 WhatsApp Integration
- [ ] Booking confirmation to user
- [ ] New booking alert to expert
- [ ] Reminder 30 min before session
- [ ] Session completion prompt
- [ ] Payment received notification

#### 5.1.5 Safety Features
- [ ] Platform-only transactions (no direct dealing)
- [ ] Money-back guarantee
- [ ] Review/rating system
- [ ] Report expert option
- [ ] Session recording consent

### 5.2 Files to Create/Modify

```
app/(dashboard)/experts/
├── page.tsx                  # CREATE - Expert listing
├── [expertId]/
│   └── page.tsx              # CREATE - Expert profile
└── booking/
    └── [expertId]/
        └── page.tsx          # CREATE - Booking flow

components/experts/
├── expert-card.tsx           # CREATE - Listing card
├── expert-grid.tsx           # CREATE - Grid layout
├── expert-profile.tsx        # CREATE - Full profile
├── booking-calendar.tsx      # CREATE - Time slot picker
├── booking-confirmation.tsx  # CREATE - Confirmation modal
├── session-card.tsx          # CREATE - Booked session card
└── review-form.tsx           # CREATE - Post-session review

lib/
├── whatsapp.ts               # CREATE - WhatsApp API integration
└── commission.ts             # CREATE - Commission calculations
```

### 5.3 Database Schema

```sql
-- Experts table
CREATE TABLE experts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  designation VARCHAR(255) NOT NULL,
  specializations TEXT[],
  hourly_rate DECIMAL(10,2) NOT NULL,
  session_duration INT DEFAULT 30, -- minutes
  google_meet_link VARCHAR(500),
  whatsapp_number VARCHAR(20),
  availability JSONB, -- { "monday": ["09:00-12:00", "14:00-18:00"], ... }
  is_verified BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  rating DECIMAL(3,2) DEFAULT 0,
  total_reviews INT DEFAULT 0,
  total_sessions INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Expert bookings
CREATE TABLE expert_bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  expert_id UUID REFERENCES experts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  scheduled_at TIMESTAMP NOT NULL,
  duration INT NOT NULL, -- minutes
  total_amount DECIMAL(10,2) NOT NULL,
  expert_amount DECIMAL(10,2) NOT NULL,
  platform_fee DECIMAL(10,2) NOT NULL,
  status VARCHAR(50) DEFAULT 'pending', -- pending, confirmed, completed, cancelled, refunded
  google_meet_link VARCHAR(500),
  payment_status VARCHAR(50) DEFAULT 'pending', -- pending, paid, released, refunded
  completed_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Expert reviews
CREATE TABLE expert_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id UUID REFERENCES expert_bookings(id) ON DELETE CASCADE,
  expert_id UUID REFERENCES experts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  rating INT CHECK (rating >= 1 AND rating <= 5),
  review TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Whatsapp notifications log
CREATE TABLE whatsapp_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id UUID REFERENCES expert_bookings(id),
  recipient_type VARCHAR(20), -- 'user' or 'expert'
  phone_number VARCHAR(20),
  message_type VARCHAR(50), -- booking_confirmed, reminder, completion, etc.
  status VARCHAR(20) DEFAULT 'pending',
  sent_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);
```

---

## Database Schema Requirements

### Summary of All New Tables

| Table | Feature | Priority |
|-------|---------|----------|
| `colleges` | Campus Connect | High |
| `campus_posts` | Campus Connect | High |
| `campus_post_likes` | Campus Connect | High |
| `campus_post_comments` | Campus Connect | High |
| `campus_saved_posts` | Campus Connect | Medium |
| `experts` | Expert Consultation | High |
| `expert_bookings` | Expert Consultation | High |
| `expert_reviews` | Expert Consultation | Medium |
| `whatsapp_notifications` | Expert Consultation | Medium |

### Profile Table Modifications

```sql
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS
  college_email VARCHAR(255),
  is_college_verified BOOLEAN DEFAULT FALSE,
  college_id UUID REFERENCES colleges(id),
  college_verified_at TIMESTAMP,
  has_completed_tour BOOLEAN DEFAULT FALSE,
  tour_completed_at TIMESTAMP,
  user_type VARCHAR(50); -- student, professional, businessman
```

---

## Implementation Timeline

### Phase 1: Foundation (Landing + Auth)
1. Landing Page Redesign
2. Magic Link Authentication
3. Google OAuth
4. College Email Verification

### Phase 2: Dashboard Enhancement
1. Onboarding Tour
2. UI Polish

### Phase 3: Campus Connect
1. Database Schema
2. Post Creation
3. Masonry Grid
4. Filters & Search
5. Interactions (like, comment, save)

### Phase 4: Expert Consultation
1. Database Schema
2. Expert Listings
3. Booking Flow
4. Payment Integration
5. WhatsApp Integration

---

## Quality Assurance Checklist

### Landing Page
- [ ] Clean, uncluttered design
- [ ] Three user type cards render correctly
- [ ] Stats animate on scroll
- [ ] Mobile responsive
- [ ] Fast load time (<3s)

### Authentication
- [ ] Magic link sends successfully
- [ ] Magic link expires after 10 minutes
- [ ] Google OAuth works
- [ ] College email verification flow works
- [ ] Rate limiting active
- [ ] Error handling for invalid emails

### Dashboard Onboarding
- [ ] Tour starts for first-time users
- [ ] All 6 steps work correctly
- [ ] Skip button works
- [ ] "Don't show again" persists
- [ ] Mobile tooltips position correctly

### Campus Connect
- [ ] Only verified college users can post
- [ ] Masonry grid renders correctly
- [ ] Category filter works
- [ ] College filter works
- [ ] Like/comment/save work
- [ ] No anonymous posting allowed
- [ ] Admin can upload banners

### Expert Consultation
- [ ] Expert cards display correctly
- [ ] Booking flow completes
- [ ] Commission calculated correctly
- [ ] WhatsApp notifications send
- [ ] Google Meet link shared
- [ ] Money-back refund works
- [ ] Reviews post correctly

---

## Appendix: Environment Variables Required

```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=

# Google OAuth
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=

# WhatsApp Business API
WHATSAPP_API_TOKEN=
WHATSAPP_PHONE_NUMBER_ID=

# Payment Gateway (for future)
RAZORPAY_KEY_ID=
RAZORPAY_KEY_SECRET=
```

---

*Document prepared for AssignX development team*
