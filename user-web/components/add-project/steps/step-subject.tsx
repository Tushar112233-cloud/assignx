"use client";

import { UseFormReturn } from "react-hook-form";
import { motion } from "framer-motion";
import { ArrowRight } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { SubjectSelector } from "../subject-selector";
import type { ProjectStep1Schema } from "@/lib/validations/project";

/** Props for StepSubject component */
interface StepSubjectProps {
  form: UseFormReturn<ProjectStep1Schema>;
  onSubmit: () => void;
}

/** Step 1: Subject and topic selection - Clean Professional Design */
export function StepSubject({ form, onSubmit }: StepSubjectProps) {
  return (
    <motion.form
      key="step1"
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
          Subject & Topic
        </h2>
        <p className="mt-2 text-sm text-muted-foreground">
          Tell us about your project
        </p>
      </div>

      {/* Subject Area */}
      <div className="space-y-2">
        <Label htmlFor="subject">Subject Area</Label>
        <SubjectSelector
          value={form.watch("subject")}
          onChange={(value) => form.setValue("subject", value)}
          error={form.formState.errors.subject?.message}
        />
        {form.formState.errors.subject && (
          <p className="text-xs text-destructive">{form.formState.errors.subject.message}</p>
        )}
      </div>

      {/* Topic/Title */}
      <div className="space-y-2">
        <Label htmlFor="topic">Topic / Title</Label>
        <Input
          id="topic"
          placeholder="e.g., Impact of Social Media on Mental Health"
          {...form.register("topic")}
          className={form.formState.errors.topic ? "border-destructive" : ""}
        />
        {form.formState.errors.topic && (
          <p className="text-xs text-destructive">{form.formState.errors.topic.message}</p>
        )}
      </div>

      {/* Continue Button */}
      <Button type="submit" className="w-full h-12 text-sm font-medium mt-8">
        Continue
        <ArrowRight className="ml-2 h-4 w-4" />
      </Button>
    </motion.form>
  );
}
