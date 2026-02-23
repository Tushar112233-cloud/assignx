"use client";

import { useState } from "react";
import {
  GraduationCap,
  Briefcase,
  Building2,
  Crown,
  Check,
  X,
  ArrowRight,
  Sparkles,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { cn } from "@/lib/utils";
import { UpgradeDialog } from "./upgrade-dialog";
import { accountTiers, featureComparison } from "@/lib/data/account-upgrade";
import type { AccountType } from "@/types/account-upgrade";

interface AccountUpgradeSectionProps {
  /** Current account type of the user */
  currentType: AccountType;
  /** Callback when upgrade is initiated */
  onUpgradeComplete?: (newType: AccountType) => void;
}

/**
 * Get the icon component for an account type
 */
function getAccountIcon(type: AccountType, className?: string) {
  const iconClass = cn("h-5 w-5", className);
  switch (type) {
    case "student":
      return <GraduationCap className={iconClass} />;
    case "professional":
      return <Briefcase className={iconClass} />;
    case "business_owner":
      return <Building2 className={iconClass} />;
  }
}

/**
 * Get badge color for account type
 */
function getBadgeVariant(type: AccountType): "default" | "secondary" | "outline" {
  switch (type) {
    case "business_owner":
      return "default";
    case "professional":
      return "secondary";
    default:
      return "outline";
  }
}

/**
 * Account Upgrade Section Component
 *
 * Displays current account type, available upgrade options,
 * and a benefits comparison table.
 */
export function AccountUpgradeSection({
  currentType,
  onUpgradeComplete,
}: AccountUpgradeSectionProps) {
  const [upgradeDialogOpen, setUpgradeDialogOpen] = useState(false);
  const [selectedUpgrade, setSelectedUpgrade] = useState<AccountType | null>(null);

  const currentTier = accountTiers[currentType];
  const availableUpgrades = currentTier.canUpgradeTo;

  const handleUpgradeClick = (targetType: AccountType) => {
    setSelectedUpgrade(targetType);
    setUpgradeDialogOpen(true);
  };

  const handleUpgradeSuccess = () => {
    if (selectedUpgrade && onUpgradeComplete) {
      onUpgradeComplete(selectedUpgrade);
    }
    setUpgradeDialogOpen(false);
    setSelectedUpgrade(null);
  };

  return (
    <>
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              {getAccountIcon(currentType)}
              <CardTitle>Account Type</CardTitle>
            </div>
            <Badge variant={getBadgeVariant(currentType)}>
              {currentTier.displayName}
            </Badge>
          </div>
          <CardDescription>
            Manage your account type and unlock additional features
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          {/* Current Account Info */}
          <div className="rounded-lg border p-4 bg-muted/30">
            <div className="flex items-center gap-3 mb-3">
              <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10">
                {getAccountIcon(currentType, "text-primary")}
              </div>
              <div>
                <h3 className="font-semibold">{currentTier.displayName} Account</h3>
                <p className="text-sm text-muted-foreground">
                  {currentTier.description}
                </p>
              </div>
            </div>
            <ul className="space-y-2">
              {currentTier.benefits.slice(0, 4).map((benefit, index) => (
                <li key={index} className="flex items-center gap-2 text-sm">
                  <Check className="h-4 w-4 text-green-500 shrink-0" />
                  <span>{benefit}</span>
                </li>
              ))}
              {currentTier.benefits.length > 4 && (
                <li className="text-sm text-muted-foreground">
                  +{currentTier.benefits.length - 4} more benefits
                </li>
              )}
            </ul>
          </div>

          {/* Available Upgrades */}
          {availableUpgrades.length > 0 && (
            <div className="space-y-3">
              <h4 className="text-sm font-medium flex items-center gap-2">
                <Sparkles className="h-4 w-4 text-amber-500" />
                Available Upgrades
              </h4>
              <div className="grid gap-3 sm:grid-cols-2">
                {availableUpgrades.map((upgradeType) => {
                  const tier = accountTiers[upgradeType];
                  return (
                    <div
                      key={upgradeType}
                      className={cn(
                        "relative rounded-lg border p-4 transition-all hover:border-primary hover:shadow-sm cursor-pointer",
                        upgradeType === "professional" && "border-purple-200 bg-purple-50/30",
                        upgradeType === "business_owner" && "border-amber-200 bg-amber-50/30"
                      )}
                      onClick={() => handleUpgradeClick(upgradeType)}
                    >
                      {upgradeType === "business_owner" && (
                        <div className="absolute -top-2.5 left-4">
                          <Badge className="bg-amber-500 text-white">
                            <Crown className="h-3 w-3 mr-1" />
                            Premium
                          </Badge>
                        </div>
                      )}
                      <div className="flex items-start justify-between gap-2">
                        <div className="flex items-center gap-2">
                          {getAccountIcon(upgradeType)}
                          <div>
                            <p className="font-medium">{tier.displayName}</p>
                            <p className="text-xs text-muted-foreground">
                              {tier.description}
                            </p>
                          </div>
                        </div>
                        <ArrowRight className="h-4 w-4 text-muted-foreground shrink-0 mt-1" />
                      </div>
                      <ul className="mt-3 space-y-1">
                        {tier.benefits.slice(0, 3).map((benefit, idx) => (
                          <li key={idx} className="flex items-center gap-1.5 text-xs text-muted-foreground">
                            <Check className="h-3 w-3 text-green-500 shrink-0" />
                            {benefit}
                          </li>
                        ))}
                      </ul>
                    </div>
                  );
                })}
              </div>
            </div>
          )}

          {/* No Upgrades Available */}
          {availableUpgrades.length === 0 && (
            <div className="rounded-lg border border-green-200 bg-green-50/50 p-4">
              <div className="flex items-center gap-2 text-green-700">
                <Crown className="h-5 w-5" />
                <p className="font-medium">You have the highest account tier!</p>
              </div>
              <p className="text-sm text-green-600 mt-1">
                Enjoy all premium features and benefits of your Business account.
              </p>
            </div>
          )}

          {/* Benefits Comparison Table */}
          <div className="space-y-3">
            <h4 className="text-sm font-medium">Feature Comparison</h4>
            <div className="rounded-lg border overflow-hidden">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead className="w-[40%]">Feature</TableHead>
                    <TableHead className="text-center">
                      <div className="flex items-center justify-center gap-1">
                        <GraduationCap className="h-4 w-4" />
                        <span className="hidden sm:inline">Student</span>
                      </div>
                    </TableHead>
                    <TableHead className="text-center">
                      <div className="flex items-center justify-center gap-1">
                        <Briefcase className="h-4 w-4" />
                        <span className="hidden sm:inline">Professional</span>
                      </div>
                    </TableHead>
                    <TableHead className="text-center">
                      <div className="flex items-center justify-center gap-1">
                        <Building2 className="h-4 w-4" />
                        <span className="hidden sm:inline">Business</span>
                      </div>
                    </TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {featureComparison.map((row, index) => (
                    <TableRow key={index}>
                      <TableCell className="font-medium text-sm">
                        {row.feature}
                      </TableCell>
                      <TableCell className="text-center">
                        {renderFeatureValue(row.student)}
                      </TableCell>
                      <TableCell className="text-center">
                        {renderFeatureValue(row.professional)}
                      </TableCell>
                      <TableCell className="text-center">
                        {renderFeatureValue(row.business)}
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>
          </div>

          {/* Upgrade Button */}
          {availableUpgrades.length > 0 && (
            <div className="flex justify-end">
              <Button onClick={() => handleUpgradeClick(availableUpgrades[0])}>
                Upgrade Account
                <ArrowRight className="ml-2 h-4 w-4" />
              </Button>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Upgrade Dialog */}
      <UpgradeDialog
        open={upgradeDialogOpen}
        onOpenChange={setUpgradeDialogOpen}
        currentType={currentType}
        targetType={selectedUpgrade}
        onSuccess={handleUpgradeSuccess}
      />
    </>
  );
}

/**
 * Render feature value as icon or text
 */
function renderFeatureValue(value: string | boolean) {
  if (typeof value === "boolean") {
    return value ? (
      <Check className="h-4 w-4 text-green-500 mx-auto" />
    ) : (
      <X className="h-4 w-4 text-muted-foreground/50 mx-auto" />
    );
  }
  return <span className="text-sm">{value}</span>;
}
