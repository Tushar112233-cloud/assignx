/**
 * Expert data helpers
 * Fetches expert data from the real API.
 */

import { apiClient } from "@/lib/api/client";
import type { Expert, ExpertReview, ConsultationBooking } from "@/types/expert";

/**
 * Re-export empty arrays for backward compatibility with any imports
 * that still reference them (e.g. type-only usage).
 */
export const MOCK_EXPERTS: Expert[] = [];
export const MOCK_REVIEWS: ExpertReview[] = [];
export const MOCK_BOOKINGS: ConsultationBooking[] = [];

/**
 * Fetch all experts from the API
 */
export async function fetchExperts(): Promise<{ experts: Expert[]; total: number }> {
  try {
    const data = await apiClient<{ experts: Expert[]; total: number }>("/api/experts");
    return { experts: data.experts || [], total: data.total || 0 };
  } catch (error) {
    console.error("Failed to fetch experts:", error);
    return { experts: [], total: 0 };
  }
}

/**
 * Fetch expert by ID from the API
 */
export async function fetchExpertById(id: string): Promise<Expert | null> {
  try {
    const data = await apiClient<{ expert: Expert }>(`/api/experts/${id}`);
    return data.expert || null;
  } catch (error) {
    console.error("Failed to fetch expert:", error);
    return null;
  }
}

/**
 * Fetch reviews for an expert
 */
export async function fetchExpertReviews(expertId: string): Promise<ExpertReview[]> {
  try {
    const data = await apiClient<{ reviews: ExpertReview[] }>(`/api/experts/${expertId}/reviews`);
    return data.reviews || [];
  } catch (error) {
    console.error("Failed to fetch reviews:", error);
    return [];
  }
}

/**
 * Fetch current user's bookings from the API
 */
export async function fetchUserBookings(): Promise<ConsultationBooking[]> {
  try {
    const data = await apiClient<{ bookings: ConsultationBooking[] }>("/api/experts/bookings/me");
    return data.bookings || [];
  } catch (error) {
    console.error("Failed to fetch bookings:", error);
    return [];
  }
}

/**
 * Fetch available time slots for an expert on a specific date.
 * Returns slots with booked ones marked as unavailable.
 */
export async function fetchExpertAvailability(
  expertId: string,
  date: string
): Promise<{ slots: Array<{ id: string; time: string; displayTime: string; available: boolean }>; bookedCount: number }> {
  try {
    const data = await apiClient<{
      slots: Array<{ id: string; time: string; displayTime: string; display_time: string; available: boolean }>;
      bookedCount: number;
    }>(`/api/experts/${expertId}/availability?date=${date}`);
    const slots = (data.slots || []).map((s) => ({
      id: s.id,
      time: s.time,
      displayTime: s.displayTime || s.display_time || s.time,
      available: s.available,
    }));
    return { slots, bookedCount: data.bookedCount || 0 };
  } catch (error) {
    console.error("Failed to fetch expert availability:", error);
    return { slots: [], bookedCount: 0 };
  }
}

/**
 * Create a Razorpay order for an expert booking
 */
export async function createExpertBookingOrder(
  expertId: string,
  amount: number
): Promise<{ orderId: string; amount: number; currency: string; keyId: string } | null> {
  try {
    const data = await apiClient<{ orderId: string; amount: number; currency: string; keyId: string }>(
      "/api/experts/bookings/create-order",
      { method: "POST", body: JSON.stringify({ expertId, amount }) }
    );
    return data;
  } catch (error) {
    console.error("Failed to create booking order:", error);
    return null;
  }
}

/**
 * Verify Razorpay payment and create expert booking
 */
export async function verifyExpertBookingPayment(data: {
  razorpay_order_id: string;
  razorpay_payment_id: string;
  razorpay_signature: string;
  expertId: string;
  date: string;
  time: string;
  startTime: string;
  endTime: string;
  duration: number;
  topic: string;
  notes: string;
  amount: number;
}): Promise<{ booking: any } | null> {
  try {
    const result = await apiClient<{ booking: any }>(
      "/api/experts/bookings/verify-payment",
      { method: "POST", body: JSON.stringify(data) }
    );
    return result;
  } catch (error) {
    console.error("Failed to verify expert booking payment:", error);
    return null;
  }
}

/**
 * @deprecated Use fetchExpertById instead
 */
export function getExpertById(id: string): Expert | undefined {
  return MOCK_EXPERTS.find((expert) => expert.id === id);
}

/**
 * @deprecated Use fetchExpertReviews instead
 */
export function getExpertReviews(expertId: string): ExpertReview[] {
  return MOCK_REVIEWS.filter((review) => review.expertId === expertId);
}

/**
 * @deprecated Use fetchUserBookings instead
 */
export function getUserBookings(userId: string): ConsultationBooking[] {
  return MOCK_BOOKINGS.filter((booking) => booking.clientId === userId);
}

/**
 * @deprecated Use fetchExperts with featured filter instead
 */
export function getFeaturedExperts(): Expert[] {
  return MOCK_EXPERTS.filter((expert) => expert.featured);
}
