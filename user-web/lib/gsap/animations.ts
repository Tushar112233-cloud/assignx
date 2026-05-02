/**
 * GSAP Animation Utilities
 * Reusable animation configurations for landing page
 */

import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";

// Register plugins
if (typeof window !== "undefined") {
  gsap.registerPlugin(ScrollTrigger);
}

// ============================================
// EASING CURVES
// ============================================

export const easings = {
  // Smooth exponential ease
  smooth: "power2.out",
  // Snappy ease for UI elements
  snappy: "power3.out",
  // Bouncy ease for playful elements
  bouncy: "back.out(1.7)",
  // Elastic for attention-grabbing
  elastic: "elastic.out(1, 0.5)",
  // Smooth in-out for transitions
  inOut: "power2.inOut",
  // Custom bezier for premium feel
  premium: "expo.out",
} as const;

// ============================================
// TEXT ANIMATIONS
// ============================================

/**
 * Split text into spans for character animation
 */
export function splitTextToChars(element: HTMLElement): HTMLSpanElement[] {
  const text = element.textContent || "";
  element.textContent = "";

  return text.split("").map((char) => {
    const span = document.createElement("span");
    span.textContent = char === " " ? "\u00A0" : char;
    span.style.display = "inline-block";
    element.appendChild(span);
    return span;
  });
}

/**
 * Split text into words for word animation
 */
export function splitTextToWords(element: HTMLElement): HTMLSpanElement[] {
  const text = element.textContent || "";
  element.textContent = "";

  return text.split(" ").map((word, index, array) => {
    const span = document.createElement("span");
    span.textContent = word;
    span.style.display = "inline-block";
    span.style.marginRight = index < array.length - 1 ? "0.25em" : "0";
    element.appendChild(span);
    return span;
  });
}

/**
 * Split text into lines for line animation
 */
export function splitTextToLines(element: HTMLElement): HTMLDivElement[] {
  const text = element.innerHTML;
  element.innerHTML = "";

  // Simple line split based on <br> or manual splits
  const lines = text.split(/<br\s*\/?>/i);

  return lines.map((line) => {
    const div = document.createElement("div");
    div.innerHTML = line.trim();
    div.style.overflow = "hidden";
    element.appendChild(div);
    return div;
  });
}

// ============================================
// SCROLL-TRIGGERED ANIMATIONS
// ============================================

/**
 * Fade in from bottom on scroll
 */
export function fadeInUp(
  element: gsap.TweenTarget,
  options: {
    y?: number;
    duration?: number;
    delay?: number;
    trigger?: string | Element;
    start?: string;
  } = {}
) {
  const { y = 60, duration = 1, delay = 0, trigger, start = "top 80%" } = options;

  return gsap.fromTo(
    element,
    { y, opacity: 0 },
    {
      y: 0,
      opacity: 1,
      duration,
      delay,
      ease: easings.smooth,
      scrollTrigger: trigger
        ? {
            trigger,
            start,
            toggleActions: "play none none reverse",
          }
        : undefined,
    }
  );
}

/**
 * Staggered reveal animation
 */
export function staggerReveal(
  elements: gsap.TweenTarget,
  options: {
    stagger?: number;
    y?: number;
    duration?: number;
    trigger?: string | Element;
    start?: string;
  } = {}
) {
  const { stagger = 0.1, y = 40, duration = 0.8, trigger, start = "top 80%" } = options;

  return gsap.fromTo(
    elements,
    { y, opacity: 0 },
    {
      y: 0,
      opacity: 1,
      duration,
      stagger,
      ease: easings.smooth,
      scrollTrigger: trigger
        ? {
            trigger,
            start,
            toggleActions: "play none none reverse",
          }
        : undefined,
    }
  );
}

/**
 * Scale in animation
 */
export function scaleIn(
  element: gsap.TweenTarget,
  options: {
    scale?: number;
    duration?: number;
    delay?: number;
    trigger?: string | Element;
  } = {}
) {
  const { scale = 0.8, duration = 1, delay = 0, trigger } = options;

  return gsap.fromTo(
    element,
    { scale, opacity: 0 },
    {
      scale: 1,
      opacity: 1,
      duration,
      delay,
      ease: easings.bouncy,
      scrollTrigger: trigger
        ? {
            trigger,
            start: "top 80%",
            toggleActions: "play none none reverse",
          }
        : undefined,
    }
  );
}

// ============================================
// HORIZONTAL SCROLL
// ============================================

/**
 * Create horizontal scroll section
 */
export function createHorizontalScroll(
  container: HTMLElement,
  sections: HTMLElement | HTMLElement[],
  options: {
    scrub?: number | boolean;
    pin?: boolean;
    anticipatePin?: number;
    snap?: number | number[] | false;
  } = {}
) {
  const { scrub = 1, pin = true, anticipatePin = 1, snap = false } = options;

  const sectionsArray = Array.isArray(sections) ? sections : [sections];
  const totalWidth = sectionsArray.reduce((acc, section) => acc + section.offsetWidth, 0);

  return gsap.to(sectionsArray, {
    x: () => -(totalWidth - window.innerWidth),
    ease: "none",
    scrollTrigger: {
      trigger: container,
      start: "top top",
      end: () => `+=${totalWidth}`,
      scrub,
      pin,
      anticipatePin,
      snap: snap
        ? {
            snapTo: snap,
            duration: 0.5,
            ease: easings.snappy,
          }
        : undefined,
    },
  });
}

// ============================================
// PARALLAX EFFECTS
// ============================================

/**
 * Simple parallax effect
 */
export function parallax(
  element: string | Element,
  options: {
    speed?: number;
    direction?: "up" | "down";
    trigger?: string | Element;
  } = {}
) {
  const { speed = 0.5, direction = "up", trigger } = options;
  const yPercent = direction === "up" ? -100 * speed : 100 * speed;

  return gsap.to(element, {
    yPercent,
    ease: "none",
    scrollTrigger: {
      trigger: trigger || element,
      start: "top bottom",
      end: "bottom top",
      scrub: true,
    },
  });
}

// ============================================
// MAGNETIC EFFECT
// ============================================

/**
 * Magnetic hover effect for buttons/elements
 */
export function createMagneticEffect(element: HTMLElement, strength: number = 0.3) {
  const handleMouseMove = (e: MouseEvent) => {
    const rect = element.getBoundingClientRect();
    const x = e.clientX - rect.left - rect.width / 2;
    const y = e.clientY - rect.top - rect.height / 2;

    gsap.to(element, {
      x: x * strength,
      y: y * strength,
      duration: 0.3,
      ease: easings.smooth,
    });
  };

  const handleMouseLeave = () => {
    gsap.to(element, {
      x: 0,
      y: 0,
      duration: 0.5,
      ease: easings.bouncy,
    });
  };

  element.addEventListener("mousemove", handleMouseMove);
  element.addEventListener("mouseleave", handleMouseLeave);

  return () => {
    element.removeEventListener("mousemove", handleMouseMove);
    element.removeEventListener("mouseleave", handleMouseLeave);
  };
}

// ============================================
// NUMBER COUNTER
// ============================================

/**
 * Animated number counter
 */
export function countUp(
  element: HTMLElement,
  endValue: number,
  options: {
    duration?: number;
    suffix?: string;
    prefix?: string;
    decimals?: number;
    trigger?: string | Element;
  } = {}
) {
  const { duration = 2, suffix = "", prefix = "", decimals = 0, trigger } = options;

  const counter = { value: 0 };

  return gsap.to(counter, {
    value: endValue,
    duration,
    ease: easings.inOut,
    scrollTrigger: trigger
      ? {
          trigger,
          start: "top 80%",
          toggleActions: "play none none none",
        }
      : undefined,
    onUpdate: () => {
      element.textContent = `${prefix}${counter.value.toFixed(decimals)}${suffix}`;
    },
  });
}

// ============================================
// TEXT REVEAL ANIMATIONS
// ============================================

/**
 * Character-by-character reveal
 */
export function revealChars(
  element: HTMLElement,
  options: {
    stagger?: number;
    duration?: number;
    delay?: number;
    trigger?: string | Element;
  } = {}
) {
  const { stagger = 0.02, duration = 0.5, delay = 0, trigger } = options;
  const chars = splitTextToChars(element);

  return gsap.fromTo(
    chars,
    { opacity: 0, y: 20 },
    {
      opacity: 1,
      y: 0,
      duration,
      stagger,
      delay,
      ease: easings.smooth,
      scrollTrigger: trigger
        ? {
            trigger,
            start: "top 80%",
            toggleActions: "play none none reverse",
          }
        : undefined,
    }
  );
}

/**
 * Word-by-word reveal
 */
export function revealWords(
  element: HTMLElement,
  options: {
    stagger?: number;
    duration?: number;
    delay?: number;
    trigger?: string | Element;
  } = {}
) {
  const { stagger = 0.05, duration = 0.6, delay = 0, trigger } = options;
  const words = splitTextToWords(element);

  return gsap.fromTo(
    words,
    { opacity: 0, y: 30, rotateX: -90 },
    {
      opacity: 1,
      y: 0,
      rotateX: 0,
      duration,
      stagger,
      delay,
      ease: easings.smooth,
      scrollTrigger: trigger
        ? {
            trigger,
            start: "top 80%",
            toggleActions: "play none none reverse",
          }
        : undefined,
    }
  );
}

/**
 * Line-by-line reveal with clip path
 */
export function revealLines(
  element: HTMLElement,
  options: {
    stagger?: number;
    duration?: number;
    delay?: number;
    trigger?: string | Element;
  } = {}
) {
  const { stagger = 0.15, duration = 0.8, delay = 0, trigger } = options;
  const lines = splitTextToLines(element);

  // Wrap each line's content in a span for animation
  lines.forEach((line) => {
    const wrapper = document.createElement("span");
    wrapper.style.display = "block";
    wrapper.innerHTML = line.innerHTML;
    line.innerHTML = "";
    line.appendChild(wrapper);
  });

  const wrappers = lines.map((line) => line.querySelector("span"));

  return gsap.fromTo(
    wrappers,
    { yPercent: 100 },
    {
      yPercent: 0,
      duration,
      stagger,
      delay,
      ease: easings.smooth,
      scrollTrigger: trigger
        ? {
            trigger,
            start: "top 80%",
            toggleActions: "play none none reverse",
          }
        : undefined,
    }
  );
}

// ============================================
// CURSOR EFFECTS
// ============================================

/**
 * Custom cursor follower
 */
export function createCursorFollower(
  cursorElement: HTMLElement,
  options: {
    speed?: number;
    scale?: number;
  } = {}
) {
  const { speed = 0.15, scale = 1 } = options;

  let mouseX = 0;
  let mouseY = 0;
  let cursorX = 0;
  let cursorY = 0;

  const handleMouseMove = (e: MouseEvent) => {
    mouseX = e.clientX;
    mouseY = e.clientY;
  };

  const animate = () => {
    cursorX += (mouseX - cursorX) * speed;
    cursorY += (mouseY - cursorY) * speed;

    gsap.set(cursorElement, {
      x: cursorX,
      y: cursorY,
      scale,
    });

    requestAnimationFrame(animate);
  };

  window.addEventListener("mousemove", handleMouseMove);
  animate();

  return () => {
    window.removeEventListener("mousemove", handleMouseMove);
  };
}
