"use client";

import { useState } from "react";
import { Loader2 } from "lucide-react";
import { motion } from "framer-motion";
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetDescription, SheetFooter } from "@/components/ui/sheet";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { toast } from "sonner";
import { submitConnectQuestion } from "@/lib/actions/data";
import { subjectFilters } from "@/lib/data/connect";

/** Props for AskQuestionSheet component */
interface AskQuestionSheetProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onSuccess?: () => void;
}

/** Sheet for asking a new question */
export function AskQuestionSheet({ open, onOpenChange, onSuccess }: AskQuestionSheetProps) {
  const [form, setForm] = useState({ title: "", content: "", subject: "", tags: "" });
  const [isSubmitting, setIsSubmitting] = useState(false);

  /** Submits the question */
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form.title || !form.content || !form.subject) {
      toast.error("Please fill in all required fields");
      return;
    }
    setIsSubmitting(true);
    try {
      // Combine title and content into question field
      const fullQuestion = `${form.title}\n\n${form.content}${form.tags ? `\n\nTags: ${form.tags}` : ""}`;
      const result = await submitConnectQuestion({
        question: fullQuestion,
        category: form.subject,
      });
      if (result.error) {
        toast.error(result.error);
        return;
      }
      toast.success("Question posted successfully!");
      setForm({ title: "", content: "", subject: "", tags: "" });
      onOpenChange(false);
      onSuccess?.();
    } catch {
      toast.error("Failed to post question");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent side="bottom" className="h-[85vh] rounded-t-xl flex flex-col">
        <SheetHeader>
          <SheetTitle>Ask a Question</SheetTitle>
          <SheetDescription>Get help from the community</SheetDescription>
        </SheetHeader>
        <form onSubmit={handleSubmit} className="flex flex-col flex-1">
          <div className="flex-1 overflow-y-auto px-4 space-y-4">
            <div className="space-y-2">
              <Label htmlFor="title">Question Title *</Label>
              <Input
                id="title"
                value={form.title}
                onChange={(e) => setForm((p) => ({ ...p, title: e.target.value }))}
                placeholder="What's your question?"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="content">Details *</Label>
              <Textarea
                id="content"
                value={form.content}
                onChange={(e) => setForm((p) => ({ ...p, content: e.target.value }))}
                placeholder="Provide more context..."
                rows={4}
              />
            </div>
            <div className="space-y-2">
              <Label>Subject *</Label>
              <Select value={form.subject} onValueChange={(v) => setForm((p) => ({ ...p, subject: v }))}>
                <SelectTrigger><SelectValue placeholder="Select subject" /></SelectTrigger>
                <SelectContent>
                  {subjectFilters.slice(1).map((s) => <SelectItem key={s} value={s}>{s}</SelectItem>)}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <Label htmlFor="tags">Tags (comma separated)</Label>
              <Input
                id="tags"
                value={form.tags}
                onChange={(e) => setForm((p) => ({ ...p, tags: e.target.value }))}
                placeholder="react, hooks, javascript"
              />
            </div>
          </div>
          <SheetFooter>
            <motion.div whileTap={{ scale: 0.98 }} className="w-full">
              <Button type="submit" className="w-full" disabled={isSubmitting}>
                {isSubmitting ? <><Loader2 className="mr-2 h-4 w-4 animate-spin" />Posting...</> : "Post Question"}
              </Button>
            </motion.div>
          </SheetFooter>
        </form>
      </SheetContent>
    </Sheet>
  );
}
