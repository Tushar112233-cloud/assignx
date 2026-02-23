"use client";

import { useState } from "react";
import { Calendar, Clock, Loader2 } from "lucide-react";
import { motion } from "framer-motion";
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetDescription,
  SheetFooter,
} from "@/components/ui/sheet";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Calendar as CalendarComponent } from "@/components/ui/calendar";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import { bookExpertSession } from "@/lib/actions/data";
import type { Tutor, TimeSlot } from "@/types/connect";
import { availableTimeSlots } from "@/lib/data/connect";

interface BookSessionSheetProps {
  tutor: Tutor | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onSuccess?: () => void;
}

const durations = [
  { value: "30", label: "30 min", multiplier: 0.5 },
  { value: "60", label: "1 hour", multiplier: 1 },
  { value: "90", label: "1.5 hours", multiplier: 1.5 },
  { value: "120", label: "2 hours", multiplier: 2 },
];

/**
 * Book Session Sheet - Minimalist Design
 */
export function BookSessionSheet({
  tutor,
  open,
  onOpenChange,
  onSuccess,
}: BookSessionSheetProps) {
  const [selectedDate, setSelectedDate] = useState<Date | undefined>();
  const [selectedTimeSlot, setSelectedTimeSlot] = useState<string>("");
  const [duration, setDuration] = useState("60");
  const [notes, setNotes] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  if (!tutor) return null;

  const getInitials = (name: string) => {
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase()
      .slice(0, 2);
  };

  const selectedDuration = durations.find((d) => d.value === duration);
  const totalPrice = tutor.hourlyRate * (selectedDuration?.multiplier || 1);

  const handleSubmit = async () => {
    if (!selectedDate || !selectedTimeSlot) {
      toast.error("Please select a date and time");
      return;
    }

    setIsSubmitting(true);

    try {
      const timeSlot = availableTimeSlots.find((s: TimeSlot) => s.id === selectedTimeSlot);

      const result = await bookExpertSession({
        expertId: tutor.id,
        sessionType: `${duration}-minute session`,
        date: selectedDate.toISOString().split("T")[0],
        time: timeSlot?.time || selectedTimeSlot,
        topic: `Session with ${tutor.name} - ${tutor.subjects[0] || "General"}`,
        notes: notes || undefined,
      });

      if (result.error) {
        toast.error(result.error);
        return;
      }

      toast.success("Session booked successfully!");
      onOpenChange(false);
      onSuccess?.();

      // Reset form
      setSelectedDate(undefined);
      setSelectedTimeSlot("");
      setDuration("60");
      setNotes("");
    } catch {
      toast.error("Failed to book session. Please try again.");
    } finally {
      setIsSubmitting(false);
    }
  };

  const isDateDisabled = (date: Date) => {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    return date < today;
  };

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent side="bottom" className="h-[85vh] rounded-t-2xl flex flex-col">
        <SheetHeader>
          <div className="flex items-center gap-3">
            <Avatar className="h-10 w-10">
              <AvatarImage src={tutor.avatar} alt={tutor.name} />
              <AvatarFallback className="text-sm">{getInitials(tutor.name)}</AvatarFallback>
            </Avatar>
            <div>
              <SheetTitle className="text-base">Book Session</SheetTitle>
              <SheetDescription className="text-sm">with {tutor.name}</SheetDescription>
            </div>
          </div>
        </SheetHeader>

        <div className="flex-1 overflow-y-auto px-4 space-y-6">
          {/* Date Selection */}
          <div className="space-y-2">
            <Label className="flex items-center gap-2 text-sm">
              <Calendar className="h-3.5 w-3.5" />
              Select Date
            </Label>
            <div className="flex justify-center rounded-xl border border-border p-3">
              <CalendarComponent
                mode="single"
                selected={selectedDate}
                onSelect={setSelectedDate}
                disabled={isDateDisabled}
                className="w-full"
              />
            </div>
          </div>

          {/* Time Slot Selection */}
          {selectedDate && (
            <div className="space-y-2">
              <Label className="flex items-center gap-2 text-sm">
                <Clock className="h-3.5 w-3.5" />
                Select Time
              </Label>
              <div className="grid grid-cols-4 gap-2">
                {availableTimeSlots.map((slot: TimeSlot) => (
                  <motion.button
                    key={slot.id}
                    type="button"
                    disabled={!slot.available}
                    whileHover={slot.available ? { scale: 1.02 } : undefined}
                    whileTap={slot.available ? { scale: 0.98 } : undefined}
                    onClick={() => setSelectedTimeSlot(slot.id)}
                    className={cn(
                      "rounded-lg border p-2 text-sm transition-colors",
                      slot.available
                        ? selectedTimeSlot === slot.id
                          ? "border-primary bg-primary text-primary-foreground"
                          : "border-border hover:border-foreground/20"
                        : "cursor-not-allowed opacity-40 border-border"
                    )}
                  >
                    {slot.time}
                  </motion.button>
                ))}
              </div>
            </div>
          )}

          {/* Duration Selection */}
          <div className="space-y-2">
            <Label className="text-sm">Duration</Label>
            <Select value={duration} onValueChange={setDuration}>
              <SelectTrigger>
                <SelectValue placeholder="Select duration" />
              </SelectTrigger>
              <SelectContent>
                {durations.map((d) => (
                  <SelectItem key={d.value} value={d.value}>
                    {d.label} ({tutor.hourlyRate * d.multiplier})
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {/* Notes */}
          <div className="space-y-2">
            <Label htmlFor="notes" className="text-sm">Notes (Optional)</Label>
            <Textarea
              id="notes"
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              placeholder="What would you like to focus on?"
              rows={2}
              className="resize-none"
            />
          </div>

          {/* Price Summary */}
          <div className="rounded-xl border border-border bg-muted/50 p-4 space-y-2">
            <div className="flex items-center justify-between text-sm">
              <span className="text-muted-foreground">Rate</span>
              <span>{tutor.hourlyRate}/hour</span>
            </div>
            <div className="flex items-center justify-between text-sm">
              <span className="text-muted-foreground">Duration</span>
              <span>{selectedDuration?.label}</span>
            </div>
            <div className="flex items-center justify-between pt-2 border-t border-border">
              <span className="font-medium">Total</span>
              <span className="text-lg font-semibold">{totalPrice}</span>
            </div>
          </div>
        </div>

        <SheetFooter>
          <motion.div whileTap={{ scale: 0.98 }} className="w-full">
            <Button
              className="w-full"
              onClick={handleSubmit}
              disabled={isSubmitting || !selectedDate || !selectedTimeSlot}
            >
              {isSubmitting ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Booking...
                </>
              ) : (
                <>Confirm Booking - {totalPrice}</>
              )}
            </Button>
          </motion.div>
        </SheetFooter>
      </SheetContent>
    </Sheet>
  );
}
