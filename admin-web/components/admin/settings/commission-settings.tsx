"use client";

import { useState } from "react";
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

type SettingsGroup = Record<
  string,
  { id: string; key: string; value: unknown; description: string | null }[]
>;

const COMMISSION_TYPES = [
  { key: "commission_assignment", label: "Assignment Help", description: "Commission on assignment projects" },
  { key: "commission_project", label: "Project Work", description: "Commission on project-based work" },
  { key: "commission_tutoring", label: "Tutoring", description: "Commission on tutoring sessions" },
  { key: "commission_consultation", label: "Consultation", description: "Commission on expert consultations" },
];

export function CommissionSettings({
  settings,
  onSave,
  saving,
}: {
  settings: SettingsGroup;
  onSave: (commissions: { key: string; value: unknown }[]) => Promise<void>;
  saving: boolean;
}) {
  const paymentsGroup = settings["payments"] || [];

  const [commissions, setCommissions] = useState<Record<string, string>>(() => {
    const initial: Record<string, string> = {};
    COMMISSION_TYPES.forEach((ct) => {
      const found = paymentsGroup.find((s) => s.key === ct.key);
      initial[ct.key] = String((found?.value as number) ?? 10);
    });

    const minAmount = paymentsGroup.find((s) => s.key === "min_transaction_amount");
    const maxAmount = paymentsGroup.find((s) => s.key === "max_transaction_amount");
    initial["min_transaction_amount"] = String((minAmount?.value as number) ?? 100);
    initial["max_transaction_amount"] = String((maxAmount?.value as number) ?? 100000);

    return initial;
  });

  const updateCommission = (key: string, value: string) => {
    setCommissions((prev) => ({ ...prev, [key]: value }));
  };

  const handleSave = () => {
    const updates = Object.entries(commissions).map(([key, value]) => ({
      key,
      value: parseFloat(value) || 0,
    }));
    onSave(updates);
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle>Payment & Commission Settings</CardTitle>
        <CardDescription>
          Configure commission rates and transaction limits
        </CardDescription>
      </CardHeader>
      <CardContent className="flex flex-col gap-6">
        <div>
          <h3 className="mb-3 font-medium">Commission Rates (%)</h3>
          <div className="grid gap-4 sm:grid-cols-2">
            {COMMISSION_TYPES.map((ct) => (
              <div key={ct.key} className="flex flex-col gap-2">
                <Label htmlFor={ct.key}>{ct.label}</Label>
                <div className="flex items-center gap-2">
                  <Input
                    id={ct.key}
                    type="number"
                    value={commissions[ct.key]}
                    onChange={(e) => updateCommission(ct.key, e.target.value)}
                    min={0}
                    max={100}
                    step={0.5}
                    className="w-24"
                  />
                  <span className="text-sm text-muted-foreground">%</span>
                </div>
                <p className="text-xs text-muted-foreground">
                  {ct.description}
                </p>
              </div>
            ))}
          </div>
        </div>

        <div>
          <h3 className="mb-3 font-medium">Transaction Limits</h3>
          <div className="grid gap-4 sm:grid-cols-2">
            <div className="flex flex-col gap-2">
              <Label htmlFor="min_transaction_amount">Minimum Amount</Label>
              <div className="flex items-center gap-2">
                <span className="text-sm text-muted-foreground">&#8377;</span>
                <Input
                  id="min_transaction_amount"
                  type="number"
                  value={commissions["min_transaction_amount"]}
                  onChange={(e) =>
                    updateCommission("min_transaction_amount", e.target.value)
                  }
                  min={0}
                />
              </div>
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="max_transaction_amount">Maximum Amount</Label>
              <div className="flex items-center gap-2">
                <span className="text-sm text-muted-foreground">&#8377;</span>
                <Input
                  id="max_transaction_amount"
                  type="number"
                  value={commissions["max_transaction_amount"]}
                  onChange={(e) =>
                    updateCommission("max_transaction_amount", e.target.value)
                  }
                  min={0}
                />
              </div>
            </div>
          </div>
        </div>

        <Button onClick={handleSave} disabled={saving} className="w-fit">
          {saving ? "Saving..." : "Save Payment Settings"}
        </Button>
      </CardContent>
    </Card>
  );
}
