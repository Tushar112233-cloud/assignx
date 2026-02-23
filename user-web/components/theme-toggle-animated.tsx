"use client";

import * as React from "react";
import { useTheme } from "next-themes";
import { cn } from "@/lib/utils";

/**
 * Animated theme toggle button with sun/moon micro-interaction
 * Supports only light and dark mode (no system mode)
 */
export function ThemeToggleAnimated() {
  const { theme, setTheme, resolvedTheme } = useTheme();
  const [mounted, setMounted] = React.useState(false);

  // Prevent hydration mismatch
  React.useEffect(() => {
    setMounted(true);
  }, []);

  const isDark = resolvedTheme === "dark";

  const toggleTheme = () => {
    setTheme(isDark ? "light" : "dark");
  };

  if (!mounted) {
    return (
      <button
        className="relative h-8 w-8 rounded-lg bg-muted/50 flex items-center justify-center"
        disabled
      >
        <span className="sr-only">Toggle theme</span>
      </button>
    );
  }

  return (
    <button
      onClick={toggleTheme}
      className={cn(
        "relative h-8 w-8 rounded-lg",
        "bg-muted/50 hover:bg-muted transition-colors duration-200",
        "flex items-center justify-center",
        "focus:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
      )}
      aria-label={`Switch to ${isDark ? "light" : "dark"} mode`}
    >
      {/* Sun Icon */}
      <svg
        className={cn(
          "absolute h-[18px] w-[18px] transition-all duration-500",
          isDark
            ? "rotate-90 scale-0 opacity-0"
            : "rotate-0 scale-100 opacity-100"
        )}
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
        strokeWidth={1.5}
      >
        {/* Sun center */}
        <circle
          cx="12"
          cy="12"
          r="4"
          className={cn(
            "transition-all duration-500 origin-center",
            isDark ? "scale-0" : "scale-100"
          )}
          fill="currentColor"
          stroke="none"
        />
        {/* Sun rays - animated */}
        <g
          className={cn(
            "transition-all duration-500 origin-center",
            isDark ? "scale-0 rotate-90" : "scale-100 rotate-0"
          )}
        >
          <line x1="12" y1="1" x2="12" y2="3" strokeLinecap="round" />
          <line x1="12" y1="21" x2="12" y2="23" strokeLinecap="round" />
          <line x1="4.22" y1="4.22" x2="5.64" y2="5.64" strokeLinecap="round" />
          <line x1="18.36" y1="18.36" x2="19.78" y2="19.78" strokeLinecap="round" />
          <line x1="1" y1="12" x2="3" y2="12" strokeLinecap="round" />
          <line x1="21" y1="12" x2="23" y2="12" strokeLinecap="round" />
          <line x1="4.22" y1="19.78" x2="5.64" y2="18.36" strokeLinecap="round" />
          <line x1="18.36" y1="5.64" x2="19.78" y2="4.22" strokeLinecap="round" />
        </g>
      </svg>

      {/* Moon Icon */}
      <svg
        className={cn(
          "absolute h-[18px] w-[18px] transition-all duration-500",
          isDark
            ? "rotate-0 scale-100 opacity-100"
            : "-rotate-90 scale-0 opacity-0"
        )}
        fill="currentColor"
        viewBox="0 0 24 24"
      >
        <path
          d="M21.752 15.002A9.718 9.718 0 0118 15.75c-5.385 0-9.75-4.365-9.75-9.75 0-1.33.266-2.597.748-3.752A9.753 9.753 0 003 11.25C3 16.635 7.365 21 12.75 21a9.753 9.753 0 009.002-5.998z"
          className={cn(
            "transition-all duration-500 origin-center",
            isDark ? "scale-100" : "scale-0"
          )}
        />
        {/* Stars for dark mode */}
        <circle
          cx="19"
          cy="5"
          r="1"
          className={cn(
            "transition-all duration-700 delay-100",
            isDark ? "opacity-100 scale-100" : "opacity-0 scale-0"
          )}
        />
        <circle
          cx="22"
          cy="8"
          r="0.5"
          className={cn(
            "transition-all duration-700 delay-200",
            isDark ? "opacity-100 scale-100" : "opacity-0 scale-0"
          )}
        />
      </svg>

      <span className="sr-only">
        {isDark ? "Switch to light mode" : "Switch to dark mode"}
      </span>
    </button>
  );
}
