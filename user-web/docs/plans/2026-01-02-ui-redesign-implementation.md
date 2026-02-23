# UI Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Transform AssignX from a generic AI-generated look into a bold, Gen-Z Notion-inspired experience with full micro-interactions.

**Architecture:** Design system first approach - create CSS tokens, Framer Motion variants, and base components before rebuilding the dashboard. Components use composition pattern with motion wrappers.

**Tech Stack:** Next.js 16, React 19, Framer Motion, Tailwind CSS 4, Lottie-react, OpenPeeps SVGs, shadcn/ui (extended)

---

## Phase 1: Foundation

### Task 1: Install Dependencies

**Files:**
- Modify: `package.json`

**Step 1: Install lottie-react for animated icons**

```bash
npm install lottie-react
```

Expected: Package added to dependencies

**Step 2: Verify installation**

```bash
npm ls lottie-react
```

Expected: Shows `lottie-react@x.x.x`

**Step 3: Commit**

```bash
git add package.json package-lock.json
git commit -m "chore: add lottie-react for animated icons"
```

---

### Task 2: Create Color Tokens

**Files:**
- Create: `styles/tokens/colors.css`
- Modify: `app/globals.css`

**Step 1: Create colors.css token file**

Create file `styles/tokens/colors.css`:

```css
/* AssignX Design System - Color Tokens */
/* Notion-inspired warm neutrals + vibrant pops */

:root {
  /* Background colors */
  --background: 30 50% 99%;           /* #FFFCF9 warm cream */
  --background-rgb: 255, 252, 249;

  --surface: 0 0% 100%;               /* #FFFFFF */
  --surface-rgb: 255, 255, 255;

  --surface-muted: 30 15% 96%;        /* #F7F5F2 warm gray */
  --surface-muted-rgb: 247, 245, 242;

  /* Text colors */
  --foreground: 0 0% 10%;             /* #1A1A1A */
  --foreground-rgb: 26, 26, 26;

  --muted: 0 0% 42%;                  /* #6B6B6B */
  --muted-rgb: 107, 107, 107;

  --muted-foreground: 0 0% 61%;       /* #9B9B9B */
  --muted-foreground-rgb: 155, 155, 155;

  /* Primary - Coral Orange */
  --primary: 14 100% 60%;             /* #FF5C35 */
  --primary-rgb: 255, 92, 53;
  --primary-foreground: 0 0% 100%;

  /* Secondary */
  --secondary: 30 15% 96%;
  --secondary-foreground: 0 0% 10%;

  /* Accent colors */
  --success: 160 100% 39%;            /* #00C48C mint */
  --success-rgb: 0, 196, 140;
  --success-foreground: 0 0% 100%;

  --warning: 43 100% 50%;             /* #FFB800 gold */
  --warning-rgb: 255, 184, 0;
  --warning-foreground: 0 0% 10%;

  --info: 220 80% 65%;                /* #5B8DEF blue */
  --info-rgb: 91, 141, 239;
  --info-foreground: 0 0% 100%;

  --destructive: 0 84% 60%;           /* #E53935 */
  --destructive-rgb: 229, 57, 53;
  --destructive-foreground: 0 0% 100%;

  --accent-purple: 282 39% 53%;       /* #9B59B6 */
  --accent-purple-rgb: 155, 89, 182;

  /* Border & Ring */
  --border: 30 15% 90%;
  --ring: 14 100% 60%;

  /* Card */
  --card: 0 0% 100%;
  --card-foreground: 0 0% 10%;

  /* Popover */
  --popover: 0 0% 100%;
  --popover-foreground: 0 0% 10%;

  /* Input */
  --input: 30 15% 90%;

  /* Chart colors */
  --chart-1: 14 100% 60%;
  --chart-2: 160 100% 39%;
  --chart-3: 220 80% 65%;
  --chart-4: 43 100% 50%;
  --chart-5: 282 39% 53%;
}

.dark {
  --background: 0 0% 7%;              /* #121212 */
  --background-rgb: 18, 18, 18;

  --surface: 0 0% 11%;                /* #1C1C1C */
  --surface-rgb: 28, 28, 28;

  --surface-muted: 0 0% 15%;          /* #262626 */
  --surface-muted-rgb: 38, 38, 38;

  --foreground: 0 0% 95%;             /* #F2F2F2 */
  --foreground-rgb: 242, 242, 242;

  --muted: 0 0% 60%;
  --muted-foreground: 0 0% 45%;

  --border: 0 0% 20%;
  --input: 0 0% 20%;

  --card: 0 0% 11%;
  --card-foreground: 0 0% 95%;

  --popover: 0 0% 11%;
  --popover-foreground: 0 0% 95%;
}
```

**Step 2: Import colors in globals.css**

Add at the top of `app/globals.css` after tailwind imports:

```css
@import "../styles/tokens/colors.css";
```

**Step 3: Create styles/tokens directory if needed**

```bash
mkdir -p styles/tokens
```

**Step 4: Verify file exists**

```bash
ls styles/tokens/colors.css
```

Expected: File exists

**Step 5: Commit**

```bash
git add styles/tokens/colors.css app/globals.css
git commit -m "feat(design): add color tokens - warm neutrals + vibrant pops"
```

---

### Task 3: Create Spacing & Shadow Tokens

**Files:**
- Create: `styles/tokens/spacing.css`
- Modify: `app/globals.css`

**Step 1: Create spacing.css token file**

Create file `styles/tokens/spacing.css`:

```css
/* AssignX Design System - Spacing & Shadow Tokens */

:root {
  /* Spacing scale (8px base) */
  --space-0: 0;
  --space-1: 0.25rem;   /* 4px */
  --space-2: 0.5rem;    /* 8px */
  --space-3: 0.75rem;   /* 12px */
  --space-4: 1rem;      /* 16px */
  --space-5: 1.25rem;   /* 20px */
  --space-6: 1.5rem;    /* 24px */
  --space-8: 2rem;      /* 32px */
  --space-10: 2.5rem;   /* 40px */
  --space-12: 3rem;     /* 48px */
  --space-16: 4rem;     /* 64px */
  --space-20: 5rem;     /* 80px */
  --space-24: 6rem;     /* 96px */

  /* Border radius */
  --radius-none: 0;
  --radius-sm: 6px;
  --radius-md: 12px;
  --radius-lg: 16px;
  --radius-xl: 24px;
  --radius-full: 9999px;

  /* Shadows */
  --shadow-none: none;
  --shadow-xs: 0 1px 2px rgba(0, 0, 0, 0.04);
  --shadow-sm: 0 1px 3px rgba(0, 0, 0, 0.06), 0 1px 2px rgba(0, 0, 0, 0.04);
  --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.05), 0 2px 4px rgba(0, 0, 0, 0.04);
  --shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.08), 0 4px 6px rgba(0, 0, 0, 0.04);
  --shadow-xl: 0 20px 25px rgba(0, 0, 0, 0.1), 0 10px 10px rgba(0, 0, 0, 0.04);
  --shadow-2xl: 0 25px 50px rgba(0, 0, 0, 0.15);

  /* Glow shadows for interactive states */
  --shadow-glow-primary: 0 0 20px rgba(255, 92, 53, 0.25);
  --shadow-glow-success: 0 0 20px rgba(0, 196, 140, 0.25);
  --shadow-glow-info: 0 0 20px rgba(91, 141, 239, 0.25);

  /* Card hover shadow */
  --shadow-card-hover: 0 12px 24px rgba(0, 0, 0, 0.1), 0 4px 8px rgba(0, 0, 0, 0.05);

  /* Transitions */
  --transition-fast: 150ms ease;
  --transition-normal: 250ms ease;
  --transition-slow: 400ms ease;
  --transition-spring: 500ms cubic-bezier(0.175, 0.885, 0.32, 1.1);
}

.dark {
  --shadow-xs: 0 1px 2px rgba(0, 0, 0, 0.2);
  --shadow-sm: 0 1px 3px rgba(0, 0, 0, 0.3), 0 1px 2px rgba(0, 0, 0, 0.2);
  --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.25), 0 2px 4px rgba(0, 0, 0, 0.2);
  --shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.3), 0 4px 6px rgba(0, 0, 0, 0.2);
  --shadow-xl: 0 20px 25px rgba(0, 0, 0, 0.35), 0 10px 10px rgba(0, 0, 0, 0.2);
  --shadow-2xl: 0 25px 50px rgba(0, 0, 0, 0.4);

  --shadow-glow-primary: 0 0 20px rgba(255, 92, 53, 0.35);
  --shadow-glow-success: 0 0 20px rgba(0, 196, 140, 0.35);
  --shadow-glow-info: 0 0 20px rgba(91, 141, 239, 0.35);

  --shadow-card-hover: 0 12px 24px rgba(0, 0, 0, 0.3), 0 4px 8px rgba(0, 0, 0, 0.2);
}
```

**Step 2: Import in globals.css**

Add after colors import in `app/globals.css`:

```css
@import "../styles/tokens/spacing.css";
```

**Step 3: Commit**

```bash
git add styles/tokens/spacing.css app/globals.css
git commit -m "feat(design): add spacing, shadow, and radius tokens"
```

---

### Task 4: Create Framer Motion Animation Variants

**Files:**
- Create: `lib/animations/variants.ts`
- Create: `lib/animations/index.ts`

**Step 1: Create animations directory**

```bash
mkdir -p lib/animations
```

**Step 2: Create variants.ts**

Create file `lib/animations/variants.ts`:

```typescript
/**
 * Framer Motion Animation Variants
 * Reusable animation configurations for consistent micro-interactions
 */

import { Variants, Transition } from "framer-motion";

// ============================================
// EASING CURVES
// ============================================

export const easings = {
  /** Smooth default easing */
  smooth: [0.25, 0.1, 0.25, 1] as const,
  /** Bouncy spring-like easing */
  bounce: [0.68, -0.55, 0.265, 1.55] as const,
  /** Snappy with slight overshoot */
  snappy: [0.175, 0.885, 0.32, 1.1] as const,
  /** Ease out for exits */
  easeOut: [0, 0, 0.2, 1] as const,
  /** Ease in for entrances */
  easeIn: [0.4, 0, 1, 1] as const,
};

// ============================================
// DURATION PRESETS
// ============================================

export const durations = {
  /** Quick feedback (buttons, hovers) */
  fast: 0.15,
  /** Standard transitions */
  normal: 0.25,
  /** Slower, more dramatic */
  slow: 0.4,
  /** Stagger delay between children */
  stagger: 0.05,
  /** Page transitions */
  page: 0.3,
};

// ============================================
// SPRING CONFIGS
// ============================================

export const springs = {
  /** Gentle, smooth spring */
  gentle: { type: "spring", stiffness: 120, damping: 14 } as Transition,
  /** Bouncy, playful spring */
  bouncy: { type: "spring", stiffness: 300, damping: 15 } as Transition,
  /** Snappy, responsive spring */
  snappy: { type: "spring", stiffness: 400, damping: 25 } as Transition,
  /** Stiff, minimal overshoot */
  stiff: { type: "spring", stiffness: 500, damping: 30 } as Transition,
};

// ============================================
// FADE VARIANTS
// ============================================

export const fadeIn: Variants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: { duration: durations.normal }
  },
  exit: {
    opacity: 0,
    transition: { duration: durations.fast }
  },
};

export const fadeInUp: Variants = {
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: { duration: durations.normal, ease: easings.smooth }
  },
  exit: {
    opacity: 0,
    y: -10,
    transition: { duration: durations.fast }
  },
};

export const fadeInDown: Variants = {
  hidden: { opacity: 0, y: -20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: { duration: durations.normal, ease: easings.smooth }
  },
  exit: {
    opacity: 0,
    y: 10,
    transition: { duration: durations.fast }
  },
};

export const fadeInScale: Variants = {
  hidden: { opacity: 0, scale: 0.95 },
  visible: {
    opacity: 1,
    scale: 1,
    transition: { duration: durations.normal, ease: easings.smooth }
  },
  exit: {
    opacity: 0,
    scale: 0.95,
    transition: { duration: durations.fast }
  },
};

// ============================================
// STAGGER CONTAINERS
// ============================================

export const staggerContainer: Variants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: durations.stagger,
      delayChildren: 0.1,
    },
  },
  exit: {
    opacity: 0,
    transition: {
      staggerChildren: 0.03,
      staggerDirection: -1,
    },
  },
};

export const staggerContainerFast: Variants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.03,
      delayChildren: 0.05,
    },
  },
};

export const staggerItem: Variants = {
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: { duration: durations.normal, ease: easings.smooth },
  },
  exit: {
    opacity: 0,
    y: -10,
    transition: { duration: durations.fast },
  },
};

// ============================================
// CARD ANIMATIONS
// ============================================

export const cardHover: Variants = {
  rest: {
    y: 0,
    boxShadow: "0 1px 3px rgba(0, 0, 0, 0.06), 0 1px 2px rgba(0, 0, 0, 0.04)",
  },
  hover: {
    y: -4,
    boxShadow: "0 12px 24px rgba(0, 0, 0, 0.1), 0 4px 8px rgba(0, 0, 0, 0.05)",
    transition: { duration: durations.fast, ease: easings.easeOut },
  },
  tap: {
    y: -2,
    scale: 0.99,
    transition: { duration: 0.1 },
  },
};

export const cardPress: Variants = {
  rest: { scale: 1 },
  pressed: {
    scale: 0.98,
    transition: { duration: 0.1 },
  },
};

// ============================================
// BUTTON ANIMATIONS
// ============================================

export const buttonTap: Variants = {
  rest: { scale: 1 },
  hover: {
    scale: 1.02,
    transition: { duration: durations.fast, ease: easings.easeOut },
  },
  tap: {
    scale: 0.97,
    transition: { duration: 0.1 },
  },
};

export const buttonPulse: Variants = {
  rest: { scale: 1 },
  pulse: {
    scale: [1, 1.05, 1],
    transition: {
      duration: 1.5,
      repeat: Infinity,
      ease: "easeInOut"
    },
  },
};

// ============================================
// MODAL ANIMATIONS
// ============================================

export const modalOverlay: Variants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: { duration: durations.fast },
  },
  exit: {
    opacity: 0,
    transition: { duration: durations.fast, delay: 0.1 },
  },
};

export const modalContent: Variants = {
  hidden: {
    opacity: 0,
    scale: 0.95,
    y: 10,
  },
  visible: {
    opacity: 1,
    scale: 1,
    y: 0,
    transition: springs.snappy,
  },
  exit: {
    opacity: 0,
    scale: 0.95,
    y: 10,
    transition: { duration: durations.fast },
  },
};

export const sheetContent: Variants = {
  hidden: {
    y: "100%",
    opacity: 0.5,
  },
  visible: {
    y: 0,
    opacity: 1,
    transition: springs.snappy,
  },
  exit: {
    y: "100%",
    opacity: 0.5,
    transition: { duration: durations.normal, ease: easings.easeIn },
  },
};

// ============================================
// PAGE TRANSITIONS
// ============================================

export const pageTransition: Variants = {
  hidden: {
    opacity: 0,
    y: 12,
  },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      duration: durations.page,
      ease: easings.smooth,
      when: "beforeChildren",
    },
  },
  exit: {
    opacity: 0,
    transition: { duration: durations.fast },
  },
};

// ============================================
// SIDEBAR ANIMATIONS
// ============================================

export const sidebarExpand: Variants = {
  collapsed: { width: 72 },
  expanded: {
    width: 260,
    transition: springs.snappy,
  },
};

export const sidebarItemLabel: Variants = {
  collapsed: {
    opacity: 0,
    width: 0,
    transition: { duration: durations.fast },
  },
  expanded: {
    opacity: 1,
    width: "auto",
    transition: { duration: durations.normal, delay: 0.1 },
  },
};

export const sidebarActiveIndicator: Variants = {
  inactive: {
    width: 0,
    opacity: 0,
  },
  active: {
    width: 4,
    opacity: 1,
    transition: springs.bouncy,
  },
};

// ============================================
// ICON ANIMATIONS
// ============================================

export const iconWiggle: Variants = {
  rest: { rotate: 0 },
  hover: {
    rotate: [0, -10, 10, -5, 5, 0],
    transition: { duration: 0.5 },
  },
};

export const iconBounce: Variants = {
  rest: { y: 0 },
  hover: {
    y: [0, -4, 0],
    transition: { duration: 0.3, ease: easings.bounce },
  },
};

export const iconSpin: Variants = {
  rest: { rotate: 0 },
  spin: {
    rotate: 360,
    transition: { duration: 0.8, ease: "linear", repeat: Infinity },
  },
};

// ============================================
// NOTIFICATION ANIMATIONS
// ============================================

export const toastSlideIn: Variants = {
  hidden: {
    opacity: 0,
    x: 100,
    scale: 0.9,
  },
  visible: {
    opacity: 1,
    x: 0,
    scale: 1,
    transition: springs.bouncy,
  },
  exit: {
    opacity: 0,
    x: 100,
    scale: 0.9,
    transition: { duration: durations.fast },
  },
};

export const badgePop: Variants = {
  hidden: { scale: 0, opacity: 0 },
  visible: {
    scale: 1,
    opacity: 1,
    transition: springs.bouncy,
  },
  exit: {
    scale: 0,
    opacity: 0,
    transition: { duration: durations.fast },
  },
};

// ============================================
// SKELETON SHIMMER
// ============================================

export const shimmer: Variants = {
  animate: {
    backgroundPosition: ["200% 0", "-200% 0"],
    transition: {
      duration: 1.5,
      ease: "linear",
      repeat: Infinity,
    },
  },
};

// ============================================
// CELEBRATION ANIMATIONS
// ============================================

export const checkmarkDraw: Variants = {
  hidden: { pathLength: 0, opacity: 0 },
  visible: {
    pathLength: 1,
    opacity: 1,
    transition: {
      pathLength: { duration: 0.4, ease: "easeOut" },
      opacity: { duration: 0.2 },
    },
  },
};

export const celebrationPop: Variants = {
  hidden: { scale: 0, rotate: -180 },
  visible: {
    scale: 1,
    rotate: 0,
    transition: springs.bouncy,
  },
};
```

**Step 3: Create index.ts barrel export**

Create file `lib/animations/index.ts`:

```typescript
/**
 * Animation System Exports
 * Central export for all animation utilities
 */

export * from "./variants";
```

**Step 4: Commit**

```bash
git add lib/animations/
git commit -m "feat(design): add Framer Motion animation variants system"
```

---

### Task 5: Create Motion Component Wrappers

**Files:**
- Create: `components/animations/motion-div.tsx`
- Create: `components/animations/stagger-container.tsx`
- Create: `components/animations/fade-in.tsx`
- Create: `components/animations/index.ts`

**Step 1: Create animations component directory**

```bash
mkdir -p components/animations
```

**Step 2: Create motion-div.tsx**

Create file `components/animations/motion-div.tsx`:

```tsx
"use client";

/**
 * MotionDiv - Base animated div wrapper
 * Use for simple animations on any container
 */

import { motion, HTMLMotionProps } from "framer-motion";
import { forwardRef } from "react";

export interface MotionDivProps extends HTMLMotionProps<"div"> {
  children: React.ReactNode;
}

export const MotionDiv = forwardRef<HTMLDivElement, MotionDivProps>(
  ({ children, ...props }, ref) => {
    return (
      <motion.div ref={ref} {...props}>
        {children}
      </motion.div>
    );
  }
);

MotionDiv.displayName = "MotionDiv";
```

**Step 3: Create stagger-container.tsx**

Create file `components/animations/stagger-container.tsx`:

```tsx
"use client";

/**
 * StaggerContainer - Animates children with staggered delay
 * Wrap list items for sequential fade-in effect
 */

import { motion, HTMLMotionProps } from "framer-motion";
import { staggerContainer, staggerItem } from "@/lib/animations";
import { forwardRef } from "react";

export interface StaggerContainerProps extends Omit<HTMLMotionProps<"div">, "variants"> {
  children: React.ReactNode;
  /** Custom stagger delay in seconds */
  staggerDelay?: number;
  /** Delay before animation starts */
  delayChildren?: number;
  /** HTML element to render as */
  as?: "div" | "ul" | "ol" | "section" | "article";
}

export const StaggerContainer = forwardRef<HTMLDivElement, StaggerContainerProps>(
  ({ children, staggerDelay = 0.05, delayChildren = 0.1, as = "div", ...props }, ref) => {
    const Component = motion[as] as typeof motion.div;

    return (
      <Component
        ref={ref}
        variants={{
          hidden: { opacity: 0 },
          visible: {
            opacity: 1,
            transition: {
              staggerChildren: staggerDelay,
              delayChildren,
            },
          },
        }}
        initial="hidden"
        animate="visible"
        exit="hidden"
        {...props}
      >
        {children}
      </Component>
    );
  }
);

StaggerContainer.displayName = "StaggerContainer";

/**
 * StaggerItem - Child component for StaggerContainer
 * Each item animates in sequence
 */
export interface StaggerItemProps extends Omit<HTMLMotionProps<"div">, "variants"> {
  children: React.ReactNode;
}

export const StaggerItem = forwardRef<HTMLDivElement, StaggerItemProps>(
  ({ children, ...props }, ref) => {
    return (
      <motion.div ref={ref} variants={staggerItem} {...props}>
        {children}
      </motion.div>
    );
  }
);

StaggerItem.displayName = "StaggerItem";
```

**Step 4: Create fade-in.tsx**

Create file `components/animations/fade-in.tsx`:

```tsx
"use client";

/**
 * FadeIn - Simple fade in animation wrapper
 * Supports multiple directions and triggers
 */

import { motion, HTMLMotionProps, useInView } from "framer-motion";
import { fadeIn, fadeInUp, fadeInDown, fadeInScale } from "@/lib/animations";
import { forwardRef, useRef } from "react";

type FadeDirection = "up" | "down" | "none" | "scale";

export interface FadeInProps extends Omit<HTMLMotionProps<"div">, "variants"> {
  children: React.ReactNode;
  /** Direction of fade animation */
  direction?: FadeDirection;
  /** Delay before animation starts */
  delay?: number;
  /** Duration of animation */
  duration?: number;
  /** Trigger animation when in view */
  triggerOnView?: boolean;
  /** Only animate once when in view */
  once?: boolean;
  /** Viewport margin for triggering */
  viewportMargin?: string;
}

const variantMap = {
  up: fadeInUp,
  down: fadeInDown,
  none: fadeIn,
  scale: fadeInScale,
};

export const FadeIn = forwardRef<HTMLDivElement, FadeInProps>(
  (
    {
      children,
      direction = "up",
      delay = 0,
      duration,
      triggerOnView = false,
      once = true,
      viewportMargin = "-100px",
      ...props
    },
    ref
  ) => {
    const internalRef = useRef<HTMLDivElement>(null);
    const isInView = useInView(internalRef, {
      once,
      margin: viewportMargin,
    });

    const variants = variantMap[direction];
    const shouldAnimate = triggerOnView ? isInView : true;

    return (
      <motion.div
        ref={ref || internalRef}
        variants={variants}
        initial="hidden"
        animate={shouldAnimate ? "visible" : "hidden"}
        transition={{ delay, duration }}
        {...props}
      >
        {children}
      </motion.div>
    );
  }
);

FadeIn.displayName = "FadeIn";
```

**Step 5: Create index.ts barrel export**

Create file `components/animations/index.ts`:

```typescript
/**
 * Animation Components Exports
 */

export { MotionDiv, type MotionDivProps } from "./motion-div";
export {
  StaggerContainer,
  StaggerItem,
  type StaggerContainerProps,
  type StaggerItemProps
} from "./stagger-container";
export { FadeIn, type FadeInProps } from "./fade-in";
```

**Step 6: Commit**

```bash
git add components/animations/
git commit -m "feat(design): add motion component wrappers for animations"
```

---

### Task 6: Download OpenPeeps Illustrations

**Files:**
- Create: `public/illustrations/openpeeps/` directory
- Download: Core OpenPeeps SVG assets

**Step 1: Create illustrations directory**

```bash
mkdir -p public/illustrations/openpeeps
```

**Step 2: Create a placeholder README for illustrations**

Create file `public/illustrations/openpeeps/README.md`:

```markdown
# OpenPeeps Illustrations

Download from: https://www.openpeeps.com/

## Required Assets

Place the following SVG files in this directory:

- `celebrating.svg` - Person celebrating (for success states)
- `relaxing.svg` - Person relaxing in hammock (for empty projects)
- `working.svg` - Person working on laptop (for in-progress)
- `waving.svg` - Person waving hello (for sidebar/greeting)
- `confused.svg` - Person scratching head (for error states)
- `thinking.svg` - Person thinking (for loading states)
- `reading.svg` - Person reading (for empty notifications)

## Usage

```tsx
import Image from "next/image";

<Image
  src="/illustrations/openpeeps/celebrating.svg"
  alt="Celebration"
  width={200}
  height={200}
/>
```

## License

OpenPeeps is CC0 - free for personal and commercial use.
```

**Step 3: Commit**

```bash
git add public/illustrations/
git commit -m "docs: add OpenPeeps illustrations directory with README"
```

---

### Task 7: Create Lottie Icons Directory

**Files:**
- Create: `public/lottie/` directory structure
- Create: Placeholder JSON for testing

**Step 1: Create lottie directory**

```bash
mkdir -p public/lottie/icons
```

**Step 2: Create a simple test animation JSON**

Create file `public/lottie/icons/checkmark.json`:

```json
{
  "v": "5.7.4",
  "fr": 60,
  "ip": 0,
  "op": 60,
  "w": 100,
  "h": 100,
  "nm": "Checkmark",
  "ddd": 0,
  "assets": [],
  "layers": [
    {
      "ddd": 0,
      "ind": 1,
      "ty": 4,
      "nm": "Check",
      "sr": 1,
      "ks": {
        "o": { "a": 0, "k": 100 },
        "r": { "a": 0, "k": 0 },
        "p": { "a": 0, "k": [50, 50, 0] },
        "a": { "a": 0, "k": [0, 0, 0] },
        "s": { "a": 0, "k": [100, 100, 100] }
      },
      "ao": 0,
      "shapes": [
        {
          "ty": "gr",
          "it": [
            {
              "ind": 0,
              "ty": "sh",
              "ks": {
                "a": 1,
                "k": [
                  {
                    "t": 0,
                    "s": [{ "c": false, "v": [[-20, 0], [-20, 0], [-20, 0]], "i": [[0, 0], [0, 0], [0, 0]], "o": [[0, 0], [0, 0], [0, 0]] }]
                  },
                  {
                    "t": 30,
                    "s": [{ "c": false, "v": [[-20, 0], [-5, 15], [-5, 15]], "i": [[0, 0], [0, 0], [0, 0]], "o": [[0, 0], [0, 0], [0, 0]] }]
                  },
                  {
                    "t": 60,
                    "s": [{ "c": false, "v": [[-20, 0], [-5, 15], [25, -20]], "i": [[0, 0], [0, 0], [0, 0]], "o": [[0, 0], [0, 0], [0, 0]] }]
                  }
                ]
              }
            },
            {
              "ty": "st",
              "c": { "a": 0, "k": [0, 0.77, 0.55, 1] },
              "o": { "a": 0, "k": 100 },
              "w": { "a": 0, "k": 6 },
              "lc": 2,
              "lj": 2
            },
            {
              "ty": "tr",
              "p": { "a": 0, "k": [0, 0] },
              "a": { "a": 0, "k": [0, 0] },
              "s": { "a": 0, "k": [100, 100] },
              "r": { "a": 0, "k": 0 },
              "o": { "a": 0, "k": 100 }
            }
          ],
          "nm": "Checkmark"
        }
      ],
      "ip": 0,
      "op": 60,
      "st": 0
    }
  ]
}
```

**Step 3: Create README for lottie directory**

Create file `public/lottie/README.md`:

```markdown
# Lottie Animations

## Directory Structure

```
lottie/
├── icons/           # Small icon animations
│   ├── checkmark.json
│   ├── loading.json
│   ├── new-project.json
│   ├── proofread.json
│   ├── ai-check.json
│   └── expert.json
├── success.json     # Success celebration
├── error.json       # Error state
└── confetti.json    # Confetti celebration
```

## Recommended Sources

- LottieFiles: https://lottiefiles.com/
- IconScout: https://iconscout.com/lottie-animations

## Usage with lottie-react

```tsx
import Lottie from "lottie-react";
import checkmarkAnimation from "@/public/lottie/icons/checkmark.json";

<Lottie
  animationData={checkmarkAnimation}
  loop={false}
  style={{ width: 48, height: 48 }}
/>
```
```

**Step 4: Commit**

```bash
git add public/lottie/
git commit -m "feat(design): add Lottie animations directory with test checkmark"
```

---

## Phase 2: Core Components

### Task 8: Create Animated Button Component

**Files:**
- Modify: `components/ui/button.tsx`

**Step 1: Read current button implementation**

```bash
cat components/ui/button.tsx
```

Understand current structure before modifying.

**Step 2: Update button.tsx with motion animations**

Modify `components/ui/button.tsx` to add Framer Motion:

```tsx
"use client";

import * as React from "react";
import { Slot } from "@radix-ui/react-slot";
import { cva, type VariantProps } from "class-variance-authority";
import { motion, HTMLMotionProps } from "framer-motion";
import { Loader2 } from "lucide-react";

import { cn } from "@/lib/utils";
import { buttonTap } from "@/lib/animations";

const buttonVariants = cva(
  "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-[var(--radius-sm)] text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0",
  {
    variants: {
      variant: {
        default:
          "bg-primary text-primary-foreground shadow hover:bg-primary/90",
        destructive:
          "bg-destructive text-destructive-foreground shadow-sm hover:bg-destructive/90",
        outline:
          "border border-input bg-background shadow-sm hover:bg-accent hover:text-accent-foreground",
        secondary:
          "bg-secondary text-secondary-foreground shadow-sm hover:bg-secondary/80",
        ghost: "hover:bg-accent hover:text-accent-foreground",
        link: "text-primary underline-offset-4 hover:underline",
        success:
          "bg-[hsl(var(--success))] text-white shadow-sm hover:bg-[hsl(var(--success))]/90",
        warning:
          "bg-[hsl(var(--warning))] text-[hsl(var(--foreground))] shadow-sm hover:bg-[hsl(var(--warning))]/90",
      },
      size: {
        default: "h-10 px-4 py-2",
        xs: "h-7 px-2.5 text-xs rounded-[var(--radius-sm)]",
        sm: "h-8 px-3 text-sm rounded-[var(--radius-sm)]",
        lg: "h-12 px-6 text-base rounded-[var(--radius-md)]",
        xl: "h-14 px-8 text-lg rounded-[var(--radius-md)]",
        icon: "h-10 w-10",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
);

export interface ButtonProps
  extends Omit<HTMLMotionProps<"button">, "children">,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean;
  loading?: boolean;
  children?: React.ReactNode;
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, loading = false, children, disabled, ...props }, ref) => {
    // If asChild, don't use motion
    if (asChild) {
      return (
        <Slot
          className={cn(buttonVariants({ variant, size, className }))}
          ref={ref as React.Ref<HTMLElement>}
          {...(props as React.HTMLAttributes<HTMLElement>)}
        >
          {children}
        </Slot>
      );
    }

    return (
      <motion.button
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        disabled={disabled || loading}
        variants={buttonTap}
        initial="rest"
        whileHover={disabled || loading ? undefined : "hover"}
        whileTap={disabled || loading ? undefined : "tap"}
        {...props}
      >
        {loading ? (
          <>
            <Loader2 className="animate-spin" />
            <span className="opacity-70">Loading...</span>
          </>
        ) : (
          children
        )}
      </motion.button>
    );
  }
);

Button.displayName = "Button";

export { Button, buttonVariants };
```

**Step 3: Test the button renders**

```bash
npm run build
```

Expected: Build succeeds without errors

**Step 4: Commit**

```bash
git add components/ui/button.tsx
git commit -m "feat(button): add Framer Motion animations and loading state"
```

---

### Task 9: Create Animated Card Component

**Files:**
- Modify: `components/ui/card.tsx`

**Step 1: Read current card implementation**

```bash
cat components/ui/card.tsx
```

**Step 2: Update card.tsx with motion animations and variants**

Modify `components/ui/card.tsx`:

```tsx
"use client";

import * as React from "react";
import { motion, HTMLMotionProps } from "framer-motion";
import { cva, type VariantProps } from "class-variance-authority";

import { cn } from "@/lib/utils";
import { cardHover } from "@/lib/animations";

const cardVariants = cva(
  "rounded-[var(--radius-md)] bg-card text-card-foreground transition-colors",
  {
    variants: {
      variant: {
        default: "border border-border/50 shadow-sm",
        elevated: "shadow-md border-0",
        interactive: "border border-border/50 shadow-sm cursor-pointer",
        highlighted: "border-l-4 border border-border/50 shadow-sm",
        glass: "bg-background/80 backdrop-blur-md border border-border/30",
      },
      padding: {
        none: "",
        sm: "p-4",
        md: "p-6",
        lg: "p-8",
      },
      highlightColor: {
        none: "",
        primary: "border-l-[hsl(var(--primary))]",
        success: "border-l-[hsl(var(--success))]",
        warning: "border-l-[hsl(var(--warning))]",
        info: "border-l-[hsl(var(--info))]",
        destructive: "border-l-[hsl(var(--destructive))]",
      },
    },
    defaultVariants: {
      variant: "default",
      padding: "none",
      highlightColor: "none",
    },
  }
);

export interface CardProps
  extends Omit<HTMLMotionProps<"div">, "children">,
    VariantProps<typeof cardVariants> {
  children?: React.ReactNode;
  /** Enable hover lift animation */
  animated?: boolean;
}

const Card = React.forwardRef<HTMLDivElement, CardProps>(
  ({ className, variant, padding, highlightColor, animated = false, children, ...props }, ref) => {
    if (animated || variant === "interactive") {
      return (
        <motion.div
          ref={ref}
          className={cn(cardVariants({ variant, padding, highlightColor, className }))}
          variants={cardHover}
          initial="rest"
          whileHover="hover"
          whileTap="tap"
          {...props}
        >
          {children}
        </motion.div>
      );
    }

    return (
      <div
        ref={ref as React.Ref<HTMLDivElement>}
        className={cn(cardVariants({ variant, padding, highlightColor, className }))}
        {...(props as React.HTMLAttributes<HTMLDivElement>)}
      >
        {children}
      </div>
    );
  }
);

Card.displayName = "Card";

const CardHeader = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn("flex flex-col space-y-1.5 p-6", className)}
    {...props}
  />
));
CardHeader.displayName = "CardHeader";

const CardTitle = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn("font-semibold leading-none tracking-tight", className)}
    {...props}
  />
));
CardTitle.displayName = "CardTitle";

const CardDescription = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn("text-sm text-muted-foreground", className)}
    {...props}
  />
));
CardDescription.displayName = "CardDescription";

const CardContent = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div ref={ref} className={cn("p-6 pt-0", className)} {...props} />
));
CardContent.displayName = "CardContent";

const CardFooter = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn("flex items-center p-6 pt-0", className)}
    {...props}
  />
));
CardFooter.displayName = "CardFooter";

export { Card, CardHeader, CardFooter, CardTitle, CardDescription, CardContent, cardVariants };
```

**Step 3: Verify build**

```bash
npm run build
```

Expected: Build succeeds

**Step 4: Commit**

```bash
git add components/ui/card.tsx
git commit -m "feat(card): add animated variants with Framer Motion hover effects"
```

---

### Task 10: Create Empty State Component

**Files:**
- Create: `components/feedback/empty-state.tsx`
- Create: `components/feedback/index.ts`

**Step 1: Create feedback directory**

```bash
mkdir -p components/feedback
```

**Step 2: Create empty-state.tsx**

Create file `components/feedback/empty-state.tsx`:

```tsx
"use client";

/**
 * EmptyState - Friendly empty state with OpenPeeps illustration
 * Use when lists/sections have no content
 */

import Image from "next/image";
import { motion } from "framer-motion";
import { Button } from "@/components/ui/button";
import { fadeInUp } from "@/lib/animations";
import { cn } from "@/lib/utils";

type EmptyStateVariant =
  | "projects"
  | "notifications"
  | "search"
  | "error"
  | "generic";

interface EmptyStateConfig {
  illustration: string;
  title: string;
  description: string;
}

const variantConfig: Record<EmptyStateVariant, EmptyStateConfig> = {
  projects: {
    illustration: "/illustrations/openpeeps/relaxing.svg",
    title: "No projects yet!",
    description: "Your first one is just a tap away. Let's get started!",
  },
  notifications: {
    illustration: "/illustrations/openpeeps/reading.svg",
    title: "All caught up!",
    description: "No new notifications. Enjoy the peace.",
  },
  search: {
    illustration: "/illustrations/openpeeps/thinking.svg",
    title: "Nothing found",
    description: "Try a different search term or check your filters.",
  },
  error: {
    illustration: "/illustrations/openpeeps/confused.svg",
    title: "Oops! Something went wrong",
    description: "We're on it. Please try again in a moment.",
  },
  generic: {
    illustration: "/illustrations/openpeeps/waving.svg",
    title: "Nothing here yet",
    description: "Check back later or create something new.",
  },
};

export interface EmptyStateProps {
  /** Predefined variant with matching illustration */
  variant?: EmptyStateVariant;
  /** Custom title (overrides variant) */
  title?: string;
  /** Custom description (overrides variant) */
  description?: string;
  /** Custom illustration path (overrides variant) */
  illustration?: string;
  /** Action button text */
  actionLabel?: string;
  /** Action button callback */
  onAction?: () => void;
  /** Additional CSS classes */
  className?: string;
  /** Illustration size */
  size?: "sm" | "md" | "lg";
}

const sizeMap = {
  sm: { width: 120, height: 120 },
  md: { width: 180, height: 180 },
  lg: { width: 240, height: 240 },
};

export function EmptyState({
  variant = "generic",
  title,
  description,
  illustration,
  actionLabel,
  onAction,
  className,
  size = "md",
}: EmptyStateProps) {
  const config = variantConfig[variant];
  const { width, height } = sizeMap[size];

  return (
    <motion.div
      className={cn(
        "flex flex-col items-center justify-center py-12 px-4 text-center",
        className
      )}
      variants={fadeInUp}
      initial="hidden"
      animate="visible"
    >
      {/* Illustration */}
      <motion.div
        className="mb-6"
        initial={{ scale: 0.8, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ delay: 0.1, duration: 0.4 }}
      >
        <Image
          src={illustration || config.illustration}
          alt=""
          width={width}
          height={height}
          className="opacity-90"
          priority
        />
      </motion.div>

      {/* Title */}
      <motion.h3
        className="text-xl font-semibold text-foreground mb-2"
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2 }}
      >
        {title || config.title}
      </motion.h3>

      {/* Description */}
      <motion.p
        className="text-muted-foreground max-w-sm mb-6"
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.3 }}
      >
        {description || config.description}
      </motion.p>

      {/* Action Button */}
      {actionLabel && onAction && (
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
        >
          <Button onClick={onAction} size="lg">
            {actionLabel}
          </Button>
        </motion.div>
      )}
    </motion.div>
  );
}
```

**Step 3: Create index.ts**

Create file `components/feedback/index.ts`:

```typescript
/**
 * Feedback Components Exports
 */

export { EmptyState, type EmptyStateProps } from "./empty-state";
```

**Step 4: Commit**

```bash
git add components/feedback/
git commit -m "feat(feedback): add EmptyState component with OpenPeeps illustrations"
```

---

### Task 11: Create Skeleton Loading Component

**Files:**
- Modify or create: `components/ui/skeleton.tsx`

**Step 1: Update skeleton.tsx with shimmer animation**

Create or update `components/ui/skeleton.tsx`:

```tsx
"use client";

/**
 * Skeleton - Shimmer loading placeholder
 * Use for content loading states
 */

import { cn } from "@/lib/utils";
import { motion } from "framer-motion";

export interface SkeletonProps extends React.HTMLAttributes<HTMLDivElement> {
  /** Enable shimmer animation */
  animate?: boolean;
}

function Skeleton({ className, animate = true, ...props }: SkeletonProps) {
  return (
    <div
      className={cn(
        "rounded-[var(--radius-sm)] bg-muted/60",
        animate && "relative overflow-hidden",
        className
      )}
      {...props}
    >
      {animate && (
        <motion.div
          className="absolute inset-0 -translate-x-full bg-gradient-to-r from-transparent via-white/20 to-transparent"
          animate={{
            translateX: ["−100%", "100%"],
          }}
          transition={{
            duration: 1.5,
            repeat: Infinity,
            ease: "linear",
          }}
        />
      )}
    </div>
  );
}

/**
 * SkeletonCard - Card-shaped skeleton
 */
function SkeletonCard({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div
      className={cn(
        "rounded-[var(--radius-md)] border border-border/50 p-6 space-y-4",
        className
      )}
      {...props}
    >
      <div className="flex items-center gap-4">
        <Skeleton className="h-12 w-12 rounded-full" />
        <div className="space-y-2 flex-1">
          <Skeleton className="h-4 w-3/4" />
          <Skeleton className="h-3 w-1/2" />
        </div>
      </div>
      <Skeleton className="h-20 w-full" />
      <div className="flex justify-between">
        <Skeleton className="h-4 w-24" />
        <Skeleton className="h-8 w-20 rounded-[var(--radius-sm)]" />
      </div>
    </div>
  );
}

/**
 * SkeletonText - Text line skeleton
 */
function SkeletonText({
  lines = 3,
  className,
  ...props
}: { lines?: number } & React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div className={cn("space-y-2", className)} {...props}>
      {Array.from({ length: lines }).map((_, i) => (
        <Skeleton
          key={i}
          className="h-4"
          style={{ width: `${100 - (i % 3) * 15}%` }}
        />
      ))}
    </div>
  );
}

export { Skeleton, SkeletonCard, SkeletonText };
```

**Step 2: Commit**

```bash
git add components/ui/skeleton.tsx
git commit -m "feat(skeleton): add shimmer animation and card/text variants"
```

---

## Phase 3: Layout Components

### Task 12: Create Animated Sidebar

**Files:**
- Create: `components/layout/sidebar/animated-sidebar.tsx`
- Create: `components/layout/sidebar/sidebar-item.tsx`
- Create: `components/layout/sidebar/sidebar-profile.tsx`
- Create: `components/layout/sidebar/index.ts`

This task creates the new Notion-inspired sidebar. Due to complexity, implement in substeps.

**Step 1: Create layout/sidebar directory**

```bash
mkdir -p components/layout/sidebar
```

**Step 2: Create sidebar-item.tsx**

Create file `components/layout/sidebar/sidebar-item.tsx`:

```tsx
"use client";

/**
 * SidebarItem - Individual navigation item with animations
 */

import Link from "next/link";
import { usePathname } from "next/navigation";
import { motion, AnimatePresence } from "framer-motion";
import { cn } from "@/lib/utils";
import { iconWiggle, sidebarActiveIndicator } from "@/lib/animations";
import { LucideIcon } from "lucide-react";

export interface SidebarItemProps {
  href: string;
  icon: LucideIcon;
  label: string;
  badge?: number;
  collapsed?: boolean;
}

export function SidebarItem({
  href,
  icon: Icon,
  label,
  badge,
  collapsed = false,
}: SidebarItemProps) {
  const pathname = usePathname();
  const isActive = pathname === href || pathname.startsWith(`${href}/`);

  return (
    <Link href={href} className="block">
      <motion.div
        className={cn(
          "relative flex items-center gap-3 px-3 py-2.5 rounded-[var(--radius-sm)] transition-colors",
          "hover:bg-surface-muted",
          isActive && "bg-surface-muted font-medium"
        )}
        whileHover="hover"
        initial="rest"
      >
        {/* Active indicator */}
        <motion.div
          className="absolute left-0 top-1/2 -translate-y-1/2 w-1 h-6 rounded-r-full bg-primary"
          variants={sidebarActiveIndicator}
          initial="inactive"
          animate={isActive ? "active" : "inactive"}
        />

        {/* Icon */}
        <motion.div
          className={cn(
            "flex-shrink-0 w-5 h-5",
            isActive ? "text-primary" : "text-muted-foreground"
          )}
          variants={iconWiggle}
        >
          <Icon className="w-5 h-5" />
        </motion.div>

        {/* Label */}
        <AnimatePresence mode="wait">
          {!collapsed && (
            <motion.span
              className={cn(
                "flex-1 text-sm truncate",
                isActive ? "text-foreground" : "text-muted-foreground"
              )}
              initial={{ opacity: 0, width: 0 }}
              animate={{ opacity: 1, width: "auto" }}
              exit={{ opacity: 0, width: 0 }}
              transition={{ duration: 0.2 }}
            >
              {label}
            </motion.span>
          )}
        </AnimatePresence>

        {/* Badge */}
        <AnimatePresence>
          {badge !== undefined && badge > 0 && !collapsed && (
            <motion.span
              className="px-2 py-0.5 text-xs font-medium bg-primary/10 text-primary rounded-full"
              initial={{ scale: 0, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0, opacity: 0 }}
              transition={{ type: "spring", stiffness: 500, damping: 25 }}
            >
              {badge > 99 ? "99+" : badge}
            </motion.span>
          )}
        </AnimatePresence>
      </motion.div>
    </Link>
  );
}
```

**Step 3: Create sidebar-profile.tsx**

Create file `components/layout/sidebar/sidebar-profile.tsx`:

```tsx
"use client";

/**
 * SidebarProfile - User profile pill in sidebar
 */

import { motion, AnimatePresence } from "framer-motion";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { ChevronDown } from "lucide-react";
import { cn } from "@/lib/utils";

export interface SidebarProfileProps {
  name: string;
  email?: string;
  avatarUrl?: string;
  collapsed?: boolean;
  onClick?: () => void;
}

export function SidebarProfile({
  name,
  email,
  avatarUrl,
  collapsed = false,
  onClick,
}: SidebarProfileProps) {
  const initials = name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);

  return (
    <motion.button
      className={cn(
        "w-full flex items-center gap-3 p-3 rounded-[var(--radius-md)]",
        "hover:bg-surface-muted transition-colors",
        "focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2"
      )}
      onClick={onClick}
      whileHover={{ scale: 1.01 }}
      whileTap={{ scale: 0.99 }}
    >
      <Avatar className="h-9 w-9 flex-shrink-0">
        <AvatarImage src={avatarUrl} alt={name} />
        <AvatarFallback className="bg-primary/10 text-primary text-sm font-medium">
          {initials}
        </AvatarFallback>
      </Avatar>

      <AnimatePresence mode="wait">
        {!collapsed && (
          <motion.div
            className="flex-1 text-left overflow-hidden"
            initial={{ opacity: 0, width: 0 }}
            animate={{ opacity: 1, width: "auto" }}
            exit={{ opacity: 0, width: 0 }}
            transition={{ duration: 0.2 }}
          >
            <p className="text-sm font-medium text-foreground truncate">{name}</p>
            {email && (
              <p className="text-xs text-muted-foreground truncate">{email}</p>
            )}
          </motion.div>
        )}
      </AnimatePresence>

      <AnimatePresence>
        {!collapsed && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
          >
            <ChevronDown className="h-4 w-4 text-muted-foreground" />
          </motion.div>
        )}
      </AnimatePresence>
    </motion.button>
  );
}
```

**Step 4: Create index.ts**

Create file `components/layout/sidebar/index.ts`:

```typescript
/**
 * Sidebar Components Exports
 */

export { SidebarItem, type SidebarItemProps } from "./sidebar-item";
export { SidebarProfile, type SidebarProfileProps } from "./sidebar-profile";
```

**Step 5: Commit**

```bash
git add components/layout/
git commit -m "feat(sidebar): add animated sidebar item and profile components"
```

---

### Task 13: Create Mobile Bottom Navigation

**Files:**
- Create: `components/layout/mobile-nav.tsx`

**Step 1: Create mobile-nav.tsx**

Create file `components/layout/mobile-nav.tsx`:

```tsx
"use client";

/**
 * MobileNav - Bottom navigation for mobile devices
 * 5 items: Home, Projects, FAB, Connect, Profile
 */

import Link from "next/link";
import { usePathname } from "next/navigation";
import { motion, AnimatePresence } from "framer-motion";
import { Home, FolderKanban, Plus, Users, User } from "lucide-react";
import { cn } from "@/lib/utils";

interface NavItem {
  href: string;
  icon: typeof Home;
  label: string;
}

const navItems: NavItem[] = [
  { href: "/home", icon: Home, label: "Home" },
  { href: "/projects", icon: FolderKanban, label: "Projects" },
  { href: "#fab", icon: Plus, label: "New" }, // FAB placeholder
  { href: "/connect", icon: Users, label: "Connect" },
  { href: "/profile", icon: User, label: "Profile" },
];

interface MobileNavProps {
  onFabClick?: () => void;
}

export function MobileNav({ onFabClick }: MobileNavProps) {
  const pathname = usePathname();

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-50 bg-background/95 backdrop-blur-md border-t border-border md:hidden">
      <div className="flex items-center justify-around h-16 px-2">
        {navItems.map((item, index) => {
          const isActive = pathname === item.href || pathname.startsWith(`${item.href}/`);
          const isFab = item.href === "#fab";

          if (isFab) {
            return (
              <motion.button
                key={item.href}
                onClick={onFabClick}
                className="relative -mt-6 flex items-center justify-center w-14 h-14 rounded-full bg-primary text-primary-foreground shadow-lg"
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                initial={{ y: 0 }}
                animate={{ y: [0, -2, 0] }}
                transition={{
                  y: { duration: 2, repeat: Infinity, ease: "easeInOut" },
                }}
              >
                <Plus className="w-6 h-6" />
              </motion.button>
            );
          }

          return (
            <Link
              key={item.href}
              href={item.href}
              className="relative flex flex-col items-center justify-center flex-1 h-full"
            >
              <motion.div
                className={cn(
                  "flex flex-col items-center gap-1 py-1",
                  isActive ? "text-primary" : "text-muted-foreground"
                )}
                whileTap={{ scale: 0.95 }}
              >
                <item.icon className="w-5 h-5" />
                <span className="text-[10px] font-medium">{item.label}</span>
              </motion.div>

              {/* Active indicator dot */}
              <AnimatePresence>
                {isActive && (
                  <motion.div
                    className="absolute -bottom-0.5 w-1 h-1 rounded-full bg-primary"
                    layoutId="mobile-nav-indicator"
                    initial={{ scale: 0 }}
                    animate={{ scale: 1 }}
                    exit={{ scale: 0 }}
                    transition={{ type: "spring", stiffness: 500, damping: 30 }}
                  />
                )}
              </AnimatePresence>
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
```

**Step 2: Create layout index.ts**

Create file `components/layout/index.ts`:

```typescript
/**
 * Layout Components Exports
 */

export * from "./sidebar";
export { MobileNav } from "./mobile-nav";
```

**Step 3: Commit**

```bash
git add components/layout/mobile-nav.tsx components/layout/index.ts
git commit -m "feat(layout): add mobile bottom navigation with FAB"
```

---

## Phase 4: Dashboard Components

### Task 14: Create Greeting Header

**Files:**
- Create: `components/dashboard/greeting-header.tsx`

**Step 1: Create greeting-header.tsx**

Create file `components/dashboard/greeting-header.tsx`:

```tsx
"use client";

/**
 * GreetingHeader - Time-based personalized greeting
 * Includes wallet pill and notification bell
 */

import { useMemo } from "react";
import { motion } from "framer-motion";
import { Bell, Wallet } from "lucide-react";
import { Button } from "@/components/ui/button";
import { fadeInUp, badgePop } from "@/lib/animations";
import { cn } from "@/lib/utils";

interface GreetingHeaderProps {
  userName: string;
  walletBalance?: number;
  notificationCount?: number;
  onNotificationClick?: () => void;
  onWalletClick?: () => void;
  className?: string;
}

function getGreeting(): { text: string; emoji: string } {
  const hour = new Date().getHours();

  if (hour >= 5 && hour < 12) {
    return { text: "Good morning", emoji: "🌅" };
  } else if (hour >= 12 && hour < 17) {
    return { text: "Good afternoon", emoji: "☀️" };
  } else if (hour >= 17 && hour < 21) {
    return { text: "Good evening", emoji: "🌆" };
  } else {
    return { text: "Good night", emoji: "🌙" };
  }
}

const motivationalSubtitles = [
  "Ready to crush it today?",
  "Let's make progress!",
  "Time to get things done!",
  "Another productive day ahead!",
  "Let's create something great!",
];

export function GreetingHeader({
  userName,
  walletBalance = 0,
  notificationCount = 0,
  onNotificationClick,
  onWalletClick,
  className,
}: GreetingHeaderProps) {
  const greeting = getGreeting();

  const subtitle = useMemo(() => {
    const index = new Date().getDate() % motivationalSubtitles.length;
    return motivationalSubtitles[index];
  }, []);

  const formattedBalance = new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency: "INR",
    maximumFractionDigits: 0,
  }).format(walletBalance);

  return (
    <motion.header
      className={cn(
        "flex items-center justify-between py-4",
        className
      )}
      variants={fadeInUp}
      initial="hidden"
      animate="visible"
    >
      {/* Greeting */}
      <div>
        <motion.h1
          className="text-2xl font-semibold text-foreground"
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: 0.1 }}
        >
          {greeting.text}, {userName}! {greeting.emoji}
        </motion.h1>
        <motion.p
          className="text-muted-foreground mt-0.5"
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: 0.2 }}
        >
          {subtitle}
        </motion.p>
      </div>

      {/* Actions */}
      <div className="flex items-center gap-2">
        {/* Notification Bell */}
        <motion.div
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.3 }}
        >
          <Button
            variant="ghost"
            size="icon"
            className="relative"
            onClick={onNotificationClick}
          >
            <motion.div
              animate={notificationCount > 0 ? { rotate: [0, -10, 10, -5, 5, 0] } : {}}
              transition={{ duration: 0.5, delay: 1 }}
            >
              <Bell className="h-5 w-5" />
            </motion.div>

            {notificationCount > 0 && (
              <motion.span
                className="absolute -top-1 -right-1 flex h-5 w-5 items-center justify-center rounded-full bg-primary text-[10px] font-medium text-primary-foreground"
                variants={badgePop}
                initial="hidden"
                animate="visible"
              >
                {notificationCount > 9 ? "9+" : notificationCount}
              </motion.span>
            )}
          </Button>
        </motion.div>

        {/* Wallet Pill */}
        <motion.div
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.4 }}
        >
          <Button
            variant="outline"
            size="sm"
            className="gap-2 rounded-full px-4"
            onClick={onWalletClick}
          >
            <Wallet className="h-4 w-4 text-primary" />
            <span className="font-medium">{formattedBalance}</span>
          </Button>
        </motion.div>
      </div>
    </motion.header>
  );
}
```

**Step 2: Update dashboard index.ts**

Update `components/dashboard/index.ts` to include new export:

```typescript
// Add to existing exports
export { GreetingHeader } from "./greeting-header";
```

**Step 3: Commit**

```bash
git add components/dashboard/greeting-header.tsx components/dashboard/index.ts
git commit -m "feat(dashboard): add animated GreetingHeader with time-based greeting"
```

---

### Task 15: Create Quick Actions Grid

**Files:**
- Create: `components/dashboard/quick-actions.tsx`

**Step 1: Create quick-actions.tsx**

Create file `components/dashboard/quick-actions.tsx`:

```tsx
"use client";

/**
 * QuickActions - Service action cards grid
 * Animated cards for New Project, Proofreading, AI Check, Expert Opinion
 */

import { useRouter } from "next/navigation";
import { motion } from "framer-motion";
import { FileText, Glasses, Bot, Lightbulb } from "lucide-react";
import { Card } from "@/components/ui/card";
import { staggerContainer, staggerItem, iconBounce } from "@/lib/animations";
import { cn } from "@/lib/utils";
import { LucideIcon } from "lucide-react";

interface QuickAction {
  id: string;
  icon: LucideIcon;
  label: string;
  description: string;
  href: string;
  color: string;
  bgColor: string;
}

const quickActions: QuickAction[] = [
  {
    id: "new-project",
    icon: FileText,
    label: "New Project",
    description: "Get expert help",
    href: "/projects/new?type=project",
    color: "text-primary",
    bgColor: "bg-primary/10",
  },
  {
    id: "proofread",
    icon: Glasses,
    label: "Proofread",
    description: "Polish your draft",
    href: "/projects/new?type=proofreading",
    color: "text-info",
    bgColor: "bg-info/10",
  },
  {
    id: "ai-check",
    icon: Bot,
    label: "AI Check",
    description: "Verify content",
    href: "/projects/new?type=report",
    color: "text-accent-purple",
    bgColor: "bg-accent-purple/10",
  },
  {
    id: "expert",
    icon: Lightbulb,
    label: "Ask Expert",
    description: "Free consultation",
    href: "/projects/new?type=consultation",
    color: "text-warning",
    bgColor: "bg-warning/10",
  },
];

interface QuickActionsProps {
  className?: string;
}

export function QuickActions({ className }: QuickActionsProps) {
  const router = useRouter();

  return (
    <section className={className}>
      <motion.h2
        className="text-lg font-semibold text-foreground mb-4"
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
      >
        Quick Actions
      </motion.h2>

      <motion.div
        className="grid grid-cols-2 md:grid-cols-4 gap-4"
        variants={staggerContainer}
        initial="hidden"
        animate="visible"
      >
        {quickActions.map((action) => (
          <motion.div key={action.id} variants={staggerItem}>
            <Card
              variant="interactive"
              animated
              className="p-4 h-full"
              onClick={() => router.push(action.href)}
            >
              <motion.div
                className={cn(
                  "w-12 h-12 rounded-[var(--radius-md)] flex items-center justify-center mb-3",
                  action.bgColor
                )}
                variants={iconBounce}
                whileHover="hover"
              >
                <action.icon className={cn("w-6 h-6", action.color)} />
              </motion.div>

              <h3 className="font-medium text-foreground">{action.label}</h3>
              <p className="text-sm text-muted-foreground mt-0.5">
                {action.description}
              </p>
            </Card>
          </motion.div>
        ))}
      </motion.div>
    </section>
  );
}
```

**Step 2: Update dashboard index.ts**

Add to `components/dashboard/index.ts`:

```typescript
export { QuickActions } from "./quick-actions";
```

**Step 3: Commit**

```bash
git add components/dashboard/quick-actions.tsx components/dashboard/index.ts
git commit -m "feat(dashboard): add QuickActions grid with animated service cards"
```

---

### Task 16: Create Project Card Component

**Files:**
- Create: `components/dashboard/project-card-new.tsx`

**Step 1: Create project-card-new.tsx**

Create file `components/dashboard/project-card-new.tsx`:

```tsx
"use client";

/**
 * ProjectCardNew - Redesigned project card with status-based styling
 * Includes progress bar, deadline, and contextual actions
 */

import { useRouter } from "next/navigation";
import { motion } from "framer-motion";
import { Clock, FileText, Eye, CreditCard, CheckCircle } from "lucide-react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { cardHover } from "@/lib/animations";
import { cn } from "@/lib/utils";
import { formatDistanceToNow } from "date-fns";

type ProjectStatus =
  | "analyzing"
  | "payment_pending"
  | "in_progress"
  | "for_review"
  | "completed";

interface ProjectCardNewProps {
  id: string;
  projectNumber: string;
  title: string;
  subject: string;
  status: ProjectStatus;
  progress?: number;
  deadline?: Date;
  price?: number;
  autoApproveAt?: Date;
  className?: string;
}

const statusConfig: Record<ProjectStatus, {
  label: string;
  color: string;
  borderColor: string;
  icon: typeof Clock;
}> = {
  analyzing: {
    label: "Analyzing",
    color: "text-warning",
    borderColor: "border-l-[hsl(var(--warning))]",
    icon: Clock,
  },
  payment_pending: {
    label: "Payment Pending",
    color: "text-orange-500",
    borderColor: "border-l-orange-500",
    icon: CreditCard,
  },
  in_progress: {
    label: "In Progress",
    color: "text-info",
    borderColor: "border-l-[hsl(var(--info))]",
    icon: FileText,
  },
  for_review: {
    label: "For Review",
    color: "text-success",
    borderColor: "border-l-[hsl(var(--success))]",
    icon: Eye,
  },
  completed: {
    label: "Completed",
    color: "text-muted-foreground",
    borderColor: "border-l-muted-foreground",
    icon: CheckCircle,
  },
};

export function ProjectCardNew({
  id,
  projectNumber,
  title,
  subject,
  status,
  progress = 0,
  deadline,
  price,
  autoApproveAt,
  className,
}: ProjectCardNewProps) {
  const router = useRouter();
  const config = statusConfig[status];
  const StatusIcon = config.icon;

  const deadlineText = deadline
    ? formatDistanceToNow(deadline, { addSuffix: true })
    : null;

  const autoApproveText = autoApproveAt
    ? formatDistanceToNow(autoApproveAt, { addSuffix: false })
    : null;

  const formattedPrice = price
    ? new Intl.NumberFormat("en-IN", {
        style: "currency",
        currency: "INR",
        maximumFractionDigits: 0,
      }).format(price)
    : null;

  const getActionButton = () => {
    switch (status) {
      case "payment_pending":
        return (
          <Button size="sm" className="gap-1">
            Pay {formattedPrice}
          </Button>
        );
      case "for_review":
        return (
          <Button size="sm" variant="success" className="gap-1">
            Review Now
          </Button>
        );
      case "in_progress":
        return (
          <Button size="sm" variant="outline" className="gap-1">
            <Eye className="w-3 h-3" /> Track Live
          </Button>
        );
      default:
        return null;
    }
  };

  return (
    <motion.div
      variants={cardHover}
      initial="rest"
      whileHover="hover"
      whileTap="tap"
    >
      <Card
        className={cn(
          "border-l-4 p-4 cursor-pointer",
          config.borderColor,
          className
        )}
        onClick={() => router.push(`/project/${id}`)}
      >
        {/* Header */}
        <div className="flex items-start justify-between mb-3">
          <div className="flex items-center gap-2">
            <StatusIcon className={cn("w-4 h-4", config.color)} />
            <span className={cn("text-xs font-medium", config.color)}>
              {config.label}
            </span>
          </div>
          <span className="text-xs text-muted-foreground font-mono">
            #{projectNumber}
          </span>
        </div>

        {/* Title & Subject */}
        <h3 className="font-semibold text-foreground mb-1 line-clamp-1">
          {title}
        </h3>
        <p className="text-sm text-muted-foreground mb-3">{subject}</p>

        {/* Progress (for in_progress) */}
        {status === "in_progress" && (
          <div className="mb-3">
            <div className="flex justify-between text-xs text-muted-foreground mb-1">
              <span>Progress</span>
              <motion.span
                key={progress}
                initial={{ scale: 1.2 }}
                animate={{ scale: 1 }}
              >
                {progress}%
              </motion.span>
            </div>
            <Progress value={progress} className="h-1.5" />
          </div>
        )}

        {/* Auto-approve timer (for for_review) */}
        {status === "for_review" && autoApproveText && (
          <p className="text-xs text-muted-foreground mb-3">
            ⏰ Auto-approves in {autoApproveText}
          </p>
        )}

        {/* Footer */}
        <div className="flex items-center justify-between pt-2 border-t border-border/50">
          {deadlineText && (
            <span className="text-xs text-muted-foreground flex items-center gap-1">
              <Clock className="w-3 h-3" />
              Due {deadlineText}
            </span>
          )}
          {getActionButton()}
        </div>
      </Card>
    </motion.div>
  );
}
```

**Step 2: Update dashboard index.ts**

Add to `components/dashboard/index.ts`:

```typescript
export { ProjectCardNew } from "./project-card-new";
```

**Step 3: Commit**

```bash
git add components/dashboard/project-card-new.tsx components/dashboard/index.ts
git commit -m "feat(dashboard): add redesigned ProjectCard with status-based styling"
```

---

## Phase 5: Integration & Polish

### Task 17: Integrate New Components into Home Page

**Files:**
- Modify: `app/(dashboard)/home/page.tsx`

**Step 1: Update home page to use new components**

Update `app/(dashboard)/home/page.tsx`:

```tsx
import { GreetingHeader } from "@/components/dashboard/greeting-header";
import { BannerCarousel } from "@/components/dashboard/banner-carousel";
import { QuickActions } from "@/components/dashboard/quick-actions";
import { RecentProjects } from "@/components/dashboard/recent-projects";
import { CampusPulse } from "@/components/dashboard/campus-pulse";
import { FadeIn } from "@/components/animations";

/**
 * Dashboard home page - Redesigned with new design system
 * Includes animated greeting, quick actions, and recent projects
 */
export default function DashboardHomePage() {
  // TODO: Get user data from auth context
  const userName = "Om";
  const walletBalance = 240;
  const notificationCount = 3;

  return (
    <div className="flex flex-col min-h-full bg-[hsl(var(--background))]">
      {/* Greeting Header */}
      <div className="px-4 lg:px-6">
        <GreetingHeader
          userName={userName}
          walletBalance={walletBalance}
          notificationCount={notificationCount}
          onNotificationClick={() => console.log("notifications")}
          onWalletClick={() => console.log("wallet")}
        />
      </div>

      {/* Content */}
      <div className="flex-1 space-y-8 p-4 lg:p-6">
        {/* Banner Carousel */}
        <FadeIn delay={0.1}>
          <section>
            <BannerCarousel />
          </section>
        </FadeIn>

        {/* Quick Actions */}
        <FadeIn delay={0.2}>
          <QuickActions />
        </FadeIn>

        {/* Recent Projects */}
        <FadeIn delay={0.3}>
          <RecentProjects />
        </FadeIn>

        {/* Campus Pulse */}
        <FadeIn delay={0.4}>
          <CampusPulse />
        </FadeIn>
      </div>
    </div>
  );
}
```

**Step 2: Verify build**

```bash
npm run build
```

Expected: Build succeeds

**Step 3: Commit**

```bash
git add app/(dashboard)/home/page.tsx
git commit -m "feat(home): integrate new design system components"
```

---

### Task 18: Add Page Transition Wrapper

**Files:**
- Create: `components/animations/page-transition.tsx`
- Modify: `app/(dashboard)/layout.tsx`

**Step 1: Create page-transition.tsx**

Create file `components/animations/page-transition.tsx`:

```tsx
"use client";

/**
 * PageTransition - Animated page wrapper for route transitions
 */

import { motion, AnimatePresence } from "framer-motion";
import { usePathname } from "next/navigation";
import { pageTransition } from "@/lib/animations";

interface PageTransitionProps {
  children: React.ReactNode;
}

export function PageTransition({ children }: PageTransitionProps) {
  const pathname = usePathname();

  return (
    <AnimatePresence mode="wait">
      <motion.div
        key={pathname}
        variants={pageTransition}
        initial="hidden"
        animate="visible"
        exit="exit"
        className="flex-1"
      >
        {children}
      </motion.div>
    </AnimatePresence>
  );
}
```

**Step 2: Update animations index.ts**

Add to `components/animations/index.ts`:

```typescript
export { PageTransition } from "./page-transition";
```

**Step 3: Commit**

```bash
git add components/animations/page-transition.tsx components/animations/index.ts
git commit -m "feat(animations): add PageTransition wrapper for route animations"
```

---

### Task 19: Create Confetti Celebration Component

**Files:**
- Create: `components/animations/confetti.tsx`

**Step 1: Install canvas-confetti (if not installed)**

Check package.json - canvas-confetti is already installed.

**Step 2: Create confetti.tsx**

Create file `components/animations/confetti.tsx`:

```tsx
"use client";

/**
 * Confetti - Celebration animation trigger
 * Use for success moments like project submission
 */

import { useCallback } from "react";
import confetti from "canvas-confetti";

interface ConfettiOptions {
  /** Spread angle in degrees */
  spread?: number;
  /** Number of particles */
  particleCount?: number;
  /** Origin point { x: 0-1, y: 0-1 } */
  origin?: { x: number; y: number };
  /** Custom colors array */
  colors?: string[];
}

const defaultColors = [
  "#FF5C35", // Primary coral
  "#00C48C", // Success mint
  "#FFB800", // Warning gold
  "#5B8DEF", // Info blue
  "#9B59B6", // Accent purple
];

export function useConfetti() {
  const fire = useCallback((options: ConfettiOptions = {}) => {
    const {
      spread = 70,
      particleCount = 100,
      origin = { x: 0.5, y: 0.6 },
      colors = defaultColors,
    } = options;

    confetti({
      spread,
      particleCount,
      origin,
      colors,
      disableForReducedMotion: true,
    });
  }, []);

  const burst = useCallback(() => {
    // Fire multiple bursts for more impact
    const count = 200;
    const defaults = {
      origin: { y: 0.7 },
      colors: defaultColors,
      disableForReducedMotion: true,
    };

    function fireConfetti(particleRatio: number, opts: confetti.Options) {
      confetti({
        ...defaults,
        ...opts,
        particleCount: Math.floor(count * particleRatio),
      });
    }

    fireConfetti(0.25, { spread: 26, startVelocity: 55 });
    fireConfetti(0.2, { spread: 60 });
    fireConfetti(0.35, { spread: 100, decay: 0.91, scalar: 0.8 });
    fireConfetti(0.1, { spread: 120, startVelocity: 25, decay: 0.92, scalar: 1.2 });
    fireConfetti(0.1, { spread: 120, startVelocity: 45 });
  }, []);

  const sides = useCallback(() => {
    // Fire from both sides
    const end = Date.now() + 1000;
    const colors = defaultColors;

    (function frame() {
      confetti({
        particleCount: 2,
        angle: 60,
        spread: 55,
        origin: { x: 0 },
        colors,
        disableForReducedMotion: true,
      });
      confetti({
        particleCount: 2,
        angle: 120,
        spread: 55,
        origin: { x: 1 },
        colors,
        disableForReducedMotion: true,
      });

      if (Date.now() < end) {
        requestAnimationFrame(frame);
      }
    })();
  }, []);

  return { fire, burst, sides };
}

/**
 * ConfettiButton - Button that triggers confetti on click
 */
interface ConfettiButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  children: React.ReactNode;
  confettiType?: "fire" | "burst" | "sides";
}

export function ConfettiButton({
  children,
  confettiType = "burst",
  onClick,
  ...props
}: ConfettiButtonProps) {
  const { fire, burst, sides } = useConfetti();

  const handleClick = (e: React.MouseEvent<HTMLButtonElement>) => {
    switch (confettiType) {
      case "fire":
        fire();
        break;
      case "burst":
        burst();
        break;
      case "sides":
        sides();
        break;
    }
    onClick?.(e);
  };

  return (
    <button onClick={handleClick} {...props}>
      {children}
    </button>
  );
}
```

**Step 3: Update animations index.ts**

Add to `components/animations/index.ts`:

```typescript
export { useConfetti, ConfettiButton } from "./confetti";
```

**Step 4: Commit**

```bash
git add components/animations/confetti.tsx components/animations/index.ts
git commit -m "feat(animations): add confetti celebration component and hook"
```

---

### Task 20: Final Build & Verification

**Files:**
- None (verification only)

**Step 1: Run full build**

```bash
npm run build
```

Expected: Build completes successfully

**Step 2: Run linter**

```bash
npm run lint
```

Expected: No errors (warnings acceptable)

**Step 3: Run type check**

```bash
npx tsc --noEmit
```

Expected: No type errors

**Step 4: Create summary commit**

```bash
git add -A
git commit -m "feat(design-system): complete Phase 1-5 UI redesign foundation

- Color tokens: warm cream + vibrant accent pops
- Spacing & shadow tokens with CSS custom properties
- Framer Motion animation variants library
- Motion component wrappers (FadeIn, StaggerContainer)
- Animated Button with loading state
- Animated Card with variants (elevated, interactive, highlighted)
- EmptyState with OpenPeeps illustrations
- Skeleton with shimmer animation
- Sidebar components (SidebarItem, SidebarProfile)
- Mobile bottom navigation with FAB
- GreetingHeader with time-based greetings
- QuickActions grid with animated cards
- ProjectCardNew with status-based styling
- PageTransition wrapper
- Confetti celebration hook

Ready for Phase 2: Page-by-page implementation"
```

---

## Verification Checklist

After completing all tasks, verify:

- [ ] `npm run build` succeeds
- [ ] `npm run lint` passes
- [ ] No TypeScript errors
- [ ] Colors display correctly (warm cream background)
- [ ] Animations work (hover cards, click buttons)
- [ ] Mobile navigation renders on small screens
- [ ] All commits are clean and atomic

---

## Next Steps

After this plan is complete:

1. **Download OpenPeeps SVGs** from https://www.openpeeps.com/
2. **Download Lottie animations** from LottieFiles
3. **Implement remaining pages** using the new design system
4. **Add dark mode support** using the dark variant tokens
5. **Mobile testing** on actual devices

---

*Plan created: January 2, 2026*
*Estimated completion: 14 days*
*Tasks: 20*
