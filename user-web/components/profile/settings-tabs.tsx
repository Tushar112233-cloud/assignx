"use client";

import {
  User,
  GraduationCap,
  Settings,
  Shield,
  CreditCard,
} from "lucide-react";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import { cn } from "@/lib/utils";
import type { ProfileTab } from "@/types/profile";

interface SettingsTabsProps {
  activeTab: ProfileTab;
  onTabChange: (tab: ProfileTab) => void;
  children: React.ReactNode;
}

interface MobileSettingsProps {
  activeTab: ProfileTab;
  onTabChange: (tab: ProfileTab) => void;
  children: React.ReactNode;
}

const tabs: { value: ProfileTab; label: string; icon: React.ElementType }[] = [
  { value: "personal", label: "Personal", icon: User },
  { value: "academic", label: "Academic", icon: GraduationCap },
  { value: "preferences", label: "Preferences", icon: Settings },
  { value: "security", label: "Security", icon: Shield },
  { value: "subscription", label: "Subscription", icon: CreditCard },
];

/**
 * Settings navigation tabs component
 * Desktop: Top tabs navigation
 * Mobile: Accordion sections
 */
export function SettingsTabs({
  activeTab,
  onTabChange,
  children,
}: SettingsTabsProps) {
  return (
    <>
      {/* Desktop Tabs */}
      <div className="hidden md:block">
        <DesktopTabs
          activeTab={activeTab}
          onTabChange={onTabChange}
        />
        <div className="mt-6">{children}</div>
      </div>

      {/* Mobile Accordion */}
      <div className="md:hidden">
        <MobileSettings
          activeTab={activeTab}
          onTabChange={onTabChange}
        >
          {children}
        </MobileSettings>
      </div>
    </>
  );
}

/**
 * Desktop tab navigation
 */
function DesktopTabs({
  activeTab,
  onTabChange,
}: {
  activeTab: ProfileTab;
  onTabChange: (tab: ProfileTab) => void;
}) {
  return (
    <Tabs value={activeTab} onValueChange={(v) => onTabChange(v as ProfileTab)}>
      <TabsList className="w-full justify-start overflow-x-auto">
        {tabs.map((tab) => {
          const Icon = tab.icon;
          return (
            <TabsTrigger
              key={tab.value}
              value={tab.value}
              className="gap-2"
            >
              <Icon className="h-4 w-4" />
              {tab.label}
            </TabsTrigger>
          );
        })}
      </TabsList>
    </Tabs>
  );
}

/**
 * Mobile accordion navigation
 */
function MobileSettings({
  activeTab,
  onTabChange,
  children,
}: MobileSettingsProps) {
  // Convert children to array for distribution
  const childrenArray = Array.isArray(children) ? children : [children];

  return (
    <Accordion
      type="single"
      value={activeTab}
      onValueChange={(value) => {
        if (value) onTabChange(value as ProfileTab);
      }}
      className="space-y-2"
    >
      {tabs.map((tab, index) => {
        const Icon = tab.icon;
        return (
          <AccordionItem
            key={tab.value}
            value={tab.value}
            className="border rounded-lg px-4"
          >
            <AccordionTrigger className="hover:no-underline">
              <div className="flex items-center gap-2">
                <Icon className="h-4 w-4" />
                <span>{tab.label}</span>
              </div>
            </AccordionTrigger>
            <AccordionContent className="pt-4">
              {childrenArray[index]}
            </AccordionContent>
          </AccordionItem>
        );
      })}
    </Accordion>
  );
}

/**
 * Settings section wrapper with consistent styling
 */
export function SettingsSection({
  children,
  className,
}: {
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <div className={cn("space-y-6", className)}>
      {children}
    </div>
  );
}
