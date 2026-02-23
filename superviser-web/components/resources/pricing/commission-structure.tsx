/**
 * @fileoverview Visual display of commission structure breakdown.
 * @module components/resources/pricing/commission-structure
 */

"use client"

import { Users, Info } from "lucide-react"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "@/components/ui/tooltip"

interface CommissionStructureProps {
  supervisorPercentage: number
  platformPercentage: number
  doerPercentage: number
}

/**
 * Displays the commission structure breakdown with a visual bar.
 * @param props - Component props containing commission percentages
 */
export function CommissionStructure({ supervisorPercentage, platformPercentage, doerPercentage }: CommissionStructureProps) {
  return (
    <Card>
      <CardHeader>
        <div className="flex items-center gap-3">
          <div className="h-10 w-10 rounded-lg bg-purple-100 flex items-center justify-center">
            <Users className="h-5 w-5 text-purple-600" />
          </div>
          <div>
            <CardTitle className="text-base">Commission Structure</CardTitle>
            <CardDescription>How earnings are distributed</CardDescription>
          </div>
        </div>
      </CardHeader>
      <CardContent>
        <div className="flex items-center gap-2">
          <div className="flex-1 space-y-2">
            <div className="h-8 rounded-lg overflow-hidden flex">
              <div
                className="bg-blue-500 flex items-center justify-center text-xs font-medium text-white"
                style={{ width: `${doerPercentage}%` }}
              >
                Doer {doerPercentage}%
              </div>
              <div
                className="bg-green-500 flex items-center justify-center text-xs font-medium text-white"
                style={{ width: `${supervisorPercentage}%` }}
              >
                You {supervisorPercentage}%
              </div>
              <div
                className="bg-gray-400 flex items-center justify-center text-xs font-medium text-white"
                style={{ width: `${platformPercentage}%` }}
              >
                Platform {platformPercentage}%
              </div>
            </div>
          </div>
          <TooltipProvider>
            <Tooltip>
              <TooltipTrigger>
                <Info className="h-4 w-4 text-muted-foreground" />
              </TooltipTrigger>
              <TooltipContent side="left" className="max-w-[300px]">
                <p className="text-xs">
                  Commission is calculated on the final project amount after all multipliers are applied.
                </p>
              </TooltipContent>
            </Tooltip>
          </TooltipProvider>
        </div>
      </CardContent>
    </Card>
  )
}
