/**
 * @fileoverview RecentActivity - Recent activity timeline card
 */

import { memo } from "react"
import { motion } from "framer-motion"
import { Clock, Activity, ArrowRight, Zap, Folder, CreditCard, MessageSquare, UserCheck } from "lucide-react"
import { Card, CardHeader, CardTitle, CardContent, CardDescription } from "@/components/ui/card"
import { Button } from "@/components/ui/button"

export interface RecentActivityProps {
  runsCount: number
  promptsCount: number
  competitorsCount: number
  onViewAllClick?: () => void
  onRunPromptsClick?: () => void
}

interface ActivityItemProps {
  icon: React.ReactNode
  title: string
  time: string
  color: "primary" | "secondary" | "accent" | "muted"
}

const colorClasses = {
  primary: "bg-primary/15 text-primary",
  secondary: "bg-secondary text-secondary-foreground",
  accent: "bg-accent/30 text-accent-foreground",
  muted: "bg-muted text-muted-foreground",
}

/**
 * Memoized ActivityItem component
 */
const ActivityItem = memo(function ActivityItem({ icon, title, time, color }: ActivityItemProps) {
  return (
    <div className="flex items-center gap-3 rounded-lg p-3 bg-muted/30">
      <div className={`flex h-8 w-8 items-center justify-center rounded-lg ${colorClasses[color]}`}>
        {icon}
      </div>
      <div className="flex-1 min-w-0">
        <p className="text-sm font-medium truncate">{title}</p>
      </div>
      <span className="text-xs text-muted-foreground">{time}</span>
    </div>
  )
})

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.4 } },
}

export function RecentActivity({
  runsCount,
  promptsCount,
  competitorsCount,
  onViewAllClick,
  onRunPromptsClick,
}: RecentActivityProps) {
  return (
    <motion.div variants={itemVariants}>
      <Card className="rounded-2xl border-border/50">
        <CardHeader className="pb-2">
          <div className="flex items-center justify-between">
            <div>
              <CardTitle className="text-base flex items-center gap-2">
                <Clock className="h-4 w-4 text-primary" />
                Recent Activity
              </CardTitle>
              <CardDescription className="text-xs">
                Your latest workspace activity
              </CardDescription>
            </div>
            {onViewAllClick && (
              <Button
                variant="ghost"
                size="sm"
                className="text-xs"
                onClick={onViewAllClick}
              >
                View All
                <ArrowRight className="ml-1 h-3 w-3" />
              </Button>
            )}
          </div>
        </CardHeader>
        <CardContent>
          {runsCount === 0 ? (
            <div className="flex flex-col items-center justify-center py-12 text-center">
              <div className="flex h-16 w-16 items-center justify-center rounded-full bg-muted">
                <Activity className="h-8 w-8 text-muted-foreground" />
              </div>
              <h3 className="mt-4 font-medium">No activity yet</h3>
              <p className="mt-1 text-sm text-muted-foreground max-w-xs">
                Run your first prompt to see activity here
              </p>
              {onRunPromptsClick && (
                <Button
                  className="mt-4 rounded-full"
                  size="sm"
                  onClick={onRunPromptsClick}
                >
                  <Zap className="mr-2 h-4 w-4" />
                  Run Prompts
                </Button>
              )}
            </div>
          ) : (
            <div className="space-y-3">
              <ActivityItem
                icon={<Zap className="h-4 w-4" />}
                title={`${runsCount} projects completed`}
                time="Recently"
                color="primary"
              />
              <ActivityItem
                icon={<MessageSquare className="h-4 w-4" />}
                title={`${promptsCount} new requests`}
                time="Active"
                color="secondary"
              />
              <ActivityItem
                icon={<Folder className="h-4 w-4" />}
                title={`${competitorsCount} ready to assign`}
                time="Monitoring"
                color="accent"
              />
            </div>
          )}
        </CardContent>
      </Card>
    </motion.div>
  )
}
