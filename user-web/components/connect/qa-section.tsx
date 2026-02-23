"use client";

import { useState, useMemo } from "react";
import { Plus, Filter } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { QuestionCard } from "./question-card";
import { AskQuestionSheet } from "./ask-question-sheet";
import { questions, qaFilters, subjectFilters } from "@/lib/data/connect";
import type { QAFilterStatus } from "@/types/connect";

/** Q&A section for Connect page */
export function QASection() {
  const [askSheetOpen, setAskSheetOpen] = useState(false);
  const [statusFilter, setStatusFilter] = useState<QAFilterStatus>("all");
  const [subjectFilter, setSubjectFilter] = useState("All Subjects");

  /** Filtered questions based on status and subject */
  const filteredQuestions = useMemo(() => {
    return questions.filter((q) => {
      if (statusFilter === "answered" && !q.isAnswered) return false;
      if (statusFilter === "unanswered" && q.isAnswered) return false;
      if (subjectFilter !== "All Subjects" && q.subject !== subjectFilter) return false;
      return true;
    });
  }, [statusFilter, subjectFilter]);

  return (
    <section className="space-y-4">
      <div className="flex items-center justify-between">
        <h2 className="text-lg font-semibold">Questions & Answers</h2>
        <Button onClick={() => setAskSheetOpen(true)}>
          <Plus className="mr-2 h-4 w-4" />Ask Question
        </Button>
      </div>
      <div className="flex flex-wrap gap-2">
        <Select value={statusFilter} onValueChange={(v) => setStatusFilter(v as QAFilterStatus)}>
          <SelectTrigger className="w-[140px]"><Filter className="mr-2 h-4 w-4" /><SelectValue /></SelectTrigger>
          <SelectContent>
            {qaFilters.map((f) => <SelectItem key={f.value} value={f.value}>{f.label}</SelectItem>)}
          </SelectContent>
        </Select>
        <Select value={subjectFilter} onValueChange={setSubjectFilter}>
          <SelectTrigger className="w-[160px]"><SelectValue /></SelectTrigger>
          <SelectContent>
            {subjectFilters.map((s) => <SelectItem key={s} value={s}>{s}</SelectItem>)}
          </SelectContent>
        </Select>
      </div>
      <div className="space-y-3">
        {filteredQuestions.length === 0 ? (
          <div className="rounded-lg border border-dashed p-8 text-center">
            <p className="text-muted-foreground">No questions found</p>
            <Button variant="link" onClick={() => setAskSheetOpen(true)}>Be the first to ask!</Button>
          </div>
        ) : (
          filteredQuestions.map((q) => <QuestionCard key={q.id} question={q} />)
        )}
      </div>
      <AskQuestionSheet open={askSheetOpen} onOpenChange={setAskSheetOpen} />
    </section>
  );
}
