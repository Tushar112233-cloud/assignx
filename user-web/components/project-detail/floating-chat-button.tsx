"use client";

import { MessageCircle } from "lucide-react";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

interface FloatingChatButtonProps {
  unreadCount?: number;
  onClick: () => void;
  className?: string;
}

/**
 * Floating chat button fixed at bottom-right
 */
export function FloatingChatButton({
  unreadCount = 0,
  onClick,
  className,
}: FloatingChatButtonProps) {
  return (
    <Button
      onClick={onClick}
      size="icon"
      className={cn(
        "fixed bottom-20 right-4 z-50 h-14 w-14 rounded-full shadow-lg md:bottom-6",
        className
      )}
    >
      <MessageCircle className="h-6 w-6" />

      {/* Unread badge */}
      {unreadCount > 0 && (
        <span className="absolute -right-1 -top-1 flex h-5 w-5 items-center justify-center rounded-full bg-red-500 text-[10px] font-bold text-white">
          {unreadCount > 9 ? "9+" : unreadCount}
        </span>
      )}

      <span className="sr-only">
        Open chat {unreadCount > 0 && `(${unreadCount} unread)`}
      </span>
    </Button>
  );
}
