"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { motion, AnimatePresence, useReducedMotion } from "framer-motion";
import {
  ArrowLeft,
  ArrowRight,
  Loader2,
  CheckCircle2,
  Sparkles,
  GraduationCap,
  BookOpen,
  Award,
  Users,
  Target,
  TrendingUp,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Checkbox } from "@/components/ui/checkbox";
import { PhoneInput } from "./phone-input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { UniversitySelector } from "./university-selector";
import { CourseSelector } from "./course-selector";
import { TermsModal } from "./terms-modal";
import { SuccessAnimation } from "./success-animation";
import {
  studentStep1Schema,
  studentStep2Schema,
  studentStep3Schema,
  type StudentFormData,
} from "@/lib/validations/student";
import { createStudentProfile, getAuthUserData } from "@/lib/actions/auth";
import { toast } from "sonner";

import "./onboarding.css";

// Animation configuration
const EASE = [0.16, 1, 0.3, 1] as const;

const steps = ["Personal", "Academic", "Confirm"];

// Visual config for each step
const STEP_VISUALS = [
  {
    heading: "Tell Us About Yourself",
    subheading: "Let's start with your basic information to personalize your experience.",
    cards: [
      { icon: GraduationCap, iconBg: "bg-primary", title: "Students", value: "10K+", label: "Active learners", position: "position-1", delay: 0.3 },
      { icon: Users, iconBg: "bg-accent", title: "Community", value: "500+", label: "Universities", position: "position-2", delay: 0.5 },
      { icon: Award, iconBg: "bg-success", title: "Success", value: "95%", label: "Satisfaction", position: "position-3", delay: 0.7 },
    ],
  },
  {
    heading: "Academic Details",
    subheading: "Help us understand your academic background for better service matching.",
    cards: [
      { icon: BookOpen, iconBg: "bg-primary", title: "Subjects", value: "200+", label: "Topics covered", position: "position-1", delay: 0.3 },
      { icon: Target, iconBg: "bg-accent", title: "Accuracy", value: "99%", label: "Quality assurance", position: "position-2", delay: 0.5 },
      { icon: TrendingUp, iconBg: "bg-success", title: "Grades", value: "A+", label: "Average improvement", position: "position-3", delay: 0.7 },
    ],
  },
  {
    heading: "Almost There!",
    subheading: "Just a few more details and you'll be ready to start your academic journey.",
    cards: [
      { icon: CheckCircle2, iconBg: "bg-success", title: "Verified", value: "100%", label: "Expert tutors", position: "position-1", delay: 0.3 },
      { icon: Award, iconBg: "bg-primary", title: "Quality", value: "Premium", label: "Service level", position: "position-2", delay: 0.5 },
      { icon: Users, iconBg: "bg-accent", title: "Support", value: "24/7", label: "Available help", position: "position-3", delay: 0.7 },
    ],
  },
];

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
 * Multi-step student signup form with premium split-screen design
 */
export function StudentSignupForm() {
  const router = useRouter();
  const prefersReducedMotion = useReducedMotion();
  const [currentStep, setCurrentStep] = useState(0);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [showTerms, setShowTerms] = useState(false);
  const [showSuccess, setShowSuccess] = useState(false);
  const [formData, setFormData] = useState<Partial<StudentFormData>>({});
  const [authEmail, setAuthEmail] = useState<string>("");
  const [isAuthDataLoaded, setIsAuthDataLoaded] = useState(false);

  // Step 1 form
  const step1Form = useForm({
    resolver: zodResolver(studentStep1Schema),
    defaultValues: {
      fullName: formData.fullName || "",
      dateOfBirth: formData.dateOfBirth || "",
    },
  });

  // Step 2 form
  const step2Form = useForm({
    resolver: zodResolver(studentStep2Schema),
    defaultValues: {
      universityId: formData.universityId || "",
      courseId: formData.courseId || "",
      semester: formData.semester || 1,
    },
  });

  // Step 3 form
  const step3Form = useForm({
    resolver: zodResolver(studentStep3Schema),
    defaultValues: {
      collegeEmail: formData.collegeEmail || "",
      phone: formData.phone || "",
      acceptTerms: formData.acceptTerms || false,
    },
  });

  // Fetch auth user data on mount
  useEffect(() => {
    const fetchAuthData = async () => {
      try {
        const authData = await getAuthUserData();
        if (authData) {
          if (authData.fullName) {
            step1Form.setValue("fullName", authData.fullName);
            setFormData((prev) => ({ ...prev, fullName: authData.fullName }));
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
  }, [step1Form, router]);

  const handleStep1Submit = step1Form.handleSubmit((data) => {
    setFormData((prev) => ({ ...prev, ...data }));
    setCurrentStep(1);
  });

  const handleStep2Submit = step2Form.handleSubmit((data) => {
    setFormData((prev) => ({ ...prev, ...data }));
    setCurrentStep(2);
  });

  const handleStep3Submit = step3Form.handleSubmit(async (data) => {
    setIsSubmitting(true);
    const finalData = { ...formData, ...data } as StudentFormData;

    try {
      const result = await createStudentProfile({
        fullName: finalData.fullName,
        dateOfBirth: finalData.dateOfBirth,
        universityId: finalData.universityId,
        courseId: finalData.courseId,
        semester: finalData.semester,
        collegeEmail: finalData.collegeEmail,
        phone: finalData.phone,
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
  });

  const handleBack = () => {
    if (currentStep > 0) {
      setCurrentStep(currentStep - 1);
    } else {
      router.push("/signup");
    }
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

  const visualConfig = STEP_VISUALS[currentStep];

  return (
    <div className="onboarding-page">
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
              {visualConfig.heading}
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
          <StepIndicator currentStep={currentStep} totalSteps={steps.length} />
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
          <ProgressBar currentStep={currentStep} totalSteps={steps.length} />

          {/* Content */}
          <AnimatePresence mode="wait">
            {/* Step 1: Personal Information */}
            {currentStep === 0 && (
              <motion.form
                key="step1"
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                onSubmit={handleStep1Submit}
                className="onboarding-form-content"
              >
                <button type="button" onClick={handleBack} className="onboarding-back-button">
                  <ArrowLeft className="h-4 w-4" />
                  Back
                </button>

                <div className="onboarding-form-header">
                  <h2 className="onboarding-form-title">Personal Information</h2>
                  <p className="onboarding-form-subtitle">Enter your basic details</p>
                </div>

                <div className="space-y-6">
                  <div className="space-y-2">
                    <div className="flex items-center justify-between">
                      <Label htmlFor="fullName">Full Name</Label>
                      {formData.fullName && (
                        <span className="flex items-center gap-1 text-xs text-green-600">
                          <CheckCircle2 className="h-3 w-3" />
                          From Google
                        </span>
                      )}
                    </div>
                    <Input
                      id="fullName"
                      placeholder="Enter your full name"
                      {...step1Form.register("fullName")}
                      className={step1Form.formState.errors.fullName ? "border-destructive" : ""}
                    />
                    {step1Form.formState.errors.fullName && (
                      <p className="text-sm text-destructive">
                        {step1Form.formState.errors.fullName.message}
                      </p>
                    )}
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="dateOfBirth">Date of Birth</Label>
                    <Input
                      id="dateOfBirth"
                      type="date"
                      {...step1Form.register("dateOfBirth")}
                      className={step1Form.formState.errors.dateOfBirth ? "border-destructive" : ""}
                    />
                    {step1Form.formState.errors.dateOfBirth && (
                      <p className="text-sm text-destructive">
                        {step1Form.formState.errors.dateOfBirth.message}
                      </p>
                    )}
                  </div>

                  <Button type="submit" className="onboarding-button-primary w-full">
                    Continue <ArrowRight className="ml-2 h-4 w-4" />
                  </Button>
                </div>
              </motion.form>
            )}

            {/* Step 2: Academic Information */}
            {currentStep === 1 && (
              <motion.form
                key="step2"
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                onSubmit={handleStep2Submit}
                className="onboarding-form-content"
              >
                <button type="button" onClick={handleBack} className="onboarding-back-button">
                  <ArrowLeft className="h-4 w-4" />
                  Back
                </button>

                <div className="onboarding-form-header">
                  <h2 className="onboarding-form-title">Academic Information</h2>
                  <p className="onboarding-form-subtitle">Tell us about your studies</p>
                </div>

                <div className="space-y-6">
                  <div className="space-y-2">
                    <Label>University</Label>
                    <UniversitySelector
                      value={step2Form.watch("universityId")}
                      onChange={(value) => step2Form.setValue("universityId", value)}
                      error={step2Form.formState.errors.universityId?.message}
                    />
                  </div>

                  <div className="space-y-2">
                    <Label>Course</Label>
                    <CourseSelector
                      value={step2Form.watch("courseId")}
                      onChange={(value) => step2Form.setValue("courseId", value)}
                      error={step2Form.formState.errors.courseId?.message}
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="semester">Semester</Label>
                    <Select
                      value={step2Form.watch("semester")?.toString()}
                      onValueChange={(value) => step2Form.setValue("semester", parseInt(value))}
                    >
                      <SelectTrigger className={step2Form.formState.errors.semester ? "border-destructive" : ""}>
                        <SelectValue placeholder="Select semester" />
                      </SelectTrigger>
                      <SelectContent>
                        {Array.from({ length: 12 }, (_, i) => i + 1).map((sem) => (
                          <SelectItem key={sem} value={sem.toString()}>
                            Semester {sem}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    {step2Form.formState.errors.semester && (
                      <p className="text-sm text-destructive">
                        {step2Form.formState.errors.semester.message}
                      </p>
                    )}
                  </div>

                  <Button type="submit" className="onboarding-button-primary w-full">
                    Continue <ArrowRight className="ml-2 h-4 w-4" />
                  </Button>
                </div>
              </motion.form>
            )}

            {/* Step 3: Contact Information */}
            {currentStep === 2 && (
              <motion.form
                key="step3"
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                onSubmit={handleStep3Submit}
                className="onboarding-form-content"
              >
                <button type="button" onClick={handleBack} className="onboarding-back-button">
                  <ArrowLeft className="h-4 w-4" />
                  Back
                </button>

                <div className="onboarding-form-header">
                  <h2 className="onboarding-form-title">Contact Information</h2>
                  <p className="onboarding-form-subtitle">Final step to complete your profile</p>
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
                    <Label htmlFor="collegeEmail">College Email (Optional)</Label>
                    <Input
                      id="collegeEmail"
                      type="email"
                      placeholder="your.email@college.edu"
                      {...step3Form.register("collegeEmail")}
                      className={step3Form.formState.errors.collegeEmail ? "border-destructive" : ""}
                    />
                    <p className="text-xs text-muted-foreground">
                      Add your .edu email for university verification (optional)
                    </p>
                    {step3Form.formState.errors.collegeEmail && (
                      <p className="text-sm text-destructive">
                        {step3Form.formState.errors.collegeEmail.message}
                      </p>
                    )}
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="phone">Phone Number</Label>
                    <PhoneInput
                      value={step3Form.watch("phone")}
                      onChange={(val) => step3Form.setValue("phone", val, { shouldValidate: true })}
                      error={!!step3Form.formState.errors.phone}
                      disabled={isSubmitting}
                    />
                    {step3Form.formState.errors.phone && (
                      <p className="text-sm text-destructive">
                        {step3Form.formState.errors.phone.message}
                      </p>
                    )}
                  </div>

                  <div className="flex items-start gap-3">
                    <Checkbox
                      id="acceptTerms"
                      checked={step3Form.watch("acceptTerms")}
                      onCheckedChange={(checked) => step3Form.setValue("acceptTerms", checked as boolean)}
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
                      {step3Form.formState.errors.acceptTerms && (
                        <p className="text-sm text-destructive">
                          {step3Form.formState.errors.acceptTerms.message}
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
            )}
          </AnimatePresence>
        </div>
      </div>

      {/* Terms Modal */}
      <TermsModal open={showTerms} onOpenChange={setShowTerms} />
    </div>
  );
}
