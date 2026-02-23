"use client";

import Link from "next/link";
import { FileText, FileSearch, Brain, MessageSquare } from "lucide-react";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import { Badge } from "@/components/ui/badge";

const uploadOptions = [
  {
    id: "new-project",
    title: "New Project",
    description: "Submit a new project for expert help",
    icon: FileText,
    href: "/projects/new",
  },
  {
    id: "proofreading",
    title: "Quick Proofread",
    description: "Get your document reviewed and polished",
    icon: FileSearch,
    href: "/projects/new?type=proofreading",
  },
  {
    id: "ai-check",
    title: "AI/Plagiarism Check",
    description: "Verify originality of your content",
    icon: Brain,
    href: "/projects/new?type=report",
  },
  {
    id: "expert-opinion",
    title: "Expert Opinion",
    description: "Ask an expert for guidance",
    icon: MessageSquare,
    href: "/projects/new?type=consultation",
    badge: "Free",
  },
];

interface UploadSheetProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

/**
 * Upload sheet with quick action options
 * Bottom sheet on mobile, side sheet on desktop
 */
export function UploadSheet({ open, onOpenChange }: UploadSheetProps) {
  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent side="bottom" className="h-auto rounded-t-xl lg:hidden">
        <SheetHeader className="text-left pb-2">
          <SheetTitle className="text-lg">What would you like to do?</SheetTitle>
          <SheetDescription className="text-sm">
            Choose an option to get started
          </SheetDescription>
        </SheetHeader>
        <div className="mt-4 space-y-2">
          {uploadOptions.map((option) => (
            <Link
              key={option.id}
              href={option.href}
              onClick={() => onOpenChange(false)}
              className="flex items-center gap-3 rounded-lg border-2 border-border bg-card p-4 transition-all hover:border-[#765341]/50 hover:bg-gradient-to-r hover:from-[#765341]/10 hover:to-[#A07A65]/10 hover:shadow-md hover:-translate-y-0.5 group"
            >
              <div className="flex h-10 w-10 items-center justify-center rounded-lg border border-border bg-muted/30 text-muted-foreground group-hover:bg-[#765341] group-hover:text-white group-hover:border-[#765341] transition-all">
                <option.icon className="h-5 w-5" />
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                  <span className="text-sm font-medium">{option.title}</span>
                  {option.badge && (
                    <Badge variant="outline" className="text-[10px] px-1.5 py-0 h-4 border-emerald-500 text-emerald-600 dark:text-emerald-400">
                      {option.badge}
                    </Badge>
                  )}
                </div>
                <p className="text-xs text-muted-foreground truncate">
                  {option.description}
                </p>
              </div>
            </Link>
          ))}
        </div>
      </SheetContent>

      {/* Desktop side sheet */}
      <SheetContent side="right" className="hidden w-[380px] lg:block">
        <SheetHeader className="pb-2">
          <SheetTitle className="text-lg">What would you like to do?</SheetTitle>
          <SheetDescription className="text-sm">
            Choose an option to get started
          </SheetDescription>
        </SheetHeader>
        <div className="mt-4 space-y-2">
          {uploadOptions.map((option) => (
            <Link
              key={option.id}
              href={option.href}
              onClick={() => onOpenChange(false)}
              className="flex items-center gap-3 rounded-lg border-2 border-border bg-card p-4 transition-all hover:border-[#765341]/50 hover:bg-gradient-to-r hover:from-[#765341]/10 hover:to-[#A07A65]/10 hover:shadow-md hover:-translate-y-0.5 group"
            >
              <div className="flex h-10 w-10 items-center justify-center rounded-lg border border-border bg-muted/30 text-muted-foreground group-hover:bg-[#765341] group-hover:text-white group-hover:border-[#765341] transition-all">
                <option.icon className="h-5 w-5" />
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                  <span className="text-sm font-medium">{option.title}</span>
                  {option.badge && (
                    <Badge variant="outline" className="text-[10px] px-1.5 py-0 h-4 border-emerald-500 text-emerald-600 dark:text-emerald-400">
                      {option.badge}
                    </Badge>
                  )}
                </div>
                <p className="text-xs text-muted-foreground truncate">
                  {option.description}
                </p>
              </div>
            </Link>
          ))}
        </div>
      </SheetContent>
    </Sheet>
  );
}
