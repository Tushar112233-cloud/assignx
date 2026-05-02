"use client";

import { useState, useEffect, useRef } from "react";

interface UseMinimumLoadingTimeOptions {
  minimumDuration?: number;
  onLoadingComplete?: () => void;
}

/**
 * Hook that ensures loading state displays for a minimum duration
 * Prevents jarring flash of content when data loads quickly
 *
 * @param isLoading - Current loading state from data fetch
 * @param options - Configuration options
 * @returns Extended loading state that respects minimum duration
 */
export function useMinimumLoadingTime(
  isLoading: boolean,
  options: UseMinimumLoadingTimeOptions = {}
): boolean {
  const { minimumDuration = 1000, onLoadingComplete } = options;
  const [showLoading, setShowLoading] = useState(isLoading);
  const loadingStartTime = useRef<number | null>(null);
  const timeoutRef = useRef<NodeJS.Timeout | null>(null);

  useEffect(() => {
    if (isLoading) {
      // Start loading - record start time
      loadingStartTime.current = Date.now();
      setShowLoading(true);
    } else if (loadingStartTime.current !== null) {
      // Loading finished - calculate remaining time
      const elapsed = Date.now() - loadingStartTime.current;
      const remainingTime = Math.max(0, minimumDuration - elapsed);

      if (remainingTime > 0) {
        // Wait for remaining time before hiding skeleton
        timeoutRef.current = setTimeout(() => {
          setShowLoading(false);
          loadingStartTime.current = null;
          onLoadingComplete?.();
        }, remainingTime);
      } else {
        // Minimum time already elapsed
        setShowLoading(false);
        loadingStartTime.current = null;
        onLoadingComplete?.();
      }
    }

    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
    };
  }, [isLoading, minimumDuration, onLoadingComplete]);

  return showLoading;
}

export default useMinimumLoadingTime;
