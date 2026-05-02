"use client";

/**
 * ReportDialog - Modal dialog for reporting listings
 *
 * Features:
 * - Reason selection with predefined options
 * - Optional details textarea
 * - Loading and success states
 * - Form validation
 */

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  Flag,
  AlertTriangle,
  Ban,
  FileWarning,
  MessageSquareWarning,
  HelpCircle,
  CheckCircle2,
  Loader2,
  X,
} from "lucide-react";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { cn } from "@/lib/utils";
import { reportListing } from "@/lib/actions/campus-connect";

/** Report reason options */
export type ReportReason = "scam" | "inappropriate" | "inaccurate" | "spam" | "other";

interface ReportReasonOption {
  value: ReportReason;
  label: string;
  description: string;
  icon: React.ElementType;
}

const reportReasons: ReportReasonOption[] = [
  {
    value: "scam",
    label: "Scam or Fraud",
    description: "Suspicious activity, fake listings, or fraud attempts",
    icon: AlertTriangle,
  },
  {
    value: "inappropriate",
    label: "Inappropriate Content",
    description: "Offensive, harmful, or violates community guidelines",
    icon: Ban,
  },
  {
    value: "inaccurate",
    label: "Inaccurate Information",
    description: "Misleading, false, or outdated information",
    icon: FileWarning,
  },
  {
    value: "spam",
    label: "Spam",
    description: "Repetitive posts, promotional content, or irrelevant",
    icon: MessageSquareWarning,
  },
  {
    value: "other",
    label: "Other",
    description: "Something else not listed above",
    icon: HelpCircle,
  },
];

interface ReportDialogProps {
  /** The listing ID to report */
  listingId: string;
  /** Whether the dialog is open */
  isOpen: boolean;
  /** Callback when dialog open state changes */
  onOpenChange: (open: boolean) => void;
  /** Callback when report is successfully submitted */
  onSuccess?: () => void;
}

/**
 * ReportDialog - Modal for submitting listing reports
 */
export function ReportDialog({
  listingId,
  isOpen,
  onOpenChange,
  onSuccess,
}: ReportDialogProps) {
  const [selectedReason, setSelectedReason] = useState<ReportReason | null>(null);
  const [details, setDetails] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async () => {
    if (!selectedReason) {
      setError("Please select a reason for your report");
      return;
    }

    setIsSubmitting(true);
    setError(null);

    try {
      const result = await reportListing(listingId, selectedReason, details || undefined);

      if (result.error) {
        setError(result.error);
        setIsSubmitting(false);
        return;
      }

      setIsSuccess(true);

      // Close dialog after showing success
      setTimeout(() => {
        onOpenChange(false);
        onSuccess?.();
        // Reset state after close animation
        setTimeout(() => {
          setSelectedReason(null);
          setDetails("");
          setIsSuccess(false);
        }, 300);
      }, 1500);
    } catch (err) {
      setError("Failed to submit report. Please try again.");
      setIsSubmitting(false);
    }
  };

  const handleClose = () => {
    if (!isSubmitting) {
      onOpenChange(false);
      // Reset state after close animation
      setTimeout(() => {
        setSelectedReason(null);
        setDetails("");
        setError(null);
        setIsSuccess(false);
      }, 300);
    }
  };

  return (
    <Dialog open={isOpen} onOpenChange={handleClose}>
      <DialogContent className="sm:max-w-[500px] p-0 overflow-hidden">
        <AnimatePresence mode="wait">
          {isSuccess ? (
            <motion.div
              key="success"
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.9 }}
              className="flex flex-col items-center justify-center py-12 px-6 text-center"
            >
              <div className="h-16 w-16 rounded-full bg-green-100 dark:bg-green-900/30 flex items-center justify-center mb-4">
                <CheckCircle2 className="h-8 w-8 text-green-600 dark:text-green-400" />
              </div>
              <h3 className="text-xl font-semibold text-foreground mb-2">
                Report Submitted
              </h3>
              <p className="text-muted-foreground text-sm max-w-xs">
                Thank you for helping keep our community safe. We'll review your report shortly.
              </p>
            </motion.div>
          ) : (
            <motion.div
              key="form"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
            >
              {/* Header */}
              <DialogHeader className="px-6 pt-6 pb-4 border-b">
                <div className="flex items-center gap-3">
                  <div className="h-10 w-10 rounded-full bg-amber-100 dark:bg-amber-900/30 flex items-center justify-center">
                    <Flag className="h-5 w-5 text-amber-600 dark:text-amber-400" />
                  </div>
                  <div>
                    <DialogTitle className="text-lg">Report Listing</DialogTitle>
                    <DialogDescription className="text-sm">
                      Help us maintain a safe community
                    </DialogDescription>
                  </div>
                </div>
              </DialogHeader>

              {/* Form Content */}
              <div className="px-6 py-5 space-y-5">
                {/* Reason Selection */}
                <div className="space-y-3">
                  <Label className="text-sm font-medium">
                    Why are you reporting this listing?
                  </Label>
                  <RadioGroup
                    value={selectedReason || ""}
                    onValueChange={(value) => setSelectedReason(value as ReportReason)}
                    className="space-y-2"
                  >
                    {reportReasons.map((reason) => {
                      const Icon = reason.icon;
                      const isSelected = selectedReason === reason.value;

                      return (
                        <label
                          key={reason.value}
                          className={cn(
                            "flex items-start gap-3 p-3 rounded-xl border-2 cursor-pointer transition-all",
                            isSelected
                              ? "border-primary bg-primary/5"
                              : "border-transparent bg-muted/50 hover:bg-muted"
                          )}
                        >
                          <RadioGroupItem
                            value={reason.value}
                            className="mt-0.5 shrink-0"
                          />
                          <div className="flex-1 min-w-0">
                            <div className="flex items-center gap-2">
                              <Icon className={cn(
                                "h-4 w-4",
                                isSelected ? "text-primary" : "text-muted-foreground"
                              )} />
                              <span className="font-medium text-sm">{reason.label}</span>
                            </div>
                            <p className="text-xs text-muted-foreground mt-0.5">
                              {reason.description}
                            </p>
                          </div>
                        </label>
                      );
                    })}
                  </RadioGroup>
                </div>

                {/* Details Textarea */}
                <div className="space-y-2">
                  <Label htmlFor="details" className="text-sm font-medium">
                    Additional Details <span className="text-muted-foreground font-normal">(optional)</span>
                  </Label>
                  <Textarea
                    id="details"
                    value={details}
                    onChange={(e) => setDetails(e.target.value)}
                    placeholder="Provide any additional context that might help us review this report..."
                    className="min-h-[100px] resize-none"
                    maxLength={1000}
                  />
                  <p className="text-xs text-muted-foreground text-right">
                    {details.length}/1000
                  </p>
                </div>

                {/* Error Message */}
                {error && (
                  <motion.div
                    initial={{ opacity: 0, y: -10 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="flex items-center gap-2 p-3 rounded-lg bg-destructive/10 text-destructive text-sm"
                  >
                    <AlertTriangle className="h-4 w-4 shrink-0" />
                    <span>{error}</span>
                  </motion.div>
                )}
              </div>

              {/* Footer */}
              <div className="px-6 py-4 border-t bg-muted/30 flex items-center justify-end gap-3">
                <Button
                  variant="outline"
                  onClick={handleClose}
                  disabled={isSubmitting}
                  className="rounded-full"
                >
                  Cancel
                </Button>
                <Button
                  onClick={handleSubmit}
                  disabled={!selectedReason || isSubmitting}
                  className="rounded-full min-w-[100px]"
                >
                  {isSubmitting ? (
                    <>
                      <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                      Submitting...
                    </>
                  ) : (
                    "Submit Report"
                  )}
                </Button>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </DialogContent>
    </Dialog>
  );
}

export default ReportDialog;
