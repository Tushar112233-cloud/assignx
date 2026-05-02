"use client";

import { Info, ExternalLink } from "lucide-react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { appVersion } from "@/lib/data/settings";
import { format } from "date-fns";

/** App information and version details section */
export function AppInfoSection() {
  const lastUpdated = format(new Date(appVersion.lastUpdated), "MMMM d, yyyy");

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Info className="h-5 w-5" />
          About AssignX
        </CardTitle>
        <CardDescription>App version and legal information</CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="flex items-center justify-between">
          <span className="text-muted-foreground">Version</span>
          <div className="flex items-center gap-2">
            <span className="font-mono">{appVersion.version}</span>
            <Badge variant="secondary">Beta</Badge>
          </div>
        </div>
        <div className="flex items-center justify-between">
          <span className="text-muted-foreground">Build</span>
          <span className="font-mono">{appVersion.buildNumber}</span>
        </div>
        <div className="flex items-center justify-between">
          <span className="text-muted-foreground">Last Updated</span>
          <span>{lastUpdated}</span>
        </div>
        <div className="pt-4 space-y-2 border-t">
          <a href="#" className="flex items-center justify-between text-sm hover:underline">
            Terms of Service <ExternalLink className="h-4 w-4" />
          </a>
          <a href="#" className="flex items-center justify-between text-sm hover:underline">
            Privacy Policy <ExternalLink className="h-4 w-4" />
          </a>
          <a href="#" className="flex items-center justify-between text-sm hover:underline">
            Open Source Licenses <ExternalLink className="h-4 w-4" />
          </a>
        </div>
      </CardContent>
    </Card>
  );
}
