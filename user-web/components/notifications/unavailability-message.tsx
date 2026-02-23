"use client";

import { useState, useEffect, useCallback } from "react";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  type UnavailabilityTemplateConfig,
  type UnavailabilityTemplateType,
  getTemplate,
  getIconColorClass,
  getIconBgClass,
  getTimeToServiceStart,
  calculateCountdown,
} from "@/lib/data/message-templates";
import { Mail, ArrowRight, Loader2 } from "lucide-react";

/**
 * Props for the UnavailabilityMessage component.
 */
interface UnavailabilityMessageProps {
  /** Template type or custom template configuration */
  template: UnavailabilityTemplateType | UnavailabilityTemplateConfig;
  /** Variables to substitute in the template message */
  variables?: Record<string, string>;
  /** Target time for countdown (ISO string or Date) */
  countdownTarget?: string | Date;
  /** Callback when an action button is clicked */
  onAction?: (action: string) => void;
  /** Callback when email is submitted */
  onEmailSubmit?: (email: string) => Promise<void>;
  /** Additional CSS classes */
  className?: string;
  /** Whether to use compact layout */
  compact?: boolean;
}

/**
 * Countdown timer display component.
 */
function CountdownTimer({
  targetTime,
  useServiceHours = false,
}: {
  targetTime?: string | Date;
  useServiceHours?: boolean;
}) {
  const [countdown, setCountdown] = useState<{
    hours: number;
    minutes: number;
    seconds?: number;
  }>({ hours: 0, minutes: 0 });

  useEffect(() => {
    const updateCountdown = () => {
      if (useServiceHours) {
        const serviceTime = getTimeToServiceStart();
        if (!serviceTime.isWithinServiceHours) {
          setCountdown({
            hours: serviceTime.hours,
            minutes: serviceTime.minutes,
          });
        }
      } else if (targetTime) {
        const remaining = calculateCountdown(targetTime);
        if (!remaining.isExpired) {
          setCountdown({
            hours: remaining.hours,
            minutes: remaining.minutes,
            seconds: remaining.seconds,
          });
        }
      }
    };

    updateCountdown();
    const interval = setInterval(updateCountdown, 1000);
    return () => clearInterval(interval);
  }, [targetTime, useServiceHours]);

  const formatNumber = (n: number) => n.toString().padStart(2, "0");

  return (
    <div className="flex items-center justify-center gap-2 mt-4">
      <div className="flex flex-col items-center">
        <span className="text-2xl font-bold text-foreground">
          {formatNumber(countdown.hours)}
        </span>
        <span className="text-xs text-muted-foreground uppercase">Hours</span>
      </div>
      <span className="text-2xl font-bold text-muted-foreground">:</span>
      <div className="flex flex-col items-center">
        <span className="text-2xl font-bold text-foreground">
          {formatNumber(countdown.minutes)}
        </span>
        <span className="text-xs text-muted-foreground uppercase">Minutes</span>
      </div>
      {countdown.seconds !== undefined && (
        <>
          <span className="text-2xl font-bold text-muted-foreground">:</span>
          <div className="flex flex-col items-center">
            <span className="text-2xl font-bold text-foreground">
              {formatNumber(countdown.seconds)}
            </span>
            <span className="text-xs text-muted-foreground uppercase">Seconds</span>
          </div>
        </>
      )}
    </div>
  );
}

/**
 * Email notification signup form.
 */
function EmailSignupForm({
  onSubmit,
  buttonText = "Notify Me",
}: {
  onSubmit: (email: string) => Promise<void>;
  buttonText?: string;
}) {
  const [email, setEmail] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSubmitted, setIsSubmitted] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    // Basic email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      setError("Please enter a valid email address");
      return;
    }

    setIsSubmitting(true);
    try {
      await onSubmit(email);
      setIsSubmitted(true);
    } catch (err) {
      setError("Failed to subscribe. Please try again.");
    } finally {
      setIsSubmitting(false);
    }
  };

  if (isSubmitted) {
    return (
      <div className="mt-4 p-3 bg-green-50 dark:bg-green-900/20 rounded-lg border border-green-200 dark:border-green-800">
        <p className="text-sm text-green-700 dark:text-green-400 text-center">
          You&apos;ll be notified when this becomes available!
        </p>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="mt-4 space-y-3">
      <div className="flex gap-2">
        <div className="relative flex-1">
          <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <Input
            type="email"
            placeholder="Enter your email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            className="pl-10"
            disabled={isSubmitting}
          />
        </div>
        <Button type="submit" disabled={isSubmitting || !email}>
          {isSubmitting ? (
            <Loader2 className="h-4 w-4 animate-spin" />
          ) : (
            buttonText
          )}
        </Button>
      </div>
      {error && (
        <p className="text-sm text-red-500 dark:text-red-400">{error}</p>
      )}
    </form>
  );
}

/**
 * UnavailabilityMessage component displays pre-drafted unavailability
 * response messages with consistent styling and interactive elements.
 *
 * Supports various unavailability scenarios including:
 * - Service at capacity
 * - Expert unavailable
 * - Outside service hours (with countdown)
 * - Maintenance mode
 * - Region not supported
 *
 * @example
 * ```tsx
 * <UnavailabilityMessage
 *   template="expertUnavailable"
 *   variables={{
 *     expertName: "Dr. Sarah Johnson",
 *     estimatedDate: "February 1, 2026"
 *   }}
 *   onAction={(action) => {
 *     if (action === "find_similar") {
 *       router.push("/experts");
 *     }
 *   }}
 * />
 * ```
 */
export function UnavailabilityMessage({
  template,
  variables,
  countdownTarget,
  onAction,
  onEmailSubmit,
  className,
  compact = false,
}: UnavailabilityMessageProps) {
  // Resolve template configuration
  const config: UnavailabilityTemplateConfig =
    typeof template === "string"
      ? getTemplate(template, variables)
      : template;

  const {
    title,
    message,
    icon: Icon,
    iconVariant,
    actionText,
    actionLink,
    actions,
    serviceHours,
    showCountdown,
    showEmailInput,
  } = config;

  // Handle action button click
  const handleAction = useCallback(
    (action: string) => {
      if (onAction) {
        onAction(action);
      }
    },
    [onAction]
  );

  // Handle single action click (link or callback)
  const handlePrimaryAction = useCallback(() => {
    if (actionLink) {
      window.location.href = actionLink;
    } else if (actionText) {
      handleAction(actionText.toLowerCase().replace(/\s+/g, "_"));
    }
  }, [actionLink, actionText, handleAction]);

  // Parse message into paragraphs and bullet points
  const renderMessage = (text: string) => {
    const lines = text.split("\n").filter((line) => line.trim());

    return lines.map((line, index) => {
      const trimmed = line.trim();

      // Check for bullet points
      if (trimmed.startsWith("-") || trimmed.startsWith("*")) {
        const bulletText = trimmed.substring(1).trim();
        return (
          <li key={index} className="text-sm text-muted-foreground ml-4">
            {bulletText}
          </li>
        );
      }

      return (
        <p key={index} className="text-sm text-muted-foreground">
          {trimmed}
        </p>
      );
    });
  };

  // Check if any lines are bullet points
  const hasBulletPoints = message.includes("\n-") || message.includes("\n*");

  return (
    <Card
      className={cn(
        "overflow-hidden transition-all duration-200",
        "bg-white/80 dark:bg-gray-900/80 backdrop-blur-xl",
        "border border-white/20 dark:border-gray-800/50",
        "shadow-lg shadow-black/5",
        compact ? "max-w-sm" : "max-w-md",
        className
      )}
    >
      <CardHeader className={cn("space-y-3", compact && "pb-3")}>
        {/* Icon */}
        <div className="flex justify-center">
          <div
            className={cn(
              "rounded-full p-4",
              getIconBgClass(iconVariant)
            )}
          >
            <Icon
              className={cn("h-8 w-8", getIconColorClass(iconVariant))}
              strokeWidth={1.5}
            />
          </div>
        </div>

        {/* Title */}
        <CardTitle className="text-center text-lg font-semibold">
          {title}
        </CardTitle>
      </CardHeader>

      <CardContent className={cn("space-y-4", compact && "pt-0")}>
        {/* Message */}
        <div className={cn("space-y-2", hasBulletPoints && "space-y-1")}>
          {hasBulletPoints ? (
            <ul className="space-y-1 list-disc">{renderMessage(message)}</ul>
          ) : (
            renderMessage(message)
          )}
        </div>

        {/* Service Hours Badge */}
        {serviceHours && (
          <div className="flex justify-center">
            <span className="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-primary/10 text-primary">
              Service Hours: {serviceHours}
            </span>
          </div>
        )}

        {/* Countdown Timer */}
        {showCountdown && (
          <CountdownTimer
            targetTime={countdownTarget}
            useServiceHours={!countdownTarget && !!serviceHours}
          />
        )}

        {/* Email Input */}
        {showEmailInput && onEmailSubmit && (
          <EmailSignupForm
            onSubmit={onEmailSubmit}
            buttonText={actionText}
          />
        )}

        {/* Action Buttons */}
        {!showEmailInput && (
          <div className="flex flex-col gap-2 pt-2">
            {/* Multiple actions */}
            {actions && actions.length > 0 ? (
              <div className="flex flex-col sm:flex-row gap-2">
                {actions.map((action, index) => (
                  <Button
                    key={action.action}
                    variant={
                      action.variant === "primary"
                        ? "default"
                        : action.variant === "outline"
                          ? "outline"
                          : "secondary"
                    }
                    className={cn(
                      "flex-1",
                      action.variant === "primary" &&
                        "bg-primary hover:bg-primary/90"
                    )}
                    onClick={() => handleAction(action.action)}
                  >
                    {action.text}
                    {index === 0 && (
                      <ArrowRight className="ml-2 h-4 w-4" />
                    )}
                  </Button>
                ))}
              </div>
            ) : (
              /* Single action */
              actionText &&
              !showEmailInput && (
                <Button
                  className="w-full bg-primary hover:bg-primary/90"
                  onClick={handlePrimaryAction}
                >
                  {actionText}
                  <ArrowRight className="ml-2 h-4 w-4" />
                </Button>
              )
            )}
          </div>
        )}
      </CardContent>
    </Card>
  );
}

/**
 * Inline variant of the unavailability message for use in lists/cards.
 */
export function UnavailabilityBanner({
  template,
  variables,
  onAction,
  className,
}: Pick<
  UnavailabilityMessageProps,
  "template" | "variables" | "onAction" | "className"
>) {
  const config: UnavailabilityTemplateConfig =
    typeof template === "string"
      ? getTemplate(template, variables)
      : template;

  const { title, message, icon: Icon, iconVariant, actionText } = config;

  // Get first paragraph only for banner
  const shortMessage = message.split("\n")[0];

  return (
    <div
      className={cn(
        "flex items-start gap-3 p-4 rounded-lg",
        "bg-amber-50 dark:bg-amber-900/20",
        "border border-amber-200 dark:border-amber-800",
        className
      )}
    >
      <div
        className={cn(
          "shrink-0 rounded-full p-2",
          getIconBgClass(iconVariant)
        )}
      >
        <Icon className={cn("h-5 w-5", getIconColorClass(iconVariant))} />
      </div>

      <div className="flex-1 min-w-0">
        <p className="text-sm font-medium text-foreground">{title}</p>
        <p className="text-sm text-muted-foreground mt-0.5 line-clamp-2">
          {shortMessage}
        </p>
      </div>

      {actionText && onAction && (
        <Button
          variant="ghost"
          size="sm"
          className="shrink-0"
          onClick={() => onAction("primary_action")}
        >
          {actionText}
        </Button>
      )}
    </div>
  );
}

export default UnavailabilityMessage;
