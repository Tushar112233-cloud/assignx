"use client";

import { useState, useMemo, type ReactNode } from "react";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import {
  BookOpen,
  Globe,
  Smartphone,
  MessageCircle,
  Zap,
  Calculator,
} from "lucide-react";
import { cn } from "@/lib/utils";

type SettingsGroup = Record<
  string,
  { id: string; key: string; value: unknown; description: string | null }[]
>;

interface ProjectPricingValue {
  assignment_per_word: number;
  website_per_page: number;
  app_single_platform: number;
  app_both_platforms: number;
  consultancy_30min: number;
  consultancy_1hr: number;
  consultancy_2hr: number;
  gst_percent: number;
  urgency_standard: number;
  urgency_express: number;
  urgency_urgent: number;
}

const DEFAULT_PRICING: ProjectPricingValue = {
  assignment_per_word: 0.8,
  website_per_page: 2000,
  app_single_platform: 25000,
  app_both_platforms: 40000,
  consultancy_30min: 500,
  consultancy_1hr: 800,
  consultancy_2hr: 1500,
  gst_percent: 18,
  urgency_standard: 1.0,
  urgency_express: 1.5,
  urgency_urgent: 2.0,
};

// ---------------------------------------------------------------------------
// Section wrapper with colored header
// ---------------------------------------------------------------------------

function PricingSection({
  icon,
  title,
  subtitle,
  color,
  children,
  preview,
}: {
  icon: ReactNode;
  title: string;
  subtitle: string;
  color: "blue" | "purple" | "green" | "amber" | "red";
  children: ReactNode;
  preview?: ReactNode;
}) {
  const palette = {
    blue: {
      bg: "bg-blue-50 dark:bg-blue-950/30",
      border: "border-blue-200 dark:border-blue-800",
      iconBg: "bg-blue-100 dark:bg-blue-900/50",
      iconText: "text-blue-600 dark:text-blue-400",
      headerText: "text-blue-900 dark:text-blue-100",
    },
    purple: {
      bg: "bg-purple-50 dark:bg-purple-950/30",
      border: "border-purple-200 dark:border-purple-800",
      iconBg: "bg-purple-100 dark:bg-purple-900/50",
      iconText: "text-purple-600 dark:text-purple-400",
      headerText: "text-purple-900 dark:text-purple-100",
    },
    green: {
      bg: "bg-emerald-50 dark:bg-emerald-950/30",
      border: "border-emerald-200 dark:border-emerald-800",
      iconBg: "bg-emerald-100 dark:bg-emerald-900/50",
      iconText: "text-emerald-600 dark:text-emerald-400",
      headerText: "text-emerald-900 dark:text-emerald-100",
    },
    amber: {
      bg: "bg-amber-50 dark:bg-amber-950/30",
      border: "border-amber-200 dark:border-amber-800",
      iconBg: "bg-amber-100 dark:bg-amber-900/50",
      iconText: "text-amber-600 dark:text-amber-400",
      headerText: "text-amber-900 dark:text-amber-100",
    },
    red: {
      bg: "bg-red-50 dark:bg-red-950/30",
      border: "border-red-200 dark:border-red-800",
      iconBg: "bg-red-100 dark:bg-red-900/50",
      iconText: "text-red-600 dark:text-red-400",
      headerText: "text-red-900 dark:text-red-100",
    },
  }[color];

  return (
    <div className={cn("rounded-xl border", palette.border)}>
      {/* Colored header */}
      <div
        className={cn(
          "flex items-center gap-3 px-4 py-3 rounded-t-xl",
          palette.bg
        )}
      >
        <div className={cn("p-2 rounded-lg", palette.iconBg)}>
          <div className={palette.iconText}>{icon}</div>
        </div>
        <div>
          <h3 className={cn("font-semibold text-sm", palette.headerText)}>
            {title}
          </h3>
          <p className="text-xs text-muted-foreground">{subtitle}</p>
        </div>
      </div>

      {/* Fields */}
      <div className="p-4 space-y-4">
        <div className="grid gap-4 sm:grid-cols-2">{children}</div>
        {preview && (
          <div className="pt-3 border-t border-dashed">
            <div className="flex items-center gap-1.5 text-xs font-medium text-muted-foreground mb-2">
              <Calculator className="h-3.5 w-3.5" />
              Sample Quote Preview
            </div>
            {preview}
          </div>
        )}
      </div>
    </div>
  );
}

// ---------------------------------------------------------------------------
// Main component
// ---------------------------------------------------------------------------

export function ProjectPricing({
  settings,
  onSave,
  saving,
}: {
  settings: SettingsGroup;
  onSave: (updates: { key: string; value: unknown }[]) => Promise<void>;
  saving: boolean;
}) {
  const pricingGroup = settings["pricing"] || [];
  const existing = pricingGroup.find((s) => s.key === "project_pricing");
  const existingValue = (existing?.value as ProjectPricingValue) || null;

  const [pricing, setPricing] = useState<ProjectPricingValue>({
    assignment_per_word:
      existingValue?.assignment_per_word ??
      DEFAULT_PRICING.assignment_per_word,
    website_per_page:
      existingValue?.website_per_page ?? DEFAULT_PRICING.website_per_page,
    app_single_platform:
      existingValue?.app_single_platform ??
      DEFAULT_PRICING.app_single_platform,
    app_both_platforms:
      existingValue?.app_both_platforms ??
      DEFAULT_PRICING.app_both_platforms,
    consultancy_30min:
      existingValue?.consultancy_30min ?? DEFAULT_PRICING.consultancy_30min,
    consultancy_1hr:
      existingValue?.consultancy_1hr ?? DEFAULT_PRICING.consultancy_1hr,
    consultancy_2hr:
      existingValue?.consultancy_2hr ?? DEFAULT_PRICING.consultancy_2hr,
    gst_percent:
      existingValue?.gst_percent ?? DEFAULT_PRICING.gst_percent,
    urgency_standard:
      existingValue?.urgency_standard ?? DEFAULT_PRICING.urgency_standard,
    urgency_express:
      existingValue?.urgency_express ?? DEFAULT_PRICING.urgency_express,
    urgency_urgent:
      existingValue?.urgency_urgent ?? DEFAULT_PRICING.urgency_urgent,
  });

  const updateField = (key: keyof ProjectPricingValue, value: string) => {
    setPricing((prev) => ({ ...prev, [key]: parseFloat(value) || 0 }));
  };

  const handleSave = () => {
    onSave([{ key: "project_pricing", value: pricing }]);
  };

  // Compute sample previews
  const previews = useMemo(() => {
    const gst = pricing.gst_percent / 100;
    const assignmentBase = 1000 * pricing.assignment_per_word;
    const websiteBase = 5 * pricing.website_per_page;
    return {
      assignment: {
        desc: "1,000 words",
        base: assignmentBase,
        total: assignmentBase * (1 + gst),
      },
      website: {
        desc: "5 pages",
        base: websiteBase,
        total: websiteBase * (1 + gst),
      },
      app: {
        desc: "Single platform",
        base: pricing.app_single_platform,
        total: pricing.app_single_platform * (1 + gst),
      },
      consult: {
        desc: "1 hr session",
        base: pricing.consultancy_1hr,
        total: pricing.consultancy_1hr * (1 + gst),
      },
    };
  }, [pricing]);

  return (
    <Card>
      <CardHeader>
        <CardTitle>Project Pricing</CardTitle>
        <CardDescription>
          Configure base pricing for different project types. Each section shows
          a sample quote preview with GST.
        </CardDescription>
      </CardHeader>
      <CardContent className="flex flex-col gap-5">
        {/* Assignment / Writing */}
        <PricingSection
          icon={<BookOpen className="h-4 w-4" />}
          title="Writing & Assignments"
          subtitle="Per-word rate for documents, essays, and research papers"
          color="blue"
          preview={
            <p className="text-sm">
              {previews.assignment.desc}{" "}
              <span className="text-muted-foreground">
                = ₹{previews.assignment.base.toFixed(0)} + GST =
              </span>{" "}
              <span className="font-semibold text-blue-600 dark:text-blue-400">
                ₹{previews.assignment.total.toFixed(0)}
              </span>
            </p>
          }
        >
          <div className="flex flex-col gap-2">
            <Label htmlFor="assignment_per_word">Per-word rate (₹)</Label>
            <Input
              id="assignment_per_word"
              type="number"
              value={pricing.assignment_per_word}
              onChange={(e) => updateField("assignment_per_word", e.target.value)}
              min={0}
              step={0.1}
            />
          </div>
        </PricingSection>

        {/* Website */}
        <PricingSection
          icon={<Globe className="h-4 w-4" />}
          title="Website Projects"
          subtitle="Per-page rate for website design and development"
          color="purple"
          preview={
            <p className="text-sm">
              {previews.website.desc}{" "}
              <span className="text-muted-foreground">
                = ₹{previews.website.base.toFixed(0)} + GST =
              </span>{" "}
              <span className="font-semibold text-purple-600 dark:text-purple-400">
                ₹{previews.website.total.toFixed(0)}
              </span>
            </p>
          }
        >
          <div className="flex flex-col gap-2">
            <Label htmlFor="website_per_page">Per-page rate (₹)</Label>
            <Input
              id="website_per_page"
              type="number"
              value={pricing.website_per_page}
              onChange={(e) => updateField("website_per_page", e.target.value)}
              min={0}
              step={100}
            />
          </div>
        </PricingSection>

        {/* App */}
        <PricingSection
          icon={<Smartphone className="h-4 w-4" />}
          title="App Projects"
          subtitle="Base pricing for mobile application development"
          color="green"
          preview={
            <p className="text-sm">
              {previews.app.desc}{" "}
              <span className="text-muted-foreground">
                = ₹{previews.app.base.toFixed(0)} + GST =
              </span>{" "}
              <span className="font-semibold text-emerald-600 dark:text-emerald-400">
                ₹{previews.app.total.toFixed(0)}
              </span>
            </p>
          }
        >
          <div className="flex flex-col gap-2">
            <Label htmlFor="app_single_platform">Single platform base (₹)</Label>
            <Input
              id="app_single_platform"
              type="number"
              value={pricing.app_single_platform}
              onChange={(e) =>
                updateField("app_single_platform", e.target.value)
              }
              min={0}
              step={1000}
            />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="app_both_platforms">Both platforms base (₹)</Label>
            <Input
              id="app_both_platforms"
              type="number"
              value={pricing.app_both_platforms}
              onChange={(e) =>
                updateField("app_both_platforms", e.target.value)
              }
              min={0}
              step={1000}
            />
          </div>
        </PricingSection>

        {/* Consultation */}
        <PricingSection
          icon={<MessageCircle className="h-4 w-4" />}
          title="Consultation"
          subtitle="Session-based pricing for expert consultations"
          color="amber"
          preview={
            <p className="text-sm">
              {previews.consult.desc}{" "}
              <span className="text-muted-foreground">
                = ₹{previews.consult.base.toFixed(0)} + GST =
              </span>{" "}
              <span className="font-semibold text-amber-600 dark:text-amber-400">
                ₹{previews.consult.total.toFixed(0)}
              </span>
            </p>
          }
        >
          <div className="flex flex-col gap-2">
            <Label htmlFor="consultancy_30min">30 min (₹)</Label>
            <Input
              id="consultancy_30min"
              type="number"
              value={pricing.consultancy_30min}
              onChange={(e) => updateField("consultancy_30min", e.target.value)}
              min={0}
              step={50}
            />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="consultancy_1hr">1 hr (₹)</Label>
            <Input
              id="consultancy_1hr"
              type="number"
              value={pricing.consultancy_1hr}
              onChange={(e) => updateField("consultancy_1hr", e.target.value)}
              min={0}
              step={50}
            />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="consultancy_2hr">2 hr (₹)</Label>
            <Input
              id="consultancy_2hr"
              type="number"
              value={pricing.consultancy_2hr}
              onChange={(e) => updateField("consultancy_2hr", e.target.value)}
              min={0}
              step={50}
            />
          </div>
        </PricingSection>

        {/* Tax & Urgency */}
        <PricingSection
          icon={<Zap className="h-4 w-4" />}
          title="Tax & Urgency"
          subtitle="GST rate and urgency multipliers applied to all project types"
          color="red"
        >
          <div className="flex flex-col gap-2">
            <Label htmlFor="gst_percent">GST (%)</Label>
            <Input
              id="gst_percent"
              type="number"
              value={pricing.gst_percent}
              onChange={(e) => updateField("gst_percent", e.target.value)}
              min={0}
              step={1}
            />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="urgency_standard">Standard multiplier</Label>
            <Input
              id="urgency_standard"
              type="number"
              value={pricing.urgency_standard}
              onChange={(e) => updateField("urgency_standard", e.target.value)}
              min={0}
              step={0.1}
            />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="urgency_express">Express multiplier</Label>
            <Input
              id="urgency_express"
              type="number"
              value={pricing.urgency_express}
              onChange={(e) => updateField("urgency_express", e.target.value)}
              min={0}
              step={0.1}
            />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="urgency_urgent">Urgent multiplier</Label>
            <Input
              id="urgency_urgent"
              type="number"
              value={pricing.urgency_urgent}
              onChange={(e) => updateField("urgency_urgent", e.target.value)}
              min={0}
              step={0.1}
            />
          </div>
        </PricingSection>

        <Button onClick={handleSave} disabled={saving} className="w-fit">
          {saving ? "Saving..." : "Save Project Pricing"}
        </Button>
      </CardContent>
    </Card>
  );
}
