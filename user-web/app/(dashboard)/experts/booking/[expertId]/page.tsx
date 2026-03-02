"use client";

/**
 * ExpertBookingPage - Clean, modern multi-step booking flow
 * Features improved step indicator and clean card design
 */

import { use, useState } from "react";
import { useRouter } from "next/navigation";
import { motion, AnimatePresence } from "framer-motion";
import { format } from "date-fns";
import {
  ArrowLeft,
  ArrowRight,
  Calendar,
  Clock,
  CheckCircle2,
  CreditCard,
  Shield,
  Loader2,
  Video,
  MessageSquare,
  BadgeCheck,
  Star,
  Sparkles,
} from "lucide-react";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { cn } from "@/lib/utils";
import { formatINR } from "@/lib/utils";
import { BookingCalendar, PriceBreakdown } from "@/components/experts";
import { getExpertById } from "@/lib/data/experts";
import { toast } from "sonner";
import type { TimeSlot, ConsultationBooking } from "@/types/expert";
import { COMMISSION_RATES } from "@/types/expert";
import { useBookingStore } from "@/stores";
import { bookExpertSession } from "@/lib/actions/data";

/**
 * Booking steps configuration
 */
type BookingStep = "datetime" | "details" | "payment";

const STEPS = [
  { key: "datetime", label: "Date & Time", icon: Calendar, emoji: "📅" },
  { key: "details", label: "Details", icon: MessageSquare, emoji: "📝" },
  { key: "payment", label: "Payment", icon: CreditCard, emoji: "💳" },
] as const;

/**
 * Expert Booking Page - Clean modern design
 */
export default function ExpertBookingPage({
  params,
}: {
  params: Promise<{ expertId: string }>;
}) {
  const resolvedParams = use(params);
  const router = useRouter();
  const addBooking = useBookingStore((s) => s.addBooking);

  const [currentStep, setCurrentStep] = useState<BookingStep>("datetime");
  const [selectedDate, setSelectedDate] = useState<Date | undefined>();
  const [selectedTimeSlot, setSelectedTimeSlot] = useState<TimeSlot | null>(null);
  const [topic, setTopic] = useState("");
  const [notes, setNotes] = useState("");
  const [isProcessingPayment, setIsProcessingPayment] = useState(false);
  const [showConfirmation, setShowConfirmation] = useState(false);
  const [bookingId, setBookingId] = useState<string | null>(null);

  const expert = getExpertById(resolvedParams.expertId);

  // Handle expert not found
  if (!expert) {
    return (
      <div className="min-h-screen flex items-center justify-center p-4">
        <div className="text-center">
          <div className="text-5xl mb-4">🔍</div>
          <h2 className="text-lg font-semibold mb-2">Expert not found</h2>
          <p className="text-sm text-muted-foreground mb-4">
            The expert you're looking for doesn't exist.
          </p>
          <Button
            variant="outline"
            onClick={() => router.push("/experts")}
          >
            <ArrowLeft className="h-4 w-4 mr-2" />
            Back to Experts
          </Button>
        </div>
      </div>
    );
  }

  /**
   * Get initials from name
   */
  const getInitials = (name: string) => {
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase()
      .slice(0, 2);
  };

  /**
   * Get current step index
   */
  const currentStepIndex = STEPS.findIndex((s) => s.key === currentStep);

  /**
   * Check if can proceed to next step
   */
  const canProceed = () => {
    switch (currentStep) {
      case "datetime":
        return selectedDate && selectedTimeSlot;
      case "details":
        return topic.trim().length > 0;
      case "payment":
        return true;
      default:
        return false;
    }
  };

  /**
   * Navigate to a specific step (only if completed or current)
   */
  const goToStep = (step: BookingStep) => {
    const targetIndex = STEPS.findIndex((s) => s.key === step);
    if (targetIndex <= currentStepIndex) {
      setCurrentStep(step);
    }
  };

  /**
   * Go to next step
   */
  const handleNextStep = () => {
    switch (currentStep) {
      case "datetime":
        setCurrentStep("details");
        break;
      case "details":
        setCurrentStep("payment");
        break;
      case "payment":
        handlePayment();
        break;
    }
  };

  /**
   * Go to previous step
   */
  const handlePrevStep = () => {
    switch (currentStep) {
      case "details":
        setCurrentStep("datetime");
        break;
      case "payment":
        setCurrentStep("details");
        break;
    }
  };

  /**
   * Handle payment processing
   */
  const handlePayment = async () => {
    setIsProcessingPayment(true);

    try {
      // Simulate payment processing
      await new Promise((resolve) => setTimeout(resolve, 2000));

      // Persist booking to database
      const dbResult = await bookExpertSession({
        expertId: expert.id,
        sessionType: "consultation",
        date: selectedDate ? format(selectedDate, "yyyy-MM-dd") : "",
        time: selectedTimeSlot?.time || "",
        topic,
        notes: notes || undefined,
        hourlyRate: expert.pricePerSession,
      });

      // Check for DB error
      if (dbResult?.error) {
        throw new Error(dbResult.error);
      }

      // Generate booking ID from DB response or fallback
      const newBookingId = dbResult?.booking?.id || dbResult?.booking?._id || `BOOK-${Date.now()}`;
      setBookingId(String(newBookingId));

      // Calculate commission split
      const totalAmount = expert.pricePerSession;
      const expertAmount = Math.round(totalAmount * COMMISSION_RATES.EXPERT_PERCENTAGE / 100);
      const platformFee = totalAmount - expertAmount;

      // Update local store for immediate UI feedback
      const newBooking: ConsultationBooking = {
        id: String(newBookingId),
        expertId: expert.id,
        clientId: "current-user",
        date: selectedDate!,
        startTime: selectedTimeSlot!.time,
        endTime: "",
        duration: 60,
        topic,
        notes: notes || undefined,
        status: "upcoming",
        meetLink: `https://meet.google.com/${String(newBookingId).toLowerCase()}`,
        totalAmount,
        expertAmount,
        platformFee,
        currency: "INR",
        paymentId: `pay_${Date.now()}`,
        paymentStatus: "completed",
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      addBooking(newBooking);

      setShowConfirmation(true);
      toast.success("Booking confirmed! Check your email for details.");
    } catch (error) {
      toast.error("Payment failed. Please try again.");
    } finally {
      setIsProcessingPayment(false);
    }
  };

  /**
   * Handle confirmation close
   */
  const handleConfirmationClose = () => {
    setShowConfirmation(false);
    router.push("/experts");
  };

  return (
    <div className="min-h-screen bg-stone-50 dark:bg-stone-950">
      <div className="container max-w-5xl mx-auto px-4 pt-6 pb-36 space-y-6">
        {/* Back Button */}
        <motion.div
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
        >
          <Button
            variant="ghost"
            size="sm"
            onClick={() => router.push(`/experts/${expert.id}`)}
            className="gap-2 text-muted-foreground hover:text-foreground"
          >
            <ArrowLeft className="h-4 w-4" />
            Back to Profile
          </Button>
        </motion.div>

        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center"
        >
          <h1 className="text-2xl font-bold mb-1">Book Consultation</h1>
          <p className="text-muted-foreground">
            Schedule your session with {expert.name}
          </p>
        </motion.div>

        {/* Step Indicator - Clickable capsules */}
        <div className="flex items-center justify-center gap-2 flex-wrap">
          {STEPS.map((step, index) => {
            const isCompleted = index < currentStepIndex;
            const isCurrent = index === currentStepIndex;
            const isClickable = index <= currentStepIndex;

            return (
              <div key={step.key} className="flex items-center">
                <motion.button
                  whileHover={isClickable ? { scale: 1.02 } : {}}
                  whileTap={isClickable ? { scale: 0.98 } : {}}
                  onClick={() => isClickable && goToStep(step.key)}
                  disabled={!isClickable}
                  className={cn(
                    "flex items-center gap-2 px-4 py-2.5 rounded-full text-sm font-medium transition-all duration-200",
                    isCompleted &&
                      "bg-emerald-100 dark:bg-emerald-900/30 text-emerald-700 dark:text-emerald-300 cursor-pointer",
                    isCurrent &&
                      "bg-violet-600 text-white shadow-md shadow-violet-500/25",
                    !isCompleted &&
                      !isCurrent &&
                      "bg-stone-100 dark:bg-stone-800 text-stone-400 dark:text-stone-500 cursor-not-allowed"
                  )}
                >
                  {isCompleted ? (
                    <CheckCircle2 className="h-4 w-4" />
                  ) : (
                    <span>{step.emoji}</span>
                  )}
                  <span className="hidden sm:inline">{step.label}</span>
                  <span className="sm:hidden">{index + 1}</span>
                </motion.button>

                {index < STEPS.length - 1 && (
                  <div
                    className={cn(
                      "w-8 h-0.5 mx-2",
                      index < currentStepIndex
                        ? "bg-emerald-500"
                        : "bg-stone-200 dark:bg-stone-700"
                    )}
                  />
                )}
              </div>
            );
          })}
        </div>

        <div className="grid md:grid-cols-3 gap-6">
          {/* Main Content */}
          <div className="md:col-span-2">
            <AnimatePresence mode="wait">
              {/* Step 1: Date & Time Selection */}
              {currentStep === "datetime" && (
                <motion.div
                  key="datetime"
                  initial={{ opacity: 0, x: 20 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0, x: -20 }}
                >
                  <BookingCalendar
                    expertId={expert.id}
                    selectedDate={selectedDate}
                    selectedTimeSlot={selectedTimeSlot}
                    onDateSelect={setSelectedDate}
                    onTimeSlotSelect={setSelectedTimeSlot}
                  />
                </motion.div>
              )}

              {/* Step 2: Session Details */}
              {currentStep === "details" && (
                <motion.div
                  key="details"
                  initial={{ opacity: 0, x: 20 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0, x: -20 }}
                  className="space-y-4"
                >
                  <div className="rounded-2xl bg-white dark:bg-stone-900 border border-stone-200 dark:border-stone-800 overflow-hidden">
                    <div className="p-5 border-b border-stone-100 dark:border-stone-800">
                      <h3 className="font-semibold flex items-center gap-2">
                        <span>📝</span>
                        Session Details
                      </h3>
                    </div>
                    <div className="p-5 space-y-5">
                      <div className="space-y-2">
                        <Label htmlFor="topic" className="text-sm font-medium">
                          Topic / Subject{" "}
                          <span className="text-red-500">*</span>
                        </Label>
                        <Input
                          id="topic"
                          placeholder="e.g., Machine Learning Project Help"
                          value={topic}
                          onChange={(e) => setTopic(e.target.value)}
                          maxLength={100}
                          className="h-12 rounded-xl border-stone-200 dark:border-stone-700"
                        />
                        <p className="text-xs text-muted-foreground">
                          Brief description of what you need help with
                        </p>
                      </div>

                      <div className="space-y-2">
                        <Label htmlFor="notes" className="text-sm font-medium">
                          Additional Notes (Optional)
                        </Label>
                        <Textarea
                          id="notes"
                          placeholder="Any specific questions or materials you want to discuss..."
                          value={notes}
                          onChange={(e) => setNotes(e.target.value)}
                          rows={4}
                          maxLength={500}
                          className="rounded-xl border-stone-200 dark:border-stone-700 resize-none"
                        />
                        <p className="text-xs text-muted-foreground text-right">
                          {notes.length}/500
                        </p>
                      </div>
                    </div>
                  </div>

                  {/* Selected Date/Time Summary */}
                  {selectedDate && selectedTimeSlot && (
                    <div className="rounded-2xl bg-violet-50 dark:bg-violet-950/30 border border-violet-100 dark:border-violet-900/50 p-4">
                      <p className="text-xs font-medium text-violet-600 dark:text-violet-400 mb-2">
                        Selected Time
                      </p>
                      <div className="flex items-center gap-4 text-sm">
                        <div className="flex items-center gap-1.5">
                          <Calendar className="h-4 w-4 text-violet-500" />
                          <span className="font-medium">
                            {format(selectedDate, "EEE, MMM d")}
                          </span>
                        </div>
                        <div className="flex items-center gap-1.5">
                          <Clock className="h-4 w-4 text-violet-500" />
                          <span className="font-medium">
                            {selectedTimeSlot.displayTime}
                          </span>
                        </div>
                      </div>
                    </div>
                  )}
                </motion.div>
              )}

              {/* Step 3: Payment */}
              {currentStep === "payment" && (
                <motion.div
                  key="payment"
                  initial={{ opacity: 0, x: 20 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0, x: -20 }}
                  className="space-y-4"
                >
                  {/* Session Summary */}
                  <div className="rounded-2xl bg-white dark:bg-stone-900 border border-stone-200 dark:border-stone-800 overflow-hidden">
                    <div className="p-5 border-b border-stone-100 dark:border-stone-800">
                      <h3 className="font-semibold flex items-center gap-2">
                        <span>📋</span>
                        Session Summary
                      </h3>
                    </div>
                    <div className="p-5 space-y-4">
                      {/* Expert */}
                      <div className="flex items-center gap-3">
                        <div className="relative">
                          <div className="absolute -inset-0.5 bg-gradient-to-br from-violet-400 to-purple-500 rounded-full opacity-60" />
                          <Avatar className="relative h-12 w-12 border-2 border-white dark:border-stone-900">
                            <AvatarImage src={expert.avatar} alt={expert.name} />
                            <AvatarFallback className="bg-violet-100 dark:bg-violet-900/50 text-violet-700">
                              {getInitials(expert.name)}
                            </AvatarFallback>
                          </Avatar>
                        </div>
                        <div>
                          <div className="flex items-center gap-1.5">
                            <p className="font-medium">{expert.name}</p>
                            {expert.verified && (
                              <BadgeCheck className="h-4 w-4 text-violet-500" />
                            )}
                          </div>
                          <p className="text-sm text-muted-foreground">
                            {expert.designation}
                          </p>
                        </div>
                      </div>

                      <div className="h-px bg-stone-100 dark:bg-stone-800" />

                      {/* Details */}
                      <div className="space-y-3">
                        <div className="flex items-center gap-3 text-sm">
                          <div className="h-8 w-8 rounded-lg bg-stone-100 dark:bg-stone-800 flex items-center justify-center">
                            <Calendar className="h-4 w-4 text-stone-500" />
                          </div>
                          <span>
                            {selectedDate
                              ? format(selectedDate, "EEEE, MMMM d, yyyy")
                              : "-"}
                          </span>
                        </div>
                        <div className="flex items-center gap-3 text-sm">
                          <div className="h-8 w-8 rounded-lg bg-stone-100 dark:bg-stone-800 flex items-center justify-center">
                            <Clock className="h-4 w-4 text-stone-500" />
                          </div>
                          <span>
                            {selectedTimeSlot?.displayTime} (60 min)
                          </span>
                        </div>
                        <div className="flex items-center gap-3 text-sm">
                          <div className="h-8 w-8 rounded-lg bg-stone-100 dark:bg-stone-800 flex items-center justify-center">
                            <Video className="h-4 w-4 text-stone-500" />
                          </div>
                          <span>Google Meet (link will be shared)</span>
                        </div>
                        <div className="flex items-center gap-3 text-sm">
                          <div className="h-8 w-8 rounded-lg bg-stone-100 dark:bg-stone-800 flex items-center justify-center">
                            <MessageSquare className="h-4 w-4 text-stone-500" />
                          </div>
                          <span className="line-clamp-1">{topic}</span>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Price Breakdown */}
                  <PriceBreakdown
                    totalAmount={expert.pricePerSession}
                    currency="INR"
                    showDetails
                  />

                  {/* Payment Method */}
                  <div className="rounded-2xl bg-white dark:bg-stone-900 border border-stone-200 dark:border-stone-800 overflow-hidden">
                    <div className="p-5 border-b border-stone-100 dark:border-stone-800">
                      <h3 className="font-semibold flex items-center gap-2">
                        <span>💳</span>
                        Payment Method
                      </h3>
                    </div>
                    <div className="p-5">
                      <div className="flex items-center gap-3 p-4 rounded-xl border-2 border-violet-200 dark:border-violet-800 bg-violet-50 dark:bg-violet-950/30">
                        <div className="h-10 w-10 rounded-lg bg-violet-100 dark:bg-violet-900/50 flex items-center justify-center">
                          <CreditCard className="h-5 w-5 text-violet-600 dark:text-violet-400" />
                        </div>
                        <div className="flex-1">
                          <p className="font-medium text-sm">Razorpay</p>
                          <p className="text-xs text-muted-foreground">
                            UPI, Cards, Net Banking, Wallets
                          </p>
                        </div>
                        <span className="px-2 py-1 rounded-full bg-emerald-100 dark:bg-emerald-900/30 text-emerald-700 dark:text-emerald-300 text-xs font-medium">
                          Secure
                        </span>
                      </div>
                    </div>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>

            {/* Navigation Buttons */}
            <div className="flex items-center justify-between mt-6 pt-6 border-t border-stone-200 dark:border-stone-800">
              {currentStep !== "datetime" ? (
                <Button
                  variant="outline"
                  onClick={handlePrevStep}
                  className="gap-2"
                >
                  <ArrowLeft className="h-4 w-4" />
                  Back
                </Button>
              ) : (
                <div />
              )}
              <Button
                onClick={handleNextStep}
                disabled={!canProceed() || isProcessingPayment}
                className="gap-2 bg-violet-600 hover:bg-violet-700 text-white shadow-lg shadow-violet-500/25"
              >
                {isProcessingPayment ? (
                  <>
                    <Loader2 className="h-4 w-4 animate-spin" />
                    Processing...
                  </>
                ) : currentStep === "payment" ? (
                  <>
                    Pay {formatINR(expert.pricePerSession)}
                    <Sparkles className="h-4 w-4" />
                  </>
                ) : (
                  <>
                    Continue
                    <ArrowRight className="h-4 w-4" />
                  </>
                )}
              </Button>
            </div>
          </div>

          {/* Sidebar - Expert Info */}
          <div className="space-y-4">
            {/* Expert Card */}
            <div className="rounded-2xl bg-white dark:bg-stone-900 border border-stone-200 dark:border-stone-800 overflow-hidden">
              <div className="p-5">
                <div className="flex items-center gap-3 mb-4">
                  <div className="relative">
                    <div className="absolute -inset-0.5 bg-gradient-to-br from-violet-400 to-purple-500 rounded-full opacity-60" />
                    <Avatar className="relative h-12 w-12 border-2 border-white dark:border-stone-900">
                      <AvatarImage src={expert.avatar} alt={expert.name} />
                      <AvatarFallback className="bg-violet-100 dark:bg-violet-900/50 text-violet-700">
                        {getInitials(expert.name)}
                      </AvatarFallback>
                    </Avatar>
                  </div>
                  <div>
                    <div className="flex items-center gap-1.5">
                      <p className="font-medium">{expert.name}</p>
                      {expert.verified && (
                        <BadgeCheck className="h-4 w-4 text-violet-500" />
                      )}
                    </div>
                    <p className="text-xs text-muted-foreground">
                      {expert.designation}
                    </p>
                  </div>
                </div>

                {/* Rating */}
                <div className="flex items-center gap-2 mb-4">
                  <div className="flex items-center gap-1 px-2 py-1 rounded-full bg-amber-50 dark:bg-amber-900/20">
                    <Star className="h-3.5 w-3.5 fill-amber-500 text-amber-500" />
                    <span className="text-sm font-semibold text-amber-700 dark:text-amber-400">
                      {expert.rating.toFixed(1)}
                    </span>
                  </div>
                  <span className="text-xs text-muted-foreground">
                    {expert.totalSessions}+ sessions
                  </span>
                </div>

                {/* Price */}
                <div className="text-center p-4 rounded-xl bg-stone-50 dark:bg-stone-800/50">
                  <span className="text-2xl font-bold">
                    {formatINR(expert.pricePerSession)}
                  </span>
                  <span className="text-muted-foreground">/session</span>
                </div>
              </div>
            </div>

            {/* Trust Indicators */}
            <div className="rounded-2xl bg-white dark:bg-stone-900 border border-stone-200 dark:border-stone-800 p-5 space-y-3">
              <div className="flex items-center gap-3 text-sm">
                <div className="h-8 w-8 rounded-lg bg-emerald-100 dark:bg-emerald-900/30 flex items-center justify-center">
                  <Shield className="h-4 w-4 text-emerald-600 dark:text-emerald-400" />
                </div>
                <span className="text-muted-foreground">Secure payment</span>
              </div>
              <div className="flex items-center gap-3 text-sm">
                <div className="h-8 w-8 rounded-lg bg-emerald-100 dark:bg-emerald-900/30 flex items-center justify-center">
                  <CheckCircle2 className="h-4 w-4 text-emerald-600 dark:text-emerald-400" />
                </div>
                <span className="text-muted-foreground">
                  100% money-back guarantee
                </span>
              </div>
              <div className="flex items-center gap-3 text-sm">
                <div className="h-8 w-8 rounded-lg bg-emerald-100 dark:bg-emerald-900/30 flex items-center justify-center">
                  <Video className="h-4 w-4 text-emerald-600 dark:text-emerald-400" />
                </div>
                <span className="text-muted-foreground">Google Meet session</span>
              </div>
              <div className="flex items-center gap-3 text-sm">
                <div className="h-8 w-8 rounded-lg bg-emerald-100 dark:bg-emerald-900/30 flex items-center justify-center">
                  <Clock className="h-4 w-4 text-emerald-600 dark:text-emerald-400" />
                </div>
                <span className="text-muted-foreground">60 minute duration</span>
              </div>
            </div>
          </div>
        </div>

        {/* Confirmation Dialog */}
        <Dialog open={showConfirmation} onOpenChange={setShowConfirmation}>
          <DialogContent className="sm:max-w-md rounded-2xl">
            <DialogHeader>
              <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-emerald-100 dark:bg-emerald-900/30">
                <CheckCircle2 className="h-8 w-8 text-emerald-600" />
              </div>
              <DialogTitle className="text-center text-xl">
                Booking Confirmed!
              </DialogTitle>
              <DialogDescription className="text-center">
                Your consultation has been scheduled successfully.
              </DialogDescription>
            </DialogHeader>
            <div className="space-y-4 py-4">
              <div className="text-center p-3 rounded-xl bg-stone-100 dark:bg-stone-800">
                <p className="text-xs text-muted-foreground mb-1">Booking ID</p>
                <p className="font-mono font-medium">{bookingId}</p>
              </div>
              <div className="rounded-xl border border-stone-200 dark:border-stone-800 divide-y divide-stone-200 dark:divide-stone-800">
                <div className="flex justify-between p-3 text-sm">
                  <span className="text-muted-foreground">Expert</span>
                  <span className="font-medium">{expert.name}</span>
                </div>
                <div className="flex justify-between p-3 text-sm">
                  <span className="text-muted-foreground">Date</span>
                  <span className="font-medium">
                    {selectedDate ? format(selectedDate, "MMM d, yyyy") : "-"}
                  </span>
                </div>
                <div className="flex justify-between p-3 text-sm">
                  <span className="text-muted-foreground">Time</span>
                  <span className="font-medium">
                    {selectedTimeSlot?.displayTime}
                  </span>
                </div>
                <div className="flex justify-between p-3 text-sm">
                  <span className="text-muted-foreground">Amount Paid</span>
                  <span className="font-medium text-emerald-600 dark:text-emerald-400">
                    {formatINR(expert.pricePerSession)}
                  </span>
                </div>
              </div>
              <p className="text-xs text-muted-foreground text-center">
                A confirmation email with the Google Meet link has been sent to
                your registered email address.
              </p>
            </div>
            <DialogFooter className="flex-col sm:flex-row gap-2">
              <Button
                variant="outline"
                onClick={() => router.push("/home")}
                className="w-full sm:w-auto"
              >
                Go to Dashboard
              </Button>
              <Button
                onClick={handleConfirmationClose}
                className="w-full sm:w-auto bg-violet-600 hover:bg-violet-700"
              >
                View My Consultations
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>
    </div>
  );
}
