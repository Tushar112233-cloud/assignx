"use client";

import { Plus } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";

interface CentralFABProps {
  onClick: () => void;
}

/**
 * Central floating action button (desktop only)
 * Opens the upload sheet for quick project actions
 */
export function CentralFAB({ onClick }: CentralFABProps) {
  return (
    <TooltipProvider>
      <Tooltip>
        <TooltipTrigger asChild>
          <Button
            onClick={onClick}
            size="icon"
            className="fixed bottom-8 right-8 z-40 hidden h-14 w-14 rounded-full shadow-lg transition-transform hover:scale-105 lg:flex"
          >
            <Plus className="h-6 w-6" />
          </Button>
        </TooltipTrigger>
        <TooltipContent side="left">
          <p>Add New Project</p>
        </TooltipContent>
      </Tooltip>
    </TooltipProvider>
  );
}
