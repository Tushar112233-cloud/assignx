# AssignX UI Redesign - Complete Design System

> **Date:** January 2, 2026
> **Status:** Approved
> **Scope:** Core Dashboard (Home, Sidebar, Navigation)
> **Style:** Bold Gen-Z / Notion-inspired

---

## Table of Contents

1. [Design Vision](#1-design-vision)
2. [Color Palette](#2-color-palette)
3. [Typography](#3-typography)
4. [Spacing & Layout](#4-spacing--layout)
5. [Micro-Interactions & Animations](#5-micro-interactions--animations)
6. [Framer Motion System](#6-framer-motion-system)
7. [Sidebar Design](#7-sidebar-design)
8. [Home Dashboard](#8-home-dashboard)
9. [Card System](#9-card-system)
10. [Buttons & Form Inputs](#10-buttons--form-inputs)
11. [Feedback & Celebrations](#11-feedback--celebrations)
12. [Mobile Experience](#12-mobile-experience)
13. [File Structure](#13-file-structure)
14. [Implementation Plan](#14-implementation-plan)

---

## 1. Design Vision

### Problem Statement
- Current UI looks like generic AI-generated app
- Zero micro-interactions or "wow factor"
- Layout, colors, and UX planning are poor
- No personality or brand differentiation

### Design Direction
- **Style:** Bold Gen-Z / Playful (like Notion)
- **Colors:** Warm grays + cream + vibrant accent pops
- **Illustrations:** Animated Lottie/Rive icons + OpenPeeps (https://www.openpeeps.com/)
- **Interactions:** Full micro-interaction system on every touchpoint
- **Priority:** Core Dashboard first (Home, Sidebar, Navigation)

### Approach
**Design System First** - Build complete design system (colors, typography, spacing, animations) then rebuild dashboard for cohesive, reusable foundation.

---

## 2. Color Palette

### Base Colors (Notion-inspired warm neutrals)

| Role | Hex | HSL | Usage |
|------|-----|-----|-------|
| **Background** | `#FFFCF9` | `30 50% 99%` | Main app background |
| **Surface** | `#FFFFFF` | `0 0% 100%` | Cards, modals, elevated elements |
| **Surface Muted** | `#F7F5F2` | `30 15% 96%` | Sidebar, secondary areas |
| **Text Primary** | `#1A1A1A` | `0 0% 10%` | Headlines, important text |
| **Text Secondary** | `#6B6B6B` | `0 0% 42%` | Descriptions, labels |
| **Text Muted** | `#9B9B9B` | `0 0% 61%` | Hints, placeholders |

### Accent Colors (Vibrant pops)

| Accent | Hex | Usage |
|--------|-----|-------|
| **Primary** | `#FF5C35` | CTAs, primary actions, brand moments |
| **Success** | `#00C48C` | Completed states, approvals, positive |
| **Warning** | `#FFB800` | Pending, attention needed |
| **Info** | `#5B8DEF` | In-progress, informational |
| **Accent Purple** | `#9B59B6` | Special highlights, premium |

### CSS Custom Properties

```css
:root {
  --background: 30 50% 99%;
  --surface: 0 0% 100%;
  --surface-muted: 30 15% 96%;
  --foreground: 0 0% 10%;
  --muted: 0 0% 42%;
  --muted-foreground: 0 0% 61%;

  --primary: 14 100% 60%;
  --success: 160 100% 39%;
  --warning: 43 100% 50%;
  --info: 220 80% 65%;
  --accent-purple: 282 39% 53%;
}
```

---

## 3. Typography

### Font Stack

| Role | Font | Weight | Size | Usage |
|------|------|--------|------|-------|
| **Display** | `Cal Sans` / `Plus Jakarta Sans` | 700 | 32-48px | Hero headlines, page titles |
| **Headings** | `Inter` | 600 | 20-28px | Section headers, card titles |
| **Body** | `Inter` | 400-500 | 14-16px | Paragraphs, descriptions |
| **Labels** | `Inter` | 500 | 12-13px | Buttons, tags, metadata |
| **Mono** | `JetBrains Mono` | 400 | 13px | Project IDs, codes, prices |

### Type Scale (1.25 ratio)

```
xs:   12px  - labels, badges
sm:   14px  - body small, captions
base: 16px  - body text
lg:   20px  - card titles
xl:   24px  - section headers
2xl:  32px  - page titles
3xl:  40px  - hero headlines
```

### Principles
- **Line-height:** 1.5-1.6 for readability
- **Letter-spacing:** -0.02em on headlines
- **Font smoothing:** Antialiased
- **Emoji support:** Strategic emoji in headers

---

## 4. Spacing & Layout

### 8px Grid System

| Token | Value | Usage |
|-------|-------|-------|
| `space-1` | 4px | Tight gaps, icon padding |
| `space-2` | 8px | Inline spacing, small gaps |
| `space-3` | 12px | Button padding, list items |
| `space-4` | 16px | Card padding, section gaps |
| `space-6` | 24px | Between components |
| `space-8` | 32px | Section separations |
| `space-12` | 48px | Major page sections |
| `space-16` | 64px | Hero areas |

### Layout Fixes

| Problem | Solution |
|---------|----------|
| Too cramped | Min 24px between cards, 32px between sections |
| No hierarchy | Size + weight + spacing for clear levels |
| Wall of content | Group items, use whitespace |
| Everything equal | Primary actions 2x larger than secondary |

### Container Widths

```
Sidebar:   260px (expanded) → 72px (collapsed)
Content:   max-width 1200px, centered
Cards:     min 280px, responsive grid
Modals:    max 480px (small) / 640px (medium)
```

### Border Radius

```
sm:   6px   - buttons, inputs
md:   12px  - cards, containers
lg:   16px  - modals, large cards
full: 9999px - pills, avatars
```

---

## 5. Micro-Interactions & Animations

### Hover States

| Element | Animation | Duration | Easing |
|---------|-----------|----------|--------|
| **Cards** | Lift (y: -4px) + shadow grow | 200ms | ease-out |
| **Buttons** | Scale 1.02 + bg brighten | 150ms | spring |
| **Links** | Underline slides in | 200ms | ease-out |
| **Icons** | Gentle bounce/rotate | 300ms | spring |
| **Sidebar items** | Bg fade + icon color shift | 150ms | ease |

### Click/Tap Feedback

| Element | Animation |
|---------|-----------|
| **Buttons** | Scale 0.97 → back + ripple |
| **Cards** | Scale 0.99 before navigation |
| **Toggles** | Snap with slight overshoot |
| **Checkboxes** | Bounce-in checkmark |

### Page Transitions

| Transition | Animation |
|------------|-----------|
| **Page enter** | Fade (200ms) + slide up (12px) |
| **Page exit** | Fade out (150ms) |
| **List items** | Stagger in, 50ms delay each |
| **Modals** | Scale 0.95 + fade, backdrop blur |

### Celebrations

| Trigger | Animation |
|---------|-----------|
| **Project submitted** | Confetti + success sound |
| **Payment complete** | Checkmark draws + pulse |
| **Milestone** | OpenPeeps celebration + badge |
| **First-time** | Tooltip spotlight + pulse |

### Loading States

| State | Animation |
|-------|-----------|
| **Skeleton** | Shimmer wave (not static) |
| **Buttons** | Text → spinner morph |
| **Progress** | Animated gradient, number bounces |

---

## 6. Framer Motion System

### Core Tokens

```typescript
// lib/animations/variants.ts

export const easings = {
  smooth: [0.25, 0.1, 0.25, 1],
  bounce: [0.68, -0.55, 0.265, 1.55],
  snappy: [0.175, 0.885, 0.32, 1.1],
};

export const durations = {
  fast: 0.15,
  normal: 0.25,
  slow: 0.4,
  stagger: 0.05,
};
```

### Animation Variants

```typescript
export const fadeIn = {
  hidden: { opacity: 0 },
  visible: { opacity: 1, transition: { duration: 0.25 } }
};

export const slideUp = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.3 } }
};

export const staggerContainer = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: { staggerChildren: 0.08, delayChildren: 0.1 }
  }
};

export const cardHover = {
  rest: { y: 0, boxShadow: "var(--shadow-sm)" },
  hover: {
    y: -4,
    boxShadow: "var(--shadow-lg)",
    transition: { duration: 0.2, ease: "easeOut" }
  }
};

export const buttonTap = {
  tap: { scale: 0.97 },
  hover: { scale: 1.02 }
};

export const modalOverlay = {
  hidden: { opacity: 0 },
  visible: { opacity: 1 }
};

export const modalContent = {
  hidden: { opacity: 0, scale: 0.95, y: 10 },
  visible: {
    opacity: 1,
    scale: 1,
    y: 0,
    transition: { type: "spring", damping: 25, stiffness: 300 }
  }
};
```

### Key Patterns

| Pattern | Usage |
|---------|-------|
| `LayoutGroup` + `layoutId` | Tab indicators, card expansions |
| `AnimatePresence` | Page transitions, modals, toasts |
| `useInView` | Scroll-triggered animations |
| `useDragControls` | Draggable/reorderable items |

---

## 7. Sidebar Design

### Structure (Expanded - 260px)

```
┌─────────────────────────────┐
│  👤 Profile Pill            │
│  ────────────────────────── │
│  🏠 Home                    │
│  📁 My Projects         12  │
│  🛒 Campus Connect          │
│  👤 Profile                 │
│  ────────────────────────── │
│  ⚙️ Settings                │
│  ❓ Help & Support          │
│  ────────────────────────── │
│  💳 Wallet          ₹240.00 │
│                             │
│  ┌─────────────────────────┐│
│  │   OpenPeeps character   ││
│  └─────────────────────────┘│
│                             │
│  [+ New Project]            │
└─────────────────────────────┘
```

### Collapsed State (72px)

```
┌──────┐
│  👤  │
│ ──── │
│  🏠  │
│  📁  │
│  🛒  │
│  👤  │
│ ──── │
│  ⚙️  │
│  ❓  │
│ ──── │
│  💳  │
│      │
│  ➕  │
└──────┘
```

### Interactions

| Element | Animation |
|---------|-----------|
| **Nav items** | Hover: bg fades, icon wiggles |
| **Active item** | Primary left border, `layoutId` indicator |
| **Collapse** | Width animates, labels fade |
| **Profile pill** | Hover: glow, click: dropdown |
| **Badge counts** | Number morphs on change |
| **New Project** | Pulse on first visit |

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `[` or `]` | Toggle collapse |
| `G then H` | Go to Home |
| `G then P` | Go to Projects |

---

## 8. Home Dashboard

### Layout

```
┌────────────────────────────────────────────────────────────────┐
│  Good morning, Om! 👋                        🔔 3    [Wallet]  │
│  Ready to crush it today?                                      │
├────────────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  🎉 HERO BANNER (auto-scroll)             [View Now →]   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                │
│  ── Quick Actions ───────────────────────────────────────────  │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐  │
│  │ 📝 New    │ │ 👓 Proof  │ │ 🤖 AI     │ │ 💡 Ask    │  │
│  │ Project   │ │ read      │ │ Check     │ │ Expert    │  │
│  └────────────┘ └────────────┘ └────────────┘ └────────────┘  │
│                                                                │
│  ── Your Projects ──────────────────────────── [View All →]   │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐  │
│  │ 🟢 For Review   │ │ 🔵 In Progress  │ │ 🟡 Analyzing    │  │
│  │ Marketing Plan  │ │ Data Analysis   │ │ Research Paper  │  │
│  └─────────────────┘ └─────────────────┘ └─────────────────┘  │
│                                                                │
│  ── Campus Pulse 🔥 ──────────────────────────  [Explore →]   │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ (scroll)        │
│  │ 📚 Book│ │ 🏠 Room│ │ 💼 Job │ │ 📚 Note│                 │
│  └────────┘ └────────┘ └────────┘ └────────┘                  │
└────────────────────────────────────────────────────────────────┘
```

### Components

| Section | Features |
|---------|----------|
| **Greeting** | Time-based + emoji, motivational subtitle |
| **Notifications** | Animated wiggle, badge pulse |
| **Wallet** | Balance, green glow on credit |
| **Quick Actions** | Lottie icons, hover bounce |
| **Project Cards** | Status colors, progress bars |
| **Campus Pulse** | Horizontal scroll, price tags |

---

## 9. Card System

### Variants

| Variant | Usage | Treatment |
|---------|-------|-----------|
| **Default** | General | White bg, subtle border |
| **Elevated** | Important | Soft shadow, no border |
| **Interactive** | Clickable | Hover lift, pointer |
| **Highlighted** | Attention | Colored left border |
| **Glass** | Overlays | Blur backdrop, transparent |

### Project Card States

| State | Color | Treatment |
|-------|-------|-----------|
| **For Review** | Green | Pulsing "Action needed" dot |
| **In Progress** | Blue | Animated progress bar |
| **Analyzing** | Yellow | Shimmer loading |
| **Payment Pending** | Orange | Price badge prominent |

### Micro-interactions

| Interaction | Animation |
|-------------|-----------|
| **Hover** | y: -4, shadow expands |
| **Press** | scale: 0.98, snap back |
| **Status change** | Border color morphs |
| **Progress update** | Bar animates, number counts |
| **Deadline urgent** | Red tint, subtle shake |

### Empty States

| Page | OpenPeeps Scene | Message |
|------|-----------------|---------|
| **No projects** | Relaxing in hammock | "No projects yet!" |
| **No notifications** | Meditating | "All caught up!" |
| **Search empty** | Binoculars | "Nothing here..." |
| **Error** | Scratching head | "Oops! Something went wrong." |

---

## 10. Buttons & Form Inputs

### Button Variants

| Variant | Appearance | Usage |
|---------|------------|-------|
| **Primary** | `#FF5C35` bg, white text | Main CTAs |
| **Secondary** | Transparent, border | Cancel, back |
| **Ghost** | Text only | Tertiary actions |
| **Danger** | `#E53935` bg | Delete |
| **Success** | `#00C48C` bg | Confirm |

### Button Sizes

```
xs:  h-7  px-2.5  text-xs
sm:  h-8  px-3    text-sm
md:  h-10 px-4    text-sm  (default)
lg:  h-12 px-6    text-base
xl:  h-14 px-8    text-lg
```

### Button Animations

| State | Animation |
|-------|-----------|
| **Hover** | Scale 1.02, shadow |
| **Press** | Scale 0.97 |
| **Loading** | Text → spinner morph |
| **Success** | Spinner → checkmark |

### Input States

| State | Treatment |
|-------|-----------|
| **Default** | Subtle border, placeholder |
| **Focused** | Primary border, label floats up |
| **Error** | Red border, shake, error text |
| **Success** | Checkmark fades in |

### Other Inputs

- **Select:** Search, highlighted option
- **Checkbox:** Bounce-in checkmark
- **Radio:** Dot scales with spring
- **Toggle:** Slides with spring, bg transitions

---

## 11. Feedback & Celebrations

### Toast Types

| Type | Icon | Animation |
|------|------|-----------|
| **Success** | ✅ | Slide in + overshoot |
| **Error** | ❌ | Shake on entry |
| **Info** | 💡 | Gentle fade |
| **Action** | 📄 | With undo button |

### Celebration Moments

| Trigger | Animation |
|---------|-----------|
| **Project submitted** | Confetti + success modal |
| **Payment complete** | Money particles + checkmark |
| **First project** | OpenPeeps cheering + badge |
| **Milestones (5/10/25)** | Full confetti + achievement |

### Loading States

| Context | Animation |
|---------|-----------|
| **Page** | Skeleton shimmer wave |
| **Button** | Text → spinner |
| **Card** | Pulsing placeholders |
| **Image** | Blur-up effect |

---

## 12. Mobile Experience

### Breakpoints

| Name | Width | Changes |
|------|-------|---------|
| `mobile` | < 640px | Single column, bottom nav |
| `tablet` | 640-1024px | 2 columns, collapsible sidebar |
| `desktop` | > 1024px | Full sidebar, 3-4 columns |

### Bottom Navigation

```
┌─────────────────────────────────────────────┐
│   🏠      📁       ➕       🛒      👤     │
│  Home  Projects   New   Connect  Profile    │
└─────────────────────────────────────────────┘
```

### Mobile FAB

- **Collapsed:** + icon with subtle float
- **Expanded:** Menu fans out with stagger
- **Close:** × rotates back to +

### Touch Gestures

| Gesture | Action |
|---------|--------|
| **Swipe left** | Reveal delete |
| **Swipe right** | Quick action |
| **Pull down** | Refresh with bounce |
| **Long press** | Context menu |

### Mobile Enhancements

| Element | Enhancement |
|---------|-------------|
| **Buttons** | Min 44px tap targets |
| **Inputs** | 16px min (prevent zoom) |
| **Modals** | Slide up as sheets |
| **Toasts** | Top of screen |

---

## 13. File Structure

```
components/
├── ui/                       # Base primitives
│   ├── button.tsx
│   ├── card.tsx
│   ├── input.tsx
│   ├── select.tsx
│   ├── checkbox.tsx
│   ├── toggle.tsx
│   ├── skeleton.tsx
│   ├── toast.tsx
│   ├── modal.tsx
│   └── progress.tsx
│
├── animations/               # Framer Motion
│   ├── variants.ts
│   ├── page-transition.tsx
│   ├── stagger-container.tsx
│   ├── fade-in.tsx
│   └── confetti.tsx
│
├── illustrations/            # Assets
│   ├── lottie/
│   │   ├── loading.json
│   │   ├── success.json
│   │   └── icons/*.json
│   └── openpeeps/
│       ├── celebrating.svg
│       ├── relaxing.svg
│       └── *.svg
│
├── layout/                   # Layout
│   ├── sidebar/
│   ├── mobile-nav.tsx
│   ├── mobile-drawer.tsx
│   ├── mobile-fab.tsx
│   └── page-header.tsx
│
├── dashboard/                # Dashboard
│   ├── greeting-header.tsx
│   ├── banner-carousel.tsx
│   ├── quick-actions.tsx
│   ├── project-card.tsx
│   ├── campus-pulse.tsx
│   └── wallet-pill.tsx
│
├── feedback/                 # Feedback
│   ├── toast-provider.tsx
│   ├── celebration-modal.tsx
│   ├── empty-state.tsx
│   └── loading-state.tsx
│
└── forms/                    # Forms
    ├── form-field.tsx
    ├── file-upload.tsx
    └── step-indicator.tsx

styles/
├── globals.css
└── tokens/
    ├── colors.css
    ├── typography.css
    ├── spacing.css
    └── shadows.css
```

---

## 14. Implementation Plan

### Phase 1: Foundation (Day 1-2)
- [ ] Set up CSS tokens
- [ ] Install lottie-react, download OpenPeeps
- [ ] Create animation variants
- [ ] Extend shadcn button component

### Phase 2: Core Components (Day 3-5)
- [ ] Animated Card system
- [ ] Form inputs with floating labels
- [ ] Toast system
- [ ] Loading/Empty states

### Phase 3: Layout (Day 6-8)
- [ ] Sidebar redesign
- [ ] Mobile bottom nav
- [ ] Mobile drawer
- [ ] Page transitions

### Phase 4: Dashboard Pages (Day 9-12)
- [ ] Greeting header
- [ ] Quick actions grid
- [ ] Project cards
- [ ] Banner carousel
- [ ] Campus pulse
- [ ] Home page assembly

### Phase 5: Polish (Day 13-14)
- [ ] Confetti system
- [ ] Success modals
- [ ] Micro-interaction audit
- [ ] Mobile testing

---

## Success Metrics

| Metric | Target |
|--------|--------|
| **Interaction coverage** | 100% animated |
| **Page load feel** | Staggered animations |
| **Empty states** | OpenPeeps on every empty |
| **Mobile gestures** | Swipe, pull, FAB working |
| **User feedback** | "Feels like a real app" |

---

*Design approved: January 2, 2026*
*Ready for implementation*
