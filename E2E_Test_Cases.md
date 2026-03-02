# AssignX End-to-End Test Cases

## Test Environment
- **API Server**: http://localhost:4000
- **User-Web**: http://localhost:3001
- **Doer-Web**: http://localhost:3003
- **Superviser-Web**: http://localhost:3000
- **Admin-Web**: http://localhost:3002
- **Database**: MongoDB Atlas (AssignX)

## Test Accounts
| Role | Email | Password/Auth |
|------|-------|---------------|
| User (Real) | omrajpal.exe@gmail.com | Magic Link |
| User (Test) | testuser@gmail.com | Magic Link |
| Doer | testdoer@gmail.com | Magic Link |
| Supervisor | testsupervisor@gmail.com | Magic Link |
| Admin | admin@gmail.com | bypass |

---

## PHASE 1: USER-WEB (Student/User Platform)

### 1.1 Authentication Flow
- [ ] **TC-U-001**: Visit landing page at `/` - verify hero section, stats, features load
- [ ] **TC-U-002**: Click "Login" - navigate to `/login`
- [ ] **TC-U-003**: Enter email, receive magic link via Resend
- [ ] **TC-U-004**: Click magic link - verify redirect to dashboard
- [ ] **TC-U-005**: Visit `/signup` - verify registration form loads
- [ ] **TC-U-006**: Complete signup as student - verify onboarding redirect
- [ ] **TC-U-007**: Complete onboarding profile setup at `/onboarding`
- [ ] **TC-U-008**: Logout - verify session cleared, redirected to landing

### 1.2 Dashboard
- [ ] **TC-U-010**: Verify dashboard loads with personalized greeting
- [ ] **TC-U-011**: Check wallet balance pill displays correctly
- [ ] **TC-U-012**: Verify notification bell shows unread count
- [ ] **TC-U-013**: Check services grid (New Project, Campus Connect, Experts, etc.)
- [ ] **TC-U-014**: Verify banner carousel displays promotions
- [ ] **TC-U-015**: Sidebar navigation links all work

### 1.3 Project Creation & Management
- [ ] **TC-U-020**: Click "New Project" - verify project form loads
- [ ] **TC-U-021**: Create an Assignment project:
  - Fill title, subject, description
  - Set deadline (future date)
  - Upload reference files
  - Select urgency level
  - Submit project
- [ ] **TC-U-022**: Create a Report project with different service type
- [ ] **TC-U-023**: Create a Proofreading project
- [ ] **TC-U-024**: Create a Consultation/Expert Opinion project
- [ ] **TC-U-025**: Verify project appears in "My Projects" list at `/projects`
- [ ] **TC-U-026**: Click on project - verify detail page loads with:
  - Project title, description, subject
  - Status badge (draft/submitted/in_progress/etc.)
  - Assigned supervisor and doer (when assigned)
  - Chat window for communication
  - Timeline/status tracker
  - File attachments
- [ ] **TC-U-027**: Send a message in project chat
- [ ] **TC-U-028**: Upload a file in project chat
- [ ] **TC-U-029**: Verify chat presence indicator shows who's online
- [ ] **TC-U-030**: Verify typing indicator works

### 1.4 Campus Connect
- [ ] **TC-U-040**: Navigate to `/campus-connect`
- [ ] **TC-U-041**: View existing posts in feed
- [ ] **TC-U-042**: Create a new campus post with title and content
- [ ] **TC-U-043**: Upload image with post
- [ ] **TC-U-044**: Like/react to a post
- [ ] **TC-U-045**: Comment on a post
- [ ] **TC-U-046**: Report a post (verify report dialog)
- [ ] **TC-U-047**: Save/bookmark a post
- [ ] **TC-U-048**: Filter posts by category
- [ ] **TC-U-049**: Search posts

### 1.5 Experts
- [ ] **TC-U-050**: Navigate to `/experts` - verify expert directory loads
- [ ] **TC-U-051**: Browse expert profiles with ratings
- [ ] **TC-U-052**: Click expert - verify profile detail page loads
- [ ] **TC-U-053**: Book an expert session:
  - Select date from calendar
  - Choose time slot
  - Review price breakdown
  - Confirm booking
- [ ] **TC-U-054**: View "My Bookings" list
- [ ] **TC-U-055**: Leave a review for a completed session

### 1.6 Marketplace
- [ ] **TC-U-060**: Navigate to `/marketplace`
- [ ] **TC-U-061**: Browse marketplace listings
- [ ] **TC-U-062**: Create a marketplace listing:
  - Add title, description, price
  - Upload images
  - Select category
  - Publish listing
- [ ] **TC-U-063**: Search and filter listings
- [ ] **TC-U-064**: View listing detail page

### 1.7 Connect / Pro Network / Business Hub
- [ ] **TC-U-070**: Navigate to `/connect` - view professional network
- [ ] **TC-U-071**: Browse study groups and connections
- [ ] **TC-U-072**: Navigate to `/pro-network` - view professional posts
- [ ] **TC-U-073**: Create a pro-network post
- [ ] **TC-U-074**: Save/bookmark pro-network posts
- [ ] **TC-U-075**: Navigate to `/business-hub` - view business content
- [ ] **TC-U-076**: Create a business hub post

### 1.8 Wallet & Payments
- [ ] **TC-U-080**: Navigate to `/wallet`
- [ ] **TC-U-081**: View current balance and transaction history
- [ ] **TC-U-082**: Add balance to wallet (Razorpay integration):
  - Enter amount
  - Complete Razorpay checkout
  - Verify balance updated
- [ ] **TC-U-083**: Send money to another user:
  - Enter recipient email
  - Enter amount
  - Confirm transfer
  - Verify balance deducted
- [ ] **TC-U-084**: Pay for a project using wallet balance
- [ ] **TC-U-085**: Verify transaction history updates after each operation
- [ ] **TC-U-086**: Download invoice for a completed project

### 1.9 Profile
- [ ] **TC-U-090**: Navigate to `/profile`
- [ ] **TC-U-091**: View profile information (name, email, avatar)
- [ ] **TC-U-092**: Edit profile (change name, bio, avatar)
- [ ] **TC-U-093**: Update payment methods
- [ ] **TC-U-094**: View security settings
- [ ] **TC-U-095**: Change password/email settings

### 1.10 Settings
- [ ] **TC-U-100**: Navigate to `/settings`
- [ ] **TC-U-101**: Toggle notification preferences (email, push, in-app)
- [ ] **TC-U-102**: Update privacy controls
- [ ] **TC-U-103**: Change language preference
- [ ] **TC-U-104**: Toggle dark/light mode

### 1.11 Support
- [ ] **TC-U-110**: Navigate to `/support`
- [ ] **TC-U-111**: View FAQ section
- [ ] **TC-U-112**: Submit a support ticket:
  - Select category
  - Enter subject and description
  - Attach screenshot
  - Submit
- [ ] **TC-U-113**: View existing tickets and their status
- [ ] **TC-U-114**: Reply to a support ticket

---

## PHASE 2: SUPERVISER-WEB (Supervisor Platform)

### 2.1 Authentication & Onboarding
- [ ] **TC-S-001**: Visit supervisor login page at `/`
- [ ] **TC-S-002**: Login with magic link (testsupervisor@gmail.com)
- [ ] **TC-S-003**: Verify redirect to dashboard after auth
- [ ] **TC-S-004**: Visit `/register` - verify 4-step registration wizard
- [ ] **TC-S-005**: Complete registration (personal info, experience, banking, review)
- [ ] **TC-S-006**: View pending approval page at `/pending-approval`
- [ ] **TC-S-007**: Complete training at `/training`

### 2.2 Dashboard
- [ ] **TC-S-010**: Verify dashboard loads with stats:
  - Total projects count
  - Active/completed projects
  - Commission earned
  - Available doers count
- [ ] **TC-S-011**: Verify project quick stats cards
- [ ] **TC-S-012**: Check availability toggle (online/offline)
- [ ] **TC-S-013**: Review incoming project assignments

### 2.3 Project Management
- [ ] **TC-S-020**: Navigate to `/projects` - view all assigned projects
- [ ] **TC-S-021**: View project detail page (`/projects/[id]`):
  - Project requirements and description
  - Assigned doer information
  - Deliverables and milestones
  - Deadline timer
  - Status progression
- [ ] **TC-S-022**: Assign a doer to a project (from available doers)
- [ ] **TC-S-023**: Send a quote/pricing to user for a project
- [ ] **TC-S-024**: Review submitted deliverables (QC review)
- [ ] **TC-S-025**: Approve deliverables - mark as QC approved
- [ ] **TC-S-026**: Reject deliverables - provide revision feedback:
  - Enter detailed feedback
  - Specify what needs to change
  - Set revision deadline
- [ ] **TC-S-027**: Track project through all statuses:
  draft → submitted → quoted → paid → assigned → in_progress →
  submitted_for_qc → qc_approved → delivered → completed
- [ ] **TC-S-028**: Filter projects by status (active, completed, pending)
- [ ] **TC-S-029**: Search projects by title or number

### 2.4 Doer Management
- [ ] **TC-S-030**: Navigate to `/doers` - view available doers
- [ ] **TC-S-031**: View doer detail page (`/doers/[doerId]`):
  - Profile information
  - Skills and subjects
  - Performance metrics
  - Rating and reviews
  - Project history
- [ ] **TC-S-032**: Assign a doer to a specific project
- [ ] **TC-S-033**: Review doer performance
- [ ] **TC-S-034**: Add doer to blacklist (with reason)
- [ ] **TC-S-035**: Remove doer from blacklist

### 2.5 Chat & Communication
- [ ] **TC-S-040**: Navigate to `/chat` - view conversation list
- [ ] **TC-S-041**: Open a chat room with a user/doer
- [ ] **TC-S-042**: Send text messages
- [ ] **TC-S-043**: Upload and send files
- [ ] **TC-S-044**: Verify message read receipts
- [ ] **TC-S-045**: Check unread message counts
- [ ] **TC-S-046**: Mark all messages as read

### 2.6 Earnings
- [ ] **TC-S-050**: Navigate to earnings page
- [ ] **TC-S-051**: View commission overview and goal tracker
- [ ] **TC-S-052**: Check transaction history
- [ ] **TC-S-053**: View commission tracking charts
- [ ] **TC-S-054**: Verify earnings calculations are correct

### 2.7 Users/Clients
- [ ] **TC-S-060**: Navigate to `/users` - view client list
- [ ] **TC-S-061**: View client detail page
- [ ] **TC-S-062**: See client project history

### 2.8 Resources & Training
- [ ] **TC-S-070**: Navigate to `/resources` - view training library
- [ ] **TC-S-071**: Watch training videos
- [ ] **TC-S-072**: Access tools and guides

### 2.9 Settings & Profile
- [ ] **TC-S-080**: Navigate to `/profile` - view/edit profile
- [ ] **TC-S-081**: Navigate to `/settings` - update preferences
- [ ] **TC-S-082**: Toggle notification settings
- [ ] **TC-S-083**: Update privacy settings

### 2.10 Support
- [ ] **TC-S-090**: Navigate to support page
- [ ] **TC-S-091**: View FAQs
- [ ] **TC-S-092**: Submit support ticket
- [ ] **TC-S-093**: View ticket history

---

## PHASE 3: DOER-WEB (Doer/Freelancer Platform)

### 3.1 Authentication & Activation
- [ ] **TC-D-001**: Visit doer login page at `/login`
- [ ] **TC-D-002**: Login with magic link (testdoer@gmail.com)
- [ ] **TC-D-003**: Verify redirect to dashboard
- [ ] **TC-D-004**: Visit `/register` - verify registration form
- [ ] **TC-D-005**: Complete registration (name, skills, bank details)
- [ ] **TC-D-006**: View pending approval at `/pending-approval`
- [ ] **TC-D-007**: Complete training at `/training`
- [ ] **TC-D-008**: Complete activation quiz at `/quiz`

### 3.2 Dashboard
- [ ] **TC-D-010**: Verify dashboard loads with:
  - Active projects count
  - Available projects in open pool
  - Pending earnings
  - Quick stats cards
- [ ] **TC-D-011**: View assigned task cards
- [ ] **TC-D-012**: View task pool cards (available to claim)

### 3.3 Projects
- [ ] **TC-D-020**: Navigate to `/projects` - view project list
- [ ] **TC-D-021**: View "Active Projects" tab with assigned work
- [ ] **TC-D-022**: View "Open Pool" tab with available projects
- [ ] **TC-D-023**: Accept/claim a project from open pool
- [ ] **TC-D-024**: View project detail (`/projects/[id]`):
  - Requirements and instructions
  - Deadline and timeline
  - Deliverable specifications
  - Chat with supervisor
- [ ] **TC-D-025**: Submit deliverables for a project:
  - Upload completed files
  - Add submission notes
  - Submit for QC review
- [ ] **TC-D-026**: Handle revision requests:
  - View revision feedback from supervisor
  - Make corrections
  - Resubmit
- [ ] **TC-D-027**: View "Under Review" tab for pending QC
- [ ] **TC-D-028**: View "Completed" tab for finished projects
- [ ] **TC-D-029**: Check project insights sidebar (deadlines, stats)

### 3.4 Reviews & Statistics
- [ ] **TC-D-030**: Navigate to `/reviews` - view feedback received
- [ ] **TC-D-031**: Navigate to `/statistics` - view performance metrics
- [ ] **TC-D-032**: Check earnings graph
- [ ] **TC-D-033**: View completion rate and on-time delivery stats

### 3.5 Resources
- [ ] **TC-D-040**: Navigate to `/resources`
- [ ] **TC-D-041**: View training center with videos
- [ ] **TC-D-042**: Access learning materials and guides

### 3.6 Settings & Profile
- [ ] **TC-D-050**: Navigate to settings page
- [ ] **TC-D-051**: Update account settings
- [ ] **TC-D-052**: Update notification preferences
- [ ] **TC-D-053**: Update privacy settings
- [ ] **TC-D-054**: Edit profile (name, bio, skills)
- [ ] **TC-D-055**: Update bank details

### 3.7 Support
- [ ] **TC-D-060**: Navigate to support page
- [ ] **TC-D-061**: View FAQs
- [ ] **TC-D-062**: Submit support ticket
- [ ] **TC-D-063**: Track ticket status

---

## PHASE 4: ADMIN-WEB (Admin Panel)

### 4.1 Authentication
- [ ] **TC-A-001**: Visit admin login at `/login`
- [ ] **TC-A-002**: Login with admin@gmail.com / bypass
- [ ] **TC-A-003**: Verify redirect to dashboard

### 4.2 Dashboard
- [ ] **TC-A-010**: Verify dashboard loads with stats cards:
  - Total Users
  - Active Projects
  - Revenue
  - Pending Tickets
- [ ] **TC-A-011**: Verify user growth chart displays data
- [ ] **TC-A-012**: Verify revenue chart displays data
- [ ] **TC-A-013**: Check recent support tickets table

### 4.3 User Management
- [ ] **TC-A-020**: Navigate to `/users` - verify all users listed
- [ ] **TC-A-021**: Search users by name or email
- [ ] **TC-A-022**: Filter users by type (user, doer, supervisor, admin)
- [ ] **TC-A-023**: Filter users by status (active, suspended)
- [ ] **TC-A-024**: Click user row - view user detail page
- [ ] **TC-A-025**: Suspend/activate a user
- [ ] **TC-A-026**: View user's wallet and transactions

### 4.4 Project Management
- [ ] **TC-A-030**: Navigate to `/projects` - verify all projects listed
- [ ] **TC-A-031**: Search projects by title
- [ ] **TC-A-032**: Filter projects by status
- [ ] **TC-A-033**: View project detail with all assignments
- [ ] **TC-A-034**: Verify user/supervisor/doer names display correctly

### 4.5 People Management
- [ ] **TC-A-040**: Navigate to `/supervisors` - view supervisor list
- [ ] **TC-A-041**: Click supervisor - view detail with performance metrics
- [ ] **TC-A-042**: Approve/reject supervisor application
- [ ] **TC-A-043**: Navigate to `/doers` - view doer list
- [ ] **TC-A-044**: Click doer - view detail with skills, earnings, projects
- [ ] **TC-A-045**: Approve/reject doer application
- [ ] **TC-A-046**: Navigate to `/experts` - view expert list
- [ ] **TC-A-047**: Add new expert from admin panel
- [ ] **TC-A-048**: Verify/reject expert profile
- [ ] **TC-A-049**: Feature/unfeature an expert

### 4.6 Financial Management
- [ ] **TC-A-050**: Navigate to `/wallets` - view all wallets
- [ ] **TC-A-051**: View wallet detail with transactions
- [ ] **TC-A-052**: Issue a refund to a user
- [ ] **TC-A-053**: View financial summary

### 4.7 Support & Moderation
- [ ] **TC-A-060**: Navigate to `/support` - view all tickets
- [ ] **TC-A-061**: View ticket detail and respond
- [ ] **TC-A-062**: Navigate to `/moderation` - view reported content
- [ ] **TC-A-063**: Flag/unflag a user
- [ ] **TC-A-064**: Navigate to `/messages` - view system messages

### 4.8 Content Management
- [ ] **TC-A-070**: Navigate to `/banners` - view all banners
- [ ] **TC-A-071**: Create a new banner with image and scheduling
- [ ] **TC-A-072**: Edit/delete existing banner
- [ ] **TC-A-073**: Toggle banner active/inactive
- [ ] **TC-A-074**: Navigate to `/colleges` - view colleges
- [ ] **TC-A-075**: Navigate to `/learning` - view learning resources
- [ ] **TC-A-076**: Create new learning resource

### 4.9 CRM
- [ ] **TC-A-080**: Navigate to `/crm` - view CRM dashboard with metrics
- [ ] **TC-A-081**: View revenue pipeline
- [ ] **TC-A-082**: View customer segments at `/crm/segments`
- [ ] **TC-A-083**: View communications at `/crm/communications`
- [ ] **TC-A-084**: View content control at `/crm/content`
- [ ] **TC-A-085**: View customer detail (`/crm/customers/[id]`)

### 4.10 Analytics & Reports
- [ ] **TC-A-090**: Navigate to `/analytics` - verify KPI cards load
- [ ] **TC-A-091**: Verify platform health cards (pending approvals, active doers, tickets)
- [ ] **TC-A-092**: Verify user growth chart
- [ ] **TC-A-093**: Verify user distribution breakdown
- [ ] **TC-A-094**: Verify project status breakdown
- [ ] **TC-A-095**: Navigate to `/reports`

### 4.11 Settings
- [ ] **TC-A-100**: Navigate to `/settings`
- [ ] **TC-A-101**: Update general settings (app name, support email)
- [ ] **TC-A-102**: Toggle maintenance mode
- [ ] **TC-A-103**: Configure feature flags
- [ ] **TC-A-104**: Update payment/commission settings

---

## PHASE 5: CROSS-PLATFORM FLOWS (End-to-End Scenarios)

### 5.1 Complete Project Lifecycle
- [ ] **TC-X-001**: User creates project on user-web
- [ ] **TC-X-002**: Admin sees new project on admin-web `/projects`
- [ ] **TC-X-003**: Supervisor sees project on superviser-web `/projects`
- [ ] **TC-X-004**: Supervisor sends quote to user
- [ ] **TC-X-005**: User pays for project (wallet/Razorpay)
- [ ] **TC-X-006**: Supervisor assigns doer to project
- [ ] **TC-X-007**: Doer sees assigned project on doer-web `/projects`
- [ ] **TC-X-008**: Doer works on project, submits deliverables
- [ ] **TC-X-009**: Supervisor reviews QC, approves/rejects
- [ ] **TC-X-010**: If rejected: doer gets revision feedback, resubmits
- [ ] **TC-X-011**: If approved: project marked as delivered
- [ ] **TC-X-012**: User confirms completion
- [ ] **TC-X-013**: Payment released to doer/supervisor wallets

### 5.2 Cross-Platform Chat
- [ ] **TC-X-020**: User sends message in project chat
- [ ] **TC-X-021**: Supervisor receives message in superviser-web
- [ ] **TC-X-022**: Supervisor replies
- [ ] **TC-X-023**: Doer sees messages in doer-web
- [ ] **TC-X-024**: Doer sends file in chat
- [ ] **TC-X-025**: All parties see real-time updates (Socket.IO)

### 5.3 Notifications Across Platforms
- [ ] **TC-X-030**: Project assignment generates notification for supervisor
- [ ] **TC-X-031**: Doer assignment generates notification for doer
- [ ] **TC-X-032**: QC approval generates notification for user
- [ ] **TC-X-033**: Payment generates notification for doer/supervisor
- [ ] **TC-X-034**: Support ticket update generates admin notification

### 5.4 Wallet/Payment Flow
- [ ] **TC-X-040**: User adds money to wallet
- [ ] **TC-X-041**: User pays for project
- [ ] **TC-X-042**: Admin verifies payment in admin wallets
- [ ] **TC-X-043**: On completion, doer/supervisor earnings credited
- [ ] **TC-X-044**: Admin issues refund if needed

### 5.5 Admin Actions Affecting Other Platforms
- [ ] **TC-X-050**: Admin suspends a user - verify user can't login
- [ ] **TC-X-051**: Admin approves doer - verify doer can access platform
- [ ] **TC-X-052**: Admin approves supervisor - verify supervisor can access
- [ ] **TC-X-053**: Admin creates banner - verify it shows on user-web
- [ ] **TC-X-054**: Admin flags content - verify it's hidden

---

## PHASE 6: EDGE CASES & ERROR HANDLING

### 6.1 Authentication Edge Cases
- [ ] **TC-E-001**: Try logging in with non-existent email
- [ ] **TC-E-002**: Try accessing protected page without auth - verify redirect
- [ ] **TC-E-003**: Token expiry - verify auto-refresh or re-login prompt
- [ ] **TC-E-004**: Concurrent sessions - verify behavior

### 6.2 Project Edge Cases
- [ ] **TC-E-010**: Create project with minimum fields only
- [ ] **TC-E-011**: Create project with very long title/description
- [ ] **TC-E-012**: Set deadline in the past
- [ ] **TC-E-013**: Upload large file (>25MB) - verify limit enforced
- [ ] **TC-E-014**: Cancel project mid-flow
- [ ] **TC-E-015**: Submit empty deliverables

### 6.3 Payment Edge Cases
- [ ] **TC-E-020**: Insufficient wallet balance for project payment
- [ ] **TC-E-021**: Send money with amount > balance
- [ ] **TC-E-022**: Send money to non-existent user
- [ ] **TC-E-023**: Double payment prevention
- [ ] **TC-E-024**: Razorpay failure handling

### 6.4 API Error Handling
- [ ] **TC-E-030**: API server down - verify graceful error pages
- [ ] **TC-E-031**: Invalid API response format - verify fallback rendering
- [ ] **TC-E-032**: Network timeout handling
- [ ] **TC-E-033**: Rate limiting behavior

### 6.5 UI/UX Edge Cases
- [ ] **TC-E-040**: Mobile responsive layout (resize browser)
- [ ] **TC-E-041**: Dark mode toggle on all pages
- [ ] **TC-E-042**: Empty state displays (no projects, no transactions, etc.)
- [ ] **TC-E-043**: Loading states during API calls
- [ ] **TC-E-044**: Form validation (required fields, email format, etc.)

---

## Test Execution Tracker

| Phase | Total Tests | Passed | Failed | Blocked | Notes |
|-------|------------|--------|--------|---------|-------|
| Phase 1: User-Web | 54 | 0 | 0 | 0 | |
| Phase 2: Superviser-Web | 42 | 0 | 0 | 0 | |
| Phase 3: Doer-Web | 33 | 0 | 0 | 0 | |
| Phase 4: Admin-Web | 44 | 0 | 0 | 0 | |
| Phase 5: Cross-Platform | 25 | 0 | 0 | 0 | |
| Phase 6: Edge Cases | 22 | 0 | 0 | 0 | |
| **TOTAL** | **220** | **0** | **0** | **0** | |
