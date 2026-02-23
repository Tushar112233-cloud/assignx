"use client";

import { useState } from "react";
import { Mail, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { toast } from "sonner";
import { createSupportTicket } from "@/lib/actions/data";

/**
 * Contact form data interface
 */
interface ContactFormData {
  subject: string;
  message: string;
  category: string;
}

/**
 * Contact categories
 */
const contactCategories = [
  { value: "general", label: "General Inquiry" },
  { value: "billing", label: "Billing & Payments" },
  { value: "technical", label: "Technical Issue" },
  { value: "project", label: "Project Related" },
  { value: "account", label: "Account Issues" },
];

/**
 * Contact form for support requests
 * Submits tickets to Supabase
 */
export function ContactForm() {
  const [form, setForm] = useState<ContactFormData>({
    subject: "",
    message: "",
    category: "general",
  });
  const [isSubmitting, setIsSubmitting] = useState(false);

  /**
   * Validates and submits contact form
   */
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!form.subject || !form.message) {
      toast.error("Please fill in all required fields");
      return;
    }

    setIsSubmitting(true);
    try {
      const result = await createSupportTicket({
        subject: form.subject,
        description: form.message,
        category: form.category,
      });

      if (result.error) {
        toast.error(result.error);
        return;
      }

      toast.success("Ticket created! We'll get back to you soon.");
      setForm({ subject: "", message: "", category: "general" });

      // Reload page to show new ticket in history
      window.location.reload();
    } catch {
      toast.error("Failed to create ticket");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Mail className="h-5 w-5" />
          Contact Us
        </CardTitle>
        <CardDescription>
          Create a support ticket and we&apos;ll respond within 24 hours
        </CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid gap-4 sm:grid-cols-2">
            <div className="space-y-2">
              <Label>Category</Label>
              <Select
                value={form.category}
                onValueChange={(v) => setForm((p) => ({ ...p, category: v }))}
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {contactCategories.map((c) => (
                    <SelectItem key={c.value} value={c.value}>
                      {c.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <Label htmlFor="subject">Subject *</Label>
              <Input
                id="subject"
                value={form.subject}
                onChange={(e) =>
                  setForm((p) => ({ ...p, subject: e.target.value }))
                }
                placeholder="Brief subject"
                required
              />
            </div>
          </div>
          <div className="space-y-2">
            <Label htmlFor="message">Message *</Label>
            <Textarea
              id="message"
              value={form.message}
              onChange={(e) =>
                setForm((p) => ({ ...p, message: e.target.value }))
              }
              placeholder="Describe your issue in detail..."
              rows={4}
              required
            />
          </div>
          <Button type="submit" disabled={isSubmitting} className="w-full">
            {isSubmitting ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Creating Ticket...
              </>
            ) : (
              "Create Support Ticket"
            )}
          </Button>
        </form>
      </CardContent>
    </Card>
  );
}
