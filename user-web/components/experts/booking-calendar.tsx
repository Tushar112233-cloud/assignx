"use client";

import { useState, useMemo } from "react";
import { format, addDays, isSameDay, isAfter, startOfDay, isBefore } from "date-fns";
import { ChevronLeft, ChevronRight, Clock } from "lucide-react";
import { Calendar } from "@/components/ui/calendar";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";
import type { AvailabilitySlot, TimeSlot } from "@/types/expert";

interface BookingCalendarProps {
  expertId: string;
  availableSlots?: AvailabilitySlot[];
  selectedDate: Date | undefined;
  selectedTimeSlot: TimeSlot | null;
  onDateSelect: (date: Date | undefined) => void;
  onTimeSlotSelect: (slot: TimeSlot) => void;
  className?: string;
}

/**
 * Default time slots when no availability data is provided
 */
const DEFAULT_TIME_SLOTS: TimeSlot[] = [
  { id: "slot-1", time: "09:00", displayTime: "9:00 AM", available: true },
  { id: "slot-2", time: "10:00", displayTime: "10:00 AM", available: true },
  { id: "slot-3", time: "11:00", displayTime: "11:00 AM", available: true },
  { id: "slot-4", time: "12:00", displayTime: "12:00 PM", available: false },
  { id: "slot-5", time: "14:00", displayTime: "2:00 PM", available: true },
  { id: "slot-6", time: "15:00", displayTime: "3:00 PM", available: true },
  { id: "slot-7", time: "16:00", displayTime: "4:00 PM", available: true },
  { id: "slot-8", time: "17:00", displayTime: "5:00 PM", available: false },
  { id: "slot-9", time: "18:00", displayTime: "6:00 PM", available: true },
  { id: "slot-10", time: "19:00", displayTime: "7:00 PM", available: true },
];

/**
 * Booking calendar component with date and time slot selection
 * Highlights available dates and allows time slot picking
 */
export function BookingCalendar({
  expertId,
  availableSlots,
  selectedDate,
  selectedTimeSlot,
  onDateSelect,
  onTimeSlotSelect,
  className,
}: BookingCalendarProps) {
  const today = startOfDay(new Date());
  const maxDate = addDays(today, 30); // Allow booking up to 30 days in advance

  /**
   * Get available dates from slots
   */
  const availableDates = useMemo(() => {
    if (!availableSlots?.length) {
      // Default: all weekdays for next 30 days
      const dates: Date[] = [];
      for (let i = 1; i <= 30; i++) {
        const date = addDays(today, i);
        const dayOfWeek = date.getDay();
        // Skip weekends (0 = Sunday, 6 = Saturday)
        if (dayOfWeek !== 0 && dayOfWeek !== 6) {
          dates.push(date);
        }
      }
      return dates;
    }

    return availableSlots
      .filter((slot) => !slot.isBooked)
      .map((slot) => startOfDay(new Date(slot.date)));
  }, [availableSlots, today]);

  /**
   * Get time slots for selected date
   */
  const timeSlotsForDate = useMemo(() => {
    if (!selectedDate) return [];

    if (!availableSlots?.length) {
      // Return default slots with random availability for demo
      return DEFAULT_TIME_SLOTS.map((slot) => ({
        ...slot,
        id: `${format(selectedDate, "yyyy-MM-dd")}-${slot.time}`,
        available: Math.random() > 0.3, // 70% chance of being available
      }));
    }

    const dateSlots = availableSlots.filter((slot) =>
      isSameDay(new Date(slot.date), selectedDate)
    );

    return dateSlots.map((slot) => ({
      id: slot.id,
      time: slot.startTime,
      displayTime: format(new Date(`2000-01-01T${slot.startTime}`), "h:mm a"),
      available: !slot.isBooked,
    }));
  }, [selectedDate, availableSlots]);

  /**
   * Check if a date is available
   */
  const isDateAvailable = (date: Date) => {
    return availableDates.some((d) => isSameDay(d, date));
  };

  /**
   * Calendar disabled dates matcher
   */
  const disabledDays = (date: Date) => {
    // Disable past dates
    if (isBefore(date, today)) return true;
    // Disable dates beyond max
    if (isAfter(date, maxDate)) return true;
    // Disable unavailable dates
    return !isDateAvailable(date);
  };

  return (
    <div className={cn("space-y-4", className)}>
      {/* Calendar */}
      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-base flex items-center gap-2">
            <Clock className="h-4 w-4" />
            Select Date
          </CardTitle>
        </CardHeader>
        <CardContent>
          <Calendar
            mode="single"
            selected={selectedDate}
            onSelect={onDateSelect}
            disabled={disabledDays}
            className="rounded-md border-0 p-0"
            classNames={{
              day: "h-9 w-9 text-center text-sm p-0 relative [&:has([aria-selected])]:bg-accent first:[&:has([aria-selected])]:rounded-l-md last:[&:has([aria-selected])]:rounded-r-md focus-within:relative focus-within:z-20",
              day_selected:
                "bg-primary text-primary-foreground hover:bg-primary hover:text-primary-foreground focus:bg-primary focus:text-primary-foreground",
              day_today: "bg-accent text-accent-foreground",
              day_outside: "text-muted-foreground opacity-50",
              day_disabled: "text-muted-foreground opacity-50",
            }}
            modifiers={{
              available: availableDates,
            }}
            modifiersStyles={{
              available: {
                fontWeight: "bold",
                color: "var(--primary)",
              },
            }}
          />
          <div className="flex items-center gap-4 mt-4 text-xs text-muted-foreground">
            <div className="flex items-center gap-1.5">
              <div className="w-3 h-3 rounded bg-primary" />
              <span>Selected</span>
            </div>
            <div className="flex items-center gap-1.5">
              <div className="w-3 h-3 rounded bg-accent" />
              <span>Today</span>
            </div>
            <div className="flex items-center gap-1.5">
              <div className="w-3 h-3 rounded bg-muted" />
              <span>Unavailable</span>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Time Slots */}
      {selectedDate && (
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-base">
              Available Times for {format(selectedDate, "EEEE, MMM d")}
            </CardTitle>
          </CardHeader>
          <CardContent>
            {timeSlotsForDate.length === 0 ? (
              <p className="text-sm text-muted-foreground text-center py-4">
                No available time slots for this date
              </p>
            ) : (
              <div className="grid grid-cols-3 sm:grid-cols-4 gap-2">
                {timeSlotsForDate.map((slot) => (
                  <Button
                    key={slot.id}
                    variant={selectedTimeSlot?.id === slot.id ? "default" : "outline"}
                    size="sm"
                    disabled={!slot.available}
                    onClick={() => onTimeSlotSelect(slot)}
                    className={cn(
                      "h-10 text-sm",
                      !slot.available && "opacity-50 cursor-not-allowed"
                    )}
                  >
                    {slot.displayTime}
                  </Button>
                ))}
              </div>
            )}
            <p className="text-xs text-muted-foreground mt-3">
              Session duration: 60 minutes
            </p>
          </CardContent>
        </Card>
      )}

      {/* Selection Summary */}
      {selectedDate && selectedTimeSlot && (
        <Card className="bg-primary/5 border-primary/20">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium">Selected Session</p>
                <p className="text-lg font-semibold">
                  {format(selectedDate, "EEEE, MMMM d, yyyy")}
                </p>
                <p className="text-sm text-muted-foreground">
                  {selectedTimeSlot.displayTime} (60 min)
                </p>
              </div>
              <Badge variant="secondary" className="bg-green-500/10 text-green-600">
                Available
              </Badge>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
