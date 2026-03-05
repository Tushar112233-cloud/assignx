"use client";

import { useEffect, useState, useRef, useCallback, Suspense } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import Link from "next/link";
import {
  checkAccount,
  sendOTP,
  verifyOTP,
  devLogin,
  isDevBypassEmail,
  isLoggedIn,
} from "@/lib/api/auth";
import { motion, useReducedMotion, AnimatePresence } from "framer-motion";
import { Mail, ArrowLeft, Loader2 } from "lucide-react";
import { toast } from "sonner";

import { AuthLayout } from "@/components/auth/auth-layout";
import { Button } from "@/components/ui/button";

import "./login.css";

const RESEND_COOLDOWN = 60;

function isLoginRequired(): boolean {
  return process.env.NEXT_PUBLIC_REQUIRE_LOGIN !== "false";
}

/**
 * OTP input component - 6 digit boxes with auto-advance, backspace nav, and paste support.
 */
function OTPInput({
  value,
  onChange,
  disabled,
}: {
  value: string;
  onChange: (otp: string) => void;
  disabled?: boolean;
}) {
  const inputRefs = useRef<(HTMLInputElement | null)[]>([]);

  const handleChange = useCallback(
    (index: number, digit: string) => {
      if (!/^\d?$/.test(digit)) return;

      const chars = value.split("");
      while (chars.length < 6) chars.push("");
      chars[index] = digit;
      const newOtp = chars.join("").slice(0, 6);
      onChange(newOtp);

      if (digit && index < 5) {
        inputRefs.current[index + 1]?.focus();
      }
    },
    [value, onChange]
  );

  const handleKeyDown = useCallback(
    (index: number, e: React.KeyboardEvent<HTMLInputElement>) => {
      if (e.key === "Backspace" && !value[index] && index > 0) {
        inputRefs.current[index - 1]?.focus();
      }
      if (e.key === "ArrowLeft" && index > 0) {
        e.preventDefault();
        inputRefs.current[index - 1]?.focus();
      }
      if (e.key === "ArrowRight" && index < 5) {
        e.preventDefault();
        inputRefs.current[index + 1]?.focus();
      }
    },
    [value]
  );

  const handlePaste = useCallback(
    (e: React.ClipboardEvent) => {
      e.preventDefault();
      const pasted = e.clipboardData
        .getData("text")
        .replace(/\D/g, "")
        .slice(0, 6);
      if (pasted) {
        onChange(pasted);
        const focusIndex = Math.min(pasted.length, 5);
        inputRefs.current[focusIndex]?.focus();
      }
    },
    [onChange]
  );

  return (
    <div className="flex items-center justify-center gap-2.5">
      {Array.from({ length: 6 }).map((_, i) => (
        <input
          key={i}
          ref={(el) => {
            inputRefs.current[i] = el;
          }}
          type="text"
          inputMode="numeric"
          autoComplete={i === 0 ? "one-time-code" : "off"}
          maxLength={1}
          disabled={disabled}
          value={value[i] || ""}
          onChange={(e) => handleChange(i, e.target.value)}
          onKeyDown={(e) => handleKeyDown(i, e)}
          onPaste={handlePaste}
          className="h-12 w-10 rounded-lg border border-border bg-background text-center text-lg font-semibold text-foreground transition-all
            focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/20
            disabled:cursor-not-allowed disabled:opacity-50
            sm:h-14 sm:w-12"
        />
      ))}
    </div>
  );
}

type Step = "email" | "otp";

function LoginContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const prefersReducedMotion = useReducedMotion();

  const [step, setStep] = useState<Step>("email");
  const [email, setEmail] = useState("");
  const [otp, setOtp] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [cooldown, setCooldown] = useState(0);

  // Handle query-param errors (e.g. redirected from middleware)
  useEffect(() => {
    const qError = searchParams.get("error");
    const message = searchParams.get("message");

    if (qError === "auth_failed") {
      toast.error("Authentication failed", {
        description: "Please try again or use a different method.",
      });
    } else if (qError) {
      toast.error("Error", {
        description: message || "An error occurred during sign in.",
      });
    }
  }, [searchParams]);

  // Redirect if already logged in or login not required
  useEffect(() => {
    const qError = searchParams.get("error");
    if (qError === "unauthorized") return;

    if (!isLoginRequired()) {
      router.replace("/home");
      return;
    }

    if (isLoggedIn()) {
      router.replace("/home");
    }
  }, [router, searchParams]);

  // Resend cooldown timer
  useEffect(() => {
    if (cooldown <= 0) return;
    const timer = setInterval(() => {
      setCooldown((prev) => (prev <= 1 ? 0 : prev - 1));
    }, 1000);
    return () => clearInterval(timer);
  }, [cooldown]);

  /**
   * Handles the email submission step:
   * 1. Dev bypass check
   * 2. Check if account exists
   * 3. Send OTP
   */
  const handleEmailSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const trimmed = email.trim();
    if (!trimmed) return;

    setError("");
    setLoading(true);

    try {
      // Dev bypass path
      if (isDevBypassEmail(trimmed)) {
        const result = await devLogin(trimmed);
        if (result.success) {
          router.push("/home");
          return;
        }
        setError(result.error || "Dev login failed");
        return;
      }

      // Check account existence
      const account = await checkAccount(trimmed);
      if (account.error) {
        setError(account.error);
        return;
      }
      if (!account.exists) {
        setError("NO_ACCOUNT");
        return;
      }

      // Send OTP
      const otpResult = await sendOTP(trimmed, "login");
      if (!otpResult.success) {
        setError(otpResult.error || "Failed to send verification code");
        return;
      }

      setStep("otp");
      setCooldown(RESEND_COOLDOWN);
      toast.success("Code sent", {
        description: `We sent a verification code to ${trimmed}`,
      });
    } catch {
      setError("Something went wrong. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  /**
   * Handles OTP verification submission.
   */
  const handleOTPSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (otp.length !== 6) return;

    setError("");
    setLoading(true);

    try {
      const result = await verifyOTP(email.trim(), otp, "login");
      if (!result.success) {
        setError(result.error || "Verification failed");
        return;
      }
      router.push("/home");
    } catch {
      setError("Something went wrong. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  /**
   * Resends the OTP if cooldown has expired.
   */
  const handleResend = async () => {
    if (cooldown > 0) return;

    setError("");
    setLoading(true);

    try {
      const result = await sendOTP(email.trim(), "login");
      if (!result.success) {
        setError(result.error || "Failed to resend code");
        return;
      }
      setCooldown(RESEND_COOLDOWN);
      setOtp("");
      toast.success("Code resent", {
        description: "A new verification code has been sent.",
      });
    } catch {
      setError("Failed to resend code.");
    } finally {
      setLoading(false);
    }
  };

  const goBackToEmail = () => {
    setStep("email");
    setOtp("");
    setError("");
  };

  return (
    <AuthLayout>
      <AnimatePresence mode="wait">
        {step === "email" ? (
          <motion.div
            key="email-step"
            initial={prefersReducedMotion ? {} : { opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={prefersReducedMotion ? {} : { opacity: 0, y: -20 }}
            transition={{ duration: 0.4 }}
          >
            <motion.h1
              initial={prefersReducedMotion ? {} : { opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.1, duration: 0.5 }}
              className="text-center text-[32px] font-semibold leading-tight tracking-[-0.02em] text-foreground md:text-[36px]"
            >
              Welcome back
            </motion.h1>

            <motion.p
              initial={prefersReducedMotion ? {} : { opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.2, duration: 0.5 }}
              className="mt-2 text-center text-sm text-muted-foreground"
            >
              Sign in to continue to your dashboard
            </motion.p>

            <motion.form
              onSubmit={handleEmailSubmit}
              initial={prefersReducedMotion ? {} : { opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.3, duration: 0.5 }}
              className="mt-8 space-y-4"
            >
              <div className="relative">
                <Mail className="absolute left-4 top-1/2 h-4.5 w-4.5 -translate-y-1/2 text-muted-foreground" />
                <input
                  type="email"
                  placeholder="Enter your email"
                  value={email}
                  onChange={(e) => {
                    setEmail(e.target.value);
                    setError("");
                  }}
                  required
                  autoFocus
                  disabled={loading}
                  className="h-14 w-full rounded-xl border border-border bg-background pl-11 pr-4 text-sm text-foreground placeholder:text-muted-foreground
                    transition-colors focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/20
                    disabled:cursor-not-allowed disabled:opacity-50"
                />
              </div>

              {error && error !== "NO_ACCOUNT" && (
                <p className="text-center text-sm text-destructive">{error}</p>
              )}

              {error === "NO_ACCOUNT" && (
                <p className="text-center text-sm text-destructive">
                  No account found for this email.{" "}
                  <Link
                    href="/signup"
                    className="font-medium underline underline-offset-2 hover:text-destructive/80"
                  >
                    Sign up instead
                  </Link>
                </p>
              )}

              <Button
                type="submit"
                disabled={loading || !email.trim()}
                className="h-14 w-full rounded-xl text-sm font-medium"
              >
                {loading ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Checking...
                  </>
                ) : (
                  "Continue"
                )}
              </Button>
            </motion.form>

            <motion.p
              initial={prefersReducedMotion ? {} : { opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.4, duration: 0.5 }}
              className="mt-6 text-center text-[13px] text-muted-foreground"
            >
              No password needed. We&apos;ll send you a secure sign-in code.
            </motion.p>

            <motion.div
              initial={prefersReducedMotion ? {} : { opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.55, duration: 0.5 }}
              className="mt-5 flex items-center justify-center gap-1.5"
            >
              <span className="text-[13px] text-muted-foreground">
                Don&apos;t have an account?
              </span>
              <Link
                href="/signup"
                className="text-[13px] font-medium text-foreground transition-colors hover:text-primary"
              >
                Sign up
              </Link>
            </motion.div>

            <motion.p
              initial={prefersReducedMotion ? {} : { opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.65, duration: 0.5 }}
              className="mt-6 text-center text-[11px] text-muted-foreground"
            >
              By continuing, you agree to our{" "}
              <Link
                href="/terms"
                className="underline underline-offset-2 hover:text-foreground"
              >
                Terms of Service
              </Link>{" "}
              and{" "}
              <Link
                href="/privacy"
                className="underline underline-offset-2 hover:text-foreground"
              >
                Privacy Policy
              </Link>
              .
            </motion.p>
          </motion.div>
        ) : (
          <motion.div
            key="otp-step"
            initial={prefersReducedMotion ? {} : { opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={prefersReducedMotion ? {} : { opacity: 0, y: -20 }}
            transition={{ duration: 0.4 }}
          >
            <button
              type="button"
              onClick={goBackToEmail}
              className="mb-6 flex items-center gap-1.5 text-sm text-muted-foreground transition-colors hover:text-foreground"
            >
              <ArrowLeft className="h-4 w-4" />
              Back
            </button>

            <h1 className="text-center text-[32px] font-semibold leading-tight tracking-[-0.02em] text-foreground md:text-[36px]">
              Check your email
            </h1>

            <p className="mt-2 text-center text-sm text-muted-foreground">
              We sent a 6-digit code to{" "}
              <span className="font-medium text-foreground">
                {email.trim()}
              </span>
            </p>

            <form onSubmit={handleOTPSubmit} className="mt-8 space-y-6">
              <OTPInput
                value={otp}
                onChange={setOtp}
                disabled={loading}
              />

              {error && (
                <p className="text-center text-sm text-destructive">{error}</p>
              )}

              <Button
                type="submit"
                disabled={loading || otp.length !== 6}
                className="h-14 w-full rounded-xl text-sm font-medium"
              >
                {loading ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Verifying...
                  </>
                ) : (
                  "Verify"
                )}
              </Button>
            </form>

            <div className="mt-6 text-center">
              {cooldown > 0 ? (
                <p className="text-[13px] text-muted-foreground">
                  Resend code in{" "}
                  <span className="font-medium text-foreground tabular-nums">
                    {cooldown}s
                  </span>
                </p>
              ) : (
                <button
                  type="button"
                  onClick={handleResend}
                  disabled={loading}
                  className="text-[13px] font-medium text-foreground transition-colors hover:text-primary disabled:cursor-not-allowed disabled:opacity-50"
                >
                  Resend code
                </button>
              )}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </AuthLayout>
  );
}

export default function LoginPage() {
  return (
    <Suspense
      fallback={
        <AuthLayout>
          <div className="animate-pulse">
            <div className="mx-auto mb-2 h-10 w-48 rounded bg-muted" />
            <div className="mx-auto mb-8 h-4 w-64 rounded bg-muted" />
            <div className="h-14 w-full rounded-xl bg-muted" />
          </div>
        </AuthLayout>
      }
    >
      <LoginContent />
    </Suspense>
  );
}
