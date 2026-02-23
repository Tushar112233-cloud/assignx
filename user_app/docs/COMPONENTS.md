# Components Documentation

This document describes reusable UI components in the AssignX User App.

## Overview

Components are organized by feature in `lib/features/*/widgets/` and shared components in `lib/shared/widgets/`.

---

## Shared Components

### SupportFAB

**File:** `lib/shared/widgets/support_fab.dart`

Floating action button for WhatsApp support access.

#### Usage

```dart
Scaffold(
  floatingActionButton: SupportFAB(
    phoneNumber: AppConfig.supportPhone,
    message: 'Help with my project',
  ),
)
```

#### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `phoneNumber` | `String` | `AppConfig.supportPhone` | WhatsApp number with country code |
| `message` | `String?` | Default support message | Pre-filled message |

---

### SupportButton

**File:** `lib/shared/widgets/support_fab.dart`

Compact support button for inline use.

#### Usage

```dart
SupportButton(
  phoneNumber: '+919876543210',
  message: 'Need help with onboarding',
)
```

---

## Profile Components

### ProfileHero

**File:** `lib/features/profile/widgets/profile_hero.dart`

Hero section with user avatar and info on profile screen.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `profile` | `UserProfile` | User profile data |
| `onEditTap` | `VoidCallback?` | Callback for edit button |
| `onAvatarTap` | `VoidCallback?` | Callback for avatar tap |

#### Features

- Displays user avatar with initials fallback
- Shows verification badge
- Gradient background
- Edit button overlay

---

### StatsCard

**File:** `lib/features/profile/widgets/stats_card.dart`

Card displaying wallet balance and project stats.

#### Usage

```dart
StatsCard(
  walletBalance: 2450.50,
  projectsCompleted: 12,
  onWalletTap: () => context.push('/wallet'),
  onTopUpTap: () => _showTopUpSheet(context),
)
```

---

### SettingsItem

**File:** `lib/features/profile/widgets/settings_item.dart`

Standardized settings menu item.

#### Usage

```dart
SettingsItem(
  icon: Icons.person_outline,
  title: 'Edit Profile',
  subtitle: 'Update your information',
  onTap: () => context.push('/profile/edit'),
  showDivider: true,
)
```

#### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `icon` | `IconData` | Required | Leading icon |
| `title` | `String` | Required | Main text |
| `subtitle` | `String?` | null | Secondary text |
| `trailing` | `Widget?` | Arrow icon | Trailing widget |
| `onTap` | `VoidCallback?` | null | Tap handler |
| `showDivider` | `bool` | true | Show bottom divider |

---

### AppVersionFooter

**File:** `lib/features/profile/widgets/settings_item.dart`

Footer displaying app version.

#### Usage

```dart
AppVersionFooter(version: '1.0.0+1')
```

---

## Home Components

### PromoBannerCarousel

**File:** `lib/features/home/widgets/promo_banner_carousel.dart`

Auto-scrolling promotional banner carousel.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `banners` | `List<AppBanner>` | Banner data list |
| `autoPlayInterval` | `Duration` | Time between slides |
| `onBannerTap` | `Function(AppBanner)?` | Banner tap callback |

#### Features

- Auto-advances every 5 seconds
- Page indicator dots
- Infinite scroll
- Deep link support

---

### QuickActionsGrid

**File:** `lib/features/home/widgets/quick_actions.dart`

Grid of quick action buttons.

#### Actions

- New Project
- My Projects
- Proofreading
- Expert Opinion
- Marketplace
- Wallet

---

### FABBottomSheet

**File:** `lib/features/home/widgets/fab_bottom_sheet.dart`

Expandable FAB with service options.

#### Features

- Animated expansion
- Service type selection
- Navigates to project creation

---

## Project Components

### ProjectCard

**File:** `lib/features/projects/widgets/project_card.dart`

Card displaying project summary in list.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `project` | `Project` | Project data |
| `onTap` | `VoidCallback?` | Card tap handler |
| `compact` | `bool` | Use compact layout |

#### Features

- Status badge with color
- Progress indicator
- Deadline countdown
- Price display

---

### StatusBanner

**File:** `lib/features/projects/widgets/status_banner.dart`

Banner showing current project status.

#### Usage

```dart
StatusBanner(
  status: ProjectStatus.inProgress,
  progressPercentage: 65,
)
```

---

### ProjectBriefAccordion

**File:** `lib/features/projects/widgets/project_brief_accordion.dart`

Expandable section showing project requirements.

#### Sections

- Description
- Word count / Page count
- Focus areas
- Special instructions
- Reference files

---

### DeliverablesSection

**File:** `lib/features/projects/widgets/deliverables_section.dart`

Section displaying project deliverables.

#### Features

- File type icons
- Download buttons
- Version history
- Plagiarism/AI reports

---

### LiveDraftSection

**File:** `lib/features/projects/widgets/live_draft_section.dart`

Live document preview component.

#### Features

- Embedded document viewer
- Progress updates
- Last modified timestamp
- Full screen option

---

### PaymentPromptModal

**File:** `lib/features/projects/widgets/payment_prompt_modal.dart`

Modal for project payment flow.

#### Features

- Quote breakdown
- Payment method selection
- Wallet balance check
- Confirmation step

---

### ReviewActions

**File:** `lib/features/projects/widgets/review_actions.dart`

Actions for reviewing delivered projects.

#### Actions

- Approve delivery
- Request revision
- Download files
- View reports

---

## Onboarding Components

### RoleSelectionCard

**File:** `lib/features/onboarding/widgets/role_card.dart`

Card for selecting user type during onboarding.

#### Usage

```dart
RoleSelectionCard(
  userType: UserType.student,
  isSelected: selectedType == UserType.student,
  onTap: () => setState(() => selectedType = UserType.student),
)
```

---

### OnboardingProgress

**File:** `lib/features/onboarding/widgets/progress_indicator.dart`

Step progress indicator for onboarding flow.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `currentStep` | `int` | Current step (1-based) |
| `totalSteps` | `int` | Total number of steps |

---

## Marketplace Components

### ItemCard

**File:** `lib/features/marketplace/widgets/item_card.dart`

Card displaying marketplace listing.

#### Variants

- `ItemCard.standard` - Full card with image
- `ItemCard.compact` - Smaller for grids

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `listing` | `MarketplaceListing` | Listing data |
| `onTap` | `VoidCallback?` | Tap handler |
| `onLikeTap` | `VoidCallback?` | Like button handler |

---

### CategoryChip

**File:** `lib/features/marketplace/widgets/category_chip.dart`

Selectable category filter chip.

#### Usage

```dart
CategoryChip(
  category: MarketplaceCategory.hardGoods,
  isSelected: selectedCategory == MarketplaceCategory.hardGoods,
  onTap: () => selectCategory(MarketplaceCategory.hardGoods),
)
```

---

## Common Patterns

### Loading States

Use Riverpod's `AsyncValue.when`:

```dart
profileAsync.when(
  data: (profile) => ProfileContent(profile: profile),
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (error, _) => ErrorDisplay(message: error.toString()),
)
```

### Empty States

```dart
if (projects.isEmpty) {
  return EmptyState(
    icon: Icons.assignment_outlined,
    title: 'No Projects Yet',
    message: 'Create your first project to get started',
    actionLabel: 'Create Project',
    onAction: () => context.push('/add-project'),
  );
}
```

### Pull to Refresh

```dart
RefreshIndicator(
  onRefresh: () => ref.refresh(projectsProvider.future),
  child: ListView.builder(...),
)
```

### Form Validation

```dart
Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Submit form
          }
        },
        child: Text('Submit'),
      ),
    ],
  ),
)
```

---

## Theming

Components use centralized theming:

```dart
// Colors
import '../../../core/constants/app_colors.dart';
AppColors.primary
AppColors.background
AppColors.error

// Text Styles
import '../../../core/constants/app_text_styles.dart';
AppTextStyles.heading1
AppTextStyles.bodyMedium
AppTextStyles.caption

// Spacing
import '../../../core/constants/app_spacing.dart';
AppSpacing.md
AppSpacing.borderRadiusMd
```
