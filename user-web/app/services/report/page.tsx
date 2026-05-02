"use client";

import { useState } from "react";
import { ReportForm, SubmissionSuccess } from "@/components/add-project";

/**
 * AI/Plagiarism Report Service Page
 * Direct access to report form
 */
export default function ReportServicePage() {
  const [success, setSuccess] = useState<{
    projectId: string;
    projectNumber: string;
  } | null>(null);

  const handleSuccess = (projectId: string, projectNumber: string) => {
    setSuccess({ projectId, projectNumber });
  };

  return (
    <div className="min-h-screen bg-background">
      <div className="mx-auto max-w-2xl px-4 py-8">
        {success ? (
          <SubmissionSuccess
            projectId={success.projectId}
            projectNumber={success.projectNumber}
            serviceType="report"
          />
        ) : (
          <ReportForm onSuccess={handleSuccess} />
        )}
      </div>
    </div>
  );
}
