"use client";

import { UseFormReturn } from "react-hook-form";
import { motion } from "framer-motion";
import { ArrowRight } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import {
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue,
} from "@/components/ui/select";
import { referenceStyles, type ProjectStep2Schema } from "@/lib/validations/project";

/** Props for StepRequirements component */
interface StepRequirementsProps {
  form: UseFormReturn<ProjectStep2Schema>;
  onSubmit: () => void;
}

/** Step 2: Word count and reference requirements - Clean Professional Design */
export function StepRequirements({ form, onSubmit }: StepRequirementsProps) {
  const selectedStyle = form.watch("referenceStyle");

  return (
    <motion.form
      key="step2"
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
          Requirements
        </h2>
        <p className="mt-2 text-sm text-muted-foreground">
          Specify word count and citation style
        </p>
      </div>

      {/* Word Count */}
      <div className="space-y-2">
        <Label htmlFor="wordCount">Word Count</Label>
        <Input
          id="wordCount"
          type="number"
          min={250}
          max={50000}
          placeholder="e.g., 1500"
          {...form.register("wordCount", { valueAsNumber: true })}
          className={form.formState.errors.wordCount ? "border-destructive" : ""}
        />
        {form.formState.errors.wordCount && (
          <p className="text-xs text-destructive">{form.formState.errors.wordCount.message}</p>
        )}
      </div>

      {/* Reference Style */}
      <div className="space-y-2">
        <Label>Reference Style</Label>
        <Select value={selectedStyle} onValueChange={(v) => form.setValue("referenceStyle", v as "apa7")}>
          <SelectTrigger className={form.formState.errors.referenceStyle ? "border-destructive" : ""}>
            <SelectValue placeholder="Select citation style" />
          </SelectTrigger>
          <SelectContent>
            {referenceStyles.map((style) => (
              <SelectItem key={style.value} value={style.value}>{style.label}</SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      {/* Number of References (conditional) */}
      {selectedStyle !== "none" && (
        <div className="space-y-2">
          <Label htmlFor="referenceCount">Number of References</Label>
          <Input
            id="referenceCount"
            type="number"
            min={0}
            max={100}
            placeholder="e.g., 10"
            {...form.register("referenceCount", { valueAsNumber: true })}
          />
        </div>
      )}

      {/* Continue Button */}
      <Button type="submit" className="w-full h-12 text-sm font-medium mt-8">
        Continue
        <ArrowRight className="ml-2 h-4 w-4" />
      </Button>
    </motion.form>
  );
}
