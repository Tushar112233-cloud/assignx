import {
  BookOpen,
  Calculator,
  Microscope,
  Scale,
  Heart,
  Briefcase,
  Cpu,
  Palette,
  Globe,
  Users,
  type LucideIcon,
} from "lucide-react";

export interface Subject {
  id: string;
  name: string;
  icon: LucideIcon;
  color: string;
}

/**
 * Available subjects for project submission
 */
export const subjects: Subject[] = [
  {
    id: "engineering",
    name: "Engineering",
    icon: Cpu,
    color: "bg-blue-500/10 text-blue-500",
  },
  {
    id: "business",
    name: "Business & Management",
    icon: Briefcase,
    color: "bg-purple-500/10 text-purple-500",
  },
  {
    id: "medicine",
    name: "Medicine & Healthcare",
    icon: Heart,
    color: "bg-red-500/10 text-red-500",
  },
  {
    id: "law",
    name: "Law",
    icon: Scale,
    color: "bg-amber-500/10 text-amber-500",
  },
  {
    id: "science",
    name: "Natural Sciences",
    icon: Microscope,
    color: "bg-green-500/10 text-green-500",
  },
  {
    id: "mathematics",
    name: "Mathematics & Statistics",
    icon: Calculator,
    color: "bg-indigo-500/10 text-indigo-500",
  },
  {
    id: "humanities",
    name: "Humanities & Literature",
    icon: BookOpen,
    color: "bg-pink-500/10 text-pink-500",
  },
  {
    id: "social-sciences",
    name: "Social Sciences",
    icon: Users,
    color: "bg-cyan-500/10 text-cyan-500",
  },
  {
    id: "arts",
    name: "Arts & Design",
    icon: Palette,
    color: "bg-orange-500/10 text-orange-500",
  },
  {
    id: "other",
    name: "Other",
    icon: Globe,
    color: "bg-gray-500/10 text-gray-500",
  },
];

/**
 * Document types for proofreading
 */
export const documentTypes = [
  { id: "essay", name: "Essay" },
  { id: "thesis", name: "Thesis / Dissertation" },
  { id: "research-paper", name: "Research Paper" },
  { id: "report", name: "Report" },
  { id: "case-study", name: "Case Study" },
  { id: "assignment", name: "Assignment" },
  { id: "article", name: "Article" },
  { id: "other", name: "Other" },
];

/**
 * Turnaround times for proofreading
 */
export const turnaroundTimes = [
  { value: "72h", label: "72 Hours", price: 0.02 },
  { value: "48h", label: "48 Hours", price: 0.03 },
  { value: "24h", label: "24 Hours", price: 0.05 },
] as const;
