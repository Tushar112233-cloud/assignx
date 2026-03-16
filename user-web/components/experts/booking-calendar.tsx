"use client";

import { useState, useMemo, useEffect } from "react";
import { format, addDays, isSameDay, isAfter, startOfDay, isBefore } from "date-fns";
import { ChevronLeft, ChevronRight, Clock, Loader2 } from "lucide-react";
import { Calendar } from "@/components/ui/calendar";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";
import { fetchExpertAvailability } from "@/lib/data/experts";
import type { AvailabilitySlot, TimeSlot } from "@/types/expert";

interface ExpertAvailabilitySlot {
  day: string;
  startTime: string;
  endTime: string;
}

interface BookingCalendarProps {
  expertId: string;
  availableSlots?: AvailabilitySlot[];
  expertAvailability?: ExpertAvailabilitySlot[];
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
  { id: "slot-4", time: "12:00", displayTime: "12:00 PM", available: true },
  { id: "slot-5", time: "13:00", displayTime: "1:00 PM", available: true },
  { id: "slot-6", time: "14:00", displayTime: "2:00 PM", available: true },
  { id: "slot-7", time: "15:00", displayTime: "3:00 PM", available: true },
  { id: "slot-8", time: "16:00", displayTime: "4:00 PM", available: true },
  { id: "slot-9", time: "17:00", displayTime: "5:00 PM", available: true },
];

/**
 * Booking calendar component with date and time slot selection
 * Highlights available dates and allows time slot picking
 */
const DAY_MAP: Record<number, string> = {
  0: "sunday", 1: "monday", 2: "tuesday", 3: "wednesday",
  4: "thursday", 5: "friday", 6: "saturday",
};

function generateSlotsFromRange(startTime: string, endTime: string, dateStr: string): TimeSlot[] {
  const slots: TimeSlot[] = [];
  const [startH] = startTime.split(":").map(Number);
  const [endH] = endTime.split(":").map(Number);
  for (let h = startH; h < endH; h++) {
    const time = `${String(h).padStart(2, "0")}:00`;
    const displayHour = h > 12 ? h - 12 : h === 0 ? 12 : h;
    const ampm = h >= 12 ? "PM" : "AM";
    slots.push({
      id: `${dateStr}-${time}`,
      time,
      displayTime: `${displayHour}:00 ${ampm}`,
      available: true,
    });
  }
  return slots;
}

export function BookingCalendar({
  expertId,
  availableSlots,
  expertAvailability,
  selectedDate,
  selectedTimeSlot,
  onDateSelect,
  onTimeSlotSelect,
  className,
}: BookingCalendarProps) {
  const today = startOfDay(new Date());
  const maxDate = addDays(today, 30);

  // State for API-fetched slots
  const [apiSlots, setApiSlots] = useState<TimeSlot[] | null>(null);
  const [isFetchingSlots, setIsFetchingSlots] = useState(false);

  /**
   * Fetch availability from API when date changes
   */
  useEffect(() => {
    if (!selectedDate || !expertId) {
      setApiSlots(null);
      return;
    }

    let cancelled = false;
    setIsFetchingSlots(true);
    const dateStr = format(selectedDate, "yyyy-MM-dd");

    fetchExpertAvailability(expertId, dateStr)
      .then(({ slots }) => {
        if (!cancelled && slots.length > 0) {
          setApiSlots(slots.map((s) => ({
            id: s.id,
            time: s.time,
            displayTime: s.displayTime,
            available: s.available,
          })));
        } else if (!cancelled) {
          // API returned no slots - fall back to local generation
          setApiSlots(null);
        }
      })
      .catch(() => {
        if (!cancelled) setApiSlots(null);
      })
      .finally(() => {
        if (!cancelled) setIsFetchingSlots(false);
      });

    return () => { cancelled = true; };
  }, [selectedDate, expertId]);

  /**
   * Get available dates from expert's weekly availability or slot data
   */
  const availableDates = useMemo(() => {
    // If explicit per-date slots are provided, use those
    if (availableSlots?.length) {
      return availableSlots
        .filter((slot) => !slot.isBooked)
        .map((slot) => startOfDay(new Date(slot.date)));
    }

    // Use expert's weekly availability schedule
    const availableDays = new Set(
      (expertAvailability || []).map(s => s.day.toLowerCase())
    );

    const dates: Date[] = [];
    for (let i = 1; i <= 30; i++) {
      const date = addDays(today, i);
      const dayName = DAY_MAP[date.getDay()];
      if (availableDays.size > 0) {
        if (availableDays.has(dayName)) dates.push(date);
      } else {
        // No availability set — default to weekdays
        if (date.getDay() !== 0 && date.getDay() !== 6) dates.push(date);
      }
    }
    return dates;
  }, [availableSlots, expertAvailability, today]);

  /**
   * Get time slots for selected date - prefer API data over local generation
   */
  const timeSlotsForDate = useMemo(() => {
    if (!selectedDate) return [];

    // Prefer API-fetched slots (they include booked-slot info)
    if (apiSlots !== null) return apiSlots;

    // If explicit per-date slots exist
    if (availableSlots?.length) {
      const dateSlots = availableSlots.filter((slot) =>
        isSameDay(new Date(slot.date), selectedDate)
      );
      return dateSlots.map((slot) => ({
        id: slot.id,
        time: slot.startTime,
        displayTime: format(new Date(`2000-01-01T${slot.startTime}`), "h:mm a"),
        available: !slot.isBooked,
      }));
    }

    // Use expert's weekly schedule to generate hourly slots
    const dayName = DAY_MAP[selectedDate.getDay()];
    const dateStr = format(selectedDate, "yyyy-MM-dd");
    const daySlot = (expertAvailability || []).find(
      s => s.day.toLowerCase() === dayName
    );

    if (daySlot) {
      return generateSlotsFromRange(daySlot.startTime, daySlot.endTime, dateStr);
    }

    // Fallback: default 9-5 slots
    return DEFAULT_TIME_SLOTS.map((slot) => ({
      ...slot,
      id: `${dateStr}-${slot.time}`,
    }));
  }, [selectedDate, availableSlots, expertAvailability, apiSlots]);

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
            {isFetchingSlots ? (
              <div className="flex items-center justify-center py-6 gap-2">
                <Loader2 className="h-4 w-4 animate-spin text-muted-foreground" />
                <p className="text-sm text-muted-foreground">Loading available slots...</p>
              </div>
            ) : timeSlotsForDate.length === 0 ? (
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
                      "h-10 text-sm relative",
                      !slot.available && "opacity-40 cursor-not-allowed line-through bg-muted text-muted-foreground border-muted"
                    )}
                  >
                    {slot.displayTime}
                    {!slot.available && (
                      <span className="absolute -top-1 -right-1 h-3 w-3 rounded-full bg-red-400 border border-white" />
                    )}
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
