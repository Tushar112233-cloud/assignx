/**
 * @fileoverview Animation constants for landing page
 *
 * Centralized animation timing, easing, and configuration values
 * used across all landing page components.
 */

/**
 * Custom easing curve - smooth deceleration
 * cubic-bezier(0.16, 1, 0.3, 1)
 */
export const ASSIGNX_EASE = [0.16, 1, 0.3, 1] as const;

/**
 * Easing as CSS string for GSAP/CSS animations
 */
export const ASSIGNX_EASE_CSS = "cubic-bezier(0.16, 1, 0.3, 1)";

/**
 * Standard animation durations
 */
export const DURATIONS = {
  /** Quick micro-interactions (0.3s) */
  fast: 0.3,
  /** Standard transitions (0.5s) */
  normal: 0.5,
  /** Entrance animations (0.6s) */
  entrance: 0.6,
  /** Slow, dramatic reveals (0.8s) */
  slow: 0.8,
  /** Dashboard slide animation (0.8s) */
  dashboard: 0.8,
} as const;

/**
 * Stagger delays for sequential animations
 */
export const STAGGER = {
  /** Fast stagger for pills/badges (0.05s) */
  fast: 0.05,
  /** Standard stagger for content (0.1s) */
  normal: 0.1,
  /** Slow stagger for dramatic reveals (0.15s) */
  slow: 0.15,
} as const;

/**
 * Hero section animation delays (in seconds)
 */
export const HERO_DELAYS = {
  badge: 0,
  headline1: 0.1,
  headline2: 0.2,
  headline3: 0.3,
  subheadline: 0.4,
  emailForm: 0.5,
  dashboard: 0.3,
  floatingCard1: 0.7,
  floatingCard2: 0.9,
} as const;

/**
 * Viewport trigger threshold for scroll animations
 */
export const VIEWPORT_THRESHOLD = 0.7;

/**
 * Maximum total entrance animation duration
 */
export const MAX_ENTRANCE_DURATION = 1.5;

/**
 * Floating animation configuration
 */
export const FLOATING_CONFIG = {
  /** Oscillation amplitude in pixels */
  amplitude: 8,
  /** Full cycle duration in seconds */
  duration: 4,
  /** Easing type */
  ease: "easeInOut",
} as const;

/**
 * Parallax distances for different layers
 */
export const PARALLAX_DISTANCES = {
  /** Foreground elements move more */
  foreground: 100,
  /** Midground elements */
  midground: 50,
  /** Background elements move less */
  background: 25,
} as const;

/**
 * Spring configuration for smooth physics-based animations
 */
export const SPRING_CONFIG = {
  /** Stiffness - higher = snappier */
  stiffness: 100,
  /** Damping - higher = less oscillation */
  damping: 30,
  /** Rest delta - threshold for animation to "settle" */
  restDelta: 0.001,
} as const;
