"use client";

import { MessageCircle } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";

/**
 * Floating support button
 * Opens WhatsApp chat for customer support
 */
export function SupportButton() {
  const handleClick = () => {
    // WhatsApp Business number - replace with actual number
    const phoneNumber = "919876543210";
    const message = encodeURIComponent(
      "Hi! I need help with AssignX."
    );
    window.open(
      `https://wa.me/${phoneNumber}?text=${message}`,
      "_blank"
    );
  };

  return (
    <TooltipProvider>
      <Tooltip>
        <TooltipTrigger asChild>
          <Button
            onClick={handleClick}
            size="icon"
            className="fixed bottom-6 right-6 z-40 h-14 w-14 rounded-full shadow-lg transition-transform hover:scale-105"
            aria-label="Contact Support"
          >
            <MessageCircle className="h-6 w-6" />
          </Button>
        </TooltipTrigger>
        <TooltipContent side="left">
          <p>Need help? Chat with us</p>
        </TooltipContent>
      </Tooltip>
    </TooltipProvider>
  );
}
