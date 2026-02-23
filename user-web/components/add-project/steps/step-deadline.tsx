"use client";

import { UseFormReturn } from "react-hook-form";
import { motion } from "framer-motion";
import { ArrowRight } from "lucide-react";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { DeadlinePicker } from "../deadline-picker";
import { PriceEstimate } from "../price-estimate";
import { urgencyLevels, type ProjectStep3Schema } from "@/lib/validations/project";
import { cn } from "@/lib/utils";

/** Props for StepDeadline component */
interface StepDeadlineProps {
  form: UseFormReturn<ProjectStep3Schema>;
  wordCount: number;
  onSubmit: () => void;
}

/** Step 3: Deadline and urgency selection - Clean Professional Design */
export function StepDeadline({ form, wordCount, onSubmit }: StepDeadlineProps) {
  const selectedUrgency = urgencyLevels.find((u) => u.value === form.watch("urgency"));
  const urgencyMultiplier = selectedUrgency?.multiplier || 1;

  return (
    <motion.form
      key="step3"
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
          Timeline
        </h2>
        <p className="mt-2 text-sm text-muted-foreground">
          Choose your deadline and urgency level
        </p>
      </div>

      {/* Deadline */}
      <div className="space-y-2">
        <Label>Deadline</Label>
        <DeadlinePicker
          value={form.watch("deadline")}
          onChange={(date) => form.setValue("deadline", date!)}
          error={form.formState.errors.deadline?.message}
        />
      </div>

      {/* Urgency Level */}
      <div className="space-y-3">
        <Label>Urgency Level</Label>
        <RadioGroup
          value={form.watch("urgency")}
          onValueChange={(v) => form.setValue("urgency", v as "standard")}
          className="space-y-2"
        >
          {urgencyLevels.map((level) => (
            <div
              key={level.value}
              className={cn(
                "relative flex items-center gap-3 p-4 rounded-lg border cursor-pointer transition-colors",
                form.watch("urgency") === level.value
                  ? "border-foreground bg-muted"
                  : "border-border hover:bg-muted/50"
              )}
            >
              <RadioGroupItem value={level.value} id={level.value} />
              <label htmlFor={level.value} className="flex-1 cursor-pointer">
                <div className="font-medium text-sm">{level.label}</div>
                {level.multiplier > 1 && (
                  <div className="text-xs text-muted-foreground mt-0.5">
                    +{Math.round((level.multiplier - 1) * 100)}% fee
                  </div>
                )}
              </label>
            </div>
          ))}
        </RadioGroup>
      </div>

      {/* Price Estimate */}
      <PriceEstimate wordCount={wordCount} urgencyMultiplier={urgencyMultiplier} />

      {/* Continue Button */}
      <Button type="submit" className="w-full h-12 text-sm font-medium mt-8">
        Continue
        <ArrowRight className="ml-2 h-4 w-4" />
      </Button>
    </motion.form>
  );
}
