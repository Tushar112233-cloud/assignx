/**
 * Profile module static options data
 * Contains UI options for profile forms (not mock user data)
 * User data is fetched from Supabase via lib/actions/data.ts
 */

import type {
  SubscriptionPlan,
  UniversityOption,
  YearLevel,
} from "@/types/profile";

/**
 * Available subscription plans
 * Static configuration for subscription tier display
 */
export const subscriptionPlans: SubscriptionPlan[] = [
  {
    id: "plan_free",
    tier: "free",
    name: "Free",
    price: 0,
    currency: "USD",
    interval: "month",
    features: [
      "Up to 3 active projects",
      "Basic AI assistance",
      "Email support",
      "Standard delivery times",
    ],
  },
  {
    id: "plan_pro",
    tier: "pro",
    name: "Pro",
    price: 9.99,
    currency: "USD",
    interval: "month",
    features: [
      "Up to 10 active projects",
      "Advanced AI assistance",
      "Priority support",
      "Faster delivery times",
      "Revision tracking",
      "Plagiarism reports",
    ],
    highlighted: true,
  },
  {
    id: "plan_premium",
    tier: "premium",
    name: "Premium",
    price: 19.99,
    currency: "USD",
    interval: "month",
    features: [
      "Unlimited projects",
      "Premium AI assistance",
      "24/7 priority support",
      "Express delivery",
      "Advanced revision tracking",
      "Detailed plagiarism reports",
      "Dedicated account manager",
      "Early access to features",
    ],
  },
];

/**
 * Popular universities for dropdown
 * Used in academic info forms for quick selection
 */
export const popularUniversities: UniversityOption[] = [
  { id: "uni_stanford", name: "Stanford University", country: "USA" },
  { id: "uni_mit", name: "MIT", country: "USA" },
  { id: "uni_harvard", name: "Harvard University", country: "USA" },
  { id: "uni_berkeley", name: "UC Berkeley", country: "USA" },
  { id: "uni_ucla", name: "UCLA", country: "USA" },
  { id: "uni_columbia", name: "Columbia University", country: "USA" },
  { id: "uni_yale", name: "Yale University", country: "USA" },
  { id: "uni_princeton", name: "Princeton University", country: "USA" },
  { id: "uni_cornell", name: "Cornell University", country: "USA" },
  { id: "uni_upenn", name: "University of Pennsylvania", country: "USA" },
  { id: "uni_usc", name: "University of Southern California", country: "USA" },
  { id: "uni_nyu", name: "New York University", country: "USA" },
  { id: "uni_umich", name: "University of Michigan", country: "USA" },
  { id: "uni_uchicago", name: "University of Chicago", country: "USA" },
  { id: "uni_oxford", name: "Oxford University", country: "UK" },
  { id: "uni_cambridge", name: "Cambridge University", country: "UK" },
  { id: "uni_other", name: "Other", country: "" },
];

/**
 * Common majors list
 * Used for major/field of study selection
 */
export const commonMajors: string[] = [
  "Computer Science",
  "Business Administration",
  "Engineering",
  "Psychology",
  "Biology",
  "Economics",
  "English Literature",
  "Political Science",
  "Mathematics",
  "Chemistry",
  "Physics",
  "History",
  "Sociology",
  "Communications",
  "Nursing",
  "Pre-Med",
  "Pre-Law",
  "Finance",
  "Marketing",
  "Graphic Design",
  "Architecture",
  "Education",
  "Philosophy",
  "Art History",
  "Music",
  "Other",
];

/**
 * Year level options
 * Academic year/level selection
 */
export const yearLevelOptions: { value: YearLevel; label: string }[] = [
  { value: "freshman", label: "Freshman (1st Year)" },
  { value: "sophomore", label: "Sophomore (2nd Year)" },
  { value: "junior", label: "Junior (3rd Year)" },
  { value: "senior", label: "Senior (4th Year)" },
  { value: "graduate", label: "Graduate Student" },
  { value: "postgraduate", label: "Postgraduate/PhD" },
];

/**
 * Language options
 * UI language preferences
 */
export const languageOptions = [
  { value: "en", label: "English", flag: "US" },
  { value: "es", label: "Espanol", flag: "ES" },
  { value: "fr", label: "Francais", flag: "FR" },
];

/**
 * Theme options
 * UI theme preferences
 */
export const themeOptions = [
  { value: "light", label: "Light", icon: "sun" },
  { value: "dark", label: "Dark", icon: "moon" },
  { value: "system", label: "System", icon: "monitor" },
];
