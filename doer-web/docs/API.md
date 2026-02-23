# API Documentation

## Overview

The Doer Web application uses a **service-based architecture** with Supabase as the backend. All API operations are handled through dedicated service modules that interact with Supabase's PostgreSQL database.

## Base Configuration

### Supabase Client Setup

```typescript
// lib/supabase/client.ts - Browser client
import { createBrowserClient } from '@supabase/ssr'

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
```

### Environment Variables Required

| Variable | Description |
|----------|-------------|
| `NEXT_PUBLIC_SUPABASE_URL` | Supabase project URL |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Supabase anonymous/public key |

---

## Service Modules

### 1. Authentication Service (`services/auth.service.ts`)

Handles all authentication operations.

#### Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `getSession()` | - | `Session \| null` | Get current auth session |
| `getUser()` | - | `User \| null` | Get current user |
| `signUp(email, password, fullName, phone)` | `string, string, string, string` | `AuthResponse` | Register new user |
| `signIn(email, password)` | `string, string` | `AuthResponse` | Login user |
| `signOut()` | - | `void` | Logout user |
| `resetPassword(email)` | `string` | `void` | Send password reset email |
| `updatePassword(newPassword)` | `string` | `User` | Update user password |

#### Doer Service Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `getDoerByProfileId(profileId)` | `string` | `Doer \| null` | Get doer by profile ID |
| `createDoer(profileId)` | `string` | `Doer` | Create new doer record |
| `updateProfileSetup(doerId, data)` | `string, ProfileData` | `Doer` | Update doer profile |
| `updateSkills(doerId, skillIds)` | `string, string[]` | `void` | Update doer skills |
| `updateSubjects(doerId, subjectIds)` | `string, string[]` | `void` | Update doer subjects |
| `getSkills()` | - | `Skill[]` | Get all available skills |
| `getSubjects()` | - | `Subject[]` | Get all subjects |
| `getUniversities()` | - | `University[]` | Get all universities |

---

### 2. Activation Service (`services/activation.service.ts`)

Manages the doer activation flow (training, quiz, bank details).

#### Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `getActivationStatus(doerId)` | `string` | `DoerActivation \| null` | Get activation progress |
| `createActivation(doerId)` | `string` | `DoerActivation \| null` | Initialize activation record |
| `getTrainingModules()` | - | `TrainingModule[]` | Get all training modules |
| `getTrainingProgress(doerId)` | `string` | `TrainingProgress[]` | Get training progress |
| `updateTrainingProgress(doerId, moduleId, progress)` | `string, string, Partial<TrainingProgress>` | `TrainingProgress \| null` | Update module progress |
| `completeTraining(doerId)` | `string` | `boolean` | Mark training as complete |
| `getQuizQuestions()` | - | `QuizQuestion[]` | Get quiz questions |
| `getQuizAttempts(doerId)` | `string` | `QuizAttempt[]` | Get quiz attempts |
| `submitQuizAttempt(doerId, score, total, answers)` | `string, number, number, Record<string, number>` | `{ attempt: QuizAttempt, passed: boolean }` | Submit quiz |
| `submitBankDetails(doerId, bankDetails)` | `string, BankDetails` | `boolean` | Submit bank info |
| `isFullyActivated(doerId)` | `string` | `boolean` | Check activation status |

---

### 3. Project Service (`services/project.service.ts`)

Handles project management operations.

#### Types

```typescript
interface ProjectFilters {
  status?: ProjectStatus | ProjectStatus[]
  subject?: string
  isUrgent?: boolean
  search?: string
}

interface ProjectSort {
  field: 'deadline' | 'price' | 'created_at' | 'title'
  direction: 'asc' | 'desc'
}
```

#### Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `getDoerProjects(doerId, filters?, sort?)` | `string, ProjectFilters?, ProjectSort?` | `Project[]` | Get doer's projects |
| `getProjectById(projectId)` | `string` | `Project \| null` | Get single project |
| `getProjectFiles(projectId)` | `string` | `ProjectFile[]` | Get project files |
| `getProjectDeliverables(projectId)` | `string` | `ProjectDeliverable[]` | Get deliverables |
| `getProjectRevisions(projectId)` | `string` | `ProjectRevision[]` | Get revisions |
| `updateProjectStatus(projectId, status)` | `string, ProjectStatus` | `Project` | Update status |
| `acceptTask(projectId, doerId)` | `string, string` | `Project` | Accept task from pool |
| `startProject(projectId)` | `string` | `Project` | Start working |
| `submitProject(projectId)` | `string` | `Project` | Submit for review |
| `uploadDeliverable(projectId, doerId, file)` | `string, string, File` | `ProjectDeliverable` | Upload deliverable |
| `getActiveProjectsCount(doerId)` | `string` | `number` | Count active projects |
| `getProjectsByCategory(doerId, category)` | `string, 'active'\|'review'\|'completed'` | `Project[]` | Get by category |

---

### 4. Chat Service (`services/chat.service.ts`)

Real-time messaging with supervisors.

#### Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `getOrCreateProjectChatRoom(projectId)` | `string` | `ChatRoom` | Get/create chat room |
| `getChatMessages(roomId, limit?, before?)` | `string, number?, string?` | `ChatMessage[]` | Get messages |
| `sendMessage(roomId, senderId, senderName, content, avatar?)` | `...` | `ChatMessage` | Send text message |
| `sendFileMessage(roomId, senderId, senderName, file, avatar?)` | `...` | `ChatMessage` | Send file |
| `markMessagesAsRead(roomId, userId)` | `string, string` | `void` | Mark as read |
| `getUnreadCount(roomId, userId)` | `string, string` | `number` | Get unread count |
| `getChatParticipants(roomId)` | `string` | `ChatParticipant[]` | Get participants |
| `subscribeToMessages(roomId, onMessage)` | `string, (msg: ChatMessage) => void` | `RealtimeChannel` | Subscribe to real-time |
| `unsubscribeFromMessages(channel)` | `RealtimeChannel` | `void` | Unsubscribe |
| `joinChatRoom(roomId, userId, userName, role, avatar?)` | `...` | `ChatParticipant` | Join room |

---

### 5. Profile Service (`services/profile.service.ts`)

Doer profile and stats management. Re-exports all domain services.

#### Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `getDoerProfile(doerId)` | `string` | `{ profile, doer, stats }` | Get full profile |
| `updateDoerProfile(doerId, updates)` | `string, ProfileUpdatePayload` | `{ success, error? }` | Update profile |
| `uploadAvatar(doerId, file)` | `string, File` | `{ success, url?, error? }` | Upload avatar |

---

### 6. Skills Service (`services/skills.service.ts`)

Skill management and verification.

#### Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `getDoerSkills(doerId)` | `string` | `SkillWithVerification[]` | Get doer skills |
| `addDoerSkill(doerId, skillId, level)` | `string, string, ExperienceLevel` | `{ success, error? }` | Add skill |
| `removeDoerSkill(doerId, skillId)` | `string, string` | `{ success, error? }` | Remove skill |
| `requestSkillVerification(doerId, skillId)` | `string, string` | `{ success, error? }` | Request verification |

---

### 7. Wallet Service (`services/wallet.service.ts`)

Wallet and transaction management.

#### Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `getDoerWallet(doerId)` | `string` | `Wallet` | Get wallet |
| `getWalletTransactions(doerId, limit?)` | `string, number?` | `WalletTransaction[]` | Get transactions |
| `getEarningsData(doerId, period?)` | `string, string?` | `EarningsData` | Get earnings data |

---

### 8. Payouts Service (`services/payouts.service.ts`)

Payout request management.

#### Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `getPayoutHistory(doerId)` | `string` | `Payout[]` | Get payout history |
| `requestPayout(doerId, amount, method)` | `string, number, string` | `{ success, payout?, error? }` | Request payout |
| `getBankDetails(doerId)` | `string` | `BankDetails \| null` | Get bank details |
| `updateBankDetails(doerId, details)` | `string, BankDetails` | `{ success, error? }` | Update bank info |

---

### 9. Reviews Service (`services/reviews.service.ts`)

Doer reviews and ratings.

#### Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `getDoerReviews(doerId)` | `string` | `DoerReview[]` | Get reviews |
| `getRatingBreakdown(doerId)` | `string` | `RatingBreakdown` | Get rating stats |

---

### 10. Support Service (`services/support.service.ts`)

Support tickets and FAQ.

#### Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `createSupportTicket(userId, ticket)` | `string, CreateTicketPayload` | `{ success, ticket?, error? }` | Create ticket |
| `getSupportTickets(userId)` | `string` | `SupportTicket[]` | Get tickets |
| `getFAQs(category?)` | `string?` | `FAQ[]` | Get FAQs |

---

### 11. Resources Service (`services/resources.service.ts`)

Training, templates, citations, and AI tools.

#### Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `getTrainingModules()` | - | `TrainingModule[]` | Get training modules |
| `getTrainingProgress(doerId)` | `string` | `TrainingProgress[]` | Get progress |
| `updateTrainingProgress(doerId, moduleId, percent, completed)` | `...` | `TrainingProgress` | Update progress |
| `getFormatTemplates()` | - | `FormatTemplate[]` | Get templates |
| `incrementTemplateDownload(templateId)` | `string` | `void` | Track download |
| `generateCitation(url, style)` | `string, ReferenceStyleType` | `string` | Generate citation |
| `saveCitation(doerId, citation)` | `string, Omit<Citation, ...>` | `Citation` | Save citation |
| `getCitationHistory(doerId)` | `string` | `Citation[]` | Get history |
| `checkAIContent(text, doerId, projectId?)` | `string, string, string?` | `AIReport` | Check AI content |
| `getAIReportHistory(doerId)` | `string` | `AIReport[]` | Get AI reports |

---

## Project Status Flow

```
available → assigned → in_progress → submitted → under_review → approved → completed → paid
                           ↓
                  revision_requested → revision_submitted
                           ↑_______________↓
```

## Error Handling

All services follow a consistent error pattern:

```typescript
try {
  const { data, error } = await supabase.from('table').select('*')
  if (error) throw error
  return data
} catch (error) {
  console.error('Error message:', error)
  throw error
}
```

## Real-time Subscriptions

The chat service supports real-time updates using Supabase Realtime:

```typescript
const channel = subscribeToMessages(roomId, (message) => {
  console.log('New message:', message)
})

// Cleanup
await unsubscribeFromMessages(channel)
```

---

## Storage Buckets

| Bucket | Purpose |
|--------|---------|
| `avatars` | Profile pictures |
| `deliverables` | Project deliverable files |
| `chat-files` | Chat attachments |
