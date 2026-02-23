/**
 * @fileoverview User list component with filtering, sorting, and search.
 * @module components/users/user-list
 */

"use client"

import { useState, useMemo } from "react"
import { Search, SlidersHorizontal, Users, UserCheck, Clock, X, IndianRupee } from "lucide-react"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Card, CardContent } from "@/components/ui/card"
import { Skeleton } from "@/components/ui/skeleton"
import { UserCard } from "./user-card"
import { UserDetails } from "./user-details"
import { User, UserFilterStatus, UserSortOption } from "./types"
import { useUsers, useUserStats } from "@/hooks/use-users"

/** Stats card component */
function StatCard({ label, value, icon: Icon, color, isActive, onClick }: { label: string; value: number | string; icon: typeof Users; color?: string; isActive?: boolean; onClick?: () => void }) {
  return (
    <Card className={isActive ? "ring-2 ring-primary" : onClick ? "cursor-pointer hover:bg-muted/50" : ""} onClick={onClick}>
      <CardContent className="pt-6">
        <div className="flex items-center gap-2">
          <Icon className={`h-5 w-5 ${color || "text-muted-foreground"}`} />
          <div><p className="text-2xl font-bold">{value}</p><p className="text-sm text-muted-foreground">{label}</p></div>
        </div>
      </CardContent>
    </Card>
  )
}

/**
 * User list component with search, filtering and sorting.
 */
export function UserList() {
  const [searchQuery, setSearchQuery] = useState("")
  const [filterStatus, setFilterStatus] = useState<UserFilterStatus>("all")
  const [sortBy, setSortBy] = useState<UserSortOption>("recent")
  const [selectedUser, setSelectedUser] = useState<User | null>(null)

  // Fetch real users from Supabase
  const { users, isLoading, error, totalCount } = useUsers()
  const { stats } = useUserStats(users)

  // useState with initializer is pure (runs once)
  const [thirtyDaysAgo] = useState(() => Date.now() - 30 * 24 * 60 * 60 * 1000)

  const filteredUsers = useMemo(() => {
    let result = [...users]

    if (searchQuery) {
      const query = searchQuery.toLowerCase()
      result = result.filter((u) => u.full_name.toLowerCase().includes(query) || u.email.toLowerCase().includes(query) || u.college?.toLowerCase().includes(query) || u.course?.toLowerCase().includes(query))
    }

    if (filterStatus === "active") {
      result = result.filter((u) => u.active_projects > 0 || (u.last_active_at && new Date(u.last_active_at).getTime() > thirtyDaysAgo))
    }
    if (filterStatus === "inactive") {
      result = result.filter((u) => u.active_projects === 0 && (!u.last_active_at || new Date(u.last_active_at).getTime() <= thirtyDaysAgo))
    }

    const sortFns: Record<UserSortOption, (a: User, b: User) => number> = {
      name_asc: (a, b) => a.full_name.localeCompare(b.full_name),
      name_desc: (a, b) => b.full_name.localeCompare(a.full_name),
      projects_high: (a, b) => b.total_projects - a.total_projects,
      projects_low: (a, b) => a.total_projects - b.total_projects,
      spent_high: (a, b) => b.total_spent - a.total_spent,
      spent_low: (a, b) => a.total_spent - b.total_spent,
      recent: (a, b) => new Date(b.joined_at).getTime() - new Date(a.joined_at).getTime(),
    }
    return result.sort(sortFns[sortBy])
  }, [users, searchQuery, filterStatus, sortBy, thirtyDaysAgo])

  const clearFilters = () => { setSearchQuery(""); setFilterStatus("all"); setSortBy("recent") }
  const hasActiveFilters = searchQuery || filterStatus !== "all"

  return (
    <div className="space-y-6">
      <div className="grid gap-4 md:grid-cols-4">
        <StatCard label="Total Users" value={stats.total} icon={Users} isActive={filterStatus === "all"} onClick={() => setFilterStatus("all")} />
        <StatCard label="Active Users" value={stats.active} icon={UserCheck} color="text-green-600" isActive={filterStatus === "active"} onClick={() => setFilterStatus("active")} />
        <StatCard label="Inactive (30d+)" value={stats.inactive} icon={Clock} color="text-amber-600" isActive={filterStatus === "inactive"} onClick={() => setFilterStatus("inactive")} />
        <StatCard label="Total Revenue" value={`${(stats.totalSpent / 1000).toFixed(0)}k`} icon={IndianRupee} color="text-green-600" />
      </div>

      <Card>
        <CardContent className="pt-6">
          <div className="flex flex-col gap-4 md:flex-row md:items-center">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input placeholder="Search by name, email, college..." value={searchQuery} onChange={(e) => setSearchQuery(e.target.value)} className="pl-9" />
            </div>
            <Select value={sortBy} onValueChange={(v) => setSortBy(v as UserSortOption)}>
              <SelectTrigger className="w-full md:w-[200px]"><SlidersHorizontal className="h-4 w-4 mr-2" /><SelectValue placeholder="Sort by" /></SelectTrigger>
              <SelectContent>
                <SelectItem value="recent">Recently Joined</SelectItem>
                <SelectItem value="name_asc">Name: A to Z</SelectItem>
                <SelectItem value="name_desc">Name: Z to A</SelectItem>
                <SelectItem value="projects_high">Projects: High to Low</SelectItem>
                <SelectItem value="spent_high">Spending: High to Low</SelectItem>
              </SelectContent>
            </Select>
          </div>
          {hasActiveFilters && (
            <div className="flex flex-wrap items-center gap-2 mt-4">
              <span className="text-sm text-muted-foreground">Active filters:</span>
              {searchQuery && <Badge variant="secondary" className="gap-1">Search: {searchQuery}<X className="h-3 w-3 cursor-pointer" onClick={() => setSearchQuery("")} /></Badge>}
              {filterStatus !== "all" && <Badge variant="secondary" className="gap-1 capitalize">Status: {filterStatus}<X className="h-3 w-3 cursor-pointer" onClick={() => setFilterStatus("all")} /></Badge>}
              <Button variant="ghost" size="sm" onClick={clearFilters}>Clear All</Button>
            </div>
          )}
        </CardContent>
      </Card>

      <div className="space-y-4">
        <p className="text-sm text-muted-foreground">Showing {filteredUsers.length} of {totalCount} users</p>
        {filteredUsers.length === 0 ? (
          <Card><CardContent className="pt-6"><div className="text-center py-8"><Users className="h-12 w-12 text-muted-foreground mx-auto mb-4" /><h3 className="text-lg font-medium">No users found</h3><p className="text-sm text-muted-foreground mt-1">Try adjusting your filters</p><Button variant="outline" className="mt-4" onClick={clearFilters}>Clear Filters</Button></div></CardContent></Card>
        ) : (
          <div className="grid gap-4 md:grid-cols-2">{filteredUsers.map((user) => <UserCard key={user.id} user={user} onClick={() => setSelectedUser(user)} />)}</div>
        )}
      </div>

      {selectedUser && <UserDetails user={selectedUser} open={!!selectedUser} onOpenChange={(open) => !open && setSelectedUser(null)} onChat={(userId) => console.log("Chat with user:", userId)} />}
    </div>
  )
}
