"use client";

import { useMemo } from "react";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Badge } from "@/components/ui/badge";
import { useProjectStore } from "@/stores/project-store";
import type { ProjectTab } from "@/types/project";
import { cn } from "@/lib/utils";

interface TabConfig {
  value: ProjectTab;
  label: string;
}

const tabs: TabConfig[] = [
  { value: "in_review", label: "In Review" },
  { value: "in_progress", label: "In Progress" },
  { value: "for_review", label: "For Review" },
  { value: "history", label: "History" },
];

interface ProjectTabsProps {
  className?: string;
}

/**
 * Tab navigation for project filtering
 * Shows count badges for each tab
 */
export function ProjectTabs({ className }: ProjectTabsProps) {
  const { activeTab, setActiveTab, getProjectsByTab, projects } = useProjectStore();

  // Memoize tab counts to avoid recalculating on every render
  const tabCounts = useMemo(() => {
    return tabs.reduce((acc, tab) => {
      acc[tab.value] = getProjectsByTab(tab.value).length;
      return acc;
    }, {} as Record<ProjectTab, number>);
  }, [getProjectsByTab, projects]);

  return (
    <Tabs
      value={activeTab}
      onValueChange={(value) => setActiveTab(value as ProjectTab)}
      className={className}
    >
      <TabsList className="grid w-full grid-cols-4">
        {tabs.map((tab) => {
          const count = tabCounts[tab.value];
          return (
            <TabsTrigger
              key={tab.value}
              value={tab.value}
              className="relative gap-1.5 text-xs sm:text-sm"
            >
              <span className="hidden sm:inline">{tab.label}</span>
              <span className="sm:hidden">
                {tab.label.split(" ")[0]}
              </span>
              {count > 0 && (
                <Badge
                  variant={activeTab === tab.value ? "default" : "secondary"}
                  className={cn(
                    "h-5 min-w-5 px-1.5 text-xs",
                    activeTab === tab.value
                      ? "bg-background text-foreground"
                      : ""
                  )}
                >
                  {count}
                </Badge>
              )}
            </TabsTrigger>
          );
        })}
      </TabsList>
    </Tabs>
  );
}
