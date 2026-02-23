# AssignX - Complete Feature Specification

> **Version:** 1.0 | **Date:** December 2025  
> **Platform Type:** Three-Sided Marketplace  
> **Stakeholders:** Users • Doers • Supervisors

---

## 📋 Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Technology Stack](#2-technology-stack)
3. [User App & Website Features](#3-user-app--website-features)
4. [Doer App & Website Features](#4-doer-app--website-features)
5. [Supervisor App Features](#5-supervisor-app-features)
6. [Admin Panel Features](#6-admin-panel-features)
7. [Cross-Platform Features](#7-cross-platform-features)
8. [Project Workflow & Status System](#8-project-workflow--status-system)
9. [Exclusions](#9-exclusions)

---

## 1. Executive Summary

AssignX is a comprehensive three-sided marketplace platform consisting of **6 deliverables**:

| # | Deliverable | Technology |
|---|-------------|------------|
| 1 | User App | Flutter |
| 2 | User Website | Next.js |
| 3 | Doer App | Flutter |
| 4 | Doer Website | Next.js |
| 5 | Supervisor App | Flutter |
| 6 | Admin Panel | Next.js |

The platform connects **Users** (clients seeking task completion) with **Doers** (experts completing tasks) through **Supervisors** (quality controllers managing the workflow).

---

## 2. Technology Stack

| Component | Technology |
|-----------|------------|
| Mobile Apps | Flutter (Dart) - Cross-platform iOS & Android |
| Websites | Next.js, React, TypeScript, Rive, Shadcn/ui, Lenis, GSAP |
| Database & Auth | Supabase (PostgreSQL, OAuth, Realtime) |
| Payments | Razorpay |
| Notifications | WhatsApp Business API + Push Notifications |
| Monitoring | Sentry (Error tracking, Crash reports) |

---

## 3. User App & Website Features

**Target Audience:** Students (Gen Z), Job Seekers, Business Owners/Creators  
**Core Theme:** Professionalism, Security, Efficiency

### A. Onboarding & Authentication (11 Features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| U01 | Splash Screen | Minimalist logo animation with tagline "Your Task, Our Expertise", 2-second auto-transition | Core |
| U02 | Onboarding Carousel | 3 slides (Concept, Versatility, Trust) with Skip button, Next arrow, and "Get Started" CTA | Core |
| U03 | Role Selection Screen | 3 premium cards: Student, Job Seeker, Business/Creator with distinct subtexts and icons | Core |
| U04 | Student Sign-up Flow | Multi-step: Full Name, DOB → University dropdown, Course, Semester, Student ID → College Email (.edu/.ac) + Mobile OTP verification | Core |
| U05 | Professional Sign-up Flow | Quick flow: Google/LinkedIn social login → Industry dropdown, Mobile → OTP verification | Core |
| U06 | Progress Bar | Visual progress indicator during sign-up steps (33%, 66%, 100%) | Important |
| U07 | Terms & Conditions | Mandatory acceptance before account creation with link to full T&C | Core |
| U08 | Get Support Button | Present on every page during setup for confused users | Important |
| U09 | Success Animation | Confetti/Checkmark animation with personalized welcome message | Important |
| U10 | Smart Keyboard | Context-aware: @ keyboard for email, number pad for mobile/OTP | Important |
| U11 | Error States | Red outlines for invalid Student ID format or non-college email | Important |

### B. Home Dashboard (12 Features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| U12 | Personalized Greeting | "Hi, [Name] 👋" with University & Semester subtext | Core |
| U13 | Wallet Balance Pill | Small container showing balance (e.g., £24.00), tap to top-up | Core |
| U14 | Notification Bell | Icon with unread notification count badge | Core |
| U15 | Promotional Banners Carousel | Auto-scrolling (4 sec) high-quality graphics with CTAs for core services | Core |
| U16 | Services Grid (2x2) | Project Support, AI/Plag Report, Consult Doctor (placeholder), Ref. Generator (free) | Core |
| U17 | Campus Pulse Teaser | "Trending at [University]" - horizontal scroll of marketplace items with price & distance | Important |
| U18 | Bottom Navigation Bar | 5 items: Home, My Projects, FAB (+), The Quad/Connect, Profile | Core |
| U19 | Central FAB Button | Large elevated circle with + icon, opens bottom sheet modal for quick actions | Core |
| U20 | Upload Bottom Sheet Modal | Slide-up modal (50% screen) with options: Upload New Project, Quick Proofread | Core |
| U21 | Dynamic University Content | Campus Pulse content filtered by user's university and location | Important |
| U22 | Service Icons | Thin-line professional icons in brand color | Important |
| U23 | Safe Language Compliance | All text uses "Project" not "Assignment" (e.g., "Upload Project Brief") | Core |

### C. My Projects Module (18 Features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| U24 | Tab Navigation | 4 Tabs: In Review, In Progress, For Review, History | Core |
| U25 | Project Card - Header | Project Title + Subject Icon (Business, IT, Math, etc.) | Core |
| U26 | Project Card - Body | Project ID (#AE-2940), Deadline (color-coded red if <24h), Progress Bar | Core |
| U27 | Project Card - Footer | Status Badge (pill shape, color-coded) + Action Button | Core |
| U28 | Status: Analyzing | 🟡 Yellow - "Analyzing Requirements..." with disabled button | Core |
| U29 | Status: Payment Pending | 🟠 Orange - "Payment pending: $30" with Pay Now button | Core |
| U30 | Payment Prompt Modal | Paytm-style bottom sheet on app open: "Your project is ready! Pay now to begin" | Core |
| U31 | Status: In Progress | 🔵 Blue - "Expert Working" or "70% Completed" with Expected Delivery Date | Core |
| U32 | Status: For Review | 🟢 Green border - "Files Uploaded - Action Required" | Core |
| U33 | Auto-Approval Timer | Countdown clock: "Auto-approves in 48h" | Core |
| U34 | Request Changes Flow | Text box for feedback, card moves back to In Progress with "Revision" tag | Core |
| U35 | Approve Button | Moves card to History tab | Core |
| U36 | Status: Completed | 🟢 Solid Green or ⚫ Grey - "Successfully Completed" | Core |
| U37 | Download Invoice | Available in History tab for completed projects | Important |
| U38 | Grade Entry | Optional field to enter final grade received (for analytics) | Optional |
| U39 | Push Notification | Triggered when quote is ready | Core |
| U40 | WhatsApp Notification | Triggered when quote is ready (parallel to push) | Core |
| U41 | View Timeline Button | Shows project progress timeline in In Progress state | Important |

### D. Project Detail Page (14 Features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| U42 | Sticky Header | Back Arrow, Project Name, Kebab Menu (Cancel Project, Support) | Core |
| U43 | Status Banner | Thin colored strip showing status (e.g., "In Progress - On Track") | Core |
| U44 | Deadline Timer | Real-time countdown: "Due in: 3 Days, 4 Hours" | Core |
| U45 | Live Draft Tracking | "Track Progress Live" card with "Open Live Draft 📄" button | Core |
| U46 | Read-Only WebView | Google Docs/Sheets/Figma opens in read-only mode (prevents student editing) | Core |
| U47 | Project Brief Accordion | Collapsed: "Original Requirements" + Budget; Expanded: Subject, Word Count, References, Instructions | Core |
| U48 | Deliverables Section | List of uploaded files with "Download Final Solution" button | Core |
| U49 | AI Probability Report | Robot icon badge - "Human Written" (green check) or "Download Report" | Core |
| U50 | Plagiarism Check Badge | Document Scanner icon - "Unique Content" (green check) or "Download Turnitin Report" | Core |
| U51 | Quality Badges Lock | Badges grayed out/locked during "In Progress", unlock on "For Review" | Important |
| U52 | Floating Chat Button | Fixed bottom-right chat bubble 💬 with notification badge | Core |
| U53 | Context-Aware Chat | Chat automatically knows which Project ID is being discussed | Core |
| U54 | Chat with Supervisor | Overlay chat window for direct supervisor communication | Core |
| U55 | Attached Reference Files | View files originally uploaded by student in accordion | Important |

### E. Add Project Module (17 Features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| U56 | Service Selection Menu | Bottom sheet via FAB with 2-column grid | Core |
| U57 | New Project Service | Icon: 📝 - Full task creation flow | Core |
| U58 | Proofreading Service | Icon: 👓 - Polish existing drafts | Core |
| U59 | Plagiarism Check Service | Icon: 🕵️ - Turnitin report request | Core |
| U60 | AI Detection Report Service | Icon: 🤖 - AI verification report | Core |
| U61 | Expert Opinion Service | Icon: 💡 - Consultation/Advice (FREE) | Core |
| U62 | New Project Form - Step 1 | Subject dropdown, Topic Name input, Word Count (optional), Deadline picker | Core |
| U63 | Pricing Note | "Pricing depends on timeline - more time = lesser price" | Important |
| U64 | New Project Form - Step 2 | Project Guidelines textarea, Attachments (PDF/Doc/Img), Reference Style (APA, Harvard) | Core |
| U65 | Proofreading Form | File upload, Focus Area chips (Grammar, Flow, Formatting, Citations, Expert Opinion), Deadline | Core |
| U66 | Plag/AI Report Form | Document upload, Checkboxes: Similarity Check, AI Content Detection | Core |
| U67 | Expert Opinion Form | Subject dropdown, Question textbox, Optional file attachment | Core |
| U68 | Submit for Quote CTA | Primary action button for New Project | Core |
| U69 | Request Review CTA | Primary action button for Proofreading | Core |
| U70 | Get Report CTA | Primary action button for Plag/AI checks | Core |
| U71 | Ask Expert CTA | Primary action button for Expert Opinion | Core |
| U72 | Success Popup | "Project Received! Supervisor is reviewing it." with WhatsApp notification mention | Core |

### F. Student Connect / Campus Marketplace (13 Features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| U73 | Pinterest-Style Layout | Staggered Grid / Masonry Layout for visual appeal | Core |
| U74 | Feed Algorithm | Auto-populates based on User Location (City) + Interest (Course) | Core |
| U75 | Discovery Mix | Shows randomized content mix without forcing filters on load | Important |
| U76 | Optional Filters | Top bar filters for City, Category | Important |
| U77 | Hard Goods Category | Books, Drafters, Calculators, Coolers, Hostel Essentials | Core |
| U78 | Housing Category | Flatmates, Room availability (5km radius) | Core |
| U79 | Opportunities Category | Internships, Gigs, Events | Core |
| U80 | Community Category | Polls, Reviews, Questions | Core |
| U81 | Item Card | Variable aspect ratio image + Price + Distance ("800m away") | Core |
| U82 | Text Card | Solid background color + Question/Review text | Core |
| U83 | Banner Card | Full-width for Events or Job posts | Core |
| U84 | Secondary FAB | Inside Connect section for posting content | Core |
| U85 | Posting Options | Sell/Rent Item (Camera → Form), Post Opportunity, Community Post (Text/Poll) | Core |

### G. Profile & Settings (15 Features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| U86 | Hero Section | Top 30% with dark/colored background, User Avatar, Name, Tagline | Core |
| U87 | Stats Card | Floating card with Wallet Balance + Total Projects Completed | Core |
| U88 | Wallet Balance Display | Large bold text with "Available Credits" subtext, tap for Transaction History | Core |
| U89 | Personal Details Edit | Edit Name, Phone, Email | Core |
| U90 | College & Course Info | University Name, Course, Current Year, City (controls Connect feed algorithm) | Core |
| U91 | Payment Methods | Manage Saved Cards / UPI IDs | Core |
| U92 | Help & Support | Direct WhatsApp Support link + "Raise a Ticket" form | Core |
| U93 | How It Works | Re-launches onboarding overlay/tutorial | Important |
| U94 | Referral Code | "Share Code: EXPERT20" with tap-to-copy functionality | Core |
| U95 | Log Out Button | Footer action | Core |
| U96 | App Version | Display current version (v1.0.0) | Important |
| U97 | Trust Badges | Lock icon + "Your data is encrypted and never shared" on input screens | Important |
| U98 | Transaction History | Detailed list of wallet transactions | Core |
| U99 | Top-Up Wallet | Add money to wallet balance | Core |
| U100 | Profile Picture | User image or initials avatar | Important |

---

## 4. Doer App & Website Features

**Target Audience:** Students/Freelancers seeking part-time earnings  
**Core Theme:** Professionalism, Growth, Reliable Support  
**App Name:** "Talent Connect" / "DOER"

### A. Onboarding & Registration (12 Features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| D01 | Splash Screen | Clean white/dark blue background with App Logo, optional "Powered by" footer | Core |
| D02 | Onboarding Carousel | 4 slides: Opportunity, Rewards, Support, Action with Skip + Next + Dots | Core |
| D03 | Slide 1 - Opportunity | "Countless opportunities in your field" - Digital globe/network illustration | Core |
| D04 | Slide 2 - Rewards | "Small Tasks, Big Rewards" - Wallet/coin growth chart | Core |
| D05 | Slide 3 - Support | "Supervisor Support (24x7)" - Headset/shield icon | Core |
| D06 | Slide 4 - Action | "Practical Learning with Part-Time Earning" - Person on laptop, "Start Your Freelancing Journey Now!" CTA | Core |
| D07 | Registration Form | Full Name, Email, Phone (with country code + OTP verify), Password, Confirm Password | Core |
| D08 | Terms Agreement | "By signing up, I agree to Terms of Service & Privacy Policy" | Core |
| D09 | Create Account CTA | Primary registration button | Core |
| D10 | Profile Setup - Qualification | Dropdown: High School, Undergrad, Post-Grad, PhD | Core |
| D11 | Profile Setup - Skills | University Name input, Areas of Interest (multi-select chips: IT/Coding, Content Writing, Graphic Design, Data Entry, Management, Science/Math), Specific Skills (tags) | Core |
| D12 | Profile Setup - Experience | Slider or options: Beginner, Intermediate, Pro | Core |

### B. Activation Flow / Gatekeeper (8 Features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| D13 | Activation Gate UI | Dashboard LOCKED until 3 steps complete, Visual stepper (1-2-3) | Core |
| D14 | Step 1: Training Module | Video/PDF carousel covering Quality Standards, No Plagiarism Policy, Deadlines, How to use Tools | Core |
| D15 | Mark as Complete | Button to confirm training completion | Core |
| D16 | Step 2: Interview Quiz | 5-10 MCQs based on Training Module content | Core |
| D17 | Quiz Pass/Fail Logic | Success: "Great job! Proceed to next step" / Fail: "Please review training and try again" | Core |
| D18 | Step 3: Bank Details | Account Holder Name, Account Number, IFSC Code, UPI ID (optional but recommended) | Core |
| D19 | Finish Setup CTA | Completes activation, redirects to Dashboard | Core |
| D20 | Re-attempt Quiz | Allow retry after reviewing training on failure | Important |

### C. Main Dashboard (12 Features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| D21 | Top Header | App Logo/Name (left), Notification Bell + Hamburger Menu (right) | Core |
| D22 | Menu Drawer / Sidebar | User Info (Profile Pic, Name), Availability Switch, Menu Items | Core |
| D23 | Availability Toggle | 🟢 Available / ⚪ Busy switch with text "Show me as available for urgent tasks" | Core |
| D24 | Sidebar Menu Items | My Profile, Reviews, Statistics, Help & Support, Settings | Core |
| D25 | Dashboard Tabs | "Assigned to Me" (priority) + "Open Pool" (grab tasks) | Core |
| D26 | Assigned to Me Tab | Tasks specifically given by Supervisor | Core |
| D27 | Open Pool Tab | General tasks available for anyone in their field to grab | Core |
| D28 | Project Card in List | Title, Urgency Badge (Urgent/Standard), Price (₹500), Deadline ("Due in 4 Hours") | Core |
| D29 | Accept Task Button | Primary action on project cards | Core |
| D30 | Urgency Badge | 🔥 Fire icon or Red color for tasks due in <6 hours | Important |
| D31 | Statistics Page | Detailed graphs of performance metrics | Important |
| D32 | Reviews Page | Feedback score and rating history | Important |

### D. Active Projects (9 Features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| D33 | Active Projects Tabs | Active, Under Review (QC), Completed | Core |
| D34 | Active Tab | Work in Progress with "Open Workspace" button | Core |
| D35 | Workspace View | Project details, chat with supervisor, file upload | Core |
| D36 | Under Review Tab | Submitted work, "QC in Progress" status | Core |
| D37 | Completed Tab | History with "Paid" or "Approved" status | Core |
| D38 | Revision Requested Flag | Red highlight when Supervisor rejects file - "Revision Requested" | Core |
| D39 | File Upload | Submit completed work for QC | Core |
| D40 | Chat with Supervisor | In-context communication during active work | Core |
| D41 | Deadline Display | Clear deadline countdown on active projects | Core |

### E. Resources & Tools (5 Features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| D42 | Training Center | Re-watch training videos | Core |
| D43 | AI Report Generator | Internal tool to check AI percentage in work | Core |
| D44 | Citation Builder | Input URL → Get APA/Harvard reference | Core |
| D45 | Format Templates | Download standard Word/PPT templates | Core |
| D46 | Resources Grid Layout | Clean grid display of all tools | Important |

### F. Profile & Earnings (11 Features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| D47 | Scorecard Section | Table/Grid: Active Assignments, Completed, Total Earnings, Rating (4.8/5 ⭐) | Core |
| D48 | Edit Profile | Update qualifications, add new skills/interests (triggers mini-review by Supervisor) | Core |
| D49 | Payment History | Detailed list of past withdrawals and pending payments | Core |
| D50 | Bank Details Management | Edit/Update saved account info | Core |
| D51 | Contact Support | Direct WhatsApp link to Supervisor or Ticket system | Core |
| D52 | Log Out | Profile footer action | Core |
| D53 | Request Payout Button | Next to "Total Earnings" for manual withdrawal requests | Core |
| D54 | Pending Payments Display | Show earnings awaiting clearance | Important |
| D55 | Earnings Graph | Visual representation of earnings over time | Optional |
| D56 | Rating Breakdown | Detailed view of rating components | Optional |
| D57 | Skill Verification Status | Show which skills have been verified | Optional |

---

## 5. Supervisor App Features

**Target Audience:** Senior Professionals / Subject Matter Experts  
**Core Value:** "Earn by Managing" (High-level Quality Control)  
**App Name:** "AdminX"  
**Visual Theme:** Professional, Sharp, Authority-driven (Dark Blue/Slate Grey & White)

### A. Onboarding & Registration (11 Features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| S01 | Splash Screen | Professional Dark Blue background, AdminX Logo (Shield or Abstract 'A'), Footer: "Quality. Integrity. Supervision." | Core |
| S02 | Onboarding Slide 1 | "Can you supervise with the knowledge which you have?" - Person checking checklist | Core |
| S03 | Onboarding Slide 2 | "Do you want to increase the knowledge in your field?" - Growth chart/Brain icon | Core |
| S04 | Onboarding Slide 3 | "Admin X is for you!" with subtext about supervising and earning | Core |
| S05 | Step 1: Basic Credentials | Full Name, Email, Phone (OTP verify), Password | Core |
| S06 | Step 2: Professional Profile | Highest Qualification dropdown, Areas of Expertise (multi-select), Years of Experience, CV/Proof Upload (PDF) | Core |
| S07 | Step 3: Banking Setup | Bank Name, Account Number, IFSC Code, UPI ID | Core |
| S08 | Submit Application CTA | Sends application for review | Core |
| S09 | Application Pending State | Waiting for admin approval after submission | Core |
| S10 | CV Verification | Backend review of uploaded credentials | Core |
| S11 | Experience Validation | Verify years of experience claimed | Important |

### B. Activation Phase (6 Features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| S12 | Activation Lock Screen | Dashboard LOCKED with "Unlock Your Admin Rights" header | Core |
| S13 | Training Module | Videos/PDFs: "How to QC a file", "Pricing Guidelines", "Communication Ethics" | Core |
| S14 | Mark Complete Button | Unlocks next step after training | Core |
| S15 | Supervisor Test | 10 scenario-based questions (e.g., "What do you do if a Doer submits AI-generated text?") | Core |
| S16 | Test Pass/Fail | Success unlocks dashboard, Fail requires re-review | Core |
| S17 | Welcome Message | "Welcome, Admin. Your dashboard is ready." on successful activation | Core |

### C. Main Dashboard / Requests (12 Features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| S18 | Top Bar Greeting | "Hello, [Name]." with Notification Bell | Core |
| S19 | Menu Drawer | Profile Card (Name + Rating 4.9/5.0 ⭐), Availability Toggle, Menu Items | Core |
| S20 | Availability Toggle | 🟢 Available / ⚪ Busy for receiving new projects | Core |
| S21 | Drawer Menu Items | Doer Reviews, My Reviews, Earnings, Settings | Core |
| S22 | Field Filter | "My Field Only" default filter for requests | Core |
| S23 | Section A: New Requests | Projects needing quote - Card: Title, Student Name, "Analyze & Quote" button | Core |
| S24 | Analyze & Quote Action | Supervisor sets the price for the Client | Core |
| S25 | Section B: Ready to Assign | Paid projects - Card: Title, "PAID" badge, "Assign Doer" button | Core |
| S26 | Assign Doer Action | Opens list of available Experts, select based on rating/price/availability | Core |
| S27 | Doer Selection List | Shows Doer name, rating, skills, availability status | Core |
| S28 | Project Pricing | Set both user quote and doer payout amounts | Core |
| S29 | Doer Reviews Access | Check ratings/feedback of Experts before assignment | Core |

### D. Active Projects Management (10 Features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| S30 | Active Projects Tabs | On Going, For Review (QC), Completed | Core |
| S31 | On Going Tab | Project ID, Expert Name, Timer, Chat button | Core |
| S32 | For Review (QC) Tab | Expert submitted file, awaiting supervisor review | Core |
| S33 | Approve & Deliver Action | QC passed, sends deliverable to client | Core |
| S34 | Reject/Revision Action | Sends back to Doer with feedback for rework | Core |
| S35 | Completed Tab | Project history with status | Core |
| S36 | Unified Chat Interface | Talk to Client (Student) AND Doer (Expert) - separate or group chats | Core |
| S37 | Chat Monitoring | Supervisor can view all chat messages | Core |
| S38 | Chat Suspension | Supervisor can suspend chat when contact sharing detected | Core |
| S39 | Contact Sharing Prevention | Chat blocks doer from sending contact details | Core |

### E. Training & Resources (5 Features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| S40 | Plagiarism Checker | Internal tool to verify Doer's work | Core |
| S41 | AI Detector | Check for AI-generated content in submissions | Core |
| S42 | Pricing Guide | Reference sheet for standard quote amounts | Core |
| S43 | Advanced Training | Upskill videos for supervisors | Important |
| S44 | Resources Grid | Clean layout for all tools | Important |

### F. Profile & Statistics (10 Features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| S45 | Stats Dashboard | Active Projects, Projects Completed, Success Rate (%), Total Earnings | Core |
| S46 | Edit Profile | Update skills/qualifications | Core |
| S47 | Payment Ledger | Transaction history with commission details | Core |
| S48 | Contact Support | Help line access | Core |
| S49 | Log Out | Profile action | Core |
| S50 | My Reviews | See feedback Clients gave you | Core |
| S51 | Doer Blacklist | Flag bad Experts to avoid future assignments | Core |
| S52 | Commission Tracking | Earnings per project visible | Core |
| S53 | Performance Metrics | Success rate, response time, client satisfaction | Important |
| S54 | Earnings Graph | Visual earnings over time | Optional |

### G. Doer & User Management (4 Features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| S55 | Doer Management | View skills, ratings, availability of all doers | Core |
| S56 | User Management | View profiles and project history of clients | Core |
| S57 | Notification System | Alerts for new projects, submissions, payments | Core |
| S58 | Earnings Overview | Commission tracking per project with breakdown | Core |

---

## 6. Admin Panel Features

**Platform:** Next.js Web Application  
**Purpose:** Complete platform management and oversight

| # | Module | Description | Features |
|---|--------|-------------|----------|
| A01 | User Management | Complete user control | View, edit, delete, block users; User search & filters; Activity logs |
| A02 | Doer Management | Expert oversight | Manage doers, approve registrations; View performance; Suspend/activate accounts |
| A03 | Supervisor Management | Admin control | Add, edit, remove supervisors; Assign permissions; Performance tracking |
| A04 | Project Management | Full project visibility | View all projects; Status tracking; Timeline management; Payment status |
| A05 | Payments & Transactions | Financial management | Incoming payments; Payouts to doers/supervisors; Refund processing |
| A06 | Revenue Analytics | Business intelligence | Revenue graphs; Profit margins; Commission reports; Export functionality |
| A07 | Marketplace Moderation | Content control | Approve/reject listings; Flag inappropriate posts; Community moderation |
| A08 | Referral Codes | Promo management | Create codes; Track usage; Manage discounts; Expiry settings |
| A09 | Push Notifications | Communication | Send platform-wide notifications; Targeted messaging; Schedule sends |
| A10 | Content Management | Platform content | Manage banners; Onboarding slides; FAQs; Terms & Conditions |
| A11 | Support Tickets | Customer service | View complaints; Respond to tickets; Escalation management |
| A12 | Sentry Integration | Technical monitoring | Error tracking; Crash reports; Performance monitoring; Alerting |

---

## 7. Cross-Platform Features

### A. Real-Time Chat System (6 Features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| C01 | 3-Way Chat | User ↔ Supervisor ↔ Doer via Supabase Realtime | Core |
| C02 | Project Context | Chat automatically linked to specific Project ID | Core |
| C03 | Message Notifications | Push notifications for new messages | Core |
| C04 | Read Receipts | Show message read status | Important |
| C05 | File Sharing in Chat | Share documents within conversation | Important |
| C06 | Contact Blocking | Prevent sharing of personal contact details | Core |

### B. Notification System (4 Features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| C07 | Push Notifications | In-app and system notifications | Core |
| C08 | WhatsApp Notifications | Business API integration for critical updates | Core |
| C09 | Email Notifications | Optional email alerts | Optional |
| C10 | Notification Preferences | User control over notification types | Important |

### C. Payment System (6 Features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| C11 | Razorpay Integration | Primary payment gateway | Core |
| C12 | Wallet System | In-app balance for users | Core |
| C13 | UPI Payments | Direct UPI support | Core |
| C14 | Card Payments | Debit/Credit card support | Core |
| C15 | Payout Processing | Automated payouts to Doers/Supervisors | Core |
| C16 | Transaction History | Complete payment audit trail | Core |

### D. File Management (4 Features)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| C17 | File Upload | PDF, DOC, DOCX, Images support | Core |
| C18 | Google Docs Integration | Live draft tracking via read-only WebView | Core |
| C19 | Secure File Storage | Encrypted file storage | Core |
| C20 | Download Management | Secure file downloads for deliverables | Core |

---

## 8. Project Workflow & Status System

### Status Color Coding (Universal)

| Color | Status | Description |
|-------|--------|-------------|
| 🟡 Yellow | Analyzing | Supervisor reviewing requirements |
| 🟠 Orange | Payment Pending | Quote ready, awaiting payment |
| 🔵 Blue | In Progress | Expert actively working |
| 🟢 Green | For Review | Work delivered, awaiting approval |
| ⚫ Grey | Completed | Archived in history |
| 🔴 Red | Urgent/Revision | <6h deadline or revision requested |

### End-to-End Workflow

```
USER                      SUPERVISOR                  DOER
────                      ──────────                  ────

1. Submit Project ───────→ 2. Analyze Request
                          3. Set Quote ─────────────→
4. Receive Quote
   (Push + WhatsApp)
5. Pay ──────────────────→ 6. Assign Doer ──────────→ 7. Accept Task
                                                      8. Work in Progress
9. Track Live Draft ←──────────────────────────────── (Google Docs)
                                                      10. Submit File
                          11. QC Review ←─────────────
                          12a. Approve ──────────────→ Payment Released
                          12b. Reject ───────────────→ Revision Required
13. Receive Files ←─────── (Deliver to Client)
14. Review Work
15a. Approve → History
15b. Request Changes ────→ Back to Step 6
```

---

## 9. Exclusions

The following are explicitly **NOT included** in scope:

| # | Exclusion | Notes |
|---|-----------|-------|
| E01 | Doctor Consultation Feature | Placeholder only, future scope |
| E02 | Multiple Payment Gateways | Razorpay only |
| E03 | AMC / Ongoing Support | Not included post bug-fix period |
| E04 | Content Creation | No SEO, Marketing, Content services |
| E05 | Post Bug-Fix Support | Charged separately after 17 Mar 2026 |

---

## 📊 Feature Summary

| Platform | Total Features |
|----------|---------------|
| User App & Website | 100 |
| Doer App & Website | 57 |
| Supervisor App | 58 |
| Admin Panel | 12 modules |
| Cross-Platform | 20 |
| **Total Unique Features** | **247+** |

---

*Document Generated: December 2025*  
*Project: AssignX v1.0*  
*Service Provider: Om Rajpal*
