"use client";

import { useState, type ReactNode } from "react";
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
import { PieChart, Clock, Puzzle, Users } from "lucide-react";
import { cn } from "@/lib/utils";

type SettingsGroup = Record<
  string,
  { id: string; key: string; value: unknown; description: string | null }[]
>;

interface QuotePricingValue {
  supervisor_percentage: number;
  platform_percentage: number;
  urgency_24h_multiplier: number;
  urgency_48h_multiplier: number;
  urgency_72h_multiplier: number;
  website_per_feature: number;
  app_per_feature: number;
}

const DEFAULTS: QuotePricingValue = {
  supervisor_percentage: 15,
  platform_percentage: 20,
  urgency_24h_multiplier: 1.5,
  urgency_48h_multiplier: 1.3,
  urgency_72h_multiplier: 1.15,
  website_per_feature: 500,
  app_per_feature: 1000,
};

// ---------------------------------------------------------------------------
// Colored section wrapper
// ---------------------------------------------------------------------------

function QuoteSection({
  icon,
  title,
  subtitle,
  color,
  children,
}: {
  icon: ReactNode;
  title: string;
  subtitle?: string;
  color: "indigo" | "orange" | "teal";
  children: ReactNode;
}) {
  const palette = {
    indigo: {
      bg: "bg-indigo-50 dark:bg-indigo-950/30",
      border: "border-indigo-200 dark:border-indigo-800",
      iconBg: "bg-indigo-100 dark:bg-indigo-900/50",
      iconText: "text-indigo-600 dark:text-indigo-400",
      headerText: "text-indigo-900 dark:text-indigo-100",
    },
    orange: {
      bg: "bg-orange-50 dark:bg-orange-950/30",
      border: "border-orange-200 dark:border-orange-800",
      iconBg: "bg-orange-100 dark:bg-orange-900/50",
      iconText: "text-orange-600 dark:text-orange-400",
      headerText: "text-orange-900 dark:text-orange-100",
    },
    teal: {
      bg: "bg-teal-50 dark:bg-teal-950/30",
      border: "border-teal-200 dark:border-teal-800",
      iconBg: "bg-teal-100 dark:bg-teal-900/50",
      iconText: "text-teal-600 dark:text-teal-400",
      headerText: "text-teal-900 dark:text-teal-100",
    },
  }[color];

  return (
    <div className={cn("rounded-xl border", palette.border)}>
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
          {subtitle && (
            <p className="text-xs text-muted-foreground">{subtitle}</p>
          )}
        </div>
      </div>
      <div className="p-4">{children}</div>
    </div>
  );
}

// ---------------------------------------------------------------------------
// Main component
// ---------------------------------------------------------------------------

interface QuotePricingProps {
  settings: SettingsGroup;
  onSave: (updates: { key: string; value: unknown }[]) => Promise<void>;
  saving: boolean;
}

export function QuotePricing({ settings, onSave, saving }: QuotePricingProps) {
  const existing = (settings["pricing"] || []).find(
    (s) => s.key === "quote_pricing"
  );
  const saved = (existing?.value || {}) as Partial<QuotePricingValue>;

  const [values, setValues] = useState<QuotePricingValue>({
    ...DEFAULTS,
    ...saved,
  });

  const set = (key: keyof QuotePricingValue, val: number) =>
    setValues((prev) => ({ ...prev, [key]: val }));

  const handleSave = () =>
    onSave([{ key: "quote_pricing", value: values }]);

  const doerPercentage =
    100 - values.supervisor_percentage - values.platform_percentage;

  return (
    <Card>
      <CardHeader>
        <CardTitle>Quote & Commission Settings</CardTitle>
        <CardDescription>
          Configure commission splits and urgency multipliers for supervisor
          quote calculations
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-5">
        {/* Commission Splits */}
        <QuoteSection
          icon={<PieChart className="h-4 w-4" />}
          title="Commission Splits"
          subtitle="Revenue distribution between stakeholders"
          color="indigo"
        >
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div className="flex flex-col gap-2">
              <Label>Supervisor (%)</Label>
              <Input
                type="number"
                step="1"
                min="0"
                max="50"
                value={values.supervisor_percentage}
                onChange={(e) =>
                  set("supervisor_percentage", Number(e.target.value))
                }
              />
            </div>
            <div className="flex flex-col gap-2">
              <Label>Platform Fee (%)</Label>
              <Input
                type="number"
                step="1"
                min="0"
                max="50"
                value={values.platform_percentage}
                onChange={(e) =>
                  set("platform_percentage", Number(e.target.value))
                }
              />
            </div>
            <div className="flex flex-col gap-2">
              <Label>Doer Payout (%)</Label>
              <Input
                type="number"
                value={doerPercentage}
                disabled
                className="bg-muted"
              />
            </div>
          </div>

          {/* Visual bar */}
          <div className="mt-4 space-y-1.5">
            <div className="flex h-3 w-full overflow-hidden rounded-full">
              <div
                className="bg-indigo-500 transition-all"
                style={{ width: `${values.supervisor_percentage}%` }}
              />
              <div
                className="bg-indigo-300 dark:bg-indigo-700 transition-all"
                style={{ width: `${values.platform_percentage}%` }}
              />
              <div
                className="bg-emerald-400 dark:bg-emerald-600 transition-all"
                style={{ width: `${Math.max(doerPercentage, 0)}%` }}
              />
            </div>
            <div className="flex justify-between text-xs text-muted-foreground">
              <span className="flex items-center gap-1">
                <span className="inline-block h-2 w-2 rounded-full bg-indigo-500" />
                Supervisor {values.supervisor_percentage}%
              </span>
              <span className="flex items-center gap-1">
                <span className="inline-block h-2 w-2 rounded-full bg-indigo-300 dark:bg-indigo-700" />
                Platform {values.platform_percentage}%
              </span>
              <span className="flex items-center gap-1">
                <span className="inline-block h-2 w-2 rounded-full bg-emerald-400 dark:bg-emerald-600" />
                Doer {doerPercentage}%
              </span>
            </div>
          </div>
        </QuoteSection>

        {/* Urgency Multipliers */}
        <QuoteSection
          icon={<Clock className="h-4 w-4" />}
          title="Urgency Multipliers"
          subtitle="Applied to base price when deadline is within specified hours"
          color="orange"
        >
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div className="flex flex-col gap-2">
              <Label>Within 24 hours (x)</Label>
              <Input
                type="number"
                step="0.05"
                min="1"
                max="5"
                value={values.urgency_24h_multiplier}
                onChange={(e) =>
                  set("urgency_24h_multiplier", Number(e.target.value))
                }
              />
              <p className="text-xs text-muted-foreground">
                ₹1,000 base = ₹
                {(1000 * values.urgency_24h_multiplier).toLocaleString()}
              </p>
            </div>
            <div className="flex flex-col gap-2">
              <Label>Within 48 hours (x)</Label>
              <Input
                type="number"
                step="0.05"
                min="1"
                max="5"
                value={values.urgency_48h_multiplier}
                onChange={(e) =>
                  set("urgency_48h_multiplier", Number(e.target.value))
                }
              />
              <p className="text-xs text-muted-foreground">
                ₹1,000 base = ₹
                {(1000 * values.urgency_48h_multiplier).toLocaleString()}
              </p>
            </div>
            <div className="flex flex-col gap-2">
              <Label>Within 72 hours (x)</Label>
              <Input
                type="number"
                step="0.05"
                min="1"
                max="5"
                value={values.urgency_72h_multiplier}
                onChange={(e) =>
                  set("urgency_72h_multiplier", Number(e.target.value))
                }
              />
              <p className="text-xs text-muted-foreground">
                ₹1,000 base = ₹
                {(1000 * values.urgency_72h_multiplier).toLocaleString()}
              </p>
            </div>
          </div>
        </QuoteSection>

        {/* Per-Feature Add-ons */}
        <QuoteSection
          icon={<Puzzle className="h-4 w-4" />}
          title="Per-Feature Add-ons"
          subtitle="Additional cost per feature for website and app projects"
          color="teal"
        >
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="flex flex-col gap-2">
              <Label>Website: Per Feature (₹)</Label>
              <Input
                type="number"
                step="100"
                min="0"
                value={values.website_per_feature}
                onChange={(e) =>
                  set("website_per_feature", Number(e.target.value))
                }
              />
              <p className="text-xs text-muted-foreground">
                e.g. 3 features = ₹
                {(3 * values.website_per_feature).toLocaleString()}
              </p>
            </div>
            <div className="flex flex-col gap-2">
              <Label>App: Per Feature (₹)</Label>
              <Input
                type="number"
                step="100"
                min="0"
                value={values.app_per_feature}
                onChange={(e) =>
                  set("app_per_feature", Number(e.target.value))
                }
              />
              <p className="text-xs text-muted-foreground">
                e.g. 3 features = ₹
                {(3 * values.app_per_feature).toLocaleString()}
              </p>
            </div>
          </div>
        </QuoteSection>

        <Button onClick={handleSave} disabled={saving}>
          {saving ? "Saving..." : "Save Quote Settings"}
        </Button>
      </CardContent>
    </Card>
  );
}
