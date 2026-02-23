"use client";

import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { MessageSquare, Send, CheckCircle } from "lucide-react";
import { createRevisionRequest } from "@/lib/actions/data";
import { toast } from "sonner";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from "@/components/ui/dialog";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Textarea } from "@/components/ui/textarea";
import { Button } from "@/components/ui/button";
import type { Project } from "@/types/project";

const revisionSchema = z.object({
  feedback: z
    .string()
    .min(20, "Please provide at least 20 characters of feedback")
    .max(1000, "Feedback must be less than 1000 characters"),
});

type RevisionFormData = z.infer<typeof revisionSchema>;

interface RevisionRequestFormProps {
  project: Project;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onSubmit?: (feedback: string) => void;
}

/**
 * Revision request form dialog
 * Allows users to request changes to delivered work
 */
export function RevisionRequestForm({
  project,
  open,
  onOpenChange,
  onSubmit,
}: RevisionRequestFormProps) {
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);

  const form = useForm<RevisionFormData>({
    resolver: zodResolver(revisionSchema),
    defaultValues: {
      feedback: "",
    },
  });

  const handleSubmit = async (data: RevisionFormData) => {
    setIsSubmitting(true);

    try {
      const result = await createRevisionRequest(project.id, data.feedback);

      if (result.error) {
        toast.error(result.error);
        setIsSubmitting(false);
        return;
      }

      if (onSubmit) {
        onSubmit(data.feedback);
      }

      setIsSubmitting(false);
      setIsSuccess(true);

      // Auto close after success
      setTimeout(() => {
        setIsSuccess(false);
        form.reset();
        onOpenChange(false);
      }, 2000);
    } catch {
      toast.error("Failed to submit revision request");
      setIsSubmitting(false);
    }
  };

  // Success state
  if (isSuccess) {
    return (
      <Dialog open={open} onOpenChange={onOpenChange}>
        <DialogContent className="sm:max-w-md">
          <div className="flex flex-col items-center py-8 text-center">
            <div className="mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-green-100 dark:bg-green-900/30">
              <CheckCircle className="h-8 w-8 text-green-600 dark:text-green-400" />
            </div>
            <h3 className="mb-2 text-lg font-semibold">Revision Requested</h3>
            <p className="text-sm text-muted-foreground">
              Your feedback has been submitted. The expert will review and make
              the changes.
            </p>
          </div>
        </DialogContent>
      </Dialog>
    );
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-lg">
        <DialogHeader>
          <div className="mb-2 flex h-10 w-10 items-center justify-center rounded-full bg-primary/10">
            <MessageSquare className="h-5 w-5 text-primary" />
          </div>
          <DialogTitle>Request Changes</DialogTitle>
          <DialogDescription>
            Tell us what changes you&apos;d like for {project.projectNumber}
          </DialogDescription>
        </DialogHeader>

        <Form {...form}>
          <form
            onSubmit={form.handleSubmit(handleSubmit)}
            className="space-y-4"
          >
            <FormField
              control={form.control}
              name="feedback"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Your Feedback</FormLabel>
                  <FormControl>
                    <Textarea
                      placeholder="Please describe the changes you need. Be as specific as possible..."
                      className="min-h-32 resize-none"
                      {...field}
                    />
                  </FormControl>
                  <div className="flex justify-between text-xs text-muted-foreground">
                    <FormMessage />
                    <span>{field.value.length}/1000</span>
                  </div>
                </FormItem>
              )}
            />

            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => onOpenChange(false)}
                disabled={isSubmitting}
              >
                Cancel
              </Button>
              <Button type="submit" disabled={isSubmitting}>
                {isSubmitting ? (
                  <>
                    <span className="mr-2 h-4 w-4 animate-spin rounded-full border-2 border-current border-t-transparent" />
                    Submitting...
                  </>
                ) : (
                  <>
                    <Send className="mr-2 h-4 w-4" />
                    Submit Request
                  </>
                )}
              </Button>
            </DialogFooter>
          </form>
        </Form>
      </DialogContent>
    </Dialog>
  );
}
