"use client";

import { useState } from "react";
import { MessageSquare, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { toast } from "sonner";
import { submitFeedback } from "@/lib/actions/data";
import type { FeedbackData } from "@/types/settings";

/** Feedback submission section */
export function FeedbackSection() {
  const [feedback, setFeedback] = useState<FeedbackData>({ type: "general", message: "" });
  const [isSubmitting, setIsSubmitting] = useState(false);

  /** Submits feedback to server */
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!feedback.message.trim()) {
      toast.error("Please enter your feedback");
      return;
    }
    setIsSubmitting(true);
    try {
      // Map feedback type to satisfaction score for the database
      const satisfactionMap = { bug: 2, feature: 4, general: 3 };
      const result = await submitFeedback({
        overallSatisfaction: satisfactionMap[feedback.type as keyof typeof satisfactionMap] || 3,
        feedbackText: feedback.message,
        improvementSuggestions: feedback.type === "feature" ? feedback.message : undefined,
      });
      if (result.error) {
        toast.error(result.error);
        return;
      }
      toast.success("Thank you for your feedback!");
      setFeedback({ type: "general", message: "" });
    } catch {
      toast.error("Failed to submit feedback");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <MessageSquare className="h-5 w-5" />
          Send Feedback
        </CardTitle>
        <CardDescription>Help us improve AssignX</CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label>Feedback Type</Label>
            <RadioGroup value={feedback.type} onValueChange={(v) => setFeedback((p) => ({ ...p, type: v as FeedbackData["type"] }))} className="flex gap-4">
              <div className="flex items-center space-x-2">
                <RadioGroupItem value="bug" id="bug" />
                <Label htmlFor="bug" className="font-normal cursor-pointer">Bug Report</Label>
              </div>
              <div className="flex items-center space-x-2">
                <RadioGroupItem value="feature" id="feature" />
                <Label htmlFor="feature" className="font-normal cursor-pointer">Feature Request</Label>
              </div>
              <div className="flex items-center space-x-2">
                <RadioGroupItem value="general" id="general" />
                <Label htmlFor="general" className="font-normal cursor-pointer">General</Label>
              </div>
            </RadioGroup>
          </div>
          <div className="space-y-2">
            <Label htmlFor="message">Your Feedback</Label>
            <Textarea id="message" value={feedback.message} onChange={(e) => setFeedback((p) => ({ ...p, message: e.target.value }))} placeholder="Tell us what you think..." rows={4} />
          </div>
          <Button type="submit" disabled={isSubmitting} className="w-full">
            {isSubmitting ? <><Loader2 className="mr-2 h-4 w-4 animate-spin" />Sending...</> : "Send Feedback"}
          </Button>
        </form>
      </CardContent>
    </Card>
  );
}
