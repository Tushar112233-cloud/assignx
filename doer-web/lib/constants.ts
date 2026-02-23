/**
 * Application constants for Doer Web
 */

/** App name and branding */
export const APP_NAME = 'DOER'
export const APP_TAGLINE = 'Your Skills, Your Earnings'
export const POWERED_BY = 'Powered by AssignX'

/** Theme colors */
export const THEME_COLORS = {
  primary: '#1E3A5F', // Dark Blue
  accent: '#3B82F6', // Professional Blue
  background: {
    light: '#F8FAFC', // Slate Grey
    dark: '#0F172A',
  },
} as const

/** Onboarding slides content */
export const ONBOARDING_SLIDES = [
  {
    id: 1,
    title: 'Countless Opportunities',
    description: 'Discover countless opportunities in your field of expertise',
    image: '/images/onboarding/opportunity.svg',
  },
  {
    id: 2,
    title: 'Small Tasks, Big Rewards',
    description: 'Complete small tasks and earn big rewards consistently',
    image: '/images/onboarding/rewards.svg',
  },
  {
    id: 3,
    title: 'Supervisor Support (24x7)',
    description: 'Get round-the-clock support from dedicated supervisors',
    image: '/images/onboarding/support.svg',
  },
  {
    id: 4,
    title: 'Practical Learning',
    description: 'Practical learning with part-time earning opportunities',
    image: '/images/onboarding/learning.svg',
  },
] as const

/** Qualification options */
export const QUALIFICATION_OPTIONS = [
  { value: 'high_school', label: 'High School' },
  { value: 'undergraduate', label: 'Undergraduate' },
  { value: 'postgraduate', label: 'Post Graduate' },
  { value: 'phd', label: 'PhD' },
] as const

/** Experience level options */
export const EXPERIENCE_LEVELS = [
  { value: 'beginner', label: 'Beginner', description: '0-1 years' },
  { value: 'intermediate', label: 'Intermediate', description: '1-3 years' },
  { value: 'pro', label: 'Professional', description: '3+ years' },
] as const

/** Password requirements */
export const PASSWORD_MIN_LENGTH = 8
export const PASSWORD_REQUIREMENTS = [
  'At least 8 characters',
  'At least one uppercase letter',
  'At least one lowercase letter',
  'At least one number',
] as const

/** OTP settings */
export const OTP_LENGTH = 6
export const OTP_EXPIRY_SECONDS = 300 // 5 minutes

/** API endpoints */
export const API_ROUTES = {
  auth: {
    login: '/api/auth/login',
    register: '/api/auth/register',
    verifyOtp: '/api/auth/verify-otp',
    logout: '/api/auth/logout',
  },
  doer: {
    profile: '/api/doer/profile',
    skills: '/api/doer/skills',
    activation: '/api/doer/activation',
  },
} as const

/** Route paths */
export const ROUTES = {
  home: '/',
  login: '/login',
  register: '/register',
  welcome: '/welcome',
  profileSetup: '/profile-setup',
  dashboard: '/dashboard',
  projects: '/projects',
  statistics: '/statistics',
  resources: '/resources',
  profile: '/profile',
  training: '/training',
  quiz: '/quiz',
  bankDetails: '/bank-details',
} as const

/** Activation steps configuration */
export const ACTIVATION_STEPS = [
  {
    id: 1,
    title: 'Complete Training',
    description: 'Watch training videos and learn quality standards',
    route: '/training',
    icon: 'play-circle',
  },
  {
    id: 2,
    title: 'Pass Quiz',
    description: 'Answer questions to verify your understanding',
    route: '/quiz',
    icon: 'clipboard-check',
  },
  {
    id: 3,
    title: 'Add Bank Details',
    description: 'Set up your payment information',
    route: '/bank-details',
    icon: 'credit-card',
  },
] as const

/** Quiz settings */
export const QUIZ_SETTINGS = {
  passingScore: 80,
  maxAttempts: 3,
} as const

/** IFSC code regex pattern */
export const IFSC_REGEX = /^[A-Z]{4}0[A-Z0-9]{6}$/

/** UPI ID regex pattern */
export const UPI_REGEX = /^[\w.-]+@[\w.-]+$/
