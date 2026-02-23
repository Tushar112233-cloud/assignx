"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import { Loader2, GraduationCap, CheckCircle2, ArrowLeft, AlertCircle } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { toast } from "sonner";

/**
 * Supported college email domain patterns
 */
const COLLEGE_EMAIL_PATTERNS = [
  /\.edu$/i,
  /\.edu\.in$/i,
  /\.ac\.in$/i,
  /\.ac\.uk$/i,
  /\.edu\.au$/i,
  /\.edu\.ca$/i,
  /\.edu\.[a-z]{2}$/i,
];

/**
 * Example college email domains to show users
 */
const EXAMPLE_DOMAINS = [
  ".edu",
  ".edu.in",
  ".ac.in",
  ".ac.uk",
];

/**
 * Props for CollegeVerifyForm component
 */
interface CollegeVerifyFormProps {
  /** Callback when user wants to go back */
  onBack?: () => void;
  /** Callback when verification is successfully initiated */
  onSuccess?: (email: string) => void;
  /** Whether user is already logged in (adding college email to existing account) */
  isAddingToAccount?: boolean;
  /** Additional CSS classes */
  className?: string;
}

/**
 * CollegeVerifyForm - College email verification form
 *
 * Allows students to verify their college email address
 * to access Campus Connect features. Validates email
 * against known educational institution patterns.
 *
 * @example
 * ```tsx
 * <CollegeVerifyForm
 *   onBack={() => router.back()}
 *   onSuccess={(email) => console.log('Verification sent to', email)}
 * />
 * ```
 */
export function CollegeVerifyForm({
  onBack,
  onSuccess,
  isAddingToAccount = false,
  className = "",
}: CollegeVerifyFormProps) {
  const [email, setEmail] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [isSent, setIsSent] = useState(false);
  const [error, setError] = useState<string | null>(null);

  /**
   * Validates if email is from a college domain
   */
  const validateCollegeEmail = (email: string): { isValid: boolean; error?: string } => {
    const normalizedEmail = email.toLowerCase().trim();

    // Basic format check
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(normalizedEmail)) {
      return { isValid: false, error: "Please enter a valid email address" };
    }

    // Extract domain
    const domain = normalizedEmail.split("@")[1];
    if (!domain) {
      return { isValid: false, error: "Invalid email format" };
    }

    // Check against college patterns
    const isCollegeEmail = COLLEGE_EMAIL_PATTERNS.some(pattern => pattern.test(domain));

    if (!isCollegeEmail) {
      return {
        isValid: false,
        error: `Please use your college/university email address (${EXAMPLE_DOMAINS.join(", ")})`,
      };
    }

    return { isValid: true };
  };

  /**
   * Handles form submission
   */
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    // Validate email
    const validation = validateCollegeEmail(email);
    if (!validation.isValid) {
      setError(validation.error || "Invalid email");
      return;
    }

    setIsLoading(true);

    try {
      const response = await fetch("/api/auth/verify-college", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          email: email.trim().toLowerCase(),
          isAddingToAccount,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || "Failed to send verification");
      }

      setIsSent(true);
      onSuccess?.(email);
      toast.success("Verification email sent!", {
        description: "Check your college email inbox for the verification link.",
      });
    } catch (err) {
      const message = err instanceof Error ? err.message : "Something went wrong";
      setError(message);
      toast.error("Failed to send verification", {
        description: message,
      });
    } finally {
      setIsLoading(false);
    }
  };

  /**
   * Resets the form to try a different email
   */
  const handleTryAgain = () => {
    setIsSent(false);
    setEmail("");
    setError(null);
  };

  // Success state - verification sent
  if (isSent) {
    return (
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className={`text-center ${className}`}
      >
        <div className="mx-auto mb-6 flex h-16 w-16 items-center justify-center rounded-full bg-green-100 dark:bg-green-900/30">
          <CheckCircle2 className="h-8 w-8 text-green-600 dark:text-green-400" />
        </div>
        <h2 className="mb-2 text-2xl font-semibold text-foreground">
          Verification email sent!
        </h2>
        <p className="mb-6 text-muted-foreground">
          We sent a verification link to{" "}
          <span className="font-medium text-foreground">{email}</span>
        </p>
        <div className="mb-6 rounded-lg bg-muted/50 p-4">
          <p className="text-sm text-muted-foreground">
            Click the link in your college email to verify your student status.
            The link expires in 10 minutes.
          </p>
        </div>
        <div className="space-y-3">
          <Button
            variant="outline"
            onClick={handleTryAgain}
            className="w-full"
          >
            Use a different email
          </Button>
          {onBack && (
            <Button
              variant="ghost"
              onClick={onBack}
              className="w-full"
            >
              <ArrowLeft className="mr-2 h-4 w-4" />
              Back
            </Button>
          )}
        </div>
      </motion.div>
    );
  }

  // Form state
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className={className}
    >
      {onBack && (
        <Button
          variant="ghost"
          size="sm"
          onClick={onBack}
          className="mb-4 -ml-2"
        >
          <ArrowLeft className="mr-2 h-4 w-4" />
          Back
        </Button>
      )}

      <div className="mb-6 text-center">
        <div className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-primary/10">
          <GraduationCap className="h-6 w-6 text-primary" />
        </div>
        <h2 className="text-2xl font-semibold text-foreground">
          {isAddingToAccount ? "Add College Email" : "Verify College Email"}
        </h2>
        <p className="mt-2 text-sm text-muted-foreground">
          {isAddingToAccount
            ? "Link your college email to unlock Campus Connect features"
            : "Verify your student status to access Campus Connect"}
        </p>
      </div>

      {/* Info box */}
      <div className="mb-6 rounded-lg border border-blue-200 bg-blue-50 p-4 dark:border-blue-900 dark:bg-blue-950/50">
        <div className="flex gap-3">
          <AlertCircle className="h-5 w-5 shrink-0 text-blue-600 dark:text-blue-400" />
          <div className="text-sm">
            <p className="font-medium text-blue-900 dark:text-blue-100">
              What is Campus Connect?
            </p>
            <p className="mt-1 text-blue-700 dark:text-blue-300">
              Campus Connect lets you collaborate with fellow students, access
              exclusive resources, and connect with peers from your college.
            </p>
          </div>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <Input
            type="email"
            placeholder="yourname@college.edu"
            value={email}
            onChange={(e) => {
              setEmail(e.target.value);
              setError(null);
            }}
            disabled={isLoading}
            aria-invalid={!!error}
            className="h-12"
          />
          {error && (
            <motion.p
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              className="mt-2 text-sm text-destructive"
            >
              {error}
            </motion.p>
          )}
        </div>

        <Button
          type="submit"
          disabled={isLoading || !email.trim()}
          className="h-12 w-full"
        >
          {isLoading ? (
            <>
              <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              Sending verification...
            </>
          ) : (
            "Send Verification Link"
          )}
        </Button>
      </form>

      <p className="mt-4 text-center text-xs text-muted-foreground">
        Supported domains: {EXAMPLE_DOMAINS.join(", ")}
      </p>
    </motion.div>
  );
}
