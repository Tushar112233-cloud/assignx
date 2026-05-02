"use client";

import { useState } from "react";
import { Check, ChevronsUpDown, Loader2 } from "lucide-react";
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
import { Input } from "@/components/ui/input";
import { cn } from "@/lib/utils";
import { useSubjects, type ApiSubject } from "@/lib/hooks/use-subjects";
import { getSubjectPresentation } from "@/lib/data/subjects";

interface SubjectSelectorProps {
  value: string;
  onChange: (value: string) => void;
  customSubject?: string;
  onCustomSubjectChange?: (value: string) => void;
  error?: string;
  customSubjectError?: string;
  className?: string;
}

/**
 * Subject selector with search, icons, and "Other" custom input support.
 * Fetches subjects from the API and uses slug-based presentation mapping.
 */
export function SubjectSelector({
  value,
  onChange,
  customSubject,
  onCustomSubjectChange,
  error,
  customSubjectError,
  className,
}: SubjectSelectorProps) {
  const [open, setOpen] = useState(false);
  const { subjects, isLoading } = useSubjects();

  const selectedSubject = subjects.find((s) => s._id === value);
  const selectedPresentation = selectedSubject
    ? getSubjectPresentation(selectedSubject.slug)
    : null;
  const isOther = selectedSubject?.slug === "other";

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
            {isLoading ? (
              <div className="flex items-center gap-2">
                <Loader2 className="h-4 w-4 animate-spin" />
                <span>Loading subjects...</span>
              </div>
            ) : selectedSubject && selectedPresentation ? (
              <div className="flex items-center gap-2">
                <div
                  className={cn(
                    "flex h-7 w-7 items-center justify-center rounded-lg shadow-sm",
                    selectedPresentation.color
                  )}
                >
                  <selectedPresentation.icon className="h-4 w-4" />
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
                {subjects.map((subject) => {
                  const presentation = getSubjectPresentation(subject.slug);
                  return (
                    <CommandItem
                      key={subject._id}
                      value={subject.name}
                      onSelect={() => {
                        onChange(subject._id);
                        setOpen(false);
                      }}
                      className="cursor-pointer"
                    >
                      <div className="flex items-center gap-2">
                        <div
                          className={cn(
                            "flex h-7 w-7 items-center justify-center rounded-lg shadow-sm",
                            presentation.color
                          )}
                        >
                          <presentation.icon className="h-4 w-4" />
                        </div>
                        <span className="font-medium">{subject.name}</span>
                      </div>
                      <Check
                        className={cn(
                          "ml-auto h-4 w-4 text-violet-600",
                          value === subject._id ? "opacity-100" : "opacity-0"
                        )}
                      />
                    </CommandItem>
                  );
                })}
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

      {/* Custom subject input when "Other" is selected */}
      {isOther && (
        <div className="space-y-1.5 pt-1">
          <Input
            placeholder="Enter your subject name..."
            value={customSubject || ""}
            onChange={(e) => onCustomSubjectChange?.(e.target.value)}
            className={cn(
              "h-10",
              customSubjectError && "border-red-500"
            )}
          />
          {customSubjectError && (
            <p className="text-xs text-red-500 font-medium flex items-center gap-1">
              <span className="h-1 w-1 rounded-full bg-red-500" />
              {customSubjectError}
            </p>
          )}
        </div>
      )}
    </div>
  );
}
