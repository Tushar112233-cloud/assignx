"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import {
  Check,
  Copy,
  ArrowRight,
  Home,
  FileText,
  Clock,
  Bell,
  MessageSquare,
  Shield,
  Zap,
  CheckCircle2,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { toast } from "sonner";
import { cn } from "@/lib/utils";

interface SubmissionSuccessProps {
  projectId: string;
  projectNumber: string;
  serviceType: "project" | "proofreading" | "report" | "consultation";
}

const serviceConfigs = {
  project: {
    title: "Project submitted",
    subtitle: "Your project is now being reviewed by our experts",
    icon: FileText,
    timeline: [
      {
        icon: Clock,
        title: "Under Review",
        description: "Expert analyzing your requirements",
        time: "Now",
        active: true,
      },
      {
        icon: Bell,
        title: "Quote Ready",
        description: "You'll receive pricing notification",
        time: "2-4 hours",
        active: false,
      },
      {
        icon: Zap,
        title: "Work Begins",
        description: "Expert starts your project",
        time: "After payment",
        active: false,
      },
      {
        icon: CheckCircle2,
        title: "Delivery",
        description: "Final work delivered to you",
        time: "Before deadline",
        active: false,
      },
    ],
  },
  proofreading: {
    title: "Document submitted",
    subtitle: "Your document is queued for professional proofreading",
    icon: FileText,
    timeline: [
      {
        icon: Clock,
        title: "In Queue",
        description: "Document received successfully",
        time: "Now",
        active: true,
      },
      {
        icon: Zap,
        title: "Proofreading",
        description: "Expert editor reviews your work",
        time: "In progress",
        active: false,
      },
      {
        icon: CheckCircle2,
        title: "Ready",
        description: "Polished document delivered",
        time: "By deadline",
        active: false,
      },
    ],
  },
  report: {
    title: "Analysis request submitted",
    subtitle: "Your document is being processed for detailed analysis",
    icon: Shield,
    timeline: [
      {
        icon: Clock,
        title: "Processing",
        description: "Document uploaded for analysis",
        time: "Now",
        active: true,
      },
      {
        icon: Zap,
        title: "Scanning",
        description: "AI & plagiarism detection running",
        time: "~2 hours",
        active: false,
      },
      {
        icon: CheckCircle2,
        title: "Report Ready",
        description: "Detailed report delivered",
        time: "Within 24h",
        active: false,
      },
    ],
  },
  consultation: {
    title: "Question submitted",
    subtitle: "An expert will review and respond to your query",
    icon: MessageSquare,
    timeline: [
      {
        icon: Clock,
        title: "Received",
        description: "Your question is being reviewed",
        time: "Now",
        active: true,
      },
      {
        icon: Zap,
        title: "Expert Assigned",
        description: "Specialist preparing response",
        time: "~4 hours",
        active: false,
      },
      {
        icon: CheckCircle2,
        title: "Response Ready",
        description: "Detailed answer delivered",
        time: "Within 48h",
        active: false,
      },
    ],
  },
};

/**
 * Minimalist submission success screen
 */
export function SubmissionSuccess({
  projectId,
  projectNumber,
  serviceType,
}: SubmissionSuccessProps) {
  const router = useRouter();
  const [copied, setCopied] = useState(false);
  const config = serviceConfigs[serviceType];

  const handleCopy = async () => {
    try {
      await navigator.clipboard.writeText(projectNumber);
      setCopied(true);
      toast.success("Copied to clipboard");
      setTimeout(() => setCopied(false), 2000);
    } catch {
      toast.error("Failed to copy");
    }
  };

  return (
    <div className="min-h-screen bg-background">
      <div className="mx-auto max-w-md px-4 py-12 md:py-20">
        {/* Success Icon */}
        <div className="mb-8 flex justify-center">
          <div className="flex h-16 w-16 items-center justify-center rounded-full bg-emerald-100 dark:bg-emerald-900/30">
            <Check className="h-8 w-8 text-emerald-600 dark:text-emerald-400" strokeWidth={2.5} />
          </div>
        </div>

        {/* Title & Subtitle */}
        <div className="mb-8 text-center">
          <h1 className="mb-2 text-2xl font-semibold tracking-tight">
            {config.title}
          </h1>
          <p className="text-sm text-muted-foreground">{config.subtitle}</p>
        </div>

        {/* Project Number Card */}
        <div className="mb-8 rounded-xl border border-border bg-card p-4">
          <p className="mb-1 text-xs text-muted-foreground">
            Reference number
          </p>
          <div className="flex items-center justify-between gap-3">
            <span className="text-lg font-semibold tracking-wider">
              {projectNumber}
            </span>
            <Button
              variant="ghost"
              size="sm"
              onClick={handleCopy}
              className="h-8 gap-1.5 text-xs"
            >
              {copied ? (
                <>
                  <Check className="h-3.5 w-3.5 text-emerald-600" />
                  Copied
                </>
              ) : (
                <>
                  <Copy className="h-3.5 w-3.5" />
                  Copy
                </>
              )}
            </Button>
          </div>
        </div>

        {/* Timeline */}
        <div className="mb-8">
          <p className="mb-4 text-xs font-medium text-muted-foreground uppercase tracking-wider">
            What happens next
          </p>
          <div className="space-y-0">
            {config.timeline.map((step, index) => {
              const StepIcon = step.icon;
              const isLast = index === config.timeline.length - 1;

              return (
                <div key={index} className="relative flex gap-3">
                  {/* Timeline line */}
                  {!isLast && (
                    <div
                      className={cn(
                        "absolute left-[11px] top-7 h-full w-px",
                        step.active ? "bg-primary" : "bg-border"
                      )}
                    />
                  )}

                  {/* Icon */}
                  <div
                    className={cn(
                      "relative z-10 flex h-6 w-6 shrink-0 items-center justify-center rounded-full",
                      step.active
                        ? "bg-primary text-primary-foreground"
                        : "bg-muted text-muted-foreground"
                    )}
                  >
                    <StepIcon className="h-3 w-3" />
                  </div>

                  {/* Content */}
                  <div className={cn("flex-1 pb-6", isLast && "pb-0")}>
                    <div className="flex items-center justify-between">
                      <p
                        className={cn(
                          "text-sm font-medium",
                          step.active
                            ? "text-foreground"
                            : "text-muted-foreground"
                        )}
                      >
                        {step.title}
                      </p>
                      <span
                        className={cn(
                          "text-xs",
                          step.active
                            ? "text-primary"
                            : "text-muted-foreground"
                        )}
                      >
                        {step.time}
                      </span>
                    </div>
                    <p className="mt-0.5 text-xs text-muted-foreground">
                      {step.description}
                    </p>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Notification Info */}
        <div className="mb-8 flex items-start gap-3 rounded-lg border border-border bg-muted/50 p-3">
          <Bell className="h-4 w-4 shrink-0 text-muted-foreground mt-0.5" />
          <div>
            <p className="text-sm font-medium">You'll be notified</p>
            <p className="text-xs text-muted-foreground">
              Updates via WhatsApp and push notifications
            </p>
          </div>
        </div>

        {/* Action Buttons */}
        <div className="space-y-2">
          <Button
            className="w-full justify-between"
            onClick={() => router.push(`/project/${projectId}`)}
          >
            View project details
            <ArrowRight className="h-4 w-4" />
          </Button>
          <Button
            variant="ghost"
            className="w-full text-muted-foreground"
            onClick={() => router.push("/home")}
          >
            <Home className="h-4 w-4 mr-2" />
            Back to dashboard
          </Button>
        </div>

        {/* Footer Note */}
        <p className="mt-8 text-center text-xs text-muted-foreground">
          Need help? Contact support via WhatsApp
        </p>
      </div>
    </div>
  );
}
