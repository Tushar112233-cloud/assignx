"use client";

import { useState } from "react";
import { Check, ChevronsUpDown } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from "@/components/ui/command";
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import { cn } from "@/lib/utils";
import { subjects, type Subject } from "@/lib/data/subjects";

interface SubjectSelectorProps {
  value: string;
  onChange: (value: string) => void;
  error?: string;
  className?: string;
}

/**
 * Subject selector with search and icons
 */
export function SubjectSelector({
  value,
  onChange,
  error,
  className,
}: SubjectSelectorProps) {
  const [open, setOpen] = useState(false);

  const selectedSubject = subjects.find((s) => s.id === value);

  return (
    <div className={cn("space-y-2", className)}>
      <Popover open={open} onOpenChange={setOpen}>
        <PopoverTrigger asChild>
          <Button
            variant="outline"
            role="combobox"
            aria-expanded={open}
            className={cn(
              "w-full h-11 justify-between",
              error && "border-red-500",
              !value && "text-muted-foreground"
            )}
          >
            {selectedSubject ? (
              <div className="flex items-center gap-2">
                <div
                  className={cn(
                    "flex h-7 w-7 items-center justify-center rounded-lg shadow-sm",
                    selectedSubject.color
                  )}
                >
                  <selectedSubject.icon className="h-4 w-4" />
                </div>
                <span className="font-medium">{selectedSubject.name}</span>
              </div>
            ) : (
              "Select subject..."
            )}
            <ChevronsUpDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
          </Button>
        </PopoverTrigger>
        <PopoverContent className="w-full p-0" align="start">
          <Command>
            <CommandInput placeholder="Search subjects..." className="h-10" />
            <CommandList>
              <CommandEmpty>No subject found.</CommandEmpty>
              <CommandGroup>
                {subjects.map((subject) => (
                  <CommandItem
                    key={subject.id}
                    value={subject.name}
                    onSelect={() => {
                      onChange(subject.id);
                      setOpen(false);
                    }}
                    className="cursor-pointer"
                  >
                    <div className="flex items-center gap-2">
                      <div
                        className={cn(
                          "flex h-7 w-7 items-center justify-center rounded-lg shadow-sm",
                          subject.color
                        )}
                      >
                        <subject.icon className="h-4 w-4" />
                      </div>
                      <span className="font-medium">{subject.name}</span>
                    </div>
                    <Check
                      className={cn(
                        "ml-auto h-4 w-4 text-violet-600",
                        value === subject.id ? "opacity-100" : "opacity-0"
                      )}
                    />
                  </CommandItem>
                ))}
              </CommandGroup>
            </CommandList>
          </Command>
        </PopoverContent>
      </Popover>
      {error && (
        <p className="text-xs text-red-500 font-medium flex items-center gap-1">
          <span className="h-1 w-1 rounded-full bg-red-500" />
          {error}
        </p>
      )}
    </div>
  );
}
