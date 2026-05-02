"use client"

import { motion } from "framer-motion"
import { Bell, Search, Settings } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { useAuth } from "@/hooks"

export function DashboardHeader() {
  const { user } = useAuth()

  const userInitials = user?.full_name
    ?.split(" ")
    .map((n: string) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2) || "S"

  return (
    <motion.div
      initial={{ opacity: 0, y: -20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.4 }}
      className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6"
    >
      <div>
        <h1 className="text-2xl font-semibold tracking-tight text-foreground">
          Supervisor Dashboard
        </h1>
        <p className="text-sm text-muted-foreground mt-1">
          Overview of your projects, assignments, and performance
        </p>
      </div>

      <div className="flex items-center gap-3">
        <div className="relative hidden sm:block">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <Input
            placeholder="Search projects..."
            className="pl-9 w-[200px] lg:w-[260px] bg-white border-border/50 rounded-xl"
          />
        </div>

        <Button
          variant="ghost"
          size="icon"
          className="relative rounded-xl bg-white border border-border/50 hover:bg-muted/50"
        >
          <Bell className="h-5 w-5 text-muted-foreground" />
          <span className="absolute top-1.5 right-1.5 h-2 w-2 rounded-full bg-[var(--color-terracotta)]" />
        </Button>

        <Button
          variant="ghost"
          size="icon"
          className="rounded-xl bg-white border border-border/50 hover:bg-muted/50"
        >
          <Settings className="h-5 w-5 text-muted-foreground" />
        </Button>

        <div className="flex items-center gap-3 pl-3 border-l border-border/50">
          <div className="text-right hidden lg:block">
            <p className="text-sm font-medium">{user?.full_name || "Supervisor"}</p>
            <p className="text-xs text-muted-foreground">Supervisor</p>
          </div>
          <Avatar className="h-10 w-10 ring-2 ring-white shadow-sm">
            <AvatarImage src={user?.avatar_url || undefined} />
            <AvatarFallback className="bg-[var(--color-sage)] text-white font-medium">
              {userInitials}
            </AvatarFallback>
          </Avatar>
        </div>
      </div>
    </motion.div>
  )
}
