# Components Documentation

> **AdminX Supervisor Panel** - Component Reference

## Table of Contents

1. [Component Organization](#component-organization)
2. [Activation Components](#activation-components)
3. [Auth Components](#auth-components)
4. [Chat Components](#chat-components)
5. [Dashboard Components](#dashboard-components)
6. [Doers Components](#doers-components)
7. [Earnings Components](#earnings-components)
8. [Layout Components](#layout-components)
9. [Notifications Components](#notifications-components)
10. [Onboarding Components](#onboarding-components)
11. [Profile Components](#profile-components)
12. [Projects Components](#projects-components)
13. [Resources Components](#resources-components)
14. [Settings Components](#settings-components)
15. [Shared Components](#shared-components)
16. [Support Components](#support-components)
17. [Users Components](#users-components)
18. [UI Components](#ui-components)

---

## Component Organization

Each component module follows this structure:

```
components/
└── module-name/
    ├── index.ts           # Barrel exports
    ├── types.ts           # TypeScript interfaces
    ├── component-name.tsx # Component files
    └── sub-component.tsx  # Sub-components
```

---

## Activation Components

**Path:** `components/activation/`

Components for the supervisor activation flow (quiz and training).

### ActivationLock

Displays when supervisor needs to complete activation.

```tsx
import { ActivationLock } from "@/components/activation"

<ActivationLock
  onStartActivation={() => router.push('/activation')}
/>
```

### SupervisorQuiz

Interactive quiz component for supervisor certification.

```tsx
import { SupervisorQuiz } from "@/components/activation"

<SupervisorQuiz
  onComplete={(score, passed) => handleQuizComplete(score, passed)}
  requiredScore={80}
/>
```

**Props:**
| Prop | Type | Description |
|------|------|-------------|
| onComplete | (score: number, passed: boolean) => void | Callback when quiz finishes |
| requiredScore | number | Minimum passing score (default: 80) |

### TrainingViewer

Video training viewer with progress tracking.

```tsx
import { TrainingViewer } from "@/components/activation"

<TrainingViewer
  videos={trainingVideos}
  onVideoComplete={(videoId) => markVideoComplete(videoId)}
  onAllComplete={() => router.push('/activation/quiz')}
/>
```

### QuizResults

Displays quiz results with pass/fail status.

```tsx
import { QuizResults } from "@/components/activation"

<QuizResults
  score={85}
  passed={true}
  onRetry={() => restartQuiz()}
  onContinue={() => router.push('/dashboard')}
/>
```

### WelcomeScreen

Welcome screen for new supervisors starting activation.

```tsx
import { WelcomeScreen } from "@/components/activation"

<WelcomeScreen
  supervisorName="John Doe"
  onStart={() => startTraining()}
/>
```

---

## Auth Components

**Path:** `components/auth/`

Authentication form components.

### LoginForm

Login form with email/password and OAuth options.

```tsx
import { LoginForm } from "@/components/auth"

<LoginForm
  onSuccess={() => router.push('/dashboard')}
  onRegisterClick={() => router.push('/register')}
/>
```

### RegisterForm

Registration form for new supervisors.

```tsx
import { RegisterForm } from "@/components/auth"

<RegisterForm
  onSuccess={() => router.push('/onboarding')}
  onLoginClick={() => router.push('/login')}
/>
```

---

## Chat Components

**Path:** `components/chat/`

Real-time chat functionality components.

### ChatWindow

Main chat window with message list and input.

```tsx
import { ChatWindow } from "@/components/chat"

<ChatWindow
  roomId="room-123"
  currentUserId={userId}
  currentUserType="supervisor"
/>
```

**Props:**
| Prop | Type | Description |
|------|------|-------------|
| roomId | string | Chat room ID |
| currentUserId | string | Current user's ID |
| currentUserType | "user" \| "supervisor" \| "doer" | User role |

### MessageList

Scrollable list of chat messages.

```tsx
import { MessageList } from "@/components/chat"

<MessageList
  messages={messages}
  currentUserId={userId}
/>
```

### MessageInput

Message input with attachment support.

```tsx
import { MessageInput } from "@/components/chat"

<MessageInput
  onSend={(content, attachments) => sendMessage(content, attachments)}
  disabled={isLoading}
/>
```

---

## Dashboard Components

**Path:** `components/dashboard/`

Main dashboard widgets and cards.

### StatsCards

Overview statistics cards.

```tsx
import { StatsCards } from "@/components/dashboard"

<StatsCards
  stats={{
    activeProjects: 12,
    pendingRequests: 5,
    completedToday: 3,
    totalEarnings: 45000
  }}
/>
```

### NewRequestsSection

Section displaying new project requests needing quotes.

```tsx
import { NewRequestsSection } from "@/components/dashboard"

<NewRequestsSection
  requests={pendingRequests}
  onAnalyze={(request) => openQuoteModal(request)}
/>
```

### ReadyToAssignSection

Projects ready to be assigned to doers.

```tsx
import { ReadyToAssignSection } from "@/components/dashboard"

<ReadyToAssignSection
  projects={paidProjects}
  onAssign={(project) => openAssignModal(project)}
/>
```

### RequestCard

Individual project request card.

```tsx
import { RequestCard } from "@/components/dashboard"

<RequestCard
  request={request}
  onViewDetails={() => viewRequest(request.id)}
  onAnalyze={() => analyzeRequest(request.id)}
/>
```

### AnalyzeQuoteModal

Modal for analyzing requests and setting quotes.

```tsx
import { AnalyzeQuoteModal } from "@/components/dashboard"

<AnalyzeQuoteModal
  request={selectedRequest}
  isOpen={isOpen}
  onClose={() => setIsOpen(false)}
  onSubmitQuote={(quote) => submitQuote(quote)}
/>
```

### AssignDoerModal

Modal for assigning doers to projects.

```tsx
import { AssignDoerModal } from "@/components/dashboard"

<AssignDoerModal
  project={selectedProject}
  isOpen={isOpen}
  onClose={() => setIsOpen(false)}
  onAssign={(projectId, doerId) => assignDoer(projectId, doerId)}
/>
```

### AvailabilityToggle

Toggle for supervisor availability status.

```tsx
import { AvailabilityToggle } from "@/components/dashboard"

<AvailabilityToggle
  isAvailable={isAvailable}
  onToggle={(status) => updateAvailability(status)}
/>
```

### DoerReviews

Display recent doer reviews.

```tsx
import { DoerReviews } from "@/components/dashboard"

<DoerReviews
  reviews={recentReviews}
  limit={5}
/>
```

---

## Doers Components

**Path:** `components/doers/`

Doer management components.

### DoerList

Filterable list of doers.

```tsx
import { DoerList } from "@/components/doers"

<DoerList />
```

Features:
- Search by name, skills, subjects
- Filter by availability, verification status
- Sort by rating, projects, name
- Click to view details

### DoerCard

Individual doer card.

```tsx
import { DoerCard } from "@/components/doers"

<DoerCard
  doer={doer}
  onClick={() => viewDoerDetails(doer.id)}
/>
```

### DoerDetails

Detailed doer profile sheet.

```tsx
import { DoerDetails } from "@/components/doers"

<DoerDetails
  doer={selectedDoer}
  open={isOpen}
  onOpenChange={setIsOpen}
  onBlacklistChange={(id, status, reason) => handleBlacklist(id, status, reason)}
/>
```

---

## Earnings Components

**Path:** `components/earnings/`

Earnings and payment tracking components.

### EarningsSummary

Summary cards showing earnings overview.

```tsx
import { EarningsSummary } from "@/components/earnings"

<EarningsSummary
  totalEarnings={125000}
  thisMonth={28500}
  pending={12000}
  growth={14.5}
/>
```

### EarningsGraph

Interactive chart showing earnings trends.

```tsx
import { EarningsGraph } from "@/components/earnings"

<EarningsGraph />
```

Features:
- Monthly/Weekly view toggle
- Area/Bar/Line chart types
- Earnings and commission breakdown

### PaymentLedger

Transaction history table.

```tsx
import { PaymentLedger } from "@/components/earnings"

<PaymentLedger
  transactions={transactions}
  onExport={() => exportToCSV()}
/>
```

### CommissionTracking

Commission breakdown by project.

```tsx
import { CommissionTracking } from "@/components/earnings"

<CommissionTracking
  commissions={commissionData}
/>
```

---

## Layout Components

**Path:** `components/layout/`

App layout structure components.

### AppSidebar

Main navigation sidebar.

```tsx
import { AppSidebar } from "@/components/layout"

<AppSidebar />
```

Navigation items:
- Dashboard
- Projects
- Chat
- Doers
- Earnings
- Resources
- Profile
- Settings
- Support

### Header

Top header with user menu and notifications.

```tsx
import { Header } from "@/components/layout"

<Header />
```

Features:
- Sidebar toggle
- Search
- Notifications bell
- User dropdown menu

---

## Notifications Components

**Path:** `components/notifications/`

Notification management components.

### NotificationList

List of all notifications.

```tsx
import { NotificationList } from "@/components/notifications"

<NotificationList />
```

Features:
- Filter by type (all, unread, projects, chat, etc.)
- Mark as read
- Batch actions

### NotificationItem

Individual notification item.

```tsx
import { NotificationItem } from "@/components/notifications"

<NotificationItem
  notification={notification}
  onClick={() => handleClick(notification)}
  onMarkRead={() => markAsRead(notification.id)}
/>
```

---

## Onboarding Components

**Path:** `components/onboarding/`

Multi-step onboarding flow components.

### OnboardingSlides

Welcome slides introducing the platform.

```tsx
import { OnboardingSlides } from "@/components/onboarding"

<OnboardingSlides
  onComplete={() => goToNextStep()}
/>
```

### ProfessionalProfileForm

Step 1: Professional information form.

```tsx
import { ProfessionalProfileForm } from "@/components/onboarding"

<ProfessionalProfileForm
  onSubmit={(data) => saveProfile(data)}
  defaultValues={existingData}
/>
```

### BankingForm

Step 2: Banking details form.

```tsx
import { BankingForm } from "@/components/onboarding"

<BankingForm
  onSubmit={(data) => saveBankingDetails(data)}
/>
```

### ApplicationSubmit

Step 3: Review and submit application.

```tsx
import { ApplicationSubmit } from "@/components/onboarding"

<ApplicationSubmit
  profileData={profileData}
  bankingData={bankingData}
  onSubmit={() => submitApplication()}
  onEdit={(step) => goToStep(step)}
/>
```

### VerificationStatus

Displays application verification status.

```tsx
import { VerificationStatus } from "@/components/onboarding"

<VerificationStatus
  status="pending" // pending | approved | rejected
  message="Your application is under review"
/>
```

---

## Profile Components

**Path:** `components/profile/`

User profile management components.

### ProfileEditor

Edit profile information.

```tsx
import { ProfileEditor } from "@/components/profile"

<ProfileEditor
  profile={currentProfile}
  onSave={(data) => updateProfile(data)}
/>
```

### StatsDashboard

Personal statistics dashboard.

```tsx
import { StatsDashboard } from "@/components/profile"

<StatsDashboard
  stats={supervisorStats}
/>
```

### MyReviews

Reviews received on completed projects.

```tsx
import { MyReviews } from "@/components/profile"

<MyReviews
  reviews={myReviews}
/>
```

### DoerBlacklist

Manage blacklisted doers.

```tsx
import { DoerBlacklist } from "@/components/profile"

<DoerBlacklist
  blacklistedDoers={blacklist}
  onRemove={(doerId) => removeFromBlacklist(doerId)}
/>
```

### SupportContact

Contact support section.

```tsx
import { SupportContact } from "@/components/profile"

<SupportContact />
```

---

## Projects Components

**Path:** `components/projects/`

Project management components.

### OngoingProjectCard

Card for projects in progress.

```tsx
import { OngoingProjectCard } from "@/components/projects"

<OngoingProjectCard
  project={project}
  onViewDetails={() => viewProject(project.id)}
  onChat={() => openChat(project.chatRoomId)}
/>
```

### ForReviewCard

Card for projects awaiting QC review.

```tsx
import { ForReviewCard } from "@/components/projects"

<ForReviewCard
  project={project}
  onReview={() => openQCReview(project.id)}
/>
```

### CompletedProjectCard

Card for completed projects.

```tsx
import { CompletedProjectCard } from "@/components/projects"

<CompletedProjectCard
  project={project}
  onViewDetails={() => viewProject(project.id)}
/>
```

### QCReviewModal

Modal for quality control review.

```tsx
import { QCReviewModal } from "@/components/projects"

<QCReviewModal
  project={selectedProject}
  isOpen={isOpen}
  onClose={() => setIsOpen(false)}
  onApprove={(feedback) => approveProject(feedback)}
  onRequestRevision={(notes) => requestRevision(notes)}
/>
```

---

## Resources Components

**Path:** `components/resources/`

Resource tools and training components.

### PlagiarismChecker

Check content for plagiarism.

```tsx
import { PlagiarismChecker } from "@/components/resources"

<PlagiarismChecker
  onCheck={(content) => checkPlagiarism(content)}
/>
```

### AIDetector

Detect AI-generated content.

```tsx
import { AIDetector } from "@/components/resources"

<AIDetector
  onDetect={(content) => detectAI(content)}
/>
```

### PricingGuide

Pricing reference and calculator.

```tsx
import { PricingGuide } from "@/components/resources"

<PricingGuide />
```

### TrainingLibrary

Training video library.

```tsx
import { TrainingLibrary } from "@/components/resources"

<TrainingLibrary />
```

---

## Settings Components

**Path:** `components/settings/`

Application settings components.

### SettingsForm

Main settings form.

```tsx
import { SettingsForm } from "@/components/settings"

<SettingsForm
  settings={currentSettings}
  onSave={(settings) => saveSettings(settings)}
/>
```

### NotificationPreferences

Notification settings.

```tsx
import { NotificationPreferences } from "@/components/settings"

<NotificationPreferences
  preferences={notificationPrefs}
  onChange={(prefs) => updatePreferences(prefs)}
/>
```

### ThemeSelector

Theme selection (light/dark/system).

```tsx
import { ThemeSelector } from "@/components/settings"

<ThemeSelector />
```

---

## Shared Components

**Path:** `components/shared/`

Reusable shared components.

### ErrorBoundary

Error boundary wrapper.

```tsx
import { ErrorBoundary } from "@/components/shared"

<ErrorBoundary fallback={<ErrorFallback />}>
  <ComponentThatMightError />
</ErrorBoundary>
```

### LoadingSkeleton

Loading skeleton placeholder.

```tsx
import { LoadingSkeleton } from "@/components/shared"

<LoadingSkeleton variant="card" count={3} />
```

### SkipLink

Accessibility skip navigation link.

```tsx
import { SkipLink } from "@/components/shared"

<SkipLink href="#main-content">Skip to main content</SkipLink>
```

---

## Support Components

**Path:** `components/support/`

Help and support components.

### TicketList

Support ticket list.

```tsx
import { TicketList } from "@/components/support"

<TicketList
  tickets={supportTickets}
  onSelectTicket={(ticket) => viewTicket(ticket)}
/>
```

### TicketDetail

Individual ticket view.

```tsx
import { TicketDetail } from "@/components/support"

<TicketDetail
  ticket={selectedTicket}
  onReply={(message) => replyToTicket(message)}
  onClose={() => closeTicket()}
/>
```

### CreateTicketForm

Create new support ticket.

```tsx
import { CreateTicketForm } from "@/components/support"

<CreateTicketForm
  onSubmit={(data) => createTicket(data)}
/>
```

---

## Users Components

**Path:** `components/users/`

User (client) management components.

### UserList

Filterable list of users.

```tsx
import { UserList } from "@/components/users"

<UserList />
```

### UserCard

Individual user card.

```tsx
import { UserCard } from "@/components/users"

<UserCard
  user={user}
  onClick={() => viewUserDetails(user.id)}
/>
```

### UserDetails

Detailed user profile sheet.

```tsx
import { UserDetails } from "@/components/users"

<UserDetails
  user={selectedUser}
  open={isOpen}
  onOpenChange={setIsOpen}
  onChat={(userId) => openChat(userId)}
/>
```

---

## UI Components

**Path:** `components/ui/`

shadcn/ui component library (New York style).

All components from shadcn/ui are available:

- Accordion
- Alert / AlertDialog
- Avatar
- Badge
- Button
- Calendar
- Card
- Chart
- Checkbox
- Collapsible
- Command
- Dialog
- Dropdown Menu
- Form
- Input
- Label
- Popover
- Progress
- Radio Group
- Scroll Area
- Select
- Separator
- Sheet
- Sidebar
- Skeleton
- Switch
- Table
- Tabs
- Textarea
- Toast (Sonner)
- Toggle
- Tooltip

See [shadcn/ui documentation](https://ui.shadcn.com/) for usage details.
