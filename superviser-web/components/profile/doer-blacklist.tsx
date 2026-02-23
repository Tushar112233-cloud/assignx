/**
 * @fileoverview Doer blacklist management component for blocking problematic doers.
 * @module components/profile/doer-blacklist
 */

"use client"

import { useState, useMemo } from "react"
import {
  UserX,
  Search,
  Trash2,
  AlertTriangle,
  Clock,
  Star,
  MoreHorizontal,
  Plus,
  Loader2,
} from "lucide-react"
import { formatDistanceToNow } from "date-fns"

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog"
import { Textarea } from "@/components/ui/textarea"
import { Label } from "@/components/ui/label"
import { ScrollArea } from "@/components/ui/scroll-area"
import { toast } from "sonner"
import { cn } from "@/lib/utils"
import { BlacklistedDoer } from "./types"
import { useBlacklistedDoers } from "@/hooks/use-doers"
import { createClient } from "@/lib/supabase/client"

interface DoerCardProps {
  doer: BlacklistedDoer
  onRemove: (id: string) => void
  onViewDetails: (doer: BlacklistedDoer) => void
}

function BlacklistCard({ doer, onRemove, onViewDetails }: DoerCardProps) {
  return (
    <Card>
      <CardContent className="pt-6">
        <div className="flex items-start gap-4">
          <Avatar className="h-12 w-12">
            <AvatarImage src={doer.doer_avatar} alt={doer.doer_name} />
            <AvatarFallback className="bg-red-100 text-red-600">
              {doer.doer_name
                .split(" ")
                .map((n) => n[0])
                .join("")}
            </AvatarFallback>
          </Avatar>
          <div className="flex-1 min-w-0">
            <div className="flex items-start justify-between">
              <div>
                <div className="flex items-center gap-2">
                  <p className="font-medium">{doer.doer_name}</p>
                  <Badge variant="destructive" className="text-[10px]">
                    Blacklisted
                  </Badge>
                </div>
                <div className="flex items-center gap-2 mt-0.5">
                  <div className="flex items-center gap-1 text-xs text-muted-foreground">
                    <Star className="h-3 w-3 fill-amber-400 text-amber-400" />
                    {doer.doer_rating.toFixed(1)}
                  </div>
                  {doer.project_id && (
                    <span className="text-xs text-muted-foreground">
                      From: {doer.project_id}
                    </span>
                  )}
                </div>
              </div>
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <Button variant="ghost" size="icon" className="h-8 w-8">
                    <MoreHorizontal className="h-4 w-4" />
                  </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="end">
                  <DropdownMenuItem onClick={() => onViewDetails(doer)}>
                    View Details
                  </DropdownMenuItem>
                  <DropdownMenuItem
                    onClick={() => onRemove(doer.id)}
                    className="text-destructive"
                  >
                    Remove from Blacklist
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
            </div>

            <p className="mt-2 text-sm text-muted-foreground line-clamp-2">
              {doer.reason}
            </p>

            <div className="flex items-center gap-1 mt-2 text-xs text-muted-foreground">
              <Clock className="h-3 w-3" />
              Blacklisted{" "}
              {formatDistanceToNow(new Date(doer.blacklisted_at), { addSuffix: true })}
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}

export function DoerBlacklist() {
  // Fetch blacklisted doers from Supabase using hook
  const { doers: blacklistedDoersData, isLoading, refetch } = useBlacklistedDoers()
  const [searchQuery, setSearchQuery] = useState("")
  const [selectedDoer, setSelectedDoer] = useState<BlacklistedDoer | null>(null)
  const [showDetailsDialog, setShowDetailsDialog] = useState(false)
  const [showRemoveDialog, setShowRemoveDialog] = useState(false)
  const [doerToRemove, setDoerToRemove] = useState<string | null>(null)
  const [isRemoving, setIsRemoving] = useState(false)

  // Transform hook data to BlacklistedDoer format
  const blacklistedDoers: BlacklistedDoer[] = useMemo(() => {
    return blacklistedDoersData.map((doer) => ({
      id: doer.id,
      doer_id: doer.id,
      doer_name: doer.profiles?.full_name || "Unknown",
      doer_avatar: doer.profiles?.avatar_url || undefined,
      doer_rating: doer.average_rating || 0,
      reason: doer.blacklistReason || "No reason provided",
      blacklisted_at: new Date().toISOString(),
    }))
  }, [blacklistedDoersData])

  const filteredDoers = useMemo(() => {
    return blacklistedDoers.filter((doer) =>
      doer.doer_name.toLowerCase().includes(searchQuery.toLowerCase())
    )
  }, [blacklistedDoers, searchQuery])

  const handleRemove = (id: string) => {
    setDoerToRemove(id)
    setShowRemoveDialog(true)
  }

  const confirmRemove = async () => {
    if (!doerToRemove) return

    setIsRemoving(true)
    try {
      const supabase = createClient()
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) throw new Error("Not authenticated")

      // Get supervisor ID
      const { data: supervisor } = await supabase
        .from("supervisors")
        .select("id")
        .eq("profile_id", user.id)
        .single()

      if (!supervisor) throw new Error("Supervisor not found")

      // Remove from blacklist
      const { error } = await supabase
        .from("supervisor_blacklisted_doers")
        .delete()
        .eq("supervisor_id", supervisor.id)
        .eq("doer_id", doerToRemove)

      if (error) throw error

      toast.success("Doer removed from blacklist")
      await refetch()
    } catch (error) {
      console.error("Error removing doer from blacklist:", error)
      toast.error("Failed to remove doer from blacklist")
    } finally {
      setIsRemoving(false)
      setShowRemoveDialog(false)
      setDoerToRemove(null)
    }
  }

  const handleViewDetails = (doer: BlacklistedDoer) => {
    setSelectedDoer(doer)
    setShowDetailsDialog(true)
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <Card>
        <CardHeader>
          <div className="flex items-start justify-between">
            <div>
              <CardTitle className="text-base flex items-center gap-2">
                <UserX className="h-5 w-5 text-destructive" />
                Doer Blacklist
              </CardTitle>
              <CardDescription>
                Experts you have flagged to avoid in future assignments
              </CardDescription>
            </div>
            <Badge variant="outline">{blacklistedDoers.length} Doers</Badge>
          </div>
        </CardHeader>
        <CardContent>
          <div className="flex items-center gap-2">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Search blacklisted doers..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-9"
              />
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Warning */}
      <div className="flex items-start gap-3 p-4 bg-amber-50 dark:bg-amber-950/30 rounded-lg border border-amber-200 dark:border-amber-900">
        <AlertTriangle className="h-5 w-5 text-amber-600 shrink-0 mt-0.5" />
        <div>
          <p className="text-sm font-medium text-amber-800 dark:text-amber-200">
            About Blacklisted Doers
          </p>
          <p className="text-xs text-amber-700 dark:text-amber-300 mt-1">
            These experts will not appear in your assignment suggestions. You can remove them
            from the blacklist at any time if you wish to work with them again.
          </p>
        </div>
      </div>

      {/* Blacklist */}
      <ScrollArea className="h-[calc(100vh-30rem)]">
        <div className="space-y-4 pr-4">
          {isLoading ? (
            <div className="flex items-center justify-center py-12">
              <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
            </div>
          ) : filteredDoers.length > 0 ? (
            filteredDoers.map((doer) => (
              <BlacklistCard
                key={doer.id}
                doer={doer}
                onRemove={handleRemove}
                onViewDetails={handleViewDetails}
              />
            ))
          ) : (
            <div className="flex flex-col items-center justify-center py-12 text-center">
              <UserX className="h-12 w-12 text-muted-foreground/50 mb-4" />
              <h3 className="text-lg font-medium">
                {searchQuery ? "No doers found" : "No blacklisted doers"}
              </h3>
              <p className="text-sm text-muted-foreground mt-1">
                {searchQuery
                  ? "Try a different search term"
                  : "Doers you flag will appear here"}
              </p>
            </div>
          )}
        </div>
      </ScrollArea>

      {/* Details Dialog */}
      <Dialog open={showDetailsDialog} onOpenChange={setShowDetailsDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Blacklist Details</DialogTitle>
            <DialogDescription>
              Information about this blacklisted doer
            </DialogDescription>
          </DialogHeader>
          {selectedDoer && (
            <div className="space-y-4">
              <div className="flex items-center gap-4">
                <Avatar className="h-16 w-16">
                  <AvatarImage src={selectedDoer.doer_avatar} alt={selectedDoer.doer_name} />
                  <AvatarFallback className="text-xl bg-red-100 text-red-600">
                    {selectedDoer.doer_name
                      .split(" ")
                      .map((n) => n[0])
                      .join("")}
                  </AvatarFallback>
                </Avatar>
                <div>
                  <p className="font-semibold text-lg">{selectedDoer.doer_name}</p>
                  <div className="flex items-center gap-1 text-sm text-muted-foreground">
                    <Star className="h-4 w-4 fill-amber-400 text-amber-400" />
                    {selectedDoer.doer_rating.toFixed(1)} Rating
                  </div>
                </div>
              </div>

              <div className="space-y-2">
                <Label className="text-muted-foreground text-xs">REASON FOR BLACKLISTING</Label>
                <p className="text-sm">{selectedDoer.reason}</p>
              </div>

              {selectedDoer.project_id && (
                <div className="space-y-2">
                  <Label className="text-muted-foreground text-xs">RELATED PROJECT</Label>
                  <p className="text-sm">
                    {selectedDoer.project_title} ({selectedDoer.project_id})
                  </p>
                </div>
              )}

              <div className="space-y-2">
                <Label className="text-muted-foreground text-xs">BLACKLISTED ON</Label>
                <p className="text-sm">
                  {new Date(selectedDoer.blacklisted_at).toLocaleDateString("en-US", {
                    year: "numeric",
                    month: "long",
                    day: "numeric",
                  })}
                </p>
              </div>
            </div>
          )}
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowDetailsDialog(false)}>
              Close
            </Button>
            <Button
              variant="destructive"
              onClick={() => {
                if (selectedDoer) {
                  handleRemove(selectedDoer.id)
                  setShowDetailsDialog(false)
                }
              }}
            >
              <Trash2 className="h-4 w-4 mr-2" />
              Remove from Blacklist
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Remove Confirmation Dialog */}
      <AlertDialog open={showRemoveDialog} onOpenChange={setShowRemoveDialog}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Remove from Blacklist?</AlertDialogTitle>
            <AlertDialogDescription>
              This doer will be available for assignment again. You can always add them
              back to the blacklist later if needed.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel disabled={isRemoving}>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={confirmRemove} disabled={isRemoving}>
              {isRemoving ? (
                <>
                  <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                  Removing...
                </>
              ) : (
                "Remove from Blacklist"
              )}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  )
}
