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
  BookOpen,
  Users,
  Star,
  TrendingUp,
  Award,
  FileText,
  Target,
  Zap,
} from "lucide-react";
import { Card, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { cn } from "@/lib/utils";
import { createClient } from "@/lib/supabase/client";

import "./onboarding.css";

// Animation configuration
const EASE = [0.16, 1, 0.3, 1] as const;

type RoleType = "student" | "professional" | "business" | null;

interface FloatingCardData {
  icon: React.ElementType;
  iconBg: string;
  title: string;
  value: string;
  label: string;
  position: string;
  delay: number;
}

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

// Carousel slide configuration
const CAROUSEL_SLIDES = [
  {
    visualHeading: "Expert Academic Help",
    visualSubheading: "Get professional assistance with assignments, research papers, and dissertations from verified experts.",
    cards: [
      {
        icon: BookOpen,
        iconBg: "bg-primary",
        title: "Assignments",
        value: "5000+",
        label: "Completed projects",
        position: "position-1",
        delay: 0.3,
      },
      {
        icon: Users,
        iconBg: "bg-accent",
        title: "Experts",
        value: "500+",
        label: "Verified professionals",
        position: "position-2",
        delay: 0.5,
      },
      {
        icon: Star,
        iconBg: "bg-success",
        title: "Rating",
        value: "4.9",
        label: "Average score",
        position: "position-3",
        delay: 0.7,
      },
    ],
  },
  {
    visualHeading: "Fast & Reliable",
    visualSubheading: "Quick turnaround times with guaranteed quality. Track progress in real-time.",
    cards: [
      {
        icon: Zap,
        iconBg: "bg-warning",
        title: "Turnaround",
        value: "24hr",
        label: "Average delivery",
        position: "position-1",
        delay: 0.3,
      },
      {
        icon: Target,
        iconBg: "bg-primary",
        title: "Accuracy",
        value: "99%",
        label: "On-time delivery",
        position: "position-2",
        delay: 0.5,
      },
      {
        icon: Award,
        iconBg: "bg-accent",
        title: "Quality",
        value: "A+",
        label: "Average grade",
        position: "position-3",
        delay: 0.7,
      },
    ],
  },
  {
    visualHeading: "Secure & Confidential",
    visualSubheading: "Your privacy matters. All transactions and communications are encrypted and secure.",
    cards: [
      {
        icon: Shield,
        iconBg: "bg-success",
        title: "Security",
        value: "256-bit",
        label: "Encryption",
        position: "position-1",
        delay: 0.3,
      },
      {
        icon: FileText,
        iconBg: "bg-primary",
        title: "Privacy",
        value: "100%",
        label: "Confidential",
        position: "position-2",
        delay: 0.5,
      },
      {
        icon: TrendingUp,
        iconBg: "bg-accent",
        title: "Growth",
        value: "10K+",
        label: "Happy students",
        position: "position-3",
        delay: 0.7,
      },
    ],
  },
];

// Role selection visual config
const ROLE_VISUAL_CONFIG = {
  visualHeading: "Choose Your Path",
  visualSubheading: "Select the option that best describes you to get a personalized experience.",
  cards: [
    {
      icon: GraduationCap,
      iconBg: "bg-primary",
      title: "Students",
      value: "8K+",
      label: "Active users",
      position: "position-1",
      delay: 0.3,
    },
    {
      icon: Briefcase,
      iconBg: "bg-accent",
      title: "Professionals",
      value: "2K+",
      label: "Career growth",
      position: "position-2",
      delay: 0.5,
    },
    {
      icon: Building2,
      iconBg: "bg-secondary",
      title: "Others",
      value: "500+",
      label: "Happy users",
      position: "position-3",
      delay: 0.7,
    },
  ],
};

// Sign-in visual config
const SIGNIN_VISUAL_CONFIG = {
  visualHeading: "Almost There!",
  visualSubheading: "Sign in with Google to create your account securely and start your journey.",
  cards: [
    {
      icon: Shield,
      iconBg: "bg-success",
      title: "Secure",
      value: "OAuth",
      label: "Authentication",
      position: "position-1",
      delay: 0.3,
    },
    {
      icon: Zap,
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
      title: "Trusted",
      value: "Google",
      label: "Powered by",
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
 * Main onboarding content with split-screen design
 */
function OnboardingContent() {
  const searchParams = useSearchParams();
  const router = useRouter();
  const prefersReducedMotion = useReducedMotion();
  const step = searchParams.get("step");

  const [currentCarouselSlide, setCurrentCarouselSlide] = useState(0);
  const [currentStep, setCurrentStep] = useState(0); // 0: carousel, 1: role, 2: signin
  const [selectedRole, setSelectedRole] = useState<RoleType>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const supabase = createClient();

  // Handle step from URL
  useEffect(() => {
    if (step === "role") {
      setCurrentStep(1);
    }
  }, [step]);

  // Auto-advance carousel
  useEffect(() => {
    if (currentStep !== 0) return;

    const timer = setInterval(() => {
      setCurrentCarouselSlide((prev) => (prev + 1) % CAROUSEL_SLIDES.length);
    }, 5000);

    return () => clearInterval(timer);
  }, [currentStep]);

  const handleCarouselNext = () => {
    if (currentCarouselSlide < CAROUSEL_SLIDES.length - 1) {
      setCurrentCarouselSlide((prev) => prev + 1);
    } else {
      setCurrentStep(1);
    }
  };

  const handleRoleSelect = (roleId: RoleType) => {
    setSelectedRole(roleId);
    setError(null);
    setCurrentStep(2);
  };

  const handleBack = () => {
    if (currentStep === 2) {
      setSelectedRole(null);
      setCurrentStep(1);
    } else if (currentStep === 1) {
      setCurrentStep(0);
      setCurrentCarouselSlide(0);
    }
    setError(null);
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
    } catch (err) {
      setError("Something went wrong. Please try again.");
      setIsLoading(false);
    }
  };

  // Get current visual config based on step
  const getVisualConfig = () => {
    if (currentStep === 0) {
      return CAROUSEL_SLIDES[currentCarouselSlide];
    } else if (currentStep === 1) {
      return ROLE_VISUAL_CONFIG;
    } else {
      return SIGNIN_VISUAL_CONFIG;
    }
  };

  const visualConfig = getVisualConfig();
  const totalSteps = 3;
  const selectedRoleData = roles.find((r) => r.id === selectedRole);

  return (
    <div className="onboarding-page">
      {/* Left Panel - Visual Side */}
      <div className="onboarding-visual">
        {/* Floating cards */}
        <div className="onboarding-floating-cards">
          <AnimatePresence mode="wait">
            {visualConfig.cards.map((card, index) => (
              <FloatingCard
                key={`card-${currentStep}-${currentCarouselSlide}-${index}`}
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
              key={`heading-${currentStep}-${currentCarouselSlide}`}
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
              key={`subheading-${currentStep}-${currentCarouselSlide}`}
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
            {/* Step 0: Carousel */}
            {currentStep === 0 && (
              <motion.div
                key="carousel"
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                className="onboarding-form-content"
              >
                <div className="onboarding-form-header">
                  <h2 className="onboarding-form-title">Welcome to AssignX</h2>
                  <p className="onboarding-form-subtitle">
                    Your one-stop solution for academic excellence
                  </p>
                </div>

                {/* Carousel dots */}
                <div className="flex justify-center gap-2 my-8">
                  {CAROUSEL_SLIDES.map((_, idx) => (
                    <button
                      key={idx}
                      onClick={() => setCurrentCarouselSlide(idx)}
                      className={cn(
                        "w-2 h-2 rounded-full transition-all",
                        currentCarouselSlide === idx
                          ? "bg-primary w-6"
                          : "bg-muted-foreground/30"
                      )}
                    />
                  ))}
                </div>

                <Button
                  onClick={handleCarouselNext}
                  className="onboarding-button-primary w-full"
                >
                  {currentCarouselSlide < CAROUSEL_SLIDES.length - 1 ? (
                    <>
                      Next <ArrowRight className="ml-2 h-4 w-4" />
                    </>
                  ) : (
                    <>
                      Get Started <ArrowRight className="ml-2 h-4 w-4" />
                    </>
                  )}
                </Button>

                <p className="text-center text-sm text-muted-foreground mt-6">
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

            {/* Step 1: Role Selection */}
            {currentStep === 1 && (
              <motion.div
                key="role-selection"
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
                  Back
                </button>

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
                      whileHover={{ scale: 1.02 }}
                      whileTap={{ scale: 0.98 }}
                    >
                      <Card
                        onClick={() => handleRoleSelect(role.id)}
                        className="onboarding-role-card"
                      >
                        <CardHeader className="p-4">
                          <div className="flex items-center gap-4">
                            <div className="onboarding-role-card-icon bg-muted/50 text-muted-foreground border border-border">
                              <role.icon className="h-6 w-6" />
                            </div>
                            <div className="flex-1">
                              <CardTitle className="text-base">{role.title}</CardTitle>
                              <CardDescription className="text-xs mt-1">
                                {role.description}
                              </CardDescription>
                            </div>
                            <ArrowRight className="h-5 w-5 onboarding-role-card-arrow" />
                          </div>
                        </CardHeader>
                      </Card>
                    </motion.div>
                  ))}
                </div>

                <p className="text-center text-sm text-muted-foreground mt-6">
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

            {/* Step 2: Google Sign-in */}
            {currentStep === 2 && selectedRoleData && (
              <motion.div
                key="google-signin"
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
                  Back to role selection
                </button>

                <div className="onboarding-form-header">
                  <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-2xl bg-[#765341]/10 text-[#765341] border border-[#765341]/30 dark:bg-[#765341]/20 dark:text-[#A07A65] dark:border-[#765341]/40">
                    <selectedRoleData.icon className="h-8 w-8" />
                  </div>
                  <h2 className="onboarding-form-title">
                    Sign up as {selectedRoleData.title}
                  </h2>
                  <p className="onboarding-form-subtitle">
                    Continue with Google to create your account
                  </p>
                </div>

                {/* Student email hint */}
                {selectedRole === "student" && (
                  <Alert className="mb-6 border-[#765341]/30 bg-[#765341]/10 dark:border-[#765341]/40 dark:bg-[#765341]/20">
                    <AlertCircle className="h-4 w-4 text-[#765341]" />
                    <AlertDescription className="text-[#5C4233] dark:text-[#A07A65]">
                      <strong>Student accounts require a valid college email</strong>
                      <br />
                      Please sign in with your institutional email (e.g.,
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

                {/* Google Sign-in Button */}
                <Button
                  onClick={handleGoogleSignIn}
                  disabled={isLoading}
                  className="onboarding-google-button"
                  variant="outline"
                >
                  {isLoading ? (
                    <Loader2 className="h-5 w-5 animate-spin" />
                  ) : (
                    <GoogleIcon className="h-5 w-5" />
                  )}
                  <span>
                    {isLoading ? "Connecting..." : "Continue with Google"}
                  </span>
                </Button>

                {/* Security note */}
                <div className="flex items-center justify-center gap-2 text-xs text-muted-foreground mt-6">
                  <Shield className="h-4 w-4" />
                  Secure authentication powered by Google
                </div>

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
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>
    </div>
  );
}

/**
 * Onboarding page with premium split-screen design
 */
export default function OnboardingPage() {
  return (
    <Suspense
      fallback={
        <div className="flex min-h-screen items-center justify-center bg-background">
          <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
        </div>
      }
    >
      <OnboardingContent />
    </Suspense>
  );
}
