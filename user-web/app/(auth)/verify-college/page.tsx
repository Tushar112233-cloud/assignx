/**
 * @fileoverview College Email Verification Page
 *
 * Allows students to verify their college email address
 * to access Campus Connect features. Supports both new
 * users and existing users adding a college email.
 *
 * @route /verify-college
 * @access public
 */

"use client";

import { Suspense } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { AuthLayout } from "@/components/auth/auth-layout";
import { CollegeVerifyForm } from "@/components/auth/college-verify-form";
import { GraduationCap } from "lucide-react";

/**
 * Loading skeleton for the page
 */
function LoadingSkeleton() {
  return (
    <div className="animate-pulse">
      <div className="mx-auto mb-4 h-12 w-12 rounded-full bg-muted" />
      <div className="mx-auto mb-2 h-8 w-48 rounded bg-muted" />
      <div className="mx-auto mb-6 h-4 w-64 rounded bg-muted" />
      <div className="mb-4 h-24 rounded-lg bg-muted" />
      <div className="h-12 rounded-md bg-muted" />
    </div>
  );
}

/**
 * Main content component with search params access
 */
function VerifyCollegeContent() {
  const router = useRouter();
  const searchParams = useSearchParams();

  // Check if user is adding college email to existing account
  const isAddingToAccount = searchParams.get("add") === "true";
  // Get redirect path after verification
  const redirectTo = searchParams.get("redirect") || "/home";

  const handleBack = () => {
    if (isAddingToAccount) {
      router.push("/profile");
    } else {
      router.push("/login");
    }
  };

  const handleSuccess = (email: string) => {
    // Success is handled within the form component
    // The user will receive an email and click the link
    console.log("Verification sent to:", email);
  };

  return (
    <AuthLayout
      heading={
        <>
          Unlock <span className="text-white/60 font-normal">Campus Connect</span>
        </>
      }
      subheading="Verify your college email to collaborate with fellow students, access exclusive resources, and connect with your campus community."
      stats={[
        { value: "500+", label: "Colleges" },
        { value: "25K+", label: "Students" },
        { value: "Free", label: "Always" },
      ]}
    >
      <CollegeVerifyForm
        onBack={handleBack}
        onSuccess={handleSuccess}
        isAddingToAccount={isAddingToAccount}
      />
    </AuthLayout>
  );
}

/**
 * College Email Verification Page
 *
 * Features:
 * - College email input with domain validation
 * - Support for .edu, .edu.in, .ac.in, .ac.uk domains
 * - Can be used for new users or adding to existing account
 * - Sends verification magic link
 * - Success state with next steps
 */
export default function VerifyCollegePage() {
  return (
    <Suspense fallback={<LoadingSkeleton />}>
      <VerifyCollegeContent />
    </Suspense>
  );
}
