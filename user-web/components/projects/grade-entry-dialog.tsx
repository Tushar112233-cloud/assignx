"use client";

import { useState } from "react";
import { GraduationCap, Star, Loader2, Check } from "lucide-react";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { toast } from "sonner";
import { cn } from "@/lib/utils";

interface GradeEntryDialogProps {
  projectId: string;
  projectTitle: string;
  currentGrade?: string;
  onGradeSubmit?: (grade: string, feedback?: string) => Promise<void>;
  children?: React.ReactNode;
}

/**
 * Grade entry options
 */
const gradeOptions = [
  { value: "A+", label: "A+ (90-100%)", color: "text-green-600" },
  { value: "A", label: "A (85-89%)", color: "text-green-600" },
  { value: "A-", label: "A- (80-84%)", color: "text-green-500" },
  { value: "B+", label: "B+ (75-79%)", color: "text-blue-600" },
  { value: "B", label: "B (70-74%)", color: "text-blue-600" },
  { value: "B-", label: "B- (65-69%)", color: "text-blue-500" },
  { value: "C+", label: "C+ (60-64%)", color: "text-yellow-600" },
  { value: "C", label: "C (55-59%)", color: "text-yellow-600" },
  { value: "C-", label: "C- (50-54%)", color: "text-yellow-500" },
  { value: "D", label: "D (40-49%)", color: "text-orange-600" },
  { value: "F", label: "F (Below 40%)", color: "text-red-600" },
  { value: "Pass", label: "Pass", color: "text-green-600" },
  { value: "Pending", label: "Pending/Not Yet", color: "text-gray-500" },
];

/**
 * Grade Entry Dialog Component
 * Optional field for users to enter their final grade
 * Implements U38 from feature spec
 */
export function GradeEntryDialog({
  projectId,
  projectTitle,
  currentGrade,
  onGradeSubmit,
  children,
}: GradeEntryDialogProps) {
  const [open, setOpen] = useState(false);
  const [grade, setGrade] = useState(currentGrade || "");
  const [feedback, setFeedback] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [rating, setRating] = useState(0);

  const handleSubmit = async () => {
    if (!grade) {
      toast.error("Please select a grade");
      return;
    }

    setIsSubmitting(true);

    try {
      if (onGradeSubmit) {
        await onGradeSubmit(grade, feedback);
      } else {
        // Default implementation - would call server action
        // await updateProjectGrade(projectId, grade, feedback, rating);
        await new Promise((resolve) => setTimeout(resolve, 500));
      }

      toast.success("Grade saved successfully!");
      setOpen(false);
    } catch {
      toast.error("Failed to save grade");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        {children || (
          <Button variant="outline" size="sm">
            <GraduationCap className="h-4 w-4 mr-2" />
            {currentGrade ? `Grade: ${currentGrade}` : "Add Grade"}
          </Button>
        )}
      </DialogTrigger>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <GraduationCap className="h-5 w-5 text-primary" />
            Enter Your Grade
          </DialogTitle>
          <DialogDescription>
            Add the grade you received for &quot;{projectTitle}&quot;. This helps us improve our
            service quality.
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-4 pt-4">
          {/* Grade Selection */}
          <div className="space-y-2">
            <Label htmlFor="grade">Grade Received</Label>
            <Select value={grade} onValueChange={setGrade}>
              <SelectTrigger>
                <SelectValue placeholder="Select your grade" />
              </SelectTrigger>
              <SelectContent>
                {gradeOptions.map((option) => (
                  <SelectItem key={option.value} value={option.value}>
                    <span className={option.color}>{option.label}</span>
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {/* Star Rating for Service */}
          <div className="space-y-2">
            <Label>Rate Our Service (Optional)</Label>
            <div className="flex gap-1">
              {[1, 2, 3, 4, 5].map((star) => (
                <button
                  key={star}
                  type="button"
                  onClick={() => setRating(star)}
                  className="p-1 transition-transform hover:scale-110"
                >
                  <Star
                    className={cn(
                      "h-6 w-6 transition-colors",
                      star <= rating
                        ? "fill-yellow-400 text-yellow-400"
                        : "text-gray-300"
                    )}
                  />
                </button>
              ))}
            </div>
          </div>

          {/* Feedback */}
          <div className="space-y-2">
            <Label htmlFor="feedback">Feedback (Optional)</Label>
            <Textarea
              id="feedback"
              placeholder="Any comments about the project or service..."
              value={feedback}
              onChange={(e) => setFeedback(e.target.value)}
              rows={3}
            />
          </div>

          {/* Privacy Note */}
          <p className="text-xs text-muted-foreground">
            Your grade is private and only used for analytics. It helps us match you
            with better experts in the future.
          </p>

          {/* Actions */}
          <div className="flex gap-2 pt-2">
            <Button
              variant="outline"
              className="flex-1"
              onClick={() => setOpen(false)}
            >
              Cancel
            </Button>
            <Button
              className="flex-1"
              onClick={handleSubmit}
              disabled={isSubmitting || !grade}
            >
              {isSubmitting ? (
                <Loader2 className="h-4 w-4 animate-spin mr-2" />
              ) : (
                <Check className="h-4 w-4 mr-2" />
              )}
              Save Grade
            </Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
}
