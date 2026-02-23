"use client";

import { Package, Clock } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { DeliverableItem } from "./deliverable-item";
import { cn } from "@/lib/utils";
import type { Deliverable, ProjectStatus } from "@/types/project";

interface DeliverablesSectionProps {
  status: ProjectStatus;
  deliverables: Deliverable[];
  className?: string;
}

/**
 * Check if deliverables should be visible
 */
function shouldShowDeliverables(status: ProjectStatus): boolean {
  const visibleStatuses: ProjectStatus[] = [
    "delivered",
    "qc_approved",
    "completed",
  ];
  return visibleStatuses.includes(status);
}

/**
 * Deliverables section with file list
 */
export function DeliverablesSection({
  status,
  deliverables,
  className,
}: DeliverablesSectionProps) {
  const isVisible = shouldShowDeliverables(status);

  return (
    <Card className={cn(className)}>
      <CardHeader className="pb-3">
        <CardTitle className="flex items-center gap-2 text-base">
          <Package className="h-5 w-5 text-primary" />
          Deliverables
        </CardTitle>
      </CardHeader>
      <CardContent>
        {!isVisible ? (
          // Not yet available
          <div className="flex flex-col items-center justify-center rounded-lg border border-dashed bg-muted/50 p-6 text-center">
            <Clock className="mb-2 h-8 w-8 text-muted-foreground/50" />
            <p className="text-sm text-muted-foreground">
              Files will appear here once ready
            </p>
            <p className="mt-1 text-xs text-muted-foreground/70">
              You&apos;ll be notified when deliverables are uploaded
            </p>
          </div>
        ) : deliverables.length === 0 ? (
          // No deliverables
          <p className="text-sm text-muted-foreground">
            No deliverables uploaded yet
          </p>
        ) : (
          // Deliverables list
          <div className="space-y-2">
            {deliverables.map((deliverable) => (
              <DeliverableItem
                key={deliverable.id}
                deliverable={deliverable}
              />
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  );
}
