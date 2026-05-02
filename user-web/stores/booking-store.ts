import { create } from "zustand";
import { fetchUserBookings } from "@/lib/data/experts";
import type { ConsultationBooking, SessionStatus } from "@/types/expert";

interface BookingState {
  bookings: ConsultationBooking[];
  isLoading: boolean;
  hasFetched: boolean;
  fetchBookings: () => Promise<void>;
  addBooking: (booking: ConsultationBooking) => void;
  updateBookingStatus: (bookingId: string, status: SessionStatus) => void;
}

export const useBookingStore = create<BookingState>((set, get) => ({
  bookings: [],
  isLoading: false,
  hasFetched: false,

  fetchBookings: async () => {
    // Avoid re-fetching if already loaded
    if (get().hasFetched || get().isLoading) return;

    set({ isLoading: true });
    try {
      const bookings = await fetchUserBookings();
      set({ bookings, hasFetched: true });
    } catch (error) {
      console.error("Failed to fetch bookings:", error);
    } finally {
      set({ isLoading: false });
    }
  },

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
