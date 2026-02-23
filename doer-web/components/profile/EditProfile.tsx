'use client'

import { useState, useRef } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
  User,
  Mail,
  Phone,
  GraduationCap,
  Building2,
  Briefcase,
  Camera,
  Save,
  X,
  Loader2,
  Check,
} from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Badge } from '@/components/ui/badge'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { cn } from '@/lib/utils'
import type { Profile, Doer, Skill, Qualification, ExperienceLevel } from '@/types/database'

interface EditProfileProps {
  /** User profile */
  profile: Profile
  /** Doer data */
  doer: Doer
  /** Available skills */
  skills?: Skill[]
  /** Selected skills */
  selectedSkills?: string[]
  /** Callback when save is clicked */
  onSave?: (data: ProfileFormData) => Promise<void>
  /** Callback when cancelled */
  onCancel?: () => void
  /** Loading state */
  isLoading?: boolean
  /** Additional class name */
  className?: string
}

interface ProfileFormData {
  full_name: string
  phone: string
  avatar_url: string | null
  qualification: Qualification | null
  university_name: string | null
  experience_level: ExperienceLevel | null
  bio: string | null
  skills: string[]
}

/** Qualification options */
const qualificationOptions: { value: Qualification; label: string }[] = [
  { value: 'high_school', label: 'High School' },
  { value: 'undergraduate', label: 'Undergraduate' },
  { value: 'postgraduate', label: 'Postgraduate' },
  { value: 'phd', label: 'PhD' },
]

/** Experience level options */
const experienceOptions: { value: ExperienceLevel; label: string; description: string }[] = [
  { value: 'beginner', label: 'Beginner', description: 'New to academic work' },
  { value: 'intermediate', label: 'Intermediate', description: '1-2 years experience' },
  { value: 'pro', label: 'Professional', description: '3+ years experience' },
]

/** Mock skills for demo */
const mockSkills: Skill[] = [
  { id: '1', name: 'Essay Writing', category: 'Writing', is_active: true },
  { id: '2', name: 'Research', category: 'Research', is_active: true },
  { id: '3', name: 'Data Analysis', category: 'Analytics', is_active: true },
  { id: '4', name: 'PowerPoint', category: 'Presentation', is_active: true },
  { id: '5', name: 'Academic Editing', category: 'Writing', is_active: true },
  { id: '6', name: 'Literature Review', category: 'Research', is_active: true },
  { id: '7', name: 'Case Studies', category: 'Writing', is_active: true },
  { id: '8', name: 'Statistics', category: 'Analytics', is_active: true },
]

/**
 * Edit Profile component
 * Form for updating user profile information
 */
export function EditProfile({
  profile,
  doer,
  skills = mockSkills,
  selectedSkills = ['1', '2', '3'],
  onSave,
  onCancel,
  isLoading,
  className,
}: EditProfileProps) {
  const fileInputRef = useRef<HTMLInputElement>(null)
  const [isSaving, setIsSaving] = useState(false)
  const [success, setSuccess] = useState(false)
  const [error, setError] = useState<string | null>(null)

  // Form state
  const [formData, setFormData] = useState<ProfileFormData>({
    full_name: profile.full_name,
    phone: profile.phone || '',
    avatar_url: profile.avatar_url,
    qualification: doer.qualification,
    university_name: doer.university_name,
    experience_level: doer.experience_level,
    bio: doer.bio,
    skills: selectedSkills,
  })

  /** Handle input change */
  const handleChange = (field: keyof ProfileFormData, value: string | string[] | null) => {
    setFormData((prev) => ({ ...prev, [field]: value }))
    setError(null)
    setSuccess(false)
  }

  /** Toggle skill selection */
  const toggleSkill = (skillId: string) => {
    setFormData((prev) => ({
      ...prev,
      skills: prev.skills.includes(skillId)
        ? prev.skills.filter((id) => id !== skillId)
        : [...prev.skills, skillId],
    }))
  }

  /** Handle avatar upload */
  const handleAvatarClick = () => {
    fileInputRef.current?.click()
  }

  /** Handle file selection */
  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file) {
      // In production, upload to Supabase storage
      const reader = new FileReader()
      reader.onloadend = () => {
        handleChange('avatar_url', reader.result as string)
      }
      reader.readAsDataURL(file)
    }
  }

  /** Handle form submit */
  const handleSubmit = async () => {
    setIsSaving(true)
    setError(null)

    try {
      if (onSave) {
        await onSave(formData)
      } else {
        // Simulate save
        await new Promise((resolve) => setTimeout(resolve, 1000))
      }
      setSuccess(true)
      setTimeout(() => setSuccess(false), 3000)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to save profile')
    } finally {
      setIsSaving(false)
    }
  }

  return (
    <div className={cn('w-full max-w-full overflow-hidden space-y-6', className)}>
      {/* Success/Error alerts */}
      <AnimatePresence>
        {success && (
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
          >
            <Alert className="border-green-500/50 bg-green-50 rounded-xl shadow-sm">
              <Check className="h-4 w-4 text-green-600" />
              <AlertDescription className="text-green-700 font-medium">
                Profile updated successfully!
              </AlertDescription>
            </Alert>
          </motion.div>
        )}
        {error && (
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
          >
            <Alert variant="destructive" className="rounded-xl shadow-sm">
              <AlertDescription>{error}</AlertDescription>
            </Alert>
          </motion.div>
        )}
      </AnimatePresence>

      <div className="grid gap-6 xl:grid-cols-[1.2fr_0.8fr] w-full max-w-full">
        <div className="space-y-6 min-w-0">
          <Card className="overflow-hidden border-slate-200 shadow-sm w-full">
            <div className="h-20 bg-gradient-to-r from-[#5A7CFF]/10 via-[#5A7CFF]/5 to-[#EEF2FF]" />
            <CardContent className="-mt-8 space-y-6 pt-2 p-6">
              <div className="flex flex-wrap items-center gap-4 md:gap-6">
                <div className="relative group flex-shrink-0">
                  <Avatar className="h-24 w-24 md:h-28 md:w-28 border-4 border-background shadow-lg">
                    <AvatarImage src={formData.avatar_url || undefined} alt={formData.full_name} />
                    <AvatarFallback className="text-2xl bg-[#EEF2FF] text-[#5A7CFF]">
                      {formData.full_name.split(' ').map((n) => n[0]).join('').toUpperCase()}
                    </AvatarFallback>
                  </Avatar>
                  <button
                    type="button"
                    onClick={handleAvatarClick}
                    className="absolute inset-0 flex items-center justify-center bg-[#5A7CFF]/60 rounded-full opacity-0 group-hover:opacity-100 transition-all duration-200"
                  >
                    <Camera className="h-6 w-6 text-white" />
                  </button>
                  <input
                    ref={fileInputRef}
                    type="file"
                    accept="image/*"
                    onChange={handleFileChange}
                    className="hidden"
                  />
                </div>
                <div className="flex-1 min-w-0">
                  <h3 className="text-xl font-semibold text-slate-700 truncate">{formData.full_name}</h3>
                  <p className="text-sm text-slate-500 mt-1 truncate">{profile.email}</p>
                  <Button
                    variant="outline"
                    size="sm"
                    className="mt-3 border-[#5A7CFF] text-[#5A7CFF] hover:bg-[#EEF2FF] hover:border-[#5A7CFF] rounded-lg"
                    onClick={handleAvatarClick}
                  >
                    <Camera className="h-4 w-4 mr-2" />
                    Change Photo
                  </Button>
                </div>
              </div>
              <div className="grid gap-4 sm:gap-5 sm:grid-cols-2">
                <div className="space-y-2.5">
                  <Label htmlFor="full_name" className="text-sm font-medium text-slate-700">Full Name</Label>
                  <div className="relative">
                    <User className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
                    <Input
                      id="full_name"
                      value={formData.full_name}
                      onChange={(e) => handleChange('full_name', e.target.value)}
                      placeholder="Your full name"
                      className="w-full pl-10 h-11 rounded-xl border-slate-200 focus:border-[#5A7CFF] focus:ring-2 focus:ring-[#5A7CFF]/20 transition-all"
                    />
                  </div>
                </div>
                <div className="space-y-2.5">
                  <Label htmlFor="email" className="text-sm font-medium text-slate-700">Email</Label>
                  <div className="relative">
                    <Mail className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
                    <Input
                      id="email"
                      value={profile.email}
                      readOnly
                      className="w-full pl-10 h-11 rounded-xl border-slate-200 bg-slate-50"
                    />
                  </div>
                </div>
                <div className="space-y-2.5 sm:col-span-2">
                  <Label htmlFor="phone" className="text-sm font-medium text-slate-700">Phone Number</Label>
                  <div className="relative">
                    <Phone className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
                    <Input
                      id="phone"
                      value={formData.phone}
                      onChange={(e) => handleChange('phone', e.target.value)}
                      placeholder="+91 98765 43210"
                      className="w-full pl-10 h-11 rounded-xl border-slate-200 focus:border-[#5A7CFF] focus:ring-2 focus:ring-[#5A7CFF]/20 transition-all"
                    />
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card className="border-slate-200 shadow-sm w-full">
            <CardHeader className="space-y-1.5 pb-5 px-6 pt-6">
              <CardTitle className="flex items-center gap-2.5 text-slate-700">
                <Briefcase className="h-5 w-5 text-[#5A7CFF]" />
                About You
              </CardTitle>
              <CardDescription className="text-slate-500">Share a quick summary of your expertise</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4 px-6 pb-6">
              <div className="space-y-2.5">
                <Label htmlFor="bio" className="text-sm font-medium text-slate-700">Bio</Label>
                <Textarea
                  id="bio"
                  value={formData.bio || ''}
                  onChange={(e) => handleChange('bio', e.target.value)}
                  placeholder="Tell us about yourself..."
                  rows={4}
                  className="w-full max-w-full rounded-xl border-slate-200 focus:border-[#5A7CFF] focus:ring-2 focus:ring-[#5A7CFF]/20 resize-none transition-all"
                />
              </div>
            </CardContent>
          </Card>

          <Card className="border-slate-200 shadow-sm w-full">
            <CardHeader className="space-y-1.5 pb-5 px-6 pt-6">
              <CardTitle className="flex items-center gap-2.5 text-slate-700">
                <Briefcase className="h-5 w-5 text-[#5A7CFF]" />
                Skills & Expertise
              </CardTitle>
              <CardDescription className="text-slate-500">Select the skills you have experience with</CardDescription>
            </CardHeader>
            <CardContent className="px-6 pb-6">
              <div className="flex flex-wrap gap-2.5 max-w-full">
                {skills.map((skill) => (
                  <Badge
                    key={skill.id}
                    variant={formData.skills.includes(skill.id) ? 'default' : 'outline'}
                    className={cn(
                      'cursor-pointer transition-all rounded-lg px-3.5 py-1.5 text-sm font-medium',
                      formData.skills.includes(skill.id)
                        ? 'bg-[#5A7CFF] hover:bg-[#5A7CFF]/90 text-white border-[#5A7CFF]'
                        : 'hover:bg-[#EEF2FF] hover:border-[#5A7CFF] border-slate-200 text-slate-600'
                    )}
                    onClick={() => toggleSkill(skill.id)}
                  >
                    {skill.name}
                    {formData.skills.includes(skill.id) && (
                      <X className="h-3.5 w-3.5 ml-1.5" />
                    )}
                  </Badge>
                ))}
              </div>
              <p className="text-xs text-slate-500 mt-4 flex items-center gap-1.5">
                <span className="inline-flex items-center justify-center w-5 h-5 rounded-full bg-[#EEF2FF] text-[#5A7CFF] text-xs font-semibold">
                  {formData.skills.length}
                </span>
                skills selected
              </p>
            </CardContent>
          </Card>
        </div>

        <div className="space-y-6 min-w-0">
          <Card className="border-slate-200 shadow-sm w-full">
            <CardHeader className="space-y-1.5 pb-5 px-6 pt-6">
              <CardTitle className="flex items-center gap-2.5 text-slate-700">
                <GraduationCap className="h-5 w-5 text-[#5A7CFF]" />
                Education
              </CardTitle>
              <CardDescription className="text-slate-500">Your academic background and institution</CardDescription>
            </CardHeader>
            <CardContent className="space-y-5 px-6 pb-6">
              <div className="space-y-2.5">
                <Label htmlFor="qualification" className="text-sm font-medium text-slate-700">Qualification</Label>
                <Select
                  value={formData.qualification || undefined}
                  onValueChange={(v) => handleChange('qualification', v as Qualification)}
                >
                  <SelectTrigger
                    id="qualification"
                    className="w-full h-11 rounded-xl border-slate-200 focus:border-[#5A7CFF] focus:ring-2 focus:ring-[#5A7CFF]/20 transition-all"
                  >
                    <SelectValue placeholder="Select qualification" />
                  </SelectTrigger>
                  <SelectContent className="rounded-xl">
                    {qualificationOptions.map((option) => (
                      <SelectItem key={option.value} value={option.value} className="rounded-lg">
                        {option.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2.5">
                <Label htmlFor="university" className="text-sm font-medium text-slate-700">University</Label>
                <div className="relative">
                  <Building2 className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
                  <Input
                    id="university"
                    value={formData.university_name || ''}
                    onChange={(e) => handleChange('university_name', e.target.value)}
                    placeholder="Your university"
                    className="w-full pl-10 h-11 rounded-xl border-slate-200 focus:border-[#5A7CFF] focus:ring-2 focus:ring-[#5A7CFF]/20 transition-all"
                  />
                </div>
              </div>
            </CardContent>
          </Card>

          <Card className="border-slate-200 shadow-sm w-full">
            <CardHeader className="space-y-1.5 pb-5 px-6 pt-6">
              <CardTitle className="flex items-center gap-2.5 text-slate-700">
                <Briefcase className="h-5 w-5 text-[#5A7CFF]" />
                Experience Level
              </CardTitle>
              <CardDescription className="text-slate-500">Highlight your current expertise</CardDescription>
            </CardHeader>
            <CardContent className="px-6 pb-6">
              <div className="grid gap-3 w-full">
                {experienceOptions.map((option) => (
                  <button
                    key={option.value}
                    type="button"
                    onClick={() => handleChange('experience_level', option.value)}
                    className={cn(
                      'w-full p-4 rounded-xl border text-left transition-all duration-200',
                      formData.experience_level === option.value
                        ? 'border-[#5A7CFF] bg-[#EEF2FF] shadow-sm'
                        : 'border-slate-200 hover:border-[#5A7CFF] hover:bg-[#EEF2FF]/50'
                    )}
                  >
                    <p className="font-semibold text-slate-700">{option.label}</p>
                    <p className="text-sm text-slate-500 mt-0.5">{option.description}</p>
                  </button>
                ))}
              </div>
            </CardContent>
          </Card>
        </div>
      </div>

      {/* Action buttons */}
      <Card className="sticky bottom-0 z-10 bg-white/95 backdrop-blur-lg border-slate-200 shadow-lg w-full max-w-full">
        <CardContent className="flex items-center justify-end gap-3 p-5">
          {onCancel && (
            <Button
              variant="outline"
              onClick={onCancel}
              disabled={isSaving}
              className="h-11 px-6 rounded-xl border-slate-200 hover:bg-slate-50 text-slate-700"
            >
              Cancel
            </Button>
          )}
          <Button
            onClick={handleSubmit}
            disabled={isSaving}
            className="h-11 px-8 gap-2 rounded-xl bg-gradient-to-r from-[#5A7CFF] to-[#5A7CFF]/90 hover:from-[#5A7CFF]/90 hover:to-[#5A7CFF]/80 text-white shadow-lg shadow-[#5A7CFF]/25 transition-all duration-200"
          >
            {isSaving ? (
              <>
                <Loader2 className="h-4 w-4 animate-spin" />
                Saving...
              </>
            ) : (
              <>
                <Save className="h-4 w-4" />
                Save Changes
              </>
            )}
          </Button>
        </CardContent>
      </Card>
    </div>
  )
}
