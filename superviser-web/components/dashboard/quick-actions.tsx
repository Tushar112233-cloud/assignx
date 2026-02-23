/**
 * @fileoverview QuickActions - Quick action buttons for supervisor dashboard
 */

import Link from "next/link"
import { FolderKanban, Wallet, Users, BarChart3, ArrowRight, Zap } from "lucide-react"
import { Card, CardHeader, CardTitle, CardContent, CardDescription } from "@/components/ui/card"

export interface QuickActionsProps {
  onCreatePromptClick?: () => void
  onViewAnalyticsClick?: () => void
  onManageTeamClick?: () => void
  onUpgradePlanClick?: () => void
  onStartTourClick?: () => void
  className?: string
}

interface QuickActionLinkProps {
  href: string
  icon: React.ReactNode
  title: string
  description: string
}

function QuickActionLink({ href, icon, title, description }: QuickActionLinkProps) {
  return (
    <Link
      href={href}
      className="flex items-center gap-3 rounded-xl border-2 border-gray-200 bg-white p-4 text-left transition-colors duration-200 hover:border-gray-300 hover:bg-gray-50/50 w-full"
    >
      <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10 text-primary flex-shrink-0 transition-colors duration-200">
        {icon}
      </div>
      <div className="flex-1 min-w-0">
        <p className="font-medium text-sm">{title}</p>
        <p className="text-xs text-muted-foreground truncate">{description}</p>
      </div>
      <ArrowRight className="h-4 w-4 text-muted-foreground flex-shrink-0" />
    </Link>
  )
}

export function QuickActions({
  onCreatePromptClick,
  onViewAnalyticsClick,
  onManageTeamClick,
  onUpgradePlanClick,
  onStartTourClick,
  className,
}: QuickActionsProps) {
  return (
    <div className={className}>
      <Card className="h-full rounded-2xl border-border/50 shadow-none">
        <CardHeader className="pb-2">
          <CardTitle className="text-base flex items-center gap-2">
            <Zap className="h-4 w-4 text-primary" />
            Quick Actions
          </CardTitle>
          <CardDescription className="text-xs">
            Jump into common tasks
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid gap-3 sm:grid-cols-2">
            <QuickActionLink
              href="/projects"
              icon={<FolderKanban className="h-4 w-4" />}
              title="View Projects"
              description="Manage your projects"
            />
            <QuickActionLink
              href="/earnings"
              icon={<Wallet className="h-4 w-4" />}
              title="Check Earnings"
              description="View your earnings"
            />
            <QuickActionLink
              href="/doers"
              icon={<Users className="h-4 w-4" />}
              title="Manage Doers"
              description="Manage your team"
            />
            <QuickActionLink
              href="/analytics"
              icon={<BarChart3 className="h-4 w-4" />}
              title="View Analytics"
              description="Track performance"
            />
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
