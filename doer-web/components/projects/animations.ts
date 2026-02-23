/**
 * Animation utilities for projects components
 * Consistent animation variants and utilities for smooth 60fps animations
 * @module components/projects/animations
 */

import type { Variants, Transition } from 'framer-motion'

/**
 * Spring physics configuration for natural motion
 */
export const springConfig: Transition = {
  type: 'spring',
  stiffness: 260,
  damping: 20,
}

export const fastSpring: Transition = {
  type: 'spring',
  stiffness: 400,
  damping: 25,
}

export const smoothSpring: Transition = {
  type: 'spring',
  stiffness: 200,
  damping: 20,
}

/**
 * Fade in animation from bottom
 */
export const fadeInUp: Variants = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0, transition: springConfig },
  exit: { opacity: 0, y: -20, transition: { duration: 0.2 } },
}

/**
 * Fade in animation from top
 */
export const fadeInDown: Variants = {
  initial: { opacity: 0, y: -20 },
  animate: { opacity: 1, y: 0, transition: springConfig },
  exit: { opacity: 0, y: 20, transition: { duration: 0.2 } },
}

/**
 * Fade in animation from left
 */
export const fadeInLeft: Variants = {
  initial: { opacity: 0, x: -20 },
  animate: { opacity: 1, x: 0, transition: springConfig },
  exit: { opacity: 0, x: 20, transition: { duration: 0.2 } },
}

/**
 * Fade in animation from right
 */
export const fadeInRight: Variants = {
  initial: { opacity: 0, x: 20 },
  animate: { opacity: 1, x: 0, transition: springConfig },
  exit: { opacity: 0, x: -20, transition: { duration: 0.2 } },
}

/**
 * Scale in animation
 */
export const scaleIn: Variants = {
  initial: { opacity: 0, scale: 0.95 },
  animate: { opacity: 1, scale: 1, transition: springConfig },
  exit: { opacity: 0, scale: 0.95, transition: { duration: 0.2 } },
}

/**
 * Stagger container for list animations
 */
export const staggerContainer: Variants = {
  initial: { opacity: 0 },
  animate: {
    opacity: 1,
    transition: {
      staggerChildren: 0.05,
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
}

/**
 * Fast stagger container for quick animations
 */
export const fastStagger: Variants = {
  initial: { opacity: 0 },
  animate: {
    opacity: 1,
    transition: {
      staggerChildren: 0.03,
      delayChildren: 0.05,
    },
  },
}

/**
 * Card animation variant
 */
export const cardVariant: Variants = {
  initial: {
    opacity: 0,
    y: 20,
    scale: 0.95,
  },
  animate: {
    opacity: 1,
    y: 0,
    scale: 1,
    transition: springConfig,
  },
  exit: {
    opacity: 0,
    scale: 0.95,
    y: -10,
    transition: { duration: 0.2 },
  },
}

/**
 * Hover lift effect for cards
 */
export const hoverLift = {
  whileHover: {
    y: -4,
    boxShadow: '0 20px 40px rgba(0, 0, 0, 0.1)',
    transition: { duration: 0.2 },
  },
  whileTap: { scale: 0.98 },
}

/**
 * Subtle hover effect
 */
export const subtleHover = {
  whileHover: {
    y: -2,
    transition: { duration: 0.2 },
  },
  whileTap: { scale: 0.99 },
}

/**
 * Scale hover effect for buttons
 */
export const scaleHover = {
  whileHover: { scale: 1.05, transition: { duration: 0.2 } },
  whileTap: { scale: 0.95 },
}

/**
 * Shimmer loading effect animation
 */
export const shimmerAnimation: Variants = {
  initial: { backgroundPosition: '-200% 0' },
  animate: {
    backgroundPosition: '200% 0',
    transition: {
      duration: 2,
      ease: 'linear',
      repeat: Infinity,
    },
  },
}

/**
 * Pulse animation for status indicators
 */
export const pulseAnimation = {
  animate: {
    scale: [1, 1.2, 1],
    opacity: [1, 0.7, 1],
  },
  transition: {
    duration: 2,
    repeat: Infinity,
    ease: 'easeInOut',
  },
}

/**
 * Progress bar fill animation
 */
export const progressFill = (targetWidth: number): Variants => ({
  initial: { width: 0 },
  animate: {
    width: `${targetWidth}%`,
    transition: {
      duration: 1,
      ease: 'easeOut',
    },
  },
})

/**
 * Count up animation for numbers
 */
export const countUp = {
  initial: { opacity: 0, scale: 0.8 },
  animate: {
    opacity: 1,
    scale: 1,
    transition: {
      type: 'spring',
      stiffness: 200,
      damping: 15,
    },
  },
}

/**
 * Slide up reveal animation
 */
export const slideUpReveal: Variants = {
  initial: { y: 50, opacity: 0 },
  animate: {
    y: 0,
    opacity: 1,
    transition: {
      type: 'spring',
      stiffness: 100,
      damping: 15,
    },
  },
}

/**
 * Rotate animation for refresh buttons
 */
export const rotateOnHover = {
  whileHover: {
    rotate: 180,
    transition: { duration: 0.3 },
  },
}

/**
 * Bounce animation for empty states
 */
export const bounceAnimation = {
  animate: {
    y: [0, -10, 0],
  },
  transition: {
    duration: 2,
    ease: 'easeInOut',
    repeat: Infinity,
  },
}

/**
 * Floating animation for icons
 */
export const floatingAnimation = {
  animate: {
    y: [0, -15, 0],
    rotate: [0, 5, 0, -5, 0],
  },
  transition: {
    duration: 3,
    ease: 'easeInOut',
    repeat: Infinity,
  },
}

/**
 * Gradient shimmer animation
 */
export const gradientShimmer = {
  animate: {
    backgroundPosition: ['0% 50%', '100% 50%', '0% 50%'],
  },
  transition: {
    duration: 3,
    ease: 'easeInOut',
    repeat: Infinity,
  },
}

/**
 * Page transition variants
 */
export const pageTransition: Variants = {
  initial: { opacity: 0, y: 20 },
  animate: {
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.4,
      ease: 'easeOut',
    },
  },
  exit: {
    opacity: 0,
    y: -20,
    transition: {
      duration: 0.3,
      ease: 'easeIn',
    },
  },
}

/**
 * Modal animation variants
 */
export const modalVariants: Variants = {
  initial: {
    opacity: 0,
    scale: 0.95,
    y: 20,
  },
  animate: {
    opacity: 1,
    scale: 1,
    y: 0,
    transition: {
      type: 'spring',
      stiffness: 300,
      damping: 30,
    },
  },
  exit: {
    opacity: 0,
    scale: 0.95,
    y: 20,
    transition: {
      duration: 0.2,
    },
  },
}

/**
 * Backdrop animation
 */
export const backdropVariants: Variants = {
  initial: { opacity: 0 },
  animate: { opacity: 1 },
  exit: { opacity: 0 },
}

/**
 * Tab switching animation
 */
export const tabContentVariants: Variants = {
  initial: {
    opacity: 0,
    x: -20,
  },
  animate: {
    opacity: 1,
    x: 0,
    transition: {
      duration: 0.2,
    },
  },
  exit: {
    opacity: 0,
    x: 20,
    transition: {
      duration: 0.2,
    },
  },
}

/**
 * Skeleton shimmer effect styles
 */
export const skeletonShimmer = {
  backgroundImage:
    'linear-gradient(90deg, transparent 0%, rgba(255, 255, 255, 0.8) 50%, transparent 100%)',
  backgroundSize: '200% 100%',
  animation: 'shimmer 2s infinite',
}

/**
 * Keyframes for CSS animations
 */
export const keyframes = `
  @keyframes shimmer {
    0% {
      background-position: -200% 0;
    }
    100% {
      background-position: 200% 0;
    }
  }

  @keyframes pulse-ring {
    0% {
      transform: scale(1);
      opacity: 1;
    }
    100% {
      transform: scale(1.5);
      opacity: 0;
    }
  }

  @keyframes float {
    0%, 100% {
      transform: translateY(0);
    }
    50% {
      transform: translateY(-10px);
    }
  }

  @keyframes spin-slow {
    from {
      transform: rotate(0deg);
    }
    to {
      transform: rotate(360deg);
    }
  }
`

/**
 * Performance optimization utility
 * Forces hardware acceleration for smooth animations
 */
export const willChange = {
  willChange: 'transform, opacity',
}

/**
 * Reduced motion variant for accessibility
 */
export const reducedMotion: Variants = {
  initial: { opacity: 0 },
  animate: { opacity: 1, transition: { duration: 0.2 } },
  exit: { opacity: 0, transition: { duration: 0.2 } },
}
