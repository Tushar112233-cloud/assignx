"use client"

import { useState } from "react"
import {
  ChevronUp,
  ChevronDown,
  MoreHorizontal,
  Copy,
  Eye,
  Edit,
  MessageSquare,
  Check,
} from "lucide-react"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"

interface User {
  id: string
  name: string
  email: string
  avatar?: string
  projects: number
  revenue: number
  status: "active" | "inactive"
  lastActive: Date | string
}

interface UsersTableViewProps {
  users: User[]
  sortColumn: string
  sortDirection: "asc" | "desc"
  onSort: (column: string) => void
  onUserClick?: (user: User) => void
  onActionClick?: (action: string, user: User) => void
  currentPage: number
  pageSize: number
  totalCount: number
  onPageChange: (page: number) => void
  onPageSizeChange: (size: number) => void
}

export function UsersTableView({
  users,
  sortColumn,
  sortDirection,
  onSort,
  onUserClick,
  onActionClick,
  currentPage,
  pageSize,
  totalCount,
  onPageChange,
  onPageSizeChange,
}: UsersTableViewProps) {
  const [copiedEmail, setCopiedEmail] = useState<string | null>(null)

  const getInitials = (name: string) => {
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase()
      .slice(0, 2)
  }

  const formatRevenue = (amount: number) => {
    return new Intl.NumberFormat("en-IN", {
      style: "currency",
      currency: "INR",
      maximumFractionDigits: 0,
    }).format(amount)
  }

  const formatRelativeTime = (date: Date | string) => {
    const now = new Date()
    const then = new Date(date)
    const diffInSeconds = Math.floor((now.getTime() - then.getTime()) / 1000)

    if (diffInSeconds < 60) return "Just now"
    if (diffInSeconds < 3600) return `${Math.floor(diffInSeconds / 60)}m ago`
    if (diffInSeconds < 86400) return `${Math.floor(diffInSeconds / 3600)}h ago`
    if (diffInSeconds < 2592000)
      return `${Math.floor(diffInSeconds / 86400)}d ago`
    return `${Math.floor(diffInSeconds / 2592000)}mo ago`
  }

  const copyEmail = async (email: string) => {
    await navigator.clipboard.writeText(email)
    setCopiedEmail(email)
    setTimeout(() => setCopiedEmail(null), 2000)
  }

  const handleSort = (column: string) => {
    onSort(column)
  }

  const SortIcon = ({ column }: { column: string }) => {
    if (sortColumn !== column) {
      return (
        <ChevronUp className="ml-1 h-3 w-3 text-gray-400 opacity-0 group-hover:opacity-100" />
      )
    }
    return sortDirection === "asc" ? (
      <ChevronUp className="ml-1 h-3 w-3 text-orange-600" />
    ) : (
      <ChevronDown className="ml-1 h-3 w-3 text-orange-600" />
    )
  }

  const totalPages = Math.ceil(totalCount / pageSize)
  const startIndex = (currentPage - 1) * pageSize + 1
  const endIndex = Math.min(currentPage * pageSize, totalCount)

  const getPageNumbers = () => {
    const pages = []
    const maxVisiblePages = 5

    if (totalPages <= maxVisiblePages) {
      for (let i = 1; i <= totalPages; i++) {
        pages.push(i)
      }
    } else {
      if (currentPage <= 3) {
        for (let i = 1; i <= 4; i++) pages.push(i)
        pages.push("...")
        pages.push(totalPages)
      } else if (currentPage >= totalPages - 2) {
        pages.push(1)
        pages.push("...")
        for (let i = totalPages - 3; i <= totalPages; i++) pages.push(i)
      } else {
        pages.push(1)
        pages.push("...")
        for (let i = currentPage - 1; i <= currentPage + 1; i++) pages.push(i)
        pages.push("...")
        pages.push(totalPages)
      }
    }

    return pages
  }

  return (
    <div className="flex flex-col h-full">
      <div className="flex-1 bg-white rounded-2xl border border-gray-200 overflow-hidden">
        <div className="overflow-x-auto">
          <Table>
            <TableHeader className="bg-gray-50 sticky top-0 z-10">
              <TableRow className="hover:bg-gray-50">
                <TableHead
                  className="px-6 py-3 cursor-pointer group"
                  onClick={() => handleSort("name")}
                >
                  <div className="flex items-center text-xs font-bold uppercase text-gray-700">
                    User
                    <SortIcon column="name" />
                  </div>
                </TableHead>
                <TableHead className="px-6 py-3">
                  <div className="flex items-center text-xs font-bold uppercase text-gray-700">
                    Email
                  </div>
                </TableHead>
                <TableHead
                  className="px-6 py-3 cursor-pointer group"
                  onClick={() => handleSort("projects")}
                >
                  <div className="flex items-center text-xs font-bold uppercase text-gray-700">
                    Projects
                    <SortIcon column="projects" />
                  </div>
                </TableHead>
                <TableHead
                  className="px-6 py-3 cursor-pointer group"
                  onClick={() => handleSort("revenue")}
                >
                  <div className="flex items-center text-xs font-bold uppercase text-gray-700">
                    Revenue
                    <SortIcon column="revenue" />
                  </div>
                </TableHead>
                <TableHead className="px-6 py-3">
                  <div className="flex items-center text-xs font-bold uppercase text-gray-700">
                    Status
                  </div>
                </TableHead>
                <TableHead
                  className="px-6 py-3 cursor-pointer group"
                  onClick={() => handleSort("lastActive")}
                >
                  <div className="flex items-center text-xs font-bold uppercase text-gray-700">
                    Last Active
                    <SortIcon column="lastActive" />
                  </div>
                </TableHead>
                <TableHead className="px-6 py-3">
                  <div className="flex items-center text-xs font-bold uppercase text-gray-700">
                    Actions
                  </div>
                </TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {users.map((user) => (
                <TableRow
                  key={user.id}
                  className="hover:bg-gray-50 cursor-pointer transition-colors"
                  onClick={() => onUserClick?.(user)}
                >
                  <TableCell className="px-6 py-4">
                    <div className="flex items-center gap-3">
                      <Avatar className="h-8 w-8">
                        <AvatarImage src={user.avatar} alt={user.name} />
                        <AvatarFallback className="bg-orange-100 text-orange-700 text-xs font-semibold">
                          {getInitials(user.name)}
                        </AvatarFallback>
                      </Avatar>
                      <span className="font-medium text-gray-900">
                        {user.name}
                      </span>
                    </div>
                  </TableCell>
                  <TableCell className="px-6 py-4">
                    <div className="flex items-center gap-2 group">
                      <span className="text-gray-600 text-sm">
                        {user.email}
                      </span>
                      <Button
                        variant="ghost"
                        size="sm"
                        className="h-6 w-6 p-0 opacity-0 group-hover:opacity-100 transition-opacity"
                        onClick={(e) => {
                          e.stopPropagation()
                          copyEmail(user.email)
                        }}
                      >
                        {copiedEmail === user.email ? (
                          <Check className="h-3 w-3 text-green-600" />
                        ) : (
                          <Copy className="h-3 w-3 text-gray-400" />
                        )}
                      </Button>
                    </div>
                  </TableCell>
                  <TableCell className="px-6 py-4">
                    <div className="flex items-center gap-1.5 text-gray-700">
                      <span className="font-medium">{user.projects}</span>
                      <span className="text-sm text-gray-500">projects</span>
                    </div>
                  </TableCell>
                  <TableCell className="px-6 py-4">
                    <span className="font-semibold text-gray-900">
                      {formatRevenue(user.revenue)}
                    </span>
                  </TableCell>
                  <TableCell className="px-6 py-4">
                    <Badge
                      variant={
                        user.status === "active" ? "default" : "secondary"
                      }
                      className={
                        user.status === "active"
                          ? "bg-green-100 text-green-700 hover:bg-green-100"
                          : "bg-gray-100 text-gray-700 hover:bg-gray-100"
                      }
                    >
                      {user.status === "active" ? "Active" : "Inactive"}
                    </Badge>
                  </TableCell>
                  <TableCell className="px-6 py-4">
                    <span className="text-sm text-gray-600">
                      {formatRelativeTime(user.lastActive)}
                    </span>
                  </TableCell>
                  <TableCell className="px-6 py-4">
                    <DropdownMenu>
                      <DropdownMenuTrigger asChild>
                        <Button
                          variant="ghost"
                          size="sm"
                          className="h-8 w-8 p-0"
                          onClick={(e) => e.stopPropagation()}
                        >
                          <MoreHorizontal className="h-4 w-4" />
                        </Button>
                      </DropdownMenuTrigger>
                      <DropdownMenuContent align="end" className="w-48">
                        <DropdownMenuItem
                          onClick={(e) => {
                            e.stopPropagation()
                            onActionClick?.("view", user)
                          }}
                        >
                          <Eye className="mr-2 h-4 w-4" />
                          View Details
                        </DropdownMenuItem>
                        <DropdownMenuItem
                          onClick={(e) => {
                            e.stopPropagation()
                            onActionClick?.("edit", user)
                          }}
                        >
                          <Edit className="mr-2 h-4 w-4" />
                          Edit User
                        </DropdownMenuItem>
                        <DropdownMenuItem
                          onClick={(e) => {
                            e.stopPropagation()
                            onActionClick?.("message", user)
                          }}
                        >
                          <MessageSquare className="mr-2 h-4 w-4" />
                          Send Message
                        </DropdownMenuItem>
                      </DropdownMenuContent>
                    </DropdownMenu>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      </div>

      {/* Pagination */}
      <div className="mt-4 flex flex-wrap items-center justify-between gap-3 px-2">
        <div className="flex items-center gap-4">
          <div className="flex items-center gap-2">
            <span className="text-sm text-gray-600">Rows per page:</span>
            <Select
              value={pageSize.toString()}
              onValueChange={(value) => onPageSizeChange(Number(value))}
            >
              <SelectTrigger className="h-9 w-20">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="10">10</SelectItem>
                <SelectItem value="25">25</SelectItem>
                <SelectItem value="50">50</SelectItem>
                <SelectItem value="100">100</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <span className="text-sm text-gray-600">
            {startIndex}-{endIndex} of {totalCount}
          </span>
        </div>

        <div className="flex flex-wrap items-center gap-2">
          <Button
            variant="outline"
            size="sm"
            onClick={() => onPageChange(currentPage - 1)}
            disabled={currentPage === 1}
            className="h-9"
          >
            Previous
          </Button>

          <div className="flex items-center gap-1">
            {getPageNumbers().map((page, index) => (
              <div key={index}>
                {page === "..." ? (
                  <span className="px-2 text-gray-500">...</span>
                ) : (
                  <Button
                    variant={currentPage === page ? "default" : "outline"}
                    size="sm"
                    onClick={() => onPageChange(page as number)}
                    className={
                      currentPage === page
                        ? "h-9 w-9 bg-orange-600 hover:bg-orange-700"
                        : "h-9 w-9"
                    }
                  >
                    {page}
                  </Button>
                )}
              </div>
            ))}
          </div>

          <Button
            variant="outline"
            size="sm"
            onClick={() => onPageChange(currentPage + 1)}
            disabled={currentPage === totalPages}
            className="h-9"
          >
            Next
          </Button>
        </div>
      </div>
    </div>
  )
}
