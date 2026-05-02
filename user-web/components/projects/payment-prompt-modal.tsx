"use client";

import { useEffect, useState } from "react";
import { CreditCard, CheckCircle2 } from "lucide-react";
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetDescription,
} from "@/components/ui/sheet";
import { Button } from "@/components/ui/button";
import { useProjectStore, type Project } from "@/stores/project-store";
import { cn } from "@/lib/utils";

interface PaymentPromptModalProps {
  onPay?: (project: Project) => void;
}

/**
 * Minimal payment prompt modal
 * Shows when user has unpaid quotes
 */
export function PaymentPromptModal({ onPay }: PaymentPromptModalProps) {
  const { showPaymentPrompt, unpaidProject, dismissPaymentPrompt } =
    useProjectStore();
  const [isOpen, setIsOpen] = useState(false);

  // Delay showing the modal slightly for better UX
  useEffect(() => {
    if (showPaymentPrompt && unpaidProject) {
      const timer = setTimeout(() => {
        setIsOpen(true);
      }, 1000); // 1 second delay

      return () => clearTimeout(timer);
    }
  }, [showPaymentPrompt, unpaidProject]);

  const handleClose = () => {
    setIsOpen(false);
    dismissPaymentPrompt();
  };

  const handlePay = () => {
    if (unpaidProject && onPay) {
      onPay(unpaidProject);
    }
    handleClose();
  };

  if (!unpaidProject) return null;

  return (
    <Sheet open={isOpen} onOpenChange={(open) => !open && handleClose()}>
      <SheetContent side="bottom" className="h-auto max-h-[90vh] p-6">
        <SheetHeader className="text-left space-y-1">
          <SheetTitle className="text-base font-medium">Quote Ready</SheetTitle>
          <SheetDescription className="text-xs text-muted-foreground">
            Your project has been reviewed and quoted
          </SheetDescription>
        </SheetHeader>

        <div className="space-y-4 pt-4 pb-2">
          {/* Project Info - Minimal */}
          <div className="space-y-1.5">
            <p className="text-xs text-muted-foreground">
              {unpaidProject.projectNumber}
            </p>
            <p className="text-sm font-medium">{unpaidProject.title}</p>
            {unpaidProject.subjectName && (
              <p className="text-xs text-muted-foreground">
                {unpaidProject.subjectName}
              </p>
            )}
          </div>

          {/* Amount - Clean display */}
          <div className="rounded-md border bg-muted/30 p-3 space-y-1.5">
            <div className="flex items-center justify-between text-xs">
              <span className="text-muted-foreground">Quote Amount</span>
              <span className="font-medium">₹{unpaidProject.quoteAmount?.toLocaleString("en-IN") || 0}</span>
            </div>
            <div className="flex items-center justify-between text-xs">
              <span className="text-muted-foreground">Validity</span>
              <span className="text-green-600 font-medium">24 hours</span>
            </div>
          </div>

          {/* Action Buttons */}
          <div className="space-y-2 pt-2">
            <Button
              onClick={handlePay}
              className="w-full h-9 text-sm"
            >
              <CreditCard className="h-4 w-4 mr-2" />
              Proceed to Pay
            </Button>
            <button
              onClick={handleClose}
              className={cn(
                "w-full text-xs text-muted-foreground",
                "hover:text-foreground transition-colors",
                "py-2"
              )}
            >
              I'll pay later
            </button>
          </div>

          {/* Trust indicator */}
          <div className="flex items-center justify-center gap-2 text-xs text-muted-foreground pt-2 border-t">
            <CheckCircle2 className="h-3 w-3" />
            <span>Work begins after payment</span>
          </div>
        </div>
      </SheetContent>
    </Sheet>
  );
}
