"use client";

import { useState, useEffect, useRef } from "react";
import { motion } from "framer-motion";
import { Loader2, Mail, CheckCircle2, ArrowLeft, KeyRound } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { toast } from "sonner";
import { sendMagicLink, verifyOTP, devLogin, isDevBypassEmail } from "@/lib/api/auth";

/**
 * Props for MagicLinkForm component
 */
interface MagicLinkFormProps {
  onBack?: () => void;
  title?: string;
  description?: string;
  placeholder?: string;
  buttonText?: string;
  redirectTo?: string;
  validateEmail?: (email: string) => { isValid: boolean; error?: string };
  className?: string;
}

/**
 * MagicLinkForm - Passwordless authentication via OTP
 *
 * Sends a magic-link / OTP email through the API server, then
 * lets the user enter the OTP code to authenticate.
 */
export function MagicLinkForm({
  onBack,
  title = "Sign in with email",
  description = "We'll send you a one-time code to sign in instantly. No password needed.",
  placeholder = "Enter your email address",
  buttonText = "Send Code",
  redirectTo,
  validateEmail,
  className = "",
}: MagicLinkFormProps) {
  const [email, setEmail] = useState("");
  const [otp, setOtp] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [isSent, setIsSent] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [cooldownSeconds, setCooldownSeconds] = useState(0);
  const cooldownRef = useRef<NodeJS.Timeout | null>(null);

  useEffect(() => {
    return () => {
      if (cooldownRef.current) clearInterval(cooldownRef.current);
    };
  }, []);

  const isValidEmailFormat = (email: string): boolean => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  };

  const startCooldown = () => {
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
  };

  /**
   * Send the magic link / OTP email
   */
  const handleSendCode = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    if (!email.trim()) {
      setError("Please enter your email address");
      return;
    }
    if (!isValidEmailFormat(email)) {
      setError("Please enter a valid email address");
      return;
    }
    if (validateEmail) {
      const validation = validateEmail(email);
      if (!validation.isValid) {
        setError(validation.error || "Invalid email address");
        return;
      }
    }

    setIsLoading(true);
    try {
      const normalizedEmail = email.trim().toLowerCase();

      // Dev bypass: direct login without OTP
      if (isDevBypassEmail(normalizedEmail)) {
        const result = await devLogin(normalizedEmail);
        if (!result.success) {
          throw new Error(result.error || "Login failed");
        }
        document.cookie = "loggedIn=true; path=/; max-age=604800; samesite=lax";
        toast.success("Signed in successfully!");
        window.location.href = redirectTo || "/home";
        return;
      }

      const result = await sendMagicLink(normalizedEmail);
      if (!result.success) {
        throw new Error(result.error || "Failed to send code");
      }
      setIsSent(true);
      startCooldown();
      toast.success("Code sent!", {
        description: "Check your email for the sign-in code.",
      });
    } catch (err) {
      const message = err instanceof Error ? err.message : "Something went wrong";
      setError(message);
      toast.error("Failed to send code", { description: message });
    } finally {
      setIsLoading(false);
    }
  };

  /**
   * Verify the OTP code
   */
  const handleVerifyOTP = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    if (!otp.trim() || otp.trim().length < 4) {
      setError("Please enter the code from your email");
      return;
    }

    setIsLoading(true);
    try {
      const result = await verifyOTP(email.trim().toLowerCase(), otp.trim());
      if (!result.success) {
        throw new Error(result.error || "Verification failed");
      }

      // Set the loggedIn cookie for middleware
      document.cookie = "loggedIn=true; path=/; max-age=604800; samesite=lax";

      toast.success("Signed in successfully!");
      window.location.href = redirectTo || "/home";
    } catch (err) {
      const message = err instanceof Error ? err.message : "Verification failed";
      setError(message);
      toast.error("Verification failed", { description: message });
    } finally {
      setIsLoading(false);
    }
  };

  const handleTryAgain = () => {
    setIsSent(false);
    setOtp("");
    setEmail("");
    setError(null);
  };

  // OTP Entry state
  if (isSent) {
    return (
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className={`text-center ${className}`}
      >
        <div className="mx-auto mb-6 flex h-16 w-16 items-center justify-center rounded-full bg-primary/10">
          <KeyRound className="h-8 w-8 text-primary" />
        </div>
        <h2 className="mb-2 text-2xl font-semibold text-foreground">
          Enter verification code
        </h2>
        <p className="mb-6 text-muted-foreground">
          We sent a code to{" "}
          <span className="font-medium text-foreground">{email}</span>
        </p>

        <form onSubmit={handleVerifyOTP} className="space-y-4">
          <Input
            type="text"
            inputMode="numeric"
            placeholder="Enter 6-digit code"
            value={otp}
            onChange={(e) => {
              setOtp(e.target.value.replace(/\D/g, "").slice(0, 6));
              setError(null);
            }}
            disabled={isLoading}
            className="h-12 text-center text-lg tracking-[0.3em]"
            autoFocus
          />
          {error && (
            <motion.p
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              className="text-sm text-destructive"
            >
              {error}
            </motion.p>
          )}
          <Button
            type="submit"
            disabled={isLoading || otp.length < 4}
            className="h-12 w-full"
          >
            {isLoading ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Verifying...
              </>
            ) : (
              "Verify & Sign In"
            )}
          </Button>
        </form>

        <div className="mt-4 space-y-3">
          <Button
            variant="outline"
            onClick={handleSendCode as any}
            disabled={cooldownSeconds > 0}
            className="w-full"
          >
            {cooldownSeconds > 0
              ? `Resend in ${cooldownSeconds}s`
              : "Resend code"}
          </Button>
          <Button
            variant="ghost"
            onClick={handleTryAgain}
            className="w-full"
          >
            <ArrowLeft className="mr-2 h-4 w-4" />
            Use a different email
          </Button>
        </div>
      </motion.div>
    );
  }

  // Email entry state
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

      <form onSubmit={handleSendCode} className="space-y-4">
        <div>
          <Input
            type="email"
            placeholder={placeholder}
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
          disabled={isLoading || !email.trim() || !isValidEmailFormat(email)}
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
        We&apos;ll send you a secure code that expires in 10 minutes.
      </p>
    </motion.div>
  );
}
