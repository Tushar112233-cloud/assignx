/**
 * @fileoverview Profile editor component for updating supervisor information.
 * @module components/profile/profile-editor
 */

"use client"

import { useState } from "react"
import {
  User,
  Mail,
  Phone,
  GraduationCap,
  Briefcase,
  Save,
  X,
  Camera,
  Building2,
  CreditCard,
  Plus,
} from "lucide-react"

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Badge } from "@/components/ui/badge"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Separator } from "@/components/ui/separator"
import { toast } from "sonner"
import { SupervisorProfile } from "./types"

interface ProfileEditorProps {
  profile: SupervisorProfile
  onSave?: (profile: SupervisorProfile) => void
  onCancel?: () => void
}

export function ProfileEditor({ profile, onSave, onCancel }: ProfileEditorProps) {
  const [editedProfile, setEditedProfile] = useState<SupervisorProfile>(profile)
  const [newExpertise, setNewExpertise] = useState("")
  const [isLoading, setIsLoading] = useState(false)

  const handleInputChange = (field: keyof SupervisorProfile, value: string | number) => {
    setEditedProfile((prev) => ({ ...prev, [field]: value }))
  }

  const handleBankChange = (field: keyof SupervisorProfile["bank_details"], value: string) => {
    setEditedProfile((prev) => ({
      ...prev,
      bank_details: { ...prev.bank_details, [field]: value },
    }))
  }

  const addExpertise = () => {
    if (newExpertise.trim() && !editedProfile.expertise_areas.includes(newExpertise.trim())) {
      setEditedProfile((prev) => ({
        ...prev,
        expertise_areas: [...prev.expertise_areas, newExpertise.trim()],
      }))
      setNewExpertise("")
    }
  }

  const removeExpertise = (area: string) => {
    setEditedProfile((prev) => ({
      ...prev,
      expertise_areas: prev.expertise_areas.filter((a) => a !== area),
    }))
  }

  const handleSave = async () => {
    setIsLoading(true)
    try {
      // Simulate API call
      await new Promise((resolve) => setTimeout(resolve, 1000))
      onSave?.(editedProfile)
      toast.success("Profile updated successfully")
    } catch {
      toast.error("Failed to update profile")
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="space-y-6">
      {/* Profile Picture */}
      <Card className="rounded-2xl border border-gray-200 bg-white shadow-sm">
        <CardHeader>
          <CardTitle className="text-lg font-semibold text-[#1C1C1C]">Profile Picture</CardTitle>
          <CardDescription className="text-sm text-gray-500">
            Update your profile photo
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="flex items-center gap-6">
            <div className="relative">
              <Avatar className="h-24 w-24">
                <AvatarImage src={editedProfile.avatar_url} alt={editedProfile.full_name} />
                <AvatarFallback className="text-2xl">
                  {editedProfile.full_name
                    .split(" ")
                    .map((n) => n[0])
                    .join("")}
                </AvatarFallback>
              </Avatar>
              <Button
                size="icon"
                variant="secondary"
                className="absolute -bottom-1 -right-1 h-8 w-8 rounded-full"
              >
                <Camera className="h-4 w-4" />
              </Button>
            </div>
            <div className="flex-1">
              <p className="text-sm text-gray-500 mb-2">
                Upload a professional photo. JPG, PNG or GIF, max 2MB.
              </p>
              <div className="flex gap-2">
                <Button variant="outline" size="sm">
                  Upload Photo
                </Button>
                <Button variant="ghost" size="sm">
                  Remove
                </Button>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Personal Information */}
      <Card className="rounded-2xl border border-gray-200 bg-white shadow-sm">
        <CardHeader>
          <CardTitle className="text-lg font-semibold text-[#1C1C1C]">Personal Information</CardTitle>
          <CardDescription className="text-sm text-gray-500">
            Update your personal details
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid gap-4 md:grid-cols-2">
            <div className="space-y-2">
              <Label htmlFor="full_name">Full Name</Label>
              <div className="relative">
                <User className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                <Input
                  id="full_name"
                  value={editedProfile.full_name}
                  onChange={(e) => handleInputChange("full_name", e.target.value)}
                  className="pl-9"
                />
              </div>
            </div>
            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <div className="relative">
                <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                <Input
                  id="email"
                  type="email"
                  value={editedProfile.email}
                  onChange={(e) => handleInputChange("email", e.target.value)}
                  className="pl-9"
                  disabled
                />
              </div>
              <p className="text-xs text-gray-500">
                Email cannot be changed. Contact support if needed.
              </p>
            </div>
          </div>

          <div className="grid gap-4 md:grid-cols-2">
            <div className="space-y-2">
              <Label htmlFor="phone">Phone Number</Label>
              <div className="relative">
                <Phone className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                <Input
                  id="phone"
                  value={editedProfile.phone}
                  onChange={(e) => handleInputChange("phone", e.target.value)}
                  className="pl-9"
                />
              </div>
            </div>
            <div className="space-y-2">
              <Label htmlFor="qualification">Highest Qualification</Label>
              <div className="relative">
                <GraduationCap className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                <Input
                  id="qualification"
                  value={editedProfile.qualification}
                  onChange={(e) => handleInputChange("qualification", e.target.value)}
                  className="pl-9"
                />
              </div>
            </div>
          </div>

          <div className="grid gap-4 md:grid-cols-2">
            <div className="space-y-2">
              <Label htmlFor="experience">Years of Experience</Label>
              <div className="relative">
                <Briefcase className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                <Input
                  id="experience"
                  type="number"
                  min="0"
                  value={editedProfile.years_of_experience}
                  onChange={(e) =>
                    handleInputChange("years_of_experience", parseInt(e.target.value) || 0)
                  }
                  className="pl-9"
                />
              </div>
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="bio">Bio</Label>
            <Textarea
              id="bio"
              value={editedProfile.bio || ""}
              onChange={(e) => handleInputChange("bio", e.target.value)}
              placeholder="Tell us about yourself and your expertise..."
              rows={4}
            />
          </div>
        </CardContent>
      </Card>

      {/* Expertise Areas */}
      <Card className="rounded-2xl border border-gray-200 bg-white shadow-sm">
        <CardHeader>
          <CardTitle className="text-lg font-semibold text-[#1C1C1C]">Areas of Expertise</CardTitle>
          <CardDescription className="text-sm text-gray-500">
            Add or remove your subject expertise
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex flex-wrap gap-2">
            {editedProfile.expertise_areas.map((area) => (
              <Badge
                key={area}
                variant="secondary"
                className="gap-1 pr-1"
              >
                {area}
                <Button
                  variant="ghost"
                  size="icon"
                  className="h-4 w-4 p-0 hover:bg-transparent"
                  onClick={() => removeExpertise(area)}
                >
                  <X className="h-3 w-3" />
                </Button>
              </Badge>
            ))}
          </div>
          <div className="flex gap-2">
            <Input
              placeholder="Add new expertise area..."
              value={newExpertise}
              onChange={(e) => setNewExpertise(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && addExpertise()}
            />
            <Button variant="outline" onClick={addExpertise}>
              <Plus className="h-4 w-4 mr-2" />
              Add
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Banking Information */}
      <Card className="rounded-2xl border border-gray-200 bg-white shadow-sm">
        <CardHeader>
          <CardTitle className="text-lg font-semibold text-[#1C1C1C]">Banking Information</CardTitle>
          <CardDescription className="text-sm text-gray-500">
            Update your payout details
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid gap-4 md:grid-cols-2">
            <div className="space-y-2">
              <Label htmlFor="bank_name">Bank Name</Label>
              <div className="relative">
                <Building2 className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                <Input
                  id="bank_name"
                  value={editedProfile.bank_details.bank_name}
                  onChange={(e) => handleBankChange("bank_name", e.target.value)}
                  className="pl-9"
                />
              </div>
            </div>
            <div className="space-y-2">
              <Label htmlFor="account_holder">Account Holder Name</Label>
              <div className="relative">
                <User className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                <Input
                  id="account_holder"
                  value={editedProfile.bank_details.account_holder_name}
                  onChange={(e) => handleBankChange("account_holder_name", e.target.value)}
                  className="pl-9"
                />
              </div>
            </div>
          </div>

          <div className="grid gap-4 md:grid-cols-2">
            <div className="space-y-2">
              <Label htmlFor="account_number">Account Number</Label>
              <div className="relative">
                <CreditCard className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                <Input
                  id="account_number"
                  value={editedProfile.bank_details.account_number}
                  onChange={(e) => handleBankChange("account_number", e.target.value)}
                  className="pl-9"
                />
              </div>
            </div>
            <div className="space-y-2">
              <Label htmlFor="ifsc_code">IFSC Code</Label>
              <Input
                id="ifsc_code"
                value={editedProfile.bank_details.ifsc_code}
                onChange={(e) => handleBankChange("ifsc_code", e.target.value)}
              />
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="upi_id">UPI ID (Optional)</Label>
            <Input
              id="upi_id"
              value={editedProfile.bank_details.upi_id || ""}
              onChange={(e) => handleBankChange("upi_id", e.target.value)}
              placeholder="yourname@upi"
            />
          </div>
        </CardContent>
      </Card>

      <Separator />

      {/* Actions */}
      <div className="flex justify-end gap-3">
        {onCancel && (
          <Button variant="outline" onClick={onCancel}>
            Cancel
          </Button>
        )}
        <Button onClick={handleSave} disabled={isLoading}>
          <Save className="h-4 w-4 mr-2" />
          {isLoading ? "Saving..." : "Save Changes"}
        </Button>
      </div>
    </div>
  )
}
