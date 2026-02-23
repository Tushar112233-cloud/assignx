"use client";

import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { motion, AnimatePresence } from "framer-motion";
import { Loader2, Send, Bot, FileSearch, Sparkles, Shield, Clock, CheckCircle2, ArrowRight } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Card, CardContent } from "@/components/ui/card";
import { FileUploadZone } from "./file-upload-zone";
import {
  reportFormSchema,
  type ReportFormSchema,
} from "@/lib/validations/project";
import { createProject, uploadProjectFile } from "@/lib/actions/data";
import type { UploadedFile } from "@/types/add-project";
import { toast } from "sonner";
import { cn } from "@/lib/utils";

interface ReportFormProps {
  onSuccess: (projectId: string, projectNumber: string) => void;
  onStepChange?: (step: number) => void;
}

const reportTypes = [
  {
    value: "ai",
    label: "AI Detection",
    description: "Check if content was AI-generated",
    icon: Bot,
    price: 49,
    color: "from-violet-500/20 to-purple-500/20",
    borderColor: "border-violet-500/50",
    iconBg: "bg-violet-500",
  },
  {
    value: "plagiarism",
    label: "Plagiarism Check",
    description: "Check for copied content",
    icon: FileSearch,
    price: 99,
    color: "from-blue-500/20 to-cyan-500/20",
    borderColor: "border-blue-500/50",
    iconBg: "bg-blue-500",
  },
  {
    value: "both",
    label: "Complete Report",
    description: "AI detection + Plagiarism check",
    icon: Sparkles,
    price: 129,
    popular: true,
    color: "from-primary/20 to-accent/20",
    borderColor: "border-primary/50",
    iconBg: "bg-primary",
  },
];

/** Features to display */
const features = [
  { icon: Shield, text: "100% Secure & Confidential" },
  { icon: Clock, text: "Results within 24 hours" },
  { icon: CheckCircle2, text: "Detailed Analysis Report" },
];

/**
 * AI/Plagiarism report form with multi-step wizard
 */
export function ReportForm({ onSuccess, onStepChange }: ReportFormProps) {
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [files, setFiles] = useState<UploadedFile[]>([]);
  const [currentStep, setCurrentStep] = useState(0);

  const form = useForm<ReportFormSchema>({
    resolver: zodResolver(reportFormSchema),
    defaultValues: {
      reportType: "both",
      documentCount: 1,
      wordCountApprox: 5000,
    },
  });

  const watchReportType = form.watch("reportType");
  const watchDocCount = form.watch("documentCount");

  // Calculate price
  const selectedReport = reportTypes.find((r) => r.value === watchReportType);
  const basePrice = (selectedReport?.price || 0) * (watchDocCount || 1);
  const gst = basePrice * 0.18;
  const totalPrice = basePrice + gst;

  // Step navigation
  const goToNextStep = () => {
    const newStep = currentStep + 1;
    setCurrentStep(newStep);
    onStepChange?.(newStep);
  };

  const goToPrevStep = () => {
    const newStep = Math.max(0, currentStep - 1);
    setCurrentStep(newStep);
    onStepChange?.(newStep);
  };

  const handleSubmit = form.handleSubmit(async (data) => {
    if (files.length === 0) {
      toast.error("Please upload at least one document");
      return;
    }

    setIsSubmitting(true);

    try {
      // Determine service type based on report type
      const serviceType = data.reportType === "ai"
        ? "ai_detection"
        : data.reportType === "plagiarism"
          ? "plagiarism_check"
          : "ai_detection"; // for 'both', use ai_detection as primary

      const result = await createProject({
        serviceType,
        title: `${selectedReport?.label || "Report"} - ${data.documentCount} document(s)`,
        wordCount: data.wordCountApprox,
        deadline: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
      });

      if (result.error) {
        toast.error(result.error);
        setIsSubmitting(false);
        return;
      }

      // Upload files to Cloudinary
      if (files.length > 0 && result.projectId) {
        for (const uploadedFile of files) {
          try {
            // Convert File to base64
            const fileData = uploadedFile.file;
            const base64 = await new Promise<string>((resolve, reject) => {
              const reader = new FileReader();
              reader.onload = () => {
                const readerResult = reader.result as string;
                const base64Data = readerResult.split(",")[1];
                resolve(base64Data);
              };
              reader.onerror = reject;
              reader.readAsDataURL(fileData);
            });

            // Upload file
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

      onSuccess(result.projectId!, result.projectNumber!);
    } catch {
      toast.error("Something went wrong. Please try again.");
      setIsSubmitting(false);
    }
  });

  return (
    <div className="flex flex-col">
      <form onSubmit={handleSubmit} className="space-y-6">
        <AnimatePresence mode="wait">
          {/* Step 1: Select Report Type */}
          {currentStep === 0 && (
            <motion.div
              key="step-1"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
              transition={{ duration: 0.3 }}
              className="space-y-6"
            >
              {/* Report Type Selection */}
              <div className="space-y-4">
                <div className="space-y-1">
                  <Label className="text-base font-semibold">Select Report Type</Label>
                  <p className="text-sm text-muted-foreground">
                    Choose the type of analysis you need for your document
                  </p>
                </div>
                <RadioGroup
                  value={form.watch("reportType")}
                  onValueChange={(value) =>
                    form.setValue("reportType", value as "ai" | "plagiarism" | "both")
                  }
                  className="grid gap-4"
                >
                  {reportTypes.map((type, index) => {
                    const isSelected = form.watch("reportType") === type.value;
                    return (
                      <motion.div
                        key={type.value}
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: index * 0.1 }}
                      >
                        <label
                          htmlFor={type.value}
                          className={cn(
                            "relative flex cursor-pointer items-center gap-4 rounded-xl border-2 p-4 transition-all duration-200",
                            isSelected
                              ? `bg-gradient-to-r ${type.color} ${type.borderColor} shadow-lg`
                              : "border-border hover:border-muted-foreground/50 hover:shadow-md"
                          )}
                        >
                          <RadioGroupItem
                            value={type.value}
                            id={type.value}
                            className="sr-only"
                          />

                          {/* Icon */}
                          <div
                            className={cn(
                              "flex h-12 w-12 shrink-0 items-center justify-center rounded-lg transition-all",
                              isSelected ? type.iconBg : "bg-muted"
                            )}
                          >
                            <type.icon
                              className={cn(
                                "h-6 w-6 transition-colors",
                                isSelected ? "text-white" : "text-muted-foreground"
                              )}
                            />
                          </div>

                          {/* Content */}
                          <div className="flex-1 space-y-1">
                            <div className="flex items-center gap-2">
                              <span className="font-semibold">{type.label}</span>
                              {type.popular && (
                                <span className="rounded-full bg-primary px-2 py-0.5 text-[10px] font-bold text-primary-foreground">
                                  BEST VALUE
                                </span>
                              )}
                            </div>
                            <p className="text-sm text-muted-foreground">
                              {type.description}
                            </p>
                          </div>

                          {/* Price */}
                          <div className="text-right">
                            <div className="text-2xl font-bold text-primary">
                              ₹{type.price}
                            </div>
                            <div className="text-xs text-muted-foreground">
                              per document
                            </div>
                          </div>

                          {/* Checkmark */}
                          {isSelected && (
                            <motion.div
                              initial={{ scale: 0 }}
                              animate={{ scale: 1 }}
                              className="absolute -right-2 -top-2 flex h-6 w-6 items-center justify-center rounded-full bg-primary shadow-lg"
                            >
                              <CheckCircle2 className="h-4 w-4 text-white" />
                            </motion.div>
                          )}
                        </label>
                      </motion.div>
                    );
                  })}
                </RadioGroup>
              </div>

              {/* Features */}
              <div className="flex flex-wrap gap-4 rounded-lg bg-muted/50 p-4">
                {features.map((feature, index) => (
                  <div
                    key={index}
                    className="flex items-center gap-2 text-sm text-muted-foreground"
                  >
                    <feature.icon className="h-4 w-4 text-primary" />
                    <span>{feature.text}</span>
                  </div>
                ))}
              </div>

              {/* Next Button */}
              <Button
                type="button"
                className="w-full"
                size="lg"
                onClick={goToNextStep}
              >
                Continue
                <ArrowRight className="ml-2 h-4 w-4" />
              </Button>
            </motion.div>
          )}

          {/* Step 2: Upload Documents */}
          {currentStep === 1 && (
            <motion.div
              key="step-2"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
              transition={{ duration: 0.3 }}
              className="space-y-6"
            >
              {/* Document Count */}
              <div className="space-y-3">
                <Label htmlFor="documentCount" className="text-base font-semibold">
                  How many documents?
                </Label>
                <div className="flex items-center gap-4">
                  <Input
                    id="documentCount"
                    type="number"
                    min={1}
                    max={10}
                    {...form.register("documentCount", { valueAsNumber: true })}
                    className={cn(
                      "h-12 text-center text-lg font-semibold w-24",
                      form.formState.errors.documentCount && "border-destructive"
                    )}
                  />
                  <span className="text-muted-foreground">document(s)</span>
                </div>
                {form.formState.errors.documentCount && (
                  <p className="text-sm text-destructive">
                    {form.formState.errors.documentCount.message}
                  </p>
                )}
              </div>

              {/* Word Count */}
              <div className="space-y-3">
                <Label htmlFor="wordCountApprox" className="text-base font-semibold">
                  Approximate word count (per doc)
                </Label>
                <Input
                  id="wordCountApprox"
                  type="number"
                  min={100}
                  max={100000}
                  {...form.register("wordCountApprox", { valueAsNumber: true })}
                  className="h-12"
                  placeholder="e.g., 5000"
                />
                <p className="text-xs text-muted-foreground">
                  This helps us estimate processing time
                </p>
              </div>

              {/* File Upload */}
              <div className="space-y-3">
                <div className="space-y-1">
                  <Label className="text-base font-semibold">
                    Upload your document(s)
                  </Label>
                  <p className="text-sm text-muted-foreground">
                    Supported formats: PDF, DOC, DOCX, or images
                  </p>
                </div>
                <FileUploadZone
                  files={files}
                  onFilesChange={setFiles}
                  maxFiles={10}
                />
              </div>

              {/* Navigation */}
              <div className="flex gap-3">
                <Button
                  type="button"
                  variant="outline"
                  className="flex-1"
                  onClick={goToPrevStep}
                >
                  Back
                </Button>
                <Button
                  type="button"
                  className="flex-1"
                  onClick={goToNextStep}
                  disabled={files.length === 0}
                >
                  Continue
                  <ArrowRight className="ml-2 h-4 w-4" />
                </Button>
              </div>
            </motion.div>
          )}

          {/* Step 3: Review & Submit */}
          {currentStep === 2 && (
            <motion.div
              key="step-3"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
              transition={{ duration: 0.3 }}
              className="space-y-6"
            >
              <div className="space-y-1">
                <Label className="text-base font-semibold">Review Your Order</Label>
                <p className="text-sm text-muted-foreground">
                  Please confirm your details before submitting
                </p>
              </div>

              {/* Order Summary Card */}
              <Card className="overflow-hidden border-2">
                <div className={cn(
                  "bg-gradient-to-r p-4",
                  selectedReport?.color
                )}>
                  <div className="flex items-center gap-3">
                    {selectedReport && (
                      <div className={cn("rounded-lg p-2", selectedReport.iconBg)}>
                        <selectedReport.icon className="h-5 w-5 text-white" />
                      </div>
                    )}
                    <div>
                      <div className="font-semibold">{selectedReport?.label}</div>
                      <div className="text-sm text-muted-foreground">
                        {selectedReport?.description}
                      </div>
                    </div>
                  </div>
                </div>
                <CardContent className="p-4 space-y-4">
                  {/* Details */}
                  <div className="grid grid-cols-2 gap-4 text-sm">
                    <div className="space-y-1">
                      <div className="text-muted-foreground">Documents</div>
                      <div className="font-medium">{watchDocCount || 1} file(s)</div>
                    </div>
                    <div className="space-y-1">
                      <div className="text-muted-foreground">Word Count</div>
                      <div className="font-medium">
                        ~{form.watch("wordCountApprox")?.toLocaleString()} words
                      </div>
                    </div>
                    <div className="space-y-1">
                      <div className="text-muted-foreground">Delivery</div>
                      <div className="font-medium">Within 24 hours</div>
                    </div>
                    <div className="space-y-1">
                      <div className="text-muted-foreground">Files Uploaded</div>
                      <div className="font-medium">{files.length} file(s)</div>
                    </div>
                  </div>

                  {/* Price Summary */}
                  <div className="border-t pt-4 space-y-2">
                    <div className="flex justify-between text-sm">
                      <span className="text-muted-foreground">
                        {selectedReport?.label} × {watchDocCount || 1}
                      </span>
                      <span>₹{basePrice}</span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-muted-foreground">GST (18%)</span>
                      <span>₹{Math.round(gst)}</span>
                    </div>
                    <div className="flex justify-between border-t pt-2">
                      <span className="text-lg font-semibold">Total</span>
                      <span className="text-2xl font-bold text-primary">
                        ₹{Math.round(totalPrice)}
                      </span>
                    </div>
                  </div>
                </CardContent>
              </Card>

              {/* Navigation */}
              <div className="flex gap-3">
                <Button
                  type="button"
                  variant="outline"
                  className="flex-1"
                  onClick={goToPrevStep}
                  disabled={isSubmitting}
                >
                  Back
                </Button>
                <Button
                  type="submit"
                  className="flex-1"
                  size="lg"
                  disabled={isSubmitting}
                >
                  {isSubmitting ? (
                    <>
                      <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                      Processing...
                    </>
                  ) : (
                    <>
                      <Send className="mr-2 h-4 w-4" />
                      Get Report - ₹{Math.round(totalPrice)}
                    </>
                  )}
                </Button>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </form>
    </div>
  );
}
