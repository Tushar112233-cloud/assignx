"use client";

import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Button } from "@/components/ui/button";

interface TermsModalProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

/**
 * Terms and conditions modal dialog
 * Displays T&C and Privacy Policy content
 */
export function TermsModal({ open, onOpenChange }: TermsModalProps) {
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-2xl">
        <DialogHeader>
          <DialogTitle>Terms of Service & Privacy Policy</DialogTitle>
          <DialogDescription>
            Please read our terms and conditions carefully
          </DialogDescription>
        </DialogHeader>
        <ScrollArea className="h-[60vh] pr-4">
          <div className="space-y-6 text-sm">
            <section>
              <h3 className="mb-2 text-lg font-semibold">1. Terms of Service</h3>
              <p className="text-muted-foreground">
                Welcome to AssignX. By accessing or using our services, you agree
                to be bound by these Terms of Service. Please read them carefully.
              </p>
            </section>

            <section>
              <h4 className="mb-2 font-semibold">1.1 Service Description</h4>
              <p className="text-muted-foreground">
                AssignX provides a platform connecting users with professional
                experts for project assistance, including but not limited to
                academic projects, career documents, and business content. We act
                as an intermediary platform and do not directly create content.
              </p>
            </section>

            <section>
              <h4 className="mb-2 font-semibold">1.2 User Responsibilities</h4>
              <ul className="list-disc space-y-1 pl-4 text-muted-foreground">
                <li>Provide accurate information during registration</li>
                <li>Use the platform for legitimate purposes only</li>
                <li>Respect intellectual property rights</li>
                <li>Not share account credentials with others</li>
                <li>Report any issues or concerns promptly</li>
              </ul>
            </section>

            <section>
              <h4 className="mb-2 font-semibold">1.3 Payment Terms</h4>
              <p className="text-muted-foreground">
                All payments are processed securely through our payment partners.
                Refunds are subject to our refund policy. Wallet credits are
                non-transferable and may expire as per policy.
              </p>
            </section>

            <section>
              <h3 className="mb-2 text-lg font-semibold">2. Privacy Policy</h3>
              <p className="text-muted-foreground">
                Your privacy is important to us. This policy explains how we
                collect, use, and protect your personal information.
              </p>
            </section>

            <section>
              <h4 className="mb-2 font-semibold">2.1 Information We Collect</h4>
              <ul className="list-disc space-y-1 pl-4 text-muted-foreground">
                <li>Account information (name, email, phone)</li>
                <li>Academic/professional details</li>
                <li>Project requirements and files</li>
                <li>Payment information (processed securely)</li>
                <li>Usage data and analytics</li>
              </ul>
            </section>

            <section>
              <h4 className="mb-2 font-semibold">2.2 How We Use Your Data</h4>
              <ul className="list-disc space-y-1 pl-4 text-muted-foreground">
                <li>To provide and improve our services</li>
                <li>To communicate with you about your projects</li>
                <li>To process payments and transactions</li>
                <li>To send relevant updates and notifications</li>
                <li>To ensure platform security</li>
              </ul>
            </section>

            <section>
              <h4 className="mb-2 font-semibold">2.3 Data Security</h4>
              <p className="text-muted-foreground">
                We implement industry-standard security measures to protect your
                data. All communications are encrypted, and we regularly audit our
                security practices.
              </p>
            </section>

            <section>
              <h4 className="mb-2 font-semibold">2.4 Contact Us</h4>
              <p className="text-muted-foreground">
                If you have questions about these terms or our privacy practices,
                please contact us at support@assignx.com
              </p>
            </section>
          </div>
        </ScrollArea>
        <div className="flex justify-end">
          <Button onClick={() => onOpenChange(false)}>I Understand</Button>
        </div>
      </DialogContent>
    </Dialog>
  );
}
