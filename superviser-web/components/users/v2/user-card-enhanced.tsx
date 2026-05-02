"use client"

import { motion } from "framer-motion"
import {
  MoreHorizontal,
  FolderKanban,
  IndianRupee,
  Calendar,
  User as UserIcon,
  Mail,
  MessageSquare
} from "lucide-react"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { formatDistanceToNow } from "date-fns"

interface User {
  id: string
  full_name: string
  email: string
  avatar_url?: string
  total_projects: number
  active_projects: number
  total_spent: number
  last_active_at?: string
  tags?: string[]
}

interface UserCardEnhancedProps {
  user: User
  onClick?: (user: User) => void
  onMenuAction?: (action: string, user: User) => void
}

const TAG_COLORS = [
  "bg-orange-100 text-orange-700",
  "bg-amber-100 text-amber-700",
  "bg-emerald-100 text-emerald-700",
  "bg-slate-100 text-slate-700",
  "bg-gray-100 text-gray-700",
]

export function UserCardEnhanced({ user, onClick, onMenuAction }: UserCardEnhancedProps) {
  // Check if user was active in the last 5 minutes
  const isOnline = user.last_active_at
    ? new Date().getTime() - new Date(user.last_active_at).getTime() < 5 * 60 * 1000
    : false

  const isActive = user.active_projects > 0

  const visibleTags = user.tags?.slice(0, 3) || []
  const remainingTags = (user.tags?.length || 0) - visibleTags.length

  const handleMenuAction = (e: React.MouseEvent, action: string) => {
    e.preventDefault()
    e.stopPropagation()
    onMenuAction?.(action, user)
  }

  const handleCardClick = () => {
    onClick?.(user)
  }

  const getInitials = (name: string) => {
    return name
      .split(' ')
      .map(word => word[0])
      .join('')
      .toUpperCase()
      .slice(0, 2)
  }

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-IN', {
      style: 'currency',
      currency: 'INR',
      maximumFractionDigits: 0,
    }).format(amount)
  }

  const getRelativeTime = (date: string) => {
    try {
      return formatDistanceToNow(new Date(date), { addSuffix: true })
    } catch {
      return 'Never'
    }
  }

  return (
    <motion.div
      whileHover={{
        y: -2,
        boxShadow: "0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1)",
      }}
      transition={{ duration: 0.2 }}
      className="group relative bg-white border border-gray-200 rounded-2xl p-6 cursor-pointer hover:border-orange-200 transition-all"
      onClick={handleCardClick}
    >
      {/* Header Section */}
      <div className="flex items-start justify-between mb-5 gap-2">
        <div className="flex items-start gap-3 flex-1 min-w-0">
          {/* Avatar with Online Indicator */}
          <div className="relative flex-shrink-0">
            <Avatar className="h-14 w-14 border-2 border-gray-100">
              <AvatarImage src={user.avatar_url} alt={user.full_name} />
              <AvatarFallback className="bg-gradient-to-br from-orange-400 to-orange-600 text-white font-semibold text-lg">
                {getInitials(user.full_name)}
              </AvatarFallback>
            </Avatar>
            {isOnline && (
              <div className="absolute -bottom-0.5 -right-0.5">
                <div className="bg-white rounded-full p-0.5">
                  <div className="h-3 w-3 bg-green-500 rounded-full border-2 border-white animate-pulse" />
                </div>
              </div>
            )}
          </div>

          {/* Name and Email */}
          <div className="flex-1 min-w-0">
            <h3 className="font-semibold text-gray-900 line-clamp-1 text-base leading-snug">
              {user.full_name}
            </h3>
            <p className="text-sm text-gray-500 line-clamp-1 mt-0.5">
              {user.email}
            </p>
          </div>
        </div>

        {/* Three-dot Menu */}
        <DropdownMenu>
          <DropdownMenuTrigger
            onClick={(e) => e.stopPropagation()}
            className="flex-shrink-0 h-8 w-8 flex items-center justify-center rounded-lg hover:bg-gray-100 text-gray-400 hover:text-gray-600 transition-colors"
          >
            <MoreHorizontal className="h-4 w-4" />
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="w-48">
            <DropdownMenuItem
              onClick={(e) => handleMenuAction(e, 'view-profile')}
              className="cursor-pointer"
            >
              <UserIcon className="h-4 w-4 mr-2" />
              View Profile
            </DropdownMenuItem>
            <DropdownMenuItem
              onClick={(e) => handleMenuAction(e, 'view-projects')}
              className="cursor-pointer"
            >
              <FolderKanban className="h-4 w-4 mr-2" />
              View Projects
            </DropdownMenuItem>
            <DropdownMenuItem
              onClick={(e) => handleMenuAction(e, 'send-message')}
              className="cursor-pointer"
            >
              <MessageSquare className="h-4 w-4 mr-2" />
              Send Message
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-2 gap-3 mb-5">
        {/* Projects Stat */}
        <div className="bg-gray-50 rounded-xl p-3.5">
          <div className="flex flex-col gap-1.5">
            <div className="flex items-center gap-1.5">
              <div className="h-7 w-7 rounded-lg bg-orange-100 flex items-center justify-center flex-shrink-0">
                <FolderKanban className="h-3.5 w-3.5 text-orange-600" />
              </div>
              <p className="text-[11px] text-gray-500 font-medium uppercase tracking-wide">Projects</p>
            </div>
            <p className="text-xl font-bold text-gray-900 ml-0.5">
              {user.total_projects}
            </p>
          </div>
        </div>

        {/* Revenue Stat */}
        <div className="bg-gray-50 rounded-xl p-3.5">
          <div className="flex flex-col gap-1.5">
            <div className="flex items-center gap-1.5">
              <div className="h-7 w-7 rounded-lg bg-green-100 flex items-center justify-center flex-shrink-0">
                <IndianRupee className="h-3.5 w-3.5 text-green-600" />
              </div>
              <p className="text-[11px] text-gray-500 font-medium uppercase tracking-wide">Revenue</p>
            </div>
            <p className="text-base font-bold text-gray-900 line-clamp-1 ml-0.5">
              {formatCurrency(user.total_spent)}
            </p>
          </div>
        </div>
      </div>

      {/* Tags Section */}
      {user.tags && user.tags.length > 0 && (
        <div className="flex flex-wrap gap-1.5 mb-4">
          {visibleTags.map((tag, index) => (
            <Badge
              key={index}
              variant="secondary"
              className={`text-xs px-2 py-0.5 font-medium ${TAG_COLORS[index % TAG_COLORS.length]}`}
            >
              {tag}
            </Badge>
          ))}
          {remainingTags > 0 && (
            <Badge
              variant="secondary"
              className="text-xs px-2 py-0.5 font-medium bg-gray-100 text-gray-600"
            >
              +{remainingTags} more
            </Badge>
          )}
        </div>
      )}

      {/* Footer */}
      <div className="flex items-center justify-between pt-4 border-t border-gray-100 gap-3">
        {/* Last Active */}
        <div className="flex items-center gap-1.5 text-xs text-gray-500 min-w-0 flex-1">
          <Calendar className="h-3.5 w-3.5 flex-shrink-0" />
          <span className="truncate">
            {user.last_active_at ? getRelativeTime(user.last_active_at) : 'Never active'}
          </span>
        </div>

        {/* Status Badge */}
        <Badge
          variant={isActive ? "default" : "secondary"}
          className={`text-xs flex-shrink-0 whitespace-nowrap ${
            isActive
              ? "bg-green-100 text-green-700 hover:bg-green-100"
              : "bg-gray-100 text-gray-600 hover:bg-gray-100"
          }`}
        >
          {isActive ? "Active" : "Inactive"}
        </Badge>
      </div>

      {/* Hover Effect Gradient */}
      <div className="absolute inset-0 rounded-2xl bg-gradient-to-br from-orange-500/0 to-orange-500/0 group-hover:from-orange-500/5 group-hover:to-orange-500/0 transition-all pointer-events-none" />
    </motion.div>
  )
}
