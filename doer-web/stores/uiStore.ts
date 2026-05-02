import { create } from 'zustand'

/**
 * UI state interface
 */
interface UIState {
  /** Sidebar open state */
  isSidebarOpen: boolean
  /** Current onboarding step */
  onboardingStep: number
  /** Current profile setup step */
  profileSetupStep: number
  /** Toggle sidebar */
  toggleSidebar: () => void
  /** Set sidebar open state */
  setSidebarOpen: (isOpen: boolean) => void
  /** Set onboarding step */
  setOnboardingStep: (step: number) => void
  /** Set profile setup step */
  setProfileSetupStep: (step: number) => void
  /** Reset onboarding */
  resetOnboarding: () => void
}

/**
 * UI store for managing UI state
 */
export const useUIStore = create<UIState>((set) => ({
  isSidebarOpen: false,
  onboardingStep: 0,
  profileSetupStep: 1,
  toggleSidebar: () => set((state) => ({ isSidebarOpen: !state.isSidebarOpen })),
  setSidebarOpen: (isOpen) => set({ isSidebarOpen: isOpen }),
  setOnboardingStep: (step) => set({ onboardingStep: step }),
  setProfileSetupStep: (step) => set({ profileSetupStep: step }),
  resetOnboarding: () => set({ onboardingStep: 0, profileSetupStep: 1 }),
}))
