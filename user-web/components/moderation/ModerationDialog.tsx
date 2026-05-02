'use client';

/**
 * Moderation Dialog Component
 *
 * Shows a dialog when content moderation detects personal information
 * sharing attempts. Provides user-friendly feedback about violations.
 */

import * as React from 'react';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Alert, AlertDescription } from '@/components/ui/alert';
import {
  AlertTriangle,
  Ban,
  Info,
  Phone,
  Mail,
  AtSign,
  MapPin,
  Link2,
  MessageCircle,
} from 'lucide-react';
import { cn } from '@/lib/utils';
import type {
  ModerationResult,
  ViolationType,
} from '@/lib/validations/chat-content';
import type { UserViolationSummary } from '@/lib/services/moderation.service';

// =============================================================================
// TYPES
// =============================================================================

interface ModerationDialogProps {
  /** Whether the dialog is open */
  open: boolean;
  /** Callback when dialog open state changes */
  onOpenChange: (open: boolean) => void;
  /** The moderation result */
  result: ModerationResult;
  /** Optional user violation summary */
  userSummary?: UserViolationSummary;
  /** Callback when user wants to edit their message */
  onEdit?: () => void;
  /** Callback when user dismisses the dialog */
  onDismiss?: () => void;
}

interface ModerationWarningBannerProps {
  /** The moderation result */
  result: ModerationResult;
  /** Whether to show in compact mode */
  compact?: boolean;
  /** Additional class names */
  className?: string;
}

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

const getSeverityConfig = (severity: ModerationResult['severity']) => {
  switch (severity) {
    case 'high':
      return {
        icon: Ban,
        color: 'text-red-500',
        bgColor: 'bg-red-50 dark:bg-red-950/30',
        borderColor: 'border-red-200 dark:border-red-900',
        title: 'Message Blocked',
      };
    case 'medium':
      return {
        icon: AlertTriangle,
        color: 'text-orange-500',
        bgColor: 'bg-orange-50 dark:bg-orange-950/30',
        borderColor: 'border-orange-200 dark:border-orange-900',
        title: 'Content Not Allowed',
      };
    case 'low':
    default:
      return {
        icon: Info,
        color: 'text-amber-500',
        bgColor: 'bg-amber-50 dark:bg-amber-950/30',
        borderColor: 'border-amber-200 dark:border-amber-900',
        title: 'Personal Info Detected',
      };
  }
};

const getViolationIcon = (type: ViolationType) => {
  const icons: Record<ViolationType, React.ElementType> = {
    phone: Phone,
    email: Mail,
    social_media: AtSign,
    address: MapPin,
    link: Link2,
    messaging_app: MessageCircle,
  };
  return icons[type] || Info;
};

const getViolationLabel = (type: ViolationType) => {
  const labels: Record<ViolationType, string> = {
    phone: 'Phone Number',
    email: 'Email Address',
    social_media: 'Social Media',
    address: 'Address',
    link: 'External Link',
    messaging_app: 'Messaging App',
  };
  return labels[type] || type;
};

const getWarningLevelConfig = (level: UserViolationSummary['warningLevel']) => {
  switch (level) {
    case 'final':
      return {
        label: 'Final Warning',
        color: 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200',
      };
    case 'second':
      return {
        label: 'Second Warning',
        color: 'bg-orange-100 text-orange-800 dark:bg-orange-900 dark:text-orange-200',
      };
    case 'first':
      return {
        label: 'First Warning',
        color: 'bg-amber-100 text-amber-800 dark:bg-amber-900 dark:text-amber-200',
      };
    default:
      return {
        label: 'Warning',
        color: 'bg-gray-100 text-gray-800 dark:bg-gray-800 dark:text-gray-200',
      };
  }
};

// =============================================================================
// MAIN DIALOG COMPONENT
// =============================================================================

/**
 * Dialog shown when content moderation blocks a message
 */
export function ModerationDialog({
  open,
  onOpenChange,
  result,
  userSummary,
  onEdit,
  onDismiss,
}: ModerationDialogProps) {
  const severityConfig = getSeverityConfig(result.severity);
  const Icon = severityConfig.icon;

  // Get unique violation types
  const violationTypes = [...new Set(result.violations.map((v) => v.type))];

  const handleDismiss = () => {
    onOpenChange(false);
    onDismiss?.();
  };

  const handleEdit = () => {
    onOpenChange(false);
    onEdit?.();
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-md" showCloseButton={false}>
        <DialogHeader className="items-center text-center">
          {/* Icon */}
          <div
            className={cn(
              'mb-2 flex h-16 w-16 items-center justify-center rounded-full',
              severityConfig.bgColor
            )}
          >
            <Icon className={cn('h-8 w-8', severityConfig.color)} />
          </div>

          <DialogTitle className={severityConfig.color}>
            {severityConfig.title}
          </DialogTitle>

          <DialogDescription className="text-center">
            {result.message}
          </DialogDescription>
        </DialogHeader>

        {/* Violations List */}
        {violationTypes.length > 0 && (
          <div
            className={cn(
              'rounded-lg border p-3',
              severityConfig.bgColor,
              severityConfig.borderColor
            )}
          >
            <p className="mb-2 text-xs font-medium text-muted-foreground">
              Detected:
            </p>
            <div className="flex flex-wrap gap-2">
              {violationTypes.map((type) => {
                const ViolationIcon = getViolationIcon(type);
                return (
                  <Badge
                    key={type}
                    variant="outline"
                    className={cn(
                      'gap-1.5',
                      severityConfig.borderColor,
                      severityConfig.color
                    )}
                  >
                    <ViolationIcon className="h-3 w-3" />
                    {getViolationLabel(type)}
                  </Badge>
                );
              })}
            </div>
          </div>
        )}

        {/* Warning Level Indicator */}
        {userSummary && userSummary.warningLevel !== 'none' && (
          <Alert
            className={cn(
              'border',
              getWarningLevelConfig(userSummary.warningLevel).color
            )}
          >
            <AlertTriangle className="h-4 w-4" />
            <AlertDescription className="flex items-center gap-2">
              <span className="font-medium">
                {getWarningLevelConfig(userSummary.warningLevel).label}
              </span>
              {userSummary.totalViolations > 0 && (
                <Badge variant="secondary" className="text-xs">
                  {userSummary.totalViolations} total violations
                </Badge>
              )}
            </AlertDescription>
          </Alert>
        )}

        <DialogFooter className="gap-2 sm:gap-2">
          <Button
            variant="outline"
            onClick={handleEdit}
            className="flex-1 sm:flex-none"
          >
            Edit Message
          </Button>
          <Button onClick={handleDismiss} className="flex-1 sm:flex-none">
            OK, Got it
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

// =============================================================================
// WARNING BANNER COMPONENT
// =============================================================================

/**
 * Inline warning banner for showing moderation feedback while typing
 */
export function ModerationWarningBanner({
  result,
  compact = false,
  className,
}: ModerationWarningBannerProps) {
  if (result.allowed) return null;

  const severityConfig = getSeverityConfig(result.severity);
  const violationTypes = [...new Set(result.violations.map((v) => v.type))];
  const Icon = severityConfig.icon;

  if (compact) {
    return (
      <div
        className={cn(
          'flex items-center gap-2 rounded-md px-3 py-1.5 text-sm',
          severityConfig.bgColor,
          className
        )}
      >
        <Icon className={cn('h-4 w-4 shrink-0', severityConfig.color)} />
        <span className={cn('truncate', severityConfig.color)}>
          Contains {violationTypes.map(getViolationLabel).join(', ')}
        </span>
      </div>
    );
  }

  return (
    <div
      className={cn(
        'flex items-start gap-3 rounded-lg border p-3',
        severityConfig.bgColor,
        severityConfig.borderColor,
        className
      )}
    >
      <Icon className={cn('mt-0.5 h-5 w-5 shrink-0', severityConfig.color)} />
      <div className="flex-1 space-y-1">
        <p className={cn('text-sm font-medium', severityConfig.color)}>
          Personal info detected
        </p>
        <p className="text-sm text-muted-foreground">{result.message}</p>
      </div>
    </div>
  );
}

// =============================================================================
// RATE LIMITED OVERLAY COMPONENT
// =============================================================================

interface RateLimitedOverlayProps {
  /** Whether the overlay is visible */
  visible: boolean;
  /** The user violation summary */
  summary: UserViolationSummary;
  /** Callback when user acknowledges */
  onAcknowledge?: () => void;
}

/**
 * Full-screen overlay shown when user is rate limited
 */
export function RateLimitedOverlay({
  visible,
  summary,
  onAcknowledge,
}: RateLimitedOverlayProps) {
  if (!visible) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm">
      <div className="mx-4 max-w-sm rounded-2xl border bg-background p-8 shadow-2xl">
        <div className="flex flex-col items-center text-center">
          {/* Icon */}
          <div className="mb-6 flex h-20 w-20 items-center justify-center rounded-full bg-red-50 dark:bg-red-950/30">
            <Ban className="h-10 w-10 text-red-500" />
          </div>

          <h2 className="mb-2 text-xl font-bold text-red-500">
            Temporarily Restricted
          </h2>

          <p className="mb-4 text-muted-foreground">
            You have been temporarily restricted from sending messages due to
            repeated policy violations.
          </p>

          <p className="mb-6 text-sm text-muted-foreground/70">
            Please try again later or contact support if you believe this is an
            error.
          </p>

          <Button onClick={onAcknowledge} className="w-full">
            I Understand
          </Button>
        </div>
      </div>
    </div>
  );
}

// =============================================================================
// INPUT INDICATOR COMPONENT
// =============================================================================

interface ModerationInputIndicatorProps {
  /** Whether moderation is checking content */
  isChecking: boolean;
  /** Whether content has violations */
  hasViolation: boolean;
  /** Severity of violations */
  severity?: ModerationResult['severity'];
  /** Additional class names */
  className?: string;
}

/**
 * Small indicator for chat input fields
 */
export function ModerationInputIndicator({
  isChecking,
  hasViolation,
  severity = 'low',
  className,
}: ModerationInputIndicatorProps) {
  if (isChecking) {
    return (
      <div className={cn('flex items-center gap-1.5 text-xs text-muted-foreground', className)}>
        <div className="h-2 w-2 animate-pulse rounded-full bg-muted-foreground" />
        Checking...
      </div>
    );
  }

  if (!hasViolation) return null;

  const severityConfig = getSeverityConfig(severity);
  const Icon = severityConfig.icon;

  return (
    <div className={cn('flex items-center gap-1.5 text-xs', severityConfig.color, className)}>
      <Icon className="h-3 w-3" />
      Personal info detected
    </div>
  );
}
