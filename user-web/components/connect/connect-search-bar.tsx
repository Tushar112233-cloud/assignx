"use client";

import { useState } from "react";
import { Search, SlidersHorizontal, X } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

interface ConnectSearchBarProps {
  value: string;
  onChange: (value: string) => void;
  onFilterClick?: () => void;
  placeholder?: string;
  showFilterButton?: boolean;
  className?: string;
}

/**
 * Search bar component for the Student Connect page
 * Includes search input and optional filter button
 */
export function ConnectSearchBar({
  value,
  onChange,
  onFilterClick,
  placeholder = "Search tutors, resources, groups...",
  showFilterButton = true,
  className,
}: ConnectSearchBarProps) {
  const [isFocused, setIsFocused] = useState(false);

  return (
    <div className={cn("flex items-center gap-2", className)}>
      <div
        className={cn(
          "relative flex-1 transition-all duration-200",
          isFocused && "ring-2 ring-primary/20 rounded-lg"
        )}
      >
        <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
        <Input
          type="text"
          value={value}
          onChange={(e) => onChange(e.target.value)}
          onFocus={() => setIsFocused(true)}
          onBlur={() => setIsFocused(false)}
          placeholder={placeholder}
          className="pl-10 pr-10"
        />
        {value && (
          <button
            type="button"
            onClick={() => onChange("")}
            className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
          >
            <X className="h-4 w-4" />
          </button>
        )}
      </div>

      {showFilterButton && (
        <Button
          variant="outline"
          size="icon"
          onClick={onFilterClick}
          className="shrink-0"
        >
          <SlidersHorizontal className="h-4 w-4" />
        </Button>
      )}
    </div>
  );
}
