"use client";

import { useState, useMemo } from "react";
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
import { ScanSearch, ShieldCheck, FileText } from "lucide-react";
import { cn } from "@/lib/utils";

type SettingsGroup = Record<
  string,
  { id: string; key: string; value: unknown; description: string | null }[]
>;

interface TurnitinPricingValue {
  ai_detection: number;
  plagiarism_check: number;
  complete_report: number;
  gst_percent: number;
}

const DEFAULT_PRICING: TurnitinPricingValue = {
  ai_detection: 49,
  plagiarism_check: 99,
  complete_report: 129,
  gst_percent: 18,
};

export function TurnitinPricing({
  settings,
  onSave,
  saving,
}: {
  settings: SettingsGroup;
  onSave: (updates: { key: string; value: unknown }[]) => Promise<void>;
  saving: boolean;
}) {
  const pricingGroup = settings["pricing"] || [];
  const existing = pricingGroup.find((s) => s.key === "turnitin_pricing");
  const existingValue = (existing?.value as TurnitinPricingValue) || null;

  const [pricing, setPricing] = useState<TurnitinPricingValue>({
    ai_detection:
      existingValue?.ai_detection ?? DEFAULT_PRICING.ai_detection,
    plagiarism_check:
      existingValue?.plagiarism_check ?? DEFAULT_PRICING.plagiarism_check,
    complete_report:
      existingValue?.complete_report ?? DEFAULT_PRICING.complete_report,
    gst_percent:
      existingValue?.gst_percent ?? DEFAULT_PRICING.gst_percent,
  });

  const updateField = (key: keyof TurnitinPricingValue, value: string) => {
    setPricing((prev) => ({ ...prev, [key]: parseFloat(value) || 0 }));
  };

  const gstRate = pricing.gst_percent / 100;

  const cards = useMemo(
    () => [
      {
        key: "ai_detection" as const,
        label: "AI Detection",
        icon: <ScanSearch className="h-5 w-5" />,
        color: "cyan" as const,
        description: "Detect AI-generated content",
        base: pricing.ai_detection,
      },
      {
        key: "plagiarism_check" as const,
        label: "Plagiarism Check",
        icon: <ShieldCheck className="h-5 w-5" />,
        color: "violet" as const,
        description: "Check for plagiarised content",
        base: pricing.plagiarism_check,
      },
      {
        key: "complete_report" as const,
        label: "Complete Report",
        icon: <FileText className="h-5 w-5" />,
        color: "rose" as const,
        description: "AI detection + plagiarism combined",
        base: pricing.complete_report,
      },
    ],
    [pricing.ai_detection, pricing.plagiarism_check, pricing.complete_report]
  );

  const palette = {
    cyan: {
      bg: "bg-cyan-50 dark:bg-cyan-950/30",
      border: "border-cyan-200 dark:border-cyan-800",
      iconBg: "bg-cyan-100 dark:bg-cyan-900/50",
      iconText: "text-cyan-600 dark:text-cyan-400",
      totalText: "text-cyan-700 dark:text-cyan-300",
    },
    violet: {
      bg: "bg-violet-50 dark:bg-violet-950/30",
      border: "border-violet-200 dark:border-violet-800",
      iconBg: "bg-violet-100 dark:bg-violet-900/50",
      iconText: "text-violet-600 dark:text-violet-400",
      totalText: "text-violet-700 dark:text-violet-300",
    },
    rose: {
      bg: "bg-rose-50 dark:bg-rose-950/30",
      border: "border-rose-200 dark:border-rose-800",
      iconBg: "bg-rose-100 dark:bg-rose-900/50",
      iconText: "text-rose-600 dark:text-rose-400",
      totalText: "text-rose-700 dark:text-rose-300",
    },
  };

  const handleSave = () => {
    onSave([{ key: "turnitin_pricing", value: pricing }]);
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle>Turnitin Check Pricing</CardTitle>
        <CardDescription>
          Configure pricing for AI detection, plagiarism check, and complete
          reports
        </CardDescription>
      </CardHeader>
      <CardContent className="flex flex-col gap-5">
        {/* Report type cards */}
        <div className="grid gap-4 sm:grid-cols-3">
          {cards.map((card) => {
            const p = palette[card.color];
            const gst = card.base * gstRate;
            const total = card.base + gst;
            return (
              <div
                key={card.key}
                className={cn("rounded-xl border", p.border)}
              >
                <div
                  className={cn(
                    "flex items-center gap-3 px-4 py-3 rounded-t-xl",
                    p.bg
                  )}
                >
                  <div className={cn("p-2 rounded-lg", p.iconBg)}>
                    <div className={p.iconText}>{card.icon}</div>
                  </div>
                  <div>
                    <h3 className="font-semibold text-sm">{card.label}</h3>
                    <p className="text-xs text-muted-foreground">
                      {card.description}
                    </p>
                  </div>
                </div>
                <div className="p-4 space-y-3">
                  <div className="flex flex-col gap-2">
                    <Label htmlFor={card.key}>Base Price (₹)</Label>
                    <Input
                      id={card.key}
                      type="number"
                      value={pricing[card.key]}
                      onChange={(e) => updateField(card.key, e.target.value)}
                      min={0}
                      step={1}
                    />
                  </div>
                  <div className="rounded-lg bg-muted/50 px-3 py-2 text-sm">
                    <div className="flex justify-between text-muted-foreground">
                      <span>GST ({pricing.gst_percent}%)</span>
                      <span>₹{gst.toFixed(2)}</span>
                    </div>
                    <div
                      className={cn(
                        "flex justify-between font-semibold mt-1 pt-1 border-t border-dashed",
                        p.totalText
                      )}
                    >
                      <span>Total</span>
                      <span>₹{total.toFixed(2)}</span>
                    </div>
                  </div>
                </div>
              </div>
            );
          })}
        </div>

        {/* GST */}
        <div className="rounded-xl border p-4">
          <div className="flex items-center gap-2 mb-3">
            <span className="text-sm font-semibold">GST Rate</span>
          </div>
          <div className="max-w-xs">
            <Label htmlFor="turnitin_gst">GST Percentage (%)</Label>
            <Input
              id="turnitin_gst"
              type="number"
              value={pricing.gst_percent}
              onChange={(e) => updateField("gst_percent", e.target.value)}
              min={0}
              step={1}
              className="mt-1"
            />
          </div>
        </div>

        <Button onClick={handleSave} disabled={saving} className="w-fit">
          {saving ? "Saving..." : "Save Turnitin Pricing"}
        </Button>
      </CardContent>
    </Card>
  );
}
