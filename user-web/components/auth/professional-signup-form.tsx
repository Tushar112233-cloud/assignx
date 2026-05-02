"use client";

import { useState, useEffect } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { motion, AnimatePresence, useReducedMotion } from "framer-motion";
import {
  ArrowLeft,
  Loader2,
  CheckCircle2,
  Sparkles,
  Briefcase,
  Building2,
  TrendingUp,
  Award,
  Users,
  Target,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Checkbox } from "@/components/ui/checkbox";
import { PhoneInput } from "./phone-input";
import { IndustrySelector } from "./industry-selector";
import { TermsModal } from "./terms-modal";
import { SuccessAnimation } from "./success-animation";
import {
  professionalFormSchema,
  type ProfessionalFormData,
} from "@/lib/validations/professional";
import { createProfessionalProfile, getAuthUserData } from "@/lib/actions/auth";
import { toast } from "sonner";

import "./onboarding.css";

// Animation configuration
const EASE = [0.16, 1, 0.3, 1] as const;

// Visual config for professional signup
const PROFESSIONAL_VISUAL = {
  heading: "Complete Your Profile",
  subheading: "Set up your professional account to access career growth opportunities.",
  cards: [
    { icon: Briefcase, iconBg: "bg-primary", title: "Professionals", value: "5K+", label: "Active users", position: "position-1", delay: 0.3 },
    { icon: TrendingUp, iconBg: "bg-accent", title: "Growth", value: "85%", label: "Career advancement", position: "position-2", delay: 0.5 },
    { icon: Award, iconBg: "bg-success", title: "Success", value: "4.9", label: "Rating", position: "position-3", delay: 0.7 },
  ],
};

const BUSINESS_VISUAL = {
  heading: "Business Account Setup",
  subheading: "Configure your business profile to get started with our services.",
  cards: [
    { icon: Building2, iconBg: "bg-primary", title: "Businesses", value: "1K+", label: "Trusted clients", position: "position-1", delay: 0.3 },
    { icon: Users, iconBg: "bg-accent", title: "Team", value: "24/7", label: "Support", position: "position-2", delay: 0.5 },
    { icon: Target, iconBg: "bg-success", title: "Results", value: "99%", label: "Satisfaction", position: "position-3", delay: 0.7 },
  ],
};

/**
 * Floating card component
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
function StepIndicator({ currentStep, totalSteps }: { currentStep: number; totalSteps: number }) {
  return (
    <div className="onboarding-steps-indicator">
      {Array.from({ length: totalSteps }, (_, i) => (
        <div
          key={i}
          className={`onboarding-step-dot ${currentStep === i ? "active" : ""} ${i < currentStep ? "completed" : ""}`}
        />
      ))}
    </div>
  );
}

/**
 * Progress bar component
 */
function ProgressBar({ currentStep, totalSteps }: { currentStep: number; totalSteps: number }) {
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
 * Professional signup form with premium split-screen design
 */
export function ProfessionalSignupForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const prefersReducedMotion = useReducedMotion();
  const isBusiness = searchParams.get("type") === "business";

  const [isSubmitting, setIsSubmitting] = useState(false);
  const [showTerms, setShowTerms] = useState(false);
  const [showSuccess, setShowSuccess] = useState(false);
  const [authEmail, setAuthEmail] = useState<string>("");
  const [isNameFromGoogle, setIsNameFromGoogle] = useState(false);
  const [isAuthDataLoaded, setIsAuthDataLoaded] = useState(false);

  const form = useForm<ProfessionalFormData>({
    resolver: zodResolver(professionalFormSchema),
    defaultValues: {
      fullName: "",
      industryId: "",
      phone: "",
      acceptTerms: false,
    },
  });

  // Fetch auth user data on mount
  useEffect(() => {
    const fetchAuthData = async () => {
      try {
        const authData = await getAuthUserData();
        if (authData) {
          if (authData.fullName) {
            form.setValue("fullName", authData.fullName);
            setIsNameFromGoogle(true);
          }
          if (authData.email) {
            setAuthEmail(authData.email);
          }
        } else {
          router.push("/signup");
          return;
        }
      } catch {
        router.push("/signup");
        return;
      } finally {
        setIsAuthDataLoaded(true);
      }
    };

    fetchAuthData();
  }, [form, router]);

  const onSubmit = async (data: ProfessionalFormData) => {
    setIsSubmitting(true);

    try {
      const result = await createProfessionalProfile({
        fullName: data.fullName,
        industryId: data.industryId,
        phone: data.phone,
      });

      if (result.error) {
        toast.error(result.error);
        setIsSubmitting(false);
        return;
      }

      // Mark onboarding as complete in cookie for middleware
      const secure = window.location.protocol === 'https:' ? '; Secure' : '';
      document.cookie = `onboardingCompleted=true; path=/; max-age=604800; SameSite=Lax${secure}`;
      setShowSuccess(true);
    } catch {
      toast.error("Something went wrong. Please try again.");
      setIsSubmitting(false);
    }
  };

  const handleBack = () => {
    router.push("/signup");
  };

  const handleSuccessComplete = () => {
    window.location.href = "/home";
  };

  if (showSuccess) {
    return <SuccessAnimation onComplete={handleSuccessComplete} />;
  }

  if (!isAuthDataLoaded) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-background">
        <div className="flex flex-col items-center gap-4">
          <Loader2 className="h-8 w-8 animate-spin text-primary" />
          <p className="text-sm text-muted-foreground">Loading your information...</p>
        </div>
      </div>
    );
  }

  const visualConfig = isBusiness ? BUSINESS_VISUAL : PROFESSIONAL_VISUAL;

  return (
    <div className="onboarding-page">
      {/* Left Panel - Visual Side */}
      <div className="onboarding-visual">
        {/* Floating cards */}
        <div className="onboarding-floating-cards">
          <AnimatePresence mode="wait">
            {visualConfig.cards.map((card, index) => (
              <FloatingCard
                key={`card-${index}`}
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
              key="heading"
              initial={prefersReducedMotion ? {} : { opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -30 }}
              transition={{ delay: 0.2, duration: 0.6, ease: EASE }}
              className="onboarding-visual-heading"
            >
              {visualConfig.heading}
            </motion.h1>
          </AnimatePresence>

          <AnimatePresence mode="wait">
            <motion.p
              key="subheading"
              initial={prefersReducedMotion ? {} : { opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              transition={{ delay: 0.4, duration: 0.6, ease: EASE }}
              className="onboarding-visual-subheading"
            >
              {visualConfig.subheading}
            </motion.p>
          </AnimatePresence>
        </div>

        {/* Step indicators */}
        <motion.div
          initial={prefersReducedMotion ? {} : { opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.6, duration: 0.6 }}
        >
          <StepIndicator currentStep={0} totalSteps={1} />
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
          <ProgressBar currentStep={0} totalSteps={1} />

          {/* Content */}
          <motion.form
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            onSubmit={form.handleSubmit(onSubmit)}
            className="onboarding-form-content"
          >
            <button type="button" onClick={handleBack} className="onboarding-back-button">
              <ArrowLeft className="h-4 w-4" />
              Back
            </button>

            <div className="onboarding-form-header">
              <h2 className="onboarding-form-title">
                {isBusiness ? "Business Registration" : "Professional Registration"}
              </h2>
              <p className="onboarding-form-subtitle">
                {isBusiness
                  ? "Set up your business account to get started"
                  : "Complete your profile to unlock career opportunities"}
              </p>
            </div>

            <div className="space-y-6">
              {/* Show authenticated email */}
              {authEmail && (
                <div className="space-y-2">
                  <Label>Account Email</Label>
                  <div className="flex items-center gap-2 rounded-md border bg-muted/50 px-3 py-2">
                    <CheckCircle2 className="h-4 w-4 text-green-500" />
                    <span className="text-sm">{authEmail}</span>
                    <span className="ml-auto text-xs text-muted-foreground">via Google</span>
                  </div>
                </div>
              )}

              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <Label htmlFor="fullName">Full Name</Label>
                  {isNameFromGoogle && (
                    <span className="flex items-center gap-1 text-xs text-green-600">
                      <CheckCircle2 className="h-3 w-3" />
                      From Google
                    </span>
                  )}
                </div>
                <Input
                  id="fullName"
                  placeholder="Enter your full name"
                  {...form.register("fullName")}
                  className={form.formState.errors.fullName ? "border-destructive" : ""}
                />
                {form.formState.errors.fullName && (
                  <p className="text-sm text-destructive">
                    {form.formState.errors.fullName.message}
                  </p>
                )}
              </div>

              <div className="space-y-2">
                <Label>Industry</Label>
                <IndustrySelector
                  value={form.watch("industryId")}
                  onChange={(value) => form.setValue("industryId", value)}
                  error={form.formState.errors.industryId?.message}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="phone">Phone Number</Label>
                <PhoneInput
                  value={form.watch("phone")}
                  onChange={(val) => form.setValue("phone", val, { shouldValidate: true })}
                  error={!!form.formState.errors.phone}
                  disabled={isSubmitting}
                />
                {form.formState.errors.phone && (
                  <p className="text-sm text-destructive">
                    {form.formState.errors.phone.message}
                  </p>
                )}
              </div>

              <div className="flex items-start gap-3">
                <Checkbox
                  id="acceptTerms"
                  checked={form.watch("acceptTerms")}
                  onCheckedChange={(checked) => form.setValue("acceptTerms", checked as boolean)}
                />
                <div className="space-y-1">
                  <Label htmlFor="acceptTerms" className="text-sm font-normal leading-relaxed">
                    I agree to the{" "}
                    <button type="button" onClick={() => setShowTerms(true)} className="font-medium text-primary underline">
                      Terms of Service
                    </button>{" "}
                    and{" "}
                    <button type="button" onClick={() => setShowTerms(true)} className="font-medium text-primary underline">
                      Privacy Policy
                    </button>
                  </Label>
                  {form.formState.errors.acceptTerms && (
                    <p className="text-sm text-destructive">
                      {form.formState.errors.acceptTerms.message}
                    </p>
                  )}
                </div>
              </div>

              <Button type="submit" className="onboarding-button-primary w-full" disabled={isSubmitting}>
                {isSubmitting ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Creating Account...
                  </>
                ) : (
                  "Complete Registration"
                )}
              </Button>
            </div>
          </motion.form>
        </div>
      </div>

      {/* Terms Modal */}
      <TermsModal open={showTerms} onOpenChange={setShowTerms} />
    </div>
  );
}
