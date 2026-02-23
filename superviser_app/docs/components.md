# Components Documentation

This document describes the reusable UI components (widgets) in the Superviser App.

## Table of Contents

- [Overview](#overview)
- [Shared Widgets](#shared-widgets)
  - [Feedback Widgets](#feedback-widgets)
  - [Accessibility Widgets](#accessibility-widgets)
- [Feature Widgets](#feature-widgets)
  - [Dashboard Widgets](#dashboard-widgets)
  - [Project Widgets](#project-widgets)
  - [Chat Widgets](#chat-widgets)
  - [Profile Widgets](#profile-widgets)
  - [Earnings Widgets](#earnings-widgets)
  - [Support Widgets](#support-widgets)
  - [Resources Widgets](#resources-widgets)
- [Design Tokens](#design-tokens)

---

## Overview

The app follows a component-based architecture where UI elements are broken into small, reusable widgets. Components are organized by:

1. **Shared Widgets** (`lib/shared/widgets/`) - Reusable across features
2. **Feature Widgets** (`lib/features/*/presentation/widgets/`) - Feature-specific

---

## Shared Widgets

### Feedback Widgets

**Directory:** `lib/shared/widgets/feedback/`

#### ShimmerLoading

Base shimmer animation wrapper for loading states.

```dart
ShimmerLoading(
  child: Container(
    width: 100,
    height: 20,
    color: Colors.white,
  ),
)
```

#### ShimmerBox

Rectangular shimmer placeholder.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `width` | `double` | required | Box width |
| `height` | `double` | required | Box height |
| `borderRadius` | `double` | `4` | Corner radius |

```dart
const ShimmerBox(width: 150, height: 20, borderRadius: 8)
```

#### ShimmerCircle

Circular shimmer placeholder.

| Property | Type | Description |
|----------|------|-------------|
| `size` | `double` | Diameter of circle |

```dart
const ShimmerCircle(size: 48)
```

#### Skeleton Loaders

Pre-built skeleton screens for loading states:

| Widget | Usage |
|--------|-------|
| `DashboardSkeleton` | Dashboard loading state |
| `ProjectCardSkeleton` | Project card placeholder |
| `StatsCardSkeleton` | Stats summary placeholder |
| `ChatListSkeleton` | Chat list loading |
| `ChatRoomTileSkeleton` | Chat room item placeholder |
| `ChatMessageSkeleton` | Message bubble placeholder |
| `ProfileSkeleton` | Profile screen loading |
| `NotificationSkeleton` | Notification item placeholder |
| `NotificationListSkeleton` | Notification list loading |
| `EarningsSkeleton` | Earnings screen loading |
| `TransactionSkeleton` | Transaction item placeholder |
| `TicketSkeleton` | Support ticket placeholder |
| `DoerCardSkeleton` | Doer card placeholder |

---

### Accessibility Widgets

**Directory:** `lib/shared/widgets/accessibility/`

#### SemanticWrapper

Wraps widgets with semantic information for screen readers.

```dart
SemanticWrapper(
  label: 'Submit button',
  hint: 'Double tap to submit form',
  child: ElevatedButton(
    onPressed: _submit,
    child: Text('Submit'),
  ),
)
```

---

## Feature Widgets

### Dashboard Widgets

**Directory:** `lib/features/dashboard/presentation/widgets/`

#### DashboardHeader

Top header with menu, notifications, and user greeting.

| Property | Type | Description |
|----------|------|-------------|
| `onMenuTap` | `VoidCallback` | Drawer open callback |
| `onNotificationTap` | `VoidCallback` | Notification tap callback |
| `notificationCount` | `int` | Badge count |

```dart
DashboardHeader(
  onMenuTap: () => scaffoldKey.currentState?.openDrawer(),
  onNotificationTap: () => context.push('/notifications'),
  notificationCount: 5,
)
```

#### RequestCard

Displays a project request with action button.

| Property | Type | Description |
|----------|------|-------------|
| `request` | `RequestModel` | Request data |
| `onTap` | `VoidCallback?` | Card tap callback |
| `actionLabel` | `String` | Action button text |
| `onAction` | `VoidCallback` | Action button callback |

```dart
RequestCard(
  request: request,
  onTap: () => _viewDetails(request),
  actionLabel: 'Analyze & Quote',
  onAction: () => _showQuoteForm(request),
)
```

#### FieldFilter

Horizontal scrolling filter chips for subject filtering.

| Property | Type | Description |
|----------|------|-------------|
| `selectedField` | `String` | Currently selected filter |
| `onFieldSelected` | `Function(String)` | Selection callback |

```dart
FieldFilter(
  selectedField: 'Mathematics',
  onFieldSelected: (field) => provider.filterBySubject(field),
)
```

#### MenuDrawer

Navigation drawer with app menu items.

```dart
Scaffold(
  drawer: const MenuDrawer(),
  // ...
)
```

#### QuoteFormSheet

Modal bottom sheet for creating price quotes.

| Static Method | Parameters | Returns |
|---------------|------------|---------|
| `show` | `BuildContext`, `RequestModel` | `Future<bool?>` |

```dart
final result = await QuoteFormSheet.show(context, request);
if (result == true) {
  // Quote submitted successfully
}
```

#### DoerSelectionSheet

Modal bottom sheet for selecting a doer.

| Static Method | Parameters | Returns |
|---------------|------------|---------|
| `show` | `BuildContext`, `RequestModel` | `Future<DoerModel?>` |

```dart
final doer = await DoerSelectionSheet.show(context, request);
if (doer != null) {
  // Doer selected
}
```

---

### Project Widgets

**Directory:** `lib/features/projects/presentation/widgets/`

#### StatusBadge

Colored badge displaying project status.

| Property | Type | Description |
|----------|------|-------------|
| `status` | `ProjectStatus` | Status enum value |
| `size` | `BadgeSize` | `small`, `medium`, `large` |

```dart
StatusBadge(
  status: ProjectStatus.inProgress,
  size: BadgeSize.medium,
)
```

#### DeadlineTimer

Countdown timer showing time remaining.

| Property | Type | Description |
|----------|------|-------------|
| `deadline` | `DateTime` | Target deadline |
| `showIcon` | `bool` | Show clock icon |

```dart
DeadlineTimer(
  deadline: project.deadline,
  showIcon: true,
)
```

#### ProjectCard

Full project card with status, deadline, and actions.

| Property | Type | Description |
|----------|------|-------------|
| `project` | `ProjectModel` | Project data |
| `onTap` | `VoidCallback?` | Tap callback |

```dart
ProjectCard(
  project: project,
  onTap: () => context.push('/projects/${project.id}'),
)
```

#### ProjectTabs

Tab bar for project list filtering.

| Property | Type | Description |
|----------|------|-------------|
| `tabs` | `List<String>` | Tab labels |
| `selectedIndex` | `int` | Active tab index |
| `onTabSelected` | `Function(int)` | Selection callback |

```dart
ProjectTabs(
  tabs: ['Active', 'Completed', 'All'],
  selectedIndex: 0,
  onTabSelected: (index) => _filterProjects(index),
)
```

#### QCReviewCard

Quality control review submission card.

| Property | Type | Description |
|----------|------|-------------|
| `project` | `ProjectModel` | Project to review |
| `onApprove` | `VoidCallback` | Approval callback |
| `onReject` | `VoidCallback` | Rejection callback |

#### RevisionFeedbackForm

Form for requesting project revisions.

| Property | Type | Description |
|----------|------|-------------|
| `onSubmit` | `Function(String)` | Submit callback with feedback |

---

### Chat Widgets

**Directory:** `lib/features/chat/presentation/widgets/`

#### ChatRoomTile

List tile for chat room display.

| Property | Type | Description |
|----------|------|-------------|
| `room` | `ChatRoomModel` | Chat room data |
| `onTap` | `VoidCallback` | Tap callback |

```dart
ChatRoomTile(
  room: chatRoom,
  onTap: () => context.push('/chat/${chatRoom.id}'),
)
```

#### MessageBubble

Chat message bubble with sender info.

| Property | Type | Description |
|----------|------|-------------|
| `message` | `MessageModel` | Message data |
| `isMe` | `bool` | Is current user's message |

```dart
MessageBubble(
  message: message,
  isMe: message.senderId == currentUserId,
)
```

#### MessageInput

Text input for sending messages.

| Property | Type | Description |
|----------|------|-------------|
| `onSend` | `Function(String)` | Send callback |
| `isLoading` | `bool` | Disable while sending |

```dart
MessageInput(
  onSend: (text) => _sendMessage(text),
  isLoading: isSending,
)
```

---

### Profile Widgets

**Directory:** `lib/features/profile/presentation/`

Profile-related widgets are primarily composed within screens.

---

### Earnings Widgets

**Directory:** `lib/features/earnings/presentation/widgets/`

#### EarningsChart

Line/bar chart displaying earnings over time.

| Property | Type | Description |
|----------|------|-------------|
| `data` | `List<EarningsDataPoint>` | Chart data points |
| `period` | `ChartPeriod` | Time period |

```dart
EarningsChart(
  data: monthlyEarnings,
  period: ChartPeriod.monthly,
)
```

#### StatsWidgets

Various stats display widgets:

| Widget | Description |
|--------|-------------|
| `EarningsSummaryCard` | Total earnings overview |
| `StatTile` | Individual stat with label |
| `TrendIndicator` | Up/down trend arrow |

---

### Support Widgets

**Directory:** `lib/features/support/presentation/widgets/`

#### TicketForm

Form for creating support tickets.

| Property | Type | Description |
|----------|------|-------------|
| `onSubmit` | `Function(TicketModel)` | Submit callback |
| `isLoading` | `bool` | Loading state |

```dart
TicketForm(
  onSubmit: (ticket) => _createTicket(ticket),
  isLoading: isSubmitting,
)
```

#### FAQAccordion

Expandable FAQ item.

| Property | Type | Description |
|----------|------|-------------|
| `question` | `String` | FAQ question |
| `answer` | `String` | FAQ answer |
| `isExpanded` | `bool` | Expansion state |
| `onToggle` | `VoidCallback` | Toggle callback |

```dart
FAQAccordion(
  question: 'How do I reset my password?',
  answer: 'Go to Settings > Account > Reset Password...',
  isExpanded: _expandedIndex == 0,
  onToggle: () => _toggle(0),
)
```

---

### Resources Widgets

**Directory:** `lib/features/resources/presentation/widgets/`

#### ToolCard

Card displaying an available tool.

| Property | Type | Description |
|----------|------|-------------|
| `tool` | `ToolModel` | Tool data |
| `onTap` | `VoidCallback` | Tap callback |

#### VideoThumbnailCard

Training video thumbnail with play button.

| Property | Type | Description |
|----------|------|-------------|
| `video` | `TrainingVideoModel` | Video data |
| `onPlay` | `VoidCallback` | Play callback |

#### PricingGuideTable

Table displaying pricing information.

| Property | Type | Description |
|----------|------|-------------|
| `pricing` | `List<PricingModel>` | Pricing data |

#### TrainingLibrary

Grid/list of training materials.

| Property | Type | Description |
|----------|------|-------------|
| `videos` | `List<TrainingVideoModel>` | Video list |
| `onVideoTap` | `Function(TrainingVideoModel)` | Selection callback |

---

## Design Tokens

### Colors

**File:** `lib/core/theme/app_colors.dart`

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `primary` | `#1E3A5F` | `#3D5A80` | Primary brand color |
| `secondary` | `#4A90A4` | `#5DA3B7` | Secondary accent |
| `success` | `#2ECC71` | `#27AE60` | Success states |
| `warning` | `#F39C12` | `#E67E22` | Warning states |
| `error` | `#E74C3C` | `#C0392B` | Error states |
| `background` | `#F5F6F8` | `#121212` | Page background |
| `surface` | `#FFFFFF` | `#1E1E1E` | Card background |
| `textPrimary` | `#1A1A2E` | `#FFFFFF` | Primary text |
| `textSecondary` | `#6B7280` | `#9CA3AF` | Secondary text |

### Typography

**File:** `lib/core/theme/app_theme.dart`

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `headlineLarge` | 32sp | Bold | Page titles |
| `headlineMedium` | 24sp | Bold | Section headers |
| `titleLarge` | 20sp | SemiBold | Card titles |
| `titleMedium` | 16sp | SemiBold | Subtitles |
| `bodyLarge` | 16sp | Regular | Body text |
| `bodyMedium` | 14sp | Regular | Secondary body |
| `labelLarge` | 14sp | Medium | Button text |
| `labelSmall` | 12sp | Regular | Captions |

### Spacing

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4dp | Tight spacing |
| `sm` | 8dp | Small gaps |
| `md` | 16dp | Standard padding |
| `lg` | 24dp | Large gaps |
| `xl` | 32dp | Section spacing |

### Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `sm` | 4dp | Small elements |
| `md` | 8dp | Buttons, inputs |
| `lg` | 12dp | Cards |
| `xl` | 16dp | Modals, sheets |
| `full` | 9999dp | Circular/pills |

---

## Component Guidelines

### Creating New Components

1. **Single Responsibility** - Each widget should do one thing well
2. **Composability** - Build complex UIs from simple widgets
3. **Immutability** - Use `const` constructors where possible
4. **Documentation** - Add dartdoc comments to all public APIs
5. **Accessibility** - Include semantic labels for screen readers

### Example Component Structure

```dart
/// A card displaying project summary information.
///
/// Displays the project title, status badge, deadline countdown,
/// and an action button for quick actions.
///
/// ## Example
///
/// ```dart
/// ProjectCard(
///   project: myProject,
///   onTap: () => navigateToDetails(),
/// )
/// ```
class ProjectCard extends StatelessWidget {
  /// Creates a new [ProjectCard] instance.
  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
  });

  /// The project data to display.
  final ProjectModel project;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            // Widget tree...
          ),
        ),
      ),
    );
  }
}
```
