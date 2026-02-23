"use client";

import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { Loader2, Send, Clock } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Card, CardContent } from "@/components/ui/card";
import { FileUploadZone } from "./file-upload-zone";
import {
  proofreadingFormSchema,
  type ProofreadingFormSchema,
} from "@/lib/validations/project";
import { documentTypes, turnaroundTimes } from "@/lib/data/subjects";
import { createProject, uploadProjectFile } from "@/lib/actions/data";
import type { UploadedFile } from "@/types/add-project";
import { toast } from "sonner";
import { cn } from "@/lib/utils";

interface ProofreadingFormProps {
  onSuccess: (projectId: string, projectNumber: string) => void;
  onStepChange?: (step: number) => void;
}

/**
 * Proofreading service form
 */
export function ProofreadingForm({ onSuccess, onStepChange }: ProofreadingFormProps) {
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [files, setFiles] = useState<UploadedFile[]>([]);

  const form = useForm<ProofreadingFormSchema>({
    resolver: zodResolver(proofreadingFormSchema),
    defaultValues: {
      documentType: "",
      wordCount: 1000,
      turnaroundTime: "48h",
      additionalNotes: "",
    },
  });

  const watchWordCount = form.watch("wordCount");
  const watchTurnaround = form.watch("turnaroundTime");

  // Calculate price based on word count and turnaround time
  const selectedTurnaround = turnaroundTimes.find(
    (t) => t.value === watchTurnaround
  );
  const pricePerWord = selectedTurnaround?.price || 0.03;
  const basePrice = (watchWordCount || 0) * pricePerWord;
  const gst = basePrice * 0.18;
  const totalPrice = basePrice + gst;

  const handleSubmit = form.handleSubmit(async (data) => {
    if (files.length === 0) {
      toast.error("Please upload at least one document");
      return;
    }

    setIsSubmitting(true);

    try {
      // Create project in database
      const result = await createProject({
        serviceType: "proofreading",
        title: `Proofreading - ${data.documentType}`,
        wordCount: data.wordCount,
        deadline: new Date(
          Date.now() + (data.turnaroundTime === "24h" ? 24 : 48) * 60 * 60 * 1000
        ).toISOString(),
        instructions: data.additionalNotes,
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
        {/* Document Type */}
        <div className="space-y-2">
          <Label>Document Type</Label>
          <Select
            value={form.watch("documentType")}
            onValueChange={(value) => form.setValue("documentType", value)}
          >
            <SelectTrigger
              className={
                form.formState.errors.documentType ? "border-destructive" : ""
              }
            >
              <SelectValue placeholder="Select document type" />
            </SelectTrigger>
            <SelectContent>
              {documentTypes.map((type) => (
                <SelectItem key={type.id} value={type.id}>
                  {type.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
          {form.formState.errors.documentType && (
            <p className="text-sm text-destructive">
              {form.formState.errors.documentType.message}
            </p>
          )}
        </div>

        {/* Word Count */}
        <div className="space-y-2">
          <Label htmlFor="wordCount">Word Count (Approximate)</Label>
          <Input
            id="wordCount"
            type="number"
            min={100}
            max={100000}
            {...form.register("wordCount", { valueAsNumber: true })}
            className={
              form.formState.errors.wordCount ? "border-destructive" : ""
            }
          />
          {form.formState.errors.wordCount && (
            <p className="text-sm text-destructive">
              {form.formState.errors.wordCount.message}
            </p>
          )}
        </div>

        {/* Turnaround Time */}
        <div className="space-y-3">
          <Label>Turnaround Time</Label>
          <RadioGroup
            value={form.watch("turnaroundTime")}
            onValueChange={(value) =>
              form.setValue("turnaroundTime", value as "24h" | "48h" | "72h")
            }
            className="space-y-3"
          >
            {turnaroundTimes.map((time) => (
              <div
                key={time.value}
                className={cn(
                  "flex items-center space-x-3 rounded-lg border p-4 transition-colors",
                  form.watch("turnaroundTime") === time.value &&
                    "border-primary bg-primary/5"
                )}
              >
                <RadioGroupItem value={time.value} id={time.value} />
                <Label
                  htmlFor={time.value}
                  className="flex flex-1 cursor-pointer items-center justify-between font-normal"
                >
                  <div className="flex items-center gap-2">
                    <Clock className="h-4 w-4 text-muted-foreground" />
                    <span className="font-medium">{time.label}</span>
                  </div>
                  <span className="text-sm text-muted-foreground">
                    ₹{time.price}/word
                  </span>
                </Label>
              </div>
            ))}
          </RadioGroup>
        </div>

        {/* File Upload */}
        <div className="space-y-2">
          <Label>Upload Document(s) *</Label>
          <FileUploadZone files={files} onFilesChange={setFiles} maxFiles={3} />
        </div>

        {/* Additional Notes */}
        <div className="space-y-2">
          <Label htmlFor="additionalNotes">Additional Notes (Optional)</Label>
          <Textarea
            id="additionalNotes"
            placeholder="Any specific areas to focus on..."
            rows={3}
            {...form.register("additionalNotes")}
          />
        </div>

        {/* Price Summary */}
        {watchWordCount > 0 && (
          <Card className="bg-muted/50">
            <CardContent className="p-4">
              <div className="space-y-2 text-sm">
                <div className="flex justify-between">
                  <span className="text-muted-foreground">
                    {watchWordCount.toLocaleString()} words × ₹{pricePerWord}
                  </span>
                  <span>₹{basePrice.toFixed(2)}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">GST (18%)</span>
                  <span>₹{gst.toFixed(2)}</span>
                </div>
                <div className="flex justify-between border-t pt-2">
                  <span className="font-medium">Total</span>
                  <span className="font-bold text-primary">
                    ₹{Math.round(totalPrice).toLocaleString()}
                  </span>
                </div>
              </div>
            </CardContent>
          </Card>
        )}

        <Button type="submit" className="w-full" disabled={isSubmitting}>
          {isSubmitting ? (
            <>
              <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              Submitting...
            </>
          ) : (
            <>
              <Send className="mr-2 h-4 w-4" />
              Submit for Proofreading
            </>
          )}
        </Button>
      </form>
    </div>
  );
}
