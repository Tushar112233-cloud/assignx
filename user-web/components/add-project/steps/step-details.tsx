"use client";

import { UseFormReturn } from "react-hook-form";
import { motion } from "framer-motion";
import { Loader2, Send } from "lucide-react";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { FileUploadZone } from "../file-upload-zone";
import { PriceEstimate } from "../price-estimate";
import type { ProjectStep4Schema } from "@/lib/validations/project";
import type { UploadedFile } from "@/types/add-project";

/** Props for StepDetails component */
interface StepDetailsProps {
  form: UseFormReturn<ProjectStep4Schema>;
  files: UploadedFile[];
  onFilesChange: (files: UploadedFile[]) => void;
  wordCount: number;
  urgencyMultiplier: number;
  isSubmitting: boolean;
  onSubmit: () => void;
}

/** Step 4: Additional details and file uploads - Clean Professional Design */
export function StepDetails({
  form,
  files,
  onFilesChange,
  wordCount,
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

      {/* Additional Instructions */}
      <div className="space-y-2">
        <Label htmlFor="instructions">
          Additional Instructions <span className="text-muted-foreground font-normal">(Optional)</span>
        </Label>
        <Textarea
          id="instructions"
          placeholder="Any specific requirements, guidelines, or notes..."
          rows={5}
          {...form.register("instructions")}
          className="resize-none"
        />
        <p className="text-xs text-muted-foreground">
          Max 2000 characters
        </p>
      </div>

      {/* File Upload */}
      <div className="space-y-2">
        <Label>
          Attach Files <span className="text-muted-foreground font-normal">(Optional, max 5)</span>
        </Label>
        <FileUploadZone files={files} onFilesChange={onFilesChange} maxFiles={5} />
      </div>

      {/* Price Estimate */}
      <PriceEstimate wordCount={wordCount} urgencyMultiplier={urgencyMultiplier} />

      {/* Submit Button */}
      <Button type="submit" disabled={isSubmitting} className="w-full h-12 text-sm font-medium mt-8">
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
