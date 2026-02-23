/**
 * @fileoverview Commission tracking component showing earnings breakdown per project.
 * @module components/earnings/commission-tracking
 */

"use client"

import { useState, useEffect, useCallback, useMemo } from "react"
import {
  DollarSign,
  TrendingUp,
  Users,
  Briefcase,
  ChevronDown,
  ChevronUp,
  AlertCircle,
} from "lucide-react"
import { format } from "date-fns"

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Skeleton } from "@/components/ui/skeleton"
import { ScrollArea } from "@/components/ui/scroll-area"
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from "@/components/ui/collapsible"
import { createClient } from "@/lib/supabase/client"
import { CommissionBreakdown } from "./types"

/**
 * Loading skeleton for summary cards
 */
function SummaryCardSkeleton() {
  return (
    <Card>
      <CardContent className="pt-6">
        <div className="flex items-center gap-4">
          <Skeleton className="h-12 w-12 rounded-lg" />
          <div className="space-y-2">
            <Skeleton className="h-4 w-24" />
            <Skeleton className="h-8 w-32" />
          </div>
        </div>
      </CardContent>
    </Card>
  )
}

/**
 * Loading skeleton for commission cards
 */
function CommissionCardSkeleton() {
  return (
    <Card>
      <CardContent className="pt-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Skeleton className="h-10 w-10 rounded-lg" />
            <div className="space-y-2">
              <Skeleton className="h-4 w-40" />
              <Skeleton className="h-3 w-20" />
            </div>
          </div>
          <div className="flex items-center gap-4">
            <div className="text-right space-y-2">
              <Skeleton className="h-5 w-24" />
              <Skeleton className="h-3 w-20" />
            </div>
            <Skeleton className="h-8 w-8 rounded" />
          </div>
        </div>
      </CardContent>
    </Card>
  )
}

interface CommissionCardProps {
  commission: CommissionBreakdown
}

function CommissionCard({ commission }: CommissionCardProps) {
  const [isOpen, setIsOpen] = useState(false)

  const doerPercentage = (commission.doer_payout / commission.user_amount) * 100
  const supervisorPercentage = (commission.supervisor_commission / commission.user_amount) * 100
  const platformPercentage = (commission.platform_fee / commission.user_amount) * 100

  return (
    <Collapsible open={isOpen} onOpenChange={setIsOpen}>
      <Card>
        <CardContent className="pt-6">
          <CollapsibleTrigger asChild>
            <div className="flex items-center justify-between cursor-pointer">
              <div className="flex items-center gap-3">
                <div className="h-10 w-10 rounded-lg bg-green-100 flex items-center justify-center">
                  <DollarSign className="h-5 w-5 text-green-600" />
                </div>
                <div>
                  <p className="font-medium">{commission.project_title}</p>
                  <p className="text-xs text-muted-foreground">{commission.project_id}</p>
                </div>
              </div>
              <div className="flex items-center gap-4">
                <div className="text-right">
                  <p className="font-semibold text-green-600">
                    +{commission.supervisor_commission.toLocaleString("en-IN", {
                      style: "currency",
                      currency: "INR",
                      maximumFractionDigits: 0,
                    })}
                  </p>
                  <p className="text-xs text-muted-foreground">
                    {format(new Date(commission.completed_at), "dd MMM yyyy")}
                  </p>
                </div>
                <Button variant="ghost" size="icon" className="h-8 w-8">
                  {isOpen ? (
                    <ChevronUp className="h-4 w-4" />
                  ) : (
                    <ChevronDown className="h-4 w-4" />
                  )}
                </Button>
              </div>
            </div>
          </CollapsibleTrigger>

          <CollapsibleContent>
            <div className="mt-4 pt-4 border-t space-y-4">
              {/* Breakdown Header */}
              <div className="flex items-center justify-between">
                <span className="text-sm text-muted-foreground">Total Project Value</span>
                <span className="font-semibold">
                  {commission.user_amount.toLocaleString("en-IN", {
                    style: "currency",
                    currency: "INR",
                    maximumFractionDigits: 0,
                  })}
                </span>
              </div>

              {/* Visual Breakdown */}
              <div className="h-3 rounded-full overflow-hidden flex">
                <div
                  className="bg-blue-500 h-full"
                  style={{ width: `${doerPercentage}%` }}
                />
                <div
                  className="bg-green-500 h-full"
                  style={{ width: `${supervisorPercentage}%` }}
                />
                <div
                  className="bg-amber-500 h-full"
                  style={{ width: `${platformPercentage}%` }}
                />
              </div>

              {/* Legend */}
              <div className="grid gap-3 md:grid-cols-3">
                <div className="flex items-center gap-2 p-2 bg-muted/30 rounded-lg">
                  <div className="h-3 w-3 rounded-full bg-blue-500" />
                  <div className="flex-1">
                    <p className="text-xs text-muted-foreground">Doer Payout</p>
                    <p className="text-sm font-medium">
                      {commission.doer_payout.toLocaleString("en-IN", {
                        style: "currency",
                        currency: "INR",
                        maximumFractionDigits: 0,
                      })}
                      <span className="text-xs text-muted-foreground ml-1">
                        ({doerPercentage.toFixed(0)}%)
                      </span>
                    </p>
                  </div>
                </div>
                <div className="flex items-center gap-2 p-2 bg-green-50 dark:bg-green-950/30 rounded-lg border border-green-200 dark:border-green-900">
                  <div className="h-3 w-3 rounded-full bg-green-500" />
                  <div className="flex-1">
                    <p className="text-xs text-muted-foreground">Your Commission</p>
                    <p className="text-sm font-medium text-green-600">
                      {commission.supervisor_commission.toLocaleString("en-IN", {
                        style: "currency",
                        currency: "INR",
                        maximumFractionDigits: 0,
                      })}
                      <span className="text-xs text-muted-foreground ml-1">
                        ({supervisorPercentage.toFixed(0)}%)
                      </span>
                    </p>
                  </div>
                </div>
                <div className="flex items-center gap-2 p-2 bg-muted/30 rounded-lg">
                  <div className="h-3 w-3 rounded-full bg-amber-500" />
                  <div className="flex-1">
                    <p className="text-xs text-muted-foreground">Platform Fee</p>
                    <p className="text-sm font-medium">
                      {commission.platform_fee.toLocaleString("en-IN", {
                        style: "currency",
                        currency: "INR",
                        maximumFractionDigits: 0,
                      })}
                      <span className="text-xs text-muted-foreground ml-1">
                        ({platformPercentage.toFixed(0)}%)
                      </span>
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </CollapsibleContent>
        </CardContent>
      </Card>
    </Collapsible>
  )
}

export function CommissionTracking() {
  const [commissions, setCommissions] = useState<CommissionBreakdown[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  const fetchCommissions = useCallback(async () => {
    setIsLoading(true)
    setError(null)

    try {
      const supabase = createClient()

      // Get current user
      const { data: { user }, error: userError } = await supabase.auth.getUser()
      if (userError || !user) {
        throw new Error("Not authenticated")
      }

      // Get supervisor ID from supervisors table
      const { data: supervisor, error: supervisorError } = await supabase
        .from("supervisors")
        .select("id")
        .eq("profile_id", user.id)
        .single()

      if (supervisorError || !supervisor) {
        // User might not be a supervisor yet
        setCommissions([])
        setIsLoading(false)
        return
      }

      // Fetch completed projects with commission breakdown
      const { data: projects, error: projectsError } = await supabase
        .from("projects")
        .select(`
          project_number,
          title,
          user_quote,
          doer_payout,
          supervisor_commission,
          platform_fee,
          completed_at,
          status
        `)
        .eq("supervisor_id", supervisor.id)
        .in("status", ["completed", "auto_approved", "delivered"])
        .not("completed_at", "is", null)
        .order("completed_at", { ascending: false })
        .limit(50)

      if (projectsError) {
        throw projectsError
      }

      // Transform to CommissionBreakdown format
      const transformedCommissions: CommissionBreakdown[] = (projects || []).map((project) => ({
        project_id: project.project_number || "N/A",
        project_title: project.title || "Untitled Project",
        user_amount: project.user_quote || 0,
        doer_payout: project.doer_payout || 0,
        supervisor_commission: project.supervisor_commission || 0,
        platform_fee: project.platform_fee || 0,
        completed_at: project.completed_at || new Date().toISOString(),
      }))

      setCommissions(transformedCommissions)
    } catch (err) {
      console.error("Error fetching commissions:", err)
      setError(err instanceof Error ? err : new Error("Failed to fetch commissions"))
    } finally {
      setIsLoading(false)
    }
  }, [])

  useEffect(() => {
    fetchCommissions()
  }, [fetchCommissions])

  // Calculate summary statistics
  const { totalEarnings, totalProjects, avgCommission } = useMemo(() => {
    const total = commissions.reduce((acc, c) => acc + c.supervisor_commission, 0)
    const count = commissions.length
    return {
      totalEarnings: total,
      totalProjects: count,
      avgCommission: count > 0 ? total / count : 0,
    }
  }, [commissions])

  // Error state
  if (error) {
    return (
      <Card>
        <CardContent className="pt-6">
          <div className="text-center py-8">
            <AlertCircle className="h-12 w-12 text-destructive mx-auto mb-4" />
            <p className="text-destructive font-medium">Failed to load commissions</p>
            <p className="text-sm text-muted-foreground mt-1">{error.message}</p>
            <Button variant="outline" className="mt-4" onClick={fetchCommissions}>
              Try Again
            </Button>
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <div className="space-y-6">
      {/* Summary Cards */}
      <div className="grid gap-4 md:grid-cols-3">
        {isLoading ? (
          <>
            <SummaryCardSkeleton />
            <SummaryCardSkeleton />
            <SummaryCardSkeleton />
          </>
        ) : (
          <>
            <Card>
              <CardContent className="pt-6">
                <div className="flex items-center gap-4">
                  <div className="h-12 w-12 rounded-lg bg-green-100 flex items-center justify-center">
                    <DollarSign className="h-6 w-6 text-green-600" />
                  </div>
                  <div>
                    <p className="text-sm text-muted-foreground">Total Commission</p>
                    <p className="text-2xl font-bold">
                      {totalEarnings.toLocaleString("en-IN", {
                        style: "currency",
                        currency: "INR",
                        maximumFractionDigits: 0,
                      })}
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="pt-6">
                <div className="flex items-center gap-4">
                  <div className="h-12 w-12 rounded-lg bg-blue-100 flex items-center justify-center">
                    <Briefcase className="h-6 w-6 text-blue-600" />
                  </div>
                  <div>
                    <p className="text-sm text-muted-foreground">Projects</p>
                    <p className="text-2xl font-bold">{totalProjects}</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="pt-6">
                <div className="flex items-center gap-4">
                  <div className="h-12 w-12 rounded-lg bg-purple-100 flex items-center justify-center">
                    <TrendingUp className="h-6 w-6 text-purple-600" />
                  </div>
                  <div>
                    <p className="text-sm text-muted-foreground">Avg Commission</p>
                    <p className="text-2xl font-bold">
                      {avgCommission.toLocaleString("en-IN", {
                        style: "currency",
                        currency: "INR",
                        maximumFractionDigits: 0,
                      })}
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </>
        )}
      </div>

      {/* Commission Structure Info */}
      <Card className="bg-muted/30">
        <CardContent className="pt-6">
          <div className="flex items-start gap-4">
            <div className="h-10 w-10 rounded-lg bg-primary/10 flex items-center justify-center shrink-0">
              <Users className="h-5 w-5 text-primary" />
            </div>
            <div>
              <p className="font-medium">Commission Structure</p>
              <p className="text-sm text-muted-foreground mt-1">
                Your commission is calculated as 15% of the total project value. The remaining
                amount is split between the doer (65%) and platform fee (20%).
              </p>
              <div className="flex items-center gap-4 mt-3">
                <Badge variant="secondary" className="bg-blue-100 text-blue-700">
                  Doer: 65%
                </Badge>
                <Badge variant="secondary" className="bg-green-100 text-green-700">
                  Supervisor: 15%
                </Badge>
                <Badge variant="secondary" className="bg-amber-100 text-amber-700">
                  Platform: 20%
                </Badge>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Commission List */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base">Recent Commissions</CardTitle>
          <CardDescription>
            {isLoading
              ? "Loading commissions..."
              : commissions.length > 0
                ? "Click on a project to see the full breakdown"
                : "No completed projects with commissions yet"
            }
          </CardDescription>
        </CardHeader>
        <CardContent>
          <ScrollArea className="h-[calc(100vh-36rem)]">
            <div className="space-y-4 pr-4">
              {isLoading ? (
                <>
                  <CommissionCardSkeleton />
                  <CommissionCardSkeleton />
                  <CommissionCardSkeleton />
                </>
              ) : commissions.length > 0 ? (
                commissions.map((commission) => (
                  <CommissionCard key={commission.project_id} commission={commission} />
                ))
              ) : (
                <div className="text-center py-8">
                  <Briefcase className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
                  <p className="text-muted-foreground">No commissions yet</p>
                  <p className="text-sm text-muted-foreground mt-1">
                    Complete projects to start earning commissions
                  </p>
                </div>
              )}
            </div>
          </ScrollArea>
        </CardContent>
      </Card>
    </div>
  )
}
