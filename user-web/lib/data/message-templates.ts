import {
  Clock,
  UserX,
  Moon,
  Wrench,
  MapPin,
  AlertCircle,
  Server,
  Calendar,
  type LucideIcon,
} from "lucide-react";

/**
 * Action button configuration for unavailability templates.
 */
export interface TemplateAction {
  /** Display text for the action button */
  text: string;
  /** Action identifier for handling the button click */
  action: string;
  /** Optional variant for button styling */
  variant?: "primary" | "secondary" | "outline";
}

/**
 * Base unavailability template interface.
 * All templates conform to this structure.
 */
export interface UnavailabilityTemplateConfig {
  /** Unique template identifier */
  id: string;
  /** Title displayed at the top of the message */
  title: string;
  /** Main message body (supports {variable} placeholders) */
  message: string;
  /** Lucide icon component to display */
  icon: LucideIcon;
  /** Optional single action button text */
  actionText?: string;
  /** Optional link for single action button */
  actionLink?: string;
  /** Optional array of action buttons */
  actions?: TemplateAction[];
  /** Service hours display string */
  serviceHours?: string;
  /** Whether to show a countdown timer */
  showCountdown?: boolean;
  /** Whether to show an email input field */
  showEmailInput?: boolean;
  /** Optional estimated completion/availability time */
  estimatedTime?: string;
  /** Icon color variant */
  iconVariant?: "default" | "warning" | "error" | "success" | "info";
}

/**
 * Pre-drafted unavailability response templates.
 *
 * These templates provide consistent messaging when services,
 * experts, or features are temporarily unavailable.
 *
 * @example
 * ```tsx
 * import { unavailabilityTemplates, getTemplate } from "@/lib/data/message-templates";
 *
 * // Get a template with variable substitution
 * const template = getTemplate("expertUnavailable", {
 *   expertName: "Dr. Smith",
 *   estimatedDate: "January 30, 2026"
 * });
 * ```
 */
export const unavailabilityTemplates: Record<string, UnavailabilityTemplateConfig> = {
  /**
   * Template for when a service has reached its capacity limit.
   * Suggests browsing alternative services.
   */
  serviceAtCapacity: {
    id: "service_at_capacity",
    title: "Service at Capacity",
    message: `Thank you for your interest! This service is currently at capacity and we're working hard to accommodate more requests.

We'll notify you as soon as it becomes available. In the meantime, you might be interested in our other services that can help with your project.`,
    icon: Clock,
    iconVariant: "warning",
    actionText: "Browse Other Services",
    actionLink: "/home",
  },

  /**
   * Template for when a specific expert is not available.
   * Provides options to find similar experts or get notified.
   */
  expertUnavailable: {
    id: "expert_unavailable",
    title: "Expert Currently Unavailable",
    message: `{expertName} is currently not accepting new projects due to high demand.

You can:
- Wait for their availability (estimated: {estimatedDate})
- Let us match you with another equally qualified expert
- Save their profile to be notified when available`,
    icon: UserX,
    iconVariant: "info",
    actions: [
      { text: "Find Similar Expert", action: "find_similar", variant: "primary" },
      { text: "Get Notified", action: "notify_available", variant: "outline" },
    ],
  },

  /**
   * Template for outside of service hours.
   * Shows countdown to when service resumes.
   */
  outsideServiceHours: {
    id: "outside_hours",
    title: "Outside Service Hours",
    message: `Our team is currently outside service hours (9 AM - 9 PM IST).

Your request has been saved and we'll respond first thing tomorrow. For urgent queries, please use our emergency support line.`,
    icon: Moon,
    iconVariant: "default",
    serviceHours: "9:00 AM - 9:00 PM IST",
    actionText: "Emergency Support",
    showCountdown: true,
  },

  /**
   * Template for scheduled maintenance periods.
   * Shows estimated completion time.
   */
  maintenanceMode: {
    id: "maintenance",
    title: "Scheduled Maintenance",
    message: `We're currently performing scheduled maintenance to improve your experience.

Expected completion: {completionTime}

We apologize for any inconvenience.`,
    icon: Wrench,
    iconVariant: "warning",
    showCountdown: true,
  },

  /**
   * Template for when a service is not available in user's region.
   * Collects email for regional expansion notifications.
   */
  regionNotSupported: {
    id: "region_not_supported",
    title: "Service Not Available in Your Region",
    message: `We're sorry, but this service is not yet available in your region.

We're expanding rapidly and hope to serve your area soon. Please enter your email to be notified when we launch in your region.`,
    icon: MapPin,
    iconVariant: "info",
    showEmailInput: true,
    actionText: "Notify Me",
  },

  /**
   * Template for high demand periods with queue functionality.
   */
  highDemand: {
    id: "high_demand",
    title: "High Demand Period",
    message: `We're experiencing higher than usual demand right now.

Your request has been added to our priority queue. Expected wait time: {waitTime}

You'll receive a notification when we're ready to assist you.`,
    icon: AlertCircle,
    iconVariant: "warning",
    showCountdown: true,
    actions: [
      { text: "Stay in Queue", action: "stay_in_queue", variant: "primary" },
      { text: "Cancel Request", action: "cancel_request", variant: "outline" },
    ],
  },

  /**
   * Template for server or connectivity issues.
   */
  serverIssue: {
    id: "server_issue",
    title: "Connection Issue",
    message: `We're having trouble connecting to our servers. This is usually temporary and resolves within a few minutes.

Please try again shortly. If the problem persists, our team has been notified and is working on it.`,
    icon: Server,
    iconVariant: "error",
    actionText: "Try Again",
    actions: [
      { text: "Retry Connection", action: "retry", variant: "primary" },
      { text: "Contact Support", action: "contact_support", variant: "outline" },
    ],
  },

  /**
   * Template for booking/scheduling conflicts.
   */
  slotUnavailable: {
    id: "slot_unavailable",
    title: "Time Slot No Longer Available",
    message: `The time slot you selected has just been booked by another user.

Please choose a different time slot from the available options below.`,
    icon: Calendar,
    iconVariant: "warning",
    actionText: "View Available Slots",
    actionLink: "/schedule",
  },

  /**
   * Template for feature temporarily disabled.
   */
  featureDisabled: {
    id: "feature_disabled",
    title: "Feature Temporarily Unavailable",
    message: `This feature is temporarily disabled while we make improvements.

We expect it to be back online soon. Thank you for your patience!`,
    icon: Wrench,
    iconVariant: "info",
    showCountdown: true,
    estimatedTime: "{estimatedTime}",
  },
};

/**
 * Type representing all available template keys.
 */
export type UnavailabilityTemplateType = keyof typeof unavailabilityTemplates;

/**
 * Get an unavailability template with variable substitution.
 *
 * @param type - The template type to retrieve
 * @param variables - Optional object of variables to substitute in the message
 * @returns The template config with variables replaced in the message
 *
 * @example
 * ```tsx
 * const template = getTemplate("expertUnavailable", {
 *   expertName: "Dr. Sarah Johnson",
 *   estimatedDate: "February 1, 2026"
 * });
 * // template.message will have {expertName} and {estimatedDate} replaced
 * ```
 */
export function getTemplate(
  type: UnavailabilityTemplateType,
  variables?: Record<string, string>
): UnavailabilityTemplateConfig {
  const template = unavailabilityTemplates[type];

  if (!template) {
    throw new Error(`Unknown unavailability template type: ${type}`);
  }

  let message = template.message;

  // Replace all variables in the message
  if (variables) {
    Object.entries(variables).forEach(([key, value]) => {
      message = message.replace(new RegExp(`\\{${key}\\}`, "g"), value);
    });
  }

  return { ...template, message };
}

/**
 * Get the appropriate icon color class based on variant.
 *
 * @param variant - The icon variant type
 * @returns Tailwind CSS classes for the icon color
 */
export function getIconColorClass(
  variant?: UnavailabilityTemplateConfig["iconVariant"]
): string {
  switch (variant) {
    case "warning":
      return "text-amber-500 dark:text-amber-400";
    case "error":
      return "text-red-500 dark:text-red-400";
    case "success":
      return "text-green-500 dark:text-green-400";
    case "info":
      return "text-blue-500 dark:text-blue-400";
    default:
      return "text-primary";
  }
}

/**
 * Get the appropriate background color class based on variant.
 *
 * @param variant - The icon variant type
 * @returns Tailwind CSS classes for the background color
 */
export function getIconBgClass(
  variant?: UnavailabilityTemplateConfig["iconVariant"]
): string {
  switch (variant) {
    case "warning":
      return "bg-amber-100 dark:bg-amber-900/30";
    case "error":
      return "bg-red-100 dark:bg-red-900/30";
    case "success":
      return "bg-green-100 dark:bg-green-900/30";
    case "info":
      return "bg-blue-100 dark:bg-blue-900/30";
    default:
      return "bg-primary/10";
  }
}

/**
 * Calculate countdown time until a target date/time.
 *
 * @param targetTime - Target datetime string or Date object
 * @returns Object with hours, minutes, and seconds remaining
 */
export function calculateCountdown(targetTime: string | Date): {
  hours: number;
  minutes: number;
  seconds: number;
  isExpired: boolean;
} {
  const target = new Date(targetTime);
  const now = new Date();
  const diff = target.getTime() - now.getTime();

  if (diff <= 0) {
    return { hours: 0, minutes: 0, seconds: 0, isExpired: true };
  }

  const hours = Math.floor(diff / (1000 * 60 * 60));
  const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
  const seconds = Math.floor((diff % (1000 * 60)) / 1000);

  return { hours, minutes, seconds, isExpired: false };
}

/**
 * Calculate time until next service hours start.
 * Assumes service hours are 9 AM - 9 PM IST.
 *
 * @returns Object with countdown to next service start
 */
export function getTimeToServiceStart(): {
  hours: number;
  minutes: number;
  isWithinServiceHours: boolean;
} {
  const now = new Date();
  // Convert to IST (UTC+5:30)
  const istOffset = 5.5 * 60 * 60 * 1000;
  const istTime = new Date(now.getTime() + istOffset);
  const currentHour = istTime.getUTCHours();
  const currentMinute = istTime.getUTCMinutes();

  // Service hours: 9 AM - 9 PM IST
  const serviceStart = 9;
  const serviceEnd = 21;

  if (currentHour >= serviceStart && currentHour < serviceEnd) {
    return { hours: 0, minutes: 0, isWithinServiceHours: true };
  }

  // Calculate hours until 9 AM
  let hoursUntilOpen: number;
  if (currentHour >= serviceEnd) {
    // After 9 PM, until midnight + until 9 AM
    hoursUntilOpen = (24 - currentHour) + serviceStart;
  } else {
    // Before 9 AM
    hoursUntilOpen = serviceStart - currentHour;
  }

  // Adjust for current minutes
  let minutesRemaining = 60 - currentMinute;
  if (minutesRemaining === 60) {
    minutesRemaining = 0;
  } else {
    hoursUntilOpen -= 1;
  }

  return {
    hours: hoursUntilOpen,
    minutes: minutesRemaining,
    isWithinServiceHours: false,
  };
}
