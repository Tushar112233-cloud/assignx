"use client";

import { UseFormReturn } from "react-hook-form";
import { motion } from "framer-motion";
import { Loader2, Send } from "lucide-react";
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { FileUploadZone } from "../file-upload-zone";
import { PriceEstimate } from "../price-estimate";
import { expertQualifications } from "@/lib/validations/project";
import type { ProjectStep2Schema, ProjectStep4Schema } from "@/lib/validations/project";
import type { ProjectType, UploadedFile } from "@/types/add-project";

/** Placeholder prompts per project type */
const instructionPlaceholders: Record<ProjectType, string> = {
  assignment:
    "Include any rubric guidelines, formatting requirements, or specific sources to reference...",
  document:
    "Include structure preferences, key sections, or formatting guidelines...",
  website:
    "Describe the look and feel, specific pages needed, or any brand guidelines...",
  app:
    "Describe user flows, monetization model, or any existing backend details...",
  consultancy:
    "Any specific questions, areas of focus, or preparation needed...",
};

/** Props for StepDetails component */
interface StepDetailsProps {
  form: UseFormReturn<ProjectStep4Schema>;
  files: UploadedFile[];
  onFilesChange: (files: UploadedFile[]) => void;
  projectType: ProjectType;
  requirements: Partial<ProjectStep2Schema>;
  urgencyMultiplier: number;
  isSubmitting: boolean;
  onSubmit: () => void;
}

/** Step 4: Additional details and file uploads */
export function StepDetails({
  form,
  files,
  onFilesChange,
  projectType,
  requirements,
  urgencyMultiplier,
  isSubmitting,
  onSubmit,
}: StepDetailsProps) {
  return (
    <motion.form
      key="step4"
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -10 }}
      transition={{ duration: 0.3 }}
      onSubmit={onSubmit}
      className="space-y-6"
    >
      {/* Header */}
      <div className="mb-8">
        <h2 className="text-2xl font-semibold tracking-tight text-foreground">
          Additional Details
        </h2>
        <p className="mt-2 text-sm text-muted-foreground">
          Provide instructions and attach files
        </p>
      </div>

      {/* Type-specific fields */}
      {projectType === "website" && (
        <div className="space-y-2">
          <Label htmlFor="colorScheme">
            Color Scheme Preference{" "}
            <span className="text-muted-foreground font-normal">(Optional)</span>
          </Label>
          <Input
            id="colorScheme"
            placeholder="e.g. Navy blue and white, dark theme, earthy tones..."
            {...form.register("colorScheme")}
          />
          <p className="text-xs text-muted-foreground">
            You can also upload brand guidelines as a file below
          </p>
        </div>
      )}

      {projectType === "app" && (
        <div className="space-y-2">
          <Label htmlFor="targetAudience">
            Target Audience{" "}
            <span className="text-muted-foreground font-normal">(Optional)</span>
          </Label>
          <Input
            id="targetAudience"
            placeholder="e.g. College students aged 18-25, small business owners..."
            {...form.register("targetAudience")}
          />
        </div>
      )}

      {projectType === "consultancy" && (
        <div className="space-y-2">
          <Label htmlFor="expertQualification">
            Preferred Expert Qualification{" "}
            <span className="text-muted-foreground font-normal">(Optional)</span>
          </Label>
          <Select
            value={form.watch("expertQualification") || ""}
            onValueChange={(value) =>
              form.setValue(
                "expertQualification",
                value as ProjectStep4Schema["expertQualification"]
              )
            }
          >
            <SelectTrigger id="expertQualification">
              <SelectValue placeholder="Any qualification" />
            </SelectTrigger>
            <SelectContent>
              {expertQualifications.map((q) => (
                <SelectItem key={q.value} value={q.value}>
                  {q.label}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      )}

      {/* Additional Instructions */}
      <div className="space-y-2">
        <Label htmlFor="instructions">
          Additional Instructions{" "}
          <span className="text-muted-foreground font-normal">(Optional)</span>
        </Label>
        <Textarea
          id="instructions"
          placeholder={instructionPlaceholders[projectType]}
          rows={5}
          {...form.register("instructions")}
          className="resize-none"
        />
        <p className="text-xs text-muted-foreground">Max 2000 characters</p>
      </div>

      {/* File Upload */}
      <div className="space-y-2">
        <Label>
          Attach Files{" "}
          <span className="text-muted-foreground font-normal">
            (Optional, max 5)
          </span>
        </Label>
        <FileUploadZone files={files} onFilesChange={onFilesChange} maxFiles={5} />
      </div>

      {/* Price Estimate */}
      <PriceEstimate
        projectType={projectType}
        requirements={requirements}
        urgencyMultiplier={urgencyMultiplier}
      />

      {/* Submit Button */}
      <Button
        type="submit"
        disabled={isSubmitting}
        className="w-full h-12 text-sm font-medium mt-8"
      >
        {isSubmitting ? (
          <>
            <Loader2 className="mr-2 h-4 w-4 animate-spin" />
            Submitting...
          </>
        ) : (
          <>
            <Send className="mr-2 h-4 w-4" />
            Submit Project
          </>
        )}
      </Button>
    </motion.form>
  );
}
