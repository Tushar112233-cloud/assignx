/**
 * @fileoverview Supervisor Dashboard - Modern minimal design
 * Charcoal + Orange/Amber accent palette with illustrations
 * @module app/(dashboard)/dashboard/page
 */

"use client"

import { useMemo } from "react"
import { motion } from "framer-motion"
import { useProjectsByStatus, useSupervisorStats, useEarningsStats, claimProject } from "@/hooks"
import { useRouter } from "next/navigation"
import { toast } from "sonner"
import {
  FileText,
  Clock,
  CheckCircle,
  Wallet,
  Users,
  BookOpen,
  Zap,
  ArrowRight,
  TrendingUp,
  Calendar,
  ChevronRight,
} from "lucide-react"
import { useAuth } from "@/hooks"
import { cn } from "@/lib/utils"
import { Button } from "@/components/ui/button"
import Link from "next/link"
import { formatDistanceToNow } from "date-fns"

// Illustration Component - Modern Dashboard Illustration
function SupervisorIllustration() {
  return (
    <svg viewBox="0 0 400 300" fill="none" xmlns="http://www.w3.org/2000/svg" className="w-full h-full">
      {/* Background circles */}
      <circle cx="200" cy="150" r="140" fill="#FFF7ED" opacity="0.3" />
      <circle cx="200" cy="150" r="100" fill="#FFEDD5" opacity="0.4" />

      {/* Desk */}
      <rect x="80" y="210" width="240" height="10" rx="3" fill="#E5E7EB" />
      <rect x="95" y="220" width="10" height="55" rx="2" fill="#D1D5DB" />
      <rect x="295" y="220" width="10" height="55" rx="2" fill="#D1D5DB" />

      {/* Large Monitor - Modern flat design */}
      <rect x="120" y="110" width="160" height="100" rx="6" fill="#1C1C1C" />
      <rect x="127" y="117" width="146" height="80" rx="3" fill="#2D2D2D" />
      <rect x="190" y="205" width="20" height="12" fill="#374151" />
      <rect x="170" y="210" width="60" height="4" rx="2" fill="#6B7280" />

      {/* Screen content - Dashboard with orange accent */}
      <rect x="135" y="125" width="50" height="30" rx="2" fill="#F97316" opacity="0.2" />
      <rect x="190" y="125" width="50" height="30" rx="2" fill="#10B981" opacity="0.2" />
      <rect x="245" y="125" width="20" height="30" rx="2" fill="#3B82F6" opacity="0.2" />

      {/* Chart line */}
      <path d="M135 170 L155 160 L175 165 L195 150 L215 155 L235 145 L255 150"
            stroke="#F97316" strokeWidth="3" fill="none" strokeLinecap="round" strokeLinejoin="round" />
      <circle cx="155" cy="160" r="4" fill="#F97316" />
      <circle cx="195" cy="150" r="4" fill="#F97316" />
      <circle cx="235" cy="145" r="4" fill="#F97316" />

      {/* Person - Modern minimalist style */}
      {/* Head */}
      <circle cx="200" cy="60" r="22" fill="#FCD34D" />

      {/* Hair - Modern style */}
      <path d="M178 55 Q180 38 200 42 Q220 38 222 55 Q225 50 222 65 L178 65 Q175 50 178 55" fill="#1C1C1C" />

      {/* Face features */}
      <circle cx="193" cy="58" r="2" fill="#1C1C1C" />
      <circle cx="207" cy="58" r="2" fill="#1C1C1C" />
      <path d="M195 68 Q200 72 205 68" stroke="#1C1C1C" strokeWidth="2" fill="none" strokeLinecap="round" />

      {/* Glasses */}
      <rect x="188" y="56" width="10" height="8" rx="2" fill="none" stroke="#1C1C1C" strokeWidth="1.5" />
      <rect x="202" y="56" width="10" height="8" rx="2" fill="none" stroke="#1C1C1C" strokeWidth="1.5" />
      <line x1="198" y1="60" x2="202" y2="60" stroke="#1C1C1C" strokeWidth="1.5" />

      {/* Body - Orange shirt */}
      <path d="M178 82 L170 190 L185 190 L200 115 L215 190 L230 190 L222 82 Z" fill="#F97316" />

      {/* Arms */}
      <path d="M175 90 L140 130 L148 138 L178 105" fill="#FCD34D" />
      <path d="M225 90 L260 130 L252 138 L222 105" fill="#FCD34D" />

      {/* Laptop on desk */}
      <rect x="150" y="195" width="100" height="10" rx="2" fill="#374151" />
      <rect x="155" y="197" width="90" height="6" rx="1" fill="#4B5563" />

      {/* Laptop screen glow */}
      <rect x="160" y="175" width="80" height="18" rx="1" fill="#F97316" opacity="0.1" />

      {/* Coffee mug - Orange themed */}
      <ellipse cx="290" cy="195" rx="12" ry="4" fill="#EA580C" />
      <rect x="278" y="185" width="24" height="15" rx="2" fill="#F97316" />
      <path d="M302 190 Q312 192 302 198" stroke="#EA580C" strokeWidth="3" fill="none" />

      {/* Steam from coffee */}
      <path d="M285 178 Q287 172 285 168" stroke="#D1D5DB" strokeWidth="1.5" opacity="0.5" fill="none" strokeLinecap="round" />
      <path d="M295 178 Q297 172 295 168" stroke="#D1D5DB" strokeWidth="1.5" opacity="0.5" fill="none" strokeLinecap="round" />

      {/* Plant - Modern minimal */}
      <rect x="65" y="185" width="18" height="28" rx="2" fill="#E5E7EB" />
      <circle cx="74" cy="175" r="16" fill="#10B981" />
      <circle cx="62" cy="168" r="11" fill="#34D399" />
      <circle cx="85" cy="170" r="9" fill="#34D399" />

      {/* Floating UI elements */}
      <rect x="310" y="75" width="45" height="30" rx="4" fill="white" stroke="#F97316" strokeWidth="2" opacity="0.9" />
      <circle cx="322" cy="85" r="3" fill="#F97316" />
      <line x1="330" y1="83" x2="345" y2="83" stroke="#E5E7EB" strokeWidth="2" strokeLinecap="round" />
      <line x1="330" y1="88" x2="340" y2="88" stroke="#E5E7EB" strokeWidth="2" strokeLinecap="round" />

      {/* Notification badge */}
      <circle cx="352" cy="78" r="6" fill="#F97316" />
      <text x="352" y="81" fontSize="8" fill="white" textAnchor="middle" fontWeight="bold">3</text>

      {/* Decorative dots */}
      <circle cx="50" cy="95" r="5" fill="#FDBA74" opacity="0.6" />
      <circle cx="340" cy="240" r="7" fill="#FED7AA" opacity="0.5" />
      <circle cx="85" cy="130" r="4" fill="#FEF3C7" opacity="0.7" />
    </svg>
  )
}

// TODO: Replace static SVG with dynamic chart driven by real earnings/project data
function MiniChart() {
  return (
    <svg viewBox="0 0 200 80" className="w-full h-20">
      <defs>
        <linearGradient id="chartGradient" x1="0%" y1="0%" x2="0%" y2="100%">
          <stop offset="0%" stopColor="#F97316" stopOpacity="0.3" />
          <stop offset="100%" stopColor="#F97316" stopOpacity="0" />
        </linearGradient>
      </defs>
      {/* Grid lines */}
      <line x1="0" y1="20" x2="200" y2="20" stroke="#E5E7EB" strokeWidth="1" />
      <line x1="0" y1="40" x2="200" y2="40" stroke="#E5E7EB" strokeWidth="1" />
      <line x1="0" y1="60" x2="200" y2="60" stroke="#E5E7EB" strokeWidth="1" />

      {/* Area fill */}
      <path
        d="M0 60 L25 55 L50 45 L75 50 L100 35 L125 40 L150 25 L175 30 L200 20 L200 80 L0 80 Z"
        fill="url(#chartGradient)"
      />

      {/* Line */}
      <path
        d="M0 60 L25 55 L50 45 L75 50 L100 35 L125 40 L150 25 L175 30 L200 20"
        stroke="#F97316"
        strokeWidth="2.5"
        fill="none"
        strokeLinecap="round"
        strokeLinejoin="round"
      />

      {/* Dots */}
      <circle cx="100" cy="35" r="4" fill="#F97316" />
      <circle cx="150" cy="25" r="4" fill="#F97316" />
      <circle cx="200" cy="20" r="4" fill="#F97316" />
    </svg>
  )
}

export default function DashboardPage() {
  const router = useRouter()
  const { user } = useAuth()
  const firstName = user?.full_name?.split(" ")[0] || "Supervisor"

  const {
    needsQuote,
    readyToAssign: readyToAssignProjects,
    inProgress,
    needsQC,
    completed,
    refetch: refetchProjects,
  } = useProjectsByStatus()

  const { stats: supervisorStats } = useSupervisorStats()
  const { stats: earningsStats } = useEarningsStats()

  const stats = useMemo(() => ({
    activeProjects: supervisorStats?.activeProjects || inProgress.length,
    pendingReview: needsQC.length,
    completedThisMonth: supervisorStats?.completedProjects || completed.length,
    earningsThisMonth: earningsStats?.thisMonth || 0,
    newRequests: needsQuote.length,
    readyToAssign: readyToAssignProjects.length,
  }), [supervisorStats, earningsStats, inProgress.length, needsQC.length, completed.length, needsQuote.length, readyToAssignProjects.length])

  const handleAnalyzeRequest = async (projectId: string, projectNumber: string) => {
    try {
      await claimProject(projectId)
      toast.success(`Project ${projectNumber} claimed!`)
      await refetchProjects()
      router.push(`/projects/${projectId}`)
    } catch (error) {
      console.error("Failed to claim project:", error)
      toast.error("Failed to claim project")
      await refetchProjects()
    }
  }

  const statusItems = [
    { label: "New Requests", value: stats.newRequests, icon: FileText, href: "/projects?tab=requests", active: false },
    { label: "In Progress", value: stats.activeProjects, icon: Clock, href: "/projects?tab=ongoing", active: false },
    { label: "Pending QC", value: stats.pendingReview, icon: CheckCircle, href: "/projects?tab=review", active: false },
    { label: "Earnings", value: `₹${stats.earningsThisMonth.toLocaleString("en-IN")}`, icon: Wallet, href: "/earnings", active: false },
  ]

  const quickActions = [
    { label: "Ready to Assign", description: `${stats.readyToAssign} projects`, icon: Zap, href: "/projects?tab=ready", color: "bg-orange-50 text-[#F97316]" },
    { label: "Doers", description: "Manage experts", icon: Users, href: "/doers", color: "bg-emerald-50 text-emerald-600" },
    { label: "Resources", description: "Guides & tools", icon: BookOpen, href: "/resources", color: "bg-purple-50 text-purple-600" },
  ]

  return (
    <div className="min-h-screen bg-gray-50">
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.4 }}
        className="max-w-[1400px] mx-auto px-8 lg:px-10 pt-4 pb-8"
      >
        {/* Hero Section */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1, duration: 0.5 }}
          className="flex flex-col lg:flex-row items-center justify-between gap-6 mb-6"
        >
          {/* Left - Greeting */}
          <div className="flex-1 space-y-4">
            <div>
              <h1 className="text-4xl lg:text-5xl font-bold text-[#1C1C1C] tracking-tight">
                Hi {firstName},
              </h1>
              <p className="text-lg text-gray-500 mt-2">
                {stats.newRequests > 0
                  ? `You have ${stats.newRequests} new request${stats.newRequests > 1 ? 's' : ''} waiting for review`
                  : "All caught up! No new requests at the moment"}
              </p>
            </div>
            <Link href="/projects?tab=requests">
              <Button className="bg-[#F97316] hover:bg-[#EA580C] text-white rounded-full px-6 h-11 font-medium shadow-lg shadow-orange-500/20 hover:shadow-xl hover:shadow-orange-500/30 hover:-translate-y-0.5 active:translate-y-0 transition-all duration-200">
                View Requests
                <ArrowRight className="ml-2 h-4 w-4" />
              </Button>
            </Link>
          </div>

          {/* Right - Illustration */}
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.2, duration: 0.5 }}
            className="w-[280px] h-[210px] lg:w-[320px] lg:h-[240px]"
          >
            <SupervisorIllustration />
          </motion.div>
        </motion.div>

        {/* Status Pills Row */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2, duration: 0.5 }}
          className="grid grid-cols-2 lg:grid-cols-4 gap-3 mb-6"
        >
          {statusItems.map((item, index) => (
            <Link key={item.label} href={item.href}>
              <motion.div
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.1 * index, duration: 0.3 }}
                className={cn(
                  "group flex items-center gap-3 p-4 rounded-2xl border transition-all duration-300",
                  item.active
                    ? "bg-[#1C1C1C] border-[#1C1C1C] text-white"
                    : "bg-white border-gray-200 hover:border-gray-300 hover:shadow-md"
                )}
              >
                <div className={cn(
                  "w-10 h-10 rounded-xl flex items-center justify-center transition-colors",
                  item.active ? "bg-white/10" : "bg-orange-100"
                )}>
                  <item.icon className={cn(
                    "h-5 w-5",
                    item.active ? "text-white" : "text-orange-600"
                  )} />
                </div>
                <div className="flex-1 min-w-0">
                  <p className={cn(
                    "text-xs font-medium",
                    item.active ? "text-white/70" : "text-gray-500"
                  )}>
                    {item.label}
                  </p>
                  <p className={cn(
                    "text-lg font-bold truncate",
                    item.active ? "text-white" : "text-[#1C1C1C]"
                  )}>
                    {item.value}
                  </p>
                </div>
              </motion.div>
            </Link>
          ))}
        </motion.div>

        {/* Analytics + Quick Actions Row */}
        <div className="grid grid-cols-1 lg:grid-cols-[1fr_320px] gap-6 mb-6">
          {/* Analytics Card */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3, duration: 0.5 }}
            className="bg-white rounded-2xl border border-gray-200 p-6"
          >
            <div className="flex items-center justify-between mb-4">
              <div>
                <h3 className="text-lg font-semibold text-[#1C1C1C]">Analytics</h3>
                <p className="text-sm text-gray-500">Project completion trend</p>
              </div>
              <div className="flex items-center gap-2 text-sm">
                <span className="flex items-center gap-1 text-emerald-600 font-medium">
                  <TrendingUp className="h-4 w-4" />
                  {stats.completedThisMonth > 0 ? "Active" : "No data"}
                </span>
                <span className="text-gray-400">this month</span>
              </div>
            </div>
            <MiniChart />
            <div className="flex items-center justify-between mt-4 pt-4 border-t border-gray-100">
              <div className="flex items-center gap-6">
                <div>
                  <p className="text-2xl font-bold text-[#1C1C1C]">{stats.completedThisMonth}</p>
                  <p className="text-xs text-gray-500">Completed</p>
                </div>
                <div>
                  <p className="text-2xl font-bold text-[#1C1C1C]">{stats.activeProjects}</p>
                  <p className="text-xs text-gray-500">In Progress</p>
                </div>
              </div>
              <Link
                href="/projects"
                className="text-sm text-orange-600 hover:text-orange-700 font-medium flex items-center gap-1 transition-colors"
              >
                View all <ChevronRight className="h-4 w-4" />
              </Link>
            </div>
          </motion.div>

          {/* Quick Actions */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.35, duration: 0.5 }}
            className="space-y-3"
          >
            {quickActions.map((action, index) => (
              <Link key={action.label} href={action.href}>
                <motion.div
                  initial={{ opacity: 0, x: 20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 0.1 * index + 0.3, duration: 0.3 }}
                  className="group flex items-center gap-4 p-4 bg-white rounded-2xl border border-gray-200 hover:border-orange-200 hover:shadow-md hover:-translate-y-0.5 active:translate-y-0 transition-all duration-200"
                >
                  <div className={cn("w-12 h-12 rounded-xl flex items-center justify-center", action.color)}>
                    <action.icon className="h-6 w-6" />
                  </div>
                  <div className="flex-1">
                    <p className="font-semibold text-[#1C1C1C] group-hover:text-orange-600 transition-colors">
                      {action.label}
                    </p>
                    <p className="text-sm text-gray-500">{action.description}</p>
                  </div>
                  <ChevronRight className="h-5 w-5 text-gray-400 group-hover:text-orange-500 group-hover:translate-x-0.5 transition-all" />
                </motion.div>
              </Link>
            ))}
          </motion.div>
        </div>

        {/* Recent Requests Table */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4, duration: 0.5 }}
          className="bg-white rounded-2xl border border-gray-200 overflow-hidden"
        >
          <div className="flex items-center justify-between p-6 border-b border-gray-100">
            <div>
              <h3 className="text-lg font-semibold text-[#1C1C1C]">Recent Requests</h3>
              <p className="text-sm text-gray-500">Latest projects awaiting review</p>
            </div>
            <Link
              href="/projects?tab=requests"
              className="text-sm text-orange-600 hover:text-orange-700 font-medium flex items-center gap-1 transition-colors"
            >
              View all <ChevronRight className="h-4 w-4" />
            </Link>
          </div>

          {needsQuote.length === 0 ? (
            <div className="p-12 text-center">
              <div className="w-16 h-16 rounded-full bg-gray-100 flex items-center justify-center mx-auto mb-4">
                <CheckCircle className="h-8 w-8 text-gray-400" />
              </div>
              <p className="text-gray-600 font-medium">All caught up!</p>
              <p className="text-gray-400 text-sm mt-1">No new requests at the moment</p>
            </div>
          ) : (
            <div className="divide-y divide-gray-100">
              {needsQuote.slice(0, 5).map((project, index) => (
                <motion.div
                  key={project.id}
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  transition={{ delay: 0.05 * index }}
                  className="flex items-center justify-between p-4 hover:bg-gray-50 transition-colors"
                >
                  <div className="flex items-center gap-4 flex-1 min-w-0">
                    <div className="w-10 h-10 rounded-xl bg-orange-100 flex items-center justify-center shrink-0">
                      <FileText className="h-5 w-5 text-orange-600" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-0.5">
                        <span className="text-xs font-mono text-gray-400">#{project.project_number}</span>
                        <span className="text-xs px-2 py-0.5 rounded-full bg-gray-100 text-gray-600">
                          {project.service_type.replace(/_/g, ' ')}
                        </span>
                      </div>
                      <p className="font-medium text-[#1C1C1C] truncate">{project.title}</p>
                      <div className="flex items-center gap-3 mt-1 text-xs text-gray-500">
                        <span>{project.user?.full_name || "User"}</span>
                        <span className="flex items-center gap-1">
                          <Calendar className="h-3 w-3" />
                          {project.deadline
                            ? formatDistanceToNow(new Date(project.deadline), { addSuffix: true })
                            : "No deadline"}
                        </span>
                      </div>
                    </div>
                  </div>
                  <Button
                    size="sm"
                    onClick={() => handleAnalyzeRequest(project.id, project.project_number)}
                    className="bg-[#1C1C1C] hover:bg-[#2D2D2D] text-white rounded-xl px-4 h-9 font-medium hover:shadow-lg active:scale-95 transition-all duration-200"
                  >
                    Analyze
                  </Button>
                </motion.div>
              ))}
            </div>
          )}
        </motion.div>
      </motion.div>
    </div>
  )
}
