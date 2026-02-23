"use client";

import { useState, Suspense } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import { Loader2, FileText, Bot, FileSearch, Clock, Sparkles, CheckCircle2, MessageSquare } from "lucide-react";
import {
  NewProjectForm,
  ProofreadingForm,
  ReportForm,
  ConsultationForm,
  SubmissionSuccess,
} from "@/components/add-project";
import { FormLayout } from "@/components/add-project/form-layout";
import type { ServiceType } from "@/types/add-project";

/**
 * Service configurations for different form types
 */
const serviceConfigs: Record<ServiceType, {
  title: string;
  accentWord: string;
  subtitle: string;
  floatingCards: Array<{
    icon: React.ReactNode;
    title: string;
    value: string;
    label?: string;
    position: 1 | 2 | 3;
    iconBg?: string;
  }>;
}> = {
  project: {
    title: "Create Your Academic Project",
    accentWord: "Academic",
    subtitle: "Tell us about your project requirements and we'll match you with the perfect expert tutor.",
    floatingCards: [
      {
        icon: <FileText className="w-5 h-5 text-white" />,
        title: "Projects",
        value: "500+",
        label: "Completed",
        position: 1,
        iconBg: "bg-primary",
      },
      {
        icon: <Clock className="w-5 h-5 text-white" />,
        title: "Avg. Delivery",
        value: "48h",
        label: "Turnaround",
        position: 2,
        iconBg: "bg-accent",
      },
      {
        icon: <CheckCircle2 className="w-5 h-5 text-white" />,
        title: "Success Rate",
        value: "98%",
        label: "Satisfaction",
        position: 3,
        iconBg: "bg-success",
      },
    ],
  },
  proofreading: {
    title: "Professional Proofreading Service",
    accentWord: "Proofreading",
    subtitle: "Get your documents polished by expert editors with attention to detail.",
    floatingCards: [
      {
        icon: <FileText className="w-5 h-5 text-white" />,
        title: "Documents",
        value: "10K+",
        label: "Proofread",
        position: 1,
        iconBg: "bg-primary",
      },
      {
        icon: <Clock className="w-5 h-5 text-white" />,
        title: "Turnaround",
        value: "24h",
        label: "Express",
        position: 2,
        iconBg: "bg-accent",
      },
      {
        icon: <CheckCircle2 className="w-5 h-5 text-white" />,
        title: "Accuracy",
        value: "99%",
        label: "Error-free",
        position: 3,
        iconBg: "bg-success",
      },
    ],
  },
  report: {
    title: "AI & Plagiarism Detection Report",
    accentWord: "Detection",
    subtitle: "Verify the originality and authenticity of your content with our comprehensive reports.",
    floatingCards: [
      {
        icon: <Bot className="w-5 h-5 text-white" />,
        title: "AI Detection",
        value: "98%",
        label: "Accuracy",
        position: 1,
        iconBg: "bg-primary",
      },
      {
        icon: <FileSearch className="w-5 h-5 text-white" />,
        title: "Plagiarism",
        value: "100M+",
        label: "Sources",
        position: 2,
        iconBg: "bg-accent",
      },
      {
        icon: <Clock className="w-5 h-5 text-white" />,
        title: "Delivery",
        value: "24h",
        label: "Report Ready",
        position: 3,
        iconBg: "bg-success",
      },
    ],
  },
  consultation: {
    title: "Expert Consultation Session",
    accentWord: "Expert",
    subtitle: "Get personalized guidance from subject matter experts for your academic questions.",
    floatingCards: [
      {
        icon: <MessageSquare className="w-5 h-5 text-white" />,
        title: "Questions",
        value: "5K+",
        label: "Answered",
        position: 1,
        iconBg: "bg-primary",
      },
      {
        icon: <Sparkles className="w-5 h-5 text-white" />,
        title: "Experts",
        value: "200+",
        label: "Available",
        position: 2,
        iconBg: "bg-accent",
      },
      {
        icon: <Clock className="w-5 h-5 text-white" />,
        title: "Response",
        value: "48h",
        label: "Guaranteed",
        position: 3,
        iconBg: "bg-success",
      },
    ],
  },
};

/**
 * Step labels for each service type
 */
const stepLabels: Record<ServiceType, string[]> = {
  project: ["Subject", "Requirements", "Deadline", "Details"],
  proofreading: ["Document", "Deadline", "Review"],
  report: ["Report Type", "Upload", "Review"],
  consultation: ["Topic", "Question", "Review"],
};

/**
 * Inner component that uses searchParams
 */
function NewProjectContent() {
  const searchParams = useSearchParams();
  const router = useRouter();
  const typeParam = searchParams.get("type");

  // Determine service type from URL param
  // Support aliases: plagiarism -> report, ai -> report
  const serviceType: ServiceType =
    typeParam === "proofreading" ? "proofreading" :
    typeParam === "report" || typeParam === "plagiarism" || typeParam === "ai" ? "report" :
    typeParam === "consultation" ? "consultation" :
    "project";

  const [success, setSuccess] = useState<{
    projectId: string;
    projectNumber: string;
  } | null>(null);

  const [currentStep, setCurrentStep] = useState(0);

  const handleSuccess = (projectId: string, projectNumber: string) => {
    setSuccess({ projectId, projectNumber });
  };

  const handleStepChange = (step: number) => {
    setCurrentStep(step);
  };

  const handleBack = () => {
    if (currentStep > 0) {
      setCurrentStep(currentStep - 1);
    } else {
      router.back();
    }
  };

  // Show success screen if submission was successful
  if (success) {
    return (
      <SubmissionSuccess
        projectId={success.projectId}
        projectNumber={success.projectNumber}
        serviceType={serviceType}
      />
    );
  }

  const config = serviceConfigs[serviceType];
  const steps = stepLabels[serviceType];
  const totalSteps = steps.length;

  // Render appropriate form based on service type
  const renderForm = () => {
    switch (serviceType) {
      case "project":
        return (
          <NewProjectForm
            onSuccess={handleSuccess}
            onStepChange={handleStepChange}
            currentStep={currentStep}
          />
        );
      case "proofreading":
        return (
          <ProofreadingForm
            onSuccess={handleSuccess}
            onStepChange={handleStepChange}
          />
        );
      case "report":
        return (
          <ReportForm
            onSuccess={handleSuccess}
            onStepChange={handleStepChange}
          />
        );
      case "consultation":
        return (
          <ConsultationForm
            onSuccess={handleSuccess}
            onStepChange={handleStepChange}
          />
        );
      default:
        return null;
    }
  };

  return (
    <FormLayout
      title={config.title}
      accentWord={config.accentWord}
      subtitle={config.subtitle}
      currentStep={currentStep}
      totalSteps={totalSteps}
      stepLabels={steps}
      floatingCards={config.floatingCards}
      onBack={handleBack}
      showBack={true}
      serviceType={serviceType}
    >
      {renderForm()}
    </FormLayout>
  );
}

/**
 * New Project Page
 * Handles different service types based on URL query param:
 * - /projects/new - New project form
 * - /projects/new?type=proofreading - Proofreading form
 * - /projects/new?type=report - AI/Plagiarism report form
 * - /projects/new?type=consultation - Expert opinion form
 */
export default function NewProjectPage() {
  return (
    <Suspense
      fallback={
        <div className="min-h-screen bg-background flex items-center justify-center">
          <div className="flex flex-col items-center gap-4">
            <Loader2 className="h-8 w-8 animate-spin text-primary" />
            <p className="text-sm text-muted-foreground">Loading...</p>
          </div>
        </div>
      }
    >
      <NewProjectContent />
    </Suspense>
  );
}
