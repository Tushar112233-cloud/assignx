# AssignX End-to-End Parallel Test Plan

> **Purpose:** Systematically test all four platforms (user-web, supervisor-web, doer-web, admin-web) with parallel, interconnected use cases that mirror real production workflows.

**Platforms:**
- User Web: `http://localhost:3000`
- Supervisor Web: `http://localhost:3001`
- Admin Web: `http://localhost:3002`
- Doer Web: `http://localhost:3003`
- API Server: `http://localhost:4000`

**Test Accounts:**
- User: `om@agiready.io`
- Supervisor: `omrajpal.exe@gmail.com`
- Doer: `omrajpal.exe@gmail.com`
- Admin: (check admin credentials in DB)

---

## PHASE 1: Authentication & Onboarding (All Platforms)

### TODO List

- [ ] **1.1 User Login** - Go to user-web `/login`, enter email, receive OTP, verify, land on dashboard
- [ ] **1.2 Supervisor Login** - Go to supervisor-web `/login`, enter email, receive OTP, verify, land on dashboard
- [ ] **1.3 Doer Login** - Go to doer-web `/login`, enter email, receive OTP, verify, land on dashboard
- [ ] **1.4 Admin Login** - Go to admin-web `/login`, enter email, receive OTP, verify, land on dashboard
- [ ] **1.5 Verify all dashboards load** - Each platform shows correct user info, stats, and navigation
- [ ] **1.6 Check notification badges** - All platforms show correct unread notification count on load

---

## PHASE 2: Project Creation & Claim Flow (User -> Supervisor)

### TODO List

- [ ] **2.1 [User] Create new project** - Go to `/projects/new`, fill form (title, description, subject, deadline, word count), submit
- [ ] **2.2 [User] Verify project appears** - Check `/projects` page, new project shows with "submitted" or "draft" status
- [ ] **2.3 [Supervisor] Check dashboard** - Verify new project appears in supervisor dashboard or projects list
- [ ] **2.4 [Supervisor] Claim project** - Go to `/projects`, find the new project, click claim/accept
- [ ] **2.5 [Supervisor] Submit quote** - Enter user quote amount, verify commission calculation (platform fee 20%, supervisor commission 15%)
- [ ] **2.6 [User] Receive notification** - Check user-web notification bell shows "Quote Ready" notification
- [ ] **2.7 [User] View quote** - Open project detail, see the quoted price
- [ ] **2.8 [Admin] Verify project** - Go to admin `/projects`, find the project, verify status shows "quoted"
- [ ] **2.9 [Admin] Check notification in admin** - Verify admin can see the project status in their management view

---

## PHASE 3: Payment Flow (User)

### TODO List

- [ ] **3.1 [User] Check wallet** - Go to `/wallet`, verify current balance
- [ ] **3.2 [User] Top-up wallet** - If insufficient balance, add funds via Razorpay
- [ ] **3.3 [User] Pay for project** - Go to project detail, click pay, confirm payment
- [ ] **3.4 [User] Verify payment success** - Check wallet transaction history shows "project_payment" debit
- [ ] **3.5 [Supervisor] Receive payment notification** - Check supervisor gets "Payment Received" notification
- [ ] **3.6 [Admin] Verify transaction** - Go to admin `/wallets`, verify the transaction appears with correct amount

---

## PHASE 4: Doer Assignment (Supervisor -> Doer)

### TODO List

- [ ] **4.1 [Supervisor] Go to project detail** - Open the paid project
- [ ] **4.2 [Supervisor] Browse doers** - Go to `/doers`, search for available doer
- [ ] **4.3 [Supervisor] Assign doer** - Click assign on project, select the doer, confirm assignment
- [ ] **4.4 [Doer] Receive notification** - Check doer-web shows "Task Assigned" notification
- [ ] **4.5 [Doer] View assigned project** - Go to `/projects`, verify the project appears in "Active" tab
- [ ] **4.6 [Doer] Open project workspace** - Click on project, verify all details load (title, deadline, payout, files)
- [ ] **4.7 [Admin] Verify assignment** - Check admin `/projects/[id]` shows doer assigned
- [ ] **4.8 [Supervisor] Verify auto-join chat** - Both supervisor and doer should now be in the project chat room

---

## PHASE 5: Project Execution (Doer)

### TODO List

- [ ] **5.1 [Doer] Start project** - Click "Start Project" button, status changes to "in_progress"
- [ ] **5.2 [Supervisor] Receive status notification** - Check supervisor gets notification about status change
- [ ] **5.3 [Doer] Add live document URL** - Paste a Google Docs link, click Save, verify it saves
- [ ] **5.4 [Supervisor] Check live doc notification** - Supervisor should see "Live Document Updated" notification
- [ ] **5.5 [User] Check live doc notification** - User should also see the live doc notification
- [ ] **5.6 [Doer] Verify live doc link visible** - Refresh project page, link shows with "Open current document" button

---

## PHASE 6: Cross-Platform Chat Testing

### TODO List

- [ ] **6.1 [Doer] Send message in project chat** - Go to Chat tab, type "Hello, I've started working on the project", send
- [ ] **6.2 [Supervisor] Check pending message** - Go to supervisor chat room, see doer message with "pending" approval status
- [ ] **6.3 [Supervisor] Approve message** - Click the green checkmark to approve the message
- [ ] **6.4 [User] See approved message** - Open user-web project chat, the approved message should appear
- [ ] **6.5 [User] Reply to message** - Type "Great, looking forward to the update!", send
- [ ] **6.6 [Supervisor] See user message** - Supervisor should see the user's message (auto-approved)
- [ ] **6.7 [Doer] See user message** - Doer should see the user's message in their chat
- [ ] **6.8 [Supervisor] Send own message** - Type "I'll coordinate between you two", send
- [ ] **6.9 [User] See supervisor message** - User should see the supervisor's message
- [ ] **6.10 [Doer] See supervisor message** - Doer should see the supervisor's message
- [ ] **6.11 [Supervisor] Reject a doer message** - Doer sends another message, supervisor rejects it
- [ ] **6.12 [User] NOT see rejected message** - User should NOT see the rejected message
- [ ] **6.13 [Supervisor] Suspend chat** - Test suspend chat functionality, verify all parties see "suspended" state
- [ ] **6.14 [Supervisor] Resume chat** - Resume the chat, verify messaging works again
- [ ] **6.15 Verify unread badges** - Navigate away from chat on all platforms, check unread count badges update

---

## PHASE 7: Submission & QC Flow (Doer -> Supervisor -> User)

### TODO List

- [ ] **7.1 [Doer] Upload deliverable** - Go to Submit tab, upload a file as deliverable
- [ ] **7.2 [Doer] Submit for review** - Click "Submit for Review", status changes to "submitted_for_qc"
- [ ] **7.3 [Supervisor] Receive QC notification** - Check supervisor gets "Work Submitted" or "Project Submitted for QC" notification
- [ ] **7.4 [Supervisor] Open QC interface** - Go to project detail, see the QC review tab
- [ ] **7.5 [Supervisor] Review deliverable** - Download the submitted file, review it
- [ ] **7.6 [Supervisor] Approve submission** - Click approve, status changes to "delivered" or "qc_approved"
- [ ] **7.7 [User] Receive delivery notification** - Check user gets "Project Delivered" notification
- [ ] **7.8 [User] View deliverables** - Open project detail, see the delivered files
- [ ] **7.9 [User] Accept delivery** - If auto-approve is off, accept the delivery
- [ ] **7.10 [All] Verify "completed" status** - All platforms show the project as completed
- [ ] **7.11 [Admin] Verify in admin panel** - Admin sees project status as completed

---

## PHASE 8: Revision Flow (Alternative Path)

### TODO List

- [ ] **8.1 [Supervisor] Reject submission** - Instead of approving, reject with feedback "Needs more analysis in section 3"
- [ ] **8.2 [Doer] Receive revision notification** - Doer gets "Revision Requested" notification
- [ ] **8.3 [Doer] View revision reason** - Open project, see the revision feedback
- [ ] **8.4 [Doer] Start revision** - Click start revision, status changes to "in_revision"
- [ ] **8.5 [Doer] Re-submit** - Upload revised file, submit again
- [ ] **8.6 [Supervisor] Review again** - Get notification, review revised submission, approve this time

---

## PHASE 9: Notification System Deep Test

### TODO List

- [ ] **9.1 [Supervisor] Open notifications page** - Go to `/notifications`, verify all notifications have titles AND messages
- [ ] **9.2 [Supervisor] Filter notifications** - Test filter by type, search by text
- [ ] **9.3 [Supervisor] Mark as read** - Click on notification, verify it marks as read
- [ ] **9.4 [Supervisor] Mark all as read** - Click "Mark all read", verify badge resets to 0
- [ ] **9.5 [User] Open notification bell** - Click bell icon, verify dropdown shows notifications with messages
- [ ] **9.6 [User] Click notification** - Click a notification, verify it navigates to relevant page
- [ ] **9.7 [Doer] Check notification header** - Verify doer header shows correct unread count
- [ ] **9.8 [Doer] Click notification** - Verify notifications are clickable and show message body
- [ ] **9.9 Real-time test** - With both platforms open, trigger an action on one, verify notification appears on the other WITHOUT page refresh

---

## PHASE 10: Earnings & Wallet Verification

### TODO List

- [ ] **10.1 [Supervisor] Check earnings page** - Go to `/earnings`, verify total earnings, monthly breakdown
- [ ] **10.2 [Supervisor] Verify commission** - After project completion, check the commission shows correctly
- [ ] **10.3 [Supervisor] Request withdrawal** - If balance > 500, try requesting a withdrawal
- [ ] **10.4 [Doer] Check earnings** - Go to doer profile > Payments tab, verify payout amount shows
- [ ] **10.5 [User] Check wallet** - Go to `/wallet`, verify transaction history shows project payment
- [ ] **10.6 [Admin] Check wallets** - Go to admin `/wallets`, verify all transactions are tracked

---

## PHASE 11: Supervisor Chat List & Messages Page

### TODO List

- [ ] **11.1 [Supervisor] Chat list page** - Go to `/chat`, verify rooms show with correct names, project numbers, titles
- [ ] **11.2 [Supervisor] Stats correct** - Verify Total, Unread, Clients, Experts, Groups counts
- [ ] **11.3 [Supervisor] Search works** - Type project name in search, verify filtering
- [ ] **11.4 [Supervisor] Category tabs** - Click "Groups", "Clients", "Experts" tabs, verify filtering
- [ ] **11.5 [Supervisor] Click room** - Click on a chat room, verify it navigates to chat detail with messages
- [ ] **11.6 [Supervisor] Send file in chat** - Upload a file in chat, verify it sends and shows

---

## PHASE 12: Doer Project Workspace Deep Test

### TODO List

- [ ] **12.1 [Doer] Details tab** - Open project, verify title, status, brief, requirements load
- [ ] **12.2 [Doer] Reference files** - Check if project files from user are downloadable
- [ ] **12.3 [Doer] Submit tab** - Check deliverable upload and submit buttons
- [ ] **12.4 [Doer] Chat tab** - Verify chat loads with messages, unread badge is accurate
- [ ] **12.5 [Doer] Google Docs link** - Verify live doc link is displayed and clickable
- [ ] **12.6 [Doer] Time remaining** - Verify countdown timer shows correct time to deadline

---

## PHASE 13: Admin Panel Deep Test

### TODO List

#### Dashboard
- [ ] **13.1 Dashboard loads** - Verify summary cards show correct counts (users, projects, revenue)
- [ ] **13.2 Charts render** - User growth chart and revenue chart display data

#### User Management
- [ ] **13.3 Users list** - Go to `/users`, verify list loads with search and filters
- [ ] **13.4 User detail** - Click a user, verify profile, projects, wallet info
- [ ] **13.5 Suspend user** - Test suspend action (if safe to test)

#### Project Management
- [ ] **13.6 Projects list** - Go to `/projects`, verify all projects with correct statuses
- [ ] **13.7 Project detail** - Click a project, verify full info (users, supervisor, doer, timeline, files)
- [ ] **13.8 Status history** - Verify project status timeline shows all changes

#### People Management
- [ ] **13.9 Supervisors list** - Go to `/supervisors`, verify list with metrics
- [ ] **13.10 Supervisor detail** - Click supervisor, verify stats and projects
- [ ] **13.11 Doers list** - Go to `/doers`, verify list with metrics
- [ ] **13.12 Doer detail** - Click doer, verify stats and tasks

#### Applications
- [ ] **13.13 Applications page** - Go to `/applications`, verify pending/approved/rejected apps
- [ ] **13.14 Filter by role** - Filter by doer/supervisor
- [ ] **13.15 Approve/reject** - Test approve/reject workflow (if test applicants exist)

#### Messages & Chat Monitoring
- [ ] **13.16 Messages page** - Go to `/messages`, verify chat room list with stats
- [ ] **13.17 Room stats** - Verify total rooms, active, suspended, message counts

#### Wallets & Payments
- [ ] **13.18 Wallets page** - Go to `/wallets`, verify financial summary
- [ ] **13.19 Revenue chart** - Verify 90-day revenue visualization
- [ ] **13.20 Transactions table** - Verify transactions with filters (type, status)

#### Support & Tickets
- [ ] **13.21 Support page** - Go to `/support`, verify ticket list
- [ ] **13.22 Ticket detail** - Click a ticket, verify conversation thread
- [ ] **13.23 Reply to ticket** - Test replying to a support ticket

#### Content & Tools
- [ ] **13.24 Moderation** - Go to `/moderation`, check for flagged content
- [ ] **13.25 Banners** - Go to `/banners`, verify banner list and create form
- [ ] **13.26 Colleges** - Go to `/colleges`, verify college list
- [ ] **13.27 Learning** - Go to `/learning`, verify resource list

#### Analytics & Reports
- [ ] **13.28 Analytics** - Go to `/analytics`, verify KPIs and charts load
- [ ] **13.29 Reports** - Go to `/reports`, verify summary stats and breakdowns

#### Settings
- [ ] **13.30 Settings page** - Go to `/settings`, verify form loads with current values

---

## PHASE 14: Edge Cases & Error Handling

### TODO List

- [ ] **14.1 Empty states** - Create a fresh account, verify empty state messages on projects, chat, notifications
- [ ] **14.2 Invalid URLs** - Navigate to non-existent project/chat IDs, verify error handling
- [ ] **14.3 Session expiry** - Let token expire, verify redirect to login
- [ ] **14.4 Network error** - Disconnect API, verify error messages show gracefully
- [ ] **14.5 Concurrent access** - Open same chat room on two platforms, send messages simultaneously

---

## Execution Order (Parallel Flow)

```
Timeline:
========

Step 1: Login all 4 platforms simultaneously (Phase 1)
   |
Step 2: [User] Create project  ->  [Admin] Observe new project
   |
Step 3: [Supervisor] Claim + Quote  ->  [User] See quote notification
   |
Step 4: [User] Pay for project  ->  [Supervisor] See payment notification
   |                                  [Admin] See transaction
   |
Step 5: [Supervisor] Assign doer  ->  [Doer] See assignment notification
   |
Step 6: [Doer] Start project  ->  [Supervisor] See status change
   |                               [User] See status change
   |
Step 7: [Doer] Add live doc  ->  [Supervisor + User] See notification
   |
Step 8: [Doer] Chat message  ->  [Supervisor] Approve  ->  [User] See message
         [User] Reply        ->  [Supervisor + Doer] See reply
         [Supervisor] Send   ->  [User + Doer] See message
   |
Step 9: [Doer] Submit work  ->  [Supervisor] QC Review  ->  [User] Delivery
   |
Step 10: Verify all notifications, earnings, wallets, admin panel
```
