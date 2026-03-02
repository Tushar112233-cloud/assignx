# AssignX Platform - QA Test Document (Part 2)

**Platforms Covered:** Doer App (Flutter Mobile), Supervisor App (Flutter Mobile), Admin Web (Next.js), User Web (Next.js), Doer Web (Next.js), Supervisor Web (Next.js)

**Document Version:** 2.0
**Date:** 2026-02-25
**Test ID Convention:**
- DA = Doer App, SA = Supervisor App, AW = Admin Web, UW = User Web, DW = Doer Web, SW = Supervisor Web
- E2E = End-to-End Cross-Platform, NF = Non-Functional

**Priority Legend:**
- **P1** = Critical (blocks core functionality, must pass before release)
- **P2** = Major (significant feature, should pass before release)
- **P3** = Minor (cosmetic, edge case, or enhancement)

---

## 3. DOER APP (Flutter Mobile) - Test Cases

### 3.1 Onboarding and Registration

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| DA-ONB-001 | Splash Screen | Verify splash screen renders correctly | 1. Launch the Doer app for the first time. 2. Observe the splash screen. | Splash screen displays with white/dark blue background, centered AssignX logo, and smooth transition to next screen within 2-3 seconds. | P1 |
| DA-ONB-002 | Splash Screen | Verify splash auto-navigates for unauthenticated users | 1. Clear app data. 2. Launch the app. 3. Wait for splash to complete. | App navigates to OnboardingScreen (carousel) after splash animation completes. | P1 |
| DA-ONB-003 | Splash Screen | Verify splash auto-navigates for authenticated users | 1. Log in, then force-close the app. 2. Relaunch the app. | App skips onboarding and navigates to ActivationGateScreen (if not activated) or DashboardScreen (if fully activated). | P1 |
| DA-ONB-004 | Onboarding Carousel | Verify 4-slide carousel renders | 1. Launch app as unauthenticated user. 2. Observe the onboarding screen. | Four slides display in order: "Countless Opportunities" (blue), "Small Tasks, Big Rewards" (green), "Supervisor Support (24x7)" (amber), "Learn While You Earn" (purple). Each slide has an icon, title, and subtitle. | P2 |
| DA-ONB-005 | Onboarding Carousel | Verify swipe navigation between slides | 1. On the onboarding screen, swipe left. 2. Repeat to traverse all 4 slides. 3. Swipe right to go back. | Slides transition smoothly with page indicator (ExpandingDots) updating to reflect the current page index. | P2 |
| DA-ONB-006 | Onboarding Carousel | Verify Skip button bypasses onboarding | 1. On any onboarding slide, tap the "Skip" button. | App navigates directly to the RegisterScreen. | P2 |
| DA-ONB-007 | Onboarding Carousel | Verify Next/Get Started button logic | 1. On slides 1-3, tap the primary button. 2. On slide 4, tap the primary button. | Slides 1-3: Button text reads "Next" and advances to the next slide. Slide 4: Button text reads "Get Started" and navigates to RegisterScreen. | P2 |
| DA-ONB-008 | Onboarding Carousel | Verify Sign In link for existing users | 1. On the onboarding screen, tap the "Already have an account? Sign In" text. | App navigates to LoginScreen. | P2 |
| DA-ONB-009 | Registration Form | Verify registration form fields render | 1. Navigate to the RegisterScreen. 2. Observe all form fields. | Form displays: Full Name field, Email field, Phone Number field, Password field (with visibility toggle), and "I agree to Terms" checkbox. | P1 |
| DA-ONB-010 | Registration Form | Verify Full Name validation | 1. Leave Full Name empty and submit. 2. Enter a single character and submit. 3. Enter a valid name (2+ characters). | Empty: Shows "Full name is required" error. Single char: Shows "Name must be at least 2 characters" error. Valid name: No validation error. | P1 |
| DA-ONB-011 | Registration Form | Verify Email validation | 1. Leave email empty and submit. 2. Enter "invalid-email" and submit. 3. Enter "user@example.com". | Empty: Shows "Email is required" error. Invalid format: Shows "Enter a valid email" error. Valid email: No validation error. | P1 |
| DA-ONB-012 | Registration Form | Verify Phone Number with OTP verification | 1. Enter a valid phone number. 2. Tap "Send OTP". 3. Enter correct OTP. 4. Enter incorrect OTP. | Valid phone: OTP is sent and a 6-digit input appears. Correct OTP: Phone verified with green checkmark. Incorrect OTP: Shows "Invalid OTP" error with retry option. | P1 |
| DA-ONB-013 | Registration Form | Verify Password validation and visibility toggle | 1. Enter password less than 8 characters. 2. Enter password without uppercase. 3. Enter valid strong password. 4. Tap eye icon to toggle visibility. | Weak passwords show specific validation errors. Strong password passes. Eye icon toggles between obscured and visible text. | P1 |
| DA-ONB-014 | Terms Agreement | Verify terms checkbox is required | 1. Fill all fields correctly. 2. Leave the terms checkbox unchecked. 3. Tap Register. | Registration is blocked. Error message indicates terms must be accepted. | P1 |
| DA-ONB-015 | Terms Agreement | Verify terms link opens policy | 1. Tap the "Terms & Conditions" link text. | Terms and Conditions document opens in a modal or webview. | P3 |
| DA-ONB-016 | Registration | Verify successful registration flow | 1. Fill all fields with valid data. 2. Verify phone via OTP. 3. Accept terms. 4. Tap Register. | Loading indicator appears. On success, user is navigated to ProfileSetupScreen. Success toast or snackbar is shown. | P1 |
| DA-ONB-017 | Registration | Verify duplicate email handling | 1. Register with an email that already exists in the system. | Error message: "An account with this email already exists" or equivalent Supabase auth error. | P1 |
| DA-ONB-018 | Profile Setup | Verify 3-step wizard renders | 1. After registration, observe the ProfileSetupScreen. | Screen shows a StepProgressBar with 3 steps (Education, Skills, Experience), current step highlighted, and percentage indicator. | P1 |
| DA-ONB-019 | Profile Setup - Step 1 | Verify Qualification dropdown | 1. On Step 1 (Education), tap the Qualification dropdown. 2. Select "High School". 3. Change to "Bachelor's Degree". 4. Verify all options: High School, Diploma, Bachelor's, Master's, PhD. | Dropdown opens with all qualification levels. Selected value persists and displays correctly. | P2 |
| DA-ONB-020 | Profile Setup - Step 1 | Verify University Name input | 1. On Step 1, enter a university name. 2. Leave it empty and proceed. | University name field accepts text input. Field is optional and does not block progression. | P3 |
| DA-ONB-021 | Profile Setup - Step 2 | Verify Areas of Interest ChipSelector | 1. On Step 2 (Skills), observe the subject area chips. 2. Select "IT/Coding". 3. Select 4 more areas. 4. Try to select a 6th area. | ChipSelector displays: IT/Coding, Content Writing, Graphic Design, Data Entry, Management, Science/Math. Maximum 5 selections enforced. 6th selection is blocked or deselects the oldest. | P1 |
| DA-ONB-022 | Profile Setup - Step 2 | Verify Specific Skills ChipSelector | 1. After selecting subject areas, observe the skills chips that appear. 2. Select multiple skills. 3. Try to exceed 8 skills. | Skills chips dynamically populate based on selected areas. Maximum 8 skills enforced. Chip visual shows selected state (filled color). | P1 |
| DA-ONB-023 | Profile Setup - Step 3 | Verify ExperienceSlider widget | 1. On Step 3 (Experience), observe the experience slider. 2. Drag slider to "Beginner". 3. Drag to "Intermediate". 4. Drag to "Pro". | Slider displays three levels with labels. Slider snaps to discrete positions. Visual feedback (icon, color, description) updates per level. | P2 |
| DA-ONB-024 | Profile Setup - Step 3 | Verify profile summary before submission | 1. On Step 3, review the summary section. | Summary displays all selected values: Qualification, University, Areas, Skills, and Experience Level. | P2 |
| DA-ONB-025 | Profile Setup | Verify step navigation (Back/Next) | 1. On Step 2, tap Back. 2. On Step 1, tap Next. 3. On Step 3, tap "Complete Setup". | Back navigates to previous step preserving data. Next validates current step and advances. Complete Setup submits the profile. | P1 |
| DA-ONB-026 | Profile Setup | Verify form validation per step | 1. On Step 1, do not select qualification and tap Next. 2. On Step 2, do not select any area and tap Next. | Step 1: Error "Please select your qualification". Step 2: Error "Please select at least one area". Progression is blocked. | P1 |
| DA-ONB-027 | Profile Setup | Verify successful profile submission | 1. Complete all 3 steps with valid data. 2. Tap "Complete Setup". | Loading indicator appears. Profile is created via AuthProvider.setupDoerProfile. User is navigated to ActivationGateScreen. | P1 |

### 3.2 Activation Flow / Gatekeeper

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| DA-ACT-001 | Activation Gate UI | Verify activation gate screen renders with 3-step stepper | 1. Log in as a user who has completed profile setup but not activation. 2. Observe the ActivationGateScreen. | Screen displays ActivationStepper with 3 steps: Training, Quiz, Bank Details. Dashboard is locked. Current step is highlighted. Info section explains activation importance. | P1 |
| DA-ACT-002 | Activation Gate UI | Verify locked steps cannot be accessed | 1. On the activation gate, try tapping Step 2 (Quiz) without completing Step 1. 2. Try tapping Step 3 (Bank Details). | Locked steps show a lock icon or grey/disabled state. Tapping a locked step shows no navigation or displays "Complete previous step first" message. | P1 |
| DA-ACT-003 | Step 1 - Training Module | Verify training content renders | 1. Tap Step 1 (Training) on the activation gate. 2. Observe the TrainingScreen. | Training screen displays a carousel or list of training modules: Quality Standards, No Plagiarism Policy, Deadline Adherence, Tools & Resources. Each module contains video/PDF content. | P1 |
| DA-ACT-004 | Step 1 - Training Module | Verify video/PDF playback | 1. On the TrainingScreen, tap a video module. 2. Tap a PDF module. | Video plays with standard controls (play, pause, seek). PDF renders with scroll capability. Content loads without errors. | P2 |
| DA-ACT-005 | Step 1 - Training Module | Verify "Mark as Complete" button | 1. View all training modules. 2. Tap "Mark as Complete" after viewing all content. | Button is enabled only after all modules are viewed. On tap, Step 1 status changes to completed (green checkmark). Step 2 (Quiz) becomes unlocked. | P1 |
| DA-ACT-006 | Step 1 - Training Module | Verify training progress percentage | 1. View 2 of 4 training modules. 2. Return to activation gate. | Activation gate displays "50%" progress for Step 1. Progress bar reflects partial completion. | P2 |
| DA-ACT-007 | Step 2 - Interview Quiz | Verify quiz screen renders | 1. Complete Step 1 (Training). 2. Tap Step 2 (Quiz). | QuizScreen displays 5-10 multiple-choice questions, each with 4 answer options. Questions relate to training content. Progress indicator shows current question number. | P1 |
| DA-ACT-008 | Step 2 - Interview Quiz | Verify quiz pass logic | 1. Answer all questions correctly (or achieve passing threshold). 2. Submit the quiz. | Success screen displays with congratulatory message. Step 2 marked as complete. Step 3 (Bank Details) becomes unlocked. "Proceed" button navigates to activation gate. | P1 |
| DA-ACT-009 | Step 2 - Interview Quiz | Verify quiz fail logic | 1. Answer most questions incorrectly (below passing threshold). 2. Submit the quiz. | Fail screen displays with score and "Review & Retry" option. Step 2 remains incomplete. User can review correct answers and re-attempt. | P1 |
| DA-ACT-010 | Step 2 - Interview Quiz | Verify quiz re-attempt after failure | 1. Fail the quiz. 2. Tap "Review & Retry". 3. Retake the quiz. | Quiz resets with same or shuffled questions. User can attempt again. On pass, Step 2 completes normally. | P2 |
| DA-ACT-011 | Step 3 - Bank Details | Verify bank details form renders | 1. Complete Steps 1 and 2. 2. Tap Step 3 (Bank Details). | BankDetailsScreen displays fields: Account Holder Name, Account Number, Confirm Account Number, IFSC Code, UPI ID (optional). | P1 |
| DA-ACT-012 | Step 3 - Bank Details | Verify bank details validation | 1. Leave Account Holder empty and submit. 2. Enter mismatched account numbers. 3. Enter invalid IFSC format. 4. Enter all valid data. | Empty fields: Shows required field errors. Mismatched accounts: Shows "Account numbers do not match" error. Invalid IFSC: Shows format error. Valid data: Form submits successfully. | P1 |
| DA-ACT-013 | Step 3 - Bank Details | Verify successful bank details submission | 1. Fill all fields with valid data. 2. Tap Submit. | Loading indicator appears. Bank details are saved. Step 3 marked as complete. | P1 |
| DA-ACT-014 | Finish Setup | Verify "Finish Setup" CTA after all steps | 1. Complete all 3 activation steps. 2. Return to ActivationGateScreen. | All 3 steps show green checkmarks. "Finish Setup" or "Go to Dashboard" CTA button appears. Tapping it redirects to DashboardScreen. | P1 |
| DA-ACT-015 | Auto-Redirect | Verify auto-redirect when fully activated | 1. Complete all activation steps. 2. Force-close and relaunch the app. | App skips ActivationGateScreen entirely and navigates directly to DashboardScreen. ActivationProvider reports isFullyActivated = true. | P1 |
| DA-ACT-016 | Sign Out | Verify sign out from activation gate | 1. On the ActivationGateScreen, tap the "Sign Out" option. | User is signed out and returned to OnboardingScreen. Auth tokens are cleared. | P2 |

### 3.3 Main Dashboard

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| DA-DASH-001 | Dashboard Rendering | Verify dashboard screen renders after activation | 1. Log in as a fully activated doer. 2. Observe the DashboardScreen. | Dashboard displays: Welcome header with gradient, Quick Stats row, "Assigned Tasks" section, and "Open Pool" section. RefreshIndicator is present. | P1 |
| DA-DASH-002 | Top Header | Verify logo, notification bell, and hamburger menu | 1. On the dashboard, observe the top header area. | Header displays AssignX logo/branding, a notification bell icon (with unread badge if applicable), and a hamburger menu icon on the left. | P2 |
| DA-DASH-003 | Hamburger Menu | Verify app drawer opens and displays content | 1. Tap the hamburger menu icon. 2. Observe the AppDrawer. | Drawer slides in from the left. Displays: User avatar, name, email. Availability switch. Menu items: My Profile, Reviews, Statistics, Help & Support, Settings. | P1 |
| DA-DASH-004 | Availability Toggle | Verify availability switch in drawer | 1. Open the drawer. 2. Toggle the availability switch from Available to Busy. 3. Toggle back. | Switch toggles between "Available" (green) and "Busy" (red/orange) states. State persists after closing and reopening drawer. Backend is updated with new availability status. | P1 |
| DA-DASH-005 | Sidebar Menu - My Profile | Verify navigation to My Profile | 1. Open drawer. 2. Tap "My Profile". | Navigates to ProfileScreen displaying user info, scorecard, qualifications, skills. | P2 |
| DA-DASH-006 | Sidebar Menu - Reviews | Verify navigation to Reviews | 1. Open drawer. 2. Tap "Reviews". | Navigates to ReviewsScreen displaying user ratings and review history. | P2 |
| DA-DASH-007 | Sidebar Menu - Statistics | Verify navigation to Statistics | 1. Open drawer. 2. Tap "Statistics". | Navigates to StatisticsScreen with Performance Hero Banner, Quick Stats Grid, Interactive Earnings Chart, Rating Breakdown, Project Distribution, Top Subjects, Monthly Heatmap, and Insights panel. | P2 |
| DA-DASH-008 | Sidebar Menu - Help & Support | Verify navigation to Support | 1. Open drawer. 2. Tap "Help & Support". | Navigates to SupportScreen. | P3 |
| DA-DASH-009 | Sidebar Menu - Settings | Verify navigation to Settings | 1. Open drawer. 2. Tap "Settings". | Navigates to SettingsScreen with notification, appearance, privacy, and account options. | P3 |
| DA-DASH-010 | Quick Stats | Verify quick stats cards display | 1. On the dashboard, observe the quick stats row below the welcome header. | Displays 4 stat cards: Active Projects (count), Completed (count), Pending Earnings (amount in INR), Rating (star value). Values match backend data from doerStatsProvider. | P1 |
| DA-DASH-011 | Assigned Tasks Section | Verify "Assigned to Me" tasks display | 1. As a doer with assigned projects, observe the "Assigned Tasks" section. | Section header shows "Assigned Tasks" with count badge. Each project shows an AssignedTaskCard with: Title, Urgency Badge, Price, Deadline, and action button. "See All" link appears if more than 3 tasks. | P1 |
| DA-DASH-012 | Open Pool Section | Verify "Open Pool" tasks display | 1. Scroll down to the "Open Pool" section on the dashboard. | Section displays TaskPoolCards for available projects. Each card shows: Title, Subject, Price, Deadline, and "Accept" button. Empty state shown if no tasks available. | P1 |
| DA-DASH-013 | Project Card | Verify project card details | 1. Observe any project card on the dashboard. | Card displays: Project title, Urgency badge (if applicable), Price in INR, Deadline date/time. Tap navigates to ProjectDetailScreen. | P1 |
| DA-DASH-014 | Accept Task | Verify accepting a task from Open Pool | 1. In the Open Pool, tap "Accept" on a task card. 2. Confirm acceptance. | Confirmation dialog appears. On confirm: Task moves to "Assigned to Me". Open Pool refreshes. Success message shown. | P1 |
| DA-DASH-015 | Urgency Badge | Verify urgency badge for tight deadlines | 1. Observe a project with a deadline less than 6 hours away. | Card displays a fire icon urgency badge in red/orange, visually distinguishing it from normal-deadline projects. | P2 |
| DA-DASH-016 | Pull-to-Refresh | Verify pull-to-refresh reloads dashboard | 1. Pull down on the dashboard scroll view. | RefreshIndicator animates. Dashboard data reloads from dashboardProvider.refresh(). Stats, assigned tasks, and open pool update with fresh data. | P2 |
| DA-DASH-017 | Empty States | Verify empty state for no assigned tasks | 1. Log in as a doer with zero assigned projects. | "Assigned Tasks" section shows EmptyAssignedTasks widget with appropriate illustration and message encouraging the user to accept tasks. | P2 |
| DA-DASH-018 | Empty States | Verify empty state for no open pool tasks | 1. Log in when no tasks are in the open pool. | "Open Pool" section shows empty state message indicating no tasks are currently available. | P2 |
| DA-DASH-019 | Notification Bell | Verify notification bell tap | 1. Tap the notification bell icon in the header. | Navigates to NotificationsScreen. If unread notifications exist, bell displays a count badge. | P2 |
| DA-DASH-020 | Statistics Page | Verify statistics screen content | 1. Navigate to Statistics from drawer. 2. Observe all sections. | Screen displays: Performance Hero Banner with period selector, Quick Stats Grid (4 cards), Interactive Earnings Chart (line chart with toggle), Rating Breakdown (Quality/Timeliness/Communication bars), Project Distribution (donut chart), Top Subjects ranking, Monthly Heatmap (12-month grid), Insights and Goals panel. | P2 |
| DA-DASH-021 | Reviews Page | Verify reviews screen content | 1. Navigate to Reviews from drawer. | Screen displays past reviews with ratings, reviewer info, and review text. Overall rating summary shown at top. | P2 |
| DA-DASH-022 | Loading State | Verify loading indicator on dashboard | 1. Navigate to dashboard with slow network. | LoadingOverlay displays while dashboardState.isLoading is true. Content renders after data loads. | P2 |

### 3.4 Active Projects / Workspace

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| DA-PROJ-001 | Projects Screen | Verify 3-tab layout renders | 1. Navigate to MyProjectsScreen. 2. Observe the tab bar. | Screen displays 3 tabs: "Active" (WIP), "Under Review" (QC), "Completed". Default tab is "Active". | P1 |
| DA-PROJ-002 | Active Tab | Verify active projects display with "Open Workspace" button | 1. On the Active tab, observe a project card. | Each active project card displays: Title, deadline, status, and an "Open Workspace" button. Tapping "Open Workspace" navigates to WorkspaceScreen. | P1 |
| DA-PROJ-003 | Under Review Tab | Verify "QC in Progress" status display | 1. Tap the "Under Review" tab. 2. Observe projects. | Projects submitted for QC display "QC in Progress" status badge. No workspace edit actions are available. Supervisor review is pending. | P1 |
| DA-PROJ-004 | Completed Tab | Verify completed project statuses | 1. Tap the "Completed" tab. 2. Observe project cards. | Completed projects display "Paid" or "Approved" status badges. Project history is accessible. No further actions required. | P2 |
| DA-PROJ-005 | Revision Requested | Verify revision flag with red highlight | 1. As a doer with a revision-requested project, observe the Active tab. | Revision-requested projects display a red highlight or badge reading "Revision Requested". Revision notes from supervisor are accessible. | P1 |
| DA-PROJ-006 | File Upload | Verify file upload for work submission | 1. Open the workspace for an active project. 2. Tap the file upload area. 3. Select a file. 4. Submit. | File picker opens. Selected file displays with name and size. Upload progress indicator shown. File is attached to the project submission. | P1 |
| DA-PROJ-007 | Chat with Supervisor | Verify chat functionality from workspace | 1. In the workspace or project detail, tap the "Chat" button. | ChatScreen opens with the assigned supervisor. Message input field and send button are present. Previous messages load. | P1 |
| DA-PROJ-008 | Deadline Display | Verify countdown timer for deadlines | 1. Observe the deadline display on any active project. | Deadline shows as a countdown timer (e.g., "2d 5h 30m remaining"). Timer updates in real-time or near-real-time. Urgency color changes as deadline approaches. | P2 |
| DA-PROJ-009 | Workspace View | Verify workspace screen content | 1. Tap "Open Workspace" on an active project. | WorkspaceScreen displays: Project details section, chat access, file upload area, work notes input, and submission controls. | P1 |

### 3.5 Project Detail and Workspace

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| DA-DET-001 | Project Title | Verify project title with urgency badge | 1. Navigate to ProjectDetailScreen for a project with tight deadline. | Title displays prominently with urgency badge (fire icon) if deadline is less than 6 hours. | P2 |
| DA-DET-002 | Info Chips | Verify info chips display | 1. On the project detail screen, observe the info chips row. | Chips display: Subject/category, Price (INR), Word count, Reference style (APA/Harvard/etc.), Current status. | P2 |
| DA-DET-003 | Deadline Countdown | Verify deadline countdown timer | 1. On the project detail, observe the deadline section. | Countdown timer shows remaining time. Updates dynamically. Visual urgency indicator (color/icon) for tight deadlines. | P2 |
| DA-DET-004 | Full Description | Verify full project description display | 1. Scroll to the description section. | Complete project description text renders with proper formatting. Long text is scrollable. | P2 |
| DA-DET-005 | Requirements List | Verify requirements checklist | 1. Observe the requirements section on project detail. | Requirements display as a list or checklist. Each item is clearly readable. Checklist items may be checkable for doer tracking. | P2 |
| DA-DET-006 | Supervisor Contact | Verify supervisor contact info display | 1. Observe the supervisor info section. | Supervisor name, avatar, and rating are displayed. Direct contact is facilitated via in-app chat only (no personal details exposed). | P2 |
| DA-DET-007 | Chat Button | Verify chat button navigates to chat | 1. Tap the "Chat" button on project detail. | Navigates to ChatScreen with the supervisor for this specific project. Chat context (project ID) is maintained. | P1 |
| DA-DET-008 | Workspace Button | Verify workspace button opens workspace | 1. Tap the "Workspace" button on project detail. | Navigates to WorkspaceScreen with full editing and submission capabilities. | P1 |
| DA-DET-009 | File Upload | Verify deliverables upload | 1. In the workspace, tap file upload. 2. Select one or more files. 3. Observe upload progress. | File picker supports common formats (PDF, DOCX, PPTX, images). Upload progress bar shown. Files appear in the deliverables list after upload. | P1 |
| DA-DET-010 | Work Notes | Verify work notes input | 1. In the workspace, enter notes in the work notes field. 2. Save or submit. | Text area accepts multiline input. Notes are saved with the submission. Notes persist across screen navigations. | P3 |
| DA-DET-011 | Submission Confirmation | Verify submission confirmation dialog | 1. Upload deliverables. 2. Tap "Submit for Review". | Confirmation dialog appears with summary of uploaded files. On confirm: Project status changes to "Under Review". Success message shown. | P1 |
| DA-DET-012 | Revision Notes | Verify revision notes from supervisor | 1. On a project with revision requested status, view the project detail. | Revision notes from supervisor are displayed prominently (highlighted section). Doer can read the feedback and re-submit work. | P1 |
| DA-DET-013 | Revision Screen | Verify revision screen workflow | 1. On a revision-requested project, tap to open the revision screen. | RevisionScreen shows supervisor feedback, original submission, and an updated upload area for resubmission. | P1 |

### 3.6 Resources and Tools

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| DA-RES-001 | Resources Hub | Verify resources hub screen layout | 1. Navigate to ResourcesHubScreen from the drawer. | Screen displays: Quick Stats section (training progress, AI checks count, citations count), Writing Tools section, Learning & Development section, and Additional Resources section in a grid layout. | P2 |
| DA-RES-002 | Training Center | Verify training center access | 1. Tap on "Training Center" in the resources hub. | TrainingCenterScreen opens with previously viewed training modules. Videos can be re-watched. Progress bar shows completion status. | P2 |
| DA-RES-003 | AI Report Generator | Verify AI checker screen | 1. Tap on "AI Content Checker" in the resources hub. | AICheckerScreen opens. User can paste or upload text for AI detection analysis. Results display with confidence score. Usage count badge updates. | P2 |
| DA-RES-004 | Citation Builder | Verify citation builder functionality | 1. Tap on "Citation Builder" in the resources hub. 2. Enter a URL. 3. Select reference style (APA or Harvard). 4. Generate citation. | CitationBuilderScreen opens. URL input field accepts valid URLs. Style selector allows APA/Harvard selection. Generated citation displays formatted text with copy-to-clipboard option. | P2 |
| DA-RES-005 | Format Templates | Verify format templates download | 1. Tap on "Format Templates" in the resources hub. | FormatTemplatesScreen displays downloadable templates: Word documents, PowerPoint templates. Tap to download. Templates open in appropriate viewer. | P3 |
| DA-RES-006 | Resources Grid Layout | Verify grid layout responsiveness | 1. Observe the resources hub on different screen sizes. | Tool cards display in a responsive grid layout. Cards are evenly spaced with appropriate icons, titles, and usage badges. | P3 |
| DA-RES-007 | Quick Stats | Verify resource usage statistics | 1. Use AI checker and citation builder several times. 2. Return to resources hub. | Quick stats update: Training progress shows correct percentage, AI checks count reflects actual usage, Citations count matches history. | P3 |

### 3.7 Community / Pro Network

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| DA-COM-001 | Community Feed | Verify community screen renders | 1. Navigate to CommunityScreen. | Community feed displays a list of posts with author info, content preview, engagement metrics (likes, comments). Pull-to-refresh available. | P2 |
| DA-COM-002 | Create Post | Verify post creation flow | 1. Tap the "Create Post" button. 2. Enter post content on CreatePostScreen. 3. Submit. | Post creation form opens with text input, optional image upload, and category selection. On submit: Post appears in the feed. Success message shown. | P2 |
| DA-COM-003 | Like/Save/Comment | Verify engagement actions | 1. On a post card, tap the like button. 2. Tap the save/bookmark button. 3. Tap to comment. | Like: Heart icon fills, count increments. Save: Bookmark icon fills, post saved. Comment: Opens PostDetailScreen with comment input. | P2 |
| DA-COM-004 | Category Filter Tabs | Verify filter tab functionality | 1. On the community screen, tap different category filter tabs. | Feed filters to show only posts in the selected category. "All" tab shows all posts. Tabs scroll horizontally if many categories. | P3 |
| DA-COM-005 | Search | Verify search functionality | 1. Tap the search icon/bar. 2. Enter a search query. | Search results filter posts by keyword match in title or content. Results update as user types or on submit. | P3 |
| DA-COM-006 | Report Posts | Verify post reporting flow | 1. On a post, tap the report/flag option. 2. Select a reason. 3. Submit report. | Report dialog opens with reason options. On submit: Confirmation message shown. Post is flagged for admin review. | P3 |
| DA-COM-007 | Saved Posts | Verify saved posts screen | 1. Navigate to SavedPostsScreen. | Screen displays all posts the user has saved/bookmarked. Posts can be unsaved. Tap navigates to post detail. | P3 |
| DA-COM-008 | Post Detail | Verify post detail screen | 1. Tap on a post card in the feed. | PostDetailScreen shows full post content, author details, all comments, and engagement actions. Comment input at bottom. | P2 |

### 3.8 Profile and Earnings

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| DA-PROF-001 | Profile Scorecard | Verify scorecard displays | 1. Navigate to ProfileScreen. 2. Observe the scorecard section. | Scorecard shows: Active Assignments count, Completed count, Total Earnings (INR), Overall Rating (stars). Values match backend data. | P1 |
| DA-PROF-002 | Edit Profile | Verify profile editing | 1. On ProfileScreen, tap "Edit Profile". 2. Modify qualifications and skills. 3. Save changes. | EditProfileScreen opens with current values pre-filled. Changes can be made to qualifications, skills, and other editable fields. On save: Profile updates. Success message shown. | P2 |
| DA-PROF-003 | Payment History | Verify payment history display | 1. Navigate to PaymentHistoryScreen. | Screen displays a chronological list of all payment transactions: amounts, dates, project references, and statuses (Paid, Pending, Processing). | P1 |
| DA-PROF-004 | Bank Details Management | Verify bank details view and edit | 1. Navigate to bank details section. 2. View current bank info. 3. Edit bank details. | Current bank details display (partially masked account number). Edit option allows updating Account Holder, Account Number, IFSC, UPI. Changes require confirmation. | P1 |
| DA-PROF-005 | Contact Support | Verify support contact access | 1. From profile or support screen, access contact support. | Support options display: FAQ, email support, in-app ticket creation. Contact methods are functional. | P3 |
| DA-PROF-006 | Log Out | Verify logout from profile | 1. On profile or settings, tap "Log Out". 2. Confirm. | Confirmation dialog appears. On confirm: User session is cleared. App navigates to OnboardingScreen. Auth tokens are removed. | P1 |
| DA-PROF-007 | Request Payout | Verify payout request flow | 1. On the earnings section, tap "Request Payout" or "Withdraw". 2. Enter amount. 3. Confirm. | Payout request form shows available balance. Amount field validates against available balance. On confirm: Payout request is submitted. Status shows "Processing". | P1 |
| DA-PROF-008 | Pending Payments | Verify pending payments display | 1. Observe the earnings section for pending payments. | Pending payments list shows: Amount, associated project, expected payment date, and status. Clearly distinguished from completed payments. | P2 |
| DA-PROF-009 | Earnings Graph | Verify earnings visualization | 1. Navigate to the earnings or statistics section. 2. Observe the earnings graph. | Interactive line or bar chart displays earnings over time. Period selector allows switching between week/month/year views. Values match payment history. | P2 |
| DA-PROF-010 | Rating Breakdown | Verify rating breakdown display | 1. On the profile or reviews screen, observe rating breakdown. | Breakdown shows individual category ratings: Quality, Timeliness, Communication. Bar charts or star displays for each category. Overall average calculated correctly. | P2 |
| DA-PROF-011 | Skill Verification Status | Verify skill verification badges | 1. On the profile, observe skill tags. | Skills show verification status: Verified (green badge), Pending, or Unverified. Verified skills have a checkmark icon. | P3 |

### 3.9 Settings

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| DA-SET-001 | Notification Settings | Verify push notification toggle | 1. Navigate to SettingsScreen. 2. Toggle push notifications on/off. | Toggle switches between enabled and disabled states. Change persists after leaving and returning to settings. Backend notification preferences updated. | P2 |
| DA-SET-002 | Notification Settings | Verify email notification toggle | 1. Toggle email notifications on/off. | Toggle works independently of push notifications. State persists. | P2 |
| DA-SET-003 | Notification Settings | Verify project update notifications toggle | 1. Toggle project update notifications on/off. | User can control whether they receive notifications for project status changes. | P3 |
| DA-SET-004 | Appearance | Verify theme switching | 1. Under Appearance settings, select Light theme. 2. Select Dark theme. 3. Select System default. | App theme changes immediately. Light: White backgrounds, dark text. Dark: Dark backgrounds, light text. System: Follows device setting. | P2 |
| DA-SET-005 | Appearance | Verify language selection | 1. Under Language settings, select a different language. | App UI text updates to the selected language. Translation applies across all screens. | P3 |
| DA-SET-006 | Privacy Settings | Verify privacy options | 1. Navigate to Privacy settings. | Privacy options display: Profile visibility, data sharing preferences. Toggles function correctly. | P3 |
| DA-SET-007 | Account Settings | Verify account management options | 1. Navigate to Account settings. | Account options display: Change password, Update email, linked accounts. Each option navigates to appropriate screen. | P2 |
| DA-SET-008 | Log Out | Verify log out from settings | 1. In Settings, tap "Log Out". 2. Confirm the action. | User is logged out and returned to OnboardingScreen. All local data and tokens are cleared. | P1 |
| DA-SET-009 | Delete Account | Verify account deletion flow | 1. In Settings, tap "Delete Account". 2. Read the warning. 3. Confirm deletion. | Warning dialog explains data loss. Confirmation requires explicit action (e.g., type "DELETE"). On confirm: Account is deactivated/deleted. User is logged out. | P1 |

---

## 4. SUPERVISOR APP (Flutter Mobile) - Test Cases

### 4.1 Onboarding and Registration

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| SA-ONB-001 | Splash Screen | Verify splash screen with professional dark blue theme | 1. Launch the Supervisor app for the first time. 2. Observe the splash screen. | Splash displays with dark blue background, shield logo, professional tagline. Smooth transition within 2-3 seconds. | P1 |
| SA-ONB-002 | Splash Navigation | Verify splash auto-navigates correctly | 1. Launch as unauthenticated user. 2. Launch as authenticated but pending approval. 3. Launch as fully activated supervisor. | Unauthenticated: Navigates to OnboardingScreen. Pending: Navigates to ApplicationPendingScreen. Activated: Navigates to DashboardScreen. | P1 |
| SA-ONB-003 | Onboarding Slides | Verify 3 onboarding slides render | 1. As unauthenticated user, observe the onboarding carousel. | Three slides display showcasing the supervisor role value proposition. Skip and Next buttons present. Page indicator dots shown. | P2 |
| SA-ONB-004 | Step 1 - Basic Credentials | Verify registration wizard Step 1 | 1. Tap "Get Started" from onboarding. 2. Observe RegistrationWizardScreen Step 1. | Form displays: Full Name, Email, Phone with OTP verification, Password fields. All fields have validation. | P1 |
| SA-ONB-005 | Step 1 - Phone OTP | Verify phone number OTP verification | 1. Enter a valid phone number. 2. Tap "Send OTP". 3. Enter the received OTP. | OTP sent successfully. 6-digit input field appears. Correct OTP verifies phone with visual confirmation. Timer for resend. | P1 |
| SA-ONB-006 | Step 2 - Professional Profile | Verify professional profile form | 1. Complete Step 1. 2. Observe Step 2 fields. | Form displays: Qualification dropdown, Expertise multi-select chips, Years of Experience input, CV Upload button. All fields render correctly. | P1 |
| SA-ONB-007 | Step 2 - Expertise Multi-Select | Verify expertise area selection | 1. On Step 2, tap expertise chips. 2. Select multiple areas. | Multi-select chips allow selecting relevant expertise areas. Selected chips show filled/highlighted state. At least one area is required. | P1 |
| SA-ONB-008 | Step 2 - CV Upload | Verify CV upload functionality | 1. Tap the CV Upload button. 2. Select a PDF/DOC file. | File picker opens. Selected file name and size display. Upload progress shown. Accepted formats: PDF, DOC, DOCX. | P1 |
| SA-ONB-009 | Step 3 - Banking Setup | Verify bank details form | 1. Complete Step 2. 2. Observe Step 3 fields. | Form displays: Bank Name, Account Number, Confirm Account Number, IFSC Code, UPI ID (optional). Validation on all required fields. | P1 |
| SA-ONB-010 | Submit Application | Verify "Submit Application" CTA | 1. Complete all 3 steps. 2. Tap "Submit Application". | Loading indicator appears. Application is submitted to backend. User navigates to ApplicationPendingScreen. | P1 |
| SA-ONB-011 | Application Pending State | Verify pending approval screen | 1. After submitting application, observe the pending screen. | ApplicationPendingScreen displays: Status message indicating admin review is in progress. Estimated timeline. No access to dashboard features. Refresh option to check status. | P1 |
| SA-ONB-012 | Application Approved | Verify transition after admin approval | 1. Admin approves the supervisor application. 2. Supervisor opens the app. | App transitions from ApplicationPendingScreen to ActivationScreen (training phase). Push notification sent about approval. | P1 |
| SA-ONB-013 | CV Verification | Verify CV upload is stored for backend verification | 1. Upload a CV during registration. 2. Check admin panel for submitted applications. | CV file is accessible in the admin panel for the supervisor's application. File is stored securely via Supabase storage. | P2 |

### 4.2 Activation Phase

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| SA-ACT-001 | Activation Lock Screen | Verify activation lock with "Unlock Your Admin Rights" message | 1. Log in as an approved but not activated supervisor. | ActivationScreen displays with "Unlock Your Admin Rights" or similar message. Visual stepper shows activation steps. Dashboard features are locked. | P1 |
| SA-ACT-002 | Training Module | Verify training content (Videos/PDFs) | 1. On the activation screen, start training. | Training modules display: QC Process, Pricing Guidelines, Communication Standards. Each module has video or PDF content. Progress tracked per module. | P1 |
| SA-ACT-003 | Training Video Screen | Verify video playback in training | 1. Open a training video module. | TrainingVideoScreen renders video player with controls. Video plays, pauses, and seeks correctly. Completion is tracked. | P2 |
| SA-ACT-004 | Training Document Screen | Verify PDF document viewing | 1. Open a training PDF/document module. | TrainingDocumentScreen renders PDF with scroll. Document is readable. Completion is tracked when scrolled to end. | P2 |
| SA-ACT-005 | Mark Complete | Verify "Mark Complete" for training | 1. View all training modules. 2. Tap "Mark Complete". | Training step marked as complete. Next step (Supervisor Test) becomes unlocked. Visual indicator updates. | P1 |
| SA-ACT-006 | Supervisor Test | Verify 10 scenario-based questions | 1. Complete training. 2. Start the supervisor test on QuizScreen. | QuizScreen displays 10 scenario-based MCQ questions testing supervisor judgment. Questions cover real QC situations. Progress indicator shown. | P1 |
| SA-ACT-007 | Test Pass | Verify pass result | 1. Answer questions correctly to pass threshold. 2. Submit. | ActivationCompleteScreen displays with congratulatory welcome message. Account is fully activated. Dashboard access granted. | P1 |
| SA-ACT-008 | Test Fail | Verify fail result with retry | 1. Answer questions incorrectly to fail. 2. Submit. | Fail screen shows score. "Review & Retry" option available. User can re-study materials and retake. Step remains incomplete. | P1 |

### 4.3 Main Dashboard / Requests

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| SA-DASH-001 | Dashboard Rendering | Verify dashboard renders with all sections | 1. Log in as fully activated supervisor. 2. Observe DashboardScreen. | Dashboard displays: Greeting header with notification bell, KPI cards row, "New Requests" section (Section A), and "Ready to Assign" section (Section B). MenuDrawer accessible via hamburger. | P1 |
| SA-DASH-002 | Top Bar Greeting | Verify personalized greeting | 1. Observe the dashboard header (DashboardHeader). | Header shows: "Good Morning/Afternoon/Evening, [Name]". Notification bell icon with unread count badge. | P2 |
| SA-DASH-003 | Menu Drawer | Verify drawer content | 1. Tap hamburger icon to open MenuDrawer. | Drawer shows: Profile card (avatar, name, role). Availability toggle. Menu items: Dashboard, Projects, Doers, Users, Chat, Earnings, Resources, Support, Campus Connect, Settings. | P1 |
| SA-DASH-004 | Availability Toggle | Verify availability switch | 1. In the drawer, toggle availability on/off. | Switch toggles between Available (green) and Unavailable (grey/red). State persists. Backend updated. Affects visibility for project assignment. | P1 |
| SA-DASH-005 | Field Filter | Verify "My Field Only" filter chips | 1. On the dashboard, observe the FieldFilter horizontal chips. 2. Select a specific field/subject. 3. Select "All". | Horizontal scrollable chips display subject areas. Selecting a chip filters both New Requests and Ready to Assign sections. "All" shows everything. | P2 |
| SA-DASH-006 | Section A - New Requests | Verify new requests with "Analyze & Quote" button | 1. Observe the "New Requests" section. 2. Tap "Analyze & Quote" on a request card. | New requests display RequestCards with: Title, subject, deadline, urgency. "Analyze & Quote" button opens QuoteFormSheet bottom sheet. | P1 |
| SA-DASH-007 | Quote Form Sheet | Verify pricing form (user quote + doer payout) | 1. Tap "Analyze & Quote" on a new request. 2. Fill in the QuoteFormSheet. | Bottom sheet displays: Project summary, User Quote input (price for client), Doer Payout input (payment to expert), margin display, deadline confirmation. Submit button sends quote. | P1 |
| SA-DASH-008 | Section B - Ready to Assign | Verify paid requests with "Assign Doer" button | 1. Observe the "Ready to Assign" section. | Paid requests display with "PAID" badge and "Assign Doer" button. Cards show: Title, amount paid, deadline, subject. | P1 |
| SA-DASH-009 | Assign Doer Flow | Verify doer selection and assignment | 1. Tap "Assign Doer" on a paid request. 2. Observe the DoerSelectionSheet. 3. Select a doer. 4. Confirm. | DoerSelectionSheet opens with list of available experts. Each entry shows: Name, rating, skills, availability status, past stats. Selecting a doer and confirming assigns the project. Success message shown. | P1 |
| SA-DASH-010 | Doer Selection List | Verify doer list details | 1. In the DoerSelectionSheet, scroll through doers. | List displays: Avatar, name, star rating, relevant skills tags, availability indicator, completed projects count. Search/filter available. | P2 |
| SA-DASH-011 | KPI Cards | Verify KPI dashboard metrics | 1. Observe the KPI cards row at the top of the dashboard. | Four KPI cards display: New Requests (count), Ready to Assign (count), Pending QC (count), Earnings (amount in INR). Values match backend data. | P1 |
| SA-DASH-012 | FAB Quick Actions | Verify floating action button | 1. Tap the FAB on the dashboard. | FAB expands to show quick action options for common tasks (e.g., view all requests, check messages, view doers). | P3 |
| SA-DASH-013 | Doer Reviews Access | Verify accessing doer reviews from assignment | 1. In the DoerSelectionSheet, tap on a doer's rating or reviews link. | Doer's review history opens showing past supervisor reviews, ratings, and performance notes. | P2 |
| SA-DASH-014 | Pull-to-Refresh | Verify pull-to-refresh on dashboard | 1. Pull down on the dashboard. | Data reloads from dashboardProvider. KPI cards, new requests, and ready-to-assign sections update with fresh data. | P2 |

### 4.4 Projects Management

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| SA-PROJ-001 | Projects Screen | Verify 3-tab layout | 1. Navigate to ProjectsScreen. | Screen displays 3 tabs: "On Going", "For Review (QC)", "Completed". Default tab is "On Going". | P1 |
| SA-PROJ-002 | On Going Tab | Verify ongoing project cards | 1. On the "On Going" tab, observe project cards. | Each card shows: Project ID, Expert (Doer) name, Timer/deadline countdown, Chat access button, status indicator. | P1 |
| SA-PROJ-003 | For Review (QC) Tab | Verify QC review content | 1. Tap the "For Review" tab. 2. Observe submitted work. | Projects awaiting QC show: Expert's submitted files, project details, "Approve & Deliver" and "Reject/Revision" action buttons. | P1 |
| SA-PROJ-004 | Approve and Deliver | Verify approval action | 1. On a QC project, review the submitted work. 2. Tap "Approve & Deliver". 3. Confirm. | Confirmation dialog appears. On confirm: Project status changes to "Delivered". User is notified. Payment release process initiates. Project moves to Completed tab. | P1 |
| SA-PROJ-005 | Reject/Revision | Verify rejection with feedback | 1. On a QC project, tap "Reject" or "Request Revision". 2. Enter feedback notes. 3. Submit. | Feedback form appears with text input for revision notes. On submit: Project returns to "On Going" with revision flag. Doer receives notification with feedback. | P1 |
| SA-PROJ-006 | Completed Tab | Verify completed projects history | 1. Tap the "Completed" tab. | Completed projects display with: Final status (Delivered/Paid), completion date, earnings from project, expert name, client satisfaction rating. | P2 |
| SA-PROJ-007 | Unified Chat | Verify chat with both client and doer | 1. On a project, tap the chat button. | Chat interface opens with the ability to communicate with both the client (user) AND the assigned doer. Messages are separated by recipient context. | P1 |
| SA-PROJ-008 | Chat Monitoring | Verify supervisor can monitor conversations | 1. View chat threads on a project. | Supervisor can see the full conversation history. Ability to monitor ongoing communication between user and doer if applicable. | P2 |
| SA-PROJ-009 | Contact Prevention | Verify personal details blocking in chat | 1. In chat, try sending a message containing a phone number or email. | System blocks or warns about sharing personal contact information. Message may be filtered or flagged. Policy enforcement active. | P1 |
| SA-PROJ-010 | Search/Sort/Filter | Verify project list management | 1. On the projects screen, use search bar. 2. Apply sort options. 3. Apply filter. | Search filters projects by title or ID. Sort options: Date, Deadline, Amount. Filter by: Status, Subject, Doer. Results update in real-time. | P2 |
| SA-PROJ-011 | Project Detail | Verify project detail screen | 1. Tap on a project card to view ProjectDetailScreen. | Detail screen shows: Full project info, timeline, assigned doer details, files, chat history, status progression, and available actions. | P1 |

### 4.5 Chat Feature

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| SA-CHAT-001 | Chat List | Verify chat list screen with categories | 1. Navigate to ChatListScreen. | Screen displays chat conversations with category tabs: All, Unread, Client, Expert, Group. Each chat entry shows avatar, name, last message preview, timestamp. | P1 |
| SA-CHAT-002 | Unread Count Badges | Verify unread message counts | 1. Observe chat list entries with unread messages. | Unread chats display a count badge (e.g., "3") next to the chat entry. Badge color is prominent (blue/red). | P2 |
| SA-CHAT-003 | Mark All as Read | Verify mark all as read functionality | 1. With unread messages, tap "Mark All as Read" option. | All unread badges clear. All chats marked as read. | P3 |
| SA-CHAT-004 | Chat Room | Verify chat room with message bubbles | 1. Tap on a chat entry. 2. Observe ChatScreen. | ChatScreen displays: Message bubbles (sent on right, received on left) with timestamps. Sender name/avatar shown. Messages load in chronological order. | P1 |
| SA-CHAT-005 | Message Input | Verify message sending | 1. In a chat room, type a message. 2. Tap send. | Message appears in the chat bubble immediately. Message is delivered to the recipient. Sent indicator (check mark) shown. | P1 |
| SA-CHAT-006 | File Sharing | Verify file sharing in chat | 1. In chat, tap the attachment icon. 2. Select a file. 3. Send. | File picker opens. Selected file uploads with progress. File message appears in chat with name, size, and download link. | P2 |
| SA-CHAT-007 | Real-Time Updates | Verify messages appear in real-time | 1. Have two users in a chat. 2. Send a message from one side. | Message appears on the recipient's screen without manual refresh. Real-time subscription via Supabase Realtime active. | P1 |
| SA-CHAT-008 | Hero Section Stats | Verify chat stats in hero section | 1. Observe the chat list header/hero section. | Stats display: Total conversations, unread count, response time average. | P3 |

### 4.6 Doers Management

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| SA-DOER-001 | Doers Directory | Verify doers screen with search | 1. Navigate to DoersScreen. | Screen displays a list of doers with search bar at top. Each doer entry shows card format. | P1 |
| SA-DOER-002 | Filter by Expertise/Rating/Availability | Verify filter options | 1. Apply expertise filter. 2. Apply rating filter. 3. Apply availability filter. | Filters narrow the doer list. Multiple filters can be combined. Results update immediately. Filter state persists until cleared. | P2 |
| SA-DOER-003 | Doer Cards | Verify doer card content | 1. Observe a doer card in the directory. | Card displays: Avatar, full name, star rating, skills tags, completed projects count, availability status indicator. | P2 |
| SA-DOER-004 | Assign Button | Verify direct assignment from doer card | 1. On a doer card, tap "Assign". | Opens a project selection list for assigning the doer to an available project. Selection and confirmation flow. | P2 |
| SA-DOER-005 | Chat Button | Verify chat initiation with doer | 1. On a doer card, tap "Chat". | Opens or creates a chat room with the selected doer. Previous messages load if conversation exists. | P2 |
| SA-DOER-006 | Top Performers Section | Verify top performers display | 1. Observe the top performers section on the doers screen. | Highlighted section shows top-rated or most productive doers. Special visual treatment (badges, ranking). | P3 |
| SA-DOER-007 | Doer Detail View | Verify DoerDetailScreen | 1. Tap on a doer card to view DoerDetailScreen. | Detail screen shows: Full profile info, skills list, experience level, performance stats, rating breakdown, project history, reviews, and action buttons (Assign, Chat). | P2 |

### 4.7 Users/Clients Management

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| SA-USER-001 | Client Directory | Verify users screen with search | 1. Navigate to UsersScreen. | Screen displays a list of clients/users with search bar. Each user entry shows a card format. | P2 |
| SA-USER-002 | Sort Options | Verify sort functionality | 1. Apply sort by "Name". 2. Sort by "Recently Active". 3. Sort by "Most Projects". | List reorders based on selected sort criterion. Sort indicator shows active sort option. | P3 |
| SA-USER-003 | Client Cards | Verify client card content | 1. Observe a client card. | Card displays: Avatar, full name, total projects count, recent activity indicator. | P2 |
| SA-USER-004 | Client Detail | Verify client detail view | 1. Tap on a client card. | Detail view shows: Client stats (total projects, active, completed), notes, project history list, contact options (Chat only, no personal info). | P2 |
| SA-USER-005 | View Projects / Chat | Verify action buttons on client detail | 1. On client detail, tap "View Projects". 2. Tap "Chat". | View Projects: Filters project list to show only this client's projects. Chat: Opens or creates a chat room with the client. | P2 |

### 4.8 Earnings and Payments

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| SA-EARN-001 | Earnings Screen | Verify 3-tab layout | 1. Navigate to EarningsScreen. | Screen displays 3 tabs: "Overview", "Transactions", "Commission". TabController with 3 tabs renders correctly. | P1 |
| SA-EARN-002 | Period Selector | Verify period filtering | 1. On the Overview tab, tap different period options. | Period selector offers: Today, Week, Month, Year, All Time. Selecting a period filters all displayed data accordingly. Charts and stats update. | P2 |
| SA-EARN-003 | Balance Card | Verify balance display with Withdraw button | 1. Observe the balance card on the Overview tab. | Card displays: Total Earnings, Available Balance, Pending Balance. "Withdraw" button is present and enabled when available balance > 0. | P1 |
| SA-EARN-004 | Withdraw Flow | Verify withdrawal request | 1. Tap "Withdraw" on the balance card. 2. Enter amount. 3. Confirm. | Withdraw dialog shows available balance. Amount input validates against available balance. On confirm: Withdrawal request submitted. Status updates to "Processing". | P1 |
| SA-EARN-005 | Goal Tracker | Verify earnings goal progress | 1. Observe the goal tracker widget. | Goal tracker shows: Current earnings vs target. Progress bar with percentage. Visual indicator of how close to goal. | P3 |
| SA-EARN-006 | Earnings Snapshot | Verify 3 snapshot cards | 1. Observe the earnings snapshot section. | Three summary cards display key metrics: This Period Earnings, Average Per Project, Growth percentage. | P2 |
| SA-EARN-007 | Stats Cards | Verify projects and average stats | 1. Observe the stats cards section. | Cards display: Total Projects (count), Average Per Project (INR amount). Values match transaction data. | P2 |
| SA-EARN-008 | Earnings Trend Chart | Verify earnings chart visualization | 1. Observe the earnings chart (EarningsChart widget). | Line or bar chart renders earnings over time for the selected period. Chart is interactive (tap for values). Axes labeled correctly. | P2 |
| SA-EARN-009 | Transaction List | Verify transactions tab with filters | 1. Tap the "Transactions" tab. 2. Observe the transaction list. 3. Apply filters. | Chronological list of transactions with: Amount, date, project reference, type (earning/payout), status. Filters: Type, Status, Date range. | P1 |
| SA-EARN-010 | Transaction Detail | Verify transaction detail sheet | 1. Tap on a transaction entry. | Bottom sheet or detail screen shows: Full transaction details, associated project, payment method, timestamps, status history. | P2 |
| SA-EARN-011 | Commission Breakdown | Verify commission tab with pie chart | 1. Tap the "Commission" tab. | Commission breakdown displays: Pie chart showing earnings distribution (platform fee, supervisor commission, doer payout). Percentage and INR amounts for each segment. | P2 |
| SA-EARN-012 | Refresh | Verify data refresh | 1. Tap the refresh icon button in the AppBar. | Both earningsProvider and transactionsProvider refresh. Loading indicator shown during refresh. Data updates on completion. | P2 |

### 4.9 Resources

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| SA-RES-001 | Resources Screen | Verify 3-tab layout (Tools, Training, Pricing) | 1. Navigate to ResourcesScreen. | Screen displays 3 tabs with icons: Tools (build icon), Training (school icon), Pricing (money icon). | P2 |
| SA-RES-002 | Tools Tab | Verify tools grid | 1. On the Tools tab, observe the grid. | Grid displays tool cards: Plagiarism Checker, AI Detector, and other webview-based tools. Each card has icon, title, and description. | P2 |
| SA-RES-003 | Tool Webview | Verify tool opens in webview | 1. Tap on a tool card (e.g., Plagiarism Checker). | ToolWebviewScreen opens with the tool loaded in an embedded webview. Back navigation works. Loading indicator during page load. | P2 |
| SA-RES-004 | Training Tab | Verify training library with category filter and search | 1. Tap the "Training" tab. 2. Use category filter. 3. Use search. | Training library displays video/document entries. Category filter narrows results. Search filters by title/description. | P2 |
| SA-RES-005 | Training Video Player | Verify video playback | 1. Tap a training video entry. | TrainingVideoScreen plays the video with standard controls. Completion tracking active. | P2 |
| SA-RES-006 | Pricing Tab | Verify pricing calculator | 1. Tap the "Pricing" tab. 2. Select work type, level, urgency, page count. | Pricing calculator displays input fields for: Work type dropdown, Academic level, Urgency selector, Page count. Calculated price updates dynamically. | P2 |
| SA-RES-007 | Price Table | Verify pricing guide table | 1. Scroll through the Pricing tab. | PricingGuideTable displays reference pricing for different work types, levels, and urgency combinations. Table is scrollable and readable. | P3 |

### 4.10 Support

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| SA-SUP-001 | Support Screen | Verify 3-tab layout | 1. Navigate to SupportScreen. | Screen displays 3 tabs: "My Tickets", "New Ticket", "FAQ". | P2 |
| SA-SUP-002 | Ticket List | Verify ticket list with status filters | 1. On "My Tickets" tab, observe the list. 2. Apply status filters. | Ticket list shows: Subject, status badge, priority, date. Filters: All, Open, In Progress, Resolved, Closed. | P2 |
| SA-SUP-003 | Create Ticket | Verify new ticket form | 1. Tap "New Ticket" tab. 2. Fill in the form. 3. Submit. | Form displays: Subject input, Description textarea, Category dropdown, Priority selector. On submit: Ticket created. Confirmation shown. Ticket appears in "My Tickets". | P2 |
| SA-SUP-004 | FAQ | Verify FAQ accordion with search | 1. Tap "FAQ" tab. 2. Expand an FAQ item. 3. Use search. | FaqScreen displays expandable accordion items. Search filters FAQ entries by keyword. Expanded items show full answer text. | P3 |
| SA-SUP-005 | Quick Support Actions | Verify quick action buttons | 1. Observe quick support action buttons. | Actions display: FAQ, Email Support, Live Chat, Call Support. Each button navigates to the appropriate support channel. | P3 |
| SA-SUP-006 | Ticket Detail | Verify ticket detail with timeline | 1. Tap on a ticket from the list. | TicketDetailScreen shows: Full ticket info, status timeline, message thread with replies, and reply input for adding updates. | P2 |

### 4.11 Notifications

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| SA-NOTIF-001 | Notifications Screen | Verify filter chips | 1. Navigate to NotificationsScreen. 2. Observe filter chips. | Filter chips display: All, Unread, Projects, Chat, Payments, System. Selecting a chip filters the notification list. | P2 |
| SA-NOTIF-002 | Grouped by Date | Verify date grouping | 1. Observe notification list with multiple dates. | Notifications grouped under headers: "Today", "Yesterday", "This Week", "Older". Chronological order within groups. | P2 |
| SA-NOTIF-003 | Swipe to Dismiss | Verify swipe gesture | 1. Swipe a notification left or right. | Notification is dismissed/deleted with swipe animation. Undo option may appear briefly. | P3 |
| SA-NOTIF-004 | Mark as Read | Verify marking notifications as read | 1. Tap on an unread notification. 2. Use "Mark All as Read" option. | Individual tap: Notification marked as read (visual change). Mark All: All notifications lose unread styling. Badge count updates. | P2 |
| SA-NOTIF-005 | Notification Settings | Verify push/email/quiet hours settings | 1. Navigate to notification settings. | Settings display: Push notification toggle, Email notification toggle, Quiet Hours toggle with start/end time pickers. Changes persist. | P2 |

### 4.12 Settings

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| SA-SET-001 | Settings Screen | Verify 4-tab layout | 1. Navigate to SettingsScreen. | Screen displays 4 scrollable tabs: Notifications, Appearance, Privacy, Language. TabBar with icons and labels. | P2 |
| SA-SET-002 | Notifications Tab | Verify email/push toggles | 1. On Notifications tab, toggle email notifications. 2. Toggle push notifications. | Both toggles function independently. States persist after navigation. Backend preferences updated. | P2 |
| SA-SET-003 | Quiet Hours | Verify quiet hours configuration | 1. Enable quiet hours toggle. 2. Set start time. 3. Set end time. | Time pickers appear for start and end times. During quiet hours, notifications are silenced. Settings persist. | P3 |
| SA-SET-004 | Appearance Tab | Verify theme switching (Light/Dark/System) | 1. On Appearance tab, select Light. 2. Select Dark. 3. Select System. | Theme changes immediately across the app. ThemeProvider updates. System option follows device theme. | P2 |
| SA-SET-005 | Privacy Tab | Verify privacy settings | 1. On Privacy tab, toggle profile visibility. 2. Toggle 2FA. | Profile visibility toggle controls whether profile appears in directory. 2FA toggle enables/disables two-factor authentication (with setup flow if enabling). | P2 |
| SA-SET-006 | Language Tab | Verify language selection | 1. On Language tab, select a different language. | LanguagePicker displays available languages. Selection updates app UI via TranslationProvider. All screens reflect new language. | P3 |
| SA-SET-007 | Logout | Verify logout from settings | 1. In settings or drawer, tap "Logout". 2. Confirm. | Confirmation dialog appears. On confirm: Session cleared. Navigates to login screen. Auth tokens removed. | P1 |
| SA-SET-008 | Delete Account | Verify account deletion | 1. In settings, tap "Delete Account". 2. Confirm. | Warning about data loss. Confirmation requires explicit action. On confirm: Account deactivated. User logged out. | P1 |
| SA-SET-009 | Timezone | Verify timezone dropdown | 1. Locate timezone setting. 2. Select a different timezone. | Dropdown lists available timezones. Selection persists. Deadline displays adjust to selected timezone. | P3 |

### 4.13 Campus Connect / Business Hub

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| SA-CC-001 | Campus Connect Screen | Verify hero section with actions | 1. Navigate to CampusConnectScreen. | Hero section displays with "Create Post" and "View Saved" buttons. Visual branding present. | P2 |
| SA-CC-002 | Search Bar | Verify search functionality | 1. Tap the search bar. 2. Enter a query. | Search filters posts by keyword. Results update as user types. | P3 |
| SA-CC-003 | Filter Tabs | Verify category filter tabs | 1. Tap different filter tabs. | Tabs filter content by category. Active tab visually highlighted. Content updates on tab change. | P3 |
| SA-CC-004 | Staggered Grid | Verify Pinterest-style grid layout | 1. Observe the post feed layout. | Posts display in a staggered/masonry grid (Pinterest-style). Cards have varying heights. Layout is visually appealing and responsive. | P2 |
| SA-CC-005 | Post Cards | Verify post card content | 1. Observe individual post cards. | Cards display: Image (if any), title, description preview, author info, engagement metrics. Tap opens PostDetailScreen. | P2 |
| SA-CC-006 | Create Post | Verify post creation flow | 1. Tap "Create Post". 2. Fill in the form on CreatePostScreen. 3. Submit. | Form displays: Title, content, category, image upload. On submit: Post appears in feed. Success confirmation. | P2 |
| SA-CC-007 | Saved Listings | Verify saved listings screen | 1. Tap "View Saved". | SavedListingsScreen shows all bookmarked/saved posts. Posts can be unsaved. Tap opens detail. | P3 |
| SA-CC-008 | Post Detail | Verify post detail screen | 1. Tap on a post card. | PostDetailScreen shows full content, author details, comments, and engagement actions (like, save, report). | P2 |

---

## 5. ADMIN WEB (Next.js) - Test Cases

### 5.1 Authentication

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| AW-AUTH-001 | Login Page | Verify admin login page renders | 1. Navigate to /login. 2. Observe the login form. | Login page displays: Email input, Password input, Submit button. Professional admin branding. Title "AssignX Admin". | P1 |
| AW-AUTH-002 | Login - Valid Credentials | Verify successful login with test account | 1. Enter email: admin@gmail.com. 2. Enter password: Admin@123. 3. Click Submit. | Login succeeds. User is redirected to the admin dashboard (/(authenticated) route). Session cookie is set. | P1 |
| AW-AUTH-003 | Login - Invalid Credentials | Verify login failure with wrong credentials | 1. Enter incorrect email or password. 2. Click Submit. | Error message displays (e.g., "Invalid login credentials"). User remains on login page. No session created. | P1 |
| AW-AUTH-004 | Admin Verification | Verify non-admin users cannot access admin panel | 1. Log in with a regular user (non-admin) account. | Access denied. User is redirected to login page or shown "Unauthorized" message. Admin role verification in (authenticated)/layout.tsx blocks access. | P1 |
| AW-AUTH-005 | Session Management | Verify session persistence and expiration | 1. Log in successfully. 2. Close browser. 3. Reopen and navigate to admin URL. | Session persists within expiration window. User sees dashboard without re-login. Expired sessions redirect to login. | P1 |
| AW-AUTH-006 | Redirect if Not Authenticated | Verify unauthenticated redirect | 1. Without logging in, navigate directly to /(authenticated)/page. | User is redirected to /login. No admin content is exposed. | P1 |

### 5.2 Dashboard

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| AW-DASH-001 | Dashboard Rendering | Verify admin dashboard renders with stats | 1. Log in as admin. 2. Observe the main dashboard page. | Dashboard displays: AdminSectionCards (stat cards), AdminCharts, AdminRecentActivity. No errors in console. | P1 |
| AW-DASH-002 | Stats Cards | Verify stat card values | 1. Observe the AdminSectionCards component. | Five stat cards display: Total Users, New Users (This Month), Active Projects, Total Revenue (INR), Pending Tickets. Values fetched via get_admin_dashboard_stats RPC. | P1 |
| AW-DASH-003 | User Growth Chart | Verify user growth visualization | 1. Observe the user growth chart in AdminCharts. | Line or area chart renders user registrations over the last 30 days. Axes are labeled. Data points are accurate. | P2 |
| AW-DASH-004 | Revenue Chart | Verify revenue chart visualization | 1. Observe the revenue chart in AdminCharts. | Chart renders revenue data over the last 30 days. Amount in INR on Y-axis. Dates on X-axis. Trend line visible. | P2 |
| AW-DASH-005 | Recent Activity Table | Verify recent activity display | 1. Observe the AdminRecentActivity section. | Table shows the 5 most recent support tickets with: Requester name (from profiles), subject, status, created date. Clickable rows. | P2 |

### 5.3 User Management

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| AW-USER-001 | Users List | Verify users list page renders | 1. Navigate to /(authenticated)/users. | Users list page displays with: Search bar, user type filter, status filter, paginated table of users. | P1 |
| AW-USER-002 | Search Users | Verify search functionality | 1. Enter a user name in the search bar. 2. Press Enter or observe live search. | Results filter to show matching users. Search works on name and email. Clear search restores full list. | P1 |
| AW-USER-003 | Type Filter | Verify user type filtering | 1. Filter by "Student". 2. Filter by "Professional". 3. Filter by "Business". | List shows only users of the selected type. Filter UI indicates active filter. "All" option resets. | P2 |
| AW-USER-004 | Status Filter | Verify user status filtering | 1. Filter by "Active". 2. Filter by "Suspended". | List shows only users matching the selected status. Status badges are color-coded. | P2 |
| AW-USER-005 | Suspend/Activate Users | Verify user status toggle | 1. On a user row, click "Suspend" action. 2. Confirm. 3. Click "Activate" on a suspended user. | Suspend: User status changes to "Suspended". Account access is revoked. Activate: User status restored. Access re-enabled. Confirmation dialog for both actions. | P1 |
| AW-USER-006 | User Detail View | Verify user detail page | 1. Click on a user row to navigate to /users/[id]. | User detail page shows: Profile info (name, email, role, join date), Projects list, Wallet information, Activity log. Back navigation works. | P1 |
| AW-USER-007 | Pagination | Verify users list pagination | 1. With many users, observe pagination controls. 2. Navigate to page 2. | Pagination controls display: Previous/Next buttons, page numbers. Clicking page 2 loads the next set of users. Current page highlighted. | P2 |

### 5.4 Project Management

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| AW-PROJ-001 | Projects List | Verify projects list page | 1. Navigate to /(authenticated)/projects. | Projects list displays with: Search bar, status filter dropdown, paginated table. | P1 |
| AW-PROJ-002 | Search Projects | Verify project search | 1. Enter a project title or ID in the search bar. | Results filter to matching projects. Search is responsive. | P1 |
| AW-PROJ-003 | Status Filter | Verify status filter with 20+ statuses | 1. Open the status filter dropdown. 2. Select different statuses (e.g., Submitted, Quoted, Paid, In Progress, Under Review, Completed, Delivered, Cancelled). | Dropdown lists all available project statuses (20+). Selecting a status filters the list accurately. Status badges use appropriate colors. | P1 |
| AW-PROJ-004 | Project Detail | Verify project detail page | 1. Click on a project row to navigate to /projects/[id]. | Detail page shows: Full project info, timeline of status changes, attached files, payment details, assigned supervisor and doer, chat history. | P1 |
| AW-PROJ-005 | Status Badges | Verify color-coded status badges | 1. Observe status badges across the projects list. | Each status has a distinct color badge: Green for completed, Yellow for in-progress, Red for cancelled, Blue for submitted, etc. Consistent across list and detail views. | P2 |

### 5.5 People Management

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| AW-PEOPLE-001 | Supervisors List | Verify supervisors page | 1. Navigate to /(authenticated)/supervisors. | Supervisors list displays with: Search, status filter, paginated table. Each entry shows name, email, status, expertise, rating, projects count. | P1 |
| AW-PEOPLE-002 | Supervisor Detail | Verify supervisor detail page | 1. Click a supervisor row to navigate to /supervisors/[id]. | Detail page shows: Full profile, performance stats, assigned projects, earnings history, review scores, CV download (if uploaded). | P2 |
| AW-PEOPLE-003 | Doers List | Verify doers page | 1. Navigate to /(authenticated)/doers. | Doers list displays with: Search, filter options, paginated table. Each entry shows name, skills, rating, availability, activation status. | P1 |
| AW-PEOPLE-004 | Doer Detail | Verify doer detail page | 1. Click a doer row to navigate to /doers/[id]. | Detail page shows: Full profile, skills, experience level, performance metrics, project history, earnings, reviews. | P2 |
| AW-PEOPLE-005 | Experts List | Verify experts page | 1. Navigate to /(authenticated)/experts. | Experts list displays with: Search, filter options, paginated table. Each entry shows name, specialization, status, rating. | P1 |
| AW-PEOPLE-006 | Expert Actions | Verify verify/reject/suspend/feature actions | 1. On an expert entry, click "Verify". 2. Click "Reject" on another. 3. Click "Suspend". 4. Click "Feature". | Verify: Expert status changes to Verified. Reject: Status changes to Rejected with reason prompt. Suspend: Account access restricted. Feature: Expert highlighted in public listings. All actions require confirmation. | P1 |
| AW-PEOPLE-007 | Expert Detail | Verify expert detail page | 1. Click an expert row to navigate to /experts/[id]. | Detail page shows: Full profile, specialization, session history, reviews, earnings, availability calendar, action buttons. | P2 |

### 5.6 Financial Management

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| AW-FIN-001 | Wallets Page | Verify wallets/financial page | 1. Navigate to /(authenticated)/wallets. | Financial page displays: Summary cards (Total Revenue, Refunds, Payouts, Platform Fees, Net Revenue). Transaction ledger table. | P1 |
| AW-FIN-002 | Revenue Summary Cards | Verify financial summary metrics | 1. Observe the summary cards at the top. | Five cards display: Total Revenue, Total Refunds, Total Payouts (to doers/supervisors), Platform Fees, Net Revenue. All in INR with proper formatting. | P1 |
| AW-FIN-003 | Revenue Breakdown Chart | Verify 90-day revenue chart | 1. Observe the revenue breakdown chart. | Chart renders revenue data for the last 90 days. Breakdown by category (project payments, wallet top-ups, etc.). Interactive tooltips. | P2 |
| AW-FIN-004 | Transaction Ledger | Verify transaction table with filters | 1. Observe the transaction ledger. 2. Apply filters (type, status, date range). | Table shows: Transaction ID, User, Amount, Type (Payment/Payout/Refund), Status, Date. Filters narrow results. Sortable columns. | P1 |
| AW-FIN-005 | Wallet Detail | Verify individual wallet detail | 1. Click on a wallet entry to navigate to /wallets/[id]. | Wallet detail shows: Owner info, current balance, transaction history for this wallet, top-up history, payout history. | P2 |

### 5.7 Support Management

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| AW-SUP-001 | Support Page | Verify support tickets page | 1. Navigate to /(authenticated)/support. | Page displays: Ticket stats cards at top, tickets table with search, status filter, priority filter. | P1 |
| AW-SUP-002 | Ticket Stats Cards | Verify ticket statistics | 1. Observe the stats cards. | Cards show: Total Tickets, Open, In Progress, Resolved, Average Response Time. Values accurate. | P2 |
| AW-SUP-003 | Tickets Table | Verify tickets table with filters | 1. Search for a ticket. 2. Filter by status. 3. Filter by priority. | Table shows: Subject, requester name, status badge, priority badge, date. All filters work correctly. Pagination present. | P1 |
| AW-SUP-004 | Ticket Detail | Verify ticket detail page | 1. Click a ticket row to navigate to /support/[id]. | Detail page shows: Full ticket info, message thread (chronological), status timeline, and admin action buttons. | P1 |
| AW-SUP-005 | Reply Action | Verify admin reply to ticket | 1. On ticket detail, type a reply message. 2. Click Send/Reply. | Reply appears in the message thread. Ticket status may update (e.g., to "In Progress"). User is notified of the reply. | P1 |
| AW-SUP-006 | Assign Action | Verify ticket assignment | 1. On ticket detail, assign the ticket to an admin/support agent. | Assignment dropdown shows available agents. Selected agent is notified. Ticket shows assigned agent name. | P2 |
| AW-SUP-007 | Resolve Action | Verify ticket resolution | 1. On ticket detail, click "Resolve". 2. Confirm. | Ticket status changes to "Resolved". Resolution timestamp recorded. User notified of resolution. | P1 |

### 5.8 Content Management

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| AW-CMS-001 | Banners List | Verify banners page | 1. Navigate to /(authenticated)/banners. | Banners list displays existing banners with: Image preview, title, status (Active/Inactive), target platform, date. Create button present. | P2 |
| AW-CMS-002 | Create Banner | Verify banner creation form | 1. Click "Create Banner" or navigate to /banners/create. 2. Fill in the form. 3. Submit. | Form displays: Title, description, image upload, target URL, target platform, active toggle. On submit: Banner created. Appears in list. | P2 |
| AW-CMS-003 | Edit Banner | Verify banner editing | 1. On a banner entry, click "Edit". 2. Modify fields. 3. Save. | Edit form pre-fills current values. Changes save successfully. Updated values reflected in list. | P2 |
| AW-CMS-004 | Delete Banner | Verify banner deletion | 1. On a banner entry, click "Delete". 2. Confirm. | Confirmation dialog appears. On confirm: Banner removed from list. Deletion is permanent. | P2 |
| AW-CMS-005 | Banner Preview | Verify banner preview | 1. On a banner, click "Preview". | Banner renders in a preview modal showing how it will appear to end users on the target platform. | P3 |
| AW-CMS-006 | Learning Resources List | Verify learning resources page | 1. Navigate to /(authenticated)/learning. | List of learning resources with: Title, type (Video/PDF/Article), category, status. Create button present. | P2 |
| AW-CMS-007 | Create Learning Resource | Verify resource creation | 1. Navigate to /learning/create. 2. Fill in the form. 3. Submit. | Form displays: Title, description, type selector, category, file upload (video/PDF), target audience. On submit: Resource created. | P2 |
| AW-CMS-008 | Edit/Delete Resource | Verify resource management | 1. Edit an existing resource. 2. Delete a resource. | Edit: Pre-filled form, save updates. Delete: Confirmation required, resource removed. | P2 |

### 5.9 Moderation

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| AW-MOD-001 | Moderation Page | Verify flagged content queue | 1. Navigate to /(authenticated)/moderation. | Page displays a queue of flagged/reported content items. Each item shows: Content type, reporter, reason, date, content preview. | P1 |
| AW-MOD-002 | Approve Action | Verify content approval | 1. On a flagged item, click "Approve". | Content is cleared from the moderation queue. Original post/content remains visible to users. Reporter may receive notification. | P1 |
| AW-MOD-003 | Reject Action | Verify content rejection | 1. On a flagged item, click "Reject/Remove". 2. Optionally add a reason. | Content is removed from the platform. Author is notified of content removal with reason. Item removed from moderation queue. | P1 |
| AW-MOD-004 | Ban Action | Verify user ban from moderation | 1. On a flagged item, click "Ban User". 2. Confirm. | User account is suspended. All user's content may be hidden. User receives ban notification. Admin can specify ban duration. | P1 |
| AW-MOD-005 | Content Type Tabs | Verify filtering by content type | 1. Switch between content type tabs (Posts, Comments, Profiles, etc.). | Queue filters to show only the selected content type. Counts update per tab. | P2 |

### 5.10 Analytics and Reports

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| AW-ANLYT-001 | Analytics Page | Verify analytics dashboard | 1. Navigate to /(authenticated)/analytics. | Page displays: KPI cards, platform health indicators, user growth chart, revenue breakdown. | P2 |
| AW-ANLYT-002 | KPI Cards | Verify KPI metrics | 1. Observe KPI cards. | Cards show key platform metrics: DAU/MAU, conversion rate, average project value, completion rate. | P2 |
| AW-ANLYT-003 | Period Selector | Verify period filtering (7d/30d/90d) | 1. Select 7-day period. 2. Select 30-day. 3. Select 90-day. | All charts and metrics update to reflect the selected time period. Active period indicator highlighted. | P2 |
| AW-ANLYT-004 | User Growth Chart | Verify user registration trends | 1. Observe user growth chart. | Chart shows new user registrations over the selected period. Breakdown by user type if available. | P2 |
| AW-ANLYT-005 | Revenue Breakdown | Verify revenue analytics | 1. Observe revenue breakdown chart. | Chart shows revenue composition: Project payments, subscriptions, fees. Amounts in INR. | P2 |
| AW-ANLYT-006 | Reports Page | Verify reports page | 1. Navigate to /(authenticated)/reports. | Reports page shows: Projects by status report, recent projects table, top supervisors ranking. Data is exportable if applicable. | P2 |
| AW-ANLYT-007 | Top Supervisors | Verify supervisor rankings | 1. Observe top supervisors section. | Ranked list of supervisors by: Projects completed, earnings, rating. Links to supervisor detail. | P3 |

### 5.11 Settings

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| AW-SET-001 | Settings Page | Verify settings form renders | 1. Navigate to /(authenticated)/settings. | SettingsForm component renders with tabs or sections: General, Features, Payments, Limits, Notifications. Data fetched via getSettings(). | P1 |
| AW-SET-002 | Maintenance Mode | Verify maintenance mode toggle | 1. Toggle maintenance mode ON. 2. Observe the platform. 3. Toggle OFF. | ON: Platform shows maintenance page to users. Admin panel remains accessible. OFF: Normal operation resumes. Confirmation required. | P1 |
| AW-SET-003 | Feature Flags | Verify feature flag toggles | 1. Toggle a feature flag (e.g., Campus Connect, Expert Consultation). | Feature is enabled/disabled across the platform. Changes take effect immediately or on next page load. | P2 |
| AW-SET-004 | Commission Settings | Verify commission rate configuration | 1. Update platform commission percentage. 2. Save. | Commission rate input accepts valid percentages. On save: New rate applies to future transactions. Current transactions unaffected. | P1 |
| AW-SET-005 | File Size Limits | Verify file upload size limits | 1. Update maximum file upload size. 2. Save. | Limit input accepts values in MB. On save: New limits enforced on all file uploads across the platform. | P2 |
| AW-SET-006 | Project Limits | Verify project-related limits | 1. Update project limits (e.g., max concurrent projects per user). 2. Save. | Limits are configurable and persist. Enforced when users create new projects. | P2 |
| AW-SET-007 | Notification Settings | Verify platform notification configuration | 1. Configure email notification templates or triggers. 2. Save. | Notification settings control which events trigger notifications. Templates can be customized if applicable. | P3 |

### 5.12 Colleges and Messages

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| AW-COL-001 | Colleges List | Verify colleges page | 1. Navigate to /(authenticated)/colleges. | Page displays list of colleges/universities with: Name, user count distribution, status. Search available. | P2 |
| AW-COL-002 | College Detail | Verify college detail page | 1. Click on a college to navigate to /colleges/[id]. | Detail page shows: College info, registered users breakdown (students, professionals), activity metrics, associated projects. | P2 |
| AW-COL-003 | User Distribution | Verify user distribution per college | 1. On college detail, observe user distribution. | Visual breakdown (chart or table) showing user types registered from this college. | P3 |
| AW-COL-004 | Messages Page | Verify chat monitoring page | 1. Navigate to /(authenticated)/messages. | Chat rooms monitoring page displays: Active chat rooms, participant info, message counts, flagged conversations. Admin can view conversations for moderation purposes. | P2 |

---

## 6. USER WEB (Next.js) - Test Cases

### 6.1 Landing Page

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| UW-LAND-001 | Landing Page | Verify landing page renders at root | 1. Navigate to the root URL (/) of the user web app. | Landing page renders: Hero section with CTA, How It Works steps, User Type Cards, Trust Stats. No auth required. | P1 |
| UW-LAND-002 | Hero Section | Verify hero section content | 1. Observe the hero section. | Hero displays: Headline text, subheadline, primary CTA button ("Get Started" or "Sign Up"), secondary CTA ("Learn More"). Background visual/animation. | P1 |
| UW-LAND-003 | How It Works | Verify how-it-works section | 1. Scroll to the "How It Works" section. | Section displays step-by-step process: 1. Submit Project, 2. Get Matched, 3. Track Progress, 4. Receive Delivery. Icons or illustrations for each step. | P2 |
| UW-LAND-004 | User Type Cards | Verify role cards | 1. Observe the user type cards section. | Three cards display: Student, Professional, Business. Each card describes the value proposition for that user type. CTA to sign up for each role. | P2 |
| UW-LAND-005 | Trust Stats | Verify trust statistics | 1. Observe the trust stats section. | Statistics display: Number of projects completed, active experts, satisfaction rate, etc. Animated counters or static values. | P2 |
| UW-LAND-006 | Testimonials Carousel | Verify testimonials section | 1. Observe the testimonials carousel. 2. Navigate between testimonials. | Carousel displays user testimonials with: Quote text, author name, role, avatar. Auto-rotate or manual navigation. | P3 |
| UW-LAND-007 | Global Reach Section | Verify global reach display | 1. Observe the global reach section. | Section shows geographic reach with map or statistics. Highlights coverage areas and user count by region. | P3 |
| UW-LAND-008 | CTA Buttons | Verify CTA button navigation | 1. Click "Get Started" CTA. 2. Click "Sign Up" CTA. | CTA buttons navigate to /signup or /login page. Navigation is smooth without errors. | P1 |
| UW-LAND-009 | Footer Navigation | Verify footer links | 1. Scroll to footer. 2. Click footer links (Terms, Privacy, Support, etc.). | Footer displays: Company info, legal links (Terms at /terms, Privacy at /privacy, Open Source at /open-source), support links. All links navigate correctly. | P3 |

### 6.2 Authentication

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| UW-AUTH-001 | Login Page | Verify login page renders | 1. Navigate to /login. | Login page displays: Email input for magic link, Google OAuth button, "Sign Up" link for new users. Error boundary present. Loading state configured. | P1 |
| UW-AUTH-002 | Magic Link Login | Verify magic link email flow | 1. Enter a valid registered email. 2. Click "Send Magic Link". 3. Check email inbox. 4. Click the magic link. | Magic link email sent via /api/auth/magic-link route. Email contains a login link. Clicking link authenticates the user and redirects to /home via /auth/callback. | P1 |
| UW-AUTH-003 | Google OAuth | Verify Google sign-up/login | 1. Click the "Sign in with Google" button. 2. Complete Google OAuth flow. | Google OAuth popup or redirect initiates. On success: User authenticated. New users redirected to onboarding. Existing users redirected to /home. Callback handled at /auth/callback. | P1 |
| UW-AUTH-004 | Signup Page | Verify signup page with role selection | 1. Navigate to /signup. | Signup page displays role selection: Student, Professional, Business. Each role card is clickable and leads to the appropriate registration form. | P1 |
| UW-AUTH-005 | Student Registration | Verify student signup flow | 1. Select "Student" role on signup. 2. Navigate to /signup/student. 3. Fill in the form with a college email. 4. Submit. | Student registration form displays: Name, college email (validation for .edu or college domain), college selection. On submit: Account created. College verification initiated via /api/auth/verify-college. | P1 |
| UW-AUTH-006 | College Email Validation | Verify college email domain check | 1. Enter a non-college email (e.g., gmail.com). 2. Enter a valid college email. | Non-college email: Validation error or warning. College email: Passes validation. Verify-college page at /verify-college handles verification flow. | P1 |
| UW-AUTH-007 | Professional Registration | Verify professional signup | 1. Select "Professional" on signup. 2. Navigate to /signup/professional. 3. Fill in the form. 4. Submit. | Professional registration form displays: Name, email, company (optional), field of expertise. On submit: Account created. Redirected to onboarding. | P1 |
| UW-AUTH-008 | Onboarding Carousel | Verify post-signup onboarding | 1. After registration, observe /onboarding page. | Onboarding carousel displays slides explaining the platform features. Skip option available. Completion leads to /home dashboard. | P2 |
| UW-AUTH-009 | Auth Error Handling | Verify error boundary on auth pages | 1. Trigger an auth error (e.g., expired magic link). | Error page renders via (auth)/error.tsx with user-friendly message and retry options. | P2 |

### 6.3 Dashboard Home

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| UW-HOME-001 | Dashboard Rendering | Verify home page renders | 1. Log in and navigate to /home. | Dashboard home page renders: Personalized greeting, quick stats, recent projects, services grid. Loading state shows during data fetch. | P1 |
| UW-HOME-002 | Personalized Greeting | Verify greeting text | 1. Observe the greeting section. | Greeting displays: "Good [Morning/Afternoon/Evening], [User Name]". Time-appropriate greeting. | P2 |
| UW-HOME-003 | Quick Stats | Verify dashboard statistics | 1. Observe quick stats area. | Stats show: Active projects count, completed projects count, wallet balance, pending actions. | P1 |
| UW-HOME-004 | Recent Projects | Verify recent projects display | 1. Observe the recent projects section. | Most recent projects display with: Title, status badge, deadline, last update. Click navigates to /project/[id]. | P1 |
| UW-HOME-005 | Services Grid | Verify services navigation grid | 1. Observe the services grid. | Grid shows available services: Assignment Help, Content Writing, Graphic Design, Data Entry, etc. Each service card is clickable and leads to project creation for that category. | P2 |
| UW-HOME-006 | Banner Carousel | Verify promotional banners | 1. Observe the banner carousel section. | Banner carousel displays admin-configured promotional banners. Auto-rotate. Click navigates to target URL. | P3 |
| UW-HOME-007 | Dock Navigation | Verify dock/bottom navigation | 1. Observe the dock or navigation bar. | Dock displays: Home, Projects, Campus Connect, Wallet, Profile. Active page highlighted. Navigation works on all items. | P1 |
| UW-HOME-008 | Wallet Pill | Verify wallet balance display | 1. Observe the wallet pill/badge. | Wallet balance displays in a pill format showing current balance in INR. Tap/click navigates to /wallet. | P2 |
| UW-HOME-009 | Notification Bell | Verify notification bell | 1. Click the notification bell icon. | Notification panel or page opens. Unread count badge displayed. Recent notifications listed. | P2 |
| UW-HOME-010 | Professional Dashboard | Verify professional-specific dashboard | 1. Log in as a "Professional" user. 2. Navigate to /home. | Dashboard renders dashboard-pro.tsx variant with professional-specific content, consultation features, and business metrics. | P2 |

### 6.4 Projects

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| UW-PROJ-001 | Projects List | Verify projects page | 1. Navigate to /projects. | Projects page renders with: Status tabs, project cards, search, filter options. Loading state via loading.tsx. | P1 |
| UW-PROJ-002 | Status Tabs | Verify project status filtering | 1. Click different status tabs (All, Active, Completed, Cancelled). | Projects filter by selected status. Tab indicator shows active tab. Count badges on tabs. | P1 |
| UW-PROJ-003 | Multi-Step Project Creation | Verify new project creation | 1. Navigate to /projects/new. 2. Complete each step of the creation form. 3. Submit. | Multi-step form guides user through: Service type, requirements, deadline, file attachments, budget preferences. Progress indicator shows current step. On submit: Project created. | P1 |
| UW-PROJ-004 | Project Detail | Verify project detail page | 1. Navigate to /project/[id]. | Project detail page (project-detail-client.tsx) shows: Full project info, status timeline, chat with supervisor, deliverables section, payment status. Error boundary via error.tsx. | P1 |
| UW-PROJ-005 | Project Timeline | Verify timeline view | 1. On project detail, navigate to /project/[id]/timeline. | Timeline page shows chronological status changes: Created, Quoted, Paid, In Progress, Under Review, Delivered. Each step has timestamp and details. | P2 |
| UW-PROJ-006 | Payment via Razorpay | Verify payment flow | 1. On a quoted project, click "Pay Now". 2. Complete Razorpay checkout. | Razorpay payment modal opens. Payment creation via /api/payments/create-order. Verification via /api/payments/verify. On success: Project status updates to "Paid". | P1 |
| UW-PROJ-007 | Partial Payment | Verify partial payment option | 1. On a quoted project, select "Pay Partially". 2. Complete partial payment. | Partial payment route (/api/payments/partial-pay) handles partial amounts. Remaining balance displayed. Project proceeds with partial payment if allowed. | P2 |
| UW-PROJ-008 | Wallet Payment | Verify wallet payment option | 1. On a quoted project, select "Pay with Wallet". | Wallet payment route (/api/payments/wallet-pay) deducts from wallet balance. Insufficient balance shows error with top-up option. | P2 |
| UW-PROJ-009 | Auto-Approval Timer | Verify automatic approval after timer | 1. After delivery, observe the auto-approval countdown. | Timer displays remaining time before auto-approval (e.g., 48 hours). If user does not approve or request changes, project auto-approves. Payment released. | P1 |
| UW-PROJ-010 | Invoice Download | Verify invoice generation | 1. On a completed project, click "Download Invoice". | Invoice PDF generates via /api/invoices/[projectId] route. PDF downloads with: Project details, payment breakdown, dates, AssignX branding. | P2 |
| UW-PROJ-011 | Professional Projects View | Verify professional-specific projects | 1. Log in as "Professional". 2. Navigate to /projects. | Projects page renders projects-pro.tsx variant with professional-specific project types and views. | P2 |

### 6.5 Campus Connect

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| UW-CC-001 | Campus Connect Page | Verify campus connect renders | 1. Navigate to /campus-connect. | Campus Connect page renders with: Post feed, create button, filter options, search. Loading state via loading.tsx. | P2 |
| UW-CC-002 | Multi-Role Portal | Verify role-specific content | 1. Access campus connect as Student. 2. Access as Professional. 3. Access as Business. | Content adapts based on user role. Student sees campus-specific content. Professional sees networking content. Business sees marketplace content. | P2 |
| UW-CC-003 | Post Creation | Verify creating a new post | 1. Navigate to /campus-connect/create. 2. Fill in the form. 3. Submit. | Post creation form: Title, content, category, images. On submit: Post published. Appears in feed. Redirects to post detail. | P2 |
| UW-CC-004 | Post Detail | Verify post detail page | 1. Click on a post to navigate to /campus-connect/[postId]. | Post detail displays: Full content, author info, comments section, engagement actions (like, save, report). | P2 |
| UW-CC-005 | Feed Browsing | Verify scrolling through posts | 1. On the campus connect page, scroll through the feed. | Posts load progressively (infinite scroll or pagination). Each post shows: Preview, author, engagement counts. | P2 |
| UW-CC-006 | Like/Save/Report/Comment | Verify engagement actions | 1. Like a post. 2. Save a post. 3. Report a post. 4. Comment on a post. | Like: Count increments, icon fills. Save: Post added to saved list. Report: Report dialog opens. Comment: Comment appears under post. | P2 |
| UW-CC-007 | Connect Page (Alternate) | Verify /connect route | 1. Navigate to /connect. | Connect page renders with connect-pro.tsx for professional users. Create post available at /connect/create. | P2 |

### 6.6 Experts and Consultation

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| UW-EXP-001 | Browse Experts | Verify experts page | 1. Navigate to /experts. | Experts page displays: Expert cards with specialization, rating, availability. Filter and search options. Loading state. | P2 |
| UW-EXP-002 | Expert Detail | Verify expert profile page | 1. Click on an expert to navigate to /experts/[expertId]. | Expert detail shows: Full profile, specialization, reviews, availability calendar, consultation rates, booking button. Loading state via loading.tsx. | P2 |
| UW-EXP-003 | Filter by Specialization | Verify filtering experts | 1. Apply specialization filter on experts page. | List filters to show experts matching the selected specialization. Multiple filters can be combined. | P2 |
| UW-EXP-004 | Booking Calendar | Verify consultation booking | 1. On expert detail, click "Book Consultation". 2. Navigate to /experts/booking/[expertId]. 3. Select date/time. 4. Confirm booking. | Booking page shows: Calendar with available slots, session duration options, pricing. On confirm: Booking created. Payment initiated. Confirmation shown. | P2 |
| UW-EXP-005 | Session Management | Verify managing booked sessions | 1. View booked sessions from profile or dashboard. | Sessions list shows: Expert name, date/time, status (Upcoming/Completed/Cancelled), join link (if virtual). Cancel option for upcoming sessions. | P2 |
| UW-EXP-006 | Review System | Verify reviewing after consultation | 1. After a completed session, submit a review. | Review form: Star rating, text feedback. On submit: Review published on expert's profile. Rating recalculated. | P2 |

### 6.7 Wallet

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| UW-WAL-001 | Wallet Page | Verify wallet page renders | 1. Navigate to /wallet. | Wallet page displays: Credit card design balance display, action buttons, transaction history. Loading state. | P1 |
| UW-WAL-002 | Balance Display | Verify credit card style balance | 1. Observe the balance card. | Balance displays in a credit card design: Current balance in INR, card number styling, user name. Visually distinctive. | P2 |
| UW-WAL-003 | Top-Up | Verify wallet top-up flow | 1. Click "Top Up" or "Add Money". 2. Enter amount. 3. Complete payment via Razorpay. | Amount input with preset options (100, 500, 1000, 5000). Razorpay payment flow. On success: Balance updates. Transaction recorded. | P1 |
| UW-WAL-004 | Send Money | Verify send money functionality | 1. Click "Send Money". 2. Enter recipient and amount. 3. Confirm. | Send money flow via /api/payments/send-money route. Recipient search/selection. Amount validation against balance. Confirmation required. | P2 |
| UW-WAL-005 | Pay Bills | Verify pay bills feature | 1. Click "Pay Bills". 2. Select an outstanding invoice/project. 3. Pay. | Outstanding bills list displays. Payment deducts from wallet balance. Bill marked as paid. | P2 |
| UW-WAL-006 | Transaction History | Verify transaction history list | 1. Scroll to transaction history section. | Chronological list of transactions: Credits (top-ups, refunds), Debits (payments, sends). Each entry shows: Amount, type, date, reference. | P1 |
| UW-WAL-007 | Rewards | Verify rewards display | 1. Observe the rewards section. | Rewards section shows: Available reward points, cashback offers, referral bonuses. Redemption options if applicable. | P3 |

### 6.8 Profile and Settings

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| UW-PROF-001 | Profile Page | Verify profile page renders | 1. Navigate to /profile. | Profile page renders: User info, avatar, stats, edit options. Loading state. Professional users see profile-pro.tsx variant. | P1 |
| UW-PROF-002 | Edit Profile | Verify profile editing | 1. Click "Edit Profile". 2. Modify name, bio, or preferences. 3. Save. | Edit form pre-fills current values. Changes save successfully. Profile updates reflected immediately. | P2 |
| UW-PROF-003 | Avatar Upload | Verify avatar image upload | 1. Click on avatar to change. 2. Select an image. 3. Confirm. | Image upload via /api/cloudinary/upload. Preview shown before confirm. Avatar updates on profile and across the platform. Delete via /api/cloudinary/delete. | P2 |
| UW-PROF-004 | Settings Page | Verify settings page | 1. Navigate to /settings. | Settings page renders: Notification preferences, privacy settings, account settings. Professional users see settings-pro.tsx variant. Loading state. | P1 |
| UW-PROF-005 | Security - Password Change | Verify password change | 1. In security settings, enter current password. 2. Enter new password. 3. Confirm. | Password validation (strength requirements). On success: Password updated. Confirmation message. | P2 |
| UW-PROF-006 | Security - 2FA | Verify two-factor authentication setup | 1. Enable 2FA in security settings. 2. Complete setup (QR code scan, verification code). | 2FA setup flow: QR code display, authenticator app pairing, verification code entry. On success: 2FA enabled. Future logins require 2FA code. | P2 |
| UW-PROF-007 | Security - Sessions | Verify active sessions management | 1. View active sessions. 2. Terminate a session. | Active sessions list: Device, location, last active. Terminate option for each session except current. | P3 |
| UW-PROF-008 | Data Export | Verify data export request | 1. In settings, click "Export My Data". | Data export request initiated. User notified when export is ready. Download link provided. | P3 |
| UW-PROF-009 | Feedback | Verify feedback submission | 1. In settings, access feedback form. 2. Submit feedback. | Feedback form: Rating, text input, category. On submit: Feedback recorded. Thank you message displayed. | P3 |
| UW-PROF-010 | Account Deletion | Verify account deletion flow | 1. In settings, click "Delete Account". 2. Read warnings. 3. Confirm. | Warning explains data loss. Confirmation requires explicit action. On confirm: Account deactivated. User logged out. Redirect to landing page. | P1 |
| UW-PROF-011 | Support Page | Verify support page | 1. Navigate to /support. | Support page renders: FAQ, ticket submission, contact options. Professional users see support-pro.tsx. Loading state. | P2 |
| UW-PROF-012 | Legal Pages | Verify legal pages render | 1. Navigate to /terms. 2. Navigate to /privacy. 3. Navigate to /open-source. | Each legal page renders content within (legal) layout. Proper formatting. Back navigation. | P3 |

---

## 7. DOER WEB (Next.js) - Test Cases

### 7.1 Authentication

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| DW-AUTH-001 | Landing Page | Verify doer web landing page | 1. Navigate to the root URL of doer-web. | Landing page renders at page.tsx with login/signup options. Professional doer branding. | P1 |
| DW-AUTH-002 | Login Page | Verify magic link login | 1. Navigate to /login. 2. Enter email. 3. Click "Send Magic Link". | Magic link sent via /api/auth/send-magic-link route. Email received with login link. Clicking link authenticates via /auth/callback. | P1 |
| DW-AUTH-003 | Registration Page | Verify 4-step registration | 1. Navigate to /register. 2. Complete Step 1: Email and Name. 3. Step 2: Profile (skills, experience). 4. Step 3: Banking details. 5. Step 4: Review and submit. | Multi-step form guides through registration. Each step validates before progression. On submit: Account created. Redirected to /pending for approval status. | P1 |
| DW-AUTH-004 | Pending Approval | Verify pending approval page | 1. After registration, observe /pending page. | Pending page displays: Status message indicating admin review. Estimated timeline. Option to check status. Also accessible at /pending-approval route. | P1 |
| DW-AUTH-005 | Auth Callback | Verify auth callback handling | 1. Click magic link from email. 2. Observe /auth/callback route. | Callback processes the auth token. Session established. Redirect to appropriate page based on user state (onboarding, activation, or dashboard). | P1 |
| DW-AUTH-006 | Session Page | Verify session management | 1. Navigate to /auth/session. | Session page handles session verification and token refresh. Redirects appropriately based on auth state. | P2 |
| DW-AUTH-007 | Logout | Verify logout flow | 1. Click logout. | Logout via /api/auth/logout route. Session cleared. Redirected to login page. | P1 |
| DW-AUTH-008 | Auth Error Handling | Verify error states | 1. Use an expired magic link. 2. Access protected routes without auth. | Auth errors render via (auth)/error.tsx. Protected routes redirect to login. Meaningful error messages displayed. | P2 |

### 7.2 Onboarding and Activation

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| DW-ONB-001 | Welcome Page | Verify onboarding welcome | 1. After approval, navigate to /welcome. | Welcome page within (onboarding) layout displays introductory content. Guided entry into the platform. | P2 |
| DW-ONB-002 | Profile Setup | Verify profile setup page | 1. Navigate to /profile-setup. | Profile setup form within (onboarding) layout: Skills selection, experience level, qualifications. Validation on required fields. On submit: Profile saved. Redirect to activation. | P1 |
| DW-ONB-003 | Training Page | Verify training module | 1. Navigate to /training within (activation) layout. | Training page displays learning modules: Videos, documents, quizzes. Progress tracking. "Mark Complete" functionality. | P1 |
| DW-ONB-004 | Quiz Page | Verify assessment quiz | 1. Navigate to /quiz within (activation) layout. | Quiz page displays MCQ questions. Submit button. Pass/fail result. On pass: Redirect to bank details. On fail: Review and retry option. | P1 |
| DW-ONB-005 | Bank Details Page | Verify bank details setup | 1. Navigate to /bank-details within (activation) layout. | Bank details form: Account holder, account number, IFSC, UPI. Validation. On submit: Details saved. Activation complete. Redirect to dashboard. | P1 |
| DW-ONB-006 | Activation Error | Verify activation error handling | 1. Trigger an error during activation. | Error page renders via (activation)/error.tsx with retry options and helpful messages. | P2 |

### 7.3 Dashboard

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| DW-DASH-001 | Dashboard Page | Verify dashboard renders | 1. Log in as activated doer. 2. Navigate to /dashboard. | Dashboard page renders via dashboard-client.tsx within (main) layout. Task overview, assigned tasks, task pool displayed. | P1 |
| DW-DASH-002 | Task Overview | Verify task statistics | 1. Observe the task overview section. | Overview shows: Active tasks count, under review count, completed count, earnings summary. | P1 |
| DW-DASH-003 | Assigned Tasks | Verify assigned tasks list | 1. Observe the assigned tasks section. | Assigned tasks display with: Title, deadline, status, action buttons. Click navigates to /projects/[id]. | P1 |
| DW-DASH-004 | Task Pool | Verify open task pool | 1. Observe the task pool section. | Available tasks display with: Title, subject, price, deadline. "Accept" button on each. Empty state when no tasks available. | P1 |
| DW-DASH-005 | Quick Actions | Verify quick action buttons | 1. Observe quick action buttons on dashboard. | Actions: View all projects, check resources, view statistics. Each navigates to the correct page. | P2 |
| DW-DASH-006 | Dashboard Error | Verify dashboard error handling | 1. Trigger a data loading error. | Error page renders via (main)/dashboard/error.tsx with retry option. | P2 |

### 7.4 Projects

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| DW-PROJ-001 | Projects Page | Verify projects page with tabs | 1. Navigate to /projects. | Projects page renders with 3 tabs: Active, Under Review, Completed. Error boundary via projects/error.tsx. | P1 |
| DW-PROJ-002 | Project Detail | Verify project detail page | 1. Click on a project to navigate to /projects/[id]. | Project detail shows: Full info, workspace controls, chat, file management, status updates. | P1 |
| DW-PROJ-003 | Grid/List/Timeline Views | Verify view toggle | 1. Toggle between Grid, List, and Timeline views. | Projects display in the selected layout. Grid: Card grid. List: Table/list format. Timeline: Chronological view. View preference persists. | P2 |
| DW-PROJ-004 | Project Workspace | Verify workspace functionality | 1. Open workspace for an active project. | Workspace provides: File upload area, work notes, progress tracking, submission button. Real-time saving if applicable. | P1 |
| DW-PROJ-005 | Submit for Review | Verify work submission | 1. Upload deliverables. 2. Click "Submit for Review". 3. Confirm. | Confirmation dialog appears. On confirm: Files submitted. Status changes to "Under Review". Success notification. | P1 |
| DW-PROJ-006 | Metrics and Analytics | Verify project metrics | 1. Observe project metrics section. | Metrics display: Time spent, files uploaded, revision count, estimated vs actual completion. | P2 |

### 7.5 Statistics and Reviews

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| DW-STAT-001 | Statistics Page | Verify statistics page | 1. Navigate to /statistics. | Statistics page renders performance analytics. Error boundary via statistics/error.tsx. | P2 |
| DW-REV-001 | Reviews Page | Verify reviews page | 1. Navigate to /reviews. | Reviews page renders: Rating analytics dashboard, review highlights, achievement cards, full reviews list. | P2 |
| DW-REV-002 | Rating Analytics | Verify rating breakdown | 1. Observe the rating analytics section. | Analytics show: Overall rating, category breakdowns (Quality, Timeliness, Communication), rating distribution chart. | P2 |
| DW-REV-003 | Achievement Cards | Verify achievement badges | 1. Observe achievement cards. | Achievement cards display earned badges: Top Rated, Fast Delivery, Consistent Quality, etc. Visual badges with descriptions. | P3 |
| DW-REV-004 | Full Reviews List | Verify scrollable reviews | 1. Scroll through the full reviews list. | All reviews display: Star rating, reviewer name, review text, date, associated project. Pagination or infinite scroll. | P2 |

### 7.6 Profile, Resources, and Settings

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| DW-PROF-001 | Profile Page | Verify profile page with tabs | 1. Navigate to /profile. | Profile page renders with tabs: Overview, Edit, Payments, Bank, Earnings, More. Error boundary via profile/error.tsx. | P1 |
| DW-PROF-002 | Edit Profile | Verify profile editing | 1. On the Edit tab, modify profile fields. 2. Save. | Editable fields: Name, skills, qualifications, bio. On save: Changes persist. Confirmation shown. | P2 |
| DW-PROF-003 | Payments Tab | Verify payment history | 1. On the Payments tab, observe payment list. | Payment history: Amount, date, project reference, status. Sortable and filterable. | P1 |
| DW-PROF-004 | Bank Tab | Verify bank details management | 1. On the Bank tab, view/edit bank details. | Current bank details displayed (partially masked). Edit option with validation. | P1 |
| DW-PROF-005 | Earnings Tab | Verify earnings display | 1. On the Earnings tab, observe earnings data. | Earnings graph, request payout button, pending vs available balance. | P1 |
| DW-PROF-006 | Request Payout | Verify payout request | 1. On earnings, click "Request Payout". 2. Enter amount. 3. Confirm. | Amount validates against available balance. On confirm: Payout request submitted. Status shows "Processing". | P1 |
| DW-RES-001 | Resources Page | Verify resources page | 1. Navigate to /resources. | Resources page renders: Tools, training materials, templates. Grid or list layout. | P2 |
| DW-SET-001 | Settings Page | Verify settings page | 1. Navigate to /settings. | Settings page renders via settings-client.tsx: Notification preferences, theme, privacy, account options. | P2 |
| DW-SET-002 | Theme Toggle | Verify dark/light theme | 1. Toggle theme in settings. | Theme switches immediately. Preference persists across sessions. | P2 |
| DW-SUP-001 | Support Page | Verify support page | 1. Navigate to /support. | Support page renders via support-client.tsx: FAQ, ticket creation, contact options. | P2 |

---

## 8. SUPERVISOR WEB (Next.js) - Test Cases

### 8.1 Authentication

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| SW-AUTH-001 | Landing Page | Verify supervisor web landing page | 1. Navigate to the root URL of superviser-web. | Landing page renders at page.tsx with trust indicators, login/register options, professional supervisor branding. | P1 |
| SW-AUTH-002 | Login Page | Verify magic link login | 1. Navigate to /login within (auth) layout. | Login form with email input. Trust indicators (security badges, encryption mentions). Magic link sent on submit. | P1 |
| SW-AUTH-003 | Registration Page | Verify registration form | 1. Navigate to /register within (auth) layout. | Registration form: Name, email, phone, expertise, qualifications, CV upload, banking details. Multi-step or single-page form. | P1 |
| SW-AUTH-004 | Pending Approval | Verify pending state | 1. After registration, observe /pending within (auth) layout. Also check /pending-approval route. | Pending page: Status message, admin review indicator. Option to check status. Email notification on approval. | P1 |
| SW-AUTH-005 | Auth Callback | Verify email confirmation | 1. Click confirmation link from email. 2. Navigate to /auth/confirm. | Confirmation page processes the auth token. Error handling via auth/confirm/error.tsx. Redirect to dashboard on success. | P1 |
| SW-AUTH-006 | Logout | Verify logout | 1. Click logout. | Logout via /api/auth/logout route. Session cleared. Redirected to landing page. | P1 |
| SW-AUTH-007 | Supervisor Setup | Verify supervisor account setup | 1. After approval, access setup route. | /api/auth/setup-supervisor route configures supervisor-specific settings and permissions. Profile populated correctly. | P2 |

### 8.2 Activation and Training

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| SW-ACT-001 | Activation Page | Verify activation page | 1. Navigate to /activation within (activation) layout. | Activation page shows training requirements, progress tracking, and next steps. | P1 |
| SW-ACT-002 | Training Page | Verify training modules | 1. Navigate to /training. | Training page within training/layout.tsx shows: Video modules, document modules, progress tracking, completion status. | P1 |
| SW-ACT-003 | Training Completion | Verify completing training | 1. View all training modules. 2. Mark as complete. | Training status updates. Quiz becomes available. Progress persists across sessions. | P1 |

### 8.3 Dashboard

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| SW-DASH-001 | Dashboard Page | Verify dashboard renders | 1. Log in as activated supervisor. 2. Navigate to /dashboard. | Dashboard page renders within (dashboard) layout: Hero greeting with illustration, status pills, analytics, quick actions, recent requests table. | P1 |
| SW-DASH-002 | Hero Section | Verify greeting and illustration | 1. Observe the hero section. | Personalized greeting with supervisor name. Professional illustration. Time-of-day appropriate greeting. | P2 |
| SW-DASH-003 | Status Pills | Verify 4 metric pills | 1. Observe status pill indicators. | Four metric pills display: New Requests, In Progress, Under Review, Completed. Values match backend data. Color-coded. | P1 |
| SW-DASH-004 | Analytics Section | Verify analytics display | 1. Observe the analytics section. | Charts and metrics showing: Revenue trends, project completion rates, response times. | P2 |
| SW-DASH-005 | Quick Actions | Verify quick action buttons | 1. Click various quick action buttons. | Actions available: View all projects, manage doers, check earnings, view messages. Each navigates correctly. | P2 |
| SW-DASH-006 | Recent Requests Table | Verify requests table with "Analyze" button | 1. Observe the recent requests table. | Table shows recent project requests with: Title, client, status, deadline, "Analyze" button. Clicking "Analyze" opens project detail or quote form. | P1 |

### 8.4 Projects

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| SW-PROJ-001 | Projects Page | Verify projects page | 1. Navigate to /projects within (dashboard) layout. | Projects page with: Status rail sidebar, pipeline snapshot, project cards. Loading state via loading.tsx. | P1 |
| SW-PROJ-002 | Status Rail Sidebar | Verify status navigation | 1. Click different statuses in the sidebar rail. | Status rail shows: All statuses with counts. Clicking a status filters project cards. Active status highlighted. | P2 |
| SW-PROJ-003 | Pipeline Snapshot | Verify pipeline overview | 1. Observe the pipeline snapshot. | Visual pipeline showing project counts at each stage. Quick overview of work distribution. | P2 |
| SW-PROJ-004 | Project Cards with Actions | Verify status-specific actions | 1. On a "New" project, observe actions. 2. On a "Paid" project, observe actions. 3. On a "Under Review" project, observe actions. | New: "Claim" or "Analyze" button. Paid: "Assign Doer" button. Under Review: "Approve" and "Reject" buttons. Actions specific to current project status. | P1 |
| SW-PROJ-005 | Project Detail | Verify project detail page | 1. Navigate to /projects/[projectId]. | Full project detail: Info, timeline, files, chat, assigned personnel, financial breakdown, action buttons. | P1 |
| SW-PROJ-006 | QC Review Modal | Verify quality check review | 1. On an "Under Review" project, click "Review". | QC review modal opens: Submitted files preview, checklist, approve/reject buttons, feedback input for rejection. | P1 |
| SW-PROJ-007 | Assign Doer Modal | Verify doer assignment | 1. On a "Paid" project, click "Assign Doer". | Doer selection modal: Available doers list with ratings, skills, availability. Search/filter. Select and confirm assignment. | P1 |
| SW-PROJ-008 | Quote Action | Verify setting a quote | 1. On a new request, set quote via actions (quote.ts server action). | Quote form: Client price, doer payout, margin calculation. Exchange rate handling via exchange-rate.ts. On submit: Quote sent to user. | P1 |
| SW-PROJ-009 | Search/Filter/Sort | Verify project management tools | 1. Search for a project. 2. Apply filters. 3. Sort results. | Search by title/ID. Filters: Status, subject, date range, doer. Sort: Date, deadline, amount. Results update in real-time. | P2 |

### 8.5 Doers Management

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| SW-DOER-001 | Doers Page | Verify doers management page | 1. Navigate to /doers within (dashboard) layout. | Expert Network hero section with availability snapshot. Doer cards list. Filters. Loading state via loading.tsx. | P1 |
| SW-DOER-002 | Availability Snapshot | Verify availability overview | 1. Observe the availability snapshot. | Summary shows: Available doers count, busy count, offline count. Visual breakdown. | P2 |
| SW-DOER-003 | Filters | Verify filter options | 1. Apply availability filter. 2. Apply rating filter. 3. Apply sort option. | Filters: Available/Busy/All. Rating: Min rating slider. Sort: Rating, Name, Projects completed. Results update immediately. | P2 |
| SW-DOER-004 | Doer Cards | Verify card content and actions | 1. Observe doer cards. | Each card shows: Avatar, name, rating, skills, availability badge, completed count. Action buttons: "Assign" and "Chat". | P2 |
| SW-DOER-005 | Doer Detail | Verify doer detail page | 1. Navigate to /doers/[doerId]. | Detail page: Full profile, performance metrics, project history, reviews, skills breakdown, action buttons. | P2 |
| SW-DOER-006 | Top Performers | Verify top performers section | 1. Observe the top performers area. | Highlighted section showing highest-rated or most productive doers. Special visual treatment. | P3 |

### 8.6 Chat

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| SW-CHAT-001 | Chat Page | Verify messages hub | 1. Navigate to /chat within (dashboard) layout. | Chat page renders: Inbox list with unread count, category tabs. Loading state via loading.tsx. | P1 |
| SW-CHAT-002 | Category Tabs | Verify chat category filtering | 1. Click "All" tab. 2. Click "Unread". 3. Click "Project-User". 4. Click "Project-Doer". 5. Click "Group". | Each tab filters the chat list: All shows everything. Unread shows only unread chats. Project-User shows client conversations. Project-Doer shows expert conversations. Group shows group chats. | P2 |
| SW-CHAT-003 | Inbox Pulse Stats | Verify chat statistics | 1. Observe inbox pulse stats. | Stats display: Total conversations, unread messages, average response time, messages today. | P3 |
| SW-CHAT-004 | Chat Room | Verify chat room | 1. Click on a chat entry to navigate to /chat/[roomId]. | Chat room displays: Message history, sender info, timestamps. Message input at bottom. File sharing capability. Real-time updates. | P1 |
| SW-CHAT-005 | Send Message | Verify message sending in chat room | 1. Type a message in the chat room. 2. Click send. | Message appears immediately. Delivered to recipient. Read status tracked. | P1 |

### 8.7 Earnings

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| SW-EARN-001 | Earnings Page | Verify earnings page | 1. Navigate to /earnings within (dashboard) layout. | Earnings page renders: Vault card, goal tracker, earnings chart, commission breakdown, transaction timeline. Loading state. | P1 |
| SW-EARN-002 | Vault Card | Verify balance vault display | 1. Observe the vault card. | Vault card shows: Total balance, available balance, pending balance. Professional vault visual design. | P1 |
| SW-EARN-003 | Goal Tracker | Verify earnings goal progress | 1. Observe the goal tracker. | Progress bar or visual showing current earnings vs monthly/weekly goal. Percentage complete. Motivational indicator. | P3 |
| SW-EARN-004 | Earnings Chart | Verify earnings visualization | 1. Observe the earnings chart. | Chart renders earnings trend over time. Interactive data points. Period selector. Axes labeled with INR and dates. | P2 |
| SW-EARN-005 | Commission Breakdown | Verify commission details | 1. Observe the commission breakdown section. | Breakdown shows: Gross earnings, platform commission, net earnings. Pie or bar chart. Percentages and INR amounts. | P2 |
| SW-EARN-006 | Transaction Timeline | Verify transaction history | 1. Observe the transaction timeline. | Chronological list: Amount, type, date, project reference, status. Visual timeline or list format. | P2 |
| SW-EARN-007 | Payout Request | Verify requesting payout | 1. Click "Request Payout" or "Withdraw". 2. Enter amount. 3. Confirm. | Amount validates against available balance. Confirmation required. On submit: Request created. Status shows "Processing". | P1 |

### 8.8 Users Management, Resources, Support, Settings, Notifications

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| SW-USER-001 | Users Page | Verify users management | 1. Navigate to /users within (dashboard) layout. | User directory with search and filters. Client cards with project counts. Loading state. | P2 |
| SW-USER-002 | User Detail | Verify user detail page | 1. Navigate to /users/[userId]. | User detail: Profile info, project history, communication history, notes. Action buttons for chat and viewing projects. | P2 |
| SW-RES-001 | Resources Page | Verify resources page | 1. Navigate to /resources within (dashboard) layout. | Resources page renders: Tools, training content, pricing guides. Loading state. | P2 |
| SW-SUP-001 | Support Page | Verify support page | 1. Navigate to /support within (dashboard) layout. | Support page: Ticket list, create ticket, FAQ. Loading state. | P2 |
| SW-SET-001 | Settings Page | Verify settings page | 1. Navigate to /settings within (dashboard) layout. | Settings page: Notification preferences, theme, privacy, account options. Loading state. | P2 |
| SW-NOTIF-001 | Notifications Page | Verify notifications page | 1. Navigate to /notifications within (dashboard) layout. | Notifications list with filters: All, Unread, Projects, Chat, Payments, System. Grouped by date. Mark as read. Loading state. | P2 |
| SW-PROF-001 | Profile Page | Verify profile page | 1. Navigate to /profile within (dashboard) layout. | Profile page: Personal info, qualifications, expertise, performance stats, reviews, edit option. Loading state. | P2 |
| SW-MSG-001 | Messages Page | Verify messages page | 1. Navigate to /messages within (dashboard) layout. | Messages page (alternate to /chat): Message hub, conversation list, quick actions. | P2 |
| SW-SEND-001 | Send Email | Verify email sending capability | 1. Trigger email via actions/send-email.ts or /api/email/send route. | Email sent successfully via backend. Delivery confirmation. Error handling for failed sends. | P2 |

---

## 9. CROSS-PLATFORM / END-TO-END TEST CASES

### 9.1 Complete Project Lifecycle

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| E2E-PROJ-001 | Step 1: User Submits Project | Verify project submission from user app/web | 1. Log in as a user (app or web). 2. Create a new project with all required details. 3. Submit. | Project created with status "Submitted". Project appears in user's project list. Supervisor receives notification. Project visible in admin dashboard. | P1 |
| E2E-PROJ-002 | Step 2: Supervisor Analyzes | Verify supervisor receives and views new request | 1. Log in as supervisor (app or web). 2. View the new request on dashboard or projects page. | New request appears in "New Requests" section (app) or project list (web). Full project details accessible. "Analyze & Quote" action available. | P1 |
| E2E-PROJ-003 | Step 3: Supervisor Sets Quote | Verify quote creation with dual pricing | 1. Supervisor taps/clicks "Analyze & Quote". 2. Enters User Quote (client price). 3. Enters Doer Payout (expert payment). 4. Submits quote. | Quote saved with both amounts. Platform margin calculated automatically. Project status changes to "Quoted". Quote stored in database. | P1 |
| E2E-PROJ-004 | Step 4: User Notified of Quote | Verify user receives quote notification | 1. After supervisor sets quote, check user's notifications. 2. User opens the project. | User receives push notification and/or email. Project detail shows quoted price. "Pay Now" button appears. | P1 |
| E2E-PROJ-005 | Step 5: User Pays | Verify payment via Razorpay | 1. User clicks "Pay Now". 2. Completes Razorpay checkout. 3. Payment is verified. | Razorpay payment processed. Payment verified via /api/payments/verify. Project status changes to "Paid". Supervisor notified. Transaction recorded in wallet/financials. | P1 |
| E2E-PROJ-006 | Step 6: Supervisor Assigns Doer | Verify doer assignment after payment | 1. Supervisor sees "Paid" project in "Ready to Assign". 2. Opens doer selection. 3. Selects a qualified doer. 4. Confirms assignment. | Doer assigned to project. Project status changes to "In Progress" or "Assigned". Doer receives notification. Project appears in doer's "Assigned Tasks". | P1 |
| E2E-PROJ-007 | Step 7: Doer Accepts Task | Verify doer acknowledges assignment | 1. Doer opens app/web. 2. Views the assigned project. 3. Accepts or opens workspace. | Doer can view full project details. Workspace accessible. Chat with supervisor available. Deadline countdown starts. | P1 |
| E2E-PROJ-008 | Step 8: Doer Works on Project | Verify workspace functionality during work | 1. Doer opens workspace. 2. Uses resources (citation builder, templates). 3. Uploads progress files. 4. Communicates via chat. | Workspace supports file upload, notes, chat. Resources are accessible. Progress is trackable. All features work during active work phase. | P1 |
| E2E-PROJ-009 | Step 9: User Tracks Draft Progress | Verify user can see project progress | 1. User checks project status on app/web. | User sees project status "In Progress". Timeline shows assignment and work-in-progress updates. Chat with supervisor available. | P2 |
| E2E-PROJ-010 | Step 10: Doer Submits Work | Verify work submission for QC | 1. Doer uploads final deliverables. 2. Adds work notes. 3. Clicks "Submit for Review". 4. Confirms. | Files uploaded successfully. Project status changes to "Under Review". Supervisor notified. Project moves to "Under Review" tab for doer. | P1 |
| E2E-PROJ-011 | Step 11: Supervisor QC Review | Verify quality check by supervisor | 1. Supervisor views the submitted work. 2. Reviews files and checklist. | Submitted files are accessible. QC checklist available. Approve and Reject actions present. Supervisor can download and review all deliverables. | P1 |
| E2E-PROJ-012a | Step 12a: Approved - Payment Released | Verify approval and payment release | 1. Supervisor clicks "Approve & Deliver". 2. Confirms. | Project status changes to "Delivered". User receives deliverable files. Doer payment is released (or queued). Supervisor commission calculated. All parties notified. | P1 |
| E2E-PROJ-012b | Step 12b: Rejected - Revision Required | Verify rejection with feedback | 1. Supervisor clicks "Reject/Revision". 2. Enters detailed feedback. 3. Submits. | Project status changes to "Revision Requested". Doer receives notification with feedback. Project returns to doer's "Active" tab with revision flag. | P1 |
| E2E-PROJ-013 | Step 13: User Receives Files | Verify user access to deliverables | 1. After approval, user checks project detail. | Deliverable files are downloadable. Project shows "Delivered" status. Auto-approval timer starts (e.g., 48 hours). | P1 |
| E2E-PROJ-014 | Step 14: User Reviews Delivery | Verify user review process | 1. User reviews the delivered files. 2. Decides to approve or request changes. | User can download and review all files. Approve and "Request Changes" options available. Rating input for satisfaction. | P1 |
| E2E-PROJ-015a | Step 15a: User Approves | Verify final user approval | 1. User clicks "Approve". 2. Submits rating/review. | Project status changes to "Completed". Rating saved. Final payment released to doer and supervisor. Invoice generated. Project moves to completed history for all parties. | P1 |
| E2E-PROJ-015b | Step 15b: User Requests Changes | Verify user change request | 1. User clicks "Request Changes". 2. Enters change details. 3. Submits. | Change request sent to supervisor. Supervisor reviews and may assign revision to doer. Project cycles back to Step 8 workflow. | P1 |
| E2E-PROJ-016 | Auto-Approval | Verify auto-approval after timer expiry | 1. Deliver a project. 2. Wait for auto-approval timer to expire (without user action). | After timer expires: Project auto-approves. Payment released. User notified of auto-approval. Status changes to "Completed". | P1 |

### 9.2 Payment Flow

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| E2E-PAY-001 | Razorpay Integration | Verify end-to-end Razorpay payment | 1. User initiates payment for a quoted project. 2. Complete Razorpay checkout with test card. 3. Verify payment. | Order created via /api/payments/create-order. Payment captured by Razorpay. Verification via /api/payments/verify. Transaction recorded. Project status updated. | P1 |
| E2E-PAY-002 | Wallet Top-Up | Verify wallet funding | 1. User navigates to wallet. 2. Clicks "Top Up". 3. Enters amount. 4. Completes Razorpay payment. | Wallet balance increases by the top-up amount. Transaction recorded as "Credit". Razorpay payment verified. | P1 |
| E2E-PAY-003 | Wallet Payment | Verify paying for project with wallet | 1. User with sufficient wallet balance selects "Pay with Wallet" for a quoted project. | Balance deducted. Transaction recorded as "Debit". Project status updates to "Paid". Insufficient balance blocked with top-up prompt. | P1 |
| E2E-PAY-004 | Doer Payout | Verify doer receives payment | 1. Complete a project through full lifecycle. 2. Check doer's earnings. | Doer's pending earnings increase after project completion. Payout amount matches the doer payout set by supervisor. Payment history updated. | P1 |
| E2E-PAY-005 | Supervisor Commission | Verify supervisor receives commission | 1. Complete a project through full lifecycle. 2. Check supervisor's earnings. | Supervisor's earnings increase by the commission amount (margin between user quote and doer payout minus platform fee). Commission visible in earnings breakdown. | P1 |
| E2E-PAY-006 | Commission Calculation | Verify platform fee calculation | 1. Set a user quote of 1000 INR and doer payout of 600 INR. 2. Complete the project. 3. Check all financial entries. | Platform fee calculated correctly. Supervisor commission = User Quote - Doer Payout - Platform Fee. All amounts reconcile in admin financial dashboard. | P1 |
| E2E-PAY-007 | Payout Request Processing | Verify doer/supervisor withdrawal | 1. Doer/supervisor requests payout. 2. Admin processes the payout. | Payout request appears in admin financials. Processing updates available balance. Transaction marked as "Completed" after processing. | P1 |
| E2E-PAY-008 | Refund Processing | Verify refund for cancelled project | 1. Cancel a paid project. 2. Process refund. | Refund initiated via appropriate API. User wallet credited or Razorpay refund processed. Transaction recorded. Admin financial summary updated. | P1 |
| E2E-PAY-009 | Partial Payment | Verify partial payment flow | 1. User makes partial payment for a project. 2. Completes remaining payment later. | Partial payment recorded via /api/payments/partial-pay. Remaining balance displayed. Project proceeds when fully paid. Both transactions recorded. | P2 |
| E2E-PAY-010 | Send Money | Verify peer-to-peer money transfer | 1. User sends money to another user via wallet. | Transfer processed via /api/payments/send-money. Sender balance decreases. Recipient balance increases. Both transactions recorded. | P2 |

### 9.3 Chat System

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| E2E-CHAT-001 | User-Supervisor Chat | Verify user can chat with supervisor | 1. User opens a project chat. 2. Sends a message. 3. Supervisor receives it. 4. Supervisor replies. | Messages flow bidirectionally in real-time. Both parties see messages instantly. Chat context tied to the project. | P1 |
| E2E-CHAT-002 | Supervisor-Doer Chat | Verify supervisor can chat with doer | 1. Supervisor opens chat with assigned doer. 2. Sends instructions. 3. Doer receives and replies. | Messages flow bidirectionally. Chat accessible from both supervisor and doer apps/web. Project context maintained. | P1 |
| E2E-CHAT-003 | Three-Way Communication | Verify all three parties can communicate on a project | 1. User sends message to supervisor. 2. Supervisor sends to doer. 3. Doer replies to supervisor. 4. Supervisor relays to user. | All communication flows through supervisor. User and doer do not have direct chat (by design). Supervisor mediates all communication. | P1 |
| E2E-CHAT-004 | Real-Time Messaging | Verify real-time message delivery | 1. Open chat on two devices simultaneously. 2. Send messages from both sides. | Messages appear in real-time (< 2 second delay) via Supabase Realtime subscriptions. No manual refresh needed. | P1 |
| E2E-CHAT-005 | File Sharing in Chat | Verify file attachment delivery | 1. Send a file (image, PDF, document) in chat. | File uploads with progress indicator. File message appears in chat. Recipient can download the file. File stored in Supabase Storage. | P2 |
| E2E-CHAT-006 | Contact Information Blocking | Verify personal details are blocked | 1. In chat, send a message containing a phone number (e.g., "Call me at 9876543210"). 2. Send a message with an email address. | System detects contact information. Message is blocked, filtered, or flagged. Warning shown to sender about policy violation. | P1 |
| E2E-CHAT-007 | Read Receipts | Verify message read status | 1. Send a message. 2. Recipient opens the chat. | Sender sees read receipt indicator (e.g., double check marks, "Read" status) after recipient views the message. | P3 |
| E2E-CHAT-008 | Chat Push Notifications | Verify push notification for new messages | 1. Send a message when recipient has the app backgrounded or closed. | Recipient receives a push notification with: Sender name, message preview. Tapping notification opens the relevant chat. | P1 |
| E2E-CHAT-009 | Cross-Platform Chat Sync | Verify chat syncs between app and web | 1. Send a message from the mobile app. 2. Check the web platform. | Message appears on both mobile app and web platform. Read status syncs. File attachments accessible on both platforms. | P1 |

### 9.4 Notification System

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| E2E-NOTIF-001 | Push Notifications | Verify push notifications across platforms | 1. Trigger a notification event (e.g., project status change). 2. Check all relevant platforms (user app, doer app, supervisor app, web). | Push notification delivered to all relevant parties on the correct platforms. Notification contains: Title, body, action URL. Subscribe route /api/notifications/subscribe handles registration. | P1 |
| E2E-NOTIF-002 | WhatsApp Notifications | Verify WhatsApp notification for critical updates | 1. Trigger a critical event (e.g., payment received, project delivered). 2. Check WhatsApp. | WhatsApp notification sent via /api/notifications/whatsapp route. Message contains relevant details. Only for critical updates. | P2 |
| E2E-NOTIF-003 | Email Notifications | Verify email notifications | 1. Trigger a notification event. 2. Check email inbox. | Email notification sent with: Subject line, body content, action links. Formatted HTML email. Unsubscribe option. | P2 |
| E2E-NOTIF-004 | Notification Preferences | Verify preference settings are respected | 1. Disable push notifications in settings. 2. Trigger a notification event. 3. Re-enable and trigger again. | Disabled: No push notification received. Enabled: Push notification received. Preferences respected across all notification types (push, email, WhatsApp). | P2 |
| E2E-NOTIF-005 | Quiet Hours | Verify quiet hours enforcement | 1. Set quiet hours (e.g., 10 PM to 7 AM). 2. Trigger a notification during quiet hours. 3. Trigger during active hours. | Quiet hours: Notification silenced or deferred. Active hours: Normal delivery. Critical notifications may bypass quiet hours. | P3 |

### 9.5 Authentication Across Platforms

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| E2E-AUTH-001 | Google OAuth Consistency | Verify Google OAuth on all platforms | 1. Sign up with Google on user app. 2. Log in with same Google account on user web. 3. Try on doer web. | Same Google account works across platforms. Profile data syncs. Platform determines user role correctly. | P1 |
| E2E-AUTH-002 | Magic Link Across Platforms | Verify magic link works on all web platforms | 1. Request magic link on user-web. 2. Request on doer-web. 3. Request on superviser-web. | Magic link emails sent from each platform. Links authenticate correctly on the respective platform. Links do not cross-authenticate (user link does not work on doer-web). | P1 |
| E2E-AUTH-003 | Admin Bypass Login | Verify admin bypass mechanism | 1. Use admin bypass login on each platform. | Admin bypass authentication works as configured. Bypasses normal auth flow for testing. Restricted to authorized admin accounts. | P1 |
| E2E-AUTH-004 | Session Management | Verify sessions across platforms | 1. Log in on mobile app. 2. Log in on web simultaneously. 3. Log out from one platform. | Both sessions active simultaneously. Logging out of one platform does not affect the other. Session tokens independent per platform. | P1 |
| E2E-AUTH-005 | Activation Gating - Doer | Verify doer activation requirement | 1. Register a new doer. 2. Try accessing dashboard before completing activation. 3. Complete all activation steps. 4. Access dashboard. | Before activation: Dashboard locked. ActivationGateScreen shown. After activation: Full dashboard access. Consistent behavior on app and web. | P1 |
| E2E-AUTH-006 | Activation Gating - Supervisor | Verify supervisor activation requirement | 1. Register a new supervisor. 2. Wait for admin approval. 3. Complete training and quiz. 4. Access dashboard. | Before approval: Pending screen. After approval: Activation screen. After training/quiz: Full access. Consistent on app and web. | P1 |

### 9.6 Data Consistency

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| E2E-DATA-001 | Project Status Sync | Verify project status is consistent across all platforms | 1. Change project status from supervisor app. 2. Check user app. 3. Check doer app. 4. Check admin web. 5. Check all web platforms. | Status change reflects on all platforms within seconds. No stale data after refresh. All platforms show the same current status. | P1 |
| E2E-DATA-002 | Wallet Balance Consistency | Verify wallet balance matches across platforms | 1. Top up wallet on user web. 2. Check balance on user app. 3. Make a payment on the app. 4. Check balance on web. | Balance is consistent across app and web after each transaction. No discrepancies. Real-time or near-real-time sync. | P1 |
| E2E-DATA-003 | Chat Message Sync | Verify chat messages appear on all platforms | 1. Send a message from doer app. 2. Check supervisor app. 3. Check supervisor web. | Message appears on all platforms where the chat is accessible. Timestamps consistent. File attachments accessible everywhere. | P1 |
| E2E-DATA-004 | Notification Sync | Verify notifications appear consistently | 1. Trigger a notification. 2. Read it on one platform. 3. Check other platforms. | Notification appears on all platforms. Marking as read on one platform reflects on others. Unread counts update everywhere. | P2 |
| E2E-DATA-005 | Profile Data Sync | Verify profile changes sync | 1. Edit profile on doer app. 2. Check doer web. 3. Check supervisor view of the doer. | Profile changes reflect on all platforms. Supervisor sees updated doer info. Admin panel shows updated profile. | P2 |
| E2E-DATA-006 | Concurrent Operations | Verify data integrity under concurrent access | 1. Two supervisors try to claim the same project simultaneously. 2. User pays while supervisor modifies quote. | Only one supervisor successfully claims the project. Race conditions handled with proper locking or conflict resolution. Optimistic concurrency controls in place. | P1 |

---

## 10. NON-FUNCTIONAL TEST CASES

### 10.1 Performance

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| NF-PERF-001 | App Launch Time | Verify app cold start under 3 seconds | 1. Force-close the doer/supervisor app. 2. Launch and time until interactive. | Cold start completes in under 3 seconds on mid-range devices. Splash screen displays during initialization. | P1 |
| NF-PERF-002 | Screen Transition | Verify screen transition under 300ms | 1. Navigate between screens (dashboard to projects, projects to detail). 2. Measure transition time. | Screen transitions complete within 300ms. No visible lag or frame drops. Animations at 60fps. | P2 |
| NF-PERF-003 | API Response Time | Verify API responses under 2 seconds | 1. Monitor API calls during normal app usage. 2. Time responses for key endpoints (dashboard, projects, chat). | 95th percentile API response time under 2 seconds. Loading indicators appear for longer operations. Timeouts handled gracefully. | P1 |
| NF-PERF-004 | Image Loading | Verify image loading with caching | 1. Load a screen with multiple images. 2. Navigate away and return. 3. Observe load times on return. | First load: Images load with placeholders. Second load: Images load from cache instantly. Cache headers properly configured. | P2 |
| NF-PERF-005 | Infinite Scroll | Verify scroll performance with large datasets | 1. On projects or community feed, scroll through 100+ items. 2. Monitor frame rate and memory. | Scroll remains smooth at 60fps. No memory leaks. Items outside viewport are recycled/virtualized. No app crashes. | P2 |
| NF-PERF-006 | Web Page Load (LCP) | Verify Largest Contentful Paint under 2.5 seconds | 1. Load each web platform's main page. 2. Measure LCP using Lighthouse or WebPageTest. | LCP under 2.5 seconds. Server-side rendering (Next.js) provides fast initial paint. Loading states (loading.tsx) display during hydration. | P2 |
| NF-PERF-007 | Web Bundle Size | Verify JavaScript bundle optimization | 1. Analyze bundle size using Next.js build output. 2. Check for code splitting. | Bundle is tree-shaken and code-split. No unnecessarily large dependencies. Lazy loading for heavy components. | P3 |
| NF-PERF-008 | Database Query Performance | Verify Supabase query performance | 1. Monitor query execution times for RPC calls (get_admin_dashboard_stats, etc.). 2. Check for N+1 queries. | RPC calls complete in under 500ms. No N+1 query patterns. Indexes on frequently queried columns. | P2 |

### 10.2 Security

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| NF-SEC-001 | Token Handling | Verify authentication tokens are stored securely | 1. Inspect token storage on mobile (secure storage). 2. Inspect token storage on web (httpOnly cookies). | Mobile: Tokens in secure/encrypted storage, not in SharedPreferences. Web: Tokens in httpOnly, Secure cookies. No tokens in localStorage or URL params. | P1 |
| NF-SEC-002 | Sensitive Data Encryption | Verify sensitive data (bank details, passwords) are encrypted | 1. Inspect database storage for bank details. 2. Check password handling. | Bank details encrypted at rest. Passwords hashed (not stored in plain text). Supabase handles password hashing. API responses do not expose full account numbers. | P1 |
| NF-SEC-003 | Input Sanitization - XSS | Verify protection against XSS attacks | 1. Enter `<script>alert('XSS')</script>` in text fields (name, project description, chat). 2. Submit and view the output. | Script tags are sanitized or escaped. No JavaScript execution from user input. HTML entities properly encoded in display. React/Flutter inherently escape by default. | P1 |
| NF-SEC-004 | Input Sanitization - SQL Injection | Verify protection against SQL injection | 1. Enter `'; DROP TABLE profiles; --` in search and form fields. 2. Submit. | Input is parameterized by Supabase client library. No raw SQL execution from user input. Query fails safely or input is sanitized. | P1 |
| NF-SEC-005 | File Upload Validation | Verify file upload restrictions | 1. Try uploading an executable (.exe) file. 2. Try uploading a file exceeding the size limit. 3. Upload a valid file. | Executable: Rejected with "Invalid file type" error. Oversized: Rejected with "File too large" error. Valid: Accepted. File type and size validated on both client and server. | P1 |
| NF-SEC-006 | Rate Limiting | Verify rate limiting on auth and API endpoints | 1. Send 50+ login attempts in rapid succession. 2. Send 100+ API requests in a short period. | Auth: Account lockout or CAPTCHA after N failed attempts. API: Rate limit response (429 Too Many Requests) after threshold. Supabase built-in rate limiting active. | P1 |
| NF-SEC-007 | Contact Blocking | Verify contact information cannot be shared in chat | 1. Send phone numbers, email addresses, social media handles in chat messages. | Personal contact details detected and blocked or flagged. Users warned about policy. Repeated violations may trigger account review. | P1 |
| NF-SEC-008 | Admin Route Protection | Verify admin routes cannot be accessed by non-admins | 1. As a regular user, try navigating to admin-web URLs. 2. Try API calls to admin endpoints. | All admin routes protected by authentication and authorization middleware. Non-admin users receive 401/403. No admin data exposed. | P1 |
| NF-SEC-009 | Role-Based Access | Verify users cannot access other role's features | 1. As a "user" role, try accessing doer endpoints. 2. As a doer, try accessing supervisor endpoints. | Cross-role access blocked. Supabase RLS (Row Level Security) policies enforce data isolation. Each role sees only authorized data. | P1 |

### 10.3 Accessibility

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| NF-A11Y-001 | Screen Reader | Verify screen reader compatibility on mobile apps | 1. Enable VoiceOver (iOS) or TalkBack (Android). 2. Navigate through the doer and supervisor apps. | All interactive elements have accessibility labels. Screen order is logical. Actions are announced. Custom widgets have proper semantics. | P2 |
| NF-A11Y-002 | Touch Target Size | Verify minimum touch target of 48x48dp | 1. Using accessibility scanner, check all interactive elements (buttons, toggles, links). | All touch targets meet the 48x48dp minimum. Small icons have extended touch areas. No elements are too small to tap accurately. | P2 |
| NF-A11Y-003 | Color Contrast | Verify WCAG AA color contrast ratios | 1. Test text/background contrast ratios across all themes (light and dark). | Normal text: Minimum 4.5:1 contrast ratio. Large text: Minimum 3:1. UI components: Minimum 3:1. Status badges and urgency indicators are distinguishable. | P2 |
| NF-A11Y-004 | Reduced Motion | Verify reduced motion support | 1. Enable "Reduce Motion" in device accessibility settings. 2. Navigate through the app. | Animations are reduced or disabled. Page transitions use simple fades instead of slides. Carousel auto-play stops. No motion-triggered content. | P3 |
| NF-A11Y-005 | Keyboard Navigation (Web) | Verify full keyboard navigation on web platforms | 1. On each web platform, navigate using Tab, Enter, and Arrow keys. 2. Verify focus indicators. | All interactive elements are tab-focusable. Focus indicator is visible. Enter activates buttons. Escape closes modals. Logical tab order. Skip navigation link present. | P2 |
| NF-A11Y-006 | Form Labels | Verify all form fields have associated labels | 1. Inspect forms across all platforms with accessibility tools. | Every input field has an associated label (visible or aria-label). Error messages are linked to their fields. Required fields are indicated. | P2 |

### 10.4 Compatibility

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| NF-COMPAT-001 | iOS Devices | Verify doer and supervisor apps on iOS 16+ (iPhone 12+) | 1. Install and run both apps on iPhone 12, 13, 14, 15 series. 2. Test core flows. | Apps function correctly on all supported iOS devices. UI adapts to different screen sizes (including notch/Dynamic Island). No crashes. | P1 |
| NF-COMPAT-002 | Android Devices | Verify apps on Android API 24+ | 1. Install and run both apps on devices with Android 7.0+. 2. Test on Samsung, Pixel, OnePlus devices. | Apps function correctly across Android versions and OEMs. Material Design renders correctly. No vendor-specific crashes. | P1 |
| NF-COMPAT-003 | Chrome Browser | Verify all web platforms on Chrome (latest 3 versions) | 1. Open each web platform on Chrome. 2. Test core flows. | All pages render correctly. No console errors. Features work as expected. SSR and CSR both function. | P1 |
| NF-COMPAT-004 | Safari Browser | Verify all web platforms on Safari (latest 2 versions) | 1. Open each web platform on Safari (macOS and iOS). 2. Test core flows. | All pages render correctly. Safari-specific CSS handled. Payment modals work. No WebKit-specific issues. | P1 |
| NF-COMPAT-005 | Firefox Browser | Verify all web platforms on Firefox | 1. Open each web platform on Firefox. 2. Test core flows. | All pages render correctly. No Firefox-specific rendering issues. Forms and modals work. | P2 |
| NF-COMPAT-006 | Edge Browser | Verify all web platforms on Edge | 1. Open each web platform on Microsoft Edge. 2. Test core flows. | All pages render correctly. Chromium-based Edge compatible with Chrome behavior. | P2 |
| NF-COMPAT-007 | Responsive Design - Mobile | Verify web platforms on mobile viewport (320px-480px) | 1. Open web platforms on mobile browser or using browser DevTools mobile emulation. | Layout adapts to mobile viewport. No horizontal scrolling. Touch-friendly elements. Text readable without zooming. Navigation collapses to mobile pattern. | P1 |
| NF-COMPAT-008 | Responsive Design - Tablet | Verify web platforms on tablet viewport (768px-1024px) | 1. Open web platforms on tablet or tablet emulation. | Layout adapts with appropriate column counts. Sidebars may collapse. Content fills available space. Touch and mouse both work. | P2 |
| NF-COMPAT-009 | Responsive Design - Desktop | Verify web platforms on desktop viewport (1280px+) | 1. Open web platforms on standard desktop resolution. | Full layout renders: Sidebars, multi-column grids, full navigation. Proper use of whitespace. No elements overflowing. | P1 |

### 10.5 Offline and Network

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| NF-NET-001 | Offline Mode | Verify app behavior when offline | 1. Put device in airplane mode. 2. Open the doer/supervisor app. 3. Try navigating between screens. | App shows cached data where available. Offline indicator displayed. Network-dependent actions show "No internet connection" message. App does not crash. | P1 |
| NF-NET-002 | Network Error States | Verify error states with retry | 1. Simulate network timeout (slow network). 2. Observe error handling. | Error screens display with user-friendly messages. "Retry" button present. Error boundaries (error.tsx on web, try-catch on mobile) catch failures. No raw error messages shown to users. | P1 |
| NF-NET-003 | Reconnection | Verify reconnection after network loss | 1. Start a data-loading operation. 2. Disable network mid-operation. 3. Re-enable network. | App detects reconnection. Pending operations retry automatically or prompt user. Supabase Realtime reconnects. Chat messages sync. | P1 |
| NF-NET-004 | Data Sync After Reconnection | Verify data freshness after reconnection | 1. Go offline. 2. Another user makes changes to shared data (project status, chat). 3. Come back online. | After reconnection: Data refreshes to latest state. Missed chat messages load. Notification count updates. No data conflicts or loss. | P2 |
| NF-NET-005 | Slow Network Handling | Verify behavior on 2G/3G networks | 1. Throttle network to 2G speed. 2. Perform core operations. | Loading indicators appear. Operations complete (slower but successful). No timeouts for critical operations. Images may load at lower quality. | P2 |

### 10.6 Localization

| Test ID | Feature | Test Case | Steps to Test | Expected Result | Priority |
|---------|---------|-----------|---------------|-----------------|----------|
| NF-L10N-001 | Multi-Language Support | Verify language switching on mobile apps | 1. Change language in settings (both doer and supervisor apps). 2. Navigate through all screens. | All UI text translates to the selected language via TranslationProvider/.tr(context). No untranslated strings. Layout adapts to text length. | P2 |
| NF-L10N-002 | RTL Layout | Verify right-to-left layout support | 1. Select an RTL language (Arabic, Hebrew, etc.) if supported. 2. Observe layout direction. | Layout mirrors: Navigation on right, text aligned right. Icons and arrows flip. No overlapping elements. Proper RTL reading order. | P3 |
| NF-L10N-003 | Date/Time Localization | Verify date and time format adapts to locale | 1. Change device locale. 2. Observe date/time displays (deadlines, timestamps, transaction dates). | Dates display in locale-appropriate format (DD/MM/YYYY vs MM/DD/YYYY). Times in 12h or 24h format per locale. Timezone offsets correct. | P2 |
| NF-L10N-004 | Currency Formatting (INR) | Verify INR currency formatting | 1. Observe all monetary values across the platform (prices, earnings, wallet balance). | All amounts display with INR symbol or "INR" prefix. Indian number formatting (lakhs/crores) or international formatting as configured. Decimal places consistent (2 decimal places). | P1 |
| NF-L10N-005 | Long Text Handling | Verify UI handles translated text of varying lengths | 1. Switch to a language with longer average word lengths (e.g., German). 2. Check all buttons, labels, and headers. | Text does not overflow containers. Buttons expand or text wraps appropriately. No truncation without ellipsis. Layout remains visually correct. | P3 |

---

## APPENDIX: Test Summary

### Total Test Case Count by Section

| Section | Subsection Count | Test Case Count |
|---------|-----------------|-----------------|
| 3. Doer App (Mobile) | 9 sections | 105 test cases |
| 4. Supervisor App (Mobile) | 13 sections | 100 test cases |
| 5. Admin Web | 12 sections | 53 test cases |
| 6. User Web | 8 sections | 62 test cases |
| 7. Doer Web | 6 sections | 36 test cases |
| 8. Supervisor Web | 8 sections | 40 test cases |
| 9. Cross-Platform E2E | 6 sections | 50 test cases |
| 10. Non-Functional | 6 sections | 37 test cases |
| **TOTAL** | **68 sections** | **514 unique test cases** |

### Priority Distribution

| Priority | Count | Percentage |
|----------|-------|------------|
| P1 (Critical) | 231 | 45% |
| P2 (Major) | 229 | 45% |
| P3 (Minor) | 54 | 10% |

### Test Execution Order Recommendation

1. **Phase 1 - Core Auth and Activation**: All authentication tests (DA-ONB, SA-ONB, AW-AUTH, UW-AUTH, DW-AUTH, SW-AUTH), activation flows (DA-ACT, SA-ACT)
2. **Phase 2 - Dashboard and Navigation**: All dashboard tests, drawer/navigation tests across all platforms
3. **Phase 3 - Project Lifecycle (E2E)**: E2E-PROJ-001 through E2E-PROJ-016 end-to-end
4. **Phase 4 - Payment Flow**: E2E-PAY-001 through E2E-PAY-010
5. **Phase 5 - Chat and Notifications**: E2E-CHAT, E2E-NOTIF, all platform-specific chat tests
6. **Phase 6 - Platform-Specific Features**: Resources, community, campus connect, profile, settings per platform
7. **Phase 7 - Admin Operations**: All admin web tests (AW-*)
8. **Phase 8 - Non-Functional**: Performance, security, accessibility, compatibility, network, localization

---

*Document generated for AssignX QA Team. All test cases map to actual implemented screens and routes verified from the codebase.*
