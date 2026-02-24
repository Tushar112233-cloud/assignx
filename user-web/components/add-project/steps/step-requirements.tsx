"use client";

import { UseFormReturn } from "react-hook-form";
import { motion } from "framer-motion";
import { ArrowRight } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Checkbox } from "@/components/ui/checkbox";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import {
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue,
} from "@/components/ui/select";
import {
  referenceStyles,
  documentTypes,
  techStackOptions,
  websiteFeatureOptions,
  platformOptions,
  consultationDurations,
  type ProjectStep2Schema,
} from "@/lib/validations/project";
import type { ProjectType } from "@/types/add-project";
import { cn } from "@/lib/utils";

/** Subtitle text per project type */
const subtitles: Record<ProjectType, string> = {
  assignment: "Specify word count and citation style",
  document: "Select document type and formatting preferences",
  website: "Define pages, tech stack, and features",
  app: "Choose platform and describe features",
  consultancy: "Set duration and describe your questions",
};

/** Props for StepRequirements component */
interface StepRequirementsProps {
  form: UseFormReturn<ProjectStep2Schema>;
  projectType: ProjectType;
  onSubmit: () => void;
}

/** Step 2: Requirements - Dynamic fields based on project type */
export function StepRequirements({ form, projectType, onSubmit }: StepRequirementsProps) {
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
          {subtitles[projectType]}
        </p>
      </div>

      {/* Dynamic fields per project type */}
      {projectType === "assignment" && <AssignmentFields form={form} />}
      {projectType === "document" && <DocumentFields form={form} />}
      {projectType === "website" && <WebsiteFields form={form} />}
      {projectType === "app" && <AppFields form={form} />}
      {projectType === "consultancy" && <ConsultancyFields form={form} />}

      {/* Continue Button */}
      <Button type="submit" className="w-full h-12 text-sm font-medium mt-8">
        Continue
        <ArrowRight className="ml-2 h-4 w-4" />
      </Button>
    </motion.form>
  );
}

/** Assignment: word count, reference style, reference count */
function AssignmentFields({ form }: { form: UseFormReturn<ProjectStep2Schema> }) {
  const selectedStyle = form.watch("referenceStyle");

  return (
    <>
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
        <Select value={selectedStyle ?? ""} onValueChange={(v) => form.setValue("referenceStyle", v as "apa7")}>
          <SelectTrigger className={form.formState.errors.referenceStyle ? "border-destructive" : ""}>
            <SelectValue placeholder="Select citation style" />
          </SelectTrigger>
          <SelectContent>
            {referenceStyles.map((style) => (
              <SelectItem key={style.value} value={style.value}>{style.label}</SelectItem>
            ))}
          </SelectContent>
        </Select>
        {form.formState.errors.referenceStyle && (
          <p className="text-xs text-destructive">{form.formState.errors.referenceStyle.message}</p>
        )}
      </div>

      {/* Number of References */}
      {selectedStyle && selectedStyle !== "none" && (
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
    </>
  );
}

/** Document: document type, word count, reference style, reference count */
function DocumentFields({ form }: { form: UseFormReturn<ProjectStep2Schema> }) {
  const selectedStyle = form.watch("referenceStyle");
  const selectedDocType = form.watch("documentType");

  return (
    <>
      {/* Document Type */}
      <div className="space-y-2">
        <Label>Document Type</Label>
        <Select value={selectedDocType ?? ""} onValueChange={(v) => form.setValue("documentType", v)}>
          <SelectTrigger className={form.formState.errors.documentType ? "border-destructive" : ""}>
            <SelectValue placeholder="Select document type" />
          </SelectTrigger>
          <SelectContent>
            {documentTypes.map((dt) => (
              <SelectItem key={dt.value} value={dt.value}>{dt.label}</SelectItem>
            ))}
          </SelectContent>
        </Select>
        {form.formState.errors.documentType && (
          <p className="text-xs text-destructive">{form.formState.errors.documentType.message}</p>
        )}
      </div>

      {/* Word Count */}
      <div className="space-y-2">
        <Label htmlFor="wordCount">Word Count</Label>
        <Input
          id="wordCount"
          type="number"
          min={250}
          max={50000}
          placeholder="e.g., 3000"
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
        <Select value={selectedStyle ?? ""} onValueChange={(v) => form.setValue("referenceStyle", v as "apa7")}>
          <SelectTrigger className={form.formState.errors.referenceStyle ? "border-destructive" : ""}>
            <SelectValue placeholder="Select citation style" />
          </SelectTrigger>
          <SelectContent>
            {referenceStyles.map((style) => (
              <SelectItem key={style.value} value={style.value}>{style.label}</SelectItem>
            ))}
          </SelectContent>
        </Select>
        {form.formState.errors.referenceStyle && (
          <p className="text-xs text-destructive">{form.formState.errors.referenceStyle.message}</p>
        )}
      </div>

      {/* Number of References */}
      {selectedStyle && selectedStyle !== "none" && (
        <div className="space-y-2">
          <Label htmlFor="referenceCount">Number of References</Label>
          <Input
            id="referenceCount"
            type="number"
            min={0}
            max={100}
            placeholder="e.g., 15"
            {...form.register("referenceCount", { valueAsNumber: true })}
          />
        </div>
      )}
    </>
  );
}

/** Website: page count, tech stack, features checklist, design URL */
function WebsiteFields({ form }: { form: UseFormReturn<ProjectStep2Schema> }) {
  const features = form.watch("websiteFeatures") ?? [];

  const toggleFeature = (value: string) => {
    const current = form.getValues("websiteFeatures") ?? [];
    if (current.includes(value)) {
      form.setValue("websiteFeatures", current.filter((f) => f !== value));
    } else {
      form.setValue("websiteFeatures", [...current, value]);
    }
  };

  return (
    <>
      {/* Number of Pages */}
      <div className="space-y-2">
        <Label htmlFor="pageCount">Number of Pages</Label>
        <Input
          id="pageCount"
          type="number"
          min={1}
          max={50}
          placeholder="e.g., 5"
          {...form.register("pageCount", { valueAsNumber: true })}
          className={form.formState.errors.pageCount ? "border-destructive" : ""}
        />
        {form.formState.errors.pageCount && (
          <p className="text-xs text-destructive">{form.formState.errors.pageCount.message}</p>
        )}
      </div>

      {/* Tech Stack */}
      <div className="space-y-2">
        <Label>Tech Stack Preference</Label>
        <Select value={form.watch("techStack") ?? ""} onValueChange={(v) => form.setValue("techStack", v)}>
          <SelectTrigger>
            <SelectValue placeholder="Select preferred tech stack (optional)" />
          </SelectTrigger>
          <SelectContent>
            {techStackOptions.map((opt) => (
              <SelectItem key={opt.value} value={opt.value}>{opt.label}</SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      {/* Website Features */}
      <div className="space-y-3">
        <Label>Key Features</Label>
        <div className="grid grid-cols-2 gap-2">
          {websiteFeatureOptions.map((feat) => (
            <div
              key={feat.value}
              className={cn(
                "flex items-center gap-3 p-3 rounded-lg border cursor-pointer transition-colors",
                features.includes(feat.value)
                  ? "border-foreground bg-muted"
                  : "border-border hover:bg-muted/50"
              )}
              onClick={() => toggleFeature(feat.value)}
            >
              <Checkbox
                id={`feature-${feat.value}`}
                checked={features.includes(feat.value)}
                onCheckedChange={() => toggleFeature(feat.value)}
              />
              <label htmlFor={`feature-${feat.value}`} className="text-sm cursor-pointer flex-1">
                {feat.label}
              </label>
            </div>
          ))}
        </div>
      </div>

      {/* Design Reference URL */}
      <div className="space-y-2">
        <Label htmlFor="designReferenceUrl">Design Reference URL</Label>
        <Input
          id="designReferenceUrl"
          type="text"
          placeholder="https://example.com (optional)"
          {...form.register("designReferenceUrl")}
          className={form.formState.errors.designReferenceUrl ? "border-destructive" : ""}
        />
        {form.formState.errors.designReferenceUrl && (
          <p className="text-xs text-destructive">{form.formState.errors.designReferenceUrl.message}</p>
        )}
      </div>
    </>
  );
}

/** App: platform, features description, design URL, backend requirements */
function AppFields({ form }: { form: UseFormReturn<ProjectStep2Schema> }) {
  const selectedPlatform = form.watch("platform");

  return (
    <>
      {/* Platform */}
      <div className="space-y-3">
        <Label>Platform</Label>
        <RadioGroup
          value={selectedPlatform ?? ""}
          onValueChange={(v) => form.setValue("platform", v)}
          className="space-y-2"
        >
          {platformOptions.map((opt) => (
            <div
              key={opt.value}
              className={cn(
                "relative flex items-center gap-3 p-4 rounded-lg border cursor-pointer transition-colors",
                selectedPlatform === opt.value
                  ? "border-foreground bg-muted"
                  : "border-border hover:bg-muted/50"
              )}
            >
              <RadioGroupItem value={opt.value} id={`platform-${opt.value}`} />
              <label htmlFor={`platform-${opt.value}`} className="flex-1 cursor-pointer">
                <div className="font-medium text-sm">{opt.label}</div>
              </label>
            </div>
          ))}
        </RadioGroup>
        {form.formState.errors.platform && (
          <p className="text-xs text-destructive">{form.formState.errors.platform.message}</p>
        )}
      </div>

      {/* Key Features Description */}
      <div className="space-y-2">
        <Label htmlFor="appFeatures">Key Features</Label>
        <Textarea
          id="appFeatures"
          placeholder="Describe the key features of your app (min 20 characters)"
          rows={4}
          {...form.register("appFeatures")}
          className={form.formState.errors.appFeatures ? "border-destructive" : ""}
        />
        {form.formState.errors.appFeatures && (
          <p className="text-xs text-destructive">{form.formState.errors.appFeatures.message}</p>
        )}
      </div>

      {/* Design Reference URL */}
      <div className="space-y-2">
        <Label htmlFor="appDesignUrl">Design Reference URL</Label>
        <Input
          id="appDesignUrl"
          type="text"
          placeholder="https://example.com (optional)"
          {...form.register("appDesignUrl")}
          className={form.formState.errors.appDesignUrl ? "border-destructive" : ""}
        />
        {form.formState.errors.appDesignUrl && (
          <p className="text-xs text-destructive">{form.formState.errors.appDesignUrl.message}</p>
        )}
      </div>

      {/* Backend Requirements */}
      <div className="space-y-2">
        <Label htmlFor="backendRequirements">Backend Requirements</Label>
        <Textarea
          id="backendRequirements"
          placeholder="Describe any backend/API requirements (optional)"
          rows={3}
          {...form.register("backendRequirements")}
        />
      </div>
    </>
  );
}

/** Consultancy: duration, question summary, preferred date/time */
function ConsultancyFields({ form }: { form: UseFormReturn<ProjectStep2Schema> }) {
  const selectedDuration = form.watch("consultationDuration");

  return (
    <>
      {/* Consultation Duration */}
      <div className="space-y-3">
        <Label>Consultation Duration</Label>
        <RadioGroup
          value={selectedDuration ?? ""}
          onValueChange={(v) => form.setValue("consultationDuration", v)}
          className="space-y-2"
        >
          {consultationDurations.map((dur) => (
            <div
              key={dur.value}
              className={cn(
                "relative flex items-center gap-3 p-4 rounded-lg border cursor-pointer transition-colors",
                selectedDuration === dur.value
                  ? "border-foreground bg-muted"
                  : "border-border hover:bg-muted/50"
              )}
            >
              <RadioGroupItem value={dur.value} id={`duration-${dur.value}`} />
              <label htmlFor={`duration-${dur.value}`} className="flex-1 cursor-pointer">
                <div className="font-medium text-sm">{dur.label}</div>
              </label>
            </div>
          ))}
        </RadioGroup>
        {form.formState.errors.consultationDuration && (
          <p className="text-xs text-destructive">{form.formState.errors.consultationDuration.message}</p>
        )}
      </div>

      {/* Question Summary */}
      <div className="space-y-2">
        <Label htmlFor="questionSummary">Question Summary</Label>
        <Textarea
          id="questionSummary"
          placeholder="Describe what you'd like to discuss (min 20 characters)"
          rows={4}
          {...form.register("questionSummary")}
          className={form.formState.errors.questionSummary ? "border-destructive" : ""}
        />
        {form.formState.errors.questionSummary && (
          <p className="text-xs text-destructive">{form.formState.errors.questionSummary.message}</p>
        )}
      </div>

      {/* Preferred Date */}
      <div className="space-y-2">
        <Label htmlFor="preferredDate">Preferred Date</Label>
        <Input
          id="preferredDate"
          type="date"
          {...form.register("preferredDate")}
          className={form.formState.errors.preferredDate ? "border-destructive" : ""}
        />
      </div>

      {/* Preferred Time */}
      <div className="space-y-2">
        <Label htmlFor="preferredTime">Preferred Time</Label>
        <Input
          id="preferredTime"
          type="time"
          placeholder="Optional"
          {...form.register("preferredTime")}
        />
      </div>
    </>
  );
}
