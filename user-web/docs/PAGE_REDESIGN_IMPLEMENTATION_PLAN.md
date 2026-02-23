# Page Redesign Implementation Plan

## Executive Summary

This document outlines the comprehensive redesign plan for AssignX web application pages to achieve visual consistency with the Dashboard and Projects reference designs.

---

## 1. Design System Analysis

### Reference Designs (Dashboard & Projects)

#### Key Design Patterns Identified:

1. **Gradient Backgrounds**
   - Class: `mesh-gradient-bottom-right-animated`
   - Time-based variants: `mesh-gradient-morning`, `mesh-gradient-afternoon`, `mesh-gradient-evening`
   - Fixed height, non-scrollable backgrounds
   - Applied to full viewport

2. **Glass Morphism**
   - Cards use `action-card-glass` class
   - Backdrop blur with border opacity
   - Subtle shadows for depth

3. **Animation System**
   - Framer Motion with spring configs (`stiffness: 300-400, damping: 28-30`)
   - `AnimatePresence` for page transitions
   - Staggered reveal animations via `StaggerItem` component

4. **Skeleton Loading**
   - `PageSkeletonProvider` for unified loading experience
   - Minimum 1000ms display duration
   - Component-specific skeleton designs

5. **Lottie Animations**
   - Dynamic imports for SSR compatibility
   - Located in `/public/lottie/icons/`
   - Used for greeting animations and page headers

---

## 2. Current State Analysis

### Pages Requiring Redesign:

| Page | Current State | Required Changes |
|------|---------------|-----------------|
| **Landing** | Separate design system | Add gradient background, align with app design |
| **Campus Connect** | `connect-curved-hero` gradient | Replace with `gradient.jpg` image header |
| **Wallet** | `wallet-dome-hero` gradient | Replace with `gradient.jpg` image header |
| **Settings** | No gradient, basic cards | Add gradient background, glass morphism |
| **Profile** | No gradient, basic cards | Add gradient background, glass morphism |
| **Project Detail** | Complex layout | Update styling to match new system |
| **Campus Post Detail** | Generic view | Create category-specific layouts |

### Assets Available:
- Image: `public/gradient.jpg` (for Campus Connect & Wallet headers)
- Lottie: `public/lottie/icons/computer.json`, `pizza.json`, `game.json`

---

## 3. Implementation Plan

### Phase 1: Landing Page

**Current:** Uses separate `landing.css` with custom CSS variables

**Changes:**
1. Add gradient background to hero section
2. Use `mesh-gradient-bottom-right-animated` class
3. Apply time-based gradient variants
4. Keep existing animations but enhance with spring configs

**Implementation:**
```tsx
// app/page.tsx or components/landing/hero-section.tsx
<section className="mesh-gradient-bottom-right-animated mesh-gradient-{time}">
  {/* existing content */}
</section>
```

**Files to Edit:**
- `components/landing/hero-section.tsx`

---

### Phase 2: Campus Connect Page

**Current:** Uses `connect-curved-hero` CSS class with gradient

**Changes:**
1. Replace gradient with `gradient.jpg` image
2. Clip image to curved shape
3. Maintain Lottie animation overlay
4. Keep search and filter functionality

**Implementation:**
```tsx
// components/campus-connect/campus-connect-page.tsx
<div className="connect-curved-hero relative">
  <Image
    src="/gradient.jpg"
    alt=""
    fill
    className="object-cover"
    priority
  />
  <div className="absolute inset-0 bg-gradient-to-b from-transparent to-background/90" />
</div>
```

**CSS Updates (globals.css):**
```css
.connect-curved-hero {
  position: relative;
  overflow: hidden;
  /* Keep curved bottom edge */
}

.connect-curved-hero img {
  clip-path: ellipse(100% 100% at 50% 0%);
}
```

**Files to Edit:**
- `components/campus-connect/campus-connect-page.tsx`
- `app/globals.css`

---

### Phase 3: Wallet Page

**Current:** Uses `wallet-dome-hero` with gradient, credit card design

**Changes:**
1. Replace gradient with `gradient.jpg` image
2. Clip image to dome shape
3. Keep credit card and balance widgets
4. Add glass morphism to widgets

**Implementation:**
```tsx
// app/(dashboard)/wallet/page.tsx
<div className="wallet-dome-hero relative">
  <Image
    src="/gradient.jpg"
    alt=""
    fill
    className="object-cover"
    priority
  />
  <div className="absolute inset-0 bg-gradient-to-b from-transparent via-transparent to-background" />
</div>
```

**Files to Edit:**
- `app/(dashboard)/wallet/page.tsx`
- `app/globals.css`

---

### Phase 4: Settings Page

**Current:** Basic card layout, no gradient

**Changes:**
1. Add `mesh-gradient-bottom-right-animated` background
2. Apply glass morphism to setting sections
3. Add staggered reveal animations
4. Enhance toggle/button interactions

**Implementation:**
```tsx
// app/(dashboard)/settings/settings-pro.tsx
export function SettingsPro() {
  return (
    <div className="mesh-gradient-bottom-right-animated min-h-full">
      <main className="relative z-10 p-6 md:p-8 max-w-3xl mx-auto">
        <StaggerItem>
          {/* Settings sections with glass morphism */}
        </StaggerItem>
      </main>
    </div>
  );
}
```

**Section Component Update:**
```tsx
function SettingsSection({ ... }) {
  return (
    <div className="action-card-glass rounded-xl overflow-hidden">
      {/* content */}
    </div>
  );
}
```

**Files to Edit:**
- `app/(dashboard)/settings/settings-pro.tsx`

---

### Phase 5: Profile Page

**Current:** Basic card layout, no gradient

**Changes:**
1. Add `mesh-gradient-bottom-right-animated` background
2. Apply glass morphism to profile card and stats
3. Add staggered reveal animations
4. Enhance avatar and stat card interactions

**Implementation:**
```tsx
// app/(dashboard)/profile/profile-pro.tsx
export function ProfilePro({ ... }) {
  return (
    <div className="mesh-gradient-bottom-right-animated min-h-full">
      <main className="relative z-10 p-6 md:p-8 max-w-2xl mx-auto">
        <StaggerItem>
          <section className="action-card-glass p-5 rounded-xl">
            {/* Profile header */}
          </section>
        </StaggerItem>
      </main>
    </div>
  );
}
```

**Files to Edit:**
- `app/(dashboard)/profile/profile-pro.tsx`

---

### Phase 6: Project Detail Section

**Current:** Complex layout with chat panel, step progress

**Changes:**
1. Add subtle gradient background
2. Apply glass morphism to info cards
3. Enhance timeline and progress animations
4. Improve mobile responsiveness

**Files to Edit:**
- `app/project/[id]/project-detail-client.tsx`

---

### Phase 7: Campus Connect Post Detail Pages

**Current:** Generic `PostDetailView` for all categories

**Required:** Category-specific layouts with unique styling

#### Categories:
1. **Doubts** - Q&A style with answer highlighting
2. **Residentials** - Property listing style with gallery
3. **Jobs** - Job posting style with requirements list
4. **Teacher Reviews** - Review card with rating display
5. **Subject Tips** - Article/tip style with highlight boxes
6. **Events** - Event card with date/time prominence

**Implementation Approach:**
Create variant components for each category:

```tsx
// components/campus-connect/post-detail-view.tsx
function PostDetailView({ postId }) {
  // ... existing fetch logic

  switch (post.category) {
    case "doubts":
      return <DoubtsDetailView post={post} comments={comments} />;
    case "residentials":
      return <ResidentialsDetailView post={post} comments={comments} />;
    case "jobs":
      return <JobsDetailView post={post} comments={comments} />;
    case "teacher_reviews":
      return <TeacherReviewDetailView post={post} comments={comments} />;
    case "subject_tips":
      return <SubjectTipsDetailView post={post} comments={comments} />;
    case "events":
      return <EventsDetailView post={post} comments={comments} />;
    default:
      return <DefaultDetailView post={post} comments={comments} />;
  }
}
```

**Files to Create/Edit:**
- `components/campus-connect/details/doubts-detail.tsx`
- `components/campus-connect/details/residentials-detail.tsx`
- `components/campus-connect/details/jobs-detail.tsx`
- `components/campus-connect/details/teacher-review-detail.tsx`
- `components/campus-connect/details/subject-tips-detail.tsx`
- `components/campus-connect/details/events-detail.tsx`
- `components/campus-connect/details/index.ts`
- `components/campus-connect/post-detail-view.tsx` (update)

---

## 4. CSS Updates Required

### New CSS Classes to Add (globals.css):

```css
/* Image-based hero backgrounds */
.image-hero-dome {
  position: relative;
  overflow: hidden;
}

.image-hero-dome::after {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(to bottom, transparent 60%, var(--background) 100%);
}

.image-hero-curved {
  position: relative;
  overflow: hidden;
  clip-path: ellipse(150% 100% at 50% 0%);
}

/* Glass morphism enhancement */
.glass-section {
  background: hsl(var(--card) / 0.7);
  backdrop-filter: blur(12px);
  border: 1px solid hsl(var(--border) / 0.3);
}
```

---

## 5. Animation Constants

Use consistent spring configurations:

```tsx
// lib/animations/constants.ts
export const SPRING_CONFIG = {
  smooth: { type: "spring", stiffness: 300, damping: 28, mass: 0.8 },
  snappy: { type: "spring", stiffness: 400, damping: 30 },
  gentle: { type: "spring", stiffness: 200, damping: 25 },
};

export const STAGGER_CONFIG = {
  container: { staggerChildren: 0.05 },
  item: { opacity: [0, 1], y: [20, 0] },
};
```

---

## 6. Implementation Order

1. **Landing Page** - Isolated, won't break existing dashboard
2. **Settings Page** - Simple, limited dependencies
3. **Profile Page** - Similar to Settings
4. **Wallet Page** - Image header swap
5. **Campus Connect Page** - Image header swap
6. **Campus Connect Detail Pages** - New components
7. **Project Detail** - Complex, do last

---

## 7. QA Checklist

### Per Page:
- [ ] Gradient/image renders correctly
- [ ] No layout shifts on load
- [ ] Skeleton loading works
- [ ] Animations are smooth (60fps)
- [ ] Dark/light mode works
- [ ] Mobile responsive
- [ ] No console errors
- [ ] Accessibility maintained

### Global:
- [ ] Page transitions work
- [ ] Dock navigation visible on all pages
- [ ] Header consistent across pages
- [ ] No CSS conflicts between pages

---

## 8. Files Summary

### To Edit:
1. `components/landing/hero-section.tsx`
2. `components/campus-connect/campus-connect-page.tsx`
3. `app/(dashboard)/wallet/page.tsx`
4. `app/(dashboard)/settings/settings-pro.tsx`
5. `app/(dashboard)/profile/profile-pro.tsx`
6. `app/project/[id]/project-detail-client.tsx`
7. `components/campus-connect/post-detail-view.tsx`
8. `app/globals.css`

### To Create:
1. `components/campus-connect/details/doubts-detail.tsx`
2. `components/campus-connect/details/residentials-detail.tsx`
3. `components/campus-connect/details/jobs-detail.tsx`
4. `components/campus-connect/details/teacher-review-detail.tsx`
5. `components/campus-connect/details/subject-tips-detail.tsx`
6. `components/campus-connect/details/events-detail.tsx`
7. `components/campus-connect/details/index.ts`

---

## 9. Risk Assessment

| Risk | Mitigation |
|------|-----------|
| Breaking existing functionality | Test each page individually before moving to next |
| Performance regression | Use dynamic imports for Lottie, optimize images |
| CSS conflicts | Use scoped class names, avoid global overrides |
| Animation jank | Test on low-end devices, use `will-change` sparingly |

---

## Ready for Implementation

This plan is comprehensive and ready for execution. Each section can be implemented independently, allowing for incremental updates and testing.
