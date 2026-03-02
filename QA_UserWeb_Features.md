# AssignX User-Web (localhost:3003) - Complete Feature Documentation

> **Generated:** 2026-02-25
> **App Version:** 1.0.0-beta (Build 2024.12.26)
> **Status:** Beta
> **Logged in as:** Admin Test User (admin@gmail.com)

---

## Table of Contents

1. [Global Navigation & Layout](#1-global-navigation--layout)
2. [/home - Dashboard](#2-home---dashboard)
3. [/projects - Projects Page](#3-projects---projects-page)
4. [/projects/new - New Project Form](#4-projectsnew---new-project-form)
5. [/campus-connect - Campus Connect](#5-campus-connect---campus-connect)
6. [/experts - Expert Consultations](#6-experts---expert-consultations)
7. [/wallet - Wallet](#7-wallet---wallet)
8. [/settings - Settings](#8-settings---settings)
9. [/profile - Profile](#9-profile---profile)

---

## 1. Global Navigation & Layout

### Top Navigation Bar (Banner)

Present on every page. Contains the following elements:

| Element | Type | Description |
|---------|------|-------------|
| AssignX Logo + Text | Link | Navigates to `/home`. Includes app icon image and "AssignX" text. |
| Page Title | Heading (h1) | Dynamically shows the current page name (e.g., "Dashboard", "Projects", "Campus Connect", etc.) |
| Language Selector | Button/Dropdown | Shows current language with flag emoji (default: "English"). Opens dropdown menu on click. |
| Wallet Link | Link | Shows "Wallet . [balance]" (e.g., "Wallet . Rs.0"). Navigates to `/wallet`. Includes wallet icon. |
| Toggle Theme | Button | Switches between light and dark mode. Has sun/moon icon. |
| Notifications Bell | Button | Shows unread notification count as a badge (e.g., "7"). Opens a dropdown notification panel. |

### Language Options (Dropdown)

| Language | Flag | Notes |
|----------|------|-------|
| English | US flag | Default |
| Hindi | India flag | |
| Francais | France flag | |
| Arabic | UAE flag | Tagged as "RTL" |
| Espanol | Spain flag | |
| Chinese | China flag | |

### Notifications Panel (Dropdown Menu)

- **Header:** "Notifications" with a "Mark all read" button
- **Separator** between header and notification list
- **Notification Items** (menuitem role, clickable):
  - Each notification shows:
    - **Title** (e.g., "Quote Ready", "Project Completed!", "Project Delivered!", "Payment Received")
    - **Description** (detail text about the notification)
    - **Timestamp** (e.g., "1 day ago", "3 days ago")
  - Observed notification types:
    - Quote Ready
    - Project Completed!
    - Project Delivered!
    - Payment Received

### Bottom Navigation Bar (Sidebar on Desktop)

Fixed navigation bar at the bottom (mobile) / side (desktop). Contains icon links:

| Position | Destination | Route |
|----------|-------------|-------|
| 1 | Home/Dashboard | `/home` |
| 2 | Projects | `/projects` |
| 3 | Campus Connect | `/campus-connect` |
| 4 | Experts | `/experts` |
| 5 | Wallet | `/wallet` |
| 6 | Settings | `/settings` |
| 7 | Profile (shows user initials "AT") | `/profile` |

---

## 2. /home - Dashboard

**Page Title in Header:** "Dashboard"

### Greeting Section

- **Heading (h1):** "Good Evening," (time-of-day greeting)
- **Heading (h2):** "Admin" (user's first name) with a verification/avatar image
- **Subtitle:** "Ready to optimize your workflow and generate insights."

### Quick Stats Row

Three stat cards displayed inline:

| Stat | Value | Icon |
|------|-------|------|
| Active | 0 | Activity icon |
| Pending | 1 | Clock icon |
| Wallet | Rs.0 | Wallet icon |

### Needs Attention Section

- **Header:** "Needs Attention" with count badge (1)
- **Action Card (button):**
  - Project: "Statistical Analysis of Sales Data"
  - Status: "Quote Ready"
  - Arrow/chevron icon for navigation

### Quick Action Cards (Service Cards)

Four service cards displayed in a grid:

| Card | Type | Heading | Description | Route | Badge |
|------|------|---------|-------------|-------|-------|
| 1 | Link | New Project | "Essays, research, assignments & more" | `/projects/new` | "Start Here" sparkle badge |
| 2 | Link | Expert Sessions | "1-on-1 video consultations" | `/experts` | "50+ experts" |
| 3 | Link | Plagiarism Check | "AI-powered detection" | `/projects/new?type=plagiarism` | "99.9% Accurate" with shield icon |
| 4 | Button | Campus Connect | Rotating text: "Campus Events - Never miss what's happening" / "Student Housing - Find your perfect place" | N/A (opens campus connect) | "Live" with pulse indicator |

Each card has an icon/illustration and a chevron/arrow for navigation.

---

## 3. /projects - Projects Page

**Page Title in Header:** "Projects"

### Quote Ready Dialog (Auto-popup)

A dialog modal that appears when a project has a pending quote:

| Element | Details |
|---------|---------|
| Title | "Quote Ready" |
| Subtitle | "Your project has been reviewed and quoted" |
| Project ID | AX-769834 |
| Project Name | Statistical Analysis of Sales Data |
| Subject | Mathematics |
| Quote Amount | Rs.500 |
| Validity | 24 hours |
| Primary Button | "Proceed to Pay" (with icon) |
| Secondary Button | "I'll pay later" |
| Info Note | "Work begins after payment" (with info icon) |
| Close Button | X button in top-right corner |

### Greeting & Stats Header

- **Heading (h1):** "Good Evening,"
- **Heading (h2):** "Admin" (with avatar)
- **Subtitle:** "Track your projects and manage deadlines efficiently."
- **Stats Row:**
  - 0 Active
  - 1 Done
  - 1 Payment Due

### Quick Action Cards

Three action cards:

| Card | Heading | Description | Count | Icon |
|------|---------|-------------|-------|------|
| New Project | "New Project" | "Upload assignment & get expert help" | N/A | Sparkle badge "Start Here" |
| Active Projects | "Active Projects" | "Being worked on" | 0 | Activity icon |
| Completed | "Completed" | "All done" | 1 | Check icon |

### Action Required Section

- **Header:** "Action Required" with count badge (1)
- **Project Card (clickable):**
  - Status badge: "Payment Due" (with icon)
  - Title: "Statistical Analysis of Sales Data"
  - ID & Subject: "#AX-769834 . Mathematics"
  - Amount: Rs.500
  - "Pay Now" button (with arrow icon)

### Project Tabs (Filter Tabs)

Four filter tabs for the project list:

| Tab | Count | Active State |
|-----|-------|--------------|
| Active | - | Default view |
| Review | 2 | Badge count |
| Pending | - | No badge |
| Completed | 1 | Badge count |

### Search Bar

- **Icon:** Search magnifying glass icon
- **Textbox:** Placeholder "Search projects..."

### Project List Cards

Each project card (clickable) shows:

| Element | Example |
|---------|---------|
| Status Badge | "Submitted" (with icon) |
| Title | "assignmet" |
| ID & Subject | "#AX-190278 . Engineering" |
| Deadline indicator | "1d left" (with clock icon) |
| Action icon | Chevron/arrow |

---

## 4. /projects/new - New Project Form

**Layout:** Split-screen design with a left sidebar and main form area.

### Left Sidebar (Progress Panel)

| Element | Details |
|---------|---------|
| Logo | AssignX icon + text |
| Progress Indicator | Circle with "25% Complete" |
| Step Title | "Choose Your Focus" |
| Step Description | "Select the subject area that matches your project. Our experts cover 50+ academic fields." |
| Pro Tip | "Not sure? Start broad - you can refine details later." |
| Trust Badges | "15,234 projects", "4.9/5 rating", "98% on-time" |
| Next Step Hint | "Next: Set requirements" with arrow |

### Main Form Area

**Section Heading:** "Project Details"
**Subtitle:** "What kind of project do you need help with?"

#### Project Type Selection (Button Group)

Five project type options (radio-style buttons):

| Type | Icon | Description |
|------|------|-------------|
| Assignment | Document icon | "Academic work, essays, homework" |
| Document | File icon | "Reports, thesis, papers" |
| Website | Globe icon | "Web development projects" |
| App | Smartphone icon | "Mobile or web applications" |
| Consultancy | Users icon | "Expert consultation" |

#### Subject Area (Combobox/Searchable Dropdown)

Label: "Subject Area"
Placeholder: "Select subject..."

Available options:

| Subject |
|---------|
| Engineering |
| Business & Management |
| Medicine & Healthcare |
| Law |
| Natural Sciences |
| Mathematics & Statistics |
| Humanities & Literature |
| Social Sciences |
| Arts & Design |
| Other |

Each option has a category icon.

#### Topic / Title (Text Input)

- **Label:** "Topic / Title"
- **Placeholder:** "e.g., Impact of Social Media on Mental Health"

#### Continue Button

- **Text:** "Continue" with arrow icon
- Advances to the next step in the multi-step project creation flow

---

## 5. /campus-connect - Campus Connect

**Page Title in Header:** "Campus Connect"

### Hero Section

| Element | Details |
|---------|---------|
| Badge | "Campus Connect" (with icon) |
| Greeting | "Good Evening, there" |
| Campus Status | "Your Campus is BUZZING" (with animation icon) |
| Live Stats | "47 posts in last hour", "234 students online", "12 colleges active" |
| Description | "Join conversations, discover opportunities, and connect with students across 500+ colleges. Your campus community awaits." |
| Primary CTA | "Verify College to Post" (link to `/verify-college`) with arrow |
| Secondary CTA | "Explore" button |

### Live Feed Preview (Right Panel)

- **Header:** "15 cities connected"
- **Feed Items** (4 preview posts, each clickable):

| College | Time | Content | Category |
|---------|------|---------|----------|
| IIT Delhi | 2m | "Anyone selling MacBook charger?" | Market |
| BITS Pilani | 5m | "Looking for roommate near campus" | Housing |
| VIT Vellore | 8m | "Hackathon this weekend - need designer!" | Event |
| NIT Trichy | 12m | "How to prepare for GATE?" | Question |

Each post shows college initial avatar, college name, timestamp, content preview, and category tag.

### Feature Carousel (Slider)

A carousel/slider showcasing community features:

**Current Slide:**
- Badge: "Connect & Collaborate"
- Heading: "Your Campus Community"
- Description: "Join thousands of students sharing knowledge, opportunities, and experiences across 500+ colleges"
- Feature bullets:
  - Ask academic doubts
  - Share study resources
  - Form study groups

**Navigation Controls:**
- "Previous slide" button
- "Next slide" button
- 4 dot indicators (Go to slide 1-4)

### "What is Campus Connect?" Section

- **Heading:** "What is Campus Connect?"
- **Description:** "Campus Connect is your all-in-one platform to stay connected with your college community. From academic help to housing, we've got you covered."

**Feature Cards (6 cards, clickable):**

| Feature | Icon | Description |
|---------|------|-------------|
| Ask & Answer | Chat icon | "Get help with academic doubts from seniors and peers" |
| Find Housing | Home icon | "Discover verified PGs, flats, and roommates near campus" |
| Grab Opportunities | Briefcase icon | "Find internships, jobs, and freelance gigs" |
| Join Events | Calendar icon | "Never miss fests, hackathons, and workshops" |
| Buy & Sell | Shopping icon | "Trade textbooks, gadgets, and more safely" |
| Network | Users icon | "Connect with students from 500+ colleges" |

### Quick Access Section

- **Heading:** "Quick Access"
- **Quick Action Buttons (5):**

| Button | Emoji | Subtitle |
|--------|-------|----------|
| Questions | ? | "Ask doubts" |
| Jobs | Briefcase | "Internships" |
| Events | Party | "Campus events" |
| Market | Shopping bag | "Buy & sell" |
| Resources | Books | "Study tips" |

### Search & Filter Bar

| Element | Details |
|---------|---------|
| Search Icon | Magnifying glass |
| Search Input | Placeholder: "Search posts, questions, events..." |
| College Filter | "All Colleges" dropdown button |
| Filter/Sort Buttons | 2 icon buttons for additional filtering/sorting |

### Category Filter Tabs

Horizontal scrollable tab bar with 12 category filters:

| Tab | Emoji |
|-----|-------|
| All | (icon) |
| Questions | ? |
| Opportunities | Briefcase |
| Events | Party |
| Marketplace | Shopping bag |
| Resources | Books |
| Lost & Found | Magnifying glass |
| Rides | Car |
| Study Groups | People |
| Clubs | Trophy |
| Announcements | Megaphone |
| Discussions | Speech bubble |

### Posts Feed Area

- **Loading State:** Shows spinner icon with "Loading posts..." text

---

## 6. /experts - Expert Consultations

**Page Title in Header:** "Expert Consultations"

### Search & Stats Header

| Element | Details |
|---------|---------|
| Heading | "Find Your Expert" |
| Subtitle | "Connect with verified professionals for consultations" |
| Search Bar | Placeholder: "Search by name, specialty, or condition..." with keyboard shortcut indicator "/" |
| Trust Stats | "500+ Verified", "4.9 Rating", "24/7 Available" |

### Main Tabs (3 tabs)

| Tab | Badge | Description |
|-----|-------|-------------|
| Doctors | - | Medical professionals |
| All Experts | - | All categories of experts |
| My Bookings | 2 | User's booked consultations |

---

### Tab: Doctors

#### Top Pick Section (Featured Doctor)

- **Badge:** "Top Pick"
- **Navigation:** Previous/Next arrows + dot indicators (4 slides)

**Featured Doctor Card:**

| Field | Value |
|-------|-------|
| Avatar | "DA" initials |
| Name | Dr. Ananya Sharma (with verified badge) |
| Credentials | MBBS, MD (Internal Medicine) |
| Rating | 4.9 |
| Sessions | 580+ sessions |
| Response | Quick response |
| Bio | "Experienced physician with 12+ years in internal medicine. Specializes in preventive healthcare, chronic disease management, and lifestyle medicine. Available for online consultations." |
| Price | Rs.499 per session |
| CTA | "Book Now" button |

#### Doctor Specialty Filter Tabs

Horizontal scrollable specialty filter:

| Filter | Emoji |
|--------|-------|
| All | Sparkle |
| Heart | Heart |
| Brain | Brain |
| Kids | Baby |
| Bones | Bone |
| Eyes | Eye |
| General | Stethoscope |
| Skin | Hand |
| Mental | Meditation |

**Count:** "5 doctors available"

#### Doctor Cards (List)

Each card (clickable) displays:

| Element | Details |
|---------|---------|
| Online Status | "Online" badge |
| Avatar | Initials (e.g., "DA", "DR", "DP", "DK") |
| Name | Doctor name + verified badge |
| Credentials | Degree/specialization |
| Rating | Star rating + count (e.g., "4.9 (142)") |
| Sessions | Session count (e.g., "580+") |
| Price | Rate per session |
| CTA | "Book" button |

**Doctors Listed:**

| Name | Credentials | Rating | Sessions | Price |
|------|------------|--------|----------|-------|
| Dr. Ananya Sharma | MBBS, MD (Internal Medicine) | 4.9 (142) | 580+ | Rs.499 |
| Dr. Rajesh Gupta | BDS, MDS (Orthodontics) | 4.7 (98) | 320+ | Rs.399 |
| Dr. Priya Nair | MBBS, MD (Dermatology) | 4.9 (176) | 450+ | Rs.599 |
| Dr. Kavita Singh | MBBS, MD (Psychiatry) | 4.9 (203) | 780+ | Rs.699 |
| Dr. Rohit Malhotra | MBBS, MS (Ophthalmology) | 4.6 (72) | 250+ | Rs.449 |

---

### Tab: All Experts

#### Expert Category Filter Tabs

| Filter | Emoji |
|--------|-------|
| All | Sparkle |
| Medicine | Stethoscope |
| Science | Microscope |
| Code | Computer |
| Data | Chart |
| Math | Triangle ruler |
| Research | Books |
| Writing | Pen |
| Business | Briefcase |
| Engineering | Gear |
| Law | Scales |
| Arts | Palette |

**Count:** "12 experts available"

#### Expert Cards (List)

Each card shows: Avatar initials, Name (with verified badge), Credentials, Category tags, Rating, Session count, Price per session, and "Book" button.

**Full Expert Listing:**

| Name | Credentials | Categories | Rating | Sessions | Price |
|------|------------|------------|--------|----------|-------|
| Dr. Ananya Sharma | MBBS, MD (Internal Medicine) | Medicine | 4.9 | 580+ | Rs.499 |
| Dr. Rajesh Gupta | BDS, MDS (Orthodontics) | Medicine | 4.7 | 320+ | Rs.399 |
| Prof. Vikram Mehta | PhD Computer Science, IIT Bombay | Code, Data | 4.8 | 890+ | Rs.699 |
| Dr. Priya Nair | MBBS, MD (Dermatology) | Medicine | 4.9 | 450+ | Rs.599 |
| Adv. Sanjay Kapoor | LLM, Supreme Court Advocate | Law | 4.6 | 210+ | Rs.999 |
| Dr. Meera Iyer | PhD Mathematics, ISI Kolkata | Math, Data | 4.8 | 620+ | Rs.549 |
| Prof. Arjun Reddy | MBA, IIM Ahmedabad - Strategy Consultant | Business | 4.7 | 340+ | Rs.799 |
| Dr. Kavita Singh | MBBS, MD (Psychiatry) | Medicine | 4.9 | 780+ | Rs.699 |
| Prof. Deepak Joshi | PhD Mechanical Engineering, IIT Delhi | Engineering, Science | 4.5 | 180+ | Rs.449 |
| Dr. Neha Patel | PhD English Literature - Academic Writing Coach | Writing, Research | 4.8 | 520+ | Rs.399 |
| Dr. Rohit Malhotra | MBBS, MS (Ophthalmology) | Medicine | 4.6 | 250+ | Rs.449 |
| Prof. Aisha Khan | PhD Biotechnology - Research Advisor | Science, Research | 4.7 | 310+ | Rs.549 |

---

### Tab: My Bookings

#### Booking Sub-tabs

| Sub-tab | Count |
|---------|-------|
| Upcoming | 2 |
| Completed | 1 |
| Cancelled | - |

#### Upcoming Bookings (2 cards)

**Booking 1:**

| Field | Value |
|-------|-------|
| Expert | Prof. Vikram Mehta (verified) |
| Credentials | PhD Computer Science, IIT Bombay |
| Status | Confirmed |
| Timing | In 2 days, 14:00 - 15:00 |
| Mode | Video Call |
| Topic | "Machine Learning Project Review" |
| Starts in | 1d |
| Amount Paid | Rs.699 |
| Actions | "Message" button, "Reschedule" button, More options button (3-dot) |

**Booking 2:**

| Field | Value |
|-------|-------|
| Expert | Dr. Ananya Sharma (verified) |
| Credentials | MBBS, MD (Internal Medicine) |
| Status | Confirmed |
| Timing | In 5 days, 10:00 - 11:00 |
| Mode | Video Call |
| Topic | "General Health Checkup Discussion" |
| Starts in | 4d |
| Amount Paid | Rs.499 |
| Actions | "Message" button, "Reschedule" button, More options button (3-dot) |

---

## 7. /wallet - Wallet

**Page Title in Header:** "Wallet"

### Virtual Card Display

A styled virtual card showing:

| Element | Details |
|---------|---------|
| Card Number (last 4) | 4242 |
| Balance Label | "Available Balance" |
| Balance Amount | Rs.0 |
| Card Holder | Admin Test User |
| Valid Thru | 02/31 |
| Brand | assignX |

### Action Buttons

| Button | Icon | Description |
|--------|------|-------------|
| Add Balance | Plus/deposit icon | Opens top-up flow |
| Send Money | Send/arrow icon | Opens money transfer flow |

### Stats Cards (3 cards)

| Stat | Value | Icon |
|------|-------|------|
| Rewards | 0 | Gift/star icon |
| Wallet Balance | Rs.0 | Wallet icon |
| Monthly Spend | Rs.0 | Calendar icon |

### Offers Section

**Heading:** "Offers"

4 offer cards (clickable):

| Offer | Category | Provider | Icon |
|-------|----------|----------|------|
| Internet & TV | Utility | Airtel | Service icon |
| Electricity | Utility | Energy Board | Service icon |
| Shopping | Retail | Amazon | Service icon |
| Food & Dining | Food | Cafeteria | Service icon |

### Payment History Section

| Element | Details |
|---------|---------|
| Heading | "Payment History" |
| Filter Button | Icon button (likely for date range or type filter) |
| Empty State | Icon + "No transactions yet" + "Your transaction history will appear here" |

---

## 8. /settings - Settings

**Page Title in Header:** "Settings"
**Page Subtitle:** "Manage your preferences and account"

### Section 1: Notifications

**Heading:** "Notifications"
**Subtitle:** "Manage how you receive updates"

| Setting | Description | Type | Default |
|---------|-------------|------|---------|
| Push Notifications | Get push notifications on your device | Toggle switch | ON |
| Email Notifications | Receive important updates via email | Toggle switch | ON |
| Project Updates | Get notified when projects are updated | Toggle switch | ON |
| Marketing Emails | Receive promotional offers | Toggle switch | OFF |

### Section 2: Appearance

**Heading:** "Appearance"
**Subtitle:** "Customize how the app looks"

| Setting | Description | Type | Default |
|---------|-------------|------|---------|
| Theme | (Theme selector - label visible) | Selector | - |
| Reduced Motion | Minimize animations | Toggle switch | OFF |
| Compact Mode | Use a more compact layout | Toggle switch | OFF |

### Section 3: Privacy & Data

**Heading:** "Privacy & Data"
**Subtitle:** "Control your data"

| Setting | Description | Type | Default |
|---------|-------------|------|---------|
| Analytics Opt-out | Disable anonymous usage analytics | Toggle switch | OFF |
| Show Online Status | Let others see when you are online | Toggle switch | ON |

**Action Buttons:**

| Button | Description | Icon |
|--------|-------------|------|
| Export Data | "Download your data as JSON" | Download icon + chevron |
| Clear Cache | "Clear local storage" | Trash icon + chevron |

### Section 4: About AssignX

**Heading:** "About AssignX"
**Subtitle:** "App information"

| Info | Value |
|------|-------|
| Version | 1.0.0-beta |
| Build | 2024.12.26 |
| Status | Beta |
| Last Updated | Dec 26, 2024 |

**Links:**

| Link | Description | Route |
|------|-------------|-------|
| Terms of Service | "Read our terms" | `/terms` |
| Privacy Policy | "How we handle data" | `/privacy` |
| Open Source | "Third-party licenses" | `/open-source` |

### Section 5: My Roles

**Heading:** "My Roles"
**Subtitle:** "Manage your portal access"

| Role | Description | Type | Default |
|------|-------------|------|---------|
| Student | Access Campus Connect | Toggle switch | OFF |
| Professional | Access Job Portal | Toggle switch | OFF |
| Business | Access Business Portal & VC Funding | Toggle switch | OFF |

### Section 6: Send Feedback

**Heading:** "Send Feedback"
**Subtitle:** "Help us improve"

| Element | Details |
|---------|---------|
| Feedback Type | Three selectable buttons: "Bug" (bug icon), "Feature" (lightbulb icon), "General" (message icon) |
| Feedback Text | Textarea with placeholder "Share your thoughts..." |
| Submit Button | "Send Feedback" (with send icon) |

### Section 7: Danger Zone

**Heading:** "Danger Zone"
**Subtitle:** "Irreversible actions"

| Action | Description | Button Style |
|--------|-------------|-------------|
| Log Out | "Sign out of your account" | "Log Out" button (with icon) |
| Deactivate Account | "Temporarily disable your account" | "Deactivate" button (with icon) |
| Delete Account | "Permanently delete all data" | "Delete" button (with icon) |

---

## 9. /profile - Profile

**Page Title in Header:** "Profile"

### Profile Header

| Element | Details |
|---------|---------|
| Avatar | Large circle with initials "AT" |
| Edit Avatar Button | Camera/edit icon button |
| Name | "Admin Test User" (h1 heading) |
| Plan Badge | "free" (with icon) |
| Email | admin@gmail.com (with copy icon) |
| Join Date | "Joined February 2026" (with calendar icon) |
| Edit Profile Button | "Edit Profile" (with pencil icon) |

### Stats Cards (4 cards)

| Stat | Value | Link |
|------|-------|------|
| Balance | Rs.0 | Links to `/wallet` |
| Projects | 1 | Links to `/projects?tab=history` |
| Referrals | 3 | Non-link card |
| Earned | Rs.150 | Non-link card |

### Add Money Banner

| Element | Details |
|---------|---------|
| Icon | Wallet icon |
| Title | "Add Money to Wallet" |
| Subtitle | "Top-up for quick payments" |
| CTA | "Top Up" link (navigates to `/wallet?action=topup`) |

### Refer & Earn Section

| Element | Details |
|---------|---------|
| Icon | Gift/referral icon |
| Title | "Refer & Earn" |
| Subtitle | "Earn Rs.50 per referral" |
| Referral Code | "EXPERT20" (in a readonly textbox) |
| Copy Button | Icon button next to code field |
| Action Buttons | "Copy Code" button, "Share" button |
| Stats | "3 Referrals", "Rs.150 Earned" (with respective icons) |

### Settings Quick Links

**Heading:** "Settings"

5 expandable/navigable settings items:

| Setting | Description | Extra |
|---------|-------------|-------|
| Personal Information | "Name, phone, and other details" | Chevron icon |
| Academic Details | "University and course info" | Chevron icon |
| Notifications | "Notification preferences" | Chevron icon |
| Security & Privacy | "Password and 2FA" | "2FA" badge |
| Subscription | "Manage your plan" | "Upgrade" badge |

### Footer

| Element | Details |
|---------|---------|
| Version | "AssignX v1.0.0" |
| Links | "Terms" (`/terms`), "Privacy" (`/privacy`), "Help" (`/help`) separated by dots |

---

## Summary of All Routes

| Route | Page Name | Key Features |
|-------|-----------|--------------|
| `/home` | Dashboard | Greeting, stats, needs attention alerts, quick action cards |
| `/projects` | Projects | Project list with tabs (Active/Review/Pending/Completed), search, action required section, quote dialog |
| `/projects/new` | New Project | Multi-step form: project type, subject area, topic input |
| `/projects/new?type=plagiarism` | Plagiarism Check | Variant of new project form |
| `/campus-connect` | Campus Connect | Live feed, category filters (12 categories), search, quick access, feature carousel |
| `/experts` | Expert Consultations | Doctor listings, all experts, bookings management, specialty filters |
| `/wallet` | Wallet | Virtual card, balance, add money, send money, offers, payment history |
| `/settings` | Settings | Notifications, appearance, privacy, roles, feedback, danger zone |
| `/profile` | Profile | User info, stats, referral system, settings quick links |
| `/verify-college` | Verify College | Linked from Campus Connect (not visited) |
| `/terms` | Terms of Service | Linked from Settings & Profile footer (not visited) |
| `/privacy` | Privacy Policy | Linked from Settings & Profile footer (not visited) |
| `/open-source` | Open Source Licenses | Linked from Settings (not visited) |
| `/help` | Help | Linked from Profile footer (not visited) |

---

## Key UX Patterns Observed

1. **Consistent Top Bar:** Every page has the same top navigation with logo, page title, language selector, wallet link, theme toggle, and notification bell.
2. **Bottom/Side Navigation:** 7-item navigation persists across all pages.
3. **Card-Based UI:** Heavy use of cards for projects, experts, offers, stats, and settings.
4. **Badge System:** Notification counts on tabs (Review: 2, Completed: 1, My Bookings: 2), plan badges (free), feature badges (2FA, Upgrade, RTL).
5. **Multi-Language Support:** 6 languages including RTL (Arabic).
6. **Dark/Light Theme:** Toggle available globally.
7. **Real-Time Indicators:** "Live" badge on Campus Connect, "Online" status on doctors, "BUZZING" campus status.
8. **Multi-Step Forms:** Project creation uses a progress-tracked multi-step wizard (25% shown on step 1).
9. **Referral System:** Built-in referral code sharing with earnings tracking.
10. **Role-Based Access:** Users can toggle between Student, Professional, and Business roles.
11. **Currency:** Indian Rupee (Rs.) used throughout.
12. **Keyboard Shortcuts:** "/" for search on experts page, "alt+T" for notifications.
