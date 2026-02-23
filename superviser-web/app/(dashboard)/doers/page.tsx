/**
 * @fileoverview Expert Doers Management Page - Studio layout redesign
 * Charcoal + Orange palette with distinct layout from dashboard
 * @module app/(dashboard)/doers/page
 */

"use client"

import { useState, useMemo } from "react"
import { useRouter } from "next/navigation"
import { motion } from "framer-motion"
import {
  Users,
  Search,
  Star,
  CheckCircle,
  MessageSquare,
  Eye,
  Briefcase,
  Ban,
  ArrowRight,
  AlertTriangle,
  Sparkles,
} from "lucide-react"

import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Skeleton } from "@/components/ui/skeleton"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { useDoers, useBlacklistedDoers } from "@/hooks"
import type { DoerWithProfile } from "@/types/database"
import { DoerDetails } from "@/components/doers/doer-details"
import { cn } from "@/lib/utils"
import DoerIllustration from "@/components/doers/doer-illustration"
import type { Doer, DoerFilterStatus, RatingFilter } from "@/components/doers/types"

type DoerSortOption = "rating_high" | "rating_low" | "projects_high" | "earnings_high" | "recent"

function DoerCard({
  doer,
  onViewProfile,
  onAssignProject,
  onMessage,
  index,
}: {
  doer: Doer
  onViewProfile: () => void
  onAssignProject: () => void
  onMessage: () => void
  index: number
}) {
  const initials = doer.full_name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .slice(0, 2)
    .toUpperCase()

  const statusLabel = doer.is_blacklisted
    ? "Blacklisted"
    : doer.is_available
      ? "Available"
      : "Busy"

  const statusClass = doer.is_blacklisted
    ? "bg-red-50 text-red-700 border-red-200"
    : doer.is_available
      ? "bg-emerald-50 text-emerald-700 border-emerald-200"
      : "bg-gray-100 text-gray-600 border-gray-200"

  return (
    <motion.div
      initial={{ opacity: 0, y: 16 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.4, delay: index * 0.04 }}
      whileHover={{ y: -2 }}
      className="bg-white rounded-2xl border border-gray-200 p-4 hover:border-orange-200 hover:shadow-md transition-all"
    >
      {/* Header: Avatar + Name + Status */}
      <div className="flex items-start justify-between gap-3 mb-3">
        <div className="flex items-start gap-3 min-w-0 flex-1">
          <div className="relative shrink-0">
            <Avatar className="h-12 w-12 ring-2 ring-white shadow-sm">
              <AvatarImage src={doer.avatar_url} alt={doer.full_name} />
              <AvatarFallback className="bg-[#1C1C1C] text-white font-semibold">
                {initials}
              </AvatarFallback>
            </Avatar>
            <span
              className={cn(
                "absolute -bottom-0.5 -right-0.5 h-3 w-3 rounded-full border-2 border-white",
                doer.is_blacklisted ? "bg-red-500" : doer.is_available ? "bg-emerald-500" : "bg-gray-400"
              )}
            />
          </div>

          <div className="min-w-0 flex-1">
            <div className="flex items-center gap-1.5">
              <h3 className="text-sm font-semibold text-[#1C1C1C] truncate">
                {doer.full_name}
              </h3>
              {doer.is_verified && <CheckCircle className="h-3.5 w-3.5 text-[#F97316] shrink-0" />}
              {doer.is_blacklisted && <Ban className="h-3.5 w-3.5 text-red-500 shrink-0" />}
            </div>
            <p className="text-xs text-gray-500 mt-0.5 truncate">
              {doer.qualification} · {doer.years_of_experience}y exp
            </p>
            <div className="flex items-center gap-1 mt-1.5">
              <div className="flex">
                {[1, 2, 3, 4, 5].map((star) => (
                  <Star
                    key={star}
                    className={cn(
                      "h-3 w-3",
                      star <= Math.round(doer.rating)
                        ? "fill-amber-400 text-amber-400"
                        : "fill-gray-200 text-gray-200"
                    )}
                  />
                ))}
              </div>
              <span className="text-xs font-semibold text-[#1C1C1C]">{doer.rating.toFixed(1)}</span>
              <span className="text-[10px] text-gray-400">({doer.total_reviews})</span>
            </div>
          </div>
        </div>

        <Badge className={cn("rounded-full border px-2.5 py-0.5 text-[10px] whitespace-nowrap shrink-0", statusClass)}>
          {statusLabel}
        </Badge>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-3 gap-2 mb-3">
        <div className="text-center p-2 bg-gray-50 rounded-lg">
          <p className="text-sm font-semibold text-[#1C1C1C]">{doer.completed_projects}</p>
          <p className="text-[9px] uppercase tracking-wide text-gray-400 mt-0.5">Projects</p>
        </div>
        <div className="text-center p-2 bg-gray-50 rounded-lg">
          <p className="text-sm font-semibold text-[#1C1C1C]">
            {doer.total_earnings ? `₹${(doer.total_earnings / 1000).toFixed(1)}k` : "₹0"}
          </p>
          <p className="text-[9px] uppercase tracking-wide text-gray-400 mt-0.5">Earnings</p>
        </div>
        <div className="text-center p-2 bg-gray-50 rounded-lg">
          <p className="text-sm font-semibold text-[#1C1C1C]">{doer.success_rate}%</p>
          <p className="text-[9px] uppercase tracking-wide text-gray-400 mt-0.5">Success</p>
        </div>
      </div>

      {/* Skills */}
      <div className="flex flex-wrap gap-1.5 mb-3">
        {doer.skills.slice(0, 3).map((skill) => (
          <Badge
            key={skill}
            variant="secondary"
            className="text-[10px] font-normal px-2 py-0.5 bg-gray-100 text-gray-600 border-0"
          >
            {skill}
          </Badge>
        ))}
        {doer.skills.length > 3 && (
          <Badge variant="outline" className="text-[10px] font-normal px-2 py-0.5 border-gray-200">
            +{doer.skills.length - 3}
          </Badge>
        )}
      </div>

      {/* Action Buttons */}
      <div className="flex gap-2">
        <Button
          variant="outline"
          size="sm"
          className="flex-1 rounded-lg text-xs h-8 border-gray-200 hover:border-orange-200 hover:bg-orange-50"
          onClick={onViewProfile}
        >
          <Eye className="h-3.5 w-3.5 mr-1.5" />
          View
        </Button>
        <Button
          size="sm"
          className="flex-1 rounded-lg text-xs h-8 bg-[#F97316] hover:bg-[#EA580C] text-white"
          onClick={onAssignProject}
          disabled={!doer.is_available || doer.is_blacklisted}
        >
          <Briefcase className="h-3.5 w-3.5 mr-1.5" />
          Assign
        </Button>
        <Button
          variant="ghost"
          size="sm"
          className="flex-1 rounded-lg text-xs h-8 hover:bg-gray-100"
          onClick={onMessage}
        >
          <MessageSquare className="h-3.5 w-3.5 mr-1.5" />
          Chat
        </Button>
      </div>
    </motion.div>
  )
}

function LoadingCard() {
  return (
    <div className="bg-white rounded-2xl border border-gray-200 p-4">
      {/* Header: Avatar + Name + Status badge */}
      <div className="flex items-start justify-between gap-3 mb-3">
        <div className="flex items-start gap-3 min-w-0 flex-1">
          <Skeleton className="h-12 w-12 rounded-full shrink-0" />
          <div className="min-w-0 flex-1 space-y-2">
            <Skeleton className="h-4 w-32" />
            <Skeleton className="h-3 w-24" />
            <Skeleton className="h-3 w-28" />
          </div>
        </div>
        <Skeleton className="h-5 w-16 rounded-full shrink-0" />
      </div>

      {/* Stats Grid: 3 columns */}
      <div className="grid grid-cols-3 gap-2 mb-3">
        {[1, 2, 3].map((i) => (
          <div key={i} className="p-2 bg-gray-50 rounded-lg space-y-1.5">
            <Skeleton className="h-4 w-10 mx-auto" />
            <Skeleton className="h-3 w-14 mx-auto" />
          </div>
        ))}
      </div>

      {/* Skills */}
      <div className="flex flex-wrap gap-1.5 mb-3">
        <Skeleton className="h-5 w-16 rounded-full" />
        <Skeleton className="h-5 w-20 rounded-full" />
        <Skeleton className="h-5 w-14 rounded-full" />
      </div>

      {/* Action Buttons */}
      <div className="flex gap-2">
        <Skeleton className="h-8 flex-1 rounded-lg" />
        <Skeleton className="h-8 flex-1 rounded-lg" />
        <Skeleton className="h-8 flex-1 rounded-lg" />
      </div>
    </div>
  )
}

function EmptyState({ hasFilters, onClearFilters }: { hasFilters: boolean; onClearFilters: () => void }) {
  return (
    <div className="bg-white rounded-2xl border border-gray-200 p-12 text-center">
      <div className="w-16 h-16 rounded-2xl bg-orange-50 flex items-center justify-center mx-auto mb-4">
        <Users className="h-7 w-7 text-orange-500" />
      </div>
      <h3 className="text-lg font-semibold text-[#1C1C1C]">No experts found</h3>
      <p className="text-sm text-gray-500 mt-1">
        {hasFilters
          ? "Try adjusting your filters to explore more experts."
          : "Experts will appear here once they join your network."}
      </p>
      {hasFilters && (
        <Button
          variant="outline"
          className="mt-5 rounded-full border-gray-200"
          onClick={onClearFilters}
        >
          Clear all filters
        </Button>
      )}
    </div>
  )
}

export default function DoersPage() {
  const router = useRouter()
  const [searchQuery, setSearchQuery] = useState("")
  const [statusFilter, setStatusFilter] = useState<DoerFilterStatus>("all")
  const [ratingFilter, setRatingFilter] = useState<RatingFilter>("all")
  const [sortOption, setSortOption] = useState<DoerSortOption>("rating_high")
  const [selectedDoer, setSelectedDoer] = useState<Doer | null>(null)
  const [detailsOpen, setDetailsOpen] = useState(false)

  const { doers: allDoers, isLoading: allLoading, error: doersError } = useDoers()
  const { doers: blacklistedDoers, isLoading: blacklistLoading, error: blacklistError } = useBlacklistedDoers()

  const isLoading = allLoading || blacklistLoading
  const error = doersError || blacklistError

  const transformDoer = (doer: DoerWithProfile): Doer => ({
    id: doer.id,
    full_name: doer.profiles?.full_name || "Unknown",
    email: doer.profiles?.email || "",
    phone: doer.profiles?.phone ?? undefined,
    avatar_url: doer.profiles?.avatar_url ?? undefined,
    qualification: doer.qualification || "Graduate",
    years_of_experience: doer.years_of_experience || 0,
    skills: doer.skills || [],
    subjects: doer.subjects || [],
    bio: doer.bio ?? undefined,
    rating: doer.average_rating || 0,
    total_reviews: doer.total_reviews || 0,
    total_projects: doer.total_projects_completed || 0,
    completed_projects: doer.total_projects_completed || 0,
    active_projects: doer.active_projects_count || 0,
    success_rate: doer.success_rate || 95,
    total_earnings: doer.total_earnings || 0,
    joined_at: doer.created_at || new Date().toISOString(),
    is_available: doer.is_available ?? false,
    is_verified: doer.is_activated ?? false,
    is_blacklisted: false,
    last_active_at: doer.updated_at ?? undefined,
  })

  const doers = useMemo(() => {
    const transformed = allDoers.map(transformDoer)
    const blacklistedMap = new Map(blacklistedDoers.map((d) => [d.id, d.blacklistReason]))

    return transformed.map((d) => ({
      ...d,
      is_blacklisted: blacklistedMap.has(d.id),
      blacklist_reason: blacklistedMap.get(d.id),
    }))
  }, [allDoers, blacklistedDoers])

  const stats = useMemo(() => {
    const available = doers.filter((d) => d.is_available && !d.is_blacklisted).length
    const ratings = doers.filter((d) => !d.is_blacklisted).map((d) => d.rating)
    const averageRating = ratings.length > 0 ? ratings.reduce((a, b) => a + b, 0) / ratings.length : 0
    const topPerformers = doers.filter((d) => d.rating >= 4.5 && !d.is_blacklisted).length

    return {
      total: doers.length,
      available,
      averageRating: Math.round(averageRating * 10) / 10,
      topPerformers,
    }
  }, [doers])

  const availabilityStats = useMemo(() => {
    const available = doers.filter((d) => d.is_available && !d.is_blacklisted).length
    const busy = doers.filter((d) => !d.is_available && !d.is_blacklisted).length
    const blacklisted = doers.filter((d) => d.is_blacklisted).length
    const total = doers.length || 1

    return {
      total,
      available,
      busy,
      blacklisted,
      availablePct: Math.round((available / total) * 100),
      busyPct: Math.round((busy / total) * 100),
      blacklistedPct: Math.round((blacklisted / total) * 100),
    }
  }, [doers])

  const topPerformers = useMemo(
    () =>
      [...doers]
        .filter((d) => !d.is_blacklisted)
        .sort((a, b) => b.rating - a.rating)
        .slice(0, 3),
    [doers]
  )

  const filteredDoers = useMemo(() => {
    let result = [...doers]

    if (statusFilter === "available") result = result.filter((d) => d.is_available && !d.is_blacklisted)
    else if (statusFilter === "busy") result = result.filter((d) => !d.is_available && !d.is_blacklisted)
    else if (statusFilter === "blacklisted") result = result.filter((d) => d.is_blacklisted)

    if (ratingFilter === "4plus") result = result.filter((d) => d.rating >= 4)
    else if (ratingFilter === "4_5plus") result = result.filter((d) => d.rating >= 4.5)
    else if (ratingFilter === "5") result = result.filter((d) => d.rating === 5)

    if (searchQuery) {
      const query = searchQuery.toLowerCase()
      result = result.filter(
        (d) =>
          d.full_name.toLowerCase().includes(query) ||
          d.email.toLowerCase().includes(query) ||
          d.skills.some((s) => s.toLowerCase().includes(query)) ||
          d.subjects.some((s) => s.toLowerCase().includes(query))
      )
    }

    const sortFns: Record<DoerSortOption, (a: Doer, b: Doer) => number> = {
      rating_high: (a, b) => b.rating - a.rating,
      rating_low: (a, b) => a.rating - b.rating,
      projects_high: (a, b) => b.completed_projects - a.completed_projects,
      earnings_high: (a, b) => (b.total_earnings || 0) - (a.total_earnings || 0),
      recent: (a, b) => new Date(b.joined_at).getTime() - new Date(a.joined_at).getTime(),
    }
    return result.sort(sortFns[sortOption])
  }, [doers, searchQuery, statusFilter, ratingFilter, sortOption])

  const hasActiveFilters = Boolean(searchQuery) || statusFilter !== "all" || ratingFilter !== "all"

  const handleDoerSelect = (doer: Doer) => {
    setSelectedDoer(doer)
    setDetailsOpen(true)
  }

  const clearFilters = () => {
    setSearchQuery("")
    setStatusFilter("all")
    setRatingFilter("all")
  }

  const heroChips = [
    {
      label: "Total",
      value: stats.total,
      tone: "bg-gray-100 text-gray-700",
      onClick: () => setStatusFilter("all"),
    },
    {
      label: "Available",
      value: stats.available,
      tone: "bg-emerald-50 text-emerald-700",
      onClick: () => setStatusFilter("available"),
    },
    {
      label: "Avg Rating",
      value: stats.averageRating.toFixed(1),
      tone: "bg-amber-50 text-amber-700",
      onClick: () => setRatingFilter("4plus"),
    },
    {
      label: "Top 4.5+",
      value: stats.topPerformers,
      tone: "bg-purple-50 text-purple-700",
      onClick: () => setRatingFilter("4_5plus"),
    },
  ]

  const statusChips: Array<{ value: DoerFilterStatus; label: string }> = [
    { value: "all", label: "All" },
    { value: "available", label: "Available" },
    { value: "busy", label: "Busy" },
    { value: "blacklisted", label: "Blacklisted" },
  ]

  const ratingChips: Array<{ value: RatingFilter; label: string }> = [
    { value: "all", label: "All" },
    { value: "4plus", label: "4+" },
    { value: "4_5plus", label: "4.5+" },
    { value: "5", label: "5" },
  ]

  const activeFilters = [
    searchQuery ? `Search: "${searchQuery}"` : null,
    statusFilter !== "all" ? `Status: ${statusFilter}` : null,
    ratingFilter !== "all"
      ? `Rating: ${ratingFilter === "4plus" ? "4+" : ratingFilter === "4_5plus" ? "4.5+" : "5"}`
      : null,
  ].filter(Boolean) as string[]

  return (
    <div className="min-h-screen bg-gray-50 overflow-x-hidden">
      <div className="relative overflow-x-hidden">
        <div className="pointer-events-none absolute inset-0">
          <div className="absolute -top-24 right-0 h-64 w-64 rounded-full bg-orange-100/60 blur-3xl" />
          <div className="absolute top-40 left-10 h-56 w-56 rounded-full bg-amber-100/50 blur-3xl" />
        </div>

        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.4 }}
          className="relative max-w-[1400px] mx-auto px-6 lg:px-10 py-8 lg:py-10 space-y-10"
        >
          <motion.section
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1, duration: 0.5 }}
            className="relative overflow-hidden rounded-3xl border border-gray-200 bg-white p-6 lg:p-8"
          >
            <div className="absolute -top-16 left-1/3 h-44 w-44 rounded-full bg-orange-100/50 blur-3xl" />
            <div className="absolute -bottom-16 right-10 h-44 w-44 rounded-full bg-amber-100/50 blur-3xl" />

            <div className="relative grid lg:grid-cols-[1.2fr_0.8fr] gap-8 items-center">
              <div className="space-y-6">
                <div>
                  <p className="text-xs uppercase tracking-[0.2em] text-gray-400">Expert Studio</p>
                  <h1 className="text-4xl lg:text-5xl font-bold text-[#1C1C1C] tracking-tight mt-2">
                    Expert Network
                  </h1>
                  <p className="text-lg text-gray-500 mt-3">
                    {stats.total > 0
                      ? `Manage ${stats.total} experts with verified skills, availability, and live performance.`
                      : "Build your network of skilled experts to handle projects."}
                  </p>
                </div>

                <div className="flex flex-wrap items-center gap-3">
                  <Button
                    className="bg-[#F97316] hover:bg-[#EA580C] text-white rounded-full px-6 h-11 font-medium shadow-lg shadow-orange-500/20 hover:shadow-xl hover:shadow-orange-500/30 hover:-translate-y-0.5 active:translate-y-0 transition-all duration-200"
                    onClick={() => setStatusFilter("available")}
                  >
                    View Available
                    <ArrowRight className="ml-2 h-4 w-4" />
                  </Button>
                  <Button
                    variant="outline"
                    onClick={() => setRatingFilter("4_5plus")}
                    className="rounded-full h-11 px-5 border-gray-200 text-gray-700"
                  >
                    Top Rated
                  </Button>
                </div>

                <div className="flex flex-wrap gap-2">
                  {heroChips.map((chip, index) => (
                    <motion.button
                      key={chip.label}
                      initial={{ opacity: 0, y: 6 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: 0.08 * index, duration: 0.25 }}
                      onClick={chip.onClick}
                      className={cn(
                        "px-3 py-1.5 rounded-full text-xs font-medium border border-transparent hover:border-orange-200 transition-all",
                        chip.tone
                      )}
                    >
                      {chip.label}:{" "}
                      {isLoading ? "..." : <span className="font-semibold">{chip.value}</span>}
                    </motion.button>
                  ))}
                </div>
              </div>

              <div className="space-y-4">
                <div className="w-full h-[220px]">
                  <DoerIllustration />
                </div>
                <div className="rounded-2xl border border-gray-200 bg-gray-50/80 p-4">
                  <div className="flex items-center justify-between">
                    <h3 className="text-sm font-semibold text-[#1C1C1C]">Availability Snapshot</h3>
                    <span className="text-xs text-gray-400">{availabilityStats.total} total</span>
                  </div>
                  <div className="mt-4 space-y-3">
                    {[
                      {
                        label: "Available",
                        count: availabilityStats.available,
                        percent: availabilityStats.availablePct,
                        color: "bg-emerald-500",
                      },
                      {
                        label: "Busy",
                        count: availabilityStats.busy,
                        percent: availabilityStats.busyPct,
                        color: "bg-gray-400",
                      },
                      {
                        label: "Blacklisted",
                        count: availabilityStats.blacklisted,
                        percent: availabilityStats.blacklistedPct,
                        color: "bg-red-500",
                      },
                    ].map((item) => (
                      <div key={item.label} className="space-y-1">
                        <div className="flex items-center justify-between text-xs text-gray-500">
                          <span>{item.label}</span>
                          <span>{item.count}</span>
                        </div>
                        <div className="h-2 rounded-full bg-white border border-gray-200 overflow-hidden">
                          <div className={item.color} style={{ width: `${item.percent}%`, height: "100%" }} />
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </div>
          </motion.section>

          <div className="grid lg:grid-cols-[320px_1fr] gap-8">
            <aside className="space-y-6">
              <div className="rounded-2xl border border-gray-200 bg-white p-5 space-y-4">
                <div className="flex items-center justify-between">
                  <div>
                    <h3 className="text-sm font-semibold text-[#1C1C1C]">Filters</h3>
                    <p className="text-xs text-gray-500">Refine your expert network</p>
                  </div>
                  {hasActiveFilters && (
                    <Button
                      variant="ghost"
                      size="sm"
                      className="text-orange-600 hover:text-orange-700"
                      onClick={clearFilters}
                    >
                      Clear
                    </Button>
                  )}
                </div>

                <div className="relative">
                  <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                  <Input
                    placeholder="Search experts..."
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    className="pl-10 h-11 rounded-xl border-gray-200 bg-gray-50 focus:bg-white transition-colors"
                  />
                </div>

                {activeFilters.length > 0 && (
                  <div className="flex flex-wrap gap-2">
                    {activeFilters.map((filter) => (
                      <Badge key={filter} variant="secondary" className="text-xs bg-gray-100 text-gray-600">
                        {filter}
                      </Badge>
                    ))}
                  </div>
                )}

                <div className="space-y-3">
                  <div>
                    <p className="text-xs font-medium text-gray-500 mb-2">Status</p>
                    <div className="flex flex-wrap gap-2">
                      {statusChips.map((chip) => (
                        <button
                          key={chip.value}
                          onClick={() => setStatusFilter(chip.value)}
                          className={cn(
                            "px-3 py-1.5 rounded-full text-xs font-medium border transition-all",
                            statusFilter === chip.value
                              ? "bg-orange-500 text-white border-orange-500"
                              : "bg-white text-gray-600 border-gray-200 hover:border-orange-300"
                          )}
                        >
                          {chip.label}
                        </button>
                      ))}
                    </div>
                  </div>

                  <div>
                    <p className="text-xs font-medium text-gray-500 mb-2">Rating</p>
                    <div className="flex flex-wrap gap-2">
                      {ratingChips.map((chip) => (
                        <button
                          key={chip.value}
                          onClick={() => setRatingFilter(chip.value)}
                          className={cn(
                            "px-3 py-1.5 rounded-full text-xs font-medium border transition-all",
                            ratingFilter === chip.value
                              ? "bg-orange-500 text-white border-orange-500"
                              : "bg-white text-gray-600 border-gray-200 hover:border-orange-300"
                          )}
                        >
                          {chip.label}
                        </button>
                      ))}
                    </div>
                  </div>

                  <div>
                    <p className="text-xs font-medium text-gray-500 mb-2">Sort by</p>
                    <Select value={sortOption} onValueChange={(v) => setSortOption(v as DoerSortOption)}>
                      <SelectTrigger className="w-full h-11 rounded-xl border-gray-200">
                        <SelectValue placeholder="Sort by" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="rating_high">Highest Rating</SelectItem>
                        <SelectItem value="rating_low">Lowest Rating</SelectItem>
                        <SelectItem value="projects_high">Most Projects</SelectItem>
                        <SelectItem value="earnings_high">Highest Earnings</SelectItem>
                        <SelectItem value="recent">Recently Joined</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div className="flex items-center justify-between text-xs text-gray-500">
                  <span>
                    Showing <span className="font-semibold text-[#1C1C1C]">{filteredDoers.length}</span> of{" "}
                    <span className="font-semibold text-[#1C1C1C]">{doers.length}</span>
                  </span>
                </div>
              </div>

              <div className="rounded-2xl border border-gray-200 bg-white p-5">
                <div className="flex items-center justify-between">
                  <h3 className="text-sm font-semibold text-[#1C1C1C]">Availability Board</h3>
                  <span className="text-xs text-gray-400">Live status</span>
                </div>
                <div className="mt-4 space-y-3">
                  {[
                    {
                      label: "Available",
                      count: availabilityStats.available,
                      percent: availabilityStats.availablePct,
                      color: "bg-emerald-500",
                    },
                    {
                      label: "Busy",
                      count: availabilityStats.busy,
                      percent: availabilityStats.busyPct,
                      color: "bg-gray-400",
                    },
                    {
                      label: "Blacklisted",
                      count: availabilityStats.blacklisted,
                      percent: availabilityStats.blacklistedPct,
                      color: "bg-red-500",
                    },
                  ].map((item) => (
                    <div key={item.label} className="space-y-1">
                      <div className="flex items-center justify-between text-xs text-gray-500">
                        <span>{item.label}</span>
                        <span>{item.count}</span>
                      </div>
                      <div className="h-2 rounded-full bg-gray-100 overflow-hidden">
                        <div className={item.color} style={{ width: `${item.percent}%`, height: "100%" }} />
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              <div className="rounded-2xl border border-gray-200 bg-white p-5">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <Sparkles className="h-4 w-4 text-orange-500" />
                    <h3 className="text-sm font-semibold text-[#1C1C1C]">Top Performers</h3>
                  </div>
                  <span className="text-xs text-gray-400">This month</span>
                </div>
                <div className="mt-4 space-y-3">
                  {isLoading && (
                    <div className="space-y-3">
                      {[1, 2, 3].map((item) => (
                        <div key={item} className="flex items-center gap-3">
                          <Skeleton className="h-10 w-10 rounded-full" />
                          <div className="flex-1 space-y-2">
                            <Skeleton className="h-3 w-3/4" />
                            <Skeleton className="h-3 w-1/2" />
                          </div>
                        </div>
                      ))}
                    </div>
                  )}

                  {!isLoading && topPerformers.length === 0 && (
                    <p className="text-xs text-gray-500">No top performers yet.</p>
                  )}

                  {!isLoading && topPerformers.length > 0 && (
                    <div className="space-y-3">
                      {topPerformers.map((doer) => (
                        <div key={doer.id} className="flex items-center justify-between gap-3">
                          <div className="flex items-center gap-3">
                            <Avatar className="h-9 w-9">
                              <AvatarImage src={doer.avatar_url} alt={doer.full_name} />
                              <AvatarFallback className="bg-gray-100 text-gray-600 text-xs font-semibold">
                                {doer.full_name
                                  .split(" ")
                                  .map((n) => n[0])
                                  .join("")
                                  .slice(0, 2)
                                  .toUpperCase()}
                              </AvatarFallback>
                            </Avatar>
                            <div>
                              <p className="text-sm font-medium text-[#1C1C1C] line-clamp-1">{doer.full_name}</p>
                              <div className="flex items-center gap-1 text-xs text-gray-500">
                                <Star className="h-3 w-3 text-amber-400" />
                                {doer.rating.toFixed(1)}
                              </div>
                            </div>
                          </div>
                          <Button
                            variant="ghost"
                            size="sm"
                            className="text-xs text-orange-600 hover:text-orange-700"
                            onClick={() => handleDoerSelect(doer)}
                          >
                            View
                          </Button>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              </div>
            </aside>

            <section className="space-y-6">
              <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
                <div>
                  <h2 className="text-lg font-semibold text-[#1C1C1C]">Doer Directory</h2>
                  <p className="text-sm text-gray-500">Search, assign, and manage expert doers</p>
                </div>
                <div className="flex items-center gap-2 text-xs text-gray-500">
                  <span className="px-3 py-1 rounded-full bg-orange-50 text-orange-700">
                    Available {stats.available}
                  </span>
                  <span className="px-3 py-1 rounded-full bg-gray-100 text-gray-600">Total {stats.total}</span>
                </div>
              </div>

              {error ? (
                <motion.div
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  className="bg-white rounded-2xl border border-red-200 p-12 text-center"
                >
                  <div className="w-16 h-16 rounded-full bg-red-100 flex items-center justify-center mx-auto mb-4">
                    <AlertTriangle className="h-8 w-8 text-red-500" />
                  </div>
                  <p className="text-red-600 font-semibold text-lg">Failed to load experts</p>
                  <p className="text-gray-500 text-sm mt-2 max-w-md mx-auto">{error.message}</p>
                  <Button
                    variant="outline"
                    onClick={() => window.location.reload()}
                    className="mt-6 border-red-200 text-red-600 hover:bg-red-50"
                  >
                    Try Again
                  </Button>
                </motion.div>
              ) : isLoading ? (
                <div className="grid gap-4 2xl:grid-cols-2">
                  {[...Array(6)].map((_, i) => (
                    <LoadingCard key={i} />
                  ))}
                </div>
              ) : filteredDoers.length === 0 ? (
                <EmptyState hasFilters={hasActiveFilters} onClearFilters={clearFilters} />
              ) : (
                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  transition={{ delay: 0.3, duration: 0.5 }}
                  className="grid gap-4 2xl:grid-cols-2"
                >
                  {filteredDoers.map((doer, index) => (
                    <DoerCard
                      key={doer.id}
                      doer={doer}
                      index={index}
                      onViewProfile={() => handleDoerSelect(doer)}
                      onAssignProject={() => router.push(`/projects?tab=ready`)}
                      onMessage={() => router.push(`/chat?doerId=${doer.id}`)}
                    />
                  ))}
                </motion.div>
              )}
            </section>
          </div>

          <DoerDetails doer={selectedDoer} open={detailsOpen} onOpenChange={setDetailsOpen} />
        </motion.div>
      </div>
    </div>
  )
}
