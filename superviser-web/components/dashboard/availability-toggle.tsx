/**
 * @fileoverview Supervisor availability toggle for accepting new assignments.
 * @module components/dashboard/availability-toggle
 */

"use client"

import { useState } from "react"
import { Switch } from "@/components/ui/switch"
import { Label } from "@/components/ui/label"
import { createClient } from "@/lib/supabase/client"
import { toast } from "sonner"
import { Loader2 } from "lucide-react"

interface AvailabilityToggleProps {
  initialStatus?: boolean
  userId?: string
  compact?: boolean
}

export function AvailabilityToggle({
  initialStatus = true,
  userId,
  compact = false,
}: AvailabilityToggleProps) {
  const [isAvailable, setIsAvailable] = useState(initialStatus)
  const [isUpdating, setIsUpdating] = useState(false)

  const handleToggle = async (checked: boolean) => {
    if (!userId) return

    setIsUpdating(true)
    const previousValue = isAvailable
    setIsAvailable(checked)

    try {
      const supabase = createClient()

      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      await (supabase as any)
        .from("supervisors")
        .update({
          is_available: checked,
          updated_at: new Date().toISOString(),
        })
        .eq("id", userId)

      toast.success(checked ? "You are now available" : "You are now busy")
    } catch (error) {
      console.error("Error updating availability:", error)
      setIsAvailable(previousValue)
      toast.error("Failed to update availability")
    } finally {
      setIsUpdating(false)
    }
  }

  if (compact) {
    return (
      <div className="flex items-center gap-2">
        {isUpdating ? (
          <Loader2 className="h-3 w-3 animate-spin text-muted-foreground" />
        ) : (
          <span
            className={`h-2 w-2 rounded-full ${
              isAvailable ? "bg-green-500" : "bg-gray-400"
            }`}
          />
        )}
        <span className="text-xs text-muted-foreground">
          {isAvailable ? "Available" : "Busy"}
        </span>
      </div>
    )
  }

  return (
    <div className="flex items-center justify-between gap-4 p-3 rounded-lg border bg-card">
      <div className="flex items-center gap-3">
        <div
          className={`h-3 w-3 rounded-full transition-colors ${
            isAvailable ? "bg-green-500" : "bg-gray-400"
          }`}
        />
        <div>
          <Label htmlFor="availability" className="font-medium">
            {isAvailable ? "Available" : "Busy"}
          </Label>
          <p className="text-xs text-muted-foreground">
            {isAvailable
              ? "Receiving new project requests"
              : "Not receiving new requests"}
          </p>
        </div>
      </div>
      <Switch
        id="availability"
        checked={isAvailable}
        onCheckedChange={handleToggle}
        disabled={isUpdating}
        className="data-[state=checked]:bg-green-500"
      />
    </div>
  )
}
