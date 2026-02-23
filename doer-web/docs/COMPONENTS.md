# Components Documentation

## Overview

The Doer Web application uses a **component-based architecture** with shadcn/ui as the base component library. Components are organized by feature domain for better maintainability.

---

## Component Structure

```
components/
├── ui/           # Base UI components (shadcn/ui)
├── providers/    # Context providers
├── shared/       # Shared/global components
├── layout/       # Layout components
├── onboarding/   # Onboarding flow components
├── activation/   # Activation flow components
├── dashboard/    # Dashboard components
├── projects/     # Project-related components
├── resources/    # Resource center components
└── profile/      # Profile & settings components
```

---

## UI Components (`components/ui/`)

Base components from shadcn/ui (New York style variant).

| Component | File | Description |
|-----------|------|-------------|
| `Accordion` | `accordion.tsx` | Collapsible content panels |
| `Alert` | `alert.tsx` | Alert messages with variants |
| `Avatar` | `avatar.tsx` | User avatar with fallback |
| `Badge` | `badge.tsx` | Status/category badges |
| `Button` | `button.tsx` | Button with variants |
| `Card` | `card.tsx` | Card container with header/content/footer |
| `Carousel` | `carousel.tsx` | Image/content carousel |
| `Checkbox` | `checkbox.tsx` | Checkbox input |
| `Dialog` | `dialog.tsx` | Modal dialog |
| `Dropdown Menu` | `dropdown-menu.tsx` | Dropdown menu |
| `Form` | `form.tsx` | Form with react-hook-form |
| `Input` | `input.tsx` | Text input |
| `Label` | `label.tsx` | Form label |
| `Progress` | `progress.tsx` | Progress bar |
| `Radio Group` | `radio-group.tsx` | Radio button group |
| `Scroll Area` | `scroll-area.tsx` | Custom scrollbar area |
| `Select` | `select.tsx` | Select dropdown |
| `Separator` | `separator.tsx` | Visual separator |
| `Sheet` | `sheet.tsx` | Slide-out panel |
| `Skeleton` | `skeleton.tsx` | Loading skeleton |
| `Sonner` | `sonner.tsx` | Toast notifications |
| `Switch` | `switch.tsx` | Toggle switch |
| `Table` | `table.tsx` | Data table |
| `Tabs` | `tabs.tsx` | Tab navigation |
| `Textarea` | `textarea.tsx` | Multiline text input |

---

## Provider Components (`components/providers/`)

### ThemeProvider

```typescript
interface ThemeProviderProps {
  children: React.ReactNode
  defaultTheme?: 'light' | 'dark' | 'system'
}
```

Provides dark/light mode theming using `next-themes`.

**Usage:**
```tsx
<ThemeProvider defaultTheme="system">
  <App />
</ThemeProvider>
```

---

## Shared Components (`components/shared/`)

### Logo

```typescript
interface LogoProps {
  size?: 'sm' | 'md' | 'lg'
  showText?: boolean
  className?: string
}
```

Application logo component with configurable size.

### AvailabilityToggle

```typescript
interface AvailabilityToggleProps {
  isAvailable: boolean
  onToggle: (value: boolean) => void
  disabled?: boolean
}
```

Toggle switch for doer availability status.

---

## Layout Components (`components/layout/`)

### Header

```typescript
interface HeaderProps {
  title?: string
  showBackButton?: boolean
  onBack?: () => void
}
```

Top navigation header with:
- App logo
- Page title
- User menu dropdown
- Notifications button

### Sidebar

```typescript
interface SidebarProps {
  isOpen?: boolean
  onClose?: () => void
}
```

Navigation sidebar with:
- Dashboard link
- Projects link
- Resources link
- Profile link
- Stats link
- Availability toggle

### MainLayout

```typescript
interface MainLayoutProps {
  children: React.ReactNode
}
```

Combines Header + Sidebar + Content area. Used by all main app pages.

---

## Onboarding Components (`components/onboarding/`)

### SplashScreen

Animated splash screen with logo and loading indicator.

### OnboardingCarousel

```typescript
interface OnboardingCarouselProps {
  onComplete: () => void
}
```

Swipeable carousel showing app benefits:
1. Countless Opportunities
2. Small Tasks, Big Rewards
3. 24x7 Supervisor Support
4. Practical Learning

### RegistrationForm

```typescript
interface RegistrationFormProps {
  onSuccess: () => void
}
```

User registration with:
- Full name input
- Email input
- Phone input with OTP verification
- Password with strength indicator

### ProfileSetupForm

```typescript
interface ProfileSetupFormProps {
  onComplete: () => void
}
```

Profile setup wizard:
- Qualification selection
- University search
- Skills multi-select
- Subjects multi-select
- Experience level
- Bio textarea

---

## Activation Components (`components/activation/`)

### ActivationGate

```typescript
interface ActivationGateProps {
  children: React.ReactNode
}
```

HOC that checks activation status and redirects to appropriate step if incomplete.

### TrainingModule

```typescript
interface TrainingModuleProps {
  module: TrainingModule
  progress?: TrainingProgress
  onComplete: (moduleId: string) => void
}
```

Training content display:
- Video player (YouTube embed)
- PDF viewer
- Progress tracking
- Completion button

### QuizComponent

```typescript
interface QuizComponentProps {
  questions: QuizQuestion[]
  onComplete: (score: number, answers: Record<string, number>) => void
}
```

Quiz interface with:
- Question display
- Multiple choice options
- Progress indicator
- Timer
- Score display

### BankDetailsForm

```typescript
interface BankDetailsFormProps {
  onComplete: () => void
}
```

Bank details collection:
- Account holder name
- Account number
- IFSC code (with validation)
- Bank name (auto-fetch)
- UPI ID (optional)

---

## Dashboard Components (`components/dashboard/`)

### ProjectCard

```typescript
interface Project {
  id: string
  title: string
  subject: string
  description?: string
  price: number
  deadline: Date
  status: ProjectStatus
  supervisorName?: string
  isUrgent?: boolean
}

interface ProjectCardProps {
  project: Project
  onClick?: (id: string) => void
  onAccept?: (id: string) => void
  variant?: 'assigned' | 'pool'
}
```

Project display card with:
- Title and subject badge
- Price display (INR)
- Deadline countdown
- Status indicator
- Urgent flag
- Action buttons

### TaskPoolList

```typescript
interface TaskPoolListProps {
  projects: Project[]
  isLoading?: boolean
  onAcceptTask: (projectId: string) => void
  onProjectClick?: (projectId: string) => void
  onRefresh?: () => void
}
```

Open task pool grid:
- Filterable list
- Sort options
- Accept button
- Pull-to-refresh

### AssignedTaskList

```typescript
interface AssignedTaskListProps {
  projects: Project[]
  isLoading?: boolean
  onProjectClick: (projectId: string) => void
}
```

Assigned tasks display:
- Grouped by urgency
- Status indicators
- Quick actions

---

## Project Components (`components/projects/`)

### WorkspaceView

```typescript
interface WorkspaceViewProps {
  project: Project
  files: ProjectFile[]
  deliverables: ProjectDeliverable[]
  revisions: ProjectRevision[]
  messages: ChatMessage[]
  chatRoomId?: string
  currentUserId: string
  currentUserName: string
  currentUserAvatar?: string
  isLoading?: boolean
  isChatLoading?: boolean
  isChatSending?: boolean
  onUploadDeliverable?: (files: File[]) => Promise<void>
  onSubmitProject?: () => Promise<void>
  onStartProject?: () => Promise<void>
  onSendMessage?: (content: string) => Promise<void>
  onSendFile?: (file: File) => Promise<void>
  onStartRevision?: (revisionId: string) => void
}
```

Full project workspace with tabs:
- **Details Tab**: Project brief, requirements, files
- **Submit Tab**: File upload, deliverables, submit button
- **Chat Tab**: Real-time chat with supervisor

### FileUpload

```typescript
interface FileUploadProps {
  onFilesSelected: (files: File[]) => void
  onUpload?: (files: File[]) => Promise<void>
  isUploading?: boolean
  maxFiles?: number
  maxSizeMB?: number
  accept?: string
  multiple?: boolean
}
```

Drag-and-drop file upload:
- Drop zone
- File preview
- Upload progress
- Size validation

### ChatPanel

```typescript
interface ChatPanelProps {
  roomId: string
  currentUserId: string
  currentUserName: string
  currentUserAvatar?: string
  messages: ChatMessage[]
  isLoading?: boolean
  isSending?: boolean
  onSendMessage?: (content: string) => Promise<void>
  onSendFile?: (file: File) => Promise<void>
  className?: string
}
```

Real-time chat interface:
- Message list
- Text input
- File attachments
- Read receipts
- Auto-scroll

### RevisionBanner / RevisionList

```typescript
interface RevisionListProps {
  revisions: ProjectRevision[]
  supervisorName?: string
  onStartRevision?: (revisionId: string) => void
}
```

Revision request display:
- Revision notes
- Supervisor feedback
- Action button

### ActiveProjectsTab / UnderReviewTab / CompletedTab

Project list components for the Projects page tabs.

---

## Resource Components (`components/resources/`)

### ResourcesGrid

```typescript
interface ResourcesGridProps {
  onResourceSelect: (resourceId: string) => void
}
```

Resource center grid with:
- Citation Builder
- Format Templates
- Training Videos
- AI Checker

### CitationBuilder

```typescript
interface CitationBuilderProps {
  doerId?: string
}
```

Citation generation tool:
- URL input
- Style selector (APA, MLA, Harvard, Chicago, IEEE, Vancouver)
- Generated citation display
- Copy button
- History

### FormatTemplates

```typescript
interface FormatTemplatesProps {
  templates?: FormatTemplate[]
}
```

Document template gallery:
- Category filter
- Template cards
- Download button
- Preview

### TrainingCenter

```typescript
interface TrainingCenterProps {
  doerId?: string
}
```

Training resources:
- Video modules
- Progress tracking
- Certificate download

### AIReportGenerator

```typescript
interface AIReportGeneratorProps {
  doerId?: string
  projectId?: string
}
```

AI content detector:
- Text input / file upload
- Analysis progress
- Originality score
- Section breakdown
- Report history

---

## Profile Components (`components/profile/`)

### Scorecard

```typescript
interface ScorecardProps {
  stats: DoerStats
}
```

Performance metrics card:
- Active assignments
- Completed projects
- Total earnings
- Average rating

### EditProfile

```typescript
interface EditProfileProps {
  profile: Profile
  doer: Doer
  onSave: (data: ProfileUpdatePayload) => Promise<void>
}
```

Profile editing form:
- Avatar upload
- Name, phone, email
- Bio
- Qualification
- University

### BankSettings

```typescript
interface BankSettingsProps {
  doerId: string
}
```

Bank details management:
- View/edit bank details
- IFSC validation
- UPI management

### EarningsGraph

```typescript
interface EarningsGraphProps {
  data: EarningsData
  period?: 'week' | 'month' | 'year'
}
```

Earnings visualization:
- Line chart
- Period selector
- Trend indicators

### PaymentHistory

```typescript
interface PaymentHistoryProps {
  doerId: string
}
```

Transaction history:
- Transaction list
- Type filters
- Date range
- Export option

### SupportSection

```typescript
interface SupportSectionProps {
  userId: string
}
```

Support interface:
- FAQ accordion
- Ticket creation
- Ticket history

### RatingBreakdown

```typescript
interface RatingBreakdownProps {
  doerId: string
}
```

Rating display:
- Overall rating
- Category breakdown (quality, timeliness, communication)
- Star distribution

### SkillVerification

```typescript
interface SkillVerificationProps {
  doerId: string
}
```

Skills management:
- Skill list
- Verification status
- Add/remove skills
- Request verification

### RequestPayout

```typescript
interface RequestPayoutProps {
  doerId: string
  walletBalance: number
}
```

Payout request form:
- Amount input
- Payment method
- Bank details preview
- Request button

---

## Component Patterns

### Props Pattern

All components use typed props interfaces:

```typescript
interface ComponentProps {
  /** Required prop description */
  data: DataType
  /** Optional callback */
  onAction?: () => void
  /** Optional styling */
  className?: string
}
```

### Loading States

Use skeleton components for loading:

```tsx
if (isLoading) {
  return <Skeleton className="h-32 w-full" />
}
```

### Error Boundaries

Wrap critical components:

```tsx
<ErrorBoundary fallback={<ErrorMessage />}>
  <CriticalComponent />
</ErrorBoundary>
```

### Composition

Build complex UIs from smaller components:

```tsx
<Card>
  <CardHeader>
    <CardTitle>Title</CardTitle>
  </CardHeader>
  <CardContent>
    <DataDisplay data={data} />
  </CardContent>
</Card>
```

---

## Styling

### Tailwind Classes

Components use Tailwind CSS utility classes:

```tsx
<div className="flex items-center gap-4 p-4 bg-card rounded-lg border">
  <Avatar className="h-10 w-10" />
  <div className="flex-1">
    <p className="font-medium">Title</p>
    <p className="text-sm text-muted-foreground">Description</p>
  </div>
</div>
```

### cn() Utility

Merge classes conditionally:

```tsx
import { cn } from '@/lib/utils'

<Button className={cn(
  'w-full',
  isActive && 'bg-primary',
  disabled && 'opacity-50'
)}>
```

### Theme Variables

Use CSS variables for theming:

```css
--background
--foreground
--primary
--secondary
--muted
--accent
--destructive
```
