/**
 * Framer Motion Animation Variants
 * Reusable animation configurations for consistent micro-interactions
 */

import { Variants, Transition } from "framer-motion";

// ============================================
// EASING CURVES
// ============================================

export const easings = {
  smooth: [0.25, 0.1, 0.25, 1] as const,
  bounce: [0.68, -0.55, 0.265, 1.55] as const,
  snappy: [0.175, 0.885, 0.32, 1.1] as const,
  easeOut: [0, 0, 0.2, 1] as const,
  easeIn: [0.4, 0, 1, 1] as const,
};

export const durations = {
  fast: 0.15,
  normal: 0.25,
  slow: 0.4,
  stagger: 0.05,
  page: 0.3,
};

export const springs = {
  gentle: { type: "spring", stiffness: 120, damping: 14 } as Transition,
  bouncy: { type: "spring", stiffness: 300, damping: 15 } as Transition,
  snappy: { type: "spring", stiffness: 400, damping: 25 } as Transition,
  stiff: { type: "spring", stiffness: 500, damping: 30 } as Transition,
};

// ============================================
// FADE VARIANTS
// ============================================

export const fadeIn: Variants = {
  hidden: { opacity: 0 },
  visible: { opacity: 1, transition: { duration: durations.normal } },
  exit: { opacity: 0, transition: { duration: durations.fast } },
};

export const fadeInUp: Variants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0, transition: { duration: durations.normal, ease: easings.smooth } },
  exit: { opacity: 0, y: -10, transition: { duration: durations.fast } },
};

export const fadeInDown: Variants = {
  hidden: { opacity: 0, y: -20 },
  visible: { opacity: 1, y: 0, transition: { duration: durations.normal, ease: easings.smooth } },
  exit: { opacity: 0, y: 10, transition: { duration: durations.fast } },
};

export const fadeInScale: Variants = {
  hidden: { opacity: 0, scale: 0.95 },
  visible: { opacity: 1, scale: 1, transition: { duration: durations.normal, ease: easings.smooth } },
  exit: { opacity: 0, scale: 0.95, transition: { duration: durations.fast } },
};

// ============================================
// STAGGER CONTAINERS
// ============================================

export const staggerContainer: Variants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: { staggerChildren: durations.stagger, delayChildren: 0.1 },
  },
  exit: {
    opacity: 0,
    transition: { staggerChildren: 0.03, staggerDirection: -1 },
  },
};

export const staggerItem: Variants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0, transition: { duration: durations.normal, ease: easings.smooth } },
  exit: { opacity: 0, y: -10, transition: { duration: durations.fast } },
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
  tap: { y: -2, scale: 0.99, transition: { duration: 0.1 } },
};

// ============================================
// BUTTON ANIMATIONS
// ============================================

export const buttonTap: Variants = {
  rest: { scale: 1 },
  hover: { scale: 1.02, transition: { duration: durations.fast, ease: easings.easeOut } },
  tap: { scale: 0.97, transition: { duration: 0.1 } },
};

// ============================================
// MODAL ANIMATIONS
// ============================================

export const modalOverlay: Variants = {
  hidden: { opacity: 0 },
  visible: { opacity: 1, transition: { duration: durations.fast } },
  exit: { opacity: 0, transition: { duration: durations.fast, delay: 0.1 } },
};

export const modalContent: Variants = {
  hidden: { opacity: 0, scale: 0.95, y: 10 },
  visible: { opacity: 1, scale: 1, y: 0, transition: springs.snappy },
  exit: { opacity: 0, scale: 0.95, y: 10, transition: { duration: durations.fast } },
};

export const sheetContent: Variants = {
  hidden: { y: "100%", opacity: 0.5 },
  visible: { y: 0, opacity: 1, transition: springs.snappy },
  exit: { y: "100%", opacity: 0.5, transition: { duration: durations.normal, ease: easings.easeIn } },
};

// ============================================
// PAGE TRANSITIONS
// ============================================

export const pageTransition: Variants = {
  hidden: { opacity: 0, y: 12 },
  visible: {
    opacity: 1,
    y: 0,
    transition: { duration: durations.page, ease: easings.smooth, when: "beforeChildren" },
  },
  exit: { opacity: 0, transition: { duration: durations.fast } },
};

// ============================================
// SIDEBAR ANIMATIONS
// ============================================

export const sidebarExpand: Variants = {
  collapsed: { width: 72 },
  expanded: { width: 260, transition: springs.snappy },
};

export const sidebarActiveIndicator: Variants = {
  inactive: { width: 0, opacity: 0 },
  active: { width: 4, opacity: 1, transition: springs.bouncy },
};

// ============================================
// ICON ANIMATIONS
// ============================================

export const iconWiggle: Variants = {
  rest: { rotate: 0 },
  hover: { rotate: [0, -10, 10, -5, 5, 0], transition: { duration: 0.5 } },
};

export const iconBounce: Variants = {
  rest: { y: 0 },
  hover: { y: [0, -4, 0], transition: { duration: 0.3, ease: easings.bounce } },
};

// ============================================
// NOTIFICATION ANIMATIONS
// ============================================

export const toastSlideIn: Variants = {
  hidden: { opacity: 0, x: 100, scale: 0.9 },
  visible: { opacity: 1, x: 0, scale: 1, transition: springs.bouncy },
  exit: { opacity: 0, x: 100, scale: 0.9, transition: { duration: durations.fast } },
};

export const badgePop: Variants = {
  hidden: { scale: 0, opacity: 0 },
  visible: { scale: 1, opacity: 1, transition: springs.bouncy },
  exit: { scale: 0, opacity: 0, transition: { duration: durations.fast } },
};

// ============================================
// CELEBRATION ANIMATIONS
// ============================================

export const checkmarkDraw: Variants = {
  hidden: { pathLength: 0, opacity: 0 },
  visible: {
    pathLength: 1,
    opacity: 1,
    transition: { pathLength: { duration: 0.4, ease: "easeOut" }, opacity: { duration: 0.2 } },
  },
};

export const celebrationPop: Variants = {
  hidden: { scale: 0, rotate: -180 },
  visible: { scale: 1, rotate: 0, transition: springs.bouncy },
};
