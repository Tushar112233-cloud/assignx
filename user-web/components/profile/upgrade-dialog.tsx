"use client";

import { useState, useCallback } from "react";
import {
  GraduationCap,
  Briefcase,
  Building2,
  Upload,
  Check,
  ChevronLeft,
  ChevronRight,
  Loader2,
  FileText,
  X,
  Sparkles,
  Clock,
  Shield,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import {
  accountTiers,
  getVerificationRequirements,
  getProcessingTime,
} from "@/lib/data/account-upgrade";
import type {
  AccountType,
  UpgradeStep,
  VerificationRequirement,
} from "@/types/account-upgrade";

interface UpgradeDialogProps {
  /** Whether the dialog is open */
  open: boolean;
  /** Callback when open state changes */
  onOpenChange: (open: boolean) => void;
  /** Current account type */
  currentType: AccountType;
  /** Target account type for upgrade */
  targetType: AccountType | null;
  /** Callback when upgrade is successful */
  onSuccess: () => void;
}

/**
 * Get the icon component for an account type
 */
function getAccountIcon(type: AccountType, className?: string) {
  const iconClass = cn("h-6 w-6", className);
  switch (type) {
    case "student":
      return <GraduationCap className={iconClass} />;
    case "professional":
      return <Briefcase className={iconClass} />;
    case "business_owner":
      return <Building2 className={iconClass} />;
  }
}

/**
 * Multi-step Upgrade Dialog Component
 *
 * Guides users through account upgrade with:
 * - Step 1: Select account type
 * - Step 2: Upload verification documents
 * - Step 3: Review and confirm
 * - Step 4: Success confirmation
 */
export function UpgradeDialog({
  open,
  onOpenChange,
  currentType,
  targetType,
  onSuccess,
}: UpgradeDialogProps) {
  const [step, setStep] = useState<UpgradeStep>("select");
  const [selectedType, setSelectedType] = useState<AccountType | null>(targetType);
  const [documents, setDocuments] = useState<VerificationRequirement[]>([]);
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Reset state when dialog opens
  const handleOpenChange = useCallback((newOpen: boolean) => {
    if (newOpen) {
      setStep(targetType ? "verify" : "select");
      setSelectedType(targetType);
      if (targetType) {
        setDocuments(getVerificationRequirements(currentType, targetType));
      }
    } else {
      setStep("select");
      setSelectedType(null);
      setDocuments([]);
    }
    onOpenChange(newOpen);
  }, [targetType, currentType, onOpenChange]);

  // Handle type selection
  const handleTypeSelect = (type: AccountType) => {
    setSelectedType(type);
    setDocuments(getVerificationRequirements(currentType, type));
    setStep("verify");
  };

  // Handle file upload
  const handleFileUpload = (requirementId: string, file: File | null) => {
    setDocuments((prev) =>
      prev.map((doc) =>
        doc.id === requirementId
          ? { ...doc, file: file || undefined, accepted: !!file }
          : doc
      )
    );
  };

  // Check if all required documents are uploaded
  const allRequiredUploaded = documents
    .filter((doc) => doc.required)
    .every((doc) => doc.accepted);

  // Handle form submission
  const handleSubmit = async () => {
    if (!selectedType) return;

    setIsSubmitting(true);
    try {
      // Simulate API call
      await new Promise((resolve) => setTimeout(resolve, 2000));

      setStep("success");
      toast.success("Upgrade request submitted successfully!");
    } catch {
      toast.error("Failed to submit upgrade request. Please try again.");
    } finally {
      setIsSubmitting(false);
    }
  };

  // Handle success acknowledgment
  const handleSuccessClose = () => {
    onSuccess();
    handleOpenChange(false);
  };

  // Get step indicator
  const getStepNumber = () => {
    switch (step) {
      case "select":
        return 1;
      case "verify":
        return 2;
      case "confirm":
        return 3;
      case "success":
        return 4;
    }
  };

  const currentTier = accountTiers[currentType];
  const targetTier = selectedType ? accountTiers[selectedType] : null;

  return (
    <Dialog open={open} onOpenChange={handleOpenChange}>
      <DialogContent className="max-w-lg">
        <DialogHeader>
          <div className="flex items-center gap-2 mb-2">
            {/* Step Indicator */}
            <div className="flex items-center gap-1">
              {[1, 2, 3].map((s) => (
                <div
                  key={s}
                  className={cn(
                    "h-2 w-8 rounded-full transition-colors",
                    getStepNumber() >= s ? "bg-primary" : "bg-muted"
                  )}
                />
              ))}
            </div>
          </div>
          <DialogTitle>
            {step === "select" && "Choose Account Type"}
            {step === "verify" && "Verification Documents"}
            {step === "confirm" && "Confirm Upgrade"}
            {step === "success" && "Upgrade Submitted"}
          </DialogTitle>
          <DialogDescription>
            {step === "select" && "Select the account type you want to upgrade to"}
            {step === "verify" && "Upload required documents for verification"}
            {step === "confirm" && "Review your upgrade request before submitting"}
            {step === "success" && "Your upgrade request has been submitted"}
          </DialogDescription>
        </DialogHeader>

        <div className="py-4">
          {/* Step 1: Select Account Type */}
          {step === "select" && (
            <div className="space-y-4">
              {currentTier.canUpgradeTo.map((type) => {
                const tier = accountTiers[type];
                const isSelected = selectedType === type;
                return (
                  <div
                    key={type}
                    className={cn(
                      "relative rounded-lg border-2 p-4 cursor-pointer transition-all",
                      isSelected
                        ? "border-primary bg-primary/5"
                        : "border-muted hover:border-primary/50"
                    )}
                    onClick={() => setSelectedType(type)}
                  >
                    <div className="flex items-start gap-3">
                      <div
                        className={cn(
                          "flex h-12 w-12 items-center justify-center rounded-lg",
                          type === "professional" && "bg-purple-100",
                          type === "business_owner" && "bg-amber-100"
                        )}
                      >
                        {getAccountIcon(
                          type,
                          cn(
                            type === "professional" && "text-purple-600",
                            type === "business_owner" && "text-amber-600"
                          )
                        )}
                      </div>
                      <div className="flex-1">
                        <div className="flex items-center gap-2">
                          <h3 className="font-semibold">{tier.displayName}</h3>
                          {type === "business_owner" && (
                            <Badge variant="secondary" className="text-xs">
                              Premium
                            </Badge>
                          )}
                        </div>
                        <p className="text-sm text-muted-foreground mt-1">
                          {tier.description}
                        </p>
                        <ul className="mt-3 space-y-1">
                          {tier.benefits.slice(0, 4).map((benefit, idx) => (
                            <li
                              key={idx}
                              className="flex items-center gap-2 text-sm"
                            >
                              <Check className="h-3.5 w-3.5 text-green-500 shrink-0" />
                              {benefit}
                            </li>
                          ))}
                        </ul>
                      </div>
                      <div
                        className={cn(
                          "h-5 w-5 rounded-full border-2 flex items-center justify-center",
                          isSelected ? "border-primary bg-primary" : "border-muted"
                        )}
                      >
                        {isSelected && <Check className="h-3 w-3 text-white" />}
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          )}

          {/* Step 2: Upload Verification Documents */}
          {step === "verify" && targetTier && (
            <div className="space-y-4">
              <div className="flex items-center gap-3 p-3 rounded-lg bg-muted/50">
                <Shield className="h-5 w-5 text-primary" />
                <div className="text-sm">
                  <p className="font-medium">Secure Verification</p>
                  <p className="text-muted-foreground">
                    Your documents are encrypted and reviewed by our team
                  </p>
                </div>
              </div>

              <div className="space-y-3">
                {documents.map((doc) => (
                  <div
                    key={doc.id}
                    className="rounded-lg border p-4 space-y-3"
                  >
                    <div className="flex items-start justify-between gap-2">
                      <div>
                        <Label className="text-sm font-medium">
                          {doc.label}
                          {doc.required && (
                            <span className="text-destructive ml-1">*</span>
                          )}
                        </Label>
                        <p className="text-xs text-muted-foreground mt-0.5">
                          {doc.description}
                        </p>
                      </div>
                      {doc.accepted && (
                        <Badge variant="secondary" className="shrink-0">
                          <Check className="h-3 w-3 mr-1" />
                          Uploaded
                        </Badge>
                      )}
                    </div>

                    {doc.file ? (
                      <div className="flex items-center gap-2 p-2 rounded bg-muted/50">
                        <FileText className="h-4 w-4 text-muted-foreground" />
                        <span className="text-sm flex-1 truncate">
                          {doc.file.name}
                        </span>
                        <Button
                          variant="ghost"
                          size="icon"
                          className="h-6 w-6"
                          onClick={() => handleFileUpload(doc.id, null)}
                        >
                          <X className="h-3.5 w-3.5" />
                        </Button>
                      </div>
                    ) : (
                      <div className="relative">
                        <Input
                          type="file"
                          accept=".pdf,.jpg,.jpeg,.png"
                          className="absolute inset-0 opacity-0 cursor-pointer"
                          onChange={(e) => {
                            const file = e.target.files?.[0];
                            if (file) {
                              handleFileUpload(doc.id, file);
                            }
                          }}
                        />
                        <div className="flex items-center justify-center gap-2 p-3 rounded-lg border-2 border-dashed border-muted-foreground/25 hover:border-primary/50 transition-colors">
                          <Upload className="h-4 w-4 text-muted-foreground" />
                          <span className="text-sm text-muted-foreground">
                            Click to upload (PDF, JPG, PNG)
                          </span>
                        </div>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Step 3: Confirm */}
          {step === "confirm" && targetTier && (
            <div className="space-y-4">
              <div className="flex items-center gap-4 p-4 rounded-lg bg-muted/50">
                <div className="flex items-center gap-2">
                  {getAccountIcon(currentType, "h-5 w-5 text-muted-foreground")}
                  <span className="font-medium">{currentTier.displayName}</span>
                </div>
                <ChevronRight className="h-4 w-4 text-muted-foreground" />
                <div className="flex items-center gap-2">
                  {getAccountIcon(selectedType!, "h-5 w-5 text-primary")}
                  <span className="font-medium text-primary">
                    {targetTier.displayName}
                  </span>
                </div>
              </div>

              <div className="space-y-3">
                <div className="flex items-center gap-3 p-3 rounded-lg border">
                  <FileText className="h-5 w-5 text-muted-foreground" />
                  <div className="flex-1">
                    <p className="text-sm font-medium">Documents Uploaded</p>
                    <p className="text-xs text-muted-foreground">
                      {documents.filter((d) => d.accepted).length} of{" "}
                      {documents.length} documents
                    </p>
                  </div>
                  <Check className="h-5 w-5 text-green-500" />
                </div>

                <div className="flex items-center gap-3 p-3 rounded-lg border">
                  <Clock className="h-5 w-5 text-muted-foreground" />
                  <div className="flex-1">
                    <p className="text-sm font-medium">Estimated Processing</p>
                    <p className="text-xs text-muted-foreground">
                      {getProcessingTime(selectedType!)}
                    </p>
                  </div>
                </div>
              </div>

              <div className="p-3 rounded-lg bg-amber-50 border border-amber-200">
                <p className="text-sm text-amber-800">
                  Your upgrade request will be reviewed by our team. You will
                  receive an email notification once approved.
                </p>
              </div>
            </div>
          )}

          {/* Step 4: Success */}
          {step === "success" && targetTier && (
            <div className="text-center space-y-4 py-4">
              <div className="flex justify-center">
                <div className="h-16 w-16 rounded-full bg-green-100 flex items-center justify-center">
                  <Sparkles className="h-8 w-8 text-green-600" />
                </div>
              </div>
              <div>
                <h3 className="text-lg font-semibold">Request Submitted!</h3>
                <p className="text-muted-foreground mt-1">
                  Your upgrade to {targetTier.displayName} is being processed.
                </p>
              </div>
              <div className="p-4 rounded-lg bg-muted/50 text-sm">
                <p className="font-medium">What happens next?</p>
                <ul className="mt-2 space-y-1 text-muted-foreground text-left">
                  <li>1. Our team will review your documents</li>
                  <li>2. You will receive an email with the decision</li>
                  <li>3. If approved, your account will be upgraded automatically</li>
                </ul>
              </div>
            </div>
          )}
        </div>

        <DialogFooter>
          {step === "select" && (
            <>
              <Button variant="outline" onClick={() => handleOpenChange(false)}>
                Cancel
              </Button>
              <Button
                onClick={() => selectedType && handleTypeSelect(selectedType)}
                disabled={!selectedType}
              >
                Continue
                <ChevronRight className="ml-2 h-4 w-4" />
              </Button>
            </>
          )}

          {step === "verify" && (
            <>
              <Button variant="outline" onClick={() => setStep("select")}>
                <ChevronLeft className="mr-2 h-4 w-4" />
                Back
              </Button>
              <Button
                onClick={() => setStep("confirm")}
                disabled={!allRequiredUploaded}
              >
                Continue
                <ChevronRight className="ml-2 h-4 w-4" />
              </Button>
            </>
          )}

          {step === "confirm" && (
            <>
              <Button
                variant="outline"
                onClick={() => setStep("verify")}
                disabled={isSubmitting}
              >
                <ChevronLeft className="mr-2 h-4 w-4" />
                Back
              </Button>
              <Button onClick={handleSubmit} disabled={isSubmitting}>
                {isSubmitting ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Submitting...
                  </>
                ) : (
                  <>
                    Submit Request
                    <Check className="ml-2 h-4 w-4" />
                  </>
                )}
              </Button>
            </>
          )}

          {step === "success" && (
            <Button onClick={handleSuccessClose} className="w-full">
              Done
            </Button>
          )}
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
