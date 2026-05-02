"use client";

import { Bot, FileSearch, Lock, CheckCircle, ExternalLink } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { cn } from "@/lib/utils";
import type { QualityReport } from "@/types/project";

interface QualityReportBadgeProps {
  reports: QualityReport[];
  className?: string;
}

interface SingleBadgeProps {
  report: QualityReport;
}

/**
 * Single quality report badge
 */
function SingleBadge({ report }: SingleBadgeProps) {
  const isAI = report.type === "ai";

  const handleClick = () => {
    if (report.status === "available" && report.reportUrl) {
      window.open(report.reportUrl, "_blank", "noopener,noreferrer");
    }
  };

  // Locked state
  if (report.status === "locked") {
    return (
      <div className="flex flex-1 flex-col items-center justify-center rounded-lg border border-dashed bg-muted/50 p-4 text-center">
        <div className="relative mb-2">
          {isAI ? (
            <Bot className="h-8 w-8 text-muted-foreground/40" />
          ) : (
            <FileSearch className="h-8 w-8 text-muted-foreground/40" />
          )}
          <Lock className="absolute -bottom-1 -right-1 h-4 w-4 text-muted-foreground/50" />
        </div>
        <p className="text-xs font-medium text-muted-foreground">
          {isAI ? "AI Detection" : "Plagiarism Check"}
        </p>
        <p className="mt-1 text-[10px] text-muted-foreground/70">
          Available after delivery
        </p>
      </div>
    );
  }

  // Passed state
  if (report.status === "passed") {
    return (
      <div className="flex flex-1 flex-col items-center justify-center rounded-lg border border-green-500 dark:border-green-600 p-4 text-center">
        <div className="relative mb-2">
          {isAI ? (
            <Bot className="h-8 w-8 text-green-500" />
          ) : (
            <FileSearch className="h-8 w-8 text-green-500" />
          )}
          <CheckCircle className="absolute -bottom-1 -right-1 h-4 w-4 text-green-500" />
        </div>
        <p className="text-xs font-medium text-green-600 dark:text-green-400">
          {isAI ? "Human Written" : `${report.score}% Unique`}
        </p>
        <p className="mt-1 text-[10px] text-green-600/70 dark:text-green-400/70">
          {isAI ? "AI Detection Passed" : "Plagiarism Check Passed"}
        </p>
      </div>
    );
  }

  // Available state (can view report)
  return (
    <button
      onClick={handleClick}
      className="flex flex-1 flex-col items-center justify-center rounded-lg border border-blue-200 bg-blue-50 p-4 text-center transition-colors hover:bg-blue-100 dark:border-blue-800 dark:bg-blue-900/20 dark:hover:bg-blue-900/30"
    >
      <div className="relative mb-2">
        {isAI ? (
          <Bot className="h-8 w-8 text-blue-500" />
        ) : (
          <FileSearch className="h-8 w-8 text-blue-500" />
        )}
        <ExternalLink className="absolute -bottom-1 -right-1 h-4 w-4 text-blue-500" />
      </div>
      <p className="text-xs font-medium text-blue-700 dark:text-blue-400">
        {isAI ? "View AI Report" : `${report.score}% Unique`}
      </p>
      <p className="mt-1 text-[10px] text-blue-600/70 dark:text-blue-400/70">
        Click to view full report
      </p>
    </button>
  );
}

/**
 * Quality reports section with AI and Plagiarism badges
 */
export function QualityReportBadge({
  reports,
  className,
}: QualityReportBadgeProps) {
  const aiReport = reports.find((r) => r.type === "ai");
  const plagReport = reports.find((r) => r.type === "plagiarism");

  return (
    <Card className={cn(className)}>
      <CardHeader className="pb-3">
        <CardTitle className="text-base">Quality Reports</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="flex gap-3">
          {aiReport && <SingleBadge report={aiReport} />}
          {plagReport && <SingleBadge report={plagReport} />}
        </div>
      </CardContent>
    </Card>
  );
}
