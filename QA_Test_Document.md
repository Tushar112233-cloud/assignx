# AssignX - Comprehensive QA Test Document

**Version:** 1.0
**Date:** 2026-02-25
**Document Owner:** QA Team
**Platform Coverage:** PART 1 - User App (Flutter Mobile)

---

## Table of Contents

### PART 1 - User App (This Document)
- [1. Platform Overview](#1-platform-overview)
  - [1.1 All Platforms](#11-all-platforms)
  - [1.2 Tech Stack Summary](#12-tech-stack-summary)
  - [1.3 End-to-End Workflow](#13-end-to-end-workflow)
- [2. USER APP (Flutter Mobile) - Test Cases](#2-user-app-flutter-mobile---test-cases)
  - [2.1 Authentication & Onboarding](#21-authentication--onboarding)
  - [2.2 Home Dashboard](#22-home-dashboard)
  - [2.3 My Projects](#23-my-projects)
  - [2.4 Project Detail](#24-project-detail)
  - [2.5 Add Project](#25-add-project)
  - [2.6 Campus Connect / Marketplace](#26-campus-connect--marketplace)
  - [2.7 Experts & Consultations](#27-experts--consultations)
  - [2.8 Connect (Peer Network)](#28-connect-peer-network)
  - [2.9 Chat & Messaging](#29-chat--messaging)
  - [2.10 Profile & Account](#210-profile--account)
  - [2.11 Wallet & Payments](#211-wallet--payments)
  - [2.12 Notifications](#212-notifications)
  - [2.13 Settings](#213-settings)
  - [2.14 Business Hub](#214-business-hub)
  - [2.15 Pro Network](#215-pro-network)

### PART 2 (Separate Document)
- 3. DOER APP (Flutter Mobile)
- 4. SUPERVISOR APP (Flutter Mobile)
- 5. USER WEB (Next.js)
- 6. ADMIN WEB (Next.js)
- 7. BACKEND / SUPABASE
- 8. CROSS-PLATFORM INTEGRATION TESTS
- 9. PERFORMANCE & SECURITY TESTS

---

## 1. Platform Overview

### 1.1 All Platforms

AssignX is a three-sided marketplace connecting Users (clients), Doers (freelance experts), and Supervisors (quality controllers). The platform consists of 8 distinct applications:

| # | Platform | Technology | Purpose |
|---|----------|-----------|---------|
| 1 | **User App** | Flutter (iOS/Android) | Client-facing mobile app for submitting projects, tracking progress, payments, campus community |
| 2 | **Doer App** | Flutter (iOS/Android) | Expert-facing mobile app for accepting tasks, submitting work, managing earnings |
| 3 | **Supervisor App** | Flutter (iOS/Android) | QC-facing mobile app for reviewing deliverables, approving/rejecting work |
| 4 | **User Web** | Next.js (React) | Web version of the client portal with full project management |
| 5 | **Admin Web** | Next.js (React) | Internal admin dashboard for managing operations, users, pricing, and assignments |
| 6 | **Backend API** | Supabase (PostgreSQL + Edge Functions) | Core backend with database, auth, realtime, storage, and serverless functions |
| 7 | **Notification Service** | Firebase Cloud Messaging + Resend Email | Push notifications and transactional email delivery |
| 8 | **Payment Service** | Razorpay Integration | Payment processing for wallet top-ups and project payments |

### 1.2 Tech Stack Summary

| Layer | Technology |
|-------|-----------|
| Mobile Apps | Flutter 3.x, Dart, Riverpod (state management), GoRouter (navigation) |
| Web Apps | Next.js 14+, React, TypeScript, Tailwind CSS |
| Backend | Supabase (PostgreSQL, Auth, Realtime, Storage, Edge Functions) |
| Auth | Supabase Auth (Google OAuth, Magic Link, Password) |
| Payments | Razorpay SDK |
| Push Notifications | Firebase Cloud Messaging (FCM) |
| Email | Resend API |
| File Storage | Supabase Storage |
| Real-time | Supabase Realtime (WebSocket channels) |
| Analytics | PostHog / Custom |
| CI/CD | GitHub Actions |

### 1.3 End-to-End Workflow (15-Step Process)

| Step | Actor | Action | Platform |
|------|-------|--------|----------|
| 1 | **User** | Signs up via Google OAuth or Magic Link, completes onboarding (role selection, profile) | User App / User Web |
| 2 | **User** | Creates a new project (selects service type, fills form, attaches files) | User App / User Web |
| 3 | **System** | Project enters "Submitted" status, admin is notified | Backend |
| 4 | **Admin** | Reviews submission, creates a quote with pricing and estimated deadline | Admin Web |
| 5 | **User** | Receives push + WhatsApp notification that quote is ready | Notification Service |
| 6 | **User** | Reviews quote, makes payment via Razorpay (wallet or direct) | User App / User Web |
| 7 | **System** | Payment confirmed, project enters "Paid" status, task is created for assignment | Backend + Payment Service |
| 8 | **Admin** | Assigns project to a qualified Doer | Admin Web |
| 9 | **Doer** | Receives task notification, accepts assignment, begins working | Doer App |
| 10 | **Doer** | Uploads deliverables (documents, reports), submits for QC review | Doer App |
| 11 | **Supervisor** | Receives QC task, reviews deliverables against quality criteria | Supervisor App |
| 12 | **Supervisor** | Approves or rejects work (with feedback for revision if rejected) | Supervisor App |
| 13 | **System** | If approved, deliverables are made available to User; if rejected, Doer revises | Backend |
| 14 | **User** | Reviews delivered work, can approve or request changes (48h auto-approval timer) | User App / User Web |
| 15 | **System** | Project marked "Completed", Doer earnings credited, invoice generated | Backend + Payment Service |

---

## 2. USER APP (Flutter Mobile) - Test Cases

**App Architecture:** Flutter with Riverpod state management, GoRouter navigation, Supabase backend.
**Navigation:** MainShell with IndexedStack preserving state across 6 bottom nav tabs (Home, Projects, ConnectHub, Experts, Wallet, Profile).

---

### 2.1 Authentication & Onboarding

#### 2.1.1 Splash Screen

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| UA-AUTH-001 | Splash Animation | Verify splash screen displays with fade-in animation | 1. Cold launch the app | App logo "AssignX" fades in with scale animation (0.8 to 1.0) over 500ms, tagline "Your Task, Our Expertise" slides up after 300ms delay | P2 |
| UA-AUTH-002 | Splash Gradient | Verify gradient background renders correctly | 1. Launch app 2. Observe background | Gradient displays from primary color (top-left) to purple accent (bottom-right) | P3 |
| UA-AUTH-003 | Splash Loading Indicator | Verify loading spinner appears | 1. Launch app 2. Wait 800ms | Circular progress indicator fades in at 800ms with white color and 2px stroke width | P3 |
| UA-AUTH-004 | Splash Auto-Transition (Unauthenticated) | Verify splash navigates to onboarding for new users | 1. Clear app data 2. Launch app 3. Wait 2.5 seconds | After 2500ms delay, app navigates to onboarding screen | P1 |
| UA-AUTH-005 | Splash Auto-Transition (Authenticated + Profile) | Verify splash navigates to home for authenticated users with complete profile | 1. Sign in previously 2. Kill and relaunch app | After 2500ms, app navigates directly to Home screen | P1 |
| UA-AUTH-006 | Splash Auto-Transition (Authenticated + No Profile) | Verify splash navigates to role selection for authenticated users without profile | 1. Sign in via Google but do not complete profile 2. Kill and relaunch app | After 2500ms, app navigates to Role Selection screen | P1 |
| UA-AUTH-007 | Splash Error Handling | Verify splash handles auth errors gracefully | 1. Simulate auth error (e.g., no network on initial load) | App navigates to onboarding screen on error instead of crashing | P1 |
| UA-AUTH-008 | Splash Loading Retry | Verify splash retries when auth state is still loading | 1. Simulate slow network 2. Launch app | If auth state is "loading" after 2500ms, splash waits additional 500ms and retries | P2 |

#### 2.1.2 Onboarding Carousel

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| UA-AUTH-010 | 3-Slide Carousel | Verify all 3 onboarding slides render | 1. Open app as new user 2. Arrive at onboarding | Three slides displayed: Slide 1 (Pink gradient, "Expert Help"), Slide 2 (Blue gradient, "Versatile Projects"), Slide 3 (Green gradient, "Your Journey Starts") | P1 |
| UA-AUTH-011 | Auto-Scroll | Verify carousel auto-scrolls every 4 seconds | 1. Arrive at onboarding 2. Do not touch screen 3. Wait 4+ seconds | Carousel automatically advances to next slide every 4 seconds with 600ms easeInOutCubic animation | P2 |
| UA-AUTH-012 | Auto-Scroll Loop | Verify auto-scroll loops from last to first slide | 1. Wait for carousel to reach slide 3 2. Wait 4 more seconds | Carousel loops back to slide 1 | P2 |
| UA-AUTH-013 | Manual Swipe | Verify user can swipe between slides | 1. Swipe left on slide 1 | Carousel advances to slide 2 | P1 |
| UA-AUTH-014 | Auto-Scroll Stops on Interaction | Verify auto-scroll stops when user swipes | 1. Wait for auto-scroll 2. Swipe manually | Auto-scroll timer cancels, no further auto-scrolling occurs | P2 |
| UA-AUTH-015 | Page Indicator Dots | Verify dot indicators reflect current page | 1. Navigate between slides | Active dot expands to 24px width (pill shape), inactive dots are 8px circles; active dot is dark, inactive are light gray | P2 |
| UA-AUTH-016 | Next Button (Arrow) | Verify circular arrow button on slides 1 and 2 | 1. Tap the circular blue arrow button on slide 1 | Carousel advances to slide 2; button is 64x64 circle with arrow_forward icon | P1 |
| UA-AUTH-017 | Get Started Button | Verify "Get Started" pill button on last slide | 1. Navigate to slide 3 2. Observe button | Button changes from circular arrow to "Get Started" pill button (blue, rounded 30px corners) | P1 |
| UA-AUTH-018 | Get Started Navigation | Verify "Get Started" navigates to login screen | 1. Tap "Get Started" on slide 3 | App saves onboarding_complete flag to SharedPreferences and navigates to login screen | P1 |
| UA-AUTH-019 | Sign In Link | Verify "Already have an account? Sign in" link | 1. On slides 1 or 2, look for sign-in link at bottom | Link text "Already have an account? Sign in" appears in primary color; tapping navigates to sign-in screen | P2 |
| UA-AUTH-020 | Sign In Link Hidden on Last Slide | Verify sign-in link is hidden on slide 3 | 1. Navigate to slide 3 | The "Already have an account? Sign in" link is NOT displayed on the last slide | P3 |
| UA-AUTH-021 | Lottie Animations | Verify Lottie animations load and play | 1. On each slide, observe animation area | Lottie animation loads from network URL and plays; on failure, fallback icon (image_outlined) appears | P2 |
| UA-AUTH-022 | Animated Gradient Background | Verify gradient transitions smoothly between slides | 1. Swipe between slides | Background gradient colors smoothly animate (500ms easeInOut) between Pink, Blue, and Green gradient pairs | P3 |
| UA-AUTH-023 | Decorative Doodle Elements | Verify doodle elements render (rings, circles, dots, squiggles) | 1. Observe the gradient area on any slide | White semi-transparent decorative elements visible: rings, circles, dots, squiggles, crosses, triangles | P3 |

#### 2.1.3 Sign-In / Sign-Up Screen

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| UA-AUTH-030 | Sign-In Screen Layout | Verify sign-in screen renders with all elements | 1. Navigate to sign-in screen | Screen shows: AssignX logo at top, Lottie animation (floating game animation), glass morphism bottom section with "Welcome Back!" title | P1 |
| UA-AUTH-031 | Terms & Conditions Checkbox | Verify T&C checkbox must be accepted before sign-in | 1. Do NOT check T&C checkbox 2. Tap "Continue with Google" | Error message "Please accept the Terms & Conditions to continue" displayed in red error banner | P1 |
| UA-AUTH-032 | Terms Checkbox Toggle | Verify checkbox visual toggle | 1. Tap the checkbox | Checkbox animates (200ms) from empty border to filled blue with checkmark icon | P2 |
| UA-AUTH-033 | Google Sign-In (Happy Path) | Verify Google OAuth sign-in works | 1. Check T&C checkbox 2. Tap "Continue with Google" | Loading overlay "Signing in..." appears, Google OAuth flow launches, on success navigates to role selection (new user) or home (existing user) | P1 |
| UA-AUTH-034 | Google Sign-In Button Disabled State | Verify Google button is disabled when T&C unchecked | 1. Observe Google button with T&C unchecked | Button has 0.5 opacity, no shadow, tap has no effect | P2 |
| UA-AUTH-035 | Google Sign-In Error | Verify error handling on Google sign-in failure | 1. Accept T&C 2. Start Google sign-in 3. Cancel or simulate failure | Error message "Sign in failed. Please try again." displayed; loading state cleared | P1 |
| UA-AUTH-036 | Magic Link Option | Verify "Sign in with Email" button | 1. Accept T&C 2. Tap "Sign in with Email" | View transitions to magic link email form with "Back to options" button, email input, and "Send Magic Link" button | P1 |
| UA-AUTH-037 | Magic Link - Empty Email | Verify validation for empty email | 1. On magic link form, tap "Send Magic Link" without entering email | Error text "Please enter your email address" appears | P1 |
| UA-AUTH-038 | Magic Link - Invalid Email | Verify email format validation | 1. Enter "notanemail" 2. Tap "Send Magic Link" | Error text "Please enter a valid email address" appears | P1 |
| UA-AUTH-039 | Magic Link - Valid Email | Verify magic link sends successfully | 1. Enter valid email (e.g., test@example.com) 2. Tap "Send Magic Link" | Loading overlay "Sending magic link..." appears, navigates to magic link confirmation screen with email displayed | P1 |
| UA-AUTH-040 | Admin Bypass Login | Verify admin@gmail.com bypasses magic link | 1. Enter "admin@gmail.com" in magic link email field 2. Tap "Send Magic Link" | System uses signInWithPassword (email: admin@gmail.com, password: Admin@123) instead of magic link; on success, navigates via auth state listener | P1 |
| UA-AUTH-041 | Admin Bypass Login Failure | Verify admin bypass error handling | 1. Enter "admin@gmail.com" 2. Simulate backend rejection | Error "Login failed: [error details]" displayed | P2 |
| UA-AUTH-042 | Magic Link Sent Confirmation | Verify magic link sent view | 1. Successfully send magic link | View shows green checkmark icon, "Check your email" title, email address displayed, "The link expires in 10 minutes" note, "Try a different email" button | P1 |
| UA-AUTH-043 | Try Different Email | Verify "Try a different email" resets form | 1. On magic link sent view, tap "Try a different email" | Returns to email input form with cleared field and no errors | P2 |
| UA-AUTH-044 | Back Navigation | Verify back button behavior from magic link form | 1. On magic link form, tap "Back to options" | Returns to main sign-in options (Google + Magic Link) | P2 |
| UA-AUTH-045 | Back Navigation from Sign-In | Verify back from main sign-in view | 1. On sign-in options view, trigger back | Navigates to onboarding screen | P2 |
| UA-AUTH-046 | Sign Up Link | Verify "Don't have an account? Sign up" | 1. On sign-in options, tap "Sign up" | Navigates to login/sign-up screen | P2 |
| UA-AUTH-047 | Security Note | Verify security note at bottom | 1. Observe bottom of sign-in section | Lock icon and text "Secure passwordless authentication" displayed | P3 |
| UA-AUTH-048 | Floating Lottie Animation | Verify Lottie hero has floating effect | 1. Observe the Lottie animation on sign-in screen | Animation floats vertically with sine wave pattern (6px amplitude, 6-second cycle) | P3 |
| UA-AUTH-049 | Or Divider | Verify visual separator between Google and Email | 1. Observe sign-in section | Horizontal line with "Or" text centered between Google and Email buttons | P3 |

#### 2.1.4 Role Selection

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| UA-AUTH-060 | Role Selection Layout | Verify 3 role cards display correctly | 1. Complete Google sign-in as new user | Screen shows greeting "Hey [name]!", subtitle "Tell us about yourself", and 3 role cards: Student, Job Seeker, Business/Creator | P1 |
| UA-AUTH-061 | Role Card - Student | Verify Student card content | 1. Observe Student card | Icon: school_outlined, Title: "Student", Description: "Currently pursuing education at a university or college" | P1 |
| UA-AUTH-062 | Role Card - Job Seeker | Verify Job Seeker card content | 1. Observe Job Seeker card | Icon: work_outline, Title: "Job Seeker", Description: "Looking for job opportunities or freelance work" | P1 |
| UA-AUTH-063 | Role Card - Business/Creator | Verify Business card content | 1. Observe Business card | Icon: rocket_launch_outlined, Title: "Business / Creator", Description: "Running a business or working as a content creator" | P1 |
| UA-AUTH-064 | Card Selection | Verify only one role can be selected at a time | 1. Tap Student card 2. Tap Job Seeker card | Student card deselects, Job Seeker card becomes selected (visual highlight) | P1 |
| UA-AUTH-065 | Continue Button Disabled | Verify Continue button is disabled with no selection | 1. Arrive at role selection without selecting | Continue button is disabled (null onPressed) | P1 |
| UA-AUTH-066 | Continue Button Enabled | Verify Continue button enables after selection | 1. Select any role | Continue button becomes active with arrow_forward icon | P1 |
| UA-AUTH-067 | Student Navigation | Verify Student role navigates to student profile | 1. Select Student 2. Tap Continue | Navigates to StudentProfileScreen; userType set to student | P1 |
| UA-AUTH-068 | Job Seeker Navigation | Verify Job Seeker navigates to professional profile | 1. Select Job Seeker 2. Tap Continue | Navigates to ProfessionalProfileScreen; userType set to professional, professionalType set to jobSeeker | P1 |
| UA-AUTH-069 | Business Navigation | Verify Business navigates to professional profile | 1. Select Business/Creator 2. Tap Continue | Navigates to ProfessionalProfileScreen; userType set to professional, professionalType set to business | P1 |
| UA-AUTH-070 | Staggered Animations | Verify cards animate in sequence | 1. Arrive at role selection | Cards slide in from left with staggered delays (200ms, 350ms, 500ms) and 500ms fadeIn duration | P3 |
| UA-AUTH-071 | Glass Morphism Header | Verify glass container header renders | 1. Observe header area | Glass container with greeting and subtitle has frosted glass effect | P3 |
| UA-AUTH-072 | Mesh Gradient Background | Verify gradient background | 1. Observe screen background | MeshGradientBackground with blue/purple/pink colors at topLeft position, 0.4 opacity | P3 |

#### 2.1.5 Student Profile Setup

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| UA-AUTH-080 | 2-Step Form | Verify student profile has 2 steps | 1. Select Student role 2. Arrive at student profile | Two-step form: Step 1 "Basic Info", Step 2 "Education" with StepProgressBar showing 2 total steps | P1 |
| UA-AUTH-081 | Auto-Fill Name | Verify name auto-fills from Google account | 1. Sign in with Google 2. Navigate to student profile | Full Name field pre-filled with name from Google account metadata | P2 |
| UA-AUTH-082 | Step 1 - Full Name Validation | Verify name field is required | 1. Clear name field 2. Tap Continue | Error snackbar "Please enter your full name" with red background | P1 |
| UA-AUTH-083 | Step 1 to Step 2 Navigation | Verify step progression | 1. Enter valid name 2. Tap Continue | PageView animates to Step 2 (400ms easeOutCubic), progress bar updates to step 2 | P1 |
| UA-AUTH-084 | Step 2 - University Dropdown | Verify searchable university dropdown | 1. On Step 2, tap University dropdown | Searchable dropdown loads universities from Supabase; shows loading spinner while fetching | P1 |
| UA-AUTH-085 | Step 2 - Course Dropdown (Dependent) | Verify course dropdown appears after university selection | 1. Select a university | Course dropdown appears (conditional rendering), loads courses filtered by selected university | P1 |
| UA-AUTH-086 | Step 2 - Year of Study | Verify year of study dropdown | 1. Tap Year of Study dropdown | Options: Year 1, Year 2, Year 3, Year 4, Year 5 | P2 |
| UA-AUTH-087 | Step 2 - Semester (Optional) | Verify semester dropdown | 1. Tap Semester dropdown | Options: Semester 1 through Semester 8; field is optional | P2 |
| UA-AUTH-088 | Step 2 - Student ID (Optional) | Verify student ID text field | 1. Enter or skip student ID | TextField with badge_outlined icon; field is optional | P3 |
| UA-AUTH-089 | Back Navigation Step 2 to Step 1 | Verify back button on Step 2 | 1. On Step 2, tap back arrow | PageView animates back to Step 1 (400ms), progress bar resets to step 1 | P2 |
| UA-AUTH-090 | Back Navigation Step 1 | Verify back button on Step 1 pops screen | 1. On Step 1, tap back arrow | Screen pops back to previous route (role selection) | P2 |
| UA-AUTH-091 | Complete Button | Verify "Complete" button appears on Step 2 | 1. Navigate to Step 2 | Button label changes from "Continue" to "Complete" with check icon | P2 |
| UA-AUTH-092 | Form Submission | Verify profile saves correctly | 1. Fill all fields 2. Tap "Complete" | Loading overlay "Saving profile..." appears; profile saved to Supabase with userType: student, onboardingStep: complete; navigates to signupSuccess | P1 |
| UA-AUTH-093 | Form Submission Error | Verify error handling on save failure | 1. Simulate network error during save | Error snackbar "Failed to save profile. Please try again." displayed; loading state cleared | P1 |
| UA-AUTH-094 | University Load Error | Verify university fetch error handling | 1. Simulate university API failure | Error text "Failed to load universities" displayed in red | P2 |
| UA-AUTH-095 | Course Load Error | Verify course fetch error handling | 1. Select university 2. Simulate course API failure | Error text "Failed to load courses" displayed in red | P2 |
| UA-AUTH-096 | Progress Bar Display | Verify step progress bar labels | 1. Observe progress bar | Labels: "Basic Info" and "Education"; current step highlighted | P3 |
| UA-AUTH-097 | Physics - No Manual Page Swipe | Verify PageView cannot be swiped manually | 1. Try to swipe the form pages | NeverScrollableScrollPhysics prevents manual swiping; only buttons control navigation | P2 |

#### 2.1.6 Success Screen & Signup Completion

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| UA-AUTH-100 | Success Screen | Verify signup success screen displays | 1. Complete student or professional profile | Signup success screen shows with animation (confetti/checkmark) | P1 |
| UA-AUTH-101 | Navigation to Home | Verify success screen navigates to home | 1. On success screen, wait or tap continue | User is taken to the main Home screen | P1 |

---

### 2.2 Home Dashboard

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| UA-DASH-001 | Home Screen Layout | Verify home screen renders with all sections | 1. Sign in and navigate to Home tab | Screen shows: HomeAppBar at top, greeting section, bento grid with quick action cards | P1 |
| UA-DASH-002 | Personalized Greeting - Morning | Verify time-based greeting (morning) | 1. Open app between 00:00-11:59 | Displays "Good Morning," followed by user's first name on next line | P1 |
| UA-DASH-003 | Personalized Greeting - Afternoon | Verify time-based greeting (afternoon) | 1. Open app between 12:00-16:59 | Displays "Good Afternoon," followed by user's first name | P1 |
| UA-DASH-004 | Personalized Greeting - Evening | Verify time-based greeting (evening) | 1. Open app between 17:00-23:59 | Displays "Good Evening," followed by user's first name | P1 |
| UA-DASH-005 | Greeting First Name Extraction | Verify first name extraction from full name | 1. User with full name "John Smith" opens home | Greeting shows "John" (first word of full name); if name is empty, shows "Student" | P2 |
| UA-DASH-006 | Greeting Subtitle | Verify subtitle text | 1. Observe greeting section | Subtitle "Ready to tackle your assignments?" displayed below name | P3 |
| UA-DASH-007 | HomeAppBar | Verify app bar renders | 1. Observe top of home screen | HomeAppBar displays at the top with appropriate branding | P1 |
| UA-DASH-008 | MeshGradientBackground | Verify gradient background | 1. Observe home screen background | MeshGradientBackground at bottomRight position with pink/peach/orange colors at 0.5 opacity | P3 |
| UA-DASH-009 | New Assignment Card | Verify primary action card | 1. Observe bento grid | Large gradient card (primary color) with plus icon, "New Assignment" title, "Submit your work" subtitle | P1 |
| UA-DASH-010 | New Assignment Card Tap | Verify navigation on tap | 1. Tap "New Assignment" card | Navigates to /new-project route | P1 |
| UA-DASH-011 | Active Projects Card | Verify active projects counter | 1. Observe bento grid | Card shows count of active projects (inProgress, assigned, paid statuses), folder icon, "Active Projects" label | P1 |
| UA-DASH-012 | Active Projects Card Tap | Verify navigation to projects | 1. Tap Active Projects card | Sets selectedProjectTabProvider to 1 (In Progress) and navigates to /my-projects | P1 |
| UA-DASH-013 | Wallet Balance Card | Verify wallet balance display | 1. Observe bento grid second row | Card shows wallet balance in INR format (e.g., "Rs.500"), wallet icon, "Wallet Balance" label | P1 |
| UA-DASH-014 | Wallet Card Tap | Verify navigation to wallet | 1. Tap Wallet Balance card | Navigates to /wallet route | P1 |
| UA-DASH-015 | Quick Help Card | Verify help card | 1. Observe bento grid second row | Card shows help icon, "Quick Help" title, "FAQs & Support" subtitle | P2 |
| UA-DASH-016 | Quick Help Card Tap | Verify navigation to help | 1. Tap Quick Help card | Navigates to /help route | P2 |
| UA-DASH-017 | Needs Attention Section | Verify attention items display | 1. Have projects with status payment_pending, quoted, or delivered | "Needs Attention" section appears with orange dot, item count, horizontal scrollable list of attention cards | P1 |
| UA-DASH-018 | Attention Card Navigation | Verify attention card tap navigation | 1. Tap an attention card | Navigates to /projects/{project.id} for the specific project | P1 |
| UA-DASH-019 | Attention Card Content | Verify attention card displays correct info | 1. Observe attention cards | Each card (260x90) shows: status icon in colored container, project title (1 line, ellipsis), status badge (colored), chevron right icon | P2 |
| UA-DASH-020 | Pull-to-Refresh | Verify pull-to-refresh works | 1. Pull down on home screen | RefreshIndicator appears, walletProvider/projectsProvider/unreadCountProvider invalidated, data reloads | P1 |
| UA-DASH-021 | Loading State (Skeleton) | Verify skeleton loaders during data fetch | 1. Open home with slow network | Greeting section shows SkeletonLoader (180w, 28h + 120w, 28h + 220w, 14h); Bento grid shows CardSkeleton placeholders | P2 |
| UA-DASH-022 | Error State | Verify error state with retry | 1. Simulate network failure | EmptyStateVariants.networkError displayed with retry button; tapping retry invalidates providers and clears error flag | P1 |
| UA-DASH-023 | Bottom Nav Bar | Verify 6-tab bottom navigation | 1. Observe bottom of screen | BottomNavBar with 6 items: Home, Projects, ConnectHub, Experts, Wallet, Profile; profile tab shows user avatar | P1 |
| UA-DASH-024 | Bottom Nav Tab Switching | Verify tab switching preserves state | 1. Navigate to Projects tab 2. Switch to Home 3. Switch back to Projects | IndexedStack preserves state; Projects tab returns to same scroll position and tab selection | P1 |
| UA-DASH-025 | Staggered Entrance Animations | Verify cards animate in | 1. Open Home screen | Cards fade in and slide up with staggered delays (50ms, 100ms, 150ms, 200ms, 250ms, 300ms) | P3 |
| UA-DASH-026 | Quick Actions Label | Verify "Quick Actions" section header | 1. Observe above bento grid | "Quick Actions" text in bold, 16px, primary text color | P3 |

---

### 2.3 My Projects

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| UA-PROJ-001 | Projects Screen Layout | Verify screen structure | 1. Navigate to Projects tab | Screen shows: DashboardAppBar, Projects Overview Card, Filter Tabs, Search Bar, Projects List | P1 |
| UA-PROJ-002 | Projects Overview Card | Verify overview stats display | 1. Observe overview card | Card shows sparkle icon, "Projects Overview" title, "Track your assignment progress" subtitle, stats row (Total, Active, Review, Done), "New Project" button | P1 |
| UA-PROJ-003 | Stats Row - Total | Verify total projects count | 1. Observe stats row | "Total" label with correct count from projectCountsProvider[5] | P1 |
| UA-PROJ-004 | Stats Row - Active | Verify active projects count | 1. Observe stats row | "Active" label in primary color with count from projectCountsProvider[1] | P1 |
| UA-PROJ-005 | Stats Row - Review | Verify review projects count | 1. Observe stats row | "Review" label in warning color with count from projectCountsProvider[2] | P1 |
| UA-PROJ-006 | Stats Row - Done | Verify completed projects count | 1. Observe stats row | "Done" label in success color with count from projectCountsProvider[4] | P1 |
| UA-PROJ-007 | New Project Button | Verify new project button navigation | 1. Tap "+ New Project" button | Navigates to /add-project/new route | P1 |
| UA-PROJ-008 | 4 Filter Tabs | Verify filter tab labels | 1. Observe filter tabs | Four tabs: "In Review", "In Progress", "For Review", "History" with project counts in parentheses | P1 |
| UA-PROJ-009 | Tab Selection Visual | Verify selected tab styling | 1. Tap different tabs | Selected tab: dark brown background, white text. Unselected: white background, secondary text, light border | P2 |
| UA-PROJ-010 | In Review Tab Filtering | Verify In Review tab shows correct statuses | 1. Select "In Review" tab | Shows projects with statuses: submitted, analyzing, quoted, payment_pending | P1 |
| UA-PROJ-011 | In Progress Tab Filtering | Verify In Progress tab shows correct statuses | 1. Select "In Progress" tab | Shows projects with statuses: paid, assigning, assigned, in_progress, QC states | P1 |
| UA-PROJ-012 | For Review Tab Filtering | Verify For Review tab shows correct statuses | 1. Select "For Review" tab | Shows projects with status: delivered (awaiting user approval) | P1 |
| UA-PROJ-013 | History Tab Filtering | Verify History tab shows correct statuses | 1. Select "History" tab | Shows projects with statuses: completed, auto_approved, cancelled, refunded | P1 |
| UA-PROJ-014 | Search Bar | Verify search functionality | 1. Type in search bar 2. Enter part of project title | Projects filtered by title or project number (case-insensitive); search updates in real-time | P1 |
| UA-PROJ-015 | Search No Results | Verify empty search state | 1. Search for non-existent project | Shows "No Results Found" with "Try a different search term" message | P2 |
| UA-PROJ-016 | Project Card - Completed | Verify completed project card styling | 1. View a completed project card | Green checkmark icon, "Completed" status badge in green, no dashed border | P2 |
| UA-PROJ-017 | Project Card - In Progress | Verify in-progress project card | 1. View an in-progress project card | Primary color trending_up icon, "In Progress" badge, dashed border in primary color, progress bar shown | P2 |
| UA-PROJ-018 | Project Card - Payment Pending | Verify payment pending card | 1. View a quoted/payment_pending project | Warning color payment icon, "Payment Pending" badge, dashed border, "Pay Now" action chip | P1 |
| UA-PROJ-019 | Project Card - Delivered | Verify delivered project card | 1. View a delivered project card | Warning hourglass icon, "Under Review" badge, dashed border, "Changes" and "Approve" action buttons | P1 |
| UA-PROJ-020 | Project Card Content | Verify card displays correct information | 1. Observe any project card | Shows: title (max 2 lines), #project_number, service type, last updated time, action button | P1 |
| UA-PROJ-021 | Last Updated Formatting | Verify time formatting | 1. Check project updated times | Format: "Xm ago" (<60min), "Xh ago" (<24h), "Xd ago" (<7d), "MMM d" (>7d) | P2 |
| UA-PROJ-022 | Progress Bar (In Progress) | Verify progress percentage bar | 1. View in-progress project | ProjectProgressIndicator shows progress percentage with label | P2 |
| UA-PROJ-023 | Pay Now Action | Verify Pay Now chip navigation | 1. Tap "Pay Now" on payment_pending card | Navigates to /projects/{id}/pay route | P1 |
| UA-PROJ-024 | Approve Action | Verify approval dialog | 1. Tap "Approve" on delivered card | Confirmation dialog: "Approve Delivery" title, "Are you sure?" message, Cancel and Approve (green) buttons | P1 |
| UA-PROJ-025 | Approve Confirmation | Verify approval executes | 1. In approval dialog, tap "Approve" | Project status updated via projectNotifierProvider.approveProject; dialog closes | P1 |
| UA-PROJ-026 | Request Changes Action | Verify changes feedback modal | 1. Tap "Changes" on delivered card | FeedbackInputModal appears for entering text feedback | P1 |
| UA-PROJ-027 | Request Changes Submission | Verify changes request submits | 1. Enter feedback 2. Submit | projectNotifierProvider.requestChanges called with project ID and feedback text | P1 |
| UA-PROJ-028 | Card Tap Navigation | Verify card tap goes to detail | 1. Tap a project card (not action buttons) | Navigates to /projects/{project.id} detail screen | P1 |
| UA-PROJ-029 | Pull-to-Refresh | Verify pull-to-refresh | 1. Pull down on projects list | projectsProvider, projectCountsProvider, walletProvider all invalidated; data refreshes | P1 |
| UA-PROJ-030 | Pending Payment Modal | Verify automatic payment prompt | 1. Open Projects screen with pending payment projects | PaymentPromptModal shows for first pending project with "Pay Now" and "Remind Later" options | P1 |
| UA-PROJ-031 | Pending Payment - Pay Now | Verify Pay Now from modal | 1. Tap "Pay Now" on payment modal | Navigates to project payment screen | P1 |
| UA-PROJ-032 | Pending Payment - Remind Later | Verify Remind Later | 1. Tap "Remind Later" on payment modal | Snackbar "We'll remind you about payment for [title]" with "Pay Now" action button | P2 |
| UA-PROJ-033 | Duplicate Modal Prevention | Verify modal doesn't show twice | 1. Navigate away and back to Projects tab | Static _isPaymentModalShowing flag prevents duplicate modals in IndexedStack | P2 |
| UA-PROJ-034 | Empty State - In Review | Verify empty in-review tab | 1. View In Review with no projects | "No Projects In Review" + "Projects awaiting AssignX review will appear here" | P2 |
| UA-PROJ-035 | Empty State - In Progress | Verify empty in-progress tab | 1. View In Progress with no projects | "No Projects In Progress" + "Projects being worked on by experts will appear here" | P2 |
| UA-PROJ-036 | Empty State - For Review | Verify empty for-review tab | 1. View For Review with no projects | "No Projects For Review" + "Projects awaiting your approval will appear here" | P2 |
| UA-PROJ-037 | Empty State - History | Verify empty history tab | 1. View History with no projects | "No Project History" + "Completed and cancelled projects will appear here" | P2 |
| UA-PROJ-038 | Error State | Verify error handling in project list | 1. Simulate network error | Error icon, "Failed to load projects" text, "Retry" button that invalidates provider | P1 |
| UA-PROJ-039 | Transparent Background | Verify transparent scaffold | 1. Observe projects screen | Scaffold background is transparent (shows SubtleGradientScaffold from MainShell) | P3 |
| UA-PROJ-040 | Revision Status Card | Verify revision card styling | 1. View project with revision_requested/in_revision status | Red edit_note icon, "Revision" badge in red, dashed red border | P2 |

---

### 2.4 Project Detail

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| UA-PDET-001 | Detail Screen Layout | Verify project detail screen structure | 1. Tap a project card | Screen shows: sticky header (back arrow, project name), status banner, sections for brief, deliverables, quality badges | P1 |
| UA-PDET-002 | Sticky Header | Verify header with back arrow and kebab menu | 1. Observe top of detail screen | Header with back arrow, project title, kebab menu icon (3 dots) with Cancel/Support options | P1 |
| UA-PDET-003 | Status Banner | Verify colored status banner | 1. View project with any status | Colored strip/banner at top reflecting current project status (color matches status) | P1 |
| UA-PDET-004 | Deadline Timer | Verify real-time countdown display | 1. View project with active deadline | DeadlineBadge widget shows countdown (days/hours/minutes remaining) | P1 |
| UA-PDET-005 | Project Brief Accordion | Verify collapsible project brief | 1. Tap the project brief section | ProjectBriefAccordion expands/collapses to show full project details (topic, word count, guidelines, references) | P2 |
| UA-PDET-006 | Deliverables Section | Verify deliverables display and download | 1. View completed project with deliverables | DeliverablesSection shows list of files with download buttons | P1 |
| UA-PDET-007 | Download File | Verify file download works | 1. Tap download button on a deliverable | File downloads to device; loading indicator during download | P1 |
| UA-PDET-008 | Live Draft Section | Verify live draft tracking | 1. View in-progress project with live draft URL | LiveDraftSection renders WebView of Google Docs/Sheets/Figma in read-only mode | P2 |
| UA-PDET-009 | Quality Badges - Locked State | Verify badges are locked during in-progress | 1. View in-progress project | QualityBadges widget shows AI probability and plagiarism badges as grayed/locked | P2 |
| UA-PDET-010 | Quality Badges - Unlocked | Verify badges unlock on delivery | 1. View delivered project | AI probability badge shows result (e.g., "Human Written" green check or download link); plagiarism badge shows result | P2 |
| UA-PDET-011 | Floating Chat Button | Verify chat FAB | 1. View any active project | FloatingChatButton appears bottom-right with message icon; may show notification badge count | P1 |
| UA-PDET-012 | Chat Button Navigation | Verify chat button opens chat | 1. Tap floating chat button | Opens ProjectChatScreen for this specific project; chat context-aware with project ID | P1 |
| UA-PDET-013 | Auto-Approval Timer | Verify 48-hour countdown | 1. View delivered project | AutoApprovalTimer widget shows countdown from 48 hours; auto-approves when timer reaches zero | P1 |
| UA-PDET-014 | Invoice Download | Verify invoice generation and download | 1. View completed project 2. Tap download invoice | InvoiceDownloadButton triggers PDF generation and download | P2 |
| UA-PDET-015 | Grade Entry | Verify optional grade entry | 1. View completed project 2. Open grade entry | GradeEntryDialog appears with input field for entering grade received | P3 |
| UA-PDET-016 | Review Actions (Delivered) | Verify approve/reject actions | 1. View delivered project | ReviewActions widget shows "Approve" and "Request Changes" buttons | P1 |
| UA-PDET-017 | Timeline View | Verify project timeline | 1. Tap "View Timeline" or timeline section | ProjectTimelineScreen opens showing chronological project events | P2 |
| UA-PDET-018 | Progress Indicator | Verify progress bar in detail | 1. View in-progress project | Progress bar with percentage label reflecting project completion status | P2 |
| UA-PDET-019 | Reference Files | Verify attached reference files display | 1. View project with reference files | Reference files listed with file names and types; downloadable | P2 |
| UA-PDET-020 | Kebab Menu - Cancel | Verify cancel project option | 1. Tap kebab menu 2. Tap "Cancel" | Cancellation confirmation dialog appears | P2 |
| UA-PDET-021 | Kebab Menu - Support | Verify support option | 1. Tap kebab menu 2. Tap "Support" | Opens help/support flow (WhatsApp or ticket) | P2 |
| UA-PDET-022 | Payment Screen Navigation | Verify payment flow from detail | 1. View quoted project 2. Tap "Pay Now" | Navigates to ProjectPaymentScreen with project details and pricing | P1 |

---

### 2.5 Add Project

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| UA-APRJ-001 | Service Selection Sheet | Verify bottom sheet opens with 4 service types | 1. Tap FAB or "New Project" button | ServiceSelectionSheet slides up (modal bottom sheet) with 4 options: New Project, Proofreading, Plag/AI Report, Ask Expert | P1 |
| UA-APRJ-002 | New Project Option | Verify New Project card | 1. Observe service selection | Card shows: create_new_folder_outlined icon, "New Project", "Full project work from scratch", "Starting from Rs.499" | P1 |
| UA-APRJ-003 | Proofreading Option | Verify Proofreading card | 1. Observe service selection | Card shows: spellcheck icon, "Proofreading", "Get your document proofread & edited", "Starting from Rs.199" | P1 |
| UA-APRJ-004 | Plag/AI Report Option | Verify report card | 1. Observe service selection | Card shows: document_scanner_outlined icon, "Plag/AI Report", "Check plagiarism & AI detection", "Starting from Rs.99" | P1 |
| UA-APRJ-005 | Ask Expert Option | Verify expert opinion card | 1. Observe service selection | Card shows: psychology_outlined icon, "Ask Expert", "Get expert opinion on your work", "Starting from Rs.299" | P1 |
| UA-APRJ-006 | Service Selection Navigation | Verify each option navigates correctly | 1. Tap each service type | New Project -> /add-project/new, Proofreading -> /add-project/proofread, Report -> /add-project/report, Expert -> /add-project/expert | P1 |
| UA-APRJ-007 | New Project Form - Subject Dropdown | Verify searchable subject dropdown | 1. Open New Project form 2. Tap Subject field | SubjectDropdown opens with searchable list of academic subjects from database | P1 |
| UA-APRJ-008 | New Project Form - Topic Field | Verify topic text input | 1. Enter project topic | Text field accepts project topic/title with validation | P1 |
| UA-APRJ-009 | New Project Form - Word Count | Verify word count input | 1. Enter word count | WordCountInput widget accepts numeric input for desired word count | P1 |
| UA-APRJ-010 | New Project Form - Deadline Picker | Verify deadline date/time picker | 1. Tap deadline field | DeadlinePicker opens with calendar/date selection; shows "More time = lesser price" pricing note | P1 |
| UA-APRJ-011 | Pricing Note | Verify pricing hint | 1. Observe deadline section | Text "More time = lesser price" displayed near deadline picker | P2 |
| UA-APRJ-012 | New Project Form - Guidelines | Verify guidelines textarea | 1. Enter project guidelines | Multi-line text area accepts detailed instructions | P2 |
| UA-APRJ-013 | New Project Form - File Attachments | Verify file upload | 1. Tap attachment button 2. Select file (PDF/Doc/Image) | FileAttachment widget allows selecting and previewing uploaded files | P1 |
| UA-APRJ-014 | New Project Form - Reference Style | Verify reference style dropdown | 1. Tap reference style field | ReferenceStyleDropdown shows options: APA, Harvard, MLA, Chicago, etc. | P2 |
| UA-APRJ-015 | Budget Display | Verify dynamic budget/price display | 1. Fill form fields | BudgetDisplay widget shows estimated price based on word count, deadline, service type | P2 |
| UA-APRJ-016 | New Project Submit | Verify form submission | 1. Fill all required fields 2. Tap "Submit for Quote" | Project created in Supabase, success popup appears with WhatsApp mention | P1 |
| UA-APRJ-017 | Proofreading Form | Verify proofreading form fields | 1. Select Proofreading service | Form shows: File upload, Focus Area chips (grammar, clarity, structure, etc.) | P1 |
| UA-APRJ-018 | Focus Area Chips | Verify chip selection | 1. Tap focus area chips | FocusAreaChips widget allows multi-selection of focus areas | P2 |
| UA-APRJ-019 | Report Request Form | Verify plag/AI report form | 1. Select Plag/AI Report service | Form shows: Document upload, checkboxes for plagiarism check and AI detection | P1 |
| UA-APRJ-020 | Expert Opinion Form | Verify expert opinion form | 1. Select Ask Expert service | Form shows: Subject dropdown, Question textbox, Optional file attachment | P1 |
| UA-APRJ-021 | Success Popup | Verify submission success popup | 1. Successfully submit any project type | SuccessPopup shows confirmation message mentioning WhatsApp notification for quote | P1 |
| UA-APRJ-022 | Form Validation - Required Fields | Verify required field validation | 1. Try to submit New Project form with empty fields | Error indicators on required fields; form does not submit | P1 |
| UA-APRJ-023 | File Upload - Size/Type Validation | Verify file type and size limits | 1. Try uploading unsupported file or oversized file | Appropriate error message shown; file rejected | P2 |
| UA-APRJ-024 | Sheet Handle and Close | Verify bottom sheet can be dismissed | 1. Drag down on sheet handle or tap outside | Service selection sheet dismisses | P3 |

---

### 2.6 Campus Connect / Marketplace

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| UA-CAMP-001 | Campus Connect Screen Layout | Verify screen structure | 1. Navigate to Campus Connect tab (via ConnectHub) | Screen shows: DashboardAppBar, CampusConnectHero gradient section, search bar, filter tabs, staggered grid feed | P1 |
| UA-CAMP-002 | Hero Section | Verify gradient hero section | 1. Observe hero section | CampusConnectHero displays with gradient background and chat icon | P2 |
| UA-CAMP-003 | Staggered Grid Feed | Verify Pinterest-style masonry layout | 1. Observe content feed | flutter_staggered_grid_view renders posts in masonry/staggered grid layout | P1 |
| UA-CAMP-004 | Category Filter Tabs | Verify filter tabs display | 1. Observe filter tabs | FilterTabsBar shows category options for filtering content | P1 |
| UA-CAMP-005 | Category - Hard Goods | Verify hard goods filter | 1. Select Hard Goods category | Only marketplace items (sell/rent) displayed | P1 |
| UA-CAMP-006 | Category - Housing | Verify housing filter (student) | 1. As student user, select Housing category | Housing listings displayed with housing-specific filters | P1 |
| UA-CAMP-007 | Category - Housing (Non-Student) | Verify housing restriction for non-students | 1. As professional/business user, select Housing | HousingRestrictedState widget displayed instead of listings; explains student-only access | P1 |
| UA-CAMP-008 | Category - Opportunities | Verify opportunities filter | 1. Select Opportunities category | Opportunity posts displayed (jobs, internships, events) | P1 |
| UA-CAMP-009 | Category - Community | Verify community filter | 1. Select Community category | Community discussion posts displayed | P1 |
| UA-CAMP-010 | Search Functionality | Verify search bar | 1. Type in search bar | SearchBarWidget filters posts by search query in real-time | P1 |
| UA-CAMP-011 | Post Card Display | Verify post card content | 1. Observe any post card | PostCard shows appropriate content based on type (image, text, price, distance for items) | P1 |
| UA-CAMP-012 | Like/Save Button | Verify like and save interactions | 1. Tap like button on a post | LikeButton toggles state; SaveButton bookmarks the post | P2 |
| UA-CAMP-013 | Report Button | Verify report functionality | 1. Tap report button on a post | ReportButton opens ReportDialog with reason options | P2 |
| UA-CAMP-014 | Report Dialog | Verify report submission | 1. Open report dialog 2. Select reason 3. Submit | Report submitted to backend; confirmation shown | P2 |
| UA-CAMP-015 | Post Detail Navigation | Verify tap navigates to detail | 1. Tap on a post card | Navigates to PostDetailScreen with full post content | P1 |
| UA-CAMP-016 | Comment Section | Verify comments on post detail | 1. Open post detail 2. View comments | CommentSection shows existing comments; ability to add new comment | P2 |
| UA-CAMP-017 | Create Post (Secondary FAB) | Verify create post button | 1. Tap create/post FAB button | Opens CreatePostScreen with posting options | P1 |
| UA-CAMP-018 | Create Post Form | Verify post creation flow | 1. On create post screen 2. Fill details 3. Submit | Post created with category, content, optional images; appears in feed | P1 |
| UA-CAMP-019 | Pull-to-Refresh | Verify feed refresh | 1. Pull down on feed | marketplaceListingsProvider invalidated; content refreshes | P1 |
| UA-CAMP-020 | Housing Filters | Verify housing-specific filters | 1. Select Housing category 2. Open filters | HousingFilters widget shows budget range, location, furnished toggle | P2 |
| UA-CAMP-021 | Event Filters | Verify event-specific filters | 1. Select events/opportunities 2. Open filters | EventFilters widget shows date range, capacity, event type | P2 |
| UA-CAMP-022 | Resource Filters | Verify resource-specific filters | 1. View resources section 2. Open filters | ResourceFilters widget shows type and subject filters | P2 |
| UA-CAMP-023 | College Filter | Verify college-based filtering | 1. Open college filter | CollegeFilter allows filtering posts by specific college/university | P2 |
| UA-CAMP-024 | Filter Sheet | Verify advanced filter bottom sheet | 1. Tap filter icon | CampusConnectFilterSheet opens with combined filter options | P2 |
| UA-CAMP-025 | Saved Listings | Verify saved posts navigation | 1. Save a post 2. Navigate to saved listings | SavedListingsScreen shows all bookmarked posts | P2 |
| UA-CAMP-026 | Transparent Scaffold | Verify transparent background | 1. Observe screen | Scaffold is transparent showing SubtleGradientScaffold from MainShell | P3 |

---

### 2.7 Experts & Consultations

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| UA-EXPT-001 | Experts Screen Layout | Verify experts screen structure | 1. Navigate to Experts tab | ExpertsScreen shows with tabs/sections for browsing experts | P1 |
| UA-EXPT-002 | Doctors Carousel | Verify doctors horizontal carousel | 1. Observe top of experts screen | DoctorsCarousel displays doctor cards in horizontal scrollable list | P2 |
| UA-EXPT-003 | Expert Card Display | Verify expert card content | 1. Observe any expert card | ExpertCard shows: name, specialization, rating, availability indicator, profile image | P1 |
| UA-EXPT-004 | Expert Detail Screen | Verify detail navigation and content | 1. Tap an expert card | ExpertDetailScreen shows full profile: bio, qualifications, reviews, available slots, pricing | P1 |
| UA-EXPT-005 | Booking Calendar | Verify date/time slot selection | 1. On expert detail, tap "Book Session" | BookingCalendar widget opens with date picker and available time slots | P1 |
| UA-EXPT-006 | Time Slot Selection | Verify slot selection | 1. Select a date 2. Select a time slot | Selected slot highlighted; "Confirm" button becomes active | P1 |
| UA-EXPT-007 | Price Breakdown | Verify price breakdown display | 1. Select a session | PriceBreakdown widget shows: consultation fee, platform fee, taxes, total | P1 |
| UA-EXPT-008 | Booking Confirmation | Verify session booking | 1. Select slot 2. Review price 3. Confirm booking | BookingScreen processes booking, navigates to confirmation; payment deducted | P1 |
| UA-EXPT-009 | My Bookings Screen | Verify bookings list | 1. Navigate to My Bookings tab/section | MyBookingsScreen lists all past and upcoming sessions with status | P1 |
| UA-EXPT-010 | Session Card | Verify session card display | 1. Observe a booking card | SessionCard shows: expert name, date/time, status (upcoming/completed/cancelled), duration | P2 |
| UA-EXPT-011 | Leave Review | Verify review submission | 1. Complete a session 2. Tap "Leave Review" | ExpertReviewForm opens with rating stars and comment field | P2 |
| UA-EXPT-012 | Review Submission | Verify review saves | 1. Enter rating and comment 2. Submit | Review saved to backend; appears on expert's profile | P2 |
| UA-EXPT-013 | Filter by Specialization | Verify specialization filter | 1. Select specialization filter | Expert list filters to only matching specializations | P2 |
| UA-EXPT-014 | Skeleton Loading | Verify loading state | 1. Open experts with slow network | ExpertsSkeleton placeholder cards displayed during loading | P2 |
| UA-EXPT-015 | Empty State | Verify empty experts list | 1. View with no matching experts | Appropriate empty state message displayed | P2 |

---

### 2.8 Connect (Peer Network)

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| UA-CONN-001 | Connect Screen Layout | Verify connect screen structure | 1. Navigate to Connect screen | ConnectScreen shows with sections/tabs for peer networking | P1 |
| UA-CONN-002 | Study Groups Screen | Verify study groups display | 1. Navigate to Study Groups section | StudyGroupsScreen shows available study groups with StudyGroupCard components | P1 |
| UA-CONN-003 | Study Group Card | Verify group card content | 1. Observe a study group card | StudyGroupCard shows: group name, member count, subject, description | P2 |
| UA-CONN-004 | Resource Cards | Verify resource display | 1. Navigate to Resources section | ResourceCards component shows shared study materials and resources | P1 |
| UA-CONN-005 | Search Functionality | Verify connect search | 1. Use ConnectSearch widget | Search filters tutors, groups, or resources by keyword | P1 |
| UA-CONN-006 | Advanced Filter Sheet | Verify advanced filters | 1. Tap filter icon | AdvancedFilterSheet opens with filter options for subject, availability, rating | P2 |
| UA-CONN-007 | Join Group | Verify joining a study group | 1. Tap "Join" on a study group | User added to group; membership confirmed | P2 |
| UA-CONN-008 | Connect Hub Navigation | Verify ConnectHub tab switching | 1. On ConnectHub screen, switch between Campus Connect / Pro Network / Business Hub | ConnectHubScreen properly switches between sub-screens | P1 |

---

### 2.9 Chat & Messaging

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| UA-CHAT-001 | Project Chat Screen | Verify chat screen opens | 1. Tap floating chat button on project detail | ProjectChatScreen opens with project context (project ID auto-known) | P1 |
| UA-CHAT-002 | Real-Time Messaging | Verify messages send and receive in real-time | 1. Send a message 2. Observe delivery | Message appears instantly via Supabase Realtime WebSocket; no refresh needed | P1 |
| UA-CHAT-003 | Message Display | Verify message bubble layout | 1. Observe chat messages | User messages right-aligned (blue), support/admin messages left-aligned (gray); timestamps shown | P1 |
| UA-CHAT-004 | Send Text Message | Verify text message sending | 1. Type message 2. Tap send | Message submitted to Supabase; appears in chat thread; input cleared | P1 |
| UA-CHAT-005 | File Attachment in Chat | Verify sending files | 1. Tap attachment icon 2. Select file 3. Send | File uploaded to Supabase Storage; preview/link appears in chat | P2 |
| UA-CHAT-006 | Message Status | Verify sent/delivered/read indicators | 1. Send a message | Status indicators: sent (single check), delivered (double check), read (blue double check) | P2 |
| UA-CHAT-007 | Floating Chat Button Badge | Verify unread message count | 1. Receive messages while not in chat | FloatingChatButton shows notification badge with unread count | P2 |
| UA-CHAT-008 | System Messages | Verify system event messages | 1. Observe chat after project status change | System messages appear (e.g., "Project status changed to In Progress") | P2 |
| UA-CHAT-009 | Typing Indicator | Verify typing indicator display | 1. Other party starts typing | Typing indicator (dots animation) appears at bottom of chat | P3 |
| UA-CHAT-010 | Empty Chat State | Verify new chat appearance | 1. Open chat for project with no messages | Empty state message encouraging communication displayed | P3 |

---

### 2.10 Profile & Account

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| UA-PROF-001 | Profile Screen Layout | Verify profile screen structure | 1. Navigate to Profile tab | ProfileScreen shows: hero section (avatar, name, role badge), stats card, menu sections | P1 |
| UA-PROF-002 | Profile Hero Section | Verify hero section content | 1. Observe top of profile | ProfileHero displays user avatar, full name, and role badge (student/professional/business) | P1 |
| UA-PROF-003 | Stats Card | Verify stats display | 1. Observe stats card | StatsCard shows: Wallet Balance, Completed Projects, Referral Count, Earnings | P1 |
| UA-PROF-004 | Account Badge | Verify account type badge | 1. Observe profile | AccountBadge widget shows current account tier/type | P2 |
| UA-PROF-005 | Edit Profile Screen | Verify edit profile navigation and form | 1. Tap "Edit Profile" | EditProfileScreen opens with fields: name, email, phone, university, course | P1 |
| UA-PROF-006 | Edit Profile Save | Verify profile update saves | 1. Modify fields 2. Tap Save | Profile updated in Supabase; confirmation shown; returns to profile screen | P1 |
| UA-PROF-007 | Avatar Upload | Verify profile picture upload | 1. Tap avatar 2. Select image | AvatarUploadDialog opens with camera/gallery options; image cropped and uploaded to Supabase Storage | P2 |
| UA-PROF-008 | Payment Methods Screen | Verify payment methods management | 1. Tap "Payment Methods" | PaymentMethodsScreen shows saved cards/UPI methods with add/remove options | P2 |
| UA-PROF-009 | Help & Support Screen | Verify help screen | 1. Tap "Help & Support" | HelpSupportScreen shows WhatsApp contact button, ticket form, FAQ section | P1 |
| UA-PROF-010 | Ticket History | Verify support ticket history | 1. Open help & support | TicketHistorySection shows past support tickets with status | P2 |
| UA-PROF-011 | Account Upgrade Card | Verify upgrade prompt | 1. Observe profile section | AccountUpgradeCard shows upgrade options and benefits | P3 |
| UA-PROF-012 | Account Upgrade Screen | Verify upgrade flow | 1. Tap upgrade card | AccountUpgradeScreen shows available plans and pricing | P2 |
| UA-PROF-013 | Subscription Card | Verify current subscription display | 1. Observe profile | SubscriptionCard shows current plan details | P2 |
| UA-PROF-014 | Preferences Section | Verify preferences display | 1. Observe profile menu | PreferencesSection shows notification, privacy, and app settings shortcuts | P2 |
| UA-PROF-015 | Skeleton Loading | Verify profile loading state | 1. Open profile with slow network | ProfileSkeleton shows placeholder content during loading | P2 |
| UA-PROF-016 | Security Screen | Verify security settings | 1. Tap "Security" menu item | SecurityScreen opens with password change, 2FA options | P2 |
| UA-PROF-017 | Settings Navigation | Verify settings access | 1. Tap "Settings" menu item | Navigates to SettingsScreen (accessible from Profile screen) | P1 |
| UA-PROF-018 | Log Out | Verify logout functionality | 1. Tap "Log Out" | Confirmation dialog appears; on confirm, user signed out, navigated to onboarding/login | P1 |

---

### 2.11 Wallet & Payments

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| UA-WALL-001 | Wallet Screen Layout | Verify wallet screen structure | 1. Navigate to Wallet tab | WalletScreen shows: curved dome hero with credit card, balance widgets grid, transactions, offers | P1 |
| UA-WALL-002 | Credit Card Display | Verify credit card-style balance | 1. Observe dome hero section | Curved dome hero with mesh gradient background, credit card widget showing balance, username | P1 |
| UA-WALL-003 | Balance Display | Verify balance amount | 1. Observe wallet balance | Balance shown in INR format (Rs.X) matching actual wallet balance from walletProvider | P1 |
| UA-WALL-004 | Top-Up Button | Verify top-up action | 1. Tap "Top Up" button on credit card | Top-up bottom sheet appears with amount selection and Razorpay checkout | P1 |
| UA-WALL-005 | Balance Widgets Grid | Verify 2x2 widget grid | 1. Observe below credit card | BalanceWidgetsGrid shows: credits/balance, monthly spend, rewards, loyalty points in 2x2 layout | P1 |
| UA-WALL-006 | Transaction History | Verify transaction list | 1. Scroll down on wallet screen | Transaction history shows recent transactions with date, type (credit/debit), amount, description | P1 |
| UA-WALL-007 | Transaction Item Detail | Verify transaction formatting | 1. Observe a transaction item | Glass-styled item showing: icon, title/description, formatted date, amount (green for credit, red for debit) | P2 |
| UA-WALL-008 | Offers Carousel | Verify promotional offers | 1. Observe offers section | WalletOffersCarousel shows horizontal scrolling promotional offer pills/cards | P2 |
| UA-WALL-009 | Rewards Display | Verify rewards section | 1. Observe rewards area | WalletRewards widget shows earned rewards and loyalty status | P2 |
| UA-WALL-010 | Monthly Spending Chart | Verify spending visualization | 1. Observe spending section | MonthlySpendChart shows bar/line chart of monthly spending history | P2 |
| UA-WALL-011 | Pull-to-Refresh | Verify refresh functionality | 1. Pull down on wallet screen | walletProvider and walletTransactionsProvider invalidated; data refreshes | P1 |
| UA-WALL-012 | Loading State | Verify loading appearance | 1. Open wallet with slow network | Dome hero shows loading skeleton; WalletSkeleton for other sections | P2 |
| UA-WALL-013 | Error State | Verify error handling | 1. Simulate wallet API failure | Error state displayed in hero section (hasError flag); retry available via pull-to-refresh | P1 |
| UA-WALL-014 | Razorpay Integration | Verify payment processing | 1. Initiate top-up 2. Enter amount 3. Proceed to pay | Razorpay SDK opens with payment options (UPI, cards, net banking); on success, balance updates | P1 |
| UA-WALL-015 | Payment Success | Verify post-payment balance update | 1. Complete Razorpay payment | Balance updates immediately; transaction appears in history; success confirmation shown | P1 |
| UA-WALL-016 | Payment Failure | Verify payment failure handling | 1. Cancel or fail Razorpay payment | Appropriate error message; balance unchanged; no ghost transaction | P1 |
| UA-WALL-017 | Offer Pills Section | Verify quick category pills | 1. Observe offer pills | _OfferPillsSection shows quick-tap category pills for offers/deals | P3 |
| UA-WALL-018 | Status Bar Style | Verify light status bar | 1. Observe status bar on wallet | AnnotatedRegion sets SystemUiOverlayStyle.light for dome hero area | P3 |

---

### 2.12 Notifications

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| UA-NOTF-001 | Notifications Screen Layout | Verify screen structure | 1. Navigate to Notifications | Screen shows: AppBar with "Notifications" title, "Mark all read" button, 5 filter tabs, notification list | P1 |
| UA-NOTF-002 | 5 Filter Tabs | Verify tab categories | 1. Observe filter tabs | 5 tabs with icons: All (inbox), Unread (mail), Projects (briefcase), Campus (users), System (settings) | P1 |
| UA-NOTF-003 | Tab Selection Visual | Verify tab selection styling | 1. Tap different tabs | Selected tab: primary color background with white text/icon, shadow. Unselected: transparent with secondary text | P2 |
| UA-NOTF-004 | All Tab | Verify All tab shows everything | 1. Select "All" tab | All notifications displayed regardless of type | P1 |
| UA-NOTF-005 | Unread Tab | Verify Unread filter | 1. Select "Unread" tab | Only unread notifications (is_read == false) displayed | P1 |
| UA-NOTF-006 | Projects Tab | Verify Projects filter | 1. Select "Projects" tab | Only project-related notifications (submitted, assigned, delivered, completed, taskAvailable, taskAssigned) | P1 |
| UA-NOTF-007 | Campus Tab | Verify Campus filter | 1. Select "Campus" tab | Only marketplace/campus and promotional notifications | P1 |
| UA-NOTF-008 | System Tab | Verify System filter | 1. Select "System" tab | Only system alerts, payment received, and payout processed notifications | P1 |
| UA-NOTF-009 | Date Grouping | Verify notifications grouped by date | 1. View notifications list | Grouped under headers: "Today", "Yesterday", "This Week", "MMMM yyyy" for older | P2 |
| UA-NOTF-010 | Notification Tile Content | Verify tile displays correctly | 1. Observe a notification tile | GlassCard with: colored icon circle, title (bold if unread), body (max 2 lines), time, unread blue dot indicator | P1 |
| UA-NOTF-011 | Unread Indicator | Verify blue dot for unread | 1. Observe unread notification | Blue dot (10px circle) with glow shadow on right side of title | P2 |
| UA-NOTF-012 | Read vs Unread Styling | Verify visual difference | 1. Compare read and unread notifications | Unread: bold title (w700), primary text, 0.85 opacity. Read: normal title (w500), secondary text, 0.7 opacity | P2 |
| UA-NOTF-013 | Mark All Read | Verify bulk mark as read | 1. Tap "Mark all read" button | All notifications updated to is_read: true with read_at timestamp; UI refreshes; providers invalidated | P1 |
| UA-NOTF-014 | Tap to Navigate | Verify notification tap navigation | 1. Tap a project notification | Marks as read, navigates to related content: project -> /projects/{id}, chat -> /projects/{id}/chat, wallet -> /wallet | P1 |
| UA-NOTF-015 | Swipe to Delete | Verify dismissible deletion | 1. Swipe notification left | Dismissible widget reveals red trash icon background; notification deleted from database on dismiss | P1 |
| UA-NOTF-016 | Pull-to-Refresh | Verify refresh | 1. Pull down on notification list | notificationsProvider and unreadNotificationsCountProvider invalidated | P1 |
| UA-NOTF-017 | Empty State - All | Verify empty notifications | 1. View with no notifications | "No notifications yet" + "You'll see updates about your projects here" with bell-off icon | P2 |
| UA-NOTF-018 | Empty State - Unread | Verify empty unread | 1. Mark all as read, select Unread tab | "No unread notifications" + "All caught up!" | P2 |
| UA-NOTF-019 | Error State | Verify error handling | 1. Simulate notification fetch failure | GlassCard with alert icon, "Failed to load notifications", "Retry" button | P1 |
| UA-NOTF-020 | Notification Icons by Type | Verify correct icons per type | 1. Observe different notification types | Each type has unique icon: submitted=send, quote=fileText, payment=creditCard, assigned=userPlus, delivered=truck, completed=checkCircle2, message=messageCircle | P2 |
| UA-NOTF-021 | Icon Colors by Type | Verify correct colors per type | 1. Observe notification icons | Info (blue): quote/submitted. Success (green): payment/completed/qcApproved. Primary: delivered/message. Warning: revision/qcRejected. Purple: promotional | P3 |
| UA-NOTF-022 | Time Formatting | Verify time display | 1. Observe notification times | "Just now" (<1min), "Xm ago" (<60min), "Xh ago" (<24h), "MMM d, h:mm a" (>24h) | P2 |

---

### 2.13 Settings

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| UA-SETT-001 | Settings Screen Layout | Verify settings screen structure | 1. Navigate to Settings from Profile | SettingsScreen shows: DashboardAppBar, sections for Account, Notifications, Appearance, Privacy, Language, Support | P1 |
| UA-SETT-002 | Account Section - Email | Verify email display/edit | 1. Observe account section | Current email displayed with option to change | P2 |
| UA-SETT-003 | Account Section - Delete Account | Verify delete account option | 1. Scroll to delete account option | Red-colored delete action with confirmation dialog requiring explicit confirmation | P1 |
| UA-SETT-004 | Notifications - Push Toggle | Verify push notification toggle | 1. Toggle push notifications switch | Toggle switches between on/off states; preference saved; toggleOn color (brown) for on, toggleOff (gray) for off | P1 |
| UA-SETT-005 | Notifications - Email Toggle | Verify email notification toggle | 1. Toggle email notifications | Email notification preference saved | P2 |
| UA-SETT-006 | Notifications - Project Updates | Verify project update toggle | 1. Toggle project updates | Project notification preference saved | P2 |
| UA-SETT-007 | Notifications - Promotions | Verify promotion toggle | 1. Toggle promotional notifications | Promotion notification preference saved | P2 |
| UA-SETT-008 | Appearance - Theme Selection | Verify Light/Dark/System theme | 1. Select each theme option | Theme changes: Light, Dark, or System (follows device setting); uses themeProvider | P1 |
| UA-SETT-009 | Appearance - Theme Visual | Verify theme tint on selection | 1. Select a theme | Selected theme option shows selectedThemeTint background color | P2 |
| UA-SETT-010 | Appearance - Reduced Motion | Verify reduced motion toggle | 1. Toggle reduced motion | Animations disabled/reduced throughout app; uses accessibilityProvider | P2 |
| UA-SETT-011 | Appearance - Compact Mode | Verify compact mode toggle | 1. Toggle compact mode | UI elements reduce spacing for compact layout | P3 |
| UA-SETT-012 | Privacy - Analytics Opt-out | Verify analytics toggle | 1. Toggle analytics | Analytics tracking enabled/disabled based on preference | P2 |
| UA-SETT-013 | Privacy - Online Status | Verify online status toggle | 1. Toggle online status visibility | Online/offline status visibility to other users controlled | P2 |
| UA-SETT-014 | Privacy - Data Privacy | Verify data privacy option | 1. Tap data privacy option | Opens data privacy information/settings | P2 |
| UA-SETT-015 | Language Picker | Verify language selection | 1. Tap language option | LanguagePicker opens with available languages; uses translationProvider; app language updates | P1 |
| UA-SETT-016 | Support - FAQ | Verify FAQ navigation | 1. Tap FAQ option | Opens FAQ section or web page | P2 |
| UA-SETT-017 | Support - Contact | Verify contact option | 1. Tap contact option | Opens contact method (WhatsApp/email) via url_launcher | P2 |
| UA-SETT-018 | Support - Terms | Verify terms & conditions | 1. Tap Terms option | Opens terms & conditions page | P2 |
| UA-SETT-019 | Support - Privacy Policy | Verify privacy policy | 1. Tap Privacy Policy option | Opens privacy policy page | P2 |
| UA-SETT-020 | Support - About | Verify about section | 1. Tap About option | Shows app information and version | P2 |
| UA-SETT-021 | App Version Display | Verify version number | 1. Observe bottom of settings | App version displayed using package_info_plus (e.g., "Version 1.0.0 (1)") | P3 |
| UA-SETT-022 | Account Upgrade Card | Verify upgrade prompt in settings | 1. Observe settings | AccountUpgradeCard shows upgrade options (if applicable to user's current plan) | P3 |
| UA-SETT-023 | Export Data | Verify data export option | 1. Tap export data | Export function available with exportBlueBackground styling; generates user data export | P2 |
| UA-SETT-024 | Clear Cache | Verify cache clearing | 1. Tap clear cache | Cache cleared; clearRedBackground styling; confirmation shown | P3 |
| UA-SETT-025 | Transparent Background | Verify gradient from MainShell | 1. Observe settings background | Transparent scaffold showing gradient from MainShell | P3 |

---

### 2.14 Business Hub

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| UA-BHUB-001 | Business Hub Screen Layout | Verify screen structure | 1. Navigate to Business Hub (via ConnectHub for business users) | BusinessHubScreen shows: hero section, search bar, filter tabs, staggered content grid | P1 |
| UA-BHUB-002 | Hero Section | Verify business hub hero | 1. Observe hero section | BusinessHubHero displays with gradient background and business-focused branding | P2 |
| UA-BHUB-003 | Category Filter Tabs | Verify business categories | 1. Observe filter tabs | BusinessFilterTabsBar shows categories: News, Opportunities, Partnerships, Networking, Products | P1 |
| UA-BHUB-004 | Search Bar | Verify business search | 1. Use BusinessSearchBar | Search filters business posts by keyword | P1 |
| UA-BHUB-005 | Business Post Card | Verify card display | 1. Observe business post card | BusinessPostCard shows relevant business content with appropriate formatting | P1 |
| UA-BHUB-006 | Create Business Post | Verify post creation | 1. Tap create post button | BusinessCreatePostScreen opens with form for creating business-relevant content | P1 |
| UA-BHUB-007 | Post Detail Screen | Verify detail navigation | 1. Tap a business post | BusinessPostDetailScreen opens with full post content, comments, interactions | P1 |
| UA-BHUB-008 | Save Post | Verify bookmarking | 1. Tap save/bookmark on a post | Post saved; appears in BusinessSavedPostsScreen | P2 |
| UA-BHUB-009 | Saved Posts Screen | Verify saved posts | 1. Navigate to saved posts | BusinessSavedPostsScreen shows all bookmarked business posts | P2 |
| UA-BHUB-010 | Staggered Grid | Verify masonry layout | 1. Observe content feed | Posts displayed in staggered/masonry grid layout | P2 |
| UA-BHUB-011 | Filter by Category | Verify category filtering | 1. Select a specific category | Only posts matching selected category displayed | P1 |
| UA-BHUB-012 | Empty State | Verify empty feed | 1. View with no business posts | Appropriate empty state message shown | P2 |

---

### 2.15 Pro Network

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| UA-PNET-001 | Pro Network Screen Layout | Verify screen structure | 1. Navigate to Pro Network (via ConnectHub for professional users) | ProNetworkScreen shows: filter tabs, search bar, content feed | P1 |
| UA-PNET-002 | Category Filter Tabs | Verify professional categories | 1. Observe filter tabs | ProFilterTabsBar shows categories: Industry News, Jobs, Professional Development, Networking, Thought Leadership | P1 |
| UA-PNET-003 | Search Bar | Verify professional search | 1. Use ProSearchBar | Search filters professional posts by keyword | P1 |
| UA-PNET-004 | Pro Post Card | Verify card display | 1. Observe a professional post | ProPostCard shows relevant professional content with engagement indicators | P1 |
| UA-PNET-005 | Create Professional Post | Verify post creation | 1. Tap create post button | ProCreatePostScreen opens with form for professional content creation | P1 |
| UA-PNET-006 | Post Detail Screen | Verify detail navigation | 1. Tap a professional post | ProPostDetailScreen opens with full content, comments, professional interactions | P1 |
| UA-PNET-007 | Save Post | Verify bookmarking | 1. Tap save on a post | Post saved; appears in ProSavedPostsScreen | P2 |
| UA-PNET-008 | Saved Posts Screen | Verify saved posts | 1. Navigate to saved posts | ProSavedPostsScreen shows all bookmarked professional posts | P2 |
| UA-PNET-009 | Filter by Category | Verify category filtering | 1. Select a specific category (e.g., Jobs) | Only posts matching selected category displayed | P1 |
| UA-PNET-010 | Empty State | Verify empty feed | 1. View with no professional posts | Appropriate empty state message shown | P2 |
| UA-PNET-011 | ConnectHub Role Routing | Verify correct hub shown per role | 1. Login as student -> ConnectHub shows Campus Connect 2. Login as professional -> shows Pro Network 3. Login as business -> shows Business Hub | ConnectHubScreen routes to the correct sub-screen based on user role | P1 |
| UA-PNET-012 | Pull-to-Refresh | Verify feed refresh | 1. Pull down on Pro Network feed | Content refreshes from backend | P1 |

---

## Appendix A: Test Environment Requirements

### Device Matrix

| Device Category | OS Versions | Screen Sizes |
|----------------|-------------|--------------|
| Android Phone (Low-end) | Android 10+ | 5.0" - 5.5" (720p) |
| Android Phone (Mid-range) | Android 12+ | 6.0" - 6.5" (1080p) |
| Android Phone (High-end) | Android 14+ | 6.5" - 6.8" (1440p) |
| iPhone SE (3rd gen) | iOS 16+ | 4.7" |
| iPhone 14/15 | iOS 17+ | 6.1" |
| iPhone 14/15 Pro Max | iOS 17+ | 6.7" |
| iPad (Optional) | iPadOS 17+ | 10.9" |

### Network Conditions to Test

| Condition | Description |
|-----------|-------------|
| WiFi (Fast) | >50 Mbps, <50ms latency |
| 4G (Normal) | 10-30 Mbps, 50-100ms latency |
| 3G (Slow) | 1-5 Mbps, 100-500ms latency |
| Edge/2G | <500 Kbps, >500ms latency |
| No Connection | Airplane mode / WiFi off |
| Intermittent | Simulate connection drops |

### Test Accounts

| Account Type | Email | Purpose |
|-------------|-------|---------|
| Admin Bypass | admin@gmail.com (password: Admin@123) | Quick login for testing without Google/Magic Link |
| Student User | Create via Google OAuth | Test student-specific features (Campus Connect, Housing) |
| Professional User | Create via Google OAuth, select Job Seeker | Test Pro Network features |
| Business User | Create via Google OAuth, select Business/Creator | Test Business Hub features |

---

## Appendix B: Priority Summary

| Priority | Count | Description |
|----------|-------|-------------|
| P1 (Critical) | ~145 | Blocks core usage; must pass for release |
| P2 (Major) | ~115 | Important functionality; should pass for release |
| P3 (Minor) | ~35 | Nice-to-have, cosmetic, animations; can defer |
| **Total** | **~295** | **Complete User App test cases** |

---

## Appendix C: Test ID Reference

| Prefix | Feature Area | Section |
|--------|-------------|---------|
| UA-AUTH | Authentication & Onboarding | 2.1 |
| UA-DASH | Home Dashboard | 2.2 |
| UA-PROJ | My Projects | 2.3 |
| UA-PDET | Project Detail | 2.4 |
| UA-APRJ | Add Project | 2.5 |
| UA-CAMP | Campus Connect / Marketplace | 2.6 |
| UA-EXPT | Experts & Consultations | 2.7 |
| UA-CONN | Connect (Peer Network) | 2.8 |
| UA-CHAT | Chat & Messaging | 2.9 |
| UA-PROF | Profile & Account | 2.10 |
| UA-WALL | Wallet & Payments | 2.11 |
| UA-NOTF | Notifications | 2.12 |
| UA-SETT | Settings | 2.13 |
| UA-BHUB | Business Hub | 2.14 |
| UA-PNET | Pro Network | 2.15 |

---

**END OF PART 1 - USER APP**

*PART 2 will cover: Doer App, Supervisor App, User Web, Admin Web, Backend/Supabase, Cross-Platform Integration Tests, and Performance & Security Tests.*
