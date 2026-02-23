# Widget/Component Documentation

**Version:** 1.0.0
**Last Updated:** December 28, 2024
**Status:** Production Ready

---

## Table of Contents

1. [Shared Widgets](#1-shared-widgets)
2. [Dashboard Widgets](#2-dashboard-widgets)
3. [Onboarding Widgets](#3-onboarding-widgets)
4. [Activation Widgets](#4-activation-widgets)
5. [Workspace Widgets](#5-workspace-widgets)

---

## 1. Shared Widgets

Reusable widgets used across multiple features.

**Location:** `lib/shared/widgets/`

---

### 1.1 AppButton

A customizable button widget following the app design system.

**Purpose:** Provide consistent button styling with multiple variants, sizes, and states.

**Location:** `lib/shared/widgets/app_button.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `text` | `String` | required | Button label text |
| `onPressed` | `VoidCallback?` | `null` | Tap callback (null = disabled) |
| `variant` | `AppButtonVariant` | `primary` | Visual style variant |
| `size` | `AppButtonSize` | `medium` | Button size |
| `isLoading` | `bool` | `false` | Show loading indicator |
| `isFullWidth` | `bool` | `false` | Expand to fill width |
| `icon` | `IconData?` | `null` | Leading icon |
| `suffixIcon` | `IconData?` | `null` | Trailing icon |

#### Variants

| Variant | Description |
|---------|-------------|
| `primary` | Solid background with primary color |
| `secondary` | Solid background with accent color |
| `outline` | Transparent with primary-colored border |
| `text` | Text only, no background |

#### Sizes

| Size | Height | Font Size |
|------|--------|-----------|
| `small` | 36px | 12px |
| `medium` | 48px | 14px |
| `large` | 56px | 16px |

#### Usage Example

```dart
AppButton(
  text: 'Submit',
  onPressed: () => handleSubmit(),
  variant: AppButtonVariant.primary,
  isLoading: isSubmitting,
  isFullWidth: true,
  icon: Icons.send,
)
```

---

### 1.2 AppTextField

A customizable text field widget with validation support.

**Purpose:** Provide consistent text input styling with labels, hints, and error handling.

**Location:** `lib/shared/widgets/app_text_field.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `label` | `String?` | `null` | Label above field |
| `hint` | `String?` | `null` | Placeholder text |
| `helperText` | `String?` | `null` | Helper text below field |
| `errorText` | `String?` | `null` | Error message |
| `controller` | `TextEditingController?` | `null` | Text controller |
| `validator` | `String? Function(String?)?` | `null` | Validation function |
| `onChanged` | `void Function(String)?` | `null` | Change callback |
| `onSubmitted` | `void Function(String)?` | `null` | Submit callback |
| `keyboardType` | `TextInputType` | `text` | Keyboard type |
| `textInputAction` | `TextInputAction` | `next` | Keyboard action |
| `obscureText` | `bool` | `false` | Password mode |
| `enabled` | `bool` | `true` | Enable/disable |
| `readOnly` | `bool` | `false` | Read-only mode |
| `maxLines` | `int` | `1` | Multi-line support |
| `maxLength` | `int?` | `null` | Character limit |
| `prefixIcon` | `IconData?` | `null` | Prefix icon |
| `suffixIcon` | `IconData?` | `null` | Suffix icon |

#### Usage Example

```dart
AppTextField(
  label: 'Email',
  hint: 'Enter your email',
  controller: emailController,
  keyboardType: TextInputType.emailAddress,
  prefixIcon: Icons.email,
  validator: (value) => validateEmail(value),
)
```

#### AppPhoneField (Variant)

Specialized phone number input with country code prefix.

```dart
AppPhoneField(
  label: 'Phone Number',
  controller: phoneController,
  countryCode: '+91',
  validator: (value) => validatePhone(value),
)
```

---

### 1.3 AppCard

A reusable card widget with customizable styling.

**Purpose:** Container for content with shadow, border, and tap interaction.

**Location:** `lib/shared/widgets/app_card.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `child` | `Widget` | required | Card content |
| `padding` | `EdgeInsetsGeometry?` | `paddingMd` | Inner padding |
| `margin` | `EdgeInsetsGeometry?` | `null` | Outer margin |
| `color` | `Color?` | `surface` | Background color |
| `elevation` | `double?` | `4` | Shadow blur radius |
| `borderRadius` | `BorderRadius?` | `borderRadiusMd` | Corner radius |
| `border` | `Border?` | light border | Custom border |
| `onTap` | `VoidCallback?` | `null` | Tap callback |
| `hasShadow` | `bool` | `true` | Show drop shadow |

#### Usage Example

```dart
AppCard(
  padding: AppSpacing.paddingMd,
  onTap: () => handleTap(),
  child: Text('Card content'),
)
```

#### Variants

**AppStatusCard** - Status display with icon and value:

```dart
AppStatusCard(
  icon: Icons.assignment,
  title: 'Active Projects',
  value: '5',
  color: AppColors.primary,
  onTap: () => navigateToProjects(),
)
```

**AppInfoCard** - Title/description with leading/trailing:

```dart
AppInfoCard(
  title: 'Account Settings',
  description: 'Manage your account preferences',
  leading: Icon(Icons.settings),
  trailing: Icon(Icons.chevron_right),
  onTap: () => navigateToSettings(),
)
```

---

### 1.4 AppAvatar

A customizable avatar widget for user profile images.

**Purpose:** Display profile images with initials fallback and status badges.

**Location:** `lib/shared/widgets/app_avatar.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `imageUrl` | `String?` | `null` | Profile image URL |
| `name` | `String?` | `null` | Name for initials |
| `size` | `AvatarSize` | `medium` | Avatar size |
| `onTap` | `VoidCallback?` | `null` | Tap callback |
| `showBadge` | `bool` | `false` | Show status badge |
| `badgeColor` | `Color?` | `success` | Badge color |
| `badge` | `Widget?` | `null` | Custom badge widget |

#### Sizes

| Size | Diameter | Font Size |
|------|----------|-----------|
| `small` | 32px | 12px |
| `medium` | 48px | 16px |
| `large` | 64px | 20px |
| `xlarge` | 96px | 28px |

#### Usage Example

```dart
AppAvatar(
  imageUrl: user.avatarUrl,
  name: user.fullName,
  size: AvatarSize.large,
  showBadge: user.isOnline,
  badgeColor: AppColors.success,
)
```

---

### 1.5 AppBadge

Badge widgets for displaying status and labels.

**Purpose:** Display status indicators, urgency levels, and categorical labels.

**Location:** `lib/shared/widgets/app_badge.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `text` | `String` | required | Badge text |
| `variant` | `BadgeVariant` | `primary` | Color variant |
| `icon` | `IconData?` | `null` | Optional icon |
| `isSmall` | `bool` | `false` | Compact size |

#### Variants

| Variant | Background | Text Color |
|---------|------------|------------|
| `primary` | Primary/10% | Primary |
| `success` | Success light | Success |
| `warning` | Warning light | Warning |
| `error` | Error light | Error |
| `info` | Info light | Info |
| `neutral` | Surface variant | Text secondary |

#### Usage Example

```dart
AppBadge(
  text: 'Active',
  variant: BadgeVariant.success,
  icon: Icons.check_circle,
)
```

#### Specialized Variants

**UrgencyBadge** - Time-based urgency:

```dart
UrgencyBadge(hoursLeft: 5)  // Shows "Urgent" in red
UrgencyBadge(hoursLeft: 12) // Shows "12h left" in yellow
UrgencyBadge(hoursLeft: 48) // Shows "2d left" in green
```

**StatusBadge** - Project status:

```dart
StatusBadge(status: 'In Progress') // Info blue
StatusBadge(status: 'Completed')   // Success green
```

---

### 1.6 SectionCard

A section card widget with icon and title header.

**Purpose:** Group related content with a descriptive header.

**Location:** `lib/shared/widgets/section_card.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `icon` | `IconData` | required | Header icon |
| `title` | `String` | required | Header title |
| `child` | `Widget` | required | Card content |
| `iconColor` | `Color?` | `primary` | Icon/title color |
| `backgroundColor` | `Color?` | `null` | Card background |
| `borderSide` | `BorderSide?` | `null` | Card border |
| `elevation` | `double` | `2` | Shadow depth |
| `trailing` | `Widget?` | `null` | Header action widget |

#### Usage Example

```dart
SectionCard(
  icon: Icons.person,
  title: 'Personal Information',
  trailing: IconButton(
    icon: Icon(Icons.edit),
    onPressed: () => editProfile(),
  ),
  child: Column(
    children: [
      Text('Name: John Doe'),
      Text('Email: john@example.com'),
    ],
  ),
)
```

---

### 1.7 EmptyState

A reusable empty state widget for empty lists and error states.

**Purpose:** Display informative message when content is unavailable.

**Location:** `lib/shared/widgets/empty_state.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `icon` | `IconData` | required | Large icon |
| `title` | `String` | required | Title text |
| `description` | `String?` | `null` | Description text |
| `actionText` | `String?` | `null` | Button text |
| `onAction` | `VoidCallback?` | `null` | Button callback |

#### Usage Example

```dart
EmptyState(
  icon: Icons.inbox,
  title: 'No Projects',
  description: 'You have no assigned projects yet.',
  actionText: 'Browse Available',
  onAction: () => navigateToBrowse(),
)
```

#### ErrorState (Variant)

```dart
ErrorState(
  message: 'Failed to load data',
  onRetry: () => refreshData(),
)
```

---

### 1.8 LoadingIndicator

Reusable loading indicator widget.

**Purpose:** Display loading state with optional message.

**Location:** `lib/shared/widgets/loading_indicator.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `size` | `LoadingIndicatorSize` | `medium` | Indicator size |
| `color` | `Color?` | `primary` | Indicator color |
| `message` | `String?` | `null` | Loading message |

#### Sizes

| Size | Diameter | Stroke Width |
|------|----------|--------------|
| `small` | 20px | 2px |
| `medium` | 36px | 3px |
| `large` | 48px | 4px |

#### Usage Example

```dart
LoadingIndicator(
  size: LoadingIndicatorSize.large,
  message: 'Loading projects...',
)
```

---

### 1.9 LoadingOverlay

Full screen loading overlay that covers content.

**Purpose:** Block interactions during async operations.

**Location:** `lib/shared/widgets/loading_overlay.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `isLoading` | `bool` | required | Show/hide overlay |
| `child` | `Widget` | required | Content widget |
| `overlayColor` | `Color?` | white/80% | Overlay color |
| `message` | `String?` | `null` | Loading message |

#### Usage Example

```dart
LoadingOverlay(
  isLoading: isSubmitting,
  message: 'Saving changes...',
  child: ProfileForm(),
)
```

---

## 2. Dashboard Widgets

Widgets specific to the dashboard feature.

**Location:** `lib/features/dashboard/widgets/`

---

### 2.1 AppHeader

Application header with avatar and notifications.

**Purpose:** Provide consistent header across dashboard screens.

**Location:** `lib/features/dashboard/widgets/app_header.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `userName` | `String` | required | User display name |
| `avatarUrl` | `String?` | `null` | User avatar URL |
| `greeting` | `String?` | auto | Time-based greeting |
| `onAvatarTap` | `VoidCallback?` | `null` | Avatar tap callback |
| `onNotificationTap` | `VoidCallback?` | `null` | Notification tap |
| `notificationCount` | `int` | `0` | Unread notifications |

#### Usage Example

```dart
AppHeader(
  userName: user.fullName,
  avatarUrl: user.avatarUrl,
  onAvatarTap: () => navigateToProfile(),
  onNotificationTap: () => navigateToNotifications(),
  notificationCount: 3,
)
```

---

### 2.2 AppDrawer

Navigation drawer with user info and menu items.

**Purpose:** Provide navigation to all app sections.

**Location:** `lib/features/dashboard/widgets/app_drawer.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `user` | `UserModel` | required | Current user |
| `onLogout` | `VoidCallback` | required | Logout callback |

---

### 2.3 ProjectCard

Card for displaying project information in lists.

**Purpose:** Show project details with status, deadline, and actions.

**Location:** `lib/features/dashboard/widgets/project_card.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `project` | `ProjectModel` | required | Project data |
| `onTap` | `VoidCallback?` | `null` | Card tap callback |
| `onAccept` | `VoidCallback?` | `null` | Accept button callback |
| `showAcceptButton` | `bool` | `false` | Show accept button |

#### Usage Example

```dart
ProjectCard(
  project: project,
  onTap: () => navigateToProject(project.id),
  onAccept: () => acceptProject(project.id),
  showAcceptButton: project.status == ProjectStatus.open,
)
```

#### CompactProjectCard (Variant)

Smaller variant for horizontal lists.

```dart
CompactProjectCard(
  project: project,
  onTap: () => navigateToProject(project.id),
)
```

---

### 2.4 StatCard

Card for displaying statistics with icon.

**Purpose:** Show numeric metrics prominently.

**Location:** `lib/features/dashboard/widgets/stat_card.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | `String` | required | Stat label |
| `value` | `String` | required | Stat value |
| `icon` | `IconData` | required | Stat icon |
| `color` | `Color?` | `primary` | Theme color |
| `subtitle` | `String?` | `null` | Secondary text |
| `onTap` | `VoidCallback?` | `null` | Tap callback |

#### Usage Example

```dart
StatCard(
  title: 'Total Earnings',
  value: '25,000',
  icon: Icons.currency_rupee,
  color: AppColors.success,
  subtitle: 'This month',
  onTap: () => navigateToEarnings(),
)
```

#### Related Widgets

**StatRow** - Inline stat display:

```dart
StatRow(
  label: 'Success Rate',
  value: '95%',
  icon: Icons.trending_up,
  valueColor: AppColors.success,
)
```

**ScorecardGrid** - Grid of multiple stats:

```dart
ScorecardGrid(
  activeProjects: 3,
  completedProjects: 25,
  totalEarnings: '50,000',
  rating: 4.8,
)
```

---

### 2.5 UrgencyBadge

Badge indicating project urgency level.

**Purpose:** Visual indicator for time-sensitive projects.

**Location:** `lib/features/dashboard/widgets/urgency_badge.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `compact` | `bool` | `false` | Use compact size |

#### Usage Example

```dart
if (project.isUrgent)
  UrgencyBadge()
```

---

### 2.6 DeadlineCountdown

Countdown display for project deadlines.

**Purpose:** Show time remaining until deadline.

**Location:** `lib/features/dashboard/widgets/deadline_countdown.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `deadline` | `DateTime` | required | Target deadline |

#### Usage Example

```dart
DeadlineCountdown(deadline: project.deadline)
```

---

### 2.7 AvailabilityToggle

Toggle switch for availability status.

**Purpose:** Allow doers to toggle their availability.

**Location:** `lib/features/dashboard/widgets/availability_toggle.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `isAvailable` | `bool` | required | Current status |
| `onChanged` | `ValueChanged<bool>` | required | Change callback |
| `isLoading` | `bool` | `false` | Loading state |

#### Usage Example

```dart
AvailabilityToggle(
  isAvailable: user.isAvailable,
  onChanged: (value) => updateAvailability(value),
  isLoading: isUpdating,
)
```

---

## 3. Onboarding Widgets

Widgets for the onboarding flow.

**Location:** `lib/features/onboarding/widgets/`

---

### 3.1 ChipSelector

Multi-select chip selector widget.

**Purpose:** Allow selection of multiple options from a list.

**Location:** `lib/features/onboarding/widgets/chip_selector.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `options` | `List<ChipOption<T>>` | required | Available options |
| `selectedValues` | `List<T>` | required | Selected values |
| `onChanged` | `ValueChanged<List<T>>` | required | Change callback |
| `maxSelections` | `int?` | `null` | Max selections |
| `enabled` | `bool` | `true` | Enable/disable |
| `label` | `String?` | `null` | Label text |
| `helperText` | `String?` | `null` | Helper text |
| `wrap` | `bool` | `true` | Wrap or scroll |

#### Usage Example

```dart
ChipSelector<String>(
  label: 'Select Skills',
  options: skills.map((s) => ChipOption(value: s.id, label: s.name)).toList(),
  selectedValues: selectedSkillIds,
  onChanged: (values) => setState(() => selectedSkillIds = values),
  maxSelections: 5,
  helperText: 'Select up to 5 skills',
)
```

#### SingleChipSelector (Variant)

Single selection mode:

```dart
SingleChipSelector<String>(
  label: 'Primary Subject',
  options: subjects.map((s) => ChipOption(value: s.id, label: s.name)).toList(),
  selectedValue: primarySubjectId,
  onChanged: (value) => setState(() => primarySubjectId = value),
)
```

---

### 3.2 StepProgressBar

Progress indicator for multi-step flows.

**Purpose:** Show current position in a multi-step process.

**Location:** `lib/features/onboarding/widgets/step_progress_bar.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `totalSteps` | `int` | required | Total step count |
| `currentStep` | `int` | required | Current step (1-indexed) |
| `labels` | `List<String>?` | `null` | Step labels |

#### Usage Example

```dart
StepProgressBar(
  totalSteps: 4,
  currentStep: 2,
  labels: ['Account', 'Profile', 'Skills', 'Verify'],
)
```

---

### 3.3 OtpInputField

OTP code input field.

**Purpose:** Enter verification codes with auto-focus.

**Location:** `lib/features/onboarding/widgets/otp_input_field.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `length` | `int` | `6` | Code length |
| `onCompleted` | `ValueChanged<String>` | required | Completion callback |
| `onChanged` | `ValueChanged<String>?` | `null` | Change callback |
| `enabled` | `bool` | `true` | Enable/disable |

#### Usage Example

```dart
OtpInputField(
  length: 6,
  onCompleted: (code) => verifyOtp(code),
)
```

---

### 3.4 ExperienceSlider

Experience level selector widget.

**Purpose:** Select expertise level with visual feedback.

**Location:** `lib/features/onboarding/widgets/experience_slider.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `value` | `ExperienceLevel` | required | Current level |
| `onChanged` | `ValueChanged<ExperienceLevel>` | required | Change callback |
| `enabled` | `bool` | `true` | Enable/disable |
| `label` | `String?` | `null` | Label text |

#### Experience Levels

| Level | Icon | Description |
|-------|------|-------------|
| `beginner` | School | Starting out, guided tasks |
| `intermediate` | Trending Up | Some experience, moderate tasks |
| `pro` | Star | Highly experienced, premium tasks |

#### Usage Example

```dart
ExperienceSlider(
  label: 'Experience Level',
  value: experienceLevel,
  onChanged: (level) => setState(() => experienceLevel = level),
)
```

---

### 3.5 PasswordStrengthIndicator

Password strength visualization.

**Purpose:** Show password strength as user types.

**Location:** `lib/features/onboarding/widgets/password_strength_indicator.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `password` | `String` | required | Current password |

#### Usage Example

```dart
PasswordStrengthIndicator(password: passwordController.text)
```

---

## 4. Activation Widgets

Widgets for the activation flow.

**Location:** `lib/features/activation/widgets/`

---

### 4.1 ActivationStepper

3-step activation progress widget.

**Purpose:** Show activation progress with interactive steps.

**Location:** `lib/features/activation/widgets/activation_stepper.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `status` | `ActivationStatus` | required | Current status |
| `onStepTapped` | `Function(ActivationStep)?` | `null` | Step tap callback |
| `currentStep` | `ActivationStep?` | `null` | Active step |

#### Usage Example

```dart
ActivationStepper(
  status: activationStatus,
  currentStep: ActivationStep.training,
  onStepTapped: (step) => navigateToStep(step),
)
```

#### CompactActivationStepper (Variant)

Compact horizontal dot indicator:

```dart
CompactActivationStepper(status: activationStatus)
```

---

### 4.2 TrainingModuleCard

Card for displaying training module.

**Purpose:** Show module info with progress and type indicator.

**Location:** `lib/features/activation/widgets/training_module_card.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `module` | `TrainingModule` | required | Module data |
| `progress` | `TrainingProgress?` | `null` | Progress data |
| `onTap` | `VoidCallback?` | `null` | Tap callback |
| `isLocked` | `bool` | `false` | Lock state |

#### Usage Example

```dart
TrainingModuleCard(
  module: module,
  progress: progressMap[module.id],
  onTap: () => openModule(module),
  isLocked: !canAccessModule(module),
)
```

---

### 4.3 QuizQuestion

Quiz question display widget.

**Purpose:** Display question with answer options.

**Location:** `lib/features/activation/widgets/quiz_question.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `question` | `QuizQuestion` | required | Question data |
| `selectedIndex` | `int?` | `null` | Selected answer |
| `onSelect` | `ValueChanged<int>` | required | Selection callback |
| `showResult` | `bool` | `false` | Show correct/incorrect |

#### Usage Example

```dart
QuizQuestion(
  question: questions[currentIndex],
  selectedIndex: selectedAnswer,
  onSelect: (index) => setState(() => selectedAnswer = index),
  showResult: hasSubmitted,
)
```

---

### 4.4 QuizResult

Quiz result display widget.

**Purpose:** Show quiz completion results.

**Location:** `lib/features/activation/widgets/quiz_result.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `attempt` | `QuizAttempt` | required | Attempt data |
| `onRetry` | `VoidCallback?` | `null` | Retry callback |
| `onContinue` | `VoidCallback?` | `null` | Continue callback |

#### Usage Example

```dart
QuizResult(
  attempt: lastAttempt,
  onRetry: lastAttempt.passed ? null : () => retryQuiz(),
  onContinue: lastAttempt.passed ? () => proceedToNextStep() : null,
)
```

---

### 4.5 BankVerificationBadge

Badge showing bank verification status.

**Purpose:** Visual indicator for bank details verification.

**Location:** `lib/features/activation/widgets/bank_verification_badge.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `isVerified` | `bool` | required | Verification status |

#### Usage Example

```dart
BankVerificationBadge(isVerified: user.bankVerified)
```

---

## 5. Workspace Widgets

Widgets for the workspace/project screens.

**Location:** `lib/features/workspace/widgets/`

---

### 5.1 FileUpload

File upload area widget.

**Purpose:** Provide drop zone for file uploads.

**Location:** `lib/features/workspace/widgets/file_upload.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `onTap` | `VoidCallback?` | `null` | Tap callback |
| `isUploading` | `bool` | `false` | Uploading state |

#### Usage Example

```dart
FileUploadArea(
  onTap: () => pickFiles(),
  isUploading: isUploadingFiles,
)
```

#### FileList (Related)

Display list of uploaded files:

```dart
FileList(
  files: uploadedFiles,
  onRemove: (id) => removeFile(id),
  onSetPrimary: (id) => setPrimaryFile(id),
  editable: true,
)
```

---

### 5.2 ProgressTracker

Project progress tracking widget.

**Purpose:** Show project completion progress.

**Location:** `lib/features/workspace/widgets/progress_tracker.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `progress` | `double` | required | Progress 0-100 |
| `status` | `ProjectStatus` | required | Current status |

#### Usage Example

```dart
ProgressTracker(
  progress: 65,
  status: ProjectStatus.inProgress,
)
```

---

### 5.3 ProjectInfoCard

Card displaying project details.

**Purpose:** Show comprehensive project information.

**Location:** `lib/features/workspace/widgets/project_info_card.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `project` | `ProjectModel` | required | Project data |
| `showActions` | `bool` | `true` | Show action buttons |

#### Usage Example

```dart
ProjectInfoCard(
  project: project,
  showActions: canModify,
)
```

---

### 5.4 RequirementsList

Checklist of project requirements.

**Purpose:** Display project requirements with check states.

**Location:** `lib/features/workspace/widgets/requirements_list.dart`

#### Props/Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `requirements` | `List<String>` | required | Requirement list |
| `checkedItems` | `Set<int>` | `{}` | Checked indices |
| `onToggle` | `ValueChanged<int>?` | `null` | Toggle callback |
| `editable` | `bool` | `true` | Allow toggling |

#### Usage Example

```dart
RequirementsList(
  requirements: project.requirements,
  checkedItems: completedRequirements,
  onToggle: (index) => toggleRequirement(index),
  editable: project.status == ProjectStatus.inProgress,
)
```

---

## Appendix

### A. Design System Constants

| Constant | Location | Purpose |
|----------|----------|---------|
| `AppColors` | `core/constants/app_colors.dart` | Color palette |
| `AppSpacing` | `core/constants/app_spacing.dart` | Spacing & sizing |
| `AppTextStyles` | `core/constants/app_text_styles.dart` | Typography |

### B. Related Documents

- [API Documentation](./API.md) - Data models and repositories
- [Screens](./SCREENS.md) - Screen documentation
- [Architecture](./ARCHITECTURE.md) - System overview

---

*Document maintained by Development Team*
*Last reviewed: December 28, 2024*
