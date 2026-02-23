"use client"

/**
 * ProjectCard - Animated project card with status, progress, and actions
 * Features hover lift, progress animation, and status badges
 */

import * as React from "react"
import Link from "next/link"
import { motion, AnimatePresence } from "framer-motion"
import { formatDistanceToNow } from "date-fns"
import {
  Clock,
  CheckCircle2,
  AlertCircle,
  MessageSquare,
  MoreHorizontal,
  FileText,
  type LucideIcon,
} from "lucide-react"

import { cn } from "@/lib/utils"
import { cardHover, fadeInScale, springs } from "@/lib/animations/variants"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Progress } from "@/components/ui/progress"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"

export type ProjectStatus =
  | "draft"
  | "pending"
  | "in_progress"
  | "review"
  | "completed"
  | "cancelled"

interface ProjectCardProps {
  id: string
  title: string
  description?: string
  status: ProjectStatus
  progress: number
  dueDate?: Date
  createdAt: Date
  assignee?: {
    name: string
    avatar?: string
  }
  unreadMessages?: number
  serviceType?: string
  className?: string
  onAction?: (action: "view" | "message" | "cancel") => void
}

const statusConfig: Record<
  ProjectStatus,
  { label: string; icon: LucideIcon; color: string; bgColor: string }
> = {
  draft: {
    label: "Draft",
    icon: FileText,
    color: "text-muted-foreground",
    bgColor: "bg-muted",
  },
  pending: {
    label: "Pending",
    icon: Clock,
    color: "text-yellow-600 dark:text-yellow-400",
    bgColor: "bg-yellow-100 dark:bg-yellow-900/30",
  },
  in_progress: {
    label: "In Progress",
    icon: Clock,
    color: "text-blue-600 dark:text-blue-400",
    bgColor: "bg-blue-100 dark:bg-blue-900/30",
  },
  review: {
    label: "In Review",
    icon: AlertCircle,
    color: "text-purple-600 dark:text-purple-400",
    bgColor: "bg-purple-100 dark:bg-purple-900/30",
  },
  completed: {
    label: "Completed",
    icon: CheckCircle2,
    color: "text-green-600 dark:text-green-400",
    bgColor: "bg-green-100 dark:bg-green-900/30",
  },
  cancelled: {
    label: "Cancelled",
    icon: AlertCircle,
    color: "text-red-600 dark:text-red-400",
    bgColor: "bg-red-100 dark:bg-red-900/30",
  },
}

export function ProjectCard({
  id,
  title,
  description,
  status,
  progress,
  dueDate,
  createdAt,
  assignee,
  unreadMessages = 0,
  serviceType,
  className,
  onAction,
}: ProjectCardProps) {
  const statusInfo = statusConfig[status]
  const StatusIcon = statusInfo.icon
  const timeAgo = formatDistanceToNow(createdAt, { addSuffix: true })

  return (
    <motion.div
      variants={cardHover}
      initial="rest"
      whileHover="hover"
      whileTap="tap"
      className={cn(
        "group relative bg-card rounded-2xl border p-5",
        "cursor-pointer transition-colors",
        className
      )}
    >
      <Link href={`/project/${id}`} className="absolute inset-0 z-10" />

      {/* Header: Status & Menu */}
      <div className="flex items-start justify-between mb-3">
        <motion.div
          className={cn(
            "inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium",
            statusInfo.bgColor,
            statusInfo.color
          )}
          variants={fadeInScale}
        >
          <StatusIcon className="size-3.5" />
          {statusInfo.label}
        </motion.div>

        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <motion.button
              className="relative z-20 p-1.5 rounded-lg opacity-0 group-hover:opacity-100 hover:bg-muted transition-opacity"
              whileTap={{ scale: 0.9 }}
            >
              <MoreHorizontal className="size-4 text-muted-foreground" />
            </motion.button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            <DropdownMenuItem onClick={() => onAction?.("view")}>
              View Details
            </DropdownMenuItem>
            <DropdownMenuItem onClick={() => onAction?.("message")}>
              Send Message
            </DropdownMenuItem>
            {status !== "completed" && status !== "cancelled" && (
              <DropdownMenuItem
                onClick={() => onAction?.("cancel")}
                className="text-destructive"
              >
                Cancel Project
              </DropdownMenuItem>
            )}
          </DropdownMenuContent>
        </DropdownMenu>
      </div>

      {/* Title & Description */}
      <div className="mb-4">
        <h3 className="font-semibold text-foreground mb-1 line-clamp-1 group-hover:text-primary transition-colors">
          {title}
        </h3>
        {description && (
          <p className="text-sm text-muted-foreground line-clamp-2">
            {description}
          </p>
        )}
      </div>

      {/* Progress Bar */}
      <div className="mb-4">
        <div className="flex items-center justify-between text-xs mb-1.5">
          <span className="text-muted-foreground">Progress</span>
          <span className="font-medium">{progress}%</span>
        </div>
        <motion.div
          initial={{ scaleX: 0 }}
          animate={{ scaleX: 1 }}
          transition={{ duration: 0.5, ease: "easeOut" }}
          style={{ transformOrigin: "left" }}
        >
          <Progress value={progress} className="h-2" />
        </motion.div>
      </div>

      {/* Footer: Assignee & Meta */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          {assignee && (
            <div className="flex items-center gap-2">
              <Avatar className="size-7">
                <AvatarImage src={assignee.avatar} alt={assignee.name} />
                <AvatarFallback className="text-xs">
                  {assignee.name
                    .split(" ")
                    .map((n) => n[0])
                    .join("")}
                </AvatarFallback>
              </Avatar>
              <span className="text-xs text-muted-foreground truncate max-w-[100px]">
                {assignee.name}
              </span>
            </div>
          )}

          {/* Unread messages badge */}
          <AnimatePresence>
            {unreadMessages > 0 && (
              <motion.div
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                exit={{ scale: 0 }}
                transition={springs.bouncy}
                className="flex items-center gap-1 px-2 py-0.5 rounded-full bg-primary/10 text-primary"
              >
                <MessageSquare className="size-3" />
                <span className="text-xs font-medium">{unreadMessages}</span>
              </motion.div>
            )}
          </AnimatePresence>
        </div>

        <span className="text-xs text-muted-foreground">{timeAgo}</span>
      </div>

      {/* Service type tag */}
      {serviceType && (
        <div className="absolute bottom-5 right-5">
          <span className="text-[10px] uppercase tracking-wider text-muted-foreground/60 font-medium">
            {serviceType}
          </span>
        </div>
      )}
    </motion.div>
  )
}

/**
 * Compact project card for lists
 */
export function ProjectCardCompact({
  id,
  title,
  status,
  progress,
  dueDate,
  className,
}: Pick<ProjectCardProps, "id" | "title" | "status" | "progress" | "dueDate" | "className">) {
  const statusInfo = statusConfig[status]
  const StatusIcon = statusInfo.icon

  return (
    <Link href={`/project/${id}`}>
      <motion.div
        className={cn(
          "flex items-center gap-4 p-3 rounded-xl border bg-card",
          "hover:bg-accent transition-colors",
          className
        )}
        whileTap={{ scale: 0.98 }}
      >
        {/* Status icon */}
        <div
          className={cn(
            "flex items-center justify-center size-10 rounded-xl",
            statusInfo.bgColor
          )}
        >
          <StatusIcon className={cn("size-5", statusInfo.color)} />
        </div>

        {/* Title & progress */}
        <div className="flex-1 min-w-0">
          <h4 className="font-medium text-sm truncate">{title}</h4>
          <div className="flex items-center gap-2 mt-1">
            <Progress value={progress} className="h-1.5 flex-1" />
            <span className="text-xs text-muted-foreground">{progress}%</span>
          </div>
        </div>

        {/* Due date */}
        {dueDate && (
          <span className="text-xs text-muted-foreground shrink-0">
            Due {formatDistanceToNow(dueDate, { addSuffix: true })}
          </span>
        )}
      </motion.div>
    </Link>
  )
}
