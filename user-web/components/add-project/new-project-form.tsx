"use client";

import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { AnimatePresence } from "framer-motion";
import { StepSubject, StepRequirements, StepDeadline, StepDetails } from "./steps";
import {
  projectStep1Schema,
  createStep2Schema,
  projectStep3Schema,
  projectStep4Schema,
  urgencyLevels,
  type ProjectFormSchema,
  type ProjectStep1Schema,
  type ProjectStep2Schema,
  type ProjectStep3Schema,
  type ProjectStep4Schema,
} from "@/lib/validations/project";
import type { ProjectType } from "@/types/add-project";
import { createProject, createProjectFileRecord } from "@/lib/actions/data";
import { apiClient } from "@/lib/api/client";
import { sanitizeFileName } from "@/lib/validations/file-upload";
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
    defaultValues: {
      projectType: formData.projectType ?? "assignment",
      subject: formData.subject || "",
      customSubject: formData.customSubject ?? "",
      topic: formData.topic || "",
    },
  });

  // Get the projectType from step 1 data (set after step 1 is submitted)
  const selectedProjectType = (formData.projectType ?? "assignment") as ProjectType;

  const step2Form = useForm<ProjectStep2Schema>({
    resolver: (values, context, options) => {
      const schema = createStep2Schema(selectedProjectType);
      return zodResolver(schema)(values, context, options);
    },
    defaultValues: {
      wordCount: formData.wordCount ?? 1000,
      referenceStyle: formData.referenceStyle ?? "apa7",
      referenceCount: formData.referenceCount ?? 10,
      websiteFeatures: [],
    },
  });

  const step3Form = useForm<ProjectStep3Schema>({
    resolver: zodResolver(projectStep3Schema),
    defaultValues: { deadline: formData.deadline, urgency: formData.urgency || "standard" },
  });

  const step4Form = useForm<ProjectStep4Schema>({
    resolver: zodResolver(projectStep4Schema),
    defaultValues: {
      instructions: formData.instructions || "",
      colorScheme: "",
      targetAudience: "",
      expertQualification: undefined,
    },
  });

  /** Handles step 1 submission - resets step 2 if project type changed */
  const handleStep1Submit = step1Form.handleSubmit((data) => {
    const previousType = formData.projectType;
    setFormData((prev) => ({ ...prev, ...data }));

    // Reset step 2 form when project type changes
    if (previousType && previousType !== data.projectType) {
      step2Form.reset({
        wordCount: undefined,
        referenceStyle: undefined,
        referenceCount: undefined,
        documentType: undefined,
        pageCount: undefined,
        techStack: undefined,
        websiteFeatures: [],
        designReferenceUrl: "",
        platform: undefined,
        appFeatures: undefined,
        appDesignUrl: "",
        backendRequirements: undefined,
        consultationDuration: undefined,
        questionSummary: undefined,
        preferredDate: undefined,
        preferredTime: undefined,
      });
    }

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
      // Combine all form data including step 4 type-specific fields
      const allFormData = {
        ...formData,
        instructions: data.instructions,
        colorScheme: data.colorScheme,
        targetAudience: data.targetAudience,
        expertQualification: data.expertQualification,
      };

      // Create project in database with all type-specific fields
      const result = await createProject({
        serviceType: "new_project",
        projectType: allFormData.projectType,
        title: allFormData.topic || `Project - ${allFormData.subject}`,
        subjectId: allFormData.subject,
        customSubject: allFormData.subject === "other" ? allFormData.customSubject : undefined,
        topic: allFormData.topic,
        wordCount: allFormData.wordCount,
        referenceStyleId: allFormData.referenceStyle,
        deadline: allFormData.deadline
          ? new Date(allFormData.deadline).toISOString()
          : new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
        urgencyLevel: allFormData.urgency,
        instructions: allFormData.instructions,
        // Type-specific fields from step 2
        documentType: allFormData.documentType,
        pageCount: allFormData.pageCount,
        techStack: allFormData.techStack,
        websiteFeatures: allFormData.websiteFeatures,
        designReferenceUrl: allFormData.designReferenceUrl || allFormData.appDesignUrl,
        platform: allFormData.platform,
        appFeatures: allFormData.appFeatures,
        backendRequirements: allFormData.backendRequirements,
        consultationDuration: allFormData.consultationDuration,
        questionSummary: allFormData.questionSummary,
        preferredDate: allFormData.preferredDate,
        preferredTime: allFormData.preferredTime,
        // Type-specific fields from step 4
        colorScheme: allFormData.colorScheme,
        targetAudience: allFormData.targetAudience,
        expertQualification: allFormData.expertQualification,
      });

      if (result.error) {
        toast.error(result.error);
        setIsSubmitting(false);
        return;
      }

      // Upload files via API (Cloudinary)
      const projectId = result.project?.id || result.project?._id;
      if (files.length > 0 && projectId) {

        // Update file statuses to uploading
        setFiles((prev) =>
          prev.map((f) => ({ ...f, status: "uploading" as const, progress: 0 }))
        );

        for (let i = 0; i < files.length; i++) {
          const uploadedFile = files[i];
          try {
            const safeName = sanitizeFileName(uploadedFile.name);

            // Upload via API
            const formData = new FormData();
            formData.append("file", uploadedFile.file);
            formData.append("folder", `project-files/${projectId}`);

            const uploadResult = await apiClient("/api/upload", {
              method: "POST",
              body: formData,
              isFormData: true,
            });

            if (!uploadResult?.url) {
              setFiles((prev) =>
                prev.map((f) =>
                  f.id === uploadedFile.id
                    ? { ...f, status: "error" as const, errorMessage: "Upload failed" }
                    : f
                )
              );
              toast.error(`Failed to upload ${uploadedFile.name}`);
              continue;
            }

            // Create DB record via server action
            const recordResult = await createProjectFileRecord(projectId, {
              fileName: safeName,
              fileUrl: uploadResult.url,
              fileType: uploadedFile.type,
              fileSizeBytes: uploadedFile.size,
              fileCategory: "user_upload",
            });

            if (recordResult.error) {
              toast.error(`Failed to save record for ${uploadedFile.name}`);
            }

            // Mark file as complete
            setFiles((prev) =>
              prev.map((f) =>
                f.id === uploadedFile.id
                  ? { ...f, status: "complete" as const, progress: 100 }
                  : f
              )
            );
          } catch {
            setFiles((prev) =>
              prev.map((f) =>
                f.id === uploadedFile.id
                  ? { ...f, status: "error" as const, errorMessage: "Upload failed" }
                  : f
              )
            );
            toast.error(`Failed to upload ${uploadedFile.name}`);
          }
        }
      }

      // Success - redirect
      const projectNumber = result.project?.project_number || result.project?.projectNumber;
      onSuccess(projectId || result.project?.id, projectNumber);
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
        {currentStep === 1 && <StepRequirements form={step2Form} projectType={selectedProjectType} onSubmit={handleStep2Submit} />}
        {currentStep === 2 && (
          <StepDeadline
            form={step3Form}
            projectType={selectedProjectType}
            requirements={step2Form.getValues()}
            onSubmit={handleStep3Submit}
          />
        )}
        {currentStep === 3 && (
          <StepDetails
            form={step4Form}
            files={files}
            onFilesChange={setFiles}
            projectType={selectedProjectType}
            requirements={step2Form.getValues()}
            urgencyMultiplier={urgencyMultiplier}
            isSubmitting={isSubmitting}
            onSubmit={handleFinalSubmit}
          />
        )}
      </AnimatePresence>
    </div>
  );
}
