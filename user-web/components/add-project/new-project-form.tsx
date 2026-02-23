"use client";

import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { AnimatePresence } from "framer-motion";
import { StepSubject, StepRequirements, StepDeadline, StepDetails } from "./steps";
import {
  projectStep1Schema,
  projectStep2Schema,
  projectStep3Schema,
  projectStep4Schema,
  urgencyLevels,
  type ProjectFormSchema,
  type ProjectStep1Schema,
  type ProjectStep2Schema,
  type ProjectStep3Schema,
  type ProjectStep4Schema,
} from "@/lib/validations/project";
import { createProject, uploadProjectFile } from "@/lib/actions/data";
import type { UploadedFile } from "@/types/add-project";
import { toast } from "sonner";

/** Props for NewProjectForm component */
interface NewProjectFormProps {
  onSuccess: (projectId: string, projectNumber: string) => void;
  onStepChange?: (step: number) => void;
  /** Controlled step from parent (optional - uses internal state if not provided) */
  currentStep?: number;
}

/**
 * Multi-step new project submission form
 * Guides users through 4 steps to submit a project
 */
export function NewProjectForm({ onSuccess, onStepChange, currentStep: controlledStep }: NewProjectFormProps) {
  const [internalStep, setInternalStep] = useState(0);

  // Use controlled step if provided, otherwise use internal state
  const currentStep = controlledStep ?? internalStep;

  // Notify parent of step changes
  const updateStep = (step: number) => {
    setInternalStep(step);
    onStepChange?.(step);
  };
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [files, setFiles] = useState<UploadedFile[]>([]);
  const [formData, setFormData] = useState<Partial<ProjectFormSchema>>({
    referenceStyle: "apa7",
    urgency: "standard",
    referenceCount: 10,
  });

  const step1Form = useForm<ProjectStep1Schema>({
    resolver: zodResolver(projectStep1Schema),
    defaultValues: { subject: formData.subject || "", topic: formData.topic || "" },
  });

  const step2Form = useForm<ProjectStep2Schema>({
    resolver: zodResolver(projectStep2Schema),
    defaultValues: {
      wordCount: formData.wordCount || 1000,
      referenceStyle: formData.referenceStyle || "apa7",
      referenceCount: formData.referenceCount || 10,
    },
  });

  const step3Form = useForm<ProjectStep3Schema>({
    resolver: zodResolver(projectStep3Schema),
    defaultValues: { deadline: formData.deadline, urgency: formData.urgency || "standard" },
  });

  const step4Form = useForm<ProjectStep4Schema>({
    resolver: zodResolver(projectStep4Schema),
    defaultValues: { instructions: formData.instructions || "" },
  });

  /** Handles step 1 submission */
  const handleStep1Submit = step1Form.handleSubmit((data) => {
    setFormData((prev) => ({ ...prev, ...data }));
    updateStep(1);
  });

  /** Handles step 2 submission */
  const handleStep2Submit = step2Form.handleSubmit((data) => {
    setFormData((prev) => ({ ...prev, ...data }));
    updateStep(2);
  });

  /** Handles step 3 submission */
  const handleStep3Submit = step3Form.handleSubmit((data) => {
    setFormData((prev) => ({ ...prev, ...data }));
    updateStep(3);
  });

  /** Handles final form submission */
  const handleFinalSubmit = step4Form.handleSubmit(async (data) => {
    setIsSubmitting(true);
    try {
      // Combine all form data
      const allFormData = {
        ...formData,
        instructions: data.instructions,
      };

      // Create project in database
      const result = await createProject({
        serviceType: "new_project",
        title: allFormData.topic || `Project - ${allFormData.subject}`,
        subjectId: allFormData.subject,
        topic: allFormData.topic,
        wordCount: allFormData.wordCount,
        referenceStyleId: allFormData.referenceStyle,
        deadline: allFormData.deadline
          ? new Date(allFormData.deadline).toISOString()
          : new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
        urgencyLevel: allFormData.urgency,
        instructions: allFormData.instructions,
      });

      if (result.error) {
        toast.error(result.error);
        setIsSubmitting(false);
        return;
      }

      // Upload files if any
      if (files.length > 0 && result.projectId) {
        for (const uploadedFile of files) {
          try {
            // Convert File to base64
            const fileData = uploadedFile.file;
            const base64 = await new Promise<string>((resolve, reject) => {
              const reader = new FileReader();
              reader.onload = () => {
                const result = reader.result as string;
                // Remove data URL prefix to get just the base64 data
                const base64Data = result.split(",")[1];
                resolve(base64Data);
              };
              reader.onerror = reject;
              reader.readAsDataURL(fileData);
            });

            // Upload file to storage
            const uploadResult = await uploadProjectFile(result.projectId, {
              name: uploadedFile.name,
              type: uploadedFile.type,
              size: uploadedFile.size,
              base64Data: base64,
            });

            if (uploadResult.error) {
              toast.error(`Failed to upload ${uploadedFile.name}: ${uploadResult.error}`);
            }
          } catch {
            toast.error(`Failed to upload ${uploadedFile.name}`);
          }
        }
      }

      // Success - redirect
      onSuccess(result.projectId!, result.projectNumber!);
    } catch {
      toast.error("Something went wrong. Please try again.");
      setIsSubmitting(false);
    }
  });

  const selectedUrgency = urgencyLevels.find((u) => u.value === step3Form.watch("urgency"));
  const urgencyMultiplier = selectedUrgency?.multiplier || 1;

  return (
    <div className="flex flex-col">
      <AnimatePresence mode="wait">
        {currentStep === 0 && <StepSubject form={step1Form} onSubmit={handleStep1Submit} />}
        {currentStep === 1 && <StepRequirements form={step2Form} onSubmit={handleStep2Submit} />}
        {currentStep === 2 && <StepDeadline form={step3Form} wordCount={step2Form.getValues("wordCount") || 0} onSubmit={handleStep3Submit} />}
        {currentStep === 3 && (
          <StepDetails
            form={step4Form}
            files={files}
            onFilesChange={setFiles}
            wordCount={step2Form.getValues("wordCount") || 0}
            urgencyMultiplier={urgencyMultiplier}
            isSubmitting={isSubmitting}
            onSubmit={handleFinalSubmit}
          />
        )}
      </AnimatePresence>
    </div>
  );
}
