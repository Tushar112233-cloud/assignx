/**
 * @fileoverview Premium Login Page
 *
 * Split-screen login with animated visual panel,
 * floating cards, and smooth animations. Supports
 * both Google OAuth and Magic Link authentication.
 *
 * @route /login
 * @access public
 */

"use client";

import { useEffect, useState, Suspense } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import { motion, useReducedMotion } from "framer-motion";
import { Loader2, Mail } from "lucide-react";
import { toast } from "sonner";

import { AuthLayout, GoogleIcon } from "@/components/auth/auth-layout";
import { MagicLinkForm } from "@/components/auth/magic-link-form";
import { Button } from "@/components/ui/button";

import "./login.css";

/**
 * Check if login is required based on environment variable
 * In dev mode (REQUIRE_LOGIN=false), we bypass authentication
 */
function isLoginRequired(): boolean {
  return process.env.NEXT_PUBLIC_REQUIRE_LOGIN !== "false";
}

/**
 * Main login content component
 */
function LoginContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const prefersReducedMotion = useReducedMotion();
  const [loading, setLoading] = useState(false);
  const [showMagicLink, setShowMagicLink] = useState(false);
  const supabase = createClient();

  // Check for error messages from callback
  useEffect(() => {
    const error = searchParams.get("error");
    const message = searchParams.get("message");

    if (error === "auth_failed") {
      toast.error("Authentication failed", {
        description: "Please try again or use a different method.",
      });
    } else if (error === "invalid_student_email") {
      toast.error("Invalid student email", {
        description: message || "Please use a valid college/university email.",
      });
    } else if (error) {
      toast.error("Error", {
        description: message || "An error occurred during sign in.",
      });
    }
  }, [searchParams]);

  // Redirect if login is not required (dev mode) or already logged in
  useEffect(() => {
    const checkUser = async () => {
      // Don't auto-redirect if the middleware sent us here with an error
      // (e.g., user_type not allowed on this platform)
      const error = searchParams.get("error");
      if (error === "unauthorized") return;

      // In dev mode, redirect directly to home without auth check
      if (!isLoginRequired()) {
        router.replace("/home");
        return;
      }

      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (user) {
        router.replace("/home");
      }
    };
    checkUser();
  }, [router, supabase.auth, searchParams]);

  /**
   * Handles Google OAuth sign in
   */
  const handleGoogle = async () => {
    setLoading(true);
    const callbackUrl = `${window.location.origin}/auth/callback`;

    const { error } = await supabase.auth.signInWithOAuth({
      provider: "google",
      options: {
        redirectTo: callbackUrl,
      },
    });

    if (error) {
      toast.error("Sign in failed", {
        description: error.message,
      });
      setLoading(false);
    }
  };

  // Show magic link form
  if (showMagicLink) {
    return (
      <AuthLayout>
        <MagicLinkForm
          onBack={() => setShowMagicLink(false)}
          title="Sign in with email"
          description="We'll send you a magic link to sign in instantly. No password needed."
        />

        {/* Terms */}
        <motion.p
          initial={prefersReducedMotion ? {} : { opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.3, duration: 0.5 }}
          className="mt-6 text-center text-[11px] text-muted-foreground"
        >
          By continuing, you agree to our{" "}
          <Link href="/terms" className="underline underline-offset-2 hover:text-foreground">
            Terms of Service
          </Link>{" "}
          and{" "}
          <Link href="/privacy" className="underline underline-offset-2 hover:text-foreground">
            Privacy Policy
          </Link>
          .
        </motion.p>
      </AuthLayout>
    );
  }

  // Main login view
  return (
    <AuthLayout>
      {/* Heading */}
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

      {/* Magic Link Button */}
      <motion.div
        initial={prefersReducedMotion ? {} : { opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.3, duration: 0.5 }}
      >
        <Button
          onClick={() => setShowMagicLink(true)}
          variant="outline"
          className="mt-8 h-14 w-full gap-2.5 rounded-xl text-sm font-medium"
        >
          <Mail className="h-5 w-5" />
          Continue with Email
        </Button>
      </motion.div>

      {/* Info */}
      <motion.p
        initial={prefersReducedMotion ? {} : { opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.4, duration: 0.5 }}
        className="mt-6 text-center text-[13px] text-muted-foreground"
      >
        No password needed. We&apos;ll send you a secure sign-in link.
      </motion.p>

      {/* Sign up link */}
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

      {/* College verification link */}
      <motion.div
        initial={prefersReducedMotion ? {} : { opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.6, duration: 0.5 }}
        className="mt-3 flex items-center justify-center"
      >
        <Link
          href="/verify-college"
          className="text-[13px] text-muted-foreground transition-colors hover:text-primary"
        >
          Verify college email for Campus Connect
        </Link>
      </motion.div>

      {/* Terms */}
      <motion.p
        initial={prefersReducedMotion ? {} : { opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.65, duration: 0.5 }}
        className="mt-6 text-center text-[11px] text-muted-foreground"
      >
        By continuing, you agree to our{" "}
        <Link href="/terms" className="underline underline-offset-2 hover:text-foreground">
          Terms of Service
        </Link>{" "}
        and{" "}
        <Link href="/privacy" className="underline underline-offset-2 hover:text-foreground">
          Privacy Policy
        </Link>
        .
      </motion.p>
    </AuthLayout>
  );
}

/**
 * Login Page with Suspense boundary
 */
export default function LoginPage() {
  return (
    <Suspense
      fallback={
        <AuthLayout>
          <div className="animate-pulse">
            <div className="mx-auto mb-2 h-10 w-48 rounded bg-muted" />
            <div className="mx-auto mb-8 h-4 w-64 rounded bg-muted" />
            <div className="h-14 w-full rounded-xl bg-muted" />
            <div className="my-6 h-px w-full bg-muted" />
            <div className="h-14 w-full rounded-xl bg-muted" />
          </div>
        </AuthLayout>
      }
    >
      <LoginContent />
    </Suspense>
  );
}
