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
  Beaker,
  TrendingUp,
  DollarSign,
  Stethoscope,
  History,
  Brain,
  type LucideIcon,
} from "lucide-react";

/** Presentation details (icon + color) for a subject, keyed by slug */
export interface SubjectPresentation {
  icon: LucideIcon;
  color: string;
}

/** Map of subject slug to its presentation (icon and color class) */
export const subjectPresentationMap: Record<string, SubjectPresentation> = {
  engineering: { icon: Cpu, color: "bg-blue-500/10 text-blue-500" },
  "computer-science": { icon: Cpu, color: "bg-sky-500/10 text-sky-500" },
  mathematics: { icon: Calculator, color: "bg-indigo-500/10 text-indigo-500" },
  physics: { icon: Microscope, color: "bg-violet-500/10 text-violet-500" },
  chemistry: { icon: Beaker, color: "bg-emerald-500/10 text-emerald-500" },
  biology: { icon: Microscope, color: "bg-green-500/10 text-green-500" },
  "data-science": { icon: TrendingUp, color: "bg-teal-500/10 text-teal-500" },
  business: { icon: Briefcase, color: "bg-purple-500/10 text-purple-500" },
  economics: { icon: TrendingUp, color: "bg-amber-500/10 text-amber-500" },
  marketing: { icon: Briefcase, color: "bg-fuchsia-500/10 text-fuchsia-500" },
  finance: { icon: DollarSign, color: "bg-lime-500/10 text-lime-500" },
  medicine: { icon: Heart, color: "bg-red-500/10 text-red-500" },
  nursing: { icon: Stethoscope, color: "bg-rose-500/10 text-rose-500" },
  psychology: { icon: Brain, color: "bg-pink-500/10 text-pink-500" },
  sociology: { icon: Users, color: "bg-cyan-500/10 text-cyan-500" },
  law: { icon: Scale, color: "bg-amber-600/10 text-amber-600" },
  literature: { icon: BookOpen, color: "bg-pink-500/10 text-pink-500" },
  history: { icon: History, color: "bg-stone-500/10 text-stone-500" },
  arts: { icon: Palette, color: "bg-orange-500/10 text-orange-500" },
  other: { icon: Globe, color: "bg-gray-500/10 text-gray-500" },
};

/** Default presentation for unknown slugs */
const defaultPresentation: SubjectPresentation = {
  icon: Globe,
  color: "bg-gray-500/10 text-gray-500",
};

/** Get the presentation (icon + color) for a subject by its slug */
export function getSubjectPresentation(slug: string): SubjectPresentation {
  return subjectPresentationMap[slug] || defaultPresentation;
}

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
