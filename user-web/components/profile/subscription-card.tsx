"use client";

import { useState } from "react";
import {
  Loader2,
  Crown,
  Check,
  Sparkles,
  ArrowRight,
  CreditCard,
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
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import { format } from "date-fns";
import { subscriptionPlans } from "@/lib/data/profile";
import type { UserSubscription, SubscriptionPlan, SubscriptionTier } from "@/types/profile";

interface SubscriptionCardProps {
  subscription: UserSubscription;
  onUpgrade: (planId: string) => Promise<void>;
  onManageBilling: () => void;
}

/**
 * Subscription card component with plan comparison
 */
export function SubscriptionCard({
  subscription,
  onUpgrade,
  onManageBilling,
}: SubscriptionCardProps) {
  const [upgradeDialogOpen, setUpgradeDialogOpen] = useState(false);
  const [selectedPlan, setSelectedPlan] = useState<string | null>(null);
  const [isUpgrading, setIsUpgrading] = useState(false);

  const currentPlan = subscriptionPlans.find(
    (p) => p.tier === subscription.tier
  );

  const handleUpgrade = async (planId: string) => {
    setIsUpgrading(true);
    setSelectedPlan(planId);
    try {
      await onUpgrade(planId);
      toast.success("Subscription upgraded successfully!");
      setUpgradeDialogOpen(false);
    } catch {
      toast.error("Failed to upgrade subscription");
    } finally {
      setIsUpgrading(false);
      setSelectedPlan(null);
    }
  };

  const getTierIcon = (tier: SubscriptionTier) => {
    switch (tier) {
      case "premium":
        return <Crown className="h-5 w-5 text-yellow-500" />;
      case "pro":
        return <Sparkles className="h-5 w-5 text-blue-500" />;
      default:
        return null;
    }
  };

  const getTierBadgeVariant = (tier: SubscriptionTier) => {
    switch (tier) {
      case "premium":
        return "default";
      case "pro":
        return "secondary";
      default:
        return "outline";
    }
  };

  const getStatusBadge = () => {
    switch (subscription.status) {
      case "active":
        return <Badge variant="default" className="bg-green-500">Active</Badge>;
      case "trial":
        return <Badge variant="secondary">Trial</Badge>;
      case "cancelled":
        return <Badge variant="destructive">Cancelled</Badge>;
      case "expired":
        return <Badge variant="outline">Expired</Badge>;
    }
  };

  const periodEnd = format(new Date(subscription.currentPeriodEnd), "MMMM d, yyyy");

  return (
    <>
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              {getTierIcon(subscription.tier)}
              <CardTitle>Subscription</CardTitle>
            </div>
            {getStatusBadge()}
          </div>
          <CardDescription>
            Manage your subscription and billing
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          {/* Current Plan */}
          <div className="rounded-lg border p-4">
            <div className="flex items-center justify-between mb-3">
              <div>
                <div className="flex items-center gap-2">
                  <h3 className="font-semibold text-lg">{currentPlan?.name} Plan</h3>
                  <Badge variant={getTierBadgeVariant(subscription.tier)}>
                    Current
                  </Badge>
                </div>
                <p className="text-sm text-muted-foreground">
                  {currentPlan?.price === 0
                    ? "Free forever"
                    : `$${currentPlan?.price}/${currentPlan?.interval}`}
                </p>
              </div>
              {subscription.tier !== "premium" && (
                <Button onClick={() => setUpgradeDialogOpen(true)}>
                  Upgrade
                  <ArrowRight className="ml-2 h-4 w-4" />
                </Button>
              )}
            </div>

            {/* Features */}
            <ul className="space-y-2">
              {currentPlan?.features.slice(0, 4).map((feature, index) => (
                <li key={index} className="flex items-center gap-2 text-sm">
                  <Check className="h-4 w-4 text-green-500" />
                  <span>{feature}</span>
                </li>
              ))}
            </ul>
          </div>

          {/* Billing Info */}
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-muted-foreground">
                {subscription.cancelAtPeriodEnd
                  ? "Subscription ends on"
                  : "Next billing date"}
              </p>
              <p className="font-medium">{periodEnd}</p>
            </div>
            <Button variant="outline" onClick={onManageBilling}>
              <CreditCard className="mr-2 h-4 w-4" />
              Manage Billing
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Upgrade Dialog */}
      <Dialog open={upgradeDialogOpen} onOpenChange={setUpgradeDialogOpen}>
        <DialogContent className="max-w-3xl">
          <DialogHeader>
            <DialogTitle>Choose Your Plan</DialogTitle>
            <DialogDescription>
              Select a plan that best fits your needs
            </DialogDescription>
          </DialogHeader>
          <div className="grid gap-4 md:grid-cols-3 py-4">
            {subscriptionPlans.map((plan) => (
              <PlanCard
                key={plan.id}
                plan={plan}
                isCurrentPlan={plan.tier === subscription.tier}
                isDowngrade={getPlanOrder(plan.tier) < getPlanOrder(subscription.tier)}
                onSelect={() => handleUpgrade(plan.id)}
                isLoading={isUpgrading && selectedPlan === plan.id}
                disabled={isUpgrading}
              />
            ))}
          </div>
        </DialogContent>
      </Dialog>
    </>
  );
}

/**
 * Plan comparison card component
 */
function PlanCard({
  plan,
  isCurrentPlan,
  isDowngrade,
  onSelect,
  isLoading,
  disabled,
}: {
  plan: SubscriptionPlan;
  isCurrentPlan: boolean;
  isDowngrade: boolean;
  onSelect: () => void;
  isLoading: boolean;
  disabled: boolean;
}) {
  return (
    <div
      className={cn(
        "relative rounded-lg border p-4 transition-all",
        plan.highlighted && "border-primary shadow-md",
        isCurrentPlan && "bg-muted/50"
      )}
    >
      {plan.highlighted && (
        <Badge className="absolute -top-2.5 left-1/2 -translate-x-1/2">
          Popular
        </Badge>
      )}

      <div className="text-center mb-4">
        <h3 className="font-semibold text-lg">{plan.name}</h3>
        <div className="mt-2">
          {plan.price === 0 ? (
            <span className="text-3xl font-bold">Free</span>
          ) : (
            <>
              <span className="text-3xl font-bold">${plan.price}</span>
              <span className="text-muted-foreground">/{plan.interval}</span>
            </>
          )}
        </div>
      </div>

      <ul className="space-y-2 mb-6">
        {plan.features.map((feature, index) => (
          <li key={index} className="flex items-start gap-2 text-sm">
            <Check className="h-4 w-4 text-green-500 mt-0.5 shrink-0" />
            <span>{feature}</span>
          </li>
        ))}
      </ul>

      <Button
        className="w-full"
        variant={isCurrentPlan ? "outline" : plan.highlighted ? "default" : "secondary"}
        onClick={onSelect}
        disabled={isCurrentPlan || isDowngrade || disabled}
      >
        {isLoading ? (
          <>
            <Loader2 className="mr-2 h-4 w-4 animate-spin" />
            Processing...
          </>
        ) : isCurrentPlan ? (
          "Current Plan"
        ) : isDowngrade ? (
          "Contact Support"
        ) : (
          "Upgrade"
        )}
      </Button>
    </div>
  );
}

/**
 * Get numeric order for plan comparison
 */
function getPlanOrder(tier: SubscriptionTier): number {
  switch (tier) {
    case "free":
      return 0;
    case "pro":
      return 1;
    case "premium":
      return 2;
  }
}
