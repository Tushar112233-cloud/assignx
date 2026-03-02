"use client";

/**
 * BusinessSearchBar - Debounced search input for filtering business hub posts
 */

import { useState, useEffect, useCallback } from "react";
import { Search, X } from "lucide-react";
import { Input } from "@/components/ui/input";
import { cn } from "@/lib/utils";

interface BusinessSearchBarProps {
  /** Current search value */
  value: string;
  /** Callback when search value changes (debounced) */
  onSearch: (query: string) => void;
  /** Optional className */
  className?: string;
}

export function BusinessSearchBar({
  value,
  onSearch,
  className,
}: BusinessSearchBarProps) {
  const [localValue, setLocalValue] = useState(value);

  // Sync from parent
  useEffect(() => {
    setLocalValue(value);
  }, [value]);

  // Debounced search
  useEffect(() => {
    const timer = setTimeout(() => {
      if (localValue !== value) {
        onSearch(localValue);
      }
    }, 400);

    return () => clearTimeout(timer);
  }, [localValue, value, onSearch]);

  const handleClear = useCallback(() => {
    setLocalValue("");
    onSearch("");
  }, [onSearch]);

  return (
    <div className={cn("relative", className)}>
      <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
      <Input
        type="text"
        placeholder="Search companies, discussions, opportunities..."
        value={localValue}
        onChange={(e) => setLocalValue(e.target.value)}
        className="pl-10 pr-10 h-11 rounded-xl bg-muted/50 border-border/50 focus:bg-background"
      />
      {localValue && (
        <button
          onClick={handleClear}
          className="absolute right-3 top-1/2 -translate-y-1/2 p-0.5 rounded-full hover:bg-muted transition-colors"
        >
          <X className="h-4 w-4 text-muted-foreground" />
        </button>
      )}
    </div>
  );
}
