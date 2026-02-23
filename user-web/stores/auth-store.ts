import { create } from "zustand";
import { persist } from "zustand/middleware";
import type {
  User,
  StudentProfile,
  ProfessionalProfile,
  WalletProfile,
} from "./user-store";

/**
 * User type enumeration for type-safe user classification
 */
export type UserType = "student" | "professional" | "business";

/**
 * Onboarding step tracking for progressive user setup
 */
export type OnboardingStep =
  | "user_type"
  | "profile_details"
  | "verification"
  | "completed";

/**
 * Authentication state interface for managing user session and profile data
 * @interface AuthState
 */
interface AuthState {
  /**
   * Current authenticated user profile
   * Contains base profile information from the profiles table
   */
  user: User | null;

  /**
   * Student-specific profile data
   * Populated when user_type is 'student'
   */
  student: StudentProfile | null;

  /**
   * Professional-specific profile data
   * Populated when user_type is 'professional' or 'business'
   */
  professional: ProfessionalProfile | null;

  /**
   * User wallet information
   * Contains balance and currency data
   */
  wallet: WalletProfile | null;

  /**
   * Loading state for async operations
   */
  isLoading: boolean;

  /**
   * Whether the user is currently authenticated
   * Derived from user presence
   */
  isAuthenticated: boolean;

  /**
   * Whether the user has completed onboarding
   * True when user_type is set and required profile data exists
   */
  isOnboarded: boolean;

  /**
   * Current onboarding step for tracking progress
   */
  onboardingStep: OnboardingStep | null;

  /**
   * Error message from last operation
   */
  error: string | null;

  /**
   * Sets the user profile and updates authentication state
   * @param user - User profile or null to clear
   */
  setUser: (user: User | null) => void;

  /**
   * Sets the student profile data
   * @param student - Student profile or null to clear
   */
  setStudent: (student: StudentProfile | null) => void;

  /**
   * Sets the professional profile data
   * @param professional - Professional profile or null to clear
   */
  setProfessional: (professional: ProfessionalProfile | null) => void;

  /**
   * Sets the wallet data
   * @param wallet - Wallet profile or null to clear
   */
  setWallet: (wallet: WalletProfile | null) => void;

  /**
   * Sets the loading state
   * @param isLoading - Loading state boolean
   */
  setLoading: (isLoading: boolean) => void;

  /**
   * Sets the onboarded state
   * @param isOnboarded - Onboarding completion status
   */
  setOnboarded: (isOnboarded: boolean) => void;

  /**
   * Sets the current onboarding step
   * @param step - Current step in the onboarding flow
   */
  setOnboardingStep: (step: OnboardingStep | null) => void;

  /**
   * Sets an error message
   * @param error - Error message or null to clear
   */
  setError: (error: string | null) => void;

  /**
   * Initializes auth state from user data
   * Determines onboarding status based on user_type and profile existence
   * @param user - User profile data
   * @param student - Optional student profile
   * @param professional - Optional professional profile
   * @param wallet - Optional wallet data
   */
  initializeAuth: (
    user: User | null,
    student?: StudentProfile | null,
    professional?: ProfessionalProfile | null,
    wallet?: WalletProfile | null
  ) => void;

  /**
   * Clears all authentication data
   * Called on logout to reset state
   */
  clearAuth: () => void;
}

/**
 * Determines if user has completed onboarding based on profile data
 * @param user - User profile
 * @param student - Student profile if user_type is student
 * @param professional - Professional profile if user_type is professional/business
 * @returns Boolean indicating onboarding completion
 */
function checkOnboardingComplete(
  user: User | null,
  student: StudentProfile | null,
  professional: ProfessionalProfile | null
): boolean {
  if (!user) return false;

  // User must have a type selected
  if (!user.user_type) return false;

  // Check for type-specific profile existence
  if (user.user_type === "student") {
    return student !== null && !!student.university_id;
  }

  if (user.user_type === "professional" || user.user_type === "business") {
    return professional !== null && !!professional.professional_type;
  }

  return false;
}

/**
 * Determines current onboarding step based on profile data
 * @param user - User profile
 * @param student - Student profile
 * @param professional - Professional profile
 * @returns Current onboarding step
 */
function determineOnboardingStep(
  user: User | null,
  student: StudentProfile | null,
  professional: ProfessionalProfile | null
): OnboardingStep | null {
  if (!user) return null;

  // Step 1: User type selection
  if (!user.user_type) return "user_type";

  // Step 2: Profile details
  if (user.user_type === "student" && !student?.university_id) {
    return "profile_details";
  }
  if (
    (user.user_type === "professional" || user.user_type === "business") &&
    !professional?.professional_type
  ) {
    return "profile_details";
  }

  // All steps complete
  return "completed";
}

/**
 * Authentication store for managing user session state
 *
 * This store handles:
 * - User authentication status tracking
 * - Profile data management (user, student, professional)
 * - Wallet data reference
 * - Onboarding status and step tracking
 *
 * Persists onboarding state to localStorage for session continuity
 *
 * @example
 * ```tsx
 * // In a component
 * const { user, isAuthenticated, isOnboarded } = useAuthStore();
 *
 * if (!isAuthenticated) {
 *   return <LoginPage />;
 * }
 *
 * if (!isOnboarded) {
 *   return <OnboardingFlow />;
 * }
 *
 * return <Dashboard user={user} />;
 * ```
 */
export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      user: null,
      student: null,
      professional: null,
      wallet: null,
      isLoading: true,
      isAuthenticated: false,
      isOnboarded: false,
      onboardingStep: null,
      error: null,

      /**
       * Sets user and updates authentication state
       */
      setUser: (user) =>
        set({
          user,
          isAuthenticated: !!user,
          isOnboarded: checkOnboardingComplete(
            user,
            get().student,
            get().professional
          ),
          onboardingStep: determineOnboardingStep(
            user,
            get().student,
            get().professional
          ),
        }),

      /**
       * Sets student profile and updates onboarding state
       */
      setStudent: (student) => {
        const { user, professional } = get();
        set({
          student,
          isOnboarded: checkOnboardingComplete(user, student, professional),
          onboardingStep: determineOnboardingStep(user, student, professional),
        });
      },

      /**
       * Sets professional profile and updates onboarding state
       */
      setProfessional: (professional) => {
        const { user, student } = get();
        set({
          professional,
          isOnboarded: checkOnboardingComplete(user, student, professional),
          onboardingStep: determineOnboardingStep(user, student, professional),
        });
      },

      /**
       * Sets wallet data
       */
      setWallet: (wallet) => set({ wallet }),

      /**
       * Sets loading state
       */
      setLoading: (isLoading) => set({ isLoading }),

      /**
       * Manually sets onboarded state
       */
      setOnboarded: (isOnboarded) => set({ isOnboarded }),

      /**
       * Sets current onboarding step
       */
      setOnboardingStep: (onboardingStep) => set({ onboardingStep }),

      /**
       * Sets error state
       */
      setError: (error) => set({ error }),

      /**
       * Initializes authentication state with all profile data
       */
      initializeAuth: (user, student = null, professional = null, wallet = null) => {
        const isOnboarded = checkOnboardingComplete(user, student, professional);
        const onboardingStep = determineOnboardingStep(user, student, professional);

        set({
          user,
          student,
          professional,
          wallet,
          isAuthenticated: !!user,
          isOnboarded,
          onboardingStep,
          isLoading: false,
          error: null,
        });
      },

      /**
       * Clears all auth data on logout
       */
      clearAuth: () =>
        set({
          user: null,
          student: null,
          professional: null,
          wallet: null,
          isAuthenticated: false,
          isOnboarded: false,
          onboardingStep: null,
          isLoading: false,
          error: null,
        }),
    }),
    {
      name: "auth-storage",
      /**
       * Only persist essential state that should survive page refresh
       * User data will be re-fetched from Supabase on load
       */
      partialize: (state) => ({
        isOnboarded: state.isOnboarded,
        onboardingStep: state.onboardingStep,
      }),
    }
  )
);

/**
 * Selector hook for checking if user needs onboarding
 * @returns Boolean indicating if onboarding is required
 */
export const useNeedsOnboarding = (): boolean => {
  const { isAuthenticated, isOnboarded } = useAuthStore();
  return isAuthenticated && !isOnboarded;
};

/**
 * Selector hook for getting current user type
 * @returns User type or null if not authenticated
 */
export const useUserType = (): UserType | null => {
  const user = useAuthStore((state) => state.user);
  return user?.user_type ?? null;
};

/**
 * Selector hook for getting user's wallet balance
 * @returns Wallet balance or 0 if no wallet
 */
export const useWalletBalance = (): number => {
  const wallet = useAuthStore((state) => state.wallet);
  return wallet?.balance ?? 0;
};
