"use client";

/**
 * ProjectDetailClient - Clean, modern project detail with navigable timeline
 * Features clickable steps to view historical information
 */

import { useState, useRef, useEffect, useCallback, type KeyboardEvent } from "react";
import { useRouter } from "next/navigation";
import { toast } from "sonner";
import { motion, AnimatePresence } from "framer-motion";
import {
  ArrowLeft,
  Clock,
  FileText,
  ExternalLink,
  BookOpen,
  Hash,
  Calendar,
  MoreHorizontal,
  XCircle,
  Loader2,
  Send,
  Paperclip,
  ChevronRight,
  Check,
  User,
  AlertTriangle,
  ChevronUp,
  Download,
  Package,
  CreditCard,
  Eye,
  ShieldCheck,
  Zap,
  CheckCircle2,
  Timer,
  X,
  ClipboardList,
  Search,
  MessageSquare,
  UserCheck,
  FileCheck,
  Truck,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import {
  AlertDialog,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  DeliverablesSection,
  QualityReportBadge,
  AttachedFiles,
} from "@/components/project-detail";
import { RazorpayCheckout } from "@/components/payments/razorpay-checkout";
import { cn } from "@/lib/utils";
import { useMemo } from "react";
import { generateInvoiceHTML } from "@/lib/actions/invoice";
import { createRevisionRequest, markProjectComplete } from "@/lib/actions/data";
import { useChat } from "@/hooks/useChat";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { validateChatContent, getValidationErrorMessage } from "@/lib/validations/chat-content";
import { flagUserForViolation, type FlagReason } from "@/lib/actions/user-flagging";
import type { ProjectDetail, ProjectStatus } from "@/types/project";
import { STATUS_CONFIG } from "@/types/project";
import { projectService, type TimelineEvent } from "@/services";

/**
 * Step configuration with emojis and details
 */
const STEPS = [
  {
    id: "submitted",
    label: "Submitted",
    emoji: "📤",
    icon: FileText,
    description: "Your project has been submitted for review",
    details: "We've received your project requirements and attached files.",
  },
  {
    id: "analyzing",
    label: "Under Review",
    emoji: "🔍",
    icon: Search,
    description: "Our team is reviewing your requirements",
    details: "An expert is analyzing your project to prepare an accurate quote.",
  },
  {
    id: "quoted",
    label: "Quote Ready",
    emoji: "💰",
    icon: CreditCard,
    description: "Your quote is ready for review",
    details: "Review the quote and proceed with payment to start work.",
  },
  {
    id: "paid",
    label: "Paid",
    emoji: "✅",
    icon: CheckCircle2,
    description: "Payment received successfully",
    details: "Your payment has been confirmed. We're assigning an expert.",
  },
  {
    id: "assigned",
    label: "Assigned",
    emoji: "👨‍💻",
    icon: UserCheck,
    description: "Expert assigned to your project",
    details: "A qualified expert has been assigned and will begin work soon.",
  },
  {
    id: "in_progress",
    label: "In Progress",
    emoji: "⚡",
    icon: Zap,
    description: "Your expert is actively working",
    details: "Track real-time progress through the live document link.",
  },
  {
    id: "qc",
    label: "Quality Check",
    emoji: "🔬",
    icon: ShieldCheck,
    description: "Work is being reviewed for quality",
    details: "Our QC team ensures your work meets quality standards.",
  },
  {
    id: "delivered",
    label: "Delivered",
    emoji: "🎉",
    icon: Truck,
    description: "Your project is complete",
    details: "Review the deliverables and mark as complete or request revisions.",
  },
];

/**
 * Get step index from status
 */
function getStepIndex(status: ProjectStatus): number {
  const map: Record<string, number> = {
    draft: 0,
    submitted: 0,
    analyzing: 1,
    quoted: 2,
    payment_pending: 2,
    paid: 3,
    assigning: 4,
    assigned: 4,
    in_progress: 5,
    submitted_for_qc: 6,
    qc_in_progress: 6,
    qc_approved: 6,
    qc_rejected: 5,
    delivered: 7,
    revision_requested: 7,
    in_revision: 5,
    completed: 8,
    auto_approved: 8,
  };
  return map[status] ?? 0;
}

/**
 * Format time helper
 */
function formatTime(timestamp: string): string {
  const date = new Date(timestamp);
  const now = new Date();
  const diffDays = Math.floor((now.getTime() - date.getTime()) / (1000 * 60 * 60 * 24));
  if (diffDays === 0) return date.toLocaleTimeString("en-IN", { hour: "2-digit", minute: "2-digit" });
  if (diffDays === 1) return "Yesterday";
  return date.toLocaleDateString("en-IN", { day: "numeric", month: "short" });
}

interface ProjectDetailClientProps {
  project: ProjectDetail;
  userId: string;
}

/**
 * Main Component
 */
export function ProjectDetailClient({ project, userId }: ProjectDetailClientProps) {
  const router = useRouter();
  const [isDownloadingInvoice, setIsDownloadingInvoice] = useState(false);
  const [mobileTab, setMobileTab] = useState<"info" | "chat">("chat");
  const [isPaymentOpen, setIsPaymentOpen] = useState(false);
  const [isRevisionDialogOpen, setIsRevisionDialogOpen] = useState(false);
  const [revisionFeedback, setRevisionFeedback] = useState("");
  const [isSubmittingRevision, setIsSubmittingRevision] = useState(false);
  const [isCompleteDialogOpen, setIsCompleteDialogOpen] = useState(false);
  const [isMarkingComplete, setIsMarkingComplete] = useState(false);
  const [selectedStepIndex, setSelectedStepIndex] = useState<number | null>(null);

  const config = STATUS_CONFIG[project.status];
  const stepIndex = getStepIndex(project.status);
  const showInvoice = stepIndex >= 3;
  const isQuoted = project.status === "quoted" || project.status === "payment_pending";
  const isDelivered = stepIndex >= 7;
  const isCompleted = project.status === "completed" || project.status === "auto_approved";
  const paymentAmount = project.budget ? parseInt(project.budget.replace(/[^0-9]/g, "")) : 0;

  // Handlers
  const handleDownloadInvoice = async () => {
    if (!project.id) return;
    setIsDownloadingInvoice(true);
    try {
      const html = await generateInvoiceHTML(project.id);
      if (!html) { toast.error("Invoice not available"); return; }
      const win = window.open("", "_blank");
      if (!win) { toast.error("Allow popups"); return; }
      win.document.write(html);
      win.document.close();
      win.onload = () => { win.focus(); win.print(); };
    } catch { toast.error("Failed to generate invoice"); }
    finally { setIsDownloadingInvoice(false); }
  };

  const handlePaymentSuccess = () => {
    toast.success("Payment successful!");
    setTimeout(() => router.refresh(), 1500);
  };

  const handleRequestRevision = async () => {
    if (!revisionFeedback.trim()) {
      toast.error("Please describe what changes you need");
      return;
    }
    setIsSubmittingRevision(true);
    try {
      const result = await createRevisionRequest(project.id, revisionFeedback.trim());
      if (result.error) {
        toast.error(result.error);
      } else {
        toast.success("Revision request submitted");
        setIsRevisionDialogOpen(false);
        setRevisionFeedback("");
        router.refresh();
      }
    } catch {
      toast.error("Failed to submit revision request");
    } finally {
      setIsSubmittingRevision(false);
    }
  };

  const handleMarkComplete = async () => {
    setIsMarkingComplete(true);
    try {
      const result = await markProjectComplete(project.id);
      if (result.error) {
        toast.error(result.error);
      } else {
        toast.success("Project marked as complete!");
        setIsCompleteDialogOpen(false);
        router.refresh();
      }
    } catch {
      toast.error("Failed to mark project as complete");
    } finally {
      setIsMarkingComplete(false);
    }
  };

  // Time remaining
  const getTimeRemaining = () => {
    if (!project.deadline) return null;
    const diff = new Date(project.deadline).getTime() - Date.now();
    if (diff <= 0) return { text: "Overdue", urgent: true };
    const days = Math.floor(diff / (1000 * 60 * 60 * 24));
    const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    return { text: days > 0 ? `${days}d ${hours}h` : `${hours}h`, urgent: days < 2 };
  };

  const timeInfo = getTimeRemaining();

  return (
    <div className="h-screen flex overflow-hidden bg-stone-50 dark:bg-stone-950">
      {/* Left Panel - Project Info */}
      <div className="hidden lg:flex flex-col w-[55%] max-w-2xl border-r border-stone-200 dark:border-stone-800 h-screen bg-white dark:bg-stone-900">
        {/* Header */}
        <div className="flex items-center gap-4 p-4 border-b border-stone-100 dark:border-stone-800">
          <button
            onClick={() => router.push("/projects")}
            className="h-9 w-9 rounded-xl border border-stone-200 dark:border-stone-700 flex items-center justify-center text-muted-foreground hover:text-foreground hover:bg-stone-100 dark:hover:bg-stone-800 transition-colors"
          >
            <ArrowLeft className="h-4 w-4" />
          </button>
          <div className="flex-1 min-w-0">
            <span className="text-xs font-mono text-muted-foreground">{project.projectNumber}</span>
            <h1 className="text-base font-semibold truncate">{project.title}</h1>
          </div>
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <button className="h-9 w-9 rounded-xl border border-stone-200 dark:border-stone-700 flex items-center justify-center text-muted-foreground hover:text-foreground hover:bg-stone-100 dark:hover:bg-stone-800 transition-colors">
                <MoreHorizontal className="h-4 w-4" />
              </button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-48">
              {showInvoice && (
                <>
                  <DropdownMenuItem onClick={handleDownloadInvoice} disabled={isDownloadingInvoice}>
                    <Download className="h-4 w-4 mr-2" />
                    Download Invoice
                  </DropdownMenuItem>
                  <DropdownMenuSeparator />
                </>
              )}
              <DropdownMenuItem className="text-red-500">
                <XCircle className="h-4 w-4 mr-2" /> Cancel Project
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>

        {/* Content - Scrollable */}
        <div className="flex-1 overflow-y-auto p-6 space-y-6">
          {/* Status Badge */}
          <div className="flex items-center gap-2">
            <span className={cn(
              "inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium",
              stepIndex >= 7
                ? "bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-400"
                : stepIndex >= 5
                  ? "bg-violet-100 text-violet-700 dark:bg-violet-900/30 dark:text-violet-400"
                  : "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400"
            )}>
              <span className="h-1.5 w-1.5 rounded-full bg-current" />
              {config.label}
            </span>
          </div>

          {/* Interactive Step Progress */}
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider">
                Progress Timeline
              </p>
              <span className="text-xs text-muted-foreground">
                Step {Math.min(stepIndex + 1, STEPS.length)} of {STEPS.length}
              </span>
            </div>

            {/* Clickable Steps */}
            <div className="flex items-center gap-1">
              {STEPS.map((step, i) => {
                const isCompleted = i < stepIndex;
                const isCurrent = i === stepIndex;
                const isClickable = i <= stepIndex;

                return (
                  <motion.button
                    key={step.id}
                    whileHover={isClickable ? { scale: 1.1 } : {}}
                    whileTap={isClickable ? { scale: 0.95 } : {}}
                    onClick={() => isClickable && setSelectedStepIndex(i)}
                    disabled={!isClickable}
                    className={cn(
                      "h-2 rounded-full flex-1 transition-all duration-200",
                      isCompleted && "bg-emerald-500 cursor-pointer hover:bg-emerald-600",
                      isCurrent && "bg-violet-500 cursor-pointer hover:bg-violet-600",
                      !isCompleted && !isCurrent && "bg-stone-200 dark:bg-stone-700 cursor-not-allowed"
                    )}
                    title={isClickable ? `View: ${step.label}` : step.label}
                  />
                );
              })}
            </div>

            {/* Current Step Info */}
            <div className="flex items-center gap-3 p-4 rounded-2xl bg-stone-50 dark:bg-stone-800/50 border border-stone-100 dark:border-stone-800">
              <div className={cn(
                "h-10 w-10 rounded-xl flex items-center justify-center text-lg",
                stepIndex >= 7
                  ? "bg-emerald-100 dark:bg-emerald-900/30"
                  : stepIndex >= 5
                    ? "bg-violet-100 dark:bg-violet-900/30"
                    : "bg-amber-100 dark:bg-amber-900/30"
              )}>
                {STEPS[Math.min(stepIndex, STEPS.length - 1)]?.emoji}
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium">{STEPS[Math.min(stepIndex, STEPS.length - 1)]?.label}</p>
                <p className="text-xs text-muted-foreground">
                  {STEPS[Math.min(stepIndex, STEPS.length - 1)]?.description}
                </p>
              </div>
              <Button
                variant="ghost"
                size="sm"
                onClick={() => setSelectedStepIndex(stepIndex)}
                className="text-xs text-muted-foreground hover:text-foreground"
              >
                Details
                <ChevronRight className="h-3 w-3 ml-1" />
              </Button>
            </div>

            {/* Tap to view hint */}
            <p className="text-[10px] text-center text-muted-foreground">
              Tap any completed step to view its history
            </p>
          </div>

          {/* Quote Payment Card */}
          {isQuoted && paymentAmount > 0 && (
            <div className="p-5 rounded-2xl bg-gradient-to-br from-violet-50 to-purple-50 dark:from-violet-950/30 dark:to-purple-950/30 border border-violet-200 dark:border-violet-800">
              <div className="flex items-center gap-2 text-xs text-violet-600 dark:text-violet-400 mb-3">
                <CreditCard className="h-3.5 w-3.5" />
                Payment Required
              </div>
              <p className="text-3xl font-bold text-violet-700 dark:text-violet-300 mb-4">
                ₹{paymentAmount.toLocaleString()}
              </p>
              <Button
                onClick={() => setIsPaymentOpen(true)}
                className="w-full bg-violet-600 hover:bg-violet-700 text-white"
              >
                <CreditCard className="h-4 w-4 mr-2" />
                Pay Now
              </Button>
              <p className="text-[10px] text-violet-600/70 dark:text-violet-400/70 text-center mt-3">
                Quote valid for 24 hours
              </p>
            </div>
          )}

          {/* Live Document Link */}
          {project.liveDocUrl && stepIndex === 5 && (
            <a
              href={project.liveDocUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-3 p-4 rounded-2xl border-2 border-blue-200 dark:border-blue-800 bg-blue-50 dark:bg-blue-950/30 hover:bg-blue-100 dark:hover:bg-blue-950/50 transition-colors"
            >
              <div className="h-10 w-10 rounded-xl bg-blue-500 flex items-center justify-center text-white">
                <Eye className="h-5 w-5" />
              </div>
              <div className="flex-1">
                <p className="text-sm font-medium">Live Document</p>
                <p className="text-xs text-muted-foreground">Track progress in real-time</p>
              </div>
              <ExternalLink className="h-4 w-4 text-blue-500" />
            </a>
          )}

          {/* Timeline Info */}
          {stepIndex >= 3 && stepIndex < 7 && project.deadline && (
            <div className="grid grid-cols-2 gap-3">
              <div className="p-4 rounded-2xl bg-white dark:bg-stone-800/50 border border-stone-200 dark:border-stone-800">
                <div className="flex items-center gap-2 text-xs text-muted-foreground mb-1">
                  <Calendar className="h-3 w-3" />
                  Deadline
                </div>
                <p className="text-sm font-medium">
                  {new Date(project.deadline).toLocaleDateString("en-IN", { day: "numeric", month: "short" })}
                </p>
              </div>
              {timeInfo && (
                <div className={cn(
                  "p-4 rounded-2xl",
                  timeInfo.urgent
                    ? "border-2 border-red-200 bg-red-50 dark:border-red-800 dark:bg-red-950/30"
                    : "bg-white dark:bg-stone-800/50 border border-stone-200 dark:border-stone-800"
                )}>
                  <div className="flex items-center gap-2 text-xs text-muted-foreground mb-1">
                    <Timer className="h-3 w-3" />
                    Time Left
                  </div>
                  <p className={cn("text-sm font-medium", timeInfo.urgent && "text-red-600 dark:text-red-400")}>
                    {timeInfo.text}
                  </p>
                </div>
              )}
            </div>
          )}

          {/* Expert Info */}
          {stepIndex >= 4 && stepIndex < 7 && project.supervisorName && (
            <div className="flex items-center gap-3 p-4 rounded-2xl bg-white dark:bg-stone-800/50 border border-stone-200 dark:border-stone-800">
              <div className="h-10 w-10 rounded-xl bg-violet-600 flex items-center justify-center text-white font-medium">
                {project.supervisorName.charAt(0)}
              </div>
              <div>
                <p className="text-sm font-medium">{project.supervisorName}</p>
                <p className="text-xs text-muted-foreground">
                  {stepIndex === 5 ? "Working on your project" : "Assigned to your project"}
                </p>
              </div>
            </div>
          )}

          {/* Project Details (Early steps) */}
          {stepIndex <= 2 && (
            <>
              <div className="space-y-3">
                <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider">Details</p>
                <div className="grid grid-cols-2 gap-3">
                  <div className="p-4 rounded-2xl bg-white dark:bg-stone-800/50 border border-stone-200 dark:border-stone-800">
                    <div className="flex items-center gap-2 text-xs text-muted-foreground mb-1">
                      <BookOpen className="h-3 w-3" />
                      Subject
                    </div>
                    <p className="text-sm font-medium">{project.subjectName || "Not specified"}</p>
                  </div>
                  {project.wordCount && (
                    <div className="p-4 rounded-2xl bg-white dark:bg-stone-800/50 border border-stone-200 dark:border-stone-800">
                      <div className="flex items-center gap-2 text-xs text-muted-foreground mb-1">
                        <Hash className="h-3 w-3" />
                        Word Count
                      </div>
                      <p className="text-sm font-medium">{project.wordCount.toLocaleString()}</p>
                    </div>
                  )}
                  {project.deadline && (
                    <div className="p-4 rounded-2xl bg-white dark:bg-stone-800/50 border border-stone-200 dark:border-stone-800">
                      <div className="flex items-center gap-2 text-xs text-muted-foreground mb-1">
                        <Calendar className="h-3 w-3" />
                        Deadline
                      </div>
                      <p className="text-sm font-medium">
                        {new Date(project.deadline).toLocaleDateString("en-IN", { day: "numeric", month: "short" })}
                      </p>
                    </div>
                  )}
                </div>
              </div>

              {project.instructions && (
                <div className="p-4 rounded-2xl bg-white dark:bg-stone-800/50 border border-stone-200 dark:border-stone-800">
                  <p className="text-xs font-medium text-muted-foreground mb-2">Instructions</p>
                  <p className="text-sm text-muted-foreground whitespace-pre-wrap">{project.instructions}</p>
                </div>
              )}

              {project.attachedFiles.length > 0 && (
                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider">Files</p>
                    <span className="text-xs text-muted-foreground">{project.attachedFiles.length} files</span>
                  </div>
                  <div className="space-y-2">
                    {project.attachedFiles.map((file) => (
                      <a
                        key={file.id}
                        href={file.url}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="flex items-center gap-3 p-3 rounded-xl bg-white dark:bg-stone-800/50 border border-stone-200 dark:border-stone-800 hover:border-violet-300 dark:hover:border-violet-700 transition-colors"
                      >
                        <div className="h-9 w-9 rounded-lg bg-stone-100 dark:bg-stone-700 flex items-center justify-center text-muted-foreground">
                          <FileText className="h-4 w-4" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <p className="text-sm font-medium truncate">{file.name}</p>
                          {file.size && <p className="text-xs text-muted-foreground">{file.size}</p>}
                        </div>
                        <Download className="h-4 w-4 text-muted-foreground" />
                      </a>
                    ))}
                  </div>
                </div>
              )}
            </>
          )}

          {/* Delivered Content */}
          {isDelivered && (
            <>
              <DeliverablesSection status={project.status} deliverables={project.deliverables} />
              <QualityReportBadge reports={project.qualityReports} />

              {!isCompleted && (
                <div className="space-y-3">
                  <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider">Actions</p>
                  <div className="flex gap-3">
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => setIsRevisionDialogOpen(true)}
                      className="flex-1 border-stone-200 dark:border-stone-700"
                    >
                      Request Revision
                    </Button>
                    <Button
                      size="sm"
                      onClick={() => setIsCompleteDialogOpen(true)}
                      className="flex-1 bg-emerald-600 hover:bg-emerald-700 text-white"
                    >
                      <Check className="h-4 w-4 mr-1" />
                      Complete
                    </Button>
                  </div>
                </div>
              )}
              <button
                onClick={handleDownloadInvoice}
                className="flex items-center justify-center gap-2 w-full py-2 text-xs text-muted-foreground hover:text-foreground transition-colors"
              >
                <Download className="h-3.5 w-3.5" />
                Download Invoice
              </button>
            </>
          )}
        </div>
      </div>

      {/* Right Panel - Chat */}
      <div className="flex-1 flex flex-col h-screen bg-white dark:bg-stone-900">
        {/* Mobile Header */}
        <div className="lg:hidden flex items-center gap-3 p-3 border-b border-stone-200 dark:border-stone-800">
          <button onClick={() => router.push("/projects")} className="p-2 -ml-1">
            <ArrowLeft className="h-5 w-5" />
          </button>
          <span className="flex-1 text-sm font-medium truncate">{project.title}</span>
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <button className="p-2 -mr-1">
                <MoreHorizontal className="h-5 w-5" />
              </button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              {showInvoice && (
                <DropdownMenuItem onClick={handleDownloadInvoice}>
                  <Download className="h-4 w-4 mr-2" /> Invoice
                </DropdownMenuItem>
              )}
            </DropdownMenuContent>
          </DropdownMenu>
        </div>

        {/* Mobile Tabs */}
        <div className="lg:hidden flex border-b border-stone-200 dark:border-stone-800">
          <button
            className={cn(
              "flex-1 py-3 text-sm font-medium border-b-2 transition-colors",
              mobileTab === "info" ? "border-violet-600 text-foreground" : "border-transparent text-muted-foreground"
            )}
            onClick={() => setMobileTab("info")}
          >
            Project Info
          </button>
          <button
            className={cn(
              "flex-1 py-3 text-sm font-medium border-b-2 transition-colors",
              mobileTab === "chat" ? "border-violet-600 text-foreground" : "border-transparent text-muted-foreground"
            )}
            onClick={() => setMobileTab("chat")}
          >
            Chat
          </button>
        </div>

        {/* Mobile Info Content */}
        {mobileTab === "info" && (
          <div className="lg:hidden flex-1 overflow-y-auto p-4 space-y-4">
            {/* Mobile Step Progress */}
            <div className="flex items-center gap-1 mb-4">
              {STEPS.map((step, i) => (
                <button
                  key={step.id}
                  onClick={() => i <= stepIndex && setSelectedStepIndex(i)}
                  disabled={i > stepIndex}
                  className={cn(
                    "h-2 rounded-full flex-1 transition-all",
                    i < stepIndex && "bg-emerald-500",
                    i === stepIndex && "bg-violet-500",
                    i > stepIndex && "bg-stone-200 dark:bg-stone-700"
                  )}
                />
              ))}
            </div>

            <div className={cn(
              "inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium",
              stepIndex >= 7 ? "bg-emerald-100 text-emerald-700" : stepIndex >= 5 ? "bg-violet-100 text-violet-700" : "bg-amber-100 text-amber-700"
            )}>
              <span className="h-1.5 w-1.5 rounded-full bg-current" />
              {config.label}
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div className="p-3 rounded-xl bg-stone-50 dark:bg-stone-800">
                <p className="text-xs text-muted-foreground mb-1">Subject</p>
                <p className="text-sm font-medium">{project.subjectName || "N/A"}</p>
              </div>
              {project.deadline && (
                <div className="p-3 rounded-xl bg-stone-50 dark:bg-stone-800">
                  <p className="text-xs text-muted-foreground mb-1">Deadline</p>
                  <p className="text-sm font-medium">
                    {new Date(project.deadline).toLocaleDateString("en-IN", { day: "numeric", month: "short" })}
                  </p>
                </div>
              )}
            </div>

            {project.instructions && (
              <div className="p-4 rounded-xl bg-stone-50 dark:bg-stone-800">
                <p className="text-xs font-medium text-muted-foreground mb-2">Instructions</p>
                <p className="text-sm text-muted-foreground whitespace-pre-wrap">{project.instructions}</p>
              </div>
            )}

            {project.attachedFiles.length > 0 && (
              <div className="space-y-2">
                <p className="text-sm font-medium">Files</p>
                <AttachedFiles files={project.attachedFiles} />
              </div>
            )}

            <DeliverablesSection status={project.status} deliverables={project.deliverables} />
          </div>
        )}

        {/* Chat Panel */}
        <div className={cn("flex-1 flex flex-col overflow-hidden", mobileTab !== "chat" && "hidden lg:flex")}>
          <ChatPanel projectId={project.id} userId={userId} supervisorName={project.supervisorName} />
        </div>
      </div>

      {/* Step Details Dialog */}
      <Dialog open={selectedStepIndex !== null} onOpenChange={() => setSelectedStepIndex(null)}>
        <DialogContent className="sm:max-w-md rounded-2xl">
          <DialogHeader>
            <div className="flex items-center gap-3 mb-2">
              <div className={cn(
                "h-12 w-12 rounded-xl flex items-center justify-center text-xl",
                selectedStepIndex !== null && selectedStepIndex < stepIndex
                  ? "bg-emerald-100 dark:bg-emerald-900/30"
                  : "bg-violet-100 dark:bg-violet-900/30"
              )}>
                {selectedStepIndex !== null && STEPS[selectedStepIndex]?.emoji}
              </div>
              <div>
                <DialogTitle className="text-left">
                  {selectedStepIndex !== null && STEPS[selectedStepIndex]?.label}
                </DialogTitle>
                <DialogDescription className="text-left">
                  {selectedStepIndex !== null && (
                    selectedStepIndex < stepIndex ? "Completed" : "Current Step"
                  )}
                </DialogDescription>
              </div>
            </div>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <p className="text-sm text-muted-foreground">
              {selectedStepIndex !== null && STEPS[selectedStepIndex]?.details}
            </p>

            {/* Step-specific content */}
            {selectedStepIndex === 0 && (
              <div className="space-y-3">
                <div className="p-3 rounded-xl bg-stone-100 dark:bg-stone-800">
                  <p className="text-xs text-muted-foreground mb-1">Submitted</p>
                  <p className="text-sm font-medium">
                    {project.createdAt
                      ? new Date(project.createdAt).toLocaleDateString("en-IN", {
                          day: "numeric",
                          month: "short",
                          year: "numeric",
                        })
                      : "N/A"}
                  </p>
                </div>
                {project.attachedFiles.length > 0 && (
                  <div className="p-3 rounded-xl bg-stone-100 dark:bg-stone-800">
                    <p className="text-xs text-muted-foreground mb-1">Files Attached</p>
                    <p className="text-sm font-medium">{project.attachedFiles.length} files</p>
                  </div>
                )}
              </div>
            )}

            {selectedStepIndex === 2 && project.budget && (
              <div className="p-4 rounded-xl bg-violet-50 dark:bg-violet-950/30 border border-violet-200 dark:border-violet-800 text-center">
                <p className="text-xs text-violet-600 dark:text-violet-400 mb-1">Quote Amount</p>
                <p className="text-2xl font-bold text-violet-700 dark:text-violet-300">
                  ₹{paymentAmount.toLocaleString()}
                </p>
              </div>
            )}

            {selectedStepIndex === 3 && (
              <div className="p-4 rounded-xl bg-emerald-50 dark:bg-emerald-950/30 border border-emerald-200 dark:border-emerald-800 text-center">
                <CheckCircle2 className="h-8 w-8 text-emerald-600 mx-auto mb-2" />
                <p className="text-sm font-medium text-emerald-700 dark:text-emerald-300">
                  Payment Confirmed
                </p>
              </div>
            )}

            {selectedStepIndex === 4 && project.supervisorName && (
              <div className="flex items-center gap-3 p-3 rounded-xl bg-stone-100 dark:bg-stone-800">
                <div className="h-10 w-10 rounded-xl bg-violet-600 flex items-center justify-center text-white font-medium">
                  {project.supervisorName.charAt(0)}
                </div>
                <div>
                  <p className="text-sm font-medium">{project.supervisorName}</p>
                  <p className="text-xs text-muted-foreground">Assigned Expert</p>
                </div>
              </div>
            )}

            {selectedStepIndex === 7 && isDelivered && (
              <div className="p-4 rounded-xl bg-emerald-50 dark:bg-emerald-950/30 border border-emerald-200 dark:border-emerald-800 text-center">
                <Package className="h-8 w-8 text-emerald-600 mx-auto mb-2" />
                <p className="text-sm font-medium text-emerald-700 dark:text-emerald-300">
                  Project Delivered
                </p>
                <p className="text-xs text-emerald-600/70 dark:text-emerald-400/70 mt-1">
                  Review deliverables in the main view
                </p>
              </div>
            )}
          </div>
          <Button
            variant="outline"
            onClick={() => setSelectedStepIndex(null)}
            className="w-full"
          >
            Close
          </Button>
        </DialogContent>
      </Dialog>

      {/* Razorpay Payment Dialog */}
      <RazorpayCheckout
        open={isPaymentOpen}
        onOpenChange={setIsPaymentOpen}
        amount={paymentAmount}
        type="project_payment"
        projectId={project.id}
        userId={userId}
        onSuccess={handlePaymentSuccess}
        onError={(error) => toast.error(error || "Payment failed")}
      />

      {/* Revision Dialog */}
      <AlertDialog open={isRevisionDialogOpen} onOpenChange={setIsRevisionDialogOpen}>
        <AlertDialogContent className="max-w-md rounded-2xl">
          <AlertDialogHeader>
            <AlertDialogTitle>Request Revision</AlertDialogTitle>
            <AlertDialogDescription>
              Describe what changes you need. Our expert will review and make adjustments.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <div className="py-4">
            <Label htmlFor="revision-feedback" className="text-sm font-medium">
              What changes do you need?
            </Label>
            <Textarea
              id="revision-feedback"
              placeholder="Describe the changes..."
              value={revisionFeedback}
              onChange={(e) => setRevisionFeedback(e.target.value)}
              className="mt-2 min-h-[120px] rounded-xl"
            />
          </div>
          <AlertDialogFooter>
            <Button variant="outline" onClick={() => setIsRevisionDialogOpen(false)} disabled={isSubmittingRevision}>
              Cancel
            </Button>
            <Button
              onClick={handleRequestRevision}
              disabled={isSubmittingRevision || !revisionFeedback.trim()}
              className="bg-violet-600 hover:bg-violet-700"
            >
              {isSubmittingRevision ? (
                <>
                  <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                  Submitting...
                </>
              ) : (
                "Submit"
              )}
            </Button>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      {/* Complete Dialog */}
      <AlertDialog open={isCompleteDialogOpen} onOpenChange={setIsCompleteDialogOpen}>
        <AlertDialogContent className="max-w-md rounded-2xl">
          <AlertDialogHeader>
            <AlertDialogTitle className="flex items-center gap-2">
              <CheckCircle2 className="h-5 w-5 text-emerald-500" />
              Mark Complete
            </AlertDialogTitle>
            <AlertDialogDescription>
              Are you satisfied with the deliverables? The project will be closed but you can still access files.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <Button variant="outline" onClick={() => setIsCompleteDialogOpen(false)} disabled={isMarkingComplete}>
              Cancel
            </Button>
            <Button
              onClick={handleMarkComplete}
              disabled={isMarkingComplete}
              className="bg-emerald-600 hover:bg-emerald-700"
            >
              {isMarkingComplete ? (
                <>
                  <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                  Completing...
                </>
              ) : (
                <>
                  <Check className="h-4 w-4 mr-2" />
                  Complete
                </>
              )}
            </Button>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}

/**
 * Chat Panel Component
 */
interface ChatPanelProps {
  projectId: string;
  userId: string;
  supervisorName?: string;
}

function ChatPanel({ projectId, userId, supervisorName }: ChatPanelProps) {
  const [inputValue, setInputValue] = useState("");
  const [showViolationAlert, setShowViolationAlert] = useState(false);
  const [violationMessage, setViolationMessage] = useState("");
  const [timelineEvents, setTimelineEvents] = useState<TimelineEvent[]>([]);
  const scrollRef = useRef<HTMLDivElement>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const { messages, isLoading, isSending, hasMore, sendMessage, sendMessageWithAttachment, loadMore } = useChat(projectId, userId);

  useEffect(() => {
    const fetchTimeline = async () => {
      try {
        const events = await projectService.getChatTimeline(projectId);
        setTimelineEvents(events);
      } catch (error) {
        console.error("Failed to fetch timeline:", error);
      }
    };
    fetchTimeline();
  }, [projectId]);

  useEffect(() => {
    if (scrollRef.current && messages.length > 0) {
      setTimeout(() => {
        scrollRef.current?.scrollTo({ top: scrollRef.current.scrollHeight, behavior: "smooth" });
      }, 100);
    }
  }, [messages]);

  const handleViolation = useCallback(async (reason: FlagReason, message: string) => {
    if (userId) await flagUserForViolation(userId, reason);
    setViolationMessage(message);
    setShowViolationAlert(true);
    setInputValue("");
  }, [userId]);

  const handleSend = useCallback(async () => {
    if (!inputValue.trim() || isSending) return;
    const validation = validateChatContent(inputValue);
    if (!validation.isValid) {
      const reasonMap: Record<string, FlagReason> = {
        phone: "phone_sharing",
        email: "email_sharing",
        link: "link_sharing",
        address: "address_sharing",
      };
      await handleViolation(reasonMap[validation.reason || ""] || "link_sharing", getValidationErrorMessage(validation));
      return;
    }
    const success = await sendMessage(inputValue);
    if (success) setInputValue("");
  }, [inputValue, isSending, sendMessage, handleViolation]);

  const handleKeyDown = (e: KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  const handleFileSelect = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      if (file.size > 10 * 1024 * 1024) {
        toast.error("Max 10MB");
        return;
      }
      await sendMessageWithAttachment("", file);
      e.target.value = "";
    }
  };

  const supervisor = supervisorName || "Supervisor";

  return (
    <>
      {/* Chat Header */}
      <div className="p-4 border-b border-stone-200 dark:border-stone-800">
        <div className="flex items-center justify-between mb-3">
          <h2 className="text-sm font-semibold">Chat</h2>
          <span className="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full bg-emerald-100 dark:bg-emerald-900/30 text-[10px] font-medium text-emerald-600 dark:text-emerald-400">
            <span className="h-1.5 w-1.5 rounded-full bg-current animate-pulse" />
            Online
          </span>
        </div>
        <div className="flex items-center gap-3 p-3 rounded-xl bg-stone-50 dark:bg-stone-800/50 border border-stone-200 dark:border-stone-700">
          <div className="h-10 w-10 rounded-xl bg-violet-600 flex items-center justify-center text-white font-medium relative">
            {supervisor.charAt(0)}
            <span className="absolute -bottom-0.5 -right-0.5 h-3 w-3 rounded-full bg-emerald-500 border-2 border-white dark:border-stone-900" />
          </div>
          <div>
            <p className="text-sm font-medium">{supervisor}</p>
            <p className="text-xs text-muted-foreground">Project Coordinator</p>
          </div>
        </div>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-4" ref={scrollRef}>
        {hasMore && !isLoading && messages.length > 0 && (
          <button
            onClick={loadMore}
            className="w-full py-2 text-xs text-violet-600 hover:underline flex items-center justify-center gap-1 mb-4"
          >
            <ChevronUp className="h-3 w-3" /> Load earlier
          </button>
        )}

        {isLoading && messages.length === 0 && (
          <div className="flex items-center justify-center h-full">
            <Loader2 className="h-5 w-5 animate-spin text-muted-foreground" />
          </div>
        )}

        {!isLoading && messages.length === 0 && timelineEvents.length === 0 && (
          <div className="flex flex-col items-center justify-center h-full text-center">
            <div className="h-12 w-12 rounded-xl bg-stone-100 dark:bg-stone-800 flex items-center justify-center mb-3">
              <Send className="h-5 w-5 text-muted-foreground" />
            </div>
            <p className="text-sm font-medium mb-1">Start the conversation</p>
            <p className="text-xs text-muted-foreground max-w-[200px]">
              Ask questions or share details about your project
            </p>
          </div>
        )}

        {/* Project Activity Header - shown when there are timeline events */}
        {timelineEvents.length > 0 && messages.length === 0 && !isLoading && (
          <div className="flex justify-center mb-4">
            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-stone-50 dark:bg-stone-900 border border-stone-200 dark:border-stone-800">
              <ClipboardList className="h-3.5 w-3.5 text-muted-foreground" />
              <span className="text-xs font-medium text-muted-foreground">Project Activity</span>
            </div>
          </div>
        )}

        {/* Timeline Events & Messages Combined */}
        {(() => {
          const combined: Array<{ type: "message" | "event"; timestamp: string; data: any }> = [];

          messages.forEach((msg) => {
            combined.push({
              type: "message",
              timestamp: msg.created_at || new Date().toISOString(),
              data: msg,
            });
          });

          timelineEvents.forEach((event) => {
            combined.push({
              type: "event",
              timestamp: event.timestamp,
              data: event,
            });
          });

          combined.sort((a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime());

          return combined.map((item, index) => {
            if (item.type === "event") {
              const event = item.data as TimelineEvent;
              return <TimelineEventCard key={`event-${event.id}`} event={event} supervisorName={supervisor} />;
            }

            const msg = item.data;
            const isUser = msg.sender_id === userId;
            const senderName = msg.sender?.full_name || supervisor;

            return (
              <div key={msg.id} className={cn("flex gap-2 mb-3", isUser ? "flex-row-reverse justify-start" : "justify-start")}>
                <div
                  className={cn(
                    "h-8 w-8 rounded-xl flex items-center justify-center text-xs font-medium shrink-0",
                    isUser
                      ? "bg-violet-600 text-white"
                      : "bg-stone-100 dark:bg-stone-800 text-muted-foreground border border-stone-200 dark:border-stone-700"
                  )}
                >
                  {isUser ? <User className="h-4 w-4" /> : senderName.charAt(0)}
                </div>
                <div className={cn("flex flex-col max-w-[75%]", isUser ? "items-end" : "items-start")}>
                  <div
                    className={cn(
                      "px-4 py-2.5 rounded-2xl text-sm",
                      isUser
                        ? "bg-violet-600 text-white rounded-br-sm"
                        : "bg-stone-100 dark:bg-stone-800 border border-stone-200 dark:border-stone-700 rounded-bl-sm"
                    )}
                  >
                    <p className="whitespace-pre-wrap break-words">{msg.content}</p>
                    {msg.file_url && (
                      <a
                        href={msg.file_url}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="flex items-center gap-1 mt-1 text-xs underline opacity-80"
                      >
                        <Paperclip className="h-3 w-3" /> Attachment
                      </a>
                    )}
                  </div>
                  <span className={cn("text-[10px] text-muted-foreground mt-1 px-1", isUser && "text-right")}>
                    {msg.created_at && formatTime(msg.created_at)}
                  </span>
                </div>
              </div>
            );
          });
        })()}
      </div>

      {/* Input */}
      <div className="p-4 border-t border-stone-200 dark:border-stone-800">
        <div className="flex items-center gap-2 p-1.5 pl-4 rounded-full border border-stone-200 dark:border-stone-700 bg-stone-50 dark:bg-stone-800/50 focus-within:border-violet-500 focus-within:ring-2 focus-within:ring-violet-500/20 transition-all">
          <input
            type="file"
            ref={fileInputRef}
            onChange={handleFileSelect}
            className="hidden"
            accept=".pdf,.doc,.docx,.txt,.png,.jpg,.jpeg"
          />
          <input
            type="text"
            placeholder="Type a message..."
            value={inputValue}
            onChange={(e) => setInputValue(e.target.value)}
            onKeyDown={handleKeyDown}
            disabled={isSending}
            className="flex-1 bg-transparent text-sm outline-none"
          />
          <button
            onClick={() => fileInputRef.current?.click()}
            disabled={isSending}
            className="h-8 w-8 rounded-full flex items-center justify-center text-muted-foreground hover:text-foreground hover:bg-stone-200 dark:hover:bg-stone-700 transition-colors"
          >
            <Paperclip className="h-4 w-4" />
          </button>
          <button
            onClick={handleSend}
            disabled={!inputValue.trim() || isSending}
            className="h-9 w-9 rounded-full bg-violet-600 flex items-center justify-center text-white disabled:opacity-50 hover:bg-violet-700 transition-colors"
          >
            {isSending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Send className="h-4 w-4" />}
          </button>
        </div>
      </div>

      <AlertDialog open={showViolationAlert} onOpenChange={setShowViolationAlert}>
        <AlertDialogContent className="rounded-2xl">
          <AlertDialogHeader>
            <AlertDialogTitle className="flex items-center gap-2 text-red-600">
              <AlertTriangle className="h-5 w-5" /> Policy Violation
            </AlertDialogTitle>
            <AlertDialogDescription>{violationMessage}</AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <Button onClick={() => setShowViolationAlert(false)} variant="destructive">
              I Understand
            </Button>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  );
}

/**
 * WhatsApp-style System Message - Centered notification
 */
function SystemMessage({ emoji, text, timestamp }: { emoji: string; text: string; timestamp: string }) {
  return (
    <div className="flex justify-center my-4">
      <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-stone-100 dark:bg-stone-800 border border-stone-200 dark:border-stone-700 shadow-sm">
        <span className="text-sm">{emoji}</span>
        <span className="text-xs text-muted-foreground">{text}</span>
        <span className="text-[10px] text-muted-foreground/70">{formatTime(timestamp)}</span>
      </div>
    </div>
  );
}

/**
 * Timeline Event Card - WhatsApp-style status messages
 * Shows ALL project events including supervisor/doer assignments, payments, completions
 */
function TimelineEventCard({ event, supervisorName }: { event: TimelineEvent; supervisorName?: string }) {
  const supervisor = supervisorName || "Supervisor";
  const notes = event.data.notes;

  // User-initiated actions (show on right side)
  const userActions = ["paid", "completed", "revision_requested", "submitted"];
  const isUserAction = event.type === "status_change" && userActions.includes(event.data.to_status || "");

  // Comprehensive status configuration for ALL possible statuses
  const statusConfig: Record<string, { label: string; description: string; emoji: string; isSystem?: boolean }> = {
    // Initial stages
    draft: { label: "Draft Created", description: "Project draft has been created", emoji: "📝", isSystem: true },
    submitted: { label: "Project Submitted", description: "Your project has been submitted for review", emoji: "📤" },

    // Review & Quote stages
    analyzing: { label: "Under Review", description: "Our team is reviewing your requirements", emoji: "🔍", isSystem: true },
    quoted: { label: "Quote Prepared", description: "Your quote is ready for review", emoji: "💰", isSystem: true },
    payment_pending: { label: "Awaiting Payment", description: "Please complete the payment to proceed", emoji: "⏳", isSystem: true },

    // Payment
    paid: { label: "Payment Successful", description: "Your payment has been received", emoji: "✅" },

    // Assignment stages - IMPORTANT for "supervisor came in" & "doer assigned"
    assigning: { label: "Finding Expert", description: "We're finding the best expert for your project", emoji: "🔎", isSystem: true },
    assigned: { label: "Expert Assigned", description: notes || "An expert has been assigned to your project", emoji: "👨‍💻", isSystem: true },
    supervisor_assigned: { label: "Supervisor Joined", description: notes || `${supervisor} is now managing your project`, emoji: "👤", isSystem: true },
    doer_assigned: { label: "Doer Assigned", description: notes || "A specialist has been assigned to work on your project", emoji: "👷", isSystem: true },
    expert_joined: { label: "Expert Joined", description: notes || "Expert has joined the project", emoji: "🤝", isSystem: true },

    // Work stages
    in_progress: { label: "Work Started", description: notes || "Your expert has started working on your project", emoji: "⚡", isSystem: true },

    // QC stages
    submitted_for_qc: { label: "Submitted for QC", description: "Work has been submitted for quality review", emoji: "📋", isSystem: true },
    qc_in_progress: { label: "QC In Progress", description: "Quality check is underway", emoji: "🔬", isSystem: true },
    qc_approved: { label: "QC Approved", description: "Work has passed quality checks", emoji: "✓", isSystem: true },
    qc_rejected: { label: "QC Rejected", description: "Work needs improvements before delivery", emoji: "⚠️", isSystem: true },

    // Delivery stages
    delivered: { label: "Delivered", description: notes || "Your project has been delivered", emoji: "🎉", isSystem: true },

    // Revision stages
    revision_requested: { label: "Revision Requested", description: notes || "You requested changes to the delivery", emoji: "🔄" },
    in_revision: { label: "In Revision", description: notes || "Your expert is making the requested changes", emoji: "📝", isSystem: true },

    // Completion stages
    completed: { label: "Marked Complete", description: "You marked this project as complete", emoji: "✅" },
    auto_approved: { label: "Auto-Approved", description: "Project was automatically approved", emoji: "🤖", isSystem: true },

    // Cancellation
    cancelled: { label: "Project Cancelled", description: notes || "This project has been cancelled", emoji: "❌", isSystem: true },
    refunded: { label: "Refund Processed", description: notes || "Your payment has been refunded", emoji: "💸", isSystem: true },
  };

  // Quote card - Special styled card for quotes
  if (event.type === "quote") {
    return (
      <div className="flex gap-2 mb-4">
        <div className="h-8 w-8 rounded-xl flex items-center justify-center text-xs font-medium shrink-0 bg-stone-100 dark:bg-stone-800 text-muted-foreground border border-stone-200 dark:border-stone-700">
          {supervisor.charAt(0)}
        </div>
        <div className="max-w-[80%]">
          <div className="rounded-2xl rounded-tl-md overflow-hidden border border-violet-200 dark:border-violet-800 bg-violet-50 dark:bg-violet-950/30">
            <div className="flex items-center gap-2 px-4 py-2.5 bg-violet-100/50 dark:bg-violet-900/20 border-b border-violet-200 dark:border-violet-800">
              <span className="text-lg">💰</span>
              <div>
                <p className="text-sm font-medium text-violet-700 dark:text-violet-300">Quote Ready</p>
                <p className="text-[10px] text-violet-600/70 dark:text-violet-400/70">Project quotation</p>
              </div>
            </div>
            <div className="p-4 text-center">
              <p className="text-3xl font-bold text-violet-700 dark:text-violet-300">
                ₹{(event.data.amount || 0).toLocaleString()}
              </p>
              <p className="text-xs text-violet-600/70 dark:text-violet-400/70 mt-1">Total Amount</p>
            </div>
          </div>
          <span className="text-[10px] text-muted-foreground mt-1 px-1">{formatTime(event.timestamp)}</span>
        </div>
      </div>
    );
  }

  const status = event.data.to_status || "";
  const config = statusConfig[status] || { label: status.replace(/_/g, " ").replace(/\b\w/g, l => l.toUpperCase()), description: notes || "Status updated", emoji: "📋", isSystem: true };

  // Special card for Payment success
  if (status === "paid") {
    return (
      <div className="flex gap-2 mb-4 flex-row-reverse">
        <div className="h-8 w-8 rounded-xl flex items-center justify-center text-xs font-medium shrink-0 bg-violet-600 text-white">
          <User className="h-4 w-4" />
        </div>
        <div className="max-w-[80%]">
          <div className="rounded-2xl rounded-tr-md overflow-hidden border border-emerald-200 dark:border-emerald-800 bg-emerald-50 dark:bg-emerald-950/30">
            <div className="p-4 text-center">
              <div className="h-12 w-12 rounded-full bg-emerald-500 flex items-center justify-center mx-auto mb-2">
                <CheckCircle2 className="h-6 w-6 text-white" />
              </div>
              <p className="text-sm font-semibold text-emerald-700 dark:text-emerald-300">Payment Successful</p>
              <p className="text-[11px] text-emerald-600/70 dark:text-emerald-400/70 mt-1">Your payment has been received</p>
            </div>
          </div>
          <div className="flex justify-end">
            <span className="text-[10px] text-muted-foreground mt-1 px-1">{formatTime(event.timestamp)}</span>
          </div>
        </div>
      </div>
    );
  }

  // Special card for Project Completed
  if (status === "completed" || status === "auto_approved") {
    return (
      <div className="flex gap-2 mb-4 flex-row-reverse">
        <div className="h-8 w-8 rounded-xl flex items-center justify-center text-xs font-medium shrink-0 bg-violet-600 text-white">
          <User className="h-4 w-4" />
        </div>
        <div className="max-w-[80%]">
          <div className="rounded-2xl rounded-tr-md overflow-hidden border border-emerald-200 dark:border-emerald-800 bg-emerald-50 dark:bg-emerald-950/30">
            <div className="p-4 text-center">
              <div className="h-12 w-12 rounded-full bg-emerald-500 flex items-center justify-center mx-auto mb-2">
                <CheckCircle2 className="h-6 w-6 text-white" />
              </div>
              <p className="text-sm font-semibold text-emerald-700 dark:text-emerald-300">
                {status === "auto_approved" ? "Project Auto-Approved" : "Project Completed"}
              </p>
              <p className="text-[11px] text-emerald-600/70 dark:text-emerald-400/70 mt-1">
                {status === "auto_approved" ? "Project was automatically approved" : "You marked this project as complete"}
              </p>
            </div>
          </div>
          <div className="flex justify-end">
            <span className="text-[10px] text-muted-foreground mt-1 px-1">{formatTime(event.timestamp)}</span>
          </div>
        </div>
      </div>
    );
  }

  // Special card for Supervisor/Expert Assignment (WhatsApp-style "joined" message)
  if (status === "assigned" || status === "assigning" || status === "supervisor_assigned" || status === "doer_assigned" || status === "expert_joined") {
    const assignmentLabel = status === "assigning"
      ? "Finding the best expert for your project..."
      : status === "supervisor_assigned"
        ? `${supervisor} joined as supervisor`
        : status === "doer_assigned"
          ? notes || "A specialist was assigned to your project"
          : notes || `${supervisor} was assigned to your project`;

    return (
      <div className="flex justify-center my-4">
        <div className="inline-flex flex-col items-center gap-1 px-5 py-3 rounded-2xl bg-gradient-to-br from-violet-50 to-purple-50 dark:from-violet-950/30 dark:to-purple-950/30 border border-violet-200 dark:border-violet-800 shadow-sm">
          <div className="flex items-center gap-2">
            <div className="h-8 w-8 rounded-full bg-violet-600 flex items-center justify-center text-white">
              <UserCheck className="h-4 w-4" />
            </div>
            <div>
              <p className="text-sm font-medium text-violet-700 dark:text-violet-300">{config.emoji} {config.label}</p>
              <p className="text-[11px] text-violet-600/70 dark:text-violet-400/70">{assignmentLabel}</p>
            </div>
          </div>
          <span className="text-[10px] text-muted-foreground/70 mt-1">{formatTime(event.timestamp)}</span>
        </div>
      </div>
    );
  }

  // Special card for Delivered (celebration style)
  if (status === "delivered") {
    return (
      <div className="flex justify-center my-4">
        <div className="inline-flex flex-col items-center gap-2 px-6 py-4 rounded-2xl bg-gradient-to-br from-emerald-50 to-green-50 dark:from-emerald-950/30 dark:to-green-950/30 border border-emerald-200 dark:border-emerald-800 shadow-sm">
          <div className="h-12 w-12 rounded-full bg-emerald-500 flex items-center justify-center">
            <Package className="h-6 w-6 text-white" />
          </div>
          <div className="text-center">
            <p className="text-sm font-semibold text-emerald-700 dark:text-emerald-300">🎉 Project Delivered!</p>
            <p className="text-[11px] text-emerald-600/70 dark:text-emerald-400/70 mt-0.5">
              {notes || "Your project has been delivered. Please review the deliverables."}
            </p>
          </div>
          <span className="text-[10px] text-muted-foreground/70">{formatTime(event.timestamp)}</span>
        </div>
      </div>
    );
  }

  // Special card for QC stages (system notification style)
  if (status.startsWith("qc") || status === "submitted_for_qc") {
    const qcColors = status === "qc_approved"
      ? "from-emerald-50 to-green-50 dark:from-emerald-950/30 dark:to-green-950/30 border-emerald-200 dark:border-emerald-800"
      : status === "qc_rejected"
        ? "from-amber-50 to-orange-50 dark:from-amber-950/30 dark:to-orange-950/30 border-amber-200 dark:border-amber-800"
        : "from-blue-50 to-indigo-50 dark:from-blue-950/30 dark:to-indigo-950/30 border-blue-200 dark:border-blue-800";

    const qcTextColor = status === "qc_approved"
      ? "text-emerald-700 dark:text-emerald-300"
      : status === "qc_rejected"
        ? "text-amber-700 dark:text-amber-300"
        : "text-blue-700 dark:text-blue-300";

    return (
      <div className="flex justify-center my-4">
        <div className={cn("inline-flex items-center gap-3 px-5 py-3 rounded-2xl bg-gradient-to-br border shadow-sm", qcColors)}>
          <div className={cn("h-8 w-8 rounded-full flex items-center justify-center",
            status === "qc_approved" ? "bg-emerald-500" : status === "qc_rejected" ? "bg-amber-500" : "bg-blue-500"
          )}>
            <ShieldCheck className="h-4 w-4 text-white" />
          </div>
          <div>
            <p className={cn("text-sm font-medium", qcTextColor)}>{config.emoji} {config.label}</p>
            <p className="text-[11px] text-muted-foreground">{config.description}</p>
          </div>
          <span className="text-[10px] text-muted-foreground/70">{formatTime(event.timestamp)}</span>
        </div>
      </div>
    );
  }

  // Special card for Work Started
  if (status === "in_progress") {
    return (
      <div className="flex justify-center my-4">
        <div className="inline-flex items-center gap-3 px-5 py-3 rounded-2xl bg-gradient-to-br from-amber-50 to-orange-50 dark:from-amber-950/30 dark:to-orange-950/30 border border-amber-200 dark:border-amber-800 shadow-sm">
          <div className="h-8 w-8 rounded-full bg-amber-500 flex items-center justify-center animate-pulse">
            <Zap className="h-4 w-4 text-white" />
          </div>
          <div>
            <p className="text-sm font-medium text-amber-700 dark:text-amber-300">⚡ Work Started</p>
            <p className="text-[11px] text-amber-600/70 dark:text-amber-400/70">
              {notes || "Your expert has started working on your project"}
            </p>
          </div>
          <span className="text-[10px] text-muted-foreground/70">{formatTime(event.timestamp)}</span>
        </div>
      </div>
    );
  }

  // User-initiated status changes (right-aligned bubble)
  if (isUserAction) {
    return (
      <div className="flex gap-2 mb-3 flex-row-reverse">
        <div className="h-8 w-8 rounded-xl flex items-center justify-center text-xs font-medium shrink-0 bg-violet-600 text-white">
          <User className="h-4 w-4" />
        </div>
        <div className="max-w-[75%]">
          <div className="px-4 py-3 rounded-2xl rounded-tr-md bg-violet-600 text-white">
            <div className="flex items-center gap-2 mb-1">
              <span>{config.emoji}</span>
              <span className="text-sm font-medium">{config.label}</span>
            </div>
            <p className="text-xs opacity-80">{notes || config.description}</p>
          </div>
          <div className="flex justify-end">
            <span className="text-[10px] text-muted-foreground mt-1 px-1">{formatTime(event.timestamp)}</span>
          </div>
        </div>
      </div>
    );
  }

  // Default: System/supervisor status changes (WhatsApp-style centered notification)
  return (
    <div className="flex justify-center my-3">
      <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-stone-100 dark:bg-stone-800 border border-stone-200 dark:border-stone-700 shadow-sm">
        <span className="text-sm">{config.emoji}</span>
        <span className="text-xs text-muted-foreground">{config.label}</span>
        {notes && <span className="text-[10px] text-muted-foreground/70">• {notes}</span>}
        <span className="text-[10px] text-muted-foreground/70">{formatTime(event.timestamp)}</span>
      </div>
    </div>
  );
}
