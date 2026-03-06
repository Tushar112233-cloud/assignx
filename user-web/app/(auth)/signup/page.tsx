"use client";

import { useState, useEffect, useRef, useCallback, Suspense } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import Link from "next/link";
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
import { sendOTP, verifyOTP } from "@/lib/api/auth";
import { toast } from "sonner";

import "../onboarding/onboarding.css";

/**
 * Supported college email domain patterns
 */
const COLLEGE_EMAIL_PATTERNS = [
  /\.edu$/i,
  /\.ac\.in$/i,
  /\.ac\.uk$/i,
  /\.edu\.au$/i,
  /\.edu\.ca$/i,
];

/**
 * Validates if email is from a college/university domain
 */
function isCollegeEmail(email: string): boolean {
  const domain = email.toLowerCase().split("@")[1];
  if (!domain) return false;
  return COLLEGE_EMAIL_PATTERNS.some((pattern) => pattern.test(domain));
}

// Animation configuration
const EASE = [0.16, 1, 0.3, 1] as const;

type RoleType = "student" | "professional" | "business";

interface Role {
  id: RoleType;
  icon: React.ElementType;
  title: string;
  description: string;
  emailHint?: string;
}

const roles: Role[] = [
  {
    id: "student",
    icon: GraduationCap,
    title: "Student",
    description:
      "Get expert help with your academic projects. From essays to dissertations, we have you covered.",
    emailHint: "Requires educational email (.edu, .ac.in, etc.)",
  },
  {
    id: "professional",
    icon: Briefcase,
    title: "Professional",
    description:
      "Professional assistance for career growth. Resumes, portfolios, and interview prep.",
  },
  {
    id: "business",
    icon: Building2,
    title: "Other",
    description:
      "General users, businesses, and anyone else looking for expert assistance.",
  },
];

// Visual configs for each step
const STEP_VISUAL_CONFIGS = [
  {
    visualHeading: "Join AssignX Today",
    visualSubheading:
      "Create your account and get access to expert academic assistance tailored just for you.",
    cards: [
      { icon: Users, iconBg: "bg-primary", title: "Students", value: "10K+", label: "Active users", position: "position-1", delay: 0.3 },
      { icon: Star, iconBg: "bg-accent", title: "Rating", value: "4.9", label: "User satisfaction", position: "position-2", delay: 0.5 },
      { icon: TrendingUp, iconBg: "bg-success", title: "Success", value: "95%", label: "Grade improvement", position: "position-3", delay: 0.7 },
    ],
  },
  {
    visualHeading: "Verify Your Identity",
    visualSubheading:
      "We'll send a secure 6-digit code to your email. No passwords needed.",
    cards: [
      { icon: Shield, iconBg: "bg-success", title: "Secure", value: "OTP", label: "Verification", position: "position-1", delay: 0.3 },
      { icon: Award, iconBg: "bg-primary", title: "Quick", value: "1-Min", label: "Setup", position: "position-2", delay: 0.5 },
      { icon: Star, iconBg: "bg-accent", title: "No", value: "Password", label: "Needed", position: "position-3", delay: 0.7 },
    ],
  },
  {
    visualHeading: "You're All Set!",
    visualSubheading: "Setting up your account. You'll be redirected momentarily.",
    cards: [
      { icon: CheckCircle2, iconBg: "bg-success", title: "Verified", value: "Done", label: "Email confirmed", position: "position-1", delay: 0.3 },
      { icon: Award, iconBg: "bg-primary", title: "Account", value: "Ready", label: "All set", position: "position-2", delay: 0.5 },
      { icon: Star, iconBg: "bg-accent", title: "Welcome", value: "Hello!", label: "Let's go", position: "position-3", delay: 0.7 },
    ],
  },
];

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
        <span>
          Step {currentStep + 1} of {totalSteps}
        </span>
        <span>{Math.round(progress)}% complete</span>
      </div>
    </div>
  );
}

/**
 * OTP input component - 6 individual digit boxes with auto-advance and paste support
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
  const digits = Array.from({ length: 6 }, (_, i) => value[i] || "");

  const focusInput = (index: number) => {
    if (index >= 0 && index < 6) {
      inputRefs.current[index]?.focus();
    }
  };

  const handleChange = (index: number, char: string) => {
    // Only allow digits
    if (char && !/^\d$/.test(char)) return;

    const newDigits = [...digits];
    newDigits[index] = char;
    const newOtp = newDigits.join("");
    onChange(newOtp);

    // Auto-advance to next input
    if (char && index < 5) {
      focusInput(index + 1);
    }
  };

  const handleKeyDown = (index: number, e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Backspace") {
      if (digits[index]) {
        // Clear current digit
        handleChange(index, "");
      } else if (index > 0) {
        // Move to previous and clear it
        focusInput(index - 1);
        handleChange(index - 1, "");
      }
      e.preventDefault();
    } else if (e.key === "ArrowLeft" && index > 0) {
      focusInput(index - 1);
      e.preventDefault();
    } else if (e.key === "ArrowRight" && index < 5) {
      focusInput(index + 1);
      e.preventDefault();
    }
  };

  const handlePaste = (e: React.ClipboardEvent) => {
    e.preventDefault();
    const pastedText = e.clipboardData.getData("text").replace(/\D/g, "").slice(0, 6);
    if (pastedText) {
      onChange(pastedText);
      // Focus the input after the last pasted digit
      focusInput(Math.min(pastedText.length, 5));
    }
  };

  return (
    <div className="flex gap-2 justify-center" onPaste={handlePaste}>
      {digits.map((digit, index) => (
        <input
          key={index}
          ref={(el) => { inputRefs.current[index] = el; }}
          type="text"
          inputMode="numeric"
          maxLength={1}
          value={digit}
          disabled={disabled}
          onChange={(e) => handleChange(index, e.target.value.slice(-1))}
          onKeyDown={(e) => handleKeyDown(index, e)}
          onFocus={(e) => e.target.select()}
          className="w-12 h-14 text-center text-xl font-semibold rounded-lg border-2 border-gray-300 dark:border-gray-600 bg-[var(--onboarding-bg)] text-[var(--onboarding-text)] focus:outline-none focus:border-primary focus:ring-2 focus:ring-primary/20 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
          aria-label={`Digit ${index + 1}`}
        />
      ))}
    </div>
  );
}

/**
 * Signup page content with 3-step stepper: Role -> Email+OTP -> Redirect
 */
function SignupContent() {
  const searchParams = useSearchParams();
  const router = useRouter();
  const prefersReducedMotion = useReducedMotion();

  // Step state: 0 = role selection, 1 = email + OTP, 2 = redirect
  const [currentStep, setCurrentStep] = useState(0);
  const [selectedRole, setSelectedRole] = useState<RoleType | null>(null);

  // Email + OTP state
  const [email, setEmail] = useState("");
  const [otp, setOtp] = useState("");
  const [otpSent, setOtpSent] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [accountExistsError, setAccountExistsError] = useState(false);

  // Resend cooldown
  const [resendCooldown, setResendCooldown] = useState(0);
  const cooldownRef = useRef<NodeJS.Timeout | null>(null);

  // Email error banner from URL
  const [showEmailError, setShowEmailError] = useState(false);
  const [emailErrorMessage, setEmailErrorMessage] = useState("");

  // Handle error from URL params
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

  // Cleanup cooldown timer
  useEffect(() => {
    return () => {
      if (cooldownRef.current) clearInterval(cooldownRef.current);
    };
  }, []);

  /**
   * Start the 60-second resend cooldown
   */
  const startResendCooldown = useCallback(() => {
    setResendCooldown(60);
    if (cooldownRef.current) clearInterval(cooldownRef.current);
    cooldownRef.current = setInterval(() => {
      setResendCooldown((prev) => {
        if (prev <= 1) {
          if (cooldownRef.current) clearInterval(cooldownRef.current);
          return 0;
        }
        return prev - 1;
      });
    }, 1000);
  }, []);

  /**
   * Validates basic email format
   */
  const isValidEmail = (em: string): boolean => {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(em);
  };

  /**
   * Step 1: Select a role and advance
   */
  const handleRoleSelect = (roleId: RoleType) => {
    setSelectedRole(roleId);
    setError(null);
    setAccountExistsError(false);
    setCurrentStep(1);
  };

  /**
   * Step 2a: Send OTP to the entered email
   */
  const handleSendOTP = async () => {
    if (!selectedRole) return;

    const trimmedEmail = email.trim().toLowerCase();
    setError(null);
    setAccountExistsError(false);

    if (!trimmedEmail) {
      setError("Please enter your email address.");
      return;
    }
    if (!isValidEmail(trimmedEmail)) {
      setError("Please enter a valid email address.");
      return;
    }
    if (selectedRole === "student" && !isCollegeEmail(trimmedEmail)) {
      setError(
        "Student accounts require a valid educational email (.edu, .ac.in, .ac.uk, .edu.au, .edu.ca)."
      );
      return;
    }

    setIsLoading(true);

    const result = await sendOTP(trimmedEmail, "signup", selectedRole);

    setIsLoading(false);

    if (!result.success) {
      // Detect 409 "account already exists" from the error message
      if (result.error && /already exists/i.test(result.error)) {
        setAccountExistsError(true);
        setError(null);
      } else {
        setError(result.error || "Failed to send verification code.");
      }
      return;
    }

    setOtpSent(true);
    setOtp("");
    startResendCooldown();
    toast.success("Verification code sent!", {
      description: "Check your email inbox for the 6-digit code.",
    });
  };

  /**
   * Step 2b: Verify the OTP
   */
  const handleVerifyOTP = async () => {
    if (!selectedRole) return;

    const trimmedEmail = email.trim().toLowerCase();
    const trimmedOtp = otp.trim();

    setError(null);

    if (trimmedOtp.length !== 6) {
      setError("Please enter the complete 6-digit code.");
      return;
    }

    setIsLoading(true);

    const result = await verifyOTP(trimmedEmail, trimmedOtp, "signup", selectedRole);

    setIsLoading(false);

    if (!result.success) {
      setError(result.error || "Verification failed. Please try again.");
      return;
    }

    // Step 3: Redirect
    setCurrentStep(2);

    // Store role in cookie
    const secure = window.location.protocol === "https:" ? "; Secure" : "";
    document.cookie = `signup_role=${selectedRole}; path=/; max-age=600; SameSite=Lax${secure}`;

    // Small delay for the success animation, then redirect
    setTimeout(() => {
      if (selectedRole === "student") {
        router.push("/signup/student");
      } else {
        const typeParam = selectedRole === "business" ? "?type=business" : "";
        router.push(`/signup/professional${typeParam}`);
      }
    }, 1200);
  };

  /**
   * Resend OTP
   */
  const handleResendOTP = async () => {
    if (resendCooldown > 0 || !selectedRole) return;
    setError(null);
    setIsLoading(true);

    const trimmedEmail = email.trim().toLowerCase();
    const result = await sendOTP(trimmedEmail, "signup", selectedRole);

    setIsLoading(false);

    if (!result.success) {
      setError(result.error || "Failed to resend code.");
      return;
    }

    setOtp("");
    startResendCooldown();
    toast.success("Code resent!", {
      description: "A new verification code has been sent to your email.",
    });
  };

  /**
   * Navigate back one step
   */
  const handleBack = () => {
    setError(null);
    setAccountExistsError(false);

    if (otpSent) {
      // Go back from OTP entry to email entry
      setOtpSent(false);
      setOtp("");
      if (cooldownRef.current) clearInterval(cooldownRef.current);
      setResendCooldown(0);
    } else if (currentStep === 1) {
      // Go back from email to role selection
      setCurrentStep(0);
      setSelectedRole(null);
      setEmail("");
    }
  };

  const totalSteps = 3;
  const visualConfig = STEP_VISUAL_CONFIGS[currentStep] || STEP_VISUAL_CONFIGS[0];
  const selectedRoleData = roles.find((r) => r.id === selectedRole);

  return (
    <div className="onboarding-page">
      {/* Error Alert for invalid student email (from URL) */}
      {showEmailError && (
        <div className="fixed inset-x-0 top-0 z-50 p-4">
          <Alert variant="destructive" className="mx-auto max-w-lg shadow-lg">
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
            {/* ===== STEP 0: Role Selection ===== */}
            {currentStep === 0 && (
              <motion.div
                key="step-role"
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                transition={{ duration: 0.3, ease: EASE }}
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
                            <div className="onboarding-role-card-title">
                              {role.title}
                            </div>
                            <div className="onboarding-role-card-description">
                              {role.description}
                            </div>
                            {role.emailHint && (
                              <div className="mt-1 text-xs text-[var(--onboarding-accent)] font-medium">
                                {role.emailHint}
                              </div>
                            )}
                          </div>
                          <ArrowRight className="h-5 w-5 onboarding-role-card-arrow" />
                        </div>
                      </div>
                    </motion.div>
                  ))}
                </div>

                <p className="text-center text-sm text-muted-foreground mt-8">
                  Already have an account?{" "}
                  <Link
                    href="/login"
                    className="text-primary font-medium hover:underline"
                  >
                    Sign in
                  </Link>
                </p>
              </motion.div>
            )}

            {/* ===== STEP 1: Email + OTP ===== */}
            {currentStep === 1 && selectedRoleData && (
              <motion.div
                key="step-email-otp"
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                transition={{ duration: 0.3, ease: EASE }}
                className="onboarding-form-content"
              >
                <button onClick={handleBack} className="onboarding-back-button">
                  <ArrowLeft className="h-4 w-4" />
                  {otpSent ? "Change email" : "Back to role selection"}
                </button>

                <div className="onboarding-form-header">
                  <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-2xl bg-[#765341]/10 text-[#765341] border border-[#765341]/30 dark:bg-[#765341]/20 dark:text-[#A07A65] dark:border-[#765341]/40">
                    <selectedRoleData.icon className="h-8 w-8" />
                  </div>
                  <h2 className="onboarding-form-title">
                    {otpSent ? "Enter Verification Code" : `Sign up as ${selectedRoleData.title}`}
                  </h2>
                  <p className="onboarding-form-subtitle">
                    {otpSent
                      ? <>We sent a 6-digit code to <span className="font-medium text-[var(--onboarding-text)]">{email.trim().toLowerCase()}</span></>
                      : "Enter your email to receive a secure verification code"}
                  </p>
                </div>

                {/* Student email requirement notice */}
                {selectedRole === "student" && !otpSent && (
                  <Alert className="mb-6 border-[#765341]/30 bg-[#765341]/10 dark:border-[#765341]/40 dark:bg-[#765341]/20">
                    <AlertCircle className="h-4 w-4 text-[#765341]" />
                    <AlertDescription className="text-[#5C4233] dark:text-[#A07A65]">
                      <strong>Educational email required</strong>
                      <br />
                      Use your college email (.edu, .ac.in, .ac.uk, .edu.au, .edu.ca)
                    </AlertDescription>
                  </Alert>
                )}

                {/* Account exists error with link */}
                {accountExistsError && (
                  <motion.div
                    initial={{ opacity: 0, y: -10 }}
                    animate={{ opacity: 1, y: 0 }}
                  >
                    <Alert variant="destructive" className="mb-6">
                      <AlertCircle className="h-4 w-4" />
                      <AlertDescription>
                        Account already exists.{" "}
                        <Link
                          href="/login"
                          className="font-medium underline hover:no-underline"
                        >
                          Log in instead
                        </Link>
                      </AlertDescription>
                    </Alert>
                  </motion.div>
                )}

                {/* General error */}
                {error && (
                  <motion.div
                    initial={{ opacity: 0, y: -10 }}
                    animate={{ opacity: 1, y: 0 }}
                  >
                    <Alert variant="destructive" className="mb-6">
                      <AlertCircle className="h-4 w-4" />
                      <AlertDescription>{error}</AlertDescription>
                    </Alert>
                  </motion.div>
                )}

                {!otpSent ? (
                  /* ---- Email Input ---- */
                  <div className="space-y-4">
                    <div>
                      <Input
                        type="email"
                        placeholder={
                          selectedRole === "student"
                            ? "yourname@college.edu"
                            : "Enter your email address"
                        }
                        value={email}
                        onChange={(e) => {
                          setEmail(e.target.value);
                          setError(null);
                          setAccountExistsError(false);
                        }}
                        onKeyDown={(e) => {
                          if (e.key === "Enter") {
                            e.preventDefault();
                            handleSendOTP();
                          }
                        }}
                        disabled={isLoading}
                        aria-invalid={!!error || accountExistsError}
                        className="h-12"
                        autoFocus
                      />
                    </div>

                    <Button
                      onClick={handleSendOTP}
                      disabled={isLoading || !email.trim()}
                      className="h-12 w-full"
                    >
                      {isLoading ? (
                        <>
                          <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                          Sending...
                        </>
                      ) : (
                        <>
                          <Mail className="mr-2 h-4 w-4" />
                          Send Code
                        </>
                      )}
                    </Button>
                  </div>
                ) : (
                  /* ---- OTP Input ---- */
                  <motion.div
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="space-y-6"
                  >
                    <OTPInput
                      value={otp}
                      onChange={(newOtp) => {
                        setOtp(newOtp);
                        setError(null);
                      }}
                      disabled={isLoading}
                    />

                    <Button
                      onClick={handleVerifyOTP}
                      disabled={isLoading || otp.replace(/\s/g, "").length !== 6}
                      className="h-12 w-full"
                    >
                      {isLoading ? (
                        <>
                          <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                          Verifying...
                        </>
                      ) : (
                        <>
                          <CheckCircle2 className="mr-2 h-4 w-4" />
                          Verify
                        </>
                      )}
                    </Button>

                    {/* Resend */}
                    <div className="text-center">
                      {resendCooldown > 0 ? (
                        <p className="text-sm text-muted-foreground">
                          Resend code in{" "}
                          <span className="font-medium text-[var(--onboarding-text)]">
                            {resendCooldown}s
                          </span>
                        </p>
                      ) : (
                        <button
                          onClick={handleResendOTP}
                          disabled={isLoading}
                          className="text-sm font-medium text-primary hover:underline disabled:opacity-50"
                        >
                          Resend code
                        </button>
                      )}
                    </div>
                  </motion.div>
                )}

                {/* Security note */}
                <div className="flex items-center justify-center gap-2 text-xs text-muted-foreground mt-6">
                  <Shield className="h-4 w-4" />
                  Secure passwordless authentication
                </div>

                {/* Terms */}
                <p className="text-center text-xs text-muted-foreground mt-4">
                  By continuing, you agree to our{" "}
                  <Link
                    href="/terms"
                    className="underline hover:text-foreground"
                  >
                    Terms of Service
                  </Link>{" "}
                  and{" "}
                  <Link
                    href="/privacy"
                    className="underline hover:text-foreground"
                  >
                    Privacy Policy
                  </Link>
                </p>

                <p className="text-center text-sm text-muted-foreground mt-6">
                  Already have an account?{" "}
                  <Link
                    href="/login"
                    className="text-primary font-medium hover:underline"
                  >
                    Sign in
                  </Link>
                </p>
              </motion.div>
            )}

            {/* ===== STEP 2: Redirect (success) ===== */}
            {currentStep === 2 && (
              <motion.div
                key="step-redirect"
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ duration: 0.4, ease: EASE }}
                className="onboarding-form-content text-center"
              >
                <motion.div
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  transition={{ delay: 0.2, type: "spring", stiffness: 200, damping: 15 }}
                  className="mx-auto mb-6 flex h-20 w-20 items-center justify-center rounded-full bg-green-100 dark:bg-green-900/30"
                >
                  <CheckCircle2 className="h-10 w-10 text-green-600 dark:text-green-400" />
                </motion.div>

                <h2 className="onboarding-form-title">Verified!</h2>
                <p className="onboarding-form-subtitle mb-6">
                  Your email has been verified. Setting up your account...
                </p>

                <div className="flex items-center justify-center">
                  <Loader2 className="h-5 w-5 animate-spin text-muted-foreground" />
                  <span className="ml-2 text-sm text-muted-foreground">
                    Redirecting...
                  </span>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>
    </div>
  );
}

/**
 * Signup page with 3-step stepper: Role Selection -> Email + OTP -> Redirect
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
