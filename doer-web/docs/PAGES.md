# Pages Documentation

## Overview

The Doer Web application uses **Next.js App Router** with route groups for organizing pages by authentication and activation states. This document describes each page and its functionality.

---

## Route Structure

```
app/
├── page.tsx                     # / - Splash/Home
├── layout.tsx                   # Root layout
│
├── (auth)/                      # Authentication pages
│   ├── layout.tsx              # Centered auth layout
│   ├── login/page.tsx          # /login
│   └── register/page.tsx       # /register
│
├── (onboarding)/                # Onboarding pages
│   ├── layout.tsx              # Onboarding layout
│   ├── welcome/page.tsx        # /welcome
│   └── profile-setup/page.tsx  # /profile-setup
│
├── (activation)/                # Activation pages
│   ├── layout.tsx              # Activation gate layout
│   ├── training/page.tsx       # /training
│   ├── quiz/page.tsx           # /quiz
│   └── bank-details/page.tsx   # /bank-details
│
└── (main)/                      # Main app pages
    ├── layout.tsx              # Main layout (sidebar + header)
    ├── dashboard/page.tsx      # /dashboard
    ├── projects/
    │   ├── page.tsx            # /projects
    │   └── [id]/page.tsx       # /projects/:id
    ├── resources/page.tsx      # /resources
    ├── profile/page.tsx        # /profile
    ├── statistics/page.tsx     # /statistics
    └── reviews/page.tsx        # /reviews
```

---

## Root Pages

### Home / Splash (`/`)

**File:** `app/page.tsx`

**Purpose:** Landing page with splash screen animation.

**Features:**
- Animated logo display
- Auto-redirect based on auth state:
  - Not authenticated → `/welcome`
  - Authenticated but not onboarded → `/profile-setup`
  - Onboarded but not activated → `/training`
  - Fully activated → `/dashboard`

**Component:** `SplashScreen`

---

## Authentication Pages

### Login (`/login`)

**File:** `app/(auth)/login/page.tsx`

**Layout:** Centered card layout with gradient background

**Purpose:** User authentication.

**Features:**
- Email/password login
- Form validation with error messages
- "Forgot password" link
- "Register" link for new users
- Loading state during authentication
- Error handling with toast notifications

**Flow:**
```
Login → Check Onboarding → Check Activation → Dashboard
```

### Register (`/register`)

**File:** `app/(auth)/register/page.tsx`

**Layout:** Same as login

**Purpose:** New user registration.

**Features:**
- Full name input
- Email input with validation
- Phone number input
- OTP verification (SMS)
- Password with strength indicator
- Terms acceptance checkbox
- Loading states
- Error handling

**Validations:**
- Email format
- Phone format (Indian)
- Password: 8+ chars, uppercase, lowercase, number
- OTP: 6 digits

**Flow:**
```
Register → OTP Verify → Auto Login → Profile Setup
```

---

## Onboarding Pages

### Welcome (`/welcome`)

**File:** `app/(onboarding)/welcome/page.tsx`

**Layout:** Full-screen with navigation

**Purpose:** Introduce app features to new users.

**Features:**
- Swipeable carousel (4 slides):
  1. Countless Opportunities
  2. Small Tasks, Big Rewards
  3. 24x7 Supervisor Support
  4. Practical Learning
- Dot indicators
- Skip button
- "Get Started" button on last slide

**Component:** `OnboardingCarousel`

### Profile Setup (`/profile-setup`)

**File:** `app/(onboarding)/profile-setup/page.tsx`

**Layout:** Centered form layout

**Purpose:** Complete doer profile.

**Features:**
- Multi-step form:
  1. Qualification selection
  2. University search/select
  3. Skills multi-select (min 3)
  4. Subjects multi-select (min 2)
  5. Experience level
  6. Bio/About
- Progress indicator
- Back/Next navigation
- Save on each step

**Component:** `ProfileSetupForm`

---

## Activation Pages

### Training (`/training`)

**File:** `app/(activation)/training/page.tsx`

**Layout:** Activation layout with progress bar

**Purpose:** Complete required training modules.

**Features:**
- Training module list:
  1. Quality Standards (video)
  2. Plagiarism Policy (video)
  3. Meeting Deadlines (PDF)
  4. Tools & Resources (video)
- Video player embed
- PDF viewer
- Progress tracking per module
- Completion checkbox
- "Continue to Quiz" button when complete

**Requirements:**
- All modules must be completed
- Minimum watch time validation

### Quiz (`/quiz`)

**File:** `app/(activation)/quiz/page.tsx`

**Layout:** Activation layout

**Purpose:** Verify understanding of training content.

**Features:**
- 5 multiple choice questions
- Timer (optional)
- Progress indicator
- Score display after completion
- Pass/Fail result (80% required)
- Retry option (max 3 attempts)
- "Continue to Bank Details" on pass

**Settings:**
- Passing score: 80%
- Max attempts: 3
- Questions per attempt: 5

### Bank Details (`/bank-details`)

**File:** `app/(activation)/bank-details/page.tsx`

**Layout:** Activation layout

**Purpose:** Collect payment information.

**Features:**
- Account holder name
- Account number (masked after entry)
- IFSC code with auto-validation
- Bank name auto-fetch from IFSC
- UPI ID (optional)
- Confirmation checkbox
- Submit button

**Validations:**
- IFSC: `^[A-Z]{4}0[A-Z0-9]{6}$`
- Account: 9-18 digits
- UPI: `^[\w.-]+@[\w.-]+$`

**On Complete:**
- Mark activation as complete
- Redirect to Dashboard

---

## Main App Pages

### Dashboard (`/dashboard`)

**File:** `app/(main)/dashboard/page.tsx`

**Layout:** MainLayout (Header + Sidebar + Content)

**Purpose:** Central hub for task management.

**Features:**
- Tab navigation:
  - **Assigned to Me**: Tasks assigned to the doer
  - **Open Pool**: Available tasks to accept
- Task cards with:
  - Title and subject
  - Price (INR)
  - Deadline countdown
  - Status badge
  - Urgency indicator
- Accept task functionality
- Quick filters
- Pull-to-refresh

**Components:**
- `AssignedTaskList`
- `TaskPoolList`
- `ProjectCard`

### Projects (`/projects`)

**File:** `app/(main)/projects/page.tsx`

**Layout:** MainLayout

**Purpose:** Project portfolio management.

**Features:**
- Tab navigation:
  - **Active**: In-progress projects
  - **Under Review**: Submitted projects
  - **Completed**: Finished projects
- Search and filter
- Sort by deadline/price/date
- Project cards
- Quick status view

**Components:**
- `ActiveProjectsTab`
- `UnderReviewTab`
- `CompletedTab`

### Project Workspace (`/projects/:id`)

**File:** `app/(main)/projects/[id]/page.tsx`

**Layout:** MainLayout

**Purpose:** Full project workspace for working on assignments.

**Features:**

**Header Section:**
- Deadline countdown (days, hours, minutes)
- Urgency indicator
- Price display
- Progress bar

**Details Tab:**
- Project title and subject
- Status badge
- Project brief (collapsible)
- Requirements (word count, pages, reference style)
- Special instructions
- Reference files download
- Supervisor info

**Submit Tab:**
- Previous submissions list
- File upload dropzone
- Upload progress
- Submit for review button

**Chat Tab:**
- Real-time messaging
- Message history
- File attachments
- Unread indicator
- Auto-scroll

**Revision Banner:**
- Shows when revision requested
- Revision notes
- "Start Revision" button

**Components:**
- `WorkspaceView`
- `FileUpload`
- `ChatPanel`
- `RevisionBanner`

### Resources (`/resources`)

**File:** `app/(main)/resources/page.tsx`

**Layout:** MainLayout

**Purpose:** Tools and resources for doers.

**Features:**

**Citation Builder:**
- URL input
- Style selection (APA, MLA, Harvard, Chicago, IEEE, Vancouver)
- Generate citation
- Copy to clipboard
- Citation history

**Format Templates:**
- Template gallery by category
- Preview thumbnails
- Download templates
- Category filter

**Training Center:**
- Video tutorials
- Progress tracking
- Certificate download

**AI Content Checker:**
- Text input / file upload
- Analysis progress
- Originality score
- Section breakdown
- Report history

**Components:**
- `ResourcesGrid`
- `CitationBuilder`
- `FormatTemplates`
- `TrainingCenter`
- `AIReportGenerator`

### Profile (`/profile`)

**File:** `app/(main)/profile/page.tsx`

**Layout:** MainLayout

**Purpose:** Profile management and settings.

**Features:**

**Scorecard:**
- Active assignments count
- Completed projects count
- Total earnings
- Average rating

**Edit Profile:**
- Avatar upload
- Personal info editing
- Qualification update
- Skills management

**Skills & Verification:**
- Skill list with proficiency
- Verification status
- Request verification
- Add/remove skills

**Bank Settings:**
- View bank details
- Update bank info
- IFSC validation

**Earnings & Payouts:**
- Earnings graph
- Transaction history
- Request payout

**Support:**
- FAQ section
- Create support ticket
- Ticket history

**Components:**
- `Scorecard`
- `EditProfile`
- `SkillVerification`
- `BankSettings`
- `EarningsGraph`
- `PaymentHistory`
- `RequestPayout`
- `SupportSection`
- `RatingBreakdown`

### Statistics (`/statistics`)

**File:** `app/(main)/statistics/page.tsx`

**Layout:** MainLayout

**Purpose:** Detailed performance analytics.

**Features:**
- Earnings over time chart
- Projects completed chart
- Rating trends
- Subject-wise breakdown
- Monthly comparison
- Export reports

### Reviews (`/reviews`)

**File:** `app/(main)/reviews/page.tsx`

**Layout:** MainLayout

**Purpose:** View and manage reviews.

**Features:**
- Review list
- Rating breakdown
- Filter by rating
- Sort by date
- Response to reviews

---

## Page Navigation Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         NEW USER FLOW                            │
└─────────────────────────────────────────────────────────────────┘
    /  →  /welcome  →  /register  →  /profile-setup  →  /training
                                                            │
                                                            ▼
                           /dashboard  ←  /bank-details  ←  /quiz

┌─────────────────────────────────────────────────────────────────┐
│                       RETURNING USER FLOW                        │
└─────────────────────────────────────────────────────────────────┘
    /  →  /login  →  (activation check)  →  /dashboard

┌─────────────────────────────────────────────────────────────────┐
│                         MAIN APP FLOW                            │
└─────────────────────────────────────────────────────────────────┘
                    ┌─────────────┐
                    │  Dashboard  │
                    └─────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        ▼                 ▼                 ▼
    ┌───────┐       ┌──────────┐      ┌──────────┐
    │Projects│      │Resources │      │ Profile  │
    └───────┘       └──────────┘      └──────────┘
        │
        ▼
    ┌───────────────┐
    │Project/:id    │
    │(Workspace)    │
    └───────────────┘
```

---

## Protected Routes

### Authentication Required

All routes except:
- `/`
- `/login`
- `/register`
- `/welcome`

### Activation Required

Main app routes require full activation:
- `/dashboard`
- `/projects`
- `/projects/:id`
- `/resources`
- `/profile`
- `/statistics`
- `/reviews`

### Route Guards

```typescript
// Activation gate in layout
export default function ActivationLayout({ children }) {
  const { isActivated } = useActivation()

  if (!isActivated) {
    return <ActivationGate />
  }

  return children
}
```

---

## SEO & Metadata

Each page exports metadata:

```typescript
export const metadata = {
  title: 'Dashboard | Doer',
  description: 'Manage your tasks and find new opportunities',
}
```

---

## Error Handling

### Not Found (`app/not-found.tsx`)

404 page for invalid routes.

### Error Boundary (`app/error.tsx`)

Global error page with retry option.

### Loading States (`app/loading.tsx`)

Global loading fallback with skeleton.
