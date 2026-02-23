import { create } from "zustand";
import { MOCK_BOOKINGS } from "@/lib/data/experts";
import type { ConsultationBooking, SessionStatus } from "@/types/expert";

interface BookingState {
  bookings: ConsultationBooking[];
  addBooking: (booking: ConsultationBooking) => void;
  updateBookingStatus: (bookingId: string, status: SessionStatus) => void;
}

export const useBookingStore = create<BookingState>((set) => ({
  bookings: [...MOCK_BOOKINGS],

  addBooking: (booking) =>
    set((state) => ({
      bookings: [booking, ...state.bookings],
    })),

  updateBookingStatus: (bookingId, status) =>
    set((state) => ({
      bookings: state.bookings.map((b) =>
        b.id === bookingId
          ? { ...b, status, updatedAt: new Date() }
          : b
      ),
    })),
}));
