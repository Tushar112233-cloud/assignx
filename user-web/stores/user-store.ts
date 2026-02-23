import { create } from "zustand";
import { persist } from "zustand/middleware";
import { getProfile } from "@/lib/actions/data";

/**
 * User interface matching Supabase profile schema
 */
export interface User {
  id: string;
  email: string;
  full_name: string | null;
  phone: string | null;
  user_type: "student" | "professional" | "business";
  avatar_url: string | null;
  is_active: boolean;
  city: string | null;
  state: string | null;
  country: string | null;
  created_at: string;
  updated_at: string;
  user_roles: ("student" | "professional" | "business")[];
  // Joined relations
  students?: StudentProfile | null;
  professionals?: ProfessionalProfile | null;
  wallet?: WalletProfile | null;
  // Backward compatibility
  fullName?: string | null;
  userType?: "student" | "professional" | "business";
  avatarUrl?: string | null;
}

export interface StudentProfile {
  id: string;
  profile_id: string;
  university_id: string;
  course_id: string;
  semester: number | null;
  enrollment_year: number | null;
  college_email: string | null;
  student_id: string | null;
  date_of_birth: string | null;
  created_at: string;
  university?: {
    id: string;
    name: string;
    short_name: string | null;
    city: string | null;
    state: string | null;
    country: string | null;
  } | null;
  course?: {
    id: string;
    name: string;
    short_name: string | null;
    degree_type: string | null;
  } | null;
}

export interface ProfessionalProfile {
  id: string;
  profile_id: string;
  industry_id: string;
  professional_type: string | null;
  company_name: string | null;
  years_experience: number | null;
  created_at: string;
  industry?: {
    id: string;
    name: string;
  } | null;
}

export interface WalletProfile {
  id: string;
  profile_id: string;
  balance: number;
  currency: string;
}

type PortalRole = "student" | "professional" | "business";

interface UserState {
  user: User | null;
  isLoading: boolean;
  error: string | null;
  fetchUser: () => Promise<void>;
  setUser: (user: User | null) => void;
  setLoading: (isLoading: boolean) => void;
  clearUser: () => void;
  addRole: (role: PortalRole) => void;
  removeRole: (role: PortalRole) => void;
}

/**
 * Transforms database profile to component format
 */
function transformUser(profile: User): User {
  // Ensure user_roles is always populated
  const roles = Array.isArray(profile.user_roles) && profile.user_roles.length > 0
    ? profile.user_roles
    : [profile.user_type];

  return {
    ...profile,
    user_roles: roles,
    fullName: profile.full_name,
    userType: profile.user_type,
    avatarUrl: profile.avatar_url,
  };
}

/**
 * Global user state store
 * Persists user data to localStorage for session management
 * Integrates with Supabase for profile fetching
 */
export const useUserStore = create<UserState>()(
  persist(
    (set) => ({
      user: null,
      isLoading: true,
      error: null,

      /**
       * Fetches user profile from Supabase
       */
      fetchUser: async () => {
        set({ isLoading: true, error: null });
        try {
          const profile = await getProfile();
          if (profile) {
            set({ user: transformUser(profile), isLoading: false });
          } else {
            set({ user: null, isLoading: false });
          }
        } catch (error) {
          set({
            error: error instanceof Error ? error.message : "Failed to fetch profile",
            isLoading: false,
          });
        }
      },

      /**
       * Sets user manually
       */
      setUser: (user) => set({ user, isLoading: false }),

      /**
       * Sets loading state
       */
      setLoading: (isLoading) => set({ isLoading }),

      /**
       * Clears user data (logout)
       */
      clearUser: () => set({ user: null, isLoading: false, error: null }),

      /**
       * Add a role to current user (client-side, persisted via localStorage)
       */
      addRole: (role) =>
        set((state) => {
          if (!state.user) return state;
          const current = state.user.user_roles || [state.user.user_type];
          if (current.includes(role)) return state;
          return { user: { ...state.user, user_roles: [...current, role] } };
        }),

      /**
       * Remove a role from current user (cannot remove primary role)
       */
      removeRole: (role) =>
        set((state) => {
          if (!state.user) return state;
          if (state.user.user_type === role) return state;
          const current = state.user.user_roles || [state.user.user_type];
          const filtered = current.filter((r) => r !== role);
          if (filtered.length < 1) return state;
          return { user: { ...state.user, user_roles: filtered } };
        }),
    }),
    {
      name: "user-storage",
    }
  )
);
