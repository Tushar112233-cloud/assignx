"use client";

import { UseFormReturn } from "react-hook-form";
import { motion } from "framer-motion";
import {
  ArrowRight,
  GraduationCap,
  FileText,
  Globe,
  Smartphone,
  MessageSquare,
} from "lucide-react";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { SubjectSelector } from "../subject-selector";
import type { ProjectStep1Schema } from "@/lib/validations/project";
import type { ProjectType } from "@/types/add-project";

/** Project type card configuration */
const projectTypeCards: {
  value: ProjectType;
  label: string;
  description: string;
  icon: typeof GraduationCap;
  color: string;
}[] = [
  {
    value: "assignment",
    label: "Assignment",
    description: "Academic work, essays, homework",
    icon: GraduationCap,
    color: "bg-violet-500/10 text-violet-600 border-violet-200 dark:border-violet-800",
  },
  {
    value: "document",
    label: "Document",
    description: "Reports, thesis, papers",
    icon: FileText,
    color: "bg-blue-500/10 text-blue-600 border-blue-200 dark:border-blue-800",
  },
  {
    value: "website",
    label: "Website",
    description: "Web development projects",
    icon: Globe,
    color: "bg-emerald-500/10 text-emerald-600 border-emerald-200 dark:border-emerald-800",
  },
  {
    value: "app",
    label: "App",
    description: "Mobile or web applications",
    icon: Smartphone,
    color: "bg-orange-500/10 text-orange-600 border-orange-200 dark:border-orange-800",
  },
  {
    value: "consultancy",
    label: "Consultancy",
    description: "Expert consultation",
    icon: MessageSquare,
    color: "bg-pink-500/10 text-pink-600 border-pink-200 dark:border-pink-800",
  },
];

/** Topic placeholder text based on project type */
const topicPlaceholders: Record<ProjectType, string> = {
  assignment: "e.g., Impact of Social Media on Mental Health",
  document: "e.g., Annual financial report for Q4 2025",
  website: "e.g., E-commerce store for handmade jewelry",
  app: "e.g., Fitness tracking app with meal planning",
  consultancy: "e.g., Career guidance in data science",
};

/** Props for StepSubject component */
interface StepSubjectProps {
  form: UseFormReturn<ProjectStep1Schema>;
  onSubmit: () => void;
}

/** Step 1: Project type, subject, and topic selection */
export function StepSubject({ form, onSubmit }: StepSubjectProps) {
  const selectedType = form.watch("projectType") as ProjectType | undefined;
  const selectedSubject = form.watch("subject");

  const placeholder = selectedType
    ? topicPlaceholders[selectedType]
    : "e.g., Impact of Social Media on Mental Health";

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
          Project Details
        </h2>
        <p className="mt-2 text-sm text-muted-foreground">
          What kind of project do you need help with?
        </p>
      </div>

      {/* Project Type Selection */}
      <div className="space-y-3">
        <Label>Project Type</Label>
        <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
          {projectTypeCards.map((card) => {
            const isSelected = selectedType === card.value;
            const Icon = card.icon;
            return (
              <motion.button
                key={card.value}
                type="button"
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                onClick={() => form.setValue("projectType", card.value, { shouldValidate: true })}
                className={cn(
                  "relative flex flex-col items-center gap-2 rounded-xl border-2 p-4 text-center transition-all cursor-pointer",
                  isSelected
                    ? cn(card.color, "ring-2 ring-offset-2 ring-violet-500/40")
                    : "border-border bg-card hover:border-muted-foreground/30 hover:bg-muted/30"
                )}
              >
                <div
                  className={cn(
                    "flex h-10 w-10 items-center justify-center rounded-lg",
                    isSelected ? card.color : "bg-muted text-muted-foreground"
                  )}
                >
                  <Icon className="h-5 w-5" />
                </div>
                <span className="text-sm font-semibold">{card.label}</span>
                <span className="text-[11px] text-muted-foreground leading-tight">
                  {card.description}
                </span>
              </motion.button>
            );
          })}
        </div>
        {form.formState.errors.projectType && (
          <p className="text-xs text-destructive">
            {form.formState.errors.projectType.message}
          </p>
        )}
      </div>

      {/* Subject Area */}
      <div className="space-y-2">
        <Label htmlFor="subject">Subject Area</Label>
        <SubjectSelector
          value={selectedSubject}
          onChange={(value) => {
            form.setValue("subject", value, { shouldValidate: true });
            if (value !== "other") {
              form.setValue("customSubject", "", { shouldValidate: true });
            }
          }}
          customSubject={form.watch("customSubject")}
          onCustomSubjectChange={(value) =>
            form.setValue("customSubject", value, { shouldValidate: true })
          }
          error={form.formState.errors.subject?.message}
          customSubjectError={form.formState.errors.customSubject?.message}
        />
      </div>

      {/* Topic/Title */}
      <div className="space-y-2">
        <Label htmlFor="topic">Topic / Title</Label>
        <Input
          id="topic"
          placeholder={placeholder}
          {...form.register("topic")}
          className={form.formState.errors.topic ? "border-destructive" : ""}
        />
        {form.formState.errors.topic && (
          <p className="text-xs text-destructive">
            {form.formState.errors.topic.message}
          </p>
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
