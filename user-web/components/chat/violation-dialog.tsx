'use client';

import * as React from 'react';
import { AlertTriangle, ShieldAlert, Mail, Phone, AtSign, X } from 'lucide-react';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';

/**
 * Types of policy violations that can be detected
 */
export type ViolationType = 'phone' | 'email' | 'social_media';

/**
 * Props for the ViolationDialog component
 */
export interface ViolationDialogProps {
  /** Whether the dialog is open */
  open: boolean;
  /** Callback when the dialog is closed */
  onClose: () => void;
  /** The type of violation detected */
  violationType: ViolationType;
  /** Callback when user wants to edit their message */
  onEdit: () => void;
  /** Optional custom class name */
  className?: string;
}

/**
 * Configuration for each violation type including icon, title, and description
 */
const violationConfig: Record<
  ViolationType,
  {
    icon: React.ReactNode;
    detectedText: string;
    color: string;
    bgColor: string;
  }
> = {
  phone: {
    icon: <Phone className="w-5 h-5" />,
    detectedText: 'We detected a phone number in your message.',
    color: 'text-amber-600 dark:text-amber-400',
    bgColor: 'bg-amber-50 dark:bg-amber-950/30',
  },
  email: {
    icon: <Mail className="w-5 h-5" />,
    detectedText: 'We detected an email address in your message.',
    color: 'text-amber-600 dark:text-amber-400',
    bgColor: 'bg-amber-50 dark:bg-amber-950/30',
  },
  social_media: {
    icon: <AtSign className="w-5 h-5" />,
    detectedText: 'We detected a social media handle in your message.',
    color: 'text-amber-600 dark:text-amber-400',
    bgColor: 'bg-amber-50 dark:bg-amber-950/30',
  },
};

/**
 * ViolationDialog - A professional dialog that appears when users attempt
 * to share personal contact information in project chats.
 *
 * Features:
 * - Educational, non-accusatory messaging
 * - Clear explanation of why the message was blocked
 * - Options to edit or cancel
 * - Consistent, professional appearance
 *
 * @example
 * ```tsx
 * <ViolationDialog
 *   open={showViolation}
 *   onClose={() => setShowViolation(false)}
 *   violationType="phone"
 *   onEdit={() => {
 *     setShowViolation(false);
 *     inputRef.current?.focus();
 *   }}
 * />
 * ```
 */
export function ViolationDialog({
  open,
  onClose,
  violationType,
  onEdit,
  className,
}: ViolationDialogProps) {
  const config = violationConfig[violationType];

  const handleEdit = React.useCallback(() => {
    onEdit();
    onClose();
  }, [onEdit, onClose]);

  return (
    <Dialog open={open} onOpenChange={(isOpen) => !isOpen && onClose()}>
      <DialogContent
        className={cn(
          'sm:max-w-md',
          'border-amber-200 dark:border-amber-800/50',
          className
        )}
        showCloseButton={false}
      >
        <DialogHeader className="space-y-4">
          {/* Icon Container */}
          <div className="flex justify-center">
            <div
              className={cn(
                'w-16 h-16 rounded-full flex items-center justify-center',
                'bg-gradient-to-br from-amber-100 to-amber-50',
                'dark:from-amber-900/40 dark:to-amber-800/20',
                'border border-amber-200 dark:border-amber-700/50',
                'shadow-lg shadow-amber-500/10'
              )}
            >
              <ShieldAlert className="w-8 h-8 text-amber-500 dark:text-amber-400" />
            </div>
          </div>

          {/* Title */}
          <DialogTitle className="text-xl font-semibold text-center">
            Message Not Sent
          </DialogTitle>

          {/* Main Description */}
          <DialogDescription className="text-center text-base leading-relaxed">
            For your protection and privacy, sharing personal contact information
            is not allowed in project chats. All communication should remain
            within the AssignX platform.
          </DialogDescription>
        </DialogHeader>

        {/* Detection Info Badge */}
        <div
          className={cn(
            'flex items-center gap-3 p-4 rounded-lg mt-2',
            config.bgColor,
            'border border-amber-200/50 dark:border-amber-700/30'
          )}
        >
          <div
            className={cn(
              'flex items-center justify-center w-10 h-10 rounded-full',
              'bg-white dark:bg-amber-900/50',
              'border border-amber-200 dark:border-amber-700/50',
              config.color
            )}
          >
            {config.icon}
          </div>
          <p className={cn('text-sm font-medium', config.color)}>
            {config.detectedText}
          </p>
        </div>

        {/* Privacy Note */}
        <div className="flex items-start gap-2 mt-2 p-3 bg-muted/50 rounded-lg">
          <AlertTriangle className="w-4 h-4 text-muted-foreground mt-0.5 flex-shrink-0" />
          <p className="text-xs text-muted-foreground leading-relaxed">
            This policy helps protect both you and your assigned expert from
            potential risks associated with sharing personal information outside
            the platform.
          </p>
        </div>

        {/* Action Buttons */}
        <DialogFooter className="flex-col sm:flex-row gap-2 mt-4">
          <Button
            variant="outline"
            onClick={onClose}
            className="flex-1 sm:flex-none"
          >
            <X className="w-4 h-4 mr-2" />
            Cancel
          </Button>
          <Button
            onClick={handleEdit}
            className={cn(
              'flex-1 sm:flex-none',
              'bg-gradient-to-r from-[#765341] to-[#9D7B65]',
              'hover:from-[#8D6A58] hover:to-[#B39580]',
              'text-white border-0'
            )}
          >
            Edit Message
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

/**
 * Hook to manage violation dialog state
 *
 * @example
 * ```tsx
 * const { isOpen, violationType, showViolation, closeViolation } = useViolationDialog();
 *
 * // When detecting a violation
 * if (containsPhoneNumber(message)) {
 *   showViolation('phone');
 *   return;
 * }
 *
 * // In your JSX
 * <ViolationDialog
 *   open={isOpen}
 *   violationType={violationType}
 *   onClose={closeViolation}
 *   onEdit={handleEdit}
 * />
 * ```
 */
export function useViolationDialog() {
  const [isOpen, setIsOpen] = React.useState(false);
  const [violationType, setViolationType] = React.useState<ViolationType>('phone');

  const showViolation = React.useCallback((type: ViolationType) => {
    setViolationType(type);
    setIsOpen(true);
  }, []);

  const closeViolation = React.useCallback(() => {
    setIsOpen(false);
  }, []);

  return {
    isOpen,
    violationType,
    showViolation,
    closeViolation,
  };
}

/**
 * Utility function to detect personal information in a message
 *
 * @param message - The message to check
 * @returns The type of violation found, or null if none
 */
export function detectViolation(message: string): ViolationType | null {
  // Phone number patterns (various formats)
  const phonePatterns = [
    /\+?\d{1,4}[-.\s]?\(?\d{1,3}\)?[-.\s]?\d{1,4}[-.\s]?\d{1,4}[-.\s]?\d{1,9}/,
    /\b\d{10,12}\b/,
    /\(\d{3}\)\s*\d{3}[-.\s]?\d{4}/,
  ];

  // Email pattern
  const emailPattern = /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/;

  // Social media patterns
  const socialMediaPatterns = [
    /@[a-zA-Z0-9_]{3,}/,
    /instagram\.com\/[a-zA-Z0-9_.]+/i,
    /twitter\.com\/[a-zA-Z0-9_]+/i,
    /x\.com\/[a-zA-Z0-9_]+/i,
    /facebook\.com\/[a-zA-Z0-9.]+/i,
    /linkedin\.com\/in\/[a-zA-Z0-9-]+/i,
    /wa\.me\/\d+/i,
    /t\.me\/[a-zA-Z0-9_]+/i,
    /telegram\.me\/[a-zA-Z0-9_]+/i,
  ];

  // Check for phone numbers
  for (const pattern of phonePatterns) {
    if (pattern.test(message)) {
      return 'phone';
    }
  }

  // Check for email
  if (emailPattern.test(message)) {
    return 'email';
  }

  // Check for social media
  for (const pattern of socialMediaPatterns) {
    if (pattern.test(message)) {
      return 'social_media';
    }
  }

  return null;
}

export default ViolationDialog;
