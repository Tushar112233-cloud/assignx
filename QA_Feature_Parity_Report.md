# QA Feature Parity Report - AssignX
## Web (localhost:3001) vs Mobile (iOS Simulator)

**Date:** 2026-02-26
**Tester:** Claude Code
**Web Status:** All pages tested via Playwright MCP
**Mobile Status:** Pending manual testing

---

## 1. LANDING PAGE (/)

### Web Features:
- [x] Nav bar: Logo, Toggle Theme, Sign In, Get Started
- [x] Hero: "Get expert help with any task or project"
- [x] Trust stats: 98% Success Rate, 24h Avg Delivery, 500+ Experts
- [x] How It Works: 4 steps (Submit Request → Quality Review → Expert Work → Delivered)
- [x] Detailed Steps: Submit Project, Get Matched, Review Progress, Download & Succeed
- [x] User Types: Students, Professionals, Business Owners (each with features list + CTA)
- [x] Flow Diagram: Students → Supervisor → Experts (Research, Writing, Analysis)
- [x] Trust Stats Section: Success Rate, Avg Delivery, Verified Experts, 4.9/5 Client Rating
- [x] Global Network: 50+ Countries, 24/7 Support, 15+ Languages
- [x] Testimonials: 6 reviews (Priya S., Rahul M., Ananya K., Vikram P., Sneha R., Arjun D.)
- [x] Our Promise: Quality Assured, Supervised Experts, End-to-End Handling
- [x] CTA: "Ready to excel?" with Get Started Free + Learn More
- [x] Footer: Services, Company, Support links + Newsletter subscribe + Contact info

### Mobile Equivalent:
- Onboarding screens (swipeable pages) instead of full landing page
- "Already have an account? Sign in" link at bottom

---

## 2. DASHBOARD (/home)

### Web Features:
- [x] App Bar: Logo, page title "Dashboard", Language switcher, Wallet balance link, Theme toggle, Notification bell (badge: 7)
- [x] Greeting: "Good Morning, Admin" (time-based)
- [x] Subtitle: "Ready to optimize your workflow and generate insights"
- [x] Quick Stats Row: Active (0), Pending (1), Wallet (₹0)
- [x] Needs Attention: Card with project "Statistical Analysis of Sales Data - Quote Ready" (clickable)
- [x] Quick Actions Grid (4 cards):
  - New Project (link to /projects/new) - "Essays, research, assignments & more"
  - Expert Sessions (link to /experts) - "1-on-1 video consultations" - "50+ experts"
  - Plagiarism Check (link to /projects/new?type=plagiarism) - "AI-powered detection" - "99.9% Accurate"
  - Campus Connect (button) - "Marketplace - Buy & sell with students" - "Live" badge
- [x] Dock Navigation (bottom): home, projects, campus-connect, pro-network, business-hub, experts, marketplace, wallet, settings, profile (10 items)

### Mobile Features (verified via screenshot):
- [x] App Bar: Logo "AssignX", language, theme, wallet (₹0), notification bell (red badge)
- [x] Greeting: "Good Morning, Admin" (matches web)
- [x] Quick Stats: Active 0, Pending 1, Wallet ₹0 (matches web)
- [x] Needs Attention: "Statistical Analysis of Sales Data - Quote Ready" (matches web)
- [x] Quick Actions (4 cards):
  - Project Support
  - AI/Plag Report
  - Consult Doctor (Coming Soon)
  - Ref. Generator (Free)
- [x] **Explore More Section** (NEW - added for parity): Marketplace, Connect, Pro Network, Business Hub chips
- [x] Recent Projects: horizontal scroll (3 items)
- [x] Campus Pulse section
- [x] Bottom Nav (6 items): Home, Projects, ConnectHub, Experts, Wallet, Profile

### Parity Notes:
- Web has "Expert Sessions" → Mobile has "Consult Doctor" (different label, same concept)
- Web has "Campus Connect" action → Mobile has it in Explore More + ConnectHub tab
- Mobile has "Ref. Generator" (external link) → Web doesn't have this as a quick action
- Mobile has "Explore More" section providing access to features not in bottom nav (Marketplace, Connect, Pro Network, Business Hub) - ADDED during this session
- Navigation: Web has 10 dock items, Mobile has 6 bottom nav + Explore More chips

---

## 3. PROJECTS (/projects)

### Web Features:
- [x] Greeting header: "Good Morning, Admin" + "Track your projects and manage deadlines efficiently"
- [x] Stats: 0 Active, 1 Done, 1 Payment Due
- [x] Quick Actions: New Project, Active Projects (0), Completed (1)
- [x] Action Required Section (badge: 1):
  - "Statistical Analysis of Sales Data" - Payment Due - #AX-769834 - Mathematics - Amount ₹500 - "Pay Now" button
- [x] Filter Tabs: Active, Review (2), Pending, Completed (1)
- [x] Search bar: "Search projects..."
- [x] Project Card: "assignmet" - #AX-190278 - Engineering - Submitted - 19h left
- [x] Quote Ready Dialog (auto-popup): Project ID, Amount ₹500, Validity 24h, "Proceed to Pay" / "I'll pay later"

### Mobile Features (verified via screenshot):
- [x] Projects Overview card: 3 Total, 0 Active, 0 Review, 1 Done
- [x] "+ New Project" button (brown/gold)
- [x] Filter Tabs: In Review (2), In Progress (0), For Review (0)
- [x] Search bar: "Search projects..."
- [x] Project cards:
  - "assignmet" - #AX-190278 - Submitted - 1d ago - "View" button
  - "Statistical Analysis of Sales Data" - #AX-769834 - Payment Pending - 2d ago - "Pay Now" button
- [x] Quote Ready modal (auto-popup on login): Same project AX-769834, ₹500, "Proceed to Pay" / "I'll pay later"

### Parity: MATCH - Same data, same actions, slightly different layout

---

## 4. NEW PROJECT (/projects/new)

### Web Features - 4-Step Wizard:

**Step 1 (25%) - "Choose Your Focus":**
- [x] Project Type selection: Assignment, Document, Website, App, Consultancy
- [x] Subject Area dropdown (10 options): Engineering, Business & Management, Medicine & Healthcare, Law, Natural Sciences, Mathematics & Statistics, Humanities & Literature, Social Sciences, Arts & Design, Other
- [x] Topic/Title text field
- [x] Continue button
- [x] Side panel: stats (15,234 projects, 4.9/5 rating, 98% on-time), pro tips

**Step 2 (50%) - "Set Your Scope":**
- [x] Word Count (spinner, default 1000)
- [x] Reference Style dropdown (default: APA 7th Edition)
- [x] Number of References (spinner, default 10)

**Step 3 (75%) - "When Do You Need It?":**
- [x] Deadline date picker with quick select: 1 Week, 2 Weeks, 1 Month
- [x] Full calendar grid (past dates disabled)
- [x] Urgency Level radio: Standard (5-7 days), Express (+50%), Urgent (+100%)
- [x] Price Estimate: Base (words × rate) + GST 18% = Total
- [x] Validation: "Please select a deadline" if skipped

**Step 4 (100%) - "Final Touches":**
- [x] Additional Instructions textarea (optional, max 2000 chars)
- [x] File Upload (optional, max 5 files, PDF/DOC/DOCX/PPT/XLS/ZIP/images, 10MB each)
- [x] Price Estimate summary
- [x] "Submit Project" button

### Mobile Equivalent:
- Has project creation wizard (project_wizard_screen.dart)
- Subject dropdown, type selection, file upload
- **TO TEST ON MOBILE**

---

## 5. CAMPUS CONNECT (/campus-connect)

### Web Features:
- [x] Hero: "Good Morning, there" - "Your Campus is BUZZING"
- [x] Live Stats: 47 posts in last hour, 234 students online, 12 colleges active
- [x] CTA: "Verify College to Post" + "Explore"
- [x] Live Feed Preview: 4 recent posts (IIT Delhi, BITS Pilani, VIT Vellore, NIT Trichy)
- [x] Carousel: "Your Campus Community" with slides (prev/next, dot indicators)
- [x] Feature Cards (6): Ask & Answer, Find Housing, Grab Opportunities, Join Events, Buy & Sell, Network
- [x] Quick Access Buttons: Questions, Jobs, Events, Market, Resources
- [x] Search bar: "Search posts, questions, events..."
- [x] Filters: College dropdown, sort, filter buttons
- [x] Category Tabs (12): All, Questions, Opportunities, Events, Marketplace, Resources, Lost & Found, Rides, Study Groups, Clubs, Announcements, Discussions
- [x] Create Post button (link to /campus-connect/create)
- [x] Saved button
- [x] FAB: "Create Post" floating button

### Mobile Equivalent:
- ConnectHub tab wraps Campus Connect, Pro Network, Business Hub
- Campus Connect screen with hero, live stats, feature cards, quick access, filters
- **TO TEST ON MOBILE**

---

## 6. PRO NETWORK (/pro-network)

### Web Features:
- [x] Hero: "Professional Network" - "Connect with industry professionals..."
- [x] "Create Post" link
- [x] Stats: Professionals, 0 Posts, Active Network
- [x] Search bar: "Search posts, topics, professionals..."
- [x] Category filters (9): All, Technology, Business, Healthcare, Finance, Legal, Engineering, Research, Marketing, Education
- [x] Saved link (/pro-network/saved)
- [x] Create Post link (/pro-network/create)
- [x] Loading state for posts

### Mobile Equivalent:
- Accessible via ConnectHub tab (role-based) AND via Explore More chips on dashboard
- Direct route: /pro-network (added during this session)
- **TO TEST ON MOBILE**

---

## 7. BUSINESS HUB (/business-hub)

### Web Features:
- [x] Hero: "Business Hub" - "Connect with entrepreneurs and investors..."
- [x] "Create Post" link
- [x] Stats: Companies, 0 Discussions, Opportunities
- [x] Search bar: "Search companies, discussions, opportunities..."
- [x] Category filters (9): All, Startups, Investments, Marketing, Tech, Finance, Operations, HR, Strategy
- [x] Saved link (/business-hub/saved)
- [x] Create Post link (/business-hub/create)

### Mobile Equivalent:
- Accessible via ConnectHub tab AND Explore More chips
- Direct route: /business-hub (added during this session)
- **TO TEST ON MOBILE**

---

## 8. EXPERTS (/experts)

### Web Features:
- [x] Hero: "Find Your Expert" - "Connect with verified professionals for consultations"
- [x] Search: "Search by name, specialty, or condition..."
- [x] Stats: 500+ Verified, 4.9 Rating, 24/7 Available
- [x] Tabs: Doctors, All Experts, My Bookings (badge: 2)
- [x] Top Pick Carousel: Dr. Ananya Sharma - MBBS, MD - 580+ sessions - ₹499/session - "Book Now"
- [x] Specialty Filters (9): All, Heart, Brain, Kids, Bones, Eyes, General, Skin, Mental
- [x] Doctor Count: "5 doctors available"
- [x] Doctor Cards (5):
  - Dr. Ananya Sharma - Internal Medicine - 4.9 (142) - 580+ sessions - ₹499
  - Dr. Rajesh Gupta - Orthodontics - 4.7 (98) - 320+ sessions - ₹399
  - Dr. Priya Nair - Dermatology - 4.9 (176) - 450+ sessions - ₹599
  - Dr. Kavita Singh - Psychiatry - 4.9 (203) - 780+ sessions - ₹699
  - Dr. Rohit Malhotra - Ophthalmology - 4.6 (72) - 250+ sessions - ₹449
- [x] Each card: Online badge, avatar, name, verified badge, specialty, rating, sessions, price, "Book" button

### Mobile Equivalent:
- Experts tab (4th in bottom nav)
- Doctors carousel, booking calendar, expert detail, price breakdown
- **TO TEST ON MOBILE**

---

## 9. MARKETPLACE (/marketplace)

### Web Features:
- [x] Hero: "Campus Marketplace" - "Buy, sell, and trade with your campus community"
- [x] Stats: 0 Listings, 0 Active Sellers, 8 Categories
- [x] Search bar: "Search listings..." + Search button
- [x] Category filters (9): All, Books, Electronics, Services, Tutoring, Housing, Clothing, Furniture, Other
- [x] "Create Listing" button (link to /marketplace/create)
- [x] Empty state with illustration
- [x] FAB: "Create Listing" at bottom

### Mobile Equivalent:
- Accessible via Explore More section on dashboard
- Direct route: /marketplace
- **TO TEST ON MOBILE**

---

## 10. WALLET (/wallet)

### Web Features:
- [x] Card UI: Last 4 digits (4242), Available Balance ₹0, Card Holder "Admin Test User", Valid Thru 02/31, "assignX" branding
- [x] **Add Balance** button → Dialog:
  - Quick Select: ₹100, ₹500, ₹1k, ₹2k, ₹5k, ₹10k
  - Custom Amount field (min ₹10, max ₹50,000)
  - "Proceed to Pay" button (disabled until amount selected)
  - Security badges: Secure, Instant
- [x] **Send Money** button → Dialog:
  - Step 1: Recipient Email field + "Find User" button
  - Step 2: Amount selection (after user found)
  - Step 3: Confirmation
- [x] Stats Row: Rewards (0), Wallet Balance (₹0), Monthly Spend (₹0)
- [x] Offers Section (4 cards): Internet & TV (Airtel), Electricity (Energy Board), Shopping (Amazon), Food & Dining (Cafeteria)
- [x] Payment History: "No transactions yet" empty state with filter button

### Mobile Features (verified via earlier session):
- [x] Curved dome hero with card UI (balance, card details)
- [x] Top Up button → Razorpay integration
- [x] **Send Money** button → Bottom sheet (IMPLEMENTED during this session):
  - Step 0: Search recipient by email
  - Step 1: Amount selection (preset chips + custom) + optional note + confirm
  - Uses Supabase RPC transfer_wallet_funds
- [x] Transaction history
- [x] Offers section

### Parity: MATCH - Both have Add Balance, Send Money, Offers, History

---

## 11. SETTINGS (/settings)

### Web Features:
- [x] **Notifications** section:
  - Push Notifications toggle (ON)
  - Email Notifications toggle (ON)
  - Project Updates toggle (ON)
  - Marketing Emails toggle (OFF)
- [x] **Appearance** section:
  - Theme selector
  - Reduced Motion toggle
  - Compact Mode toggle
- [x] **Privacy & Data** section:
  - Analytics Opt-out toggle
  - Show Online Status toggle (ON)
  - Export Data button ("Download your data as JSON")
  - Clear Cache button ("Clear local storage")
- [x] **About AssignX** section:
  - Version: 1.0.0-beta
  - Build: 2024.12.26
  - Status: Beta
  - Links: Terms of Service, Privacy Policy, Open Source
- [x] **My Roles** section:
  - Student toggle (Access Campus Connect)
  - Professional toggle (Access Job Portal)
  - Business toggle (Access Business Portal & VC Funding)
- [x] **Send Feedback** section:
  - Type: Bug, Feature, General buttons
  - Feedback textarea
  - "Send Feedback" button
- [x] **Danger Zone** section:
  - Log Out button
  - Deactivate Account button
  - Delete Account button

### Mobile Equivalent:
- Settings screen at /settings (route added during this session)
- Has: Notifications, Appearance, Privacy, Roles, Feedback, About, Danger Zone
- **TO TEST ON MOBILE**

---

## 12. PROFILE (/profile)

### Web Features:
- [x] Avatar: "AT" initials
- [x] Name: "Admin Test User"
- [x] Tier badge: "free"
- [x] Email: admin@gmail.com (with copy icon)
- [x] Joined: February 2026
- [x] "Edit Profile" button
- [x] Wallet Quick Action: "Add Money to Wallet" - "Top-up for quick payments" - "Top Up" link
- [x] Refer & Earn:
  - Code: EXPERT20
  - Copy Code / Share buttons
  - Stats: 3 Referrals, ₹150 Earned
- [x] Settings Menu (8 items):
  - Personal Information
  - Academic Details
  - Notifications
  - Security & Privacy (2FA badge)
  - **Payment Methods** (ADDED during this session)
  - Subscription (Upgrade badge)
  - App Settings (link to /settings)
  - Help & Support (link to /support)
- [x] Footer: AssignX v1.0.0, Terms, Privacy, Help links

### Mobile Equivalent:
- Profile tab (6th in bottom nav)
- Has: avatar, name, tier, edit profile, wallet, settings menu items
- **TO TEST ON MOBILE**

---

## 13. SUPPORT (/support)

### Web Features:
- [x] Header: "Help & Support" - "Get help from our support team or browse FAQs"
- [x] Stats: <2hr Response, 98% Resolved
- [x] Quick Contact Cards (4):
  - Live Chat (Online badge)
  - Email Support
  - Knowledge Base
  - Schedule Call
- [x] FAQ Section: "Frequently Asked Questions" with search bar
- [x] Create Support Ticket:
  - Category dropdown
  - Subject field
  - Message textarea
  - "Create Ticket" button
- [x] Your Tickets section (with loading state)

### Mobile Equivalent:
- Help & Support screen (accessible from Profile)
- Has: FAQ, ticket creation, ticket history, quick contact
- Already verified at parity in earlier session

---

## 14. CONNECT (/connect - Web redirects to dashboard)

### Web:
- /connect redirects to /home (no dedicated Connect page on web)
- Connect features (Tutors, Resources, Study Groups, Q&A) are part of Campus Connect

### Mobile:
- Dedicated Connect screen with 4 tabs: Tutors, Resources, Study Groups, Q&A
- Q&A tab ADDED during this session with:
  - Question cards, filters (answered/unanswered, by subject)
  - Ask Question bottom sheet
  - Question detail view
- Accessible via Explore More section on dashboard

---

## SUMMARY OF CHANGES MADE FOR PARITY

| Change | Platform | Files |
|--------|----------|-------|
| Added Pro Network/Business Hub/Settings routes | Mobile | route_names.dart, app_router.dart |
| Added Explore More section to dashboard | Mobile | explore_more_section.dart, dashboard_screen.dart |
| Implemented Send Money functionality | Mobile | wallet_screen.dart |
| Added Q&A tab to Connect screen | Mobile | qa_section.dart, question_card.dart, ask_question_sheet.dart, connect_screen.dart |
| Added Payment Methods section | Web | payment-methods-section.tsx, profile types, settings-tabs, profile page |
| Added Privacy Controls section | Web | privacy-controls-section.tsx, settings index |

---

## MOBILE TESTING CHECKLIST (for manual testing)

Please navigate to each screen and I'll screenshot + verify:

- [ ] Dashboard (Home tab)
- [ ] Projects tab → Project list
- [ ] Projects → + New Project → wizard flow
- [ ] Projects → View a project detail
- [ ] Projects → Pay Now button
- [ ] ConnectHub tab → Campus Connect
- [ ] ConnectHub tab → Pro Network (if role enabled)
- [ ] ConnectHub tab → Business Hub (if role enabled)
- [ ] Explore More → Marketplace chip
- [ ] Explore More → Connect chip
- [ ] Explore More → Pro Network chip
- [ ] Explore More → Business Hub chip
- [ ] Experts tab → Doctor list
- [ ] Experts → Book a doctor
- [ ] Wallet tab → Balance view
- [ ] Wallet → Top Up
- [ ] Wallet → Send Money
- [ ] Profile tab → Profile view
- [ ] Profile → Settings
- [ ] Profile → Help & Support
- [ ] Connect screen → Tutors tab
- [ ] Connect screen → Resources tab
- [ ] Connect screen → Study Groups tab
- [ ] Connect screen → Q&A tab
