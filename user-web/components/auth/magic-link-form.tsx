"use client";

import { useState, useEffect, useRef } from "react";
import { motion } from "framer-motion";
import { Loader2, Mail, CheckCircle2, ArrowLeft } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { toast } from "sonner";

/**
 * Props for MagicLinkForm component
 */
interface MagicLinkFormProps {
  /** Callback when user wants to go back to other auth options */
  onBack?: () => void;
  /** Title to display above the form */
  title?: string;
  /** Description text */
  description?: string;
  /** Placeholder text for email input */
  placeholder?: string;
  /** Button text */
  buttonText?: string;
  /** Custom redirect path after magic link click */
  redirectTo?: string;
  /** Custom validation function for email */
  validateEmail?: (email: string) => { isValid: boolean; error?: string };
  /** Additional CSS classes */
  className?: string;
}

/**
 * MagicLinkForm - Passwordless authentication form
 *
 * Allows users to sign in via magic link sent to their email.
 * Supports custom validation for specific email requirements
 * (e.g., college emails only).
 *
 * @example
 * ```tsx
 * <MagicLinkForm
 *   title="Sign in with email"
 *   onBack={() => setShowMagicLink(false)}
 * />
 * ```
 */
export function MagicLinkForm({
  onBack,
  title = "Sign in with email",
  description = "We'll send you a magic link to sign in instantly. No password needed.",
  placeholder = "Enter your email address",
  buttonText = "Send Magic Link",
  redirectTo,
  validateEmail,
  className = "",
}: MagicLinkFormProps) {
  const [email, setEmail] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [isSent, setIsSent] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [cooldownSeconds, setCooldownSeconds] = useState(0);
  const cooldownRef = useRef<NodeJS.Timeout | null>(null);

  // Clean up interval on unmount
  useEffect(() => {
    return () => {
      if (cooldownRef.current) clearInterval(cooldownRef.current);
    };
  }, []);

  /**
   * Validates email format
   */
  const isValidEmailFormat = (email: string): boolean => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  };

  /**
   * Handles form submission
   */
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    // Basic validation
    if (!email.trim()) {
      setError("Please enter your email address");
      return;
    }

    if (!isValidEmailFormat(email)) {
      setError("Please enter a valid email address");
      return;
    }

    // Custom validation if provided
    if (validateEmail) {
      const validation = validateEmail(email);
      if (!validation.isValid) {
        setError(validation.error || "Invalid email address");
        return;
      }
    }

    setIsLoading(true);

    // TEST BYPASS: admin@gmail.com logs in directly with password
    if (email.trim().toLowerCase() === "admin@gmail.com") {
      try {
        const { createClient } = await import("@/lib/supabase/client");
        const supabase = createClient();
        const { error: signInError } = await supabase.auth.signInWithPassword({
          email: "admin@gmail.com",
          password: "Admin@123",
        });
        if (signInError) {
          setError(signInError.message);
          setIsLoading(false);
          return;
        }
        window.location.href = "/home";
        return;
      } catch {
        setError("Test login failed. Please try again.");
        setIsLoading(false);
        return;
      }
    }

    try {
      const response = await fetch("/api/auth/magic-link", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          email: email.trim().toLowerCase(),
          redirectTo,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || "Failed to send magic link");
      }

      setIsSent(true);
      // Start 60-second cooldown to prevent Supabase rate limit hits
      setCooldownSeconds(60);
      if (cooldownRef.current) clearInterval(cooldownRef.current);
      cooldownRef.current = setInterval(() => {
        setCooldownSeconds((prev) => {
          if (prev <= 1) {
            if (cooldownRef.current) clearInterval(cooldownRef.current);
            return 0;
          }
          return prev - 1;
        });
      }, 1000);
      toast.success("Magic link sent!", {
        description: "Check your email inbox for the sign-in link.",
      });
    } catch (err) {
      const message = err instanceof Error ? err.message : "Something went wrong";
      setError(message);
      toast.error("Failed to send magic link", {
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

  // Success state - magic link sent
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
          Check your email
        </h2>
        <p className="mb-6 text-muted-foreground">
          We sent a magic link to{" "}
          <span className="font-medium text-foreground">{email}</span>
        </p>
        <p className="mb-6 text-sm text-muted-foreground">
          Click the link in your email to sign in. The link expires in 10
          minutes.
        </p>
        <div className="space-y-3">
          <Button
            variant="outline"
            onClick={handleTryAgain}
            disabled={cooldownSeconds > 0}
            className="w-full"
          >
            {cooldownSeconds > 0
              ? `Resend in ${cooldownSeconds}s`
              : "Try a different email"}
          </Button>
          {onBack && (
            <Button
              variant="ghost"
              onClick={onBack}
              className="w-full"
            >
              <ArrowLeft className="mr-2 h-4 w-4" />
              Back to sign in options
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
          <Mail className="h-6 w-6 text-primary" />
        </div>
        <h2 className="text-2xl font-semibold text-foreground">{title}</h2>
        <p className="mt-2 text-sm text-muted-foreground">{description}</p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <Input
            type="email"
            placeholder={placeholder}
            value={email}
            onChange={(e) => {
              const val = e.target.value;
              setEmail(val);
              if (val.trim() && !isValidEmailFormat(val) && val.includes("@") === false && val.length > 3) {
                setError("Please enter a valid email address");
              } else {
                setError(null);
              }
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
          disabled={isLoading || !email.trim() || (email.trim().length > 0 && !isValidEmailFormat(email))}
          className="h-12 w-full"
        >
          {isLoading ? (
            <>
              <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              Sending...
            </>
          ) : (
            buttonText
          )}
        </Button>
      </form>

      <p className="mt-4 text-center text-xs text-muted-foreground">
        We&apos;ll send you a secure link that expires in 10 minutes.
      </p>
    </motion.div>
  );
}
