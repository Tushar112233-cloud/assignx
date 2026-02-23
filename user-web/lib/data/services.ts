import {
  FileText,
  Search,
  Stethoscope,
  BookOpen,
  type LucideIcon,
} from "lucide-react";

export interface Service {
  id: string;
  title: string;
  description: string;
  icon: LucideIcon;
  href: string;
  color: string;
  disabled?: boolean;
  badge?: string;
}

/**
 * Dashboard services configuration
 * Displayed in 2x2 grid on home page
 * Uses earthy color palette: Cinnamon (#A9714B), Toasted Almond (#E8985E), Dark Brown (#54442B)
 */
export const services: Service[] = [
  {
    id: "project-support",
    title: "Project Support",
    description: "Get expert help with your projects",
    icon: FileText,
    href: "/projects/new",
    color: "bg-primary/10 text-primary",
  },
  {
    id: "ai-plag-report",
    title: "AI/Plag Report",
    description: "Check originality & AI detection",
    icon: Search,
    href: "/services/report",
    color: "bg-accent/15 text-accent dark:text-accent",
  },
  {
    id: "consult-doctor",
    title: "Consult Doctor",
    description: "Medical consultation service",
    icon: Stethoscope,
    href: "/services/consult",
    color: "bg-emerald-600/10 text-emerald-700 dark:text-emerald-500",
    disabled: true,
    badge: "Coming Soon",
  },
  {
    id: "ref-generator",
    title: "Ref. Generator",
    description: "Generate citations for free",
    icon: BookOpen,
    href: "https://www.citethisforme.com/",
    color: "bg-amber-700/10 text-amber-800 dark:text-amber-500",
    badge: "Free",
  },
];
