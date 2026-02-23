"use client";

import { useState } from "react";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Switch } from "@/components/ui/switch";
import { Button } from "@/components/ui/button";

type SettingsGroup = Record<
  string,
  { id: string; key: string; value: unknown; description: string | null }[]
>;

const FEATURE_FLAGS = [
  {
    key: "feature_wallet_transfers",
    label: "Wallet Transfers",
    description: "Allow users to transfer funds between wallets",
  },
  {
    key: "feature_expert_sessions",
    label: "Expert Sessions",
    description: "Enable expert consultation booking",
  },
  {
    key: "feature_learning_resources",
    label: "Learning Resources",
    description: "Show learning section to users",
  },
  {
    key: "feature_chat",
    label: "In-App Chat",
    description: "Enable real-time messaging between users",
  },
  {
    key: "feature_referrals",
    label: "Referral Program",
    description: "Enable referral rewards system",
  },
  {
    key: "feature_analytics_dashboard",
    label: "User Analytics",
    description: "Show analytics dashboard to supervisors",
  },
];

export function FeatureFlags({
  settings,
  onSave,
  saving,
}: {
  settings: SettingsGroup;
  onSave: (flags: { key: string; value: unknown }[]) => Promise<void>;
  saving: boolean;
}) {
  const featuresGroup = settings["features"] || [];

  const [flags, setFlags] = useState<Record<string, boolean>>(() => {
    const initial: Record<string, boolean> = {};
    FEATURE_FLAGS.forEach((flag) => {
      const found = featuresGroup.find((s) => s.key === flag.key);
      initial[flag.key] = (found?.value as boolean) ?? false;
    });
    return initial;
  });

  const toggleFlag = (key: string) => {
    setFlags((prev) => ({ ...prev, [key]: !prev[key] }));
  };

  const handleSave = () => {
    const updates = Object.entries(flags).map(([key, value]) => ({
      key,
      value,
    }));
    onSave(updates);
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle>Feature Flags</CardTitle>
        <CardDescription>
          Enable or disable platform features
        </CardDescription>
      </CardHeader>
      <CardContent className="flex flex-col gap-4">
        {FEATURE_FLAGS.map((flag) => (
          <div
            key={flag.key}
            className="flex items-center justify-between rounded-lg border p-4"
          >
            <div>
              <p className="font-medium">{flag.label}</p>
              <p className="text-sm text-muted-foreground">
                {flag.description}
              </p>
            </div>
            <Switch
              checked={flags[flag.key] ?? false}
              onCheckedChange={() => toggleFlag(flag.key)}
            />
          </div>
        ))}
        <Button onClick={handleSave} disabled={saving} className="w-fit">
          {saving ? "Saving..." : "Save Feature Flags"}
        </Button>
      </CardContent>
    </Card>
  );
}
