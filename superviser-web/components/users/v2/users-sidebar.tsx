"use client"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Filter, Activity, UserPlus, CheckCircle, Briefcase } from "lucide-react"
import { formatDistanceToNow } from "date-fns"

interface QuickFilter {
  id: string
  label: string
  count: number
  color: 'green' | 'orange' | 'blue' | 'gray'
}

interface ActivityItem {
  id: string
  type: 'project_created' | 'project_completed' | 'user_joined'
  user_name: string
  user_avatar?: string
  timestamp: string
  description: string
}

interface UsersSidebarProps {
  quickFilters: QuickFilter[]
  recentActivity: ActivityItem[]
  activeFilter?: string
  onFilterClick: (filterId: string) => void
}

const colorClasses = {
  green: {
    bg: 'bg-green-50 hover:bg-green-100',
    text: 'text-green-700',
    indicator: 'bg-green-500',
    active: 'bg-green-50 border-green-400',
    badgeActive: 'bg-green-100 text-green-700'
  },
  orange: {
    bg: 'bg-orange-50 hover:bg-orange-100',
    text: 'text-orange-700',
    indicator: 'bg-orange-500',
    active: 'bg-orange-50 border-orange-500',
    badgeActive: 'bg-orange-100 text-orange-700'
  },
  blue: {
    bg: 'bg-blue-50 hover:bg-blue-100',
    text: 'text-blue-700',
    indicator: 'bg-blue-500',
    active: 'bg-blue-50 border-blue-400',
    badgeActive: 'bg-blue-100 text-blue-700'
  },
  gray: {
    bg: 'bg-gray-50 hover:bg-gray-100',
    text: 'text-gray-700',
    indicator: 'bg-gray-500',
    active: 'bg-gray-50 border-gray-400',
    badgeActive: 'bg-gray-100 text-gray-700'
  }
}

const activityIcons = {
  project_created: Briefcase,
  project_completed: CheckCircle,
  user_joined: UserPlus
}

const activityIconColors = {
  project_created: 'text-blue-500 bg-blue-50',
  project_completed: 'text-green-500 bg-green-50',
  user_joined: 'text-orange-500 bg-orange-50'
}

export function UsersSidebar({
  quickFilters,
  recentActivity,
  activeFilter,
  onFilterClick
}: UsersSidebarProps) {
  return (
    <div className="hidden xl:block w-80 shrink-0">
      <div className="sticky top-24">
        <div className="bg-white/90 rounded-2xl border border-gray-200 p-6 space-y-6 shadow-sm">
          {/* Quick Filters Section */}
          <div className="space-y-3">
            <div className="flex items-center gap-2">
              <Filter className="h-4 w-4 text-gray-500" />
              <h3 className="text-xs font-semibold uppercase tracking-wider text-gray-500">
                Quick Filters
              </h3>
            </div>

            <div className="space-y-2">
              {quickFilters.map((filter) => {
                const isActive = activeFilter === filter.id
                const colors = colorClasses[filter.color]

                return (
                  <button
                    key={filter.id}
                    onClick={() => onFilterClick(filter.id)}
                    className={`
                      w-full flex items-center justify-between gap-3 px-4 py-3 rounded-xl
                      border-2 transition-all duration-200
                      ${isActive
                        ? `${colors.active} border-orange-500`
                        : `${colors.bg} border-transparent ${colors.text}`
                      }
                    `}
                  >
                    <div className="flex items-center gap-3">
                      <div className={`h-2 w-2 rounded-full ${colors.indicator}`} />
                      <span className="text-sm font-medium">{filter.label}</span>
                    </div>
                    <Badge
                      variant="secondary"
                      className={`
                        ${isActive ? colors.badgeActive : 'bg-white'}
                      `}
                    >
                      {filter.count}
                    </Badge>
                  </button>
                )
              })}
            </div>
          </div>

          {/* Divider */}
          <div className="border-t border-gray-200" />

          {/* Recent Activity Section */}
          <div className="space-y-3">
            <div className="flex items-center gap-2">
              <Activity className="h-4 w-4 text-gray-500" />
              <h3 className="text-xs font-semibold uppercase tracking-wider text-gray-500">
                Recent Activity
              </h3>
            </div>

            <div className="space-y-3 max-h-[400px] overflow-y-auto pr-2 custom-scrollbar">
              {recentActivity.slice(0, 8).map((activity) => {
                const Icon = activityIcons[activity.type]
                const iconColors = activityIconColors[activity.type]

                return (
                  <div
                    key={activity.id}
                    className="flex items-start gap-3 p-3 rounded-lg hover:bg-gray-50 transition-colors"
                  >
                    <div className="relative flex-shrink-0">
                      <Avatar className="h-8 w-8">
                        <AvatarImage src={activity.user_avatar} alt={activity.user_name} />
                        <AvatarFallback className="text-xs bg-gradient-to-br from-orange-400 to-orange-600 text-white">
                          {activity.user_name.split(' ').map(n => n[0]).join('').toUpperCase()}
                        </AvatarFallback>
                      </Avatar>
                      <div className={`absolute -bottom-1 -right-1 rounded-full p-0.5 ${iconColors}`}>
                        <Icon className="h-3 w-3" />
                      </div>
                    </div>

                    <div className="flex-1 min-w-0">
                      <p className="text-sm text-gray-900 line-clamp-2">
                        <span className="font-medium">{activity.user_name}</span>
                        {' '}
                        {activity.description}
                      </p>
                      <p className="text-xs text-gray-500 mt-1">
                        {formatDistanceToNow(new Date(activity.timestamp), { addSuffix: true })}
                      </p>
                    </div>
                  </div>
                )
              })}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
