import { Suspense } from "react";
import { ProfessionalSignupForm } from "@/components/auth/professional-signup-form";

/**
 * Professional/Business signup page
 */
export default function ProfessionalSignupPage() {
  return (
    <Suspense
      fallback={
        <div className="flex min-h-screen items-center justify-center">
          <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
        </div>
      }
    >
      <ProfessionalSignupForm />
    </Suspense>
  );
}
