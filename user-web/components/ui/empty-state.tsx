"use client";

/**
 * EmptyState - Beautiful empty state component with icon illustrations
 * Modern glassmorphism design with lucide icons
 */

import * as React from "react";
import { motion } from "framer-motion";
import {
  FolderOpen,
  MessageSquare,
  Bell,
  Search,
  AlertTriangle,
  Plus,
} from "lucide-react";

import { cn } from "@/lib/utils";
import { staggerContainer, staggerItem, fadeInScale, springs } from "@/lib/animations/variants";
import { AnimatedButton } from "./animated-button";

export interface EmptyStateProps {
  /** Custom icon component */
  icon?: React.ReactNode;
  /** Main headline */
  title: string;
  /** Supporting description */
  description?: string;
  /** Primary action button */
  primaryAction?: {
    label: string;
    onClick: () => void;
    icon?: React.ReactNode;
  };
  /** Secondary action button/link */
  secondaryAction?: {
    label: string;
    onClick: () => void;
  };
  /** Custom className */
  className?: string;
  /** Size variant */
  size?: "sm" | "default" | "lg";
  /** Icon color class */
  iconColor?: string;
}

const sizeConfig = {
  sm: {
    container: "py-8 px-4",
    iconSize: "w-10 h-10",
    iconWrapper: "p-3",
    title: "text-base",
    description: "text-sm",
  },
  default: {
    container: "py-12 px-6",
    iconSize: "w-12 h-12",
    iconWrapper: "p-4",
    title: "text-lg",
    description: "text-sm",
  },
  lg: {
    container: "py-16 px-8",
    iconSize: "w-16 h-16",
    iconWrapper: "p-5",
    title: "text-xl",
    description: "text-base",
  },
};

export function EmptyState({
  icon,
  title,
  description,
  primaryAction,
  secondaryAction,
  className,
  size = "default",
  iconColor = "text-muted-foreground",
}: EmptyStateProps) {
  const config = sizeConfig[size];

  return (
    <motion.div
      className={cn(
        "flex flex-col items-center justify-center text-center",
        config.container,
        className
      )}
      variants={staggerContainer}
      initial="hidden"
      animate="visible"
    >
      {/* Icon with glassmorphism effect */}
      {icon && (
        <motion.div
          variants={fadeInScale}
          className="mb-6 relative"
        >
          <div className="absolute inset-0 bg-gradient-to-br from-primary/10 via-accent/5 to-primary/5 rounded-3xl blur-xl scale-150" />
          <motion.div
            className={cn(
              "relative rounded-2xl bg-white/80 dark:bg-gray-800/80",
              "border border-white/60 dark:border-gray-700/60",
              "shadow-sm backdrop-blur-sm",
              config.iconWrapper
            )}
            whileHover={{ scale: 1.05 }}
            transition={springs.gentle}
          >
            <div className={cn(config.iconSize, iconColor, "flex items-center justify-center")}>
              {icon}
            </div>
          </motion.div>
        </motion.div>
      )}

      {/* Title */}
      <motion.h3
        variants={staggerItem}
        className={cn(
          "font-semibold text-foreground mb-2",
          config.title
        )}
      >
        {title}
      </motion.h3>

      {/* Description */}
      {description && (
        <motion.p
          variants={staggerItem}
          className={cn(
            "text-muted-foreground max-w-sm",
            config.description
          )}
        >
          {description}
        </motion.p>
      )}

      {/* Actions */}
      {(primaryAction || secondaryAction) && (
        <motion.div
          variants={staggerItem}
          className="mt-6 flex flex-col sm:flex-row items-center gap-3"
        >
          {primaryAction && (
            <AnimatedButton
              onClick={primaryAction.onClick}
              leftIcon={primaryAction.icon}
              size={size === "sm" ? "sm" : "default"}
            >
              {primaryAction.label}
            </AnimatedButton>
          )}
          {secondaryAction && (
            <AnimatedButton
              variant="ghost"
              onClick={secondaryAction.onClick}
              size={size === "sm" ? "sm" : "default"}
            >
              {secondaryAction.label}
            </AnimatedButton>
          )}
        </motion.div>
      )}
    </motion.div>
  );
}

/**
 * Preset empty states for common scenarios
 */

export function NoProjectsEmpty({ onCreateNew }: { onCreateNew: () => void }) {
  return (
    <EmptyState
      icon={<FolderOpen className="w-full h-full" />}
      iconColor="text-primary"
      title="No projects yet"
      description="Start your academic journey by creating your first project. We'll match you with expert tutors."
      primaryAction={{
        label: "Create Project",
        onClick: onCreateNew,
        icon: <Plus className="w-4 h-4" />,
      }}
    />
  );
}

export function NoMessagesEmpty() {
  return (
    <EmptyState
      icon={<MessageSquare className="w-full h-full" />}
      iconColor="text-blue-500"
      title="No messages yet"
      description="Once you start a project, you'll be able to chat with your assigned expert here."
      size="sm"
    />
  );
}

export function NoNotificationsEmpty() {
  return (
    <EmptyState
      icon={<Bell className="w-full h-full" />}
      iconColor="text-amber-500"
      title="All caught up!"
      description="You have no new notifications. We'll let you know when something needs your attention."
      size="sm"
    />
  );
}

export function SearchNoResultsEmpty({ query, onClear }: { query: string; onClear: () => void }) {
  return (
    <EmptyState
      icon={<Search className="w-full h-full" />}
      iconColor="text-muted-foreground"
      title={`No results for "${query}"`}
      description="Try adjusting your search terms or filters to find what you're looking for."
      primaryAction={{
        label: "Clear Search",
        onClick: onClear,
      }}
    />
  );
}

export function ErrorEmpty({ onRetry }: { onRetry: () => void }) {
  return (
    <EmptyState
      icon={<AlertTriangle className="w-full h-full" />}
      iconColor="text-destructive"
      title="Something went wrong"
      description="We couldn't load the content. Please try again."
      primaryAction={{
        label: "Try Again",
        onClick: onRetry,
      }}
    />
  );
}
