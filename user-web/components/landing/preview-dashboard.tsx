"use client";

/**
 * PreviewDashboard - Mini dashboard preview component
 * Showcases actual dashboard components in a scaled-down,
 * non-interactive preview with subtle animations
 */

import { useEffect, useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  FileText,
  Clock,
  CheckCircle2,
  MessageSquare,
  Send,
  FolderKanban,
  TrendingUp,
  Calendar,
  Wallet,
  Sparkles,
  BookOpen,
  Calculator,
  Beaker,
  Plus,
  Bell,
  Search,
  ChevronRight,
  User,
} from "lucide-react";
import { cn } from "@/lib/utils";

/**
 * Sample project data for preview
 */
const sampleProjects = [
  {
    id: "1",
    title: "Research Paper on Climate Change",
    status: "in_progress" as const,
    progress: 65,
    icon: BookOpen,
    deadline: "2 days left",
    color: "from-blue-500 to-blue-600",
  },
  {
    id: "2",
    title: "Statistical Analysis Assignment",
    status: "review" as const,
    progress: 90,
    icon: Calculator,
    deadline: "Tomorrow",
    color: "from-purple-500 to-purple-600",
  },
  {
    id: "3",
    title: "Chemistry Lab Report",
    status: "completed" as const,
    progress: 100,
    icon: Beaker,
    deadline: "Completed",
    color: "from-green-500 to-green-600",
  },
];

/**
 * Sample chat messages for preview
 */
const sampleMessages = [
  {
    id: "1",
    sender: "expert",
    text: "I've started working on your research paper. The outline looks great!",
    time: "2:34 PM",
  },
  {
    id: "2",
    sender: "user",
    text: "Thanks! Please focus on the methodology section.",
    time: "2:36 PM",
  },
  {
    id: "3",
    sender: "expert",
    text: "Absolutely! I'll have the first draft ready by tomorrow.",
    time: "2:38 PM",
  },
];

/**
 * Status configuration for badges
 */
const statusConfig = {
  in_progress: {
    label: "In Progress",
    icon: Clock,
    color: "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400",
    dot: "bg-blue-500",
  },
  review: {
    label: "In Review",
    icon: FileText,
    color: "bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-400",
    dot: "bg-purple-500",
  },
  completed: {
    label: "Completed",
    icon: CheckCircle2,
    color: "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400",
    dot: "bg-green-500",
  },
};

/**
 * Animated typing indicator for chat preview
 */
function TypingIndicator() {
  return (
    <div className="flex items-center gap-1 px-3 py-2 bg-slate-100 dark:bg-slate-800 rounded-2xl rounded-bl-md w-fit">
      {[0, 1, 2].map((i) => (
        <motion.div
          key={i}
          className="w-1.5 h-1.5 rounded-full bg-slate-400"
          animate={{ y: [0, -4, 0] }}
          transition={{
            duration: 0.6,
            repeat: Infinity,
            delay: i * 0.15,
          }}
        />
      ))}
    </div>
  );
}

/**
 * Mini project card for preview
 */
function MiniProjectCard({
  project,
  delay = 0,
}: {
  project: (typeof sampleProjects)[0];
  delay?: number;
}) {
  const status = statusConfig[project.status];
  const Icon = project.icon;

  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.4, delay }}
      className="group p-3 bg-white dark:bg-slate-800/50 rounded-xl border border-slate-100 dark:border-slate-700/50 hover:shadow-md transition-all duration-200"
    >
      <div className="flex items-start gap-3">
        {/* Icon */}
        <div className={cn(
          "shrink-0 w-9 h-9 rounded-lg bg-gradient-to-br flex items-center justify-center shadow-sm",
          project.color
        )}>
          <Icon className="w-4 h-4 text-white" />
        </div>

        {/* Content */}
        <div className="flex-1 min-w-0">
          <div className="flex items-center justify-between gap-2 mb-1">
            <h4 className="text-sm font-medium text-slate-900 dark:text-slate-100 truncate group-hover:text-primary transition-colors">
              {project.title}
            </h4>
          </div>

          {/* Progress bar */}
          <div className="flex items-center gap-2 mb-2">
            <div className="flex-1 h-1.5 bg-slate-100 dark:bg-slate-700 rounded-full overflow-hidden">
              <motion.div
                className={cn("h-full rounded-full bg-gradient-to-r", project.color)}
                initial={{ width: 0 }}
                animate={{ width: `${project.progress}%` }}
                transition={{ duration: 1, delay: delay + 0.3, ease: "easeOut" }}
              />
            </div>
            <span className="text-xs font-medium text-slate-500 dark:text-slate-400">
              {project.progress}%
            </span>
          </div>

          {/* Footer */}
          <div className="flex items-center justify-between">
            <span className={cn("inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-medium", status.color)}>
              <status.icon className="w-2.5 h-2.5" />
              {status.label}
            </span>
            <span className="text-[10px] text-slate-400 dark:text-slate-500 flex items-center gap-1">
              <Clock className="w-2.5 h-2.5" />
              {project.deadline}
            </span>
          </div>
        </div>
      </div>
    </motion.div>
  );
}

/**
 * Chat message component for preview
 */
function ChatMessage({
  message,
  delay = 0,
}: {
  message: (typeof sampleMessages)[0];
  delay?: number;
}) {
  const isUser = message.sender === "user";

  return (
    <motion.div
      initial={{ opacity: 0, y: 10, scale: 0.95 }}
      animate={{ opacity: 1, y: 0, scale: 1 }}
      transition={{ duration: 0.3, delay }}
      className={cn("flex gap-2", isUser ? "flex-row-reverse" : "flex-row")}
    >
      {/* Avatar */}
      {!isUser && (
        <div className="shrink-0 w-6 h-6 rounded-full bg-gradient-to-br from-primary to-primary/70 flex items-center justify-center">
          <Sparkles className="w-3 h-3 text-white" />
        </div>
      )}

      {/* Message bubble */}
      <div
        className={cn(
          "max-w-[75%] px-3 py-2 rounded-2xl text-xs",
          isUser
            ? "bg-primary text-white rounded-br-md"
            : "bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300 rounded-bl-md"
        )}
      >
        {message.text}
      </div>
    </motion.div>
  );
}

/**
 * Stats pill component for preview
 */
function StatPill({
  icon: Icon,
  label,
  value,
  highlight = false,
}: {
  icon: React.ElementType;
  label: string;
  value: string | number;
  highlight?: boolean;
}) {
  return (
    <div
      className={cn(
        "flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs",
        "bg-white/60 dark:bg-slate-800/60 backdrop-blur-sm border border-slate-100 dark:border-slate-700/50",
        highlight && "border-primary/30 bg-primary/5"
      )}
    >
      <Icon
        className={cn("h-3 w-3", highlight ? "text-primary" : "text-slate-400")}
      />
      <span className="text-slate-500 dark:text-slate-400">{label}</span>
      <span className={cn("font-medium", highlight ? "text-primary" : "text-slate-700 dark:text-slate-300")}>
        {value}
      </span>
    </div>
  );
}

/**
 * PreviewDashboard - Main dashboard preview component
 */
export function PreviewDashboard({ variant = "full" }: { variant?: "full" | "compact" | "chat" }) {
  const [showTyping, setShowTyping] = useState(false);
  const [currentProgress, setCurrentProgress] = useState(65);

  // Animate progress bar periodically
  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentProgress((prev) => {
        const newValue = prev + Math.random() * 3;
        return newValue >= 100 ? 65 : Math.min(newValue, 99);
      });
    }, 2000);

    return () => clearInterval(interval);
  }, []);

  // Show typing indicator periodically
  useEffect(() => {
    const interval = setInterval(() => {
      setShowTyping(true);
      setTimeout(() => setShowTyping(false), 2000);
    }, 5000);

    return () => clearInterval(interval);
  }, []);

  if (variant === "chat") {
    return (
      <div className="h-full flex flex-col bg-slate-50 dark:bg-slate-950">
        {/* Chat header */}
        <div className="flex items-center gap-3 px-4 py-3 bg-white dark:bg-slate-900 border-b border-slate-100 dark:border-slate-800">
          <div className="w-8 h-8 rounded-full bg-gradient-to-br from-primary to-primary/70 flex items-center justify-center">
            <Sparkles className="w-4 h-4 text-white" />
          </div>
          <div className="flex-1">
            <h4 className="text-sm font-semibold text-slate-900 dark:text-slate-100">Expert Chat</h4>
            <p className="text-[10px] text-green-500 flex items-center gap-1">
              <span className="w-1.5 h-1.5 rounded-full bg-green-500 animate-pulse" />
              Online
            </p>
          </div>
          <MessageSquare className="w-4 h-4 text-slate-400" />
        </div>

        {/* Messages */}
        <div className="flex-1 p-4 space-y-3 overflow-hidden">
          {sampleMessages.map((message, i) => (
            <ChatMessage key={message.id} message={message} delay={i * 0.2} />
          ))}
          <AnimatePresence>
            {showTyping && (
              <motion.div
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                className="flex items-center gap-2"
              >
                <div className="shrink-0 w-6 h-6 rounded-full bg-gradient-to-br from-primary to-primary/70 flex items-center justify-center">
                  <Sparkles className="w-3 h-3 text-white" />
                </div>
                <TypingIndicator />
              </motion.div>
            )}
          </AnimatePresence>
        </div>

        {/* Input */}
        <div className="px-4 py-3 bg-white dark:bg-slate-900 border-t border-slate-100 dark:border-slate-800">
          <div className="flex items-center gap-2 px-3 py-2 bg-slate-100 dark:bg-slate-800 rounded-full">
            <input
              type="text"
              placeholder="Type a message..."
              className="flex-1 bg-transparent text-xs text-slate-700 dark:text-slate-300 placeholder:text-slate-400 outline-none"
              readOnly
            />
            <button className="w-7 h-7 rounded-full bg-primary flex items-center justify-center">
              <Send className="w-3.5 h-3.5 text-white" />
            </button>
          </div>
        </div>
      </div>
    );
  }

  if (variant === "compact") {
    return (
      <div className="p-4 bg-slate-50 dark:bg-slate-950 h-full">
        <div className="space-y-3">
          {sampleProjects.slice(0, 2).map((project, i) => (
            <MiniProjectCard key={project.id} project={project} delay={i * 0.15} />
          ))}
        </div>
      </div>
    );
  }

  // Full dashboard preview
  return (
    <div className="h-full bg-gradient-to-br from-slate-50 via-white to-slate-50 dark:from-slate-950 dark:via-slate-900 dark:to-slate-950">
      {/* Header */}
      <div className="flex items-center justify-between px-5 py-3 border-b border-slate-100 dark:border-slate-800 bg-white/80 dark:bg-slate-900/80 backdrop-blur-sm">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-xl bg-gradient-to-br from-primary to-primary/70 flex items-center justify-center shadow-md">
            <span className="text-sm font-bold text-white">A</span>
          </div>
          <div>
            <h3 className="text-sm font-semibold text-slate-900 dark:text-slate-100">Welcome back, Alex</h3>
            <p className="text-[10px] text-slate-500 dark:text-slate-400">Let's tackle your projects</p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <button className="w-8 h-8 rounded-lg bg-slate-100 dark:bg-slate-800 flex items-center justify-center">
            <Search className="w-4 h-4 text-slate-400" />
          </button>
          <button className="relative w-8 h-8 rounded-lg bg-slate-100 dark:bg-slate-800 flex items-center justify-center">
            <Bell className="w-4 h-4 text-slate-400" />
            <span className="absolute -top-0.5 -right-0.5 w-2.5 h-2.5 rounded-full bg-red-500 border-2 border-white dark:border-slate-900" />
          </button>
          <div className="w-8 h-8 rounded-full bg-gradient-to-br from-slate-200 to-slate-300 dark:from-slate-700 dark:to-slate-600 flex items-center justify-center">
            <User className="w-4 h-4 text-slate-600 dark:text-slate-300" />
          </div>
        </div>
      </div>

      {/* Stats row */}
      <div className="px-5 py-3 flex items-center gap-2 overflow-x-auto scrollbar-hide">
        <StatPill icon={FolderKanban} label="Active" value={3} highlight />
        <StatPill icon={Clock} label="Pending" value={2} highlight />
        <StatPill icon={Wallet} label="Wallet" value="$250" />
      </div>

      {/* Main content */}
      <div className="px-5 pb-5">
        {/* Quick actions */}
        <div className="flex items-center gap-2 mb-4">
          <motion.button
            className="flex-1 flex items-center justify-center gap-2 px-4 py-2.5 bg-primary text-white rounded-xl text-xs font-medium shadow-lg shadow-primary/20"
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
          >
            <Plus className="w-4 h-4" />
            New Project
          </motion.button>
          <button className="flex items-center justify-center gap-2 px-4 py-2.5 bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl text-xs font-medium text-slate-700 dark:text-slate-300">
            <MessageSquare className="w-4 h-4" />
            Support
          </button>
        </div>

        {/* Projects header */}
        <div className="flex items-center justify-between mb-3">
          <h4 className="text-sm font-semibold text-slate-900 dark:text-slate-100 flex items-center gap-2">
            <FolderKanban className="w-4 h-4 text-primary" />
            Recent Projects
          </h4>
          <button className="text-[10px] text-primary font-medium flex items-center gap-1 hover:underline">
            View all
            <ChevronRight className="w-3 h-3" />
          </button>
        </div>

        {/* Project cards */}
        <div className="space-y-2.5">
          {sampleProjects.map((project, i) => (
            <MiniProjectCard key={project.id} project={project} delay={i * 0.1} />
          ))}
        </div>

        {/* Live progress indicator */}
        <motion.div
          className="mt-4 p-3 bg-gradient-to-r from-blue-50 to-purple-50 dark:from-blue-900/20 dark:to-purple-900/20 rounded-xl border border-blue-100 dark:border-blue-800/30"
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.5 }}
        >
          <div className="flex items-center justify-between mb-2">
            <span className="text-[10px] font-medium text-slate-600 dark:text-slate-400 flex items-center gap-1">
              <motion.span
                className="w-1.5 h-1.5 rounded-full bg-blue-500"
                animate={{ opacity: [1, 0.5, 1] }}
                transition={{ duration: 1.5, repeat: Infinity }}
              />
              Live Progress
            </span>
            <span className="text-[10px] font-semibold text-blue-600 dark:text-blue-400">
              {Math.round(currentProgress)}%
            </span>
          </div>
          <div className="h-1.5 bg-white dark:bg-slate-800 rounded-full overflow-hidden">
            <motion.div
              className="h-full bg-gradient-to-r from-blue-500 to-purple-500 rounded-full"
              animate={{ width: `${currentProgress}%` }}
              transition={{ duration: 0.5 }}
            />
          </div>
        </motion.div>
      </div>
    </div>
  );
}

/**
 * TimelinePreview - Shows project timeline preview
 */
export function TimelinePreview() {
  const milestones = [
    { label: "Submitted", status: "completed", date: "Jan 20" },
    { label: "In Progress", status: "current", date: "Jan 22" },
    { label: "Review", status: "pending", date: "Jan 25" },
    { label: "Delivered", status: "pending", date: "Jan 27" },
  ];

  return (
    <div className="p-4 bg-slate-50 dark:bg-slate-950 h-full">
      <h4 className="text-sm font-semibold text-slate-900 dark:text-slate-100 mb-4 flex items-center gap-2">
        <Calendar className="w-4 h-4 text-primary" />
        Project Timeline
      </h4>

      <div className="relative">
        {/* Timeline line */}
        <div className="absolute left-3 top-3 bottom-3 w-0.5 bg-slate-200 dark:bg-slate-700" />

        {/* Milestones */}
        <div className="space-y-4">
          {milestones.map((milestone, i) => (
            <motion.div
              key={milestone.label}
              initial={{ opacity: 0, x: -10 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: i * 0.15 }}
              className="relative flex items-center gap-3 pl-8"
            >
              {/* Dot */}
              <div
                className={cn(
                  "absolute left-0 w-6 h-6 rounded-full flex items-center justify-center border-2",
                  milestone.status === "completed" && "bg-green-500 border-green-500",
                  milestone.status === "current" && "bg-blue-500 border-blue-500 animate-pulse",
                  milestone.status === "pending" && "bg-white dark:bg-slate-900 border-slate-300 dark:border-slate-600"
                )}
              >
                {milestone.status === "completed" && (
                  <CheckCircle2 className="w-3 h-3 text-white" />
                )}
                {milestone.status === "current" && (
                  <div className="w-2 h-2 rounded-full bg-white" />
                )}
              </div>

              {/* Content */}
              <div className="flex-1">
                <p
                  className={cn(
                    "text-xs font-medium",
                    milestone.status === "pending"
                      ? "text-slate-400 dark:text-slate-500"
                      : "text-slate-700 dark:text-slate-300"
                  )}
                >
                  {milestone.label}
                </p>
                <p className="text-[10px] text-slate-400 dark:text-slate-500">{milestone.date}</p>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </div>
  );
}
