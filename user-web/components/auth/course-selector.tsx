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
import courses from "@/lib/data/courses.json";

interface CourseSelectorProps {
  value: string;
  onChange: (value: string) => void;
  error?: string;
}

/**
 * Searchable course selector with combobox
 */
export function CourseSelector({ value, onChange, error }: CourseSelectorProps) {
  const [open, setOpen] = useState(false);

  const selectedCourse = courses.find((c) => c.id === value);

  // Group courses by category
  const groupedCourses = courses.reduce(
    (acc, course) => {
      if (!acc[course.category]) {
        acc[course.category] = [];
      }
      acc[course.category].push(course);
      return acc;
    },
    {} as Record<string, typeof courses>
  );

  return (
    <div className="space-y-2">
      <Popover open={open} onOpenChange={setOpen}>
        <PopoverTrigger asChild>
          <Button
            variant="outline"
            role="combobox"
            aria-expanded={open}
            className={cn(
              "w-full justify-between",
              !value && "text-muted-foreground",
              error && "border-destructive"
            )}
          >
            {selectedCourse ? selectedCourse.name : "Select course..."}
            <ChevronsUpDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
          </Button>
        </PopoverTrigger>
        <PopoverContent className="w-full p-0" align="start">
          <Command>
            <CommandInput placeholder="Search course..." />
            <CommandList>
              <CommandEmpty>No course found.</CommandEmpty>
              {Object.entries(groupedCourses).map(([category, categoryCourses]) => (
                <CommandGroup key={category} heading={category}>
                  {categoryCourses.map((course) => (
                    <CommandItem
                      key={course.id}
                      value={course.name}
                      onSelect={() => {
                        onChange(course.id);
                        setOpen(false);
                      }}
                    >
                      <Check
                        className={cn(
                          "mr-2 h-4 w-4",
                          value === course.id ? "opacity-100" : "opacity-0"
                        )}
                      />
                      <span>{course.name}</span>
                      <span className="ml-auto text-xs text-muted-foreground">
                        {course.shortName}
                      </span>
                    </CommandItem>
                  ))}
                </CommandGroup>
              ))}
            </CommandList>
          </Command>
        </PopoverContent>
      </Popover>
      {error && <p className="text-sm text-destructive">{error}</p>}
    </div>
  );
}
