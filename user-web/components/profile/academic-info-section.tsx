"use client";

import { useState } from "react";
import { Loader2, GraduationCap, Search } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
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
import { toast } from "sonner";
import {
  popularUniversities,
  commonMajors,
  yearLevelOptions,
} from "@/lib/data/profile";
import type { AcademicInfo, YearLevel, FormErrors } from "@/types/profile";

interface AcademicInfoSectionProps {
  academicInfo: AcademicInfo;
  onSave: (data: AcademicInfo) => Promise<void>;
}

/**
 * Academic information form section
 */
export function AcademicInfoSection({
  academicInfo,
  onSave,
}: AcademicInfoSectionProps) {
  const [formData, setFormData] = useState<AcademicInfo>({
    ...academicInfo,
  });
  const [errors, setErrors] = useState<FormErrors>({});
  const [isSaving, setIsSaving] = useState(false);
  const [hasChanges, setHasChanges] = useState(false);
  const [universityOpen, setUniversityOpen] = useState(false);
  const [majorOpen, setMajorOpen] = useState(false);

  const validateForm = (): boolean => {
    const newErrors: FormErrors = {};

    if (!formData.university.trim()) {
      newErrors.university = "University is required";
    }
    if (!formData.major.trim()) {
      newErrors.major = "Major is required";
    }
    if (!formData.yearLevel) {
      newErrors.yearLevel = "Year level is required";
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleChange = <K extends keyof AcademicInfo>(
    field: K,
    value: AcademicInfo[K]
  ) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
    setHasChanges(true);
    if (errors[field]) {
      setErrors((prev) => ({ ...prev, [field]: undefined }));
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!validateForm()) return;

    setIsSaving(true);
    try {
      await onSave(formData);
      toast.success("Academic information updated");
      setHasChanges(false);
    } catch {
      toast.error("Failed to update academic information");
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center gap-2">
          <GraduationCap className="h-5 w-5" />
          <CardTitle>Academic Information</CardTitle>
        </div>
        <CardDescription>
          Your educational background and current enrollment details
        </CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-4">
          {/* University */}
          <div className="space-y-2">
            <Label>University</Label>
            <Popover open={universityOpen} onOpenChange={setUniversityOpen}>
              <PopoverTrigger asChild>
                <Button
                  variant="outline"
                  role="combobox"
                  aria-expanded={universityOpen}
                  className={cn(
                    "w-full justify-between",
                    !formData.university && "text-muted-foreground",
                    errors.university && "border-destructive"
                  )}
                >
                  {formData.university || "Select university..."}
                  <Search className="ml-2 h-4 w-4 shrink-0 opacity-50" />
                </Button>
              </PopoverTrigger>
              <PopoverContent className="w-full p-0" align="start">
                <Command>
                  <CommandInput placeholder="Search universities..." />
                  <CommandList>
                    <CommandEmpty>No university found.</CommandEmpty>
                    <CommandGroup>
                      {popularUniversities.map((uni) => (
                        <CommandItem
                          key={uni.id}
                          value={uni.name}
                          onSelect={() => {
                            handleChange("university", uni.name);
                            handleChange("universityId", uni.id);
                            setUniversityOpen(false);
                          }}
                        >
                          <span>{uni.name}</span>
                          {uni.country && (
                            <span className="ml-2 text-muted-foreground">
                              {uni.country}
                            </span>
                          )}
                        </CommandItem>
                      ))}
                    </CommandGroup>
                  </CommandList>
                </Command>
              </PopoverContent>
            </Popover>
            {errors.university && (
              <p className="text-sm text-destructive">{errors.university}</p>
            )}
          </div>

          {/* Major */}
          <div className="space-y-2">
            <Label>Major / Field of Study</Label>
            <Popover open={majorOpen} onOpenChange={setMajorOpen}>
              <PopoverTrigger asChild>
                <Button
                  variant="outline"
                  role="combobox"
                  aria-expanded={majorOpen}
                  className={cn(
                    "w-full justify-between",
                    !formData.major && "text-muted-foreground",
                    errors.major && "border-destructive"
                  )}
                >
                  {formData.major || "Select major..."}
                  <Search className="ml-2 h-4 w-4 shrink-0 opacity-50" />
                </Button>
              </PopoverTrigger>
              <PopoverContent className="w-full p-0" align="start">
                <Command>
                  <CommandInput placeholder="Search majors..." />
                  <CommandList>
                    <CommandEmpty>No major found.</CommandEmpty>
                    <CommandGroup>
                      {commonMajors.map((major) => (
                        <CommandItem
                          key={major}
                          value={major}
                          onSelect={() => {
                            handleChange("major", major);
                            setMajorOpen(false);
                          }}
                        >
                          {major}
                        </CommandItem>
                      ))}
                    </CommandGroup>
                  </CommandList>
                </Command>
              </PopoverContent>
            </Popover>
            {errors.major && (
              <p className="text-sm text-destructive">{errors.major}</p>
            )}
          </div>

          {/* Year Level */}
          <div className="space-y-2">
            <Label>Year Level</Label>
            <Select
              value={formData.yearLevel}
              onValueChange={(value: YearLevel) =>
                handleChange("yearLevel", value)
              }
            >
              <SelectTrigger
                className={cn(errors.yearLevel && "border-destructive")}
              >
                <SelectValue placeholder="Select year level" />
              </SelectTrigger>
              <SelectContent>
                {yearLevelOptions.map((option) => (
                  <SelectItem key={option.value} value={option.value}>
                    {option.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            {errors.yearLevel && (
              <p className="text-sm text-destructive">{errors.yearLevel}</p>
            )}
          </div>

          {/* Student ID */}
          <div className="space-y-2">
            <Label htmlFor="studentId">
              Student ID <span className="text-muted-foreground">(optional)</span>
            </Label>
            <Input
              id="studentId"
              value={formData.studentId || ""}
              onChange={(e) => handleChange("studentId", e.target.value)}
              placeholder="e.g., STU2024001"
            />
          </div>

          {/* Expected Graduation */}
          <div className="space-y-2">
            <Label htmlFor="expectedGraduation">
              Expected Graduation{" "}
              <span className="text-muted-foreground">(optional)</span>
            </Label>
            <Input
              id="expectedGraduation"
              type="month"
              value={formData.expectedGraduation || ""}
              onChange={(e) =>
                handleChange("expectedGraduation", e.target.value)
              }
            />
          </div>

          {/* Submit button */}
          <div className="flex justify-end pt-4">
            <Button type="submit" disabled={!hasChanges || isSaving}>
              {isSaving ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Saving...
                </>
              ) : (
                "Save Changes"
              )}
            </Button>
          </div>
        </form>
      </CardContent>
    </Card>
  );
}
