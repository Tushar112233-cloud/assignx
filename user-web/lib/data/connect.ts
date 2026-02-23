/**
 * Student Connect module data
 * Batch 7: Student Connect
 */

import type { Tutor, Resource, StudyGroup, Question, Answer, TimeSlot } from "@/types/connect";

/**
 * Featured tutors - fetched from database
 */
export const featuredTutors: Tutor[] = [];

/**
 * All tutors - fetched from database
 */
export const allTutors: Tutor[] = [];

/**
 * Shared resources - fetched from database
 */
export const sharedResources: Resource[] = [];

/**
 * Study groups - fetched from database
 */
export const studyGroups: StudyGroup[] = [];

/**
 * Q&A questions - fetched from database
 */
export const questions: Question[] = [];

/**
 * Available time slots for booking
 */
export const availableTimeSlots: TimeSlot[] = [
  { id: "slot-1", time: "09:00 AM", available: true },
  { id: "slot-2", time: "10:00 AM", available: true },
  { id: "slot-3", time: "11:00 AM", available: false },
  { id: "slot-4", time: "12:00 PM", available: true },
  { id: "slot-5", time: "01:00 PM", available: false },
  { id: "slot-6", time: "02:00 PM", available: true },
  { id: "slot-7", time: "03:00 PM", available: true },
  { id: "slot-8", time: "04:00 PM", available: true },
  { id: "slot-9", time: "05:00 PM", available: false },
  { id: "slot-10", time: "06:00 PM", available: true },
];

/**
 * Connect categories
 */
export const connectCategories = [
  { id: "all", label: "All", icon: "Grid" },
  { id: "tutors", label: "Tutors", icon: "GraduationCap" },
  { id: "resources", label: "Resources", icon: "FileText" },
  { id: "study-groups", label: "Study Groups", icon: "Users" },
  { id: "qa", label: "Q&A", icon: "MessageCircle" },
] as const;

/**
 * Subject filters for connect
 */
export const subjectFilters = [
  "All Subjects",
  "Mathematics",
  "Computer Science",
  "Physics",
  "Chemistry",
  "Biology",
  "Business",
  "Economics",
  "English",
  "Psychology",
  "Engineering",
  "Medicine",
  "Law",
  "Statistics",
];

/** Answers for Q&A - fetched from database */
export const mockAnswers: Answer[] = [];

/** Q&A filter options */
export const qaFilters = [
  { value: "all", label: "All Questions" },
  { value: "unanswered", label: "Unanswered" },
  { value: "answered", label: "Answered" },
];
