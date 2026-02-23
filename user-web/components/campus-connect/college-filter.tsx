"use client";

import { useState, useEffect } from "react";
import { Check, ChevronsUpDown, School, X } from "lucide-react";
import { cn } from "@/lib/utils";
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
import { Badge } from "@/components/ui/badge";
import { getUniversities } from "@/lib/actions/campus-connect";

interface University {
  id: string;
  name: string;
  shortName: string | null;
}

interface CollegeFilterProps {
  selectedUniversityId: string | null;
  onUniversityChange: (universityId: string | null) => void;
  className?: string;
  /** Placeholder text */
  placeholder?: string;
  /** Show clear button */
  showClear?: boolean;
}

/**
 * CollegeFilter - Searchable dropdown for selecting university/college
 * Features combobox pattern with search functionality
 */
export function CollegeFilter({
  selectedUniversityId,
  onUniversityChange,
  className,
  placeholder = "All Colleges",
  showClear = true,
}: CollegeFilterProps) {
  const [open, setOpen] = useState(false);
  const [universities, setUniversities] = useState<University[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  // Fetch universities on mount
  useEffect(() => {
    async function loadUniversities() {
      setIsLoading(true);
      const { data, error } = await getUniversities();
      if (!error && data) {
        setUniversities(data);
      }
      setIsLoading(false);
    }
    loadUniversities();
  }, []);

  const selectedUniversity = universities.find(u => u.id === selectedUniversityId);

  const handleSelect = (universityId: string) => {
    if (universityId === selectedUniversityId) {
      onUniversityChange(null);
    } else {
      onUniversityChange(universityId);
    }
    setOpen(false);
  };

  const handleClear = (e: React.MouseEvent) => {
    e.stopPropagation();
    onUniversityChange(null);
  };

  return (
    <div className={cn("w-full max-w-xs", className)}>
      <Popover open={open} onOpenChange={setOpen}>
        <PopoverTrigger asChild>
          <Button
            variant="outline"
            role="combobox"
            aria-expanded={open}
            className={cn(
              "w-full justify-between font-normal",
              !selectedUniversity && "text-muted-foreground"
            )}
          >
            <div className="flex items-center gap-2 min-w-0 flex-1">
              <School className="h-4 w-4 shrink-0 opacity-50" />
              <span className="truncate">
                {selectedUniversity
                  ? selectedUniversity.shortName || selectedUniversity.name
                  : placeholder}
              </span>
            </div>
            <div className="flex items-center gap-1 shrink-0 ml-2">
              {showClear && selectedUniversity && (
                <Badge
                  variant="secondary"
                  className="h-5 w-5 p-0 rounded-full hover:bg-destructive/20 cursor-pointer"
                  onClick={handleClear}
                >
                  <X className="h-3 w-3" />
                </Badge>
              )}
              <ChevronsUpDown className="h-4 w-4 opacity-50" />
            </div>
          </Button>
        </PopoverTrigger>
        <PopoverContent className="w-[300px] p-0" align="start">
          <Command>
            <CommandInput placeholder="Search colleges..." className="h-9" />
            <CommandList>
              <CommandEmpty>
                {isLoading ? "Loading..." : "No college found."}
              </CommandEmpty>
              <CommandGroup>
                {/* All Colleges Option */}
                <CommandItem
                  value="all"
                  onSelect={() => {
                    onUniversityChange(null);
                    setOpen(false);
                  }}
                >
                  <div className="flex items-center gap-2">
                    <School className="h-4 w-4 text-muted-foreground" />
                    <span>All Colleges</span>
                  </div>
                  <Check
                    className={cn(
                      "ml-auto h-4 w-4",
                      !selectedUniversityId ? "opacity-100" : "opacity-0"
                    )}
                  />
                </CommandItem>

                {/* University List */}
                {universities.map((university) => (
                  <CommandItem
                    key={university.id}
                    value={`${university.name} ${university.shortName || ""}`}
                    onSelect={() => handleSelect(university.id)}
                  >
                    <div className="flex flex-col min-w-0 flex-1">
                      <span className="truncate font-medium">
                        {university.shortName || university.name}
                      </span>
                      {university.shortName && (
                        <span className="text-xs text-muted-foreground truncate">
                          {university.name}
                        </span>
                      )}
                    </div>
                    <Check
                      className={cn(
                        "ml-auto h-4 w-4 shrink-0",
                        selectedUniversityId === university.id
                          ? "opacity-100"
                          : "opacity-0"
                      )}
                    />
                  </CommandItem>
                ))}
              </CommandGroup>
            </CommandList>
          </Command>
        </PopoverContent>
      </Popover>
    </div>
  );
}

/**
 * CollegeFilterCompact - Compact badge-style version
 */
export function CollegeFilterCompact({
  selectedUniversityId,
  onUniversityChange,
  className,
}: CollegeFilterProps) {
  const [open, setOpen] = useState(false);
  const [universities, setUniversities] = useState<University[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    async function loadUniversities() {
      setIsLoading(true);
      const { data, error } = await getUniversities();
      if (!error && data) {
        setUniversities(data);
      }
      setIsLoading(false);
    }
    loadUniversities();
  }, []);

  const selectedUniversity = universities.find(u => u.id === selectedUniversityId);

  return (
    <Popover open={open} onOpenChange={setOpen}>
      <PopoverTrigger asChild>
        <Button
          variant="ghost"
          size="sm"
          className={cn(
            "h-8 px-3 rounded-full border border-border/50 hover:bg-muted",
            selectedUniversity && "bg-primary/10 border-primary/30",
            className
          )}
        >
          <School className="h-3.5 w-3.5 mr-1.5 text-muted-foreground" />
          <span className="text-xs font-medium truncate max-w-[120px]">
            {selectedUniversity?.shortName || selectedUniversity?.name || "All Colleges"}
          </span>
          <ChevronsUpDown className="h-3 w-3 ml-1.5 opacity-50" />
        </Button>
      </PopoverTrigger>
      <PopoverContent className="w-[280px] p-0" align="start">
        <Command>
          <CommandInput placeholder="Search..." className="h-9" />
          <CommandList className="max-h-[200px]">
            <CommandEmpty>
              {isLoading ? "Loading..." : "No results."}
            </CommandEmpty>
            <CommandGroup>
              <CommandItem
                value="all"
                onSelect={() => {
                  onUniversityChange(null);
                  setOpen(false);
                }}
              >
                All Colleges
                <Check
                  className={cn(
                    "ml-auto h-4 w-4",
                    !selectedUniversityId ? "opacity-100" : "opacity-0"
                  )}
                />
              </CommandItem>
              {universities.map((u) => (
                <CommandItem
                  key={u.id}
                  value={`${u.name} ${u.shortName || ""}`}
                  onSelect={() => {
                    onUniversityChange(u.id);
                    setOpen(false);
                  }}
                >
                  <span className="truncate">
                    {u.shortName || u.name}
                  </span>
                  <Check
                    className={cn(
                      "ml-auto h-4 w-4",
                      selectedUniversityId === u.id ? "opacity-100" : "opacity-0"
                    )}
                  />
                </CommandItem>
              ))}
            </CommandGroup>
          </CommandList>
        </Command>
      </PopoverContent>
    </Popover>
  );
}

export default CollegeFilter;
