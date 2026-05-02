"use client";

import { useState } from "react";
import { format, addDays } from "date-fns";
import { Calendar as CalendarIcon } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Calendar } from "@/components/ui/calendar";
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import { cn } from "@/lib/utils";

interface DeadlinePickerProps {
  value?: Date;
  onChange: (date: Date | undefined) => void;
  minDays?: number;
  error?: string;
  className?: string;
}

/**
 * Quick select options for deadlines
 */
const quickOptions = [
  { label: "1 Week", days: 7 },
  { label: "2 Weeks", days: 14 },
  { label: "1 Month", days: 30 },
];

/**
 * Deadline picker with calendar and quick select options
 */
export function DeadlinePicker({
  value,
  onChange,
  minDays = 1,
  error,
  className,
}: DeadlinePickerProps) {
  const [open, setOpen] = useState(false);

  const minDate = addDays(new Date(), minDays);

  const handleQuickSelect = (days: number) => {
    const date = addDays(new Date(), days);
    onChange(date);
    setOpen(false);
  };

  return (
    <div className={cn("space-y-2", className)}>
      <Popover open={open} onOpenChange={setOpen}>
        <PopoverTrigger asChild>
          <Button
            variant="outline"
            className={cn(
              "w-full justify-start text-left font-normal",
              !value && "text-muted-foreground",
              error && "border-destructive"
            )}
          >
            <CalendarIcon className="mr-2 h-4 w-4" />
            {value ? format(value, "PPP") : "Select deadline..."}
          </Button>
        </PopoverTrigger>
        <PopoverContent className="w-auto p-0" align="start">
          {/* Quick Select Options */}
          <div className="flex gap-2 border-b p-3">
            {quickOptions.map((option) => (
              <Button
                key={option.days}
                variant="outline"
                size="sm"
                onClick={() => handleQuickSelect(option.days)}
                className="flex-1"
              >
                {option.label}
              </Button>
            ))}
          </div>
          <Calendar
            mode="single"
            selected={value}
            onSelect={(date) => {
              onChange(date);
              setOpen(false);
            }}
            disabled={(date) => date < minDate}
            initialFocus
          />
        </PopoverContent>
      </Popover>
      {error && <p className="text-sm text-destructive">{error}</p>}
    </div>
  );
}
