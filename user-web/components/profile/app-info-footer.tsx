"use client";

import Link from "next/link";
import { PlayCircle, Info, FileText, Shield } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Separator } from "@/components/ui/separator";

/**
 * App version - should match package.json
 */
const APP_VERSION = "1.0.0";

/**
 * App Info Footer Component
 * Shows "How It Works", legal links, and app version
 * Implements U93 (How It Works) and U96 (App Version) from feature spec
 */
export function AppInfoFooter() {
  return (
    <div className="space-y-4">
      {/* How It Works */}
      <Button variant="outline" className="w-full justify-start" asChild>
        <Link href="/onboarding">
          <PlayCircle className="h-4 w-4 mr-3 text-primary" />
          How It Works
          <span className="ml-auto text-xs text-muted-foreground">
            View tutorial
          </span>
        </Link>
      </Button>

      <Separator />

      {/* Legal Links */}
      <div className="space-y-2">
        <Button
          variant="ghost"
          size="sm"
          className="w-full justify-start h-9 px-2"
          asChild
        >
          <Link href="/terms">
            <FileText className="h-4 w-4 mr-3 text-muted-foreground" />
            Terms & Conditions
          </Link>
        </Button>
        <Button
          variant="ghost"
          size="sm"
          className="w-full justify-start h-9 px-2"
          asChild
        >
          <Link href="/privacy">
            <Shield className="h-4 w-4 mr-3 text-muted-foreground" />
            Privacy Policy
          </Link>
        </Button>
      </div>

      <Separator />

      {/* App Version */}
      <div className="flex items-center justify-center gap-2 py-4 text-xs text-muted-foreground">
        <Info className="h-3 w-3" />
        <span>AssignX v{APP_VERSION}</span>
      </div>
    </div>
  );
}
