# AssignX Feature Parity — Implementation Plan

> **Generated:** 2026-02-25
> **Scope:** All non-dashboard changes across User Web (Next.js) and User App (Flutter)
> **Rule:** Dashboard/Home page is NOT touched on either platform

---

## Table of Contents

1. [Phase 1: APP — Settings & Account Features](#phase-1-app--settings--account-features)
2. [Phase 2: APP — Campus Connect Enhancements](#phase-2-app--campus-connect-enhancements)
3. [Phase 3: APP — Project Creation Alignment](#phase-3-app--project-creation-alignment)
4. [Phase 4: APP — Header & Global Features](#phase-4-app--header--global-features)
5. [Phase 5: WEB — Pro Network Page](#phase-5-web--pro-network-page)
6. [Phase 6: WEB — Business Hub Page](#phase-6-web--business-hub-page)
7. [Phase 7: WEB — Marketplace Page](#phase-7-web--marketplace-page)
8. [Phase 8: WEB — Connect Page Enhancements](#phase-8-web--connect-page-enhancements)
9. [Phase 9: WEB — Project Detail Enhancements](#phase-9-web--project-detail-enhancements)
10. [Phase 10: WEB — Campus Connect Post Actions](#phase-10-web--campus-connect-post-actions)
11. [Phase 11: WEB — Profile Preferences](#phase-11-web--profile-preferences)
12. [Phase 12: Profile & Settings Alignment (Both)](#phase-12-profile--settings-alignment-both)

---

## Phase 1: APP — Settings & Account Features

**Priority:** HIGH
**Reason:** Delete/Deactivate Account is required for App Store compliance. Feedback and role management improve UX parity.

### 1.1 My Roles Toggle

**What:** Allow users to toggle between Student/Professional/Business roles from settings.

**Web Reference:** `user-web/components/settings/` — Section 5 in settings page. Three toggle switches (Student, Professional, Business) with descriptions.

**App Changes:**

| Action | File | Details |
|--------|------|---------|
| CREATE | `user_app/lib/features/settings/widgets/my_roles_section.dart` | New widget with 3 toggle switches: Student ("Access Campus Connect"), Professional ("Access Job Portal"), Business ("Access Business Portal & VC Funding"). Uses `Switch` widgets with Riverpod state. |
| MODIFY | `user_app/lib/features/settings/screens/settings_screen.dart` | Add `MyRolesSection` widget between existing sections. |
| MODIFY | `user_app/lib/features/profile/screens/profile_screen.dart` | Add "My Roles" as a settings item that navigates to the settings screen's roles section. |

**Data Flow:**
- Read/write to `user_profiles` table columns: `user_type`, `portal_access` (JSON array)
- Provider: Extend `authStateProvider` or create dedicated `userRolesProvider`

---

### 1.2 Send Feedback Form

**What:** In-app feedback submission with Bug/Feature/General type selector.

**Web Reference:** `user-web/components/settings/feedback-section.tsx` — Feedback type buttons + textarea + submit button.

**App Changes:**

| Action | File | Details |
|--------|------|---------|
| CREATE | `user_app/lib/features/settings/widgets/feedback_section.dart` | Widget with 3 ChoiceChips (Bug with bug icon, Feature with lightbulb icon, General with message icon), a `TextFormField` textarea ("Share your thoughts..."), and "Send Feedback" ElevatedButton. |
| MODIFY | `user_app/lib/features/settings/screens/settings_screen.dart` | Add `FeedbackSection` widget. |

**Data Flow:**
- Insert into `feedback` table: `user_id`, `type` (bug/feature/general), `message`, `created_at`
- Show `SnackBar` on success

---

### 1.3 Danger Zone (Delete/Deactivate Account)

**What:** Account deactivation and deletion options with confirmation dialogs.

**Web Reference:** `user-web/components/profile/danger-zone.tsx` — Three actions: Log Out, Deactivate Account, Delete Account.

**App Changes:**

| Action | File | Details |
|--------|------|---------|
| CREATE | `user_app/lib/features/settings/widgets/danger_zone_section.dart` | Red-themed section with: "Deactivate Account" button ("Temporarily disable your account") and "Delete Account" button ("Permanently delete all data"). Each shows a confirmation `AlertDialog`. |
| MODIFY | `user_app/lib/features/settings/screens/settings_screen.dart` | Add `DangerZoneSection` at bottom of settings. |
| MODIFY | `user_app/lib/features/profile/screens/profile_screen.dart` | Replace simple "Log Out" with navigation to settings danger zone, OR add Deactivate/Delete items directly in profile settings list. |

**Data Flow:**
- Deactivate: Set `user_profiles.status = 'deactivated'`, sign out
- Delete: Call Supabase Edge Function or RPC to cascade-delete user data, then `auth.signOut()`
- Both require password re-entry confirmation

---

### 1.4 Export Data / Clear Cache

**What:** Privacy compliance features — download user data as JSON, clear local cache.

**Web Reference:** `user-web/components/settings/data-section.tsx` — Two action buttons in Privacy & Data section.

**App Changes:**

| Action | File | Details |
|--------|------|---------|
| CREATE | `user_app/lib/features/settings/widgets/privacy_data_section.dart` | Section with: Analytics Opt-out toggle, Show Online Status toggle, "Export Data" button (download icon + chevron), "Clear Cache" button (trash icon + chevron). |
| MODIFY | `user_app/lib/features/settings/screens/settings_screen.dart` | Add `PrivacyDataSection`. |

**Data Flow:**
- Export Data: Fetch all user data from Supabase (profile, projects, wallet, referrals), serialize to JSON, share via `Share.share()` or save to device
- Clear Cache: Clear Hive boxes, SharedPreferences, image cache (`DefaultCacheManager().emptyCache()`)
- Toggles: Store in `user_preferences` table or local SharedPreferences

---

### 1.5 Reduced Motion / Compact Mode

**What:** Accessibility appearance toggles.

**Web Reference:** Settings Section 2 (Appearance) — "Reduced Motion" and "Compact Mode" toggles.

**App Changes:**

| Action | File | Details |
|--------|------|---------|
| MODIFY | `user_app/lib/features/settings/screens/settings_screen.dart` | Add Appearance subsection with two toggles. |
| MODIFY | `user_app/lib/core/hooks/use_reduced_motion.dart` | Already exists — wire it to the settings toggle value stored in SharedPreferences. |
| CREATE | `user_app/lib/core/providers/appearance_provider.dart` | Riverpod provider for `reducedMotion` and `compactMode` boolean states, persisted to SharedPreferences. |

**Data Flow:**
- `reducedMotion`: Disables `flutter_animate` animations globally. Already has `use_reduced_motion.dart` hook.
- `compactMode`: Reduces padding/spacing by ~30%. Provide `AppSpacing.compact` variant.

---

### 1.6 About AssignX Section

**What:** Show app version, build number, and legal links.

**Web Reference:** Settings Section 4 — Version 1.0.0-beta, Build 2024.12.26, Terms/Privacy/Open Source links.

**App Changes:**

| Action | File | Details |
|--------|------|---------|
| CREATE | `user_app/lib/features/settings/widgets/about_section.dart` | Card showing: Version (from `package_info_plus`), Build number, Status badge ("Beta"), Last Updated date. Links to Terms, Privacy, Open Source. |
| MODIFY | `user_app/lib/features/settings/screens/settings_screen.dart` | Add `AboutSection` at bottom before Danger Zone. |

---

## Phase 2: APP — Campus Connect Enhancements

**Priority:** HIGH
**Reason:** Campus Connect is a core engagement feature. Web has significantly richer UX.

### 2.1 Hero Section with Live Stats

**What:** Add hero section with live activity stats and campus buzzing indicator.

**Web Reference:** `user-web/components/campus-connect/campus-pulse-hero.tsx`, `live-stats-badge.tsx`, `live-activity-feed.tsx`

**App Changes:**

| Action | File | Details |
|--------|------|---------|
| MODIFY | `user_app/lib/features/campus_connect/widgets/campus_connect_hero.dart` | Already exists but is simple. Redesign to match web: Add "Campus Connect" badge, "Your Campus is BUZZING" animated text, live stats row ("47 posts in last hour", "234 students online", "12 colleges active"), and "Verify College to Post" CTA button. |
| CREATE | `user_app/lib/features/campus_connect/widgets/live_stats_badge.dart` | Animated stat badges with pulse effect. Each badge: icon + count + label. |

**Data Flow:**
- Live stats: Query `campus_posts` table for counts (posts in last hour, distinct users online, distinct colleges)
- Use Supabase realtime subscription for live updates
- "Verify College to Post" navigates to `college_verification_screen.dart` (already exists in auth)

---

### 2.2 Feature Carousel

**What:** Sliding carousel explaining Campus Connect features.

**Web Reference:** `user-web/components/campus-connect/campus-pulse-hero.tsx` — 4-slide carousel with prev/next buttons and dot indicators.

**App Changes:**

| Action | File | Details |
|--------|------|---------|
| CREATE | `user_app/lib/features/campus_connect/widgets/feature_carousel.dart` | `PageView` with 4 slides: (1) "Your Campus Community" - Join conversations, (2) "Find Housing" - PGs/flats, (3) "Grab Opportunities" - Jobs/internships, (4) "Buy & Sell" - Marketplace. Each slide: badge, heading, description, feature bullets. Dot indicators + auto-scroll. |

---

### 2.3 "What is Campus Connect" Section

**What:** 6 feature cards explaining the platform.

**Web Reference:** `user-web/components/campus-connect/campus-connect-page.tsx` — Grid of 6 feature cards.

**App Changes:**

| Action | File | Details |
|--------|------|---------|
| CREATE | `user_app/lib/features/campus_connect/widgets/feature_cards_grid.dart` | Grid of 6 tappable cards: Ask & Answer (chat icon), Find Housing (home icon), Grab Opportunities (briefcase icon), Join Events (calendar icon), Buy & Sell (shopping icon), Network (users icon). Each card navigates to the respective category filter. |

---

### 2.4 Quick Access Buttons

**What:** 5 shortcut buttons for quick category navigation.

**Web Reference:** Campus Connect "Quick Access" section — 5 emoji buttons.

**App Changes:**

| Action | File | Details |
|--------|------|---------|
| CREATE | `user_app/lib/features/campus_connect/widgets/quick_access_row.dart` | Horizontal row of 5 circular action buttons: Questions ("Ask doubts"), Jobs ("Internships"), Events ("Campus events"), Market ("Buy & sell"), Resources ("Study tips"). Tapping sets the active category filter. |

---

### 2.5 Additional Category Filters

**What:** Web has 12 categories; app has ~6. Add missing ones.

**Web Categories:** All, Questions, Opportunities, Events, Marketplace, Resources, Lost & Found, Rides, Study Groups, Clubs, Announcements, Discussions

**App Changes:**

| Action | File | Details |
|--------|------|---------|
| MODIFY | `user_app/lib/features/campus_connect/widgets/filter_tabs_bar.dart` | Add missing categories: Lost & Found (magnifying glass), Rides (car), Study Groups (people), Clubs (trophy), Announcements (megaphone), Discussions (speech bubble). Update the enum/list of filter categories. |

---

### 2.6 Live Feed Preview

**What:** Show 4 recent posts from different colleges in the hero area.

**Web Reference:** Hero section right panel — 4 preview posts with college, time, content, category.

**App Changes:**

| Action | File | Details |
|--------|------|---------|
| CREATE | `user_app/lib/features/campus_connect/widgets/live_feed_preview.dart` | Small scrollable list of 4 recent post previews. Each shows: college avatar, college name, timestamp, content snippet, category chip. Tapping opens the full post. |

---

### 2.7 Integrate All New Widgets into Campus Connect Screen

| Action | File | Details |
|--------|------|---------|
| MODIFY | `user_app/lib/features/campus_connect/screens/campus_connect_screen.dart` | Restructure the screen body as a `CustomScrollView` with sections in order: (1) Hero with live stats, (2) Live feed preview, (3) Feature carousel, (4) "What is Campus Connect" cards, (5) Quick access row, (6) Search bar + college filter, (7) Category filter tabs (12 categories), (8) Posts feed. |

---

## Phase 3: APP — Project Creation Alignment

**Priority:** MEDIUM-HIGH
**Reason:** Multi-step wizard provides better UX than separate forms. Website/App project types are missing.

### 3.1 Multi-Step Project Wizard

**What:** Replace 4 separate form screens with a unified multi-step wizard matching the web.

**Web Reference:** `user-web/components/add-project/` — `form-steps.tsx`, `form-layout.tsx`, `steps/step-subject.tsx`, `step-details.tsx`, `step-requirements.tsx`, `step-deadline.tsx`

**App Changes:**

| Action | File | Details |
|--------|------|---------|
| CREATE | `user_app/lib/features/add_project/screens/project_wizard_screen.dart` | New unified wizard screen with `PageView` or `Stepper`. 4 steps: (1) Project Type + Subject, (2) Details + Requirements, (3) Deadline + Files, (4) Review + Submit. Progress indicator showing "25% / 50% / 75% / 100%". |
| CREATE | `user_app/lib/features/add_project/widgets/wizard_progress_sidebar.dart` | Left/top progress panel (mobile-optimized): step title, description, pro tip, trust badges ("15,234 projects", "4.9/5 rating", "98% on-time"), next step hint. |
| CREATE | `user_app/lib/features/add_project/widgets/project_type_selector.dart` | 5 project type cards (replaces service_selection_sheet): Assignment, Document, Website, App, Consultancy. Each with icon and description. |
| MODIFY | `user_app/lib/features/add_project/widgets/subject_dropdown.dart` | Ensure 10 subjects match web: Engineering, Business & Management, Medicine & Healthcare, Law, Natural Sciences, Mathematics & Statistics, Humanities & Literature, Social Sciences, Arts & Design, Other. Make searchable. |
| MODIFY | `user_app/lib/core/router/app_router.dart` | Add route for new wizard: `/add-project/wizard`. Keep old routes as fallbacks. |
| MODIFY | `user_app/lib/core/router/route_names.dart` | Add `projectWizard` route name. |

**Data Flow:**
- Wizard state managed by a local `StateNotifier` or `ChangeNotifier`
- On final step submit, call existing project creation Supabase function
- Website/App types: Add `project_type` enum values: `website`, `app` in addition to existing `assignment`, `document`, `consultancy`

---

### 3.2 Quote Ready Dialog Enhancement

**What:** Match the web's detailed quote popup with full project info.

**Web Reference:** `user-web/components/projects/payment-prompt-modal.tsx` — Shows project ID, name, subject, quote amount, validity, pay/later buttons.

**App Changes:**

| Action | File | Details |
|--------|------|---------|
| MODIFY | `user_app/lib/features/projects/widgets/payment_prompt_modal.dart` | Enhance to show: "Quote Ready" title, "Your project has been reviewed and quoted" subtitle, Project ID (AX-XXXXXX), Project Name, Subject, Quote Amount (Rs.XXX), Validity (24 hours), "Proceed to Pay" primary button, "I'll pay later" secondary button, info note "Work begins after payment". |

---

## Phase 4: APP — Header & Global Features

**Priority:** MEDIUM
**Reason:** Language selector and theme toggle improve accessibility and match web UX.

### 4.1 Language Selector

**What:** Add language selection accessible from the header or settings.

**Web Reference:** `user-web/components/language-selector.tsx` — Dropdown with 6 languages.

**App has:** `user_app/lib/core/translation/` — translation_service.dart, supported_languages.dart, translation_cache.dart, translation_extensions.dart (infrastructure exists but no UI).

**App Changes:**

| Action | File | Details |
|--------|------|---------|
| CREATE | `user_app/lib/features/settings/widgets/language_selector.dart` | Bottom sheet or dropdown with 6 languages: English (US flag), Hindi (India flag), Francais (France flag), Arabic (UAE flag, RTL tag), Espanol (Spain flag), Chinese (China flag). Tapping changes the app locale. |
| MODIFY | `user_app/lib/features/home/widgets/home_app_bar.dart` | Add a globe/language icon button that opens the language selector sheet. |
| MODIFY | `user_app/lib/core/translation/translation_service.dart` | Wire selected language to the translation service. Persist choice in SharedPreferences. |

---

### 4.2 Theme Toggle in Header

**What:** Quick dark/light mode toggle visible in the app bar.

**Web Reference:** `user-web/components/theme-toggle.tsx` — Sun/moon icon button in top bar.

**App has:** `user_app/lib/core/theme/app_theme.dart` — Theme definitions exist. Toggle is only in App Settings deep in profile.

**App Changes:**

| Action | File | Details |
|--------|------|---------|
| MODIFY | `user_app/lib/features/home/widgets/home_app_bar.dart` | Add a sun/moon icon button next to the notification bell. Toggles `themeMode` between light and dark. |
| CREATE | `user_app/lib/core/providers/theme_provider.dart` | Riverpod `StateNotifierProvider` for theme mode. Persists to SharedPreferences. Already partially exists in app_theme.dart. |

---

## Phase 5: WEB — Pro Network Page

**Priority:** HIGH
**Reason:** App has full Pro Network feature that web completely lacks.

### 5.1 Pro Network Dashboard Page

**What:** Professional networking tab with posts, filters, create/save functionality.

**App Reference:**
- `user_app/lib/features/pro_network/screens/pro_network_screen.dart` — Main feed
- `user_app/lib/features/pro_network/screens/pro_create_post_screen.dart` — Create post
- `user_app/lib/features/pro_network/screens/pro_post_detail_screen.dart` — Post detail
- `user_app/lib/features/pro_network/screens/pro_saved_posts_screen.dart` — Saved posts
- `user_app/lib/features/pro_network/widgets/` — Hero, filter tabs, search bar, post card

**Web Changes:**

| Action | File | Details |
|--------|------|---------|
| CREATE | `user-web/app/(dashboard)/pro-network/page.tsx` | Server component that renders the Pro Network page. |
| CREATE | `user-web/app/(dashboard)/pro-network/loading.tsx` | Skeleton loading state. |
| CREATE | `user-web/app/(dashboard)/pro-network/[postId]/page.tsx` | Individual post detail page. |
| CREATE | `user-web/app/(dashboard)/pro-network/create/page.tsx` | Create post page. |
| CREATE | `user-web/components/pro-network/index.ts` | Barrel export for all components. |
| CREATE | `user-web/components/pro-network/pro-network-page.tsx` | Main page component with hero, search, filters, feed. |
| CREATE | `user-web/components/pro-network/pro-hero.tsx` | Hero section for professional network. |
| CREATE | `user-web/components/pro-network/pro-post-card.tsx` | Post card matching app's `pro_post_card.dart` design. |
| CREATE | `user-web/components/pro-network/pro-filter-tabs.tsx` | Category filter tabs for professional content. |
| CREATE | `user-web/components/pro-network/pro-search-bar.tsx` | Search bar component. |
| CREATE | `user-web/components/pro-network/create-pro-post-form.tsx` | Form to create professional network posts. |
| CREATE | `user-web/components/pro-network/saved-posts.tsx` | Saved posts view. |
| CREATE | `user-web/types/pro-network.ts` | TypeScript types for pro network posts. |
| CREATE | `user-web/lib/actions/pro-network.ts` | Server actions for CRUD operations. |
| MODIFY | `user-web/components/dashboard/sidebar.tsx` | Add "Pro Network" nav item with briefcase icon. |
| MODIFY | `user-web/components/navigation/mobile-bottom-nav.tsx` | Add Pro Network to mobile nav (or use portal switcher). |

**Data Model (Supabase):**
- Table: `pro_network_posts` (mirrors app's `pro_network_post_model.dart`)
- Columns: `id`, `user_id`, `title`, `content`, `category`, `tags`, `likes_count`, `comments_count`, `created_at`, `updated_at`

---

## Phase 6: WEB — Business Hub Page

**Priority:** HIGH
**Reason:** App has full Business Hub that web completely lacks.

### 6.1 Business Hub Dashboard Page

**What:** Business community with posts, filters, create/save — mirrors app's Business Hub.

**App Reference:**
- `user_app/lib/features/business_hub/screens/` — 4 screens (main, create, detail, saved)
- `user_app/lib/features/business_hub/widgets/` — Hero, filter tabs, search bar, post card
- `user_app/lib/features/business_hub/data/models/business_hub_post_model.dart`

**Web Changes:**

| Action | File | Details |
|--------|------|---------|
| CREATE | `user-web/app/(dashboard)/business-hub/page.tsx` | Server component for Business Hub. |
| CREATE | `user-web/app/(dashboard)/business-hub/loading.tsx` | Skeleton loading. |
| CREATE | `user-web/app/(dashboard)/business-hub/[postId]/page.tsx` | Post detail. |
| CREATE | `user-web/app/(dashboard)/business-hub/create/page.tsx` | Create post. |
| CREATE | `user-web/components/business-hub/index.ts` | Barrel export. |
| CREATE | `user-web/components/business-hub/business-hub-page.tsx` | Main page: hero, search, filters, feed. |
| CREATE | `user-web/components/business-hub/business-hero.tsx` | Hero section. |
| CREATE | `user-web/components/business-hub/business-post-card.tsx` | Post card. |
| CREATE | `user-web/components/business-hub/business-filter-tabs.tsx` | Filter tabs. |
| CREATE | `user-web/components/business-hub/business-search-bar.tsx` | Search bar. |
| CREATE | `user-web/components/business-hub/create-business-post-form.tsx` | Create form. |
| CREATE | `user-web/components/business-hub/saved-posts.tsx` | Saved view. |
| CREATE | `user-web/types/business-hub.ts` | TypeScript types. |
| CREATE | `user-web/lib/actions/business-hub.ts` | Server actions. |
| MODIFY | `user-web/components/dashboard/sidebar.tsx` | Add "Business Hub" nav item. |

**Integration with Portal System:**
- Web already has `user-web/components/portals/` with `portal-page.tsx`, `portal-switcher.tsx`, `business-portal.tsx`
- Wire the Business Hub page to the portal switcher so it shows for Business-role users

---

## Phase 7: WEB — Marketplace Page

**Priority:** HIGH
**Reason:** App has full marketplace (listings, create, detail) that web only has a detail view.

### 7.1 Marketplace Listing Page

**What:** Full marketplace with grid of listings, search, filters, create listing.

**App Reference:**
- `user_app/lib/features/marketplace/screens/marketplace_screen.dart`
- `user_app/lib/features/marketplace/screens/create_listing_screen.dart`
- `user_app/lib/features/marketplace/widgets/` — item_card, marketplace_filters, banner_card, tutor_card, etc.

**Web Changes:**

| Action | File | Details |
|--------|------|---------|
| CREATE | `user-web/app/(dashboard)/marketplace/page.tsx` | Server component for marketplace listing page. |
| CREATE | `user-web/app/(dashboard)/marketplace/loading.tsx` | Skeleton loading. |
| CREATE | `user-web/app/(dashboard)/marketplace/create/page.tsx` | Create new listing page. |
| MODIFY | `user-web/components/marketplace/index.ts` | Export new components. |
| CREATE | `user-web/components/marketplace/marketplace-page.tsx` | Main page: search, filters, grid of items. |
| CREATE | `user-web/components/marketplace/marketplace-hero.tsx` | Hero/header section. |
| CREATE | `user-web/components/marketplace/marketplace-grid.tsx` | Grid layout for items. |
| CREATE | `user-web/components/marketplace/tutor-card.tsx` | Tutor listing card. |
| MODIFY | `user-web/components/marketplace/filter-bar.tsx` | Ensure category filters match app (Books, Gadgets, Services, Tutoring, etc.). |
| CREATE | `user-web/lib/actions/marketplace.ts` | Server actions — already exists partially at `lib/actions/marketplace.ts`. Extend for listing creation. |
| MODIFY | `user-web/components/dashboard/sidebar.tsx` | Add "Marketplace" nav item with shopping bag icon. |

---

## Phase 8: WEB — Connect Page Enhancements

**Priority:** MEDIUM
**Reason:** Web has a basic connect page. App has richer Tutors/Study Groups/Resources tabs.

### 8.1 Connect Tabs Enhancement

**What:** Add Tutors, Study Groups, and Resources tab views to the Connect page.

**App Reference:**
- `user_app/lib/features/connect/screens/connect_screen.dart` — Main with tabs
- `user_app/lib/features/connect/screens/study_groups_screen.dart`
- `user_app/lib/features/connect/widgets/` — resource_cards, study_group_card, connect_search, advanced_filter_sheet

**Web has:** `user-web/components/connect/` with tutor-card, study-group-card, resource-card, qa-section — components exist but may not be fully wired.

**Web Changes:**

| Action | File | Details |
|--------|------|---------|
| MODIFY | `user-web/app/(dashboard)/connect/page.tsx` | Ensure 3 tabs are visible and functional: Tutors, Study Groups, Resources. |
| MODIFY | `user-web/components/connect/index.ts` | Export all sub-components. |
| CREATE | `user-web/components/connect/connect-tabs.tsx` | Tab container for switching between Tutors/Study Groups/Resources. |
| MODIFY | `user-web/components/connect/study-group-card.tsx` | Ensure full functionality: group name, members count, schedule, join button. |
| MODIFY | `user-web/components/connect/resource-card.tsx` | Ensure displays: resource title, type, download/view button. |

---

## Phase 9: WEB — Project Detail Enhancements

**Priority:** MEDIUM
**Reason:** App has Timeline and Live Draft features that web needs.

### 9.1 Project Timeline

**What:** Visual timeline of project events/milestones.

**App Reference:** `user_app/lib/features/projects/screens/project_timeline_screen.dart`

**Web has:** `user-web/app/(dashboard)/project/[id]/timeline/page.tsx` and `user-web/components/projects/project-timeline.tsx` — exists but verify functionality.

**Web Changes:**

| Action | File | Details |
|--------|------|---------|
| VERIFY | `user-web/app/(dashboard)/project/[id]/timeline/page.tsx` | Confirm timeline page renders correctly with events from `project_events` table. |
| VERIFY | `user-web/components/projects/project-timeline.tsx` | Ensure events show: timestamp, event type (submitted, assigned, in progress, review, completed), description, actor. |

---

### 9.2 Live Draft View

**What:** Real-time draft viewing from expert/doer.

**App Reference:** `user_app/lib/features/projects/screens/live_draft_webview.dart`, `user_app/lib/features/projects/widgets/live_draft_section.dart`

**Web has:** `user-web/components/project-detail/live-draft-tracker.tsx` — exists.

**Web Changes:**

| Action | File | Details |
|--------|------|---------|
| VERIFY | `user-web/components/project-detail/live-draft-tracker.tsx` | Ensure live draft section displays in project detail when a draft URL is available. Should show embedded iframe or document preview with last updated timestamp. |

---

## Phase 10: WEB — Campus Connect Post Actions

**Priority:** MEDIUM
**Reason:** App has Post/Saved buttons and FAB that web lacks as explicit UI elements.

### 10.1 Post & Saved Action Buttons

**What:** Explicit "Post" and "Saved" buttons in the Campus Connect header area.

**App Reference:** Campus Connect screen has "Post" and "Saved" action buttons in the header.

**Web Changes:**

| Action | File | Details |
|--------|------|---------|
| MODIFY | `user-web/components/campus-connect/campus-connect-page.tsx` | Add "Post" button (navigates to `/campus-connect/create`) and "Saved" button (shows saved listings). Position after search bar or in a toolbar row. |

---

### 10.2 Floating Action Button (FAB)

**What:** "+" FAB for quick post creation on campus connect.

**App Reference:** Campus Connect has a floating action button to create posts.

**Web Changes:**

| Action | File | Details |
|--------|------|---------|
| MODIFY | `user-web/components/campus-connect/campus-connect-page.tsx` | Add a fixed-position FAB (bottom-right) with "+" icon that navigates to `/campus-connect/create`. Only show when user is verified. |

---

## Phase 11: WEB — Profile Preferences

**Priority:** LOW-MEDIUM
**Reason:** App has a PreferencesSection in profile that web lacks.

### 11.1 Preferences Section

**What:** User preferences section in profile page.

**App Reference:** `user_app/lib/features/profile/widgets/preferences_section.dart`

**Web has:** `user-web/components/profile/preferences-section.tsx` — file exists.

**Web Changes:**

| Action | File | Details |
|--------|------|---------|
| VERIFY | `user-web/components/profile/preferences-section.tsx` | Confirm it's imported and rendered on the profile page. |
| MODIFY | `user-web/app/(dashboard)/profile/page.tsx` | If not already showing, add `<PreferencesSection />` to the profile page between referral section and settings links. |

---

## Phase 12: Profile & Settings Alignment (Both)

**Priority:** MEDIUM
**Reason:** Several data inconsistencies and UI differences between platforms.

### 12.1 Plan Badge vs User Type Badge (APP)

**What:** Web shows "free" plan badge. App shows "Professional" user type badge. Align to show both.

| Action | File | Details |
|--------|------|---------|
| MODIFY | `user_app/lib/features/profile/widgets/account_badge.dart` | Show plan tier badge ("Free", "Pro", "Premium") alongside user type badge ("Student", "Professional"). |

### 12.2 App Version Footer (APP)

**What:** Add version footer to profile screen matching web's "AssignX v1.0.0" + Terms/Privacy/Help links.

| Action | File | Details |
|--------|------|---------|
| CREATE | `user_app/lib/features/profile/widgets/app_info_footer.dart` | Footer widget: "AssignX v{version}" centered, then row of "Terms", "Privacy", "Help" text links separated by dots. Use `package_info_plus` for version. |
| MODIFY | `user_app/lib/features/profile/screens/profile_screen.dart` | Add `AppInfoFooter` at the bottom of the scroll view. |

### 12.3 Settings Quick Links Alignment (WEB)

**What:** Web profile has 5 settings items. App has 8+. Align web to include App Settings and Help.

| Action | File | Details |
|--------|------|---------|
| MODIFY | `user-web/app/(dashboard)/profile/page.tsx` | Add "App Settings" (gear icon) and "Help & Support" (question mark icon) to settings quick links. "App Settings" navigates to `/settings`, "Help" to `/support`. |

---

## Implementation Order Summary

| Priority | Phase | Platform | Feature | Est. Files |
|----------|-------|----------|---------|------------|
| 1 | Phase 1.3 | APP | Danger Zone (Delete/Deactivate) | 2 new, 2 modified |
| 2 | Phase 1.1 | APP | My Roles Toggle | 1 new, 2 modified |
| 3 | Phase 1.2 | APP | Send Feedback | 1 new, 1 modified |
| 4 | Phase 2 | APP | Campus Connect Full Overhaul | 5 new, 2 modified |
| 5 | Phase 5 | WEB | Pro Network Page | 12 new, 2 modified |
| 6 | Phase 6 | WEB | Business Hub Page | 12 new, 1 modified |
| 7 | Phase 7 | WEB | Marketplace Page | 5 new, 3 modified |
| 8 | Phase 3.1 | APP | Multi-Step Project Wizard | 3 new, 3 modified |
| 9 | Phase 4 | APP | Language Selector + Theme Toggle | 2 new, 2 modified |
| 10 | Phase 8 | WEB | Connect Tabs Enhancement | 1 new, 3 modified |
| 11 | Phase 1.4 | APP | Export Data / Clear Cache | 1 new, 1 modified |
| 12 | Phase 1.5 | APP | Reduced Motion / Compact Mode | 1 new, 1 modified |
| 13 | Phase 1.6 | APP | About Section | 1 new, 1 modified |
| 14 | Phase 3.2 | APP | Quote Dialog Enhancement | 0 new, 1 modified |
| 15 | Phase 10 | WEB | Campus Connect Post Actions/FAB | 0 new, 1 modified |
| 16 | Phase 11 | WEB | Profile Preferences Verify | 0 new, 1 modified |
| 17 | Phase 12 | BOTH | Profile & Settings Alignment | 1 new, 4 modified |
| 18 | Phase 9 | WEB | Project Timeline/Live Draft Verify | 0 new, 2 verify |

**Total Estimated:**
- **New files:** ~48
- **Modified files:** ~32
- **Verify existing:** ~4

---

## Excluded from Scope

The following are **explicitly excluded** per user instruction:

| Feature | Reason |
|---------|--------|
| Dashboard/Home page changes | User said: "Don't change anything on the dashboard" |
| Campus Pulse on Web Dashboard | Dashboard exclusion |
| Recent Projects on Web Dashboard | Dashboard exclusion |
| Quick Action cards alignment | Dashboard exclusion |
| Stats row alignment | Dashboard exclusion |
| Landing page (web only) | Not in the app, marketing page |
| Keyboard shortcuts (web) | Not applicable to mobile |
| Reference Generator (app only) | External link, not a feature to port |
| College Verification screen | Already exists in both platforms |
| Payment Prompt Modal (app only) | Already exists in app, web has Quote Dialog |

---

## Supabase Tables Needed

| Table | For | Status |
|-------|-----|--------|
| `feedback` | Send Feedback feature | May need CREATE |
| `pro_network_posts` | Pro Network | Verify EXISTS (app uses it) |
| `business_hub_posts` | Business Hub | Verify EXISTS (app uses it) |
| `user_preferences` | Appearance/privacy settings | May need columns added |
| `campus_posts` | Campus Connect (already exists) | EXISTS |
| `marketplace_listings` | Marketplace | Verify EXISTS |

---

## Testing Checklist

After each phase, verify:

- [ ] Feature renders correctly on target platform
- [ ] Data persists to Supabase correctly
- [ ] Navigation works (deep links, back button)
- [ ] Loading states display properly
- [ ] Error states handled gracefully
- [ ] Responsive layout (app: different screen sizes; web: mobile/tablet/desktop)
- [ ] Dark/light theme works for new components
- [ ] No TypeScript/Dart compilation errors
