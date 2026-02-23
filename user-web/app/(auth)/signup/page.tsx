"use client";

import { useState, useEffect, Suspense } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import { motion, AnimatePresence, useReducedMotion } from "framer-motion";
import {
  Sparkles,
  GraduationCap,
  Briefcase,
  Building2,
  ArrowRight,
  ArrowLeft,
  Loader2,
  AlertCircle,
  Shield,
  Users,
  Star,
  TrendingUp,
  Award,
  X,
  Mail,
  CheckCircle2,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { createClient } from "@/lib/supabase/client";
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
 * Validates if email is from a college domain
 */
function isCollegeEmail(email: string): boolean {
  const domain = email.toLowerCase().split("@")[1];
  if (!domain) return false;
  return COLLEGE_EMAIL_PATTERNS.some(pattern => pattern.test(domain));
}

import "../onboarding/onboarding.css";

// Animation configuration
const EASE = [0.16, 1, 0.3, 1] as const;

type RoleType = "student" | "professional" | "business" | null;

interface Role {
  id: RoleType;
  icon: React.ElementType;
  title: string;
  description: string;
  color: string;
  emailHint?: string;
}

// Role definitions
const roles: Role[] = [
  {
    id: "student",
    icon: GraduationCap,
    title: "Student",
    description:
      "Get expert help with your academic projects. From essays to dissertations, we have you covered.",
    color: "primary",
    emailHint: "Use your college/university email (e.g., name@college.edu)",
  },
  {
    id: "professional",
    icon: Briefcase,
    title: "Professional",
    description:
      "Professional assistance for career growth. Resumes, portfolios, and interview prep.",
    color: "accent",
  },
  {
    id: "business",
    icon: Building2,
    title: "Other",
    description:
      "General users, businesses, and anyone else looking for expert assistance.",
    color: "secondary",
  },
];

// Visual config for role selection
const ROLE_VISUAL_CONFIG = {
  visualHeading: "Join AssignX Today",
  visualSubheading: "Create your account and get access to expert academic assistance tailored just for you.",
  cards: [
    {
      icon: Users,
      iconBg: "bg-primary",
      title: "Students",
      value: "10K+",
      label: "Active users",
      position: "position-1",
      delay: 0.3,
    },
    {
      icon: Star,
      iconBg: "bg-accent",
      title: "Rating",
      value: "4.9",
      label: "User satisfaction",
      position: "position-2",
      delay: 0.5,
    },
    {
      icon: TrendingUp,
      iconBg: "bg-success",
      title: "Success",
      value: "95%",
      label: "Grade improvement",
      position: "position-3",
      delay: 0.7,
    },
  ],
};

// Sign-in visual config
const SIGNIN_VISUAL_CONFIG = {
  visualHeading: "Almost There!",
  visualSubheading: "Enter your email to receive a secure magic link and start your journey.",
  cards: [
    {
      icon: Shield,
      iconBg: "bg-success",
      title: "Secure",
      value: "Magic",
      label: "Link",
      position: "position-1",
      delay: 0.3,
    },
    {
      icon: Award,
      iconBg: "bg-primary",
      title: "Quick",
      value: "1-Click",
      label: "Sign up",
      position: "position-2",
      delay: 0.5,
    },
    {
      icon: Star,
      iconBg: "bg-accent",
      title: "No",
      value: "Password",
      label: "Needed",
      position: "position-3",
      delay: 0.7,
    },
  ],
};

/**
 * Floating card component for the visual panel
 */
function FloatingCard({
  icon: Icon,
  iconBg,
  title,
  value,
  label,
  className,
  delay,
}: {
  icon: React.ElementType;
  iconBg: string;
  title: string;
  value: string;
  label: string;
  className: string;
  delay: number;
}) {
  const prefersReducedMotion = useReducedMotion();

  return (
    <motion.div
      initial={prefersReducedMotion ? {} : { opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay, duration: 0.6, ease: EASE }}
      className={`onboarding-float-card ${className}`}
    >
      <div className={`onboarding-float-card-icon ${iconBg}`}>
        <Icon className="w-5 h-5 text-white" />
      </div>
      <div className="onboarding-float-card-title">{title}</div>
      <div className="onboarding-float-card-value">{value}</div>
      <div className="onboarding-float-card-label">{label}</div>
    </motion.div>
  );
}

/**
 * Step indicator dots
 */
function StepIndicator({
  currentStep,
  totalSteps,
}: {
  currentStep: number;
  totalSteps: number;
}) {
  return (
    <div className="onboarding-steps-indicator">
      {Array.from({ length: totalSteps }, (_, i) => (
        <div
          key={i}
          className={`onboarding-step-dot ${
            currentStep === i ? "active" : ""
          } ${i < currentStep ? "completed" : ""}`}
        />
      ))}
    </div>
  );
}

/**
 * Progress bar component
 */
function ProgressBar({
  currentStep,
  totalSteps,
}: {
  currentStep: number;
  totalSteps: number;
}) {
  const progress = ((currentStep + 1) / totalSteps) * 100;

  return (
    <div className="onboarding-progress">
      <div className="onboarding-progress-bar">
        <motion.div
          className="onboarding-progress-fill"
          initial={{ width: 0 }}
          animate={{ width: `${progress}%` }}
          transition={{ duration: 0.5, ease: EASE }}
        />
      </div>
      <div className="onboarding-progress-label">
        <span>Step {currentStep + 1} of {totalSteps}</span>
        <span>{Math.round(progress)}% complete</span>
      </div>
    </div>
  );
}

/**
 * Google logo SVG component
 */
function GoogleIcon({ className }: { className?: string }) {
  return (
    <svg
      className={className}
      viewBox="0 0 24 24"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path
        d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
        fill="#4285F4"
      />
      <path
        d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
        fill="#34A853"
      />
      <path
        d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
        fill="#FBBC05"
      />
      <path
        d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
        fill="#EA4335"
      />
    </svg>
  );
}

/**
 * Signup page content with premium split-screen design
 */
function SignupContent() {
  const searchParams = useSearchParams();
  const router = useRouter();
  const prefersReducedMotion = useReducedMotion();

  const [currentStep, setCurrentStep] = useState(0); // 0: role, 1: signin
  const [selectedRole, setSelectedRole] = useState<RoleType>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [showEmailError, setShowEmailError] = useState(false);
  const [emailErrorMessage, setEmailErrorMessage] = useState("");
  // Magic link states
  const [showMagicLink, setShowMagicLink] = useState(false);
  const [magicLinkEmail, setMagicLinkEmail] = useState("");
  const [magicLinkSent, setMagicLinkSent] = useState(false);
  const [magicLinkError, setMagicLinkError] = useState<string | null>(null);
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  const supabase = createClient();

  // Check if user is already authenticated (e.g., redirected from login)
  useEffect(() => {
    const checkAuth = async () => {
      const { data: { user } } = await supabase.auth.getUser();
      setIsAuthenticated(!!user);
    };
    checkAuth();
  }, [supabase.auth]);

  // Handle error from URL (invalid student email or no account)
  useEffect(() => {
    const urlError = searchParams.get("error");
    const message = searchParams.get("message");

    if (urlError === "no_account" && message) {
      toast.info(decodeURIComponent(message));
    } else if (urlError === "invalid_student_email" && message) {
      setEmailErrorMessage(decodeURIComponent(message));
      setShowEmailError(true);
    }
  }, [searchParams]);

  const handleRoleSelect = async (roleId: RoleType) => {
    setSelectedRole(roleId);
    setError(null);

    if (isAuthenticated) {
      // User is already authenticated (came from login redirect)
      // Set cookies and redirect directly to registration form
      document.cookie = `signup_role=${roleId}; path=/; max-age=600; SameSite=Lax`;
      document.cookie = `signup_intent=true; path=/; max-age=600; SameSite=Lax`;

      // Update their profile with the selected role
      const { data: { user } } = await supabase.auth.getUser();
      if (user) {
        await supabase.from("profiles").upsert({
          id: user.id,
          email: user.email,
          user_type: roleId === "business" ? "professional" : roleId,
          updated_at: new Date().toISOString(),
        });
      }

      if (roleId === "student") {
        router.push("/signup/student");
      } else {
        const typeParam = roleId === "business" ? "?type=business" : "";
        router.push(`/signup/professional${typeParam}`);
      }
      return;
    }

    setCurrentStep(1);
  };

  const handleBack = () => {
    if (showMagicLink) {
      // Go back from magic link to auth options
      setShowMagicLink(false);
      setMagicLinkEmail("");
      setMagicLinkError(null);
      setMagicLinkSent(false);
    } else {
      // Go back from auth options to role selection
      setSelectedRole(null);
      setCurrentStep(0);
      setError(null);
    }
  };

  /**
   * Validates email format
   */
  const isValidEmailFormat = (email: string): boolean => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  };

  /**
   * Handle magic link sign in
   */
  const handleMagicLinkSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setMagicLinkError(null);

    const email = magicLinkEmail.trim().toLowerCase();

    // Basic validation
    if (!email) {
      setMagicLinkError("Please enter your email address");
      return;
    }

    if (!isValidEmailFormat(email)) {
      setMagicLinkError("Please enter a valid email address");
      return;
    }

    // For students, validate educational email
    if (selectedRole === "student" && !isCollegeEmail(email)) {
      setMagicLinkError(
        "Student accounts require a valid educational email (.edu, .ac.in, .ac.uk, etc.)"
      );
      return;
    }

    setIsLoading(true);

    try {
      // Store role in cookie (same as OAuth flow)
      document.cookie = `signup_role=${selectedRole}; path=/; max-age=600; SameSite=Lax`;
      document.cookie = `signup_intent=true; path=/; max-age=600; SameSite=Lax`;

      const response = await fetch("/api/auth/magic-link", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          email,
          role: selectedRole,
          redirectTo: "/home",
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || "Failed to send magic link");
      }

      setMagicLinkSent(true);
      toast.success("Magic link sent!", {
        description: "Check your email inbox for the sign-in link.",
      });
    } catch (err) {
      const message = err instanceof Error ? err.message : "Something went wrong";
      setMagicLinkError(message);
      toast.error("Failed to send magic link", {
        description: message,
      });
    } finally {
      setIsLoading(false);
    }
  };

  /**
   * Reset magic link form to try different email
   */
  const handleTryDifferentEmail = () => {
    setMagicLinkSent(false);
    setMagicLinkEmail("");
    setMagicLinkError(null);
  };

  const handleGoogleSignIn = async () => {
    if (!selectedRole) return;

    setIsLoading(true);
    setError(null);

    try {
      // Store the selected role in a cookie (survives OAuth redirect)
      document.cookie = `signup_role=${selectedRole}; path=/; max-age=600; SameSite=Lax`;
      document.cookie = `signup_intent=true; path=/; max-age=600; SameSite=Lax`;

      const callbackUrl = `${window.location.origin}/auth/callback`;

      const { error: authError } = await supabase.auth.signInWithOAuth({
        provider: "google",
        options: {
          redirectTo: callbackUrl,
          queryParams: {
            ...(selectedRole === "student" && {
              hd: "*",
            }),
          },
        },
      });

      if (authError) {
        setError(authError.message);
        setIsLoading(false);
      }
    } catch {
      setError("Something went wrong. Please try again.");
      setIsLoading(false);
    }
  };

  // Get current visual config based on step
  const visualConfig = currentStep === 0 ? ROLE_VISUAL_CONFIG : SIGNIN_VISUAL_CONFIG;
  const totalSteps = 2;
  const selectedRoleData = roles.find((r) => r.id === selectedRole);

  return (
    <div className="onboarding-page">
      {/* Error Alert for invalid student email */}
      {showEmailError && (
        <div className="fixed inset-x-0 top-0 z-50 p-4">
          <Alert
            variant="destructive"
            className="mx-auto max-w-lg shadow-lg"
          >
            <AlertCircle className="h-4 w-4" />
            <AlertTitle>Invalid Student Email</AlertTitle>
            <AlertDescription className="pr-8">
              {emailErrorMessage}
            </AlertDescription>
            <Button
              variant="ghost"
              size="icon"
              className="absolute right-2 top-2 h-6 w-6"
              onClick={() => setShowEmailError(false)}
            >
              <X className="h-4 w-4" />
            </Button>
          </Alert>
        </div>
      )}

      {/* Left Panel - Visual Side */}
      <div className="onboarding-visual">
        {/* Floating cards */}
        <div className="onboarding-floating-cards">
          <AnimatePresence mode="wait">
            {visualConfig.cards.map((card, index) => (
              <FloatingCard
                key={`card-${currentStep}-${index}`}
                icon={card.icon}
                iconBg={card.iconBg}
                title={card.title}
                value={card.value}
                label={card.label}
                className={card.position}
                delay={card.delay}
              />
            ))}
          </AnimatePresence>
        </div>

        {/* Content */}
        <div className="onboarding-visual-content">
          <motion.div
            initial={prefersReducedMotion ? {} : { opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, ease: EASE }}
            className="onboarding-visual-logo"
          >
            <span>
              <Sparkles className="w-4 h-4" />
              AssignX
            </span>
          </motion.div>

          <AnimatePresence mode="wait">
            <motion.h1
              key={`heading-${currentStep}`}
              initial={prefersReducedMotion ? {} : { opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -30 }}
              transition={{ delay: 0.2, duration: 0.6, ease: EASE }}
              className="onboarding-visual-heading"
            >
              {visualConfig.visualHeading}
            </motion.h1>
          </AnimatePresence>

          <AnimatePresence mode="wait">
            <motion.p
              key={`subheading-${currentStep}`}
              initial={prefersReducedMotion ? {} : { opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              transition={{ delay: 0.4, duration: 0.6, ease: EASE }}
              className="onboarding-visual-subheading"
            >
              {visualConfig.visualSubheading}
            </motion.p>
          </AnimatePresence>
        </div>

        {/* Step indicators */}
        <motion.div
          initial={prefersReducedMotion ? {} : { opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.6, duration: 0.6 }}
        >
          <StepIndicator currentStep={currentStep} totalSteps={totalSteps} />
        </motion.div>
      </div>

      {/* Right Panel - Form */}
      <div className="onboarding-form-panel">
        <div className="onboarding-form-container">
          {/* Mobile logo */}
          <motion.div
            initial={prefersReducedMotion ? {} : { opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.4 }}
            className="onboarding-mobile-logo"
          >
            <span>
              <Sparkles className="w-4 h-4" />
              AssignX
            </span>
          </motion.div>

          {/* Progress bar */}
          <ProgressBar currentStep={currentStep} totalSteps={totalSteps} />

          {/* Content */}
          <AnimatePresence mode="wait">
            {/* Step 0: Role Selection */}
            {currentStep === 0 && (
              <motion.div
                key="role-selection"
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                className="onboarding-form-content"
              >
                <div className="onboarding-form-header">
                  <h2 className="onboarding-form-title">Choose Your Path</h2>
                  <p className="onboarding-form-subtitle">
                    Select the option that best describes you
                  </p>
                </div>

                <div className="onboarding-role-cards">
                  {roles.map((role) => (
                    <motion.div
                      key={role.id}
                      whileHover={{ scale: 1.01 }}
                      whileTap={{ scale: 0.99 }}
                    >
                      <div
                        onClick={() => handleRoleSelect(role.id)}
                        className="onboarding-role-card"
                      >
                        <div className="onboarding-role-card-content">
                          <div className="onboarding-role-card-icon bg-muted/50 text-muted-foreground border border-border">
                            <role.icon className="h-6 w-6" />
                          </div>
                          <div className="onboarding-role-card-text">
                            <div className="onboarding-role-card-title">{role.title}</div>
                            <div className="onboarding-role-card-description">
                              {role.description}
                            </div>
                          </div>
                          <ArrowRight className="h-5 w-5 onboarding-role-card-arrow" />
                        </div>
                      </div>
                    </motion.div>
                  ))}
                </div>

                <p className="text-center text-sm text-muted-foreground mt-8">
                  Already have an account?{" "}
                  <button
                    onClick={() => router.push("/login")}
                    className="text-primary font-medium hover:underline"
                  >
                    Sign in
                  </button>
                </p>
              </motion.div>
            )}

            {/* Step 1: Sign-in Options */}
            {currentStep === 1 && selectedRoleData && (
              <motion.div
                key="signin-options"
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                className="onboarding-form-content"
              >
                <button
                  onClick={handleBack}
                  className="onboarding-back-button"
                >
                  <ArrowLeft className="h-4 w-4" />
                  {showMagicLink ? "Back to sign-in options" : "Back to role selection"}
                </button>

                {/* Magic Link Success State */}
                {magicLinkSent ? (
                  <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="text-center"
                  >
                    <div className="mx-auto mb-6 flex h-16 w-16 items-center justify-center rounded-full bg-green-100 dark:bg-green-900/30">
                      <CheckCircle2 className="h-8 w-8 text-green-600 dark:text-green-400" />
                    </div>
                    <h2 className="mb-2 text-2xl font-semibold text-foreground">
                      Check your email
                    </h2>
                    <p className="mb-6 text-muted-foreground">
                      We sent a magic link to{" "}
                      <span className="font-medium text-foreground">{magicLinkEmail}</span>
                    </p>
                    <p className="mb-6 text-sm text-muted-foreground">
                      Click the link in your email to sign in. The link expires in 10 minutes.
                    </p>
                    <div className="space-y-3">
                      <Button
                        variant="outline"
                        onClick={handleTryDifferentEmail}
                        className="w-full"
                      >
                        Try a different email
                      </Button>
                    </div>
                  </motion.div>
                ) : showMagicLink ? (
                  /* Magic Link Form */
                  <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                  >
                    <div className="onboarding-form-header">
                      <div className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-primary/10">
                        <Mail className="h-6 w-6 text-primary" />
                      </div>
                      <h2 className="onboarding-form-title">Sign in with email</h2>
                      <p className="onboarding-form-subtitle">
                        We&apos;ll send you a magic link to sign in instantly
                      </p>
                    </div>

                    {/* Student email requirement notice */}
                    {selectedRole === "student" && (
                      <Alert className="mb-6 border-[#765341]/30 bg-[#765341]/10 dark:border-[#765341]/40 dark:bg-[#765341]/20">
                        <AlertCircle className="h-4 w-4 text-[#765341]" />
                        <AlertDescription className="text-[#5C4233] dark:text-[#A07A65]">
                          <strong>Educational email required</strong>
                          <br />
                          Use your college email (.edu, .ac.in, .ac.uk, etc.)
                        </AlertDescription>
                      </Alert>
                    )}

                    <form onSubmit={handleMagicLinkSubmit} className="space-y-4">
                      <div>
                        <Input
                          type="email"
                          placeholder={
                            selectedRole === "student"
                              ? "yourname@college.edu"
                              : "Enter your email address"
                          }
                          value={magicLinkEmail}
                          onChange={(e) => {
                            setMagicLinkEmail(e.target.value);
                            setMagicLinkError(null);
                          }}
                          disabled={isLoading}
                          aria-invalid={!!magicLinkError}
                          className="h-12"
                        />
                        {magicLinkError && (
                          <motion.p
                            initial={{ opacity: 0, y: -10 }}
                            animate={{ opacity: 1, y: 0 }}
                            className="mt-2 text-sm text-destructive"
                          >
                            {magicLinkError}
                          </motion.p>
                        )}
                      </div>

                      <Button
                        type="submit"
                        disabled={isLoading || !magicLinkEmail.trim()}
                        className="h-12 w-full"
                      >
                        {isLoading ? (
                          <>
                            <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                            Sending...
                          </>
                        ) : (
                          "Send Magic Link"
                        )}
                      </Button>
                    </form>

                    <p className="mt-4 text-center text-xs text-muted-foreground">
                      We&apos;ll send you a secure link that expires in 10 minutes.
                    </p>
                  </motion.div>
                ) : (
                  /* Auth Options (Magic Link only) */
                  <>
                    <div className="onboarding-form-header">
                      <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-2xl bg-[#765341]/10 text-[#765341] border border-[#765341]/30 dark:bg-[#765341]/20 dark:text-[#A07A65] dark:border-[#765341]/40">
                        <selectedRoleData.icon className="h-8 w-8" />
                      </div>
                      <h2 className="onboarding-form-title">
                        Sign up as {selectedRoleData.title}
                      </h2>
                      <p className="onboarding-form-subtitle">
                        We&apos;ll send you a magic link to sign up instantly
                      </p>
                    </div>

                    {/* Student email hint */}
                    {selectedRole === "student" && (
                      <Alert className="mb-6 border-[#765341]/30 bg-[#765341]/10 dark:border-[#765341]/40 dark:bg-[#765341]/20">
                        <AlertCircle className="h-4 w-4 text-[#765341]" />
                        <AlertDescription className="text-[#5C4233] dark:text-[#A07A65]">
                          <strong>Student accounts require a valid college email</strong>
                          <br />
                          Please use your institutional email (e.g.,
                          name@university.edu or name@college.ac.in)
                        </AlertDescription>
                      </Alert>
                    )}

                    {/* Error message */}
                    {error && (
                      <Alert variant="destructive" className="mb-6">
                        <AlertCircle className="h-4 w-4" />
                        <AlertDescription>{error}</AlertDescription>
                      </Alert>
                    )}

                    {/* Magic Link Button */}
                    <Button
                      onClick={() => setShowMagicLink(true)}
                      disabled={isLoading}
                      className="w-full h-14"
                    >
                      <Mail className="mr-2 h-5 w-5" />
                      Continue with Email
                    </Button>

                    {/* Security note */}
                    <div className="flex items-center justify-center gap-2 text-xs text-muted-foreground mt-6">
                      <Shield className="h-4 w-4" />
                      Secure passwordless authentication
                    </div>

                    {/* Info */}
                    <p className="text-center text-[13px] text-muted-foreground mt-4">
                      No password needed. We&apos;ll send you a secure sign-up link.
                    </p>

                    {/* Terms */}
                    <p className="text-center text-xs text-muted-foreground mt-4">
                      By continuing, you agree to our{" "}
                      <button
                        onClick={() => router.push("/terms")}
                        className="underline hover:text-foreground"
                      >
                        Terms of Service
                      </button>{" "}
                      and{" "}
                      <button
                        onClick={() => router.push("/privacy")}
                        className="underline hover:text-foreground"
                      >
                        Privacy Policy
                      </button>
                    </p>

                    <p className="text-center text-sm text-muted-foreground mt-8">
                      Already have an account?{" "}
                      <button
                        onClick={() => router.push("/login")}
                        className="text-primary font-medium hover:underline"
                      >
                        Sign in
                      </button>
                    </p>
                  </>
                )}
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>
    </div>
  );
}

/**
 * Signup page with premium split-screen design
 */
export default function SignupPage() {
  return (
    <Suspense
      fallback={
        <div className="flex min-h-screen items-center justify-center bg-background">
          <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
        </div>
      }
    >
      <SignupContent />
    </Suspense>
  );
}
