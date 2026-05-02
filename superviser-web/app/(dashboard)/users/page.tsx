/**
 * @fileoverview Supervisor users page - redesigned layout and UI
 * @module app/(dashboard)/users/page
 */

"use client"

import { useEffect, useMemo, useRef, useState } from "react"
import { useRouter } from "next/navigation"
import { motion } from "framer-motion"
import { AlertCircle } from "lucide-react"

import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { Skeleton } from "@/components/ui/skeleton"
import { UsersHero } from "@/components/users/v2/users-hero"
import { UsersStatsPills } from "@/components/users/v2/users-stats-pills"
import { InsightsDashboard } from "@/components/users/v2/insights-dashboard"
import { AdvancedFilterBar } from "@/components/users/v2/advanced-filter-bar"
import { UsersSidebar } from "@/components/users/v2/users-sidebar"
import { UserCardEnhanced } from "@/components/users/v2/user-card-enhanced"
import { UsersTableView } from "@/components/users/v2/users-table-view"
import { UsersEmptyState } from "@/components/users/v2/empty-state"
import { UserDetails } from "@/components/users/user-details"
import { useUsers, useUserStats, type UserWithStats } from "@/hooks/use-users"

type ViewMode = "grid" | "table"
type JoinedFilter = "all" | "week" | "month"

const currencyFormatter = new Intl.NumberFormat("en-IN", {
  style: "currency",
  currency: "INR",
  maximumFractionDigits: 0,
})

function UsersGridSkeleton() {
  return (
    <div className="grid gap-6 lg:grid-cols-2 2xl:grid-cols-3">
      {Array.from({ length: 6 }).map((_, index) => (
        <Card key={index} className="bg-white border-gray-200 rounded-2xl">
          <CardContent className="p-6 space-y-5">
            <div className="flex items-start justify-between gap-2">
              <div className="flex items-start gap-3 flex-1">
                <Skeleton className="h-14 w-14 rounded-full flex-shrink-0" />
                <div className="flex-1 space-y-2">
                  <Skeleton className="h-4 w-3/4" />
                  <Skeleton className="h-3.5 w-1/2" />
                </div>
              </div>
              <Skeleton className="h-8 w-8 rounded-lg flex-shrink-0" />
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div className="bg-gray-50 rounded-xl p-3.5 space-y-2">
                <div className="flex items-center gap-1.5">
                  <Skeleton className="h-7 w-7 rounded-lg" />
                  <Skeleton className="h-3 w-16" />
                </div>
                <Skeleton className="h-5 w-10 ml-0.5" />
              </div>
              <div className="bg-gray-50 rounded-xl p-3.5 space-y-2">
                <div className="flex items-center gap-1.5">
                  <Skeleton className="h-7 w-7 rounded-lg" />
                  <Skeleton className="h-3 w-16" />
                </div>
                <Skeleton className="h-4 w-16 ml-0.5" />
              </div>
            </div>
            <div className="flex items-center justify-between pt-4 border-t border-gray-100">
              <Skeleton className="h-3.5 w-24" />
              <Skeleton className="h-6 w-16 rounded-full" />
            </div>
          </CardContent>
        </Card>
      ))}
    </div>
  )
}

export default function UsersPage() {
  const router = useRouter()
  const directoryRef = useRef<HTMLDivElement>(null)

  const [searchQuery, setSearchQuery] = useState("")
  const [statusFilter, setStatusFilter] = useState("all")
  const [projectsFilter, setProjectsFilter] = useState("all")
  const [spendingFilter, setSpendingFilter] = useState("all")
  const [joinedFilter, setJoinedFilter] = useState<JoinedFilter>("all")
  const [sortBy, setSortBy] = useState("recent")
  const [viewMode, setViewMode] = useState<ViewMode>("grid")
  const [selectedUser, setSelectedUser] = useState<UserWithStats | null>(null)
  const [currentPage, setCurrentPage] = useState(1)
  const [pageSize, setPageSize] = useState(10)
  const [tableSortColumn, setTableSortColumn] = useState("lastActive")
  const [tableSortDirection, setTableSortDirection] = useState<"asc" | "desc">("desc")

  // TODO: Implement server-side pagination/filtering for large user bases
  const { users, isLoading, error, totalCount } = useUsers({ limit: 200, offset: 0 })
  const { stats } = useUserStats(users)

  // Stable date references to avoid defeating useMemo (SW-041)
  const [sevenDaysAgo] = useState(() => new Date(Date.now() - 7 * 24 * 60 * 60 * 1000))
  const [thirtyDaysAgo] = useState(() => new Date(Date.now() - 30 * 24 * 60 * 60 * 1000))
  const [startOfMonth] = useState(() => { const now = new Date(); return new Date(now.getFullYear(), now.getMonth(), 1) })

  const isUserActive = (user: UserWithStats) =>
    user.active_projects > 0 ||
    (user.last_active_at && new Date(user.last_active_at).getTime() > thirtyDaysAgo.getTime())

  const filteredUsers = useMemo(() => {
    let result = [...users]

    if (searchQuery) {
      const query = searchQuery.toLowerCase()
      result = result.filter(
        (u) =>
          u.full_name.toLowerCase().includes(query) ||
          u.email.toLowerCase().includes(query) ||
          u.college?.toLowerCase()?.includes(query)
      )
    }

    if (statusFilter === "active") {
      result = result.filter(isUserActive)
    }

    if (statusFilter === "inactive") {
      result = result.filter((u) => !isUserActive(u))
    }

    if (projectsFilter === "has-projects") {
      result = result.filter((u) => u.total_projects > 0)
    }

    if (projectsFilter === "no-projects") {
      result = result.filter((u) => u.total_projects === 0)
    }

    if (spendingFilter === "high") {
      result = result.filter((u) => u.total_spent > 50000)
    }

    if (spendingFilter === "medium") {
      result = result.filter((u) => u.total_spent >= 10000 && u.total_spent <= 50000)
    }

    if (spendingFilter === "low") {
      result = result.filter((u) => u.total_spent < 10000)
    }

    if (joinedFilter === "week") {
      result = result.filter((u) => new Date(u.joined_at) >= sevenDaysAgo)
    }

    if (joinedFilter === "month") {
      result = result.filter((u) => new Date(u.joined_at) >= startOfMonth)
    }

    const sorters: Record<string, (a: UserWithStats, b: UserWithStats) => number> = {
      recent: (a, b) =>
        new Date(b.last_active_at || b.joined_at).getTime() -
        new Date(a.last_active_at || a.joined_at).getTime(),
      "name-asc": (a, b) => a.full_name.localeCompare(b.full_name),
      "name-desc": (a, b) => b.full_name.localeCompare(a.full_name),
      "projects-high": (a, b) => b.total_projects - a.total_projects,
      "projects-low": (a, b) => a.total_projects - b.total_projects,
      "revenue-high": (a, b) => b.total_spent - a.total_spent,
      "revenue-low": (a, b) => a.total_spent - b.total_spent,
    }

    return result.sort(sorters[sortBy] || sorters.recent)
  }, [
    users,
    searchQuery,
    statusFilter,
    projectsFilter,
    spendingFilter,
    joinedFilter,
    sortBy,
    sevenDaysAgo,
    startOfMonth,
    thirtyDaysAgo,
  ])

  const paginatedUsers = useMemo(() => {
    const startIndex = (currentPage - 1) * pageSize
    return filteredUsers.slice(startIndex, startIndex + pageSize)
  }, [filteredUsers, currentPage, pageSize])

  const tableUsers = useMemo(
    () =>
      paginatedUsers.map((user) => ({
        id: user.id,
        name: user.full_name,
        email: user.email,
        avatar: user.avatar_url,
        projects: user.total_projects,
        revenue: user.total_spent,
        status: (isUserActive(user) ? "active" : "inactive") as "active" | "inactive",
        lastActive: user.last_active_at || user.joined_at,
      })),
    [paginatedUsers, thirtyDaysAgo]
  )

  useEffect(() => {
    setCurrentPage(1)
  }, [searchQuery, statusFilter, projectsFilter, spendingFilter, joinedFilter, sortBy])

  useEffect(() => {
    const totalPages = Math.max(1, Math.ceil(filteredUsers.length / pageSize))
    setCurrentPage((prev) => Math.min(prev, totalPages))
  }, [filteredUsers.length, pageSize])

  useEffect(() => {
    const sortToTable = (value: string) => {
      switch (value) {
        case "name-asc":
          return { column: "name", direction: "asc" as const }
        case "name-desc":
          return { column: "name", direction: "desc" as const }
        case "projects-high":
          return { column: "projects", direction: "desc" as const }
        case "projects-low":
          return { column: "projects", direction: "asc" as const }
        case "revenue-high":
          return { column: "revenue", direction: "desc" as const }
        case "revenue-low":
          return { column: "revenue", direction: "asc" as const }
        default:
          return { column: "lastActive", direction: "desc" as const }
      }
    }

    const mapped = sortToTable(sortBy)
    setTableSortColumn(mapped.column)
    setTableSortDirection(mapped.direction)
  }, [sortBy])

  const handleTableSort = (column: string) => {
    if (column === "status") return
    if (column === "lastActive") {
      setTableSortColumn("lastActive")
      setTableSortDirection("desc")
      setSortBy("recent")
      return
    }

    const nextDirection =
      tableSortColumn === column && tableSortDirection === "asc" ? "desc" : "asc"
    setTableSortColumn(column)
    setTableSortDirection(nextDirection)

    if (column === "name") {
      setSortBy(nextDirection === "asc" ? "name-asc" : "name-desc")
      return
    }

    if (column === "projects") {
      setSortBy(nextDirection === "asc" ? "projects-low" : "projects-high")
      return
    }

    if (column === "revenue") {
      setSortBy(nextDirection === "asc" ? "revenue-low" : "revenue-high")
    }
  }

  const totalCompletedProjects = useMemo(
    () => users.reduce((sum, user) => sum + user.completed_projects, 0),
    [users]
  )

  const averageProjectValue =
    totalCompletedProjects > 0
      ? Math.round(stats.totalSpent / totalCompletedProjects)
      : 0

  const activeThisMonth = useMemo(
    () => users.filter(isUserActive).length,
    [users, thirtyDaysAgo]
  )

  const newThisWeek = useMemo(
    () => users.filter((user) => new Date(user.joined_at) >= sevenDaysAgo).length,
    [users, sevenDaysAgo]
  )

  const growthData = useMemo(() => {
    const referenceDate = new Date()
    const months = Array.from({ length: 6 }).map((_, index) => {
      const date = new Date(referenceDate.getFullYear(), referenceDate.getMonth() - 5 + index, 1)
      const label = date.toLocaleString("en-US", { month: "short" })
      const count = users.filter((user) => {
        const joined = new Date(user.joined_at)
        return joined.getMonth() === date.getMonth() && joined.getFullYear() === date.getFullYear()
      }).length

      return { month: label, value: count }
    })

    return months
  }, [users])

  const growthPercentage = useMemo(() => {
    const last = growthData[growthData.length - 1]?.value || 0
    const prev = growthData[growthData.length - 2]?.value || 0
    if (prev === 0) return 0
    return Math.round(((last - prev) / prev) * 100)
  }, [growthData])

  const topClients = useMemo(
    () =>
      [...users]
        .sort((a, b) => b.total_spent - a.total_spent)
        .slice(0, 5)
        .map((user, index) => ({
          id: user.id,
          name: user.full_name,
          avatar: user.avatar_url,
          revenue: user.total_spent,
          rank: index + 1,
        })),
    [users]
  )

  const quickFilters = useMemo(
    () => [
      { id: "active", label: "Active Clients", count: activeThisMonth, color: "green" as const },
      {
        id: "high-value",
        label: "High Value",
        count: users.filter((user) => user.total_spent > 50000).length,
        color: "orange" as const,
      },
      {
        id: "new-week",
        label: "New This Week",
        count: newThisWeek,
        color: "orange" as const,
      },
      {
        id: "new-month",
        label: "New This Month",
        count: users.filter((user) => new Date(user.joined_at) >= startOfMonth).length,
        color: "blue" as const,
      },
      { id: "inactive", label: "Inactive", count: stats.inactive, color: "gray" as const },
    ],
    [activeThisMonth, users, startOfMonth, stats.inactive, newThisWeek]
  )

  const recentActivity = useMemo(() => {
    const items = users.flatMap((user) => {
      const activity = [] as Array<{
        id: string
        type: "project_created" | "project_completed" | "user_joined"
        user_name: string
        user_avatar?: string
        timestamp: string
        description: string
      }>

      if (user.joined_at) {
        activity.push({
          id: `${user.id}-joined`,
          type: "user_joined",
          user_name: user.full_name,
          user_avatar: user.avatar_url,
          timestamp: user.joined_at,
          description: "joined the platform",
        })
      }

      if (user.completed_projects > 0 && user.last_active_at) {
        activity.push({
          id: `${user.id}-completed`,
          type: "project_completed",
          user_name: user.full_name,
          user_avatar: user.avatar_url,
          timestamp: user.last_active_at,
          description: `completed ${user.completed_projects} project${user.completed_projects > 1 ? "s" : ""}`,
        })
      }

      return activity
    })

    return items
      .sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime())
      .slice(0, 8)
  }, [users])

  const activeQuickFilter = useMemo(() => {
    if (joinedFilter === "month") return "new-month"
    if (joinedFilter === "week") return "new-week"
    if (statusFilter === "active") return "active"
    if (statusFilter === "inactive") return "inactive"
    if (spendingFilter === "high") return "high-value"
    return undefined
  }, [joinedFilter, statusFilter, spendingFilter])

  const handleQuickFilter = (filterId: string) => {
    if (filterId === "active") {
      setStatusFilter("active")
      return
    }
    if (filterId === "inactive") {
      setStatusFilter("inactive")
      return
    }
    if (filterId === "high-value") {
      setSpendingFilter("high")
      return
    }
    if (filterId === "new-month") {
      setJoinedFilter("month")
      return
    }
    if (filterId === "new-week") {
      setJoinedFilter("week")
    }
  }

  const handleClearAll = () => {
    setSearchQuery("")
    setStatusFilter("all")
    setProjectsFilter("all")
    setSpendingFilter("all")
    setJoinedFilter("all")
    setSortBy("recent")
  }

  const handlePillClick = (metric: string) => {
    switch (metric) {
      case "total-clients":
        handleClearAll()
        break
      case "active-month":
        setStatusFilter("active")
        break
      case "total-revenue":
        setSpendingFilter("high")
        break
      case "avg-project":
        setProjectsFilter("has-projects")
        break
      case "new-week":
        setJoinedFilter("week")
        break
      default:
        break
    }
  }

  const activeStatKey = useMemo(() => {
    if (joinedFilter === "week") return "new-week"
    if (projectsFilter === "has-projects") return "avg-project"
    if (spendingFilter === "high") return "total-revenue"
    if (statusFilter === "active") return "active-month"
    return undefined
  }, [joinedFilter, projectsFilter, spendingFilter, statusFilter])

  const handleExport = () => {
    const header = ["Name", "Email", "Projects", "Revenue", "Status", "Last Active"]
    const rows = filteredUsers.map((user) => [
      user.full_name,
      user.email,
      user.total_projects.toString(),
      currencyFormatter.format(user.total_spent),
      isUserActive(user) ? "Active" : "Inactive",
      user.last_active_at || user.joined_at,
    ])

    const csv = [header, ...rows]
      .map((row) => row.map((value) => `"${String(value).replace(/"/g, '""')}"`).join(","))
      .join("\n")

    const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" })
    const url = URL.createObjectURL(blob)
    const link = document.createElement("a")
    link.href = url
    link.download = `users-${new Date().toISOString().slice(0, 10)}.csv`
    link.click()
    URL.revokeObjectURL(url)
  }

  const handleViewAll = () => {
    directoryRef.current?.scrollIntoView({ behavior: "smooth", block: "start" })
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.4 }}
        className="max-w-[1400px] mx-auto px-6 lg:px-10 py-8 lg:py-10 space-y-10"
      >
        <UsersHero totalUsers={totalCount} onViewAll={handleViewAll} />

        <section className="space-y-4">
          <div>
            <h2 className="text-xl font-semibold text-[#1C1C1C]">Network Snapshot</h2>
            <p className="text-sm text-gray-500">Live client metrics from your portfolio</p>
          </div>
          <UsersStatsPills
            totalClients={stats.total}
            activeThisMonth={activeThisMonth}
            totalRevenue={stats.totalSpent}
            avgProjectValue={averageProjectValue}
            newThisWeek={newThisWeek}
            onPillClick={handlePillClick}
            activeKey={activeStatKey}
          />
        </section>

        <section className="space-y-4">
          <div className="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-2">
            <div>
              <h2 className="text-xl font-semibold text-[#1C1C1C]">Client Insights</h2>
              <p className="text-sm text-gray-500">Growth and top revenue contributors</p>
            </div>
            <div className="text-sm text-gray-500">
              Total revenue: <span className="font-semibold text-[#1C1C1C]">{currencyFormatter.format(stats.totalSpent)}</span>
            </div>
          </div>
          <InsightsDashboard
            growthData={growthData}
            topClients={topClients}
            growthPercentage={growthPercentage}
          />
        </section>

        <section ref={directoryRef} className="space-y-6">
          <div>
            <h2 className="text-xl font-semibold text-[#1C1C1C]">Client Directory</h2>
            <p className="text-sm text-gray-500">Search, filter, and manage all clients in one place</p>
          </div>

          <AdvancedFilterBar
            searchQuery={searchQuery}
            onSearchChange={setSearchQuery}
            viewMode={viewMode}
            onViewModeChange={setViewMode}
            statusFilter={statusFilter}
            onStatusFilterChange={setStatusFilter}
            projectsFilter={projectsFilter}
            onProjectsFilterChange={setProjectsFilter}
            spendingFilter={spendingFilter}
            onSpendingFilterChange={setSpendingFilter}
            sortBy={sortBy}
            onSortByChange={setSortBy}
            onExport={handleExport}
            onClearAll={handleClearAll}
            extraFilters={
              joinedFilter === "all"
                ? []
                : [
                    {
                      id: "joined",
                      label: joinedFilter === "week" ? "Joined: last 7 days" : "Joined: this month",
                    },
                  ]
            }
            onExtraFilterClear={() => setJoinedFilter("all")}
          />

          <div className="xl:hidden flex items-center gap-2 overflow-x-auto pb-2">
            {quickFilters.map((filter) => {
              const isActive = activeQuickFilter === filter.id
              return (
                <button
                  key={filter.id}
                  onClick={() => handleQuickFilter(filter.id)}
                  className={
                    `inline-flex items-center gap-2 rounded-full border px-4 py-2 text-sm font-medium transition-all ${
                      isActive
                        ? "bg-orange-500 text-white border-orange-500"
                        : "bg-white text-gray-700 border-gray-200 hover:border-orange-300"
                    }`
                  }
                >
                  <span>{filter.label}</span>
                  <span className={isActive ? "text-white/80" : "text-gray-500"}>{filter.count}</span>
                </button>
              )
            })}
          </div>

          <div className="flex items-center justify-between text-sm text-gray-500">
            <p>
              Showing <span className="font-semibold text-[#1C1C1C]">{filteredUsers.length}</span> of{" "}
              <span className="font-semibold text-[#1C1C1C]">{totalCount}</span> clients
            </p>
          </div>

          <div className="grid gap-6 xl:grid-cols-[minmax(0,1fr)_320px]">
            <div className="space-y-6">
              {isLoading ? (
                <UsersGridSkeleton />
              ) : error ? (
                <Card className="bg-white border-gray-200 rounded-2xl">
                  <CardContent className="p-8 text-center space-y-3">
                    <AlertCircle className="h-8 w-8 text-red-500 mx-auto" />
                    <p className="text-red-500">Error loading users: {error.message}</p>
                    <Button variant="outline" onClick={() => window.location.reload()}>
                      Retry
                    </Button>
                  </CardContent>
                </Card>
              ) : filteredUsers.length === 0 ? (
                <UsersEmptyState onClear={handleClearAll} />
              ) : viewMode === "grid" ? (
                <motion.div
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.4 }}
                  className="grid gap-6 lg:grid-cols-2 2xl:grid-cols-3"
                >
                  {paginatedUsers.map((user) => (
                    <UserCardEnhanced key={user.id} user={user} onClick={() => setSelectedUser(user)} />
                  ))}
                  {/* Grid pagination */}
                  {filteredUsers.length > pageSize && (
                    <div className="col-span-full flex items-center justify-between pt-4 border-t border-gray-200">
                      <p className="text-sm text-gray-500">
                        Showing {Math.min((currentPage - 1) * pageSize + 1, filteredUsers.length)}-{Math.min(currentPage * pageSize, filteredUsers.length)} of {filteredUsers.length}
                      </p>
                      <div className="flex gap-2">
                        <Button
                          variant="outline"
                          size="sm"
                          disabled={currentPage <= 1}
                          onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
                        >
                          Previous
                        </Button>
                        <Button
                          variant="outline"
                          size="sm"
                          disabled={currentPage >= Math.ceil(filteredUsers.length / pageSize)}
                          onClick={() => setCurrentPage((p) => p + 1)}
                        >
                          Next
                        </Button>
                      </div>
                    </div>
                  )}
                </motion.div>
              ) : (
                <UsersTableView
                  users={tableUsers}
                  sortColumn={tableSortColumn}
                  sortDirection={tableSortDirection}
                  onSort={handleTableSort}
                  onUserClick={(user) => {
                    const target = users.find((item) => item.id === user.id)
                    if (target) setSelectedUser(target)
                  }}
                  onActionClick={(action, user) => {
                    const target = users.find((item) => item.id === user.id)
                    if (action === "view" && target) setSelectedUser(target)
                  }}
                  currentPage={currentPage}
                  pageSize={pageSize}
                  totalCount={filteredUsers.length}
                  onPageChange={setCurrentPage}
                  onPageSizeChange={setPageSize}
                />
              )}
            </div>

            <UsersSidebar
              quickFilters={quickFilters}
              recentActivity={recentActivity}
              activeFilter={activeQuickFilter}
              onFilterClick={handleQuickFilter}
            />
          </div>
        </section>

        {selectedUser && (
          <UserDetails
            user={selectedUser}
            open={!!selectedUser}
            onOpenChange={(open) => !open && setSelectedUser(null)}
            onChat={(userId) => router.push(`/chat?userId=${userId}`)}
          />
        )}
      </motion.div>
    </div>
  )
}
