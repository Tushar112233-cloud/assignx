"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { motion, AnimatePresence } from "framer-motion";
import {
  GraduationCap,
  Briefcase,
  Building2,
  ArrowRight,
  ArrowLeft,
  Loader2,
  AlertCircle,
  CheckCircle2,
  Shield,
} from "lucide-react";
import { Card, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { cn } from "@/lib/utils";
import { createClient } from "@/lib/supabase/client";

type RoleType = "student" | "professional" | "business" | null;

interface Role {
  id: RoleType;
  icon: React.ElementType;
  title: string;
  description: string;
  color: string;
  emailHint?: string;
}

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

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.15,
    },
  },
};

const cardVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0 },
};

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
 * Role selection screen with integrated Google sign-in
 * Step 1: Select role (Student/Professional/Other)
 * Step 2: Sign in with Google
 */
export function RoleSelection() {
  const router = useRouter();
  const [selectedRole, setSelectedRole] = useState<RoleType>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const supabase = createClient();

  const handleRoleSelect = (roleId: RoleType) => {
    setSelectedRole(roleId);
    setError(null);
  };

  const handleBack = () => {
    setSelectedRole(null);
    setError(null);
  };

  const handleGoogleSignIn = async () => {
    if (!selectedRole) return;

    setIsLoading(true);
    setError(null);

    try {
      // Store the selected role in a cookie (survives OAuth redirect)
      // Cookie expires in 10 minutes - enough time to complete OAuth
      document.cookie = `signup_role=${selectedRole}; path=/; max-age=600; SameSite=Lax`;
      document.cookie = `signup_intent=true; path=/; max-age=600; SameSite=Lax`;

      const callbackUrl = `${window.location.origin}/auth/callback`;

      const { error: authError } = await supabase.auth.signInWithOAuth({
        provider: "google",
        options: {
          redirectTo: callbackUrl,
          queryParams: {
            // For students, we might want to hint at using institutional email
            ...(selectedRole === "student" && {
              hd: "*", // Allow any hosted domain
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

  const selectedRoleData = roles.find((r) => r.id === selectedRole);

  return (
    <div className="flex min-h-[calc(100vh-4rem)] flex-col px-4 py-8">
      <AnimatePresence mode="wait">
        {/* Step 1: Role Selection */}
        {!selectedRole && (
          <motion.div
            key="role-selection"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0, x: -20 }}
            className="flex flex-1 flex-col"
          >
            {/* Header */}
            <div className="mb-8 text-center">
              <h1 className="mb-2 text-3xl font-bold tracking-tight">
                Choose Your Path
              </h1>
              <p className="text-muted-foreground">
                Select the option that best describes you
              </p>
            </div>

            {/* Role cards */}
            <motion.div
              variants={containerVariants}
              initial="hidden"
              animate="visible"
              className="mx-auto grid w-full max-w-4xl gap-4 md:grid-cols-3"
            >
              {roles.map((role) => (
                <motion.div key={role.id} variants={cardVariants}>
                  <Card
                    onClick={() => handleRoleSelect(role.id)}
                    className={cn(
                      "group cursor-pointer transition-all duration-300",
                      "hover:border-primary hover:shadow-lg hover:shadow-primary/10",
                      "hover:-translate-y-1"
                    )}
                  >
                    <CardHeader className="text-center">
                      {/* Icon */}
                      <div
                        className={cn(
                          "mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-2xl transition-colors",
                          role.color === "primary" &&
                            "bg-primary/10 text-primary",
                          role.color === "accent" &&
                            "bg-blue-500/10 text-blue-500",
                          role.color === "secondary" &&
                            "bg-secondary/50 text-foreground"
                        )}
                      >
                        <role.icon className="h-8 w-8" />
                      </div>

                      {/* Title */}
                      <CardTitle className="text-xl">{role.title}</CardTitle>

                      {/* Description */}
                      <CardDescription className="text-sm">
                        {role.description}
                      </CardDescription>

                      {/* Arrow indicator */}
                      <div className="mt-4 flex justify-center">
                        <div className="flex h-8 w-8 items-center justify-center rounded-full bg-muted transition-colors group-hover:bg-primary group-hover:text-primary-foreground">
                          <ArrowRight className="h-4 w-4" />
                        </div>
                      </div>
                    </CardHeader>
                  </Card>
                </motion.div>
              ))}
            </motion.div>

            {/* Login link */}
            <div className="mt-8 text-center">
              <p className="text-sm text-muted-foreground">
                Already have an account?{" "}
                <button
                  onClick={() => router.push("/login")}
                  className="font-medium text-primary hover:underline"
                >
                  Sign in
                </button>
              </p>
            </div>
          </motion.div>
        )}

        {/* Step 2: Google Sign-in */}
        {selectedRole && (
          <motion.div
            key="google-signin"
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0 }}
            className="flex flex-1 flex-col"
          >
            {/* Back button */}
            <button
              onClick={handleBack}
              className="mb-6 flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground"
            >
              <ArrowLeft className="h-4 w-4" />
              Back to role selection
            </button>

            {/* Content centered */}
            <div className="mx-auto flex w-full max-w-md flex-1 flex-col items-center justify-center">
              {/* Selected role indicator */}
              {selectedRoleData && (
                <div className="mb-8 text-center">
                  <div
                    className={cn(
                      "mx-auto mb-4 flex h-20 w-20 items-center justify-center rounded-2xl",
                      selectedRoleData.color === "primary" &&
                        "bg-primary/10 text-primary",
                      selectedRoleData.color === "accent" &&
                        "bg-blue-500/10 text-blue-500",
                      selectedRoleData.color === "secondary" &&
                        "bg-secondary/50 text-foreground"
                    )}
                  >
                    <selectedRoleData.icon className="h-10 w-10" />
                  </div>
                  <h2 className="mb-2 text-2xl font-bold">
                    Sign up as {selectedRoleData.title}
                  </h2>
                  <p className="text-muted-foreground">
                    Continue with Google to create your account
                  </p>
                </div>
              )}

              {/* Student email hint */}
              {selectedRole === "student" && (
                <Alert className="mb-6 border-blue-200 bg-blue-50 dark:border-blue-800 dark:bg-blue-900/20">
                  <AlertCircle className="h-4 w-4 text-blue-600" />
                  <AlertDescription className="text-blue-700 dark:text-blue-300">
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
                className="flex h-14 w-full items-center justify-center gap-3 rounded-xl border bg-white text-gray-700 shadow-sm transition-all hover:bg-gray-50 hover:shadow-md"
                variant="outline"
              >
                {isLoading ? (
                  <Loader2 className="h-5 w-5 animate-spin" />
                ) : (
                  <GoogleIcon className="h-5 w-5" />
                )}
                <span className="font-medium">
                  {isLoading ? "Connecting..." : "Continue with Google"}
                </span>
              </Button>

              {/* Security note */}
              <div className="mt-6 flex items-center gap-2 text-xs text-muted-foreground">
                <Shield className="h-4 w-4" />
                Secure authentication powered by Google
              </div>

              {/* Terms */}
              <p className="mt-6 text-center text-xs text-muted-foreground">
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
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
