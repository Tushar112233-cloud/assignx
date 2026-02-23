/**
 * @fileoverview Urgency and complexity multiplier display components.
 * @module components/resources/pricing/multiplier-tables
 */

"use client"

import { Clock, Gauge } from "lucide-react"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { cn } from "@/lib/utils"
import type { UrgencyMultiplier, ComplexityMultiplier } from "./types"

interface UrgencyTableProps {
  multipliers: UrgencyMultiplier[]
}

/**
 * Displays urgency multiplier options in a table format.
 * @param props - Component props containing urgency multipliers
 */
export function UrgencyTable({ multipliers }: UrgencyTableProps) {
  return (
    <Card>
      <CardHeader>
        <div className="flex items-center gap-3">
          <div className="h-10 w-10 rounded-lg bg-amber-100 flex items-center justify-center">
            <Clock className="h-5 w-5 text-amber-600" />
          </div>
          <div>
            <CardTitle className="text-base">Urgency Multipliers</CardTitle>
            <CardDescription>Premiums for faster delivery</CardDescription>
          </div>
        </div>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Urgency Level</TableHead>
              <TableHead>Multiplier</TableHead>
              <TableHead>Description</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {multipliers.map((m) => (
              <TableRow key={m.id}>
                <TableCell>
                  <div className="flex items-center gap-2">
                    <Clock className="h-4 w-4 text-amber-600" />
                    <span className="font-medium">{m.name}</span>
                  </div>
                </TableCell>
                <TableCell>
                  <Badge variant="outline" className={cn(
                    m.multiplier === 1.0 ? "border-green-500 text-green-700" :
                    m.multiplier <= 1.3 ? "border-amber-500 text-amber-700" : "border-red-500 text-red-700"
                  )}>{m.multiplier}x</Badge>
                </TableCell>
                <TableCell className="text-muted-foreground text-sm">{m.description}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  )
}

interface ComplexityCardsProps {
  multipliers: ComplexityMultiplier[]
}

/**
 * Displays complexity multiplier options with examples.
 * @param props - Component props containing complexity multipliers
 */
export function ComplexityCards({ multipliers }: ComplexityCardsProps) {
  return (
    <Card>
      <CardHeader>
        <div className="flex items-center gap-3">
          <div className="h-10 w-10 rounded-lg bg-blue-100 flex items-center justify-center">
            <Gauge className="h-5 w-5 text-blue-600" />
          </div>
          <div>
            <CardTitle className="text-base">Complexity Multipliers</CardTitle>
            <CardDescription>Adjustments based on topic difficulty</CardDescription>
          </div>
        </div>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {multipliers.map((m) => (
            <div key={m.id} className="flex items-start gap-4 p-4 rounded-lg border">
              <Badge variant="outline" className={cn(
                "shrink-0 mt-0.5",
                m.multiplier === 1.0 ? "border-green-500 text-green-700" :
                m.multiplier <= 1.5 ? "border-amber-500 text-amber-700" : "border-red-500 text-red-700"
              )}>{m.multiplier}x</Badge>
              <div className="flex-1 min-w-0">
                <h4 className="font-medium">{m.name}</h4>
                <p className="text-sm text-muted-foreground mb-2">{m.description}</p>
                <div className="flex flex-wrap gap-1.5">
                  {m.examples.map((example, i) => (
                    <Badge key={i} variant="secondary" className="text-xs">{example}</Badge>
                  ))}
                </div>
              </div>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  )
}
