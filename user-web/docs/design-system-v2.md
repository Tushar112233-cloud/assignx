# AssignX Design System v2.0
## Production-Ready UI/UX Specification

**Document Version:** 2.0
**Last Updated:** January 2026
**Status:** Implementation Ready

---

## Table of Contents

1. [Design Philosophy](#1-design-philosophy)
2. [Unified Page Layout System](#2-unified-page-layout-system)
3. [Skeleton System Architecture](#3-skeleton-system-architecture)
4. [Page-Specific Implementations](#4-page-specific-implementations)
5. [Micro-Interactions Specification](#5-micro-interactions-specification)
6. [Color System Refinements](#6-color-system-refinements)
7. [Typography Scale](#7-typography-scale)
8. [Spacing & Grid System](#8-spacing--grid-system)
9. [Animation Choreography](#9-animation-choreography)
10. [Component Specifications](#10-component-specifications)
11. [Accessibility Standards](#11-accessibility-standards)
12. [Implementation Checklist](#12-implementation-checklist)

---

## 1. Design Philosophy

### Core Principles

**1.1 Perceived Performance**
> Users should never see a blank screen. Every transition should feel intentional and premium.

- Skeletons appear instantly on navigation
- Minimum 1000ms skeleton display (prevents flash of content)
- Content reveals with choreographed stagger animations
- Optimistic UI updates where possible

**1.2 Visual Consistency**
> The four core pages (Dashboard, Marketplace, Projects, Wallet) should feel like siblings - recognizably part of the same family while serving distinct purposes.

- Shared layout structure with page-specific content zones
- Consistent card styling and interaction patterns
- Unified header treatment across all pages
- Harmonious color application

**1.3 Delightful Details**
> Micro-interactions should feel natural, not showy. Every animation serves a purpose.

- Feedback on every interaction
- Smooth state transitions
- Subtle hover revelations
- Celebration moments for achievements

**1.4 Accessibility First**
> Beautiful design that everyone can use.

- WCAG 2.1 AA compliance minimum
- Keyboard navigation support
- Screen reader optimization
- Reduced motion preferences respected

---

## 2. Unified Page Layout System

### 2.1 Master Layout Structure

All four core pages share an identical layout skeleton:

```
┌─────────────────────────────────────────────────────────────────┐
│                        HEADER (Fixed)                           │
│  [Logo] [Page Title]                    [Wallet Pill] [Bell]   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                   HERO SECTION                           │   │
│  │           (Page-specific welcome/banner)                 │   │
│  │                Height: 120-180px                         │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                  QUICK ACTIONS BAR                       │   │
│  │        [Filter Pills] or [Action Buttons]                │   │
│  │                Height: 48-56px                           │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                   STATS ROW                              │   │
│  │    ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐         │   │
│  │    │ Stat 1 │ │ Stat 2 │ │ Stat 3 │ │ Stat 4 │         │   │
│  │    └────────┘ └────────┘ └────────┘ └────────┘         │   │
│  │              4-column grid, 2 on mobile                  │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                 PRIMARY CONTENT AREA                     │   │
│  │                                                          │   │
│  │    Grid/List/Masonry based on page type                 │   │
│  │    Minimum height: 400px                                │   │
│  │    Flexible growth                                       │   │
│  │                                                          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │               SECONDARY CONTENT AREA                     │   │
│  │         (Activity feed, transactions, etc.)              │   │
│  │                 Optional per page                        │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│                      (Bottom padding: 100px)                    │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                      DOCK NAVIGATION (Fixed)                    │
│         [Home] [Projects] [Connect] [Wallet] | [Settings] [Profile]
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Layout Zones Specification

| Zone | Height | Behavior | Content Type |
|------|--------|----------|--------------|
| Header | 56px | Fixed top | Logo, title, actions |
| Hero Section | 120-180px | Static | Welcome message, banner |
| Quick Actions | 48-56px | Sticky optional | Filters, CTAs |
| Stats Row | 80-100px | Static | 4 metric cards |
| Primary Content | min 400px | Flexible | Main page content |
| Secondary Content | Variable | Optional | Supporting info |
| Bottom Padding | 100px | Fixed | Dock clearance |

### 2.3 Responsive Breakpoints

```css
/* Mobile First Approach */
--breakpoint-sm: 640px;   /* Small tablets */
--breakpoint-md: 768px;   /* Tablets */
--breakpoint-lg: 1024px;  /* Laptops */
--breakpoint-xl: 1280px;  /* Desktops */
--breakpoint-2xl: 1536px; /* Large screens */
```

**Layout Adaptations:**

| Breakpoint | Stats Grid | Content Grid | Hero Height |
|------------|------------|--------------|-------------|
| < 640px | 2 columns | 1 column | 100px |
| 640-768px | 2 columns | 2 columns | 120px |
| 768-1024px | 4 columns | 2-3 columns | 140px |
| > 1024px | 4 columns | 3-4 columns | 160px |

---

## 3. Skeleton System Architecture

### 3.1 Core Principles

**Minimum Display Duration:** 1000ms (1 second)
> Even if data loads in 200ms, skeleton displays for full second to prevent jarring flash.

**Animation Style:** Shimmer (primary), Pulse (secondary)
> Shimmer for large areas (cards, images), pulse for text and small elements.

**Stagger Reveal:** 50ms between elements
> Content appears in choreographed sequence, not all at once.

### 3.2 Skeleton Provider Architecture

```typescript
interface SkeletonConfig {
  minimumDuration: number;      // Default: 1000ms
  staggerDelay: number;         // Default: 50ms
  fadeOutDuration: number;      // Default: 300ms
  animationStyle: 'shimmer' | 'pulse' | 'wave';
}

interface PageSkeletonProps {
  isLoading: boolean;
  children: React.ReactNode;
  skeleton: React.ReactNode;
  config?: Partial<SkeletonConfig>;
}
```

### 3.3 Skeleton Component Hierarchy

```
PageSkeletonProvider
├── useMinimumLoadingTime(isLoading, minMs)
├── AnimatePresence (mode="wait")
│   ├── Skeleton State
│   │   └── Page-specific skeleton component
│   └── Content State
│       └── Staggered reveal wrapper
│           └── Actual page content
```

### 3.4 Base Skeleton Primitives

```typescript
// Primitive shapes with consistent styling
<SkeletonBox />      // Rectangular block
<SkeletonCircle />   // Avatar/icon placeholder
<SkeletonText />     // Text line with natural width variance
<SkeletonButton />   // Button-shaped placeholder
<SkeletonBadge />    // Small pill-shaped placeholder
<SkeletonImage />    // Image with aspect ratio
<SkeletonCard />     // Full card structure
<SkeletonStat />     // Stat widget structure
```

### 3.5 Shimmer Animation Specification

```css
.skeleton-shimmer {
  background: linear-gradient(
    90deg,
    hsl(var(--muted)) 0%,
    hsl(var(--muted) / 0.5) 50%,
    hsl(var(--muted)) 100%
  );
  background-size: 200% 100%;
  animation: shimmer 1.5s ease-in-out infinite;
}

@keyframes shimmer {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}
```

---

## 4. Page-Specific Implementations

### 4.1 Dashboard Page (`/home`)

**Purpose:** Overview of user's activity, quick access to key features

**Hero Section:**
```
┌─────────────────────────────────────────────────────────────┐
│  👋 Welcome back, {firstName}!                              │
│  Here's what's happening with your projects today.          │
│                                                             │
│  [Quick Stats Badge: X active projects]                     │
└─────────────────────────────────────────────────────────────┘
Background: Subtle mesh gradient (primary tint)
Height: 140px
```

**Stats Row:**
| Stat | Icon | Label | Value Example |
|------|------|-------|---------------|
| 1 | FolderKanban | Active Projects | 5 |
| 2 | Clock | Pending Tasks | 12 |
| 3 | TrendingUp | Completion Rate | 78% |
| 4 | Wallet | Wallet Balance | ₹2,450 |

**Primary Content:**
```
┌──────────────────────────────────────────────────────────────┐
│  Recent Projects                            [View All →]     │
├──────────────────────────────────────────────────────────────┤
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐            │
│  │ Project 1   │ │ Project 2   │ │ Project 3   │            │
│  │ ─────────── │ │ ─────────── │ │ ─────────── │            │
│  │ [Progress]  │ │ [Progress]  │ │ [Progress]  │            │
│  │ Status: ●   │ │ Status: ●   │ │ Status: ●   │            │
│  └─────────────┘ └─────────────┘ └─────────────┘            │
└──────────────────────────────────────────────────────────────┘
Grid: 3 columns (lg), 2 columns (md), 1 column (sm)
Card style: Elevated with hover lift
```

**Secondary Content:**
```
┌──────────────────────────────────────────────────────────────┐
│  Recent Activity                                             │
├──────────────────────────────────────────────────────────────┤
│  (○) Project "Web App" moved to In Progress     2h ago      │
│  (○) Payment received for "Logo Design"         5h ago      │
│  (○) New message from @johndoe                  1d ago      │
└──────────────────────────────────────────────────────────────┘
List style: Compact with avatars
Max items: 5 (with "View All" link)
```

**Dashboard Skeleton:**
```typescript
<DashboardSkeleton>
  {/* Hero - Pulse animation */}
  <div className="h-[140px] rounded-2xl skeleton-pulse" />

  {/* Stats - Staggered shimmer */}
  <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
    {[1,2,3,4].map((i) => (
      <SkeletonStat key={i} delay={i * 50} />
    ))}
  </div>

  {/* Projects Section Header */}
  <div className="flex justify-between">
    <SkeletonText width="150px" />
    <SkeletonText width="80px" />
  </div>

  {/* Project Cards - Staggered */}
  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
    {[1,2,3].map((i) => (
      <SkeletonProjectCard key={i} delay={200 + i * 50} />
    ))}
  </div>

  {/* Activity Section */}
  <SkeletonText width="120px" />
  <div className="space-y-3">
    {[1,2,3,4,5].map((i) => (
      <SkeletonActivityItem key={i} delay={400 + i * 50} />
    ))}
  </div>
</DashboardSkeleton>
```

---

### 4.2 Projects Page (`/projects`)

**Purpose:** View and manage all user projects

**Hero Section:**
```
┌─────────────────────────────────────────────────────────────┐
│  📁 My Projects                                             │
│  Manage and track all your assignments in one place.        │
│                                                   [+ New]   │
└─────────────────────────────────────────────────────────────┘
Background: Subtle gradient (muted)
Height: 120px
CTA: Primary button for new project
```

**Quick Actions Bar:**
```
┌─────────────────────────────────────────────────────────────┐
│  [All] [Active ●] [Completed ✓] [Pending ○]    🔍 Search   │
└─────────────────────────────────────────────────────────────┘
Pills: Toggleable filter chips
Search: Expandable search input
```

**Stats Row:**
| Stat | Icon | Label | Value Example |
|------|------|-------|---------------|
| 1 | FolderOpen | Total Projects | 12 |
| 2 | Clock | In Progress | 5 |
| 3 | CheckCircle | Completed | 6 |
| 4 | AlertCircle | Needs Attention | 1 |

**Primary Content:**
```
┌──────────────────────────────────────────────────────────────┐
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ [Status Badge]                              [Menu ⋮]    │ │
│  │                                                         │ │
│  │  Project Title Here                                     │ │
│  │  Brief description of the project...                    │ │
│  │                                                         │ │
│  │  ▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░  45%                            │ │
│  │                                                         │ │
│  │  (○) Assigned to        Due: Jan 25, 2026              │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                              │
│  [Repeat for each project...]                               │
└──────────────────────────────────────────────────────────────┘
Layout: List view (default) or Grid view (toggle)
Card style: Full-width cards with all details
```

**Projects Skeleton:**
```typescript
<ProjectsSkeleton>
  {/* Hero */}
  <div className="h-[120px] rounded-2xl skeleton-pulse" />

  {/* Filter Pills */}
  <div className="flex gap-2">
    {[1,2,3,4].map((i) => (
      <SkeletonBadge key={i} width="80px" delay={i * 30} />
    ))}
    <div className="flex-1" />
    <SkeletonBox width="200px" height="40px" />
  </div>

  {/* Stats */}
  <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
    {[1,2,3,4].map((i) => (
      <SkeletonStat key={i} delay={100 + i * 50} />
    ))}
  </div>

  {/* Project Cards */}
  <div className="space-y-4">
    {[1,2,3,4].map((i) => (
      <SkeletonProjectCardFull key={i} delay={250 + i * 75} />
    ))}
  </div>
</ProjectsSkeleton>
```

---

### 4.3 Marketplace/Connect Page (`/connect`)

**Purpose:** Browse and discover campus marketplace listings

**Hero Section:**
```
┌─────────────────────────────────────────────────────────────┐
│                    🛍️ Campus Connect                        │
│         Discover products, services & opportunities         │
│                    from your campus community               │
│                                                             │
│                      [Post Listing]                         │
└─────────────────────────────────────────────────────────────┘
Background: Vibrant mesh gradient
Height: 160px
CTA: Prominent create button
```

**Quick Actions Bar:**
```
┌─────────────────────────────────────────────────────────────┐
│  [All] [Products 📦] [Housing 🏠] [Services 💼] [Community]│
└─────────────────────────────────────────────────────────────┘
Pills: Category filter chips with icons
Scrollable on mobile
```

**Stats Row:**
| Stat | Icon | Label | Value Example |
|------|------|-------|---------------|
| 1 | Package | Listed Items | 156 |
| 2 | TrendingUp | New Today | 12 |
| 3 | Heart | Your Favorites | 8 |
| 4 | Eye | Your Views | 234 |

**Primary Content:**
```
┌──────────────────────────────────────────────────────────────┐
│  Pinterest-Style Masonry Grid                                │
│                                                              │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐               │
│  │  IMG   │ │  IMG   │ │        │ │  IMG   │               │
│  │        │ │        │ │  IMG   │ │        │               │
│  │────────│ │────────│ │        │ │────────│               │
│  │ Title  │ │ Title  │ │────────│ │ Title  │               │
│  │ ₹Price │ │ ₹Price │ │ Title  │ │ ₹Price │               │
│  │ 📍 Loc │ └────────┘ │ ₹Price │ │ 📍 Loc │               │
│  └────────┘            └────────┘ └────────┘               │
│                                                              │
│  Columns: 4 (xl), 3 (lg), 2 (md), 2 (sm)                   │
│  Gap: 16px                                                   │
│  Infinite scroll with loading indicator                      │
└──────────────────────────────────────────────────────────────┘
```

**Marketplace Skeleton:**
```typescript
<MarketplaceSkeleton>
  {/* Hero */}
  <div className="h-[160px] rounded-2xl skeleton-shimmer" />

  {/* Category Pills */}
  <div className="flex gap-2 overflow-x-auto">
    {[1,2,3,4,5].map((i) => (
      <SkeletonBadge key={i} width="100px" delay={i * 30} />
    ))}
  </div>

  {/* Stats */}
  <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
    {[1,2,3,4].map((i) => (
      <SkeletonStat key={i} delay={100 + i * 50} />
    ))}
  </div>

  {/* Masonry Grid */}
  <div className="columns-2 md:columns-3 lg:columns-4 gap-4">
    {[1,2,3,4,5,6,7,8].map((i) => (
      <SkeletonMarketplaceCard
        key={i}
        height={getRandomHeight()} // 200-350px
        delay={200 + i * 50}
      />
    ))}
  </div>
</MarketplaceSkeleton>
```

---

### 4.4 Wallet Page (`/wallet`)

**Purpose:** Manage finances, view transactions, add funds

**Hero Section:**
```
┌─────────────────────────────────────────────────────────────┐
│                    💳 Your Wallet                           │
│                                                             │
│              ┌─────────────────────────┐                   │
│              │    ASSIGNX WALLET       │                   │
│              │                         │                   │
│              │    **** **** **** 4242  │                   │
│              │                         │                   │
│              │    ₹2,450.00           │                   │
│              │    Available Balance    │                   │
│              └─────────────────────────┘                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
Background: Curved dome gradient
Card: 3D credit card visualization
Height: 220px (includes card)
```

**Quick Actions Bar:**
```
┌─────────────────────────────────────────────────────────────┐
│      [➕ Add Money]    [📤 Send]    [📥 Withdraw]          │
└─────────────────────────────────────────────────────────────┘
Buttons: Icon + text, equal width
Style: Outline with hover fill
```

**Stats Row:**
| Stat | Icon | Label | Value Example |
|------|------|-------|---------------|
| 1 | Wallet | Total Balance | ₹2,450 |
| 2 | Clock | Pending | ₹500 |
| 3 | TrendingUp | Earned (Month) | ₹3,200 |
| 4 | TrendingDown | Spent (Month) | ₹1,850 |

**Primary Content:**
```
┌──────────────────────────────────────────────────────────────┐
│  Transaction History                         [Filter ▾]     │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Today                                                       │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ (○) Project Payment         +₹1,500    ● Completed    │ │
│  │     Web Development Project            2:30 PM        │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  Yesterday                                                   │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ (○) Withdrawal              -₹2,000    ● Completed    │ │
│  │     To Bank Account ****1234           11:45 AM       │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  [Load More]                                                │
└──────────────────────────────────────────────────────────────┘
```

**Wallet Skeleton:**
```typescript
<WalletSkeleton>
  {/* Hero with Card */}
  <div className="relative h-[220px]">
    <div className="absolute inset-0 rounded-2xl skeleton-pulse" />
    <div className="absolute inset-x-0 bottom-4 mx-auto w-[280px] h-[160px]">
      <SkeletonCard className="h-full rounded-xl skeleton-shimmer" />
    </div>
  </div>

  {/* Action Buttons */}
  <div className="grid grid-cols-3 gap-4">
    {[1,2,3].map((i) => (
      <SkeletonButton key={i} delay={i * 50} />
    ))}
  </div>

  {/* Stats */}
  <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
    {[1,2,3,4].map((i) => (
      <SkeletonStat key={i} delay={150 + i * 50} />
    ))}
  </div>

  {/* Transaction Header */}
  <div className="flex justify-between">
    <SkeletonText width="160px" />
    <SkeletonBadge width="80px" />
  </div>

  {/* Transactions */}
  <div className="space-y-4">
    <SkeletonText width="60px" /> {/* Date header */}
    {[1,2,3,4,5].map((i) => (
      <SkeletonTransactionItem key={i} delay={300 + i * 60} />
    ))}
  </div>
</WalletSkeleton>
```

---

## 5. Micro-Interactions Specification

### 5.1 Button Interactions

```typescript
const buttonInteractions = {
  // Hover state
  hover: {
    scale: 1.02,
    y: -1,
    transition: { duration: 0.2, ease: "easeOut" }
  },

  // Active/pressed state
  tap: {
    scale: 0.98,
    transition: { duration: 0.1, ease: "easeIn" }
  },

  // Loading state
  loading: {
    opacity: 0.8,
    cursor: "wait"
  },

  // Success feedback
  success: {
    scale: [1, 1.05, 1],
    backgroundColor: "var(--success)",
    transition: { duration: 0.4 }
  }
}
```

**Button Icon Animations:**
- Arrow icons: Translate X on hover (+4px)
- Plus icons: Rotate 90° on hover
- Check icons: Path draw animation on success

### 5.2 Card Interactions

```typescript
const cardInteractions = {
  // Idle state
  idle: {
    y: 0,
    boxShadow: "var(--shadow-sm)",
    borderColor: "var(--border)"
  },

  // Hover state
  hover: {
    y: -4,
    boxShadow: "var(--shadow-lg)",
    borderColor: "var(--border-hover)",
    transition: {
      duration: 0.25,
      ease: [0.25, 0.46, 0.45, 0.94]
    }
  },

  // Pressed state
  tap: {
    y: -2,
    scale: 0.995,
    transition: { duration: 0.1 }
  }
}
```

**Card Content Reveals:**
- Favorite button: Fade in on card hover
- Quick actions: Slide up from bottom on hover
- Image zoom: Subtle 1.05 scale on hover

### 5.3 Navigation Interactions

**Dock Icons:**
```typescript
const dockIconInteractions = {
  hover: {
    scale: 1.1,
    y: -2,
    transition: { type: "spring", stiffness: 400, damping: 25 }
  },

  tap: {
    scale: 0.95,
    transition: { duration: 0.1 }
  },

  active: {
    // Background fills with primary color
    backgroundColor: "var(--primary)",
    color: "var(--primary-foreground)",
    transition: { duration: 0.25 }
  }
}
```

**Page Transitions:**
```typescript
const pageTransition = {
  initial: {
    opacity: 0,
    y: 12,
    scale: 0.985
  },
  animate: {
    opacity: 1,
    y: 0,
    scale: 1,
    transition: {
      duration: 0.35,
      ease: [0.25, 0.46, 0.45, 0.94]
    }
  },
  exit: {
    opacity: 0,
    y: -8,
    scale: 0.99,
    transition: {
      duration: 0.2,
      ease: [0.55, 0, 1, 0.45]
    }
  }
}
```

### 5.4 Form Interactions

**Input Focus:**
```css
.input-field {
  transition: all 0.2s ease;
  border-color: var(--border);
}

.input-field:focus {
  border-color: var(--primary);
  box-shadow: 0 0 0 3px var(--primary / 0.1);
  outline: none;
}
```

**Validation States:**
```typescript
const validationAnimations = {
  error: {
    x: [0, -8, 8, -8, 8, 0], // Shake
    transition: { duration: 0.4 }
  },

  success: {
    scale: [1, 1.02, 1],
    borderColor: "var(--success)",
    transition: { duration: 0.3 }
  }
}
```

### 5.5 Skeleton to Content Transition

```typescript
const skeletonToContent = {
  skeleton: {
    opacity: 1,
    filter: "blur(0px)"
  },

  fadeOut: {
    opacity: 0,
    filter: "blur(4px)",
    transition: { duration: 0.3, ease: "easeIn" }
  },

  contentFadeIn: {
    opacity: [0, 1],
    y: [8, 0],
    transition: {
      duration: 0.4,
      ease: "easeOut",
      staggerChildren: 0.05
    }
  }
}
```

---

## 6. Color System Refinements

### 6.1 Primary Palette (Coffee Bean)

```css
/* Light Mode */
--primary: oklch(0.44 0.06 35);           /* Coffee Bean #765341 */
--primary-hover: oklch(0.48 0.065 35);    /* 10% lighter */
--primary-active: oklch(0.40 0.055 35);   /* 10% darker */
--primary-foreground: oklch(0.98 0.002 60); /* White */

/* Dark Mode */
--primary: oklch(0.57 0.055 40);          /* Coffee Light #A07A65 */
--primary-hover: oklch(0.62 0.06 40);     /* Lighter */
--primary-active: oklch(0.52 0.05 40);    /* Darker */
--primary-foreground: oklch(0.12 0.008 30); /* Pitch Black */
```

### 6.2 Semantic Colors

```css
/* Success - Sage Green */
--success: oklch(0.65 0.15 145);
--success-foreground: oklch(0.98 0.005 145);
--success-muted: oklch(0.92 0.03 145);

/* Warning - Warm Amber */
--warning: oklch(0.75 0.15 65);
--warning-foreground: oklch(0.25 0.05 65);
--warning-muted: oklch(0.92 0.04 65);

/* Error - Warm Red */
--error: oklch(0.55 0.2 25);
--error-foreground: oklch(0.98 0.01 25);
--error-muted: oklch(0.92 0.04 25);

/* Info - Calm Blue */
--info: oklch(0.60 0.12 240);
--info-foreground: oklch(0.98 0.005 240);
--info-muted: oklch(0.92 0.03 240);
```

### 6.3 Surface Colors

```css
/* Light Mode Surfaces */
--surface-0: oklch(1 0 0);                /* Pure white - cards */
--surface-1: oklch(0.985 0.002 60);       /* Warm white - page bg */
--surface-2: oklch(0.96 0.004 60);        /* Light gray - hover */
--surface-3: oklch(0.93 0.006 60);        /* Gray - muted areas */

/* Dark Mode Surfaces */
--surface-0: oklch(0.18 0.01 35);         /* Card background */
--surface-1: oklch(0.12 0.008 30);        /* Page background */
--surface-2: oklch(0.22 0.012 35);        /* Hover state */
--surface-3: oklch(0.28 0.015 35);        /* Elevated */
```

### 6.4 Text Colors

```css
/* Light Mode */
--text-primary: oklch(0.145 0.01 30);     /* Headings */
--text-secondary: oklch(0.35 0.015 30);   /* Body text */
--text-muted: oklch(0.55 0.01 30);        /* Captions */
--text-disabled: oklch(0.70 0.005 30);    /* Disabled */

/* Dark Mode */
--text-primary: oklch(0.94 0.005 60);     /* Headings */
--text-secondary: oklch(0.78 0.008 60);   /* Body text */
--text-muted: oklch(0.58 0.01 60);        /* Captions */
--text-disabled: oklch(0.45 0.008 60);    /* Disabled */
```

### 6.5 Border Colors

```css
/* Light Mode */
--border: oklch(0.90 0.005 60);           /* Default border */
--border-hover: oklch(0.80 0.01 60);      /* Hover state */
--border-focus: var(--primary);            /* Focus state */

/* Dark Mode */
--border: oklch(0.28 0.01 35);            /* Default border */
--border-hover: oklch(0.38 0.015 35);     /* Hover state */
--border-focus: var(--primary);            /* Focus state */
```

---

## 7. Typography Scale

### 7.1 Font Stack

```css
--font-sans: "Inter", ui-sans-serif, system-ui, -apple-system, sans-serif;
--font-mono: "JetBrains Mono", ui-monospace, SFMono-Regular, monospace;
```

### 7.2 Type Scale

| Name | Size | Weight | Line Height | Letter Spacing | Use Case |
|------|------|--------|-------------|----------------|----------|
| display | 48px | 700 | 1.1 | -0.02em | Hero headlines |
| h1 | 36px | 700 | 1.2 | -0.015em | Page titles |
| h2 | 28px | 600 | 1.25 | -0.01em | Section headers |
| h3 | 22px | 600 | 1.3 | -0.005em | Card titles |
| h4 | 18px | 600 | 1.35 | 0 | Subsections |
| body-lg | 16px | 400 | 1.5 | 0 | Prominent body |
| body | 14px | 400 | 1.5 | 0 | Default body |
| body-sm | 13px | 400 | 1.5 | 0.005em | Secondary text |
| caption | 12px | 400 | 1.4 | 0.01em | Labels, hints |
| overline | 11px | 600 | 1.3 | 0.05em | Eyebrows, tags |

### 7.3 Responsive Typography

```css
/* Mobile-first, scales up */
.display {
  font-size: clamp(32px, 5vw, 48px);
}

.h1 {
  font-size: clamp(28px, 4vw, 36px);
}

.h2 {
  font-size: clamp(22px, 3vw, 28px);
}
```

---

## 8. Spacing & Grid System

### 8.1 Spacing Scale (4px base)

| Token | Value | Use Case |
|-------|-------|----------|
| space-0 | 0 | Reset |
| space-1 | 4px | Tight inline |
| space-2 | 8px | Compact gaps |
| space-3 | 12px | Default inline |
| space-4 | 16px | Default block |
| space-5 | 20px | Medium block |
| space-6 | 24px | Section gaps |
| space-8 | 32px | Large gaps |
| space-10 | 40px | Extra large |
| space-12 | 48px | Section breaks |
| space-16 | 64px | Major sections |
| space-20 | 80px | Hero spacing |
| space-24 | 96px | Page margins |

### 8.2 Container Widths

```css
--container-sm: 640px;    /* Narrow content */
--container-md: 768px;    /* Default content */
--container-lg: 1024px;   /* Wide content */
--container-xl: 1280px;   /* Full width */
--container-2xl: 1536px;  /* Max width */
```

### 8.3 Grid System

```css
/* Base grid */
.grid-page {
  display: grid;
  grid-template-columns: repeat(12, 1fr);
  gap: var(--space-4);
}

/* Common patterns */
.grid-stats { grid-template-columns: repeat(4, 1fr); }
.grid-cards { grid-template-columns: repeat(3, 1fr); }
.grid-2col { grid-template-columns: repeat(2, 1fr); }

/* Responsive */
@media (max-width: 768px) {
  .grid-stats { grid-template-columns: repeat(2, 1fr); }
  .grid-cards { grid-template-columns: repeat(1, 1fr); }
}
```

---

## 9. Animation Choreography

### 9.1 Page Load Sequence

```
Timeline (1000ms total):

0ms     - Skeleton appears (instant)
0-1000ms - Skeleton shimmer animation
1000ms  - Data ready (but wait for minimum)
1000ms  - Begin exit animation
1000-1300ms - Skeleton fades out
1300ms  - Content begins reveal
1300-1350ms - Header fades in
1350-1400ms - Stats row staggers in
1400-1500ms - Primary content staggers in
1500-1600ms - Secondary content fades in
1600ms  - Page fully loaded
```

### 9.2 Stagger Configuration

```typescript
const staggerConfig = {
  container: {
    staggerChildren: 0.05,  // 50ms between children
    delayChildren: 0.1,     // 100ms before first child
  },

  item: {
    initial: { opacity: 0, y: 12 },
    animate: {
      opacity: 1,
      y: 0,
      transition: { duration: 0.3, ease: "easeOut" }
    }
  }
}
```

### 9.3 Easing Functions

```typescript
const easings = {
  // Standard easings
  easeOut: [0, 0, 0.2, 1],           // Deceleration
  easeIn: [0.4, 0, 1, 1],            // Acceleration
  easeInOut: [0.4, 0, 0.2, 1],       // Both

  // Custom easings
  smooth: [0.25, 0.1, 0.25, 1],      // Very smooth
  snappy: [0.175, 0.885, 0.32, 1.1], // Quick with overshoot
  bounce: [0.68, -0.55, 0.265, 1.55],// Playful bounce

  // Springs
  gentle: { stiffness: 120, damping: 14 },
  responsive: { stiffness: 300, damping: 25 },
  stiff: { stiffness: 500, damping: 30 }
}
```

### 9.4 Reduced Motion Support

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

```typescript
// React hook
const prefersReducedMotion = useReducedMotion();

const variants = prefersReducedMotion
  ? { initial: {}, animate: {}, exit: {} }
  : fullAnimationVariants;
```

---

## 10. Component Specifications

### 10.1 Stat Card Component

```
┌─────────────────────────────┐
│  [Icon]                     │
│                             │
│  2,450                      │  ← Value (h3, semibold)
│  Total Balance              │  ← Label (caption, muted)
│                             │
│  ↑ 12.5%                    │  ← Trend (optional)
└─────────────────────────────┘

Height: 100px
Padding: 20px
Border-radius: 16px
Background: card
Border: 1px solid border
Hover: lift + shadow
```

### 10.2 Project Card Component

```
┌─────────────────────────────────────────────┐
│ [● Active]                        [⋮ Menu] │  ← Status badge + actions
│                                             │
│  Project Title Here                         │  ← h4, semibold
│  Brief description of the project that      │  ← body-sm, muted
│  spans multiple lines if needed...          │
│                                             │
│  ▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░  45%              │  ← Progress bar
│                                             │
│  (○) John Doe              Due: Jan 25     │  ← Avatar + due date
└─────────────────────────────────────────────┘

Padding: 24px
Border-radius: 16px
Progress bar height: 6px
Hover: y: -4px, shadow-lg
```

### 10.3 Marketplace Card Component

```
┌───────────────────────┐
│                       │
│        [Image]        │  ← Aspect ratio: 4:3 or square
│                       │
│   [♡]           [₹X]  │  ← Favorite + price overlay
├───────────────────────┤
│  Product Title        │  ← body, semibold, 2 lines max
│                       │
│  📍 Location  [Badge] │  ← Meta + category
└───────────────────────┘

Border-radius: 12px
Image hover: scale 1.05
Card hover: y: -2px, border highlight
```

### 10.4 Transaction Item Component

```
┌─────────────────────────────────────────────────────────────┐
│  (○)  Project Payment Received          +₹1,500  ● Done    │
│       Web Development Project            2:30 PM           │
└─────────────────────────────────────────────────────────────┘

Height: 72px
Padding: 16px
Avatar size: 40px
Hover: background highlight
Positive amounts: success color
Negative amounts: error color
```

### 10.5 Filter Pill Component

```
┌──────────────┐  ┌──────────────┐
│  ○ All (24)  │  │  ● Active    │  ← Selected state
└──────────────┘  └──────────────┘

Height: 36px
Padding: 8px 16px
Border-radius: full (9999px)
Default: outline style
Selected: filled primary
Transition: 200ms
```

---

## 11. Accessibility Standards

### 11.1 Color Contrast

| Element | Minimum Ratio | Target Ratio |
|---------|---------------|--------------|
| Body text | 4.5:1 | 7:1 |
| Large text | 3:1 | 4.5:1 |
| UI components | 3:1 | 4.5:1 |
| Focus indicators | 3:1 | 4.5:1 |

### 11.2 Focus States

```css
/* Visible focus ring */
:focus-visible {
  outline: 2px solid var(--primary);
  outline-offset: 2px;
}

/* For dark backgrounds */
.dark :focus-visible {
  outline-color: var(--primary-light);
}
```

### 11.3 Keyboard Navigation

- All interactive elements focusable via Tab
- Logical tab order (left-to-right, top-to-bottom)
- Skip links for main content
- Escape closes modals/dropdowns
- Arrow keys navigate within components

### 11.4 Screen Reader Support

```tsx
// Proper labeling
<button aria-label="Add new project">
  <PlusIcon aria-hidden="true" />
</button>

// Live regions for updates
<div role="status" aria-live="polite">
  {loadingMessage}
</div>

// Landmark regions
<main role="main">
<nav role="navigation">
<aside role="complementary">
```

### 11.5 Motion Accessibility

```tsx
// Respect user preferences
const prefersReducedMotion = window.matchMedia(
  "(prefers-reduced-motion: reduce)"
).matches;

// Provide controls
<button onClick={toggleAnimations}>
  {animationsEnabled ? "Disable" : "Enable"} animations
</button>
```

---

## 12. Implementation Checklist

### Phase 1: Skeleton System (Priority: Critical)

- [ ] Create `useMinimumLoadingTime` hook
- [ ] Create `PageSkeletonProvider` component
- [ ] Create base skeleton primitives
  - [ ] `SkeletonBox`
  - [ ] `SkeletonCircle`
  - [ ] `SkeletonText`
  - [ ] `SkeletonButton`
  - [ ] `SkeletonBadge`
- [ ] Create composite skeletons
  - [ ] `SkeletonStat`
  - [ ] `SkeletonProjectCard`
  - [ ] `SkeletonMarketplaceCard`
  - [ ] `SkeletonTransactionItem`
  - [ ] `SkeletonActivityItem`
- [ ] Create page skeletons
  - [ ] `DashboardSkeleton`
  - [ ] `ProjectsSkeleton`
  - [ ] `MarketplaceSkeleton`
  - [ ] `WalletSkeleton`
- [ ] Implement staggered reveal animations

### Phase 2: Layout Unification

- [ ] Create shared `PageLayout` component
- [ ] Standardize hero sections across pages
- [ ] Implement consistent stats row
- [ ] Unify quick actions bar pattern
- [ ] Apply consistent spacing

### Phase 3: Micro-Interactions

- [ ] Enhance button interactions
- [ ] Improve card hover states
- [ ] Add form field animations
- [ ] Implement toast animations
- [ ] Add celebration effects

### Phase 4: Polish & Refinement

- [ ] Audit color contrast
- [ ] Test keyboard navigation
- [ ] Add screen reader labels
- [ ] Implement reduced motion
- [ ] Performance optimization
- [ ] Cross-browser testing

---

## Appendix A: File Structure

```
components/
├── skeletons/
│   ├── primitives/
│   │   ├── skeleton-box.tsx
│   │   ├── skeleton-circle.tsx
│   │   ├── skeleton-text.tsx
│   │   └── index.ts
│   ├── composites/
│   │   ├── skeleton-stat.tsx
│   │   ├── skeleton-project-card.tsx
│   │   ├── skeleton-marketplace-card.tsx
│   │   ├── skeleton-transaction-item.tsx
│   │   └── index.ts
│   ├── pages/
│   │   ├── dashboard-skeleton.tsx
│   │   ├── projects-skeleton.tsx
│   │   ├── marketplace-skeleton.tsx
│   │   ├── wallet-skeleton.tsx
│   │   └── index.ts
│   ├── page-skeleton-provider.tsx
│   └── index.ts
├── layout/
│   ├── page-layout.tsx
│   ├── hero-section.tsx
│   ├── stats-row.tsx
│   ├── quick-actions-bar.tsx
│   └── index.ts
hooks/
├── use-minimum-loading-time.ts
├── use-staggered-reveal.ts
└── use-reduced-motion.ts
```

---

## Appendix B: Design Tokens Export

```json
{
  "colors": {
    "primary": "oklch(0.44 0.06 35)",
    "background": "oklch(0.985 0.002 60)",
    "foreground": "oklch(0.145 0.01 30)"
  },
  "spacing": {
    "1": "4px",
    "2": "8px",
    "3": "12px",
    "4": "16px"
  },
  "radii": {
    "sm": "6px",
    "md": "12px",
    "lg": "16px",
    "full": "9999px"
  },
  "shadows": {
    "sm": "0 1px 3px rgba(0,0,0,0.1)",
    "md": "0 4px 6px rgba(0,0,0,0.1)",
    "lg": "0 10px 15px rgba(0,0,0,0.1)"
  },
  "durations": {
    "fast": "150ms",
    "normal": "250ms",
    "slow": "400ms"
  }
}
```

---

**Document End**

*This specification provides a complete blueprint for implementing a production-ready UI/UX system for AssignX. All measurements, colors, and animations have been carefully considered to create a cohesive, accessible, and delightful user experience.*
