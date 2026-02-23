"use client";

import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { Loader2, Send, MessageSquare } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent } from "@/components/ui/card";
import { SubjectSelector } from "./subject-selector";
import { DeadlinePicker } from "./deadline-picker";
import {
  consultationFormSchema,
  type ConsultationFormSchema,
} from "@/lib/validations/project";
import { createProject } from "@/lib/actions/data";
import { toast } from "sonner";

interface ConsultationFormProps {
  onSuccess: (projectId: string, projectNumber: string) => void;
  onStepChange?: (step: number) => void;
}

/**
 * Expert consultation/opinion form
 */
export function ConsultationForm({ onSuccess, onStepChange }: ConsultationFormProps) {
  const [isSubmitting, setIsSubmitting] = useState(false);

  const form = useForm<ConsultationFormSchema>({
    resolver: zodResolver(consultationFormSchema),
    defaultValues: {
      subject: "",
      topic: "",
      questionSummary: "",
      preferredDate: undefined,
      preferredTime: "",
    },
  });

  const handleSubmit = form.handleSubmit(async (data) => {
    setIsSubmitting(true);

    try {
      // Build deadline from preferredDate and preferredTime
      let deadline: Date;
      if (data.preferredDate) {
        deadline = new Date(data.preferredDate);
        if (data.preferredTime) {
          const [hours, minutes] = data.preferredTime.split(":").map(Number);
          deadline.setHours(hours, minutes);
        }
      } else {
        deadline = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
      }

      const result = await createProject({
        serviceType: "expert_opinion",
        title: data.topic || `Expert Opinion - ${data.subject}`,
        subjectId: data.subject,
        topic: data.topic,
        deadline: deadline.toISOString(),
        instructions: data.questionSummary,
      });

      if (result.error) {
        toast.error(result.error);
        setIsSubmitting(false);
        return;
      }

      onSuccess(result.projectId!, result.projectNumber!);
    } catch {
      toast.error("Something went wrong. Please try again.");
      setIsSubmitting(false);
    }
  });

  return (
    <div className="flex flex-col">
      {/* Free Service Info */}
      <Card className="mb-6 border-green-200 bg-green-50 dark:border-green-800 dark:bg-green-900/20">
        <CardContent className="flex items-center gap-3 p-4">
          <MessageSquare className="h-8 w-8 shrink-0 text-green-600 dark:text-green-400" />
          <div>
            <p className="font-medium text-green-700 dark:text-green-400">
              This service is completely free!
            </p>
            <p className="text-sm text-green-600/80 dark:text-green-400/80">
              Get a quick expert opinion on your topic or question.
            </p>
          </div>
        </CardContent>
      </Card>

      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Subject */}
        <div className="space-y-2">
          <Label>Subject Area</Label>
          <SubjectSelector
            value={form.watch("subject")}
            onChange={(value) => form.setValue("subject", value)}
            error={form.formState.errors.subject?.message}
          />
        </div>

        {/* Topic */}
        <div className="space-y-2">
          <Label htmlFor="topic">Topic</Label>
          <Input
            id="topic"
            placeholder="e.g., Research methodology for qualitative studies"
            {...form.register("topic")}
            className={
              form.formState.errors.topic ? "border-destructive" : ""
            }
          />
          {form.formState.errors.topic && (
            <p className="text-sm text-destructive">
              {form.formState.errors.topic.message}
            </p>
          )}
        </div>

        {/* Question Summary */}
        <div className="space-y-2">
          <Label htmlFor="questionSummary">Your Question</Label>
          <Textarea
            id="questionSummary"
            placeholder="Describe what you need help with in detail..."
            rows={5}
            {...form.register("questionSummary")}
            className={
              form.formState.errors.questionSummary ? "border-destructive" : ""
            }
          />
          {form.formState.errors.questionSummary && (
            <p className="text-sm text-destructive">
              {form.formState.errors.questionSummary.message}
            </p>
          )}
          <p className="text-xs text-muted-foreground">
            Be specific about your question for better guidance (min 20 characters)
          </p>
        </div>

        {/* Preferred Date (Optional) */}
        <div className="space-y-2">
          <Label>Preferred Response Date (Optional)</Label>
          <DeadlinePicker
            value={form.watch("preferredDate")}
            onChange={(date) => form.setValue("preferredDate", date)}
            minDays={0}
          />
          <p className="text-xs text-muted-foreground">
            We&apos;ll try our best to respond by your preferred date
          </p>
        </div>

        {/* Preferred Time (Optional) */}
        <div className="space-y-2">
          <Label htmlFor="preferredTime">Preferred Time (Optional)</Label>
          <Input
            id="preferredTime"
            type="time"
            {...form.register("preferredTime")}
          />
        </div>

        <Button type="submit" className="w-full" disabled={isSubmitting}>
          {isSubmitting ? (
            <>
              <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              Submitting...
            </>
          ) : (
            <>
              <Send className="mr-2 h-4 w-4" />
              Submit Question
            </>
          )}
        </Button>
      </form>
    </div>
  );
}
