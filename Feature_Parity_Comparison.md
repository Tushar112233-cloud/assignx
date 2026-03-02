# AssignX: User Web vs User App — Feature Parity Comparison

## Summary

This document compares every feature on the **user-web** (Next.js, port 3003) with the **user-app** (Flutter mobile). Differences are categorized as:

- **MISSING IN APP** — Feature exists on web but not in the app
- **MISSING IN WEB** — Feature exists in app but not on web
- **DIFFERENT** — Feature exists in both but implementation differs
- **MATCH** — Feature is the same on both platforms

---

## 1. NAVIGATION STRUCTURE

### Web (7 nav items)
| # | Label | Route |
|---|-------|-------|
| 1 | Home | `/home` |
| 2 | Projects | `/projects` |
| 3 | Campus Connect | `/campus-connect` |
| 4 | Experts | `/experts` |
| 5 | Wallet | `/wallet` |
| 6 | Settings | `/settings` |
| 7 | Profile | `/profile` |

### App (6 nav items)
| # | Label | Screen |
|---|-------|--------|
| 1 | Home | DashboardScreen |
| 2 | Projects | MyProjectsScreen |
| 3 | ConnectHub | ConnectHubScreen (Campus Connect / Pro Network / Business Hub) |
| 4 | Experts | ExpertsScreen |
| 5 | Wallet | WalletScreen |
| 6 | Profile | ProfileScreen (Settings embedded inside) |

### Differences:
| Issue | Detail | Status |
|-------|--------|--------|
| Settings as separate nav item | Web has `/settings` as a standalone page in the nav bar. App embeds settings inside Profile screen. | **DIFFERENT** — Web separates Settings; App combines it into Profile |
| ConnectHub has sub-tabs | App has Campus Connect + Pro Network + Business Hub as sub-tabs. Web only shows Campus Connect in the nav. | **MISSING IN WEB** — Pro Network and Business Hub tabs |

---

## 2. TOP HEADER BAR

### Web
- Logo (AssignX)
- Page title
- Language selector (6 languages: English, Hindi, Spanish, French, Arabic, German)
- Wallet balance link (₹0)
- Theme toggle (dark/light)
- Notification bell with count badge (7)

### App
- Logo (AssignX)
- Wallet balance (₹0)
- Notification bell with count badge

### Differences:
| Feature | Web | App | Status |
|---------|-----|-----|--------|
| Language selector | Yes (6 languages) | No (only stub translation service) | **MISSING IN APP** |
| Theme toggle in header | Yes | No (only in Settings) | **MISSING IN APP** |
| Page title in header | Yes | No | **DIFFERENT** |

---

## 3. DASHBOARD / HOME

### Web Features
- Greeting: "Good Evening, Admin" with avatar
- Subtitle: "Ready to optimize your workflow and generate insights."
- Stats row: Active (0), Pending (1), Wallet (₹0)
- Needs Attention section with badge count (1)
  - Project cards with status + navigation
- Quick Action Cards (4):
  1. New Project — "Essays, research, assignments & more" → `/projects/new`
  2. Expert Sessions — "1-on-1 video consultations" → `/experts` (badge: "50+ experts")
  3. Plagiarism Check — "AI-powered detection" → `/projects/new?type=plagiarism` (badge: "99.9% Accurate")
  4. Campus Connect — rotating text with "Live" badge → opens campus connect

### App Features
- Greeting: "Good Evening, Admin" with avatar
- Subtitle: "Ready to optimize your workflow and generate insights."
- Stats chips: Active (0), Pending (1), Wallet (₹0)
- Needs Attention section with count (1)
  - Project cards with status + navigation
- Quick Actions (4):
  1. Project Support — "Get expert help with your projects"
  2. AI/Plag Report — "Check originality & AI detection"
  3. Consult Doctor — "Medical consultation service" (Coming Soon badge)
  4. Ref. Generator — "Generate citations for free" (Free badge)
- Recent Projects section (horizontal scroll)
- Campus Pulse section (trending at campus)

### Differences:
| Feature | Web | App | Status |
|---------|-----|-----|--------|
| Quick Action: New Project | Direct link to `/projects/new` with "Start Here" badge | "Project Support" — different label, navigates differently | **DIFFERENT** |
| Quick Action: Plagiarism Check | Dedicated plagiarism option → `/projects/new?type=plagiarism` | "AI/Plag Report" — similar concept, different routing | **DIFFERENT** |
| Quick Action: Expert Sessions | Links to `/experts` with "50+ experts" badge | "Consult Doctor" — limited to doctors, marked "Coming Soon" | **DIFFERENT** — Web is active, App says "Coming Soon" |
| Quick Action: Campus Connect | Live rotating text with "Live" pulse indicator | Not present as quick action card | **MISSING IN APP** |
| Quick Action: Ref. Generator | Not present | "Ref. Generator" with Free badge (links to external site) | **MISSING IN WEB** |
| Recent Projects section | Not on dashboard (only in Projects page) | Horizontal scroll of recent projects on dashboard | **MISSING IN WEB** |
| Campus Pulse section | Not on dashboard | Shows trending campus content with filter chips | **MISSING IN WEB** |

---

## 4. PROJECTS

### Web Features
- Greeting header with stats: Active (0), Done (1), Payment Due (1)
- Quick action cards: New Project, Active Projects (count), Completed (count)
- Action Required section with payment due projects
- **Quote Ready Dialog** (auto-popup modal):
  - Project details, quote amount, validity
  - "Proceed to Pay" / "I'll pay later" buttons
- Filter tabs: Active, Review (2), Pending, Completed (1)
- Search bar
- Project cards with status badges, IDs, subjects, deadlines

### App Features
- Projects Overview card: Total (3), Active (0), Review (0), Done (1)
- "+ New Project" prominent button
- Filter tabs: In Review (2), In Progress (0), For Review (0) [+ History tab in code]
- Search bar: "Search projects..."
- Project cards with status badges, IDs, service type, timestamps
- Payment Prompt Modal (auto-popup)

### Differences:
| Feature | Web | App | Status |
|---------|-----|-----|--------|
| Quick action cards on Projects page | New Project + Active + Completed cards | Single "+ New Project" button | **DIFFERENT** |
| Filter tab names | Active / Review / Pending / Completed | In Review / In Progress / For Review / (History) | **DIFFERENT** — naming convention differs |
| Quote dialog | Shows quote details, amount, validity, proceed to pay | Payment Prompt Modal (simpler) | **DIFFERENT** |
| Stats display | Greeting + stats row at top | Projects Overview card with total/active/review/done | **DIFFERENT** |
| Project card info | Shows deadline ("1d left"), subject | Shows service type badge, last updated time | **DIFFERENT** |

---

## 5. NEW PROJECT FORM

### Web Features (`/projects/new`)
- Split-screen layout with progress sidebar
- Progress indicator: "25% Complete"
- Left sidebar: Step title, description, pro tip, trust badges, next step hint
- **Step 1 — Project Type Selection (5 types):**
  - Assignment ("Academic work, essays, homework")
  - Document ("Reports, thesis, papers")
  - Website ("Web development projects")
  - App ("Mobile or web applications")
  - Consultancy ("Expert consultation")
- **Subject Area** (searchable dropdown, 10 options):
  - Engineering, Business & Management, Medicine & Healthcare, Law, Natural Sciences, Mathematics & Statistics, Humanities & Literature, Social Sciences, Arts & Design, Other
- **Topic/Title** text input
- Multi-step wizard (step 1 of 4 visible)

### App Features
- 4 separate form screens:
  1. New Project Form (`/add-project/new`)
  2. Proofreading Form (`/add-project/proofread`)
  3. Report Request Form (`/add-project/report`)
  4. Expert Opinion Form (`/add-project/expert`)
- Each is a standalone form (not a multi-step wizard)
- Subject/Reference Style selection using enums

### Differences:
| Feature | Web | App | Status |
|---------|-----|-----|--------|
| Form layout | Multi-step wizard with progress sidebar | 4 separate standalone forms | **DIFFERENT** — significantly different UX |
| Project types | 5 types in single wizard (Assignment, Document, Website, App, Consultancy) | 4 separate routes (New Project, Proofreading, Report, Expert Opinion) | **DIFFERENT** |
| Subject selection | 10 subjects in searchable dropdown | Enum-based selection | **DIFFERENT** |
| Progress tracking | Visual circle: "25% Complete" with step descriptions | Not present | **MISSING IN APP** |
| Trust badges | "15,234 projects", "4.9/5 rating", "98% on-time" | Not present | **MISSING IN APP** |
| Website/App project types | Supported | Not supported | **MISSING IN APP** |
| Consultancy project type | Supported | Separate Expert Opinion form | **DIFFERENT** |

---

## 6. CAMPUS CONNECT

### Web Features
- Hero section with live stats: "47 posts in last hour", "234 students online", "12 colleges active"
- "Your Campus is BUZZING" with animation
- CTA: "Verify College to Post" → `/verify-college`
- Live feed preview (4 recent posts from different colleges)
- Feature carousel (4 slides about community features)
- "What is Campus Connect?" section with 6 feature cards:
  - Ask & Answer, Find Housing, Grab Opportunities, Join Events, Buy & Sell, Network
- Quick Access buttons: Questions, Jobs, Events, Market, Resources
- Search bar with college filter dropdown
- **12 category filter tabs**: All, Questions, Opportunities, Events, Marketplace, Resources, Lost & Found, Rides, Study Groups, Clubs, Announcements, Discussions
- Posts feed area

### App Features
- Simple header: "Campus Connect" with subtitle
- Fun emoji character illustration
- Action buttons: Post, Saved
- Search bar with Filter button
- **Category filters**: All, Questions, Opportunities + more (scrollable)
- College filter: "All Colleges" dropdown
- Posts count and sort (Latest)
- "No posts yet" empty state
- FAB: + button (create post)

### Differences:
| Feature | Web | App | Status |
|---------|-----|-----|--------|
| Hero section with live stats | Live stats (posts/hour, students online, colleges active) | Simple header with illustration | **MISSING IN APP** |
| "Verify College to Post" CTA | Prominent CTA linking to verification | Not visible | **MISSING IN APP** |
| Live feed preview | Shows 4 recent posts from different colleges | Not present | **MISSING IN APP** |
| Feature carousel | 4 slides showcasing features | Not present | **MISSING IN APP** |
| "What is Campus Connect" section | 6 feature cards explaining the platform | Not present | **MISSING IN APP** |
| Quick Access buttons | 5 emoji shortcut buttons (Questions, Jobs, Events, Market, Resources) | Not present | **MISSING IN APP** |
| Category tabs count | 12 categories | ~5-6 categories visible | **DIFFERENT** — Web has more categories (Lost & Found, Rides, Clubs, Announcements, Discussions) |
| Post/Saved buttons | Not present as buttons (navigation handles it) | Explicit Post and Saved buttons | **MISSING IN WEB** |
| FAB create button | Not present | "+" floating action button | **MISSING IN WEB** |

---

## 7. EXPERTS / CONSULTATIONS

### Web Features
- Search bar: "Search by name, specialty, or condition..."
- Trust stats: "500+ Verified", "4.9 Rating", "24/7 Available"
- **3 main tabs**: Doctors, All Experts, My Bookings
- **Doctors tab**:
  - Featured "Top Pick" carousel with 4 slides
  - Specialty filter tabs: All, Heart, Brain, Kids, Bones, Eyes, General, Skin, Mental
  - Doctor cards with: name, credentials, rating, sessions, price, "Book" button
  - 5 doctors listed
- **All Experts tab**:
  - Category filter tabs: All, Medicine, Science, Code, Data, Math, Research, Writing, Business, Engineering, Law, Arts
  - 12 experts listed across all domains
- **My Bookings tab**:
  - Sub-tabs: Upcoming (2), Completed (1), Cancelled
  - Booking cards with: expert info, timing, mode (Video Call), topic, amount, actions (Message, Reschedule)

### App Features
- Header: "Expert Consultations" with illustration
- Stats badges: Verified 500+, Rating 4.9, Sessions 10K+
- Search bar
- **3 tabs**: Doctors, All Experts, My Bookings
- Featured Doctors section with cards (name, rating, sessions, price, "Book Consultation" button)
- "6 doctors available" count

### Differences:
| Feature | Web | App | Status |
|---------|-----|-----|--------|
| Specialty filters (Doctors) | 9 emoji-labeled filters (Heart, Brain, Kids, etc.) | Not clearly visible in screenshots | **DIFFERENT** — Web has more granular filters |
| Expert categories (All Experts) | 12 categories (Medicine, Science, Code, Data, etc.) | Not clearly visible | **DIFFERENT** — Web has more categories |
| Expert count | 12 experts total | "6 doctors available" | **DIFFERENT** — Web has more experts |
| Top Pick carousel | Featured doctor with full bio, navigation arrows | Featured Doctors section (simpler) | **DIFFERENT** |
| Booking details | Shows mode (Video Call), topic, timing, "Message" and "Reschedule" buttons | Similar structure in code | **MATCH** (mostly) |
| Keyboard shortcut "/" for search | Yes | No | **MISSING IN APP** |

---

## 8. WALLET

### Web Features
- Virtual card: last 4 digits (4242), Available Balance ₹0, cardholder name, valid thru, assignX brand
- Action buttons: Add Balance, Send Money
- Stats cards: Rewards (0), Wallet Balance (₹0), Monthly Spend (₹0)
- Offers section: 4 offer cards (Internet, Electricity, Shopping, Food)
- Payment History with filter + empty state

### App Features
- Virtual card: masked number (4242), Available Balance ₹0, cardholder name, valid thru, assignX brand
- Action buttons: + Add Balance, > Send Money
- Stats: Rewards (1,250), Wallet Balance (₹0.00), Monthly Spend (₹0)
- Offers section with cards (Internet/Airtel, Electricity/Bill Pay, Shopping/Amazon)
- Transaction history

### Differences:
| Feature | Web | App | Status |
|---------|-----|-----|--------|
| Virtual card design | Present | Present | **MATCH** |
| Add Balance / Send Money | Present | Present | **MATCH** |
| Rewards value | Shows 0 | Shows 1,250 | **DIFFERENT** — data inconsistency |
| Offers | 4 offers | 3+ offers (similar) | **MATCH** (mostly) |
| Payment History | With filter button, empty state | Transaction history | **MATCH** |

---

## 9. SETTINGS

### Web Features (Standalone `/settings` page)
- **Notifications**: Push, Email, Project Updates, Marketing toggles
- **Appearance**: Theme selector, Reduced Motion, Compact Mode
- **Privacy & Data**: Analytics Opt-out, Show Online Status, Export Data, Clear Cache
- **About AssignX**: Version 1.0.0-beta, Build 2024.12.26, Terms/Privacy/Open Source links
- **My Roles**: Student/Professional/Business toggle switches
- **Send Feedback**: Bug/Feature/General type + textarea + Submit
- **Danger Zone**: Log Out, Deactivate Account, Delete Account

### App Features (Embedded in Profile screen)
- **Settings section** in Profile:
  - Personal Information → Edit Profile
  - Academic Details → Edit Profile
  - Upgrade Account → Account Upgrade
  - Security → Password, 2FA, sessions
  - App Settings → Notifications, theme, language
  - Help & Support → FAQ, Contact
  - Terms & Conditions → external link
  - Privacy Policy → external link
  - Log Out

### Differences:
| Feature | Web | App | Status |
|---------|-----|-----|--------|
| Standalone Settings page | Yes | No (embedded in Profile) | **DIFFERENT** |
| My Roles toggle | Student/Professional/Business toggles | Not present | **MISSING IN APP** |
| Send Feedback | Bug/Feature/General form | Not present | **MISSING IN APP** |
| Deactivate Account | Yes | Not present | **MISSING IN APP** |
| Delete Account | Yes | Not present | **MISSING IN APP** |
| Export Data | Yes (download as JSON) | Not present | **MISSING IN APP** |
| Clear Cache | Yes | Not present | **MISSING IN APP** |
| Reduced Motion | Yes | Not present | **MISSING IN APP** |
| Compact Mode | Yes | Not present | **MISSING IN APP** |
| Marketing Emails toggle | Yes | Not visible | **MISSING IN APP** |
| About section with version | Version, Build, Beta status, Last Updated | Not on settings (in code but not prominent) | **DIFFERENT** |

---

## 10. PROFILE

### Web Features
- Avatar with edit button
- Name: "Admin Test User", Plan badge: "free"
- Email with copy icon
- Join date
- Edit Profile button
- **Stats cards (4)**: Balance (₹0), Projects (1), Referrals (3), Earned (₹150)
- **Add Money Banner**: "Top-up for quick payments" → wallet
- **Refer & Earn section**:
  - Referral code: "EXPERT20" with copy/share buttons
  - Stats: 3 Referrals, ₹150 Earned
- **Settings Quick Links (5)**:
  - Personal Information, Academic Details, Notifications, Security & Privacy (2FA badge), Subscription (Upgrade badge)
- **Footer**: Version, Terms, Privacy, Help links

### App Features
- Avatar with camera edit icon
- Name: "ADMIN TEST USER", Professional badge
- Email with verified checkmark
- Join date: "Joined February 2026"
- Edit Profile button
- **Stats grid (2x2)**: Balance (₹0), Projects (1), Referrals (0), Earned (₹0)
- **Subscription Card** (Plan Features)
- **Add Money Banner**
- **Refer & Earn Card** (with referral code)
- **Preferences Section**
- **Settings Section**: Personal Info, Academic Details, Upgrade Account, Security, App Settings, Help & Support, Terms, Privacy, Log Out

### Differences:
| Feature | Web | App | Status |
|---------|-----|-----|--------|
| Plan badge | "free" badge | "Professional" type badge | **DIFFERENT** — Web shows plan, App shows user type |
| Referral data | Code "EXPERT20", 3 referrals, ₹150 earned | Shows 0 referrals, ₹0 earned | **DIFFERENT** — data inconsistency |
| Referral code display | Readonly textbox with copy/share buttons | Card with code | **MATCH** (mostly) |
| Settings quick links | 5 items with badges (2FA, Upgrade) | More items (8+) including App Settings, Help, Terms, Privacy, Log Out | **DIFFERENT** — App has more settings items |
| App version in footer | "AssignX v1.0.0" with Terms/Privacy/Help | Not visible | **MISSING IN APP** |
| Preferences section | Not present separately | Dedicated PreferencesSection widget | **MISSING IN WEB** |

---

## 11. FEATURES ONLY IN APP (Not on Web)

| Feature | Details |
|---------|---------|
| **Pro Network** | Entire professional networking tab with posts, filters, create/save |
| **Business Hub** | Entire business community tab with posts, filters, create/save |
| **ConnectHub role-based tabs** | Dynamic tabs based on user type (Student → Campus only; Professional → Campus + Pro/Business) |
| **Marketplace** | Full marketplace with listings, create, detail screens |
| **Connect Screen** | Tutors, Study Groups, Resources tabs |
| **Campus Pulse on Dashboard** | Trending campus content on home screen |
| **Recent Projects on Dashboard** | Horizontal scroll of recent projects on home screen |
| **Reference Generator** | Quick action card linking to citation tool |
| **Project Timeline** | Dedicated timeline screen for project events |
| **Live Draft WebView** | Real-time draft viewing from expert |
| **College Verification Screen** | Dedicated verification flow |
| **Payment Prompt Modal** | Auto-popup for pending payments |

---

## 12. FEATURES ONLY ON WEB (Not in App)

| Feature | Details |
|---------|---------|
| **Language selector** | 6 languages (English, Hindi, Spanish, French, Arabic, German) in header |
| **Theme toggle in header** | Quick dark/light mode toggle always visible |
| **Landing page** | Full marketing landing page with How It Works, testimonials, CTA sections |
| **Campus Connect hero with live stats** | "47 posts in last hour", "234 students online", live feed preview |
| **Campus Connect feature carousel** | 4-slide carousel explaining platform features |
| **"What is Campus Connect" section** | 6 feature cards explaining the platform |
| **Quick Access shortcut buttons** | 5 emoji shortcut buttons on Campus Connect |
| **12 category filters** | Lost & Found, Rides, Study Groups, Clubs, Announcements, Discussions (extra categories) |
| **My Roles toggle** | Switch between Student/Professional/Business roles in Settings |
| **Send Feedback form** | Bug/Feature/General type selector + message textarea |
| **Deactivate Account** | Temporarily disable account |
| **Delete Account** | Permanently delete all data |
| **Export Data** | Download data as JSON |
| **Clear Cache** | Clear local storage |
| **Reduced Motion / Compact Mode** | Accessibility appearance toggles |
| **Quote Ready Dialog** | Detailed popup with quote amount, validity, subject |
| **Multi-step project wizard** | Progress bar, sidebar with tips, 4-step creation |
| **Website/App project types** | Web dev and mobile app project creation |
| **Keyboard shortcut "/" for search** | Quick search access on experts page |

---

## Priority Implementation Recommendations

### HIGH PRIORITY (Core feature parity)
1. **Language selector** — Add multi-language support to app
2. **Theme toggle** — Make dark/light mode accessible from header
3. **Multi-step project wizard** — Match the web's guided creation flow
4. **Campus Connect live stats and hero** — Add engagement features
5. **My Roles toggle** — Allow role switching in settings
6. **Delete/Deactivate Account** — Required for app store compliance
7. **Send Feedback** — Important for user retention
8. **Additional Campus Connect categories** — Add Lost & Found, Rides, Clubs, Announcements, Discussions

### MEDIUM PRIORITY (UX alignment)
9. **Quote Ready Dialog** — Match the web's detailed quote popup
10. **Project creation: Website/App types** — Support all project types
11. **Export Data** — Privacy compliance feature
12. **Quick Access buttons** on Campus Connect
13. **About section with version** — Show app version info

### LOW PRIORITY (Nice to have)
14. **Reduced Motion / Compact Mode** — Accessibility features
15. **Clear Cache** — Utility setting
16. **Marketing emails toggle** — Notification preference
17. **Keyboard shortcuts** — Not applicable to mobile
